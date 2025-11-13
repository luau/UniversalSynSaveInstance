-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local stdio = require("@lune/stdio")

local ANSI = {
	Reset = stdio.color("reset") .. stdio.style("reset"),

	Red = stdio.color("red"),
	Yellow = stdio.color("yellow"),

	Bold = stdio.style("bold"),
}

local Log = {}

function Log.Info(message: string, ending: string?)
	ending = ending or "\n"
	stdio.write(`∙ {message}{ending}`)
end

function Log.Error(message: string, ending: string?)
	ending = ending or "\n"
	stdio.ewrite(`{ANSI.Bold .. ANSI.Red}∙ {message}{ANSI.Reset}{ending}`)
end

function Log.Warn(message: string, ending: string?)
	ending = ending or "\n"
	stdio.write(`{ANSI.Bold .. ANSI.Yellow}∙ {message}{ANSI.Reset}{ending}`)
end

function Log.InternalError(message: string, ending: string?)
	Log.Error("[INTERNAL ERROR] " .. message, ending)
end

return Log
