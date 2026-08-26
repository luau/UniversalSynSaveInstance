--!native
--!optimize 2
--!divine-intellect
-- https://discord.gg/wx4ThpAsmw

local function string_find(s, pattern, init)
	return string.find(s, pattern, init, true)
end

local function arrayToDict(t, mixedMode, valueOverride, typeStrict)
	local tmp = {}

	if mixedMode then
		for any1, any2 in t do
			if type(any1) == "number" then
				tmp[any2] = valueOverride or true
			elseif type(any2) == "table" then
				tmp[any1] = arrayToDict(any2, mixedMode) -- any1 is Class, any2 is Name
			else
				tmp[any1] = any2
			end
		end
	else
		for _, key in t do
			if not typeStrict or typeStrict and type(key) == typeStrict then
				tmp[key] = true
			end
		end
	end

	return tmp
end

local GLOBAL_ENV = getgenv and getgenv() or _G or shared

local service = setmetatable({}, {
	__index = function(self, serviceName)
		local o, s = pcall(Instance.new, serviceName)
		local Service = o and s
			or game:GetService(serviceName)
			or settings():GetService(serviceName)
			or UserSettings():GetService(serviceName)

		-- if cloneref then
		-- 	Service = cloneref(Service)
		-- end
		if Service then
			self[serviceName] = Service
		end
		return Service
	end,
})

local StreamBuffer
do
	local filename = "StreamBuffer"

	StreamBuffer = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
		filename
	)()
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
		-- request = 'string.find(...,"request",nil,true) and not string.find(...,"internal",nil,true)',
		base64encode = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"encode")and(c(b,"base64")or c(string.lower(tostring(a[2])),"base64"))',
		base64decode = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"decode")and(c(b,"base64")or c(string.lower(tostring(a[2])),"base64"))',
		-- cloneref = 'string.find(...,"clone",nil,true) and string.find(...,"ref",nil,true)',
		-- decompile = '(string.find(...,"decomp",nil,true) and string.sub(...,#...) ~= "s")',
		gethiddenproperty = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) ~= "s"',
		gethui = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"ui",nil,true)',
		-- getcon = 'string.find(...,"get",nil,true) and (string.find(...,"conn",nil,true) or string.find(...,"sig",nil,true)) and string.sub(...,#(...))=="s"',
		getnilinstances = 'string.find(...,"nil",nil,true) and string.find(...,"get",nil,true) and string.sub(...,#...) == "s"', -- ! Could match some unwanted stuff
		getscriptbytecode = 'string.find(...,"get",nil,true) and string.find(...,"script",nil,true) and string.find(...,"bytecode",nil,true)', --  or string.find(...,"dump",nil,true) and string.find(...,"string",nil,true) due to Fluxus (dumpstring returns a function)
		-- hash = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"hash")and c(string.lower(tostring(a[2])),"crypt")',
		protectgui = 'string.find(...,"protect",nil,true) and string.find(...,"ui",nil,true) and not string.find(...,"un",nil,true)',
		setrbxclipboard = 'string.find(...,"set",nil,true) and string.find(...,"rbx",nil,true) and string.find(...,"clipboard",nil,true)',
		-- setthreadidentity = 'string.find(...,"identity",nil,true) and string.find(...,"set",nil,true)',
	}, true, 10)
end

local identify_executor = identifyexecutor or getexecutorname or whatexecutor

local EXECUTOR_NAME = identify_executor and identify_executor() or ""

local setrbxclipboard = global_container.setrbxclipboard

-- local cloneref = global_container.cloneref
local gethiddenproperty = global_container.gethiddenproperty
local gethiddenproperty_fallback

-- These should be universal enough
local lz4compress = lz4compress
local zstdcompress = zstdcompress
local appendfile = appendfile
local isfile = isfile
local readfile = readfile
local writefile = writefile

local getscriptbytecode = global_container.getscriptbytecode -- * A lot of assumptions are made based on whether this function is defined or not. So in certain edge cases, like if the executor defines "decompile" or "getscripthash" function yet doesn't define this function there might be loss of functionality of the saveinstance. Although that would be very rare and weird
local base64encode = global_container.base64encode
local base64decode = global_container.base64decode

local sharedStringId = 1e15 -- 1 quadrillion, up to 9.(9) quadrillion, in theory this shouldn't ever run out and be enough for all sharedstrings ever imaginable 	-- TODO: worst case, add fallback to str randomizer once numbers run out : )
local sharedStrings = setmetatable({}, {
	__index = function(self, str)
		local id = base64encode(tostring(sharedStringId)) -- tostring is only needed for built-in base64encode, Luau base64 implementations don't need it as buffers autoconvert
		sharedStringId += 1

		self[str] = id -- ? The value of the md5 attribute is a Base64-encoded key. <SharedString> type elements use this key to refer to the value of the string. The value is the text content, which is Base64-encoded. Historically, the key was the MD5 hash of the string value. However, this is not required; the key can be any value that will uniquely identify the shared string. Roblox currently uses BLAKE2b truncated to 16 bytes..
		return id
	end,
})

local inheritedProperties = {}
local defaultInstances = {}
local referents, refSize = setmetatable({}, { __mode = "ks" }), 0 -- ? Roblox encodes all <Item> elements with a referent attribute. Each value is generated by starting with the prefix RBX, followed by a UUID version 4, with - characters removed, and all characters converted to uppercase.

local function getRef(instance)
	local ref = referents[instance]
	if not ref then
		ref = refSize
		referents[instance] = ref
		refSize += 1
	end
	return ref
end

local function index(self, index_name)
	return self[index_name]
end

local FULL_VERSION

if not pcall(function()
	FULL_VERSION = version()
end) then
	if not pcall(function()
		FULL_VERSION = settings():GetService("DebugSettings").RobloxVersion
	end) then
		if not pcall(function()
			FULL_VERSION = service.RunService:GetRobloxVersion()
		end) then
			FULL_VERSION = "UNKNOWN"
		end
	end
end

local CLIENT_VERSION = tonumber(string.match(FULL_VERSION, "%d+%.(%d+)")) or 9e9
local __BREAK = "__BREAK" .. service.HttpService:GenerateGUID(false)
local USSI_FOLDER = "ussi_cache/"

pcall(function()
	makefolder(USSI_FOLDER)
end)

local Type_Ids = {
	["string"] = 1,
	["bool"] = 2,
	["int"] = 3,
	["float"] = 4,
	["double"] = 5,
	["UDim"] = 6,
	["UDim2"] = 7,
	["Ray"] = 8,
	["Faces"] = 9,
	["Axes"] = 10,
	["BrickColor"] = 11,
	["Color3"] = 12,
	["Vector2"] = 13,
	["Vector3"] = 14,
	["Vector2int16"] = 15,
	["CFrame"] = 16,
	-- ["CFrameQuat"] = 17,
	["Enum"] = 18,
	["Referent"] = 19,
	["Vector3int16"] = 20,
	["NumberSequence"] = 21,
	["ColorSequence"] = 22,
	["NumberRange"] = 23,
	["Rect"] = 24,
	["PhysicalProperties"] = 25,
	["Color3uint8"] = 26,
	["int64"] = 27,
	["SharedString"] = 28,
	-- ["Bytecode"] = 29,
	["OptionalCoordinateFrame"] = 30,
	["UniqueId"] = 31,
	["Font"] = 32,
	["SecurityCapabilities"] = 33,
	["Content"] = 34,
	-- ["AssetContentMap"] = 35, -- TODO
}

local Attribute_Type_Ids =
	{ -- ValueCurveKey & StyleRule.PropertiesSerialize can be used to explore types unsupported by attributes, as they share the same serializer
		["nil"] = 0x01,
		string = 0x02,
		boolean = 0x03,
		int32 = 0x04,
		-- float = 0x05, -- float32
		number = 0x06, -- float64 (double)
		ValueArray = 0x07,
		ValueTable = 0x08, -- Dictionary
		UDim = 0x09,
		UDim2 = 0x0A,
		Ray = 0x0B,
		Faces = 0x0C,
		Axes = 0x0D,
		BrickColor = 0x0E,
		Color3 = 0x0F,
		Vector2 = 0x10,
		Vector3 = 0x11,
		Vector2int16 = 0x12,
		Vector3int16 = 0x13,
		CFrame = 0x14,
		EnumItem = 0x15,
		-- 0x16
		NumberSequence = 0x17,
		NumberSequenceKeypoint = 0x18,
		ColorSequence = 0x19,
		ColorSequenceKeypoint = 0x1A,
		NumberRange = 0x1B,
		Rect = 0x1C,
		PhysicalProperties = 0x1D,
		Color3uint8 = 0x1E,
		Region3 = 0x1F,
		Region3int16 = 0x20,
		Font = 0x21,
		SecurityCapabilities = 0x22,
		Path2DControlPoint = 0x23,
		TweenInfo = 0x24,
		-- InstanceHandle = 0x25,
	}

local CFrame_Rotation_Ids = {
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
local rotationBuffer = buffer.create(36)
local function rawBasisString(r00, r01, r02, r10, r11, r12, r20, r21, r22)
	buffer.writef32(rotationBuffer, 0, r00)
	buffer.writef32(rotationBuffer, 4, r01)
	buffer.writef32(rotationBuffer, 8, r02)
	buffer.writef32(rotationBuffer, 12, r10)
	buffer.writef32(rotationBuffer, 16, r11)
	buffer.writef32(rotationBuffer, 20, r12)
	buffer.writef32(rotationBuffer, 24, r20)
	buffer.writef32(rotationBuffer, 28, r21)
	buffer.writef32(rotationBuffer, 32, r22)
	return buffer.tostring(rotationBuffer)
end

local EMPTY_BUFFER = buffer.create(0)
local BASE_CAPABILITIES
pcall(function()
	BASE_CAPABILITIES = SecurityCapabilities.new()
end)
local CAPABILITY_BITS = {
	Plugin = 0,
	LocalUser = 1,
	WritePlayer = 2,
	RobloxScript = 3,
	RobloxEngine = 4,
	NotAccessible = 5,
	RunClientScript = 8,
	RunServerScript = 9,
	AccessOutsideWrite = 11,
	Unassigned = 15,
	LoadUnownedAsset = 16,
	LoadString = 17,
	ScriptGlobals = 18,
	CreateInstances = 19,
	Basic = 20,
	Audio = 21,
	DataStore = 22,
	Network = 23,
	Physics = 24,
	UI = 25,
	CSG = 26,
	Chat = 27,
	Animation = 28,
	AvatarAppearance = 29,
	Input = 30,
	Environment = 31,
	-- high half
	RemoteEvent = 32,
	LegacySound = 33,
	Players = 34,
	CapabilityControl = 35,
	AssetRead = 36,
	AssetManagement = 37,
	DynamicGeneration = 38,
	PlatformAvatarEditing = 39,
	AssetCreateUpdate = 40,
	Capture = 41,
	SensitiveInput = 42,
	Monetization = 43,
	LoadOwnedAsset = 44,
	Social = 45,
	ServerCommunication = 46,
	Logging = 47,
	PromptExternalPurchase = 48,
	Groups = 49,
	Teleport = 50,
	Consequences = 51,
	Material = 52,
	AvatarBehavior = 53,
	RemoteCommand = 59,
	InternalTest = 60,
	PluginOrOpenCloud = 61,
	Assistant = 62,
	Restricted = 63,
}

local function capabilityHalves(raw)
	-- TODO tostring & string.split aren't ideal but this is the only way until the feature is out of the experimental phase (SecurityCapabilities.Contains exists but the Enums that it accepts lacks some hidden bits) - NotAccessible, Unknown, Restricted
	-- ! Seems like both tostring & .Contains ignore high / internal bits (anything above CapabilityControl): RemoteCommand, InternalTest, PluginOrOpenCloud, Assistant. They're present when created & saved by Studio but can't be read through current means

	-- TODO Use https://rfcs.luau.org/type-long-integer.html once released to avoid overflow beyond ^53

	local lo, hi = 0, 0
	for _, flag in string.split(tostring(raw), " | ") do
		local b = CAPABILITY_BITS[flag]
		if b then
			if b < 32 then
				lo = bit32.bor(lo, bit32.lshift(1, b))
			else
				hi = bit32.bor(hi, bit32.lshift(1, b - 32))
			end
		end
	end
	return lo, hi
end

local function capabilityNumber(raw)
	local lo, hi = capabilityHalves(raw)
	return hi * 0x100000000 + lo
end

local function countBits(...)
	local Value = 0

	for i, bit in { ... } do
		if bit then
			Value += 2 ^ (i - 1)
		end
	end

	return Value
end

local function cframeToQuaternion(cframe)
	local _, _, _, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:GetComponents()
	local trace = R00 + R11 + R22
	local S, qW, qX, qY, qZ
	if trace > 0 then
		S = math.sqrt(1 + trace) * 2
		qW = 0.25 * S
		qX = (R21 - R12) / S
		qY = (R02 - R20) / S
		qZ = (R10 - R01) / S
	elseif (R00 > R11) and (R00 > R22) then
		S = math.sqrt(1 + R00 - R11 - R22) * 2
		qW = (R21 - R12) / S
		qX = 0.25 * S
		qY = (R01 + R10) / S
		qZ = (R02 + R20) / S
	elseif R11 > R22 then
		S = math.sqrt(1 + R11 - R00 - R22) * 2
		qW = (R02 - R20) / S
		qX = (R01 + R10) / S
		qY = 0.25 * S
		qZ = (R12 + R21) / S
	else
		S = math.sqrt(1 + R22 - R00 - R11) * 2
		qW = (R10 - R01) / S
		qX = (R02 + R20) / S
		qY = (R12 + R21) / S
		qZ = 0.25 * S
	end
	-- Force consistent sign (W positive) to match Roblox serializer
	if qW < 0 then
		qW, qX, qY, qZ = -qW, -qX, -qY, -qZ
	end
	return qX, qY, qZ, qW
end

local function classifyTable(t)
	local len = #t
	if len == 0 then
		len = nil
	end
	if next(t, len) == nil then
		return "ValueArray"
	else
		return "ValueTable"
	end
end

local function resolveTypeName(value)
	local t = typeof(value)
	if t == "table" then
		return classifyTable(value)
	end
	return t
end

-- Scalar transforms
local scratch = buffer.create(8)

-- Big-endian bit-rotated f32, no allocations.
local function rotf(v)
	buffer.writef32(scratch, 0, v)
	return bit32.lrotate(buffer.readu32(scratch, 0), 1)
end

local function zigzag32(v)
	return (v < 0) and (2 * -v - 1) or (2 * v)
end

local function splitU64(v)
	local hi = math.floor(v / 4294967296)
	return hi, v - hi * 4294967296
end

-- 64-bit zigzag from a Lua number. Doubling happens on the halves so it
-- never round-trips through a double.
local function zigzag64(v)
	local neg = v < 0
	local hi, lo = splitU64(neg and -v or v)

	local carry = bit32.extract(lo, 31)
	lo = bit32.lshift(lo, 1)
	hi = bit32.bor(bit32.lshift(hi, 1), carry)

	if neg then -- magnitude is >= 1, so this can't underflow
		if lo == 0 then
			lo, hi = 0xFFFFFFFF, hi - 1
		else
			lo -= 1
		end
	end
	return hi, lo
end

-- 64-bit zigzag from u32 halves. No arithmetic, so `Restricted` (bit 63) --
-- which makes the value negative as an i64 -- falls out correctly.
local function zigzagHalves(hi, lo)
	local sign = bit32.extract(hi, 31)
	local shi = bit32.bor(bit32.lshift(hi, 1), bit32.extract(lo, 31))
	local slo = bit32.lshift(lo, 1)
	if sign == 1 then
		shi, slo = bit32.bnot(shi), bit32.bnot(slo)
	end
	return shi, slo
end

local function u32FromHex(hex, at)
	return tonumber(string.sub(hex, at, at + 7), 16)
end

-- Byte-plane writers

local function pokeU32Planes(sbuf, o, n, v)
	sbuf:pokeu8(o, bit32.rshift(v, 24))
	sbuf:pokeu8(o + n, bit32.band(bit32.rshift(v, 16), 0xFF))
	sbuf:pokeu8(o + 2 * n, bit32.band(bit32.rshift(v, 8), 0xFF))
	sbuf:pokeu8(o + 3 * n, bit32.band(v, 0xFF))
end

local function pokeU64Planes(sbuf, o, n, hi, lo)
	pokeU32Planes(sbuf, o, n, hi)
	pokeU32Planes(sbuf, o + 4 * n, n, lo)
end

local function interleavedU32Plane(sbuf, n, base, getU32ForIndex)
	for i = 1, n do
		pokeU32Planes(sbuf, base + (i - 1), n, getU32ForIndex(i))
	end
end

-- Zigzag-delta referent plane. Every referent array in the format is this:
-- INST referents, PRNT object/parent, Referent props, Content ObjectRefs.
local function writeRefPlane(sbuf, n, base, getRef)
	local lastRef = nil
	interleavedU32Plane(sbuf, n, base, function(i)
		local ref = getRef(i)
		local acc = lastRef and (ref - lastRef) or ref
		lastRef = ref
		return zigzag32(acc)
	end)
end

-- Encoder factories

local function planeEncoder(...)
	local getters = { ... }
	local k = #getters
	return function(sbuf, vals, n)
		local base = sbuf:allocRegion(4 * k * n)
		local stride = 4 * n
		for i = 1, n do
			local v = vals[i]
			for p = 1, k do
				pokeU32Planes(sbuf, base + (p - 1) * stride + (i - 1), n, getters[p](v))
			end
		end
	end
end

local function f32Encoder(...)
	local paths = { ... }
	return function(sbuf, vals, n)
		for i = 1, n do
			local v = vals[i]
			for _, p in paths do
				sbuf:writef32(p(v))
			end
		end
	end
end

local function i16Encoder(...)
	local comps = { ... }
	return function(sbuf, vals, n)
		for i = 1, n do
			local v = vals[i]
			for _, c in comps do
				sbuf:writei16(v[c])
			end
		end
	end
end

local function sequenceEncoder(writeKeypoint)
	return function(sbuf, vals, n)
		for i = 1, n do
			local keypoints = vals[i].Keypoints
			sbuf:writeu32(#keypoints)
			for _, kp in keypoints do
				writeKeypoint(sbuf, kp)
			end
		end
	end
end

local function flagEncoder(bits)
	return function(sbuf, vals, n)
		for i = 1, n do
			local v = vals[i]
			local packed = 0
			for name, b in bits do
				if v[name] then
					packed += b
				end
			end
			sbuf:writeu8(packed)
		end
	end
end

local function writeCFrameBody(sbuf, vals, n, existsOut)
	local coordsX, coordsY, coordsZ = table.create(n), table.create(n), table.create(n)

	for i = 1, n do
		local val = vals[i]

		if existsOut then
			local has = val ~= nil
			existsOut[i] = has
			if not has then
				val = CFrame.identity
			end
		end

		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = val:GetComponents()
		coordsX[i], coordsY[i], coordsZ[i] = x, y, z

		local rotStr = rawBasisString(r00, r01, r02, r10, r11, r12, r20, r21, r22)
		local id = CFrame_Rotation_Ids[rotStr]
		if id then
			sbuf:writeu8(id)
		else
			sbuf:writeu8(0)
			sbuf:writestring(rotStr)
		end
	end

	local posBase = sbuf:allocRegion(12 * n)
	local planes = { coordsX, coordsY, coordsZ }
	for p = 1, 3 do
		local coords = planes[p]
		interleavedU32Plane(sbuf, n, posBase + (p - 1) * 4 * n, function(i)
			return rotf(coords[i])
		end)
	end
end

local Attribute_Encoders
Attribute_Encoders = {
	_packMultiple = function(encoder, value1, value2, value3)
		local buf1, size1 = encoder(value1)
		local buf2, size2 = encoder(value2)

		local len = size1 + size2
		local buf3, size3

		if value3 ~= nil then
			buf3, size3 = encoder(value3)
			len += size3
		end

		local b = buffer.create(len)

		buffer.copy(b, 0, buf1)
		buffer.copy(b, size1, buf2)

		if value3 ~= nil then
			buffer.copy(b, size1 + size2, buf3)
		end

		return b, len
	end,
	_makeSequence = function(keypoint_handler, keypointSize)
		return function(raw)
			local keypoints = raw.Keypoints
			local n = #keypoints

			local len = 4 + keypointSize * n
			local b = buffer.create(len)

			buffer.writeu32(b, 0, n)

			local offset = 4
			for _, keypoint in keypoints do
				keypoint_handler(keypoint, b, offset)
				offset += keypointSize
			end

			return b, len
		end
	end,
	_writeI64LE = function(b, offset, raw)
		local low = bit32.band(raw, 0xFFFFFFFF)
		local high = (raw - low) / 0x100000000

		buffer.writei32(b, offset, low)
		buffer.writei32(b, offset + 4, high)
	end,
	_packF32 = nil,
	_packI16 = nil,
	_makeVectorPacker = function(writeFunc, elementSize)
		return function(X, Y, Z)
			local len = Z and (elementSize * 3) or (elementSize * 2)
			local b = buffer.create(len)

			writeFunc(b, 0, X)
			writeFunc(b, elementSize, Y)
			if Z then
				writeFunc(b, elementSize * 2, Z)
			end

			return b, len
		end
	end,
	--------------------------------------------------------------
	--------------------------------------------------------------
	--------------------------------------------------------------
	["nil"] = function(raw)
		return EMPTY_BUFFER, 0
	end,
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
	["ValueArray"] = function(raw)
		-- #raw is unreliable once holes are introduced.
		local n = 0
		for k in raw do
			if type(k) == "number" and k > n and k == math.floor(k) and k >= 1 then
				n = k
			end
		end

		local bufs = table.create(n)
		local len = 4
		local count = 0

		for i = 1, n do
			local value = raw[i]
			local b, size

			if value == nil then
				-- Hole marker: single byte, preserves array position.
				b = buffer.create(1)
				buffer.writeu8(b, 0, 0x01)
				size = 1
			else
				local valueTypeName = resolveTypeName(value)
				local typeId = Attribute_Type_Ids[valueTypeName]
				local descriptor = Attribute_Encoders[valueTypeName]
				if not descriptor then
					continue
				end
				local dataBuf, dataSize = descriptor(value)

				b = buffer.create(1 + dataSize)
				buffer.writeu8(b, 0, typeId)
				buffer.copy(b, 1, dataBuf)
				size = 1 + dataSize
			end

			count += 1
			bufs[count] = b
			len += size
		end

		local b = buffer.create(len)
		buffer.writeu32(b, 0, count)

		local offset = 4
		for i = 1, count do
			local bb = bufs[i]
			buffer.copy(b, offset, bb)
			offset += buffer.len(bb)
		end

		return b, len
	end,
	["ValueTable"] = function(raw)
		local keys = {}
		local keyMap = {}
		local n = 0

		for k in raw do
			n += 1
			local keyStr = tostring(k)
			keys[n] = keyStr
			keyMap[keyStr] = k
		end

		table.sort(keys)

		local bufs = table.create(n)
		local len = 4
		local count = 0

		for i = 1, n do
			local keyStr = keys[i]
			local value = raw[keyMap[keyStr]]

			local valueTypeName = resolveTypeName(value)
			local typeId = Attribute_Type_Ids[valueTypeName]
			local descriptor = Attribute_Encoders[valueTypeName]
			if not descriptor then
				continue
			end
			local dataBuf, dataSize = descriptor(value)

			local keyLen = #keyStr
			local size = 4 + keyLen + 1 + dataSize
			local b = buffer.create(size)

			buffer.writeu32(b, 0, keyLen)
			buffer.writestring(b, 4, keyStr)
			buffer.writeu8(b, 4 + keyLen, typeId)
			buffer.copy(b, 4 + keyLen + 1, dataBuf)

			count += 1
			bufs[count] = b
			len += size
		end

		local b = buffer.create(len)
		buffer.writeu32(b, 0, count)

		local offset = 4
		for i = 1, count do
			local bb = bufs[i]
			buffer.copy(b, offset, bb)
			offset += buffer.len(bb)
		end

		return b, len
	end,
	["UDim"] = function(raw)
		local b = buffer.create(8)

		buffer.writef32(b, 0, raw.Scale)
		buffer.writei32(b, 4, raw.Offset)

		return b, 8
	end,
	["UDim2"] = function(raw)
		return Attribute_Encoders._packMultiple(Attribute_Encoders["UDim"], raw.X, raw.Y)
	end,
	["Ray"] = function(raw)
		return Attribute_Encoders._packMultiple(Attribute_Encoders["Vector3"], raw.Origin, raw.Direction)
	end,
	["Faces"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, countBits(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front))

		return b, 4
	end,
	["Axes"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, countBits(raw.X, raw.Y, raw.Z))

		return b, 4
	end,
	["BrickColor"] = function(raw)
		local b = buffer.create(4)

		buffer.writeu32(b, 0, raw.Number)

		return b, 4
	end,
	["Color3"] = function(raw)
		return Attribute_Encoders._packF32(raw.R, raw.G, raw.B)
	end,
	["Vector2"] = function(raw)
		return Attribute_Encoders._packF32(raw.X, raw.Y)
	end,
	["Vector3"] = function(raw)
		return Attribute_Encoders._packF32(raw.X, raw.Y, raw.Z)
	end,
	["Vector2int16"] = function(raw)
		return Attribute_Encoders._packI16(raw.X, raw.Y)
	end,
	["Vector3int16"] = function(raw)
		return Attribute_Encoders._packI16(raw.X, raw.Y, raw.Z)
	end,
	["CFrame"] = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()

		local rotation_ID = CFrame_Rotation_Ids[rawBasisString(R00, R01, R02, R10, R11, R12, R20, R21, R22)]

		local len = rotation_ID and 13 or 49
		local b = buffer.create(len)

		local _packF32 = Attribute_Encoders._packF32
		local position = _packF32(X, Y, Z)
		buffer.copy(b, 0, position)

		if rotation_ID then
			buffer.writeu8(b, 12, rotation_ID)
		else
			buffer.writeu8(b, 12, 0x0)

			local xBasis = _packF32(R00, R01, R02)
			buffer.copy(b, 13, xBasis)
			local yBasis = _packF32(R10, R11, R12)
			buffer.copy(b, 13 + 12, yBasis)
			local zBasis = _packF32(R20, R21, R22)
			buffer.copy(b, 13 + 24, zBasis)
		end

		return b, len
	end,
	["EnumItem"] = function(raw)
		local nameBuf, nameSize = Attribute_Encoders["string"](tostring(raw.EnumType))

		local len = nameSize + 4
		local b = buffer.create(len)

		buffer.copy(b, 0, nameBuf)
		buffer.writeu32(b, nameSize, raw.Value)

		return b, len
	end,
	["NumberSequence"] = nil,
	["NumberSequenceKeypoint"] = function(keypoint, b, offset)
		if not b then
			return Attribute_Encoders._packF32(keypoint.Envelope, keypoint.Time, keypoint.Value)
		end

		buffer.writef32(b, offset, keypoint.Envelope)
		offset += 4
		buffer.writef32(b, offset, keypoint.Time)
		offset += 4
		buffer.writef32(b, offset, keypoint.Value)
	end,
	["ColorSequence"] = nil,
	["ColorSequenceKeypoint"] = function(keypoint, b, offset)
		local value = Attribute_Encoders["Color3"](keypoint.Value)

		if not b then
			b = buffer.create(20)
			offset = 0
		end

		buffer.writef32(b, offset, 0)
		offset += 4
		buffer.writef32(b, offset, keypoint.Time)
		offset += 4
		buffer.copy(b, offset, value)

		return b, 20
	end,
	["NumberRange"] = function(raw)
		return Attribute_Encoders._packF32(raw.Min, raw.Max)
	end,
	["Rect"] = function(raw)
		return Attribute_Encoders._packMultiple(Attribute_Encoders["Vector2"], raw.Min, raw.Max)
	end,
	["PhysicalProperties"] = function(raw)
		local b = buffer.create(25)

		-- rbxl uses flag 0-3, meanwhile attributes use 1 as it's always set; can keep 3 for compatibility with both
		-- * PhysicalProperties.new(0,0,0).AcousticAbsorption could be used as default value to compare AcousticAbsorption against
		buffer.writeu8(b, 0, 1)

		buffer.writef32(b, 1, raw.Density)
		buffer.writef32(b, 5, raw.Friction)
		buffer.writef32(b, 9, raw.Elasticity)
		buffer.writef32(b, 13, raw.FrictionWeight)
		buffer.writef32(b, 17, raw.ElasticityWeight)
		buffer.writef32(b, 21, raw.AcousticAbsorption)

		return b, 25
	end,
	["Color3uint8"] = function(raw)
		local b = buffer.create(3)

		buffer.writeu8(b, 0, math.floor(raw.R * 255))
		buffer.writeu8(b, 1, math.floor(raw.G * 255))
		buffer.writeu8(b, 2, math.floor(raw.B * 255))

		return b, 3
	end,
	["Region3"] = function(raw)
		local Translation = raw.CFrame.Position
		local HalfSize = raw.Size * 0.5

		return Attribute_Encoders._packMultiple(
			Attribute_Encoders["Vector3"],
			Translation - HalfSize,
			Translation + HalfSize
		)
	end,
	["Region3int16"] = function(raw)
		return Attribute_Encoders._packMultiple(Attribute_Encoders["Vector3int16"], raw.Min, raw.Max)
	end,
	["Font"] = function(raw)
		local encoder = Attribute_Encoders["string"]

		local familyBuf, familySize = encoder(raw.Family)
		local faceIdBuf, faceIdSize = encoder("")

		local len = 3 + familySize + faceIdSize
		local b = buffer.create(len)

		local hasWeight, weight = pcall(index, raw, "Weight")
		local hasStyle, style = pcall(index, raw, "Style")

		buffer.writeu16(b, 0, hasWeight and weight.Value or 0)
		buffer.writeu8(b, 2, hasStyle and style.Value or 0)

		buffer.copy(b, 3, familyBuf)
		buffer.copy(b, 3 + familySize, faceIdBuf)

		return b, len
	end,
	["SecurityCapabilities"] = function(raw)
		local b = buffer.create(8)

		if raw == BASE_CAPABILITIES then
			return b, 8
		end

		Attribute_Encoders._writeI64LE(b, 0, capabilityNumber(raw))

		return b, 8
	end,
	["Path2DControlPoint"] = function(raw)
		return Attribute_Encoders._packMultiple(
			Attribute_Encoders["UDim2"],
			raw.Position,
			raw.LeftTangent,
			raw.RightTangent
		)
	end,
	-- ["Path3DControlPoint"] = function(raw)
	-- 	return Binary_Encoders._packMultiple(
	-- 		Binary_Encoders["Vector3"],
	-- 		raw.Position,
	-- 		raw.LeftTangent,
	-- 		raw.RightTangent
	-- 	)
	-- end,
	["TweenInfo"] = function(raw)
		local b = buffer.create(21)

		buffer.writef32(b, 0, raw.Time)
		buffer.writef32(b, 4, raw.DelayTime)
		buffer.writei32(b, 8, raw.RepeatCount)
		buffer.writeu32(b, 12, raw.EasingStyle.Value)
		buffer.writeu32(b, 16, raw.EasingDirection.Value)
		buffer.writeu8(b, 20, raw.Reverses and 1 or 0)

		return b, 21
	end,
}

do -- Sequences
	Attribute_Encoders["NumberSequence"] =
		Attribute_Encoders._makeSequence(Attribute_Encoders["NumberSequenceKeypoint"], 12)

	Attribute_Encoders["ColorSequence"] =
		Attribute_Encoders._makeSequence(Attribute_Encoders["ColorSequenceKeypoint"], 20)
end

do -- Vectors
	Attribute_Encoders._packF32 = Attribute_Encoders._makeVectorPacker(buffer.writef32, 4)

	Attribute_Encoders._packI16 = Attribute_Encoders._makeVectorPacker(buffer.writei16, 2)
end

local Binary_Encoders = {
	["string"] = function(sbuf, vals, n)
		for i = 1, n do
			sbuf:writeLenString(vals[i])
		end
	end,
	["bool"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(n)
		for i = 1, n do
			sbuf:pokeu8(base + (i - 1), vals[i] and 1 or 0)
		end
	end,

	["int"] = planeEncoder(zigzag32),
	["float"] = planeEncoder(rotf),

	["double"] = function(sbuf, vals, n)
		for i = 1, n do
			sbuf:writef64(vals[i])
		end
	end,

	["UDim"] = planeEncoder(function(v)
		return rotf(v.Scale)
	end, function(v)
		return zigzag32(v.Offset)
	end),

	["UDim2"] = planeEncoder(function(v)
		return rotf(v.X.Scale)
	end, function(v)
		return rotf(v.Y.Scale)
	end, function(v)
		return zigzag32(v.X.Offset)
	end, function(v)
		return zigzag32(v.Y.Offset)
	end),

	["Ray"] = f32Encoder(function(v)
		return v.Origin.X
	end, function(v)
		return v.Origin.Y
	end, function(v)
		return v.Origin.Z
	end, function(v)
		return v.Direction.X
	end, function(v)
		return v.Direction.Y
	end, function(v)
		return v.Direction.Z
	end),

	["Faces"] = flagEncoder({ Right = 1, Top = 2, Back = 4, Left = 8, Bottom = 16, Front = 32 }),
	["Axes"] = flagEncoder({ X = 1, Y = 2, Z = 4 }),

	["BrickColor"] = planeEncoder(function(v)
		return v.Number
	end),

	["Color3"] = planeEncoder(function(v)
		return rotf(v.R)
	end, function(v)
		return rotf(v.G)
	end, function(v)
		return rotf(v.B)
	end),
	["Vector2"] = planeEncoder(function(v)
		return rotf(v.X)
	end, function(v)
		return rotf(v.Y)
	end),
	["Vector3"] = planeEncoder(function(v)
		return rotf(v.X)
	end, function(v)
		return rotf(v.Y)
	end, function(v)
		return rotf(v.Z)
	end),
	["Vector2int16"] = i16Encoder("X", "Y"),

	["CFrame"] = function(sbuf, vals, n)
		writeCFrameBody(sbuf, vals, n, nil)
	end,

	["Enum"] = planeEncoder(function(v)
		return v.Value
	end),

	["Referent"] = function(sbuf, vals, n, refs)
		writeRefPlane(sbuf, n, sbuf:allocRegion(4 * n), function(i)
			local val = vals[i]
			return (val and refs[val]) or -1
		end)
	end,

	["Vector3int16"] = i16Encoder("X", "Y", "Z"),

	["NumberSequence"] = sequenceEncoder(function(sbuf, kp)
		sbuf:writef32(kp.Time)
		sbuf:writef32(kp.Value)
		sbuf:writef32(kp.Envelope)
	end),
	["ColorSequence"] = sequenceEncoder(function(sbuf, kp)
		local c = kp.Value
		sbuf:writef32(kp.Time)
		sbuf:writef32(c.R)
		sbuf:writef32(c.G)
		sbuf:writef32(c.B)
		sbuf:writef32(0) -- envelope, unused for ColorSequence, always 0
	end),

	["NumberRange"] = f32Encoder(function(v)
		return v.Min
	end, function(v)
		return v.Max
	end),

	["Rect"] = planeEncoder(function(v)
		return rotf(v.Min.X)
	end, function(v)
		return rotf(v.Min.Y)
	end, function(v)
		return rotf(v.Max.X)
	end, function(v)
		return rotf(v.Max.Y)
	end),

	["PhysicalProperties"] = function(sbuf, vals, n)
		for i = 1, n do
			local val = vals[i]
			if val then
				sbuf:writeu8(3)
				sbuf:writef32(val.Density)
				sbuf:writef32(val.Friction)
				sbuf:writef32(val.Elasticity)
				sbuf:writef32(val.FrictionWeight)
				sbuf:writef32(val.ElasticityWeight)
				sbuf:writef32(val.AcousticAbsorption)
			else
				sbuf:writeu8(0)
			end
		end
	end,

	["Color3uint8"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(3 * n)
		for i = 1, n do
			local val = vals[i]
			sbuf:pokeu8(base + (i - 1), math.floor(val.R * 255 + 0.5))
			sbuf:pokeu8(base + n + (i - 1), math.floor(val.G * 255 + 0.5))
			sbuf:pokeu8(base + 2 * n + (i - 1), math.floor(val.B * 255 + 0.5))
		end
	end,

	["int64"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(8 * n)
		for i = 1, n do
			pokeU64Planes(sbuf, base + (i - 1), n, zigzag64(vals[i]))
		end
	end,

	["SharedString"] = function(sbuf, vals, n, sstr)
		local base = sbuf:allocRegion(4 * n)
		interleavedU32Plane(sbuf, n, base, function(i)
			local content = vals[i]

			local index = sstr.hashes[content]
			if not index then
				index = sstr.count
				sstr.hashes[content] = index
				sstr.count += 1
				sstr.order[index + 1] = content
			end
			return index
		end)
	end,

	["OptionalCoordinateFrame"] = function(sbuf, vals, n)
		local exists = table.create(n)

		sbuf:writeu8(0x10) -- Type_Ids.CFrame
		writeCFrameBody(sbuf, vals, n, exists)

		sbuf:writeu8(0x02) -- Type_Ids.bool
		local boolBase = sbuf:allocRegion(n)
		for i = 1, n do
			sbuf:pokeu8(boolBase + (i - 1), exists[i] and 1 or 0)
		end
	end,
	["UniqueId"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(16 * n)

		for i = 1, n do
			local val = vals[i]
			local o = base + (i - 1)
			local hex = string.gsub(val, "%-", "")
			local randHi, randLo = zigzagHalves(u32FromHex(hex, 1), u32FromHex(hex, 9))

			pokeU32Planes(sbuf, o, n, u32FromHex(hex, 25))
			pokeU32Planes(sbuf, o + 4 * n, n, u32FromHex(hex, 17))
			pokeU32Planes(sbuf, o + 8 * n, n, randHi)
			pokeU32Planes(sbuf, o + 12 * n, n, randLo)
		end
	end,
	["Font"] = function(sbuf, vals, n)
		for i = 1, n do
			local val = vals[i]

			local hasWeight, weight = pcall(index, val, "Weight")
			local hasStyle, style = pcall(index, val, "Style")

			sbuf:writeLenString(val.Family)
			sbuf:writeu16(hasWeight and weight.Value or 0)
			sbuf:writeu8(hasStyle and style.Value or 0)
			sbuf:writeu32(0) -- CachedFaceId can't be indexed
		end
	end,
	["SecurityCapabilities"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(8 * n)
		for i = 1, n do
			local lo, hi = capabilityHalves(vals[i])
			pokeU64Planes(sbuf, base + (i - 1), n, zigzagHalves(hi, lo))
		end
	end,
	["Content"] = function(sbuf, vals, n, refs)
		local uris, objectRefs = {}, {}

		local base = sbuf:allocRegion(4 * n)
		interleavedU32Plane(sbuf, n, base, function(i)
			local v = vals[i]
			if v == nil then
				return 0
			end
			local st = v.SourceType
			if st == Enum.ContentSourceType.Uri then
				table.insert(uris, v.Uri or "")
				return zigzag32(1)
			elseif st == Enum.ContentSourceType.Object then
				table.insert(objectRefs, v.Object)
				return zigzag32(2)
			end
			return 0
		end)

		sbuf:writeu32(#uris)
		for _, uri in uris do
			sbuf:writeLenString(uri)
		end

		local m = #objectRefs
		sbuf:writeu32(m)
		if m > 0 then
			writeRefPlane(sbuf, m, sbuf:allocRegion(4 * m), function(i)
				return (refs and refs[objectRefs[i]]) or -1
			end)
		end

		sbuf:writeu32(0) -- ExternalObjectCount
	end,
}

for datatype, sameAs in
	{
		["NetAssetRef"] = "SharedString",
		["ContentId"] = "string",
		["BinaryString"] = "string",
		["ProtectedString"] = "string",
	}
do
	Type_Ids[datatype] = Type_Ids[sameAs]
	Binary_Encoders[datatype] = Binary_Encoders[sameAs]
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

local XML_Encoders
XML_Encoders = {
	_cdata = function(raw) -- ? Normally Roblox doesn't use CDATA unless the string has newline characters (\n); We rather CDATA everything for sake of speed
		return "<![CDATA[" .. raw .. "]]>"
	end,
	_normalizeNumber = function(raw)
		if raw ~= raw then
			return "NAN"
		elseif raw == math.huge then
			return "INF"
		elseif raw == -math.huge then
			return "-INF"
		end

		return raw
	end,
	_normalizeRange = function(raw)
		return raw ~= raw and "0" or raw -- Normally we should return "-nan(ind)" instead of "0" but this adds more compatibility
	end,
	_minMax = function(min, max, encoder)
		return "<min>" .. encoder(min) .. "</min><max>" .. encoder(max) .. "</max>"
	end,
	_makeSequence = function(keypoint_handler)
		-- tostring(raw) also works (but way slower rn)
		-- ? Trailing whitespace after Envelope is needed for lune compatibility
		return function(raw)
			local sequence = ""

			for _, keypoint in raw.Keypoints do
				sequence ..= keypoint_handler(keypoint)
			end

			return sequence
		end
	end,
	_vector = function(X, Y, Z)
		local Value = "<X>" .. X .. "</X><Y>" .. Y .. "</Y>"

		if Z then
			Value ..= "<Z>" .. Z .. "</Z>"
		end

		return Value
	end,
	--------------------------------------------------------------
	--------------------------------------------------------------
	--------------------------------------------------------------
	Axes = function(raw)
		return "<axes>" .. countBits(raw.X, raw.Y, raw.Z) .. "</axes>"
	end,

	BinaryString = function(raw) -- ! only add raw == nil if such edge-case exists (note it)
		return raw == "" and "" or base64encode(raw)
	end,

	BrickColor = function(raw)
		return raw.Number -- * Roblox encodes the tags as "int", but this is not required for Roblox to properly decode the type. For better compatibility, it is preferred that third-party implementations encode and decode "BrickColor" tags instead. Could also use "int" or "Color3uint8"
	end,
	CFrame = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		return XML_Encoders._vector(X, Y, Z)
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
		return "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>"
	end,
	Color3uint8 = function(raw)
		return 0xFF000000
			+ (math.floor(raw.R * 255) * 0x10000)
			+ (math.floor(raw.G * 255) * 0x100)
			+ math.floor(raw.B * 255)
	end,
	ColorSequence = nil,
	ColorSequenceKeypoint = function(keypoint)
		local _normalizeRange = XML_Encoders._normalizeRange

		local color3 = keypoint.Value

		return _normalizeRange(keypoint.Time)
			.. " "
			.. _normalizeRange(color3.R)
			.. " "
			.. _normalizeRange(color3.G)
			.. " "
			.. _normalizeRange(color3.B)
			.. " 0 "
	end,
	Content = function(raw) -- TODO Not sure about Object & Opaque, run tests when possible
		-- * Currently the only way to tell which properties serialize (CanSave & CanLoad don't help here) is either API-2 dump or ReflectionService
		local SourceType = raw.SourceType
		return SourceType == Enum.ContentSourceType.None and "<null></null>"
			or SourceType == Enum.ContentSourceType.Uri and "<uri>" .. XML_Encoders.string(raw.Uri) .. "</uri>"
			or SourceType == Enum.ContentSourceType.Object and "<Ref>" .. getRef(raw.Object) .. "</Ref>"
		-- or SourceType == Enum.ContentSourceType.Opaque and "<Ref>" .. GetRef(raw.Opaque) .. "</Ref>"
	end,
	ContentId = function(raw) -- ! only add raw == nil if such edge-case exists (note it)
		return raw == "" and "<null></null>" or "<url>" .. XML_Encoders.string(raw) .. "</url>", "Content"
	end,
	CoordinateFrame = function(raw)
		return "<CFrame>" .. XML_Encoders.CFrame(raw) .. "</CFrame>"
	end,
	-- DateTime = function(raw) return raw.UnixTimestampMillis end, -- ? Doesn't have serializer
	EnumItem = function(raw)
		return raw.Value, "token"
	end,
	Faces = function(raw)
		-- The text of this element is formatted as an integer between 0 and 63
		return "<faces>" .. countBits(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front) .. "</faces>"
	end,
	Font = function(raw)
		-- TODO (OPTIONAL ELEMENT): Figure out how to determine (ContentId) <CachedFaceId><url>rbxasset://fonts/GothamSSm-Medium.otf</url></CachedFaceId>
		--[[
		? game:GetService("TextService"):GetFontMemoryData()
		? rbxasset://fonts/families/{Enum.Font.BuilderSans.Name}.json
		]]

		local hasWeight, weight = pcall(index, raw, "Weight")
		local hasStyle, style = pcall(index, raw, "Style")

		return "<Family>"
			.. XML_Encoders.ContentId(raw.Family)
			.. "</Family><Weight>"
			.. (hasWeight and XML_Encoders.EnumItem(weight) or "")
			.. "</Weight><Style>"
			.. (hasStyle and style.Name or "") -- Weird but this field accepts .Name of enum instead..
			.. "</Style>"
	end,
	NetAssetRef = nil,
	NumberRange = function(raw) -- tostring(raw) also works
		local _normalizeRange = XML_Encoders._normalizeRange

		return _normalizeRange(raw.Min) .. " " .. _normalizeRange(raw.Max) --[[.. " "]] -- ! This might be required for compatibility; _normalizeRange  is not needed here but it fixes the issue where "nan 10" value would reset to "0 0"
	end,
	NumberSequence = nil,
	NumberSequenceKeypoint = function(keypoint)
		local _normalizeRange = XML_Encoders._normalizeRange

		return _normalizeRange(keypoint.Time)
			.. " "
			.. _normalizeRange(keypoint.Value)
			.. " "
			.. _normalizeRange(keypoint.Envelope)
			.. " "
	end,

	PhysicalProperties = function(raw)
		local CustomPhysics = "<CustomPhysics>" .. XML_Encoders.bool(raw and true or false) .. "</CustomPhysics>"

		return raw
				and CustomPhysics .. "<Density>" .. raw.Density .. "</Density><Friction>" .. raw.Friction .. "</Friction><Elasticity>" .. raw.Elasticity .. "</Elasticity><FrictionWeight>" .. raw.FrictionWeight .. "</FrictionWeight><ElasticityWeight>" .. raw.ElasticityWeight .. "</ElasticityWeight><AcousticAbsorption>" .. raw.AcousticAbsorption .. "</AcousticAbsorption>"
			or CustomPhysics
	end,
	ProtectedString = function(raw)
		return string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES) or XML_Encoders._cdata(raw)
	end,
	Ray = function(raw)
		local vector3 = XML_Encoders.Vector3

		return "<origin>" .. vector3(raw.Origin) .. "</origin><direction>" .. vector3(raw.Direction) .. "</direction>"
	end,
	Rect = function(raw)
		return XML_Encoders._minMax(raw.Min, raw.Max, XML_Encoders.Vector2), "Rect2D"
	end,
	Region3 = function(raw) -- ? Doesn't have serializer, the math is correct though
		local Translation = raw.CFrame.Position
		local HalfSize = raw.Size * 0.5

		return XML_Encoders._minMax(Translation - HalfSize, Translation + HalfSize, XML_Encoders.Vector3)
	end,
	Region3int16 = function(raw)
		return XML_Encoders._minMax(raw.Min, raw.Max, XML_Encoders.Vector3int16)
	end,

	SharedString = function(raw)
		return sharedStrings[XML_Encoders.BinaryString(raw)]
	end,
	SecurityCapabilities = function(raw)
		if raw == BASE_CAPABILITIES then
			return 0
		end

		return capabilityNumber(raw)
	end,

	TweenInfo = function(raw)
		local _normalizeNumber = XML_Encoders._normalizeNumber
		return "Time:"
			.. _normalizeNumber(raw.Time)
			.. " DelayTime:"
			.. _normalizeNumber(raw.DelayTime)
			.. " RepeatCount:"
			.. _normalizeNumber(raw.RepeatCount)
			.. " Reverses:"
			.. (raw.Reverses and "True" or "False")
			.. " EasingDirection:"
			.. raw.EasingDirection.Name
			.. " EasingStyle:"
			.. raw.EasingStyle.Name
	end,
	UDim = function(raw)
		return "<S>" .. raw.Scale .. "</S><O>" .. raw.Offset .. "</O>"
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
			.. "</YO>"
	end,

	UniqueId = function(raw) --  Roblox Staff: It actually doesn’t have a value assigned outside of Roblox Studio and Open Cloud execution. UniqueIdLookupService
		-- 	--[[
		-- 		UniqueId properties might be random everytime Studio saves a place file
		-- 		and don't have a use right now outside of packages, which SSI doesn't
		-- 		account for anyway. They generate diff noise, so we shouldn't serialize
		-- 		them until we have to.
		-- 	]]
		-- 	-- https://github.com/MaximumADHD/Roblox-Client-Tracker/blob/master/LuaPackages/Packages/_Index/ApolloClient/ApolloClient/utilities/common/makeUniqueId.lua#L68
		return string.gsub(raw, "-", "") -- seems to be string type by default
	end,

	Vector2 = function(raw)
		return XML_Encoders._vector(raw.X, raw.Y)
	end,
	Vector2int16 = nil,
	Vector3 = function(raw)
		return XML_Encoders._vector(raw.X, raw.Y, raw.Z)
	end,
	Vector3int16 = nil,
	bool = function(raw)
		return raw and "true" or "false"
	end,
	double = nil, -- Float64
	float = nil, -- Float32
	int = nil, -- Int32
	int64 = nil, -- Int64 (long)
	string = function(raw)
		return (raw == nil or raw == "") and ""
			or string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES)
			or XML_Encoders._cdata(string.gsub(raw, "\0", ""))
	end,

	--------------------------------------------------------------
	-----------%localappdata%/Roblox/GlobalSettings_13.xml--------
	-----------------------settings().Studio----------------------
	--------------------------------------------------------------
	-- QDir = function(raw) -- ? Not sure
	-- 	return raw
	-- end,
	-- QFont = function(raw) -- ? Not sure
	-- 	return raw
	-- end,
}

do -- Sequences
	XML_Encoders.NumberSequence = XML_Encoders._makeSequence(XML_Encoders.NumberSequenceKeypoint)

	XML_Encoders.ColorSequence = XML_Encoders._makeSequence(XML_Encoders.ColorSequenceKeypoint)
end

for encoderName, redirectName in
	{
		NetAssetRef = "SharedString",
		Vector2int16 = "Vector2",
		Vector3int16 = "Vector3",
		double = "_normalizeNumber",
		float = "_normalizeNumber",
		int = "_normalizeNumber",
		int64 = "_normalizeNumber",
	}
do
	XML_Encoders[encoderName] = XML_Encoders[redirectName]
end

local ClassList, FetchAPI
local RiskyServicesDisabled = { UGC = false, Encoding = false, Reflection = false }
do
	local ClassPropertyExceptions = arrayToDict({
		Whitelist = {
			MeshPart = { "CollisionFidelity" },
			PartOperation = { "CollisionFidelity" },
			TriangleMeshPart = { "CollisionFidelity" },
		},
		Blacklist = {
			BillboardGui = { "PlayerToHideFrom" },
			LuaSourceContainer = { "ScriptGuid" },
			Instance = { "UniqueId", "HistoryId", "SourceAssetId", "SourceContent" },
		},
	}, true)

	local function AttributesSerialize(attrs, header_bytes)
		-- * There are certain restrictions for names of attributes
		-- https://create.roblox.com/docs/reference/engine/classes/Instance#SetAttribute
		-- But it seems like even if those are present, Studio still opens the file just fine
		-- So there is no need to check for them currently

		local count = 0
		local buffer_size = 4
		local sorted = {}
		local formatted = table.clone(attrs)

		if header_bytes then
			buffer_size += #header_bytes
		end

		for attr, val in attrs do
			local t = resolveTypeName(val)

			local encoder = Attribute_Encoders[t]
			if not encoder then
				continue
			end

			count += 1
			sorted[count] = attr

			local attr_size

			formatted[attr], attr_size = encoder(val)

			buffer_size += 5 + #attr + attr_size
		end

		table.sort(sorted)

		local b = buffer.create(buffer_size)

		local offset = 0

		if header_bytes then
			for _, header_byte in header_bytes do
				buffer.writeu8(b, offset, header_byte)
				offset += 1
			end
		end

		buffer.writeu32(b, offset, count)
		offset += 4

		local stringEncoder = Attribute_Encoders["string"]
		for _, attr in sorted do
			local nameBuf, nameSize = stringEncoder(attr)

			buffer.copy(b, offset, nameBuf)
			offset += nameSize

			buffer.writeu8(b, offset, Attribute_Type_Ids[resolveTypeName(attrs[attr])])
			offset += 1

			local bb = formatted[attr]

			buffer.copy(b, offset, bb)
			offset += buffer.len(bb)
		end

		return buffer.tostring(b)
	end

	local function AttenuationSerialize(attenuations)
		if not next(attenuations) then
			return "\0" -- ? [CONSTANT] Version byte (likely)
		end

		local count = 0

		local sorted = {}

		for key in attenuations do
			count += 1
			sorted[count] = key
		end

		table.sort(sorted)

		local b = buffer.create(1 + count * 8)

		local offset = 1
		for _, key in sorted do
			buffer.writef32(b, offset, key)
			offset += 4
			buffer.writef32(b, offset, attenuations[key])
			offset += 4
		end

		return buffer.tostring(b)
	end

	local function TransformsSerialize(transforms)
		local n = #transforms

		if n == 0 then
			return "\1\0\0\0\0\0\0\0"
		end

		local b = buffer.create(8 + n * 48)

		buffer.writeu32(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
		buffer.writeu32(b, 4, n)

		local _packF32 = Attribute_Encoders._packF32

		local offset = 8
		for _, transform in transforms do
			local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = transform:GetComponents()

			local xBasis = _packF32(R00, R01, R02)
			buffer.copy(b, offset, xBasis)
			offset += 12

			local yBasis = _packF32(R10, R11, R12)
			buffer.copy(b, offset, yBasis)
			offset += 12

			local zBasis = _packF32(R20, R21, R22)
			buffer.copy(b, offset, zBasis)
			offset += 12

			local position = _packF32(X, Y, Z)
			buffer.copy(b, offset, position)
			offset += 12
		end

		return buffer.tostring(b)
	end

	local function ServiceVisibilitySerialize(wantVisible)
		local ExplorerServiceVisibilityService = game:GetService("ExplorerServiceVisibilityService")
		local stringEncoder = Attribute_Encoders["string"]
		local typeId = Attribute_Type_Ids["string"]

		local count = 0
		local buffer_size = 4
		local names = {}
		local formatted = {}

		for _, service in game:GetChildren() do
			if ExplorerServiceVisibilityService:GetServiceVisibility(service) == wantVisible then
				local name = service.ClassName
				local buf, size = stringEncoder(name)

				count += 1
				names[count] = name
				formatted[name] = buf

				buffer_size += 1 + size
			end
		end

		if count == 0 then
			return "\0\0\0\0"
		end

		table.sort(names)

		local b = buffer.create(buffer_size)
		buffer.writeu32(b, 0, count)

		local offset = 4
		for _, name in names do
			buffer.writeu8(b, offset, typeId)
			offset += 1

			local bb = formatted[name]
			buffer.copy(b, offset, bb)
			offset += buffer.len(bb)
		end

		return buffer.tostring(b)
	end

	local function encodeTimeTicks(time)
		local scaled = time * 2400
		if not (scaled >= -2147483648 and scaled < 2147483648) then
			return -2147483648
		end
		return math.round(scaled)
	end

	local function writeTimesSection(b, offset, keys)
		buffer.writeu32(b, offset, 1)
		offset += 4
		buffer.writeu32(b, offset, #keys)
		offset += 4
		for _, key in keys do
			buffer.writei32(b, offset, encodeTimeTicks(key.Time))
			offset += 4
		end
		return offset
	end

	local function deriveTangentValueCurve(keys, i)
		local key = keys[i]
		local isFirst = (i == 1)
		local isLast = (i == #keys)
		if isLast then
			return 0, 0
		end
		if key.Interpolation == Enum.KeyInterpolationMode.Constant then
			return 0, 0
		end
		if key.Interpolation == Enum.KeyInterpolationMode.Linear then
			local nextKey = keys[i + 1]
			local t = 1 / (nextKey.Time - key.Time)
			return t, t
		end
		if isFirst then
			return 0, 0
		end
		local prevKey = keys[i - 1]
		local deltaPrev = key.Time - prevKey.Time
		if prevKey.Interpolation == Enum.KeyInterpolationMode.Constant then
			return 0, 0
		elseif prevKey.Interpolation == Enum.KeyInterpolationMode.Linear then
			local t = 1 / deltaPrev
			return t, t
		else
			local nextKey = keys[i + 1]
			local deltaNext = nextKey.Time - key.Time
			local t = (1 / deltaPrev + 1 / deltaNext) / 2
			return t, t
		end
	end

	local function deriveTangentFloatCurve(keys, i)
		local key = keys[i]
		local isFirst = (i == 1)
		local isLast = (i == #keys)
		if isLast then
			return 0, 0
		end
		if key.Interpolation == Enum.KeyInterpolationMode.Constant then
			return 0, 0
		end
		if key.Interpolation == Enum.KeyInterpolationMode.Linear then
			local nextKey = keys[i + 1]
			local slope = (nextKey.Value - key.Value) / (nextKey.Time - key.Time)
			return slope, slope
		end
		if isFirst then
			return 0, 0
		end
		local prevKey = keys[i - 1]
		if prevKey.Interpolation == Enum.KeyInterpolationMode.Constant then
			return 0, 0
		elseif prevKey.Interpolation == Enum.KeyInterpolationMode.Linear then
			local slope = (key.Value - prevKey.Value) / (key.Time - prevKey.Time)
			return slope, slope
		else
			return 0, 0
		end
	end

	local function encodeGuid(uid)
		local cleanGuid = string.gsub(uid, "[{}-]", "")
		local bytes = buffer.create(16)

		for i = 0, 15 do
			local hexByte = string.sub(cleanGuid, (i * 2) + 1, (i * 2) + 2)
			local val = tonumber(hexByte, 16) or 0
			buffer.writeu8(bytes, i, val)
		end

		return buffer.tostring(bytes)
	end

	--[[
		For more info:
		- https://github.com/luau/UniversalSynSaveInstance/blob/main/Tools/NotScriptable-Related/Potentially%20Missing%20Properties%20Dumper/Potentially%20Missing%20Properties%20Dumper.luau
		- https://github.com/luau/UniversalSynSaveInstance/blob/main/Tools/NotScriptable-Related/NotScriptable%20Dumper/NotScriptable%20Dumper.py
		]]
	local NotScriptableFixes = {
		Instance = {
			AttributesSerialize = function(instance)
				local attrs = instance:GetAttributes()

				if not next(attrs) then
					return ""
				end

				return AttributesSerialize(attrs)
			end,
			DefinesCapabilities = "Sandboxed",
			Tags = function(instance)
				local tags = service.CollectionService:GetTags(instance) -- ? Seems faster than instance:GetTags

				if #tags == 0 then
					return ""
				end

				return table.concat(tags, "\0")
			end,
			-- SerializedOverrides = function(instance) -- Unused in live games?
			-- 	local datamodeldiff = game:GetService("PackageService"):GetOverrides(instance) -- Doesn't exist in live games
			-- 	local identities = datamodeldiff:GetIdentities()

			-- 	local resolved = {}
			-- 	for _, identity in identities do
			-- 		local uidBytes = encodeGuid(identity:ResolveInstance(instance).UniqueId) -- tostring could be used on identity instead but is slower
			-- 		local changeType = datamodeldiff:GetChangeType(identity)
			-- 		local props = datamodeldiff:GetPropertyNames(identity)
			-- 		table.sort(props)
			-- 		table.insert(resolved, {
			-- 			uidBytes = uidBytes,
			-- 			changeType = changeType,
			-- 			props = props,
			-- 		})
			-- 	end

			-- 	table.sort(resolved, function(a, b)
			-- 		return a.uidBytes < b.uidBytes
			-- 	end)

			-- 	local recordBlobs = {}
			-- 	local totalSize = 10

			-- 	for _, entry in resolved do
			-- 		local props = entry.props
			-- 		local bodySize = 20
			-- 		for _, p in props do
			-- 			bodySize += 1 + #p
			-- 		end

			-- 		local record = buffer.create(1 + bodySize)
			-- 		buffer.writeu8(record, 0, bodySize)
			-- 		buffer.writeu8(record, 1, 1)
			-- 		buffer.writestring(record, 2, entry.uidBytes)
			-- 		buffer.writeu8(record, 18, entry.changeType.Value)
			-- 		buffer.writeu8(record, 19, 0)
			-- 		buffer.writeu8(record, 20, #props)

			-- 		local offset = 21
			-- 		for _, p in props do
			-- 			buffer.writeu8(record, offset, #p)
			-- 			buffer.writestring(record, offset + 1, p)
			-- 			offset += 1 + #p
			-- 		end

			-- 		table.insert(recordBlobs, record)
			-- 		totalSize += buffer.len(record)
			-- 	end

			-- 	local out = buffer.create(totalSize)
			-- 	buffer.writestring(out, 0, "RDFF")
			-- 	buffer.writeu32(out, 4, 1)
			-- 	buffer.writeu8(out, 8, 0)
			-- 	buffer.writeu8(out, 9, #resolved)

			-- 	local pos = 10
			-- 	for _, record in recordBlobs do
			-- 		buffer.copy(out, pos, record)
			-- 		pos += buffer.len(record)
			-- 	end

			-- 	return buffer.tostring(out)
			-- end,
		},
		Path2D = {
			PropertiesSerialize = function(instance)
				local control_points = instance:GetControlPoints()
				local n = #control_points

				if n == 0 then
					return "\0\0\0\0"
				end

				local b = buffer.create(4 + n * 49)
				buffer.writeu32(b, 0, n)

				local typeId = Attribute_Type_Ids["Path2DControlPoint"]
				local encoder = Attribute_Encoders["Path2DControlPoint"]

				local offset = 4
				for i, point in control_points do
					local buf, bufSize = encoder(point)

					buffer.writeu8(b, offset, typeId)
					offset += 1

					buffer.copy(b, offset, buf)
					offset += bufSize
				end

				return buffer.tostring(b)
			end,
		},
		-- Path3D = {
		-- 	PropertiesSerialize = function(instance) -- ? Not sure & doesn't exist (yet?)
		-- 		local control_points = instance:GetControlPoints()
		-- 		local n = #control_points

		-- 		if n == 0 then
		-- 			return "\0\0\0\0"
		-- 		end

		-- 		local b = buffer.create(4 + n * 49)
		-- 		buffer.writeu32(b, 0, n)

		-- 		local typeId = Attribute_Type_Ids["Path3DControlPoint"]
		-- 		local encoder = Binary_Encoders["Path3DControlPoint"]

		-- 		local offset = 4
		-- 		for i, point in control_points do
		-- 			local buf,bufSize = encoder(point)

		-- 			buffer.writeu8(b, offset, typeId)
		-- 			offset += 1

		-- 			buffer.copy(b, offset, buf)
		-- 			offset += bufSize
		-- 		end

		-- 		return buffer.tostring(b)
		-- 	end,
		-- },
		PlayerEmulatorService = {
			SerializedEmulatedPolicyInfo = function(instance)
				local EmulatedPolicyInfo = instance:GetEmulatedPolicyInfo()

				if not next(EmulatedPolicyInfo) then
					return ""
				end

				return AttributesSerialize(EmulatedPolicyInfo)
			end,
		},
		StyleRule = {
			PropertiesSerialize = function(instance)
				local props = instance:GetProperties()

				if not next(props) then
					return "\0\0\0\0"
				end

				return AttributesSerialize(props)
			end,
			PropertyTransitionsSerialize = function(instance)
				local transitions = instance:GetPropertyTransitions()

				if not next(transitions) then
					return "\2\0\0\0\0\0"
				end

				return AttributesSerialize(transitions, { 0x02, 0x00 })
			end,
		},
		StyleQuery = {
			ConditionsSerialize = function(instance)
				local props = instance:GetConditions()

				if not next(props) then
					return "\0\0\0\0"
				end

				return AttributesSerialize(props)
			end,
		},
		FloatCurve = {
			ValuesAndTimes = function(instance)
				-- HapticEffect.WaveformData also has identical format but there's no GetKeys method, only Set
				local keys = instance:GetKeys()

				if #keys == 0 then
					return "\2\0\0\0\0\0\0\0\1\0\0\0\0\0\0\0"
				end

				local valuesPayloadSize = #keys * 14
				local b = buffer.create(8 + valuesPayloadSize + 8 + (#keys * 4))

				buffer.writeu32(b, 0, 2)
				buffer.writeu32(b, 4, #keys)

				local offset = 8
				for i, key in keys do
					local lt, rt = key.LeftTangent, key.RightTangent
					local mode = countBits(lt, rt)

					if mode == 0 then
						lt, rt = deriveTangentFloatCurve(keys, i)
					elseif mode == 1 then
						rt = lt
					elseif mode == 2 then
						lt = rt
					end

					buffer.writeu8(b, offset, key.Interpolation.Value) -- ! assumes this is tied to Enum order
					offset += 1
					buffer.writeu8(b, offset, mode)
					offset += 1
					buffer.writef32(b, offset, key.Value)
					offset += 4
					buffer.writef32(b, offset, lt)
					offset += 4
					buffer.writef32(b, offset, rt)
					offset += 4
				end

				offset = writeTimesSection(b, offset, keys)

				return buffer.tostring(b)
			end,
		},
		RotationCurve = {
			ValuesAndTimes = function(instance)
				local keys = instance:GetKeys()

				if #keys == 0 then
					return "\1\0\0\0\0\0\0\0\1\0\0\0\0\0\0\0"
				end

				local perKeySize = 25
				local b = buffer.create(8 + (#keys * perKeySize) + 8 + (#keys * 4))

				buffer.writeu32(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu32(b, 4, #keys)

				local offset = 8
				for _, key in keys do
					local lt = key.LeftTangent or 0
					local rt = key.RightTangent or 0
					local qx, qy, qz, qw = cframeToQuaternion(key.Value)

					buffer.writeu8(b, offset, 12 + key.Interpolation.Value) -- ! assumes this is tied to Enum order
					offset += 1
					buffer.writef32(b, offset, qx)
					offset += 4
					buffer.writef32(b, offset, qy)
					offset += 4
					buffer.writef32(b, offset, qz)
					offset += 4
					buffer.writef32(b, offset, qw)
					offset += 4
					buffer.writef32(b, offset, lt)
					offset += 4
					buffer.writef32(b, offset, rt)
					offset += 4
				end

				offset = writeTimesSection(b, offset, keys)

				return buffer.tostring(b)
			end,
		},
		ValueCurve = {
			ValuesAndTimes = function(instance)
				local keys = instance:GetKeys()

				if #keys == 0 then
					return "\2\0\0\0\0\0\0\0\1\0\0\0\0\0\0\0"
				end

				local valueTypeName = instance.ValueType -- ! assumes Attr_Type_Ids won't have "Enum" key

				local typeId = Attribute_Type_Ids[valueTypeName]

				if not typeId then
					valueTypeName = resolveTypeName(keys[1].Value) -- Region3int16, EnumItem

					typeId = Attribute_Type_Ids[valueTypeName]
				end

				local encoder = Attribute_Encoders[valueTypeName]

				if not encoder then
					return "\2\0\0\0\0\0\0\0\1\0\0\0\0\0\0\0"
				end

				local n = #keys
				local bufs = table.create(n)
				local sizes = table.create(n)
				local valuesPayloadSize = 0

				for i, key in keys do
					local dataBuf, dataSize = encoder(key.Value)
					bufs[i] = dataBuf
					sizes[i] = dataSize
					valuesPayloadSize += 15 + dataSize
				end

				local b = buffer.create(8 + valuesPayloadSize + 8 + 4 * n)
				buffer.writeu32(b, 0, 2)
				buffer.writeu32(b, 4, n)

				local offset = 8
				for i, key in keys do
					local lt, rt = key.LeftTangent, key.RightTangent
					local dataSize = sizes[i]

					buffer.writeu8(b, offset, key.Interpolation.Value) -- ! assuming this is tied to Enum order
					offset += 1
					buffer.writeu8(b, offset, countBits(lt, rt))
					offset += 1
					buffer.writeu32(b, offset, dataSize + 1)
					offset += 4
					buffer.writeu8(b, offset, typeId)
					offset += 1
					buffer.copy(b, offset, bufs[i])
					offset += dataSize

					if lt == nil and rt == nil then
						lt, rt = deriveTangentValueCurve(keys, i)
					elseif lt == nil then
						lt = rt
					elseif rt == nil then
						rt = lt
					end

					buffer.writef32(b, offset, lt)
					offset += 4
					buffer.writef32(b, offset, rt)
					offset += 4
				end

				offset = writeTimesSection(b, offset, keys)

				return buffer.tostring(b)
			end,
		},
		MarkerCurve = {
			ValuesAndTimes = function(instance)
				local markers = instance:GetMarkers()
				local n = #markers

				if n == 0 then
					return "\2\0\0\0\0\0\0\0\1\0\0\0\0\0\0\0"
				end

				local strings_size = 0
				for _, marker in markers do
					strings_size += #marker.Value + 1
				end

				local b = buffer.create(8 + strings_size + 8 + (n * 4))

				buffer.writeu32(b, 0, 2) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu32(b, 4, n)

				local offset = 8
				for _, marker in markers do
					local value = marker.Value
					buffer.writestring(b, offset, value)
					offset += #value + 1
					--buffer.writeu8(b, offset, 0) -- null terminator
					--offset += 1
				end

				offset = writeTimesSection(b, offset, markers)

				return buffer.tostring(b)
			end,
		},
		AnimationNodeDefinition = {
			InputPinData = function(instance)
				local input_pins = instance:GetOrderedInputPinNames()

				local n = #input_pins

				if n == 0 then
					return "\1\0\0\0\0\0\0\0"
				end

				local buffer_size = 8

				for _, pin in input_pins do
					buffer_size += 4 + #pin
				end

				local b = buffer.create(buffer_size)

				buffer.writeu32(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu32(b, 4, n)

				local encoder = Attribute_Encoders["string"]
				local offset = 8
				for _, pin in input_pins do
					local pinBuf, pinSize = encoder(pin)

					buffer.copy(b, offset, pinBuf)
					offset += pinSize
				end

				return buffer.tostring(b)
			end,
		},
		AnimationClip = {
			GuidBinaryString = function(instance) -- RobloxScriptSecurity
				return encodeGuid(instance.Guid)
			end,
		},
		AnimationRigData = {
			label = function(instance)
				local labels = instance:GetLabels() -- RobloxScriptSecurity
				local n = #labels

				if n == 0 then
					return "\1\0\0\0\0\0\0\0"
				end

				local b = buffer.create(8 + n * 4)

				buffer.writeu32(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu32(b, 4, n)

				local offset = 8

				for _, label in labels do
					buffer.writeu32(b, offset, label)
					offset += 4
				end

				return buffer.tostring(b)
			end,
			name = function(instance)
				local names = instance:GetNames() -- RobloxScriptSecurity
				local n = #names

				if n == 0 then
					return "\1\0\0\0\0\0\0\0"
				end

				local buffer_size = 8

				for _, name in names do
					buffer_size += 4 + #name
				end

				local b = buffer.create(buffer_size)

				buffer.writeu32(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu32(b, 4, n)

				local offset = 8

				for _, name in names do
					buffer.writeu32(b, offset, #name)
					offset += 4
				end
				for _, name in names do
					buffer.writestring(b, offset, name)
					offset += #name
				end

				return buffer.tostring(b)
			end,
			parent = function(instance)
				local parents = instance:GetParents() -- RobloxScriptSecurity
				local n = #parents

				if n == 0 then
					return "\1\0\0\0\0\0\0\0"
				end

				local b = buffer.create(8 + #parents * 2)

				buffer.writeu32(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu32(b, 4, n)

				local offset = 8

				for _, parent in parents do
					buffer.writeu16(b, offset, parent)
					offset += 2
				end

				return buffer.tostring(b)
			end,
			postTransform = function(instance)
				return TransformsSerialize(instance:GetPostTransforms()) -- RobloxScriptSecurity
			end,
			preTransform = function(instance)
				return TransformsSerialize(instance:GetPreTransforms()) -- RobloxScriptSecurity
			end,
			transform = function(instance)
				return TransformsSerialize(instance:GetTransforms()) -- RobloxScriptSecurity
			end,
		},
		AudioDeviceInput = {
			AccessList = function(instance) -- CanSave & CanLoad false
				local userid_accesslist = instance:GetUserIdAccessList()

				local n = #userid_accesslist

				if n == 0 then
					return ""
				end

				local b = buffer.create(n * 8)

				local _writeI64LE = Attribute_Encoders._writeI64LE

				local offset = 0
				for _, user_id in userid_accesslist do
					_writeI64LE(b, offset, user_id)
					offset += 8
				end

				return buffer.tostring(b)
			end,
		},
		AudioEmitter = {
			AngleAttenuation = function(instance)
				return AttenuationSerialize(instance:GetAngleAttenuation())
			end,
			DistanceAttenuation = function(instance)
				return AttenuationSerialize(instance:GetDistanceAttenuation())
			end,
		},
		AudioListener = {
			AngleAttenuation = function(instance)
				return AttenuationSerialize(instance:GetAngleAttenuation())
			end,
			DistanceAttenuation = function(instance)
				return AttenuationSerialize(instance:GetDistanceAttenuation())
			end,
		},
		-- AuroraScript = { -- Class not released yet
		-- 	AuroraScriptBindingsSerialize = function(instance)
		-- 		local bindings = service.AuroraScriptService:getInstancesForBehavior(instance)
		-- 		if #bindings == 0 then
		-- 			return ""
		-- 		end
		-- 		local refs = table.create(#bindings)
		-- 		for i, binding in bindings do
		-- 			refs[i] = GetRef(binding)
		-- 		end
		-- 		return table.concat(refs, "\0")
		-- 	end,
		-- },
		DebuggerBreakpoint = { line = "Line" }, -- ? This shouldn't appear in live games (try to prove this wrong)
		BallSocketConstraint = { MaxFrictionTorqueXml = "MaxFrictionTorque" },
		BasePart = {
			Color3uint8 = "Color",
			MaterialVariantSerialized = "MaterialVariant",
			size = "Size",
			siz = "Size",
		},
		DoubleConstrainedValue = { value = "Value" },
		IntConstrainedValue = { value = "Value" },

		CustomEvent = {
			PersistedCurrentValue = function(instance)
				local receiver = instance:GetAttachedReceivers()[1]
				if receiver then
					return receiver:GetCurrentValue()
				end

				local tempReceiver = Instance.new("CustomEventReceiver")
				local clone = Instance.fromExisting(instance)

				tempReceiver.Source = clone
				local value = tempReceiver:GetCurrentValue()

				tempReceiver:Destroy()
				clone:Destroy()

				return value
			end,
		},

		-- Lighting = {
		-- 	ExtendLightRangeTo120 = function() -- Seems default true now
		-- 		local light = Instance.new("PointLight")
		-- 		light.Range = 200
		-- 		return light.Range == 120 -- Ideally cache
		-- 	end,
		-- },

		Terrain = {
			AcquisitionMethod = "LastUsedModificationMethod", -- ? Not sure, RobloxScriptSecurity
			-- Material = function(instance) -- EnableMaterialSlotTable FFlag, uncomment once GetMaterialSlot is enabled
			-- 	local slots = {}
			-- 	for slotIndex = 2, 1e9 do -- limit is 64?
			-- 		local ok, baseMaterial, materialVariant, color =
			-- 			pcall(instance.GetMaterialSlot, instance, slotIndex)

			-- 		if ok then
			-- 			if baseMaterial then
			-- 				table.insert(
			-- 					slots,
			-- 					{
			-- 						slotIndex = slotIndex,
			-- 						baseMaterial = baseMaterial,
			-- 						materialVariant = materialVariant,
			-- 						color = color,
			-- 					}
			-- 				)
			-- 			end
			-- 		else
			-- 			break
			-- 		end
			-- 	end

			-- 	local size = 8 -- header

			-- 	for _, slot in slots do
			-- 		size += 15 + #slot.materialVariant
			-- 	end

			-- 	local b = buffer.create(size)
			-- 	local offset = 0

			-- 	-- header
			-- 	buffer.writeu32(b, offset, 1) -- version
			-- 	offset += 4

			-- 	buffer.writeu32(b, offset, #slots)
			-- 	offset += 4

			-- 	for _, slot in slots do
			-- 		buffer.writeu32(b, offset, slot.slotIndex)
			-- 		offset += 4

			-- 		buffer.writeu8(b, offset, (slot.color.R * 255))
			-- 		offset += 1
			-- 		buffer.writeu8(b, offset, (slot.color.G * 255))
			-- 		offset += 1
			-- 		buffer.writeu8(b, offset, (slot.color.B * 255))
			-- 		offset += 1

			-- 		buffer.writeu32(b, offset, slot.baseMaterial.Value)
			-- 		offset += 4

			-- 		buffer.writeu32(b, offset, #slot.materialVariant)
			-- 		offset += 4

			-- 		buffer.writestring(b, offset, slot.materialVariant)
			-- 		offset += #slot.materialVariant
			-- 	end

			-- 	return buffer.tostring(b)
			-- end,
			MaterialColors = function(instance)
				-- TODO Use code below once GetFirstCustomMaterialSlotIndex & GetMaterialSlot are enabled
				--[[
				local colors = {}
				for slotIndex = 0, instance:GetFirstCustomMaterialSlotIndex() - 1 do -- ! GetFirstCustomMaterialSlotIndex was removed
					local o, baseMaterial, materialVariant, color = pcall(instance.GetMaterialSlot, instance, slotIndex)

					if o then
						if color then
							table.insert(colors, color)
						end
					else
						break
					end
				end
				local b = buffer.create(#colors * 3)
				local offset = 0
				for _, color in colors do
					buffer.writeu8(b, offset, (color.R * 255))
					offset += 1
					buffer.writeu8(b, offset, (color.G * 255))
					offset += 1
					buffer.writeu8(b, offset, (color.B * 255))
					offset += 1
				end
				]]

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

				local b = buffer.create(69)
				local offset = 6 -- 6 reserved bytes

				for _, material in TERRAIN_MATERIAL_COLORS do
					local color = instance:GetMaterialColor(material)
					buffer.writeu8(b, offset, (color.R * 255))
					offset += 1
					buffer.writeu8(b, offset, (color.G * 255))
					offset += 1
					buffer.writeu8(b, offset, (color.B * 255))
					offset += 1
				end

				return buffer.tostring(b)
			end,
		},
		BaseWrap = {
			TemporaryCageMeshContent = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "TemporaryCageMeshId"))
			end,
		},
		MaterialVariant = {
			TexturePackContent = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "TexturePack"))
			end,
		},
		TerrainDetail = {
			TexturePackContent = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "TexturePack"))
			end,
		},
		WrapLayer = {
			TemporaryReferenceMeshContent = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "TemporaryReferenceId"))
			end,
		},
		TriangleMeshPart = {
			FluidFidelityInternal = "FluidFidelity",
		},
		MeshPart = {
			InitialSize = "MeshSize",
			MeshID = "MeshId",
			VertexCount = function(instance) -- RobloxSecurity
				if RiskyServicesDisabled.UGC then
					return __BREAK
				end
				local meshId = instance.MeshId
				if meshId == "" then
					return __BREAK
				end
				return #service.UGCValidationService:GetMeshVerts(meshId)
			end,
		},
		PartOperation = {
			Content = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "AssetId"))
			end,
			InitialSize = "MeshSize",
		},
		Part = { shape = "Shape", shap = "Shape" },
		TrussPart = { style = "Style" },
		FormFactorPart = {
			formFactorRaw = "FormFactor",
		},
		Fire = { heat_xml = "Heat", size_xml = "Size" },
		Clothing = {
			Outfit1Content = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "Outfit1"))
			end,
			Outfit2Content = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "Outfit2"))
			end,
		},
		Humanoid = {
			Health_XML = "Health",
			InternalBodyScale = function(instance) -- RobloxScriptSecurity
				-- X - BodyWidthScale
				-- Y - BodyHeightScale
				-- Z - BodyDepthScale
				local a = instance.RootPart

				if not a then
					return __BREAK
				end

				return instance:GetAccessoryHandleScale(a, Enum.BodyPartR15.RootPart)
			end,
			InternalHeadScale = function(instance) -- RobloxScriptSecurity
				-- HeadScale
				local a = instance.Parent and instance.Parent:FindFirstChild("Head")

				if not a then
					return __BREAK
				end

				return instance:GetAccessoryHandleScale(a, Enum.BodyPartR15.Head).X -- X, Y, Z seem to be always equal
			end,
			NetworkHumanoidState = function(instance) -- CanSave & CanLoad false
				return instance:GetState()
			end,
		},
		HumanoidDescription = {
			AccessoryBlob = function(instance)
				local blob = {}

				for _, acc in instance:GetAccessories(false) do
					table.insert(blob, {
						AssetId = acc.AssetId,
						Order = acc.Order,
						AccessoryType = acc.AccessoryType.Name,
						Puffiness = acc.Puffiness,
					})
				end

				return service.HttpService:JSONEncode(blob)
			end,
			EmotesDataInternal = function(instance)
				local emotes_data = ""
				for name, ids in instance:GetEmotes() do
					emotes_data ..= name .. "^" .. table.concat(ids, "^") .. "^\\"
				end
				return emotes_data
			end,
			EquippedEmotesDataInternal = function(instance)
				local equipped_emotes = instance:GetEquippedEmotes()
				if #equipped_emotes == 0 then
					return ""
				end

				local equipped_emotes_data = ""
				for _, emote in equipped_emotes do
					equipped_emotes_data = equipped_emotes_data .. emote.Slot .. "^" .. emote.Name .. "\\"
				end
				return equipped_emotes_data
			end,
		},
		LocalizationTable = {
			Contents = function(instance)
				return instance:GetContents() --service.HttpService:JSONEncode(instance:GetEntries())
			end,
		},
		MaterialService = { Use2022MaterialsXml = "Use2022Materials" }, -- RobloxScriptSecurity
		VideoPlayer = {
			PlayingReplicating = "IsPlaying", -- CanSave & CanLoad false
		},

		Model = {
			ModelMeshCFrame = function(instance)
				return instance:GetModelCFrame() -- GetBoundingBox
			end,
			ModelMeshSize = function(instance)
				return instance:GetExtentsSize() -- GetBoundingBox, GetModelSize
			end,
			Scale = function(instance) -- CanSave & CanLoad false
				return instance:GetScale()
			end,
			ScaleFactor = function(instance)
				return instance:GetScale()
			end,
			WorldPivotData = "WorldPivot", -- TODO This doesn't accurately represent whether optional type property is present or not (it's never nil), gethiddenproperty or gethiddenproperty_fallback is preferred
		},
		PackageLink = {
			PackageContentSerialize = "PackageContent",
			PackageIdSerialize = "PackageId",
			VersionIdSerialize = "VersionNumber",
		},
		Players = { MaxPlayersInternal = "MaxPlayers", PreferredPlayersInternal = "PreferredPlayers" }, -- ? Only needed for execs that lack LocalUserSecurity (Level 2, 5, 9), even so, it's a pretty useless information as it can be viewed elsewhere

		StarterPlayer = {
			AvatarJointUpgrade_SerializedRollout = "AvatarJointUpgrade", -- RobloxScriptSecurity
			-- LoadCharacterLayeredClothing = "LoadCharacterLayeredClothing ",-- * Both NotScriptable
		},
		Smoke = { size_xml = "Size", opacity_xml = "Opacity", riseVelocity_xml = "RiseVelocity" },
		Sound = {
			xmlRead_MinDistance_3 = "RollOffMinDistance", -- * Also MinDistance
			xmlRead_MaxDistance_3 = "RollOffMaxDistance", -- * Also MaxDistance
		},
		ViewportFrame = {
			CameraCFrame = function(instance)
				local CurrentCamera = instance.CurrentCamera

				return CurrentCamera and CurrentCamera.CFrame or CFrame.identity
			end,
			CameraFieldOfView = function(instance)
				local CurrentCamera = instance.CurrentCamera

				return math.rad(CurrentCamera and CurrentCamera.FieldOfView or 70)
			end,
		},
		WeldConstraint = {
			CFrame0 = function(instance)
				local Part0, Part1 = instance.Part0, instance.Part1

				return Part0 and Part1 and Part0.CFrame:ToObjectSpace(Part1.CFrame) or CFrame.identity
			end,
			CFrame1 = function(instance)
				local Part0, Part1 = instance.Part0, instance.Part1

				return Part0 and Part1 and Part1.CFrame:ToObjectSpace(Part0.CFrame) or CFrame.identity
			end,
			Part0Internal = "Part0",
			Part1Internal = "Part1",
			State = function(instance)
				return countBits(instance.Enabled, instance.Active)
			end,
		},
		Workspace = {
			-- SignalBehavior2 = "SignalBehavior", -- * Both NotScriptable
			CollisionGroups = function(instance) -- deprecated
				local collision_groups = game:GetService("PhysicsService"):GetRegisteredCollisionGroups()
				-- local collision_groups = instance:GetRegisteredCollisionGroups() -- ! Wait until MultiworldCollisionGroups2

				local n = #collision_groups
				if n == 0 then
					return ""
				end

				local t = table.create(n)
				for i, group in collision_groups do
					t[i] = group.name .. "^" .. i - 1 .. "^" .. group.mask
				end
				return table.concat(t, "\\")
			end,
		},
		WorldRoot = {
			CollisionGroupData = function(instance)
				local collision_groups = game:GetService("PhysicsService"):GetRegisteredCollisionGroups()
				-- local collision_groups = instance:GetRegisteredCollisionGroups() -- ! Wait until MultiworldCollisionGroups2
				local n = #collision_groups

				if n == 0 then
					return "\1\0"
				end

				local buffer_size = 2 -- version + count

				for _, group in collision_groups do
					buffer_size += 7 + #group.name -- id(1) + typeId(1) + mask(4) + namelen(1) + name
				end

				local b = buffer.create(buffer_size)

				buffer.writeu8(b, 0, 1) -- ? [CONSTANT] Version byte (likely)
				buffer.writeu8(b, 1, n)

				local typeId_int32 = Attribute_Type_Ids["int32"]
				local offset = 2

				for i, group in collision_groups do
					local name, id, mask = group.name, i - 1, group.mask
					local name_len = #name

					buffer.writeu8(b, offset, id) -- ID
					offset += 1

					buffer.writeu8(b, offset, typeId_int32) -- Type ID for int32 (0x04)
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

		ServiceVisibilityService = { -- Service doesn't exist outside of Studio
			HiddenServices = function()
				return ServiceVisibilitySerialize(false)
			end,
			VisibleServices = function()
				return ServiceVisibilitySerialize(true)
			end,
		},

		-- EditableImage = { -- Not sure how this would be encountered as it can't be parented
		-- 	ImageData = function(instance) -- Not sure if format is correct
		-- 		return buffer.tostring(instance:ReadPixelsBuffer(Vector2.new(), instance.Size)) -- Vector2.zero can be set to a local to avoid repeat creations
		-- 	end,
		-- },
	}
	for _, enum_item in Enum.Material:GetEnumItems() do
		NotScriptableFixes.MaterialService[enum_item.Name .. "Name"] = function(instance)
			return instance:GetBaseMaterialOverride(enum_item)
		end
	end

	FetchAPI = function()
		local FILE_NAME = USSI_FOLDER .. "API_DUMP.json"

		local API_Dump

		local Max_SecurityCapabilities = SecurityCapabilities.new(unpack(Enum.SecurityCapability:GetEnumItems()))
		local filter = { Security = Max_SecurityCapabilities, ExcludeDisplay = true, ExcludeInherited = true }

		-- ! exact version match is preferred, mismatched dump versions might result in saveinstance trying to save properties that your client doesn't have yet
		local APIDUMP_FETCHERS = {
			[1] = function()
				local res = readfile(FILE_NAME)
				if res and res ~= "" then
					return service.HttpService:JSONDecode(res)[FULL_VERSION]
				end
			end,
			[2] = function() -- version-history.json -> exact_match -> zbeta -> LIVE -> sibling major matches
				local client_version_str = tostring(CLIENT_VERSION)
				local dump
				local matching_versions, matched, is_matched, exact_match = {}, {}
				local function process_line(line, noinsert)
					local file_version, patch_commit, version_hash =
						string.match(line, '"%d+%.(%d+)%.([^"]+)": "(version%-[^"]+)')
					if file_version == client_version_str then
						is_matched = true
						if version_hash and not matched[version_hash] then -- ! this might cause issues if different file_versions point to the same version_hash (never happened)
							matched[version_hash] = true
							if not noinsert then -- to avoid fetching duplicates
								table.insert(matching_versions, version_hash) -- ? Retain the order (by latest)
							end
							if string.sub(FULL_VERSION, -#patch_commit) == patch_commit then
								return version_hash -- exact match
							end
						end
					elseif is_matched then
						return false -- stop iteration
					end
				end

				-- ! Assumes Normal dumps never include Default; Full dumps always do.
				local function isFullDump(classes)
					for _, class in classes do
						for _, member in class.Members do
							if member.MemberType == "Property" then
								return member.Default ~= nil
							end
						end
					end
					return false -- no properties found at all; treat as inconclusive/not full
				end

				local function tryFetchDump(url)
					local ok, decoded = pcall(function()
						local raw = game:HttpGet(url, true)
						return service.HttpService:JSONDecode(raw)
					end)
					return ok and decoded.Classes or nil
				end

				local function fetchFullApiDump(hash)
					-- Primary: Roblox CDN (only WindowsStudio64 hashes seem supported here)
					-- Might need timeout logic..
					local decoded = tryFetchDump("https://setup.rbxcdn.com/" .. hash .. "-Full-API-Dump.json")
					if decoded and isFullDump(decoded) then
						return decoded
					end

					-- Fallback: our own archived full dumps, in case Roblox's endpoint
					-- silently returned a normal dump instead of a full one (or 404'd).
					decoded = tryFetchDump(
						"https://raw.githubusercontent.com/setup-rbxcdn/roblox-full-api-dumps/refs/heads/main/full-dumps/"
							.. hash
							.. "-Full-API-Dump.json"
					)
					if decoded and isFullDump(decoded) then -- isFullDump check is useless here but why not
						return decoded
					end

					return nil
				end

				do
					local o, r = pcall(
						game.HttpGet,
						game,
						"https://raw.githubusercontent.com/setup-rbxcdn/setup-rbxcdn.github.io/refs/heads/main/version-history/Windows/Studio64.json",
						true
					)
					if o then
						local version_history = string.split(r, "\n")
						version_history[#version_history] = nil -- the "}"
						-- 1. version-history pass (bottom-up)
						for i = #version_history, 2, -1 do -- 2 to avoid "{"
							local res = process_line(version_history[i])
							if res == false then
								break
							elseif res then
								exact_match = res
							end
						end
					end
				end
				do -- ? this might happen when user is on a new version but Roblox-Client-Tracker hasn't updated version-history.json yet
					local function fallback_channel(channel)
						local ok, res = pcall(function()
							return service.HttpService:JSONDecode(
								game:HttpGet(
									"https://clientsettingscdn.roblox.com/v2/client-version/WindowsStudio64"
										.. (channel and "/channel/" .. channel or ""),
									true
								)
							)
						end)
						if not ok then
							return
						end
						if res.version and res.clientVersionUpload then -- just in case
							local line = '"' .. res.version .. '": "' .. res.clientVersionUpload
							return process_line(line, true)
						end
					end
					if not exact_match then
						exact_match = fallback_channel("zbeta") or fallback_channel() -- LIVE
					end
				end
				if exact_match then
					dump = fetchFullApiDump(exact_match)
				end
				if not dump then
					for _, version_hash in matching_versions do -- TODO ideally match nearest by Commit segment of version(), new>old
						dump = fetchFullApiDump(version_hash)
						if dump then
							break
						end
					end
				end
				return dump
			end,
			[3] = function()
				-- ! Some executors (like Xeno) error on ReflectionService.GetClasses due to their ProxyService
				-- TODO At the time of writing this is missing a way to confirm NotCreatable & NotScriptable
				-- also is missing some classes like UserGameSettings, not that important though as none of them appear under DataModel
				if RiskyServicesDisabled.Reflection then
					return nil
				end

				local classes, classes_size = {}, 1

				local renames = {
					CoordinateFrame = "CFrame",
					Rect2D = "Rect",
					Vector3Int16 = "Vector3int16",
					Vector2Int16 = "Vector2int16",
					Region3Int16 = "Region3int16",
				}

				for _, api_class in service.ReflectionService:GetClasses(filter) do
					local members, members_size = {}, 1
					local className = api_class.Name

					local class = {
						Name = className,
						Members = members,
						Superclass = api_class.Superclass or "<<<ROOT>>>",
					}
					local permits = api_class.Permits

					local tags = {}
					if api_class.Service then
						table.insert(tags, "Service")
					elseif permits and permits["GetService"] then
						table.insert(tags, "Service")
					elseif not permits or not permits["New"] then -- Some services can be Instance.new so it's better to include them
						table.insert(tags, "NotCreatable")
					end

					if #tags ~= 0 then
						class.Tags = tags
					end

					local o, r = pcall(
						service.ReflectionService.GetPropertiesOfClass,
						service.ReflectionService,
						className,
						filter
					) -- ? Might produce errors (ex. RolloutValidation) therefore pcall
					if o then
						for _, property in r do
							local propertyName = property.Name

							local valueType = property.Type
							local valueType_Name = valueType.EngineType

							local category = valueType.Category

							local member_tags = {}

							if not next(property.Permits) then
								table.insert(member_tags, "NotScriptable")
							end

							if valueType_Name == "Enum" then
								category, valueType_Name = "Enum", valueType.EnumType
							elseif valueType_Name == "RefType" then
								category, valueType_Name = "Class", valueType.InstanceType
							else
								valueType_Name = renames[valueType_Name] or valueType_Name
							end

							-- property.Display.DeprecationMessage can be used to track Deprecated tag (not always though)

							local member = {
								Name = propertyName,
								MemberType = "Property",
								ValueType = { Name = valueType_Name, Category = category },
								Serialization = { CanLoad = property.Serialized, CanSave = property.Serialized },
								-- Default = Member.Default,
								-- Special = Special,
								-- Tags = MemberTags,
							}

							if #member_tags ~= 0 then
								member.Tags = member_tags
							end

							members[members_size] = member
							members_size += 1
						end
						-- else
						-- warn("Missing", className, r)
					end
					classes[classes_size] = class
					classes_size += 1
				end

				return classes
			end,
			[4] = function()
				-- Credits @MaximumADHD
				return service.HttpService:JSONDecode(
					game:HttpGet(
						"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json",
						true
					)
				).Classes
			end,
		}

		for i, fetcher in APIDUMP_FETCHERS do
			local o, r = pcall(fetcher)
			if o and r then
				API_Dump = r
				if i == 2 then -- relies on [2] being the same
					if writefile then
						local ok, err =
							pcall(writefile, FILE_NAME, service.HttpService:JSONEncode({ [FULL_VERSION] = API_Dump }))
						if not ok then
							warn("[DEBUG] DUMP writefile error", err)
						end
					end
				end
				break
			elseif r ~= false and 2 < i then
				warn("[DEBUG] Failed to get", FULL_VERSION, "version API Dump, trying fallbacks..")
				warn("[DEBUG] Method number:", i, "Reason:", r)
			end
		end

		local classList = {}
		local tmp_classDict = {}

		local ClassesWhitelist, ClassesBlacklist = ClassPropertyExceptions.Whitelist, ClassPropertyExceptions.Blacklist

		local API_Dump_Decoded = API_Dump

		-- First pass (prep)
		for _, API_Class in API_Dump_Decoded do
			local ClassName = API_Class.Name
			local props = {}

			for _, Member in API_Class.Members do
				local MemberType = Member.MemberType
				if MemberType == "Property" or MemberType == "Function" then
					props[Member.Name] = {
						ValueType = MemberType == "Property" and Member.ValueType.Name,
						MemberType = MemberType,
						-- Serialization = Member.Serialization,
					}
				end
			end

			tmp_classDict[ClassName] = props
		end

		-- Second pass (actual)
		for _, API_Class in API_Dump_Decoded do
			local ClassProperties, ClassProperties_size = {}, 1
			local Class = {
				Properties = ClassProperties,
				Superclass = API_Class.Superclass,
				-- Tags = {},
				NotCreatable = nil,
			}

			local ClassName = API_Class.Name
			local ClassTags = API_Class.Tags

			if ClassTags then
				local Tags = arrayToDict(ClassTags, nil, nil, "string")
				-- Class.Tags = Tags -- or {}
				Class.NotCreatable = Tags.NotCreatable
				Class.Service = Tags.Service
			end

			local NotScriptableFixClass = NotScriptableFixes[ClassName]

			local ClassWhitelist, ClassBlacklist = ClassesWhitelist[ClassName], ClassesBlacklist[ClassName]

			local ContentProperties
			for _, Member in API_Class.Members do
				if Member.MemberType == "Property" then
					local Serialization = Member.Serialization

					if Serialization.CanLoad then -- If Roblox doesn't save it why should we; If Roblox doesn't load it we don't need to save it
						--[[
							-- ! CanSave replaces "Tags.Deprecated" check because there are some old properties which are deprecated yet have CanSave.
							Example: Humanoid.Health is CanSave false due to Humanoid.Health_XML being CanSave true (obsolete properties basically) - in this case both of them will Load. (aka PropertyPatches)
							CanSave being on same level as CanLoad also fixes potential issues with overlapping properties like Color, Color3 & Color3uint8 of BasePart, out of which only Color3uint8 should save
							This also fixes everything in IgnoreClassProperties automatically without need to hardcode :)
							A very simple fix for many problems that saveinstance scripts encounter!
						--]]
						local PropertyName = Member.Name

						local ValueType = Member.ValueType
						local ValueType_Name = ValueType.Name

						if ValueType_Name == "Content" or ValueType_Name == "AssetContentMap" then -- TODO Can Skip this if our dump was fetched from ReflectionService (make it explicit), currently ReflectionService dump isn't written to file
							-- ? This filters out Content DataType properties that Roblox doesn't serialize (even if they have CanSave/CanLoad true), takes less space, time & prevents potential property conflicts (Content vs ContentId)
							if not ContentProperties then
								ContentProperties = {}

								if not RiskyServicesDisabled.Reflection then
									local o, properties = pcall(
										service.ReflectionService.GetPropertiesOfClass,
										service.ReflectionService,
										ClassName,
										filter
									)
									if o then
										for _, property in properties do
											ContentProperties[property.Name] = property.Serialized
										end
									end
								end
							end
							if ContentProperties[PropertyName] ~= nil then
								Serialization.CanSave = ContentProperties[PropertyName]
							end
						end

						if
							(Serialization.CanSave or ClassWhitelist and ClassWhitelist[PropertyName])
							and not (ClassBlacklist and ClassBlacklist[PropertyName])
						then
							local MemberTags = Member.Tags

							local Special, PreferredDescriptorName

							if MemberTags then
								for _, tag in MemberTags do
									if type(tag) == "table" then
										PreferredDescriptorName = tag.PreferredDescriptorName
										if PreferredDescriptorName and Special then
											break
										end
									elseif tag == "NotScriptable" then
										Special = true
										if PreferredDescriptorName then
											break
										end
									end
								end
							end

							local preferredDescriptorProp
							if PreferredDescriptorName then
								preferredDescriptorProp = tmp_classDict[ClassName][PreferredDescriptorName]

								if -- Prevents type mismatch
									preferredDescriptorProp == nil
									or (
										preferredDescriptorProp.MemberType == "Property"
										and ValueType_Name ~= preferredDescriptorProp.ValueType
									)
								then -- For ex. (if they were notscriptable) CollisionGroupId (int) -> CollisionGroup (string)
									PreferredDescriptorName = nil
								end
							end

							-- if not Special then
							local Property = {
								Name = PropertyName,
								Category = ValueType.Category,
								-- Default = Member.Default,
								-- Tags = MemberTags,
								ValueType = ValueType_Name,

								Special = Special,

								CanRead = nil,
							}

							if string.sub(ValueType_Name, 1, 8) == "Optional" then
								-- Extract the string after "Optional"
								Property.Optional = string.sub(ValueType_Name, 9)
							end

							local NotScriptableFix = NotScriptableFixClass and NotScriptableFixClass[PropertyName]
							local accessFunc = PreferredDescriptorName
								and (
									preferredDescriptorProp.MemberType == "Property"
										and function(instance)
											return instance[PreferredDescriptorName]
										end
									or function(instance) -- Assume MemberType is "Function"
										return instance[PreferredDescriptorName](instance)
									end
								)

							Property.Fallback = NotScriptableFix
									and (type(NotScriptableFix) == "function" and NotScriptableFix or accessFunc and function(
										instance
									)
										local o, r = pcall(accessFunc, instance)
										if o then
											return r
										end
										return instance[NotScriptableFix]
									end or function(instance)
										return instance[NotScriptableFix]
									end)
								or accessFunc

							ClassProperties[ClassProperties_size] = Property
							ClassProperties_size += 1
						end
					end
				end
			end

			classList[ClassName] = Class
		end

		return classList
	end
end

--[=[
    @class SynSaveInstance
    Represents the options for saving instances with custom settings using the synsaveinstance function.
]=]

--- @interface CustomOptions table
--- * Structure of the main CustomOptions table.
--- * Note: Options are case-insensitive, meaning you can type `NilInstances` option as `nilInStaNces` and it still will be valid.
--- @within SynSaveInstance
--- @field __DEBUG_MODE boolean -- This will print debug logs to console about unusual scenarios. Recommended to enable if you wish to help us improve our products and find bugs / issues with it! ___Default:___ false
--- @field ReadMe boolean --___Default:___ true
--- @field Binary boolean -- Saves as a binary file (.rbxl/.rbxm) instead of XML (.rbxlx/.rbxmx). Much smaller and faster to load. Pass `XML = true` for the opposite. ___Default:___ true
--- @field CompressionMode string -- How chunks are compressed in binary mode: "zstd", "lz4", or false for none. ___Default:___ "zstd"
--- @field CompressionLevel number -- Compression strength, higher is smaller but slower. Range is -7 to 22 inclusive. ___Default:___ 9
--- @field CopyToClipboard boolean -- Puts the finished output on the clipboard instead of writing a file, so you can paste it straight into Studio. Best for small saves -- a full place is usually far too big for the clipboard to handle. ___Default:___ false
--- .RiskyServicesDisabled {UGC, Encoding, Reflection = boolean} -- Per-service kill switches for services games might detect. `UGC` skips UGCValidationService (GHP fallback reads, `MeshPart.VertexCount`). `Encoding` skips EncodingService (base64 encode/decode, zstd compression falls back to other funcs). `Reflection` skips ReflectionService (one of several API dump fallbacks, `Content` property lookups -- falls back to the other API dump sources). Examples: `{UGC = true}` disables only UGCValidationService; `{Encoding = true, Reflection = true}` disables both, leaving UGC untouched. ___Default:___ {UGC = false, Encoding = false, Reflection = false}
--- @field SafeMode boolean -- Kicks you before Saving, which keeps you safe. **HIGHLY RECOMMENDED TO KEEP ENABLED**. ___Default:___ false
--- @field KillAllScripts boolean -- Kills all scripts to further protect you. SafeMode also enables this by default. If you can't move after saving then this is the reason. **HIGHLY RECOMMENDED TO KEEP ENABLED**. ___Default:___ false
--- @field BoostFPS boolean -- Massively boosts FPS by disabling 3D rendering. Other options also enable it, like: SafeMode. ___Default:___ false
--- @field ShutdownWhenDone boolean -- Shuts the game down after saveinstance is finished. ___Default:___ false
--- @field AntiIdle boolean -- Prevents the 20-minute-Idle Kick. ___Default:___ true
--- .Anonymous {boolean|table{UserId = string?, Name = string?}} -- * **RISKY:** Removes your Name and UserId from the file -- useful for games that store them in GUIs or other Instances. Can also be a table with UserId and/or Name keys to pick the replacements. May mess up unrelated text or numbers that happen to match. Inside attributes and tags the replacement is padded to the same length, so a name shorter than yours comes out as for example `Roblox____`. ___Default:___ false
--- @field ShowStatus boolean -- ___Default:___ true
--- @field Callback function -- If set, the serialized data will be sent to the callback function instead of to file. ___Default:___ false
--- @field mode string -- Valid modes: full, optimized, scripts. Change this to invalid mode like "invalid" if you only want ExtraInstances. "optimized" mode is **NOT** supported with *@Object* option. ___Default:___ `"optimized"`
--- @field Decompile boolean -- Script decompiling. ___Default:___ true
--- @field scriptcache boolean -- Use decompiled script cache to avoid decompiling duplicate scripts. ___Default:___ true
--- @field DecompileTimeout number -- If the decompilation run time exceeds this value it gets cancelled. Set to -1 to disable timeout. ___Default:___ 10
--- @field BytecodeTimeout number -- If the SaveBytecode run time exceeds this value it gets cancelled. Set to -1 to disable timeout. ___Default:___ 3
--- @field DecompileJobless boolean -- Includes already decompiled code in the output. No new scripts are decompiled. ___Default:___ false
--- @field SaveBytecode boolean -- Includes bytecode in the output. Useful if you wish to be able to decompile it yourself later. Respects **@DecompileIgnore**. ___Default:___ false
--- .DecompileIgnore {Instance | Instance.ClassName | [Instance.ClassName] = {Instance.Name}} -- Ignores matched instances and their descendants by default. To ignore only the instance itself, set the value to `false`. Examples: `"Chat"` matches any instance with ClassName "Chat"; `Players = {"MyPlayerName"}` matches class "Players" AND name "MyPlayerName" only; `workspace` matches a specific instance by reference; `[workspace] = false` matches a specific instance by reference, ignoring only itself and not its descendants. ___Default:___ {TextChatService}
--- .IgnoreList {Instance | Instance.ClassName | [Instance.ClassName] = {Instance.Name | false}} -- Structure mirrors **@DecompileIgnore**, except `false` means keep the instance but ignore its descendants. Supports both instance references and ClassName strings. Examples: `"CoreGui"` skips entirely; `CorePackages = false` keeps the instance but skips its descendants; `Players = {"SomePlayer"}` skips a specific named instance with specific ClassName. ___Default:___ {CoreGui, CorePackages, Packages = false}
--- .ExtraInstances {Instance} -- If used with any invalid mode (like "invalidmode") it will only save these instances. ___Default:___ {}
--- @field IgnoreProperties table -- Ignores properties by Name. ___Default:___ {}
--- @field SaveCacheInterval number -- The less the value the more often it saves, but that would mean less performance due to constantly saving. XML Only. ___Default:___ 0x1600 * 10
--- @field FilePath string -- The name (can include a path) of the file to save to. If it has no extension, `.rbxmx/rbxm` (models) or `.rbxlx/rbxl` (places) is appended; an existing extension is left as-is. Ignores `OPTIONS.AvoidFileOverwrite`. ___Default:___ false
--- @field AvoidFileOverwrite boolean -- Prevents writing to place file that already exists. ___Default:___ true
--- @field Object Instance -- * If provided, saves as .rbxmx (Model file) instead. If Object is game, it will be saved as a .rbxl file. **MUST BE AN INSTANCE REFERENCE, FOR EXAMPLE - *game.Workspace***. `"optimized"` mode is **NOT** supported with this option. If IsModel is set to false then Object specified here will be saved as a place file. ___Default:___ false
--- @field IsModel boolean -- If Object is specified then sets to true automatically, unless you set it to false. ___Default:___ false
--- @field NilInstances boolean -- Save instances that aren't Parented (Parented to nil). ___Default:___ false
--- .NilInstancesFixes {[Instance.ClassName] = function} -- * This can cause some Classes to be fixed even though they might not need the fix (better be safe than sorry though). For example, Bones inherit from Attachment if we dont define them in the NilInstancesFixes then this will catch them anyways. **TO AVOID THIS BEHAVIOR USE THIS EXAMPLE:** {ClassName_That_Doesnt_Need_Fix = false}. ___Default:___ {Animator = function, AdPortal = function, BaseWrap = function, Attachment = function}
--- @field IgnoreDefaultProperties boolean -- Ignores default properties during saving. XML Only (XML=true) because Binary (default) doesn't really need it.  ___Default:___ true
--- @field IgnoreNotArchivable boolean -- Ignores the Archivable property and saves Non-Archivable instances. ___Default:___ true
--- @field IgnorePropertiesOfNotScriptsOnScriptsMode boolean -- Ignores property of every instance that is not a script in "scripts" mode. ___Default:___ false
--- @field IgnoreSpecialProperties boolean -- Prevents calls to `gethiddenproperty` and uses fallback methods instead. This also helps with crashes. If your file is corrupted after saving, you can try turning this on. ___Default:___ false
--- @field IsolateStarterPlayer boolean -- Saves StarterPlayer as separate folder, children of the original instance will be ignored. ___Default:___ false
--- @field IsolatePlayers boolean -- Saves All Players as separate folder, children of the original instance will be ignored. ___Default:___ false
--- @field IsolateLocalPlayer boolean -- Saves LocalPlayer as separate folder, original instance will be ignored. ___Default:___ false
--- @field IsolateLocalPlayerCharacter boolean -- Saves LocalPlayer.Character as separate folder, original instance will be ignored. ___Default:___ false
--- @field SavePlayerCharacters boolean -- Save player characters while saving. ___Default:___ false
--- @field SaveNotCreatable boolean -- * Includes non-serializable instances as Folder objects (Name is misleading as this is mostly a fix for certain NilInstances and isn't always related to NotCreatable). Other options also enable it, like: IsolatePlayers, IsolateLocalPlayer, etc. ___Default:___ false
--- .NotCreatableFixes table<Instance.ClassName> -- * {"Player"} is the same as {Player = "Folder"}; Format like {SpawnLocation = "Part"} is only to be used when SpawnLocation inherits from "Part" AND "Part" is Creatable. ___Default:___ { "", "Player", "PlayerScripts", "PlayerGui", "TouchTransmitter" }
--- @field AlternativeWritefile boolean -- * Splits file content string into segments and writes them using appendfile. This might help with crashes when it starts writing to file. Though there is a risk of appendfile working incorrectly on some executors. ___Default:___ true
--- @field IgnoreDefaultPlayerScripts boolean -- * **RISKY**: Ignores Default PlayerScripts like PlayerModule & RbxCharacterSounds. Prevents crashes on certain Executors. ___Default:___ true
--- @field SharedBinaryStrings boolean -- Stores BinaryString values in a shared pool so identical ones are only written once, instead of repeating them for every instance. Good when many instances hold the same data (like copies of the same mesh) -- can make files noticeably smaller. Slightly bigger when everything is unique. Roblox doesn't officially support this, so there's a small chance it confuses Studio. ___Default:___ false
--- @field TreatUnionsAsParts boolean -- * **RISKY:** Converts all UnionOperations to Parts. Useful if your Executor isn't able to save (read) Unions, because otherwise they will be invisible. ___Default:___ false (except Solara)

--- @interface OptionsAliases
--- @within SynSaveInstance
--- Alias → Canonical option mapping for the [SynSaveInstance.CustomOptions] table.
--- Format: { Alias = CanonicalOption }
--- These are resolved before user options are processed and cannot be modified at runtime.
--- @field Clipboard string -- CopyToClipboard
--- @field DecompileScripts string -- Decompile
--- @field FileName string -- FilePath
--- @field IgnoreArchivable string -- IgnoreNotArchivable
--- @field IgnoreDefaultProps string -- IgnoreDefaultProperties
--- @field InstancesBlacklist string -- IgnoreList
--- @field IsolatePlayerGui string -- IsolateLocalPlayer
--- @field SaveCharacters string -- SavePlayerCharacters
--- @field SaveLocalPlayer string -- IsolateLocalPlayer
--- @field SaveNilInstances string -- NilInstances
--- @field SaveNonCreatable string -- SaveNotCreatable
--- @field SavePlayerGui string -- IsolateLocalPlayer
--- @field SavePlayers string -- IsolatePlayers
--- @field StatusText string -- ShowStatus
--- @field timeout string -- DecompileTimeout

--- @interface OptionsAliasesInverse
--- @within SynSaveInstance
--- Alias → Canonical option mapping with boolean inversion.
--- Format: { Alias = CanonicalOption }
--- These aliases invert the provided boolean value before applying it.
--- Example: noscripts = true → Decompile = false
--- These are resolved before user options are processed and cannot be modified at runtime.
--- @field DisableCompression string -- CompressionMode
--- @field noscripts string -- Decompile
--- @field RemovePlayerCharacters string -- SavePlayerCharacters
--- @field RemovePlayers string -- IsolatePlayers
--- @field XML string -- Binary

--[=[
	@function saveinstance
	Saves instances with specified options. Example:
	```lua
	local Params = {
		RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
		SSI = "saveinstance",
	}

	local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

	local CustomOptions = { SafeMode = true, DecompileTimeout = 15, SaveBytecode = true }

	synsaveinstance(CustomOptions)
	```
	@within SynSaveInstance
	@yields
	@param Parameter_1 variant<table, table<Instance>> -- Can either be [SynSaveInstance.CustomOptions table] or a filled with instances ({Instance}), (then it will be treated as ExtraInstances with an invalid mode and IsModel will be true).
	@param Parameter_2 table -- [OPTIONAL] If present, then Parameter_2 will be assumed to be [SynSaveInstance.CustomOptions table]. And then if the Parameter_1 is an Instance, then it will be assumed to be [SynSaveInstance.CustomOptions table].Object. If Parameter_1 is a table filled with instances ({Instance}), then it will be assumed to be [SynSaveInstance.CustomOptions table].ExtraInstances and IsModel will be true). This exists for sake compatibility with `saveinstance(game, {})`
]=]

local function synsaveinstance(CustomOptions, CustomOptions2)
	if GLOBAL_ENV.USSI then
		return
	end
	GLOBAL_ENV.USSI = true
	-- do -- ? Causes issues on SirHurt (Kick lacking Capability "Consequences"), let threads operate on their default/preferred identity set by the developers
	-- 	local setthreadidentity = global_container.setthreadidentity
	-- 	if setthreadidentity then
	-- 		pcall(setthreadidentity, 8) -- ? Arceus X Fix
	-- 	end
	-- end

	local totalsize = 0

	local StatusText

	local OPTIONS = {
		mode = "optimized",
		Binary = true,
		CompressionMode = "zstd",
		CompressionLevel = 9,
		Decompile = true,
		DecompileTimeout = 10,
		DecompileJobless = false,
		-- decomptype = "",
		scriptcache = true,
		SaveBytecode = false,
		BytecodeTimeout = 3,

		__DEBUG_MODE = false,

		Callback = false,
		CopyToClipboard = false, -- Description: If set to true, the serialized data will be set to the clipboard, which can be later pasted into studio easily.

		DecompileIgnore = {
			-- "Chat",
			"TextChatService",
			ModuleScript = nil,
		},
		IgnoreDefaultPlayerScripts = true,

		IgnoreProperties = {},

		IgnoreList = { "CoreGui", "CorePackages", Packages = false },

		ExtraInstances = {},
		NilInstances = false,
		NilInstancesFixes = {},

		SaveCacheInterval = 0x1600 * 10,
		ShowStatus = true,
		KillAllScripts = false,
		SafeMode = false,
		BoostFPS = false,
		ShutdownWhenDone = false,
		AntiIdle = true,
		Anonymous = false,
		ReadMe = true,
		FilePath = false,
		AvoidFileOverwrite = true,
		Object = false,
		IsModel = false,

		IgnoreDefaultProperties = true,
		IgnoreNotArchivable = true,
		IgnorePropertiesOfNotScriptsOnScriptsMode = false,
		IgnoreSpecialProperties = false,

		IsolateLocalPlayer = false, --  #service.StarterGui:GetChildren() == 0
		IsolateLocalPlayerCharacter = false,
		IsolatePlayers = false,
		IsolateStarterPlayer = false,
		SavePlayerCharacters = false,

		SaveNotCreatable = false,
		NotCreatableFixes = {
			-- "InputObject",
			-- "LodDataEntity",
			-- "Path",
			"", -- * FilteredSelection
			"AdvancedDragger",
			"AnimationTrack",
			-- "Breakpoint",
			-- "DebuggerWatch",
			"Dragger",
			"Player",
			"PlayerGui",
			"PlayerMouse",
			"PlayerMouse",
			"PlayerScripts",
			"ScreenshotHud",
			"StudioData",
			"TextChatMessage",
			"TextSource",
			"TouchTransmitter",
			"Translator",
			CloudLocalizationTable = "LocalizationTable",
			Platform = "Part",
			Status = "Model", -- gets created by studio automatically usually so there will be duplicates due to this
			-- CoreScript = "Script", -- useless
			-- ChatWindowMessageProperties = "TextChatMessageProperties", -- ? Not needed as this can be derived with ChatWindowConfiguration.DeriveNewMessageProperties
		},

		-- ! Risky
		RiskyServicesDisabled = {
			UGC = false,
			Encoding = false,
			Reflection = false,
		},
		SharedBinaryStrings = false,
		TreatUnionsAsParts = false,
		AlternativeWritefile = not arrayToDict({ "WRD", "Xeno", "Zorara" })[EXECUTOR_NAME],

		OptionsAliases = { -- You can't really modify these as a user (because they're read before user's Options are loaded)
			Clipboard = "CopyToClipboard",
			DecompileScripts = "Decompile",
			FileName = "FilePath",
			IgnoreArchivable = "IgnoreNotArchivable",
			IgnoreDefaultProps = "IgnoreDefaultProperties",
			InstancesBlacklist = "IgnoreList",
			IsolatePlayerGui = "IsolateLocalPlayer",
			SaveCharacters = "SavePlayerCharacters",
			SaveLocalPlayer = "IsolateLocalPlayer",
			SaveNilInstances = "NilInstances",
			SaveNonCreatable = "SaveNotCreatable",
			SavePlayerGui = "IsolateLocalPlayer",
			SavePlayers = "IsolatePlayers",
			StatusText = "ShowStatus",
			timeout = "DecompileTimeout",
		},
		OptionsAliasesInverse = {
			DisableCompression = "CompressionMode",
			noscripts = "Decompile",
			RemovePlayerCharacters = "SavePlayerCharacters",
			RemovePlayers = "IsolatePlayers",
			XML = "Binary",
		},
	}
	local OPTIONS_lowercase, OptionsAliasesInverse_lowercase, CustomOptions_valid = {}, {}, {}

	do
		local function buildMap(dest, source, warnLabel)
			for k, v in source do
				local key = string.lower(k)

				if dest[key] then
					warn("DUPLICATE " .. warnLabel, k)
				else
					dest[key] = v
				end
			end
		end

		-- base options
		for o in OPTIONS do
			local option = string.lower(o)
			if OPTIONS_lowercase[option] then
				warn("DUPLICATE OPTION", o)
			else
				OPTIONS_lowercase[option] = o
			end
		end

		-- aliases
		buildMap(OPTIONS_lowercase, OPTIONS.OptionsAliases, "ALIAS")

		-- inverse aliases
		buildMap(OptionsAliasesInverse_lowercase, OPTIONS.OptionsAliasesInverse, "INVERSE ALIAS")
	end

	do -- * Load Settings
		local function makeNilinstanceFix(Name, ClassName, Separate)
			return function(instance, instancePropertyOverrides)
				local Exists

				if not Separate then
					Exists = OPTIONS.NilInstancesFixes[Name]
				end

				local Fix

				local DoesntExist = not Exists
				if DoesntExist then
					Fix = Instance.new(ClassName)
					if not Separate then
						OPTIONS.NilInstancesFixes[Name] = Fix
					end
					-- Fix.Name = Name

					instancePropertyOverrides[Fix] =
						{ __Synthetic = true, __Children = { instance }, Properties = { Name = Name } }
				else
					Fix = Exists
					table.insert(instancePropertyOverrides[Fix].__Children, instance)
				end

				-- InstancesOverrides[instance].Parent = AnimationController
				if DoesntExist then
					return Fix
				end
			end
		end

		-- TODO: Merge BaseWrap & Attachment & AdPortal fix (put all under MeshPart container)
		-- TODO?:
		-- DebuggerWatch DebuggerWatch must be a child of ScriptDebugger
		-- PluginAction Parent of PluginAction must be Plugin or PluginMenu that created it!
		OPTIONS.NilInstancesFixes.Animator =
			makeNilinstanceFix("Animator has to be placed under Humanoid or AnimationController", "AnimationController")
		OPTIONS.NilInstancesFixes.AdPortal = makeNilinstanceFix("AdPortal must be parented to a Part", "Part")
		OPTIONS.NilInstancesFixes.Attachment =
			makeNilinstanceFix("Attachments must be parented to a BasePart or another Attachment", "Part") -- * Bones inherit from Attachments
		OPTIONS.NilInstancesFixes.BaseWrap = makeNilinstanceFix("BaseWrap must be parented to a MeshPart", "MeshPart")
		OPTIONS.NilInstancesFixes.PackageLink = makeNilinstanceFix("Package already has a PackageLink", "Folder", true)

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
					local k = string.lower(key)

					local option = OPTIONS_lowercase[k]
					local invert = false

					if not option then
						option = OptionsAliasesInverse_lowercase[k]
						invert = option ~= nil
					end

					if option then
						local finalValue
						if invert then
							finalValue = not value
						else
							finalValue = value
						end

						OPTIONS[option] = finalValue
						CustomOptions_valid[option] = true
					end
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

	if not writefile and not OPTIONS.Callback then
		local function coreCall(method, ...)
			local StarterGui = service.StarterGui
			method = StarterGui[method]
			if not method then
				return
			end

			for _ = 1, 10 do -- maxtries
				local success, result = pcall(method, StarterGui, ...)
				if success then
					return result
				end
				task.wait(1)
			end
		end

		local text = 'Function "writefile" is NOT available\nUse the Option "Callback" instead for now (check docs)'

		coreCall("SetCore", "SendNotification", {
			Title = "SAVEINSTANCE ERROR",
			Text = text,
			Duration = 15,
			Icon = "rbxassetid://9072920609",
		})
		coreCall("SetCore", "SendNotification", {
			Title = "SAVEINSTANCE ERROR",
			Text = "Please ask your executor's developers to add writefile",
			Duration = 15,
			Icon = "rbxassetid://9072920609",
		})

		warn(text)

		GLOBAL_ENV.USSI = nil
		return
	end

	do
		local RiskyOption = OPTIONS.RiskyServicesDisabled
		if type(RiskyOption) == "table" then
			RiskyServicesDisabled.UGC = RiskyOption.UGC
			RiskyServicesDisabled.Encoding = RiskyOption.Encoding
			RiskyServicesDisabled.Reflection = RiskyOption.Reflection
		end
	end

	local InstancesOverrides = {}

	local DecompileIgnore, IgnoreList, IgnoreProperties, NotCreatableFixes =
		arrayToDict(OPTIONS.DecompileIgnore, true),
		arrayToDict(OPTIONS.IgnoreList, true),
		arrayToDict(OPTIONS.IgnoreProperties),
		arrayToDict(OPTIONS.NotCreatableFixes, true, "Folder")

	local CopyToClipboard = OPTIONS.CopyToClipboard
	local Callback = OPTIONS.Callback

	local CompressionLevel = OPTIONS.CompressionLevel
	local CompressionMode = OPTIONS.CompressionMode

	local __DEBUG_MODE = OPTIONS.__DEBUG_MODE

	if __DEBUG_MODE and type(__DEBUG_MODE) ~= "function" then
		__DEBUG_MODE = warn
	end

	local LP_UserId, LP_Name, ANON_UserId, ANON_Name, Anonymizers

	local function anonymize(raw, valueType)
		local fn = Anonymizers and Anonymizers[valueType]
		return fn and fn(raw) or raw
	end

	local function gsubCaseInsensitive(input, search, replacement)
		local inputLower = string.lower(input)
		search = string.lower(search)

		if not string_find(inputLower, search) then
			return input
		end

		local lastFinish = 0
		local subStrings = {}
		local search_len = #search
		local input_len = #input
		while search_len <= input_len - lastFinish do
			local init = lastFinish + 1

			local start, finish = string_find(inputLower, search, init)

			if start == nil then
				break
			end

			table.insert(subStrings, string.sub(input, init, start - 1))

			lastFinish = finish
		end

		if lastFinish == 0 then
			return input
		end

		table.insert(subStrings, string.sub(input, lastFinish + 1))

		return table.concat(subStrings, replacement)
	end

	do
		local anonymous = OPTIONS.Anonymous
		local lp = service.Players.LocalPlayer

		if anonymous and lp then
			LP_UserId, LP_Name = lp.UserId, lp.Name

			local istable = type(anonymous) == "table"
			ANON_UserId = istable and anonymous.UserId or 1
			ANON_Name = istable and anonymous.Name or "Roblox"

			-- for BinaryString/SharedString
			local padded = ANON_Name
			if #padded < #LP_Name then
				padded ..= string.rep("_", #LP_Name - #padded)
			elseif #padded > #LP_Name then
				padded = string.sub(padded, 1, #LP_Name)
			end

			local function scrubName(raw)
				return gsubCaseInsensitive(raw, LP_Name, ANON_Name)
			end
			local function scrubFixedWidth(raw)
				return gsubCaseInsensitive(raw, LP_Name, padded)
			end
			local function scrubId(raw)
				return raw == LP_UserId and ANON_UserId or raw
			end

			Anonymizers = {
				string = scrubName,
				BinaryString = scrubFixedWidth,
				SharedString = scrubFixedWidth,
				double = scrubId,
				float = scrubId,
				int = scrubId,
				int64 = scrubId,
			}
		end
	end

	local FilePath = OPTIONS.FilePath
	local SaveCacheInterval = OPTIONS.SaveCacheInterval
	local Object = OPTIONS.Object
	local IsModel = OPTIONS.IsModel

	if Object and CustomOptions.IsModel == nil then
		IsModel = true
	end

	local IgnoreDefaultProperties = OPTIONS.IgnoreDefaultProperties
	local IgnoreNotArchivable = not OPTIONS.IgnoreNotArchivable
	local IgnorePropertiesOfNotScriptsOnScriptsMode = OPTIONS.IgnorePropertiesOfNotScriptsOnScriptsMode

	local old_gethiddenproperty
	if OPTIONS.IgnoreSpecialProperties and gethiddenproperty then
		old_gethiddenproperty = gethiddenproperty
		gethiddenproperty = nil
	end

	local SaveNotCreatable = OPTIONS.SaveNotCreatable
	local TreatUnionsAsParts = OPTIONS.TreatUnionsAsParts

	local SharedBinaryStrings = OPTIONS.SharedBinaryStrings

	local ToSaveList, ldecompile, placename, elapse_t, SaveNotCreatableWillBeEnabled, RecoveredScripts

	if OPTIONS.ReadMe then
		RecoveredScripts = {}
	end

	if Object == game then
		OPTIONS.mode = "full"
		Object = nil
		IsModel = nil
	end

	local function isLuaSourceContainer(instance)
		return instance:IsA("LuaSourceContainer")
	end

	local function sanitizeFileName(str)
		return string.sub(string.gsub(string.gsub(string.gsub(str, "[^%w _]", ""), " +", " "), " +$", ""), 1, 240)
	end

	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = table.clone(OPTIONS.ExtraInstances)

		local PlaceName = game.PlaceId

		pcall(function()
			PlaceName ..= " " .. service.MarketplaceService:GetProductInfoAsync(PlaceName).Name
		end)

		if Object then
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
				if CustomOptions_valid[key] == nil then
					OPTIONS[key] = false
				end
			end
		end

		local filetype = OPTIONS.Binary and (IsModel and ".rbxm" or ".rbxl") or (IsModel and ".rbxmx" or ".rbxlx")

		if FilePath then
			local hasExtension = string.match(FilePath, "%.[^/\\]+$") ~= nil
			placename = hasExtension and FilePath or (FilePath .. filetype)
		elseif IsModel then
			placename = sanitizeFileName("model " .. PlaceName .. " " .. (Object or tmp[1] or game):GetFullName())
		else
			placename = sanitizeFileName("place " .. PlaceName)
		end

		if FilePath then
		elseif OPTIONS.AvoidFileOverwrite and isfile then
			local counter = 0
			local temp = placename

			while isfile(temp .. filetype) do
				counter += 1
				temp = placename .. "(" .. counter .. ")"
			end

			placename = temp .. filetype
		else
			placename = placename .. filetype
		end

		if GLOBAL_ENV[placename] then -- ? AvoidFileOverwrite kinda messes with this, but shouldn't be an issue
			-- warn("UniversalSynSaveInstance is already saving to this file")
			return
		end

		GLOBAL_ENV[placename] = true
		GLOBAL_ENV.USSI = nil

		if mode ~= "scripts" then
			IgnorePropertiesOfNotScriptsOnScriptsMode = nil
		end

		local TempRoot = Object or game

		if mode == "full" then
			if not Object then
				local Children = TempRoot:GetChildren()
				if 0 < #Children then
					local tmp_dict = arrayToDict(tmp)
					for _, child in Children do
						if not tmp_dict[child] then
							table.insert(tmp, child)
						end
					end
				end
			end
		elseif mode == "optimized" then -- ! Incompatible with .rbxmx (Model file) mode
			-- if IsolatePlayers then
			-- 	table.insert(_list_0, "Players")
			-- end
			local tmp_dict = arrayToDict(tmp)

			for _, serviceName in
				{
					"Workspace",
					"Players",
					"Lighting",
					"MaterialService",
					"ReplicatedFirst",
					"ReplicatedStorage",

					"ServerScriptService", -- LoadStringEnabled property (doesn't replicate); Just in case
					"ServerStorage", -- Just in case

					"StarterGui",
					"StarterPack",
					"StarterPlayer",
					"Teams",
					"SoundService",
					"Chat",
					"TextChatService",

					"LocalizationService", -- For LocalizationTables
					-- "InsertService",
					"JointsService",

					-- "TestService",
					-- "VoiceChatService",
				}
			do
				local _service = game:FindService(serviceName)
				if _service and not tmp_dict[_service] then
					table.insert(tmp, _service)
				end
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

		if Object then
			table.insert(ToSaveList, 1, Object)
		end
	end

	local IsolateLocalPlayer = OPTIONS.IsolateLocalPlayer
	local IsolateLocalPlayerCharacter = OPTIONS.IsolateLocalPlayerCharacter
	local IsolatePlayers = OPTIONS.IsolatePlayers
	local IsolateStarterPlayer = OPTIONS.IsolateStarterPlayer
	local NilInstances = OPTIONS.NilInstances

	if IsolatePlayers and IsolateLocalPlayer then
		IsolateLocalPlayer = false
	end

	local function GetLocalPlayer()
		return service.Players.LocalPlayer
			or service.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
			or service.Players.LocalPlayer
	end

	local function get_size_format()
		local Size

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

	local RunService = service.RunService
	local function wait_for_render()
		RunService.RenderStepped:Wait()
	end

	local IsLoading, LoadingText, LoadingThread = false

	local function ensureSpinner()
		if LoadingThread then
			return
		end
		LoadingThread = task.spawn(function()
			local chars = { "|", "/", "—", "\\" }
			local i = 0
			while true do
				while not IsLoading do
					task.wait()
				end

				while IsLoading do
					i = i % #chars + 1
					if StatusText and LoadingText then
						StatusText.Text = LoadingText .. " " .. chars[i]
					end
					task.wait(0.25)
				end
			end
		end)
	end

	local function run_with_loading(text, keepStatus, waitForRender, taskFunction, ...)
		local previousStatus
		if StatusText then
			if keepStatus then
				previousStatus = StatusText.Text
			end
			LoadingText = text
			IsLoading = true
			ensureSpinner()
			if waitForRender then
				wait_for_render()
			end
		end

		local result = { taskFunction(...) }

		if StatusText then
			IsLoading = false
			if previousStatus then
				StatusText.Text = previousStatus
			end
		end
		return unpack(result)
	end

	local function makeTimeoutHandler(timeout, f, timeout_return)
		if timeout < 0 then
			return function(...)
				return pcall(f, ...)
			end
		end

		local worker
		local pendingJob

		local function spawnWorker()
			return task.spawn(function()
				while true do
					while not pendingJob do
						task.wait()
					end

					local job = pendingJob
					pendingJob = nil

					local ok, result = pcall(f, unpack(job.args))

					if job.isCancelled then
						return -- this worker is retired
					end

					task.cancel(job.timeoutThread)

					local thread = job.thread
					while coroutine.status(thread) ~= "suspended" do
						task.wait()
					end

					coroutine.resume(thread, ok, result)
				end
			end)
		end

		return function(...)
			local thread = coroutine.running()
			local job = {
				thread = thread,
				args = { ... },
			}

			job.timeoutThread = task.delay(timeout, function()
				job.isCancelled = true
				worker = nil -- retire this worker; a fresh one spawns for the next call
				coroutine.resume(thread, nil, timeout_return)
			end)

			if not worker then
				worker = spawnWorker()
			end
			pendingJob = job

			return coroutine.yield()
		end
	end

	local decompileIgnoreMap = {}

	local DecompileJobless = OPTIONS.DecompileJobless

	if DecompileJobless then
		OPTIONS.scriptcache = true
	end
	local ScriptCache = OPTIONS.scriptcache and getscriptbytecode
	local ldeccache = GLOBAL_ENV.USSI_scriptcache

	if ScriptCache and not ldeccache then
		ldeccache = {}
		GLOBAL_ENV.USSI_scriptcache = ldeccache
	end

	local getbytecode
	if getscriptbytecode then
		getbytecode = makeTimeoutHandler(OPTIONS.BytecodeTimeout, getscriptbytecode) -- ? Solara fix
	end

	local SaveBytecode
	if OPTIONS.SaveBytecode and getscriptbytecode then
		SaveBytecode = function(script)
			local s, bytecode = getbytecode(script)

			if s and bytecode and bytecode ~= "" then
				return "-- Bytecode (Base64):\n-- " .. base64encode(bytecode) .. "\n\n"
			end
		end
	end

	if not OPTIONS.Decompile then
		ldecompile = function()
			return "-- Decompiling is disabled"
		end
	elseif decompile then
		local decomp = makeTimeoutHandler(OPTIONS.DecompileTimeout, decompile, "Decompiler timed out")

		ldecompile = function(script)
			-- local name = scr.ClassName .. scr.Name
			local bytecode
			if ScriptCache then
				local s
				s, bytecode = getbytecode(script)
				local cached

				if s then
					if not bytecode or bytecode == "" then
						return "-- The Script is Empty"
					end
					cached = ldeccache[bytecode]
				else
					bytecode = nil
				end

				if cached then
					if __DEBUG_MODE then
						__DEBUG_MODE("Found in Cache", script:GetFullName())
					end
					return cached
				end
			else
				if DecompileJobless then
					return "-- Not found in already decompiled ScriptCache"
				end

				-- task.wait() -- TODO Maybe remove?
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
				output = "--[[ Failed to decompile. Reason:\n" .. (result or "") .. "\n]]"
			end

			if ScriptCache and bytecode then -- TODO there might(?) be an edgecase where it manages to decompile (built-in) even though getscriptbytecode failed, and the output won't get cached
				ldeccache[bytecode] = output -- ? Should we cache even if it timed out?
				if __DEBUG_MODE then
					__DEBUG_MODE("Cached", script:GetFullName())
				end
			end

			return output
		end
	else
		ldecompile = function()
			return "-- Your Executor does NOT have a Decompiler"
		end
	end

	local function filterLinkedSource(str)
		local o, r = pcall(service.HttpService.JSONDecode, service.HttpService, str)
		if o and r.errors then
			return
		end
		return true
	end
	local function sourceFor(instance, ldIgnoring)
		if ldIgnoring then
			return "-- Ignored"
		end
		local value
		local should_decompile = true
		local LinkedSource
		local o, LinkedSource_Url = pcall(index, instance, "LinkedSource") -- ! AuroraScript has Source but not LinkedSource
		if not o then
			LinkedSource_Url = ""
		end
		local hasLinkedSource = LinkedSource_Url ~= ""
		local LinkedSource_type
		if hasLinkedSource then
			local Path = instance:GetFullName()
			if RecoveredScripts then
				table.insert(RecoveredScripts, Path)
			end

			LinkedSource = string.match(LinkedSource_Url, "%w+$") -- TODO: No sure if this pattern matches all possible cases. Example is: 'rbxassetid://0&hash=cd73dd2fe5e5013137231c227da3167e'
			if LinkedSource then
				if ScriptCache then
					local cached = ldeccache[LinkedSource]

					if cached then
						value = cached
						should_decompile = nil
					end
				end
				if should_decompile then
					if DecompileJobless then
						value = "-- Not found in LinkedSource ScriptCache"
						should_decompile = nil
					end

					LinkedSource_type = string.find(LinkedSource, "%a") and "hash" or "id"

					local asset = LinkedSource_type .. "=" .. LinkedSource

					local ok, source = pcall(function()
						-- Credits @halffalse
						return game:HttpGet("https://assetdelivery.roproxy.com/v1/asset/?" .. asset)
					end)

					if ok and filterLinkedSource(source) then
						if ScriptCache then
							ldeccache[LinkedSource] = source
						end

						value = source

						should_decompile = nil
					end
				end
			else --if __DEBUG_MODE then -- * We print this anyway because very important
				warn("FAILED TO EXTRACT LINKEDSOURCE (OPEN A GITHUB ISSUE): ", instance:GetFullName(), LinkedSource_Url)
			end
		end

		if should_decompile then
			local isLocalScript = instance:IsA("LocalScript")
			if
				isLocalScript and instance.RunContext == Enum.RunContext.Server
				or not isLocalScript and instance:IsA("Script") and instance.RunContext ~= Enum.RunContext.Client
			then
				value = "-- [FilteringEnabled] Server Scripts are IMPOSSIBLE to save" -- TODO: Could be not just server scripts in the future
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

		value = "-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw\n\n"
			.. (hasLinkedSource and "-- Original Source: https://assetdelivery.roblox.com/v1/asset/?" .. (LinkedSource_type or "id") .. "=" .. (LinkedSource or LinkedSource_Url) .. "\n\n" or "")
			.. value

		return value
	end

	local function replaceClassName(instance, InstanceName, ClassName)
		local InstanceOverride = InstancesOverrides[instance]

		if InstanceOverride then
			return InstanceOverride
		end

		if InstanceName ~= ClassName then -- TODO Compare against default instance instead (TouchTransmitter is called TouchInterest by default)
			InstanceOverride = { Properties = { Name = "[" .. ClassName .. "] " .. InstanceName } }
			InstancesOverrides[instance] = InstanceOverride
		end

		return InstanceOverride
	end

	local function refIsInvalid(target, valueType)
		if not SaveNotCreatableWillBeEnabled or not target then
			return false
		end
		local fix = NotCreatableFixes[target.ClassName]
		return fix ~= nil and (valueType ~= "Instance" and valueType ~= fix)
	end

	local function nilIsValid(category, optional)
		return optional ~= nil or category == "Class"
	end

	local function filterPropVal(result, propertyName, category, optional) -- ? raw == nil thanks to SerializedDefaultAttributes; "can't get value" - due to WriteOnly tag;  "Invalid value for enum " - "StreamingPauseMode" (old games probably) Roexec
		if result == nil then
			return not nilIsValid(category, optional)
		end
		return result == "can't get value"
			or type(result) == "string"
				and (category == "Enum" or string_find(result, "Unable to get property " .. propertyName))
	end

	local GHP_STATE_FILE = USSI_FOLDER .. "GHP_STATE.json"
	local GHPDatatypeState = {}
	local GHPPersisted = {}
	local GHPVersionKey

	do
		local execName, execVersion = "UNKNOWN", "0"
		if identify_executor then
			local ok, name, ver = pcall(identify_executor)
			if ok and name then
				execName, execVersion = name, ver or "0"
			end
		end

		GHPVersionKey = sanitizeFileName(execName)
			.. "_"
			.. sanitizeFileName(execVersion)
			.. "_"
			.. sanitizeFileName(FULL_VERSION)

		if readfile then
			local ok, decoded = pcall(function()
				return service.HttpService:JSONDecode(readfile(GHP_STATE_FILE))
			end)
			if ok and type(decoded) == "table" and type(decoded[GHPVersionKey]) == "table" then
				GHPPersisted = decoded[GHPVersionKey]
			end
		end
	end

	local function saveGHPState()
		if not writefile then
			return
		end
		pcall(writefile, GHP_STATE_FILE, service.HttpService:JSONEncode({ [GHPVersionKey] = GHPPersisted }))
	end

	local function ghpDatatypeAllowed(valueType)
		local state = GHPDatatypeState[valueType]
		if state ~= nil then
			return state
		end

		local persisted = GHPPersisted[valueType]
		if persisted == "ok" then
			state = true
		elseif persisted == "failed" or persisted == "testing" then
			state = false
		else
			GHPPersisted[valueType] = "testing"
			saveGHPState()
			state = true
		end

		GHPDatatypeState[valueType] = state
		return state
	end

	local function ghpDatatypeReport(valueType, ok)
		local wantState = ok and "ok" or "failed"
		if GHPPersisted[valueType] == wantState then
			return
		end
		GHPPersisted[valueType] = wantState
		GHPDatatypeState[valueType] = ok
		saveGHPState()
	end

	local function readProperty(instance, property)
		local raw = __BREAK

		local PropertyName, Special, Category, ValueType, Optional =
			property.Name, property.Special, property.Category, property.ValueType, property.Optional

		local InstanceOverride = InstancesOverrides[instance]
		if InstanceOverride then
			local PropertiesOverride = InstanceOverride.Properties
			if PropertiesOverride then
				local PropertyOverride = PropertiesOverride[PropertyName]
				if PropertyOverride ~= nil then
					return anonymize(PropertyOverride, ValueType)
				end
			end
		end

		if ValueType == "ProtectedString" and PropertyName == "Source" and isLuaSourceContainer(instance) then
			return sourceFor(instance, decompileIgnoreMap[instance])
		end

		local CanRead = property.CanRead
		if CanRead ~= false then
			local GHPKey = (Category == "Enum" or Category == "Class") and Category or ValueType

			if Special then
				if gethiddenproperty and ghpDatatypeAllowed(GHPKey) then
					local ok, result = pcall(gethiddenproperty, instance, PropertyName)
					if ok then
						raw = result
					end

					local filtered = filterPropVal(raw, PropertyName, Category, Optional)
					local realFailure = filtered and not (result == nil and nilIsValid(Category, Optional))

					ghpDatatypeReport(GHPKey, ok and not realFailure)

					if filtered then
						if realFailure then
							if __DEBUG_MODE then
								__DEBUG_MODE("Filtered", PropertyName)
							end
							property.CanRead = false
						end
						raw = __BREAK
					end
				end
			elseif CanRead then
				raw = instance[PropertyName]
			else
				local ok, result = pcall(index, instance, PropertyName)
				if ok then
					raw = result
				elseif gethiddenproperty and ghpDatatypeAllowed(GHPKey) then
					ok, result = pcall(gethiddenproperty, instance, PropertyName)
					ghpDatatypeReport(GHPKey, ok and not filterPropVal(result, PropertyName, Category, Optional))
					if ok then
						raw = result
						property.Special = true
					end
				end

				property.CanRead = ok

				if not ok or filterPropVal(raw, PropertyName, Category, Optional) then
					raw = __BREAK
				end
			end

			if raw ~= __BREAK then
				return anonymize(raw, ValueType)
			end
		end

		-- Fallback chain

		local GHPFFailed, Fallback = property.GHPFFailed, property.Fallback
		if GHPFFailed and not Fallback then
			return __BREAK
		end

		if not GHPFFailed then
			local ok, result = pcall(gethiddenproperty_fallback, instance, PropertyName)
			if result == nil and not nilIsValid(Category, Optional) then
				ok = nil
			end
			if ok then
				return anonymize(result, ValueType)
			end
			GHPFFailed = true
			property.GHPFFailed = true
		end

		if GHPFFailed and Fallback then
			local ok, result = pcall(Fallback, instance)
			if ok then
				return anonymize(result, ValueType)
			end
			property.Fallback = nil
			if __DEBUG_MODE then
				__DEBUG_MODE("Fix Failed", PropertyName, result)
			end
		end

		return __BREAK
	end

	local function ReturnItem(className, instance)
		return '<Item class="' .. className .. '" referent="' .. getRef(instance) .. '"><Properties>' -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is Enabled OR If all properties are default (reduces file size by at least 1.4%)
	end

	local function ReturnProperty(tag, propertyName, value)
		return "<" .. tag .. ' name="' .. propertyName .. '">' .. value .. "</" .. tag .. ">"
	end

	local function ReturnValueAndTag(raw, valueType, encoder)
		local value, tag = (encoder or XML_Encoders[valueType])(raw)

		return value, tag or valueType
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
		local cached = inheritedProperties[className]
		if cached then
			return cached
		end

		local prop_list = {}
		local layer = ClassList[className]
		while layer do
			local layer_props = layer.Properties
			table.move(layer_props, 1, #layer_props, #prop_list + 1, prop_list)

			layer = ClassList[layer.Superclass]
		end
		inheritedProperties[className] = prop_list
		return prop_list
	end

	-- Three class names per instance, all distinct in purpose:
	--   tag       -- written as the class name (XML). May be an unknown class.
	--   class     -- the resolved, instantiable class (binary INST). Never unknown.
	--   propClass -- whose property list to read (union rewrite points elsewhere)
	local function collect(roots)
		local ctx = {
			entries = {},
			classList = {},
			ordered = {},
			refs = {},
			instCount = 0,
			instTypeCount = 0,
		}

		local entries, classList = ctx.entries, ctx.classList
		local ordered, refs = ctx.ordered, ctx.refs

		local function recur(instance, parent, ldIgnore)
			if entries[instance] then
				return -- already collected via another root
			end

			local override = InstancesOverrides[instance]
			local tagOverride = override and override.__ClassName
			local virtual = override and override.__Virtual

			local class = virtual or instance.ClassName
			local name = virtual and override.Properties.Name or instance.Name
			local unknownTag, propClass, skipEntirely

			local own = DecompileIgnore[instance]
			if own == nil then
				local byClass = DecompileIgnore[class]
				if byClass ~= nil then
					own = byClass == true or byClass[name]
				end
			end
			if own == true then
				ldIgnore = true
			elseif own == false then
				ldIgnore = "self"
			end
			if ldIgnore then
				decompileIgnoreMap[instance] = true
			end

			if not tagOverride then
				if IgnoreNotArchivable and not instance.Archivable then
					return
				end

				skipEntirely = IgnoreList[instance]
				if skipEntirely then
					return
				end

				local onIgnoredList = IgnoreList[class]
				if onIgnoredList and (onIgnoredList == true or onIgnoredList[name]) then
					return
				end

				local fix = NotCreatableFixes[class]

				if fix then
					if not SaveNotCreatable then
						return -- They won't show up in Studio anyway (Enable SaveNotCreatable if you wish to bypass this)
					end
					class, override = fix, replaceClassName(instance, name, class)
				elseif TreatUnionsAsParts and instance:IsA("PartOperation") then
					class, override = "Part", replaceClassName(instance, name, class)
					propClass = "BasePart"
				elseif not ClassList[class] then
					if __DEBUG_MODE then
						__DEBUG_MODE("Class not Found", class)
					end
					unknownTag, class = class, "Folder"
				end
			end

			local e = {
				tag = unknownTag or tagOverride or class,

				class = tagOverride or class,
				propClass = propClass or class,
				override = override,
				-- Skip the property pass: nothing on these is worth reading.
				-- Virtual nodes aren't instances at all, and NilInstancesFixes
				-- containers are freshly-made holders. Their children are read
				-- normally, as are NotCreatableFixes instances -- those are real,
				-- with real tags and attributes.
				propsOnly = virtual ~= nil or (override and override.__Synthetic),
				virtual = virtual ~= nil,
				-- Single source of truth for the tree: XML nests via children,
				-- binary's PRNT reads this. The prune edits both together.
				parent = parent,
			}
			entries[instance] = e

			ctx.instCount += 1
			refs[instance] = ctx.instCount - 1

			local bucket = e.tag
			if e.propsOnly then
				bucket ..= "\0" .. e.propClass .. "\0propsOnly"
			elseif e.propClass ~= bucket then
				bucket ..= "\0" .. e.propClass
			end
			local list = classList[bucket]
			if not list then
				list = {}
				classList[bucket] = list
				ctx.instTypeCount += 1
			end
			list[#list + 1] = instance

			local kids
			if skipEntirely ~= false then
				local children = (override and override.__Children) or (not virtual and instance:GetChildren())

				kids = table.create(#children)
				for _, child in children do
					recur(child, instance, ldIgnore == true and true or nil)
					if entries[child] then
						kids[#kids + 1] = child
					end
				end
			end
			e.children = kids or {}
			ordered[#ordered + 1] = instance
		end

		local roots_kept = table.create(#roots)
		for _, root in roots do
			recur(root)
			if entries[root] then
				roots_kept[#roots_kept + 1] = root
			end
		end
		ctx.roots = roots_kept

		return ctx
	end

	local function newVirtual(className, properties, children)
		local node = {}
		InstancesOverrides[node] = {
			__ClassName = className,
			__Virtual = className,
			__Children = children or {},
			Properties = properties,
		}
		return node
	end

	local pendingExtras = {}

	local function register_extra(name, instanceOrTable, saveProps, customClassName, source)
		customClassName = customClassName or "Folder"
		local properties = { Name = name, Source = source }
		local extra = { customClassName = customClassName, properties = properties }

		if instanceOrTable and saveProps and type(instanceOrTable) ~= "table" then
			local existing = InstancesOverrides[instanceOrTable]
			if existing then
				existing.__ClassName = customClassName
				existing.Properties = properties
			else
				InstancesOverrides[instanceOrTable] = {
					__ClassName = customClassName,
					Properties = properties,
				}
			end
			extra.roots = { instanceOrTable }
		else
			local children
			if instanceOrTable then
				children = type(instanceOrTable) == "table" and instanceOrTable or instanceOrTable:GetChildren()
			end
			extra.roots = { newVirtual(customClassName, properties, children) }
		end

		pendingExtras[#pendingExtras + 1] = extra
		return extra
	end

	local function readAll(objs, prop)
		local n = #objs
		local vals = table.create(n)

		for i = 1, n do
			local raw = readProperty(objs[i], prop)
			if raw == __BREAK then
				return nil, i
			end
			vals[i] = raw
		end

		return vals
	end

	local function buildChunk(name, chunkBuf, compress)
		local uncompressedLen = chunkBuf.len
		local head = StreamBuffer.new(16)

		head:writestring(name)

		if compress then
			local dataStr = compress(chunkBuf:tostring())
			if dataStr and #dataStr < uncompressedLen then
				head:writeu32(#dataStr)
				head:writeu32(uncompressedLen)
				head:writeu32(0) -- reserved
				return { buf = head.buf, len = head.len, str = dataStr }
			end
		end

		head:writeu32(0) -- 0 signals "uncompressed, use uncompressedLength"
		head:writeu32(uncompressedLen)
		head:writeu32(0) -- reserved

		return {
			buf = head.buf,
			len = head.len,
			tailBuf = chunkBuf.buf,
			tailLen = uncompressedLen,
		}
	end
	local function emitBinary(ctx)
		local compress = CompressionMode == "zstd"
				and function(raw)
					return zstdcompress(raw, CompressionLevel)
				end
			or CompressionMode == "lz4" and lz4compress
			or nil

		local entries, classList = ctx.entries, ctx.classList
		local refs, ordered = ctx.refs, ctx.ordered
		local instCount, instTypeCount = ctx.instCount, ctx.instTypeCount

		-- Chunk assembly

		local chunks = {}

		local lastStatus = 0

		local function emit(chunk)
			chunks[#chunks + 1] = chunk
			totalsize += chunk.len + (chunk.str and #chunk.str or chunk.tailLen or 0)

			if StatusText then
				local now = os.clock()
				if now - lastStatus > 1 then
					lastStatus = now
					StatusText.Text = "Saving.. Size: " .. get_size_format()
				end
			end
		end

		do
			local header = StreamBuffer.new(32)
			header:writestring("\60\114\111\98\108\111\120\33\137\255\13\10\26\10\0\0") -- magic
			header:writei32(instTypeCount)
			header:writei32(instCount)
			header:fill(0, 8) -- reserved tail of the file header
			emit({ buf = header.buf, len = header.len })
		end

		if IsModel then
			local metaBuf = StreamBuffer.new(64)
			metaBuf:writeu32(1)
			metaBuf:writeLenString("ExplicitAutoJoints")
			metaBuf:writeLenString("true")
			emit(buildChunk("META", metaBuf, compress))
		end

		-- Reserve SSTR's slot: it must precede the INST/PROP chunks that
		-- reference it, but its contents aren't known until they're encoded.
		local sstrSlot = #chunks + 1

		-- Index 0 is reserved as the null/empty entry: unreadable or genuinely
		-- empty values serialize as index 0 rather than allocating a pool slot.
		local sharedStringCtx = { count = 0, order = {}, hashes = {} }

		local classId = 0
		local deferredBuckets

		local function encode_class_bucket(objs)
			local n = #objs
			local entry = entries[objs[1]]

			local class = entry.class

			local instBuf = StreamBuffer.new(64 + 4 * n)
			instBuf:writeu32(classId)
			instBuf:writeLenString(class)
			local classInfo = ClassList[class]

			local isService = classInfo and classInfo.Service
			instBuf:writeu8(isService and 1 or 0)
			instBuf:writeu32(n)

			writeRefPlane(instBuf, n, instBuf:allocRegion(4 * n), function(i)
				return refs[objs[i]]
			end)

			if isService then
				for _ = 1, n do
					instBuf:writeu8(1)
				end
			end

			emit(buildChunk("INST", instBuf, compress))

			-- PROP chunks
			local skipProps = IgnorePropertiesOfNotScriptsOnScriptsMode
				and not entry.propsOnly
				and not isLuaSourceContainer(objs[1])

			if entry.propsOnly then
				for propName in entry.override.Properties do
					local isSource = propName == "Source"
					local buf = StreamBuffer.new(64 + n * 16)
					buf:writeu32(classId)
					buf:writeLenString(propName)
					buf:writeu8(isSource and Type_Ids.ProtectedString or Type_Ids.string)

					for i = 1, n do
						local value = entries[objs[i]].override.Properties[propName]
						if type(value) == "function" then
							value = value() -- Deferred Source (README): resolved at encode time
						end
						buf:writeLenString(value or "")
					end

					emit(buildChunk("PROP", buf, not isSource and compress or nil)) -- ! Assumes README is the only one that uses .Source, expect anything that does to be uncompressed
				end
			elseif not skipProps then
				for _, prop in GetInheritedProps(entry.propClass) do
					local propName = prop.Name
					if IgnoreProperties[propName] then
						continue
					end

					local valueType = prop.ValueType

					if SharedBinaryStrings and valueType == "BinaryString" then
						valueType = "SharedString"
					end

					local refCtxArg = nil

					if prop.Category == "Enum" then
						valueType = "Enum"
					elseif prop.Category == "Class" then
						valueType = "Referent"
						refCtxArg = refs
					elseif valueType == "Content" then
						refCtxArg = refs
					end

					local encoder = Binary_Encoders[valueType]
					local typeId = Type_Ids[valueType]
					if typeId == Type_Ids.SharedString then
						refCtxArg = sharedStringCtx
					end

					local vals, failedAt = readAll(objs, prop)
					if not vals then
						if __DEBUG_MODE then
							__DEBUG_MODE("PROP dropped", class, propName, "n=" .. #objs, "failed at " .. failedAt)
						end
						continue
					end

					if encoder and typeId then
						if prop.Category == "Class" then
							for i = 1, n do
								if refIsInvalid(vals[i], valueType) then
									vals[i] = nil
								end
							end
						end

						local propBuf = StreamBuffer.new(128 + #objs * 4)
						propBuf:writeu32(classId)
						propBuf:writeLenString(propName)
						propBuf:writeu8(typeId)

						encoder(propBuf, vals, #objs, refCtxArg)
						emit(buildChunk("PROP", propBuf, compress))
					else
						warn("UNSUPPORTED BINARY TYPE (OPEN A GITHUB ISSUE): ", propName, valueType)
					end
				end
			end

			classId += 1
		end

		for _, objs in classList do
			if entries[objs[1]].deferLast then
				deferredBuckets = deferredBuckets or {}
				table.insert(deferredBuckets, objs)
			else
				encode_class_bucket(objs)
			end
		end

		if deferredBuckets then
			for _, objs in deferredBuckets do
				encode_class_bucket(objs)
			end
		end

		-- SSTR must land before the INST/PROP chunks it's referenced from, so it
		-- goes into the reserved slot rather than at the current end.
		if sharedStringCtx.count > 0 then
			local sstrBuf = StreamBuffer.new(64 + sharedStringCtx.count * 32)
			sstrBuf:writeu32(0) -- version
			sstrBuf:writeu32(sharedStringCtx.count)
			for i = 1, sharedStringCtx.count do
				sstrBuf:fill(0, 16) -- hash; Studio and rbx-dom both write zeros
				sstrBuf:writeLenString(sharedStringCtx.order[i])
			end
			local chunk = buildChunk("SSTR", sstrBuf, compress)
			table.insert(chunks, sstrSlot, chunk)

			totalsize += chunk.len + (chunk.str and #chunk.str or chunk.tailLen or 0)
		end

		-- PRNT chunk: two interleaved i32 zigzag-delta planes (object ref, parent ref)
		do
			local prntBuf = StreamBuffer.new(16 + instCount * 8)
			prntBuf:writeu8(0) -- version byte
			prntBuf:writeu32(instCount)

			local objBase = prntBuf:allocRegion(4 * instCount)
			local parBase = prntBuf:allocRegion(4 * instCount)

			writeRefPlane(prntBuf, instCount, objBase, function(i)
				return refs[ordered[i]]
			end)
			writeRefPlane(prntBuf, instCount, parBase, function(i)
				local par = entries[ordered[i]].parent
				return (par and refs[par]) or -1
			end)

			emit(buildChunk("PRNT", prntBuf, compress))
		end

		-- END chunk: fixed, never compressed.
		do
			local endBuf = StreamBuffer.new(16)
			endBuf:writestring("</roblox>")
			emit(buildChunk("END\0", endBuf, nil))
		end

		-- Single exact-size allocation, one per chunk part.
		local out = table.create(#chunks)

		for i, c in chunks do
			local part = buffer.readstring(c.buf, 0, c.len)
			if c.str then
				part ..= c.str
			elseif c.tailBuf then
				part ..= buffer.readstring(c.tailBuf, 0, c.tailLen)
			end
			out[i] = part
		end

		return out
	end

	local function emitXML(ctx)
		local chunks = table.create(1)
		local savebuffer, savebuffer_size = {}, 1
		local header =
			'<!-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw --><roblox version="4">'

		local function save_cache()
			local savestr = table.concat(savebuffer)

			local savestr_len = #savestr
			totalsize += savestr_len

			table.insert(chunks, savestr)

			table.clear(savebuffer)
			savebuffer_size = 1

			if StatusText then
				StatusText.Text = "Saving.. Size: " .. get_size_format()
			end

			wait_for_render() -- ? Needed for at least 1fps (status text)
		end
		local function save_hierarchy(hierarchy, ctx)
			local entries = ctx.entries

			for _, instance in hierarchy do
				local entry = entries[instance]
				if not entry then
					continue -- filtered out by collect
				end

				savebuffer[savebuffer_size] = ReturnItem(entry.tag, instance)
				savebuffer_size += 1

				if entry.propsOnly then
					for propName, value in entry.override.Properties do
						if type(value) == "function" then
							value = value() -- Deferred Source (README): resolved at encode time
						end
						if value ~= nil then
							if propName == "Source" then
								savebuffer[savebuffer_size] =
									ReturnProperty("ProtectedString", propName, XML_Encoders.ProtectedString(value))
							else
								savebuffer[savebuffer_size] =
									ReturnProperty("string", propName, XML_Encoders.string(value))
							end
							savebuffer_size += 1
						end
					end
				elseif not (IgnorePropertiesOfNotScriptsOnScriptsMode and not isLuaSourceContainer(instance)) then
					local default_instance, new_def_inst

					if IgnoreDefaultProperties then
						default_instance = defaultInstances[entry.class]
						if not default_instance then
							local Class = ClassList[entry.class]
							if not Class.NotCreatable then
								local ok, result = pcall(Instance.new, entry.class) -- ! pcall is needed for level 3 execs (for example TestService); EXCEPTION NOTED ABOVE (irrelevant)
								if ok then
									new_def_inst = result
									default_instance = {}
									defaultInstances[entry.class] = default_instance
								else
									Class.NotCreatable = true
									if __DEBUG_MODE then
										__DEBUG_MODE("Failed to create default Instance", entry.class, result)
									end
								end
							elseif __DEBUG_MODE then
								__DEBUG_MODE("Unable to create default Instance (NotCreatable)", entry.class)
							end
						end
					end
					for _, Property in GetInheritedProps(entry.propClass) do
						local PropertyName = Property.Name

						if IgnoreProperties[PropertyName] then
							continue
						end

						local ValueType = Property.ValueType

						local Category, Optional = Property.Category, Property.Optional
						local raw

						raw = readProperty(instance, Property)
						if raw == __BREAK then
							continue
						end

						if
							default_instance
							and Property.CanRead
							and not Property.Special
							and ValueType ~= "ProtectedString"
						then
							if new_def_inst then
								default_instance[PropertyName] = index(new_def_inst, PropertyName)
							end
							if default_instance[PropertyName] == raw then
								continue
							end
						end

						-- if PropertyName == "AttributesSerialize" and raw ~= "" then -- TODO unreleased yet
						-- 	for name, v in instance:GetAttributes() do
						-- 		if typeof(v) == "InstanceHandle" then
						-- 			savebuffer[savebuffer_size] =
						-- 				ReturnProperty("Ref", "__attrRef_" .. name, getRef(v))
						-- 			savebuffer_size += 1
						-- 		end
						-- 	end
						-- end

						if SharedBinaryStrings and ValueType == "BinaryString" then
							ValueType = "SharedString"
						end

						local tag, value
						if Category == "Class" then
							tag = "Ref"
							if raw and not refIsInvalid(raw, ValueType) then
								value = getRef(raw)
							else
								value = "null"
							end
						elseif Category == "Enum" then
							value, tag = XML_Encoders.EnumItem(raw)
						else
							local encoder = XML_Encoders[ValueType]

							if encoder then
								value, tag = ReturnValueAndTag(raw, ValueType, encoder)
							elseif Optional then
								encoder = XML_Encoders[Optional]
								if encoder then
									if raw == nil then
										continue
									end
									value, tag = ReturnValueAndTag(raw, ValueType, encoder)
								end
							end
						end

						if tag then
							savebuffer[savebuffer_size] = ReturnProperty(tag, PropertyName, value)
							savebuffer_size += 1
						else
							warn("UNSUPPORTED XML TYPE (OPEN A GITHUB ISSUE): ", PropertyName, ValueType)
						end
					end
				end

				savebuffer[savebuffer_size] = "</Properties>"
				savebuffer_size += 1

				if SaveCacheInterval < savebuffer_size then
					save_cache()
				end

				local children = entry.children
				if #children ~= 0 then
					save_hierarchy(children, ctx)
				end

				savebuffer[savebuffer_size] = "</Item>"
				savebuffer_size += 1
			end
		end

		if IsModel then
			header ..= '<Meta name="ExplicitAutoJoints">true</Meta>'
		end

		savebuffer[savebuffer_size] = header
		savebuffer_size += 1

		save_hierarchy(ctx.mainRoots, ctx)

		for _, extra in pendingExtras do
			save_hierarchy(extra.collectedRoots, ctx)
		end

		do
			local tmp = { "<SharedStrings>" }
			for value, id in sharedStrings do
				table.insert(tmp, '<SharedString md5="' .. id .. '">' .. value .. "</SharedString>")
			end

			if 1 < #tmp then
				savebuffer[savebuffer_size] = table.concat(tmp)
				savebuffer_size += 1
				savebuffer[savebuffer_size] = "</SharedStrings>"
				savebuffer_size += 1
			end
		end

		savebuffer[savebuffer_size] = "</roblox>"
		savebuffer_size += 1
		save_cache()
		return chunks
	end

	local function save_game()
		SaveNotCreatable = SaveNotCreatable
			or IsolateLocalPlayer
			or IsolatePlayers
			or (NilInstances and global_container.getnilinstances) and true
			or false
		SaveNotCreatableWillBeEnabled = SaveNotCreatable

		-- Register extras BEFORE collecting: they set InstancesOverrides, which
		-- collect reads to decide tag/class/saveSpecific.
		if IsolateLocalPlayer or IsolateLocalPlayerCharacter then
			local LocalPlayer = service.Players.LocalPlayer
			if LocalPlayer then
				if IsolateLocalPlayer then
					register_extra("LocalPlayer", LocalPlayer, true)
				end
				if IsolateLocalPlayerCharacter then
					local Character = LocalPlayer.Character
					if Character then
						register_extra("LocalPlayer Character", Character, true, "Model")
					end
				end
			end
		end

		if IsolateStarterPlayer then
			register_extra("StarterPlayer", service.StarterPlayer)
		end

		if IsolatePlayers then
			register_extra("Players", service.Players)
		end

		if NilInstances and global_container.getnilinstances then
			local nil_instances, nil_instances_size = {}, 1

			local NilInstancesFixes = OPTIONS.NilInstancesFixes

			for _, instance in global_container.getnilinstances() do
				if instance == game then
					instance = nil
				else
					local ClassName = instance.ClassName

					local Fix = InheritsFix(NilInstancesFixes, ClassName, instance)

					if Fix then
						instance = Fix(instance, InstancesOverrides)
					end

					local Class = ClassList[ClassName]
					if Class then
						if Class.Service then -- For CSGDictionaryService, NonReplicatedCSGDictionaryService, LogService, ProximityPromptService, TestService & more
							-- instance.Parent = game
							instance = nil
						end
					end
				end
				if instance then
					nil_instances[nil_instances_size] = instance
					nil_instances_size += 1
				end
			end
			register_extra("Nil Instances", nil_instances)
		end

		local ELAPSED_PLACEHOLDER = "@@ELAPSED" .. string.gsub(service.HttpService:GenerateGUID(false), "-", "") .. "@@"
		local ELAPSED_WIDTH = "%-" .. #ELAPSED_PLACEHOLDER .. "s"

		local function stampElapsed(chunks, seconds)
			local repl = string.format(ELAPSED_WIDTH, string.format("%.6f seconds", seconds))
			if #repl ~= #ELAPSED_PLACEHOLDER then
				return
			end
			for i, chunk in chunks do
				local at = string.find(chunk, ELAPSED_PLACEHOLDER, 1, true)
				if at then
					chunks[i] = string.sub(chunk, 1, at - 1) .. repl .. string.sub(chunk, at + #ELAPSED_PLACEHOLDER)
					return
				end
			end
		end

		local readmeExtra
		if OPTIONS.ReadMe then
			local binaryNote = ""
			if not OPTIONS.Binary then
				binaryNote = [[
		If you didn't save in Binary (rbxl) - it's recommended to save the game right away to take advantage of the binary format & to preserve values of certain properties if you used IgnoreDefaultProperties setting (as they might change in the future).
		You can do that by going to FILE -> Save to File As -> Make sure File Name ends with .rbxl -> Save

]]
			end

			local helpText = [[
		ServerStorage, ServerScriptService and Server Scripts are IMPOSSIBLE to save because of FilteringEnabled.

		If your player cannot spawn into the game, please move the scripts in StarterPlayer somewhere else or delete them. Then run `game:GetService("Players").CharacterAutoLoads = true`.
		And use "Play Here" to start game instead of "Play" to spawn your Character where your Camera currently is.

		If the chat system does not work, please use the explorer and delete everything inside the TextChatService/Chat service(s).
		Or run `game:GetService("Chat"):ClearAllChildren() game:GetService("TextChatService"):ClearAllChildren()`

		If Union and MeshPart collisions don't work, run the script below in the Studio Command Bar:


		local C = game:GetService("CoreGui")
		local D = Enum.CollisionFidelity.Default

		for _, v in game:GetDescendants() do
			if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
				v.CollisionFidelity = D
			end
		end
		print("Done")

		If you can't move the Camera, run this script in the Studio Command Bar:

		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed

		Or Destroy the Camera.

		This file was generated with the following settings:
		]]

			local platformName = select(
				2,
				pcall(function()
					return service.UserInputService:GetPlatform().Name --  -- Won't work on lvl 2 execs but we can safely assume they're on PC (and likely Windows)
				end)
			) or "Unknown"

			local executorName = identify_executor and table.concat({ identify_executor() }, " ") or "Unknown"

			local metaFooter = table.concat({
				"\n\n\t\tElapsed time: ",
				ELAPSED_PLACEHOLDER,
				"\n\t\tDate (UTC): ",
				DateTime.now():FormatUniversalTime("LL LTS", "en-gb"),
				" PlaceId: ",
				game.PlaceId,
				" PlaceVersion: ",
				game.PlaceVersion,
				" Client Version: ",
				FULL_VERSION,
				" Platform: ",
				platformName,
				" Executor: ",
				executorName,
			})

			readmeExtra = register_extra("README", nil, nil, "Script", function()
				local recoveredNote = ""
				if #RecoveredScripts ~= 0 then
					recoveredNote = "\t\tIMPORTANT: Original Source of these Scripts was Recovered: "
						.. service.HttpService:JSONEncode(RecoveredScripts)
						.. "\n"
				end

				local failedTypes = {}
				for datatype, state in GHPPersisted do
					if state ~= "ok" then
						table.insert(failedTypes, datatype)
					end
				end
				table.sort(failedTypes)

				local ghpFailureHeader = ""
				if #failedTypes > 0 then
					ghpFailureHeader = [[
		!! GETHIDDENPROPERTY FAILED ON SOME TYPES !!
		Your executor's gethiddenproperty couldn't read the properties below, so this save might be missing data or have wrong values.
		Please tell your executor's developers about this. Affected types:
		]] .. service.HttpService:JSONEncode(failedTypes) .. "\n\n"
				end

				return table.concat({
					"--[[\n",
					"\t\tThank you for using UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw.\n\n",
					recoveredNote,
					ghpFailureHeader,
					binaryNote,
					helpText,
					service.HttpService:JSONEncode(OPTIONS),
					metaFooter,
					"\n]]",
				})
			end)
		end

		-- One collect over the main roots plus every extra's roots.
		local allRoots = table.clone(ToSaveList)
		for _, extra in pendingExtras do
			for _, root in extra.roots do
				allRoots[#allRoots + 1] = root
			end
		end

		local ctx = collect(allRoots)

		-- collect filtered and deduped; recover each extra's surviving roots.
		for _, extra in pendingExtras do
			local src = extra.roots
			local kept = table.create(#src)
			for _, root in src do
				if ctx.entries[root] then
					kept[#kept + 1] = root
				end
			end
			extra.collectedRoots = kept
		end

		if readmeExtra then
			local readmeEntry = ctx.entries[readmeExtra.roots[1]]
			if readmeEntry then
				readmeEntry.deferLast = true -- emitBinary encodes this bucket after all others
			end
		end

		-- Detach claimed subtrees. Mutates ctx, so it has to run before
		-- the dispatch rather than inside either emitter.
		local claimed = {}
		for _, extra in pendingExtras do
			for _, root in extra.collectedRoots do
				claimed[root] = true
				local rootEntry = ctx.entries[root]
				local isVirtual = rootEntry and rootEntry.virtual
				local toDetach = isVirtual and table.clone(rootEntry.children) or { root }

				for _, node in toDetach do
					local e = ctx.entries[node]
					local old = e.parent and ctx.entries[e.parent]

					-- Nil-instance containers have no prior parent, and a
					-- virtual wrapper is already the parent of its own
					-- children -- detaching there would strip the list they
					-- belong in.
					if e.parent ~= root then
						if old then
							local kids = old.children
							for i = #kids, 1, -1 do
								if kids[i] == node then
									table.remove(kids, i)
									break
								end
							end
						end
						e.parent = isVirtual and root or nil
					end
				end
			end
		end

		local mainRoots = table.create(#ctx.roots)
		for _, root in ctx.roots do
			if not claimed[root] then
				mainRoots[#mainRoots + 1] = root
			end
		end
		ctx.mainRoots = mainRoots

		local chunks = OPTIONS.Binary and emitBinary(ctx) or emitXML(ctx)

		if OPTIONS.ReadMe then
			stampElapsed(chunks, os.clock() - elapse_t)
		end

		if CopyToClipboard then
			setrbxclipboard(table.concat(chunks))
		elseif Callback then
			Callback(table.concat(chunks), chunks)
		elseif OPTIONS.AlternativeWritefile and appendfile then
			-- Batch chunks into ~4MB appends: sizes come from #chunk, so nothing
			-- is joined until a batch actually flushes. A whole-file concat would
			-- overflow on large places.
			local SEGMENT_SIZE = 4145728
			local batch, batchSize, written = {}, 0, 0

			local function flush()
				if batchSize == 0 then
					return
				end
				written += batchSize
				run_with_loading(
					"Writing to File " .. math.round(written / totalsize * 100) .. "%",
					nil,
					false,
					appendfile,
					placename,
					table.concat(batch)
				)
				table.clear(batch)
				batchSize = 0
				task.wait()
			end

			writefile(placename, "")

			for _, chunk in chunks do
				if #chunk >= SEGMENT_SIZE then
					flush()
					local offset = 1
					while offset <= #chunk do
						appendfile(placename, string.sub(chunk, offset, offset + SEGMENT_SIZE - 1))
						offset += SEGMENT_SIZE
						task.wait()
					end
					written += #chunk
				else
					batch[#batch + 1] = chunk
					batchSize += #chunk
					if batchSize >= SEGMENT_SIZE then
						flush()
					end
				end
			end

			flush()
		elseif writefile then
			run_with_loading(
				"Writing " .. get_size_format() .. " to File",
				nil,
				true,
				writefile,
				placename,
				table.concat(chunks)
			)
		end
	end

	local Connections = {}
	local function Connect(event, func)
		table.insert(Connections, event:Connect(func))
	end
	local function Cleanup()
		for _, connection in Connections do
			connection:Disconnect()
		end
		GLOBAL_ENV[placename] = nil
	end
	do
		local Players = service.Players

		if IgnoreList.Model ~= true then
			local function ignoreCharacter(player)
				Connect(player.CharacterAdded, function(character)
					IgnoreList[character] = true
				end)

				local Character = player.Character
				if Character then
					IgnoreList[Character] = true
				end
			end

			if not OPTIONS.SavePlayerCharacters then
				Connect(Players.PlayerAdded, function(player)
					ignoreCharacter(player)
				end)

				for _, player in Players:GetPlayers() do
					ignoreCharacter(player)
				end
			else
				IgnoreNotArchivable = false
			end
		end
	end

	if OPTIONS.KillAllScripts and not GLOBAL_ENV.USSI_KAS then
		GLOBAL_ENV.USSI_KAS = true
		-- * partial credits @centerepic
		game:GetService("ScriptContext"):SetTimeout(math.clamp(SaveCacheInterval * 0.000047, 20, 30))

		local self = coroutine.running()
		do
			local islclosure = islclosure
			local isexecutorclosure = isexecutorclosure or checkclosure or isourclosure
			local hookfunction = EXECUTOR_NAME ~= "Volt" and hookfunction

			local done = {}
			local function filterNkill(f)
				if not f then
					return
				end

				for _, v in table.clone(f()) do
					if not done[v] then
						done[v] = true

						local _type = type(v)
						if _type == "thread" then
							if v ~= self then
								pcall(coroutine.close, v)
							end
						elseif _type == "function" then
							if
								(not islclosure or islclosure(v))
								and (not isexecutorclosure or not isexecutorclosure(v))
							then
								if hookfunction then
									pcall(hookfunction, v, coroutine.yield)
								end
							end
						end
					end
				end
			end

			filterNkill(debug and debug.getregistry or getreg or getregistry)
			filterNkill(getallthreads)
			filterNkill(getgc)
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
			local Exists = GLOBAL_ENV.USSI_statustext
			if Exists then
				Exists:Destroy()
			end
		end

		local StatusGui = Instance.new("ScreenGui")

		GLOBAL_ENV.USSI_statustext = StatusGui

		StatusGui.DisplayOrder = 2e9
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
		else
			if global_container.protectgui then
				StatusGui.Name = randomString()
				global_container.protectgui(StatusGui)
				StatusGui.Parent = game:GetService("CoreGui")
			else
				local RobloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
				if RobloxGui then
					StatusGui.Parent = RobloxGui
				else
					StatusGui.Name = randomString()
					StatusGui.Parent = game:GetService("CoreGui")
				end
			end
		end
	end
	local kickSnapshot = GLOBAL_ENV.USSI_kicksnapshot
	if not kickSnapshot then
		kickSnapshot = {}
		GLOBAL_ENV.USSI_kicksnapshot = kickSnapshot
	end

	local function snapshotKick(LocalPlayer)
		local cached = kickSnapshot[LocalPlayer]

		if not cached then
			cached = { [LocalPlayer] = LocalPlayer:GetChildren() }

			local ps = LocalPlayer:FindFirstChildOfClass("PlayerScripts")
			local function walk(inst)
				local kids = inst:GetChildren()
				cached[inst] = kids
				for _, child in kids do
					walk(child)
				end
			end
			if ps then
				walk(ps)
			end

			kickSnapshot[LocalPlayer] = cached
		end

		for inst, kids in cached do
			InstancesOverrides[inst] = { __Children = kids }
		end
	end

	if OPTIONS.SafeMode then
		task.spawn(function()
			local LocalPlayer = GetLocalPlayer()

			snapshotKick(LocalPlayer)

			local msg =
				"[SAVEINSTANCE SAFEMODE]\nSaving..\nDo NOT leave\nLVL7 Executor RECOMMENDED for more SAFETY\nTo Disable this: SafeMode=false (Less Protection)"
			local function Kick()
				LocalPlayer:Kick(msg)
			end

			Kick()
			pcall(function()
				Connect(service.GuiService.ErrorMessageChanged, function()
					if service.GuiService:GetErrorMessage() ~= msg then
						Kick()
					end
				end)
			end)
			wait_for_render()
		end)

		if CustomOptions_valid["BoostFPS"] == nil then
			OPTIONS.BoostFPS = true
		end
	end

	local function childrenOf(instance)
		local override = InstancesOverrides[instance]
		return override and override.__Children or instance:GetChildren()
	end
	if OPTIONS.IgnoreDefaultPlayerScripts then
		local default_scripts = arrayToDict({
			ModuleScript = { "PlayerModule" },
			LocalScript = {
				"BubbleChat",
				"ChatScript",
				"PlayerScriptsLoader",
				"RbxCharacterSounds",
			},
		}, true)

		local function ignorePath(path)
			if path then
				for _, child in childrenOf(path) do
					local class_match = default_scripts[child.ClassName]
					if class_match and class_match[child.Name] then
						DecompileIgnore[child] = true
					end
					ignorePath(child)
				end
			end
		end

		ignorePath(service.StarterPlayer)

		local LocalPlayer = service.Players.LocalPlayer
		if LocalPlayer then
			for _, child in childrenOf(LocalPlayer) do
				if child:IsA("PlayerScripts") then
					ignorePath(child)
					break
				end
			end
		end
	end

	if OPTIONS.BoostFPS then
		pcall(function()
			service.RunService:Set3dRenderingEnabled(false)
		end)
	end

	if OPTIONS.AntiIdle then
		local Idled = GetLocalPlayer().Idled
		Connect(Idled, function()
			service.VirtualInputManager:SendMouseWheelEvent(
				service.UserInputService:GetMouseLocation().X,
				service.UserInputService:GetMouseLocation().Y,
				true,
				game
			)
		end)
	end

	if not ClassList then -- means first run
		do -- * Load Region of Déjà Vu
			if not RiskyServicesDisabled.UGC then
				local UGCValidationService -- = service.UGCValidationService

				gethiddenproperty_fallback = function(instance, propertyName)
					-- * This helps in reading: Vector3int16, OptionalCoordinateFrame DataTypes. It also acts as an almost entire fallback for gethiddenproperty in case it is missing
					if not UGCValidationService then
						UGCValidationService = service.UGCValidationService
					end
					return UGCValidationService:GetPropertyValue(instance, propertyName) -- TODO Sadly there's no way to tell whether value is actually nil or the function just couldn't read it (always returns nil for "Class" category properties)
					-- TODO `category ~= "Class"` causes WeldConstraint Part1Internal to be read as nil and not get unfiltered. Currently, there are no properties of category "Class" that match the following: NotScriptable, can be read with gethiddenproperty_fallback accurately (it always outputs nil for "Class" category, making that check useless anyway) & don't have a NotScriptableFix.
				end
			end
			if gethiddenproperty then
				local o, r = pcall(gethiddenproperty, workspace, "StreamOutBehavior")
				if not o or r ~= nil and typeof(r) ~= "EnumItem" then -- * Tests if gethiddenproperty is broken
					gethiddenproperty = nil
				else
					o, r = pcall(gethiddenproperty, Instance.new("AnimationRigData", Instance.new("Folder")), "parent") -- * Tests how it reacts to property overlap (shadowing) due to AnimationRigData.parent; expected BinaryString

					if o and r ~= nil and type(r) ~= "string" then
						gethiddenproperty = nil
					end
				end
			end

			do
				if
					not bit32.byteswap
					or not (function()
						local o, r = pcall(bit32.byteswap, 2712847316)
						if not o then
							return -- It might be disabled on some builds
						end
						return r == 3569595041
					end)()
				then -- Because Fluxus is missing byteswap
					-- https://github.com/luau-lang/rfcs/blob/master/docs/function-bit32-byteswap.md
					local b32 = table.clone(bit32)

					b32.byteswap = function(n)
						return bit32.bor(
							bit32.lshift(n, 24),
							bit32.band(bit32.lshift(n, 8), 0xFF0000),
							bit32.band(bit32.rshift(n, 8), 0xFF00),
							bit32.rshift(n, 24)
						)
					end
					if table.isfrozen(bit32) then
						b32 = table.freeze(b32)
					end
					GLOBAL_ENV.bit32 = b32
				end
			end

			local function benchmark(funcs, iters, ...)
				local ranking = table.create(3)
				for i, f in funcs do
					local start = os.clock()
					for _ = 1, iters do
						f(...)
					end
					ranking[i] = { t = os.clock() - start, f = f }
				end
				table.sort(ranking, function(a, b)
					return a.t < b.t
				end)
				return ranking[1].f
			end

			local function pickFastestBy(label, candidates, works, iters, benchInput, ...)
				local valid = {}
				for _, f in candidates do
					if f then
						local ok, good = pcall(works, f)
						if ok and good then
							valid[#valid + 1] = f
						end
					end
				end

				if #valid == 0 then
					-- warn(label .. " not found")
					return nil
				elseif #valid == 1 then
					return valid[1]
				end
				return benchmark(valid, iters, benchInput, ...)
			end

			-- Credits @daily3014 & @XoifaiI
			local rbxcrypt_encode, rbxcrypt_decode
			pcall(function()
				local rbxcrypt_b64 = loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/daily3014/rbx-algorithms/refs/heads/main/src/Encoding/Base64.luau",
						true
					),
					"Base64"
				)()
				local enc = rbxcrypt_b64.Encode
				rbxcrypt_encode = function(raw)
					return buffer.tostring(enc(buffer.fromstring(raw)))
				end
				local dec = rbxcrypt_b64.Decode
				rbxcrypt_decode = function(raw)
					return buffer.tostring(dec(buffer.fromstring(raw)))
				end
			end)

			local es_encode, es_decode, es_zstdcompress
			if not RiskyServicesDisabled.Encoding then
				local EncodingService = game:GetService("EncodingService")

				es_encode = function(raw)
					return buffer.tostring(EncodingService:Base64Encode(buffer.fromstring(raw)))
				end
				es_decode = function(raw)
					return buffer.tostring(EncodingService:Base64Decode(buffer.fromstring(raw)))
				end

				local ZSTD_ALGO_ENUM = Enum.CompressionAlgorithm.Zstd
				es_zstdcompress = function(raw, level)
					return buffer.tostring(
						EncodingService:CompressBuffer(buffer.fromstring(raw), ZSTD_ALGO_ENUM, level)
					)
				end
			end

			local BASE64_TEST = string.rep("\1\0\0\0\1\2\3\4\5\6\7", 50)

			local function b64EncWorks(f)
				return f("\1\0\0\0\1") == "AQAAAAE="
			end

			base64encode = pickFastestBy(
				"base64encode",
				{ base64encode, rbxcrypt_encode, es_encode },
				b64EncWorks,
				50,
				BASE64_TEST
			)

			if not base64encode then
				warn("base64encode not found")
				Cleanup()
				return
			end

			local function b64DecWorks(f)
				return f("AQAAAAE=") == "\1\0\0\0\1"
			end

			base64decode = pickFastestBy(
				"base64decode",
				{ base64decode, rbxcrypt_decode, es_decode },
				b64DecWorks,
				50,
				base64encode(BASE64_TEST)
			)

			local HttpService = service.HttpService

			local function http_zstdcompress(input)
				local ok, encoded = pcall(HttpService.JSONEncode, HttpService, buffer.fromstring(input)) -- pcall due to ~100mb limit
				if not ok then
					return nil
				end

				local keyStart = string_find(encoded, '"zbase64"')
				if not keyStart then
					return nil
				end

				local valueStart = string_find(encoded, '"', keyStart + 9)
				if not valueStart then
					return nil
				end

				local valueEnd = string_find(encoded, '"', valueStart + 1)
				if not valueEnd then
					return nil
				end

				local b64 = string.sub(encoded, valueStart + 1, valueEnd - 1)

				return base64decode(b64)
			end

			local COMPRESS_TEST
			do
				local n = 4000
				local planes = table.create(4)
				for p = 1, 4 do
					local bytes = table.create(n)
					for i = 1, n do
						bytes[i] = p <= 2 and (i % 3) or ((i * 2654435761) % 256)
					end
					planes[p] = string.char(table.unpack(bytes, 1, math.min(n, 7997)))
				end
				COMPRESS_TEST = table.concat(planes)
			end

			local function zstdWorks(f)
				local out = f(COMPRESS_TEST)
				return type(out) == "string" and #out > 4 and string.sub(out, 1, 4) == "\40\181\47\253"
			end

			zstdcompress = pickFastestBy(
				"zstdcompress",
				{ zstdcompress, http_zstdcompress, es_zstdcompress },
				zstdWorks,
				10,
				COMPRESS_TEST
			)

			-- Credits @RiskoZS
			local llz4_compress
			pcall(function()
				local llz4 = loadstring(
					game:HttpGet("https://raw.githubusercontent.com/RiskoZS/llz4/refs/heads/main/llz4.luau", true),
					"llz4"
				)()
				llz4_compress = llz4.compress
			end)

			local LZ4_PROBE = "\1\2\3\4\5\6\7\8"

			local function lz4Works(f)
				local out = f(LZ4_PROBE)
				return type(out) == "string"
					and #out == #LZ4_PROBE + 1
					and string.byte(out, 1) == #LZ4_PROBE * 16
					and string.sub(out, 2) == LZ4_PROBE
			end
			lz4compress = pickFastestBy("lz4compress", { lz4compress, llz4_compress }, lz4Works, 10, COMPRESS_TEST)
		end

		do
			local ok, result = pcall(FetchAPI)
			if ok then
				ClassList = result
			else
				warn("Failed to load the API Dump")
				warn(result)
				Cleanup()
				return
			end
		end
	end

	elapse_t = os.clock()

	local ok, err = xpcall(save_game, function(err)
		return debug.traceback(err)
	end)

	if OPTIONS.BoostFPS then
		pcall(function()
			local max = 5
			task.delay(
				math.clamp(max - (os.clock() - elapse_t), 0, max),
				service.GuiService.ClearError,
				service.GuiService
			)
			service.RunService:Set3dRenderingEnabled(true)
		end)
	end

	if old_gethiddenproperty then
		gethiddenproperty = old_gethiddenproperty
	end

	Cleanup()

	elapse_t = os.clock() - elapse_t
	local Log10 = math.log10(elapse_t)
	local ExtraTime = 10

	if StatusText then
		task.spawn(function()
			if ok then
				StatusText.Text = string.format("Saved! Time %.3f seconds; Size %s", elapse_t, get_size_format())
				StatusText.TextColor3 = Color3.new(0, 1)
				task.wait(Log10 * 2 + ExtraTime)
			else
				if LoadingThread then
					task.cancel(LoadingThread)
					LoadingThread = nil
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

	if OPTIONS.ShutdownWhenDone and ok then
		task.wait(Log10 * 2 + ExtraTime)
		game:Shutdown()
	end
end

return synsaveinstance
