-- Prints all important yet hidden (NotScriptable) properties that could be missing from saveinstace file after it's done saving
-- due to broken gethiddenproperty on certain executors, therefore we must check all of these and verify it doesn't happen
-- if it does then please make an issue/pull request
-- Example of such case: Color3uint8 is prefered way to save Part's Color but this property is NotScriptable and might fail on certain executors therefore we must add a fallback redirect!

-- Only types to fail so far: BinaryString, SharedString, Color3uint8

local service = setmetatable({}, {
	__index = function(Self, Name)
		local Service = game:GetService(Name)
		Self[Name] = Service
		return Service
	end,
})
-- service.HttpService.HttpEnabled = true
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

do
	-- TODO: More @ https://github.com/Dekkonot/rbx-instance-serializer/blob/23f772f6f78af879a21faa9fea3e6c4f93d1cdee/src/API.lua#L19

	local function FetchAPI()
		local API_Dump_Url =
			"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
		local API_Dump = game:HttpGet(API_Dump_Url, true)
		local API_Classes = service.HttpService:JSONDecode(API_Dump).Classes

		local classList = {}
		local InheritorsIndex = {}
		for _index_0 = 1, #API_Classes do
			local API_Class = API_Classes[_index_0]
			local ClassMembers = API_Class.Members

			local Class = {}

			local ClassName = API_Class.Name

			local ClassTags = API_Class.Tags

			if ClassTags then
				ClassTags = ArrayToDictionary(ClassTags)
			end

			-- ClassInfo.Name = ClassName
			Class.Tags = ClassTags -- or {}
			local Superclass = API_Class.Superclass
			Class.Superclass = Superclass

			local SuperclassInheritors = InheritorsIndex[Superclass]
			if SuperclassInheritors then
				table.insert(SuperclassInheritors, ClassName)
			else
				SuperclassInheritors = { ClassName }
				InheritorsIndex[Superclass] = SuperclassInheritors
			end

			local ClassProperties = {}

			for _index_1 = 1, #ClassMembers do
				local Member = ClassMembers[_index_1]
				if Member.MemberType == "Property" then
					local PropertyName = Member.Name

					-- ? We avoid this as some Instances like services may have this property locked and thus make file unable to open and it's not even used by Roblox anyways as Parent-Child relationship is done by embedding/nesting

					local Ignored = false
					if not (Ignored and Ignored[PropertyName]) then
						local MemberTags = Member.Tags

						local Special

						if MemberTags then
							MemberTags = ArrayToDictionary(MemberTags)

							Special = MemberTags.NotScriptable
						end
						local Serialization = Member.Serialization
						if Serialization.CanLoad and Serialization.CanSave and Special then
							local ValueType = Member.ValueType

							local Property = {
								Name = PropertyName,
								Category = ValueType.Category,
								Default = Member.Default,
								-- Tags = MemberTags,
								ValueType = ValueType.Name,
							}

							if Special then
								Property.Special = true
							end

							ClassProperties[PropertyName] = Property
						end
					end
				end
			end
			local ClassInheritors = InheritorsIndex[ClassName]
			if not ClassInheritors then
				ClassInheritors = {}
				InheritorsIndex[ClassName] = ClassInheritors
			end
			Class.Inheritors = ClassInheritors
			Class.Properties = ClassProperties

			classList[ClassName] = Class
		end

		-- classList.Instance.Properties.Parent = nil -- ? Not sure if this is a better option than filtering throguh properties to remove this

		return classList
	end

	local s = `Varies per executor; Tested on {identifyexecutor()}\n\n`
	for ClassName, ClassInfo in FetchAPI() do
		local instance

		local _
		_, instance = pcall(Instance.new, ClassName)
		if not _ then
			instance = nil
			if ClassName == "UserGameSettings" then
				instance = UserSettings():GetService("UserGameSettings")
			elseif ClassName == "UserSettings" then
				instance = UserSettings()
			elseif ClassName == "GlobalSettings" then
				instance = settings()
			elseif ClassName == "TerrainRegion" then
				instance = workspace.Terrain:CopyRegion(Region3int16.new())
			end
			if ClassInfo.Tags and ClassInfo.Tags.Service and ClassName ~= "VoiceChatInternal" then
				-- writefile("crasher", ClassName)
				pcall(function()
					instance = game:GetService(ClassName)
				end)
				if not instance then
					pcall(function()
						instance = game:GetService(ClassName)
					end)
				end
			end
			if not instance then
				instance = game:FindFirstChild(ClassName, true)
				if not instance then
					instance = game:FindFirstChildWhichIsA(ClassName, true)
					if not instance then
						for i, Inheritor_ClassName in ClassInfo.Inheritors do
							_, instance = pcall(Instance.new, Inheritor_ClassName)
							if _ then
								warn("Success!")
								break
							else
								instance = nil
							end
						end
					end
				end
			end
		end
		local prevsiz = #s

		local gethiddenproperty_fallback
		do
			local UGCValidationService = service.UGCValidationService

			gethiddenproperty_fallback = function(instance, propertyName)
				return UGCValidationService:GetPropertyValue(instance, propertyName) -- :)
			end
		end

		for _, PropertyInfo in ClassInfo.Properties do
			local PropertyName = PropertyInfo.Name
			local o, r = true, true
			if instance then
				o, r = pcall(gethiddenproperty, instance, PropertyName)
				if not o then
					local oo, rr = pcall(gethiddenproperty_fallback, instance, PropertyName)
					if rr == nil then
						o = false
					elseif oo then
						o = oo
						r = rr
					end
				end
			else
				o = nil
			end
			if o == nil or o == false then
				s ..= ClassName .. "." .. PropertyName .. ` {if o == nil then "{NotCreatable Class}" else ""} {if o
						== false
					then r
					else ""}\n`
			end
			-- (not o and warn or print)(ClassName, PropertyName, not o and r or "")
		end
		if prevsiz ~= #s then
			s ..= "\n"
		end
	end
	warn("Finished")
	writefile("!missing.txt", s)
end
