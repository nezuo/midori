local function isTestModule(instance)
	return instance:IsA("ModuleScript") and instance.Name:match("%.test$") ~= nil
end

local function isInitTestModule(instance)
	return instance:IsA("ModuleScript") and instance.Name == "init.test"
end

local function removeTestSuffix(name)
	return string.gsub(name, "%.test$", "")
end

local function createModuleTree(instance)
	local initModule = nil
	local children = {}

	for _, child in instance:GetChildren() do
		if isInitTestModule(child) then
			initModule = child
			continue
		end

		local childNode = createModuleTree(child)

		if childNode ~= nil then
			table.insert(children, childNode)
		end
	end

	if initModule ~= nil or isTestModule(instance) then
		local module = if initModule ~= nil then initModule else instance

		local value = require(module)
		local valueType = typeof(value)

		if valueType ~= "function" then
			error(`Expected test module '{module:GetFullName()}' to return a function, got a {valueType}`)
		end

		return {
			name = removeTestSuffix(instance.Name),
			callback = value,
			children = children,
		}
	elseif #children > 0 then
		return {
			name = instance.Name,
			children = children,
		}
	else
		return nil
	end
end

return createModuleTree
