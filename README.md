# Obsidian Matcha

Documentation for Obsidian Matcha, a Drawing API version of the Obsidian/Linoria-style UI library adapted for Matcha.

Obsidian Matcha keeps the public scripting style close to the original Obsidian library while avoiding Roblox `Instance` UI objects. The interface is rendered externally with Drawing objects, so some original features are adapted or simplified for the Matcha Lua VM.

## Introduction

Obsidian Matcha is built for scripts that need a clean UI, themes, configs, keybinds, dropdowns, sliders, color pickers and a keybind menu without creating Roblox UI instances.

The API is modeled after Obsidian and LinoriaLib:

1. Create a window.
2. Add tabs.
3. Add groupboxes.
4. Add UI elements to groupboxes.
5. Use ThemeManager and SaveManager from the addons folder when needed.

## Why Obsidian Matcha?

- Drawing API UI for Matcha
- Obsidian-like scripting style
- ThemeManager with web and local themes
- SaveManager for UI settings/configs
- Keybind menu and key picker modes
- External image and icon support

## Installation

Use the hosted GitHub files:

```lua
local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
```

## Quick Start

```lua
local Window = Library:CreateWindow({
	Title = "mspaint",
	Footer = "version: example",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowSearch = true,
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox")

LeftGroupBox:AddToggle("MyToggle", {
	Text = "This is a toggle",
	Default = true,
	Callback = function(Value)
		print("Toggle changed:", Value)
	end,
})
```

## Structure

```lua
local Tab = Window:AddTab("Main", "user")
local LeftGroupBox = Tab:AddLeftGroupbox("Left")
local RightGroupBox = Tab:AddRightGroupbox("Right")
```

Groupboxes support the common elements:

- `AddLabel`
- `AddButton`
- `AddToggle`
- `AddCheckbox`
- `AddInput`
- `AddSlider`
- `AddDropdown`
- `AddKeyPicker`
- `AddColorPicker`
- `AddDivider`

## Buttons

You can create buttons with various functionalities like `DoubleClick`, `Disabled`, and even attach sub-buttons to them.

```lua
local MyButton = LeftGroupBox:AddButton({
	Text = "Button",
	Func = function()
		print("You clicked a button!")
	end,
	DoubleClick = false,
	Tooltip = "This is the main button",
	Disabled = false,
})

-- Adding a sub-button
local MyButton2 = MyButton:AddButton({
	Text = "Sub button",
	Func = function()
		print("You clicked a sub button!")
	end,
	DoubleClick = true, -- Requires clicking twice
	Tooltip = "This is the sub button",
})

-- Creating a disabled button
local MyDisabledButton = LeftGroupBox:AddButton({
	Text = "Disabled Button",
	Func = function()
		print("This won't trigger.")
	end,
	Disabled = true,
})
```

## Keybinds

Keybinds can use `Toggle`, `Hold` or `Press`.

```lua
LeftGroupBox:AddLabel("Keybind"):AddKeyPicker("KeyPicker", {
	Default = "MB2",
	Mode = "Toggle",
	Text = "Auto lockpick safes",
	NoUI = false,
	Callback = function(Value)
		print("Keybind clicked:", Value)
	end,
})
```

Right-clicking a visible keybind opens the keybind mode popup. You can configure which modes are shown:

```lua
local Window = Library:CreateWindow({
	KeybindModePopup = { "Toggle", "Hold", "Press" },
})

Window:SetKeybindModePopup({ "Toggle", "Press" })
Window:SetKeybindModePopup(false)
```

## DPI Scale

The DPI scale can resize the active window while keeping it centered.

```lua
Library:SetDPIScale(150)
Library:SetDPIScale(100)
Library:SetDPIScale(75)
```

## ThemeManager

```lua
ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs["UI Settings"])
```

Themes are handled separately from configs.

## SaveManager

```lua
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:BuildConfigSection(Tabs["UI Settings"])
```

SaveManager saves config values. Theme values are intentionally kept separate through ThemeManager.

## Example

You can test the entire library and all its features instantly by running the `Example.lua` script in Matcha:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/Example.lua"))()
```

This example script contains a full showcase of:
- hosted Library.lua
- hosted ThemeManager
- hosted SaveManager
- UI Settings tab
- keybind menu
- theme/config setup

## Notes

Obsidian Matcha is not a perfect copy of the original Obsidian because Matcha's Lua VM and Drawing API do not support every Roblox UI feature. The goal is to keep the public API and visual behavior as close as practical while staying compatible with Matcha.
