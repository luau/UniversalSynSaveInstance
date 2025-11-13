--!strict

--[=[
	@class Runner

	Executes all dumper scripts and reports results.

	Discovers .luau files in dumpers/ directory and runs them sequentially.
	Reports success/failure counts and total execution time.

	Usage:
	  lune run scripts/run.luau [version-hash]

	Exit codes:
	  0 - All dumpers succeeded
	  1 - One or more dumpers failed or no scripts found
]=]

-- Imports
local fs = require("@lune/fs")
local Process = require("@lune/process")
local stdio = require("@lune/stdio")
local lib = require("lib")

-- Type Definitions

--[=[
	@class Result
	Execution results tracking success and failure counts.
]=]
type Result = {
	succeeded: number,
	failed: number,
}

-- Module Table
local Runner = {}

-- Private Helpers

--[=[
	@private
	Discovers dumper scripts in the dumpers directory.

	@return { string } -- Sorted list of script filenames
	@error Throws if directory read fails
]=]
local function discoverScripts(): { string }
	local ok: boolean
	local entries: any
	local files: { string }

	ok, entries = pcall(fs.readDir, "scripts/dumpers")
	if not ok then
		error("Failed to read dumpers directory")
	end

	files = {}
	for _, entry in entries do
		if string.match(entry, "%.luau$") then
			table.insert(files, entry)
		end
	end

	table.sort(files)
	return files
end

--[=[
	@private
	Prints formatted header with separator.

	@param text -- Header text
]=]
local function printHeader(text: string)
	local separator: string

	separator = string.rep("=", 70)

	stdio.write(stdio.style("bold"))
	stdio.write(stdio.color("cyan"))
	print("")
	print(separator)
	print(text)
	print(separator)
	stdio.write(stdio.style("reset"))
	stdio.write(stdio.color("reset"))
	print("")
end

--[=[
	@private
	Prints execution summary with statistics.

	@param result -- Execution results
	@param total -- Total scripts run
	@param elapsed -- Elapsed time in seconds
]=]
local function printSummary(result: Result, total: number, elapsed: number)
	local separator: string
	local color: string

	separator = string.rep("=", 70)

	stdio.write(stdio.style("bold"))
	stdio.write(stdio.color("cyan"))
	print("")
	print(separator)
	print("Summary")
	print(separator)
	stdio.write(stdio.style("reset"))

	color = if result.failed == 0 then "green" else "yellow"
	stdio.write(stdio.color(color))
	print(`  Succeeded: {result.succeeded}/{total}`)
	stdio.write(stdio.color("reset"))

	if result.failed > 0 then
		stdio.write(stdio.color("red"))
		print(`  Failed: {result.failed}/{total}`)
		stdio.write(stdio.color("reset"))
	end

	stdio.write(stdio.color("blue"))
	print(`  Time: {string.format("%.2f", elapsed)}s`)
	stdio.write(stdio.color("reset"))
end

--[=[
	@private
	Executes a single dumper script.

	@param file -- Script filename
	@param hash -- Optional version hash
	@return boolean -- True if script succeeded
]=]
local function executeScript(file: string, hash: string?): boolean
	local args: { string }
	local path: string
	local ok: boolean
	local result: any

	args = if hash then { hash } else {}
	path = `scripts/dumpers/{file}`

	ok, result = pcall(Process.exec, "lune", { "run", path, table.unpack(args) }, {
		stdio = "inherit",
	})

	if not ok then
		stdio.write(stdio.color("red"))
		stdio.write("x ")
		stdio.write(stdio.color("reset"))
		stdio.ewrite(`Execution failed: {result}\n`)
		return false
	end

	if not result.ok then
		stdio.write(stdio.color("red"))
		stdio.write("x ")
		stdio.write(stdio.color("reset"))
		stdio.ewrite(`Exit code {result.code}\n`)
		return false
	end

	return true
end

--[=[
	@private
	Prints script name with progress indicator.

	@param index -- Current script index (1-based)
	@param total -- Total number of scripts
	@param file -- Script filename
]=]
local function printScriptName(index: number, total: number, file: string)
	local scriptName: string

	scriptName = string.gsub(file, "%.luau$", "")

	stdio.write(stdio.style("bold"))
	print(`[{index}/{total}] {scriptName}`)
	stdio.write(stdio.style("reset"))
end

-- Public API

--[=[
	Runs all dumper scripts sequentially.

	@param hash -- Optional version hash to pass to dumpers
	@error Exits with code 1 if any dumper fails or no scripts found
]=]
function Runner.run(hash: string?)
	local files: { string }
	local result: Result
	local startTime: number
	local elapsed: number

	files = discoverScripts()

	if #files == 0 then
		stdio.write(stdio.color("yellow"))
		stdio.write("! ")
		stdio.write(stdio.color("reset"))
		print("No dumper scripts found")
		Process.exit(1)
	end

	printHeader(`API Dump Analysis  •  {os.date("%Y-%m-%d %H:%M:%S")}`)

	if hash then
		stdio.write(stdio.color("blue"))
		stdio.write("i ")
		stdio.write(stdio.color("reset"))
		print(`Version: {hash}`)
		print("")
	end

	result = {
		succeeded = 0,
		failed = 0,
	}

	startTime = os.time()

	for index, file in files do
		printScriptName(index, #files, file)

		if executeScript(file, hash) then
			result.succeeded += 1
		else
			result.failed += 1
		end

		print("")
	end

	elapsed = os.time() - startTime
	printSummary(result, #files, elapsed)

	if result.failed > 0 then
		Process.exit(1)
	end
end

-- Entry Point
lib.runCli(Runner.run, Process.args)
