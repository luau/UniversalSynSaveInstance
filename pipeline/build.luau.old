--!nocheck
--!nolint LocalUnused

--// Imports
local io = require("@lune/stdio")
local fs = require("@lune/fs")
local Process = require("@lune/process")
local serde = require("@lune/serde")
local net = require("@lune/net")
local dateTime = require("@lune/datetime")

--// Variables
local config = serde.decode("json", fs.readFile(Process.args[1]))

local buildConfigs = config.buildConfigs

local frame
local build
local buildConfig
local buildVers

local composerMarkers = {
	["__COMPOSER.Insert(__COMPOSER.build)"] = function()
		return build or ""
	end,
	["__COMPOSER.Insert(__COMPOSER.genDate)"] = function()
		return string.format("%q", dateTime.now():toIsoDate() or "")
	end,
	["__COMPOSER.Insert(__COMPOSER.cfg)"] = function()
		return string.format("%q", buildConfig or "")
	end,
	["__COMPOSER.Insert(__COMPOSER.vers)"] = function()
		return string.format("%q", buildVers or "")
	end,
}

--// Constants
local RELEASE_BODY = (Process.env.TEMP or Process.env.TMP) .. "/RELEASE_BODY.md"

--// Functions
local function getBaseName(path)
	return path:match("^.+[\\/](.+)$") or path
end

local function getGhKey()
	local envPath = ".env"
	if not fs.isFile(envPath) then
		return nil
	end

	for line in fs.readFile(envPath):gmatch("[^\r\n]+") do
		local key, val = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
		if key == "GITHUB_API_KEY" and val then
			val = val:gsub('^"(.*)"$', "%1")
			val = val:gsub("^'(.*)'$", "%1")
			return val
		end
	end
	return nil
end

--// Compose
local parsedConfigs = {}

for _, v in pairs(buildConfigs) do
	table.insert(parsedConfigs, v.name)
end

local selected = io.prompt("select", "Build configuration", parsedConfigs)
buildConfig = buildConfigs[selected].name
local configOptions = buildConfigs[selected]

buildVers = configOptions.promptVersion and io.prompt("text", "Build version (vMAJOR.MINOR.PATCH)") or "v0.0.0"

local srcResult = Process.exec("darklua", {
	"process",
	configOptions.input,
	configOptions.output,
	"-c",
	configOptions.darkluaConfig,
})

if not srcResult.ok then
	print(srcResult.stderr)
	return
end

build = fs.readFile(configOptions.output)
frame = fs.readFile(configOptions.frame)

for marker, replacement in pairs(composerMarkers) do
	frame = frame:gsub(marker:gsub("([%%%+%-%*%?%[%]%^%$%(%)%%])", "%%%1"), function()
		return replacement()
	end)
end

fs.writeFile(configOptions.output, frame)

print("Build complete: " .. configOptions.output)

if config.openComposedOutput and Process.os == "windows" then
	Process.exec("powershell", {
		"-ExecutionPolicy",
		"Bypass",
		"-NoProfile",
		"-Command",
		`code '{configOptions.output}'`,
	})
end

--// Deploy
if configOptions.promptDeploy and config.deployment.enabled then
	local ghCfg = config.deployment.github

	if io.prompt("confirm", "Do you want to distribute this build publicly?") then
		if ghCfg and ghCfg.enabled == true then
			fs.writeFile(RELEASE_BODY, `# {ghCfg.repo} {buildVers}`)

			if Process.os == "windows" then
				Process.exec("powershell", {
					"-ExecutionPolicy",
					"Bypass",
					"-NoProfile",
					"-Command",
					`code '{RELEASE_BODY}'`,
				})
			end

			if io.prompt("confirm", "Add release notes, and confirm when done") then
				local response = net.request({
					url = string.format("https://api.github.com/repos/%s/%s/releases", ghCfg.owner, ghCfg.repo),
					method = "POST",
					headers = {
						["Authorization"] = "Bearer " .. (getGhKey() or ghCfg.apiKey),
						["Content-Type"] = "application/json",
					},
					body = serde.encode("json", {
						tag_name = buildVers,
						name = `{buildConfig} {buildVers}`,
						body = fs.isFile(RELEASE_BODY) and fs.readFile(RELEASE_BODY) or "",
						draft = false,
						prerelease = configOptions.prerelease,
					}),
				})

				if response.ok then
					print("Deployment successful: " .. response.statusMessage)
					local releaseData = serde.decode("json", response.body)
					local releaseId = releaseData.id
					if releaseId and fs.isFile(configOptions.output) then
						local assetName = getBaseName(configOptions.output)
						local uploadUrl = string.format(
							"https://uploads.github.com/repos/%s/%s/releases/%s/assets?name=%s",
							ghCfg.owner,
							ghCfg.repo,
							tostring(releaseId),
							assetName
						)
						local fileContent = fs.readFile(configOptions.output)
						local uploadResp = net.request({
							url = uploadUrl,
							method = "POST",
							headers = {
								["Authorization"] = "Bearer " .. (getGhKey() or ghCfg.apiKey),
								["Content-Type"] = "application/octet-stream",
							},
							body = fileContent,
						})
						if uploadResp.ok then
							print("Asset uploaded: " .. assetName)
						else
							print("Asset upload failed: " .. uploadResp.statusMessage)
							print(uploadResp.body)
						end
					else
						print("Could not upload asset: release id or file missing")
					end
				else
					print("Deployment failed: " .. response.statusMessage)
					print(response.body)
					if response.body:find("Bad credentials") then
						warn("❓ Did you set up github deployment in the pcmp configuration file or .env?")
					end
				end
			end

			if fs.isFile(RELEASE_BODY) then
				fs.removeFile(RELEASE_BODY)
			end
		end
	end
end
