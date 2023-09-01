local createModuleTree = require(script.createModuleTree)
local createPlan = require(script.createPlan)
local reportResults = require(script.reportResults)
local runPlan = require(script.runPlan)

-- should export utility asserts
-- should export shouldThrow
-- handle lifecycle somehow
-- filter tests somehow
-- potentially support running tests in parallel

-- add a timeout for tests. I think this would have to cancel all the rest of the tests because of potential cleanup issues
-- or I can just warn in the console if a test is taking a long time!

-- TODO: Every error should have the correct level

local function runTests(root: Instance)
	local moduleTree = createModuleTree(root)

	if moduleTree == nil then
		print("No tests found")
		return
	end

	local plan = createPlan(moduleTree)

	if plan.skipCount > 0 then
		if plan.hasFocusTest then
			print(`Starting {plan.testCount} focused tests ({plan.skipCount} skipped)`)
		else
			print(`Starting {plan.testCount} tests ({plan.skipCount} skipped)`)
		end
	else
		print(`Starting {plan.testCount} tests`)
	end

	local results = runPlan(plan)

	reportResults(results)
end

return {
	runTests = runTests,
}
