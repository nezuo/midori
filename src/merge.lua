local function merge(a, b)
	local new = table.clone(a)

	for key, value in b do
		new[key] = value
	end

	return new
end

return merge
