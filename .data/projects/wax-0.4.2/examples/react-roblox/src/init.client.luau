local Players = game:GetService("Players")

local React = require(script.ReactLuau.React)
local ReactRoblox = require(script.ReactLuau.ReactRoblox)

local e = React.createElement

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Element = e("ScreenGui", {}, {
    e("TextLabel", {
        Text = "Hello, Wax & Roact17! (react-roblox)",
        TextSize = 32,
        Font = Enum.Font.Gotham,
        Size = UDim2.fromScale(1, 1),
    })
})

local root = ReactRoblox.createRoot(Instance.new("Folder"))
root:render(ReactRoblox.createPortal(Element, PlayerGui))
