--!strict
--[=[
	@class Darklua
	Darklua transformation stage for code bundling and optimization.

	Executes darklua transformations with support for multiple processing stages,
	environment variable injection, and comprehensive error handling. Each stage
	can use a different darklua configuration for tasks like bundling, optimization,
	and minification.

	@usage
	```lua
	local DarkluaProcessor = require("./stages/darklua-processor")
	local result = DarkluaProcessor.process(input, output, darkluaConfig)
	```
]=]

-- Imports
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local FsUtils = require("../lib/fs-utils")
local Config = require("../lib/config")

-- Types
export type ProcessResult = {
	success: boolean,
	output: string?,
	error: string?,
	duration: number,
	stagesCompleted: number,
}

-- Module
local Darklua = {}

--[=[
	Executes darklua process command with given parameters.

	Runs darklua with custom environment variables merged into process env.

	@param input Input file path
	@param output Output file path
	@param configPath Path to darklua config JSON file
	@param env Optional environment variables to inject
	@return True if succeeded, stderr string
]=]
local function executeDarklua(
	input: string,
	output: string,
	configPath: string,
	env: { [string]: string }?
): (boolean, string)
	local processEnv: { [string]: string } = table.clone(Process.env)
	if env then
		for key: string, value: string in env do
			processEnv[key] = value
		end
	end

	local result = Process.exec("darklua", {
		"process",
		input,
		output,
		"-c",
		configPath,
	}, {
		env = processEnv,
	})

	return result.ok, result.stderr
end

--[=[
	Processes a file through multiple darklua stages.

	Runs sequential transformation passes with different configs. Intermediate
	results are stored in temporary files and cleaned up automatically.

	@param input Initial input file path
	@param finalOutput Final output file path
	@param darkluaConfig Darklua configuration with stages array
	@return ProcessResult with success, output, duration, and stage count
]=]
function Darklua.process(
	input: string,
	finalOutput: string,
	darkluaConfig: Config.DarkluaConfig
): ProcessResult
	local startTime: number = DateTime.now().unixTimestampMillis

	if not FsUtils.isReadableFile(input) then
		return {
			success = false,
			output = nil,
			error = `Input not found: {input}`,
			duration = 0,
			stagesCompleted = 0,
		}
	end

	local stages: { Config.DarkluaStage } = darkluaConfig.stages or {}

	if #stages == 0 then
		Logger.verbose("No stages defined, using default config")

		local configPath: string = "pipeline/.darklua.json"
		if not FsUtils.isReadableFile(configPath) then
			return {
				success = false,
				output = nil,
				error = `Config not found: {configPath}`,
				duration = 0,
				stagesCompleted = 0,
			}
		end

		FsUtils.ensureParentDir(finalOutput)
		local success: boolean, stderr: string = executeDarklua(input, finalOutput, configPath, nil)

		if not success then
			return {
				success = false,
				output = nil,
				error = `Processing failed: {stderr}`,
				duration = DateTime.now().unixTimestampMillis - startTime,
				stagesCompleted = 0,
			}
		end

		return {
			success = true,
			output = finalOutput,
			error = nil,
			duration = DateTime.now().unixTimestampMillis - startTime,
			stagesCompleted = 1,
		}
	end

	-- Multi-stage processing
	local currentInput: string = input
	local stagesCompleted: number = 0

	for index: number, stage: Config.DarkluaStage in stages do
		local isLastStage: boolean = index == #stages
		local stageOutput: string = if isLastStage then finalOutput else `{finalOutput}.stage{index}.tmp`

		Logger.detail(`Stage {index}/{#stages}: {stage.name} ({FsUtils.getBaseName(stage.config)})`)

		-- Validate stage config exists
		if not FsUtils.isReadableFile(stage.config) then
			if stage.optional then
				Logger.warn(`Skipping optional stage '{stage.name}': config not found`)
				continue
			else
				return {
					success = false,
					output = nil,
					error = `Darklua config not found for stage '{stage.name}': {stage.config}`,
					duration = DateTime.now().unixTimestampMillis - startTime,
					stagesCompleted = stagesCompleted,
				}
			end
		end

		-- Ensure output directory exists
		FsUtils.ensureParentDir(stageOutput)

		-- Execute darklua for this stage
		local success: boolean, stderr: string = executeDarklua(currentInput, stageOutput, stage.config, stage.env)

		if not success then
			if stage.optional then
				Logger.warn(`Optional stage '{stage.name}' failed: {stderr}`)
				continue
			else
				return {
					success = false,
					output = nil,
					error = `Stage '{stage.name}' failed: {stderr}`,
					duration = DateTime.now().unixTimestampMillis - startTime,
					stagesCompleted = stagesCompleted,
				}
			end
		end

		stagesCompleted += 1

		-- Clean up previous temporary file
		if currentInput ~= input and FsUtils.isReadableFile(currentInput) then
			FsUtils.safeRemoveFile(currentInput)
		end

		currentInput = stageOutput
	end

	-- Clean up any remaining temporary files
	for i = 1, #stages - 1 do
		local tmpFile: string = `{finalOutput}.stage{i}.tmp`
		if FsUtils.isReadableFile(tmpFile) then
			FsUtils.safeRemoveFile(tmpFile)
		end
	end

	local duration: number = DateTime.now().unixTimestampMillis - startTime

	return {
		success = true,
		output = finalOutput,
		error = nil,
		duration = duration,
		stagesCompleted = stagesCompleted,
	}
end

--[=[
	Checks if darklua is available in system PATH.

	@return True if darklua command exists
]=]
function Darklua.isAvailable(): boolean
	return Process.exec("darklua", { "--version" }).ok
end

--[=[
	Gets the installed darklua version.

	@return Version string like "0.17.2", or nil if unavailable
]=]
function Darklua.getVersion(): string?
	local result = Process.exec("darklua", { "--version" })
	if not result.ok then
		return nil
	end

	return result.stdout:match("darklua ([%d%.]+)")
end

return Darklua
