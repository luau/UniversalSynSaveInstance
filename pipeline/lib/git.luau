--!strict
--[=[
	@class Git
	GitHub API operations.
]=]

local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")
local Process = require("@lune/process")

local MAX_RETRIES = 3
local RETRY_DELAY = 2.0

export type GitHubRelease = {
	id: number,
	tag_name: string,
	name: string,
	body: string,
	html_url: string,
	upload_url: string,
}

local Git = {}

function Git.getApiKey(name: string?): string?
	local key = name or "GITHUB_API_KEY"

	if Process.env[key] then
		return Process.env[key]
	end

	if not fs.isFile(".env") then
		return
	end

	for line in fs.readFile(".env"):gmatch("[^\r\n]+") do
		local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
		if k == key and v then
			return v:gsub('^["\'](.-)["\'"]$', "%1")
		end
	end
end

local function retry(config: any, maxRetries: number?): (any?, string?)
	local left = maxRetries or MAX_RETRIES
	local delay = RETRY_DELAY

	while left >= 0 do
		local ok, res = pcall(net.request, config)

		if ok then
			if res.statusCode and res.statusCode >= 500 and left > 0 then
				task.wait(delay)
				delay *= 2
				left -= 1
				continue
			end
			return res
		elseif left > 0 then
			task.wait(delay)
			delay *= 2
			left -= 1
			continue
		else
			return nil, `Network error: {res}`
		end
	end

	return nil, "Max retries exceeded"
end

function Git.createRelease(
	owner: string,
	repo: string,
	apiKey: string,
	tag: string,
	name: string,
	body: string,
	prerelease: boolean?,
	draft: boolean?
): (GitHubRelease?, string?)
	local res, err = retry({
		url = `https://api.github.com/repos/{owner}/{repo}/releases`,
		method = "POST",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["Content-Type"] = "application/json",
			["User-Agent"] = "Pipeline",
		},
		body = serde.encode("json", {
			tag_name = tag,
			name = name,
			body = body,
			draft = draft or false,
			prerelease = prerelease or false,
		}),
	})

	if not res then
		return nil, err
	end

	if not res.ok then
		local msg = `HTTP {res.statusCode}`
		if res.body then
			local ok, parsed = pcall(serde.decode, "json", res.body)
			if ok and parsed.message then
				msg ..= `: {parsed.message}`
			end
		end
		return nil, msg
	end

	return serde.decode("json", res.body)
end

function Git.uploadAsset(
	owner: string,
	repo: string,
	apiKey: string,
	releaseId: number,
	path: string,
	name: string?
): (boolean, string?)
	if not fs.isFile(path) then
		return false, `Not found: {path}`
	end

	local fileName = name or path:match("^.+[\\/](.+)$") or path

	local res, err = retry({
		url = `https://uploads.github.com/repos/{owner}/{repo}/releases/{releaseId}/assets?name={fileName}`,
		method = "POST",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["Content-Type"] = "application/octet-stream",
			["User-Agent"] = "Pipeline",
		},
		body = fs.readFile(path),
	})

	if not res then
		return false, err
	end

	if not res.ok then
		local msg = `HTTP {res.statusCode}`
		if res.body then
			local ok, parsed = pcall(serde.decode, "json", res.body)
			if ok and parsed.message then
				msg ..= `: {parsed.message}`
			end
		end
		return false, msg
	end

	return true
end

function Git.validateApiKey(apiKey: string): (boolean, string?)
	local res, err = retry({
		url = "https://api.github.com/user",
		method = "GET",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["User-Agent"] = "Pipeline",
		},
	})

	if not res then
		return false, err
	end

	if not res.ok then
		return false, if res.statusCode == 401 then "Invalid key" else `HTTP {res.statusCode}`
	end

	return true
end

function Git.releaseExists(owner: string, repo: string, apiKey: string, tag: string): (boolean?, string?)
	local res, err = retry({
		url = `https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}`,
		method = "GET",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["User-Agent"] = "Pipeline",
		},
	})

	if not res then
		return nil, err
	end

	if res.statusCode == 404 then
		return false
	end

	if not res.ok then
		return nil, `HTTP {res.statusCode}`
	end

	return true
end

return Git
