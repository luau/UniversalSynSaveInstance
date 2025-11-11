--[[
rbxmSuite package for downloading and managing Roblox packages
https://github.com/richie0866/rbxm-suite
]]

export type Options = {
	runscripts: boolean?,
	deferred: boolean?,
	nocache: boolean?,
	nocirculardeps: boolean?,
	debug: boolean?,
	verbose: boolean?
}

export type rbxmSuite = {
	launch: (path: string, options: Options?) -> Instance,
	require: (module: LocalScript | ModuleScript) -> any,
	download: (repository: string, asset: string) -> string
}

local rbxmSuite = loadstring(game:HttpGetAsync("https://github.com/richie0866/rbxm-suite/releases/latest/download/rbxm-suite.lua"))() :: rbxmSuite

return rbxmSuite
