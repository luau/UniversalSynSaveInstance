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
	-- readbinarystring = '(...):find("bin",nil,true)', -- ! Could match some unwanted stuff
	getnilinstances = '(...):find("nil",nil,true)', -- ! Could match some unwanted stuff
	getproperties = '(...):find("get",nil,true) and (...):find("prop",nil,true) and (...):sub(#...) == "s"',
	getspecialinfo = '(...):find("get",nil,true) and (...):find("spec",nil,true)',
	writefile = '(...):find("file",nil,true) and (...):find("write",nil,true)',
}, true)

local decompile = globalcontainer.decompile
local gethiddenproperty = globalcontainer.gethiddenproperty
local getproperties = globalcontainer.getproperties
local appendfile = globalcontainer.appendfile

local function Find(String, Pattern)
	return String:find(Pattern, nil, true)
end

local GlobalSettings, GlobalBasicSettings = settings(), UserSettings()
local service = setmetatable({}, {
	__index = function(Self, Name)
		local Service = game:GetService(Name) or GlobalSettings:GetService(Name) or GlobalBasicSettings:GetService(Name)
		Self[Name] = Service
		return Service
	end,
})

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
	__BIT = function(...) -- * Credits to Friend (you know yourself)
		local Value = 0

		for Index, Bit in { ... } do
			if Bit then
				Value += 2 ^ (Index - 1)
			end
		end

		return Value
	end,
	__CDATA = function(raw)
		return "<![CDATA[" .. raw .. "]]>"
	end,
	__ENUM = function(raw)
		return raw.Value, "token"
	end,
	__ENUMNAME = function(raw)
		return raw.Name
	end,
	__EXTREMIFY = function(raw)
		local Extreme
		if raw ~= raw then
			Extreme = "NAN"
		elseif raw == math.huge then
			Extreme = "INF"
		elseif raw == -math.huge then
			Extreme = "-INF"
		end

		return Extreme
	end,
	__APIPRECISION = function(raw, default)
		if raw == 0 then
			return raw
		end

		local Extreme = Descriptors.__EXTREMIFY(raw)
		if Extreme then
			return Extreme
		end

		local precision
		if type(default) == "string" then
			local dotIndex = Find(default, ".")

			if dotIndex then
				precision = #default - dotIndex
			end
		else
			precision = default
		end
		if precision then
			return ("%." .. precision .. "f"):format(raw)
		end

		return raw
	end,
	__VECTOR = function(X, Y, Z)
		local Value = "<X>" .. X .. "</X><Y>" .. Y .. "</Y>" -- There is no Vector without at least two Coordinates.. (Vector1, at least on Roblox)

		if Z then
			Value ..= "<Z>" .. Z .. "</Z>"
		end

		return Value
	end,

	Axes = function(raw)
		--The text of this element is formatted as an integer between 0 and 7
		return "<axes>" .. Descriptors.__BIT(raw.X, raw.Y, raw.Z) .. "</axes>", "Axes"
	end,
	-- BinaryString = function(raw)

	-- end
	BrickColor = function(raw) -- ! Oh well This might hurt Color3 / Color3uint8 properties
		return raw.Number, "BrickColor" -- * Roblox encodes the tags as "int", but this is not required for Roblox to properly decode the type. For better compatibility, it is preferred that third-party implementations encode and decode "BrickColor" tags instead.
	end,
	CFrame = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		return Descriptors.__VECTOR(X, Y, Z)
			.. "<R00>"
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
		return "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>", "Color3" -- ? It is recommended that Color3 is encoded with elements instead of text.
	end,
	ColorSequence = function(raw)
		--The value is the text content, formatted as a space-separated list of FLOATing point numbers.

		local Converted = ""
		local Keypoints = raw.Keypoints
		for _index_2 = 1, #Keypoints do
			local v = Keypoints[_index_2]
			local Value = v.Value
			Converted ..= v.Time .. " " .. Value.R .. " " .. Value.G .. " " .. Value.B .. " 0 " -- * " 0" is Envelope: Has the range 0 - 1. Currently unused by Roblox.
		end

		return Converted, "ColorSequence"
	end,
	Content = function(raw)
		return (raw == nil or raw == "") and "<null></null>" or "<url>" .. Descriptors.string(raw) .. "</url>",
			"Content"
	end,
	Faces = function(raw)
		-- The text of this element is formatted as an integer between 0 and 63
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
			.. Descriptors.__ENUMNAME(raw.Style) -- Weird but this field accepts .Name of enum instead..
			.. "</Style>", --TODO: Figure out how to determine this.. (Content) <CachedFaceId><url>rbxasset://fonts/GothamSSm-Medium.otf</url></CachedFaceId>
			"Font"
	end,
	NumberRange = function(raw)
		--The value is the text content, formatted as a space-separated list of floating point numbers.
		return raw.Min .. " " .. raw.Max, --[[.. " "]] -- ! This might be required to bypass detections as thats how its formatted usually
			"NumberRange"
	end,
	NumberSequence = function(raw)
		--The value is the text content, formatted as a space-separated list of floating point numbers.
		local Converted = ""
		local Keypoints = raw.Keypoints
		for _index_2 = 1, #Keypoints do
			local v = Keypoints[_index_2]
			Converted ..= v.Time .. " " .. v.Value .. " " .. v.Envelope .. " "
		end

		return Converted, "NumberSequence"
	end,
	PhysicalProperties = function(raw)
		--[[Contains at least one CustomPhysics element, which is interpreted according to the bool type. If this value is true, then the tag also contains an element for each component of the PhysicalProperties:

    Density
    Friction
    Elasticity
    FrictionWeight
    ElasticityWeight

The value of each component is represented by the text content formatted as a 32-bit floating point number (see float).]]
		local CustomPhysics
		if raw then
			CustomPhysics = true
		else
			CustomPhysics = false
		end
		CustomPhysics = "<CustomPhysics>" .. Descriptors.bool(CustomPhysics) .. "</CustomPhysics>"

		return raw
				and CustomPhysics .. "<Density>" .. raw.Density .. "</Density><Friction>" .. raw.Friction .. "</Friction><Elasticity>" .. raw.Elasticity .. "</Elasticity><FrictionWeight>" .. raw.FrictionWeight .. "</FrictionWeight><ElasticityWeight>" .. raw.ElasticityWeight .. "</ElasticityWeight>"
			or CustomPhysics,
			"PhysicalProperties"
	end,
	-- ProtectedString = function(raw)
	-- 	return tostring(raw), "ProtectedString"
	-- end,
	Ray = function(raw)
		local vector3 = Descriptors.Vector3

		return "<origin>" .. vector3(raw.Origin) .. "</origin><direction>" .. vector3(raw.Direction) .. "</direction>",
			"Ray"
	end,
	Rect = function(raw)
		local vector2 = Descriptors.Vector2

		return "<min>" .. vector2(raw.Min) .. "</min><max>" .. vector2(raw.Max) .. "</max>", "Rect2D"
	end,
	UDim = function(raw)
		--[[
    S: Represents the Scale component. Interpreted as a <float>.
    O: Represents the Offset component. Interpreted as an <int>.
	]]

		return "<S>" .. raw.Scale .. "</S><O>" .. raw.Offset .. "</O>", "UDim"
	end,
	UDim2 = function(raw)
		--[[
    XS: Represents the X.Scale component. Interpreted as a <float>.
    XO: Represents the X.Offset component. Interpreted as an <int>.
    YS: Represents the Y.Scale component. Interpreted as a <float>.
    YO: Represents the Y.Offset component. Interpreted as an <int>.
	]]

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
		--[[
    X: Represents the X component. Interpreted as a <float>.
    Y: Represents the Y component. Interpreted as a <float>.
	]]
		return Descriptors.__VECTOR(raw.X, raw.Y), "Vector2"
	end,
	Vector3 = function(raw)
		--[[
    X: Represents the X component. Interpreted as a <float>.
    Y: Represents the Y component. Interpreted as a <float>.
    Z: Represents the Z component. Interpreted as a <float>.
	]]
		return Descriptors.__VECTOR(raw.X, raw.Y, raw.Z), "Vector3"
	end,
	bool = function(raw)
		return tostring(raw), "bool"
	end,

	double = function(raw, default)
		return Descriptors.__APIPRECISION(raw, default or 17), "double" --TODO A precision of at least 17 is required to properly represent a 64-bit floating point value, so this amount is recommended.
	end, -- ? wouldn't float be better as an optimization
	float = function(raw, default)
		return Descriptors.__APIPRECISION(raw, default or 9), "float" -- TODO A precision of at least 9 is required to properly represent a 32-bit floating point value, so this amount is recommended.
	end,
	string = function(raw)
		return raw == "" and raw or raw:gsub(EscapesPattern, Escapes), "string"
	end,
}

for _, StaysRaw in
	{
		"int",
		"int64",
	}
do
	Descriptors[StaysRaw] = function(raw)
		return Descriptors.__EXTREMIFY(raw) or raw, StaysRaw
	end
end

if getproperties then
	if globalcontainer.getspecialinfo then
		local getreal = globalcontainer.getspecialinfo

		globalcontainer.getspecialinfo = function(instance)
			local specialinfo = getproperties(instance)

			for Property, Value in getreal(instance) do
				specialinfo[Property] = Value
			end

			return specialinfo
		end
	else
		globalcontainer.getspecialinfo = getproperties
	end
end

local getspecialinfo = globalcontainer.getspecialinfo

local function getsafeproperty(instance, name)
	return instance[name]
end

local function ReadProperty(Property, instance, PropertyName, specialProperties)
	local raw
	if Property.Special then
		if specialProperties == nil and getspecialinfo then
			specialProperties = getspecialinfo(instance)
			raw = specialProperties[PropertyName]
		end

		if raw == nil then
			local ok, result = pcall(gethiddenproperty, instance, PropertyName)

			if ok then
				raw = result
			end
		end

		if raw == nil then
			-- * Skip next time we encounter this too perhaps
			-- Property.Special = false
			-- Property.CanRead = false

			return "__BREAK", specialProperties
		end
	else
		local CanRead = Property.CanRead
		if nil == CanRead then
			local ok, result = pcall(getsafeproperty, instance, PropertyName)

			if ok then
				raw = result
			else
				if specialProperties == nil and getspecialinfo then
					specialProperties = getspecialinfo(instance)
					raw = specialProperties[PropertyName]
				end

				if raw == nil then
					ok, result = pcall(gethiddenproperty, instance, PropertyName)

					if ok then
						raw = result

						Property.Special = true
					end
				else
					ok = true

					Property.Special = true
				end
			end

			Property.CanRead = ok
			if not ok then
				return "__BREAK", specialProperties
			end
		elseif true == CanRead then
			raw = instance[PropertyName]
		elseif false == CanRead then
			return "__BREAK", specialProperties
		end
	end
	return raw, specialProperties
end

local b64encode = globalcontainer.base64_encode
	or loadstring(game:HttpGet(Params.RepoURL .. Params.ROM .. ".luau", true), Params.ROM)()(4544052033).base64_encode
	or loadstring(
		game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/Libraries/Hash.lua", true),
		"HashLib"
	)().base64_encode

local ldeccache = {}

local function ArrayToDictionary(Table)
	local tmp = table.create(#Table)

	for _, Key in Table do
		tmp[Key] = true
	end

	return tmp
end

local function FetchAPI()
	local API_Dump_Url = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
	local API_Dump = game:HttpGet(API_Dump_Url, true)
	local API_Classes = service.HttpService:JSONDecode(API_Dump).Classes

	local ClassList = {}

	for _index_0 = 1, #API_Classes do
		local Class = API_Classes[_index_0]
		local ClassMembers = Class.Members

		local ClassInfo = {}

		local ClassName = Class.Name

		local ClassTags = Class.Tags

		if ClassTags then
			ClassTags = ArrayToDictionary(ClassTags)
		end

		-- ClassInfo.Name = ClassName
		ClassInfo.Tags = ClassTags -- or {}
		ClassInfo.Superclass = Class.Superclass

		local ClassProperties = {}

		for _index_1 = 1, #ClassMembers do
			local Member = ClassMembers[_index_1]
			if Member.MemberType == "Property" then
				local PropertyName = Member.Name

				-- ? We avoid this as some Instances like services may have this property locked and thus make file unable to open and it's not even used by Roblox anyways as Parent-Child relationship is done by embedding/nesting
				if not (PropertyName == "Parent" and ClassName == "Instance") then
					local Serialization = Member.Serialization

					if Serialization.CanLoad then
						local Allowed = true

						local MemberTags = Member.Tags

						local Special

						if MemberTags then
							MemberTags = ArrayToDictionary(MemberTags)

							Special = MemberTags.NotScriptable

							if MemberTags.Deprecated then
								Allowed = false
							end
						end
						if Allowed then
							local ValueInfo = Member.ValueType

							local PropertyInfo = {
								Name = PropertyName,
								Category = ValueInfo.Category,
								Default = Member.Default,
								ValueType = ValueInfo.Name,
							}

							if Special then
								PropertyInfo.Special = true
							end

							ClassProperties[PropertyName] = PropertyInfo
						end
					end
				end
			end
		end

		ClassInfo.Properties = ClassProperties

		ClassList[ClassName] = ClassInfo
	end

	-- ClassList.Instance.Properties.Parent = nil -- ? Not sure if this is a better option than filtering throguh properties to remove this

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
local placename = "place" .. game.PlaceId .. ".rbxlx"

local rswait = service.RunService.RenderStepped
local function rwait()
	rswait:Wait()
end

local NilInstancesFixes = {
	Animator = function(instance)
		local AnimationController = Instance.new("AnimationController")
		AnimationController.Name = "Animator has to be placed under Humanoid or AnimationController"
		instance.Parent = AnimationController
		return AnimationController
	end,
}

local inheritedproperties = setmetatable({}, {
	__index = function(self, ClassName)
		local proplist = {}
		local layer = ClassList[ClassName]
		while layer do
			local _list_0 = layer.Properties

			-- proplist = table.move(_list_0, 1, #_list_0, #proplist + 1, proplist)
			for _, p in _list_0 do
				p = table.clone(p)
				-- p.Name = PropertyName
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

		self[ClassName] = proplist

		return proplist
	end,
})

local classreplicas = setmetatable({}, {
	__index = function(self, ClassName)
		local Replica = Instance.new(ClassName) -- ! Might need to pcall this
		self[ClassName] = Replica
		return Replica
	end,
})

local referents = setmetatable({
	count = 0,
}, {
	__index = function(self, instance)
		local Count = self.count
		self.count = Count + 1
		local referent = "RBX" .. Count -- Todo: Roblox encodes all <Item> elements with a referent attribute. Each value is generated by starting with the prefix RBX, followed by a UUID version 4, with - characters removed, and all characters converted to uppercase. We probably need to do that too for sake of safety
		self[instance] = referent
		return referent
	end,
})

local function ReturnItem(ClassName, instance)
	return '<Item class="' .. ClassName .. '" referent="' .. referents[instance] .. '"><Properties>'
end

local function ApiFormatify(Value, Category, ValueType, Default)
	if Category == "Enum" then
		Value = Descriptors.__ENUMNAME(Value)
	elseif Category == "Primitive" then
		Value = Descriptors[ValueType](Value, Default)
	end
	return tostring(Value)
end

local OverwriteDefaults =
	{ __api_dump_class_not_creatable__ = true, __api_dump_no_string_value__ = true, __api_dump_skipped_class__ = true }

local function synsaveinstance(...)
	referents.count = 0

	local buffersize
	local savebuffer
	local stlgui

	local OPTIONS = {
		mode = "optimized", -- Change this to invalid mode like "custom" if you only want extrainstances
		noscripts = false,
		scriptcache = true,
		-- decomptype = "new", -- * Deprecated
		timeout = 30,
		--* New:
		__DEBUG_MODE = false,
		DecompileIgnore = { -- * Clean these up (merged Old Syn and New Syn)
			"Chat",
			"CoreGui",
			"CorePackages",
		},
		InstancesBlacklist = {},

		ExtraInstances = {},
		NilInstances = true,
		ShowStatus = true,
		-- Binary = false, -- true in new versions
		-- Decompile = not OPTIONS.noscripts,
		-- DecompileTimeout = OPTIONS.timeout,
		IgnoreDefaultProps = true,
		-- IsolateStarterPlayer = true,
		IsolateLocalPlayer = true, -- Saves Children of LocalPlayer as separate folder and prevents any instance with .Name identical to LocalPlayer.Name from saving
		-- MaxThreads = 3
		-- RemovePlayerCharacters = true,
		SavePlayers = false,
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

	local ldecompile
	do
		if OPTIONS.noscripts then
			ldecompile = function()
				return "-- Decompiling is disabled"
			end
		elseif decompile then
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
				local ok, result = pcall(decompile, Script, OPTIONS.timeout, OPTIONS.timeout) -- ! This might break on Syn due to second param being bool or string (deprecated tho)
				ldeccache[Script] = result
				return ok and result or "--[[\n" .. result .. "\n]]"
			end
		else
			ldecompile = function()
				return "-- Decompiling is NOT supported on your executor"
			end
		end
	end

	local ToSaveList
	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = OPTIONS.ExtraInstances

		if mode == "full" then
			tmp = game:GetChildren()
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
			if OPTIONS.SavePlayers then
				table.insert(_list_0, "Players")
			end
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

	local DecompileIgnore, InstancesBlacklist =
		ArrayToDictionary(OPTIONS.DecompileIgnore), ArrayToDictionary(OPTIONS.InstancesBlacklist)

	local function getsizeformat()
		local size
		for i, BinaryPrefix in
			{
				"B",
				"KB",
				"MB",
				"GB",
				"TB",
			}
		do
			if buffersize < 0x400 ^ i then
				size = math.floor(buffersize / (0x400 ^ (i - 1)) * 10) / 10 .. " " .. BinaryPrefix
				break
			end
		end
		return size
	end

	local function savecache()
		local savestr = table.concat(savebuffer)
		appendfile(placename, savestr)
		buffersize += #savestr
		if stlgui then
			stlgui.Text = "Saving " .. getsizeformat()
		end
		savebuffer = {}
		rwait()
	end
	local DecompileIgnoring
	local savehierarchy

	local IgnoreDefaultProps = OPTIONS.IgnoreDefaultProps
	local __DEBUG_MODE = OPTIONS.__DEBUG_MODE

	savehierarchy = function(Hierarchy)
		local savepr = #savebuffer
		if 0x1600 < savepr then
			savecache()
		end
		for _index_0 = 1, #Hierarchy do
			repeat
				local instance = Hierarchy[_index_0]

				local ClassName = instance.ClassName
				local InstanceName = instance.Name

				if instance.RobloxLocked or InstancesBlacklist[InstanceName] or not ClassList[ClassName] then
					break
				end

				if not DecompileIgnoring then
					DecompileIgnoring = DecompileIgnore[InstanceName] and instance
				end

				local Properties = inheritedproperties[ClassName]
				savebuffer[#savebuffer + 1] = ReturnItem(ClassName, instance)
				local specialProperties, Replica
				for _index_1 = 1, #Properties do
					local Property = Properties[_index_1]
					local PropertyName = Property.Name

					repeat
						local raw
						raw, specialProperties = ReadProperty(Property, instance, PropertyName, specialProperties)
						if raw == "__BREAK" then
							break
						end

						local Category = Property.Category

						if IgnoreDefaultProps then
							local Default = Property.Default
							local ValueType = Property.ValueType

							if OverwriteDefaults[Default] then
								local ClassTags = ClassList[ClassName].Tags
								if not (ClassTags and ClassTags.NotCreatable) then
									Replica = classreplicas[ClassName]

									Default = ReadProperty(Property, Replica, PropertyName, specialProperties)
									-- * Improve this along with specialProperties (merge or maybe store the method to Property.Special), get this property at any cost

									Default = ApiFormatify(Default, Category, ValueType)
									Property.Default = Default
									-- if Property.Special then
									-- end
								end
							elseif Default == "default" and ValueType == "PhysicalProperties" then
								Default = "nil"
								Property.Default = Default
							end

							if ApiFormatify(raw, Category, ValueType, Default) == Default then -- ! PhysicalProperties, Font, CFrame, BrickColor (and Enum to some extent) aren't being defaulted properly in the api dump, meaning an issue must be created.. (They're not being tostringed or fail to do so)
								-- print("Default not serializing", PropertyName)

								break
							end
						end

						local tag, value
						if Category == "Class" then
							tag = "Ref"
							if raw then
								value = referents[raw]
							else
								value = "null"
							end
						elseif Category == "Enum" then -- ! We do this order (Enums before Descriptors) specifically because Font Enum might get a Font Descriptor despite having Enum Category, unlike Font DataType which that Descriptor is meant for
							value, tag = Descriptors.__ENUM(raw)
						else
							local ValueType = Property.ValueType
							local Descriptor = Descriptors[ValueType]

							if Descriptor then
								value, tag = Descriptor(raw)
							elseif "BinaryString" == ValueType then -- TODO: Do something about these few bruh
								tag = "BinaryString"
								value = b64encode(raw)

								if
									PropertyName == "SmoothGrid"
									or PropertyName == "MaterialColors"
									or PropertyName == "PhysicsGrid"
								then
									value = Descriptors.__CDATA(value)
								end
							elseif "ProtectedString" == ValueType then
								tag = "ProtectedString"

								if PropertyName == "Source" then
									if ClassName == "Script" then
										value = "-- Server scripts can NOT be decompiled"
									else
										if DecompileIgnoring then
											value = "-- Ignored"
										else
											value = ldecompile(instance)
										end
									end
								end

								value = Find(value, "]]>") and Descriptors.string(value) or Descriptors.__CDATA(value) -- ? its purpose is to "protect" data from being treated as ordinary character data during processing
							elseif __DEBUG_MODE then
								warn("UNSUPPORTED TYPE", ValueType)
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

					until true
				end
				savebuffer[#savebuffer + 1] = "</Properties>"
				local Children = instance:GetChildren()
				if #Children ~= 0 then
					savehierarchy(Children)
				end

				if DecompileIgnoring == instance then
					DecompileIgnoring = nil
				end

				savebuffer[#savebuffer + 1] = "</Item>"

			until true
		end
	end
	local function savefolder(Name, Hierarchy)
		local Ref = Instance.new("Folder")
		table.insert(
			savebuffer,
			ReturnItem(Ref.ClassName, Ref)
				.. Descriptors[ClassList.Instance.Properties.Name.ValueType](Name)
				.. "</Properties>"
		)
		savehierarchy(Hierarchy)
		table.insert(savebuffer, "</Item>")
	end

	local function savegame()
		local nilinstances
		if OPTIONS.NilInstances and globalcontainer.getnilinstances then
			local tmp = {}
			for _, instance in globalcontainer.getnilinstances() do
				if instance == game then
					instance = nil
					-- break
				else
					local ClassName = instance.ClassName

					local Fix = NilInstancesFixes[ClassName]
					if Fix then -- *
						instance = Fix(instance)
						-- continue
					end

					local ClassTags = ClassList[ClassName].Tags

					if ClassTags and ClassTags.Service then
						instance.Parent = game
						instance = nil
						-- continue
					end
				end
				if instance then
					table.insert(tmp, instance)
				end
			end
			nilinstances = tmp
		end
		globalcontainer.writefile(
			placename,
			'<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">'
		) --[[ -- Todo <Meta name="ExplicitAutoJoints">true</Meta> is to be added if https://github.com/RobloxAPI/spec/blob/master/formats/rbxlx.md#meta Model was made in a workspace with Explicit AutoJointsMode. (only to be present in rbxmx files)
		Also http can be converted to https but not sure if Roblox would decide to detect that
		-- ? <External>null</External><External>nil</External>  - <External> is a legacy concept that is no longer used.
		]]

		savehierarchy(ToSaveList)

		if OPTIONS.IsolateLocalPlayer then
			local Players = service.Players
			local LocalPlayer = Players.LocalPlayer
			local LocalPlayer_Children = LocalPlayer:GetChildren()
			savefolder("LocalPlayer", LocalPlayer_Children)
		end

		if nilinstances then
			savefolder("Nil Instances", nilinstances)
		end

		table.insert(savebuffer, "</roblox>")
		savecache()
	end
	if OPTIONS.ShowStatus then
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
	if not OPTIONS.SavePlayers then
		InstancesBlacklist.Players = true
	end
	if OPTIONS.IsolateLocalPlayer then
		local Players = service.Players
		local LocalPlayer = Players.LocalPlayer

		InstancesBlacklist[LocalPlayer.Name] = true
	end
	do
		buffersize = 0
		savebuffer = {}
		local elapse_t = os.clock()
		local ok, err = pcall(savegame)
		elapse_t = os.clock() - elapse_t

		local Log10 = math.log10(elapse_t)

		if stlgui then
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
end

return synsaveinstance
