--!strict
--[=[
	@class Git
	GitHub API operations for releases and deployments.

	Provides authenticated HTTP operations to create releases, upload assets,
	and validate API keys. All network operations use exponential backoff retry
	for transient failures and 5xx errors.
]=]

-- Imports
local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")
local Process = require("@lune/process")

-- Maximum retry attempts for failed network requests (retries on 5xx and network errors)
local MAX_RETRIES = 3
-- Initial delay in seconds between retries (doubles after each attempt via exponential backoff)
local RETRY_DELAY = 2.0

-- Types
export type GitHubRelease = {
	id: number,
	tag_name: string,
	name: string,
	body: string,
	html_url: string,
	upload_url: string,
}

-- Module
local Git = {}

--[=[
	Retrieves GitHub API key from environment or .env file.

	Checks Process.env first, then falls back to reading .env file if present.

	@param name Environment variable name (defaults to "GITHUB_API_KEY")
	@return API key string, or nil if not found
]=]
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

--[=[
	Executes HTTP request with exponential backoff retry.

	Retries on network errors and 5xx status codes. Uses exponential backoff
	starting at RETRY_DELAY seconds, doubling after each attempt.

	@param config Request configuration for net.request
	@param maxRetries Maximum retry attempts (defaults to MAX_RETRIES)
	@return Response object, or nil and error message
]=]
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

--[=[
	Creates a new GitHub release.

	@param owner Repository owner username
	@param repo Repository name
	@param apiKey GitHub API key for authentication
	@param tag Git tag name for the release
	@param name Display name for the release
	@param body Release notes in markdown
	@param prerelease Whether this is a prerelease (defaults to false)
	@param draft Whether this is a draft release (defaults to false)
	@return GitHubRelease object, or nil and error message
]=]
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

--[=[
	Uploads a file asset to an existing GitHub release.

	@param owner Repository owner username
	@param repo Repository name
	@param apiKey GitHub API key for authentication
	@param releaseId Release ID from createRelease
	@param path Local file path to upload
	@param name Optional asset name (defaults to filename from path)
	@return True on success, or false and error message
]=]
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

--[=[
	Validates a GitHub API key by testing authentication.

	Makes a test request to /user endpoint to verify the key works.

	@param apiKey GitHub API key to validate
	@return True if valid, or false and error message
]=]
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

--[=[
	Checks if a release with the given tag already exists.

	@param owner Repository owner username
	@param repo Repository name
	@param apiKey GitHub API key for authentication
	@param tag Git tag name to check
	@return True if exists, false if not found, or nil and error message on failure
]=]
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
