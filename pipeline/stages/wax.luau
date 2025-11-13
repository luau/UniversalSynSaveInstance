--!strict
--[=[
	@class Wax
	Wax bundling stage for Roblox model and Rojo project bundling.

	Executes wax to bundle Roblox models (.rbxm/.rbxmx) or Rojo projects
	(.project.json) into standalone Lua/Luau scripts with virtual Roblox DOM
	support. Optionally integrates darklua for post-bundle minification.

	@usage
	```lua
	local WaxBundler = require("./stages/wax-bundler")
	local result = WaxBundler.bundle(input, output, waxConfig)
	```
]=]

-- Imports
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local FsUtils = require("../lib/fs-utils")
local Config = require("../lib/config")

-- Types
export type BundleResult = {
	success: boolean,
	output: string?,
	error: string?,
	duration: number,
}

-- Module
local Wax = {}

--[=[
	Builds wax command-line arguments from configuration.

	Constructs key=value pairs for wax bundle command with optional minify,
	env-name, and darklua-config-path parameters.

	@param input Input file path (.rbxm/.rbxmx/.project.json)
	@param output Output file path
	@param config Wax configuration
	@return Array of command-line argument strings
]=]
local function buildWaxArgs(input: string, output: string, config: Config.WaxConfig): { string }
	local args: { string } = {
		"bundle",
		`input={input}`,
		`output={output}`,
	}

	if config.minify then
		table.insert(args, "minify=true")
	end

	if config.envName then
		table.insert(args, `env-name={config.envName}`)
	end

	if config.darklua and config.darklua.config then
		table.insert(args, `darklua-config-path={config.darklua.config}`)
	end

	table.insert(args, "ci-mode=true")
	table.insert(args, "verbose=true")

	return args
end

--[=[
	Bundles a Roblox model or Rojo project using wax.

	Validates input file type, executes wax via lune, and verifies output creation.

	@param input Input file path (.rbxm, .rbxmx, or .project.json)
	@param output Output Luau file path
	@param config Wax configuration
	@return BundleResult with success, output, duration
]=]
function Wax.bundle(input: string, output: string, config: Config.WaxConfig): BundleResult
	local startTime: number = DateTime.now().unixTimestampMillis

	if not FsUtils.isReadableFile(input) then
		return {
			success = false,
			output = nil,
			error = `Input not found: {input}`,
			duration = 0,
		}
	end

	local validExtensions: { string } = { ".rbxm", ".rbxmx", ".project.json" }
	local hasValidExtension: boolean = false

	for _, ext: string in validExtensions do
		if input:match(ext .. "$") then
			hasValidExtension = true
			break
		end
	end

	if not hasValidExtension then
		return {
			success = false,
			output = nil,
			error = "Invalid input type (expected .rbxm, .rbxmx, or .project.json)",
			duration = 0,
		}
	end

	FsUtils.ensureParentDir(output)

	local args: { string } = buildWaxArgs(input, output, config)

	Logger.verbose(`Executing: lune run wax {table.concat(args, " ")}`)

	local result = Process.exec("lune", { "run", "wax", table.unpack(args) })
	local duration: number = DateTime.now().unixTimestampMillis - startTime

	if not result.ok then
		return {
			success = false,
			output = nil,
			error = `Bundle failed: {result.stderr}`,
			duration = duration,
		}
	end

	if not FsUtils.isReadableFile(output) then
		return {
			success = false,
			output = nil,
			error = `Output not created: {output}`,
			duration = duration,
		}
	end

	return {
		success = true,
		output = output,
		error = nil,
		duration = duration,
	}
end

--[=[
	Checks if wax is available via lune.

	@return True if wax command exists
]=]
function Wax.isAvailable(): boolean
	return Process.exec("lune", { "run", "wax", "version" }).ok
end

--[=[
	Gets the installed wax version.

	@return Version like "0.4.2", or nil if unavailable
]=]
function Wax.getVersion(): string?
	local result = Process.exec("lune", { "run", "wax", "version" })
	if not result.ok then
		return nil
	end

	return result.stdout:match("wax v([%d%.]+)")
end

--[=[
	Detects if the input file is a Rojo project.

	@param input Input file path
	@return True if ends with .project.json
]=]
function Wax.isRojoProject(input: string): boolean
	return input:match("%.project%.json$") ~= nil
end

--[=[
	Detects if the input file is a Roblox model.

	@param input Input file path
	@return True if ends with .rbxm or .rbxmx
]=]
function Wax.isRobloxModel(input: string): boolean
	return input:match("%.rbxmx?$") ~= nil
end

return Wax
