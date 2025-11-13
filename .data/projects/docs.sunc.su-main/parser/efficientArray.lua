--[[
This is obviously a very rough and quick implementation, and does not handle any clashes at all

Richy-Z@GitHub, https://richy.lol
]]

return function(arr)
    local constructed = {}

    for i, v in pairs(arr) do
        constructed[v] = true
    end

    return setmetatable(constructed, {
        __newindex = function()
            error("Addition of new items is not permitted")
        end,

        __index = function(tebel, key)
            if key == "contains" then
                return function(_, k)
                    return constructed[k] or false
                end
            end
        end
    })
end
