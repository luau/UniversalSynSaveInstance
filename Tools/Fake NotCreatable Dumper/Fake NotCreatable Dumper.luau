-- Dumps all properties that get changed when NotScriptable property is changed. This means they're somehow related to it and/or are in sync with it
-- Doesnt get everything!
local service = setmetatable({}, {
	__index = function(Self, Name)
		local Service = game:GetService(Name)
		Self[Name] = Service
		return Service
	end,
})
local function ArrayToDictionary(Table, HybridMode)
	local tmp = table.create(#Table)

	if HybridMode == "adjust" then
		for Some1, Some2 in Table do
			if type(Some1) == "number" then
				tmp[Some2] = true
			elseif type(Some2) == "table" then
				tmp[Some1] = ArrayToDictionary(Some2, "adjust") -- Some1 is Class, Some2 is Name
			else
				tmp[Some1] = Some2
			end
		end
	else
		for _, Key in Table do
			tmp[Key] = true
		end
	end

	return tmp
end
do
	-- TODO: More @ https://github.com/Dekkonot/rbx-instance-serializer/blob/23f772f6f78af879a21faa9fea3e6c4f93d1cdee/src/API.lua#L19

	local function FetchAPI()
		local API_Dump_Url =
			"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
		local API_Dump = game:HttpGet(API_Dump_Url, true)
		local API_Classes = service.HttpService:JSONDecode(API_Dump).Classes

		local classList = {}
		for _index_0 = 1, #API_Classes do
			local API_Class = API_Classes[_index_0]

			local Class = {}

			local ClassName = API_Class.Name

			local ClassTags = API_Class.Tags

			if ClassTags then
				ClassTags = ArrayToDictionary(ClassTags)
			end

			-- ClassInfo.Name = ClassName
			Class.Tags = ClassTags -- or {}
			local Superclass = API_Class.Superclass
			Class.Superclass = Superclass

			classList[ClassName] = Class
		end

		-- classList.Instance.Properties.Parent = nil -- ? Not sure if this is a better option than filtering throguh properties to remove this

		return classList
	end

	local api = FetchAPI()
	local keys = {}
	for classname in api do
		table.insert(keys, classname)
	end
	table.sort(keys)
	local s = `Varies per executor; Tested on {identifyexecutor()}\n\n`
	for _, ClassName in keys do
		local prevsiz = #s
		local ClassInfo = api[ClassName]
		local Tags = ClassInfo.Tags
		local NotCreatable = Tags and Tags.NotCreatable

		local o, r = pcall(Instance.new, ClassName)

		if NotCreatable and o then
			s ..= ClassName .. " {Fake NotCreatable}\n"
		elseif not (o or NotCreatable) then
			s ..= ClassName .. " {Fake Creatable}\n"
			print(ClassName, r)
		elseif typeof(r) ~= "Instance" then
			warn(ClassName, r)
		end

		if prevsiz ~= #s then
			s ..= "\n"
		end
	end
	warn("Finished")
	-- warn(s)
	task.wait(0.5)
	print(s)
	setclipboard(s)
	-- writefile("!missing.txt", game:GetService("HttpService"):JSONEncode(t))
end
