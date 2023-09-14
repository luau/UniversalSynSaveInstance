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
- [ ] Look into adding support for Binary Format Output (rbxl/rbxm instead of rbxlx/rbxmx) 
*  RBXL files are similar to .RBXLX files but are saved in Binary format, which helps reduce the file size.
- [ ] Support for rbxm/rbxmx
- [ ] Remove Useless tables & functions of specialinfo
- [ ] Speed things up as much as possible
* Requires benchmarks
* Requires looking at other scripts of ours that are aimed at speed & performance
- [ ] Support for NotScriptable Properties
* Requires gethiddenproperty support
- [ ] Support for as many [KRNL-like saveinstance options](https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D)
  - [x] NilInstances
  - [x] ExtraInstances
  * Change mode to invalid mode like "custom" if you only want to save ExtraInstances
- [ ] Support for as many Executors as possible (🤢🤮)
- [ ] Add Documentation similar to [KRNL](https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D) or [Synapse X](https://docs.synapse.to/reference/misc.html?highlight=saveins#save-instance)
/ [Synapse X Old](https://synapsexdocs.github.io/custom-lua-functions/misc-functions/#save-instance)
- [ ] Add more Fixes for Errors that ***can*** pop up during opening process
- [ ] Add getproperties as fallback for specialinfo
- [ ] Do clean-up in inheritor and automatically assume the top-most class that owns the property, while also cleaning up said property from classes that inherit from it
- [ ] Fix indexes being mixed up after table.remove shifting
- [ ] Use getspecialinfo fallback function carefully as it's hardcoded
- [ ] Bypass NotCreatable by hardcoding links/references/indexes to said Classes
* Example: Terrain class can be indexed by doing workspace.Terrain but is NotCreatable
