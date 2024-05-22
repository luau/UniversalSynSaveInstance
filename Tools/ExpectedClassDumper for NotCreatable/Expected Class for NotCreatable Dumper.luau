-- ! Meant for Studio

local GlobalSettings, GlobalBasicSettings = settings(), UserSettings()
local service = setmetatable({}, {
	__index = function(self, index)
		local Service = game:GetService(index)
			or GlobalSettings:GetService(index)
			or GlobalBasicSettings:GetService(index)
		self[index] = Service
		return Service
	end,
})

service.HttpService.HttpEnabled = true

local function ArrayToDictionary(Table, HybridMode)
	local tmp = table.create(#Table)

	if HybridMode == "adjust" then
		for Some1, Some2 in Table do
			if type(Some1) == "number" then
				tmp[Some2] = true
			elseif type(Some2) == "table" then
				tmp[Some1] = ArrayToDictionary(Some2, "adjust") -- Some1 is Class, Some2 is Name
			else
				tmp[Some1] = Some2
			end
		end
	else
		for _, Key in Table do
			tmp[Key] = true
		end
	end

	return tmp
end
local s = "\n"
do
	local function FetchAPI()
		local API_Dump_Url =
			"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
		local API_Dump = service.HttpService:GetAsync(API_Dump_Url, true)
		local API_Classes = service.HttpService:JSONDecode(API_Dump).Classes

		for _index_0 = 1, #API_Classes do
			local API_Class = API_Classes[_index_0]
			local ClassName = API_Class.Name
			local ClassMembers = API_Class.Members

			for _index_1 = 1, #ClassMembers do
				local Member = ClassMembers[_index_1]
				local MemberName = Member.Name
				local MemberType = Member.MemberType
				if MemberType == "Property" then
					local Serialization = Member.Serialization

					if Serialization.CanLoad and Serialization.CanSave then
						local ValueType = Member.ValueType
						if ValueType.Category == "Class" and ValueType.Name ~= "Instance" then
							-- warn(ClassName, MemberName, ValueType.Name)
							s ..= ClassName .. "." .. MemberName .. " {" .. ValueType.Name .. "}\n"
						end
					end
				end
			end
		end
	end

	local ok, result = pcall(FetchAPI)

	if ok then
		print(s)
	else
		warn(result)
	end
end
