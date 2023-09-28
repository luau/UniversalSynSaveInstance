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
- [ ] Add Redirects to some special (in a bad way 😡) values, more info @ ~~[PropertyPatches](https://github.com/MaximumADHD/Roblox-File-Format/blob/main/Plugins/GenerateApiDump/PropertyPatches.lua#L72)~~ [PropertyPatches](https://github.com/rojo-rbx/rbx-dom/tree/master/patches)+[Bonus](https://github.com/rojo-rbx/rbx-dom/blob/9716af360307eb5da5f97d54d84d694b2bc06acf/rbx_dom_lua/src/customProperties.lua), otherwise they will fallback to default when file is opened
  - Not all though, test each & see if it carries over or not (when file is opened)..
  - All current redirects: [Here](https://github.com/luau/SynSaveInstance/blob/main/TODO/PropertyPatches)
- [ ] Add more Fixes for Errors that **_can_** pop up during opening process
- [x] Add Optional tags support
- [ ] Add readbinarystring or readbinarystringpropertyvalue/readbspval (elysian) as fallback for gethiddenproperty
- [ ] Add table.clone instead {} in some cases if possible
- [ ] Avoid scanning for default values of properties if those properties won't get serialized anyway (e.g. don't have a Descriptor)
- [x] Add --!native tag just in case
- [ ] Find default values of binarystring properties (MaximumADHD might have a clue)
  - LOOK INTO Instance:IsPropertyModified & Instance:ResetPropertyToDefault
- [ ] ~~Auto-Detect DataTypes/ValueType Categories of Properties (CFrame, UDim2 so on)~~ Full API Dump Solves this ?
- [x] Bring said DataType serializer into an outside function
- [ ] ~~Bypass NotCreatable by hardcoding links/references/indexes to said Classes
  - Example: Terrain class can be indexed by doing workspace.Terrain but is NotCreatable
- [x] Check if table.concat is actually the fastest way as compared to other alternatives (IT'S NOT)
- [ ] Do ~~clean-up in inheritor &~~ (API Dumps solve this, illogical) automatically assume the top-most class that owns the property, while also cleaning up said property from classes that inherit from it
- [x] Fix indexes being mixed up after table.remove shifting
- [x] Hidden properties
  - [x] ~~Scan for them~~ Full API Dump Solves this
  - [ ] ~~Scan game & map instances in format {ClassName = {Instance1, Instance2} }, if none found then attempt to create proper Replica for them~~ Full API Dump Solves this
  * This will help with getting many ValueTypes accurately, especially BinaryStrings vs strings
  - [] ~~Inherit them properly & do the clean-up~~ Full API Dump Solves this
  - [x] ~~Tell whether ValueType is string or BinaryString~~ Full API Dump Solves this
- [ ] Look into adding support for Binary Format Output (rbxl/rbxm)
  - .RBXL files are similar to .RBXLX files but are saved in Binary format, which helps reduce the file size.
  - ! Check out string.pack & string.unpack for more information !
- [ ] Support for Model files:
  - [x] rbxmx (xml)
  - [ ] rbxm (binary)
- [ ] ~~Possibly convert to non-Name tables & use instance references instead (Perhaps make a config Bool Toggle for this, false by default), ex. DecompileIgnore = {game.CoreGui}~~ Add too much complexity for now
  - This will allow for more flexibility of saveinstancing
- [x] ~~Remove Useless tables & functions of specialinfo~~ Repurposed
- [ ] Replace all operators with compound operators if possible, make sure to add other LuaU syntax too (matters for performance!)
- [ ] Speed things up as much as possible
  - Requires benchmarks
  - Requires looking at other scripts of ours that are aimed at speed & performance
- [x] Support for NotScriptable Properties
  - Requires gethiddenproperty support
- [ ] Support for as many [KRNL-like saveinstance options](https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D):
  - Change mode to invalid mode like "custom" if you only want to save ExtraInstances
  * [x] Decompile (! This takes priority over OPTIONS.noscripts if set !)
  * [x] DecompileIgnore
  * [x] DecompileTimeout (! This takes priority over OPTIONS.timeout if set !)
  * [x] ExtraInstances
  * [x] IgnoreDefaultProps
  * [x] NilInstances
  * [x] SavePlayers
  * [x] ShowStatus
- [ ] Support for as many Executors as possible (🤢🤮)
- [x] ~~Use getspecialinfo fallback function carefully as it's hardcoded~~ Useless because there's no way to tell if the Property Values of those instances are default or not
  - LOOK INTO Instance:IsPropertyModified & Instance:ResetPropertyToDefault
- [ ] Isolators must clear
- [x] Store all functions outside that are used during saveinstancing for sake of performance
- [ ] Remove buffersize, savebuffer & so on for sake of performance by concatenating <Item> strings to total string then writing it to file (no extra steps like table.concat)
  - Test table.concat vs string ..= with a full buffer (this benchmark differs per usecase)
- [ ] Make sure BinaryStrings are compared to Defaults properly (aka in same format)
- [ ] Add Option to restart saveinstance from the point that it crashed on
- [ ] Check out DataType exceptions [Here](https://github.com/rojo-rbx/rbx-dom/blob/master/rbx_reflector/src/cli/generate.rs#L260)
- [x] Add README Similar to current Synapse
- [ ] Ignore all properties of instances that aren't Local or Module Scripts except Name if mode is set to "scripts"
- [ ] Maybe modes should do more than just affecting the list of instances to save, like changing IgnoreDefaultProperties to false if mode is "full" for example
- [x] Add Support for SharedStrings [Docs](https://github.com/RobloxAPI/spec/blob/master/formats/rbxlx.md#sharedstring)
  - Fun fact: SharedStrings can also be used for ValueTypes that aren't `SharedString`, this behavior is not documented anywhere but makes sense (Could create issues though, due to _potential_ ValueType mix-up). By replacing `<BinaryString name="Tags">Base64EncodedValue</BinaryString>` with `<SharedString name="Tags">UniqueIdentifierForSharedString</SharedString>`and putting `<SharedString md5="UniqueIdentifierForSharedString">Base64EncodedValue</SharedString>` into SharedStrings container you can achieve this amazing behaviour. This should be only enabled using an optional setting ()<br />Only known to work with (probably because both are base64 encoded):
  * BinaryString
- [ ] Add Lua & Luau versions instead of merged
- [ ] Add Support for multiple Instances to be saved as a model
- [ ] Do something about devs renaming Services therefore bypassing Ignore lists (CoreGui/CorePackages are not affected)
  - LOOK INTO Instance:IsPropertyModified & Instance:ResetPropertyToDefault

# Acknowledgments

This document is based largely on the efforts of [@Anaminus](https://github.com/Anaminus) & [@Dekkonot](https://github.com/Dekkonot), authors of the [Rbxlx Format Specifications](https://github.com/RobloxAPI/spec/blob/master/formats/rbxlx.md). Additional
resources include:

- [Syngp Synapse X 2019 Source code](https://github.com/Acrillis/SynapseX) for base saveinstance code (extended by [@mblouka](https://github.com/mblouka) & [@Acrillis](https://github.com/Acrillis))
- [Roblox File Format](https://github.com/MaximumADHD/Roblox-File-Format) for a list of redirects of old/deprecated xml properties that still use the old tag values
- [Roblox Client Tracker](https://github.com/MaximumADHD/Roblox-Client-Tracker) for an extended & close to full JSON Api Dump (with hidden properties & default values)
