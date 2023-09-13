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
- [ ] Support for NotScriptable Properties
* Requires gethiddenproperty support
- [ ] Support for as many [KRNL-like saveinstance options](https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D)
  - [x] NilInstances
  - [x] ExtraInstances
  * Change mode to invalid mode like "custom" if you only want to save ExtraInstances
- [ ] Support for as many Executors as possible (🤢🤮)
