# Loadstring

```lua
local Params = {
	RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
	SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
```

# Syn Save Instance

Or shortly SSI, a project aimed at resurrecting saveinstance function from [2019 Synapse X leaked source code](https://github.com/Acrillis/SynapseX).<br />
Reason: Many Executors fail miserably at providing good user experience when it comes to tinkering with saving instances

# TO-DOs:

- [ ] Add `continue` where needed
- [ ] Add Documentation similar to [KRNL](https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D) or [Synapse X](https://docs.synapse.to/reference/misc.html?highlight=saveins#save-instance) / [Synapse X Old](https://synapsexdocs.github.io/custom-lua-functions/misc-functions/#save-instance)
- [ ] Add fallback function for appendfile (whether through storing current xml as string or with use of readfile)
- [x] Add getproperties as fallback for specialinfo
- [ ] Add Redirects to some special (in a bad way 😡) values, more info @ [PropertyPatches](https://github.com/MaximumADHD/Roblox-File-Format/blob/main/Plugins/GenerateApiDump/PropertyPatches.lua#L72), otherwise they will fallback to default when file is opened
  - Not all though, test each and see if it carries over or not (when file is opened)..
- [ ] Add more Fixes for Errors that **_can_** pop up during opening process
- [ ] Add table.clone instead {} in some cases if possible
- [x] Add --!native tag just in case
- [ ] ~~Auto-Detect DataTypes/ValueType Categories of Properties (CFrame, UDim2 so on)~~ Full API Dump Solves this ?
- [x] Bring said DataType serializer into an outside function
- [ ] ~~Bypass NotCreatable by hardcoding links/references/indexes to said Classes
  - Example: Terrain class can be indexed by doing workspace.Terrain but is NotCreatable
- [x] Check if table.concat is actually the fastest way as compared to other alternatives (IT'S NOT)
- [ ] Do clean-up in inheritor and automatically assume the top-most class that owns the property, while also cleaning up said property from classes that inherit from it
- [x] Fix indexes being mixed up after table.remove shifting
- [x] Hidden properties
  - [x] ~~Scan for them~~ Full API Dump Solves this
  - [ ] ~~Scan game and map instances in format {ClassName = {Instance1, Instance2} }, if none found then attempt to create proper Replica for them~~ Full API Dump Solves this
  * This will help with getting many ValueTypes accurately, especially BinaryStrings vs strings
  - [] ~~Inherit them properly and do the clean-up~~ Full API Dump Solves this
  - [x] ~~Tell whether ValueType is string or BinaryString~~ Full API Dump Solves this
- [ ] Look into adding support for Binary Format Output (rbxl/rbxm instead of rbxlx/rbxmx)
  - RBXL files are similar to .RBXLX files but are saved in Binary format, which helps reduce the file size.
- [ ] Support for rbxm/rbxmx
- [ ] ~~Possibly convert to non-Name tables and use instance references instead (Perhaps make a config Bool Toggle for this, false by default), ex. DecompileIgnore = {game.CoreGui}~~ Add too much complexity for now
  - This will allow for more flexibility of saveinstancing
- [x] ~~Remove Useless tables & functions of specialinfo~~ Repurposed
- [ ] Replace all operators with compound operators if possible, make sure to add other LuaU syntax too (matters for performance!)
- [ ] Speed things up as much as possible
  - Requires benchmarks
  - Requires looking at other scripts of ours that are aimed at speed & performance
- [x] Support for NotScriptable Properties
  - Requires gethiddenproperty support
- [ ] Support for as many [KRNL-like saveinstance options](https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D)
  - Change mode to invalid mode like "custom" if you only want to save ExtraInstances
  * [x] NilInstances
  * [x] ExtraInstances
- [ ] Support for as many Executors as possible (🤢🤮)
- [x] ~~Use getspecialinfo fallback function carefully as it's hardcoded~~ Useless because there's no way to tell if the Property Values of those instances are default or not
- [ ] Store all functions outside that are used during saveinstancing for sake of performance

# Acknowledgments

This document is based largely on the efforts of [@Anaminus](https://github.com/Anaminus) & [@Dekkonot](https://github.com/Dekkonot), authors of the [Rbxlx Format Specifications](https://github.com/RobloxAPI/spec/blob/master/formats/rbxlx.md). Additional
resources include:

- [Syngp Synapse X 2019 Source code](https://github.com/Acrillis/SynapseX) for base saveinstance code (extended by [@mblouka](https://github.com/mblouka) and [@Acrillis](https://github.com/Acrillis))
- [Roblox File Format](https://github.com/MaximumADHD/Roblox-File-Format) for a list of redirects of old/deprecated xml properties that still use the old tag values
- [Roblox Client Tracker](https://github.com/MaximumADHD/Roblox-Client-Tracker) for an extended & close to full JSON Api Dump (with hidden properties & default values)
