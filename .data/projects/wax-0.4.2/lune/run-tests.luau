-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

-- This is a basic automated "test" runner, just for overlooking basic
-- functionality and making sure everything works as expected and implemented

local fs = require("@lune/fs")
local process = require("@lune/process")

local LuneUtils = require("./lib/libraries/LuneUtils")

local Log = LuneUtils.Log
local StringUtils = LuneUtils.StringUtils
local CommandUtils = LuneUtils.CommandUtils
local Run = LuneUtils.Run

CommandUtils.CheckCommands({ "lune", "luau", "lua5.1", "lua5.2", "rojo", "darklua" })

print("\n++++++++++ BUNDLING TEST PROJECTS ++++++++++\n")

local ScriptFilesToTest = {}

for _, TestName in fs.readDir("tests") do
	if not fs.isDir(`tests/{TestName}`) then
		Log.Warn(`\`tests\` entry "{TestName}" not a directory, skipping..`)
		continue
	end

	local DoNotExitForErrors = fs.isFile(`tests/{TestName}/do-not-exit-for-errors`)

	local RojoProjectFilePath = `tests/{TestName}/default.project.json`
	local OutputScriptPath = `tests/{TestName}/{TestName}.wax.lua`
	local OutputScriptPathMin = `tests/{TestName}/{TestName}.min.wax.lua`

	if not fs.isFile(RojoProjectFilePath) then
		Log.Warn(`Rojo project file for test "{TestName}" not found at "{RojoProjectFilePath}", skipping..`)
		continue
	end

	if fs.isFile(OutputScriptPath) or fs.isFile(OutputScriptPathMin) then
		Log.Info(`Existing output script at "{OutputScriptPath}", removing for re-bundling..`)

		pcall(fs.removeFile, OutputScriptPath)
		pcall(fs.removeFile, OutputScriptPathMin)
	end

	local BundleResult = Run("lune", {
		"run",
		"wax",
		"bundle",
		`input={RojoProjectFilePath}`,
		`output={OutputScriptPath}`,
		"minify=false",
		"ci-mode=true",
		"verbose=false",
	})
	local BundleResultMin = Run("lune", {
		"run",
		"wax",
		"bundle",
		`input={RojoProjectFilePath}`,
		`output={OutputScriptPathMin}`,
		"minify=true",
		"ci-mode=true",
		"verbose=false",
	})

	local BadResult = if not BundleResult.ok
		then BundleResult
		elseif not BundleResultMin.ok then BundleResultMin
		else nil
	if BadResult and not DoNotExitForErrors then
		print()
		Log.Error(`Test "{TestName}" failed to build (SEE COMMAND LOG ABOVE FOR DETAILS), aborting!`)
		process.exit(1)
	end

	table.insert(ScriptFilesToTest, { OutputScriptPath, DoNotExitForErrors })
	table.insert(ScriptFilesToTest, { OutputScriptPathMin, DoNotExitForErrors })
end

print("\n++++++++++ STARTING TEST RUNNER PROCESS ++++++++++\n")

for _, ScriptPathObject in ScriptFilesToTest do
	local ScriptPath = ScriptPathObject[1]
	local DoNotExitForErrors = ScriptPathObject[2]

	Log.Info(`Running script file "{StringUtils.FileNameFromPath(ScriptPath)}" for all targets..\n`)

	local function RunWithCommand(binary: string, args: { string }?)
		args = args or {}
		table.insert(args :: { any }, ScriptPath)

		Log.Info(`> {binary} {table.concat(args :: {}, " ")}`)
		local Result = process.spawn(binary, args, {
			shell = true,
			stdio = "inherit",
		})

		if not Result.ok and not DoNotExitForErrors then
			process.exit(1)
		end

		--[[
        Run(binary, args, false, function(message: string?)
            if not DoNotExitForErrors then
                if message then
                    Log.Error(message)
                end

                process.exit(1)
            end
        end)
        ]]
	end

	RunWithCommand("lua5.1")
	RunWithCommand("lua52")
	RunWithCommand("luau")
	RunWithCommand("lune", { "run" })

	print("--------------------------------------------------------------------------------\n")
end
