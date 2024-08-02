--!native
--!optimize 2
--!divine-intellect
-- https://discord.gg/wx4ThpAsmw

local service = setmetatable({}, {
	__index = function(self, index)
		local Service = game:GetService(index) or settings():GetService(index) or UserSettings():GetService(index)
		self[index] = Service
		return Service
	end,
})

local function string_find(s, pattern)
	return string.find(s, pattern, nil, true)
end

local function ArrayToDictionary(t, hydridMode, valueOverride)
	local tmp = {}

	if hydridMode then
		for some1, some2 in t do
			if type(some1) == "number" then
				tmp[some2] = valueOverride or true
			elseif type(some2) == "table" then
				tmp[some1] = ArrayToDictionary(some2, hydridMode) -- Some1 is Class, Some2 is Name
			else
				tmp[some1] = some2
			end
		end
	else
		for _, key in t do
			if type(key) == "string" then
				tmp[key] = true
			end
		end
	end

	return tmp
end

local ESCAPES_PATTERN = "[&<>\"'\0\1-\9\11-\12\14-\31\127-\255]" -- * The safe way is to escape all five characters in text. However, the three characters " ' and > needn't be escaped in text
-- %z (\0 aka NULL) might not be needed as Roblox automatically converts it to space everywhere it seems like
-- Characters from: https://create.roblox.com/docs/en-us/ui/rich-text#escape-forms
-- * EscapesPattern should be ordered from most common to least common characters for sake of speed
-- * Might wanna use their numerical codes instead of named codes for reduced file size (Could be an Option)
-- TODO Maybe we should invert the pattern to only allow certain characters (future-proof)
local ESCAPES = {
	["&"] = "&amp;", -- 38
	["<"] = "&lt;", -- 60
	[">"] = "&gt;", -- 62
	['"'] = "&#34;", --  quot
	["'"] = "&#39;", -- apos
	["\0"] = "",
}

for rangeStart, rangeEnd in string.gmatch(ESCAPES_PATTERN, "(.)%-(.)") do
	for charCode = string.byte(rangeStart), string.byte(rangeEnd) do
		ESCAPES[string.char(charCode)] = "&#" .. charCode .. ";"
	end
end

local global_container
do
	local filename = "UniversalMethodFinder"

	local finder
	finder, global_container = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
		filename
	)()

	finder({
		-- readbinarystring = 'string.find(...,"bin",nil,true)', -- ! Could match some unwanted stuff (getbinaryindex)
		-- request = 'string.find(...,"request",nil,true) and not string.find(...,"internal",nil,true)',
		base64encode = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"encode")and(c(b,"base64")or c(string.lower(tostring(a[2])),"base64"))',
		decompile = '(string.find(...,"decomp",nil,true) and string.sub(...,#...) ~= "s") or string.find(...,"assembl",nil,true)',
		gethiddenproperty = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) ~= "s"',
		gethui = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"ui",nil,true)',
		getnilinstances = 'string.find(...,"nil",nil,true) and string.find(...,"get",nil,true) and string.sub(...,#...) == "s"', -- ! Could match some unwanted stuff
		getscriptbytecode = 'string.find(...,"get",nil,true) and string.find(...,"bytecode",nil,true)', --  or string.find(...,"dump",nil,true) and string.find(...,"string",nil,true) due to Fluxus (dumpstring returns a function)
		hash = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"hash")and c(string.lower(tostring(a[2])),"crypt")',
		protectgui = 'string.find(...,"protect",nil,true) and string.find(...,"ui",nil,true) and not string.find(...,"un",nil,true)',
		setthreadidentity = 'string.find(...,"identity",nil,true) and string.find(...,"set",nil,true)',
	}, true, 10)
end

local identify_executor = identifyexecutor or getexecutorname or whatexecutor

local EXECUTOR_NAME = identify_executor()

local gethiddenproperty = global_container.gethiddenproperty

-- These should be universal enough
local appendfile = appendfile
local readfile = readfile
local writefile = writefile

local getscriptbytecode = global_container.getscriptbytecode -- * A lot of assumptions are made based on whether this function is defined or not. So in certain edge cases, like if the executor defines "decompile" or "getscripthash" function yet doesn't define this function there might be loss of functionality of the saveinstance. Although that would be very rare and weird
local base64encode = global_container.base64encode
local sha384

if not gethiddenproperty or EXECUTOR_NAME == "Celery" then -- ? Celery Fix
	local UGCValidationService = service.UGCValidationService

	gethiddenproperty = function(instance, property_name)
		return UGCValidationService:GetPropertyValue(instance, property_name) -- :)
	end
end

if not base64encode then
	if not bit32.byteswap or not pcall(bit32.byteswap, 1) then -- Because Fluxus is missing byteswap
		bit32 = table.clone(bit32)

		local function tobit(num)
			num %= (bit32.bxor(num, 32))
			if 0x80000000 < num then
				num -= bit32.bxor(num, 32)
			end
			return num
		end

		bit32.byteswap = function(num)
			local BYTE_SIZE = 8
			local MAX_BYTE_VALUE = 255

			num %= bit32.bxor(2, 32)

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

	-- Credits @Reselim
	local Base64_Encode_Buffer = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/Reselim/Base64/master/Base64.lua", true),
		"Base64"
	)().encode
	base64encode = function(raw)
		return raw == "" and raw or buffer.tostring(Base64_Encode_Buffer(buffer.fromstring(raw)))
	end
end

do
	local hash = global_container.hash

	if hash then
		sha384 = function(data)
			return hash(data, "sha384")
		end
	else
		local filename = "RequireOnlineModule"

		sha384 = loadstring(
			game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
			filename
		)()(4544052033).sha384
	end
end

local custom_decompiler, load_decompiler -- TODO Temporary

if getscriptbytecode then
	-- Credits @w-a-e
	local decompiler_source

	if
		pcall(function()
			decompiler_source =
				game:HttpGet("https://raw.githubusercontent.com/w-a-e/Advanced-Decompiler-V3/main/init.lua", true)
		end)
	then
		load_decompiler = function(decompTimeout)
			local CONSTANTS = [[
	local ENABLED_REMARKS = {
		NATIVE_REMARK = true,
		INLINE_REMARK = true
	}
	local DECOMPILER_TIMEOUT = ]] .. decompTimeout .. [[
		
	local READER_FLOAT_PRECISION = 7 -- up to 99
	local SHOW_INSTRUCTION_LINES = false
	local SHOW_REFERENCES = true
	local SHOW_OPERATION_NAMES = false
	local SHOW_MISC_OPERATIONS = false
	local LIST_USED_GLOBALS = true
	local RETURN_ELAPSED_TIME = false
	]]
			local _ENV = (getgenv or getrenv or getfenv)()
			local old = _ENV.decompile

			local f = loadstring(
				string.gsub(
					string.gsub(
						decompiler_source,
						"return %(x %% 2^32%) // %(2^disp%)",
						"return math.floor((x %% 2^32) / (2^disp))",
						1
					), -- TODO Temporary fix for macsploit (// operator)
					";;CONSTANTS HERE;;",
					CONSTANTS
				),
				"Advanced-Decompiler-V3"
			)
			if not f then
				return
			end
			f()
			custom_decompiler = _ENV.decompile
			_ENV.decompile = old
		end
	end
end

local SharedStrings = {}
local SharedString_identifiers = setmetatable({
	identifier = 1e15, -- 1 quadrillion, up to 9.(9) quadrillion, in theory this shouldn't ever run out and be enough for all sharedstrings ever imaginable
	-- TODO: worst case, add fallback to str randomizer once numbers run out : )
}, {
	__index = function(self, str)
		local Identifier = base64encode(tostring(self.identifier)) -- tostring is only needed for built-in base64encode, Reselim's doesn't need it as buffers autoconvert
		self.identifier += 1

		self[str] = Identifier -- ? The value of the md5 attribute is a Base64-encoded key. <SharedString> type elements use this key to refer to the value of the string. The value is the text content, which is Base64-encoded. Historically, the key was the MD5 hash of the string value. However, this is not required; the key can be any value that will uniquely identify the shared string. Roblox currently uses BLAKE2b truncated to 16 bytes..
		return Identifier
	end,
})

local Type_IDs = {
	string = 0x02,
	boolean = 0x03,
	-- float = 0x05,
	number = 0x06,
	UDim = 0x09,
	UDim2 = 0x0A,
	BrickColor = 0x0E,
	Color3 = 0x0F,
	Vector2 = 0x10,
	Vector3 = 0x11,
	CFrame = 0x14,
	EnumItem = 0x15,
	NumberSequence = 0x17,
	ColorSequence = 0x19,
	NumberRange = 0x1B,
	Rect = 0x1C,
	Font = 0x21,
}
local CFrame_Rotation_IDs = {
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x02,
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x03,
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x05,
	["\0\0\128\63\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x06,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x07,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x09,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x0a,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x0c,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x0d,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x0e,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x10,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\128"] = 0x11,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x14,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\128"] = 0x15,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x17,
	["\0\0\128\191\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\191\0\0\0\128"] = 0x18,
	["\0\0\0\0\0\0\128\63\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x19,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x1b,
	["\0\0\0\0\0\0\128\191\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x1c,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x1e,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x1f,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x20,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x22,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\191\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\128"] = 0x23,
}
local Binary_Descriptors
Binary_Descriptors = {
	__SEQUENCE = function(raw, valueFormatter, keypointSize, Envelope)
		local Keypoints = raw.Keypoints
		local Keypoints_n = #Keypoints

		local len = 4 + (keypointSize or 12) * Keypoints_n
		local b = buffer.create(len)
		local offset = 0

		buffer.writeu32(b, offset, Keypoints_n)
		offset += 4

		for _, keypoint in Keypoints do
			buffer.writef32(b, offset, Envelope or keypoint.Envelope)
			offset += 4
			buffer.writef32(b, offset, keypoint.Time)
			offset += 4

			local Value = keypoint.Value
			if valueFormatter then
				offset += valueFormatter(Value, b, offset)
			else
				buffer.writef32(b, offset, Value)
				offset += 4
			end
		end

		return b, len
	end,
	--------------------------------------------------------------
	--------------------------------------------------------------
	--------------------------------------------------------------
	["string"] = function(raw)
		local raw_len = #raw
		local len = 4 + raw_len

		local b = buffer.create(len)

		buffer.writeu32(b, 0, raw_len)
		buffer.writestring(b, 4, raw)

		return b, len
	end,
	["boolean"] = function(raw)
		local b = buffer.create(1)

		buffer.writeu8(b, 0, raw and 1 or 0)

		return b, 1
	end,
	["number"] = function(raw) -- double
		local b = buffer.create(8)

		buffer.writef64(b, 0, raw)

		return b, 8
	end,
	["UDim"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.Scale)
		buffer.writei32(b, 4, raw.Offset)

		return b, 8
	end,
	["UDim2"] = function(raw)
		local b = buffer.create(16)

		local Descriptors_UDim = Binary_Descriptors.UDim
		local X = Descriptors_UDim(raw.X)
		buffer.copy(b, 0, X)
		local Y = Descriptors_UDim(raw.Y)
		buffer.copy(b, 8, Y)

		return b, 16
	end,
	["BrickColor"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, raw.Number)

		return b, 4
	end,
	["Color3"] = function(raw)
		local b = buffer.create(12)

		buffer.writef32(b, 0, raw.R)
		buffer.writef32(b, 4, raw.G)
		buffer.writef32(b, 8, raw.B)

		return b, 12
	end,
	["Vector2"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.X)
		buffer.writef32(b, 4, raw.Y)

		return b, 8
	end,
	["Vector3"] = function(raw)
		local b = buffer.create(12)

		buffer.writef32(b, 0, raw.X)
		buffer.writef32(b, 4, raw.Y)
		buffer.writef32(b, 8, raw.Z)

		return b, 12
	end,
	["CFrame"] = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()

		local rotation_ID = CFrame_Rotation_IDs[string.pack("<fffffffff", R00, R01, R02, R10, R11, R12, R20, R21, R22)]

		local len = rotation_ID and 13 or 49
		local b = buffer.create(len)

		-- ? TODO
		-- local write_vector3 = Descriptors.Vector3
		-- local pos = write_vector3(raw.Position)
		-- buffer.copy(b, 0, pos)

		buffer.writef32(b, 0, X)
		buffer.writef32(b, 4, Y)
		buffer.writef32(b, 8, Z)

		if rotation_ID then
			buffer.writeu8(b, 12, rotation_ID)
		else
			buffer.writeu8(b, 12, 0x0)

			-- ? TODO
			-- buffer.copy(b, 13, write_vector3(raw.XVector)) -- R00, R10, R20
			-- buffer.copy(b, 13 + 12, write_vector3(raw.YVector)) -- R01, R11, R21
			-- buffer.copy(b, 13 + 24, write_vector3(raw.ZVector)) -- R02, R12, R22

			buffer.writef32(b, 13, R00)
			buffer.writef32(b, 17, R01)
			buffer.writef32(b, 21, R02)

			buffer.writef32(b, 25, R10)
			buffer.writef32(b, 29, R11)
			buffer.writef32(b, 33, R12)

			buffer.writef32(b, 37, R20)
			buffer.writef32(b, 41, R21)
			buffer.writef32(b, 45, R22)
		end

		return b, len
	end,
	["EnumItem"] = function(raw)
		local b_Name, Name_size = Binary_Descriptors.string(tostring(raw.EnumType))

		local len = Name_size + 4
		local b = buffer.create(len)

		buffer.copy(b, 0, b_Name)
		buffer.writeu32(b, Name_size, raw.Value)

		return b, len
	end,
	["NumberSequence"] = nil,

	["ColorSequence"] = function(raw)
		return Binary_Descriptors.__SEQUENCE(raw, function(color3, b, offset)
			buffer.copy(b, offset, Binary_Descriptors.Color3(color3))
			return 12
		end, 20, 0)
	end,
	["NumberRange"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.Min)
		buffer.writef32(b, 4, raw.Max)

		return b, 8
	end,
	["Rect"] = function(raw)
		local b = buffer.create(16)

		local Descriptors_Vector2 = Binary_Descriptors.Vector2
		local Min = Descriptors_Vector2(raw.Min)
		buffer.copy(b, 0, Min)
		local Max = Descriptors_Vector2(raw.Max)
		buffer.copy(b, 8, Max)

		return b, 16
	end,
	["Font"] = function(raw)
		local Descriptors_string = Binary_Descriptors.string

		local b_Family, Family_size = Descriptors_string(raw.Family)
		local b_CachedFaceId, CachedFaceId_size = Descriptors_string("")

		local len = 3 + Family_size + CachedFaceId_size
		local b = buffer.create(len)

		buffer.writeu16(b, 0, raw.Weight.Value)
		buffer.writeu8(b, 2, raw.Style.Value)

		buffer.copy(b, 3, b_Family)
		buffer.copy(b, 3 + Family_size, b_CachedFaceId)

		return b, len
	end,
}
do
	Binary_Descriptors.NumberSequence = Binary_Descriptors.__SEQUENCE
end

local XML_Descriptors
XML_Descriptors = {
	__APIPRECISION = function(raw, precision)
		if raw == 0 or raw % 1 == 0 then
			return raw
		end

		local Extreme = XML_Descriptors.__EXTREME(raw)
		if Extreme then
			return Extreme
		end

		-- TODO: scientific notation formatting also takes place if value is a decimal (only counts if it starts with 0.) then values like 0.00008 will be formatted as 8.0000000000000006544e-05 ("%.19e"), it must have 5 or more consecutive (?) zeros for this, on other hand, if it doesn't start with 0. then e20+ format is applied in case it has 20 or more consecutive (?) zeros so 1e20 will be formatted as 1e+20 and upwards (1e+19 is not allowed, same as 1e-04 for decimals)
		-- ? The good part is compression of value so less file size BUT at the potential cost of precision loss

		return string.format("%." .. precision .. "f", raw)
	end,
	__BIT = function(...) -- * Credits to Friend (you know yourself)
		local Value = 0

		for i, bit in { ... } do
			if bit then
				Value += 2 ^ (i - 1)
			end
		end

		return Value
	end,
	__CDATA = function(raw) -- ? Normally Roblox doesn't use CDATA unless the string has newline characters (\n); We rather CDATA everything for sake of speed
		return "<![CDATA[" .. raw .. "]]>"
	end,
	__ENUM = function(raw)
		return raw.Value, "token"
	end,
	__EXTREME = function(raw)
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
	__EXTREME_RANGE = function(raw)
		return raw ~= raw and "0" or raw -- Normally we should return "-nan(ind)" instead of "0" but this adds more compatibility
	end,
	__MINMAX = function(min, max, descriptor)
		return "<min>" .. descriptor(min) .. "</min><max>" .. descriptor(max) .. "</max>"
	end,
	__PROTECTEDSTRING = function(raw) -- ? its purpose is to "protect" data from being treated as ordinary character data during processing;
		return string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES) or XML_Descriptors.__CDATA(raw)
	end,
	__SEQUENCE = function(raw, valueFormatter) --The value is the text content, formatted as a space-separated list of floating point numbers.
		-- tostring(raw) also works (but way slower rn)
		local __EXTREME_RANGE = XML_Descriptors.__EXTREME_RANGE

		local Converted = ""

		for _, keypoint in raw.Keypoints do
			local Value = keypoint.Value

			Converted ..= keypoint.Time .. " " .. (valueFormatter and valueFormatter(Value) or __EXTREME_RANGE(Value) .. " " .. __EXTREME_RANGE(
				keypoint.Envelope
			) .. " ") -- ? Trailing whitespace is only needed for lune compatibility
		end

		return Converted
	end,
	__VECTOR = function(X, Y, Z) -- Each element is a <float>
		local Value = "<X>" .. X .. "</X><Y>" .. Y .. "</Y>" -- There is no Vector without at least two Coordinates.. (Vector1, at least on Roblox)

		if Z then
			Value ..= "<Z>" .. Z .. "</Z>"
		end

		return Value
	end,
	--------------------------------------------------------------
	--------------------------------------------------------------
	--------------------------------------------------------------
	Axes = function(raw)
		--The text of this element is formatted as an integer between 0 and 7

		return "<axes>" .. XML_Descriptors.__BIT(raw.X, raw.Y, raw.Z) .. "</axes>"
	end,

	-- ? Roblox uses CDATA only for these (try to prove this wrong): CollisionGroupData, SmoothGrid, MaterialColors, PhysicsGrid
	-- ! Assuming all base64 encoded strings won't have newlines

	-- ! 7/7/24
	-- ! Fix for Electron v3
	-- ! Electron v3 'gethiddenproperty' automatically base64 encodes BinaryString values

	BinaryString = EXECUTOR_NAME == "Electron" and function(raw)
		return raw
	end or base64encode,

	BrickColor = function(raw)
		return raw.Number -- * Roblox encodes the tags as "int", but this is not required for Roblox to properly decode the type. For better compatibility, it is preferred that third-party implementations encode and decode "BrickColor" tags instead. Could also use "int" or "Color3uint8"
	end,
	CFrame = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		return XML_Descriptors.__VECTOR(X, Y, Z)
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
	Color3 = function(raw) -- Each element is a <float>
		return "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>" -- ? It is recommended that Color3 is encoded with elements instead of text.
	end,
	Color3uint8 = function(raw)
		-- https://github.com/rojo-rbx/rbx-dom/blob/master/docs/xml.md#color3uint8

		return 0xFF000000
			+ (math.floor(raw.R * 255) * 0x10000)
			+ (math.floor(raw.G * 255) * 0x100)
			+ math.floor(raw.B * 255) -- ? It is recommended that Color3uint8 is encoded with text instead of elements.

		-- return bit32.bor(
		-- 	bit32.bor(bit32.bor(bit32.lshift(0xFF, 24), bit32.lshift(0xFF * raw.R, 16)), bit32.lshift(0xFF * raw.G, 8)),
		-- 	0xFF * raw.B
		-- )

		-- return tonumber(string.format("0xFF%02X%02X%02X",raw.R*255,raw.G*255,raw.B*255))
	end,
	ColorSequence = function(raw)
		--The value is the text content, formatted as a space-separated list of FLOATing point numbers.

		return XML_Descriptors.__SEQUENCE(raw, function(color3)
			local __EXTREME_RANGE = XML_Descriptors.__EXTREME_RANGE

			return __EXTREME_RANGE(color3.R)
				.. " "
				.. __EXTREME_RANGE(color3.G)
				.. " "
				.. __EXTREME_RANGE(color3.B)
				.. " 0 "
		end)
	end,
	Content = function(raw)
		return raw == "" and "<null></null>" or "<url>" .. XML_Descriptors.string(raw, true) .. "</url>"
	end,
	CoordinateFrame = function(raw)
		return "<CFrame>" .. XML_Descriptors.CFrame(raw) .. "</CFrame>"
	end,
	-- DateTime = function(raw) return raw.UnixTimestampMillis end, -- TODO
	Faces = function(raw)
		-- The text of this element is formatted as an integer between 0 and 63
		return "<faces>"
			.. XML_Descriptors.__BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front)
			.. "</faces>"
	end,
	Font = function(raw)
		local FontString = tostring(raw) -- TODO: Temporary fix

		local EmptyWeight = string_find(FontString, "Weight = ,")
		local EmptyStyle = string_find(FontString, "Style =  }")

		return "<Family>"
			.. XML_Descriptors.Content(raw.Family)
			.. "</Family><Weight>"
			.. (EmptyWeight and "" or XML_Descriptors.__ENUM(raw.Weight))
			.. "</Weight><Style>"
			.. (EmptyStyle and "" or raw.Style.Name) -- Weird but this field accepts .Name of enum instead..
			.. "</Style>" --TODO (OPTIONAL ELEMENT): Figure out how to determine (Content) <CachedFaceId><url>rbxasset://fonts/GothamSSm-Medium.otf</url></CachedFaceId>
	end,
	NumberRange = function(raw) -- tostring(raw) also works
		--The value is the text content, formatted as a space-separated list of floating point numbers.
		local __EXTREME_RANGE = XML_Descriptors.__EXTREME_RANGE

		return __EXTREME_RANGE(raw.Min) .. " " .. __EXTREME_RANGE(raw.Max) --[[.. " "]] -- ! This might be required to bypass detections as thats how its formatted usually; __EXTREME_RANGE is not needed here but it fixes the issue where "nan 10" value would reset to "0 0"
	end,
	NumberSequence = nil,
	-- NumberSequence = Descriptors.__SEQUENCE,
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
		CustomPhysics = "<CustomPhysics>" .. XML_Descriptors.bool(CustomPhysics) .. "</CustomPhysics>"

		return raw
				and CustomPhysics .. "<Density>" .. raw.Density .. "</Density><Friction>" .. raw.Friction .. "</Friction><Elasticity>" .. raw.Elasticity .. "</Elasticity><FrictionWeight>" .. raw.FrictionWeight .. "</FrictionWeight><ElasticityWeight>" .. raw.ElasticityWeight .. "</ElasticityWeight>"
			or CustomPhysics
	end,
	-- ProtectedString = function(raw) return tostring(raw), "ProtectedString" end,
	Ray = function(raw)
		local vector3 = XML_Descriptors.Vector3

		return "<origin>" .. vector3(raw.Origin) .. "</origin><direction>" .. vector3(raw.Direction) .. "</direction>"
	end,
	Rect = function(raw)
		return XML_Descriptors.__MINMAX(raw.Min, raw.Max, XML_Descriptors.Vector2), "Rect2D"
	end,
	Region3 = function(raw) --? Not sure yet (https://github.com/ui0ppk/roblox-master/blob/main/Network/Replicator.cpp#L1306)
		local Translation = raw.CFrame.Position
		local HalfSize = raw.Size * 0.5

		return XML_Descriptors.__MINMAX(
			Translation - HalfSize, -- https://github.com/ui0ppk/roblox-master/blob/main/App/util/Region3.cpp#L38
			Translation + HalfSize, -- https://github.com/ui0ppk/roblox-master/blob/main/App/util/Region3.cpp#L42
			XML_Descriptors.Vector3
		)
	end,
	Region3int16 = function(raw) --? Not sure yet (https://github.com/ui0ppk/roblox-master/blob/main/App/v8tree/EnumProperty.cpp#L346)
		return XML_Descriptors.__MINMAX(raw.Min, raw.Max, XML_Descriptors.Vector3int16)
	end,
	SharedString = function(raw)
		raw = base64encode(raw)

		local Identifier = SharedString_identifiers[raw]

		if SharedStrings[Identifier] == nil then
			SharedStrings[Identifier] = raw
		end

		return Identifier
	end,
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

	-- UniqueId = function(raw)
	--[[
		     UniqueId properties might be random everytime Studio saves a place file
	 and don't have a use right now outside of packages, which SSI doesn't
	 account for anyway. They generate diff noise, so we shouldn't serialize
	 them until we have to.
	]]
	-- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/roblox/LuaPackages/Packages/_Index/ApolloClientTesting/ApolloClientTesting/utilities/common/makeUniqueId.lua#L62
	-- 	return "" -- ? No idea if this even needs a Descriptor
	-- end,

	Vector2 = function(raw)
		--[[
    X: Represents the X component. Interpreted as a <float>.
    Y: Represents the Y component. Interpreted as a <float>.
	]]
		return XML_Descriptors.__VECTOR(raw.X, raw.Y)
	end,
	Vector2int16 = nil,
	-- Vector2int16 = Descriptors.Vector2, -- except as <int>
	Vector3 = function(raw)
		--[[
    X: Represents the X component. Interpreted as a <float>.
    Y: Represents the Y component. Interpreted as a <float>.
    Z: Represents the Z component. Interpreted as a <float>.
	]]
		return XML_Descriptors.__VECTOR(raw.X, raw.Y, raw.Z)
	end,
	Vector3int16 = nil,
	-- Vector3int16 = Descriptors.Vector3, -- except as <int>\
	bool = function(raw)
		return raw and "true" or "false"
	end,
	double = function(raw) -- Float64
		return XML_Descriptors.__APIPRECISION(raw, 17) --? A precision of at least 17 is required to properly represent a 64-bit floating point value, so this amount is recommended.
	end, -- ? wouldn't float be better as an optimization
	float = function(raw) -- Float32
		return XML_Descriptors.__APIPRECISION(raw, 9) -- ? A precision of at least 9 is required to properly represent a 32-bit floating point value, so this amount is recommended.
	end,
	int = function(raw) -- Int32
		return XML_Descriptors.__EXTREME(raw) or raw
	end,
	int64 = nil,
	string = function(raw, skipEmptyCheck)
		return not skipEmptyCheck and raw == "" and raw
			or string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES)
			or XML_Descriptors.__CDATA(string.gsub(raw, "\0", ""))
	end,
}
for descriptorName, redirectName in
	{
		NumberSequence = "__SEQUENCE",
		Vector2int16 = "Vector2",
		Vector3int16 = "Vector3",
		int64 = "int", -- Int64 (long)
	}
do
	XML_Descriptors[descriptorName] = XML_Descriptors[redirectName]
end

local ClassList

do
	local ClassPropertyExceptions = { TriangleMeshPart = ArrayToDictionary({ "CollisionFidelity" }) }

	local function FetchAPI()
		-- * You can also use: https://setup.rbxcdn.com/{https://setup.rbxcdn.com/versionQTStudio}-Full-API-Dump.json
		-- * https://setup.rbxcdn.com/versionQTStudio seems to be a bit behind DeployHistory.txt
		local API_Dump

		local ok, err = pcall(function()
				local VERSIONS = version()

				local o, r = pcall(readfile, VERSIONS)
				if o and r and r ~= "" then
					API_Dump = r
					return
				end

				local latest_commit = service.HttpService:JSONDecode(
					game:HttpGet(
						"https://api.github.com/search/commits?sort=committer-date&order=desc&q=repo:MaximumADHD/Roblox-Client-Tracker+0."
							.. string.split(VERSIONS, ".")[2],
						true
					)
				).items[1]
				-- print(VERSIONS)
				-- print(latest_commit.commit.message)
				API_Dump = game:HttpGet(
					"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/"
						.. latest_commit.sha
						.. "/Mini-API-Dump.json",
					true
				)

				writefile(VERSIONS, API_Dump) -- ? To avoid 60 requests / 1 h limit on GitHub Api
			end)

		if not ok then
			warn("Failed to get " .. version() .. " API Dump, trying latest..")
			warn(err)
			API_Dump = game:HttpGet(
				"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json",
				true
			)
		end

		local classList = {}

		for _, API_Class in service.HttpService:JSONDecode(API_Dump).Classes do
			local ClassProperties, ClassProperties_size = {}, 1
			local Class = {
				Properties = ClassProperties,
				Superclass = API_Class.Superclass,
			}

			local ClassTags = API_Class.Tags
			local ClassName = API_Class.Name

			if ClassTags then
				Class.Tags = ArrayToDictionary(ClassTags) -- or {}
			end

			-- ? Check 96ea8b2a755e55a78aedb55a7de7e83980e11077 commit - If a NotScriptableFix is needed that relies on another NotScriptable Property (which doesn't really make sense in the first place)

			local ClassExceptions = ClassPropertyExceptions[ClassName]

			for _, Member in API_Class.Members do
				if Member.MemberType == "Property" then
					local Serialization = Member.Serialization

					if Serialization.CanLoad then -- If Roblox doesn't save it why should we; If Roblox doesn't load it we don't need to save it
						--[[  -- ! CanSave replaces "Tags.Deprecated" check because there are some old properties which are deprecated yet have CanSave. 
						 Example: Humanoid.Health is CanSave false due to Humanoid.Health_XML being CanSave true (obsolete properties basically) - in this case both of them will Load. (aka PropertyPatches)
						 CanSave being on same level as CanLoad also fixes potential issues with overlapping properties like Color, Color3 & Color3uint8 of BasePart, out of which only Color3uint8 should save
						 This also fixes everything in IgnoreClassProperties automatically without need to hardcode :)
						 A very simple fix for many problems that saveinstance scripts encounter!
						--]]
						local PropertyName = Member.Name
						if Serialization.CanSave or ClassExceptions and ClassExceptions[PropertyName] then
							local MemberTags = Member.Tags

							local ValueType = Member.ValueType

							local Special

							if MemberTags then
								MemberTags = ArrayToDictionary(MemberTags)

								Special = MemberTags.NotScriptable
							end
							-- if not Special then
							ClassProperties[ClassProperties_size] = {
								Name = PropertyName,
								Category = ValueType.Category,
								-- Default = Member.Default,
								-- Tags = MemberTags,
								ValueType = ValueType.Name,

								Special = Special,

								CanRead = nil,
							}
							ClassProperties_size += 1
							-- end
						end
					end
				end
			end

			classList[ClassName] = Class
		end

		-- classList.Instance.Properties.Parent = nil -- ? Not sure if this is a better option than filtering through properties to remove this

		return classList
	end

	local ok, result = pcall(FetchAPI)
	if ok then
		ClassList = result
	else
		warn("Failed to load the API Dump")
		warn(result)
		return
	end
end

local inherited_properties = {}
local default_instances = {}
local referents, ref_size = {}, 0 -- ? Roblox encodes all <Item> elements with a referent attribute. Each value is generated by starting with the prefix RBX, followed by a UUID version 4, with - characters removed, and all characters converted to uppercase.

local GLOBAL_ENV = getgenv and getgenv() or _G or shared

--[=[
    @class SynSaveInstance
    Represents the options for saving instances with custom settings using the synsaveinstance function.
]=]

--- @interface CustomOptions table
--- * Structure of the main CustomOptions table.
--- * Note: Aliases take priority over parent option name.
--- @within SynSaveInstance
--- @field __DEBUG_MODE boolean -- Recommended to enable if you wish to help us improve our products and find bugs / issues with it! ___Default:___ false
--- @field ReadMe boolean --___Default:___ true
--- @field SafeMode boolean -- Kicks you before Saving, which prevents you from being detected in any game. ___Default:___ false
--- @field Anonymous boolean -- * **RISKY:** Cleans the file of any info related to your account like: Name, UserId. This is useful for some games that might store that info in GUIs or other Instances. Might potentially mess up parts of strings that contain characters that match your Name or parts of numbers that match your UserId. ___Default:___ false
--- @field ShowStatus boolean -- ___Default:___ true
--- @field mode string -- Change this to invalid mode like "invalid" if you only want ExtraInstances. "optimized" mode is **NOT** supported with *@Object* option. ___Default:___ `"optimized"`
--- @field noscripts boolean -- ___Aliases:___ `Decompile`. ___Default:___ false
--- @field scriptcache boolean -- ___Default:___ true
--- @field decomptype string -- * "custom" - for built-in custom decompiler. ___Default:___ Your executor's decompiler, if available. Otherwise uses "custom" if not.
--- @field timeout number -- If the decompilation run time exceeds this value it gets cancelled. Set to -1 to disable timeout (unreliable). ***Aliases***: `DecompileTimeout`. ___Default:___ 10
--- @field DecompileJobless boolean -- Includes already decompiled code in the output. No new scripts are decompiled. ___Default:___ false
--- @field SaveBytecode boolean -- Includes bytecode in the output. Useful if you wish to be able to decompile it yourself later. ___Default:___ false
--- .DecompileIgnore {Instance | Instance.ClassName | [Instance.ClassName] = {Instance.Name}} -- * Ignores match & it's descendants by default. To Ignore only the instance itself set the value to `= false`. Examples: "Chat", - Matches any instance with "Chat" ClassName, Players = {"MyPlayerName"} - Matches "Players" Class AND "MyPlayerName" Name ONLY, `workspace` - matches Instance by reference, `[workspace] = false` - matches Instance by reference and only ignores the instance itself and not it's descendants. ___Default:___ {Chat, TextChatService, ModuleScript = { "PlayerModule" }}
--- .IgnoreList {Instance | Instance.ClassName | [Instance.ClassName] = {Instance.Name}} -- Structure is similar to **@DecompileIgnore** except `= false` meaning if you ignore one instance it will automatically ignore it's descendants. ___Default:___ {CoreGui, CorePackages}
--- .ExtraInstances {Instance} -- If used with any invalid mode (like "invalidmode") it will only save these instances. ___Default:___ {}
--- @field IgnoreProperties table -- Ignores properties by Name. ___Default:___ {}
--- @field SaveCacheInterval number -- The less the value the more often it saves, but that would mean less performance due to constantly saving. ___Default:___ 0x1600 * 10
--- @field FilePath string -- Must only contain the name of the file, no file extension. ___Default:___ false
--- @field Object Instance -- * If provided, saves as .rbxmx (Model file) instead. If Object is game, it will be saved as a .rbxl file. **MUST BE AN INSTANCE REFERENCE, FOR EXAMPLE - *game.Workspace***. `"optimized"` mode is **NOT** supported with this option. If IsModel is set to false then Object specified here will be saved as a place file. ___Default:___ false
--- @field IsModel boolean -- If Object is specified then sets to true automatically, unless you set it to false. ___Default:___ false
--- @field NilInstances boolean -- Save instances that aren't Parented (Parented to nil). ___Default:___ false
--- .NilInstancesFixes {[Instance.ClassName] = function} -- * This can cause some Classes to be fixed even though they might not need the fix (better be safe than sorry though). For example, Bones inherit from Attachment if we dont define them in the NilInstancesFixes then this will catch them anyways. **TO AVOID THIS BEHAVIOR USE THIS EXAMPLE:** {ClassName_That_Doesnt_Need_Fix = false}. ___Default:___ {Animator = function, AdPortal = function, BaseWrap = function, Attachment = function}
--- .NotScriptableFixes {[Instance.ClassName] = {<string>PropertyToFix = <string>PropertyFix, _Inheritors = {[Instance.ClassName] = {<string>PropertyToFix_Name = <string>PropertyFix_Name}}}} -- * Structure is similar to **@NilInstancesFixes**. This is useful for execs that lack gethiddenproperty. ___Default:___ *too much to list*
--- @field IgnoreDefaultProperties boolean -- Ignores default properties during saving.  ___Default:___ true
--- @field IgnoreNotArchivable boolean -- Ignores the Archivable property and saves Non-Archivable instances. ___Default:___ true
--- @field IgnorePropertiesOfNotScriptsOnScriptsMode boolean -- Ignores property of every instance that is not a script in "scripts" mode. ___Default:___ false
--- @field IgnoreSpecialProperties boolean -- Ignores hidden/secret properties that are only accessible through `gethiddenproperty`. If your file is corrupted after saving, you can try turning this on. ___Default:___ false
--- @field IsolateLocalPlayer boolean -- Saves Children of LocalPlayer as separate folder and prevents any instance of ClassName Player with .Name identical to LocalPlayer.Name from saving. ___Default:___ false
--- @field IsolateStarterPlayer boolean -- If enabled, StarterPlayer will be cleared and the saved starter player will be placed into folders. ___Default:___ false
--- @field IsolateLocalPlayerCharacter boolean -- Saves Children of LocalPlayer.Character as separate folder and prevents any instance of ClassName Player with .Name identical to LocalPlayer.Name from saving. ___Default:___ false
--- @field RemovePlayerCharacters boolean -- Ignore player characters while saving. (Enables SaveNonCreatable automatically). ___Default:___ true
--- @field SaveNonCreatable boolean -- * Includes non-serializable instances as Folder objects (Name is misleading as this is mostly a fix for certain NilInstances and isn't always related to NotCreatable). ___Default:___ false
--- .NotCreatableFixes table<Instance.ClassName> -- * {"Player"} is the same as {Player = "Folder"}; Format like {SpawnLocation = "Part"} is only to be used when SpawnLocation inherits from "Part" AND "Part" is Creatable. ___Default:___ { "Player", "PlayerScripts", "PlayerGui" }
--- @field IsolatePlayers boolean -- * This option does save players, it's just they won't show up in Studio and can only be viewed through the place file code (in text editor). More info at https://github.com/luau/UniversalSynSaveInstance/issues/2. ___Default:___ false
--- @field IgnoreSharedStrings boolean -- * **RISKY: FIXES CRASHES (TEMPORARY, TESTED ON ROEXEC ONLY). FEEL FREE TO DISABLE THIS TO SEE IF IT WORKS FOR YOU**. ___Default:___ true
--- @field SharedStringOverwrite boolean -- * **RISKY:** if the process is not finished aka crashed then none of the affected values will be available. SharedStrings can also be used for ValueTypes that aren't `SharedString`, this behavior is not documented anywhere but makes sense (Could create issues though, due to _potential_ ValueType mix-up, only works on certain types which are all base64 encoded so far). Reason: Allows for potential smaller file size (can also be bigger in some cases). ___Default:___ false
--- @field TreatUnionsAsParts boolean -- * **RISKY:** Converts all UnionOperations to Parts. Useful if your Executor isn't able to save (read) Unions, because otherwise they will be invisible. ___Default:___ false (except Solara)

--- @interface OptionsAliases
--- @within SynSaveInstance
--- Aliases for the [SynSaveInstance.CustomOptions table].
--- @field FilePath string -- FileName
--- @field IgnoreDefaultProperties string -- IgnoreDefaultProps
--- @field SaveNonCreatable string -- SaveNotCreatable
--- @field IsolatePlayers string -- SavePlayers
--- @field scriptcache string -- DecompileJobless
--- @field timeout string -- DecompileTimeout
--- @field IgnoreNotArchivable string -- IgnoreArchivable
--- @field RemovePlayerCharacters string -- INVERSE SavePlayerCharacters

--[=[
	@function saveinstance
	Saves instances with specified options. Example:
	```lua
	local Params = {
		RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
		SSI = "saveinstance",
	}

	local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

	local CustomOptions = { SafeMode = true, timeout = 15, SaveBytecode = true }
	
	synsaveinstance(CustomOptions)
	```
	@within SynSaveInstance
	@yields
	@param Parameter_1 variant<table, table<Instance>> -- Can either be [SynSaveInstance.CustomOptions table] or a filled with instances ({Instance}), (then it will be treated as ExtraInstances with an invalid mode and IsModel will be true).
	@param Parameter_2 table -- [OPTIONAL] If present, then Parameter_2 will be assumed to be [SynSaveInstance.CustomOptions table]. And then if the Parameter_1 is an Instance, then it will be assumed to be [SynSaveInstance.CustomOptions table].Object. If Parameter_1 is a table filled with instances ({Instance}), then it will be assumed to be [SynSaveInstance.CustomOptions table].ExtraInstances and IsModel will be true). This exists for sake compatibility with `saveinstance(game, {})`
]=]

local function synsaveinstance(CustomOptions, CustomOptions2)
	-- if GLOBAL_ENV.__USSI then
	-- 	warn("UniversalSynSaveInstance is already running")
	-- 	return
	-- end
	-- GLOBAL_ENV.__USSI = true

	do
		local setthreadidentity = global_container.setthreadidentity
		if setthreadidentity then
			pcall(setthreadidentity, 8) -- ? Arceus X Fix
		end
	end

	local totalstr, totalsize = "", 0
	local savebuffer, savebuffer_size = { '<roblox version="4">' }, 2

	local StatusText

	local OPTIONS = {
		mode = "optimized",
		noscripts = false,
		scriptcache = true,
		decomptype = "",
		timeout = 10,
		--* New:
		__DEBUG_MODE = false,

		-- Binary = false, -- true in syn newer versions (false in our case because no binary support yet), Description: Saves everything in Binary Mode (rbxl/rbxm).
		--Callback = nil, -- Description: If set, the serialized data will be sent to the callback instead of to file.
		--Clipboard/CopyToClipboard = false, -- Description: If set to true, the serialized data will be set to the clipboard, which can be later pasted into studio easily. Useful for saving models.
		-- MaxThreads = 3 -- Description: The number of decompilation threads that can run at once. More threads means it can decompile for scripts at a time.
		-- DisableCompression = false, --Description: Disables compression in the binary output

		DecompileJobless = false,
		DecompileIgnore = { -- * Clean these up (merged Old Syn and New Syn)
			service.Chat,
			service.TextChatService,
			ModuleScript = nil,
		},
		SaveBytecode = false,

		IgnoreProperties = { "ScriptGuid", "UniqueId", "HistoryId" },

		IgnoreList = { service.CoreGui, service.CorePackages },

		ExtraInstances = {},
		NilInstances = false,
		NilInstancesFixes = {},

		SaveCacheInterval = 0x1600 * 10,
		ShowStatus = true,
		SafeMode = false,
		Anonymous = false,
		ReadMe = true,
		FilePath = false,
		Object = false,
		IsModel = false,

		IgnoreDefaultProperties = true,
		IgnoreNotArchivable = true,
		IgnorePropertiesOfNotScriptsOnScriptsMode = false,
		IgnoreSpecialProperties = false,

		IsolateLocalPlayer = false,
		IsolateLocalPlayerCharacter = false,
		IsolatePlayers = false,
		IsolateStarterPlayer = false,
		RemovePlayerCharacters = true,

		SaveNonCreatable = false,
		NotCreatableFixes = { "Player", "PlayerScripts", "PlayerGui", "TouchTransmitter" },

		-- ! Risky

		IgnoreSharedStrings = true,
		SharedStringOverwrite = false,
		TreatUnionsAsParts = EXECUTOR_NAME == "Solara", -- TODO Temporary true for Solara (once removed, remove Note from docs too)

		OptionsAliases = { -- You can't really modify these as a user
			FilePath = "FileName",
			IgnoreDefaultProperties = "IgnoreDefaultProps",
			SaveNonCreatable = "SaveNotCreatable",
			IsolatePlayers = "SavePlayers",
			scriptcache = "DecompileJobless",
			timeout = "DecompileTimeout",
			IgnoreNotArchivable = "IgnoreArchivable",
		},

		NotScriptableFixes = {
			Instance = {
				AttributesSerialize = function(instance)
					-- * There are certain restrictions for names of attributes
					-- https://create.roblox.com/docs/reference/engine/classes/Instance#SetAttribute
					-- But it seems like even if those are present, Studio still opens the file just fine
					-- So there is no need to check for them currently

					-- TODO: merge sequence Descriptors and some other descriptors where possible (check xml descriptors)
					-- ? Return early for empty tags (this proved equally as fast when done using counter/next)

					local attrs = instance:GetAttributes()

					local attrs_n = 0
					local buffer_size = 4
					local attrs_sorted = {}
					local attrs_formatted = table.clone(attrs)
					-- warn(instance)
					for attr, val in attrs do
						attrs_n += 1
						attrs_sorted[attrs_n] = attr

						local Type = typeof(val)

						local Descriptor = Binary_Descriptors[Type]
						local attr_size

						attrs_formatted[attr], attr_size = Descriptor(val)

						buffer_size += 5 + #attr + attr_size
					end
					-- print(instance, attrs_n) -- ? Looks like multiple buffer calls cause the this part to be skipped sometimes ?
					if attrs_n == 0 then
						return ""
					end
					table.sort(attrs_sorted)

					local b = buffer.create(buffer_size)

					local offset = 0

					buffer.writeu32(b, offset, attrs_n)
					offset += 4

					local Descriptors_string = Binary_Descriptors.string
					for _, attr in attrs_sorted do
						local b_Name, Name_size = Descriptors_string(attr)

						buffer.copy(b, offset, b_Name)
						offset += Name_size

						buffer.writeu8(b, offset, Type_IDs[typeof(attrs[attr])])
						offset += 1

						local bb = attrs_formatted[attr]

						buffer.copy(b, offset, bb)
						offset += buffer.len(bb)
					end

					return buffer.tostring(b)
				end,
				Tags = function(instance)
					-- https://github.com/RobloxAPI/spec/blob/master/properties/Tags.md

					local tags = instance:GetTags()

					if #tags == 0 then
						return ""
					end

					return table.concat(tags, "\0")
				end,
				_Inheritors = {
					-- DebuggerBreakpoint = {line="Line"}, -- ? This shouldn't appear in live games (try to prove this wrong)
					BallSocketConstraint = { MaxFrictionTorqueXml = "MaxFrictionTorque" },
					BasePart = {
						Color3uint8 = "Color",
						MaterialVariantSerialized = "MaterialVariant",
						size = "Size",
						_Inheritors = {
							Terrain = {
								AcquisitionMethod = "LastUsedModificationMethod", -- ? Not sure
								MaterialColors = function(instance) -- https://github.com/RobloxAPI/spec/blob/master/properties/MaterialColors.md
									local TERRAIN_MATERIAL_COLORS =
										{ --https://github.com/rojo-rbx/rbx-dom/blob/master/rbx_dom_lua/src/customProperties.lua#L5
											Enum.Material.Grass,
											Enum.Material.Slate,
											Enum.Material.Concrete,
											Enum.Material.Brick,
											Enum.Material.Sand,
											Enum.Material.WoodPlanks,
											Enum.Material.Rock,
											Enum.Material.Glacier,
											Enum.Material.Snow,
											Enum.Material.Sandstone,
											Enum.Material.Mud,
											Enum.Material.Basalt,
											Enum.Material.Ground,
											Enum.Material.CrackedLava,
											Enum.Material.Asphalt,
											Enum.Material.Cobblestone,
											Enum.Material.Ice,
											Enum.Material.LeafyGrass,
											Enum.Material.Salt,
											Enum.Material.Limestone,
											Enum.Material.Pavement,
										}

									local b = buffer.create(69) -- 69 bytes: 6 reserved + 63 for colors (21 materials * 3 components)
									local offset = 6 -- 6 reserved bytes

									local RGB_components = { "R", "G", "B" }

									for _, material in TERRAIN_MATERIAL_COLORS do
										local color = instance:GetMaterialColor(material)
										for _, component in RGB_components do
											buffer.writeu8(b, offset, math.floor(color[component] * 255)) -- ? math.floor seems unneeded but it makes it faster
											offset += 1
										end
									end

									return buffer.tostring(b)
								end,
							},
							TriangleMeshPart = {
								FluidFidelityInternal = "FluidFidelity",
								_Inheritors = {
									MeshPart = { InitialSize = "MeshSize" },
									PartOperation = { InitialSize = "MeshSize" },
								},
							},
							TrussPart = { style = "Style" },
							FormFactorPart = {
								formFactorRaw = "FormFactor",
								_Inheritors = { Part = { shape = "Shape" } },
							},
						},
					},
					-- CustomEvent = {PersistedCurrentValue=function(instance) -- * Class is Deprecated and :SetValue doesn't seem to affect GetCurrentValue anymore
					-- 	local Receiver  = instance:GetAttachedReceivers()[1]
					-- 	if Receiver then
					-- 		return Receiver:GetCurrentValue()
					-- 	else
					-- 		error("No Receiver")
					-- 	end
					-- end},

					DoubleConstrainedValue = { value = "Value" },
					IntConstrainedValue = { value = "Value" },
					Fire = { heat_xml = "Heat", size_xml = "Size" },

					Humanoid = { Health_XML = "Health" },
					LocalizationTable = {
						Contents = function(instance)
							return instance:GetContents() --service.HttpService:JSONEncode(instance:GetEntries())
						end,
					},
					MaterialService = { Use2022MaterialsXml = "Use2022Materials" },

					Model = {
						ScaleFactor = function(instance)
							return instance:GetScale()
						end,
						WorldPivotData = "WorldPivot",
						-- ModelMeshCFrame = "Pivot Offset",  -- * Both are NotScriptable
						_Inheritors = {
							Workspace = {
								-- SignalBehavior2 = "SignalBehavior", -- * Both are NotScriptable so it doesn't make sense to keep
								CollisionGroupData = function()
									local collision_groups = game:GetService("PhysicsService")
										:GetRegisteredCollisionGroups()

									local col_groups_n = #collision_groups

									if col_groups_n == 0 then
										return "\1\0"
									end

									local buffer_size = 3 -- Initial size

									for _, group in collision_groups do
										buffer_size += 7 + #group.name
									end

									buffer_size -= 1 -- Except Default group

									local b = buffer.create(buffer_size)

									local offset = 0

									buffer.writeu8(b, offset, 1) -- ? [CONSTANT] Version byte (likely)
									offset += 1
									buffer.writeu16(b, offset, col_groups_n * 10) -- Group count (not sure about u16)
									offset += 2

									for i, group in collision_groups do
										local name, id, mask = group.name, i - 1, group.mask
										local name_len = #name

										if id ~= 0 then
											buffer.writeu8(b, offset, id) -- ID
											offset += 1
										end

										buffer.writeu8(b, offset, 4) -- ? [CONSTANT] Not sure what this is (also not sure about u8, could be i8)
										offset += 1

										buffer.writei32(b, offset, mask) -- Mask value as signed 32-bit integer
										offset += 4

										buffer.writeu8(b, offset, name_len) -- Name length
										offset += 1
										buffer.writestring(b, offset, name) -- Name
										offset += name_len
									end

									return buffer.tostring(b)
								end,
							},
						},
					},
					PackageLink = { PackageIdSerialize = "PackageId", VersionIdSerialize = "VersionNumber" },
					Players = { MaxPlayersInternal = "MaxPlayers", PreferredPlayersInternal = "PreferredPlayers" }, -- ? Only needed for execs that lack LocalUserSecurity (Level 2, 5, 9), even so, it's a pretty useless information as it can be viewed elsewhere

					StarterPlayer = { AvatarJointUpgrade_Serialized = "AvatarJointUpgrade" },
					Smoke = { size_xml = "Size", opacity_xml = "Opacity", riseVelocity_xml = "RiseVelocity" },
					Sound = {
						xmlRead_MaxDistance_3 = "RollOffMaxDistance", -- * Also MaxDistance
					},
					-- ViewportFrame = { -- * Pointless because these reflect CurrentCamera's properties
					-- 	CameraCFrame = function(instance) -- *
					-- 		local CurrentCamera = instance.CurrentCamera
					-- 		if CurrentCamera then
					-- 			return CurrentCamera.CFrame
					-- 		else
					-- 			error("No CurrentCamera")
					-- 		end
					-- 	end,
					-- 	-- CameraFieldOfView =
					-- },
					WeldConstraint = {
						Part0Internal = "Part0",
						Part1Internal = "Part1",
						-- State = function(instance)
						-- 	-- If untouched then default state is 3 (default true)
						-- 	return instance.Enabled and 1 or 0
						-- end,
					},
				}, -- For more info: https://github.com/luau/UniversalSynSaveInstance/blob/master/Tests/Potentially%20Missing%20Properties%20Tracker.luau
			},
		},
	}

	local function GetAlias(searchAlias)
		for option, alias in OPTIONS.OptionsAliases do
			if searchAlias == alias then
				return option
			end
		end

		return ""
	end

	do -- * Load Settings
		local function construct_NilinstanceFix(Name, ClassName, Separate)
			return function(instance, instancePropertyOverrides)
				local Exists = if Separate then nil else OPTIONS.NilInstancesFixes[Name]

				local Fix

				local DoesntExist = not Exists
				if DoesntExist then
					Fix = Instance.new(ClassName)
					if not Separate then
						OPTIONS.NilInstancesFixes[Name] = Fix
					end
					-- Fix.Name = Name

					instancePropertyOverrides[Fix] = { __Children = { instance }, Properties = { Name = Name } }
				else
					Fix = Exists
				end

				table.insert(instancePropertyOverrides[Fix].__Children, instance)
				-- InstancePropertyOverrides[instance].Parent = AnimationController
				if DoesntExist then
					return Fix
				end
			end
		end

		-- TODO: Merge BaseWrap & Attachment & AdPortal fix (put all under MeshPart container)
		-- TODO?:
		-- DebuggerWatch DebuggerWatch must be a child of ScriptDebugger
		-- PluginAction Parent of PluginAction must be Plugin or PluginMenu that created it!
		OPTIONS.NilInstancesFixes.Animator = construct_NilinstanceFix(
			"Animator has to be placed under Humanoid or AnimationController",
			"AnimationController"
		)
		OPTIONS.NilInstancesFixes.AdPortal = construct_NilinstanceFix("AdPortal must be parented to a Part", "Part")
		OPTIONS.NilInstancesFixes.Attachment =
			construct_NilinstanceFix("Attachments must be parented to a BasePart or another Attachment", "Part") -- * Bones inherit from Attachments
		OPTIONS.NilInstancesFixes.BaseWrap =
			construct_NilinstanceFix("BaseWrap must be parented to a MeshPart", "MeshPart")
		OPTIONS.NilInstancesFixes.PackageLink =
			construct_NilinstanceFix("Package already has a PackageLink", "Folder", true)

		if CustomOptions2 and type(CustomOptions2) == "table" then
			local tmp = CustomOptions
			local Type = typeof(tmp)
			CustomOptions = CustomOptions2
			if Type == "Instance" then
				CustomOptions.Object = tmp
			elseif Type == "table" and typeof(tmp[1]) == "Instance" then
				CustomOptions.ExtraInstances = tmp
				OPTIONS.IsModel = true
			end
		end

		local Type = typeof(CustomOptions)

		if Type == "table" then
			if typeof(CustomOptions[1]) == "Instance" then
				OPTIONS.mode = "invalidmode"
				OPTIONS.ExtraInstances = CustomOptions
				OPTIONS.IsModel = true
				CustomOptions = {}
			else
				for key, value in CustomOptions do
					if OPTIONS[key] == nil then
						local Option = GetAlias(key)

						if Option then
							OPTIONS[Option] = value
						end
					else
						OPTIONS[key] = value
					end
				end
				local Decompile = CustomOptions.Decompile
				if Decompile ~= nil then
					OPTIONS.noscripts = not Decompile
				end
				local SavePlayerCharacters = CustomOptions.SavePlayerCharacters
				if SavePlayerCharacters ~= nil then
					OPTIONS.RemovePlayerCharacters = not SavePlayerCharacters
				end
				local RemovePlayers = CustomOptions.RemovePlayers
				if RemovePlayers ~= nil then
					OPTIONS.IsolatePlayers = not RemovePlayers
				end
			end
		elseif Type == "Instance" then
			OPTIONS.mode = "invalidmode"
			OPTIONS.Object = CustomOptions
			CustomOptions = {}
		else
			CustomOptions = {}
		end
	end

	do
		-- ? Fixes crashes on Mobile Devices
		-- TODO This is a bad workaround, find a better automatic way
		local DecompileIgnore = OPTIONS.DecompileIgnore

		local Path = service.StarterPlayer:FindFirstChild("StarterPlayerScripts")
		local Exclude = { ModuleScript = { "PlayerModule" }, LocalScript = { "RbxCharacterSounds" } }
		if Path then
			for _, className in Exclude do
				for _, name in className do
					table.insert(DecompileIgnore, Path:FindFirstChild(name))
				end
			end
		else
			for _, className in Exclude do
				local dest = DecompileIgnore[className]
				if dest == nil then
					DecompileIgnore[className] = Exclude
				elseif type(dest) == "table" then
					for _, name in Exclude[className] do
						table.insert(dest, name)
					end
				end
			end
		end
	end
	local InstancePropertyOverrides = {}

	local DecompileIgnore, IgnoreList, IgnoreProperties, NotCreatableFixes =
		ArrayToDictionary(OPTIONS.DecompileIgnore, true),
		ArrayToDictionary(OPTIONS.IgnoreList, true),
		ArrayToDictionary(OPTIONS.IgnoreProperties),
		ArrayToDictionary(OPTIONS.NotCreatableFixes, true, "Folder")

	local __DEBUG_MODE = OPTIONS.__DEBUG_MODE

	local FilePath = OPTIONS.FilePath
	local SaveCacheInterval = OPTIONS.SaveCacheInterval
	local ToSaveInstance = OPTIONS.Object
	local IsModel = OPTIONS.IsModel
	if ToSaveInstance and CustomOptions.IsModel == nil then
		IsModel = true
	end
	local IgnoreDefaultProperties = OPTIONS.IgnoreDefaultProperties
	local IgnoreNotArchivable = not OPTIONS.IgnoreNotArchivable
	local IgnorePropertiesOfNotScriptsOnScriptsMode = OPTIONS.IgnorePropertiesOfNotScriptsOnScriptsMode
	local IgnoreSpecialProperties = OPTIONS.IgnoreSpecialProperties
	local notIgnoreSpecialProperties = not IgnoreSpecialProperties

	local IsolateLocalPlayer = OPTIONS.IsolateLocalPlayer
	local IsolateLocalPlayerCharacter = OPTIONS.IsolateLocalPlayerCharacter
	local IsolateStarterPlayer = OPTIONS.IsolateStarterPlayer
	local IsolatePlayers = OPTIONS.IsolatePlayers

	local SaveNonCreatable = OPTIONS.SaveNonCreatable
	local TreatUnionsAsParts = OPTIONS.TreatUnionsAsParts

	local DecompileJobless = OPTIONS.DecompileJobless
	local ScriptCache = OPTIONS.scriptcache and getscriptbytecode

	local Timeout = OPTIONS.timeout

	local IgnoreSharedStrings = OPTIONS.IgnoreSharedStrings
	local SharedStringOverwrite = OPTIONS.SharedStringOverwrite
	local NotScriptableFixes = OPTIONS.NotScriptableFixes
	local NilInstances = OPTIONS.NilInstances

	if NilInstances and enablenilinstances then -- ? Solara fix
		enablenilinstances()
	end

	if
		#service.StarterGui:GetChildren() == 0
		and CustomOptions.IsolateLocalPlayer == nil
		and CustomOptions[GetAlias("IsolateLocalPlayer")] == nil
	then
		OPTIONS.IsolateLocalPlayer = true -- * QoL
	end

	local SaveBytecode
	if OPTIONS.SaveBytecode and getscriptbytecode then
		SaveBytecode = function(script)
			local s, bytecode = pcall(getscriptbytecode, script)

			if s then
				if bytecode and bytecode ~= "" then
					return "-- Bytecode (Base64):\n-- " .. base64encode(bytecode) .. "\n\n"
				end
			end
		end
	end

	local ldeccache = GLOBAL_ENV.scriptcache

	local DecompileIgnoring, ToSaveList, ldecompile, placename, elapse_t, SaveNonCreatableWillBeEnabled, RecoveredScripts

	if ScriptCache and not ldeccache then
		ldeccache = {}
		GLOBAL_ENV.scriptcache = ldeccache
	end

	if ToSaveInstance == game then
		OPTIONS.mode = "full"
		ToSaveInstance = nil
		IsModel = nil
	end

	local function isLuaSourceContainer(instance)
		return instance:IsA("LuaSourceContainer")
	end

	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = table.clone(OPTIONS.ExtraInstances)

		local PlaceName = game.PlaceId

		pcall(function()
			PlaceName ..= " " .. service.MarketplaceService:GetProductInfo(PlaceName).Name
		end)

		local function sanitizeFileName(str)
			return string.sub(string.gsub(string.gsub(string.gsub(str, "[^%w _]", ""), " +", " "), " +$", ""), 1, 240)
		end

		if IsModel then
			if mode == "optimized" then -- ! NOT supported with Model file mode
				mode = "full"
			end

			for _, key in
				{
					"IsolateLocalPlayer",
					"IsolateLocalPlayerCharacter",
					"IsolatePlayers",
					"IsolateStarterPlayer",
					"NilInstances",
				}
			do
				if CustomOptions[key] == nil and CustomOptions[GetAlias(key)] == nil then
					OPTIONS[key] = false
				end
			end

			placename = (
				FilePath or sanitizeFileName("model " .. PlaceName .. " " .. (ToSaveInstance or tmp[1]):GetFullName())
			) .. ".rbxmx"
		else
			placename = (FilePath or sanitizeFileName("place " .. PlaceName)) .. ".rbxlx"
		end

		if mode ~= "scripts" then
			IgnorePropertiesOfNotScriptsOnScriptsMode = nil
		end

		local TempRoot = ToSaveInstance or game

		if mode == "full" then
			local Children = TempRoot:GetChildren()
			if 0 < #Children then
				table.move(Children, 1, #Children, #tmp + 1, tmp)
			end
		elseif mode == "optimized" then -- ! Incompatible with .rbxmx (Model file) mode
			-- if IsolatePlayers then
			-- 	table.insert(_list_0, "Players")
			-- end
			for _, serviceName in
				{
					"Workspace",
					"Players",
					"Lighting",
					"MaterialService",
					"ReplicatedFirst",
					"ReplicatedStorage",

					"ServerScriptService", -- ? Why
					"ServerStorage", -- ? Why

					"StarterGui",
					"StarterPack",
					"StarterPlayer",
					"Teams",
					"SoundService",
					"TextChatService",
					"Chat",

					-- "InsertService",
					"JointsService",

					"LocalizationService", -- For LocalizationTables
					-- "TestService",
					-- "VoiceChatService",
				}
			do
				table.insert(tmp, service[serviceName])
			end
		elseif mode == "scripts" then
			-- TODO: Only save paths that lead to scripts (nothing else)
			-- Currently saves paths along with children of each tree
			local unique = {}
			for _, instance in TempRoot:GetDescendants() do
				if isLuaSourceContainer(instance) then
					local Parent = instance.Parent
					while Parent and Parent ~= TempRoot do
						instance = instance.Parent
						Parent = instance.Parent
					end
					if Parent then
						unique[instance] = true
					end
				end
			end
			for instance in unique do
				table.insert(tmp, instance)
			end
		end
		ToSaveList = tmp
	end

	local function get_size_format()
		local Size

		-- local totalsize = #totalstr

		for i, unit in
			{
				"B",
				"KB",
				"MB",
				"GB",
				"TB",
			}
		do
			if totalsize < 0x400 ^ i then
				Size = math.floor(totalsize / (0x400 ^ (i - 1)) * 10) / 10 .. " " .. unit
				break
			end
		end

		return Size
	end

	local function wait_for_render()
		service.RunService.RenderStepped:Wait()
	end

	local Loading
	local function run_with_loading(text, keepStatus, waitForRender, taskFunction, ...)
		local previousStatus

		if StatusText then
			if keepStatus then
				previousStatus = StatusText.Text
			end
			Loading = task.spawn(function()
				local spinner_count = 0
				local chars = { "|", "/", "—", "\\" }
				local chars_size = #chars

				local function getLoadingText()
					spinner_count += 1

					if chars_size < spinner_count then
						spinner_count = 1
					end

					return chars[spinner_count]
				end

				text ..= " "

				while true do
					StatusText.Text = text .. getLoadingText()
					task.wait(0.25)
				end
			end)
			if waitForRender then
				wait_for_render()
			end
		end

		local result = { taskFunction(...) }

		if Loading then
			task.cancel(Loading)
			Loading = nil
			if previousStatus then
				StatusText.Text = previousStatus
			end
		end

		return unpack(result)
	end

	local function construct_TimeoutHandler(timeout, f, timeout_ret)
		return function(script) -- TODO Ideally use ... (vararg) instead of `script` in case this is reused for something other than `decompile` & `getscriptbytecode`
			if timeout < 0 then
				return pcall(f, script)
			end

			local thread = coroutine.running()
			local timeoutThread, isCancelled

			timeoutThread = task.delay(timeout, function()
				isCancelled = true -- TODO task.cancel
				coroutine.resume(thread, nil, timeout_ret)
			end)

			task.spawn(function()
				local ok, result = pcall(f, script)

				if isCancelled then
					return
				end

				task.cancel(timeoutThread)

				while coroutine.status(thread) ~= "suspended" do
					task.wait()
				end

				coroutine.resume(thread, ok, result)
			end)

			return coroutine.yield()
		end
	end

	do
		if load_decompiler then
			load_decompiler(Timeout)
		end
		local Decompiler = OPTIONS.decomptype == "custom" and custom_decompiler
			or global_container.decompile
			or custom_decompiler

		-- if Decompiler == custom_decompiler then -- Cope
		-- 	local key = "DecompileTimeout"
		-- 	if CustomOptions[key] == nil then
		-- 		local Option = GetAlias(key)
		-- 		if CustomOptions[Option] == nil then
		-- 			Timeout = 1
		-- 		end
		-- 	end

		-- end

		if OPTIONS.noscripts then
			ldecompile = function()
				return "-- Decompiling is disabled"
			end
		elseif Decompiler then
			local decomp = construct_TimeoutHandler(Timeout, Decompiler, "Decompiler timed out")
			local getbytecode = construct_TimeoutHandler(3, getscriptbytecode) -- ? Solara fix

			ldecompile = function(script)
				-- local name = scr.ClassName .. scr.Name
				local hashed_bytecode
				if ScriptCache then
					local s, bytecode = getbytecode(script) -- 	TODO This is awful because we already do this in Custom Decomp (when we are using it, that is)
					local cached

					if s then
						if not bytecode or bytecode == "" then
							return "-- The Script is Empty"
						end
						hashed_bytecode = sha384(bytecode)
						cached = ldeccache[hashed_bytecode]
					end

					if cached then
						if __DEBUG_MODE then
							warn("Found in Cache", script:GetFullName())
						end
						return cached
					elseif DecompileJobless then
						return "-- Not found in already decompiled ScriptCache"
					end
				else
					task.wait() -- TODO Maybe remove?
				end
				local ok, result = run_with_loading("Decompiling " .. script.Name, true, nil, decomp, script)
				if not result then
					ok, result = false, "Empty Output"
				end

				local output
				if ok then
					result = string.gsub(result, "\0", "\\0") -- ? Some decompilers sadly output \0 which prevents files from opening
					output = result
				else
					output = "--[[ Failed to decompile\nReason:\n" .. (result or "") .. "\n]]"
				end

				if ScriptCache and hashed_bytecode then -- TODO there might(?) be an edgecase where it manages to decompile (built-in) even though getscriptbytecode failed, and the output won't get cached
					ldeccache[hashed_bytecode] = output -- ? Should we cache even if it timed out?
					if __DEBUG_MODE then
						warn("Cached", script:GetFullName())
					end
				end

				return output
			end
		else
			ldecompile = function()
				return "-- Decompiling is NOT supported on your executor"
			end
		end
	end

	local function getsafeproperty(instance, propertyName)
		return instance[propertyName]
	end

	local function ReadProperty(instance, property, propertyName, special)
		local raw = "__BREAK"

		local InstanceOverride = InstancePropertyOverrides[instance]
		if InstanceOverride then
			local PropertyOverride = InstanceOverride.Properties[propertyName]
			if PropertyOverride then
				return PropertyOverride
			end
		end

		local CanRead = property.CanRead

		if CanRead == false then -- * Skips because we've checked this property before
			return "__BREAK"
		end

		local function filterResult(result) -- ? raw == nil thanks to SerializedDefaultAttributes; "can't get value" - "shap" Roexec;  "Invalid value for enum " - "StreamingPauseMode" (old games probably) Roexec
			return result == nil
				or result == "can't get value"
				or type(result) == "string"
					and (string_find(result, "Unable to get property " .. propertyName) or property.Category == "Enum" and string_find(
						result,
						"Invalid value for enum "
					))
		end

		if special then
			if gethiddenproperty then
				local ok, result = pcall(gethiddenproperty, instance, propertyName)

				if ok then
					raw = result
				end

				if filterResult(raw) then
					-- * Skip next time we encounter this too perhaps (unless there's a chance for it to be readable on other instance, somehow)
					if __DEBUG_MODE then
						warn("Filtered", propertyName)
					end
					-- Property.Special = false
					property.CanRead = false

					return "__BREAK" -- ? We skip it because even if we use "" it will just reset to default in most cases, unless it's a string tag for example (same as not being defined)
				end
			end
		else
			if CanRead then
				raw = instance[propertyName]
			else -- Assuming CanRead == nil
				local ok, result = pcall(getsafeproperty, instance, propertyName)

				if ok then
					raw = result
				elseif notIgnoreSpecialProperties and gethiddenproperty then -- ! Be careful with this 'and gethiddenproperty' logic
					ok, result = pcall(gethiddenproperty, instance, propertyName)

					if ok then
						raw = result

						property.Special = true
					end
				end

				property.CanRead = ok
				if not ok or filterResult(raw) then
					return "__BREAK"
				end
			end
		end

		return raw
	end

	local function ReturnItem(className, instance)
		local ref = referents[instance]
		if not ref then
			ref = ref_size
			referents[instance] = ref
			ref_size += 1
		end

		return '<Item class="' .. className .. '" referent="' .. ref .. '"><Properties>' -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is Enabled OR If all properties are default (reduces file size by at least 1.4%)
	end

	local function ReturnProperty(tag, propertyName, value)
		return "<" .. tag .. ' name="' .. propertyName .. '">' .. value .. "</" .. tag .. ">"
	end

	local function ReturnValueAndTag(raw, valueType, descriptor)
		local value, tag = (descriptor or XML_Descriptors[valueType])(raw)

		return value, tag == nil and valueType or tag
	end

	local function InheritsFix(fixes, className, instance)
		local Fix = fixes[className]
		if Fix then
			return Fix
		elseif Fix == nil then
			for class_name, fix in fixes do
				if instance:IsA(class_name) then
					return fix
				end
			end
		end
	end

	local function GetInheritedProps(className)
		local prop_list = {}
		local layer = ClassList[className]
		while layer do
			local layer_props = layer.Properties
			table.move(layer_props, 1, #layer_props, #prop_list + 1, prop_list)

			-- for _, prop in layer.Properties do
			-- 	prop_list[prop_count] = prop -- ? table.clone is needed for case where .Default is modified
			-- 	prop_count += 1
			-- end

			layer = ClassList[layer.Superclass]
		end
		inherited_properties[className] = prop_list
		return prop_list
	end

	local function save_cache()
		local savestr = table.concat(savebuffer)
		totalstr ..= savestr -- TODO: Causes "not enough memory" error on some exec

		-- writefile(placename, totalstr)
		-- appendfile(placename, savestr) -- * supposedly causes uneven amount of Tags (e.g. <Item> must be closed with </Item> but sometimes there's more of one than the other). While being under load, the function produces unexpected output?
		totalsize += #savestr

		table.clear(savebuffer)
		savebuffer_size = 1

		if StatusText then
			StatusText.Text = "Saving.. Size: " .. get_size_format()
		end
		-- ? Needed for at least 1fps (status text)
		-- task.wait()
		wait_for_render()
	end

	local function save_specific(className, properties)
		local Ref = Instance.new(className) -- ! Assuming anything passed here is Creatable
		local Item = ReturnItem(Ref.ClassName, Ref)

		for propertyName, val in properties do
			local Class, value, tag

			-- TODO: Improve all sort of overrides & exceptions in the code (code below is awful)
			if "Source" == propertyName then
				tag = "ProtectedString"
				value = XML_Descriptors.__PROTECTEDSTRING(val)
				Class = "Script"
			elseif "Name" == propertyName then
				Class = "Instance"
				value, tag = ReturnValueAndTag(val, "string") -- * Doubt ValueType will change
			end

			if Class then
				Item ..= ReturnProperty(tag, propertyName, value)
			end
		end
		Item ..= "</Properties>"
		return Item
	end

	local function save_hierarchy(hierarchy, queuedHierarchy)
		for _, instance in hierarchy do
			if IgnoreNotArchivable and not instance.Archivable then
				continue
			end

			local SkipEntirely = IgnoreList[instance]
			if SkipEntirely then
				continue
			end

			local ClassName = instance.ClassName

			local InstanceName = instance.Name

			do
				local OnIgnoredList = IgnoreList[ClassName]
				if OnIgnoredList and (OnIgnoredList == true or OnIgnoredList[InstanceName]) then
					continue
				end
			end

			if not DecompileIgnoring then
				DecompileIgnoring = DecompileIgnore[instance]

				if DecompileIgnoring == nil then
					local DecompileIgnored = DecompileIgnore[ClassName]
					if DecompileIgnored then
						DecompileIgnoring = DecompileIgnored == true or DecompileIgnored[InstanceName]
					end
				end

				if DecompileIgnoring then
					DecompileIgnoring = instance
				elseif DecompileIgnoring == false then
					DecompileIgnoring = 1 -- Ignore one instance
				end
			end

			local InstanceOverride, ClassNameOverride, ClassTagOverride

			do
				local function replaceClassName(newClassName)
					if InstanceName ~= ClassName then -- TODO Compare against default instance instead (TouchTransmitter is called TouchInterest by default)
						InstanceOverride = InstancePropertyOverrides[instance]
						if not InstanceOverride then
							InstanceOverride = { Properties = { Name = "[" .. ClassName .. "] " .. InstanceName } }
							InstancePropertyOverrides[instance] = InstanceOverride
						end
					end
					ClassName = newClassName
				end

				local Fix = NotCreatableFixes[ClassName]

				if Fix then
					if SaveNonCreatable then
						replaceClassName(Fix)
					else
						continue -- They won't show up in Studio anyway (Enable IsolatePlayers if you wish to bypass this)
					end
				else -- ! Assuming nothing that is a PartOperation or inherits from it is in NotCreatableFixes
					if TreatUnionsAsParts and instance:IsA("PartOperation") then
						replaceClassName("Part")
						ClassNameOverride = "BasePart" -- * Mutual Superclass for PartOperation and Part; For properties only
					elseif not ClassList[ClassName] then -- ? API Dump is outdated then
						if __DEBUG_MODE then
							warn("Class not Found", ClassName)
						end

						ClassTagOverride = ClassName -- ? To at least retain .ClassName unlike the rest of the class-specific properties
						ClassName = "Folder" -- ? replaceClassName is not needed because of the ClassTagOverride
					end
				end
			end

			if not InstanceOverride then
				InstanceOverride = InstancePropertyOverrides[instance]
			end
			local ChildrenOverride = InstanceOverride and InstanceOverride.__Children

			if ClassName == "" then -- * FilteredSelection
				ClassName = "Folder"
			end

			-- ? The reason we only save .Name (and few other props in save_specific) is because
			-- ? we can be sure this is a custom container (ex. NilInstancesFixes)
			-- ? However, in case of NotCreatableFixes, the Instance might have Tags, Attributes etc. that can potentially be saved (even though it's a Folder)
			if ChildrenOverride then
				savebuffer[savebuffer_size] = save_specific(ClassName, InstanceOverride.Properties) -- ! Assuming anything that has __Children will have .Properties
				savebuffer_size += 1
			else
				-- local Properties =
				savebuffer[savebuffer_size] = ReturnItem(ClassTagOverride or ClassName, instance) -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is ENABLED
				savebuffer_size += 1
				if not (IgnorePropertiesOfNotScriptsOnScriptsMode and not isLuaSourceContainer(instance)) then
					local default_instance, new_def_inst

					if IgnoreDefaultProperties then
						default_instance = default_instances[ClassName]
						if not default_instance then
							local ClassTags = ClassList[ClassName].Tags
							if not (ClassTags and ClassTags.NotCreatable) then -- __api_dump_class_not_creatable__ also indicates this
								new_def_inst = Instance.new(ClassName) -- ! Assuming anything that doesn't have NotCreatable is possible to create (therefore no pcall)

								default_instance = {}

								default_instances[ClassName] = default_instance
							elseif __DEBUG_MODE then
								warn("Unable to create default Instance", ClassName)
							end
						end
					end
					local proplist = inherited_properties[ClassNameOverride or ClassName]
					if not proplist then
						proplist = GetInheritedProps(ClassNameOverride or ClassName)
						inherited_properties[ClassNameOverride or ClassName] = proplist
					end
					for _, Property in proplist do
						local PropertyName = Property.Name

						if IgnoreProperties[PropertyName] then
							continue
						end

						local Special = Property.Special
						if IgnoreSpecialProperties and Special then
							continue
						end

						local ValueType = Property.ValueType

						if IgnoreSharedStrings and ValueType == "SharedString" then -- ? More info in Options
							continue
						end

						local raw = ReadProperty(instance, Property, PropertyName, Special)
						if raw == "__BREAK" then -- ! Assuming __BREAK is always returned when there's a failure to read a property
							local PropertyFix
							do
								local Inheritors = NotScriptableFixes
								while Inheritors do
									local fix
									for superclass, fixes in Inheritors do
										if instance:IsA(superclass) then
											fix = fixes
											break
										end
									end
									if fix then
										PropertyFix = fix[PropertyName]
										if PropertyFix then
											break
										end
									else
										break
									end
									Inheritors = fix._Inheritors
								end
							end

							if PropertyFix then
								local ok, result = pcall(
									type(PropertyFix) == "string" and getsafeproperty or PropertyFix,
									instance,
									PropertyFix
								)

								if ok then
									raw = result
								else
									if __DEBUG_MODE then
										-- TODO Maybe remove the fix during runtime if it fails to avoid re-trying
										warn("Fix Failed", PropertyName)
									end
									continue
								end
							else
								continue
							end
						end

						if SharedStringOverwrite and ValueType == "BinaryString" then -- TODO: Convert this to table if more types are added
							ValueType = "SharedString"
						end

						if
							default_instance
							and not Property.Special -- TODO: .Special is checked more than once
							and not (PropertyName == "Source" and isLuaSourceContainer(instance))
						then -- ? Could be not just "Source" in the future
							if new_def_inst then
								default_instance[PropertyName] = getsafeproperty(new_def_inst, PropertyName)
							end
							if default_instance[PropertyName] == raw then
								continue
							end
							-- local ok, IsModified = pcall(IsPropertyModified, instance, PropertyName) -- ? Not yet enabled lol (580)
						end

						-- Serialization start
						local Category = Property.Category

						local tag, value
						if Category == "Class" then
							tag = "Ref"
							if raw then
								if SaveNonCreatableWillBeEnabled then
									local Fix = NotCreatableFixes[raw.ClassName]
									if
										Fix
										and (
											PropertyName == "PlayerToHideFrom"
											or ValueType ~= "Instance" and ValueType ~= Fix
										)
									then
										continue
									end
								end

								value = referents[raw]
								if not value then
									value = ref_size
									referents[raw] = value
									ref_size += 1
								end
							else
								value = "null"
							end
						elseif Category == "Enum" then -- ! We do this order (Enums before Descriptors) specifically because Font Enum might get a Font Descriptor despite having Enum Category, unlike Font DataType which that Descriptor is meant for
							value, tag = XML_Descriptors.__ENUM(raw)
						else
							local Descriptor = XML_Descriptors[ValueType]

							if Descriptor then
								value, tag = ReturnValueAndTag(raw, ValueType, Descriptor)
							elseif "ProtectedString" == ValueType then -- TODO: Try fitting this inside Descriptors
								tag = ValueType

								if PropertyName == "Source" then
									if DecompileIgnoring then -- ? Should this really prevent extraction of the original source if present ?
										if DecompileIgnoring == 1 then
											DecompileIgnoring = nil
										end
										value = "-- Ignored"
									else
										local should_decompile = true
										local LinkedSource
										local LinkedSource_Url = instance.LinkedSource -- ! Assuming every Class that has ProtectedString Source property also has a LinkedSource property
										local hasLinkedSource = LinkedSource_Url ~= ""
										if hasLinkedSource then
											local Path = instance:GetFullName()
											if RecoveredScripts then
												table.insert(RecoveredScripts, Path)
											else
												RecoveredScripts = { Path }
											end

											do -- TODO Temporary fix for crashes (getscriptbytecode calls on scripts with LinkedSource), originally was inside the "ok" block below
												should_decompile = nil
												value = ""
											end

											LinkedSource = string.match(LinkedSource_Url, "%w+$") -- TODO: No sure if this pattern matches all possible cases. Example is: 'rbxassetid://0&hash=cd73dd2fe5e5013137231c227da3167e'
											if LinkedSource then
												local cached = ldeccache[LinkedSource]

												if cached then
													value = cached
													should_decompile = nil
												elseif DecompileJobless then
													value = "-- Not found in already decompiled ScriptCache"
													should_decompile = nil
												end

												local function filterResults(str)
													local o, r =
														pcall(service.HttpService.JSONDecode, service.HttpService, str)
													if o and r.errors then
														return false
													end
													return true
												end

												local asset = (string.find(LinkedSource, "%a") and "hash" or "id")
													.. "="
													.. LinkedSource

												local source
												local ok = pcall(function()
													source = game:HttpGet(
														"https://assetdelivery.roproxy.com/v1/asset/?" .. asset
													)
												end)

												if ok then
													ok = filterResults(source)
												end

												if not ok then
													ok = run_with_loading(
														"Getting " .. instance.Name .. " LinkedSource",
														true,
														nil,
														pcall,
														function()
															source = game:HttpGet(
																"https://linkedsource.glitch.me/asset/" .. asset
															)
														end
													)
												end

												if ok then
													ok = filterResults(source)
												end

												if ok then
													ldeccache[LinkedSource] = source

													value = source

													-- should_decompile = nil
												end
											else --if __DEBUG_MODE then -- * We print this anyway because very important
												warn(
													"FAILED TO EXTRACT ORIGINAL SCRIPT SOURCE (OPEN A GITHUB ISSUE): ",
													instance:GetFullName(),
													LinkedSource_Url
												)
											end
										end

										if should_decompile then
											local isLocalScript = instance:IsA("LocalScript")
											if
												isLocalScript and instance.RunContext == Enum.RunContext.Server
												or not isLocalScript
													and instance:IsA("Script")
													and instance.RunContext ~= Enum.RunContext.Client
											then
												value = "-- Server Scripts can NOT be saved" --TODO: Could be not just server scripts in the future
											else
												value = ldecompile(instance)
												if SaveBytecode then
													local output = SaveBytecode(instance)
													if output then
														value = output .. value
													end
												end
											end
										end

										value = "-- Saved by UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw\n\n"
											.. (hasLinkedSource and "-- Original Source: https://assetdelivery.roblox.com/v1/asset/?id=" .. (LinkedSource or LinkedSource_Url) .. "\n\n" or "")
											.. value
									end
								end
								value = XML_Descriptors.__PROTECTEDSTRING(value)
							-- elseif "UniqueId" == ValueType or "SecurityCapabilities" == ValueType then -- ? Not sure yet
							-- 	tag, value = ValueType, raw
							else
								--OptionalCoordinateFrame and so on, we make it dynamic

								if string.sub(ValueType, 1, 8) == "Optional" then
									-- Extract the string after "Optional"

									Descriptor = XML_Descriptors[string.sub(ValueType, 9)]

									if Descriptor then
										if raw ~= nil then
											value, tag = ReturnValueAndTag(raw, ValueType, Descriptor)
										else
											value, tag = "", ValueType -- ? It can be empty supposedly, because it's optional
										end
									end
								end
							end
						end

						if tag then
							savebuffer[savebuffer_size] = ReturnProperty(tag, PropertyName, value)
							savebuffer_size += 1
						else --if __DEBUG_MODE then -- * We print this anyway because very important
							warn("UNSUPPORTED TYPE (OPEN A GITHUB ISSUE): ", ValueType, ClassName, PropertyName)
						end
					end
				end
				savebuffer[savebuffer_size] = "</Properties>"
				savebuffer_size += 1

				if SaveCacheInterval < savebuffer_size then
					save_cache()
				end
			end

			if SkipEntirely ~= false then -- ? We save instance without it's descendants in this case (== false)
				local Children = ChildrenOverride or queuedHierarchy or instance:GetChildren()

				if #Children ~= 0 then
					save_hierarchy(Children)
				end
			end

			if DecompileIgnoring and DecompileIgnoring == instance then
				DecompileIgnoring = nil
			end

			savebuffer[savebuffer_size] = "</Item>"
			savebuffer_size += 1
		end
	end

	local function save_extra(name, hierarchy, customClassName, source)
		savebuffer[savebuffer_size] = save_specific((customClassName or "Folder"), { Name = name, Source = source })
		savebuffer_size += 1
		if hierarchy then
			save_hierarchy(hierarchy)
		end
		savebuffer[savebuffer_size] = "</Item>"
		savebuffer_size += 1
	end

	local function save_game()
		writefile(placename, "")

		if IsModel then
			savebuffer[savebuffer_size] = '<Meta name="ExplicitAutoJoints">true</Meta>'
			savebuffer_size += 1
		end
		--[[
			-- ? Roblox encodes the following additional attributes. These are not required. Moreover, any defined schemas are ignored, and not required for a file to be valid: xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd"  
		Also http can be converted to https but not sure if Roblox would decide to detect that
		-- ? <External>null</External><External>nil</External>  - <External> is a legacy concept that is no longer used.
		]]

		-- TODO Find a better solution for this
		SaveNonCreatableWillBeEnabled = SaveNonCreatable
			or (IsolateLocalPlayer or IsolateLocalPlayerCharacter) and IsolateLocalPlayer
			or IsolatePlayers
			or NilInstances and global_container.getnilinstances -- ! Make sure this accurately reflects everything below
		if ToSaveInstance then
			save_hierarchy({ ToSaveInstance }, ToSaveList)
		else
			save_hierarchy(ToSaveList)
		end

		if IsolateLocalPlayer or IsolateLocalPlayerCharacter then
			local Players = service.Players
			local LocalPlayer = Players.LocalPlayer
			if IsolateLocalPlayer then
				SaveNonCreatable = true
				save_extra("LocalPlayer", LocalPlayer:GetChildren())
			end
			if IsolateLocalPlayerCharacter then
				local LocalPlayerCharacter = LocalPlayer.Character
				if LocalPlayerCharacter then
					save_extra("LocalPlayer Character", LocalPlayerCharacter:GetChildren())
				end
			end
		end

		if IsolateStarterPlayer then
			-- SaveNonCreatable = true -- TODO: Enable if StarterPlayerScripts or StarterCharacterScripts stop showing up in isolated folder in Studio
			save_extra("StarterPlayer", service.StarterPlayer:GetChildren())
		end

		if IsolatePlayers then
			SaveNonCreatable = true
			save_extra("Players", service.Players:GetChildren())
		end

		if NilInstances and global_container.getnilinstances then
			local nil_instances, nil_instances_size = {}, 1

			local NilInstancesFixes = OPTIONS.NilInstancesFixes

			for _, instance in global_container.getnilinstances() do
				if instance == game then
					instance = nil
					-- break
				else
					local ClassName = instance.ClassName

					local Fix = InheritsFix(NilInstancesFixes, ClassName, instance)

					if Fix then
						instance = Fix(instance, InstancePropertyOverrides)
						-- continue
					end

					local Class = ClassList[ClassName]
					if Class then
						local ClassTags = Class.Tags
						if ClassTags and ClassTags.Service then -- For CSGDictionaryService, NonReplicatedCSGDictionaryService, LogService, ProximityPromptService, TestService & more
							-- instance.Parent = game
							instance = nil
							-- continue
						end
					end
				end
				if instance then
					nil_instances[nil_instances_size] = instance
					nil_instances_size += 1
				end
			end
			SaveNonCreatable = true
			save_extra("Nil Instances", nil_instances)
		end

		if OPTIONS.ReadMe then
			save_extra(
				"README",
				nil,
				"Script",
				"--[[\n"
					.. (RecoveredScripts and "\t\tIMPORTANT: Original Source of these Scripts was Recovered: " .. service.HttpService:JSONEncode(
						RecoveredScripts
					) .. "\n" or "")
					.. [[
		Thank you for using UniversalSynSaveInstance.

		If you didn't save in Binary - we recommended to save the game right away to take advantage of the binary format & to preserve values of certain properties if you used IgnoreDefaultProperties setting (as they might change in the future).
		You can do that by going to FILE -> Save to File As -> Make sure File Name ends with .rbxl -> Save

		If your player cannot spawn into the game, please move the scripts in StarterPlayer somewhere else. Then run `game:GetService("Players").CharacterAutoLoads = true`.
		And use "Play Here" to start game instead of "Play" to spawn your Character where your Camera currently is.

		If the chat system does not work, please use the explorer and delete everything inside the TextChatService/Chat service(s). 
		Or run `game:GetService("Chat"):ClearAllChildren()`
				
		If Union and MeshPart collisions don't work, run the script below in the Studio Command Bar:
				
				
		local C = game:GetService("CoreGui")
		local D = Enum.CollisionFidelity.Default
				
		for _, v in game:GetDescendants() do
			if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
				v.CollisionFidelity = D
			end
		end
				
		If you can't move the Camera, run this script in the Studio Command Bar:
			
		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
		
		Or Destroy the Camera.

		This file was generated with the following settings:
				]]
					.. service.HttpService:JSONEncode(OPTIONS)
					.. "\n\n\t\tElapsed time: "
					.. os.clock() - elapse_t
					.. " PlaceId: "
					.. game.PlaceId
					.. " Executor: "
					.. (identify_executor and table.concat({ identify_executor() }, " ") or "Unknown")
					.. "\n]]"
			)
		end
		do
			local tmp = { "<SharedStrings>" }
			for identifier, value in SharedStrings do
				table.insert(tmp, '<SharedString md5="' .. identifier .. '">' .. value .. "</SharedString>")
			end

			if 1 < #tmp then -- TODO: This sucks so much because we try to iterate a table just to check this (check above)
				savebuffer[savebuffer_size] = table.concat(tmp)
				savebuffer[savebuffer_size] = "</SharedStrings>"
				savebuffer_size += 2 -- ? Is this fine
			end
		end

		savebuffer[savebuffer_size] = "</roblox>"
		savebuffer_size += 1
		save_cache()
		do
			-- ! Assuming we only write to file once hence why we only filter once
			-- TODO This might cause issues on non-unique Usernames (ex. "Cake" if game is about cakes then everything supposedly related to your name will be replaced with "Roblox"); Certain UserIds might also affect numbers, like if your UserId is 2481848 and there is some number that goes like "1.248184818837" then that the matched part will be replaced with 1, potentially making the number incorrect.
			-- TODO The only logical solution to that is to instead filter only certain properties like Player.UserId and such, but this would leave Instances under workspace unfiltered even if they have your UserId for example.
			-- TODO So for now it's best to keep this disabled by default
			if OPTIONS.Anonymous then
				local LocalPlayer = service.Players.LocalPlayer

				totalstr = string.gsub(string.gsub(totalstr, LocalPlayer.UserId, "1"), LocalPlayer.Name, "Roblox")
			end

			if EXECUTOR_NAME ~= "Celery" then
				run_with_loading(
					"Writing " .. get_size_format() .. " to File (Depends on Exec)",
					nil,
					true,
					writefile,
					placename,
					totalstr
				)
			else
				local SegmentLength = 4145728 -- Celery has an arbitrary savefile/appendfile size limit of ~4MB for reasons unknown. This is a workaround to save the file in segments.
				local Length = math.ceil(totalsize / SegmentLength)

				for i = 1, Length do
					local savestr = string.sub(totalstr, (i - 1) * SegmentLength + 1, i * SegmentLength)

					run_with_loading(
						"Writing to File " .. math.round(i / Length * 100) .. "% (Depends on Exec)",
						nil,
						true,
						appendfile,
						placename,
						savestr
					)

					task.wait(0.1)
				end
			end
		end
		table.clear(SharedStrings)
	end

	local Connections
	do
		local Players = service.Players
		local LocalPlayer = Players.LocalPlayer

		if IgnoreList.Model ~= true then
			Connections = {}
			local function ignoreCharacter(player)
				table.insert(
					Connections,
					player.CharacterAdded:Connect(function(character)
						IgnoreList[character] = true
					end)
				)

				local Character = player.Character
				if Character then
					IgnoreList[Character] = true
				end
			end

			if OPTIONS.RemovePlayerCharacters then
				table.insert(
					Connections,
					Players.PlayerAdded:Connect(function(player)
						ignoreCharacter(player)
					end)
				)
				for _, player in Players:GetPlayers() do
					ignoreCharacter(player)
				end
			else
				IgnoreNotArchivable = false -- TODO Bad solution (Characters are NotArchivable); Also make sure the next solution is compatible with IsolateLocalPlayerCharacter
				if IsolateLocalPlayerCharacter then
					ignoreCharacter(LocalPlayer)
				end
			end
		end
		if IsolateLocalPlayer and IgnoreList.Player ~= true then
			IgnoreList[LocalPlayer] = true
		end
	end

	if IsolateStarterPlayer then
		IgnoreList.StarterPlayer = false
	end

	if IsolatePlayers then
		IgnoreList.Players = false
	end

	if OPTIONS.ShowStatus then
		do
			local Exists = GLOBAL_ENV._statustext
			if Exists then
				Exists:Destroy()
			end
		end

		local StatusGui = Instance.new("ScreenGui")

		GLOBAL_ENV._statustext = StatusGui

		StatusGui.DisplayOrder = 2_000_000_000
		pcall(function() -- ? Compatibility with level 2
			StatusGui.OnTopOfCoreBlur = true
		end)

		StatusText = Instance.new("TextLabel")

		StatusText.Text = "Saving..."

		StatusText.BackgroundTransparency = 1
		StatusText.Font = Enum.Font.Code
		StatusText.AnchorPoint = Vector2.new(1)
		StatusText.Position = UDim2.new(1)
		StatusText.Size = UDim2.new(0.3, 0, 0, 20)

		StatusText.TextColor3 = Color3.new(1, 1, 1)
		StatusText.TextScaled = true
		StatusText.TextStrokeTransparency = 0.7
		StatusText.TextXAlignment = Enum.TextXAlignment.Right
		StatusText.TextYAlignment = Enum.TextYAlignment.Top

		StatusText.Parent = StatusGui

		local function randomString()
			local length = math.random(10, 20)
			local randomarray = table.create(length)
			for i = 1, length do
				randomarray[i] = string.char(math.random(32, 126))
			end
			return table.concat(randomarray)
		end

		if global_container.gethui then
			StatusGui.Name = randomString()
			StatusGui.Parent = global_container.gethui()
		elseif global_container.protectgui then
			StatusGui.Name = randomString()
			global_container.protectgui(StatusGui)
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
	end

	do
		if OPTIONS.SafeMode then
			service.Players.LocalPlayer:Kick("\nSaving in Progress..\nPlease do NOT leave")
			service.RunService:Set3dRenderingEnabled(false)
			wait_for_render()
			task.delay(10, service.GuiService.ClearError, service.GuiService)
		end

		elapse_t = os.clock()
		local ok, err = xpcall(save_game, function(err)
			return debug.traceback(err)
		end)
		if Connections then
			for _, connection in Connections do
				connection:Disconnect()
			end
		end
		-- GLOBAL_ENV.__USSI = nil
		if StatusText then
			task.spawn(function()
				elapse_t = os.clock() - elapse_t
				local Log10 = math.log10(elapse_t)
				local ExtraTime = 10
				if ok then
					StatusText.Text = string.format("Saved! Time %.3f seconds; Size %s", elapse_t, get_size_format())
					StatusText.TextColor3 = Color3.new(0, 1)
					task.wait(Log10 * 2 + ExtraTime)
				else
					if Loading then
						task.cancel(Loading)
						Loading = nil
					end
					StatusText.Text = "Failed! Check F9 console for more info"
					StatusText.TextColor3 = Color3.new(1)
					warn("Error found while saving:")
					warn(err)
					task.wait(Log10 + ExtraTime)
				end
				StatusText:Destroy()
			end)
		end
	end
end

return synsaveinstance
