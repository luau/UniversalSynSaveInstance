--!strict
--[=[
	@class Logger
	Colored logging utilities for the build pipeline.

	Provides standardized console output with ANSI colors and formatting for
	info, success, warning, error, and fatal messages. Supports progress indicators
	and section headers for improved build output readability.

	@usage
	```lua
	local Logger = require("./lib/logger")
	Logger.info("Starting build process")
	Logger.success("Build completed successfully")
	Logger.error("Build failed: syntax error")
	```
]=]

-- Imports
local stdio = require("@lune/stdio")

-- ANSI color codes for terminal output
local COLOR_RESET: string = stdio.color("reset")
local COLOR_CYAN: string = stdio.color("cyan")
local COLOR_GREEN: string = stdio.color("green")
local COLOR_YELLOW: string = stdio.color("yellow")
local COLOR_RED: string = stdio.color("red")
local STYLE_BOLD: string = stdio.style("bold")
local STYLE_DIM: string = stdio.style("dim")

-- Unicode symbols for log message prefixes
local SYMBOL_INFO: string = "▶"
local SYMBOL_SUCCESS: string = "✓"
local SYMBOL_WARNING: string = "⚠"
local SYMBOL_ERROR: string = "✗"

-- Module state
local verboseEnabled: boolean = false

-- Types
export type LogLevel = "info" | "success" | "warn" | "error" | "fatal"

-- Module
local Logger = {}

--[=[
	Enables or disables verbose logging output.

	@param enabled Whether to enable verbose output
]=]
function Logger.setVerbose(enabled: boolean)
	verboseEnabled = enabled
end

--[=[
	Prints an informational message with cyan color.

	@param message The message to display
]=]
function Logger.info(message: string)
	print(`{COLOR_CYAN}{SYMBOL_INFO}{COLOR_RESET} {message}`)
end

--[=[
	Prints a success message with green color and checkmark.

	@param message The success message to display
]=]
function Logger.success(message: string)
	print(`{COLOR_GREEN}{SYMBOL_SUCCESS}{COLOR_RESET} {message}`)
end

--[=[
	Prints a warning message with yellow color.

	@param message The warning message to display
]=]
function Logger.warn(message: string)
	print(`{COLOR_YELLOW}{SYMBOL_WARNING}{COLOR_RESET} {message}`)
end

--[=[
	Prints an error message with red color.

	@param message The error message to display
]=]
function Logger.error(message: string)
	print(`{COLOR_RED}{SYMBOL_ERROR}{COLOR_RESET} {message}`)
end

--[=[
	Prints a fatal error message with bold red color.

	Used for unrecoverable errors requiring immediate termination.

	@param message Fatal error message
]=]
function Logger.fatal(message: string)
	print(`{COLOR_RED}{STYLE_BOLD}{SYMBOL_ERROR} {message}{COLOR_RESET}`)
end

--[=[
	Prints a section header with bold cyan color.

	@param title The section title to display
]=]
function Logger.section(title: string)
	print(`\n{COLOR_CYAN}{STYLE_BOLD}{title}{COLOR_RESET}`)
end

--[=[
	Prints a progress indicator with current and total counts.

	@param current Current progress count
	@param total Total expected count
	@param message Optional message to display
]=]
function Logger.progress(current: number, total: number, message: string?)
	local percent: number = math.floor((current / total) * 100)
	local progressText: string = `[{percent}%] ({current}/{total})`
	if message then
		print(`{COLOR_CYAN}{SYMBOL_INFO}{COLOR_RESET} {progressText} {message}`)
	else
		print(`{COLOR_CYAN}{SYMBOL_INFO}{COLOR_RESET} {progressText}`)
	end
end

--[=[
	Prints a verbose message only if verbose mode is enabled.

	@param message The verbose message to display
]=]
function Logger.verbose(message: string)
	if verboseEnabled then
		print(`{STYLE_DIM}{message}{COLOR_RESET}`)
	end
end

--[=[
	Prints an indented detail line for nested information.

	@param message The detail message to display
	@param depth Indentation depth (default: 1)
]=]
function Logger.detail(message: string, depth: number?)
	local indent: string = string.rep("  ", depth or 1)
	print(`{indent}├─ {message}`)
end

--[=[
	Prints the final indented detail line with a different symbol.

	@param message The final detail message to display
	@param depth Indentation depth (default: 1)
]=]
function Logger.detailLast(message: string, depth: number?)
	local indent: string = string.rep("  ", depth or 1)
	print(`{indent}└─ {message}`)
end

--[=[
	Formats a duration in milliseconds to a human-readable string.

	Returns seconds with 2 decimal places if >= 1000ms, otherwise milliseconds.

	@param ms Duration in milliseconds
	@return Formatted string like "1.23s" or "456ms"
]=]
function Logger.formatDuration(ms: number): string
	if ms >= 1000 then
		return string.format("%.2fs", ms / 1000)
	end
	return string.format("%dms", math.floor(ms))
end

--[=[
	Formats a file size in bytes to a human-readable string.

	Automatically selects appropriate unit (B, KB, MB, GB) and formats with
	2 decimal places for units larger than bytes.

	@param bytes File size in bytes
	@return Formatted string like "1.23 MB" or "456 B"
]=]
function Logger.formatSize(bytes: number): string
	local units: { string } = { "B", "KB", "MB", "GB" }
	local size: number = bytes
	local unitIndex: number = 1

	while size >= 1024 and unitIndex < #units do
		size /= 1024
		unitIndex += 1
	end

	if unitIndex == 1 then
		return string.format("%d %s", size, units[unitIndex])
	end
	return string.format("%.2f %s", size, units[unitIndex])
end

return Logger
