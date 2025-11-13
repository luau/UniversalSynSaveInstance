--!strict
--[=[
	@class Deployment
	GitHub release deployment stage.

	Creates GitHub releases and uploads build artifacts with interactive
	release note editing. Includes validation, confirmation prompts, and
	comprehensive error handling with retry logic.

	@usage
	```lua
	local DeploymentStage = require("./stages/deployment-stage")
	local result = DeploymentStage.deploy(deployConfig, version, outputPath)
	```
]=]

-- Imports
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local GitUtils = require("../lib/git-utils")
local FsUtils = require("../lib/fs-utils")
local Config = require("../lib/config")

-- Constants
local RELEASE_BODY_FILE: string = (Process.env.TEMP or Process.env.TMP or "/tmp") .. "/RELEASE_BODY.md"

-- Types
export type DeployResult = {
	success: boolean,
	releaseUrl: string?,
	error: string?,
	duration: number,
}

-- Module
local Deployment = {}

--[=[
	Opens a file in the user's editor and waits for confirmation.

	On Windows, launches editor via PowerShell. On other platforms, displays
	file path for manual editing.

	@param filePath Path to file to edit
	@param editor Editor command (default: "code")
	@return True if user confirmed, false if cancelled
]=]
local function editFileInteractive(filePath: string, editor: string?): boolean
	local editorCmd: string = editor or "code"

	if Process.os == "windows" then
		local result = Process.exec("powershell", {
			"-ExecutionPolicy",
			"Bypass",
			"-NoProfile",
			"-Command",
			`{editorCmd} '{filePath}'`,
		})

		if not result.ok then
			Logger.warn(`Failed to open {editorCmd}: {result.stderr}`)
		end
	else
		Logger.info(`Edit release notes at: {filePath}`)
	end

	return stdio.prompt("confirm", "Confirm when release notes are ready")
end

--[=[
	Deploys a build to GitHub releases.

	Creates release, uploads artifact, and returns URL. In interactive mode,
	allows editing release notes before publishing.

	@param deployConfig Deployment configuration with GitHub settings
	@param version Build version tag (e.g., "v1.0.0")
	@param configName Build configuration name
	@param outputPath Path to build artifact to upload
	@param ciMode Skip prompts if true (default: false)
	@return DeployResult with success, release URL, duration
]=]
function Deployment.deploy(
	deployConfig: Config.DeploymentConfig,
	version: string,
	configName: string,
	outputPath: string,
	ciMode: boolean?
): DeployResult
	local startTime: number = DateTime.now().unixTimestampMillis
	local isCiMode: boolean = ciMode or false

	if not deployConfig.github then
		return {
			success = false,
			releaseUrl = nil,
			error = "GitHub config missing",
			duration = 0,
		}
	end

	local githubConfig: Config.GitHubConfig = deployConfig.github

	local apiKey: string? = GitUtils.getApiKey(githubConfig.apiKeyEnv)
	if not apiKey then
		return {
			success = false,
			releaseUrl = nil,
			error = `API key not found (env: {githubConfig.apiKeyEnv or "GITHUB_API_KEY"})`,
			duration = 0,
		}
	end

	if not FsUtils.isReadableFile(outputPath) then
		return {
			success = false,
			releaseUrl = nil,
			error = `Output not found: {outputPath}`,
			duration = 0,
		}
	end

	-- Prompt for confirmation in interactive mode
	if not isCiMode then
		local confirmed: boolean = stdio.prompt("confirm", `Create GitHub release for {version}?`)
		if not confirmed then
			return {
				success = false,
				releaseUrl = nil,
				error = "Deployment cancelled by user",
				duration = DateTime.now().unixTimestampMillis - startTime,
			}
		end
	end

	-- Prepare release notes
	local releaseBody: string = `# {githubConfig.repo} {version}\n\nBuild configuration: {configName}\nBuild date: {DateTime.now():toIsoDate()}\n\n## Changes\n\n`

	if not isCiMode then
		-- Write initial release notes and allow editing
		fs.writeFile(RELEASE_BODY_FILE, releaseBody)

		local editConfirmed: boolean = editFileInteractive(RELEASE_BODY_FILE, nil)
		if not editConfirmed then
			-- Clean up and cancel
			if fs.isFile(RELEASE_BODY_FILE) then
				fs.removeFile(RELEASE_BODY_FILE)
			end
			return {
				success = false,
				releaseUrl = nil,
				error = "Release note editing cancelled",
				duration = DateTime.now().unixTimestampMillis - startTime,
			}
		end

		-- Read edited release notes
		if fs.isFile(RELEASE_BODY_FILE) then
			releaseBody = fs.readFile(RELEASE_BODY_FILE)
		end
	end

	-- Check if release already exists
	Logger.verbose(`Checking if release {version} already exists...`)
	local exists: boolean?, existsErr: string? = GitUtils.releaseExists(
		githubConfig.owner,
		githubConfig.repo,
		apiKey,
		version
	)

	if exists == nil then
		return {
			success = false,
			releaseUrl = nil,
			error = `Failed to check existing releases: {existsErr}`,
			duration = DateTime.now().unixTimestampMillis - startTime,
		}
	end

	if exists then
		return {
			success = false,
			releaseUrl = nil,
			error = `Release {version} already exists`,
			duration = DateTime.now().unixTimestampMillis - startTime,
		}
	end

	-- Create release
	Logger.detail(`Creating release: {version}`)
	local release: GitUtils.GitHubRelease?, releaseErr: string? = GitUtils.createRelease(
		githubConfig.owner,
		githubConfig.repo,
		apiKey,
		version,
		`{configName} {version}`,
		releaseBody,
		deployConfig.prerelease,
		false -- not a draft
	)

	if not release then
		-- Clean up temp file
		if fs.isFile(RELEASE_BODY_FILE) then
			fs.removeFile(RELEASE_BODY_FILE)
		end

		return {
			success = false,
			releaseUrl = nil,
			error = `Failed to create release: {releaseErr}`,
			duration = DateTime.now().unixTimestampMillis - startTime,
		}
	end

	-- Upload asset
	local assetName: string = FsUtils.getBaseName(outputPath)
	Logger.detail(`Uploading asset: {assetName}`)

	local uploadSuccess: boolean, uploadErr: string? = GitUtils.uploadAsset(
		githubConfig.owner,
		githubConfig.repo,
		apiKey,
		release.id,
		outputPath,
		assetName
	)

	-- Clean up temp file
	if fs.isFile(RELEASE_BODY_FILE) then
		fs.removeFile(RELEASE_BODY_FILE)
	end

	if not uploadSuccess then
		Logger.warn(`Release created but asset upload failed: {uploadErr}`)
		Logger.warn(`You may need to manually upload the asset to: {release.html_url}`)
	end

	local duration: number = DateTime.now().unixTimestampMillis - startTime

	return {
		success = true,
		releaseUrl = release.html_url,
		error = nil,
		duration = duration,
	}
end

--[=[
	Validates deployment configuration and API key availability.

	Checks GitHub config presence and validates API key by testing authentication.

	@param deployConfig Deployment configuration to validate
	@return True if ready, false and error message otherwise
]=]
function Deployment.validate(deployConfig: Config.DeploymentConfig): (boolean, string?)
	if not deployConfig.github then
		return false, "GitHub config missing"
	end

	local apiKey: string? = GitUtils.getApiKey(deployConfig.github.apiKeyEnv)
	if not apiKey then
		return false, "API key not found"
	end

	local valid: boolean, err: string? = GitUtils.validateApiKey(apiKey)
	if not valid then
		return false, `API key validation failed: {err}`
	end

	return true, nil
end

return Deployment
