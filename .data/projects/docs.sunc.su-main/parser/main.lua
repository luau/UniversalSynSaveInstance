local fs = require("fs")
local json = require("json")

local exclusions = require("exclusions")

local extractIndex = require("indexExtractor")
local extractDoc = require("docExtractor")

local function printf(str, ...)
    p(string.format(str, ...)) ---@diagnostic disable-line: undefined-global
end

local tree = {}
for name, t in fs.scandirSync("../docs") do
    if t == "directory" and not exclusions:contains(name) then
        local library = {}

        for funcName, fType in fs.scandirSync("../docs/" .. name) do
            local formatted = ("../docs/%s/%s"):format(name, funcName)
            if fType ~= "directory" then
                library[funcName:gsub(".md", "")] = fs.readFileSync(formatted)
            else
                local exists, err = fs.readFileSync(formatted .. "/README.md")
                if not exists then
                    printf(
                        "assumed that directory %s inside of %s (%s/%s) was a function doc with a README.md, but none was found: %s",
                        funcName, name, name, funcName, err)
                else
                    -- filtergc is the only func which uses an entire directory so we are safe (for now),
                    -- until another big function comes around and requires its own directory
                    library[funcName] = fs.readFileSync(formatted .. "/README.md")
                end
            end
        end

        tree[name] = library
    end
end

local function clean(md)
    md = md:gsub("%*%*(.-)%*%*", "%1") --bold
    md = md:gsub("%*(.-)%*", "%1")     -- italic
    md = md:gsub("__(.-)__", "%1")     -- underline
    md = md:gsub("_(.-)_", "%1")       -- italic again but with underscores
    md = md:gsub("`(.-)`", "%1")       -- inline code
    md = md:gsub("%[(.-)%]%b()", "%1") -- markdown links

    return md
end

local function normaliseSnippets(md)
    return md:gsub("`#!luau%s+(.-)`", "`%1`")
end

local function normaliseUrls(md, libname)
    -- "../x/y.md" -> "https://docs.sunc.su/x/y"
    md = md:gsub("%.%.%/(.-)%.md", "https://docs.sunc.su/%1")
    -- "./x.md" with "https://docs.sunc.su/<libname>/x"
    md = md:gsub("%./(.-)%README.md", "https://docs.sunc.su/" .. libname .. "/%1")
    md = md:gsub("%./(.-)%.md", "https://docs.sunc.su/" .. libname .. "/%1")

    return md
end

--[[
functions to be cautious of (due to unique doc format) when parsing:

-- messy solutions
request -- done: added compatibility in doc extractor
getgc -- done: same above
filtergc -- done: same above + initial documentation scanner which collected markdown files
-- now recognises when funcs are an entire directory (assuming README.md exists) instead of just one file

-- TODO:
Signals/Connection
WebSocket library
remove things like annotations, e.g. "-- (1)" or maybe even parse them?!
Drawing lib functions except dont count readme

uhh more i forgor
]]

local bot = {}
for libname, library in pairs(tree) do
    bot[libname] = {}

    for func, doc in pairs(library) do
        if func == "README" then
            local description = extractIndex(doc)
            bot[libname]._description = normaliseUrls(normaliseSnippets(description), libname)
            bot[libname]._link = "https://docs.sunc.su/" .. libname
        elseif func == "WebSocket" then
            -- do nothing, we will parse this separately later
        elseif libname == "Signals" and func == "Connection" then
            -- also do nothing, will parse this later
        else
            local a = extractDoc(doc)

            a.description = normaliseUrls(normaliseSnippets(a.description), libname)

            for param, desc in pairs(a.parameters) do
                a.parameters[param] = normaliseUrls(normaliseSnippets(desc), libname)
            end

            a.link = string.format("https://docs.sunc.su/%s/%s", libname, func)

            bot[libname][func] = a
        end
    end
end

fs.mkdirpSync("../docs/built-info") -- old directory, now deprecated
fs.mkdirpSync("../docs/api")

local bot_json = json.encode(bot, { indent = true })
fs.writeFileSync("../docs/api/jumbo.json", bot_json)

local viewer = {}

for _, lib in pairs(bot) do
    for k, func in pairs(lib) do
        if k ~= "_description" and k ~= "_link" then
            viewer[func.title or ""] = clean(func.description or "")
        end
    end
end

viewer[""] = nil

local viewer_json = json.encode(viewer, { indent = true })
-- TODO: get the built-info directory ready for DEPRECATION
fs.writeFileSync("../docs/built-info/viewer.json", viewer_json) -- old
fs.writeFileSync("../docs/api/mini.json", viewer_json)




-- build the api page
print("Building API page...")

local http = require("coro-http")
require("string-extensions") -- Richy-Z/string-extensions

local res, body = http.request("GET", "https://sunc.su/_documentationAPI-preprocess.txt")
if not (res and res.code == 200 and body) then
    p("FAILED to retrieveAPI homepage!!!")
    os.exit(1)
end

local analytics = fs.readFileSync("../overrides/partials/integrations/analytics/custom.html")
---@diagnostic disable-next-line: undefined-field
body = body:gsub(string.deregexify("<numelon-plstrk></numelon-plstrk>"), analytics)

fs.writeFileSync("../docs/api/index.html", body)

print("FINISHED EVERYTHING YIPPEEE")
