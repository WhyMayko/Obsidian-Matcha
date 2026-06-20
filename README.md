# 🍵 Obsidian Matcha

Welcome to **Obsidian Matcha**, a high-performance UI Library for Roblox exploits!

Obsidian Matcha is a completely reworked and optimized version of the original [Obsidian / LinoriaLib](https://github.com/deividcomsono/Obsidian) framework. While the original version relied on Roblox's native GUI `Instance` system (ScreenGui, Frames, etc.), **Obsidian Matcha uses the raw `Drawing` API** to render the entire interface. 

This means:
- 🚀 **Maximum Performance**: By bypassing the Roblox UI engine, rendering is incredibly lightweight.
- 🛡️ **Extremely Stealthy**: The UI doesn't exist in `CoreGui` or `PlayerGui`, making it virtually invisible to game anti-cheats that scan the GUI tree.
- ✨ **Pixel-Perfect Aesthetics**: The same beautiful design you love, recreated with pure mathematics and drawing primitives.

## 📦 Features
- Full support for Tabs, Groupboxes, Toggles, Sliders, Dropdowns, ColorPickers, and Keybinds.
- Built-in **ThemeManager** for complete customization.
- Built-in **SaveManager** for seamless configuration saving and loading.
- Animated toggles and interactive elements for a premium feel.
- Custom mouse cursor and keybind listeners.

## 🚀 Getting Started

The best way to learn how to use Obsidian Matcha is by reading the `Example.lua` file provided in this repository. It contains a fully documented, step-by-step guide on how to create windows, tabs, and all the available widgets.

Here is a quick snippet to get you started:

```lua
local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

-- Load the Library
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- Create a Window
local Window = Library:CreateWindow({
    Title = "My Script",
    Footer = "Matcha Edition",
    NotifySide = "Right",
    ShowCustomCursor = true,
})

-- Add a Tab and Groupbox
local MainTab = Window:AddTab("Main", "user")
local GroupBox = MainTab:AddLeftGroupbox("Functions")

-- Add a Toggle
GroupBox:AddToggle("MyToggle", {
    Text = "Aimbot",
    Default = false,
    Callback = function(Value)
        print("Toggle changed:", Value)
    end,
})

-- Unload button
GroupBox:AddButton("Unload", function()
    Library:Unload()
end)
```

## ⚙️ Important Notes on SaveManager

When using `SaveManager` to save your users' configurations, remember that it automatically captures every interactive element that has an `ID`. 

Make sure you **ignore** settings you don't want to save across configs (like the Menu Keybind itself), instead of whitelisting:
```lua
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
```

---
*Created by Galax / deivid & based on the legendary LinoriaLib.*
