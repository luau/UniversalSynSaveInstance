-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

type OptionsInput = { [string]: { string | number | boolean | nil } }
type OptionsOutput = { [string]: string | number | boolean | nil }

local process = require("@lune/process")

local Log = require("./Log")

local function ParseArgs(args: { string }, optionsTable: OptionsInput, usageMessage: string?): OptionsOutput
	local function ErrorExit()
		if usageMessage then
			print(`\n{usageMessage}`)
		end
		process.exit(1)
	end

	local OptionsOutput = {}

	for _, Arg in args do
		local Option, Value = string.match(Arg, "([%w%-_]+)=(.+)")

		if not Option then
			Log.Error(`Command argument given, "{Arg}" not in the proper \`option=value\` format, aborting..`)
			ErrorExit()
		end

		local OptionDetails = optionsTable[Option]

		if OptionDetails == nil then -- Then it isn't a defined arg
			Log.Error(`"{Option}" isn't a valid option"`)
			ErrorExit()
		end

		local OptionType = OptionDetails[1]

		if OptionType == "boolean" then
			Value = string.lower(Value)
			Value = if Value == "true" then true elseif Value == "false" then false else nil

			if Value == nil then
				Log.Error(`"{Value}" isn't a valid boolean type; expected "true" or "false"`)
				ErrorExit()
			end
		elseif OptionType == "number" then
			Value = tonumber(Value)
			if not Value then
				Log.Error(`Failed to convert given input "{Value}" to a number value`)
				ErrorExit()
			end
		end

		OptionsOutput[Option] = Value
	end

	for Option, Details in optionsTable do
		local DefaultValue = Details[2]
		local IsRequired = Details[3] or false

		if not OptionsOutput[Option] then
			if IsRequired then
				Log.Error(`Option "{Option}" required but not provided`)
				ErrorExit()
			end

			OptionsOutput[Option] = DefaultValue
		end
	end

	return OptionsOutput
end

return ParseArgs
