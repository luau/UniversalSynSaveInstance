local insert = table.insert
local concat = table.concat

return function(markdown)
    local lines = {}
    for line in markdown:gmatch("[^\r\n]+") do
        insert(lines, line)
    end

    local result = {
        title = nil,
        description = nil,
        signature = nil,
        parameters = {}
    }

    local current = "header"
    local insideCodeblock = false
    local codeblockLanguage = nil
    local insideAdmonition = false
    local descriptionCaptured = false

    -- this is incredibly naive - look into writing a full lexer-ish/parser for the extractor instead later
    local sigCaptured = false
    local signature = {}

    for i = 1, #lines do
        local line = lines[i]

        if line:match("^!!!") then
            insideAdmonition = true
            goto continue
        elseif insideAdmonition then
            -- fixed: non-indented non-blank line should end the admonition
            if not line:match("^%s") and line:match("%S") then
                insideAdmonition = false
            else
                goto continue
            end
        end

        if line:match("^## Parameters") then
            current = "parameters"
        elseif line:match("^```") then
            if not insideCodeblock then
                -- open code block
                insideCodeblock = true
                codeblockLanguage = line:match("^```(%w+)")
            else
                -- closing code block
                insideCodeblock = false
                codeblockLanguage = nil
                sigCaptured = true
            end
        elseif line:match("^# ") and current == "header" then
            result.title = line:match("^#%s+`(.-)`") or line:match("^#%s+(.-)$")
        elseif current == "header" and not descriptionCaptured and line:match("%S") then
            result.description = line
            descriptionCaptured = true
        elseif insideCodeblock and codeblockLanguage == "luau" and not sigCaptured then
            insert(signature, line)
            -- if not result.signature then
            --     result.signature = line
            -- else
            --     result.signature = result.signature .. "\n" .. line
            -- end
        elseif current == "parameters" and line:match("|") then
            local param, desc = line:match("|%s*`.-luau%s+(.-)`%s*|%s*(.-)%s*|")
            if param and desc then
                result.parameters[param] = desc
            end
        end

        ::continue::
    end

    result.signature = concat(signature, "\n")

    return result
end
