<p align="center">
  <img height="400px" style="margin: 0; padding: 0" src=".moonwave\static\logo.png" />
</p>


# Loadstring

```lua
local Params = {
 RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
 SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {} -- Documentation here https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance
synsaveinstance(Options)
```

# Universal Syn Save Instance

Or shortly USSI, a project aimed at resurrecting saveinstance function from Synapse X.<br />
Reason: Many Executors fail miserably at providing good user experience when it comes to tinkering with saving instances.

> [!WARNING]
> As stated under the Section 7 (b) in the LICENSE:
> - You **MUST** always include the following Credit string: `UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw`
> - You are **NOT** allowed to claim authorship of the source code provided in this repository
> - You **MUST** always include the following [License](https://github.com/luau/UniversalSynSaveInstance/blob/main/LICENSE)

> [!TIP]
> Important part about this saveinstance is that it doesn't modify anything, therefore reduces the amount of detection vectors by a lot.<br />
> You can also enable the `SafeMode` option to completely bypass any detections and save **ANY** game!<br /><br />
> If this script is helpful to you, please click `⭐ Star` in the upper right corner of the page to support it, thank you!


# 💖 Support Us & Our Work

<a href='https://ko-fi.com/M4M1JNH5G' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' title='KO-FI' /></a>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M1JNH5G "KO-FI")
<br />
[![ko-fi](https://user-images.githubusercontent.com/95628489/231759262-25661006-b7ca-4967-a79d-2b465cd9575a.png)](https://ko-fi.com/M4M1JNH5G "KO-FI QR-CODE")

# DISCORD SERVER:<br />

<https://discord.com/invite/wx4ThpAsmw> **/** <https://discord.gg/wx4ThpAsmw><br />
[<img src="https://discordapp.com/api/guilds/1022465460517740654/widget.png?style=banner2" alt="Our Official Discord Server!"></img>](https://discord.com/invite/wx4ThpAsmw)<br />

# TO-DOs

- [ ] Look into adding support for Binary Format Output (rbxl/rbxm)
  - Users can already convert to Binary Format by
    1. Open the File
    2. Click on top left "FILE" text and select "Save to File As"
    3. Make Sure rbxl/rbxm format is selected (not XML!)
    4. Click Save
  - .RBXL files are similar to .RBXLX files but are saved in Binary format, which helps reduce the file size.
  - ! Check out [Rojo Rbx Dom Binary] & [Roblox Format Specifications Binary] for more documentation about the Binary File Format!
  - ! Also see [buffer], [bit32] libraries as well as [pack]/[unpack] from the [string] library for more information on how you can implement something like this!
  - ! [Rbx-Binary-Format]
- [ ] Add table.clone instead {} in some cases if possible
- [ ] Support for Model files:
  - [x] rbxmx (xml)
  - [ ] rbxm (binary)
- [x] Implement [Luau Syntax] (important for performance!):
  - [x] Compound Operators
  - [x] Avoid using `next`, `ipairs` & `pairs`
  - [x] ~~Interpolated strings instead of concat~~ Slower
  - [ ] Type-checking (😩🙀)
  - [ ] ~~`if-then-else` expressions~~ No reason to
  - [ ] Floor division

- [ ] Speed things up as much as possible
  - Requires benchmarks
- [ ] Support for as many [KRNL-like saveinstance Options] & [UNC]:
  - Change mode to invalid mode like "custom" if you only want to save ExtraInstances
  * [x] Decompile (! This takes priority over OPTIONS.noscripts if set !)
  * [x] DecompileIgnore
  * [x] DecompileTimeout (! This takes priority over OPTIONS.timeout if set !)
  * [x] ExtraInstances
  * [x] FilePath
  * [x] IgnoreDefaultProps
  * [x] IsolateStarterPlayer
  * [x] NilInstances
  * [x] Object (for .rbxmx files)
  * [x] RemovePlayerCharacters
  * [x] SavePlayers
  * [x] ShowStatus
    - [x] ~~Add Drawing Library support for ShowStatus~~ Can't reliably test if it's working on an executor
  * [x] IsolatePlayerGui (same as IsolateLocalPlayer)
  * [x] Callback
  * [x] ~~CopyToClipboard/Clipboard~~ Use Callback instead
  * [ ] Binary (rbxl/rbxm)
- [x] ~~Remove buffersize, savebuffer & so on for sake of performance by concatenating <Item> strings to total string then writing it to file (no extra steps like table.concat)~~ table.concat proved faster in the case of huge amount of concatenations
  - Test table.concat vs string ..= with a full buffer (this benchmark differs per usecase)
- [ ] Add Option to restart saveinstance from the point that it crashed on (perhaps by skipping)
- [ ] Maybe modes should do more than just determining the list of instances to save, like changing IgnoreDefaultProperties to false if mode is "full" for example
- [x] Add Lua & Luau versions instead of merged (WARNING: LUAU MIGHT BE MORE UPDATED THAN LUA VERSION, lua version exists just for the sake of old & bad executors, ask devs of your executors to support luau as its latest & greatest)
- [x] ~~Add Support for multiple Instances to be saved as a model~~ IsModel = true & ExtraInstances
- [ ] Force disable ParticleEmitters in case something like IgnorePropertiesOfNotScriptsOnScriptsMode is enabled (they stack in one place and create huge lag)
- [ ] Be able to specify which special properties you want saved (to avoid saving all)

# Acknowledgments
> [!IMPORTANT]
> This document is based largely on the efforts of [@Anaminus] & [@Dekkonot], authors of the [Roblox Format Specifications]. Additional
resources include:
> 
> - [Syngp Synapse X Source code 2019][Synapse X Source 2019] for base saveinstance code (extended by [@mblouka] & [@Acrillis])
> - [Moon/LorekeeperZinnia][@LorekeeperZinnia] for being the original creator of saveinstance that was used in Synapse X, Elysian and many others. As well as being an inspiration for this project.
> - [Rojo Rbx Dom Xml] for being a fallback documentation in case something wasn't clear in the [Roblox Format Specifications]
> - [Roblox File Format] for a list of redirects of old/deprecated xml properties that still use the old tag values
> - [Roblox Client Tracker] for an extended & close to full JSON Api Dump (with hidden properties & default values)

\*\*\* View source code of this file for more credits

[@Acrillis]: https://github.com/Acrillis
[@Anaminus]: https://github.com/Anaminus
[@Dekkonot]: https://github.com/Dekkonot
[@mblouka]: https://github.com/mblouka
[@LorekeeperZinnia]: https://github.com/LorekeeperZinnia
[bit32]: https://create.roblox.com/docs/reference/engine/libraries/bit32
[buffer]: https://create.roblox.com/docs/reference/engine/libraries/buffer
[pack]: https://create.roblox.com/docs/reference/engine/libraries/string#pack
[unpack]: https://create.roblox.com/docs/reference/engine/libraries/string#unpack
[string]: https://create.roblox.com/docs/reference/engine/libraries/string
[KRNL-like saveinstance Options]: https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D
[Rojo Rbx Dom Xml]: https://github.com/rojo-rbx/rbx-dom/blob/master/docs/xml.md
[Rojo Rbx Dom Binary]: https://github.com/rojo-rbx/rbx-dom/blob/master/docs/binary.md
[Luau Syntax]: https://luau-lang.org/syntax
[Rbx-Binary-Format]: https://github.com/Dekkonot/rbx-binary-format/blob/master/src/writer.lua
[Roblox Client Tracker]: https://github.com/MaximumADHD/Roblox-Client-Tracker
[Roblox File Format]: https://github.com/MaximumADHD/Roblox-File-Format
[Roblox Format Specifications]: https://github.com/RobloxAPI/spec/
[Roblox Format Specifications Binary]: https://github.com/RobloxAPI/spec/blob/master/formats/rbxl.md
[Synapse X Source 2019]: https://github.com/Acrillis/SynapseX
[UNC]: https://github.com/unified-naming-convention/NamingStandard/commit/613c1956b801ace54ba141dfc60842a16608b54f
