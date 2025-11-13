--!strict
--[=[
	@class Pipeline
	Main CLI entry point for the UniversalSynSaveInstance build pipeline.

	Orchestrates multi-stage builds using darklua and wax, with optional
	template composition, stylua formatting, and GitHub deployment.

	@usage
	```bash
	lune run pipeline/init.luau [build-config-name] [--ci] [--verbose]
	```
]=]

-- Imports
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local stdio = require("@lune/stdio")
local Logger = require("./lib/logger")
local Config = require("./lib/config")
local FsUtils = require("./lib/fs-utils")
local Darklua = require("./stages/darklua")
local Wax = require("./stages/wax")
local Composer = require("./stages/composer")
local Deployment = require("./stages/deployment")
local Stylua = require("./stages/stylua")

-- Constants
local EXIT_SUCCESS: number = 0
local EXIT_FAILURE: number = 1
local DEFAULT_CONFIG_PATH: string = "pipeline/.pcmp.json"
local PIPELINE_VERSION: string = "2.0.0"

-- Types
type BuildContext = {
	config: Config.BuildConfig,
	version: string,
	ciMode: boolean,
	verbose: boolean,
	startTime: number,
}

--[=[
	Parses command-line arguments.

	@param args Command-line arguments
	@return Parsed arguments with build name, flags, and config path
]=]
local function parseArgs(args: { string }): {
	buildName: string?,
	ciMode: boolean,
	verbose: boolean,
	configPath: string,
}
	local buildName: string? = nil
	local ciMode: boolean = false
	local verbose: boolean = false
	local configPath: string = DEFAULT_CONFIG_PATH

	for _, arg: string in args do
		if arg == "--ci" then
			ciMode = true
		elseif arg == "--verbose" or arg == "-v" then
			verbose = true
		elseif arg:match("^%-%-config=(.+)$") then
			configPath = arg:match("^%-%-config=(.+)$") :: string
		elseif not arg:match("^%-%-") and not buildName then
			buildName = arg
		end
	end

	return {
		buildName = buildName,
		ciMode = ciMode,
		verbose = verbose,
		configPath = configPath,
	}
end

--[=[
	Prompts for build version if required by configuration.

	@param buildConfig Build configuration
	@param ciMode Whether in CI mode
	@return Version string
]=]
local function promptVersion(buildConfig: Config.BuildConfig, ciMode: boolean): string
	if ciMode or not buildConfig.prompts or not buildConfig.prompts.version then
		return "v0.0.0-dev"
	end

	return stdio.prompt("text", "Build version (vMAJOR.MINOR.PATCH):", "v0.0.0")
end

--[=[
	Executes darklua processing stage.

	@param ctx Build context
	@return Success boolean
]=]
local function executeDarkluaStage(ctx: BuildContext): boolean
	if not Config.isDarkluaEnabled(ctx.config) then
		Logger.verbose("Darklua processing disabled, skipping")
		return true
	end

	Logger.info("Stage: Darklua Processing")

	local result: Darklua.ProcessResult = Darklua.process(
		ctx.config.input,
		ctx.config.output,
		ctx.config.darklua :: Config.DarkluaConfig
	)

	if not result.success then
		Logger.error(`Darklua processing failed: {result.error}`)
		return false
	end

	Logger.success(`Darklua processing completed ({Logger.formatDuration(result.duration)})`)
	if result.stagesCompleted > 0 then
		Logger.detail(`Completed {result.stagesCompleted} stage(s)`)
	end

	return true
end

--[=[
	Executes wax bundling stage.

	@param ctx Build context
	@return Success boolean
]=]
local function executeWaxStage(ctx: BuildContext): boolean
	if not Config.isWaxEnabled(ctx.config) then
		return true
	end

	Logger.info("Stage: Wax Bundling")

	local waxConfig: Config.WaxConfig = ctx.config.wax :: Config.WaxConfig

	local result: Wax.BundleResult = Wax.bundle(ctx.config.input, ctx.config.output, waxConfig)

	if not result.success then
		Logger.error(`Wax bundling failed: {result.error}`)
		return false
	end

	Logger.success(`Wax bundling completed ({Logger.formatDuration(result.duration)})`)

	return true
end

--[=[
	Executes template composition stage.

	@param ctx Build context
	@return Success boolean
]=]
local function executeComposer(ctx: BuildContext): boolean
	if not Config.isTemplateEnabled(ctx.config) then
		return true
	end

	Logger.info("Stage: Template Composition")

	local templateConfig: Config.TemplateConfig = ctx.config.template :: Config.TemplateConfig

	local result: Composer.ComposeStageResult =
		Composer.compose(ctx.config.output, templateConfig, ctx.version, ctx.config.name)

	if not result.success then
		Logger.error(`Template composition failed: {result.error}`)
		return false
	end

	Logger.success(`Template composition completed ({Logger.formatDuration(result.duration)})`)
	Logger.detail(`Applied {result.replacements} marker(s)`)

	return true
end

--[=[
	Executes stylua formatting stage.

	@param ctx Build context
	@return Success boolean
]=]
local function executeStyluaStage(ctx: BuildContext): boolean
	if not Config.isStyluaEnabled(ctx.config) then
		return true
	end

	Logger.info("Stage: Stylua Formatting")

	local result: Stylua.FormatResult = Stylua.format(ctx.config.output, ctx.config.stylua)

	if not result.success then
		Logger.error(`Stylua formatting failed: {result.error}`)
		return false
	end

	Logger.success(`Stylua formatting completed ({Logger.formatDuration(result.duration)})`)

	return true
end

--[=[
	Executes deployment stage.

	@param ctx Build context
	@return Success boolean
]=]
local function executeDeployment(ctx: BuildContext): boolean
	if not Config.isDeploymentEnabled(ctx.config) then
		return true
	end

	-- Prompt for deployment confirmation
	if not ctx.ciMode and ctx.config.prompts and ctx.config.prompts.deploy then
		local confirmed: boolean = stdio.prompt("confirm", "Deploy this build to GitHub?")
		if not confirmed then
			Logger.warn("Deployment skipped by user")
			return true
		end
	end

	Logger.info("Stage: GitHub Deployment")

	local deployConfig: Config.DeploymentConfig = ctx.config.deployment :: Config.DeploymentConfig

	local result: Deployment.DeployResult =
		Deployment.deploy(deployConfig, ctx.version, ctx.config.name, ctx.config.output, ctx.ciMode)

	if not result.success then
		Logger.error(`Deployment failed: {result.error}`)
		return false
	end

	Logger.success(`Deployment completed ({Logger.formatDuration(result.duration)})`)
	if result.releaseUrl then
		Logger.detail(`Release URL: {result.releaseUrl}`)
	end

	return true
end

--[=[
	Validates build environment and tool availability.

	@param buildConfig Build configuration
	@return Success boolean
]=]
local function validateEnvironment(buildConfig: Config.BuildConfig): boolean
	local hasErrors: boolean = false

	-- Check darklua
	if Config.isDarkluaEnabled(buildConfig) then
		if not Darklua.isAvailable() then
			Logger.error("darklua is not available (required for this build)")
			hasErrors = true
		else
			local version: string? = Darklua.getVersion()
			Logger.verbose(`darklua version: {version or "unknown"}`)
		end
	end

	-- Check wax
	if Config.isWaxEnabled(buildConfig) then
		if not Wax.isAvailable() then
			Logger.error("wax is not available (required for this build)")
			hasErrors = true
		else
			local version: string? = Wax.getVersion()
			Logger.verbose(`wax version: {version or "unknown"}`)
		end
	end

	-- Check stylua
	if Config.isStyluaEnabled(buildConfig) then
		if not Stylua.isAvailable() then
			Logger.warn("stylua is not available (formatting will be skipped)")
			-- Not a fatal error
		else
			local version: string? = Stylua.getVersion()
			Logger.verbose(`stylua version: {version or "unknown"}`)
		end
	end

	-- Check template
	if Config.isTemplateEnabled(buildConfig) then
		local templateConfig: Config.TemplateConfig = buildConfig.template :: Config.TemplateConfig
		local valid: boolean, err: string? = Composer.validateTemplate(templateConfig.source)
		if not valid then
			Logger.error(`Template validation failed: {err}`)
			hasErrors = true
		end
	end

	return not hasErrors
end

--[=[
	Displays build summary.

	@param ctx Build context
]=]
local function displaySummary(ctx: BuildContext)
	local totalDuration: number = DateTime.now().unixTimestampMillis - ctx.startTime

	Logger.section("Build Summary")
	Logger.detail(`Configuration: {ctx.config.name}`)
	Logger.detail(`Version: {ctx.version}`)
	Logger.detail(`Output: {ctx.config.output}`)

	-- Get file size
	local size: number? = FsUtils.getFileSize(ctx.config.output)
	if size then
		Logger.detail(`Size: {Logger.formatSize(size)}`)
	end

	Logger.detail(`Duration: {Logger.formatDuration(totalDuration)}`)
end

--[=[
	Opens the output file in the configured editor.

	@param output Output file path
	@param outputConfig Output configuration
]=]
local function openInEditor(output: string, outputConfig: Config.OutputConfig?)
	if not outputConfig or not outputConfig.openInEditor then
		return
	end

	if Process.os ~= "windows" then
		return
	end

	local editor: string = outputConfig.editor or "code"

	local result = Process.exec("powershell", {
		"-ExecutionPolicy",
		"Bypass",
		"-NoProfile",
		"-Command",
		`{editor} '{output}'`,
	})

	if not result.ok then
		Logger.warn(`Failed to open editor: {result.stderr}`)
	end
end

--[=[
	Main build execution function.

	@param args Command-line arguments
	@return Exit code
]=]
local function run(args: { string }): number
	-- Print header
	Logger.section(`UniversalSynSaveInstance Build Pipeline v{PIPELINE_VERSION}`)

	-- Parse arguments
	local parsedArgs = parseArgs(args)
	Logger.setVerbose(parsedArgs.verbose)

	-- Load configuration
	Logger.info(`Loading configuration: {parsedArgs.configPath}`)
	local configFile: Config.ConfigFile?, configErr: string? = Config.load(parsedArgs.configPath)

	if not configFile then
		Logger.fatal(`Configuration load failed: {configErr}`)
		return EXIT_FAILURE
	end

	Logger.success("Configuration loaded")

	-- Override CI mode if specified in config
	local ciMode: boolean = parsedArgs.ciMode or configFile.ciMode or false

	-- Select build configuration
	local buildConfig: Config.BuildConfig? = Config.selectBuildConfig(configFile, parsedArgs.buildName, ciMode)

	if not buildConfig then
		if parsedArgs.buildName then
			Logger.fatal(`Build configuration '{parsedArgs.buildName}' not found`)
		else
			Logger.fatal("No build configuration selected")
		end
		return EXIT_FAILURE
	end

	Logger.info(`Selected build: {buildConfig.name}`)
	if buildConfig.description then
		Logger.verbose(buildConfig.description)
	end

	-- Prompt for version
	local version: string = promptVersion(buildConfig, ciMode)
	Logger.verbose(`Build version: {version}`)

	-- Validate environment
	if not validateEnvironment(buildConfig) then
		Logger.fatal("Environment validation failed")
		return EXIT_FAILURE
	end

	-- Create build context
	local ctx: BuildContext = {
		config = buildConfig,
		version = version,
		ciMode = ciMode,
		verbose = parsedArgs.verbose,
		startTime = DateTime.now().unixTimestampMillis,
	}

	-- Execute build stages
	local buildType: "standard" | "wax" = Config.getBuildType(buildConfig)

	if buildType == "wax" then
		-- Wax build pipeline
		if not executeWaxStage(ctx) then
			Logger.fatal("Build failed at wax stage")
			return EXIT_FAILURE
		end
	else
		-- Standard build pipeline
		if not executeDarkluaStage(ctx) then
			Logger.fatal("Build failed at darklua stage")
			return EXIT_FAILURE
		end
	end

	-- Common stages for both build types
	if not executeComposer(ctx) then
		Logger.fatal("Build failed at composer stage")
		return EXIT_FAILURE
	end

	if not executeStyluaStage(ctx) then
		Logger.fatal("Build failed at stylua stage")
		return EXIT_FAILURE
	end

	if not executeDeployment(ctx) then
		Logger.fatal("Build failed at deployment stage")
		return EXIT_FAILURE
	end

	-- Display summary
	displaySummary(ctx)

	-- Open in editor if configured
	openInEditor(buildConfig.output, configFile.output)

	-- Success
	Logger.success("Build completed successfully!")

	return EXIT_SUCCESS
end

-- Entry point
local success: boolean, result: any = pcall(run, Process.args)

if not success then
	Logger.fatal(`Unhandled error: {result}`)
	Process.exit(EXIT_FAILURE)
end

Process.exit(result :: number)
