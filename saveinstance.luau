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

-- * Single shared-env entry point: caches expensive per-session state (place name, decompile cache, ...)
-- * so a full script reload doesn't have to rebuild it.
local USSI = GLOBAL_ENV.USSI
if not USSI then
	USSI = {}
	GLOBAL_ENV.USSI = USSI
end

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
local delfile = delfile
local isfile = isfile
local readfile = readfile
local writefile = writefile

local getscriptbytecode = global_container.getscriptbytecode -- * A lot of assumptions are made based on whether this function is defined or not. So in certain edge cases, like if the environment defines "decompile" or "getscripthash" function yet doesn't define this function there might be loss of functionality of the saveinstance. Although that would be very rare and weird
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

local function index(self, index_name)
	return self[index_name]
end

local cachedPlaceName = USSI.PlaceName

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

local REFLECTION_FILTER = {
	Security = SecurityCapabilities.new(unpack(Enum.SecurityCapability:GetEnumItems())),
	ExcludeDisplay = true,
	ExcludeInherited = true,
}

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
local bf32_rotation = buffer.writef32

local function rawBasisString(r00, r01, r02, r10, r11, r12, r20, r21, r22)
	bf32_rotation(rotationBuffer, 0, r00)
	bf32_rotation(rotationBuffer, 4, r01)
	bf32_rotation(rotationBuffer, 8, r02)
	bf32_rotation(rotationBuffer, 12, r10)
	bf32_rotation(rotationBuffer, 16, r11)
	bf32_rotation(rotationBuffer, 20, r12)
	bf32_rotation(rotationBuffer, 24, r20)
	bf32_rotation(rotationBuffer, 28, r21)
	bf32_rotation(rotationBuffer, 32, r22)
	return buffer.tostring(rotationBuffer)
end

local EMPTY_BUFFER = buffer.create(0)
local BASE_CAPABILITIES = SecurityCapabilities.new()
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

	local rawString = tostring(raw)
	if rawString == "" then
		return 0, 0
	end

	local lo, hi = 0, 0
	for _, flag in string.split(rawString, " | ") do
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
local bf32, ru32 = buffer.writef32, buffer.readu32
local lr32 = bit32.lrotate

local function rotf(v)
	bf32(scratch, 0, v)
	return lr32(ru32(scratch, 0), 1)
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
	local buf = sbuf.buf
	local wu8 = buffer.writeu8
	local rshift = bit32.rshift
	wu8(buf, o, rshift(v, 24))
	wu8(buf, o + n, rshift(v, 16))
	wu8(buf, o + 2 * n, rshift(v, 8))
	wu8(buf, o + 3 * n, v)
end

local function pokeU64Planes(sbuf, o, n, hi, lo)
	pokeU32Planes(sbuf, o, n, hi)
	pokeU32Planes(sbuf, o + 4 * n, n, lo)
end

local function interleavedU32Plane(sbuf, n, base, getU32ForIndex)
	local buf = sbuf.buf
	local rshift = bit32.rshift
	local wu8 = buffer.writeu8
	for i = 1, n do
		local v = getU32ForIndex(i)
		local o = base + (i - 1)
		wu8(buf, o, rshift(v, 24))
		wu8(buf, o + n, rshift(v, 16))
		wu8(buf, o + 2 * n, rshift(v, 8))
		wu8(buf, o + 3 * n, v)
	end
end

-- Zigzag-delta referent plane. Every referent array in the format is this:
-- INST referents, PRNT object/parent, Referent props, Content ObjectRefs.
local function writeRefPlane(sbuf, n, base, getRef)
	local buf = sbuf.buf
	local rshift = bit32.rshift
	local wu8 = buffer.writeu8
	local lastRef = nil
	for i = 1, n do
		local ref = getRef(i)
		local acc = lastRef and (ref - lastRef) or ref
		lastRef = ref
		local v = zigzag32(acc)
		local o = base + (i - 1)
		wu8(buf, o, rshift(v, 24))
		wu8(buf, o + n, rshift(v, 16))
		wu8(buf, o + 2 * n, rshift(v, 8))
		wu8(buf, o + 3 * n, v)
	end
end

-- Encoder factories

local function planeEncoder(...)
	local getters = { ... }
	local k = #getters
	local rshift = bit32.rshift
	local wu8 = buffer.writeu8
	return function(sbuf, vals, n)
		local base = sbuf:allocRegion(4 * k * n)
		local buf = sbuf.buf
		local stride = 4 * n
		for p = 1, k do
			local getter = getters[p]
			local pbase = base + (p - 1) * stride
			for i = 1, n do
				local v = getter(vals[i])
				local o = pbase + (i - 1)
				wu8(buf, o, rshift(v, 24))
				wu8(buf, o + n, rshift(v, 16))
				wu8(buf, o + 2 * n, rshift(v, 8))
				wu8(buf, o + 3 * n, v)
			end
		end
	end
end

local function f32Encoder(...)
	local paths = { ... }
	local k = #paths
	local wf32 = buffer.writef32
	return function(sbuf, vals, n)
		local base = sbuf:allocRegion(4 * k * n)
		local buf = sbuf.buf
		for i = 1, n do
			local v = vals[i]
			local o = base + (i - 1) * 4 * k
			for p = 1, k do
				wf32(buf, o, paths[p](v))
				o += 4
			end
		end
	end
end

local function i16Encoder(...)
	local comps = { ... }
	local k = #comps
	local wi16 = buffer.writei16
	return function(sbuf, vals, n)
		local base = sbuf:allocRegion(2 * k * n)
		local buf = sbuf.buf
		for i = 1, n do
			local v = vals[i]
			local o = base + (i - 1) * 2 * k
			for p = 1, k do
				wi16(buf, o, v[comps[p]])
				o += 2
			end
		end
	end
end

local function flagEncoder(bits)
	return function(sbuf, vals, n)
		local base = sbuf:allocRegion(n)
		local buf = sbuf.buf
		local wu8 = buffer.writeu8
		for i = 1, n do
			local v = vals[i]
			local packed = 0
			for name, b in bits do
				if v[name] then
					packed += b
				end
			end
			wu8(buf, base + (i - 1), packed)
		end
	end
end

local function writeCFrameBody(sbuf, vals, n, optional)
	local coordsX, coordsY, coordsZ = table.create(n), table.create(n), table.create(n)
	local wu8, wstr = sbuf.writeu8, sbuf.writestring
	local identity = CFrame.identity

	for i = 1, n do
		local val = vals[i]

		if optional then
			if val == nil then
				val = identity
			end
		end

		local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = val:GetComponents()
		coordsX[i], coordsY[i], coordsZ[i] = x, y, z

		local rotStr = rawBasisString(r00, r01, r02, r10, r11, r12, r20, r21, r22)
		local id = CFrame_Rotation_Ids[rotStr]
		if id then
			wu8(sbuf, id)
		else
			wu8(sbuf, 0)
			wstr(sbuf, rotStr)
		end
	end

	local posBase = sbuf:allocRegion(12 * n)
	local planes = { coordsX, coordsY, coordsZ }
	local cbuf = sbuf.buf
	local lr, rshift = bit32.lrotate, bit32.rshift
	local bf32, ru32, bwu8 = buffer.writef32, buffer.readu32, buffer.writeu8
	for p = 1, 3 do
		local coords = planes[p]
		local pbase = posBase + (p - 1) * 4 * n
		for i = 1, n do
			bf32(scratch, 0, coords[i])
			local v = lr(ru32(scratch, 0), 1)
			local o = pbase + (i - 1)
			bwu8(cbuf, o, rshift(v, 24))
			bwu8(cbuf, o + n, rshift(v, 16))
			bwu8(cbuf, o + 2 * n, rshift(v, 8))
			bwu8(cbuf, o + 3 * n, v)
		end
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
		local total = 4 * n
		for i = 1, n do
			total += #vals[i]
		end
		local o = sbuf:allocRegion(total)
		local buf = sbuf.buf
		local wu32, wstr = buffer.writeu32, buffer.writestring
		for i = 1, n do
			local v = vals[i]
			local l = #v
			wu32(buf, o, l)
			wstr(buf, o + 4, v)
			o += 4 + l
		end
	end,
	["bool"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(n)
		local buf = sbuf.buf
		local wu8 = buffer.writeu8
		for i = 1, n do
			if vals[i] then
				wu8(buf, base + (i - 1), 1)
			end
		end
	end,

	["int"] = planeEncoder(zigzag32),
	["float"] = planeEncoder(rotf),

	["double"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(8 * n)
		local buf = sbuf.buf
		local wf64 = buffer.writef64
		for i = 1, n do
			wf64(buf, base + (i - 1) * 8, vals[i])
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

	["NumberSequence"] = function(sbuf, vals, n)
		local total = 4 * n
		for i = 1, n do
			total += 12 * #vals[i].Keypoints
		end
		local o = sbuf:allocRegion(total)
		local buf = sbuf.buf
		local wu32, wf32 = buffer.writeu32, buffer.writef32
		for i = 1, n do
			local keypoints = vals[i].Keypoints
			wu32(buf, o, #keypoints)
			o += 4
			for _, kp in keypoints do
				wf32(buf, o, kp.Time)
				wf32(buf, o + 4, kp.Value)
				wf32(buf, o + 8, kp.Envelope)
				o += 12
			end
		end
	end,
	["ColorSequence"] = function(sbuf, vals, n)
		local total = 4 * n
		for i = 1, n do
			total += 20 * #vals[i].Keypoints
		end
		local o = sbuf:allocRegion(total)
		local buf = sbuf.buf
		local wu32, wf32 = buffer.writeu32, buffer.writef32
		for i = 1, n do
			local keypoints = vals[i].Keypoints
			wu32(buf, o, #keypoints)
			o += 4
			for _, kp in keypoints do
				local c = kp.Value
				wf32(buf, o, kp.Time)
				wf32(buf, o + 4, c.R)
				wf32(buf, o + 8, c.G)
				wf32(buf, o + 12, c.B)
				wf32(buf, o + 16, 0) -- envelope, unused for ColorSequence, always 0
				o += 20
			end
		end
	end,

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
		sbuf:reserve(25 * n)
		local buf = sbuf.buf
		local o = sbuf.len
		local wu8, wf32 = buffer.writeu8, buffer.writef32
		for i = 1, n do
			local val = vals[i]
			if val then
				wu8(buf, o, 3)
				wf32(buf, o + 1, val.Density)
				wf32(buf, o + 5, val.Friction)
				wf32(buf, o + 9, val.Elasticity)
				wf32(buf, o + 13, val.FrictionWeight)
				wf32(buf, o + 17, val.ElasticityWeight)
				wf32(buf, o + 21, val.AcousticAbsorption)
				o += 25
			else
				wu8(buf, o, 0)
				o += 1
			end
		end
		sbuf.len = o
	end,

	["Color3uint8"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(3 * n)
		local buf = sbuf.buf
		local wu8 = buffer.writeu8
		local floor = math.floor
		for i = 1, n do
			local val = vals[i]
			local o = base + (i - 1)
			wu8(buf, o, floor(val.R * 255 + 0.5))
			wu8(buf, o + n, floor(val.G * 255 + 0.5))
			wu8(buf, o + 2 * n, floor(val.B * 255 + 0.5))
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
		sbuf:writeu8(0x10) -- Type_Ids.CFrame
		writeCFrameBody(sbuf, vals, n, true)

		sbuf:writeu8(0x02) -- Type_Ids.bool
		local boolBase = sbuf:allocRegion(n)
		local buf = sbuf.buf
		local wu8 = buffer.writeu8
		for i = 1, n do
			if vals[i] ~= nil then
				wu8(buf, boolBase + (i - 1), 1)
			end
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
		local wlstr, wu16, wu8, wu32 = sbuf.writeLenString, sbuf.writeu16, sbuf.writeu8, sbuf.writeu32
		for i = 1, n do
			local val = vals[i]

			local hasWeight, weight = pcall(index, val, "Weight")
			local hasStyle, style = pcall(index, val, "Style")

			wlstr(sbuf, val.Family)
			wu16(sbuf, hasWeight and weight.Value or 0)
			wu8(sbuf, hasStyle and style.Value or 0)
			wu32(sbuf, 0) -- CachedFaceId can't be indexed
		end
	end,
	["SecurityCapabilities"] = function(sbuf, vals, n)
		local base = sbuf:allocRegion(8 * n)
		for i = 1, n do
			local lo, hi = capabilityHalves(vals[i])
			pokeU64Planes(sbuf, base + (i - 1), n, zigzagHalves(hi, lo))
		end
	end,
	["Content"] = function(sbuf, vals, n)
		local uris = {}

		local base = sbuf:allocRegion(4 * n)
		interleavedU32Plane(sbuf, n, base, function(i)
			local v = vals[i]
			if v ~= nil and v.SourceType == Enum.ContentSourceType.Uri then
				table.insert(uris, v.Uri or "")
				return zigzag32(1)
			end
			return 0
		end)

		sbuf:writeu32(#uris)
		for _, uri in uris do
			sbuf:writeLenString(uri)
		end

		sbuf:writeu32(0) -- object refs: all downgraded to type 0
		sbuf:writeu32(0) -- external refs
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
local RiskyServicesDisabled
do
	local ClassPropertyExceptions = arrayToDict({
		Whitelist = {},
		Blacklist = {
			BillboardGui = { "PlayerToHideFrom" },
			LuaSourceContainer = { "ScriptGuid" },
			Instance = { "UniqueId", "HistoryId", "SourceAssetId", "SourceContent" },
		},
	}, true)

	-- Minimal valid CSGPHS v8 collision blob; preserves the CollisionFidelity label but not the real geometry.
	local PHYSICAL_CONFIG_BASE =
		"\67\83\71\80\72\83\8\0\0\0\2\0\40\181\47\253\32\180\149\1\0\120\0\120\32\193\32\65\65\2\12\1\3\2\1\12\193\16\160\112\242\1\176\106\234\58\123\18\99\238\29\229\253\198\101\127\68\150\204\66\96\179\97\185\59\111\222\22\115\2\106"
	local CF = Enum.CollisionFidelity

	local PHYSICAL_CONFIG_BY_CF = {
		[CF.Box] = "\67\83\71\80\72\83\0\0\0\0\66\76\79\67\75", -- "CSGPHS\0\0\0\0BLOCK"
	}

	do
		local base = PHYSICAL_CONFIG_BASE
		local prefix = string.sub(base, 1, 10)
		local suffix = string.sub(base, 12)

		local byteMap = {
			[CF.Hull] = 1,
			[CF.Default] = 2,
			[CF.PreciseConvexDecomposition] = 3,
			[CF.Tunable] = 7,
		}

		for cf, byte in byteMap do
			PHYSICAL_CONFIG_BY_CF[cf] = prefix .. string.char(byte) .. suffix
		end
	end
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
		GuiObject = { Sink = "InputSink" },

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
			PhysicalConfigData = function(instance)
				local blob = PHYSICAL_CONFIG_BY_CF[instance.CollisionFidelity]
				if blob == nil then
					blob = PHYSICAL_CONFIG_BY_CF[CF.Default]
				end
				return blob
			end,
		},
		MeshPart = {
			InitialSize = "MeshSize",
			MeshID = "MeshId",
			-- VertexCount = function(instance) -- RobloxSecurity, Slow
			-- 	if RiskyServicesDisabled.UGC then
			-- 		return __BREAK
			-- 	end
			-- 	local meshId = instance.MeshId
			-- 	if meshId == "" then
			-- 		return __BREAK
			-- 	end
			-- 	return #service.UGCValidationService:GetMeshVerts(meshId)
			-- end,
		},
		PartOperation = {
			Content = function(instance)
				return Content.fromUri(gethiddenproperty_fallback(instance, "AssetId"))
			end,
			InitialSize = "MeshSize",
		},
		Part = { shape = "Shape" },
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
				-- ! Some execs (like Xeno) error on ReflectionService.GetClasses due to their ProxyService
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

				for _, api_class in service.ReflectionService:GetClasses(REFLECTION_FILTER) do
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
						REFLECTION_FILTER
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
		local tmp_classDict, tmp_classParents = {}, {}

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
			tmp_classParents[ClassName] = API_Class.Superclass
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
										REFLECTION_FILTER
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
							-- detect properties that shadow an ancestor (e.g. AnimationRigData.parent shadows Instance.parent)
							-- roblox ignores first-char case when indexing, so normalize for comparison
							local propNameNorm = string.lower(string.sub(PropertyName, 1, 1))
								.. string.sub(PropertyName, 2)
							local super = tmp_classParents[ClassName]
							while super do
								local superProps = tmp_classDict[super]
								if superProps then
									for parentName in superProps do
										if
											string.lower(string.sub(parentName, 1, 1)) .. string.sub(parentName, 2)
											== propNameNorm
										then
											Property.Shadows = true
											break
										end
									end
								end
								if Property.Shadows then
									break
								end
								super = tmp_classParents[super]
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
    @class UniversalSynSaveInstance
    This module saves the current place, one [Instance] (a Roblox object), or a
    group of [Instance]s to a `.rbxl`/`.rbxm` (binary) or `.rbxlx`/`.rbxmx` (XML)
    file.

    All options are optional. See
    [UniversalSynSaveInstance.SaveInstanceOptions] for all options. Option names are not
    case-sensitive. Old names from [UniversalSynSaveInstance.OptionsAliases] and
    [UniversalSynSaveInstance.OptionsAliasesInverse] also work.
    The most common options are at the top of
    [UniversalSynSaveInstance.SaveInstanceOptions]. Related options are grouped
    together, and advanced or rarely used options are at the bottom.
]=]

--- @interface SaveInstanceOptions
--- Options for [UniversalSynSaveInstance.synsaveinstance]. All fields are optional.
--- The default is shown at the end of each field. Option names are not
--- case-sensitive: `NilInstances`, `nilinstances`, and `nilInStaNces` are the
--- same option. Unknown names are ignored.
--- @within UniversalSynSaveInstance
--- @field mode string -- What to save. `optimized` saves the most important services (Workspace, Players, Lighting, ReplicatedStorage, StarterGui, and others). `full` saves everything under `game`. `scripts` saves only the top-level parts that contain a [LuaSourceContainer] (a script object). It saves the whole part, not just the script. Any other value saves only `ExtraInstances` (and `Object`, if set). If `Object` is set, `optimized` becomes `full`. ___Default:___ `optimized`
--- @field Binary boolean -- Save a binary file (`.rbxl`/`.rbxm`) instead of an XML file (`.rbxlx`/`.rbxmx`). Binary files are smaller and load faster. If the executor cannot write binary data correctly, the script uses XML. Set the old option `XML = true` to force XML. ___Default:___ true
--- @field CompressionMode string | boolean -- How to compress (make smaller) the binary file: `"zstd"`, `"lz4"`, or `false` for no compression. `true` means `"zstd"`. The old option `DisableCompression = true` means `false`. ___Default:___ `"zstd"`
--- @field CompressionLevel number -- Compression level for zstd, from -7 to 22. A higher level makes a smaller file but takes longer. This is ignored for lz4 and when compression is off. ___Default:___ 9
--- @field FilePath string | false -- File name to save to. You can include a folder. If the name has no extension, the script adds one based on `Binary` and `IsModel`. If you set this, the script overwrites an existing file and ignores `AvoidFileOverwrite`. ___Default:___ false
--- @field SafeMode boolean -- Disconnect the LocalPlayer from the game when saving starts. This turns on `KillAllScripts` and `BoostFPS` unless you set them yourself. **HIGHLY RECOMMENDED.** ___Default:___ false
--- @field KillAllScripts boolean -- Close or disable other running scripts before saving. `SafeMode` turns this on. Some games stop responding to input after this. That is normal. **HIGHLY RECOMMENDED.** ___Default:___ false
--- @field BoostFPS boolean -- Turn off 3D rendering while saving, then turn it back on. `SafeMode` turns this on. ___Default:___ false
--- @field Object Instance | false -- Save this [Instance] instead of the whole place. The script saves a model if you do not set `IsModel = false`. If you pass `game`, it saves the place and uses `full` mode. You must pass an [Instance], not a name. ___Default:___ false
--- @field IsModel boolean -- Save a model (`.rbxm`/`.rbxmx`) instead of a place (`.rbxl`/`.rbxlx`). `Object` turns this on unless you set it yourself. Passing a list of Instances as an argument also turns it on. ___Default:___ false
--- @field ShowStatus boolean -- Show a status label on the screen. It shows the size while saving, then the final size and time. ___Default:___ true
--- @field ReadMe boolean -- Add a README script to the save. It contains save details (place ID, date, time, platform, executor, recovered scripts, warnings) and tips. ___Default:___ true
--- @field Decompile boolean -- Turn the compiled script back into source code (decompile). This replaces the `Source` of each [LuaSourceContainer] with decompiled code. If this is off, `Source` says decompiling is disabled. ___Default:___ true
--- @field SaveBytecode boolean -- If the executor supports `getscriptbytecode`, add the compiled script data (bytecode) to `Source` as a comment. You can decompile it later. This respects `DecompileIgnore`. ___Default:___ false
--- @field DecompileTimeout number -- How many seconds one decompile call can take. If it takes longer, the script stops waiting and writes a timeout message in `Source`. Set to -1 to disable the timeout. ___Default:___ 10
--- @field BytecodeTimeout number -- How many seconds a `getscriptbytecode` call can take. If it takes longer, the script stops waiting and skips the bytecode for that script. Set to -1 to disable the timeout. ___Default:___ 3
--- @field DecompileIgnore {Instance | string} | {[Instance | string]: boolean | {[string]: boolean}} -- Skip decompiling matched [Instance]s and their children. `Source` becomes a short ignored message. You can pass an [Instance], a class name, or `ClassName = {Name1, Name2}`. Set an [Instance] to `false` to skip only that instance, not its children. ___Default:___ {TextChatService}
--- @field SourceCache {[Instance]: string} | false -- Source text to use for these scripts as-is instead of decompiling them. ___Default:___ false
--- @field DecompileJobless boolean -- Only use scripts that are already in the decompile cache. Missing scripts get a short not-found message. This turns on `scriptcache`. ___Default:___ false
--- @field scriptcache boolean -- If the executor supports `getscriptbytecode`, cache decompiled code. This avoids decompiling the same script twice. The cache stays after the script reloads. ___Default:___ true
--- @field RecoverScriptsFromAssets boolean -- Recover the original `Source` of scripts that were published as assets. Changes made after publishing are not included. ___Default:___ true
--- @field IsolatePlayers boolean -- Put every [Player] under a top-level `"Players"` Folder instead of inside the [Players] service. This turns on `SaveNotCreatable`. If both are on, this option is used instead of `IsolateLocalPlayer`. ___Default:___ false
--- @field IsolateLocalPlayer boolean -- Save the LocalPlayer as a Folder named `"LocalPlayer"` instead of a [Player] object. This is ignored if `IsolatePlayers` is on. ___Default:___ false
--- @field IsolateLocalPlayerCharacter boolean -- Save LocalPlayer.Character as a [Model] named `"LocalPlayer Character"`. This saves the character even when characters are normally skipped. ___Default:___ false
--- @field IsolateStarterPlayer boolean -- Put [StarterPlayer]'s children under a top-level `"StarterPlayer"` Folder. The original service stays, but it is empty. ___Default:___ false
--- @field SavePlayerCharacters boolean -- Save player characters instead of skipping them. This also saves objects with `Archivable = false`, so `IgnoreNotArchivable` is forced on. ___Default:___ false
--- @field NilInstances boolean -- Include objects that have no parent (they are not under `game`). This needs the executor function `getnilinstances`. When that function exists, it also turns on `SaveNotCreatable`. ___Default:___ false
--- @field ExtraInstances {Instance} -- A list of [Instance]s to add to the normal save. If `mode` is not a valid value, only these Instances (and `Object`, if set) are saved. Passing a list of Instances as an argument fills this list. ___Default:___ {}
--- @field IgnoreList {Instance | string} | {[Instance | string]: boolean | {[string]: boolean}} -- Objects to skip. Use an [Instance] or a class name as a key to skip that object and its children. `ClassName = false` keeps the object but skips its children. `ClassName = {Name1, Name2}` skips objects with those names. You can also pass a list of Instances or class names. ___Default:___ {CoreGui, CorePackages, Packages = false}
--- @field IgnoreSpecialProperties boolean -- Do not use the executor function `gethiddenproperty`. Other property reads still work. This can help if your executor crashes or the file is corrupted. ___Default:___ false
--- @field AlternativeWritefile boolean -- Write the file in smaller pieces with `appendfile` instead of one `writefile` call. For binary saves, if `appendfile` fails, it uses `writefile`; if both fail, it switches to XML. ___Default:___ true
--- @field Anonymous boolean | {Name: string?, UserId: number?} -- **RISKY:** Replace LocalPlayer.Name and UserId in the output. `true` replaces them with `"Roblox"` and `1`. You can also pass a table with `Name` and/or `UserId`. Name matching ignores case. This can also change other text or numbers that match. ___Default:___ false
--- @field RiskyServicesDisabled {UGC: boolean?, Encoding: boolean?, Reflection: boolean?} -- Turn off services that some games may detect. `UGC` skips [UGCValidationService] (used for some hidden properties). `Encoding` skips [EncodingService]. `Reflection` skips [ReflectionService] (used for class data). Set a flag to `true` to skip that service. If you do not set `RiskyServicesDisabled` yourself, the UGC fallback turns on automatically when `gethiddenproperty` is missing. ___Default:___ {UGC = true, Encoding = false, Reflection = false}
--- @field AvoidFileOverwrite boolean -- If `FilePath` is not set, add (1), (2), ... to the file name instead of overwriting an existing file. ___Default:___ true
--- @field AntiIdle boolean -- Stop Roblox from kicking you for being idle (not moving) for 20 minutes. ___Default:___ true
--- @field CopyToClipboard boolean -- Copy the result to the clipboard (the copy/paste buffer) instead of writing a file. Your executor must support `setrbxclipboard`. Use this only for small saves. ___Default:___ false
--- @field Callback ((data: string, chunks: {string}) -> ()) | false -- Call this function with the result instead of writing a file. It receives the full text and a list of chunks. If `CopyToClipboard` is also on, the clipboard is used instead. ___Default:___ false
--- @field IgnoreProperties {string} -- A list of property names to skip on every object. For example: `{"Tags", "AttributesSerialize"}`. ___Default:___ {}
--- @field IgnoreNotArchivable boolean -- Save objects even when their `Archivable` property is `false`. If this is off, the script skips those objects. ___Default:___ true
--- @field SaveNotCreatable boolean -- Save classes that Roblox says are not creatable. The script replaces them with a class it can create, using `NotCreatableFixes` (usually `Folder`). This turns on automatically with `IsolatePlayers`, `IsolateLocalPlayer`, and `NilInstances` (when `getnilinstances` exists). ___Default:___ false
--- @field NotCreatableFixes {string} | {[string]: string | false} -- Replace a class with a class that can be created. The default replacement is `"Folder"`. A list of class names also becomes `Folder`. Built-in changes: [Player], [PlayerGui], [PlayerScripts], [TouchTransmitter], and others become `Folder`; [CloudLocalizationTable] becomes [LocalizationTable]; `Platform` becomes [Part]; `Status` becomes [Model]. Set a class to `false` to skip its replacement. ___Default:___ built-in replacements
--- @field NilInstancesFixes {[string]: ((instance: Instance, overrides: table) -> Instance?) | false} -- Where to put objects that have no parent. For example, it puts [Animator] under an [AnimationController]. Built-in fixes exist for [Animator], [AdPortal], [Attachment], [BaseWrap], and [PackageLink]. Child classes use the parent fix ([Bone]s use the Attachment fix). Set a class to `false` to turn off its fix. ___Default:___ built-in Animator/AdPortal/Attachment/BaseWrap/PackageLink fixes
--- @field IgnoreDefaultProperties boolean -- Skip properties that already have the default value for their class. This only affects XML output. Binary output does not use this option. ___Default:___ true
--- @field IgnorePropertiesOfNotScriptsOnScriptsMode boolean -- Only in `scripts` mode: save properties for [LuaSourceContainer]s and skip properties for all other objects. This does nothing in other modes. ___Default:___ false
--- @field IgnoreDefaultPlayerScripts boolean -- Skip Roblox's default player scripts (`PlayerModule`, `BubbleChat`, `ChatScript`, `PlayerScriptsLoader`, `RbxCharacterSounds`). This can stop some executors from crashing during decompile. ___Default:___ false
--- @field SaveCacheInterval number -- How much XML data the script holds in memory while saving. Lower values update the status more often but are slower. This does not write to disk. When `KillAllScripts` is on, this also sets the script timeout between 20 and 30 seconds. ___Default:___ 0x1600 * 10
--- @field SharedBinaryStrings boolean -- Store the same binary data (meshes, images, ...) only once in the file. This makes saves with repeated data smaller. Files with all unique data can get slightly bigger. This is not an official Roblox format, but Studio can still open the file. ___Default:___ false
--- @field TreatUnionsAsParts boolean -- Change all [PartOperation]s (unions and intersections) into [Part]s. **RISKY:** you lose the merged shape, but executors that cannot read unions will still show visible parts. ___Default:___ false
--- @field ShutdownWhenDone boolean -- Close the game after a successful save. ___Default:___ false
--- @field __DEBUG_MODE boolean | ((...any) -> ()) -- Print debug warnings for unusual cases. If you pass a function, the script uses it instead of `warn`. ___Default:___ false

--- @interface OptionsAliases
--- @within UniversalSynSaveInstance
--- Map of old option names to new option names for the [UniversalSynSaveInstance.SaveInstanceOptions] table.
--- Format: `{ OldName = NewName }`
--- The script reads these before your options, so you cannot change them after the script starts.
--- @field Clipboard string -- `CopyToClipboard`
--- @field DecompileScripts string -- `Decompile`
--- @field EmbedBytecode string -- `SaveBytecode`
--- @field FileName string -- `FilePath`
--- @field IgnoreArchivable string -- `IgnoreNotArchivable`
--- @field IgnoreDefaultProps string -- `IgnoreDefaultProperties`
--- @field InstancesBlacklist string -- `IgnoreList`
--- @field IsolatePlayerGui string -- `IsolateLocalPlayer`
--- @field Path string -- `FilePath`
--- @field SaveCharacters string -- `SavePlayerCharacters`
--- @field SaveLocalPlayer string -- `IsolateLocalPlayer`
--- @field SaveNilInstances string -- `NilInstances`
--- @field SaveNonCreatable string -- `SaveNotCreatable`
--- @field SavePlayerGui string -- `IsolateLocalPlayer`
--- @field SavePlayers string -- `IsolatePlayers`
--- @field ShowProgress string -- `ShowStatus`
--- @field StatusText string -- `ShowStatus`
--- @field timeout string -- `DecompileTimeout`

--- @interface OptionsAliasesInverse
--- @within UniversalSynSaveInstance
--- Map of old option names that change a true/false value to the opposite.
--- Format: `{ OldName = NewName }`
--- The script flips the value before it uses it. `noscripts = true` sets `Decompile = false`.
--- `DisableCompression = true` sets `CompressionMode = false`.
--- The script reads these before your options, so you cannot change them after the script starts.
--- @field DisableCompression string -- `CompressionMode`
--- @field noscripts string -- `Decompile`
--- @field NullifyScripts string -- `Decompile`
--- @field RemovePlayerCharacters string -- `SavePlayerCharacters`
--- @field RemovePlayers string -- `IsolatePlayers`
--- @field XML string -- `Binary`

--[=[
	@function synsaveinstance
	Save the current place, one [Instance], or a group of [Instance]s. Example:
	```lua
	local Params = {
		RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
		SSI = "saveinstance",
	}

	local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

	local SaveInstanceOptions = { SafeMode = true, DecompileTimeout = 15, SaveBytecode = true }

	synsaveinstance(SaveInstanceOptions)
	```

	You can pass any number of arguments, in any order:
	```lua
	synsaveinstance({ mode = "scripts" }, "myScripts.rbxlx")
	synsaveinstance(workspace.Model) -- Object; saved as a model
	synsaveinstance({ workspace.Model, workspace.OtherModel }) -- ExtraInstances
	```
	@within UniversalSynSaveInstance
	@yields
	@param ... table | Instance | string -- [UniversalSynSaveInstance.SaveInstanceOptions] tables are combined in order. An [Instance] becomes `Object`. A string becomes `FilePath`. A list of Instances becomes `ExtraInstances` and sets `IsModel = true`. If you pass Instances directly and do not set `mode`, `mode` becomes invalid, so only those Instances are saved.
]=]

-- * Accepts any number of arguments, of any type, in any order:
-- *   table    -> options (an array of Instances is treated as ExtraInstances)
-- *   string   -> FilePath option
-- *   Instance -> Object option
local function synsaveinstance(...)
	if USSI.Running then
		return
	end
	USSI.Running = true
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
		RecoverScriptsFromAssets = true,
		-- decomptype = "",
		scriptcache = true,
		SaveBytecode = false,
		BytecodeTimeout = 3,
		SourceCache = false,

		__DEBUG_MODE = false,

		Callback = false,
		CopyToClipboard = false, -- Description: If set to true, the serialized data will be set to the clipboard, which can be later pasted into studio easily.

		DecompileIgnore = {
			-- "Chat",
			"TextChatService",
			ModuleScript = nil,
		},
		IgnoreDefaultPlayerScripts = false,

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
			UGC = true,
			Encoding = false,
			Reflection = false,
		},
		SharedBinaryStrings = false,
		TreatUnionsAsParts = false,
		AlternativeWritefile = true,

		OptionsAliases = { -- You can't really modify these as a user (because they're read before user's Options are loaded)
			Clipboard = "CopyToClipboard",
			DecompileScripts = "Decompile",
			EmbedBytecode = "SaveBytecode",
			FileName = "FilePath",
			IgnoreArchivable = "IgnoreNotArchivable",
			IgnoreDefaultProps = "IgnoreDefaultProperties",
			InstancesBlacklist = "IgnoreList",
			IsolatePlayerGui = "IsolateLocalPlayer",
			Path = "FilePath",
			SaveCharacters = "SavePlayerCharacters",
			SaveLocalPlayer = "IsolateLocalPlayer",
			SaveNilInstances = "NilInstances",
			SaveNonCreatable = "SaveNotCreatable",
			SavePlayerGui = "IsolateLocalPlayer",
			SavePlayers = "IsolatePlayers",
			ShowProgress = "ShowStatus",
			StatusText = "ShowStatus",
			timeout = "DecompileTimeout",
		},
		OptionsAliasesInverse = {
			DisableCompression = "CompressionMode",
			noscripts = "Decompile",
			NullifyScripts = "Decompile",
			RemovePlayerCharacters = "SavePlayerCharacters",
			RemovePlayers = "IsolatePlayers",
			XML = "Binary",
		},
	}
	local OPTIONS_lowercase, OptionsAliasesInverse_lowercase, SaveInstanceOptions_valid = {}, {}, {}

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

		local args = table.pack(...)
		local directInstances = false

		for i = 1, args.n do
			local arg = args[i]
			local Type = typeof(arg)

			if Type == "table" then
				if typeof(arg[1]) == "Instance" then -- * Array of Instances
					OPTIONS.ExtraInstances = arg
					OPTIONS.IsModel = true
					directInstances = true
				else
					for key, value in arg do
						if type(key) ~= "string" then
							warn("Option names must be strings", key)
							continue
						end
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
							SaveInstanceOptions_valid[option] = true
						end
					end
				end
			elseif Type == "Instance" then
				OPTIONS.Object = arg
				directInstances = true
			elseif Type == "string" then
				OPTIONS.FilePath = arg
			end
		end

		if directInstances and SaveInstanceOptions_valid.mode == nil then
			OPTIONS.mode = "invalidmode"
		end
	end

	if not writefile and not (OPTIONS.Callback or OPTIONS.CopyToClipboard) then
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

		USSI.Running = nil
		return
	end

	local InstancesOverrides = {}
	local ClassSerializableCache = {}
	local ReflectionUsable
	local HasAutoRemaps

	local DecompileIgnore, IgnoreList, IgnoreProperties, NotCreatableFixes =
		arrayToDict(OPTIONS.DecompileIgnore, true),
		arrayToDict(OPTIONS.IgnoreList, true),
		arrayToDict(OPTIONS.IgnoreProperties),
		arrayToDict(OPTIONS.NotCreatableFixes, true, "Folder")

	local CopyToClipboard = OPTIONS.CopyToClipboard
	local Callback = OPTIONS.Callback

	local CompressionLevel = OPTIONS.CompressionLevel
	local CompressionMode = OPTIONS.CompressionMode
	if CompressionMode == true then -- ? DisableCompression = false
		CompressionMode = "zstd"
	elseif type(CompressionMode) == "string" then
		CompressionMode = string.lower(CompressionMode)
	end

	local __DEBUG_MODE = OPTIONS.__DEBUG_MODE

	if __DEBUG_MODE and type(__DEBUG_MODE) ~= "function" then
		__DEBUG_MODE = warn
	end

	local LP_UserId, LP_Name, ANON_UserId, ANON_Name, Anonymizers

	local function anonymize(raw, valueType)
		if not Anonymizers then
			return raw
		end
		local fn = Anonymizers[valueType]
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

	if Object and SaveInstanceOptions_valid.IsModel == nil then
		IsModel = true
	end

	local IgnoreDefaultProperties = OPTIONS.IgnoreDefaultProperties
	local IgnoreNotArchivable = not OPTIONS.IgnoreNotArchivable
	local IgnorePropertiesOfNotScriptsOnScriptsMode = OPTIONS.IgnorePropertiesOfNotScriptsOnScriptsMode

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

	local EXEC_STATE_FILE = USSI_FOLDER .. "EXEC_STATE.json"
	local EXEC_STATE_KEY
	local ExecState = {}
	local GHP = {} -- ghp datatype -> "ok"|"failed"|"crashed"
	do
		local execName, execVersion = "UNKNOWN", "0"
		if identify_executor then
			execName, execVersion = identify_executor()
			if not execVersion then
				execVersion = "0"
			end
		end
		EXEC_STATE_KEY = sanitizeFileName(execName .. "_" .. execVersion .. "_" .. FULL_VERSION)
		if readfile then
			local ok, decoded = pcall(function()
				return service.HttpService:JSONDecode(readfile(EXEC_STATE_FILE))
			end)
			if ok and decoded[EXEC_STATE_KEY] then
				ExecState = decoded[EXEC_STATE_KEY]
			end
		end
		GHP = ExecState["ghp"] or {}
		ExecState["ghp"] = GHP
	end

	local function saveExecState()
		if not writefile then
			return
		end
		pcall(writefile, EXEC_STATE_FILE, service.HttpService:JSONEncode({ [EXEC_STATE_KEY] = ExecState }))
	end

	local writerFallback -- ! nil | "writefile" | "xml" when a broken writer forced a switch

	-- * Byte-mangling writers (NUL truncation, newline translation, non-ASCII
	-- * stripping) corrupt a binary save while still reporting success (#216).
	if OPTIONS.Binary and readfile and not (OPTIONS.Callback or OPTIONS.CopyToClipboard) then
		local PROBE_PATH = USSI_FOLDER .. "WRITE_PROBE"
		local probeChars = table.create(256)
		for i = 0, 255 do
			probeChars[i + 1] = string.char(i)
		end
		local PROBE_DATA = table.concat(probeChars)

		local writers = ExecState["writers"] or {}
		ExecState["writers"] = writers
		local probed = false
		local function writerWorks(key, f, calls)
			if writers[key] ~= nil then
				return writers[key]
			end
			probed = true
			if not f or not pcall(writefile, PROBE_PATH, "") then
				return nil -- ! the probe couldn't run at all; a different format wouldn't help
			end
			-- ! a writer that errors counts as broken
			local wrote = pcall(function()
				for _ = 1, calls do
					f(PROBE_PATH, PROBE_DATA)
					task.wait() -- ! the save path yields between appends; Xeno loses data after ~64 yielded appends
				end
			end)
			local ok, contents = pcall(readfile, PROBE_PATH)
			if not ok then
				return nil -- ! a broken reader is indistinguishable from a broken writer here
			end
			writers[key] = wrote and contents == string.rep(PROBE_DATA, calls)
			return writers[key]
		end

		local useAppend = OPTIONS.AlternativeWritefile and appendfile ~= nil
		if
			writerWorks(useAppend and "append" or "write", useAppend and appendfile or writefile, useAppend and 64 or 1)
			== false
		then
			if useAppend and writerWorks("write", writefile, 1) == true then
				OPTIONS.AlternativeWritefile = false
				writerFallback = "writefile"
			else
				OPTIONS.Binary = false
				writerFallback = "xml"
			end
		end

		if probed then
			saveExecState()
			if not delfile or not pcall(delfile, PROBE_PATH) then
				pcall(writefile, PROBE_PATH, "") -- ! no delfile: blank it so no stale copy lingers
			end
		end
	end

	do
		local mode = string.lower(OPTIONS.mode)
		local tmp = table.clone(OPTIONS.ExtraInstances)

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
				if SaveInstanceOptions_valid[key] == nil then
					OPTIONS[key] = false
				end
			end
		end

		local filetype = OPTIONS.Binary and (IsModel and ".rbxm" or ".rbxl") or (IsModel and ".rbxmx" or ".rbxlx")

		if FilePath then
			local hasExtension = string.match(FilePath, "%.[^/\\]+$") ~= nil
			placename = hasExtension and FilePath or (FilePath .. filetype)
		else
			if not cachedPlaceName then
				local ok, info =
					pcall(service.MarketplaceService.GetProductInfoAsync, service.MarketplaceService, game.PlaceId)
				if ok then
					cachedPlaceName = info.Name
					USSI.PlaceName = cachedPlaceName
				end
			end

			local PlaceName = cachedPlaceName and (game.PlaceId .. " " .. cachedPlaceName) or game.PlaceId
			if IsModel then
				placename = sanitizeFileName("model " .. PlaceName .. " " .. (Object or tmp[1] or game):GetFullName())
			else
				placename = sanitizeFileName("place " .. PlaceName)
			end
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

		local savedFiles = USSI.SavedFiles
		if not savedFiles then
			savedFiles = {}
			USSI.SavedFiles = savedFiles
		end

		USSI.Running = nil

		if savedFiles[placename] then -- ? AvoidFileOverwrite kinda messes with this, but shouldn't be an issue
			return
		end

		savedFiles[placename] = true

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
					-- "JointsService",

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

	local lastYield = os.clock()
	local function yieldFrame()
		pcall(task.wait) -- ? Needed for at least 1fps (status text) and resets the watchdog (RenderStepped:Wait doesn't); pcall due to "thread cannot be yielded"
		lastYield = os.clock()
	end

	local function ensureTextRendered()
		service.RunService.PreRender:Wait() -- start of next frame, right before it draws
		service.RunService.Heartbeat:Wait() -- end of that same frame, after it was drawn
		lastYield = os.clock()
	end

	local function yieldIfDue() -- ? Watchdog kills scripts that run >30s without yielding
		if os.clock() - lastYield > 10 then
			yieldFrame()
		end
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
				yieldFrame()
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
	local SourceCache = OPTIONS.SourceCache

	if DecompileJobless then
		OPTIONS.scriptcache = true
	end
	local ScriptCache = OPTIONS.scriptcache and getscriptbytecode
	local ldeccache = ScriptCache and USSI.ScriptCache

	if ScriptCache and not ldeccache then
		ldeccache = {}
		USSI.ScriptCache = ldeccache
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
				elseif DecompileJobless then
					return "-- Not found in already decompiled ScriptCache"
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

	local RecoverScriptsFromAssets = OPTIONS.RecoverScriptsFromAssets
	local sourceAssetCache = {}
	local sourceAssetIds = {}
	local function nodeKey(instance)
		return instance.ClassName .. "\0" .. instance.Name
	end

	local function assetNodeTree(live)
		local node = { children = {} }
		if isLuaSourceContainer(live) then
			node.source = live.Source
		end
		for _, child in live:GetChildren() do
			local key = nodeKey(child)
			if node.children[key] ~= nil then
				node.children[key] = false -- Duplicate names can't be matched reliably to live instances.
			else
				node.children[key] = assetNodeTree(child)
			end
		end
		return node
	end

	local function sourceAssetIdFor(instance)
		local assetId = sourceAssetIds[instance]
		if assetId == nil then
			local result = instance.SourceAssetId
			assetId = result > 0 and result or false
			sourceAssetIds[instance] = assetId
		end
		return assetId or nil
	end

	local function loadTree(assetId)
		local ok, loaded =
			pcall(service.InsertService.LoadLocalAsset, service.InsertService, "rbxassetid://" .. assetId)
		if not (ok and loaded) then
			return false
		end
		local key = nodeKey(loaded)
		local root = assetNodeTree(loaded)
		loaded:Destroy()
		return { children = { [key] = root } }
	end

	local function sourceFromAsset(assetId, chain)
		local node = sourceAssetCache[assetId]
		if node == nil then
			node = loadTree(assetId)
			sourceAssetCache[assetId] = node
		end
		-- chain[#chain] is the asset owner; walk down to chain[1]
		for i = #chain, 1, -1 do
			if not node then
				return
			end
			node = node.children[nodeKey(chain[i])]
		end
		local source = node and node.source
		if source then
			return source, assetId
		end
	end
	local function sourceFor(instance, ldIgnoring)
		if ldIgnoring then
			return "-- Ignored"
		end
		local userSource = SourceCache and SourceCache[instance] -- * SourceCache option: user-supplied source wins over decompiling
		if userSource then
			return userSource
		end
		local value
		local linkedKey
		local recoveredAssetId
		local recoveredSource
		local linkedOk, linkedSourceRaw = pcall(index, instance, "LinkedSource") -- ! AuroraScript has Source but not LinkedSource
		if not linkedOk then
			linkedSourceRaw = ""
		end
		local hasLinkedSource = linkedSourceRaw ~= ""
		if hasLinkedSource then
			linkedKey = string.match(linkedSourceRaw, "%w+$") -- TODO: No sure if this pattern matches all possible cases. Example is: 'rbxassetid://0&hash=cd73dd2fe5e5013137231c227da3167e'
			if not linkedKey then -- * We print this anyway because very important
				warn("FAILED TO EXTRACT LINKEDSOURCE (OPEN A GITHUB ISSUE): ", instance:GetFullName(), linkedSourceRaw)
			end
		end
		local chain = { instance }
		local walk = RecoverScriptsFromAssets and instance
		while walk do
			local sourceAssetId = sourceAssetIdFor(walk)
			if sourceAssetId then
				recoveredSource, recoveredAssetId = sourceFromAsset(sourceAssetId, chain)
				if recoveredSource then
					break
				end
			end

			local parent = walk.Parent
			if not parent then
				break
			end
			chain[#chain + 1] = parent
			walk = parent
		end
		if recoveredAssetId and RecoveredScripts then
			table.insert(RecoveredScripts, instance:GetFullName())
		end

		local isLocalScript = instance:IsA("LocalScript")
		if
			isLocalScript and instance.RunContext == Enum.RunContext.Server
			or not isLocalScript and instance:IsA("Script") and instance.RunContext ~= Enum.RunContext.Client
		then
			if recoveredSource then
				value = recoveredSource
				recoveredSource = nil -- Emitted as the executable source instead of a comment block
			else
				value = "-- [FilteringEnabled] Server Scripts are IMPOSSIBLE to save" -- TODO: Could be not just server scripts in the future
			end
		else
			value = ldecompile(instance)
			if SaveBytecode then
				local output = SaveBytecode(instance)
				if output then
					value = output .. value
				end
			end
		end

		local assetSourceBlock = ""
		if recoveredSource then
			local level = 0
			for eqs in string.gmatch(recoveredSource, "%](=*)%]") do
				if #eqs >= level then
					level = #eqs + 1
				end
			end
			local eq = string.rep("=", level)
			assetSourceBlock = "--[" .. eq .. "[\n" .. recoveredSource .. "\n]" .. eq .. "]\n\n"
		end

		value = "-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw\n\n"
			.. (hasLinkedSource and "-- Original Source: https://assetdelivery.roblox.com/v1/asset/?" .. (linkedKey and string.find(
				linkedKey,
				"%a"
			) and "hash" or "id") .. "=" .. (linkedKey or linkedSourceRaw) .. "\n\n" or "")
			.. (recoveredAssetId and "-- Original SourceAssetId: https://assetdelivery.roblox.com/v1/asset/?id=" .. recoveredAssetId .. "\n\n" or "")
			.. (recoveredAssetId and "-- ! Source from the asset above; the game may have edited it since.\n\n" or "")
			.. assetSourceBlock
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

	local function isClassSerializable(className)
		local known = ClassSerializableCache[className]
		if known ~= nil then
			return known
		end

		local function getSerialized(name)
			return pcall(function()
				return service.ReflectionService:GetClass(name, REFLECTION_FILTER).Serialized -- ! Some execs (like Xeno) error on ReflectionService due to their ProxyService
			end)
		end

		if ReflectionUsable == nil then
			local ok, partSerialized = getSerialized("Part")
			ReflectionUsable = not RiskyServicesDisabled.Reflection and ok and partSerialized == true
		end

		local serializable = true
		if ReflectionUsable then
			local ok, serialized = getSerialized(className)
			serializable = not ok or serialized == true -- ? Serialized is either true or nil, NEVER false
		end

		ClassSerializableCache[className] = serializable
		return serializable
	end

	local function refIsInvalid(target, valueType)
		if not target then
			return false
		end
		local className = target.ClassName

		local fix = NotCreatableFixes[className] or nil
		if fix then
			if not SaveNotCreatableWillBeEnabled then
				return false -- collect drops these outright rather than remapping them
			end
		elseif not isClassSerializable(className) then
			-- collect remaps these no matter what SaveNotCreatable says
			fix = "Folder"
		end
		return fix ~= nil and (valueType ~= "Instance" and valueType ~= fix)
	end

	local function nilIsValid(category, optional)
		return optional ~= nil or category == "Class"
	end

	local function filterPropVal(result, property, category, optional) -- ? raw == nil thanks to SerializedDefaultAttributes; "can't get value" - due to WriteOnly tag;  "Invalid value for enum " - "StreamingPauseMode" (old games probably) Roexec
		if result == nil then
			return not nilIsValid(category, optional)
		end
		if result == "can't get value" then
			return true
		end

		if type(result) ~= "string" or #result > 256 then
			return false
		end
		if category == "Enum" then
			return true
		end
		local needle = property.ErrNeedle
		if not needle then
			needle = "Unable to get property " .. property.Name
			property.ErrNeedle = needle
		end
		return string_find(result, needle) ~= nil
	end

	local GHPDatatypeState = {}
	local GHPShadowed = true -- true when ghp returns the shadowed (parent) property value instead of the shadow

	local function ghpDatatypeAllowed(valueType)
		local state = GHPDatatypeState[valueType]
		if state ~= nil then
			return state
		end

		local persisted = GHP[valueType]
		if persisted == "ok" then
			state = true
		elseif persisted == "failed" or persisted == "crashed" then
			state = false
		else
			local text
			if StatusText then
				text = StatusText.Text
				StatusText.Text = "GHP test. Crash = rerun script few times"
			end
			ensureTextRendered()

			GHP[valueType] = "crashed" -- * treated as crashed until the upcoming read reports back; if this state ever reaches the save file it means the game died mid-read (or was closed before it finished)
			saveExecState()
			if StatusText then
				StatusText.Text = text
			end
			state = true
		end

		GHPDatatypeState[valueType] = state
		return state
	end

	local function ghpDatatypeReport(valueType, ok)
		local wantState = ok and "ok" or "failed"
		if GHP[valueType] == wantState then
			return
		end
		GHP[valueType] = wantState
		GHPDatatypeState[valueType] = ok
		saveExecState()
	end

	local function readProperty(instance, property)
		local PropertyName, ValueType, CanRead, Special =
			property.Name, property.ValueType, property.CanRead, property.Special

		-- Hot path
		if
			Anonymizers == nil
			and InstancesOverrides[instance] == nil
			and CanRead == true
			and not Special
			and not (ValueType == "ProtectedString" and PropertyName == "Source")
		then
			return instance[PropertyName]
		end

		local raw = __BREAK

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

		local Category, Optional = property.Category, property.Optional

		if CanRead ~= false then
			local GHPKey = (Category == "Enum" or Category == "Class") and Category or ValueType

			if Special then
				if property.Shadows and GHPShadowed then
					property.CanRead = false
				elseif gethiddenproperty and ghpDatatypeAllowed(GHPKey) then
					local ok, result = pcall(gethiddenproperty, instance, PropertyName)
					if ok then
						raw = result
					end

					local filtered = filterPropVal(raw, property, Category, Optional)
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
				elseif not (property.Shadows and GHPShadowed) and gethiddenproperty and ghpDatatypeAllowed(GHPKey) then
					ok, result = pcall(gethiddenproperty, instance, PropertyName)
					ghpDatatypeReport(GHPKey, ok and not filterPropVal(result, property, Category, Optional))
					if ok then
						raw = result
						property.Special = true
					end
				end

				property.CanRead = ok

				if not ok or filterPropVal(raw, property, Category, Optional) then
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
			local ok, result
			if gethiddenproperty_fallback then
				ok, result = pcall(gethiddenproperty_fallback, instance, PropertyName)
			end
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

			yieldIfDue()

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
				if onIgnoredList == false then
					skipEntirely = false -- keep this instance, skip its descendants
				elseif onIgnoredList and (onIgnoredList == true or onIgnoredList[name]) then
					return
				end

				local fix = NotCreatableFixes[class]

				if fix then
					if not SaveNotCreatable then
						return -- They won't show up in Studio anyway (Enable SaveNotCreatable if you wish to bypass this)
					end
					class, override = fix, replaceClassName(instance, name, class)
					if class == "Folder" then
						propClass = "Instance"
					end
				elseif TreatUnionsAsParts and instance:IsA("PartOperation") then
					class, override = "Part", replaceClassName(instance, name, class)
					propClass = "BasePart"
				elseif not isClassSerializable(class) then
					class, override, propClass = "Folder", replaceClassName(instance, name, class), "Instance"
					HasAutoRemaps = true
				elseif not ClassList[class] then
					if __DEBUG_MODE then
						__DEBUG_MODE("Class not Found", class)
					end
					unknownTag, class, propClass = class, "Folder", "Instance"
				end
			elseif tagOverride == "Folder" then
				propClass = "Instance"
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

			refs[instance] = ctx.instCount
			ctx.instCount += 1

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
			local node = {}
			InstancesOverrides[node] = {
				__ClassName = customClassName,
				__Virtual = customClassName,
				__Children = children or {},
				Properties = properties,
			}
			extra.roots = { node }
		end

		pendingExtras[#pendingExtras + 1] = extra
		return extra
	end

	local function emitBinary(ctx)
		local function readAll(objs, prop)
			local n = #objs
			local vals = table.create(n)

			for i = 1, n do
				yieldIfDue()
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
			local head = buffer.create(16)
			buffer.writestring(head, 0, name)

			if compress then
				local dataStr = compress(chunkBuf:tostring())
				if dataStr and #dataStr < uncompressedLen then
					buffer.writeu32(head, 4, #dataStr)
					buffer.writeu32(head, 8, uncompressedLen)
					return { buf = head, len = 16, str = dataStr }
				end
			end

			-- compressedLength and reserved remain zero in the fresh header.
			buffer.writeu32(head, 8, uncompressedLen)

			return {
				buf = head,
				len = 16,
				tailBuf = chunkBuf.buf,
				tailLen = uncompressedLen,
			}
		end

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

		local chunks, propChunks = {}, {}

		local lastStatus = 0

		local function emit(chunk)
			chunks[#chunks + 1] = chunk
			totalsize += chunk.len + (chunk.str and #chunk.str or chunk.tailLen or 0)

			if StatusText then
				local now = os.clock()
				if now - lastStatus > 1 then
					lastStatus = now
					StatusText.Text = "Saving.. Size: " .. get_size_format()
					yieldFrame()
				end
			end
		end

		do
			local header = buffer.create(32)
			buffer.writestring(header, 0, "\60\114\111\98\108\111\120\33\137\255\13\10\26\10\0\0") -- magic
			buffer.writei32(header, 16, instTypeCount)
			buffer.writei32(header, 20, instCount)
			emit({ buf = header, len = 32 }) -- reserved tail remains zero
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
				buffer.fill(instBuf.buf, instBuf:allocRegion(n), 1, n)
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

					local chunk = buildChunk("PROP", buf, not isSource and compress or nil) -- ! Assumes README is the only one that uses .Source, expect anything that does to be uncompressed
					propChunks[#propChunks + 1] = chunk
					totalsize += chunk.len + (chunk.str and #chunk.str or chunk.tailLen or 0)
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

					local binaryType = valueType
					local refCtxArg = nil

					if prop.Category == "Enum" then
						binaryType = "Enum"
					elseif prop.Category == "Class" then
						binaryType = "Referent"
						refCtxArg = refs
					elseif binaryType == "Content" then
						refCtxArg = refs
					end

					local encoder = Binary_Encoders[binaryType]
					local typeId = Type_Ids[binaryType]
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
						if (SaveNotCreatableWillBeEnabled or HasAutoRemaps) and prop.Category == "Class" then
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
						local chunk = buildChunk("PROP", propBuf, compress)
						propChunks[#propChunks + 1] = chunk
						totalsize += chunk.len + (chunk.str and #chunk.str or chunk.tailLen or 0)
					else
						warn("UNSUPPORTED BINARY TYPE (OPEN A GITHUB ISSUE): ", propName, binaryType)
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
			sstrBuf:allocRegion(4) -- version 0 in fresh zeroed capacity
			sstrBuf:writeu32(sharedStringCtx.count)
			for i = 1, sharedStringCtx.count do
				sstrBuf:allocRegion(16) -- Fresh StreamBuffer capacity is already zeroed.
				sstrBuf:writeLenString(sharedStringCtx.order[i])
			end
			local chunk = buildChunk("SSTR", sstrBuf, compress)
			table.insert(chunks, sstrSlot, chunk)

			totalsize += chunk.len + (chunk.str and #chunk.str or chunk.tailLen or 0)
		end

		if #propChunks > 0 then
			table.move(propChunks, 1, #propChunks, #chunks + 1, chunks)
		end

		-- PRNT chunk: two interleaved i32 zigzag-delta planes (object ref, parent ref)
		do
			local prntBuf = StreamBuffer.new(16 + instCount * 8)
			prntBuf:allocRegion(1) -- version 0 in fresh zeroed capacity
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

		-- Preserve one output string per logical chunk without concatenating
		-- temporary strings. Each chunk gets one exact allocation and copy pass.
		local out = table.create(#chunks)
		for i, c in chunks do
			local payloadLen = c.str and #c.str or c.tailLen or 0
			if payloadLen == 0 then
				out[i] = buffer.readstring(c.buf, 0, c.len)
				continue
			end

			local chunkBuf = buffer.create(c.len + payloadLen)
			buffer.copy(chunkBuf, 0, c.buf, 0, c.len)
			if c.str then
				buffer.writestring(chunkBuf, c.len, c.str)
			else
				buffer.copy(chunkBuf, c.len, c.tailBuf, 0, payloadLen)
			end
			out[i] = buffer.tostring(chunkBuf)
		end

		return out
	end

	local function emitXML(ctx)
		local chunks = table.create(1)
		local savebuffer, savebuffer_size = {}, 1
		local header =
			'<!-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw --><roblox version="4">'
		local refs = ctx.refs

		local function ReturnProperty(tag, propertyName, value)
			return "<" .. tag .. ' name="' .. propertyName .. '">' .. value .. "</" .. tag .. ">"
		end

		local function ReturnValueAndTag(raw, valueType, encoder)
			local value, tag = (encoder or XML_Encoders[valueType])(raw)
			return value, tag or valueType
		end

		local function ReturnItem(className, instance)
			return '<Item class="' .. className .. '" referent="' .. refs[instance] .. '"><Properties>' -- TODO: Ideally this shouldn't return <Properties> as well as the line below to close it IF  IgnorePropertiesOfNotScriptsOnScriptsMode is Enabled OR If all properties are default (reduces file size by at least 1.4%)
		end

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

			yieldFrame()
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
						-- 				ReturnProperty("Ref", "__attrRef_" .. name, refs[v] ~= nil and refs[v] or "null")
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
							if raw and refs[raw] ~= nil and not refIsInvalid(raw, ValueType) then
								value = refs[raw]
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
				if instance:IsA("ServiceProvider") then -- ? game, UserSettings & GlobalSettings roots; their services (e.g. UserGameSettings) can't be parented elsewhere
					instance = nil
				else
					local ClassName = instance.ClassName

					local Fix = NilInstancesFixes[ClassName]
					if Fix == nil then
						for class_name, inheritedFix in NilInstancesFixes do
							if instance:IsA(class_name) then
								Fix = inheritedFix
								break
							end
						end
					end

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
		You saved as XML, not Binary (rbxl). To convert: FILE -> Save to File As, name it .rbxl. This keeps the binary format and preserves properties ignored by IgnoreDefaultProperties.

]]
			end

			local helpText = [[
		ServerStorage, ServerScriptService and Server Scripts are IMPOSSIBLE to save because of FilteringEnabled.

		Images, meshes, textures, sounds etc. failed to load or look invisible? Those assets are private. Try https://github.com/kartFr/Asset-Reuploader or similar.

		Player doesn't spawn? Move or delete the scripts in StarterPlayer, then run game:GetService("Players").CharacterAutoLoads = true
		Use "Play Here" instead of "Play" to spawn where your Camera is.

		Chat broken? Delete everything in TextChatService/Chat, or run game:GetService("Chat"):ClearAllChildren() game:GetService("TextChatService"):ClearAllChildren()

		Union/MeshPart collisions broken? Run this in the Studio Command Bar:


		local C = game:GetService("CoreGui")
		local E = Enum.CollisionFidelity:GetEnumItems()
		local O = {}

		for _, v in game:GetDescendants() do
			if v:IsA("TriangleMeshPart") and not v:IsDescendantOf(C) then
				local c = v.CollisionFidelity
				O[v] = c
				v.CollisionFidelity = E[1] ~= c and E[1] or E[2]
			end
		end

		for v, c in O do
			v.CollisionFidelity = c
		end
		print("Done")

		Camera stuck? Run this in the Studio Command Bar:

		workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed

		Or destroy the Camera.

		Settings:
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
				tostring(game.PlaceId),
				" PlaceVersion: ",
				tostring(game.PlaceVersion),
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
					recoveredNote = "\t\tIMPORTANT: Original Source of these Scripts was RECOVERED: "
						.. service.HttpService:JSONEncode(RecoveredScripts)
						.. "\n\n"
				end

				local failedTypes, crashTypes = {}, {}
				for datatype, state in GHP do
					if state == "crashed" then
						table.insert(crashTypes, datatype)
					elseif state == "failed" then
						table.insert(failedTypes, datatype)
					end
				end
				table.sort(failedTypes)
				table.sort(crashTypes)

				local ghpFailureHeader = ""
				if #failedTypes > 0 or #crashTypes > 0 then
					ghpFailureHeader ..= [[
		!! GETHIDDENPROPERTY ISSUES !!
		Your executor's gethiddenproperty couldn't read these types, so data may be missing or wrong.
		Tell your executor's developers. Affected types:
		]]
					if #failedTypes > 0 then
						ghpFailureHeader ..= "\t\tFailed reads: " .. service.HttpService:JSONEncode(failedTypes) .. "\n"
					end
					if #crashTypes > 0 then
						ghpFailureHeader ..= "\t\tCrashed a previous run (now skipped): " .. service.HttpService:JSONEncode(
							crashTypes
						) .. "\n"
					end
					ghpFailureHeader ..= "\n"
				end

				local writerFailureHeader = ""
				if writerFallback == "writefile" then
					writerFailureHeader = [[
		!! FILE WRITER ISSUES !!
		Your executor's appendfile can't store data faithfully - it can SILENTLY CORRUPT or SHORTEN the file - so this save used writefile instead.
		Tell your executor's developers.

]]
				elseif writerFallback == "xml" then
					writerFailureHeader = [[
		!! FILE WRITER ISSUES !!
		Your executor's file functions can't store data faithfully, so a binary save would be CORRUPT - this save used XML (.rbxlx) instead.
		Tell your executor's developers.

]]
				end

				return table.concat({
					"--[[\n",
					"\t\tThank you for using UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw\n\n",
					recoveredNote,
					ghpFailureHeader,
					writerFailureHeader,
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
		USSI.SavedFiles[placename] = nil
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

	if OPTIONS.SafeMode and SaveInstanceOptions_valid["KillAllScripts"] == nil then
		OPTIONS.KillAllScripts = true
	end

	if OPTIONS.KillAllScripts and not USSI.KillAllScripts then
		USSI.KillAllScripts = true
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

	if not IsolatePlayers and SaveInstanceOptions_valid.SaveNotCreatable == nil then
		IgnoreList.Player = true
	end

	if OPTIONS.ShowStatus then
		do
			local Exists = USSI.StatusGui
			if Exists then
				Exists:Destroy()
			end
		end

		local StatusGui = Instance.new("ScreenGui")

		USSI.StatusGui = StatusGui

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
	local kickSnapshot = USSI.KickSnapshot
	if not kickSnapshot then
		kickSnapshot = {}
		USSI.KickSnapshot = kickSnapshot
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
			ensureTextRendered()
		end)

		if SaveInstanceOptions_valid["BoostFPS"] == nil then
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

	local RiskyOption = OPTIONS.RiskyServicesDisabled
	RiskyServicesDisabled = type(RiskyOption) == "table" and table.clone(RiskyOption)
	if not gethiddenproperty and SaveInstanceOptions_valid.RiskyServicesDisabled == nil then
		RiskyServicesDisabled.UGC = false
	end
	gethiddenproperty_fallback = nil
	if not RiskyServicesDisabled.UGC then
		gethiddenproperty_fallback = function(instance, propertyName)
			return service.UGCValidationService:GetPropertyValue(instance, propertyName)
		end
	end

	if not ClassList then -- means first run
		do -- * Load Region of Déjà Vu
			if gethiddenproperty then
				local ard = Instance.new("AnimationRigData")

				local GHP_SELF_CHECKS = {
					{
						key = "boolean",
						fatal = true,
						test = function()
							-- Xeno uses UGC and returns 0
							return type(gethiddenproperty(game, "ForceR15")) == "boolean"
						end,
					},
					{
						key = "Enum",
						test = function()
							local r = gethiddenproperty(workspace, "StreamOutBehavior")
							return r == nil or typeof(r) == "EnumItem"
						end,
					},
					{
						key = "Color3uint8",
						retest = true,
						test = function()
							local terrain = workspace.Terrain
							return gethiddenproperty(terrain, "Color3uint8") == terrain.Color
						end,
					},
					{
						key = "int64",
						retest = true,
						test = function()
							return gethiddenproperty(ard, "SourceAssetId") == ard.SourceAssetId
						end,
					},
					{
						key = "string",
						test = function()
							local desc = Instance.new("HumanoidDescription")
							desc:SetEmotes({ Hello = { 3576686446 } })
							return type(gethiddenproperty(desc, "EmotesDataInternal")) == "string"
						end,
					},
					{
						key = "BinaryString",
						retest = true,
						test = function()
							ard:SetAttribute("test", "test")
							return gethiddenproperty(ard, "AttributesSerialize") == "\1\0\0\0\4\0\0\0test\2\4\0\0\0test"
						end,
					},
					{
						key = "SharedString",
						test = function()
							ard:AddTag("\1test\2\4test")
							return gethiddenproperty(ard, "Tags") == "\1test\2\4test"
						end,
					},
					{
						key = "NetAssetRef",
						test = function()
							return type(gethiddenproperty(Instance.new("MeshPart"), "SolidMeshHolder")) == "string"
						end,
					},
					{
						dep = "BinaryString",
						test = function()
							ard.Parent = Instance.new("Folder")
							local ok, r = pcall(gethiddenproperty, ard, "parent")
							GHPShadowed = ok and r ~= nil and type(r) ~= "string"
							return not GHPShadowed
						end,
					},
					{
						key = "OptionalCoordinateFrame",
						test = function()
							local m = Instance.new("Model")
							local cf = CFrame.new(1, 2, 3)
							m.WorldPivot = cf
							return gethiddenproperty(m, "WorldPivotData") == cf
						end,
					},
				}

				local statusShown
				for _, check in GHP_SELF_CHECKS do
					local key = check.key
					if key then
						local state = GHP[key]
						if state == "crashed" then
							if check.fatal then
								gethiddenproperty = nil
								break
							end
							continue
						elseif state and check.fatal and state ~= "ok" then
							gethiddenproperty = nil
							break
						elseif state and not check.retest then
							continue
						end
					end

					if check.dep and GHP[check.dep] == "crashed" then
						continue
					end

					if key then
						GHP[key] = "crashed"
						saveExecState()
					end

					if StatusText and not statusShown then
						statusShown = true
						StatusText.Text = "GHP test. Crash = rerun script few times"
						ensureTextRendered()
					end
					local ok, passed = pcall(check.test)
					passed = ok and passed
					if key then
						ghpDatatypeReport(key, passed)
					end
					if not passed and check.fatal then
						gethiddenproperty = nil
						break
					end
				end
			end

			if not gethiddenproperty and SaveInstanceOptions_valid.RiskyServicesDisabled == nil then
				RiskyServicesDisabled.UGC = false
				gethiddenproperty_fallback = function(instance, propertyName)
					-- * This helps in reading: Vector3int16, OptionalCoordinateFrame DataTypes. It also acts as an almost entire fallback for gethiddenproperty in case it is missing
					return service.UGCValidationService:GetPropertyValue(instance, propertyName) -- TODO Sadly there's no way to tell whether value is actually nil or the function just couldn't read it (always returns nil for "Class" category properties)
					-- TODO `category ~= "Class"` causes WeldConstraint Part1Internal to be read as nil and not get unfiltered. Currently, there are no properties of category "Class" that match the following: NotScriptable, can be read with gethiddenproperty_fallback accurately (it always outputs nil for "Class" category, making that check useless anyway) & don't have a NotScriptableFix.
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
	local old_gethiddenproperty
	if OPTIONS.IgnoreSpecialProperties and gethiddenproperty then
		old_gethiddenproperty = gethiddenproperty
		gethiddenproperty = nil
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
				pcall,
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

	if not ok then
		warn("Error found while saving:")
		warn(err)
	end
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
