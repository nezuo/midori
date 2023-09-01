local ConcurrentTests = {}
ConcurrentTests.__index = ConcurrentTests

function ConcurrentTests.new()
	return setmetatable({
		testCount = 0,
	}, ConcurrentTests)
end

function ConcurrentTests:execute(callback)
	task.spawn(function()
		self.testCount += 1

		callback()

		self.testCount -= 1

		if self.testCount == 0 then
			task.spawn(self.waitThread)
		end
	end)
end

function ConcurrentTests:wait()
	if self.testCount > 0 then
		self.waitThread = coroutine.running()

		coroutine.yield()
	end
end

local function runNode(node, results, concurrentTests, options)
	local tests = {}

	local function runTest(test)
		if test.skip then
			table.insert(tests, { name = test.name, skipped = true })

			return
		end

		local timeoutThread = nil
		if options.showTimeoutWarning then
			timeoutThread = task.delay(options.timeoutWarningDelay, function()
				warn(`Test '{test.name}' in '{node.modulePath}' exceeded timeout`)
			end)
		end

		local startedAt = os.clock()

		local ok, message = xpcall(test.callback, function(messagePrefix)
			return debug.traceback(tostring(messagePrefix))
		end)

		local duration = os.clock() - startedAt

		if timeoutThread ~= nil then
			task.cancel(timeoutThread)
		end

		if options.concurrent then
			results.duration = math.max(results.duration, duration)
		else
			results.duration += duration
		end

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

	for _, test in node.tests do
		if options.concurrent then
			concurrentTests:execute(function()
				runTest(test)
			end)
		else
			runTest(test)
		end
	end

	local children = {}
	for _, childNode in node.children do
		table.insert(children, runNode(childNode, results, concurrentTests, options))
	end

	return {
		name = node.name,
		isTestModule = node.isTestModule,
		children = children,
		tests = tests,
	}
end

local function run(plan, options)
	local results = {
		errors = {},
		successCount = 0,
		failureCount = 0,
		skippedCount = plan.skipCount,
		duration = 0,
	}

	local concurrentTests = ConcurrentTests.new()

	results.node = runNode(plan.node, results, concurrentTests, options)

	concurrentTests:wait()

	return results
end

return run
