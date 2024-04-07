--!native
local Params = {
	RepoURL = "https://raw.githubusercontent.com/luau/SomeHub/main/",
	UMF = "UniversalMethodFinder",
	ROM = "RequireOnlineModule",
}
local finder, globalcontainer = loadstring(game:HttpGet(Params.RepoURL .. Params.UMF .. ".luau", true), Params.UMF)()

finder({
	-- readbinarystring = 'string.find(...,"bin",nil,true)', -- ! Could match some unwanted stuff
	decompile = '(string.find(...,"decomp",nil,true) and string.sub(...,#...) ~= "s") or string.find(...,"assembl",nil,true)',
	gethiddenproperty = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) ~= "s"',
	gethiddenproperties = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) == "s"',
	sethiddenproperty = 'string.find(...,"set",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) ~= "s"',
	gethui = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"ui",nil,true)',
	getnilinstances = 'string.find(...,"nil",nil,true)', -- ! Could match some unwanted stuff
	getproperties = 'string.find(...,"get",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) == "s"',
	getspecialinfo = 'string.find(...,"get",nil,true) and string.find(...,"spec",nil,true)',
	protectgui = 'string.find(...,"protect",nil,true) and string.find(...,"ui",nil,true) and not string.find(...,"un",nil,true)',
	writefile = 'string.find(...,"file",nil,true) and string.find(...,"write",nil,true)',
}, true)

local decompile = globalcontainer.decompile
local gethiddenproperty = globalcontainer.gethiddenproperty
local sethiddenproperty = globalcontainer.sethiddenproperty
local writefile = globalcontainer.writefile

if not globalcontainer.getspecialinfo then
	globalcontainer.getspecialinfo = globalcontainer.gethiddenproperties
end

local function Find(String, Pattern)
	return string.find(String, Pattern, nil, true)
end

local GlobalSettings, GlobalBasicSettings = settings(), UserSettings()
local service = setmetatable({}, {
	__index = function(Self, Name)
		local Service = game:GetService(Name) or GlobalSettings:GetService(Name) or GlobalBasicSettings:GetService(Name)
		Self[Name] = Service
		return Service
	end,
})

local EscapesPattern = "[%z\1-\8\11-\12\14-\31\127-\191\194-\244<>\"'&]"
-- Order from: https://create.roblox.com/docs/en-us/ui/rich-text#escape-forms
local Escapes = {
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&apos;",
	["&"] = "&amp;",
}

for rangeStart, rangeEnd in string.gmatch(EscapesPattern, "(.)%-(.)") do
	for charCode = string.byte(rangeStart), string.byte(rangeEnd) do
		Escapes[string.char(charCode)] = "&#" .. charCode .. ";"
	end
end

local Base64_Encode
do
	if not bit32.byteswap or not pcall(bit32.byteswap, 1) then -- Because Fluxus is missing byteswap
		bit32 = table.clone(bit32)

		local function tobit(num)
			num = num % (bit32.bxor(num, 32))
			if num > 0x80000000 then
				num = num - bit32.bxor(num, 32)
			end
			return num
		end

		bit32.byteswap = function(num)
			local BYTE_SIZE = 8
			local MAX_BYTE_VALUE = 255

			num = num % bit32.bxor(2, 32)

			local a = bit32.band(num, MAX_BYTE_VALUE)
			num = bit32.rshift(num, BYTE_SIZE)

			local b = bit32.band(num, MAX_BYTE_VALUE)
			num = bit32.rshift(num, BYTE_SIZE)

			local c = bit32.band(num, MAX_BYTE_VALUE)
			num = bit32.rshift(num, BYTE_SIZE)

			local d = bit32.band(num, MAX_BYTE_VALUE)
			num = tobit(bit32.lshift(bit32.lshift(bit32.lshift(a, BYTE_SIZE) + b, BYTE_SIZE) + c, BYTE_SIZE) + d)
			return num
		end

		table.freeze(bit32)
	end
	local Base64_Encode_Buffer = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/Reselim/Base64/master/Base64.lua", true),
	"Base64"
)().encode
Base64_Encode = function(raw) -- ? Reselim broke all scripts that rely on their Base64 Implementation because they changed to buffers from strings (both as input & output)
		return raw == "" and raw or buffer.tostring(Base64_Encode_Buffer(buffer.fromstring(raw)))
	end
end

local SharedStrings = {}
local sharedstrings = setmetatable({
	identifier = 1e15, -- 1 quadrillion, up to 9.(9) quadrillion, in theory this shouldn't ever run out and be enough for all sharedstrings ever imaginable
	-- TODO: worst case, add fallback to randomizer once numbers run out : )
}, {
	__index = function(self, String)
		local Identifier = self.identifier
		self.identifier = Identifier + 1
		Identifier = Base64_Encode(Identifier .. "")
		self[String] = Identifier -- Todo: The value of the md5 attribute is a Base64-encoded key. <SharedString> type elements use this key to refer to the value of the string. The value is the text content, which is Base64-encoded. Historically, the key was the MD5 hash of the string value. However, this is not required; the key can be any value that will uniquely identify the shared string. Roblox currently uses BLAKE2b truncated to 16 bytes.. We probably need to do that too for sake of safety
		return Identifier
	end,
})

local Descriptors
Descriptors = {
	__APIPRECISION = function(raw, default)
		if raw == 0 or raw % 1 == 0 then
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
			-- TODO: scientific notation formatting also takes place if value is a decimal (only counts if it starts with 0.) then values like 0.00008 will be formatted as 8.0000000000000006544e-05 ("%.19e"), it must have 5 or more consecutive (?) zeros for this, on other hand, if it doesn't start with 0. then e20+ format is applied in case it has 20 or more consecutive (?) zeros so 1e20 will be formatted as 1e+20 and upwards (1e+19 is not allowed, same as 1e-04 for decimals)
			-- ? The good part is compression of value so less file size BUT at the potential cost of precision loss

			return string.format("%." .. precision .. "f", raw)
		end

		return raw
	end,
	__BINARYSTRING = Base64_Encode,
	__BIT = function(...) -- * Credits to Friend (you know yourself)
		local Value = 0
		local PackedArgs = { ... }
		for Index = 1, #PackedArgs do
			local Bit = PackedArgs[Index]
			if Bit then
				Value = Value + 2 ^ (Index - 1)
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
	__PROTECTEDSTRING = function(raw)
		return Find(raw, "]]>") and Descriptors.string(raw) or Descriptors.__CDATA(raw) -- ? its purpose is to "protect" data from being treated as ordinary character data during processing
	end,
	__VECTOR = function(X, Y, Z)
		local Value = "<X>" .. X .. "</X><Y>" .. Y .. "</Y>" -- There is no Vector without at least two Coordinates.. (Vector1, at least on Roblox)

		if Z then
			Value = Value .. "<Z>" .. Z .. "</Z>"
		end

		return Value
	end,
	Axes = function(raw)
		--The text of this element is formatted as an integer between 0 and 7
		return "<axes>" .. Descriptors.__BIT(raw.X, raw.Y, raw.Z) .. "</axes>"
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
		return "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>" -- ? It is recommended that Color3 is encoded with elements instead of text.
	end,
	-- Color3uint8 = function(raw) --? Not sure yet
	-- 	local R_255 = math.floor(raw.R * 255)
	-- 	local G_255 = math.floor(raw.G * 255)
	-- 	local B_255 = math.floor(raw.B * 255)

	-- 	return 0xFF000000 + (R_255 * 65536) + (G_255 * 256) + B_255 -- ? It is recommended that Color3uint8 is encoded with text instead of elements.
	-- end,
	ColorSequence = function(raw)
		--The value is the text content, formatted as a space-separated list of FLOATing point numbers.

		local Converted = ""
		local Keypoints = raw.Keypoints
		for Index = 1, #Keypoints do
			local v = Keypoints[Index]
			local Value = v.Value
			Converted = Converted .. v.Time .. " " .. Value.R .. " " .. Value.G .. " " .. Value.B .. " 0 " -- * " 0" is Envelope: Has the range 0 - 1. Currently unused by Roblox.
		end

		return Converted
	end,
	Content = function(raw)
		return raw == "" and "<null></null>" or "<url>" .. Descriptors.string(raw, true) .. "</url>"
	end,
	CoordinateFrame = function(raw)
		return "<CFrame>" .. Descriptors.CFrame(raw) .. "</CFrame>"
	end,
	Faces = function(raw)
		-- The text of this element is formatted as an integer between 0 and 63
		return "<faces>"
			.. Descriptors.__BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front)
			.. "</faces>"
	end,
	Font = function(raw)
		return "<Family>"
			.. Descriptors.Content(raw.Family)
			.. "</Family><Weight>"
			.. Descriptors.__ENUM(raw.Weight)
			.. "</Weight><Style>"
			.. Descriptors.__ENUMNAME(raw.Style) -- Weird but this field accepts .Name of enum instead..
			.. "</Style>" --TODO: Figure out how to determine (Content) <CachedFaceId><url>rbxasset://fonts/GothamSSm-Medium.otf</url></CachedFaceId>
	end,
	NumberRange = function(raw)
		--The value is the text content, formatted as a space-separated list of floating point numbers.
		return raw.Min .. " " .. raw.Max --[[.. " "]] -- ! This might be required to bypass detections as thats how its formatted usually
	end,
	NumberSequence = function(raw)
		--The value is the text content, formatted as a space-separated list of floating point numbers.
		local Converted = ""
		local Keypoints = raw.Keypoints
		for Index = 1, #Keypoints do
			local v = Keypoints[Index]
			Converted = Converted .. v.Time .. " " .. v.Value .. " " .. v.Envelope .. " "
		end

		return Converted
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
			or CustomPhysics
	end,
	-- ProtectedString = function(raw)
	-- 	return tostring(raw), "ProtectedString"
	-- end,
	Ray = function(raw)
		local vector3 = Descriptors.Vector3

		return "<origin>" .. vector3(raw.Origin) .. "</origin><direction>" .. vector3(raw.Direction) .. "</direction>"
	end,
	Rect = function(raw)
		local vector2 = Descriptors.Vector2

		return "<min>" .. vector2(raw.Min) .. "</min><max>" .. vector2(raw.Max) .. "</max>", "Rect2D"
	end,
	-- Region3 = function(raw) --? Not sure yet

	-- 	return "???"
	-- end,
	-- Region3int16 = function(raw) --? Not sure yet
	-- 	local vector3int16 = Descriptors.Vector3int16

	-- 	return "<min>" .. vector3int16(raw.Min) .. "</min><max>" .. vector3int16(raw.Max) .. "</max>"
	-- end,
	SharedString = function(raw)
		raw = Base64_Encode(raw)

		local Identifier = sharedstrings[raw]

		if SharedStrings[Identifier] == nil then
			SharedStrings[Identifier] = raw
		end

		return Identifier
	end, -- TODO: Add Support for this https://github.com/RobloxAPI/spec/blob/master/formats/rbxlx.md#sharedstring
	UDim = function(raw)
		--[[
    S: Represents the Scale component. Interpreted as a <float>.
    O: Represents the Offset component. Interpreted as an <int>.
	]]

		return "<S>" .. raw.Scale .. "</S><O>" .. raw.Offset .. "</O>"
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
			.. "</YO>"
	end,
	--UniqueId = function(raw)
	--[[
		    # UniqueId properties might be random everytime Studio saves a place file
    # and don't have a use right now outside of packages, which SSI doesn't
    # account for anyway. They generate diff noise, so we shouldn't serialize
    # them until we have to.
	]]
	-- 	return -- ? No idea if this even needs a Descriptor
	-- end,
	Vector2 = function(raw)
		--[[
    X: Represents the X component. Interpreted as a <float>.
    Y: Represents the Y component. Interpreted as a <float>.
	]]
		return Descriptors.__VECTOR(raw.X, raw.Y)
	end,
	Vector2int16 = function(raw)
		--[[
    X: Represents the X component. Interpreted as an <int>.
    Y: Represents the Y component. Interpreted as an <int>.
		]]
		return Descriptors.__VECTOR(raw.X, raw.Y)
	end,
	Vector3 = function(raw)
		--[[
    X: Represents the X component. Interpreted as a <float>.
    Y: Represents the Y component. Interpreted as a <float>.
    Z: Represents the Z component. Interpreted as a <float>.
	]]
		return Descriptors.__VECTOR(raw.X, raw.Y, raw.Z)
	end,
	Vector3int16 = function(raw)
		--[[
    X: Represents the X component. Interpreted as an <int>.
    Y: Represents the Y component. Interpreted as an <int>.
    Z: Represents the Z component. Interpreted as an <int>.
	]]
		return Descriptors.__VECTOR(raw.X, raw.Y, raw.Z)
	end,
	bool = function(raw)
		return tostring(raw)
	end,

	double = function(raw, default)
		return Descriptors.__APIPRECISION(raw, default or 17) --? A precision of at least 17 is required to properly represent a 64-bit floating point value, so this amount is recommended.
	end, -- ? wouldn't float be better as an optimization
	float = function(raw, default)
		return Descriptors.__APIPRECISION(raw, default or 9) -- ? A precision of at least 9 is required to properly represent a 32-bit floating point value, so this amount is recommended.
	end,
	string = function(raw, skipcheck)
		return not skipcheck and raw == "" and raw or raw:gsub(EscapesPattern, Escapes)
	end,
}

for _, StaysRaw in
	next,
	{
		"int",
		"int64",
	}
do
	Descriptors[StaysRaw] = function(raw)
		return Descriptors.__EXTREMIFY(raw) or raw
	end
end

for _, originalfuncname in next, { "getproperties", "getspecialinfo" } do -- * Some executors only allow certain Classes for this method (like UnionOperation, MeshPart, Terrain), for example Electron, Codex
local originalfunc = globalcontainer[originalfuncname]
	if originalfunc then
		globalcontainer[originalfuncname] = function(instance)
			local ok, result = pcall(originalfunc, instance)
		return ok and result or {}
end
	end
end

local getproperties = globalcontainer.getproperties

if getproperties then
	if globalcontainer.getspecialinfo then
		local old_getspecialinfo = globalcontainer.getspecialinfo

		globalcontainer.getspecialinfo = function(instance)
			local specialinfo = getproperties(instance)

			for Property, Value in next, old_getspecialinfo(instance) do
				specialinfo[Property] = Value
			end

			return specialinfo
		end
	else
		globalcontainer.getspecialinfo = getproperties
	end
end

local getspecialinfo = globalcontainer.getspecialinfo

local function getsafeproperty(instance, PropertyName)
	return instance[PropertyName]
end
local function setsafeproperty(instance, PropertyName, Value)
	instance[PropertyName] = Value
end

local function IsPropertyModified(instance, ProperyName)
	return instance:IsPropertyModified(ProperyName)
end
local function ResetPropertyToDefault(instance, ProperyName)
	instance:ResetPropertyToDefault(ProperyName)
end

local function SetProperty(instance, PropertyName, Value)
	local ok = pcall(setsafeproperty, instance, PropertyName, Value)
	if not ok then
		ok = pcall(sethiddenproperty, instance, PropertyName, Value)
	end
	return ok
end

local function ReadProperty(Property, instance, PropertyName, specialProperties, Special)
	local raw

	local function FilterResult(Result) -- ? raw == nil thanks to SerializedDefaultAttributes; "can't get value" - "shap" Roexec;  "Invalid value for enum " - "StreamingPauseMode" (old games probably) Roexec
		return Result == nil
			or Result == "can't get value"
			or type(Result) == "string"
				and (Find(Result, "Unable to get property " .. PropertyName) or Property.Category == "Enum" and Find(
					Result,
					"Invalid value for enum "
				))
	end

	if Special then
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

		if FilterResult(raw) then
			-- * Skip next time we encounter this too perhaps
			-- Property.Special = false
			-- Property.CanRead = false

			return "__BREAK", specialProperties -- ? We skip it because even if we use "" it will just reset to default in most cases, unless it's a string tag for example (same as not being defined)
		end
	else
		local CanRead = Property.CanRead
		if CanRead == nil then
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
			if not ok or FilterResult(raw) then
				return "__BREAK", specialProperties
			end
		elseif true == CanRead then
			raw = instance[PropertyName]
		elseif false == CanRead then -- * Skips because we've checked this property before
			return "__BREAK", specialProperties
		end
	end
	return raw, specialProperties
end

local ldeccache = {}

local function ArrayToDictionary(Table, HybridMode)
	local tmp = table.create(#Table)

	if HybridMode == "table" then
		for Some1, Some2 in next, Table do
			if type(Some1) == "number" then
				tmp[Some2] = true
			else
				tmp[Some1] = ArrayToDictionary(Some2, "table") -- Some1 is Class, Some2 is Name
			end
		end
	elseif HybridMode == "bool" then
		for Some1, Some2 in next, Table do
			if type(Some1) == "number" then
				tmp[Some2] = true
			else
				tmp[Some1] = Some2
			end
		end
	else
		for _, Key in next, Table do
			tmp[Key] = true
		end
	end

	return tmp
end
local ClassPropertiesBlacklist =
	{ GuiObject = { "Transparency" }, Instance = { "Parent" }, BasePart = { "BrickColor" }, Attachment = {"WorldCFrame"} } -- GuiObject.Transparency is almost always 1 meaning everything will be transparent; Instance.Parent is useless in xml (no idea about binary); BasePart.BrickColor hurts other Color3 properties; Attachment.WorldCFrame breaks Attachment.CFrame (and is hidden anyway)

for Class, Properties in next, ClassPropertiesBlacklist do
	ClassPropertiesBlacklist[Class] = ArrayToDictionary(Properties)
end
local function FetchAPI()
	local API_Dump_Url = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
	local API_Dump = game:HttpGet(API_Dump_Url, true)
	local API_Classes = service.HttpService:JSONDecode(API_Dump).Classes

	local ClassList = {}

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
		Class.Superclass = API_Class.Superclass

		local ClassProperties = {}

		for _index_1 = 1, #ClassMembers do
			local Member = ClassMembers[_index_1]
			if Member.MemberType == "Property" then
				local PropertyName = Member.Name

				-- ? We avoid this as some Instances like services may have this property locked and thus make file unable to open and it's not even used by Roblox anyways as Parent-Child relationship is done by embedding/nesting

				local Serialization = Member.Serialization

				if Serialization.CanLoad then
					local Blacklisted = ClassPropertiesBlacklist[ClassName]
					if not (Blacklisted and Blacklisted[PropertyName]) then
						local Allowed = true

						local MemberTags = Member.Tags

						local Special

						if MemberTags then
							MemberTags = ArrayToDictionary(MemberTags)

							Special = MemberTags.NotScriptable

							if MemberTags.Deprecated then
								Allowed = nil
							end
						end
						if Allowed then
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
		end

		Class.Properties = ClassProperties

		ClassList[ClassName] = Class
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

local rswait = service.RunService.RenderStepped
local function rwait()
	rswait:Wait()
end

local inheritedproperties = setmetatable({}, {
	__index = function(self, ClassName)
		local proplist = {}
		local layer = ClassList[ClassName]
		while layer do
			local _list_0 = layer.Properties

			-- proplist = table.move(_list_0, 1, #_list_0, #proplist + 1, proplist)
			for _, p in next, _list_0 do
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
	identifier = 0,
}, {
	__index = function(self, instance)
		local Count = self.identifier
		self.identifier = Count + 1
		local referent = "RBX" .. Count -- Todo: Roblox encodes all <Item> elements with a referent attribute. Each value is generated by starting with the prefix RBX, followed by a UUID version 4, with - characters removed, and all characters converted to uppercase. We probably need to do that too for sake of safety
		self[instance] = referent
		return referent
	end,
})

local function ReturnItem(ClassName, instance)
	return '<Item class="' .. ClassName .. '" referent="' .. referents[instance] .. '"><Properties>' -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is ENABLED
end
local function ReturnProperty(Tag, PropertyName, Value)
	return "<" .. Tag .. ' name="' .. PropertyName .. '">' .. Value .. "</" .. Tag .. ">"
end

local function ApiFormatify(Value, Category, ValueType, Default)
	if Category == "Enum" then
		Value = Descriptors.__ENUMNAME(Value)
	elseif Category == "Primitive" then
		Value = Descriptors[ValueType](Value, Default)
	end
	return tostring(Value)
end

local function ReturnValueAndTag(raw, ValueType, Descriptor)
	local value, tag = (Descriptor or Descriptors[ValueType])(raw)

	return value, tag == nil and ValueType or tag
end

local BlacklistedDefaults = {
	__api_dump_class_not_creatable__ = true,
	__api_dump_no_string_value__ = true,
	__api_dump_skipped_class__ = true,
	-- __api_dump_write_only_property__ = true, -- ? Is this needed
}

local StatusGui = Instance.new("ScreenGui")
StatusGui.DisplayOrder = 2_000_000_000
StatusGui.OnTopOfCoreBlur = true

local function randomString()
	local randomarray = {}
	for i = 1, math.random(10, 20) do
		randomarray[i] = string.char(math.random(32, 126))
	end
	return table.concat(randomarray)
end
if globalcontainer.gethui then
	StatusGui.Name = randomString()
	StatusGui.Parent = globalcontainer.gethui()
elseif globalcontainer.protectgui and not (is_sirhurt_closure or (syn and DrawingImmediate)) then
	StatusGui.Name = randomString()
	globalcontainer.protectgui(StatusGui)
	StatusGui.Parent = service.CoreGui
else
	local RobloxGui = service.CoreGui:FindFirstChild("RobloxGui")
	if RobloxGui then
		StatusGui.Parent = RobloxGui
	else
		StatusGui.Name = randomString()
		StatusGui.Parent = service.CoreGui
	end
end
local StatusText = Instance.new("TextLabel")
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.Code

StatusText.AnchorPoint = Vector2.new(1)
StatusText.Position = UDim2.new(1)
StatusText.Size = UDim2.new(0.3, 0, 0, 20)
StatusText.Text = "Starting..."
StatusText.TextColor3 = Color3.new(1, 1, 1)
StatusText.TextScaled = true
StatusText.TextStrokeTransparency = 0.7
StatusText.TextXAlignment = Enum.TextXAlignment.Right
StatusText.TextYAlignment = Enum.TextYAlignment.Top

local ScriptsClasses = ArrayToDictionary({ "LocalScript", "ModuleScript", Script = false }, "bool")
local function synsaveinstance(CustomOptions)
	table.clear(SharedStrings)

	local total = ""
	local savebuffer = {}
	local StatusTextClone

	local OPTIONS = {
		mode = "optimized", -- Change this to invalid mode like "custom" if you only want extrainstances; -- ! "optimized" mode is NOT supported with OPTIONS.Object option
		noscripts = false,
		scriptcache = true,
		-- decomptype = "new", -- * Deprecated
		timeout = 30, -- Description: If the decompilation run time exceeds this value it gets cancelled.
		--* New:
		__DEBUG_MODE = false, -- Recommended to enable if you wish to help us improve our products and find bugs / issues with it!
--Callback = nil, -- Description: If set, the serialized data will be sent to the callback instead of to file.
		--Clipboard = false, -- Description: If set to true, the serialized data will be set to the clipboard, which can be later pasted into studio easily. Useful for saving models.
		DecompileIgnore = { -- * Clean these up (merged Old Syn and New Syn)
			"Chat",
			"TextChatService",
		}, -- Scripts inside of these ClassNames will be saved but not decompiled
		--[[ Explanation of structure for DecompileIgnore
			{
			"Chat", - This affects any descendants of instance with "Chat" ClassName 
			Players = {"MyPlayerName"} - - This affects any descendants of instance with "Players" .Class AND "MyPlayerName" .Name ONLY
		}
		]]
PropertiesBlacklist = {},
		InstancesBlacklist = { "CoreGui", "CorePackages" },
		--[[ Explanation of structure for InstancesBlacklist
			{
			"CoreGui", - This affects any descendants of instance with "Chat" ClassName 
			Players = {"MyPlayerName"} - - This affects any descendants of instance with "Players" .Class AND "MyPlayerName" .Name ONLY
		}
		]]
		ExtraInstances = {},
		NilInstances = false, -- Description: Save nil instances.
		NilInstancesFixes = {
			Animator = function(instance)
				local AnimationController = Instance.new("AnimationController")
				AnimationController.Name = "Animator has to be placed under Humanoid or AnimationController"
				instance:Clone().Parent = AnimationController
				return AnimationController
			end,
		},
		ShowStatus = true,
		FilePath = false, --  does not need to contain a file extension, only the name of the file.
		Object = false, -- If provided, saves as .rbxmx (Model file) instead; If Object is game, it will be saved as a .RBXL file -- ! MUST BE AN INSTANCE REFERENCE like game.Workspace for example; "optimized" mode is NOT supported with this option
		-- Binary = false, -- true in syn newer versions (false in our case because no binary support yet), Description: Saves everything i Binary Mode (rbxl/rbxm).
		-- Decompile = not OPTIONS.noscripts, -- ! This takes priority over OPTIONS.noscripts if set, Description: If true scripts will be decompiled.
		-- DecompileTimeout = OPTIONS.timeout, -- ! This takes priority over OPTIONS.timeout if set
		IgnoreDefaultProperties = true, -- Description: When enabled it will ignore default properties while saving.
		IgnoreNotArchivable = true,
		IgnorePropertiesOfNotScriptsOnScriptsMode = false, -- Ignores property of every instance that is not a script in "scripts" mode
		IgnoreSpecialProperties = false, -- true will disable Terrain & Break MeshPart Sizes (very likely)
		IsolateStarterPlayer = false, --If enabled, StarterPlayer will be cleared and the saved starter player will be placed into folders.
		IsolateLocalPlayer = false, -- Saves Children of LocalPlayer as separate folder and prevents any instance of ClassName Player with .Name identical to LocalPlayer.Name from saving
		IsolateLocalPlayerCharacter = false, -- Saves Children of LocalPlayer.Character as separate folder and prevents any instance of ClassName Player with .Name identical to LocalPlayer.Name from saving
		-- MaxThreads = 3 -- Description: The number of decompilation threads that can run at once. More threads means it can decompile for scripts at a time.
		RemovePlayerCharacters = true, -- Description: Ignore player characters while saving.
		SavePlayers = false, -- This option does save players, it's just they won't show up in Studio and can only be viewed through the place file code (in text editor). More info at https://github.com/luau/UniversalSynSaveInstance/issues/2
		SaveCacheInterval = 0x1600, -- The less the more often it saves, but that would mean less performance due to constantly saving
		ReadMe = true,

		-- ! Risky

		AllowResettingProperties = false, -- Enables Resetting of properties for sake of checking their default value (Useful for cases when Instance is NotCreatable like services yet we need to get the default value ) then sets the property back to the original value, which might get detected by some games --! WARNING: Sometimes Properties might not be able to be set to the original value due to circumstances
IgnoreSharedStrings = true, -- ! FIXES CRASHES (TEMPORARY, TESTED ON ROEXEC ONLY); FEEL FREE TO DISABLE THIS TO SEE IF IT WORKS FOR YOU
		SharedStringOverwrite = false, -- !  if the process is not finished aka crashed then none of the affected values will be available; SharedStrings can also be used for ValueTypes that aren't `SharedString`, this behavior is not documented anywhere but makes sense (Could create issues though, due to _potential_ ValueType mix-up, only works on certain types which are all base64 encoded so far); Reason: Allows for potential smaller file size (can also be bigger in some cases)
	}

	if type(CustomOptions) == "table" then
		for key, value in next, CustomOptions do
			if OPTIONS[key] ~= nil then
				OPTIONS[key] = value
			end
		end
		local Decompile = CustomOptions.Decompile
		if Decompile ~= nil then
			OPTIONS.noscripts = not Decompile
		end
		local DecompileTimeout = CustomOptions.DecompileTimeout
		if DecompileTimeout ~= nil then
			OPTIONS.timeout = DecompileTimeout
		end
		local IgnoreDefaultProps = CustomOptions.IgnoreDefaultProps
		if IgnoreDefaultProps ~= nil then
			OPTIONS.IgnoreDefaultProperties = IgnoreDefaultProps
		end
	else
		CustomOptions = {}
	end
	local Timeout = OPTIONS.timeout
	local ldecompile

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
			local ok, result = pcall(decompile, Script, Timeout, Timeout) -- ! This might break on Syn due to second param being bool or string (deprecated tho)
			ldeccache[Script] = result
			return ok and result or "--[[Failed to decompile\nReason:\n" .. (result or "") .. "\n]]"
		end
	else
		ldecompile = function()
			return "-- Decompiling is NOT supported on your executor"
		end
	end
	local ToSaveInstance = OPTIONS.Object

	if ToSaveInstance == game then
		ToSaveInstance = nil
	end
	local FilePath = OPTIONS.FilePath
	local IgnorePropertiesOfNotScriptsOnScriptsMode = OPTIONS.IgnorePropertiesOfNotScriptsOnScriptsMode
	local placename

	local ToSaveList
	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = table.clone(OPTIONS.ExtraInstances)

		local PlaceId = game.PlaceId
		if ToSaveInstance then
			if mode == "optimized" then -- ! NOT supported with Model file mode
				mode = "full"
			end
			
			for _, key in next,
				{
					"IsolateLocalPlayerCharacter",
					"IsolateStarterPlayer",
					"IsolateLocalPlayer",
					"NilInstances",
				}
			do
				if not CustomOptions[key] then
				OPTIONS[key] = false
end
			end

			placename = (FilePath or "model" .. PlaceId .. "_" .. ToSaveInstance:GetDebugId(0)) .. ".rbxmx" -- * GetDebugId is only unique per instance within same game session, after rejoining it might be different
		else
			placename = (FilePath or "place" .. PlaceId) .. ".rbxlx"
		end

		if mode ~= "scripts" then
			IgnorePropertiesOfNotScriptsOnScriptsMode = nil
		end

		local TempRoot = ToSaveInstance or game

		if mode == "full" then
			tmp = TempRoot:GetChildren()
		elseif mode == "optimized" then -- ! Incompatible with .rbxmx (Model file) mode
			local _list_0 = {
				"Chat",
				"InsertService",
				"JointsService",
				"Lighting",
				"MaterialService",
				"ReplicatedFirst",
				"ReplicatedStorage",
				"ServerStorage", -- ? Why
				"ServerScriptService", -- ? Why
				"SoundService",
				"StarterGui",
				"StarterPack",
				"StarterPlayer",
				"Teams",
				"TextChatService",
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
			local Hierarchy = TempRoot:GetDescendants()
			local cach = {}
			for _index_0 = 1, #Hierarchy do
				local instance = Hierarchy[_index_0]

				if ScriptsClasses[instance.ClassName] then
					local Parent = instance.Parent
					while Parent and Parent ~= TempRoot do
						instance = instance.Parent
						Parent = instance.Parent
					end
					if Parent then
						cach[instance] = true
					end
				end
			end
			for instance in next, cach do
				table.insert(tmp, instance)
			end
		end
		ToSaveList = tmp
	end

	local DecompileIgnore, InstancesBlacklist, PropertiesBlacklist =
		ArrayToDictionary(OPTIONS.DecompileIgnore, "table"),
		ArrayToDictionary(OPTIONS.InstancesBlacklist, "table"),
		ArrayToDictionary(OPTIONS.PropertiesBlacklist, "table")

	local __DEBUG_MODE = OPTIONS.__DEBUG_MODE
	local AllowResettingProperties = OPTIONS.AllowResettingProperties
	local IgnoreDefaultProperties = OPTIONS.IgnoreDefaultProperties
	local IgnoreNotArchivable = OPTIONS.IgnoreNotArchivable
	local IgnoreSpecialProperties = OPTIONS.IgnoreSpecialProperties
	local IsolateLocalPlayer = OPTIONS.IsolateLocalPlayer

	local IsolateLocalPlayerCharacter = OPTIONS.IsolateLocalPlayerCharacter
	local IsolateStarterPlayer = OPTIONS.IsolateStarterPlayer
	local SaveCacheInterval = OPTIONS.SaveCacheInterval

	local SharedStringOverwrite = OPTIONS.SharedStringOverwrite
local IgnoreSharedStrings = OPTIONS.IgnoreSharedStrings

	local function getsizeformat()
		local Size
		local BinaryPrefixes = {
			"B",
			"KB",
			"MB",
			"GB",
			"TB",
		}
		for Index = 1, #BinaryPrefixes do
			local buffersize = #total
			if buffersize < 0x400 ^ Index then
				Size = math.floor(buffersize / (0x400 ^ (Index - 1)) * 10) / 10 .. " " .. BinaryPrefixes[Index]
				break
			end
		end
		return Size
	end

	local function savecache()
		local savestr = table.concat(savebuffer)
		total = total .. savestr
		writefile(placename, total)
		if StatusTextClone then
			StatusTextClone.Text = "Saving.. Size: " .. getsizeformat()
		end
		savebuffer = {}
		rwait()
	end
	local DecompileIgnoring
	local function savehierarchy(Hierarchy, Afterwards)
		if SaveCacheInterval < #savebuffer then
			savecache()
		end
		for _index_0 = 1, #Hierarchy do
			repeat
				local instance = Hierarchy[_index_0]

				local ClassName = instance.ClassName
				local InstanceName = instance.Name
				local Blacklisted = InstancesBlacklist[ClassName]
				if
					instance.RobloxLocked
					or not ClassList[ClassName]
					or IgnoreNotArchivable and not instance.Archivable
					or Blacklisted and (Blacklisted == true or Blacklisted[InstanceName])
				then
					break
				end

				if not DecompileIgnoring then
					local DecompileIgnored = DecompileIgnore[ClassName]
					DecompileIgnoring = DecompileIgnored
						and (DecompileIgnored == true or DecompileIgnored[InstanceName])
						and instance
				end

				local Properties = inheritedproperties[ClassName]
				savebuffer[#savebuffer + 1] = ReturnItem(ClassName, instance) -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is ENABLED
				local Ignored
				if IgnorePropertiesOfNotScriptsOnScriptsMode and ScriptsClasses[ClassName] == nil then
					Ignored = true
				end
				if not Ignored then
					local specialProperties, Replica
					for _index_1 = 1, #Properties do
						local Property = Properties[_index_1]
						local PropertyName = Property.Name

						repeat
							if PropertiesBlacklist[PropertyName] then
								break
							end
							local Special = Property.Special
							if IgnoreSpecialProperties and Special then
								break
							end

							local ValueType = Property.ValueType

							if IgnoreSharedStrings and ValueType == "SharedString" then -- ? More info in Options
								break
							end

							local raw
							raw, specialProperties =
								ReadProperty(Property, instance, PropertyName, specialProperties, Special)
							if raw == "__BREAK" then
								break
							end
							
							if SharedStringOverwrite and ValueType == "BinaryString" then -- TODO: Convert this to  table if more types are added
								ValueType = "SharedString"
							end

							local Category = Property.Category

							if IgnoreDefaultProperties and PropertyName ~= "Source" then -- ? Source is special, might need to be changed to check for LuaSourceContainer IsA instead
								local ok, IsModified = pcall(IsPropertyModified, instance, PropertyName) -- ? Not yet enabled lol (580)
								if ok and not IsModified then
									break
								end

								local Default = Property.Default

								if BlacklistedDefaults[Default] then
									local ClassTags = ClassList[ClassName].Tags

									local NotCreatable = ClassTags and ClassTags.NotCreatable

									local Reset

									if NotCreatable then -- TODO: This whole block should only run if Replica doesn't exist yet, except ResetPropertyToDefault because it's needed for just about every property of NotCreatable objects (in order to check default if undefined in API Dump)
										if AllowResettingProperties then
											Reset = pcall(ResetPropertyToDefault, instance, PropertyName)
											if Reset and not Replica then
												Replica = instance
											end
										end
									elseif not Replica then
										Replica = classreplicas[ClassName]
									end

									if Replica and not (NotCreatable and not Reset) then
										Default = ReadProperty(Property, Replica, PropertyName, specialProperties, Special)
										-- * Improve this along with specialProperties (merge or maybe store the method to Property.Special), get this property at any cost

										if Reset and not SetProperty(Replica, PropertyName, raw) and __DEBUG_MODE then -- It has been reset
											warn(
												"FAILED TO SET BACK TO ORIGINAL VALUE (OPEN A GITHUB ISSUE): ",
												ValueType,
												ClassName,
												PropertyName
											)
										end

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
								local Descriptor = Descriptors[ValueType]

								if Descriptor then
									value, tag = ReturnValueAndTag(raw, ValueType, Descriptor)
								elseif "BinaryString" == ValueType then -- TODO: Try fitting this inside Descriptors
									tag = ValueType
									value = Descriptors.__BINARYSTRING(raw)

									if -- ? Roblox doesn't CDATA anything else other than these as far as we know (feel free to prove us wrong)
										PropertyName == "SmoothGrid"
										or PropertyName == "MaterialColors"
										or PropertyName == "PhysicsGrid"
									then
										value = Descriptors.__CDATA(value)
									end
								elseif "ProtectedString" == ValueType then -- TODO: Try fitting this inside Descriptors
									tag = ValueType

									if PropertyName == "Source" then
										if ScriptsClasses[ClassName] == false then
											value = "-- Server scripts can NOT be decompiled" --TODO: Could be not just server scripts in the future
										else
											if DecompileIgnoring then
												value = "-- Ignored"
											else
												value = ldecompile(instance)
											end
										end
									end

									value = Descriptors.__PROTECTEDSTRING(value)
								else
									--OptionalCoordinateFrame and so on, we make it dynamic
									local startIDX, endIDX = Find(ValueType, "Optional")
									if startIDX == 1 then
										-- Extract the string after "Optional"

										Descriptor = Descriptors[string.sub(ValueType, endIDX + 1)]

										if Descriptor then
											if raw ~= nil then
												value, tag = ReturnValueAndTag(raw, ValueType, Descriptor)
											else
												value, tag = "", ValueType
											end
										end
									end
								end
							end

							if tag then
								savebuffer[#savebuffer + 1] = ReturnProperty(tag, PropertyName, value)
							elseif __DEBUG_MODE then
								warn("UNSUPPORTED TYPE (OPEN A GITHUB ISSUE): ", ValueType, ClassName, PropertyName)
							end

						until true
					end
				end
				savebuffer[#savebuffer + 1] = "</Properties>"
				local Children = Afterwards or instance:GetChildren()
				if #Children ~= 0 then
					savehierarchy(Children)
				end

				if DecompileIgnoring and DecompileIgnoring == instance then
					DecompileIgnoring = nil
				end

				savebuffer[#savebuffer + 1] = "</Item>"

			until true
		end
	end
	local function saveextra(Name, Hierarchy, CustomClassName, Source)
		local Ref = Instance.new(CustomClassName or "Folder")

		local PropertyName = "Name"
		local ValueType = ClassList.Instance.Properties[PropertyName].ValueType
		local value, tag = ReturnValueAndTag(Name, ValueType)

		local Buffer = ReturnItem(Ref.ClassName, Ref) .. ReturnProperty(tag, PropertyName, value)

		if Source then
			Buffer = Buffer .. ReturnProperty("ProtectedString", "Source", Descriptors.__PROTECTEDSTRING(Source))
		end

		Buffer = Buffer .. "</Properties>"

		table.insert(savebuffer, Buffer)
		if Hierarchy then
			savehierarchy(Hierarchy)
		end
		table.insert(savebuffer, "</Item>")
	end

	local function savegame()
		local nilinstances
		if OPTIONS.NilInstances and globalcontainer.getnilinstances then
			local tmp = {}

			local NilInstancesFixes = OPTIONS.NilInstancesFixes
			
			for _, instance in next, globalcontainer.getnilinstances() do
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

					local Class = ClassList[ClassName]
					if Class then
						local ClassTags = Class.Tags
						if ClassTags and ClassTags.Service then
							instance.Parent = game
							instance = nil
							-- continue
						end
					end
				end
				if instance then
					table.insert(tmp, instance)
				end
			end
			nilinstances = tmp
		end
		local Starter = '<roblox version="4">'
		if ToSaveInstance then
			Starter = Starter .. '<Meta name="ExplicitAutoJoints">true</Meta>'
		end
		table.insert(savebuffer, Starter) --[[
			-- ? Roblox encodes the following additional attributes. These are not required. Moreover, any defined schemas are ignored, and not required for a file to be valid: xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd"  
		Also http can be converted to https but not sure if Roblox would decide to detect that
		-- ? <External>null</External><External>nil</External>  - <External> is a legacy concept that is no longer used.
		]]

		if ToSaveInstance then
			savehierarchy({ ToSaveInstance }, ToSaveList)
		else
			savehierarchy(ToSaveList)
		end

		if IsolateLocalPlayer or IsolateLocalPlayerCharacter then
			local Players = service.Players
			local LocalPlayer = Players.LocalPlayer
			if IsolateLocalPlayer then
				saveextra("LocalPlayer", LocalPlayer:GetChildren())
			end
			if IsolateLocalPlayerCharacter then
				local LocalPlayerCharacter = LocalPlayer.Character
				if LocalPlayerCharacter then
					saveextra("LocalPlayer Character", LocalPlayerCharacter:GetChildren())
				end
			end
		end
		if IsolateStarterPlayer then
			saveextra("StarterPlayer", service.StarterPlayer:GetChildren())
		end

		if nilinstances then
			saveextra("Nil Instances", nilinstances)
		end
		if OPTIONS.ReadMe then
			saveextra("README", nil, "Script", "--[[\n" .. [[
			Thank you for using SynSaveInstance Revival.
			We recommended to save the game right away to take advantage of the binary format (if you didn't save in binary) AND to preserve values of certain properties if you used IgnoreDefaultProperties setting (as they might change in the future).
			If your player cannot spawn into the game, please move the scripts in StarterPlayer elsewhere. (This is done by default)
			If the chat system does not work, please use the explorer and delete everything inside the Chat service. 
			Or run `game:GetService("Chat"):ClearAllChildren()`
	
			If Union and MeshPart collisions don't work, run the script below in the Studio Command Bar:
	
	
			local C = game:GetService("CoreGui")
			local D = Enum.CollisionFidelity.Default
	
			for _, v in game:GetDescendants() do
				if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
					v.CollisionFidelity = D
				end
			end
	
If you can't move the Camera, run the scripts in the Studio Command Bar:
	
workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
	
			This file was generated with the following settings:
	]] .. service.HttpService:JSONEncode(OPTIONS) .. "\n]]")
		end
		local tmp = { "<SharedStrings>" }
		for Identifier, Value in next, SharedStrings do
			tmp[#tmp + 1] = '<SharedString md5="' .. Identifier .. '">' .. Value .. "</SharedString>"
		end

		if 1 < #tmp then -- TODO: This sucks so much because we try to iterate a table just to check this (check above)
			table.insert(savebuffer, table.concat(tmp))
			table.insert(savebuffer, "</SharedStrings>")
		end

		table.insert(savebuffer, "</roblox>")
		savecache()
	end

	if OPTIONS.ShowStatus then
		local Exists = StatusGui:FindFirstChild("TextLabel")
		if Exists then
			Exists:Destroy()
		end
		StatusTextClone = StatusText:Clone()
		StatusTextClone.Parent = StatusGui
	end
	if not OPTIONS.SavePlayers and not InstancesBlacklist.Players then
		InstancesBlacklist.Players = {}
	end
	if OPTIONS.RemovePlayerCharacters then
		local Players = service.Players

		local T = InstancesBlacklist.Model
		if T ~= true then
			if not T then
				T = {}
			end
			for _, Player in next, Players:GetPlayers() do
				T[Player.Name] = true
			end
			InstancesBlacklist.Model = T
		end
	end
	if IsolateStarterPlayer then
		InstancesBlacklist.StarterPlayer = true
	end
	if IsolateLocalPlayer or IsolateLocalPlayerCharacter then
		local Players = service.Players
		local LocalPlayer = Players.LocalPlayer
		local LocalPlayerName = LocalPlayer.Name
		if IsolateLocalPlayer and InstancesBlacklist.Player ~= true then
			if not InstancesBlacklist.Player then
				InstancesBlacklist.Player = {}
			end

			InstancesBlacklist.Player[LocalPlayerName] = true
		end
		if IsolateLocalPlayerCharacter and InstancesBlacklist.Model ~= true then
			if not InstancesBlacklist.Model then
				InstancesBlacklist.Model = {}
			end

			InstancesBlacklist.Model[LocalPlayerName] = true
		end
	end

	do
		local elapse_t = os.clock()
		local ok, err = xpcall(savegame, function(err)
			return debug.traceback(err)
		end)
		elapse_t = os.clock() - elapse_t

		local Log10 = math.log10(elapse_t)

		if StatusTextClone then
local ExtraTime = 10
			if ok then
				StatusTextClone.Text = string.format("Saved! Time %.2f seconds; Size %s", elapse_t, getsizeformat())
				task.wait(Log10 * 2 + ExtraTime)
			else
				StatusTextClone.Text = "Failed! Check F9 console for more info"
				warn("Error found while saving")
				warn("Information about error:")
				warn(err)
				task.wait(Log10 + ExtraTime)
			end
			StatusTextClone:Destroy()
		end
	end
end

return synsaveinstance
