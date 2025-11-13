-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local luau = require("@lune/luau")
local roblox = require("@lune/roblox")

local LuneUtils = require("./libraries/LuneUtils")

local Log = LuneUtils.Log
local StringUtils = LuneUtils.StringUtils

local LuaEncode = require("./libraries/LuaEncode")

local Version = require("./data/Version")

-- Init script template for codegen (in this, we'll maintain 5.1 *syntax* compat
-- for optional compilation to vanilla Lua 5.1x bytecode format)
local InitScriptTemplate = require("./data/Template")

-- The line where the 1st closure's function will start in bundled codegen
local InitialLineOffset = 8

local ClassNameIdKeys = {
	Folder = 1,
	ModuleScript = 2,
	Script = 3,
	LocalScript = 4,
	StringValue = 5,
}

-- Building codegen directly from model data (from .rbxm/.rbxmx) or a deserialized
-- object using Lune's `roblox` library
local function BundleModel(
	modelData: string | { roblox.Instance },
	envName: string?,
	minifyCodegen: boolean?,
	extraLinesToOffset: number?,
	verbose: boolean?
): (string, number)
	local EnvName = envName or "WaxRuntime"
	local MinifyCodegen = if minifyCodegen == nil then true else minifyCodegen
	local ExtraLinesToOffset = extraLinesToOffset or 0
	local Verbose = if verbose == nil then true else verbose

	-- Same as in Wax CLI
	local function RunIfVerbose(f, ...)
		if Verbose then
			f(...)
		end
	end

	local LineDebugging = MinifyCodegen == false

	local ModelRoot = if type(modelData) == "string" then roblox.deserializeModel(modelData) else modelData

	-- We'll track how long it takes for us to read the entire object tree, with all
	-- other various processes included
	local ReadStartTime = os.clock()

	local FailedCompilations = 0

	-- We'll initialize the output object tree, then walk through what we need to
	local ObjectTree = {}
	local ClosureBindings = {} -- [RefId] = Closure
	local ClosureSourceLineCounts = {} -- [RefId] = LineCount

	local ScrapedInstanceTree = {} -- [RealRef] = {Child, ...}
	local RefIds = {} -- [RefId] = RealRef

	-- Recursive function to actually walk through the real instance tree, and assign refs
	local function ScrapeInstanceChildren(instance)
		-- Add a reference id for this instance
		table.insert(RefIds, instance)

		local ScrapedChildren = {}
		for _, Child in instance:GetChildren() do
			ScrapedChildren[Child] = ScrapeInstanceChildren(Child)
		end

		return ScrapedChildren
	end

	-- Initialize the scraped instance tree and assign all refs from root
	local ModelRootChildren = ModelRoot -- Using later aswell
	for _, RealInstance in ModelRootChildren do
		ScrapedInstanceTree[RealInstance] = ScrapeInstanceChildren(RealInstance)
	end

	-- Now, we'll recursively create the fake object tree
	local function CreateObjectTree(instance, children, currentPathString: string?)
		currentPathString = currentPathString or instance.Name

		local RefId = table.find(RefIds, instance)
		local ClassName = instance.ClassName

		local ClassNameId = ClassNameIdKeys[ClassName]
		if not ClassNameId then
			Log.Warn(`Skipping instance of ClassName "{ClassName}", as it isn't supported in bundling`)
			return
		end

		local InstanceIsABaseScript = ClassName == "LocalScript" or ClassName == "Script"
		local InstanceIsAScript = InstanceIsABaseScript or ClassName == "ModuleScript"

		--[[
            {
                [1] = RefId,
                [2] = ClassName,
                [3] = Properties,
                [4] = Children?
            }
        ]]

		local InstanceObject = {
			[1] = RefId,
			[2] = ClassNameId,
		}

		-- If it's statically disabled, we just won't include the closure to run
		if InstanceIsAScript and not (InstanceIsABaseScript and instance.Disabled) then
			local ScriptSource = instance.Source

			RunIfVerbose(Log.Info, `Compile-checking {instance.ClassName} "{currentPathString}"..`)
			local CompileSuccess, CompileError = pcall(luau.compile, ScriptSource)

			if CompileSuccess then
				-- The added line here is the "\nend" below every arbitrary closure
				ClosureSourceLineCounts[RefId] = StringUtils.LineCount(ScriptSource) + 1

				-- We're using `FunctionsReturnRaw` on LuaEncode later, this will set the return
				-- to the rew value, which is the script closure
				ClosureBindings[RefId] = function()
					return "function()local wax,script,require=ImportGlobals("
						.. RefId
						.. ")local ImportGlobals return (function(...)"
						.. ScriptSource
						.. "\nend)() end"
				end
			else
				local FirstLineOfError = string.match(tostring(CompileError), "%w* ?:%d*: ?([^\n]*)\n")
				Log.Warn(
					`WARNING: {instance.ClassName} "{currentPathString}" failed to compile: {FirstLineOfError or "[Failed to parse compiler error]"}`
				)
				FailedCompilations += 1

				ClosureSourceLineCounts[RefId] = 1 -- Guaranteed 1 line; see below lol

				ClosureBindings[RefId] = function()
					return `function()error("[AOT COMPILER ERROR] {StringUtils.SerializeStringData(FirstLineOfError)}")end`
				end
			end
		end

		-- Add any properties
		local Properties = { [1] = instance.Name } -- For byte preservation (lol) the name is just set as the property index 1, and not "Name"

		if ClassName == "StringValue" then
			Properties.Value = instance.Value
		end

		-- The init script will assume the `Name` is the same as the `ClassName` if not included
		if instance.Name ~= ClassName then
			InstanceObject[3] = Properties
		end

		-- Recursively add children
		if next(children) then
			local ObjectChildren = {}

			for Child, ChildrenOfChild in children do
				local ChildObjectTree = CreateObjectTree(Child, ChildrenOfChild, `{currentPathString}.{Child.Name}`)
				if ChildObjectTree then
					table.insert(ObjectChildren, ChildObjectTree)
				end
			end

			InstanceObject[4] = ObjectChildren
		end

		return InstanceObject
	end

	for RealInstance, Children in ScrapedInstanceTree do
		local ChildObjectTree = CreateObjectTree(RealInstance, Children)

		if ChildObjectTree then
			table.insert(ObjectTree, ChildObjectTree)
		end
	end

	local LineOffsets = {}
	if LineDebugging then
		-- Where the first closure func start should be
		local CurrentLineOffset = ExtraLinesToOffset + InitialLineOffset

		for RefId, LineCount in ClosureSourceLineCounts do
			LineOffsets[RefId] = CurrentLineOffset
			CurrentLineOffset += LineCount
		end
	end

	-- Now we're done reading everything!
	local ReadEndTime = os.clock()
	RunIfVerbose(
		Log.Info,
		`Finished bundling model data in {string.format("%.4f", ReadEndTime - ReadStartTime)} (seconds)`
	)

	local Prettify = if MinifyCodegen == false then true else false

	local SerializedObjectTree = LuaEncode(ObjectTree, {
		Prettify = Prettify,
		StackLimit = math.huge,
	})

	local SerializedClosureBindings = LuaEncode(ClosureBindings, {
		Prettify = Prettify,
		FunctionsReturnRaw = true, -- For Script.Source function closures
	})

	local SerializedLineOffsets = if not LineDebugging
		then "nil"
		else LuaEncode(LineOffsets, {
			Prettify = Prettify,
		})

	local CodegenOutput = StringUtils.Replace(InitScriptTemplate, {
		Version = StringUtils.SerializeStringData(Version),
		EnvName = StringUtils.SerializeStringData(EnvName),
		ObjectTree = SerializedObjectTree,
		ClosureBindings = SerializedClosureBindings,
		LineOffsets = SerializedLineOffsets,
	})

	-- If there's a top-level init modulescript, we'll return it from the output's closure directly
	-- It's better to impl this all AoT!
	if #ModelRootChildren == 1 and ModelRootChildren[1].ClassName == "ModuleScript" then
		CodegenOutput ..= "\n-- AoT adjustment: Load init module (MainModule behavior)\nreturn LoadScript(RealObjectRoot:GetChildren()[1])"
	else
		for _, Ref in next, ModelRootChildren do
			if Ref.ClassName == "ModuleScript" and Ref.Name == "MainModule" then
				CodegenOutput ..= "\n-- AoT adjustment: Load init module (MainModule behavior)\nreturn LoadScript(RealObjectRoot.MainModule)"
				break
			end
		end
	end

	return CodegenOutput, FailedCompilations
end

return BundleModel
