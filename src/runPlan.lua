local function runNode(node, results)
	local tests = {}
	for _, test in node.tests do
		if test.skip then
			table.insert(tests, { name = test.name, skipped = true })

			continue
		end

		local startedAt = os.clock()

		local ok, message = xpcall(test.callback, function(messagePrefix)
			return debug.traceback(tostring(messagePrefix))
		end)

		local duration = os.clock() - startedAt

		results.duration += duration

		if not ok then
			results.failureCount += 1
			table.insert(results.errors, message)
		else
			results.successCount += 1
		end

		table.insert(tests, {
			name = test.name,
			skipped = false,
			success = ok,
			message = message,
			duration = duration,
		})
	end

	local children = {}
	for _, childNode in node.children do
		table.insert(children, runNode(childNode, results))
	end

	return {
		name = node.name,
		isTestModule = node.isTestModule,
		children = children,
		tests = tests,
	}
end

local function run(plan)
	local results = {
		errors = {},
		successCount = 0,
		failureCount = 0,
		skippedCount = plan.skipCount,
		duration = 0,
	}

	results.node = runNode(plan.node, results)

	return results
end

return run
