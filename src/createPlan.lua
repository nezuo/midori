local function shouldThrow(callback: () -> (), substring: string)
	local ok, err = pcall(callback)

	err = tostring(err)

	if ok then
		error("expected callback to throw, but it didn't throw", 2)
	elseif substring ~= nil and string.find(err, substring, 1, true) == nil then
		error(`expected callback to throw an error containing {substring}, but it threw: {err}`)
	end
end

local function assertType(name, value, expected)
	if typeof(value) ~= expected then
		error(`{name} must be a {expected}`, 3)
	end
end

local function createPlanNode(moduleNode)
	local planNode = {
		name = moduleNode.name,
		modulePath = moduleNode.modulePath,
		isTestModule = moduleNode.callback ~= nil,
		children = {},
		tests = {},
		beforeEaches = {},
		afterEaches = {},
	}

	for _, child in moduleNode.children do
		table.insert(planNode.children, createPlanNode(child))
	end

	if moduleNode.callback == nil then
		return planNode
	end

	local nodeStack = { planNode }

	local function createTestCallback(options)
		return function(name: string, callback: () -> ())
			assertType("name", name, "string")
			assertType("callback", callback, "function")

			table.insert(nodeStack[#nodeStack].tests, {
				name = name,
				focus = options.focus,
				skip = options.skip,
				callback = callback,
			})
		end
	end

	local function beforeEach(callback: ({}) -> ())
		table.insert(nodeStack[#nodeStack].beforeEaches, callback)
	end

	local function afterEach(callback: ({}) -> ())
		table.insert(nodeStack[#nodeStack].afterEaches, callback)
	end

	local function nested(name: string, callback: () -> ())
		assertType("name", name, "string")
		assertType("callback", callback, "function")

		local nestedNode = {
			name = name,
			modulePath = moduleNode.modulePath,
			isTestModule = true,
			children = {},
			tests = {},
			beforeEaches = {},
			afterEaches = {},
		}

		table.insert(nodeStack[#nodeStack].children, nestedNode)

		table.insert(nodeStack, nestedNode)
		callback()
		table.remove(nodeStack, #nodeStack)
	end

	moduleNode.callback({
		test = createTestCallback({ focus = false, skip = false }),
		testSKIP = createTestCallback({ focus = false, skip = true }),
		testFOCUS = createTestCallback({ focus = true, skip = false }),
		beforeEach = beforeEach,
		afterEach = afterEach,
		nested = nested,
		shouldThrow = shouldThrow,
	})

	return planNode
end

local function visitTests(node, callback)
	for _, test in node.tests do
		callback(test)
	end

	for _, child in node.children do
		visitTests(child, callback)
	end
end

local function concatLists(a, b)
	local new = table.clone(a)

	for _, value in b do
		table.insert(new, value)
	end

	return new
end

local function inheritLifecycleHooks(node, parentBeforeEaches, parentAfterEaches)
	node.beforeEaches = concatLists(parentBeforeEaches, node.beforeEaches)
	node.afterEaches = concatLists(parentAfterEaches, node.afterEaches)

	for _, child in node.children do
		inheritLifecycleHooks(child, node.beforeEaches, node.afterEaches)
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

	inheritLifecycleHooks(node, {}, {})

	return {
		node = node,
		hasFocusTest = hasFocusTest,
		testCount = testCount,
		skipCount = skipCount,
	}
end

return createPlan
