-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local process = require("@lune/process")

local Log = require("./Log")

local function Run(
	command: string,
	args: { string }?,
	directRun: boolean?,
	errorHandler: (string?) -> ()?
): process.ExecResult
	local Args = args or {}
	local DirectRun = if directRun == nil then false else directRun

	if not DirectRun then
		if #Args == 0 then
			Log.Info(`> {command}`)
		else
			Log.Info(`> {command} {table.concat(Args, " ")}`)
		end
	end

	local Result = process.exec(command, args, {
		shell = if process.os ~= "windows" then true else nil,
		stdio = if DirectRun then "default" else "inherit",
	})

	if not Result.ok and errorHandler then
		errorHandler(`Command above failed with status code {Result.code}`)
	end

	return Result
end

return Run
