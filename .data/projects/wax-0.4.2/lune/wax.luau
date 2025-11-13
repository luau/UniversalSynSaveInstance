-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

if string.sub(_VERSION, 1, 4) ~= "Lune" then
	print(
		"!! Wax doesn't appear to be running on Lune (https://lune-org.github.io/docs), which this script requires, exitting.."
	)
	return
end

do
	-- Minimum "recommended" ver
	local MajorRec, MinorRec, PatchRec = 0, 8, 0

	local Major, Minor, Patch = string.match(_VERSION, "Lune (%d+).(%d+).(%d+)")

	Major, Minor, Patch = tonumber(Major), tonumber(Minor), tonumber(Patch)

	if not Major then
		print(`! Can't parse Lune's version on the assumed format from "{_VERSION}", continuing anyway..\n`)
	else
		_G.LuneVersion = `{Major}.{Minor}.{Patch}`
		if
			Major < MajorRec
			or (Minor < MinorRec and Major <= MajorRec)
			or (Patch < PatchRec and Minor <= MinorRec and Major <= MajorRec)
		then
			print(
				`! Lune version "{_G.LuneVersion}" detected, but Wax currently recommends Lune {MajorRec}.{MinorRec}.{PatchRec} or higher, continuing anyway..\n`
			)
		end
	end
end

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local LuneUtils = require("./lib/libraries/LuneUtils")
local BundleModel = require("./lib/BundleModel")

local Version = require("./lib/data/Version")
local DefaultDarkluaConfig = require("./lib/data/DefaultDarkluaConfig")

local Log = LuneUtils.Log
local StringUtils = LuneUtils.StringUtils
local CommandUtils = LuneUtils.CommandUtils
local Run = LuneUtils.Run
local ParseArgs = LuneUtils.ParseArgs

local UsageMessage = `Wax {Version}\n`
	.. [[
A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

USAGE:
    lune run wax [subcommand] [options]

* When no subcommand is provided, this usage message is displayed
* Provide all options in the following format (no "--" flag prefix): option=value

SUBCOMMANDS:
    help      Displays this usage message

    version   Displays Wax's version

    bundle    Builds a bundled script file from a given Roblox model (*.rbxm/*.rbxmx)
              or Rojo project file (*.project.json, requires the `rojo` command
              available in your PATH environment variable), to an output path

      OPTIONS for `bundle`:
      * input[="default.project.json"]
            The input Roblox model (*.rbxm/*.rbxmx) or Rojo project (*.project.json) file
            path for Wax to bundle from

      * output[="{input-filename}.lua"]
            The final output file path (must end in .lua or .luau) for the bundled script

      * minify[=false]
            If codegen output should be "minified", which also omits any runtime line
            debugging info (offsets). For 'full' codegen minification (outside of just
            LuaEncode's table output), you must have the `darklua` command available in
            your PATH environment variable.
            Additionally, with Darklua, if a ".darklua.json/json5" file isn't found in the
            CWD (your dir "position" in your terminal), it'll use the default configuration
            we provide (see `lune/lib/data/DefaultDarkluaConfig.luau`)

      * env-name[="WaxRuntime"]
            The name of the "environment" of the bundled script. This is the "name" of
            the root object (like the `game` DataModel in Roblox) and displays in virtual
            runtime errors (e.g. "[WaxRuntime].Script:1: Some error message")

      * darklua-config-path[=(".darklua.json", ".darklua.json5")]
            When `minify` is set as true, this path can be used to directly pass your own
            Darklua config file's path, instead of only checking for the default paths
            it looks for

      * temp-dir-base[="{output-dir}"]
            If you're providing a Rojo project file as input or minifying with Darklua,
            a temporary directory is created inside of this directory path, and is removed
            by the time Wax has completed processing

      * extra-offset-lines[=0]
            (Only applicable to when `minify` is set to false) Internally acknowledges
            any extra lines offset from the top of the script (like if you're adding a
            header of sorts to the codegen) for line debugging info. Ths MUST be exactly
            accurate to its name (*extra* lines, so you may want to do something like
            `#ExtraHeader - 1` if you're using this option)

      * ci-mode[=false]
            (*Primarily* for automated CI pipelines or deployment systems) Never gives
            any user input prompts, and will *always* exit with a `1` status code upon an
            'error' or warning during the build process

      * verbose[=true]
            "Verbose" (detailed) output logging from CLI/bundler
]]

local DirectionToHelp = "Run `lune wax help` for more info"

-- Flush out any other previous ANSI nonsense
stdio.write(stdio.color("reset") .. stdio.style("reset"))

local function EncodeShellData(shellData: string): string
	return if process.os == "windows"
		then shellData -- I swear, Windows makes everything worse
		else '"' .. StringUtils.SerializeStringData(shellData) .. '"'
end

local CommandArgs = table.clone(process.args)
local Subcommand = table.remove(CommandArgs, 1)

if not Subcommand then
	print(UsageMessage)
	return
end

Subcommand = string.lower(Subcommand)

if Subcommand == "help" then
	print(UsageMessage)
	return
elseif Subcommand == "version" then
	print(`Wax v{Version}`)
	return
elseif Subcommand == "bundle" then
	-- Below is our user-proofing hell!
	-- “An idiot admires complexity, a genius admires simplicity" - Terry A Davis

	-- Parse and init default CLI options
	local Options = ParseArgs(CommandArgs, {
		-- Option = {Type, DefaultValue, IsRequired?}
		["input"] = { "string", "default.project.json" },
		["output"] = { "string", nil },
		["minify"] = { "boolean", false },
		["env-name"] = { "string", nil }, -- BundleModel() internally defaults to "WaxRuntime"
		["darklua-config-path"] = { "string", nil },
		["temp-dir-base"] = { "string", nil },
		["extra-offset-lines"] = { "number", 0 },
		["ci-mode"] = { "boolean", false },
		["verbose"] = { "boolean", true },
	}, UsageMessage)

	local Verbose = Options["verbose"]
	local CIMode = Options["ci-mode"]

	local Minify = Options["minify"]
	local EnvName = Options["env-name"]

	local function RunIfVerbose(f, ...)
		if Verbose then
			f(...)
		end
	end

	-- These is being defined here since we're utilizing RunIfVerbose()
	local function WriteFile(path: string, contents: string)
		RunIfVerbose(Log.Info, `Writing to "{path}"..`)
		fs.writeFile(path, contents)
	end

	local function RemoveFile(path: string)
		RunIfVerbose(Log.Info, `Deleting file at "{path}"..`)
		fs.removeFile(path)
	end

	local function WriteDir(path: string)
		RunIfVerbose(Log.Info, `Creating directory at "{path}"..`)
		fs.writeDir(path)
	end

	local function RemoveDir(path: string)
		RunIfVerbose(Log.Info, `Removing directory at "{path}"..`)
		fs.removeDir(path)
	end

	-- `input` option handling:

	local Input = Options["input"]

	if not fs.isFile(Input) then
		Log.Error(`Failed to find file path "{Input}" from \`input\` option\n`)
		print(DirectionToHelp)
		process.exit(1)
	end

	local InputDirectory = StringUtils.DirectoryOfFilePath(Input) or ""

	local InputLower = string.lower(Input)
	local InputType = if string.sub(InputLower, -5) == ".rbxm"
		then ".rbxm" -- Roblox model (binary)
		elseif string.sub(InputLower, -6) == ".rbxmx" then ".rbxmx" -- Roblox model (XML)
		elseif string.sub(InputLower, -13) == ".project.json" then ".project.json" -- Rojo project file
		else nil

	if not InputType then
		Log.Error(
			`Invalid file type ".{StringUtils.FileType(Input)}" for \`input\`, expected [".rbxm", ".rbxmx", ".project.json"]\n`
		)
		print(DirectionToHelp)
		process.exit(1)
	end

	-- `output` option handling:

	local Output = Options["output"]

	if not Output then
		local NewOutputBase

		if InputType == ".project.json" then
			local ParseSuccess, ErrorOrParsed = pcall(serde.decode, "json" :: "json", fs.readFile(Input))

			if not ParseSuccess then
				Log.Error(`Failed to parse Rojo project file at "{Input}": {ErrorOrParsed}`)
				process.exit(1)
			end

			if not ErrorOrParsed.name or type(ErrorOrParsed.name) ~= "string" then
				Log.Warn(
					`Couldn't find proper "name" entry at the root of Rojo project file at "{Input}", using its file name base instead..`
				)
			else
				NewOutputBase = ErrorOrParsed.name
			end
		end

		-- If it's not a Rojo project file or `NewOutputBase` still hasn't been set..
		if not NewOutputBase then
			NewOutputBase = StringUtils.FilePathWithoutExtension(Input, false)
		end

		if not NewOutputBase then
			Log.InternalError(`Failed to get file path without the extension for "{Output}"`)
			process.exit(1)
		end

		NewOutputBase ..= ".wax.lua"
		Output = InputDirectory .. NewOutputBase
	else
		local OutputFileType = StringUtils.FileType(Output)
		local DirectoryOfOutput = StringUtils.DirectoryOfFilePath(Output)

		if not DirectoryOfOutput then
			Log.Error(`\`output\` file path given, "{Output}" not a valid path\n`)
			print(DirectionToHelp)
			process.exit(1)
		elseif not fs.isDir(DirectoryOfOutput) then
			Log.Error(`Directory of \`output\` file path given, "{DirectoryOfOutput}" not found/invalid\n`)
			print(DirectionToHelp)
			process.exit(1)
		elseif not OutputFileType or not table.find({ "lua", "luau" }, OutputFileType) then
			local FileTypeDisplay = if OutputFileType == "" then "<empty>" else "." .. OutputFileType

			Log.Error(`File type of \`output\` ({FileTypeDisplay}) invalid, expected [".lua", ".luau"]\n`)
			print(DirectionToHelp)
			process.exit(1)
		end
	end

	local OutputFileName = StringUtils.FileNameFromPath(Output)
	if not OutputFileName then
		Log.InternalError(`Failed to parse file name from output file path "{Output}"`)
		process.exit(1)
	end

	local OutputFileNameWithoutExtension = StringUtils.FileNameWithoutExtension(OutputFileName, false)
	if not OutputFileNameWithoutExtension then
		Log.InternalError(`Failed to parse file name without its extension from "{OutputFileName}"`)
		process.exit(1)
	end

	-- `darklua-config-path` option handling:

	DarkluaConfigPath = Options["darklua-config-path"]

	if DarkluaConfigPath and not fs.isFile(DarkluaConfigPath) then
		Log.Error(`File path given for \`darklua-config-path\`, "{DarkluaConfigPath}" not found`)
		process.exit(1)
	end

	-- `temp-dir-base` option handling:

	local TempDirBase = Options["temp-dir-base"]

	if not TempDirBase then
		TempDirBase = StringUtils.DirectoryOfFilePath(Output)
	elseif not fs.isDir(TempDirBase) then
		Log.Error(`\`temp-dir-base\` directory given, "{TempDirBase}" not found/invalid\n`)
		print(DirectionToHelp)
		process.exit(1)
	end

	if not string.match(TempDirBase, "[/\\]$") then
		TempDirBase ..= "/"
	end

	-- The actual temp dir path we'll be using
	local TempDir = TempDirBase .. ".wax-tmp/"

	-- If it already exists for some reason..?
	if fs.isDir(TempDir) then
		RunIfVerbose(Log.Info, `Old .wax-tmp dir at "{TempDir}" already exists, removing..`)
		fs.removeDir(TempDir)
	end

	ExtraOffsetLines = Options["extra-offset-lines"]
	if ExtraOffsetLines < 0 then
		Log.Error(`Option \`extra-offset-lines\` ({ExtraOffsetLines}) cannot be less than 0\n`)
		print(DirectionToHelp)
		process.exit(1)
	end
	if not Minify and ExtraOffsetLines > 0 then
		RunIfVerbose(
			Log.Info,
			`(Note) Runtime line debugging *will* display with the assumption that \`{ExtraOffsetLines}\` lines will be added to the output by you manually; make sure this is EXACT, as debugging info could be inaccurate otherwise`
		)
	end

	-- Now we'll start non-option processing

	-- Now, we may need to eventually worry about exitting upon random unhandled errors
	-- since we may be creating a temp dir in the user's directory
	local function BadExit(message: string?)
		if message then
			Log.Error(message)
		end

		if fs.isDir(TempDir) then
			RemoveDir(TempDir)
		end

		process.exit(1)
	end

	-- Check for necessary commands
	if InputType == ".project.json" and not CommandUtils.CommandExists("rojo") then
		Log.Error(
			`Rojo project file given for input ("{Input}"), but the \`rojo\` command wasn't found in your PATH environment variable..\n`
		)
		print(DirectionToHelp)
		process.exit(1)
	end

	local DarkluaBinaryExists = CommandUtils.CommandExists("darklua")
	if Minify and not DarkluaBinaryExists then
		Log.Warn(
			"The `minify` option is set as true, but the `darklua` command wasn't found in your PATH environment variable.. (Wax won't be able to completely minify the output)"
		)
		if not CIMode then
			local ShouldContinue = stdio.prompt("confirm", "Continue anyway?")
			if not ShouldContinue then
				BadExit()
			end
		end
	end

	-- Create tmp dir if applicable
	if InputType == ".project.json" or (Minify and DarkluaBinaryExists) then
		WriteDir(TempDir)
	end

	local ModelRoot

	if table.find({ ".rbxm", ".rbxmx" }, InputType) then -- Roblox model file (direct)
		RunIfVerbose(Log.Info, `Deserializing Roblox model file at "{Input}"..`)
		local Success, ModelRootOrError = pcall(roblox.deserializeModel, fs.readFile(Input))

		if not Success then -- ModelRootOrError is an err msg
			BadExit(`Failed to deserialize Roblox model file at "{Input}": {ModelRootOrError}`)
		end

		-- Here, it's just the ModelRoot return ofc
		ModelRoot = ModelRootOrError
	elseif InputType == ".project.json" then -- Rojo project file
		local ModelOutputFileName = TempDir .. OutputFileNameWithoutExtension .. ".o.rbxm"
		RunIfVerbose(Log.Info, `Building from Rojo project file to "{ModelOutputFileName}"`)

		Run(
			"rojo",
			{
				"build",
				"-o",
				EncodeShellData(ModelOutputFileName),
				EncodeShellData(Input),
			},
			false,
			BadExit -- Run() has an option to provide an err handler ourselves
		)

		ModelRoot = roblox.deserializeModel(fs.readFile(ModelOutputFileName))
		RemoveFile(ModelOutputFileName) -- Remove temporary rbxm
	end

	local BundleSuccess, CodegenOutputOrError, FailedCompilations =
		pcall(BundleModel, ModelRoot, EnvName, Minify, ExtraOffsetLines, Verbose)

	if not BundleSuccess then
		BadExit(`Error during BundleModel() process: {CodegenOutputOrError}`)
	end

	if Minify and DarkluaBinaryExists then
		local TempOutputFilePath = TempDir .. OutputFileName
		WriteFile(TempOutputFilePath, CodegenOutputOrError)

		RunIfVerbose(Log.Info, "Starting minification process with Darklua")

		local ExtraDarkluaProcessArgs = {}

		-- Check for possible default Darklua cfg files under CWD
		local TempDarkluaConfigPath = TempDir .. ".darklua.json"
		local TempDarkluaConfigWasAdded = false

		if DarkluaConfigPath then
			table.insert(ExtraDarkluaProcessArgs, `-c={EncodeShellData(DarkluaConfigPath)}`)
		elseif not fs.isFile(".darklua.json") and not fs.isFile(".darklua.json5") then
			RunIfVerbose(
				Log.Info,
				`No default Darklua config file found in CWD; creating our default config at "{TempDarkluaConfigPath}"`
			)
			WriteFile(TempDarkluaConfigPath, DefaultDarkluaConfig)
			TempDarkluaConfigWasAdded = true

			table.insert(ExtraDarkluaProcessArgs, `-c={EncodeShellData(TempDarkluaConfigPath)}`)
		end

		Run("darklua", {
			"process",
			EncodeShellData(TempOutputFilePath),
			EncodeShellData(Output),
			unpack(ExtraDarkluaProcessArgs),
		})

		RemoveFile(TempOutputFilePath)
		if TempDarkluaConfigWasAdded then
			RemoveFile(TempDarkluaConfigPath)
		end
	else
		-- Just write directly
		WriteFile(Output, CodegenOutputOrError)
	end

	-- We're now completely finished!
	if fs.isDir(TempDir) then
		RemoveDir(TempDir)
	end

	-- Let the user *clearly* know if there were any user-fault compiler errors
	if FailedCompilations > 0 then
		print()
		Log.Warn(
			`WARNING: {FailedCompilations} scripts failed to compile ahead-of-time (CHECK FULL BUILD LOG ABOVE FOR MORE DETAILS); these will throw errors at runtime upon being loaded, detailing said compilation errors.`
		)

		process.exit(1)
	end
else
	Log.Error(`Subcommand "{Subcommand}" invalid, see usage for all valid subcommands:\n`)
	print(UsageMessage)
	process.exit(1)
end
