--[=[
	Throws if the callback doesn't error or if the error does not contain `substring`.

	```lua
	-- This will not throw because the callback errors with a string containing "needle"
	shouldThrow(function()
		error("haystick with a needle")
	end, "needle")
	```

	@within x

	@param callback () -> ()
	@param substring string?
]=]
local function shouldThrow(callback: () -> (), substring: string?)
	local ok, err = pcall(callback)

	err = tostring(err)

	if ok then
		error("expected callback to throw, but it didn't throw", 2)
	elseif substring ~= nil and string.find(err, substring, 1, true) == nil then
		error(`expected callback to throw an error containing {substring}, but it threw: {err}`, 2)
	end
end

return shouldThrow
