<!-- Links -->
[stars]: https://github.com/latte-soft/wax/stargazers
<!--[fork]: https://github.com/latte-soft/wax/fork-->
[license]: https://github.com/latte-soft/wax/blob/master/LICENSE
[latest-release]: https://github.com/latte-soft/wax/releases/latest
[commits]: https://github.com/latte-soft/wax/commits
[discord]: https://latte.to/discord

<!-- Badges -->
[badges/stars]: https://img.shields.io/github/stars/latte-soft/wax?label=Stars&logo=GitHub
<!--[badges/fork]: https://img.shields.io/github/forks/latte-soft/wax?label=Forks&logo=GitHub-->
[badges/license]: https://img.shields.io/github/license/latte-soft/wax?label=License
[badges/latest-release]: https://img.shields.io/github/v/release/latte-soft/wax?label=Latest%20Release
[badges/last-modified]: https://img.shields.io/github/last-commit/latte-soft/wax?label=Last%20Modifed
[badges/discord]: https://img.shields.io/discord/892211155303538748?label=Latte%20Softworks%20Discord&color=5865F2

# Wax

[![Stars][badges/stars]][stars] [![License][badges/license]][license] [![Latest Release][badges/latest-release]][latest-release] [![Last Modified][badges/last-modified]][commits] [![Discord Server][badges/discord]][discord]

A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

*Powered by [Lune](https://github.com/lune-org/lune), a standalone Luau script runtime*

## 🎉 About

Wax is an all-in-one bundler for projects in Lua 5.1x+ and [Luau](https://luau-lang.org), supporting and enforcing Roblox-like module require semantics (like using `require()` with a relative `script` global), and also normal `string` file paths like in generic Lua.

This is more of a successor to [Maui](https://github.com/latte-soft/maui), a similar, but much more limited and inherently flawed project for bundling Roblox projects, but **only** for running in Roblox. Wax, on the other hand, *bundles* completely outside of the Roblox engine, and generates code that can *run* outside it aswell. **Wax can 'bridge the gap' between traditional Lua projects and modern Roblox/Luau workflows, or anything in-between.**

### Features

*See [Usage](#🚀-usage) for more details on utilizing various features*

* Bundle directly from a [Rojo project](https://rojo.space/docs/v7/project-format) file (`*.project.json`), or just a generic Roblox model file. (`*.rbxm` or `*.rbxmx`) *For working directly with Rojo project files, you **must** have the `rojo` command in your $PATH*
* Created with **debugging in mind** from the start. *With output minification disabled*, even proper line info (matching to the original source files) can be shown in errors; for example, `[WaxRuntime].Script.OtherScript:1: intentional error`
* Built-in support for minifying bundled output directly with [Darklua](https://darklua.com) and either our default configuration (no extra steps), or your project's own `.darklua.json/json5` file for making personal tweaks.
* Localized/flattened modified globals in closures, meaning `getfenv`/`setfenv` aren't used to modify the script's environment - This also means that in Luau, `safeenv` runtime optimizations are maintained, and closures run 'natively' with no user modification!
* Automated CI/deployment pipeline usage in mind, with the `ci-mode` flag; no user confirmation prompts, and exits with a `1` status code upon any errors
* A 'virtual' Roblox-like DOM for scripts that can run completely outside of Roblox, while also allowing module imports (`require()`) with a simulated relative `script` global, or traditional filesystem path strings like in [Lune](https://github.com/lune-org/lune) or the Lua/Luau CLI REPLs.

Additionally, you can check out some example "projects" in our [tests](tests) directory if you don't really know what all of this is about, or how to get started..

## ⚙️ Installation

For your project, you **must** have at least [Lune](https://github.com/lune-org/lune) installed, most easily done and managed with [Aftman](https://github.com/LPGhatguy/aftman):

1. Goto Aftman's GitHub repository (linked above), and follow its installation instructions for your platform
2. Open the root directory of your project in your system's terminal, and run the following:

```
aftman init
aftman add lune-org/lune
```

3. If you've setup Aftman properly, you can now try running `lune --help`, and if all is well you should see something similar to the following in your terminal:

```
$ lune --help
A standalone Luau runtime

Usage: lune [COMMAND]
...
```

### Add Wax to Your Lune Scripts

If you already have a "`lune`", "`.lune`", or similar directory in your project for these scripts, feel free to use it - for the sake of this example guide, I'm going to use "`lune`" as the example directory for Lune script(s).

1. If you haven't already, create a directory named "`lune`" in the root of your project
2. Inside of this newly created directory, create a file named "wax.luau", and paste in the following (or directly download `wax.luau` from the latest release on the [releases page](https://github.com/latte-soft/wax/releases))

*(DO NOTE: if you're using the 'remote' loader below, you won't be able to use Wax offline, and request times per running the script could be impractical for both speed and efficiency depending on your internet connection; consider manually installing `wax.luau` from the latest release on the releases page, linked above)*

```lua
--[[
    Wax - A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>
]]

-- You set the following string to "latest" (case insensitive), or any version tag
-- on Wax's releases page (e.g. "0.4.2")
local WaxVersion = "latest"

-------------------------------------------------------------------------------

local net = require("@lune/net")
local luau = require("@lune/luau")

local FileLink = if string.lower(WaxVersion) == "latest" then
    "https://github.com/latte-soft/wax/releases/latest/download/wax.luau"
else `https://github.com/latte-soft/wax/releases/download/{WaxVersion}/wax.luau`

luau.load(net.request(FileLink).body, {
    debugName = "Wax",
})()

```

3. Now, when running `lune run wax`, you should see something similar to what's in the next section ([Usage](#🚀-usage)) in your terminal. Voilà!

## 🚀 Usage

From your terminal in the root directory of your project, run `lune run wax`, or just `lune run <path/to/wax.luau>`

```
Wax 0.4.2
A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

USAGE:
    lune run wax [subcommand] [options]

* When no subcommand is provided, this usage message is displayed
* Provide all options in the following format (no "--" flag prefix): option=value

SUBCOMMANDS:
    help      Displays this usage message

    version   Displays Wax's version

    bundle    Builds a bundled script file from a given Roblox model (*.rbxm/*.rbxmx)
              or Rojo project file (*.project.json, requires the `rojo` command
              available in your PATH environment variable), to an output path

      OPTIONS for `bundle`:
      * input[="default.project.json"]
            The input Roblox model (*.rbxm/*.rbxmx) or Rojo project (*.project.json) file
            path for Wax to bundle from

      * output[="{input-filename}.lua"]
            The final output file path (must end in .lua or .luau) for the bundled script

      * minify[=false]
            If codegen output should be "minified", which also omits any runtime line
            debugging info (offsets). For 'full' codegen minification (outside of just
            LuaEncode's table output), you must have the `darklua` command available in
            your PATH environment variable.
            Additionally, with Darklua, if a ".darklua.json/json5" file isn't found in the
            CWD (your dir "position" in your terminal), it'll use the default configuration
            we provide (see `lune/lib/data/DefaultDarkluaConfig.luau`)

      * env-name[="WaxRuntime"]
            The name of the "environment" of the bundled script. This is the "name" of
            the root object (like the `game` DataModel in Roblox) and displays in virtual
            runtime errors (e.g. "[WaxRuntime].Script:1: Some error message")

      * darklua-config-path[=(".darklua.json", ".darklua.json5")]
            When `minify` is set as true, this path can be used to directly pass your own
            Darklua config file's path, instead of only checking for the default paths
            it looks for

      * temp-dir-base[="{output-dir}"]
            If you're providing a Rojo project file as input or minifying with Darklua,
            a temporary directory is created inside of this directory path, and is removed
            by the time Wax has completed processing

      * extra-offset-lines[=0]
            (Only applicable to when `minify` is set to false) Internally acknowledges
            any extra lines offset from the top of the script (like if you're adding a
            header of sorts to the codegen) for line debugging info. Ths MUST be exactly
            accurate to its name (*extra* lines, so you may want to do something like
            `#ExtraHeader - 1` if you're using this option)

      * ci-mode[=false]
            (*Primarily* for automated CI pipelines or deployment systems) Never gives
            any user input prompts, and will *always* exit with a `1` status code upon an
            'error' or warning during the build process

      * verbose[=true]
            "Verbose" (detailed) output logging from CLI/bundler
```

## Runtime Spec Details

* If there's only 1 instance directly under the model root and it's a `ModuleScript`, that module will automatically run at init and pass its return through the **real** script, just as expected with normal module behavior. Additionally, like a model on Roblox's [Developer Marketplace](https://create.roblox.com/marketplace/models), a `ModuleScript` under the model root named (exactly) "MainModule" will also have the same functionality, even if there is more than 1 instance directly under the model root

* The real `getfenv`/`setfenv` functions are not overriden by global flattening whatsoever, so by using for example `getfenv(0)` it will return the actual root function environment of the complete, bundled script. *Just know that its behavior isn't modified whatsoever for virtual closures!*

* Instance `ClassName`s that will bundle:
  * `Folder`
  * `Script`
  * `LocalScript`
  * `ModuleScript`
  * `StringValue`

* Implemented Instance 'properties' :
  * `Instance.ClassName: string`
  * `Instance.Name: string`
  * `Instance.Parent: Instance?`
  * `StringValue.Value: string`

* Implemented Instance 'methods':
  * `Instance:GetFullName(): string`
  * `Instance:GetChildren(): {Instance}`
  * `Instance:GetDescendants(): {Instance}`
  * `Instance:FindFirstChild(name: string, recursive: boolean?): Instance?`
  * `Instance:FindFirstAncestor(name: string): Instance?`
  * `Instance:WaitForChild(name: string, timeOut: number?)` *The actual behavior of the virtual `WaitForChild` impl is identical to `FindFirstChild`, but it needs to be implemented due to many codebases using it for relative module `require()` paths*

## Runtime API Reference

**All virtual closures have a special `wax` global for accessing AOT Wax build info, an isolated `shared` table, and 'real' globals Wax replaces.**

* `wax.version`

The version of Wax the current script was bundled with.

```lua
wax.version: string
```

* `wax.envname`

The string provided in the `env-name` option at build-time. ("`WaxRuntime`" by default)

```lua
wax.envname: string
```

* `wax.shared`

A table shared across all virtual closures in a bundled project, similar to the real `_G`/`shared` globals.

```lua
wax.shared: {[any]: any}
```

* `wax.script`

The real `script` global of the current script, (for with Roblox etc) as opposed to the virtual script ref override by Wax. If there isn't a real `script` global above Wax's environment anyway, this will be `nil`.

```lua
wax.script: LuaSourceContainer?
```

* `wax.require()`

The real `require()` function given by your Lua runtime as opposed to Wax's virtual override. (Lua, Luau (vanilla repl), Roblox Engine, Lune etc)

```lua
wax.require(...: any): ...any
```

## Build from Source

1. Clone the repository with `git`:

```
git clone https://github.com/latte-soft/wax.git
cd wax
```

2. With [Aftman](https://github.com/LPGhatguy/aftman) installed and configured:

*Accept any new tools for installation from the `y/n` prompts, or append `--no-trust-check` to the following command*

```
aftman install
```

3. Build with `lune` ([lune/make.luau](lune/make.luau)):

```
lune run make
```

If successful, the resulting bundled scripts will be output in the `build/` directory:

```
build
├── wax.dbg.luau
└── wax.luau
```

## 🏛️ License

*See file: [LICENSE](LICENSE)*

```
MIT License

Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
