local insert = table.insert
local concat = table.concat

return function(markdown)
    local lines = {}
    for line in markdown:gmatch("[^\r\n]+") do
        insert(lines, line)
    end

    local constructed = {}
    local insideBlock = false
    local collect = false

    for i = 1, #lines do
        local line = lines[i]

        if line:match("^!!!") then
            insideBlock = true
        elseif insideBlock and (line:match("^%s*$") or not line:match("^%s")) then
            insideBlock = false
        end

        if not collect then
            if line:match("^# ") then
                -- found main header so skip mkdocs block if present
                local j = i + 1
                while j <= #lines do
                    local next_line = lines[j]
                    if next_line:match("^!!!") then
                        insideBlock = true
                        j = j + 1
                        -- skip the mkdocs block properly
                        while j <= #lines do
                            local block_line = lines[j]
                            if block_line:match("^%s*$") or not block_line:match("^%s") then
                                insideBlock = false
                                break
                            end
                            j = j + 1
                        end
                    elseif next_line:match("%S") then
                        collect = true
                        i = j - 1
                        break
                    end
                    j = j + 1
                end
            end
        elseif not insideBlock then
            if line:match("^%-%-%-$") or line:match("^## ") then
                break
            end
            insert(constructed, line)
        end
    end

    return concat(constructed, "\n")
end
