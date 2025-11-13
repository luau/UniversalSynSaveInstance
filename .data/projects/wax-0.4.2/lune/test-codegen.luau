-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")

local BundleModel = require("./lib/BundleModel")

local FilePath = "junk/testgen.lua"

local ModelCodegen = BundleModel({})
fs.writeFile(FilePath, ModelCodegen)
