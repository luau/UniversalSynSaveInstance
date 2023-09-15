--!native
local Params = {
	RepoURL = "https://raw.githubusercontent.com/luau/SomeHub/main/",
	UMF = "UniversalMethodFinder",
	ROM = "RequireOnlineModule",
}
local finder, globalcontainer = loadstring(game:HttpGet(Params.RepoURL .. Params.UMF .. ".luau", true), Params.UMF)()

finder({
	appendfile = '(...):find("file",nil,true) and (...):find("append",nil,true)',
	decompile = '(...):find("decomp",nil,true) or (...):find("assembl",nil,true)',
	base64_encode = '(...):find("encode",nil,true)', -- ! Could match some unwanted stuff
	gethiddenproperty = '(...):find("get",nil,true) and (...):find("h",nil,true) and (...):find("prop",nil,true) and (...):sub(#...) ~= "s"',
	readbinarystring = '(...):find("bin",nil,true)', -- ! Could match some unwanted stuff
	getnilinstances = '(...):find("nil",nil,true)', -- ! Could match some unwanted stuff
	getproperties = '(...):find("get",nil,true) and (...):find("prop",nil,true) and (...):sub(#...) == "s"',
	getspecialinfo = '(...):find("get",nil,true) and (...):find("spec",nil,true)',
	writefile = '(...):find("file",nil,true) and (...):find("write",nil,true)',
}, true)

local decompile = globalcontainer.decompile
local gethiddenproperty = globalcontainer.gethiddenproperty
local getproperties = globalcontainer.getproperties
local appendfile = globalcontainer.appendfile

-- local function Find(String, Pattern)
-- 	return String:find(Pattern, nil, true)
-- end

local GlobalSettings, GlobalBasicSettings = settings(), UserSettings()
local service = setmetatable({}, {
	__index = function(Self, Name)
		local Service = game:GetService(Name) or GlobalSettings:GetService(Name) or GlobalBasicSettings:GetService(Name)
		Self[Name] = Service
		return Service
	end,
})

local SpecialProperties = {
	UnionOperation = {
		AssetId = "Content",
		ChildData = "BinaryString",
		FormFactor = { Category = "Enum" }, -- No need to specify Name as Enums's ValueType Names are identical to the name of the Property/Enum
		InitialSize = "Vector3",
		MeshData = "BinaryString",
		PhysicsData = "BinaryString",
	},
	MeshPart = {
		InitialSize = "Vector3",
		PhysicsData = "BinaryString",
	},
	Terrain = {
		MaterialColors = "BinaryString",
		PhysicsGrid = "BinaryString",
		SmoothGrid = "BinaryString",
	},
	Instance = {
		Tags = "BinaryString",
		AttributesReplicate = "BinaryString",
		AttributesSerialize = "BinaryString",
		Attributes = "BinaryString",
	},
	BinaryStringValue = {
		Value = "BinaryString",
	},
	StyleRule = {
		PropertiesSerialize = "BinaryString",
	},
	Part = {
		CollisionGroupReplicate = "BinaryString",
	},
	RotationCurve = {
		ValuesAndTimes = "BinaryString",
	},
	MarkerCurve = {
		ValuesAndTimes = "BinaryString",
	},
	FloatCurve = {
		ValuesAndTimes = "BinaryString",
	},
	LocalizationTable = {
		Contents = "BinaryString",
	},
	KeyframeSequence = {
		GuidBinaryString = "BinaryString",
	},
	AnimationRigData = {
		preTransform = "BinaryString",
		postTransform = "BinaryString",
		transform = "BinaryString",
		label = "BinaryString",
		name = "BinaryString",
		weight = "BinaryString",
		parent = "BinaryString", -- Could be an instance..
	},
	CurveAnimation = {
		GuidBinaryString = "BinaryString",
	},
}

local EscapesPattern = "[\"&<>']"
local Escapes = {
	['"'] = "&quot;",
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	["'"] = "&apos;",
}

local Descriptors
Descriptors = {
	__ENUM = function(raw)
		return raw.Value, "token"
	end,
	__BIT = function(...)
		local Value = 0

		for Index, Bit in { ... } do
			if Bit then
				Value += 2 ^ (Index - 1)
			end
		end

		return Value
	end,
	Axes = function(raw)
		return "<axes>" .. Descriptors.__BIT(raw.X, raw.Y, raw.Z) .. "</axes>", "Axes"
	end,
	-- BinaryString = function(raw)

	-- end
	-- BrickColor = function(raw) -- ! This might hurt Color3 / Color3uint8 properties
	-- 	return raw.Number,"int"
	-- end,
	CFrame = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		return "<X>"
			.. X
			.. "</X><Y>"
			.. Y
			.. "</Y><Z>"
			.. Z
			.. "</Z><R00>"
			.. R00
			.. "</R00><R01>"
			.. R01
			.. "</R01><R02>"
			.. R02
			.. "</R02><R10>"
			.. R10
			.. "</R10><R11>"
			.. R11
			.. "</R11><R12>"
			.. R12
			.. "</R12><R20>"
			.. R20
			.. "</R20><R21>"
			.. R21
			.. "</R21><R22>"
			.. R22
			.. "</R22>",
			"CoordinateFrame"
	end,
	Color3 = function(raw)
		return "Color3", "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>" -- ? It is recommended that Color3 is encoded with elements instead of text.
	end,
	ColorSequence = function(raw)
		local ConvertedArray = {}
		local Keypoints = raw.Keypoints
		for _index_2 = 1, #Keypoints do
			local v = Keypoints[_index_2]
			local Value = v.Value
			ConvertedArray[#ConvertedArray + 1] = v.Time .. " " .. Value.R .. " " .. Value.G .. " " .. Value.B .. " 0"
		end

		return table.concat(ConvertedArray, " "), "ColorSequence"
	end,
	Content = function(raw)
		return raw and "<url>" .. Descriptors.string(raw) .. "</url>" or "<null></null>", "Content"
	end,
	Faces = function(raw)
		return "<faces>"
			.. Descriptors.__BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front)
			.. "</faces>",
			"Faces"
	end,
	Font = function(raw)
		return "<Family>"
			.. Descriptors.Content(raw.Family)
			.. "</Family><Weight>"
			.. Descriptors.__ENUM(raw.Weight)
			.. "</Weight><Style>"
			.. raw.Style.Name -- Weird but this field accepts .Name of enum instead..
			.. "</Style>", --TODO: Figure out how to determine this.. (Content) <CachedFaceId><url>rbxasset://fonts/GothamSSm-Medium.otf</url></CachedFaceId>
			"Font"
	end,
	NumberRange = function(raw)
		return raw.Min .. " " .. raw.Max, --[[.. " "]] -- ! This might be required to bypass detections as thats how its formatted usually
			"NumberRange"
	end,
	NumberSequence = function(raw)
		local ob = {}
		local Keypoints = raw.Keypoints
		for _index_2 = 1, #Keypoints do
			local v = Keypoints[_index_2]
			ob[#ob + 1] = v.Time .. " " .. v.Value .. " " .. v.Envelope
		end

		return table.concat(ob, " "), "NumberSequence"
	end,
	PhysicalProperties = function(raw)
		return raw
				and "<CustomPhysics>true</CustomPhysics><Density>" .. raw.Density .. "</Density><Friction>" .. raw.Friction .. "</Friction><Elasticity>" .. raw.Elasticity .. "</Elasticity><FrictionWeight>" .. raw.FrictionWeight .. "</FrictionWeight><ElasticityWeight>" .. raw.ElasticityWeight .. "</ElasticityWeight>"
			or "<CustomPhysics>false</CustomPhysics>",
			"PhysicalProperties"
	end,
	-- ProtectedString = function(raw)
	-- 	return tostring(raw), "ProtectedString"
	-- end,
	Ray = function(raw)
		local Origin, Direction = raw.Origin, raw.Direction

		return "<origin><X>"
			.. Origin.X
			.. "</X><Y>"
			.. Origin.Y
			.. "</Y><Z>"
			.. Origin.Z
			.. "</Z></origin><direction><X>"
			.. Direction.X
			.. "</X><Y>"
			.. Direction.Y
			.. "</Y><Z>"
			.. Direction.Z
			.. "</Z></direction>",
			"Ray"
	end,
	Rect = function(raw)
		local Min, Max = raw.Min, raw.Max

		return "<min><X>"
			.. Min.X
			.. "</X><Y>"
			.. Min.Y
			.. "</Y></min><max><X>"
			.. Max.X
			.. "</X><Y>"
			.. Max.Y
			.. "</Y></max>",
			"Rect2D"
	end,
	UDim = function(raw)
		return "<S>" .. raw.Scale .. "</S><O>" .. raw.Offset .. "</O>", "UDim"
	end,
	UDim2 = function(raw)
		local X, Y = raw.X, raw.Y

		return "<XS>"
			.. X.Scale
			.. "</XS><XO>"
			.. X.Offset
			.. "</XO><YS>"
			.. Y.Scale
			.. "</YS><YO>"
			.. Y.Offset
			.. "</YO>",
			"UDim2"
	end,
	Vector2 = function(raw)
		return "<X>" .. raw.X .. "</X><Y>" .. raw.Y .. "</Y>", "Vector2"
	end,
	Vector3 = function(raw)
		return "<X>" .. raw.X .. "</X><Y>" .. raw.Y .. "</Y><Z>" .. raw.Z .. "</Z>", "Vector3"
	end,
	bool = function(raw)
		return tostring(raw), "bool"
	end,
	-- double = function(raw)
	-- 	return "double", raw -- ? wouldn't float be better as an optimization
	-- Todo A precision of at least 17 is required to properly represent a 64-bit floating point value, so this amount is recommended.
	-- end,
	-- float = function(raw)
	-- 	return "float", raw
	-- Todo A precision of at least 9 is required to properly represent a 32-bit floating point value, so this amount is recommended.
	-- end,
	string = function(raw)
		return raw:gsub(EscapesPattern, Escapes), "string"
	end,
}

for StaysRaw in
	{
		"double", -- ? wouldn't float tag be better as an optimization (assuming it rounds)
		--TODO A precision of at least 17 is required to properly represent a 64-bit floating point value, so this amount is recommended.
		"float", -- TODO A precision of at least 9 is required to properly represent a 32-bit floating point value, so this amount is recommended.
		"int",
		"int64",
	}
do
	Descriptors[StaysRaw] = function(raw)
		return raw, StaysRaw
	end
end

local function ReturnSpecialValues(instance)
	local ObtainedValues = {}

	local specialpropslist = SpecialProperties[instance.ClassName]

	if specialpropslist then
		local gotproperties

		for Property in specialpropslist do
			local Value
			if gethiddenproperty then
				Value = gethiddenproperty(instance, Property)
			end
			if
				Value == nil --[[or Value == ""]]
				and getproperties
			then
				if not gotproperties then
					gotproperties = getproperties(instance)
				end
				Value = gotproperties[Property]
			end

			ObtainedValues[Property] = Value
		end
	end

	return ObtainedValues -- Just in case
end

if globalcontainer.getspecialinfo then
	local getreal = globalcontainer.getspecialinfo

	globalcontainer.getspecialinfo = function(instance)
		local specialinfo = getreal(instance)

		for Property, Value in ReturnSpecialValues(instance) do
			if specialinfo[Property] == nil then
				specialinfo[Property] = Value
			end
		end

		return specialinfo
	end
else
	globalcontainer.getspecialinfo = ReturnSpecialValues
end

local getspecialinfo = globalcontainer.getspecialinfo

local b64encode = globalcontainer.base64_encode
	or loadstring(game:HttpGet(Params.RepoURL .. Params.ROM .. ".luau", true), Params.ROM)()(4544052033).base64_encode
	or loadstring(
		game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/Libraries/Hash.lua", true),
		"HashLib"
	)().base64_encode

local ldeccache = {}

local synsaveinstance = function(...)
	local buffersize
	local placename
	local savebuffer
	local stlgui

	local OPTIONS = {
		mode = "optimized", -- Change this to invalid mode like "custom" if you only want extrainstances
		noscripts = false,
		scriptcache = true,
		-- decomptype = "new", -- * Deprecated
		timeout = 30,
		--* New:
		ExtraInstances = false,
		IsolateStarterPlayer = false,
		NilInstances = true,
		ShowStatus = true,
	}
	do
		local Input = ...
		if type(Input) == "table" then
			for key, value in Input do
				if OPTIONS[key] ~= nil then
					OPTIONS[key] = value
				end
			end
		end
	end

	local rwait
	do
		local rswait = service.RunService.RenderStepped
		rwait = function()
			rswait:Wait()
		end
	end

	local ldecompile
	do
		if OPTIONS.noscripts then
			ldecompile = function(Script)
				return "-- " .. Script:GetFullName() .. " not decompiled because the option is off"
			end
		else
			ldecompile = function(Script)
				-- local name = scr.ClassName .. scr.Name
				do
					if OPTIONS.scriptcache then
						local Cached = ldeccache[Script]
						if Cached then
							return Cached
						end
					else
						rwait()
					end
				end
				local ok, result = pcall(decompile, Script, OPTIONS.timeout, OPTIONS.timeout)
				ldeccache[Script] = result
				return ok and result or "--[[\n" .. result .. "\n--]]"
			end
		end
	end
	local ToSaveList
	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = OPTIONS.ExtraInstances or {}

		if mode == "full" then
			local _list_0 = game:GetChildren()
			for _index_0 = 1, #_list_0 do
				local x = _list_0[_index_0]
				table.insert(tmp, x)
			end
		elseif mode == "optimized" then
			local _list_0 = {
				"Chat",
				"InsertService",
				"JointsService",
				"Lighting",
				"ReplicatedFirst",
				"ReplicatedStorage",
				"ServerStorage",
				"StarterGui",
				"StarterPack",
				"StarterPlayer",
				"Teams",
				"Workspace",
			}
			for _index_0 = 1, #_list_0 do
				local x = _list_0[_index_0]
				table.insert(tmp, service[x])
			end
		elseif mode == "scripts" then
			local hierarchy = game:GetDescendants()

			for _index_0 = 1, #hierarchy do
				local instance = hierarchy[_index_0]
				local ClassName = instance.ClassName
				if ClassName == "LocalScript" or ClassName == "ModuleScript" then
					local Parent = instance.Parent
					while Parent and Parent ~= game do
						instance = Parent
					end
					if Parent then
						table.insert(tmp, instance)
					end
				end
			end
		end
		ToSaveList = tmp
	end
	local InstancesBlacklist
	do
		local tmp = {}
		for _, v in
			{
				"BubbleChat",
				"Camera",
				"CameraScript",
				"ChatScript",
				"ControlScript",
				"ClientChatModules",
				"ChatServiceRunner",
				"ChatModules",
			}
		do
			tmp[v] = true
		end
		InstancesBlacklist = tmp
	end
	local NilInstancesBlacklist = {
		Animator = function(instance)
			local AnimationController = Instance.new("AnimationController")
			AnimationController.Name = "Animator has to be placed under Humanoid or AnimationController"
			instance.Parent = AnimationController
			return AnimationController
		end,
	}

	--local PropertyQueue = {} --TODO: Hidden Properties
	local FetchAPI = function()
		local API_Dump_Version = game:HttpGet("https://setup.rbxcdn.com/versionQTStudio", true)
		local API_Dump_Url = string.format("https://setup.rbxcdn.com/%s-API-Dump.json", API_Dump_Version)
		local API_Dump = game:HttpGet(API_Dump_Url, true)
		local API_Classes = service.HttpService:JSONDecode(API_Dump).Classes

		local ClassList = {}

		for _index_0 = 1, #API_Classes do
			local Class = API_Classes[_index_0]
			local ClassMembers = Class.Members

			local ClassInfo = {}

			local ClassName = Class.Name

			local ClassTags = Class.Tags
			ClassInfo.Name = ClassName
			ClassInfo.Tags = ClassTags
			ClassInfo.Superclass = Class.Superclass

			local ClassProperties = {}
			local AssumedSpecialProperties = SpecialProperties[ClassName]

			--[[ --TODO: Hidden Properties
			local Unfiltered_ClassProperties = {}
			local Creatable = not (ClassTags and table.find(ClassTags, "NotCreatable"))
			local AssumedSpecialProperties --, IsService 

			if
				Creatable or IsService
			then
				local ok, ClassReplica
				
					if IsService then
					ok, ClassReplica = pcall(function()
						return service[ClassName]
					end)
				elseif ClassName == "Terrain" then
					ok, ClassReplica = true, workspace.Terrain
				elseif ClassName == "GlobalSettings" then
					ClassReplica = GlobalSettings
				elseif ClassName == "UserSettings" then
					ClassReplica = GlobalBasicSettings
				else
				ok, ClassReplica = pcall(Instance.new, ClassName)

				--end
				if
					ok and ClassReplica
				then
					if getproperties then
						AssumedSpecialProperties = table.clone(getproperties(ClassReplica))
					end

					if getspecialinfo then
						local specialinfo = getspecialinfo(ClassReplica)
						if specialinfo then
							if AssumedSpecialProperties then
								for Property, Value in specialinfo do
									local Existing = AssumedSpecialProperties[Property]
									if Existing ~= nil and Existing ~= Value then
										print(
											"Differs",
											Existing,
											Value,
											type(Existing),
											type(Value),
											typeof(Existing),
											typeof(Value)
										)
									end
									AssumedSpecialProperties[Property] = Value
								end
							else
								AssumedSpecialProperties = table.clone(specialinfo) -- Just incase its shallow
							end
						end
					end
				end
			end]]

			for _index_1 = 1, #ClassMembers do
				local Member = ClassMembers[_index_1]
				if Member.MemberType == "Property" then
					local PropertyName = Member.Name
					---TODO: Hidden Properties
					if AssumedSpecialProperties then
						AssumedSpecialProperties[PropertyName] = nil
					end

					local Serialization = Member.Serialization

					if Serialization.CanLoad then
						local Allowed = true

						local MemberTags = Member.Tags

						if MemberTags then
							for _index_2 = 1, #MemberTags do
								local Tag = MemberTags[_index_2]

								local NotScriptable = Tag == "NotScriptable"

								if NotScriptable or Tag == "Deprecated" then
									if NotScriptable then
										local ValueInfo = Member.ValueType
										local ValueType = ValueInfo.Name

										local Value = { ValueType = ValueType, Category = ValueInfo.Category }

										local SpecialClass = SpecialProperties[ClassName]
										if SpecialClass then
											SpecialClass[PropertyName] = Value
										else
											SpecialProperties[ClassName] = { [PropertyName] = Value }
										end
										local Clone = table.clone(Value)
										Clone.Special = true
										ClassProperties[PropertyName] = Clone
									end

									Allowed = false
								end
							end
						end
						if Allowed then
							local ValueInfo = Member.ValueType
							local PropertyInfo = { ValueType = ValueInfo.Name, Category = ValueInfo.Category }
							ClassProperties[PropertyName] = PropertyInfo
						end
					end

					--Unfiltered_ClassProperties[MemberName] = PropertyInfo --TODO: Hidden Properties
				end
			end
			--[[ --TODO: Hidden Properties
			if AssumedSpecialProperties then
				table.insert(PropertyQueue, {
					AssumedSpecialProperties = AssumedSpecialProperties,
					ClassName = ClassName,
					ClassProperties = ClassProperties,
				})
			end]]

			ClassInfo.Properties = ClassProperties
			--ClassInfo.UnfilteredProperties = Unfiltered_ClassProperties --TODO: Hidden Properties
			ClassList[ClassName] = ClassInfo
		end
		for ClassName, propertyList in SpecialProperties do
			local Properties = ClassList[ClassName].Properties
			for Property, ValueType in propertyList do
				if not Properties[Property] then
					local Value
					if type(ValueType) == "table" then
						Value = table.clone(ValueType)
						Value.Special = true
					else
						Value = { ValueType = ValueType, Special = true }
					end

					Properties[Property] = Value
				end
			end
		end
		return ClassList
	end
	local ClassList
	do
		local ok, result = pcall(FetchAPI)
		if ok then
			ClassList = result
		else
			warn(result)
			return
		end
	end
	local function Inheritor(
		Self,
		ClassName --[[, unfiltered]] --TODO: Hidden Properties
	)
		local proplist = {}
		local layer = ClassList[ClassName]
		while layer do
			local _list_0 = --[[unfiltered and layer.UnfilteredProperties or]] --TODO: Hidden Properties
				layer.Properties
			for _index_0 = 1, #_list_0 do
				local p = _list_0[_index_0]
				table.insert(proplist, p)
			end
			layer = ClassList[layer.Superclass]
		end
		table.sort(
			proplist,
			function(a, b) -- ? We do this as properties are always alphabetically sorted normally so Roblox might be able to detect us opening saveinstanced file if we don't do this
				return a.Name < b.Name
			end
		)
		-- if Self then  --TODO: Hidden Properties
		Self[ClassName] = proplist
		-- end
		return proplist
	end

	local properties = setmetatable({}, {
		__index = Inheritor,
	})
	local identifiers = setmetatable({
		count = 0,
	}, {
		__index = function(Self, obj)
			local Count = Self.count
			Self.count = Count + 1
			local rbxi = "RBX" .. Count -- Todo: Roblox encodes all <Item> elements with a referent attribute. Each value is generated by starting with the prefix RBX, followed by a UUID version 4, with - characters removed, and all characters converted to uppercase. We probably need to do that too for sake of safety
			Self[obj] = rbxi
			return rbxi
		end,
	})

	--[[ --TODO: Hidden Properties
	-- * Hardcoded properties/valuetypes
		for classname, propertyList in SpecialProperties do 
		local Unfiltered_Properties = ClassList[classname].UnfilteredProperties
		local Properties = ClassList[classname].Properties
		-- print(ClassName)
		for Property, ValueType in propertyList do
			if Properties[Property] then -- Not special
				continue
			end
			Properties[Property] = { ValueType = ValueType, Special = true }
			Unfiltered_Properties[Property] = { ValueType = ValueType, Special = true }
			-- print(Property, ValueType)
		end
	end
	
	-- * Automatically scanned properties/valuetypes
	for _, Info in queue do
	local ClassName = Info.ClassName
	local ClassProperties = Info.ClassProperties
	local WholePropertyTree = Inheritor(nil, ClassName, true)
	local AssumedSpecialProperties = Info.AssumedSpecialProperties
	-- AssumedSpecialProperties.MaterialColors = "BinaryString"
	for Property, Value in AssumedSpecialProperties do
		-- print("II", Property, typeof(Value))

		if WholePropertyTree[Property] or ClassProperties[Property] then
			-- if Property == "DataCost" then
			-- 	-- for i, v in WholePropertyTree do
			-- 	-- 	print(i, v)
			-- 	-- end
			-- 	-- print(ClassName, WholePropertyTree[Property])
			-- end
			continue
		end
		-- if Property == "AttributesReplicate" then
		-- 	for i, v in WholePropertyTree do
		-- 		print(i, v)
		-- 	end
		-- 	print(ClassProperties[Property], WholePropertyTree[Property])
		-- end
		local TypeOf = typeof(Value)
		if TypeOf == "string" and Find(Property, "BinaryString") then -- Auto-fix BinaryString properties that could've been mixed up with "string"
			TypeOf = "BinaryString"
		end

		ClassProperties[Property] = { ValueType = TypeOf, Special = true }
	end
end

-- *  Tell whether ValueType is string or BinaryString (prototype)
for Class, ClassInfo in ClassList do
	local Replica, Props
	for Property, PropertyInfo in ClassInfo.Properties do
		if PropertyInfo.Special and PropertyInfo.ValueType == "string" then
			if not Replica then
				Replica = Replicas[Class]
				Props = getproperties(Replica)
			end
			local value = Props[Property]
			local empty = value == ""
			total ..= "Property: " .. tostring(Property) .. " Value: " .. tostring(value) .. " Empty: " .. tostring(
				empty
			)
			local bin
			if not empty then
				bin = b64encode(value)
			end
			total ..= "\nBinary: " .. tostring(bin and true or false) .. " BinaryString: " .. (bin or "")
			total ..= "\n"
			-- print(Replica)
		end
	end
	if Props then
		total ..= "Class: " .. Class .. "\n\n"
	end
end

	]]

	local typesizeround = function(s)
		return math.floor(buffersize / (0x400 ^ s) * 10) / 10
	end
	local getsizeformat = function()
		local size
		for i, v in
			{
				"B",
				"KB",
				"MB",
				"GB",
				"TB",
			}
		do
			if buffersize < 0x400 ^ i then
				size = typesizeround(i - 1) .. " " .. v
				break
			end
		end
		return size
	end
	local getsafeproperty = function(i, name)
		return i[name]
	end
	local getplacename = function()
		local name = "place" .. game.PlaceId
		-- pcall(function()
		-- 	name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or name
		-- end)
		-- return name:gsub("[^%w%s_]", "_") .. ".rbxlx"
		return name .. ".rbxlx"
	end
	local savecache = function()
		local savestr = table.concat(savebuffer)
		appendfile(placename, savestr)
		buffersize += #savestr
		stlgui.Text = "Saving " .. getsizeformat()
		savebuffer = {}
		rwait()
	end

	local savehierarchy
	savehierarchy = function(h)
		local savepr = #savebuffer
		if 0x1600 < savepr then
			savecache()
		end
		for _index_0 = 1, #h do
			local _continue_0 = false
			repeat
				local instance = h[_index_0]
				local specialProperties
				local ClassName = instance.ClassName

				if instance.RobloxLocked or InstancesBlacklist[instance.Name] or not ClassList[ClassName] then
					_continue_0 = true
					break
				end
				local Properties = properties[ClassName]
				savebuffer[#savebuffer + 1] = '<Item class="'
					.. ClassName
					.. '" referent="'
					.. identifiers[instance]
					.. '"><Properties>'
				for PropertyName, Property in Properties do
					local _continue_1 = false
					repeat
						local value
						local tag
						local raw
						if Property.Special then
							if not specialProperties then
								specialProperties = getspecialinfo(instance)
							end

							raw = specialProperties[PropertyName]
							if raw == nil then
								_continue_1 = true
								break
							end
						else
							local SafeToRead = Property.SafeToRead
							if nil == SafeToRead then
								local ok, result = pcall(getsafeproperty, instance, PropertyName)
								Property.SafeToRead = ok
								if ok then
									raw = result
								else
									_continue_1 = true
									break
								end
							elseif true == SafeToRead then
								raw = instance[PropertyName]
							elseif false == SafeToRead then
								_continue_1 = true
								break
							end
						end

						local ValueType = Property.ValueType

						local Descriptor = Descriptors[ValueType]

						if Descriptor then
							value, tag = Descriptor(raw)
						elseif Property.Category == "Class" then
							tag = "Ref"
							if raw then
								value = identifiers[raw]
							else
								value = "null"
							end
						elseif Property.Category == "Enum" then
							value, tag = Descriptors.__ENUM(raw)
						else -- TODO: Do something about these below bruh
							if "BinaryString" == ValueType then
								tag = "BinaryString"
								if PropertyName == "SmoothGrid" or PropertyName == "MaterialColors" then
									value = "<![CDATA[" .. b64encode(raw) .. "]]>"
								else
									value = b64encode(raw)
								end
							elseif "ProtectedString" == ValueType then
								tag = "ProtectedString"
								if PropertyName == "Source" then
									if ClassName == "Script" then
										value = "-- Server scripts can NOT be decompiled\n"
									else
										value = ldecompile(instance)
									end
								else
									value = raw
								end
								value = Descriptors.string(value)

								-- else
								-- ELSE WHAT BRO?
							end
						end

						if tag then
							savebuffer[#savebuffer + 1] = "<"
								.. tag
								.. ' name="'
								.. PropertyName
								.. '">'
								.. value
								.. "</"
								.. tag
								.. ">"
						end
						_continue_1 = true
					until true
					if not _continue_1 then
						break
					end
				end
				savebuffer[#savebuffer + 1] = "</Properties>"
				local chl = instance:GetChildren()
				if #chl ~= 0 then
					savehierarchy(chl)
				end
				savebuffer[#savebuffer + 1] = "</Item>"
				_continue_0 = true
			until true
			if not _continue_0 then
				break
			end
		end
	end
	local savefolder = function(n, h)
		local Ref = identifiers[Instance.new("Folder")]
		table.insert(
			savebuffer,
			'<Item class="Folder" referent="'
				.. Ref
				.. '"><Properties><string name="Name">'
				.. n
				.. "</string></Properties>"
		)
		savehierarchy(h)
		table.insert(savebuffer, "</Item>")
	end

	local savegame = function()
		local Players = service.Players
		local LocalPlayer = Players.LocalPlayer
		local LocalPlayer_Children = LocalPlayer:GetChildren()
		local nilinstances
		if OPTIONS.NilInstances then
			local NilInstances = globalcontainer.getnilinstances()
			nilinstances = table.clone(NilInstances) -- Precaution in case this table gets updated live and is shared (table ref)
			for index, instance in NilInstances do
				if instance == game then
					table.remove(nilinstances, index)
					-- break
				else
					local ClassName = instance.ClassName

					local Fix = NilInstancesBlacklist[ClassName]
					if Fix then -- *
						nilinstances[index] = Fix(instance)
						-- continue
					end

					local Tags = ClassList[ClassName].Tags

					if Tags and table.find(Tags, "Service") then
						instance.Parent = game
						table.remove(nilinstances, index)
						-- continue
					end
				end
			end
		end
		globalcontainer.writefile(
			placename,
			'<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
		) --[[ -- Todo <Meta name="ExplicitAutoJoints">true</Meta> is to be added if https://github.com/RobloxAPI/spec/blob/master/formats/rbxlx.md#meta Model was made in a workspace with Explicit AutoJointsMode. (only to be present in rbxmx files)
		Also http can be converted to https but not sure if Roblox would decide to detect that
		-- ? <External>null</External><External>nil</External>  - <External> is a legacy concept that is no longer used.
		]]

		savehierarchy(ToSaveList)
		savefolder("LocalPlayer", LocalPlayer_Children)
		if nilinstances then
			savefolder("Nil Instances", nilinstances)
		end
		table.insert(savebuffer, "</roblox>")
		savecache()
	end
	do
		local Name = "TextLabeI"
		stlgui = Instance.new("TextLabel")
		stlgui.BackgroundTransparency = 1
		stlgui.Font = Enum.Font.Code
		stlgui.Name = Name
		-- stlgui.AnchorPoint = Vector2.new(1)
		stlgui.Position = UDim2.new(0.7, 0, 0, -20)
		stlgui.Size = UDim2.new(0.3, 0, 0, 20)
		stlgui.Text = "Starting..."
		stlgui.TextColor3 = Color3.new(1, 1, 1)
		stlgui.TextScaled = true
		stlgui.TextStrokeTransparency = 0.7
		stlgui.TextXAlignment = Enum.TextXAlignment.Right
		stlgui.TextYAlignment = Enum.TextYAlignment.Top

		local RobloxGui = service.CoreGui:FindFirstChild("RobloxGui")

		local Exists = RobloxGui:FindFirstChild(Name)
		if Exists then
			Exists:Destroy()
		end
		stlgui.Parent = RobloxGui
	end
	do
		local Players = service.Players
		local LocalPlayer = Players.LocalPlayer
		local PlayerList = Players:GetPlayers()
		for _index_0 = 1, #PlayerList do
			local Player = PlayerList[_index_0]
			if Player ~= LocalPlayer then
				InstancesBlacklist[Player.Name] = true
			end
		end
	end
	do
		placename = getplacename()
		buffersize = 0
		savebuffer = {}
		local elapse_t = os.clock()
		local ok, err = pcall(savegame)
		elapse_t = os.clock() - elapse_t

		local Log10 = math.log10(elapse_t)

		if ok then
			stlgui.Text = string.format("Saved! Time %.2f seconds; Size %s", elapse_t, getsizeformat())
			task.wait(Log10 * 2 + 3)
		else
			stlgui.Text = "Failed!\nCheck F9 console for more info"
			warn("Error encountered while saving")
			warn("Information about error:")
			warn(err)
			task.wait(Log10 + 3)
		end
		stlgui:Destroy()
	end
end

return synsaveinstance
