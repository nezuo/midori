local createModuleTree = require(script.createModuleTree)
local createPlan = require(script.createPlan)
local merge = require(script.merge)
local reportResults = require(script.reportResults)
local runPlan = require(script.runPlan)

type Options = {
	showTimeoutWarning: boolean?,
	timeoutWarningDelay: number?,
	concurrent: boolean?,
}

local DEFAULT_OPTIONS = {
	showTimeoutWarning = true,
	timeoutWarningDelay = 15,
	concurrent = false,
}

local function runTests(root: Instance, options: Options?)
	options = merge(DEFAULT_OPTIONS, options or {})

	for key in options do
		if DEFAULT_OPTIONS[key] == nil then
			error(`'{key}' is not an option`, 2)
		end
	end

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

	local results = runPlan(plan, options)

	reportResults(results)
end

return {
	runTests = runTests,
}
