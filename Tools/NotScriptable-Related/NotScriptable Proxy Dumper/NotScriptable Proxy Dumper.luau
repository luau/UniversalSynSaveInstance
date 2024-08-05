-- Dumps all properties that get changed when NotScriptable property is changed. This means they're somehow related to it and/or are in sync with it
-- Doesnt get everything!
local service = setmetatable({}, {
	__index = function(Self, Name)
		local Service = game:GetService(Name)
		Self[Name] = Service
		return Service
	end,
})
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

	local s = `Doesnt get everything; Also varies per executor; Tested on {identifyexecutor()}\n\n`
	local api = FetchAPI()
	local keys = {}
	for classname in api do
		table.insert(keys, classname)
	end
	table.sort(keys)
	local t = {
		BasePart = Instance.new("Part"),
		Instance = Instance.new("Part"),
		BinaryString = "MTAwMDAwMDAwMDAwMDAwMA==",
		-- bool = nil,
		CFrame = CFrame.new(0, 5, 8),
		OptionalCoordinateFrame = CFrame.new(0, 5, 8),
		Color3uint8 = Color3.new(0.3, 0.5, 0.8),
		Content = "rbxassetid://101332",
		double = 1.53736,
		float = 1.53736,
		int = 1.53736,
		int64 = 1.53736,
		SecurityCapabilities = 1,
		SharedString = "MTAwMDAwMDAwMDAwMDAwMA==",
		string = '{"TEST": "hello"}',
		UniqueId = "00000000000001000000000000000000",
		Vector2 = Vector2.new(1, 23),
		Vector3 = Vector3.new(1, 23, 15),
		Vector3int16 = Vector3.new(1, 23, 15),
	}
	local Parent = Instance.new("MeshPart")
	Parent.Anchored = true
	Parent.Parent = workspace
	local RS = game:GetService("RunService")
	for _, ClassName in keys do
		local ClassInfo = api[ClassName]
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
				-- writefile("crasher.txt", ClassName)
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
		-- print(ClassName)
		for _, PropertyInfo in ClassInfo.Properties do
			local PropertyName = PropertyInfo.Name

			if instance then
				writefile("crasher.txt", ClassName .. "." .. PropertyName)
				if instance.Parent == nil and instance ~= game then
					local O, err = pcall(function()
						instance.Parent = Parent
					end)
					if not O then
						print("Parent Error", err)
					end
				end
				local alreadynoted = {}
				local IsValueBase = instance:IsA("ValueBase")
				-- local cor = coroutine.running()
				local function f(descriptor)
					if descriptor == PropertyName or alreadynoted[descriptor] then
						return
					end

					alreadynoted[descriptor] = true
					local str = ClassName .. "." .. PropertyName .. " - " .. descriptor
					s ..= str .. "\n"

					return str
				end

				local listen = (IsValueBase and game.ItemChanged or instance.Changed):Connect(
					IsValueBase
							and function(obj, descriptor)
								if obj == instance then
									f(descriptor)
									-- task.defer(coroutine.resume, cor)
								end
							end
						or function(descriptor)
							local str = f(descriptor)
							if str then
								warn(str)
							end
							-- task.defer(coroutine.resume, cor)
						end
				)
				--
				local value = nil

				local ValueType = PropertyInfo.ValueType

				if PropertyInfo.Category == "Enum" then
					if not pcall(function()
						value = Enum[ValueType]:GetEnumItems()[1]
					end) then
						warn("Enum", ValueType)
					end
				else
					value = t[ValueType]
				end

				if not value and ValueType ~= "bool" then
					print(PropertyInfo.ValueType)
				end
				local O, err = pcall(sethiddenproperty, instance, PropertyName, value)

				if ValueType == "bool" then
					O, err = pcall(sethiddenproperty, instance, PropertyName, true)
					if not O then
						print("SetProp Error", err)
					end
					O, err = pcall(sethiddenproperty, instance, PropertyName, false)
					if not O then
						print("SetProp Error", err)
					end
				end
				-- task.delay(0.1, coroutine.resume, cor)
				-- coroutine.yield()
				-- listen:Disconnect()

				task.wait(0.01)

				listen:Disconnect()
			end
		end
		if prevsiz ~= #s then
			s ..= "\n"
		end
	end
	warn("Finished")
	-- warn(s)
	writefile("!proxy.txt", s)

	-- writefile("!missing.txt", game:GetService("HttpService"):JSONEncode(t))
end
