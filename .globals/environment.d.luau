declare class EnumItem
    Name: string
    Value: number
    EnumType: Enum
    function IsA(self, enumName: string): boolean
end

declare class AccessoryDescription extends Instance
	AccessoryType: EnumAccessoryType
	AssetId: number
	Instance: Instance
	IsLayered: boolean
	Order: number
	Puffiness: number
end

declare class EnumAccessoryType extends EnumItem end
declare class EnumCreatorType extends EnumItem end
declare class EnumGenre extends EnumItem end
declare class EnumHttpRequestType extends EnumItem end

declare class SomeOtherService
    [any]: any
end

declare class ServiceProvider extends Instance
	Close: RBXScriptSignal<>
	CloseLate: RBXScriptSignal<>
	ServiceAdded: RBXScriptSignal<Instance>
	ServiceRemoving: RBXScriptSignal<Instance>
	function FindService(self, className: string): Instance
	function GetService(self, classname: string): SomeOtherService
end

declare class DataModel extends ServiceProvider
	CreatorId: number
	CreatorType: EnumCreatorType
	GameId: number
	Genre: EnumGenre
	GraphicsQualityChangeRequest: RBXScriptSignal<boolean>
	IsSFFlagsLoaded: boolean
	JobId: string
	Loaded: RBXScriptSignal<>
	PlaceId: number
	PlaceVersion: number
	PrivateServerId: string
	PrivateServerOwnerId: number
	ScreenshotReady: RBXScriptSignal<string>
	ScreenshotSavedToAlbum: RBXScriptSignal<string, boolean, string>
	UniverseMetadataLoaded: RBXScriptSignal<>
	Workspace: Workspace
	SoundService: SoundService
	Players: {[any]: any}
	[string]: any

    function HttpGet(self, url: string, value: any): string

	function BindToClose(self, func: ((...any) -> ...any)): nil
	function DefineFastFlag(self, name: string, defaultValue: boolean): boolean
	function DefineFastInt(self, name: string, defaultValue: number): number
	function DefineFastString(self, name: string, defaultValue: string): string
	function GetEngineFeature(self, name: string): boolean
	function GetFastFlag(self, name: string): boolean
	function GetFastInt(self, name: string): number
	function GetFastString(self, name: string): string
	function GetJobsInfo(self): { any }
	function GetObjects(self, url: Content): { Instance }
	function GetObjectsAllOrNone(self, url: Content, binaryFormatOnly: boolean?): { Instance }
	function GetObjectsAsync(self, url: Content): { Instance }
	function GetObjectsList(self, urls: { any }): { any }
	function GetPlaySessionId(self): string
	function HttpGetAsync(self, url: string, httpRequestType: EnumHttpRequestType?): string
	function HttpPostAsync(self, url: string, data: string, contentType: string?, httpRequestType: EnumHttpRequestType?): string
	function InsertObjectsAndJoinIfLegacyAsync(self, url: Content): { Instance }
	function IsContentLoaded(self): boolean
	function IsLoaded(self): boolean
	function IsUniverseMetadataLoaded(self): boolean
	function Load(self, url: Content): nil
	function OpenScreenshotsFolder(self): nil
	function OpenVideosFolder(self): nil
	function ReportInGoogleAnalytics(self, category: string, action: string?, label: string?, value: number?): nil
	function SetFastFlagForTesting(self, name: string, newValue: boolean): boolean
	function SetFastIntForTesting(self, name: string, newValue: number): number
	function SetFastStringForTesting(self, name: string, newValue: string): string
	function SetFlagVersion(self, name: string, version: number): nil
	function SetIsLoaded(self, value: boolean, placeSizeInBytes: number?): nil
	function SetPlaceId(self, placeId: number): nil
	function SetUniverseId(self, universeId: number): nil
	function Shutdown(self): nil
end

declare game: DataModel

export type userdata = {[any]: any}
declare userdata: userdata & Instance

export type _crypt = {[any]: any}
declare crypt: _crypt
export type _cache = {[any]: any}
declare cache: _cache

declare class Connection
    Enabled: boolean
    ForeignState: boolean
    LuaConnection: boolean
    Function: (...any) -> (...any)?
    Thread: thread?
    function Fire(self, ...: any): ()
    function Defer(self, ...: any): ()
    function Disconnect(self): ()
    function Disable(self): ()
    function Enable(self): ()
end

declare class WebSocketClass
    function Send(self, message: string): ()
    function Close(self): ()
    OnMessage: RBXScriptSignal
    OnClose: RBXScriptSignal
end

declare class DrawingClass
    Visible: boolean
    ZIndex: number
    Transparency: number
    Color: Color3
    __OBJECT_EXISTS: boolean
    function Destroy(self): ()
end


export type Request = {
    Url: string,
    Method: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD" | "OPTIONS",
    Body: string?,
    Headers: {[string]: string}?,
    Cookies: {[string]: string}?,
}

export type Response = {
    Body: string,
    StatusCode: number,
    StatusMessage: string,
    Success: boolean,
    Headers: {[string]: string}
}

export type GetinfoReturnTypeFunc<A..., R...> = {
    source: string,
    short_src: string,
    func: (A...) -> R...,
    what: string,
    currentline: number,
    name: string,
    nups: number,
    numparams: number,
    is_varargs: number
}

export type GetinfoReturnTypeLvl = {
    source: string,
    short_src: string,
    func: (...any) -> (...any),
    what: string,
    currentline: number,
    name: string,
    nups: number,
    numparams: number,
    is_varargs: number
}

declare getinfo:
    (<A..., R...>(func: (A...) -> R...) -> GetinfoReturnTypeFunc<A..., R...>) &
    (level: number) -> GetinfoReturnTypeLvl

export type _debug = { 
    getconstants: (func: (...any) -> (...any) | number) -> { number | string | boolean | nil },
    getconstant:  (func: (...any) -> (...any) | number, index: number) -> number | string | boolean | nil,
    setconstant:  (func: (...any) -> (...any) | number, index: number, value: number | string | boolean | nil) -> (),
    getupvalues:  (func: (...any) -> (...any) | number) -> { any },
    getupvalue:   (func: (...any) -> (...any) | number, index: number) -> any,
    setupvalue:   (func: (...any) -> (...any) | number, index: number, value: any) -> (),
    getstack:     (level: number, index: number?) -> any | { any },
    setstack:     (level: number, index: number, value: any) -> (),
    getprotos:    (func: (...any) -> (...any) | number) -> { (...any) -> (...any) },
    getinfo: typeof(getinfo),    
    getproto:
    ((func: (...any) -> (...any) | number, index: number, activated: true) -> { (...any) -> (...any) }) &
    ((func: (...any) -> (...any) | number, index: number, activated: false?) -> (...any) -> (...any)),
    info:         ((level: number, options: string) -> ...any) & (<A1..., R1...>(func: (A1...) -> R1..., options: string) -> ...any),
    traceback: typeof(debug.traceback)
}

export type Circle = {
    NumSides: number,
    Radius: number,
    Position: Vector2,
    Thickness: number,
    Filled: boolean
} & DrawingClass

export type Line = {
    From: Vector2,
    To: Vector2,
    Thickness: number
}

export type Image = {
    Data: string,
    Size: Vector2,
    Position: Vector2,
    Rounding: Vector2
}

export type Square = {
    Size: Vector2,
    Position: Vector2,
    Thickness: number,
    Filled: boolean   
}

export type Quad = {
    PointA: Vector2,
    PointB: Vector2,
    PointC: Vector2,
    PointD: Vector2,
    Thickness: number,
    Filled: boolean
}

export type Triangle = {
    PointA: Vector2,
    PointB: Vector2,
    PointC: Vector2,
    Thickness: number,
    Filled: boolean
}

export type Text = {
    Text: string,
    TextBounds: Vector2,
    Font: string, -- idc
    Size: number,
    Position: Vector2,
    Center: boolean,
    Outline: boolean,
    OutlineColor: Color3
}

export type _WebSocket = {
    connect: (url: string) -> WebSocketClass
} 

export type Drawing = {
    new:   ((type: "Circle") -> Circle) &
           ((type: "Square") -> Square) &
           ((type: "Quad") -> Quad) &
           ((type: "Line") -> Line) &
           ((type: "Triangle") -> Triangle) &
           ((type: "Image") -> Image) &
           ((type: "Text") -> Text),
    Fonts: {[any]: any} -- nbgaf abt text or fonts or any of that shit
}

declare workspace: {[any]: any}
declare Drawing: Drawing
declare WebSocket: _WebSocket
declare debug: _debug
declare getconstants: typeof(debug.getconstants)
declare getconstant: typeof(debug.getconstant)
declare setconstant: typeof(debug.setconstant)
declare getupvalues: typeof(debug.getupvalues)
declare getupvalue: typeof(debug.getupvalue)
declare setupvalue: typeof(debug.setupvalue)
declare getstack: typeof(debug.getstack)
declare setstack: typeof(debug.setstack)
declare getprotos: typeof(debug.getprotos)
declare getproto: typeof(debug.getproto)
declare traceback: typeof(debug.traceback)

export type FunctionFilterOptions = {
    Name: string?,
    IgnoreExecutor: boolean?,
    Hash: string?,
    Constants: { string }?,
    Upvalues: { any }?
}

export type TableFilterOptions = {
    Keys: { [any]: any }?,
    Values: { [any]: any }?,
    KeyValuePairs: { [any]: any }?,
    Metatable: { [any]: any }?,
}

export type ReturnType = (...any) -> (...any) | { [any]: any }

declare filtergc: 
    ((filter_type: "function", filter_options: FunctionFilterOptions, return_one: boolean?) -> ReturnType? | { ReturnType }) & 
    ((filter_type: "table", filter_options: TableFilterOptions, return_one: boolean?) -> ReturnType? | { ReturnType })

declare getgc:
    ((include_tables: true) -> { { any } | (...any) -> (...any) | userdata }) &
    ((include_tables: false?) -> { (...any) -> (...any) | userdata })


declare function rconsolehide(): ()
declare function rconsoleclose(): ()
declare function rconsoledestroy(): ()
declare function rconsoleprint(text: string): ()
declare function rconsoleclear(): ()
declare function rconsoleinfo(text: string): ()
declare function rconsolewarn(text: string): ()
declare function rconsoleerr(text: string): ()

declare function queue_on_teleport(file: string): ()
declare function newlclosure<A..., R...>(func: (A...) -> R...): (A...) -> R...
declare function setrenderproperty(object: Drawing, property: string, value: any): ()
declare function cleardrawcache(): ()
declare function getrenderproperty(object: Drawing, property: string): any
declare function isrenderobj(obj: any): boolean
declare function setclipboard(data: string | number): ()
declare set_clipboard: typeof(setclipboard)
declare toclipboard: typeof(setclipboard)
declare to_clipboard: typeof(setclipboard)
declare function request(options: Request): Response
declare function isscriptable(inst: Instance, property: string): boolean
declare function setscriptable(inst: Instance, property: string, state: boolean): boolean | nil
declare function hookmetamethod(obj: { [any]: any } | Instance, metamethod_name: string, hook: (...any) -> (...any)): (...any) -> (...any)
declare function restorefunction(func: (...any) -> (...any)): ()
declare function decompile(src: BaseScript | ModuleScript | (...any) -> (...any)): string
declare function getscriptname(script: BaseScript | ModuleScript): string
declare function getreg(): { [any]: any }
declare function identifyexecutor(): (string, string)
declare function cloneref<T>(object: T & Instance): T
declare function replicatesignal(signal: RBXScriptSignal, ...: any?)
declare function firesignal(signal: RBXScriptSignal, ...: any?)
declare function getgenv(): { [any]: any }
declare function checkcaller(): boolean
declare function getcallingscript(): BaseScript | ModuleScript
declare function getnamecallmethod(): string
declare function compareinstances(inst1: Instance, inst2: Instance): boolean
declare function lz4compress(str: string): string
declare function lz4decompress(str: string, am: number): string
declare function getcallbackvalue(inst: Instance, callback: string): (...any) -> (...any)
declare function clonefunction<A..., R...>(function_to_clone: (A...) -> R...): (A...) -> R...
declare function newcclosure<A..., R...>(function_to_wrap: (A...) -> R...): (A...) -> R...
declare function iscclosure(func: (...any) -> (...any)): boolean
declare function islclosure(func: (...any) -> (...any)): boolean
declare function hookfunction<A1..., R1..., A2..., R2...>(function_to_hook: (A1...) -> R1..., function_hook: (A2...) -> R2...): (A1...) -> R1...
declare function isexecutorclosure(func: (...any) -> (...any)): boolean
declare function getfunctionhash(function_to_hash: (...any) -> (...any)): string
declare function LPH_NO_VIRTUALIZE(function_to_wrap: (...any) -> (...any)): (...any) -> (...any)
declare function IB_NO_VIRTUALIZE(function_to_wrap: (...any) -> (...any)): (...any) -> (...any)
declare function getrenv(): { [any]: any }
declare function writefile(path: string, data: string): ()
declare function readfile(path: string): string
declare function listfiles(path: string): { string }
declare function isfile(path: string): boolean
declare function appendfile(path: string, contents: string): ()
declare function delfile(path: string): ()
declare function loadfile<A...>(path: string): ((A...) -> any | nil, string?)
declare function makefolder(path: string): ()
declare function mousemoverel(x: number, y: number)
declare function isfolder(path: string): boolean
declare function delfolder(path: string): ()
declare function getcustomasset(path: string): string
declare function getinstances(): { Instance }
declare function getnilinstances(): { Instance }
declare function gethui(): Instance
declare function fireclickdetector(object: ClickDetector, distance: number?, event: string?): ()
declare function fireproximityprompt(object: ProximityPrompt): ()
declare function firetouchinterest(part: BasePart, part2: BasePart, toggle: boolean | number): ()
declare function getrawmetatable(object: any): { [any]: any }
declare function setrawmetatable<T>(object: T & any, metatable: { any } | nil): T
declare function setreadonly(table: { any }, state: boolean): ()
declare function isreadonly(table: { any }): boolean
declare function gethiddenproperty(instance: Instance, property_name: string): (any, boolean)
declare function sethiddenproperty(instance: Instance, property_name: string, property_value: any): boolean
declare function setscriptable(object: Instance, property: string, state: boolean): boolean | nil
declare function checkcaller(): boolean
declare function setthreadidentity(id: number): ()
declare function getthreadidentity(): number
declare function getscriptbytecode(script: BaseScript | ModuleScript): string | nil
declare function getscripthash(script: BaseScript | ModuleScript): string | nil
declare function getscriptclosure(script: BaseScript | ModuleScript): ((...any) -> (...any))
declare function getsenv(script: BaseScript | ModuleScript): { [any]: any }
declare function getscripts(): { BaseScript | ModuleScript }
declare function getrunningscripts(): { BaseScript | ModuleScript }
declare function getloadedmodules(): { ModuleScript }
declare function getcallingscript(): BaseScript | ModuleScript | nil
declare function getthreadidentity(): number
declare function setthreadidentity(input: number): ()
declare function loadstring<A...>(src: string, chunkname: string?): ((A...) -> any | nil, string?)
declare function getconnections(signal: RBXScriptSignal): { Connection }
declare function base64decode(data: string): string
declare function base64encode(data: string): string
declare function httpget(url: string): string