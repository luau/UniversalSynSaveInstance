-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")
local process = require("@lune/process")

local LuneUtils = require("./lib/libraries/LuneUtils")

local Log = LuneUtils.Log
local StringUtils = LuneUtils.StringUtils
local CommandUtils = LuneUtils.CommandUtils
local Run = LuneUtils.Run

local Version = require("./lib/data/Version")

local CodegenHeader = [[
--!nolint
--!nocheck
--!native
--!optimize 2

--[[
    Wax - A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

    Wax Version: ]] .. Version .. [=[

]]

------------------------------------------------------------------------------------------------------

]=]

local BuildFlags = {
	["build-standalone-wine"] = false,
}

for _, BuildFlag in process.args do
	if BuildFlags[BuildFlag] ~= nil then
		BuildFlags[BuildFlag] = true
	end
end

local CodegenHeaderExtraLines = StringUtils.LineCount(CodegenHeader) - 1

CommandUtils.CheckCommands({ "lune", "rojo", "darklua" })

local function WriteFile(path: string, contents: string)
	Log.Info(`Writing to "{path}"..`)
	fs.writeFile(path, contents)
end

local function WriteDir(path: string)
	Log.Info(`Creating directory at "{path}"..`)
	fs.writeDir(path)
end

local function RemoveDir(path: string)
	Log.Info(`Removing directory at "{path}"..`)
	fs.removeDir(path)
end

-- Start build process

--[[
if fs.isDir("build") then
    Log.Info("Removing old `build` directory..")
    fs.removeDir("build")
end
]]

if not fs.isDir("build") then
	WriteDir("build")
end

local function HandleRun(...)
	local Result = Run(...)
	if not Result.ok then
		RemoveDir("build")
		process.exit(1)
	end
end

HandleRun("lune", {
	"run",
	"wax",
	"bundle",
	"output=build/wax.dbg.luau",
	`extra-offset-lines={CodegenHeaderExtraLines}`,
	"ci-mode=true",
})
HandleRun("lune", { "run", "wax", "bundle", "output=build/wax.luau", "minify=true", "ci-mode=true" })

Log.Info("(Adding CodegenHeader)")
WriteFile("build/wax.dbg.luau", CodegenHeader .. fs.readFile("build/wax.dbg.luau"))
WriteFile("build/wax.luau", CodegenHeader .. fs.readFile("build/wax.luau"))

print()
Log.Info(`++++++++ Finished build target ++++++++`)
