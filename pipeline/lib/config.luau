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
	version: string?,
	verbose: boolean?,
	ciMode: boolean?,
	output: OutputConfig?,
	builds: { [string]: BuildConfig },
}

-- Module
local Config = {}

--[=[
	Loads a configuration file from the specified path.

	Supports JSON and JSON5 formats. Returns nil and error message on failure.

	@param path The configuration file path
	@return Configuration object, or nil and error message
]=]
function Config.load(path: string): (ConfigFile?, string?)
	if not fs.isFile(path) then
		return nil, `Configuration file not found: {path}`
	end

	local success: boolean, contents: string = pcall(fs.readFile, path)
	if not success then
		return nil, `Failed to read configuration file: {contents}`
	end

	local parseSuccess: boolean, parsed: any = pcall(serde.decode, "json", contents)
	if not parseSuccess then
		return nil, `Failed to parse configuration file: {parsed}`
	end

	local config: ConfigFile = parsed :: ConfigFile

	-- Validate basic structure
	local valid: boolean, err: string? = Config.validate(config)
	if not valid then
		return nil, err
	end

	-- Apply inheritance (extends)
	local resolvedConfig: ConfigFile = Config.resolveInheritance(config)

	return resolvedConfig, nil
end

--[=[
	Validates a configuration object against the expected schema.

	@param config The configuration object to validate
	@return True if valid, or false and error message
]=]
function Config.validate(config: any): (boolean, string?)
	if type(config) ~= "table" then
		return false, "Configuration must be a table"
	end

	if not config.builds or type(config.builds) ~= "table" then
		return false, "Configuration must have a 'builds' table"
	end

	local buildCount: number = 0
	for name: string, buildCfg: any in config.builds do
		buildCount += 1

		if type(buildCfg) ~= "table" then
			return false, `Build config '{name}' must be a table`
		end

		if not buildCfg.input or type(buildCfg.input) ~= "string" then
			return false, `Build config '{name}' must have a string 'input' field`
		end

		if not buildCfg.output or type(buildCfg.output) ~= "string" then
			return false, `Build config '{name}' must have a string 'output' field`
		end
	end

	if buildCount == 0 then
		return false, "Configuration must have at least one build configuration"
	end

	return true, nil
end

--[=[
	Resolves configuration inheritance (extends pattern).

	Builds can extend other builds by specifying an 'extends' field.

	@param config The configuration with potential inheritance
	@return Configuration with inheritance resolved
]=]
function Config.resolveInheritance(config: ConfigFile): ConfigFile
	local resolved: ConfigFile = table.clone(config)
	resolved.builds = {}

	local function mergeBuilds(base: BuildConfig, override: BuildConfig): BuildConfig
		local merged: BuildConfig = table.clone(base) :: any

		for key: string, value: any in override :: any do
			if key ~= "extends" then
				merged[key] = value
			end
		end

		return merged
	end

	for name: string, buildCfg: BuildConfig in config.builds do
		if buildCfg.extends then
			local baseName: string = buildCfg.extends
			local baseConfig: BuildConfig? = config.builds[baseName]

			if not baseConfig then
				error(`Build config '{name}' extends unknown config '{baseName}'`)
			end

			resolved.builds[name] = mergeBuilds(baseConfig, buildCfg)
		else
			resolved.builds[name] = table.clone(buildCfg)
		end

		-- Ensure name is set
		resolved.builds[name].name = name
	end

	return resolved
end

--[=[
	Selects a build configuration interactively or by name.

	@param config The configuration file
	@param buildName Optional build name (skips prompt if provided)
	@param ciMode Whether in CI mode (no prompts)
	@return Selected build configuration, or nil if cancelled/not found
]=]
function Config.selectBuildConfig(config: ConfigFile, buildName: string?, ciMode: boolean?): BuildConfig?
	local isCiMode: boolean = ciMode or config.ciMode or false

	-- If build name provided, find it directly
	if buildName then
		local buildCfg: BuildConfig? = config.builds[buildName]
		if not buildCfg then
			return nil
		end
		return buildCfg
	end

	-- In CI mode without build name, error
	if isCiMode then
		return nil
	end

	-- Interactive selection
	local buildNames: { string } = {}
	local buildDescriptions: { string } = {}

	for name: string, buildCfg: BuildConfig in config.builds do
		table.insert(buildNames, name)
		if buildCfg.description then
			table.insert(buildDescriptions, `{name} - {buildCfg.description}`)
		else
			table.insert(buildDescriptions, name)
		end
	end

	local selectedIndex: number = stdio.prompt("select", "Select build configuration:", buildDescriptions)
	local selectedName: string = buildNames[selectedIndex]

	return config.builds[selectedName]
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
