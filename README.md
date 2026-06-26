# Obsidian Matcha

Obsidian Matcha is a Drawing API UI library for Matcha.

## Quick Start

```lua
local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

local function loadGalax(path)
    local module = loadstring(game:HttpGet(repo .. path))()
    if type(module) ~= "table" then
        error(path .. " did not export", 2)
    end
    return module
end

local Library = loadGalax("Library.lua")

local Window = Library:CreateWindow({
    Title = "My Script",
    Footer = "example",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowSearch = true,
    Resizable = true,
    MenuKey = 0x70,
})

local Main = Window:AddTab("Main", "user")
local Group = Main:AddLeftGroupbox("Main")

Group:AddToggle("Enabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})
```

Run the full example:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/Example.lua"))()
```

## Loading Addons

```lua
local ThemeManager = loadGalax("addons/ThemeManager.lua")
local SaveManager = loadGalax("addons/SaveManager.lua")
local EssentialsManager = loadGalax("addons/EssentialsManager.lua")
```

Core addons are loaded by `Library.lua`: TextManager, IconManager, AnimationManager, DialogManager, NotificationManager, and ValueWatcher.

## Supported UI

- Windows, tabs, groupboxes and tabboxes
- Toggles and checkboxes
- Buttons and sub-buttons
- Labels and dividers
- Sliders with presets
- Inputs/textboxes
- Dropdowns, searchable dropdowns and multi dropdowns
- Color pickers and color picker pairs
- Key pickers and key tab/key box
- Notifications and draggable labels
- ThemeManager, SaveManager and EssentialsManager

## Common Patterns

Toggle with addons:

```lua
Group:AddToggle("Aim", { Text = "Aim", Default = false })
    :AddColorPicker("AimColor", { Default = Color3.fromRGB(255, 0, 0) })
    :AddKeyPicker("AimKey", { Default = 0x02, Mode = "Hold", Popup = true })
```

Slider:

```lua
Group:AddSlider("Speed", {
    Text = "Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = " studs",
    Presets = { 0, 25, 50, 75, 100 },
})
```

Dropdown:

```lua
Group:AddDropdown("Mode", {
    Text = "Mode",
    Values = { "A", "B", "C" },
    Default = "A",
    Searchable = true,
})
```

Managers:

```lua
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
EssentialsManager:SetLibrary(Library)

EssentialsManager:BuildSection(Tabs.Settings)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
```

## Notes

- Modules now return their table directly through `loadstring(... )()`. `_G.Galax[...]` remains as a compatibility fallback for older loaders.
- Keybinds use Win32 virtual-key codes, for example `0x02` for right mouse and `0x70` for F1.
- Supported Drawing fonts are `UI`, `System`, `SystemBold`, `Minecraft`, `Monospace`, `Pixel`, and `Fortnite`.
- Configs are saved under `Galax/Obsidian/Settings/Configs/`.
- Themes are saved under `Galax/Obsidian/Settings/Themes/`.
