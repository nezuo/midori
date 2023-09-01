local function shouldThrow(callback: () -> (), substring: string)
	local ok, err = pcall(callback)

	err = tostring(err)

	if ok then
		error("expected callback to throw, but it didn't throw", 2)
	elseif substring ~= nil and string.find(err, substring, 1, true) == nil then
		error(`expected callback to throw an error containing {substring}, but it threw: {err}`)
	end
end

local function createPlanNode(moduleTree)
	local tests = {}

	if moduleTree.callback ~= nil then
		local function createTestCallback(options)
			return function(name: string, callback: () -> ())
				if typeof(name) ~= "string" then
					error("name must be a string", 2)
				end

				if typeof(callback) ~= "function" then
					error("callback must be a string", 2)
				end

				table.insert(tests, {
					name = name,
					focus = options.focus,
					skip = options.skip,
					callback = callback,
				})
			end
		end

		local x = {
			test = createTestCallback({ focus = false, skip = false }),
			testSKIP = createTestCallback({ focus = false, skip = true }),
			testFOCUS = createTestCallback({ focus = true, skip = false }),
			shouldThrow = shouldThrow,
		}

		moduleTree.callback(x)
	end

	local children = {}

	for _, child in moduleTree.children do
		table.insert(children, createPlanNode(child))
	end

	return {
		name = moduleTree.name,
		modulePath = moduleTree.modulePath,
		isTestModule = moduleTree.callback ~= nil,
		children = children,
		tests = tests,
	}
end

local function visitTests(node, callback)
	for _, test in node.tests do
		callback(test)
	end

	for _, child in node.children do
		visitTests(child, callback)
	end
end

local function focusedTest(node)
	for _, test in node.tests do
		if test.focus then
			return true
		end
	end

	for _, child in node.children do
		if focusedTest(child) then
			return true
		end
	end

	return false
end

local function createPlan(moduleTree)
	local node = createPlanNode(moduleTree)

	local hasFocusTest = focusedTest(node)

	if hasFocusTest then
		visitTests(node, function(test)
			if not test.focus then
				test.skip = true
			end
		end)
	end

	local testCount = 0
	local skipCount = 0

	visitTests(node, function(test)
		if test.skip then
			skipCount += 1
		else
			testCount += 1
		end
	end)

	return {
		node = node,
		hasFocusTest = hasFocusTest,
		testCount = testCount,
		skipCount = skipCount,
	}
end

return createPlan
