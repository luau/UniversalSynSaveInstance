-- LuaEncode - Fast table serialization library for pure Luau/Lua 5.1+
-- MIT License | Copyright (c) 2022-2025 Chad Hyatt <chad@hyatt.page>
-- https://github.com/chadhyatt/LuaEncode

--!optimize 2
--!native

local table, string, next, pcall, game, workspace, tostring, tonumber, getmetatable =
	table, string, next, pcall, game, workspace, tostring, tonumber, getmetatable

local string_format = string.format
local string_char = string.char
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_sub = string.sub
local string_gmatch = string.gmatch

local table_concat = table.concat

local Type = typeof or type

local function LookupTable(array)
	local Out = {}
	for _, Value in next, array do
		Out[Value] = true
	end

	return Out
end

-- Used for checking direct getfield syntax; Lua keywords can't be used as keys without being a str
-- FYI; `continue` is Luau only (in Lua it's actually a global function)
local LuaKeywords = LookupTable({
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while",
	"continue",
})

-- Type names that can be used as manual key indexes (i.e. non-reference types)
local KeyIndexTypes = LookupTable({
	"number",
	"string",
	"boolean",
	"Enum",
	"EnumItem",
	"Enums",
})

local DirectIndexPat = "^[A-Za-z_][A-Za-z0-9_]*$"

local function CheckType(inputData, dataName, ...)
	local ValidTypes = { ... }
	local ValidTypesLookup = LookupTable(ValidTypes)
	local InputType = Type(inputData)

	if not ValidTypesLookup[InputType] then
		error(
			string_format(
				"LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`",
				dataName,
				table_concat(ValidTypes, ", "), -- For if multiple types are accepted
				InputType
			),
			0
		)
	end

	return inputData
end

-- This re-serializes a string back into Lua, for the interpreter AND humans to read. This fixes
-- `string_format("%q")` only outputting in system encoding, instead of explicit Lua byte escapes
local SerializeString
do
	-- These are control characters to be encoded in a certain way in Lua rather than just a byte escape
	local SpecialCharacters = {
		['"'] = '\\"',
		["\\"] = "\\\\",
		["\a"] = "\\a",
		["\b"] = "\\b",
		["\t"] = "\\t",
		["\n"] = "\\n",
		["\v"] = "\\v",
		["\f"] = "\\f",
		["\r"] = "\\r",
	}

	for Index = 0, 255 do
		local Character = string_char(Index)

		if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
			SpecialCharacters[Character] = string_format("\\x%02X", Index)
		end
	end

	function SerializeString(inputString)
		-- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
		-- issue. See: https://stackoverflow.com/a/22962409
		return table_concat({ '"', string_gsub(inputString, '[%z\\"\1-\31\127-\255]', SpecialCharacters), '"' })
	end
end

-- Escape warning messages and such for comment block inserts
local function CommentBlock(inputString)
	local Longest = -1
	for Match in string_gmatch(inputString, "%](=*)%]") do
		if #Match > Longest then
			Longest = #Match
		end
	end

	local Padding = string_rep("=", Longest + 1)
	return "--[" .. Padding .. "[" .. inputString .. "]" .. Padding .. "]"
end

local EvaluateInstancePath
do
	local function IsService(object)
		-- Logically, if an object is actually under a service, that service *has* to already exist, as we've
		-- presumably evaluated to said path
		local FindServiceSuccess, ServiceObject = pcall(game.FindService, game, object.ClassName)
		if FindServiceSuccess and ServiceObject then
			return true
		end

		return false
	end

	-- Evaluates an instances' accessable "path" with just it's ref, and if the root parent is nil/isn't
	-- under `game` or `workspace`, returns nil.
	function EvaluateInstancePath(object, useFindFirstChild)
		local ObjectPointer = object
		if not ObjectPointer then
			return
		end

		local Path = ""

		while ObjectPointer do
			local ObjectName = ObjectPointer.Name
			local ObjectClassName = ObjectPointer.ClassName
			local ObjectParent = ObjectPointer.Parent

			if ObjectParent == game and IsService(ObjectPointer) then
				-- ^^ Then we'll use GetService directly, since it's actually a service under the DataModel

				Path = ":GetService(" .. SerializeString(ObjectClassName) .. ")" .. Path
			elseif useFindFirstChild then
				Path = ":FindFirstChild(" .. SerializeString(ObjectName) .. ")" .. Path
			elseif not LuaKeywords[ObjectName] and string_match(ObjectName, DirectIndexPat) then
				-- ^^ Like the string data type, this means means we can index the name directly in Lua
				-- without an explicit string
				Path = "." .. ObjectName .. Path
			else
				Path = "[" .. SerializeString(ObjectName) .. "]" .. Path
			end

			if ObjectParent == game then
				Path = "game" .. Path
				return Path
			elseif ObjectParent == workspace then
				Path = "workspace" .. Path
				return Path
			end

			-- Advance ObjectPointer, whether it exists or not
			ObjectPointer = ObjectParent
		end

		return
	end
end

--[[
LuaEncode(inputTable: {[any]: any}, options: {[string]: any}): string

    ---------- OPTIONS: ----------

    Prettify <boolean:false> | Whether or not the output should be pretty printed

    IndentCount <number:0> | The amount of characters that should be used for indents
    (**Note**: If `Prettify` is set to true and this is unspecified, it will default to `4`)

    InsertCycles <boolean:false> | If there are cyclic references in your table, the output
    will be wrapped in an anonymous function that manually sets paths to those references.
    (**NOTE:** If a key in the index path to the cycle is a reference type (e.g. `table`,
    `function`), the codegen can't externally set that path, and the value will have to be ignored)

    OutputWarnings <boolean:true> | If "warnings" should be placed into the output as
    comment blocks

    FunctionsReturnRaw <boolean:false> | If `function` values should be treated as callbacks
    that return a string to be inserted directly into the serialized output as the key/value

    UseInstancePaths <boolean:true> | If Roblox `Instance` values should return their
    Lua-accessable path for serialization. If the instance is parented under `nil` or
    isn't under `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)`

    UseFindFirstChild  <boolean:true> | When `options.UseInstancePaths` is true, whether or
    not instance paths should use `FindFirstChild` instead of direct indexes

    SerializeMathHuge <boolean:true> | If "infinite" (or negative-infinite) numbers should
    be serialized as `math.huge`. (uses the `math` global, as opposed to just a direct data
    type) If false, "`1/0`" or "`-1/0`" will be serialized, which is supported on all
    target Lua environments

]]

local function LuaEncode(inputTable, options)
	options = options or {}

	CheckType(inputTable, "inputTable", "table")
	CheckType(options, "options", "table")

	CheckType(options.Prettify, "options.Prettify", "boolean", "nil")
	CheckType(options.PrettyPrinting, "options.PrettyPrinting", "boolean", "nil") -- Alias for `Options.Prettify`
	CheckType(options.IndentCount, "options.IndentCount", "number", "nil")
	CheckType(options.InsertCycles, "options.InsertCycles", "boolean", "nil")
	CheckType(options.OutputWarnings, "options.OutputWarnings", "boolean", "nil")
	CheckType(options.FunctionsReturnRaw, "options.FunctionsReturnRaw", "boolean", "nil")
	CheckType(options.UseInstancePaths, "options.UseInstancePaths", "boolean", "nil")
	CheckType(options.UseFindFirstChild, "options.UseFindFirstChild", "boolean", "nil")
	CheckType(options.SerializeMathHuge, "options.SerializeMathHuge", "boolean", "nil")

	CheckType(options._StackLevel, "options._StackLevel", "number", "nil")
	CheckType(options._VisitedTables, "options._VisitedTables", "table", "nil")
	CheckType(options._SharedTableLarpAsRegTable, "options._SharedTableLarpAsRegTable", "boolean", "nil")

	local Prettify = (options.Prettify == nil and options.PrettyPrinting == nil and false)
		or (options.Prettify ~= nil and options.Prettify)
		or (options.PrettyPrinting and options.PrettyPrinting)
	local IndentCount = options.IndentCount or (Prettify and 4) or 0
	local InsertCycles = (options.InsertCycles == nil and false) or options.InsertCycles
	local OutputWarnings = (options.OutputWarnings == nil and true) or options.OutputWarnings
	local FunctionsReturnRaw = (options.FunctionsReturnRaw == nil and false) or options.FunctionsReturnRaw
	local UseInstancePaths = (options.UseInstancePaths == nil and true) or options.UseInstancePaths
	local UseFindFirstChild = (options.UseFindFirstChild == nil and true) or options.UseFindFirstChild
	local SerializeMathHuge = (options.SerializeMathHuge == nil and true) or options.SerializeMathHuge

	local StackLevelOpt = options._StackLevel or 1
	local VisitedTables = options._VisitedTables or {} -- [Ref: table] = true
	local SharedTableLarpAsRegTable = options._SharedTableLarpAsRegTable or false

	-- Lazy serialization reference values
	local PositiveInf = (SerializeMathHuge and "math.huge") or "1/0"
	local NegativeInf = (SerializeMathHuge and "-math.huge") or "-1/0"
	local NewEntryString = (Prettify and "\n") or ""
	local CodegenNewline = (Prettify and "\n") or " "
	local ValueSeperator = (Prettify and ", ") or ","
	local BlankSeperator = (Prettify and " ") or ""
	local EqualsSeperator = (Prettify and " = ") or "="

	local StackLevel = StackLevelOpt

	-- For pretty printing we need to keep track of the current stack level, then repeat IndentString by that count
	local IndentStringBase = string_rep(" ", IndentCount)

	-- Calculated in the walk loop, based on the current StackLevel
	local IndentString = nil
	local EndingIndentString = nil

	--IndentString = (Prettify and string_rep(IndentString, StackLevel)) or IndentString
	--local EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

	-- For number key values, we want to explicitly serialize the index num ONLY when it needs to be
	local KeyNumIndex = 1

	-- Cases for encoding values, then end setup. Functions are all expected to return a (EncodedKey: string, EncloseInBrackets: boolean)
	local TypeCases = {}
	do
		local function TypeCase(typeName, value, ...)
			local EncodedValue = TypeCases[typeName](value, false, ...) -- False to label as NOT `isKey`
			return EncodedValue
		end

		local function Args(...)
			local EncodedValues = {}

			for _, Arg in next, { ... } do
				EncodedValues[#EncodedValues + 1] = TypeCase(Type(Arg), Arg)
			end

			return table_concat(EncodedValues, ValueSeperator)
		end

		-- For Roblox's different `Params` data types
		local function Params(newData, params)
			return "(function(p, t) for n, v in next, t do p[n] = v end return p end)("
				.. table_concat({ newData, TypeCase("table", params) }, ValueSeperator)
				.. ")"
		end

		TypeCases["number"] = function(value, isKey)
			-- If the number isn't the current real index of the table, we DO want to
			-- explicitly define it in the serialization no matter what for accuracy
			if isKey and value == KeyNumIndex then
				-- What's EXPECTED unless otherwise explicitly defined, if so, return no encoded num
				KeyNumIndex = KeyNumIndex + 1
				return nil, true
			end

			-- Special cases
			if value == 1 / 0 then
				return PositiveInf
			elseif value == -1 / 0 then
				return NegativeInf
			end

			-- Return fixed-formatted precision num
			return string_format("%.14g", value)
		end

		TypeCases["string"] = function(value, isKey)
			if isKey and not LuaKeywords[value] and string_match(value, DirectIndexPat) then
				-- Doesn't need full string def
				return value, true
			end

			return SerializeString(value)
		end

		-- This is NOT used for recursive table serialization, only table-as-key values and Roblox data types that use tables as
		-- arguments for constructor functions
		TypeCases["table"] = function(value, isKey, stLarpAsRegTable)
			-- Primarily for tables-as-keys
			if VisitedTables[value] and OutputWarnings then
				return "{--[[LuaEncode: Duplicate reference]]}"
			end

			local NewOptions = setmetatable({}, { __index = options })
			do
				NewOptions.Prettify = (isKey and false) or Prettify
				NewOptions.IndentCount = (isKey and ((not Prettify and IndentCount) or 1)) or IndentCount
				NewOptions._StackLevel = (isKey and 1) or StackLevel + 1
				NewOptions._VisitedTables = VisitedTables
				NewOptions._SharedTableLarpAsRegTable = (not isKey and stLarpAsRegTable)
			end

			return LuaEncode(value, NewOptions)
		end

		TypeCases["boolean"] = function(value)
			return value and "true" or "false"
		end

		TypeCases["nil"] = function(value)
			return "nil"
		end

		TypeCases["function"] = function(value)
			-- If `options.FunctionsReturnRaw` is enabled, we'll call the function here itself, expecting
			-- a raw value to insert as the serialized key/value
			if FunctionsReturnRaw then
				return value()
			end

			return string_format(
				"function()%send",
				(OutputWarnings and " --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] ")
					or ""
			)
		end

		---------- ROBLOX CUSTOM DATA TYPES BELOW ----------

		TypeCases["Axes"] = function(value)
			local EncodedArgs = {}
			local EnumValues = {
				["Enum.Axis.X"] = value.X,
				["Enum.Axis.Y"] = value.Y,
				["Enum.Axis.Z"] = value.Z,
			}

			for EnumValue, IsEnabled in next, EnumValues do
				if IsEnabled then
					EncodedArgs[#EncodedArgs + 1] = EnumValue
				end
			end

			return "Axes.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
		end

		TypeCases["BrickColor"] = function(value)
			-- BrickColor.Number (Its enum ID) will be slightly more efficient in all cases in deser,
			-- so we'll use it if Options.Prettify is false
			return "BrickColor.new(" .. ((Prettify and TypeCase("string", value.Name)) or value.Number) .. ")"
		end

		TypeCases["CFrame"] = function(value)
			return "CFrame.new(" .. Args(value:components()) .. ")"
		end

		TypeCases["CatalogSearchParams"] = function(value)
			return Params("CatalogSearchParams.new()", {
				SearchKeyword = value.SearchKeyword,
				MinPrice = value.MinPrice,
				MaxPrice = value.MaxPrice,
				SortType = value.SortType, -- EnumItem
				CategoryFilter = value.CategoryFilter, -- EnumItem
				BundleTypes = value.BundleTypes, -- table
				AssetTypes = value.AssetTypes, -- table
			})
		end

		TypeCases["Color3"] = function(value)
			return "Color3.new(" .. Args(value.R, value.G, value.B) .. ")"
		end

		TypeCases["ColorSequence"] = function(value)
			return "ColorSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
		end

		TypeCases["ColorSequenceKeypoint"] = function(value)
			return "ColorSequenceKeypoint.new(" .. Args(value.Time, value.Value) .. ")"
		end

		TypeCases["DateTime"] = function(value)
			return "DateTime.fromUnixTimestamp(" .. value.UnixTimestamp .. ")"
		end

		-- Properties seem to throw an error on index if the scope isn't a Studio plugin, so we're
		-- directly getting values! (so fun!!!!)
		TypeCases["DockWidgetPluginGuiInfo"] = function(value)
			-- e.g.: "InitialDockState:Right InitialEnabled:0 InitialEnabledShouldOverrideRestore:0 FloatingXSize:0 FloatingYSize:0 MinWidth:0 MinHeight:0"
			local ValueString = tostring(value)

			return "DockWidgetPluginGuiInfo.new("
				.. Args(
					-- InitialDockState (Enum.InitialDockState)
					Enum.InitialDockState[string_match(ValueString, "InitialDockState:(%w+)")], -- Enum.InitialDockState.Right
					-- InitialEnabled and InitialEnabledShouldOverrideRestore (boolean as number; `0` or `1`)
					string_match(ValueString, "InitialEnabled:(%w+)") == "1", -- false
					string_match(ValueString, "InitialEnabledShouldOverrideRestore:(%w+)") == "1", -- false
					-- FloatingXSize/FloatingYSize (numbers)
					tonumber(string_match(ValueString, "FloatingXSize:(%w+)")), -- 0
					tonumber(string_match(ValueString, "FloatingYSize:(%w+)")), -- 0
					-- MinWidth/MinHeight (numbers)
					tonumber(string_match(ValueString, "MinWidth:(%w+)")), -- 0
					tonumber(string_match(ValueString, "MinHeight:(%w+)")) -- 0
				)
				.. ")"
		end

		-- e.g. `Enum.UserInputType`
		TypeCases["Enum"] = function(value)
			local ValueString = tostring(value)

			if string_match(ValueString, DirectIndexPat) then
				return "Enum." .. ValueString
			end
			return "Enum[" .. SerializeString(ValueString) .. "]"
		end

		-- e.g. `Enum.UserInputType.Gyro`
		TypeCases["EnumItem"] = function(value)
			local EnumTypeStr = TypeCase("Enum", value.EnumType)
			local EnumName = value.Name

			if string_match(EnumName, DirectIndexPat) then
				return EnumTypeStr .. "." .. value.Name
			end
			return EnumTypeStr .. "[" .. SerializeString(EnumName) .. "]"
		end

		-- i.e. the `Enum` global return
		TypeCases["Enums"] = function(value)
			return "Enum"
		end

		TypeCases["Faces"] = function(value)
			local EncodedArgs = {}
			local EnumValues = {
				["Enum.NormalId.Top"] = value.Top, -- These return bools
				["Enum.NormalId.Bottom"] = value.Bottom,
				["Enum.NormalId.Left"] = value.Left,
				["Enum.NormalId.Right"] = value.Right,
				["Enum.NormalId.Back"] = value.Back,
				["Enum.NormalId.Front"] = value.Front,
			}

			for EnumValue, IsEnabled in next, EnumValues do
				if IsEnabled then
					EncodedArgs[#EncodedArgs + 1] = EnumValue
				end
			end

			return "Faces.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
		end

		TypeCases["FloatCurveKey"] = function(value)
			return "FloatCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
		end

		TypeCases["Font"] = function(value)
			return "Font.new(" .. Args(value.Family, value.Weight, value.Style) .. ")"
		end

		-- Instance refs can be evaluated to their paths (optional), but if parented to
		-- nil or some DataModel not under `game`, it'll just return nil
		TypeCases["Instance"] = function(value)
			if UseInstancePaths then
				local InstancePath = EvaluateInstancePath(value, UseFindFirstChild)
				if InstancePath then
					return InstancePath
				end
			end

			return "nil"
				.. BlankSeperator
				.. CommentBlock(
					"Instance.new("
						.. TypeCase("string", value.ClassName)
						.. ")"
						.. BlankSeperator
						.. "{"
						.. "Name:"
						.. BlankSeperator
						.. SerializeString(value.Name)
						.. "}"
				)
		end

		TypeCases["NumberRange"] = function(value)
			return "NumberRange.new(" .. Args(value.Min, value.Max) .. ")"
		end

		TypeCases["NumberSequence"] = function(value)
			return "NumberSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
		end

		TypeCases["NumberSequenceKeypoint"] = function(value)
			return "NumberSequenceKeypoint.new(" .. Args(value.Time, value.Value, value.Envelope) .. ")"
		end

		TypeCases["OverlapParams"] = function(value)
			return Params("OverlapParams.new()", {
				FilterDescendantsInstances = value.FilterDescendantsInstances,
				FilterType = value.FilterType,
				MaxParts = value.MaxParts,
				CollisionGroup = value.CollisionGroup,
				RespectCanCollide = value.RespectCanCollide,
			})
		end

		TypeCases["Path2DControlPoint"] = function(value)
			return "Path2DControlPoint.new(" .. Args(value.Position, value.LeftTangent, value.RightTangent) .. ")"
		end

		TypeCases["PathWaypoint"] = function(value)
			return "PathWaypoint.new(" .. Args(value.Position, value.Action, value.Label) .. ")"
		end

		TypeCases["PhysicalProperties"] = function(value)
			return "PhysicalProperties.new("
				.. Args(value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight)
				.. ")"
		end

		TypeCases["Random"] = function()
			return "Random.new()"
		end

		TypeCases["Ray"] = function(value)
			return "Ray.new(" .. Args(value.Origin, value.Direction) .. ")"
		end

		TypeCases["RaycastParams"] = function(value)
			return Params("RaycastParams.new()", {
				FilterDescendantsInstances = value.FilterDescendantsInstances,
				FilterType = value.FilterType,
				IgnoreWater = value.IgnoreWater,
				CollisionGroup = value.CollisionGroup,
				RespectCanCollide = value.RespectCanCollide,
			})
		end

		TypeCases["Rect"] = function(value)
			return "Rect.new(" .. Args(value.Min, value.Max) .. ")"
		end

		-- Roblox doesn't provide direct read properties for min/max on `Region3`, but they do on Region3int16..
		TypeCases["Region3"] = function(value)
			local ValuePos = value.CFrame.Position
			local ValueSize = 0.5 * value.Size

			return "Region3.new("
				.. Args(
					ValuePos - ValueSize, -- Minimum
					ValuePos + ValueSize -- Maximum
				)
				.. ")"
		end

		TypeCases["Region3int16"] = function(value)
			return "Region3int16.new(" .. Args(value.Min, value.Max) .. ")"
		end

		TypeCases["TweenInfo"] = function(value)
			return "TweenInfo.new("
				.. Args(
					value.Time,
					value.EasingStyle,
					value.EasingDirection,
					value.RepeatCount,
					value.Reverses,
					value.DelayTime
				)
				.. ")"
		end

		TypeCases["RotationCurveKey"] = function(value)
			return "RotationCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
		end

		TypeCases["UDim"] = function(value)
			return "UDim.new(" .. Args(value.Scale, value.Offset) .. ")"
		end

		TypeCases["UDim2"] = function(value)
			return "UDim2.new(" .. Args(value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset) .. ")"
		end

		TypeCases["Vector2"] = function(value)
			return "Vector2.new(" .. Args(value.X, value.Y) .. ")"
		end

		TypeCases["Vector2int16"] = function(value)
			return "Vector2int16.new(" .. Args(value.X, value.Y) .. ")"
		end

		TypeCases["Vector3"] = function(value)
			return "Vector3.new(" .. Args(value.X, value.Y, value.Z) .. ")"
		end

		TypeCases["Vector3int16"] = function(value)
			return "Vector3int16.new(" .. Args(value.X, value.Y, value.Z) .. ")"
		end

		TypeCases["buffer"] = function(value)
			return "buffer.fromstring(" .. SerializeString(buffer.tostring(value)) .. ")"
		end

		TypeCases["SharedTable"] = function(value, isKey)
			local StClone = {}
			-- Will still compile in vanilla Lua if we do it this way. We should probably create a deep clone
			-- of the current state of the table regardless
			for Key, Value in SharedTable.clone(value, not SharedTableLarpAsRegTable) do
				StClone[Key] = Value
			end

			local StCloneStr = TypeCases["table"](StClone, isKey, true) -- 3rd arg is stLarpAsRegTable
			if SharedTableLarpAsRegTable then
				return StCloneStr
			end
			return table_concat({ "SharedTable.new(", StCloneStr, ")" })
		end

		TypeCases["userdata"] = function(value)
			if getmetatable(value) ~= nil then -- Has mt
				return "newproxy(true)"
			else
				return "newproxy()" -- newproxy() defaults to false (no mt)
			end
		end
	end

	-- Setup for final output, which will be concat together
	local Output = {}

	local TablePointer = inputTable
	local NextKey = nil -- Used with TableStack so the TablePointer loop knows where to continue from upon stack pop
	local IsNewTable = true -- Used with table stack push/pop to identify when an opening curly brace should be added

	-- Stack array for table depth
	local TableStack = {} -- [Depth: number] = {TablePointer: table, NextKey: any, KeyNumIndex: number}
	local RefMaps = { [TablePointer] = "" } -- [Ref: table] = ".example["ref path"]'
	local CycleMaps = {} -- ['.example["ref path"]'] = '.another["ref path"]'

	while TablePointer do
		-- Update StackLevel for formatting
		StackLevel = StackLevelOpt + #TableStack
		IndentString = (Prettify and string_rep(IndentStringBase, StackLevel)) or IndentStringBase
		EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

		-- Only append an opening brace to the table if this isn't just a continution up the stack
		if IsNewTable then
			Output[#Output + 1] = "{"
		elseif next(TablePointer, NextKey) == nil then -- Formatting for the next entry still needs to be added like any other value
			Output[#Output + 1] = NewEntryString .. EndingIndentString
		else
			Output[#Output + 1] = ","
		end

		VisitedTables[TablePointer] = true

		-- Just because of control flow restrictions with Lua compatibility
		local SkipStackPop = false

		for Key, Value in next, TablePointer, NextKey do
			local KeyType, ValueType = Type(Key), Type(Value)
			local ValueIsTable = ValueType == "table"
			local KeyTypeCase, ValueTypeCase = TypeCases[KeyType], TypeCases[ValueType]

			Output[#Output + 1] = NewEntryString .. IndentString

			if KeyTypeCase and ValueTypeCase then
				local ValueWasEncoded = false -- Keeping track of this for adding a "," to the output if needed

				-- Evaluate output for key
				local KeyEncodedSuccess, EncodedKeyOrError, DontEncloseKeyInBrackets = pcall(KeyTypeCase, Key, true) -- The `true` represents if it's a key or not, here it is

				-- Evaluate output for value, ignoring 2nd arg (`DontEncloseInBrackets`) because this isn't the key
				local ValueEncodedSuccess, EncodedValueOrError
				if not ValueIsTable then
					ValueEncodedSuccess, EncodedValueOrError = pcall(ValueTypeCase, Value, false)
				end

				-- Ignoring `if EncodedKeyOrError` because the key doesn't actually need to ALWAYS
				-- be explicitly encoded, like if it's a number of the current key index!
				if KeyEncodedSuccess and (ValueIsTable or (ValueEncodedSuccess and EncodedValueOrError)) then
					-- Append explicit key if necessary
					if EncodedKeyOrError then
						if DontEncloseKeyInBrackets then
							Output[#Output + 1] = EncodedKeyOrError
						else
							Output[#Output + 1] = table_concat({ "[", EncodedKeyOrError, "]" })
						end

						Output[#Output + 1] = EqualsSeperator
					end

					-- Of course, recursive tables are handled differently and use the stack system
					if ValueIsTable then
						local IndexPath
						if InsertCycles and KeyIndexTypes[KeyType] and RefMaps[TablePointer] then
							if KeyType == "string" and not LuaKeywords[Key] and string_match(Key, DirectIndexPat) then
								IndexPath = "." .. Key
							else
								local EncodedKeyAsValue = TypeCases[KeyType](Key)
								IndexPath = table_concat({ "[", EncodedKeyAsValue, "]" })
							end
						end

						if not VisitedTables[Value] then
							if IndexPath then
								RefMaps[Value] = RefMaps[TablePointer] .. IndexPath
							end

							TableStack[#TableStack + 1] = { TablePointer, Key, KeyNumIndex }

							TablePointer = Value
							NextKey = nil
							KeyNumIndex = 1

							IsNewTable = true
							SkipStackPop = true
							break
						else
							EncodedValueOrError =
								string_format("{%s}", (OutputWarnings and "--[[LuaEncode: Duplicate reference]]") or "")

							if IndexPath then
								CycleMaps[IndexPath] = RefMaps[Value]
							end
						end
					end

					-- Append value like normal
					Output[#Output + 1] = EncodedValueOrError

					ValueWasEncoded = true
				elseif OutputWarnings then -- Then `Encoded(Key/Value)OrError` is the error msg
					-- ^^ Then either the key or value wasn't properly checked or encoded, and there
					-- was an error we need to log!
					local ErrorMessage = string_format(
						"LuaEncode: Failed to serialize %s of data type %s: %s",
						(not KeyEncodedSuccess and "key") or (not ValueEncodedSuccess and "value") or "key/value",
						ValueType,
						(not KeyEncodedSuccess and SerializeString(EncodedKeyOrError))
							or (not ValueEncodedSuccess and SerializeString(EncodedValueOrError))
							or "(Failed to get error message)"
					)

					Output[#Output + 1] = CommentBlock(ErrorMessage)
				end

				if next(TablePointer, Key) == nil then
					-- If there isn't another value after the current index, add ending formatting
					Output[#Output + 1] = NewEntryString .. EndingIndentString
				elseif ValueWasEncoded then
					Output[#Output + 1] = ","
				end
			else
				-- Data type is unimplemented

				-- Dtc
				local KeyTostring = (KeyType == "userdata" and "userdata") or tostring(Key)
				local ValueTostring = (ValueType == "userdata" and "userdata") or tostring(Value)

				Output[#Output + 1] = CommentBlock(
					BlankSeperator
						.. KeyType
						.. "("
						.. SerializeString(KeyTostring)
						.. ")"
						.. ":"
						.. BlankSeperator
						.. ValueType
						.. "("
						.. SerializeString(ValueTostring)
						.. ")"
						.. BlankSeperator
				)

				if next(TablePointer, Key) == nil then
					Output[#Output + 1] = NewEntryString .. EndingIndentString
				end
			end
		end

		-- Vanilla Lua control flow is fun
		if not SkipStackPop then
			if not Prettify and IndentCount > 0 then
				Output[#Output + 1] = IndentString
			end
			Output[#Output + 1] = "}"

			if #TableStack > 0 then
				local TableUp = TableStack[#TableStack]
				TableStack[#TableStack] = nil -- Pop off the table stack

				TablePointer, NextKey, KeyNumIndex = TableUp[1], TableUp[2], TableUp[3]
				IsNewTable = false
			else
				break
			end
		end
	end

	if InsertCycles then
		local CycleMapsOut = {}
		for CycleIndex, CycleMap in next, CycleMaps do
			CycleMapsOut[#CycleMapsOut + 1] = IndentString
				.. "t"
				.. CycleIndex
				.. EqualsSeperator
				.. "t"
				.. CycleMap
				.. CodegenNewline
		end

		if #CycleMapsOut > 0 then
			return table_concat({
				"(function(t)",
				NewEntryString,
				table_concat(CycleMapsOut),
				NewEntryString,
				IndentString,
				"return t",
				CodegenNewline,
				"end)(",
				table_concat(Output),
				")",
			})
		end
	end

	return table_concat(Output)
end

return LuaEncode
