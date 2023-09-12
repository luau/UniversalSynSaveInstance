local finder, globalcontainer = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/UniversalMethodFinder.luau", true),
	"UniversalMethodFinder"
)()

local b64encode = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/Libraries/Hash.lua"),
	"HashLib"
)().base64_encode

finder({
	appendfile = '(...):find("file",nil,true) and (...):find("append",nil,true)',
	decompile = '(...):find("decomp",nil,true) or (...):find("assembl",nil,true)',
	getnilinstances = '(...):find("nil")',
	getspecialinfo = '(...):find("get",nil,true) and (...):find("spec",nil,true)',
	writefile = '(...):find("file",nil,true) and (...):find("write",nil,true)',
}, true)

if not globalcontainer.getspecialinfo then
	globalcontainer.getspecialinfo = function(instance)
		local props = {
			["MeshPart"] = {
				"PhysicsData",
				"InitialSize",
			},
			["UnionOperation"] = {
				"AssetId",
				"ChildData",
				"FormFactor",
				"InitialSize",
				"MeshData",
				"PhysicsData",
			},
			["Terrain"] = {
				"SmoothGrid",
				"MaterialColors",
			},
		}
		return props[instance.ClassName] or {}
	end
end

local ldeccache = {}

local saveinstance = function(...)
	local buffersize
	local placename
	local savebuffer
	local stlgui

	local OPTIONS = {
		mode = "optimized", -- Change this to invalid mode like "custom" if you only want extrainstances
		noscripts = false,
		scriptcache = true,
		timeout = 30,
		--* New:
		NilInstances = true,
		IsolateStarterPlayer = nil,
		ExtraInstances = nil,
	}
	do
		local Input = ...
		if type(Input) == "table" then
			for key, value in Input do
				if OPTIONS[key] ~= nil then
					OPTIONS[key] = value
				end
			end
		end
	end

	local rwait
	do
		local rswait = game:GetService("RunService").RenderStepped
		rwait = function()
			return rswait:Wait()
		end
	end

	local SpecialProperties = {
		UnionOperation = {
			AssetId = "Content",
			ChildData = "BinaryString",
			FormFactor = "Token",
			InitialSize = "Vector3",
			MeshData = "BinaryString",
			PhysicsData = "BinaryString",
		},
		MeshPart = {
			InitialSize = "Vector3",
			PhysicsData = "BinaryString",
		},
		Terrain = {
			SmoothGrid = "BinaryString",
			MaterialColors = "BinaryString",
		},
	}

	local ldecompile
	do
		if OPTIONS.noscripts then
			ldecompile = function(Script)
				return "-- " .. Script:GetFullName() .. " not decompiled because the option is off"
			end
		else
			ldecompile = function(Script)
				-- local name = scr.ClassName .. scr.Name
				do
					if OPTIONS.scriptcache then
						local Cached = ldeccache[Script]
						if Cached then
							return Cached
						end
					else
						rwait()
					end
				end
				local ok, result = pcall(globalcontainer.decompile, Script, OPTIONS.timeout, OPTIONS.timeout)
				ldeccache[Script] = result
				return ok and result or "--[[\n" .. result .. "\n--]]"
			end
		end
	end
	local ToSaveList
	do
		local mode = tostring(OPTIONS.mode):lower()
		local tmp = OPTIONS.ExtraInstances or {}

		if mode == "full" then
			local _list_0 = game:GetChildren()
			for _index_0 = 1, #_list_0 do
				local x = _list_0[_index_0]
				table.insert(tmp, x)
			end
		elseif mode == "optimized" then
			local _list_0 = {
				"Chat",
				"InsertService",
				"JointsService",
				"Lighting",
				"ReplicatedFirst",
				"ReplicatedStorage",
				"ServerStorage",
				"StarterGui",
				"StarterPack",
				"StarterPlayer",
				"Teams",
				"Workspace",
			}
			for _index_0 = 1, #_list_0 do
				local x = _list_0[_index_0]
				table.insert(tmp, game:GetService(x))
			end
		elseif mode == "scripts" then
			local hierarchy = game:GetDescendants()

			for _index_0 = 1, #hierarchy do
				local s = hierarchy[_index_0]
				if s.ClassName == "LocalScript" or s.ClassName == "ModuleScript" then
					local top = s
					while top.Parent and top.Parent ~= game do
						top = top.Parent
					end
					if top.Parent then
						table.insert(tmp, top)
					end
				end
			end
		end
		ToSaveList = tmp
	end
	local InstancesBlacklist
	do
		local tmp = {}
		for _, v in
			{
				"BubbleChat",
				"Camera",
				"CameraScript",
				"ChatScript",
				"ControlScript",
				"ClientChatModules",
				"ChatServiceRunner",
				"ChatModules",
			}
		do
			tmp[v] = true
		end
		InstancesBlacklist = tmp
	end
	local NilInstancesBlacklist = {
		Animator = function(instance)
			local AnimationController = Instance.new("AnimationController")
			AnimationController.Name = "Animator has to be placed under Humanoid or AnimationController"
			instance.Parent = AnimationController
			return AnimationController
		end,
	}

	local pattern = "[\"&<>']"
	local escapes = {
		['"'] = "&quot;",
		["&"] = "&amp;",
		["<"] = "&lt;",
		[">"] = "&gt;",
		["'"] = "&apos;",
	}
	local FetchAPI = function()
		local API_Dump_Version = game:HttpGet("http://setup.roblox.com/versionQTStudio", true)
		local API_Dump_Url = "http://setup.roblox.com/" .. API_Dump_Version .. "-API-Dump.json"
		local API_Dump = game:HttpGet(API_Dump_Url, true)
		local API_Classes = game:GetService("HttpService"):JSONDecode(API_Dump).Classes

		local ClassList = {}

		for _index_0 = 1, #API_Classes do
			local Class = API_Classes[_index_0]
			local ClassMembers = Class.Members
			local ClassInfo = {}

			local ClassName = Class.Name

			ClassInfo.Name = ClassName
			ClassInfo.Tags = Class.Tags
			ClassInfo.Superclass = Class.Superclass
			ClassInfo.Properties = {}

			for _index_1 = 1, #ClassMembers do
				local Member = ClassMembers[_index_1]
				if Member.MemberType == "Property" then
					local Serialization = Member.Serialization
					if Serialization.CanLoad then
						local Allowed = true

						local MemberTags = Member.Tags

						if MemberTags then
							for _index_2 = 1, #MemberTags do
								local Tag = MemberTags[_index_2]
								if Tag == "Deprecated" or Tag == "NotScriptable" then
									Allowed = false
								end
							end
						end
						if Allowed then
							table.insert(ClassInfo.Properties, {
								Name = Member.Name,
								ValueType = Member.ValueType.Name,

								Special = false,
							})
						end
					end
				end
			end

			ClassList[ClassName] = ClassInfo
		end
		for ClassName, propertyList in SpecialProperties do
			local Properties = ClassList[ClassName].Properties
			for Property, ValueType in propertyList do
				table.insert(Properties, {
					Name = Property,
					ValueType = ValueType,
					Special = true,
				})
			end
		end
		return ClassList
	end
	local ClassList
	do
		local ok, result = pcall(FetchAPI)
		if ok then
			ClassList = result
		else
			warn(result)
			return
		end
	end
	local properties = setmetatable({}, {
		__index = function(self, name)
			local proplist = {}
			local layer = ClassList[name]
			while layer do
				local _list_0 = layer.Properties
				for _index_0 = 1, #_list_0 do
					local p = _list_0[_index_0]
					table.insert(proplist, p)
				end
				layer = ClassList[layer.Superclass]
			end
			table.sort(proplist, function(a, b)
				return a.Name < b.Name
			end)
			self[name] = proplist
			return proplist
		end,
	})
	local identifiers = setmetatable({
		count = 0,
	}, {
		__index = function(self, obj)
			self.count += 1
			local rbxi = "RBX" .. self.count
			self[obj] = rbxi
			return rbxi
		end,
	})
	local typesizeround = function(s)
		return math.floor(buffersize / (0x400 ^ s) * 10) / 10
	end
	local getsizeformat = function()
		local res
		for i, v in
			{
				"b",
				"kb",
				"mb",
				"gb",
				"tb",
			}
		do
			if buffersize < 0x400 ^ i then
				res = typesizeround(i - 1) .. v
				break
			end
		end
		return res
	end
	local getsafeproperty = function(i, name)
		return i[name]
	end
	local getplacename = function()
		local name = "place" .. game.PlaceId
		-- pcall(function()
		-- 	name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or name
		-- end)
		-- return name:gsub("[^%w%s_]", "_") .. ".rbxlx"
		return name .. ".rbxlx"
	end
	local savecache = function()
		local savestr = table.concat(savebuffer)
		globalcontainer.appendfile(placename, savestr)
		buffersize += #savestr
		stlgui.Text = string.format("Saving (%s)", getsizeformat())
		savebuffer = {}
		return rwait()
	end
	local savehierarchy
	savehierarchy = function(h)
		local savepr = #savebuffer
		if savepr > 0x1600 then
			savecache()
		end
		for _index_0 = 1, #h do
			local _continue_0 = false
			repeat
				local instance = h[_index_0]
				local specialProperties
				local ClassName = instance.ClassName

				if instance.RobloxLocked or InstancesBlacklist[instance.Name] or not ClassList[ClassName] then
					_continue_0 = true
					break
				end
				local Properties = properties[ClassName]
				savebuffer[#savebuffer + 1] = '<Item class="'
					.. ClassName
					.. '" referent="'
					.. identifiers[instance]
					.. '"><Properties>'
				for _index_1 = 1, #Properties do
					local _continue_1 = false
					repeat
						local Property = Properties[_index_1]
						local value
						local tag
						local raw
						if Property.Special then
							if not specialProperties then
								specialProperties = globalcontainer.getspecialinfo(instance)
							end
							raw = specialProperties[Property.Name]
							if raw == nil then
								_continue_1 = true
								break
							end
						else
							local isok = Property.Ok
							local _exp_0 = isok
							if nil == _exp_0 then
								local ok, result = pcall(getsafeproperty, instance, Property.Name)
								Property.Ok = ok
								if ok then
									raw = result
								else
									_continue_1 = true
									break
								end
							elseif true == _exp_0 then
								raw = instance[Property.Name]
							elseif false == _exp_0 then
								_continue_1 = true
								break
							end
						end
						local ValueType = Property.ValueType
						if "BrickColor" == ValueType then
							tag = "int"
							value = raw.Number
						elseif "Color3" == ValueType then
							tag = "Color3"
							value = "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>"
						elseif "ColorSequence" == ValueType then
							tag = "ColorSequence"
							local ConvertedArray = {}
							local Keypoints = raw.Keypoints
							for _index_2 = 1, #Keypoints do
								local v = Keypoints[_index_2]
								local Value = v.Value
								ConvertedArray[#ConvertedArray + 1] = v.Time
									.. " "
									.. Value.R
									.. " "
									.. Value.G
									.. " "
									.. Value.B
									.. " 0"
							end
							value = table.concat(ConvertedArray, " ")
						elseif "Content" == ValueType then
							tag = "Content"
							value = "<url>" .. raw:gsub(pattern, escapes) .. "</url>"
						elseif "BinaryString" == ValueType then
							tag = "BinaryString"
							if Property.Name == "SmoothGrid" or Property.Name == "MaterialColors" then
								value = "<![CDATA[" .. b64encode(raw) .. "]]>"
							else
								value = b64encode(raw)
							end
						elseif "CoordinateFrame" == ValueType then
							local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
							tag = "CoordinateFrame"
							value = "<X>"
								.. X
								.. "</X>"
								.. "<Y>"
								.. Y
								.. "</Y>"
								.. "<Z>"
								.. Z
								.. "</Z>"
								.. "<R00>"
								.. R00
								.. "</R00>"
								.. "<R01>"
								.. R01
								.. "</R01>"
								.. "<R02>"
								.. R02
								.. "</R02>"
								.. "<R10>"
								.. R10
								.. "</R10>"
								.. "<R11>"
								.. R11
								.. "</R11>"
								.. "<R12>"
								.. R12
								.. "</R12>"
								.. "<R20>"
								.. R20
								.. "</R20>"
								.. "<R21>"
								.. R21
								.. "</R21>"
								.. "<R22>"
								.. R22
								.. "</R22>"
						elseif "NumberRange" == ValueType then
							tag = "NumberRange"
							value = raw.Min .. " " .. raw.Max
						elseif "NumberSequence" == ValueType then
							tag = "NumberSequence"
							local ob = {}
							local Keypoints = raw.Keypoints
							for _index_2 = 1, #Keypoints do
								local v = Keypoints[_index_2]
								ob[#ob + 1] = v.Time .. " " .. v.Value .. " " .. v.Envelope
							end
							value = table.concat(ob, " ")
						elseif "PhysicalProperties" == ValueType then
							tag = "PhysicalProperties"
							if raw then
								value = "<CustomPhysics>true</CustomPhysics>"
									.. "<Density>"
									.. raw.Density
									.. "</Density>"
									.. "<Friction>"
									.. raw.Friction
									.. "</Friction>"
									.. "<Elasticity>"
									.. raw.Elasticity
									.. "</Elasticity>"
									.. "<FrictionWeight>"
									.. raw.FrictionWeight
									.. "</FrictionWeight>"
									.. "<ElasticityWeight>"
									.. raw.ElasticityWeight
									.. "</ElasticityWeight>"
							else
								value = "<CustomPhysics>false</CustomPhysics>"
							end
						elseif "ProtectedString" == ValueType then
							tag = "ProtectedString"
							if Property.Name == "Source" then
								if instance.ClassName == "Script" then
									value = "-- Server scripts can NOT be decompiled\n"
								else
									value = ldecompile(instance)
								end
							else
								value = raw
							end
							value = value:gsub(pattern, escapes)
						elseif "Rect2D" == ValueType then
							tag = "Rect2D"

							local Min, Max = raw.Min, raw.Max

							value = "<min>"
								.. "<X>"
								.. Min.X
								.. "</X>"
								.. "<Y>"
								.. Min.Y
								.. "</Y>"
								.. "</min>"
								.. "<max>"
								.. "<X>"
								.. Max.X
								.. "</X>"
								.. "<Y>"
								.. Max.Y
								.. "</Y>"
								.. "</max>"
						elseif "UDim2" == ValueType then
							tag = "UDim2"

							local X, Y = raw.X, raw.Y

							value = "<XS>"
								.. X.Scale
								.. "</XS>"
								.. "<XO>"
								.. X.Offset
								.. "</XO>"
								.. "<YS>"
								.. Y.Scale
								.. "</YS>"
								.. "<YO>"
								.. Y.Offset
								.. "</YO>"
						elseif "Vector2" == ValueType then
							tag = "Vector2"
							value = "<X>" .. raw.X .. "</X>" .. "<Y>" .. raw.Y .. "</Y>"
						elseif "Vector3" == ValueType then
							tag = "Vector3"
							value = "<X>" .. raw.X .. "</X>" .. "<Y>" .. raw.Y .. "</Y>" .. "<Z>" .. raw.z .. "</Z>"
						elseif "bool" == ValueType then
							tag = "bool"
							value = tostring(raw)
						elseif "double" == ValueType then
							tag = "float"
							value = raw
						elseif "float" == ValueType then
							tag = "float"
							value = raw
						elseif "int" == ValueType then
							tag = "int"
							value = raw
						elseif "string" == ValueType then
							tag = "string"
							value = raw:gsub(pattern, escapes)
						else
							if Property.ValueType:sub(1, 6) == "Class:" then
								tag = "Ref"
								if raw then
									value = identifiers[raw]
								else
									value = "null"
								end
							elseif typeof(raw) == "EnumItem" then
								tag = "token"
								value = raw.Value
							end
						end
						if tag then
							savebuffer[#savebuffer + 1] = "<"
								.. tag
								.. ' name="'
								.. Property.Name
								.. '">'
								.. value
								.. "</"
								.. tag
								.. ">"
						end
						_continue_1 = true
					until true
					if not _continue_1 then
						break
					end
				end
				savebuffer[#savebuffer + 1] = "</Properties>"
				local chl = instance:GetChildren()
				if #chl ~= 0 then
					savehierarchy(chl)
				end
				savebuffer[#savebuffer + 1] = "</Item>"
				_continue_0 = true
			until true
			if not _continue_0 then
				break
			end
		end
	end
	local savefolder = function(n, h)
		local Ref = identifiers[Instance.new("Folder")]
		table.insert(
			savebuffer,
			'<Item class="Folder" referent="'
				.. Ref
				.. '"><Properties><string name="Name">'
				.. n
				.. "</string></Properties>"
		)
		savehierarchy(h)
		return table.insert(savebuffer, "</Item>")
	end

	local savegame = function()
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local LocalPlayer_Children = LocalPlayer:GetChildren()
		local nilinstances
		if OPTIONS.NilInstances then
			local NilInstances = globalcontainer.getnilinstances()
			nilinstances = table.clone(NilInstances) -- Precaution in case this table gets updated live and is shared (table ref)
			for index, instance in NilInstances do
				if instance == game then
					table.remove(nilinstances, index)
					-- break
				else
					local ClassName = instance.ClassName

					local Fix = NilInstancesBlacklist[ClassName]
					if Fix then -- *
						nilinstances[index] = Fix(instance)
						continue
					end

					local Tags = ClassList[ClassName].Tags

					if Tags and table.find(Tags, "Service") then
						instance.Parent = game
						table.remove(nilinstances, index)
						continue
					end
				end
			end
		end
		globalcontainer.writefile(
			placename,
			'<roblox xmlns:xmime="https://www.w3.org/2005/05/xmlmime" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="https://www.roblox.com/roblox.xsd" version="4"><Meta name="ExplicitAutoJoints">true</Meta><External>null</External><External>nil</External>'
		)
		savehierarchy(ToSaveList)
		savefolder("LocalPlayer", LocalPlayer_Children)
		if nilinstances then
			savefolder("Nil Instances", nilinstances)
		end
		table.insert(savebuffer, "</roblox>")
		return savecache()
	end
	do
		stlgui = Instance.new("TextLabel")
		stlgui.BackgroundTransparency = 1
		stlgui.Font = Enum.Font.Code
		stlgui.Name = "TextLabel"
		stlgui.Position = UDim2.new(0.7, 0, 0, -20)
		stlgui.Size = UDim2.new(0.3, 0, 0, 20)
		stlgui.Text = "Starting..."
		stlgui.TextColor3 = Color3.new(1, 1, 1)
		stlgui.TextScaled = true
		stlgui.TextStrokeTransparency = 0.7
		stlgui.TextXAlignment = Enum.TextXAlignment.Right
		stlgui.TextYAlignment = Enum.TextYAlignment.Top
		stlgui.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
		game:GetService("Debris"):AddItem(stlgui, 30)
	end
	do
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local PlayerList = Players:GetPlayers()
		for _index_0 = 1, #PlayerList do
			local Player = PlayerList[_index_0]
			if Player ~= LocalPlayer then
				InstancesBlacklist[Player.Name] = true
			end
		end
	end
	do
		placename = getplacename()
		buffersize = 0
		savebuffer = {}
		local elapse_t = os.clock()
		local ok, err = pcall(savegame)
		elapse_t = os.clock() - elapse_t

		local Log10 = math.log10(elapse_t)

		if ok then
			stlgui.Text = string.format("Saved! Time %d seconds; Size %s", elapse_t, getsizeformat())
			task.wait(Log10 * 2)
		else
			stlgui.Text = "Failed! Check F9 console for more info."
			warn("Error encountered while saving")
			warn("Information about error:")
			warn(err)
			task.wait(Log10 + 3)
		end
		return stlgui:Destroy()
	end
end

return saveinstance
