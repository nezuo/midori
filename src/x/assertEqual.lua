--[=[
    Throws if `left ~= right`.

	```lua
	-- This will throw because 1 is not equal to 2.
    assertEqual(1, 2)
	```

	@within x

	@param left any
	@param right any
]=]
local function assertEqual(left: any, right: any)
	if left ~= right then
		error(`expected left == right\n  left: {left}\n  right: {right}`, 2)
	end
end

return assertEqual
