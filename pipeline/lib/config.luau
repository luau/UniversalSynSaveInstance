--!strict
--[=[
	@class Config
	Configuration loader and validator for the build pipeline.

	Loads and validates `.pcmp.json` configuration files, providing type-safe
	access to build configurations with schema validation and error reporting.

	@usage
	```lua
	local Config = require("./lib/config")
	local config, err = Config.load("pipeline/.pcmp.json")
	if not config then
		error(err)
	end
	```
]=]

-- Imports
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

-- Types
export type DarkluaStage = {
	name: string,
	config: string,
	env: { [string]: string }?,
	optional: boolean?,
}

export type DarkluaConfig = {
	enabled: boolean?,
	stages: { DarkluaStage }?,
}

export type WaxConfig = {
	enabled: boolean?,
	input: string,
	output: string,
	minify: boolean?,
	envName: string?,
	darklua: { config: string? }?,
}

export type TemplateConfig = {
	enabled: boolean?,
	source: string,
	markers: { [string]: string }?,
}

export type PromptsConfig = {
	version: boolean?,
	deploy: boolean?,
}

export type GitHubConfig = {
	enabled: boolean?,
	owner: string,
	repo: string,
	apiKeyEnv: string?,
}

export type DeploymentConfig = {
	enabled: boolean?,
	prerelease: boolean?,
	github: GitHubConfig?,
}

export type StyluaConfig = {
	enabled: boolean?,
	configPath: string?,
}

export type BuildConfig = {
	name: string,
	description: string?,
	type: "standard" | "wax"?,
	extends: string?,
	input: string,
	output: string,
	darklua: DarkluaConfig?,
	wax: WaxConfig?,
	template: TemplateConfig?,
	prompts: PromptsConfig?,
	deployment: DeploymentConfig?,
	stylua: StyluaConfig?,
}

export type OutputConfig = {
	directory: string?,
	openInEditor: boolean?,
	editor: string?,
}

export type ConfigFile = {
	verbose: boolean?,
	ciMode: boolean?,
	output: OutputConfig?,
	builds: { [string]: BuildConfig },
}

-- Module
local Config = {}

--[=[
	Merges a base build config with an override config.

	All fields from override replace base fields except 'extends' which is removed.

	@param base Base configuration to extend
	@param override Override configuration with new values
	@return Merged configuration
]=]
local function mergeBuilds(base: BuildConfig, override: BuildConfig): BuildConfig
	local merged: BuildConfig = table.clone(base) :: any

	for key: string, value: any in override :: any do
		if key ~= "extends" then
			merged[key] = value
		end
	end

	return merged
end

--[=[
	Loads a configuration file from the specified path.

	Reads, parses, validates, and resolves inheritance for build configurations.
	Supports JSON format with inheritance via extends pattern.

	@param path Path to .pcmp.json configuration file
	@return Resolved configuration, or nil and error message on failure
]=]
function Config.load(path: string): (ConfigFile?, string?)
	if not fs.isFile(path) then
		return nil, `Config not found: {path}`
	end

	local success: boolean, contents: string = pcall(fs.readFile, path)
	if not success then
		return nil, `Read failed: {contents}`
	end

	local parseSuccess: boolean, parsed: any = pcall(serde.decode, "json", contents)
	if not parseSuccess then
		return nil, `Parse failed: {parsed}`
	end

	local config: ConfigFile = parsed :: ConfigFile

	local valid: boolean, err: string? = Config.validate(config)
	if not valid then
		return nil, err
	end

	local resolvedConfig: ConfigFile = Config.resolveInheritance(config)
	return resolvedConfig, nil
end

--[=[
	Validates a configuration object against the expected schema.

	Checks that config is a table with a builds dictionary containing at least
	one valid build entry with required input and output fields.

	@param config Configuration object to validate
	@return True if valid, false and error message otherwise
]=]
function Config.validate(config: any): (boolean, string?)
	if type(config) ~= "table" then
		return false, "Config must be a table"
	end

	if not config.builds or type(config.builds) ~= "table" then
		return false, "Config must have 'builds' table"
	end

	local buildCount: number = 0
	for name: string, buildCfg: any in config.builds do
		buildCount += 1

		if type(buildCfg) ~= "table" then
			return false, `Build '{name}' must be a table`
		end

		if not buildCfg.input or type(buildCfg.input) ~= "string" then
			return false, `Build '{name}' missing 'input' string`
		end

		if not buildCfg.output or type(buildCfg.output) ~= "string" then
			return false, `Build '{name}' missing 'output' string`
		end
	end

	if buildCount == 0 then
		return false, "Config must have at least one build"
	end

	return true, nil
end

--[=[
	Resolves configuration inheritance (extends pattern).

	Builds can extend other builds by specifying an 'extends' field pointing
	to another build name. The base build's fields are merged with overrides.

	@param config Configuration with potential extends references
	@return Configuration with all inheritance resolved
	@error Throws if a build extends a non-existent base config
]=]
function Config.resolveInheritance(config: ConfigFile): ConfigFile
	local resolved: ConfigFile = table.clone(config)
	resolved.builds = {}

	for name: string, buildCfg: BuildConfig in config.builds do
		if buildCfg.extends then
			local baseName: string = buildCfg.extends
			local baseConfig: BuildConfig? = config.builds[baseName]

			if not baseConfig then
				error(`Build '{name}' extends unknown config '{baseName}'`)
			end

			resolved.builds[name] = mergeBuilds(baseConfig, buildCfg)
		else
			resolved.builds[name] = table.clone(buildCfg)
		end

		resolved.builds[name].name = name
	end

	return resolved
end

--[=[
	Selects a build configuration interactively or by name.

	If buildName is provided, returns that config. Otherwise prompts user
	interactively unless in CI mode.

	@param config Configuration file with builds
	@param buildName Optional build name to select directly
	@param ciMode Whether in CI mode (prevents prompts)
	@return Selected build, or nil if not found or cancelled
]=]
function Config.selectBuildConfig(config: ConfigFile, buildName: string?, ciMode: boolean?): BuildConfig?
	local isCiMode: boolean = ciMode or config.ciMode or false

	if buildName then
		return config.builds[buildName]
	end

	if isCiMode then
		return nil
	end

	local buildNames: { string } = {}
	local buildDescriptions: { string } = {}

	for name: string, buildCfg: BuildConfig in config.builds do
		table.insert(buildNames, name)
		local description: string = if buildCfg.description then `{name} - {buildCfg.description}` else name
		table.insert(buildDescriptions, description)
	end

	local selectedIndex: number = stdio.prompt("select", "Select build:", buildDescriptions)
	return config.builds[buildNames[selectedIndex]]
end

--[=[
	Gets the build type for a configuration.

	@param buildCfg The build configuration
	@return Build type: "standard" or "wax"
]=]
function Config.getBuildType(buildCfg: BuildConfig): "standard" | "wax"
	if buildCfg.type then
		return buildCfg.type
	end

	-- Auto-detect based on wax configuration
	if buildCfg.wax and buildCfg.wax.enabled then
		return "wax"
	end

	return "standard"
end

--[=[
	Checks if darklua processing is enabled for a build.

	@param buildCfg The build configuration
	@return True if darklua should run
]=]
function Config.isDarkluaEnabled(buildCfg: BuildConfig): boolean
	if not buildCfg.darklua then
		return false
	end

	if buildCfg.darklua.enabled == false then
		return false
	end

	return true
end

--[=[
	Checks if wax bundling is enabled for a build.

	@param buildCfg The build configuration
	@return True if wax should run
]=]
function Config.isWaxEnabled(buildCfg: BuildConfig): boolean
	if Config.getBuildType(buildCfg) ~= "wax" then
		return false
	end

	if not buildCfg.wax then
		return false
	end

	if buildCfg.wax.enabled == false then
		return false
	end

	return true
end

--[=[
	Checks if template composition is enabled for a build.

	@param buildCfg The build configuration
	@return True if template composition should run
]=]
function Config.isTemplateEnabled(buildCfg: BuildConfig): boolean
	if not buildCfg.template then
		return false
	end

	if buildCfg.template.enabled == false then
		return false
	end

	return true
end

--[=[
	Checks if deployment is enabled for a build.

	@param buildCfg The build configuration
	@return True if deployment should run
]=]
function Config.isDeploymentEnabled(buildCfg: BuildConfig): boolean
	if not buildCfg.deployment then
		return false
	end

	if buildCfg.deployment.enabled == false then
		return false
	end

	return true
end

--[=[
	Checks if stylua formatting is enabled for a build.

	@param buildCfg The build configuration
	@return True if stylua should run
]=]
function Config.isStyluaEnabled(buildCfg: BuildConfig): boolean
	if not buildCfg.stylua then
		return false
	end

	if buildCfg.stylua.enabled == false then
		return false
	end

	return true
end

return Config
