local TestService = game:GetService("TestService")

local INDENT = string.rep(" ", 3)

local function truncate(number)
	return string.format("%g", string.format("%.3f", number))
end

local function formatDuration(duration)
	if duration < 0.001 then
		return `{truncate(duration * 1000)}ms`
	else
		local minutes = math.floor(duration / 60 % 60)

		if minutes > 0 then
			local seconds = math.floor(duration - minutes * 60)

			if seconds > 0 then
				return `{minutes}m {seconds}s`
			else
				return `{minutes}m`
			end
		else
			return `{truncate(duration)}s`
		end
	end
end

local function reportNode(node, buffer, level)
	if node.isTestModule then
		table.insert(buffer, `{string.rep(INDENT, level)}🧪 {node.name}`)
	else
		table.insert(buffer, `{string.rep(INDENT, level)}📁 {node.name}`)
	end

	for _, test in node.tests do
		local indent = string.rep(INDENT, level + 1)

		if test.skipped then
			table.insert(buffer, `{indent}⏭️ {test.name}`)
		else
			table.insert(
				buffer,
				`{indent}{if test.success then "✅" else "❌"} {test.name} ({formatDuration(test.duration)})`
			)
		end
	end

	for _, child in node.children do
		reportNode(child, buffer, level + 1)
	end
end

local function reportSummary(results)
	local buffer = {
		"\nResults:\n",
		`{results.successCount} passed, {results.failureCount} failed, {results.skippedCount} skipped in {formatDuration(results.duration)}\n`,
	}

	reportNode(results.node, buffer, 0)

	if #results.errors > 0 then
		table.insert(buffer, "\n")
	end

	print(table.concat(buffer, "\n"))
end

local function reportErrors(results)
	local buffer = { "Errors reported by tests:\n" }

	for _, message in results.errors do
		local lines = string.split(message, "\n")

		local messageBuffer = {}
		for _, line in lines do
			if not string.find(line, "TEST") then
				table.insert(messageBuffer, line)
			end
		end

		table.insert(buffer, table.concat(messageBuffer, "\n"))
	end

	TestService:Error(table.concat(buffer, "\n"))
end

local function report(results)
	reportSummary(results)

	if #results.errors > 0 then
		reportErrors(results)
	end
end

return report
