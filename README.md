# 🍵 Obsidian Matcha

Welcome to **Obsidian Matcha**, an external, high-performance UI Library for Roblox exploits.

Obsidian Matcha is a reworked version of the original [Obsidian / LinoriaLib](https://github.com/deividcomsono/Obsidian). While the original relied on Roblox's native GUI `Instance` system (ScreenGui, Frames, etc.), **Obsidian Matcha uses the raw `Drawing` API** to render the interface. Because it operates externally, it does not create any instances in `CoreGui` or `PlayerGui`.

---

## 📖 Introduction & Quick Start

Obsidian Matcha follows a clean and logical structure. If you are familiar with LinoriaLib or the original Obsidian, you will feel right at home. 

The structure of the UI always follows this hierarchy:
1. **Window**: The main container for your UI.
2. **Tabs**: Pages inside your window.
3. **Groupboxes**: Sections inside your tabs to organize your features.
4. **Elements**: Toggles, Sliders, Dropdowns, Buttons, etc., that go inside your Groupboxes.

### 1. Loading the Library

To start, you need to load the library. Because `TextManager` and `IconManager` are now bundled **inside** `Library.lua`, you only need to load the main library file, along with the Theme and Save managers.

```lua
local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
```

### 2. Creating a Window

Once the library is loaded, you can create the main window.

```lua
local Window = Library:CreateWindow({
    Title = "My Script Hub",
    Footer = "Matcha Edition",
    NotifySide = "Right",
    ShowCustomCursor = true,
})
```

### 3. Creating Tabs & Groupboxes

Inside the window, you create tabs. Then, you divide the tabs into left and right groupboxes to keep things organized.

```lua
-- Create a Tab
local MainTab = Window:AddTab("Main", "user") -- "user" is the icon name

-- Create Groupboxes inside the Tab
local LeftGroupBox = MainTab:AddLeftGroupbox("Aimbot")
local RightGroupBox = MainTab:AddRightGroupbox("Visuals")
```

---

## 🛠️ Adding UI Elements

Now you can populate your groupboxes with elements. Obsidian Matcha provides a rich set of interactive widgets.

### Toggles (Checkboxes)
Used for turning features on and off.
```lua
LeftGroupBox:AddToggle("AimbotToggle", {
    Text = "Enable Aimbot",
    Default = false,
    Tooltip = "Turns on the aimbot feature.",
    Callback = function(Value)
        print("Aimbot is now:", Value)
    end,
})

-- You can fetch the value later using:
-- local state = Library.Toggles.AimbotToggle.Value
```

### Sliders
Used for selecting numeric values.
```lua
LeftGroupBox:AddSlider("AimbotFOV", {
    Text = "Field of View",
    Default = 90,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Compact = false, -- Set to true to hide the title label
    Callback = function(Value)
        print("FOV changed to:", Value)
    end,
})
```

### Dropdowns
Used for selecting one or multiple options from a list.
```lua
RightGroupBox:AddDropdown("TargetPart", {
    Values = { "Head", "Torso", "Legs" },
    Default = 1, -- Selects "Head" by default
    Multi = false, -- Set to true to allow multiple selections
    Text = "Target Part",
    Callback = function(Value)
        print("Selected:", Value)
    end,
})
```

### Buttons
Used for executing single actions. You can also attach secondary "Sub-buttons" to them.
```lua
local MyButton = RightGroupBox:AddButton({
    Text = "Kill All",
    Func = function()
        print("Executing Kill All...")
    end,
    DoubleClick = false,
})

-- Adding a Sub-button right next to it:
MyButton:AddButton({
    Text = "Teleport",
    Func = function()
        print("Teleporting...")
    end,
})
```

### Color Pickers
Used to select a custom color. You can add them to Toggles or directly to the Groupbox via a Label.
```lua
RightGroupBox:AddLabel("ESP Color"):AddColorPicker("EspColor", {
    Default = Color3.new(1, 0, 0),
    Title = "Enemy ESP",
    Transparency = 0,
    Callback = function(Color)
        print("ESP Color changed to:", Color)
    end,
})
```

### Keybinds
Used to assign custom hotkeys. You can attach them to Toggles or Labels.
```lua
LeftGroupBox:AddLabel("Fly Key"):AddKeyPicker("FlyKeybind", {
    Default = 0x46, -- "F" key in Hex
    Mode = "Toggle", -- Modes: Always, Toggle, Hold, Press
    Text = "Toggle Fly",
    Callback = function(Value)
        print("Keybind triggered!", Value)
    end,
})
```

---

## ⚙️ Configuration via SaveManager

Obsidian Matcha has an incredibly powerful `SaveManager` built-in. It automatically collects every single element (Toggles, Sliders, Keybinds, ColorPickers, etc.) that has an ID and saves them into a JSON file so users don't lose their settings.

To properly setup your config and theme system at the end of your script:

```lua
-- Add a settings tab
local SettingsTab = Window:AddTab("UI Settings", "settings")

-- Tell ThemeManager and SaveManager to use our library
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore Theme settings so they don't get mixed into the game configs
SaveManager:IgnoreThemeSettings()

-- Ignore the Menu Keybind itself so users can keep their preferred key across different configs
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

-- Build the config menus
SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)
```

## 📝 See it in Action
For a complete, copy-pasteable demonstration of every single feature available in the library, refer to the `Example.lua` file included in this repository.

---
*Created by Galax / deivid & based on the legendary LinoriaLib.*
