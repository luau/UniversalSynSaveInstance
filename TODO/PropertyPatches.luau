--!strict

-- ! Source: https://github.com/MaximumADHD/Roblox-File-Format/blob/main/Plugins/GenerateApiDump/PropertyPatches.lua
-- ! Extras: https://github.com/rojo-rbx/rbx-dom/tree/master/patches
-- ! Extras: https://github.com/Dekkonot/rbx-instance-serializer/blob/23f772f6f78af879a21faa9fea3e6c4f93d1cdee/src/API.lua#L19

export type GetSet = string | {
	Get: string,
	Set: string,
	Flags: string?,
}

export type Patch = {
	Redirect: { [string]: GetSet }?,
	Defaults: { [string]: any }?,
}

-- strict type reaffirmation?
-- this is some bug with Luau.

local function GetSet(getSet: GetSet): GetSet
	return getSet
end

local function UseColor3(propName: string): GetSet
	return {
		Get = string.format("BrickColor.FromColor3(%s)", propName),
		Set = propName .. " = value?.Color",
	}
end

local GuiTextMixIn: Patch = {
	Redirect = {
		Font = GetSet({
			Get = "FontUtility.GetLegacyFont(FontFace)",
			Set = "FontUtility.TryGetFontFace(value, out FontFace)",
		}),
	},
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local PropertyPatches: { [string]: Patch } = {

	AudioSearchParams = {
		Redirect = {
			AudioSubtype = GetSet("AudioSubType"),
		},
	},

	BallSocketConstraint = {
		-- Why does this even exist?
		Redirect = {
			MaxFrictionTorque = GetSet("MaxFrictionTorqueXml"),
		},
	},

	BasePart = {
		Redirect = {
			Position = GetSet({
				Get = "CFrame.Position",
				Set = "CFrame = new CFrame(value) * CFrame.Rotation",
			}),

			MaterialVariant = GetSet("MaterialVariantSerialized"),
			BrickColor = UseColor3("Color"),
			Color = GetSet("Color3uint8"),
		},
	},

	FormFactorPart = {

		Redirect = {
			FormFactor = GetSet("formFactorRaw"),
		},
	},

	Humanoid = {

		Redirect = {
			Health = GetSet("Health_XML"),
		},
	},

	Sound = {

		Redirect = {

			RollOffMinDistance = GetSet("EmitterSize"),
		},
	},

	Sparkles = {
		Redirect = { Color = GetSet("SparkleColor") },
	},

	TextBox = GuiTextMixIn,
	TextLabel = GuiTextMixIn,
	TextButton = GuiTextMixIn,
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return PropertyPatches

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
