--!strict
--[=[
	@class GitUtils
	GitHub API utilities for release deployment.

	Provides functions for creating GitHub releases, uploading assets, and
	reading API keys from environment or .env files. Includes retry logic
	with exponential backoff for network resilience.

	@usage
	```lua
	local GitUtils = require("./lib/git-utils")
	local apiKey = GitUtils.getApiKey()
	local releaseId, err = GitUtils.createRelease(config, "v1.0.0", "Release notes")
	```
]=]

-- Imports
local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")
local Process = require("@lune/process")

-- Network retry configuration
local MAX_RETRIES: number = 3
local INITIAL_RETRY_DELAY: number = 2.0

-- Environment file location for API keys
local ENV_FILE_PATH: string = ".env"

-- Types
export type GitHubRelease = {
	id: number,
	tag_name: string,
	name: string,
	body: string,
	html_url: string,
	upload_url: string,
}

export type ApiError = {
	message: string,
	statusCode: number?,
}

-- Module
local GitUtils = {}

--[=[
	Reads the GitHub API key from environment variable or .env file.

	Checks environment variable first, then falls back to .env file. Strips
	quotes from .env values if present.

	@param envVarName Custom variable name (default: "GITHUB_API_KEY")
	@return API key string, or nil if not found
]=]
function GitUtils.getApiKey(envVarName: string?): string?
	local varName: string = envVarName or "GITHUB_API_KEY"

	local envKey: string? = Process.env[varName]
	if envKey and envKey ~= "" then
		return envKey
	end

	if not fs.isFile(ENV_FILE_PATH) then
		return nil
	end

	local envContents: string = fs.readFile(ENV_FILE_PATH)
	for line in envContents:gmatch("[^\r\n]+") do
		local key: string?, val: string? = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
		if key == varName and val then
			val = val:gsub('^["\'](.-)["\'"]$', "%1")
			return val
		end
	end

	return nil
end

--[=[
	Performs an HTTP request with retry logic and exponential backoff.

	Retries on network errors and 5xx server errors using exponential backoff
	starting at 2s. Client errors (4xx) are not retried.

	@param config Request configuration (url, method, headers, body)
	@param maxRetries Maximum retry attempts (default: 3)
	@return Response, or nil and error message on failure
]=]
function GitUtils.requestWithRetry(config: any, maxRetries: number?): (any?, string?)
	local retriesLeft: number = maxRetries or MAX_RETRIES
	local delay: number = INITIAL_RETRY_DELAY

	while retriesLeft >= 0 do
		local success: boolean, response: any = pcall(net.request, config)

		if success then
			if response.statusCode and response.statusCode >= 500 and retriesLeft > 0 then
				task.wait(delay)
				delay *= 2
				retriesLeft -= 1
				continue
			end

			return response, nil
		elseif retriesLeft > 0 then
			task.wait(delay)
			delay *= 2
			retriesLeft -= 1
			continue
		else
			return nil, `Network error: {response}`
		end
	end

	return nil, "Max retries exceeded"
end

--[=[
	Creates a GitHub release.

	Posts release data to GitHub API with retry logic. Returns full release
	object including ID needed for asset uploads.

	@param owner Repository owner username
	@param repo Repository name
	@param apiKey GitHub API authentication token
	@param tagName Git tag for release (e.g., "v1.0.0")
	@param releaseName Human-readable release title
	@param body Markdown release notes
	@param prerelease Mark as prerelease (default: false)
	@param draft Mark as draft (default: false)
	@return GitHubRelease with id and upload_url, or nil and error
]=]
function GitUtils.createRelease(
	owner: string,
	repo: string,
	apiKey: string,
	tagName: string,
	releaseName: string,
	body: string,
	prerelease: boolean?,
	draft: boolean?
): (GitHubRelease?, string?)
	local url: string = `https://api.github.com/repos/{owner}/{repo}/releases`

	local requestBody = {
		tag_name = tagName,
		name = releaseName,
		body = body,
		draft = draft or false,
		prerelease = prerelease or false,
	}

	local response: any?, err: string? = GitUtils.requestWithRetry({
		url = url,
		method = "POST",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["Content-Type"] = "application/json",
			["User-Agent"] = "UniversalSynSaveInstance-Pipeline",
		},
		body = serde.encode("json", requestBody),
	})

	if not response then
		return nil, err
	end

	if not response.ok then
		local errorMsg: string = `HTTP {response.statusCode}: {response.statusMessage}`
		if response.body and response.body ~= "" then
			local parseSuccess: boolean, parsed: any = pcall(serde.decode, "json", response.body)
			if parseSuccess and parsed.message then
				errorMsg = `{errorMsg} - {parsed.message}`
			end
		end
		return nil, errorMsg
	end

	local releaseData: GitHubRelease = serde.decode("json", response.body)
	return releaseData, nil
end

--[=[
	Uploads an asset file to an existing GitHub release.

	Reads file and posts to GitHub uploads API with retry logic. Asset name
	defaults to the file basename if not specified.

	@param owner Repository owner username
	@param repo Repository name
	@param apiKey GitHub API authentication token
	@param releaseId Numeric release ID from createRelease
	@param filePath Path to file to upload as asset
	@param assetName Optional custom display name (default: basename)
	@return True on success, false and error message on failure
]=]
function GitUtils.uploadAsset(
	owner: string,
	repo: string,
	apiKey: string,
	releaseId: number,
	filePath: string,
	assetName: string?
): (boolean, string?)
	if not fs.isFile(filePath) then
		return false, `File not found: {filePath}`
	end

	local fileName: string = assetName or filePath:match("^.+[\\/](.+)$") or filePath
	local url: string = `https://uploads.github.com/repos/{owner}/{repo}/releases/{releaseId}/assets?name={fileName}`

	local fileContent: string = fs.readFile(filePath)

	local response: any?, err: string? = GitUtils.requestWithRetry({
		url = url,
		method = "POST",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["Content-Type"] = "application/octet-stream",
			["User-Agent"] = "UniversalSynSaveInstance-Pipeline",
		},
		body = fileContent,
	})

	if not response then
		return false, err
	end

	if not response.ok then
		local errorMsg: string = `HTTP {response.statusCode}: {response.statusMessage}`
		if response.body and response.body ~= "" then
			local parseSuccess: boolean, parsed: any = pcall(serde.decode, "json", response.body)
			if parseSuccess and parsed.message then
				errorMsg = `{errorMsg} - {parsed.message}`
			end
		end
		return false, errorMsg
	end

	return true, nil
end

--[=[
	Validates a GitHub API key by making a test request.

	@param apiKey The API key to validate
	@return True if valid, or false and error message
]=]
function GitUtils.validateApiKey(apiKey: string): (boolean, string?)
	local response: any?, err: string? = GitUtils.requestWithRetry({
		url = "https://api.github.com/user",
		method = "GET",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["User-Agent"] = "UniversalSynSaveInstance-Pipeline",
		},
	})

	if not response then
		return false, err
	end

	if not response.ok then
		if response.statusCode == 401 then
			return false, "Invalid API key"
		else
			return false, `HTTP {response.statusCode}: {response.statusMessage}`
		end
	end

	return true, nil
end

--[=[
	Checks if a release with the given tag already exists.

	@param owner Repository owner
	@param repo Repository name
	@param apiKey GitHub API key
	@param tagName Tag to check
	@return True if exists, false if not, or nil and error message on failure
]=]
function GitUtils.releaseExists(owner: string, repo: string, apiKey: string, tagName: string): (boolean?, string?)
	local url: string = `https://api.github.com/repos/{owner}/{repo}/releases/tags/{tagName}`

	local response: any?, err: string? = GitUtils.requestWithRetry({
		url = url,
		method = "GET",
		headers = {
			["Authorization"] = `Bearer {apiKey}`,
			["User-Agent"] = "UniversalSynSaveInstance-Pipeline",
		},
	})

	if not response then
		return nil, err
	end

	if response.statusCode == 404 then
		return false, nil
	end

	if not response.ok then
		return nil, `HTTP {response.statusCode}: {response.statusMessage}`
	end

	return true, nil
end

return GitUtils
