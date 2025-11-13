local b = require("./b")
local c = require("./c")
local d = require("./d")

local Package1 = require("@pkg/Package1")

return {
    b = b,
    c = c,
    d = d,
    Package1 = Package1,
}
