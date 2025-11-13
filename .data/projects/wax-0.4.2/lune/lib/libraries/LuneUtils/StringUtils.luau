-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local StringUtils = {}

function StringUtils.FileType(filePath: string): string?
	local Match = string.match(filePath, ".%.([^%.]+)$")
	if Match then
		Match = string.lower(Match)
	end

	return Match
end

function StringUtils.FileNameFromPath(filePath: string): string?
	return string.match(filePath, "[^/\\]+$")
end

function StringUtils.FileNameWithoutExtension(fileName: string, onlyTheLastDot: boolean?): string?
	onlyTheLastDot = if onlyTheLastDot == nil then true else onlyTheLastDot

	if onlyTheLastDot then
		return string.match(fileName, "^(.+)%.")
	else
		return string.match(fileName, "^%.?[^%.]+")
	end
end

function StringUtils.FilePathWithoutExtension(filePath: string, onlyTheLastDot: boolean?): string?
	local FilePathDirectory = StringUtils.DirectoryOfFilePath(filePath)
	local FileName = StringUtils.FileNameFromPath(filePath)

	if not FilePathDirectory or not FileName then
		return
	end

	local FileNameStripped = StringUtils.FileNameWithoutExtension(FileName, onlyTheLastDot)
	if not FileNameStripped then
		return
	end

	return FilePathDirectory .. FileNameStripped
end

function StringUtils.DirectoryOfFilePath(filePath: string): string?
	local Directory = string.match(filePath, "^.*[/\\]")
	if not Directory or Directory == "" then
		Directory = "./"
	end

	return Directory
end

function StringUtils.SplitStringByPattern(originalString: string, pattern: string)
	local SplitArray = {}
	for Match in string.gmatch(originalString, pattern) do
		table.insert(SplitArray, Match)
	end

	return SplitArray
end

function StringUtils.SplitFilePath(filePath: string)
	return StringUtils.SplitStringByPattern(filePath, "([^/\\]+)[/\\]?")
end

function StringUtils.LineCount(input: string): number
	local Lines = 1
	for _ in string.gmatch(input, "\n") do
		Lines += 1
	end

	return Lines
end

function StringUtils.Replace(inputString: string, replacements: { [string]: string }): string
	return string.gsub(inputString, "${([A-Za-z_][A-Za-z0-9_]*)}", replacements)
end

-- Based from https://github.com/regginator/LuaEncode/blob/995daa18266dab2e2b94f43189d6eadb46f82c79/src/LuaEncode.lua#L76-L108
do
	-- These are control characters to be encoded in a certain way in Lua rather than just a byte
	-- escape (e.g. "\n" -> "\10")
	local SpecialCharacters = {
		['"'] = '\\"', -- Double-Quote
		["\\"] = "\\\\", -- (Literal) Backslash
		-- Special ASCII control char codes
		["\a"] = "\\a", -- Bell; ASCII #7
		["\b"] = "\\b", -- Backspace; ASCII #8
		["\t"] = "\\t", -- Horizontal-Tab; ASCII #9
		["\n"] = "\\n", -- Newline; ASCII #10
		["\v"] = "\\v", -- Vertical-Tab; ASCII #11
		["\f"] = "\\f", -- Form-Feed; ASCII #12
		["\r"] = "\\r", -- Carriage-Return; ASCII #13
	}

	-- We need to assign all extra normal byte escapes for runtime optimization
	for Index = 0, 255 do
		local Character = string.char(Index)

		if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
			SpecialCharacters[Character] = "\\" .. Index
		end
	end

	function StringUtils.SerializeStringData(inputString: string): string
		-- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
		-- issue. See: https://stackoverflow.com/a/22962409
		local Serialized = string.gsub(inputString, '[%z\\"\1-\31\127-\255]', SpecialCharacters)
		return Serialized
	end
end

return StringUtils
