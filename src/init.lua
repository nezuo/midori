local createModuleTree = require(script.createModuleTree)
local createPlan = require(script.createPlan)
local merge = require(script.merge)
local reportResults = require(script.reportResults)
local runPlan = require(script.runPlan)

--[=[
	@interface Config
	@within Midori

	.showTimeoutWarning boolean? -- If `true`, a warning will show if a test runs longer than `timeoutWarningDelay`
	.timeoutWarningDelay number? -- Time in seconds for a test to show a timeout warning
	.concurrent boolean? -- If `true`, all tests will run concurrently
]=]
type Config = {
	showTimeoutWarning: boolean?,
	timeoutWarningDelay: number?,
	concurrent: boolean?,
}

local DEFAULT_CONFIG = {
	showTimeoutWarning = true,
	timeoutWarningDelay = 15,
	concurrent = false,
}

--[=[
	@class Midori
]=]
local Midori = {}

--[=[
	Runs the tests found in all the `.test` modules inside of the `root` instance.

	Example:
	```lua
	Midori.runTests(YourLibrary, {
		timeoutWarningDelay = 10,
	})
	```

	Default config values:
	```lua
	{
		showTimeoutWarning = true,
		timeoutWarningDelay = 15,
		concurrent = false,
	}
	```

	:::caution
	The `concurrent` option should only be used if your tests do not affect each other at all. If used, tests should not access
	variables other tests access. The code that is being tested should also not contain any global state.
	:::

	@param root Instance
	@param config Config?
	@yields
]=]
function Midori.runTests(root: Instance, config: Config?)
	config = merge(DEFAULT_CONFIG, config or {})

	for key in config do
		if DEFAULT_CONFIG[key] == nil then
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

	local results = runPlan(plan, config)

	reportResults(results)
end

return Midori
