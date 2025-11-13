--!strict

--[=[
	@class NotScriptable

	Analyzes NotScriptable properties with serialization support.

	Detects three categories:
	- NotScriptable properties that are serializable
	- Properties with serialization-related names (xml, internal, serial, replica)
	- Proxy properties (scriptable enum properties matching NotScriptable enum types)

	Output: Array with type="notScriptable", type="serializationNamed", or type="proxy".
]=]

-- Imports
local Process = require("@lune/process")
local lib = require("../lib")

-- Type Definitions

--[=[
	@class NotScriptableProperty
	NotScriptable property that can be serialized.
]=]
type NotScriptableProperty = {
	type: "notScriptable",
	class: string,
	property: string,
	valueType: string,
	descriptor: string?,
}

--[=[
	@class SerializationProperty
	Property with serialization-related naming.
]=]
type SerializationProperty = {
	type: "serializationNamed",
	class: string,
	property: string,
	scriptable: boolean,
	serializable: boolean,
}

--[=[
	@class ProxyProperty
	Detected proxy property for NotScriptable enum.
]=]
type ProxyProperty = {
	type: "proxy",
	class: string,
	real: string,
	proxy: string,
	enumType: string,
}

-- Type union for combined output
type Property = NotScriptableProperty | SerializationProperty | ProxyProperty

-- Module State

-- Property name patterns that suggest serialization-related purposes
local SERIALIZATION_PATTERNS = {
	"xml",
	"internal",
	"serial",
	"replica",
}

-- Module Table
local NotScriptable = {}

-- Private Helpers

--[=[
	@private
	Checks if property name suggests serialization purpose.

	@param name -- Property name
	@return boolean -- True if serialization-related
]=]
local function isSerializationNamed(name: string): boolean
	local lower = string.lower(name)
	for _, pattern in SERIALIZATION_PATTERNS do
		if string.find(lower, pattern) then
			return true
		end
	end
	return false
end

--[=[
	@private
	Processes NotScriptable serializable property.

	@param className -- Class name
	@param member -- Member to process
	@param tags -- Normalized tags
	@param props -- Properties list
	@param enums -- Enum tracker (enumType -> propertyName)
]=]
local function processNotScriptableProperty(
	className: string,
	member: lib.Member,
	tags: { [string]: any },
	props: { NotScriptableProperty },
	enums: { [string]: string }
)
	local valueType: lib.ValueType

	valueType = member.ValueType
	if not valueType then
		return
	end

	-- Track enum types for proxy detection
	if valueType.Category == "Enum" then
		enums[valueType.Name] = member.Name
	end

	table.insert(props, {
		type = "notScriptable",
		class = className,
		property = member.Name,
		valueType = valueType.Name,
		descriptor = tags.PreferredDescriptorName,
	})
end

--[=[
	@private
	Processes serialization-named property.

	@param className -- Class name
	@param member -- Member to process
	@param tags -- Normalized tags
	@param serialization -- Serialization info
	@param serProps -- Serialization properties list
]=]
local function processSerializationProperty(
	className: string,
	member: lib.Member,
	tags: { [string]: any },
	serialization: lib.Serialization,
	serProps: { SerializationProperty }
)
	table.insert(serProps, {
		type = "serializationNamed",
		class = className,
		property = member.Name,
		scriptable = not tags.NotScriptable,
		serializable = serialization.CanLoad and serialization.CanSave,
	})
end

--[=[
	@private
	Detects proxy properties for NotScriptable enums.

	Only flags properties that are scriptable AND serializable to avoid
	false positives from other NotScriptable or non-serializable properties.

	@param class -- Class to check
	@param enums -- Enum tracker (enumType -> realPropertyName)
	@param proxies -- Proxies list
]=]
local function detectProxies(class: lib.Class, enums: { [string]: string }, proxies: { ProxyProperty })
	for enumType, realName in enums do
		for _, member in class.Members do
			if member.MemberType ~= "Property" or not member.ValueType or not member.Serialization then
				continue
			end

			-- Skip the real property itself
			if member.Name == realName then
				continue
			end

			local valueType = member.ValueType
			if valueType.Category == "Enum" and valueType.Name == enumType then
				local tags = lib.tags(member.Tags)
				local ser = member.Serialization

				-- Only flag scriptable, serializable properties as proxies
				if not tags.NotScriptable and ser.CanLoad and ser.CanSave then
					table.insert(proxies, {
						type = "proxy",
						class = class.Name,
						real = realName,
						proxy = member.Name,
						enumType = enumType,
					})
				end
			end
		end
	end
end

--[=[
	@private
	Processes a single class for all property types.

	@param class -- Class to process
	@param props -- NotScriptable properties list
	@param serProps -- Serialization-named properties list
	@param proxies -- Proxy properties list
]=]
local function processClass(
	class: lib.Class,
	props: { NotScriptableProperty },
	serProps: { SerializationProperty },
	proxies: { ProxyProperty }
)
	-- Track enum types from NotScriptable properties for proxy detection
	local enums: { [string]: string } = {}

	for _, member in class.Members do
		if member.MemberType ~= "Property" or not member.ValueType or not member.Serialization then
			continue
		end

		local ok, tags = pcall(lib.tags, member.Tags)
		if not ok then
			lib.warn(`Error processing {class.Name}.{member.Name}: {tags}`)
			continue
		end

		local ser = member.Serialization

		-- Check NotScriptable + serializable
		if tags.NotScriptable and ser.CanLoad and ser.CanSave then
			processNotScriptableProperty(class.Name, member, tags, props, enums)
		end

		-- Check serialization-related naming
		if isSerializationNamed(member.Name) then
			processSerializationProperty(class.Name, member, tags, ser, serProps)
		end
	end

	-- Detect proxy properties after collecting enum types
	detectProxies(class, enums, proxies)
end

--[=[
	@private
	Collects NotScriptable properties from API dump.

	@param api -- API dump
	@return { NotScriptableProperty } -- NotScriptable properties
	@return { SerializationProperty } -- Serialization-named properties
	@return { ProxyProperty } -- Proxy properties
]=]
local function collectProperties(
	api: lib.ApiDump
): ({ NotScriptableProperty }, { SerializationProperty }, { ProxyProperty })
	local props: { NotScriptableProperty } = {}
	local serProps: { SerializationProperty } = {}
	local proxies: { ProxyProperty } = {}

	for _, class in api.Classes do
		local ok, err = pcall(processClass, class, props, serProps, proxies)
		if not ok then
			lib.warn(`Error processing {class.Name}: {err}`)
		end
	end

	return props, serProps, proxies
end

--[=[
	@private
	Combines and sorts properties into unified output.

	@param props -- NotScriptable properties
	@param serProps -- Serialization-named properties
	@param proxies -- Proxy properties
	@return { Property } -- Combined sorted properties
]=]
local function buildOutput(
	props: { NotScriptableProperty },
	serProps: { SerializationProperty },
	proxies: { ProxyProperty }
): { Property }
	local combined: { Property } = {}

	for _, prop in props do
		table.insert(combined, prop)
	end

	for _, prop in serProps do
		table.insert(combined, prop)
	end

	for _, proxy in proxies do
		table.insert(combined, proxy)
	end

	-- Sort for deterministic output
	table.sort(combined, function(a, b)
		if a.class == b.class then
			local aKey = a.property or a.real or ""
			local bKey = b.property or b.real or ""
			return aKey < bKey
		end
		return a.class < b.class
	end)

	return combined
end

-- Public API

--[=[
	Runs NotScriptable analysis on API dump.

	@param hash -- Optional version hash
	@error Throws if analysis fails
]=]
function NotScriptable.run(hash: string?)
	local api = lib.fetch(hash)
	local props, serProps, proxies = collectProperties(api)
	local combined = buildOutput(props, serProps, proxies)

	lib.json("not-scriptable", lib.output(hash, combined, {
		notScriptable = #props,
		serializationNamed = #serProps,
		proxy = #proxies,
	}))

	lib.success(#combined, "items", `{#props} NotScriptable, {#proxies} proxies, {#serProps} serialization-named`)
end

-- Entry Point
lib.runCli(NotScriptable.run, Process.args)
