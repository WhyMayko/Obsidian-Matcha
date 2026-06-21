# Obsidian Matcha

Obsidian Matcha is a Drawing API UI library for Matcha external. It keeps the public scripting style close to the original Obsidian/LinoriaLib while rendering everything with Drawing objects instead of Roblox UI instances.

## Introduction

The library gives you windows, tabs, groupboxes and all the common UI elements — toggles, sliders, dropdowns, color pickers, key pickers, inputs, buttons and more — without touching the Roblox UI tree.

Scripts load only three files. Because Matcha's `loadstring` does not return values the same way as standard Lua, always use the `_G` fallback after each load:

```lua
local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
Library = (_G.Galax["Library.lua"])

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
ThemeManager = (_G.Galax["addons/ThemeManager.lua"])

local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
SaveManager = (_G.Galax["addons/SaveManager.lua"])
```

`Library.lua` automatically downloads `TextManager`, `IconManager` and `AnimationManager` from the repository at runtime. You do not need to load them manually.

---

## Quick Test

Run the full showcase example directly in Matcha:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/Example.lua"))()
```

---

## Creating a Window

```lua
local Window = Library:CreateWindow({
    Title      = "My Script",   -- Title shown at the top of the window
    Subtitle   = "v1.0",        -- Optional subtitle below the title
    Footer     = "by me",       -- Small text at the bottom of the window

    -- Icon: accepts a Roblox asset ID (number), a direct image URL (string),
    -- or a raw rbxassetid:// string.
    Icon = 95816097006870,      -- Roblox asset ID
    -- Icon = "https://example.com/icon.png"  -- or a direct URL

    NotifySide  = "Right",      -- Where notifications appear: "Left" or "Right"
    ShowSearch  = true,         -- Shows the search bar at the top of the tab
    Resizable   = true,         -- Allow in-game window resizing (default true)

    -- Size and position (optional, defaults shown below)
    Size     = Vector2.new(820, 600),
    Position = Vector2.new(180, 130),

    -- MenuKey: Win32 virtual-key code for toggling the menu
    -- Default is 0x70 (F1). Full key list: https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
    MenuKey = 0x70,

    -- KeybindModePopup: controls which modes appear when right-clicking a keybind
    -- Set to false to disable the popup entirely
    KeybindModePopup = { "Toggle", "Hold", "Press" },
})
```

---

## Tabs

```lua
local Tabs = {
    Main          = Window:AddTab("Main", "user"),     -- name, icon
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
    Key           = Window:AddKeyTab("Key System"),    -- special key-locked tab
}
```

Tab icons are matched by name. Built-in icons: `user`, `settings`, `key`, `search`, `move`, `boxes`, `wrench`. You can also pass a Roblox asset ID or a direct image URL as the icon.

---

## Groupboxes and Tabboxes

```lua
local Left  = Tabs.Main:AddLeftGroupbox("Name")
local Right = Tabs.Main:AddRightGroupbox("Name")

-- Tabboxes split one side into switchable sub-tabs
local TBox = Tabs.Main:AddLeftTabbox()
local T1   = TBox:AddTab("Tab 1")
local T2   = TBox:AddTab("Tab 2")
-- T1 and T2 support the same element methods as groupboxes
```

---

## Shared Options

Every element accepts these options unless stated otherwise:

| Option           | Type    | Description                                      |
|------------------|---------|--------------------------------------------------|
| `Disabled`       | bool    | Greys out and blocks interaction                 |
| `Visible`        | bool    | Hides the element (still takes space)            |
| `Risky`          | bool    | Makes the label text red                         |
| `Tooltip`        | string  | Text shown on hover                              |
| `DisabledTooltip`| string  | Tooltip shown when the element is disabled       |
| `Callback`       | function| Called whenever the value changes                |

---

## Toggle

```lua
Left:AddToggle("MyToggle", {
    Text    = "Enable something",
    Default = false,
    Disabled = false,
    Visible  = true,
    Risky    = false,

    Callback = function(Value)
        print("Toggle is now:", Value)
    end,
})

-- Read / react to the value later:
Toggles.MyToggle:OnChanged(function()
    print(Toggles.MyToggle.Value)
end)

Toggles.MyToggle:SetValue(true)
```

You can chain a `ColorPicker` or `KeyPicker` directly on a toggle:

```lua
Left:AddToggle("MyToggle", { Text = "Aim" })
    :AddColorPicker("AimColor", { Default = Color3.new(1, 0, 0) })
    :AddKeyPicker("AimKey", { Default = 0x02, Mode = "Hold" })
```

---

## Checkbox

Identical API to Toggle. Use `Library.ForceCheckbox = true` to render all toggles as checkboxes.

```lua
Left:AddCheckbox("MyCheckbox", {
    Text    = "Check me",
    Default = false,
    Callback = function(Value) end,
})
```

---

## Button

```lua
local Btn = Left:AddButton({
    Text        = "Click me",
    Func        = function() print("clicked") end,
    DoubleClick = false,   -- Require two clicks to fire
    Disabled    = false,
    Tooltip     = "Hover text",
})

-- Sub-buttons appear inline next to the parent button
Btn:AddButton({
    Text        = "Sub",
    Func        = function() print("sub clicked") end,
    DoubleClick = true,
})
```

Buttons can be chained:

```lua
Left:AddButton({ Text = "A", Func = funcA })
    :AddButton({ Text = "B", Func = funcB })
    :AddButton({ Text = "C", Func = funcC })
```

---

## Label

```lua
Left:AddLabel("Simple label")
Left:AddLabel("Wrapping label\nwith multiple lines", true)

-- Label with an index so you can update it later
Left:AddLabel("MyLabel", {
    Text     = "Updatable label",
    DoesWrap = true,
})

Options.MyLabel:SetText("New text")
```

---

## Divider

```lua
Left:AddDivider()
```

---

## Slider

```lua
Left:AddSlider("MySlider", {
    Text    = "Speed",
    Default = 50,
    Min     = 0,
    Max     = 100,
    Rounding = 0,      -- decimal places (0 = integer)
    Suffix  = " studs",
    Compact = false,   -- compact single-line display
    HideMax = false,   -- hides the max value display

    -- Optional custom display (return nil to use default)
    FormatDisplayValue = function(slider, value)
        if value == slider.Max then return "MAX" end
    end,

    Callback = function(Value) end,
})

Options.MySlider:OnChanged(function()
    print(Options.MySlider.Value)
end)

Options.MySlider:SetValue(75)
Options.MySlider:SetMin(10)
Options.MySlider:SetMax(200)
Options.MySlider:SetSuffix(" px")
```

---

## Input (Textbox)

```lua
Left:AddInput("MyInput", {
    Text             = "Label",
    Default          = "",
    Placeholder      = "Type here...",
    Numeric          = false,   -- only allow numbers
    Finished         = false,   -- only fire callback on Enter
    ClearTextOnFocus = true,

    Callback = function(Value) end,
})

Options.MyInput:OnChanged(function()
    print(Options.MyInput.Value)
end)
```

---

## Dropdown

```lua
Left:AddDropdown("MyDropdown", {
    Text   = "Choose one",
    Values = { "Option A", "Option B", "Option C" },
    Default = 1,            -- index or string
    Multi   = false,
    Searchable = false,
    MaxVisibleDropdownItems = 8,

    -- Optional: remap the displayed text per value
    FormatDisplayValue = function(Value)
        if Value == "Option A" then return "A (renamed)" end
        return Value
    end,

    -- Values the user cannot select
    DisabledValues = { "Option C" },

    Callback = function(Value) end,
})

-- Multi-select (Default is a table of strings)
Left:AddDropdown("Multi", {
    Text   = "Pick many",
    Values = { "A", "B", "C" },
    Default = { "A" },
    Multi   = true,
    Callback = function(Value)
        for k, v in pairs(Value) do print(k, v) end
    end,
})

Options.MyDropdown:OnChanged(function()
    print(Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue("Option B")
Options.MyDropdown:SetValues({ "X", "Y", "Z" })
Options.MyDropdown:AddValues({ "W" })
```

### Special Dropdowns

```lua
-- Auto-fills with all players in the game
Left:AddDropdown("Players", {
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Text = "Target player",
    Callback = function(Value) end,
})

-- Auto-fills with all teams
Left:AddDropdown("Teams", {
    SpecialType = "Team",
    Text = "Select team",
    Callback = function(Value) end,
})
```

---

## Color Picker

```lua
Left:AddLabel("Color"):AddColorPicker("MyColor", {
    Title        = "Pick a color",
    Default      = Color3.new(1, 0, 0),
    Transparency = 0,   -- adds a transparency slider when set (0 = opaque)

    Callback = function(Value) end,
})

Options.MyColor:OnChanged(function()
    print(Options.MyColor.Value)         -- Color3
    print(Options.MyColor.Transparency)  -- number
end)

Options.MyColor:SetValueRGB(Color3.fromRGB(0, 255, 140))
```

---

## Key Picker (Keybind)

Matcha keybinds use **Win32 virtual-key codes**. Common values:

| Key | Code |
|-----|------|
| MB1 (left click) | `0x01` |
| MB2 (right click) | `0x02` |
| F1–F12 | `0x70`–`0x7B` |
| Letters A–Z | `0x41`–`0x5A` |
| 0–9 | `0x30`–`0x39` |

Full list: https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

```lua
Left:AddLabel("Keybind"):AddKeyPicker("MyKeybind", {
    Default = 0x02,
    Mode    = "Toggle",   -- "Toggle", "Hold" or "Press"
    Text    = "Description shown in keybind menu",
    NoUI    = false,      -- hides from the keybind menu when true

    SyncToggleState = false,

    Popup = true,    -- enables popup format for keybind mode selection

    Callback = function(Value)
        print("Active:", Value)
    end,

    ChangedCallback = function(NewKey)
        print("Key changed to:", NewKey)
    end,
})

Options.MyKeybind:OnClick(function()
    print("Clicked, state:", Options.MyKeybind:GetState())
end)

Options.MyKeybind:OnChanged(function()
    print("Key is now:", Options.MyKeybind.Value)
end)

-- Set key and mode together
Options.MyKeybind:SetValue({ 0x02, "Hold" })
```

### Popup Mode Selection

Right-clicking a keybind label opens a popup to change the mode. You can control which modes appear globally or per-keybind:

**Global control (affects all keybinds):**
```lua
Window:SetKeybindModePopup({ "Toggle", "Press" })
Window:SetKeybindModePopup(false)   -- disable popup entirely
```

**Per-keybind control (enables popup format):**
```lua
Left:AddLabel("Keybind"):AddKeyPicker("MyKeybind", {
    Default = 0x02,
    Mode    = "Toggle",
    Popup   = true,    -- enable popup for this specific keybind
    -- ... other options
})
```

---

## Key System Tab

A special tab that shows a text input for a key/code. Useful for locking features behind a key.

```lua
local KeyTab = Window:AddKeyTab("Key System")

KeyTab:AddLabel({ Text = "Enter key: Banana", DoesWrap = true })

KeyTab:AddKeyBox(function(ReceivedKey)
    local ok = ReceivedKey == "Banana"
    Library:Notify({
        Title       = "Key check",
        Description = "Got: " .. ReceivedKey .. " | " .. (ok and "Correct!" or "Wrong!"),
        Time        = 4,
    })
end)
```

---

## Notifications

```lua
Library:Notify({
    Title       = "Hello",
    Description = "Something happened.",
    Time        = 5,   -- seconds
})
```

---

## Draggable Label

A floating label that the user can drag anywhere on screen, independent of the window.

```lua
Library:AddDraggableLabel("Draggable info text")
```

---

## DPI Scale

Resizes the window proportionally. Values are percentages.

```lua
Library:SetDPIScale(150)   -- 150%
Library:SetDPIScale(100)   -- default
Library:SetDPIScale(75)
```

---

## Window Corner Radius

```lua
Window:SetCornerRadius(6)   -- 0 = sharp corners
```

---

## Unload

```lua
Library:OnUnload(function()
    -- clean up your loops, connections, etc.
    print("Unloaded")
end)

Library:Unload()   -- destroys the window and fires OnUnload callbacks
```

Check inside loops:

```lua
task.spawn(function()
    while task.wait(1) do
        if Library.Unloaded then break end
        -- your logic
    end
end)
```

---

## ThemeManager

```lua
ThemeManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs["UI Settings"])
-- or apply to a specific groupbox:
-- ThemeManager:ApplyToGroupbox(SomeGroupbox)
```

Themes are stored separately from configs so changing a theme does not overwrite saved settings.

---

## SaveManager

```lua
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()                        -- keeps themes out of configs
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })          -- exclude specific options
SaveManager:BuildConfigSection(Tabs["UI Settings"])      -- adds the config UI
```

SaveManager saves and loads all `Options` and `Toggles` values automatically. The active autoload config is applied as soon as `BuildConfigSection` is called.

---

## Full UI Settings Example

```lua
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Text = "Open Keybind Menu",
    Default = false,
    Callback = function(Value)
        Window:SetKeybindMenuVisible(Value)
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values  = { "Left", "Right" },
    Default = "Right",
    Text    = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values  = { "75%", "100%", "125%", "150%" },
    Default = "100%",
    Text    = "DPI Scale",
    Callback = function(Value)
        Library:SetDPIScale(tonumber(Value:gsub("%%", "")))
    end,
})

MenuGroup:AddSlider("CornerRadius", {
    Text    = "Corner Radius",
    Default = Library.CornerRadius,
    Min     = 0,
    Max     = 10,
    Rounding = 0,
    Callback = function(Value)
        Window:SetCornerRadius(Value)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = 0x70, Mode = "Toggle", NoUI = true, Text = "Menu keybind" })

Options.MenuKeybind:OnChanged(function(Value)
    Options.MenuKeybind.Mode = "Toggle"
    Window.MenuKey = Value
end)

Library.ToggleKeybind = Options.MenuKeybind

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
```

---

---

## Community Configs and Themes

While a script is running in Matcha you can pull configs and themes directly from the community repository and apply them instantly with one command in the Matcha console.

```lua
-- Load a community config by name
community.loadConfig("ConfigName")

-- Load a community theme by name
community.loadTheme("ThemeName")
```

What happens when you run these commands:
1. The file is downloaded from the community folder on GitHub
2. It is saved to your local `Galax/Obsidian/Settings/` folder
3. It is applied to the current running script immediately

These commands are available as soon as `SaveManager` and `ThemeManager` have been loaded by your script. Community files are curated — users can request configs and themes and they will be added to the repository manually.

---

## Sidebar Image

You can add an image to the bottom of the sidebar either from code or from a theme file. The image's aspect ratio is calculated automatically.

### From code

```lua
-- Accepts a Roblox asset ID, a direct https:// URL, or a rbxassetid:// string
Window:SetSidebarImage(
    "https://example.com/logo.png",
    1.0,  -- scale (1.0 = fills full sidebar width, 0.5 = fills half width)
    0,    -- X offset from sidebar left (0 = centered horizontally)
    0     -- Y offset from sidebar top  (0 = pinned to bottom)
)

-- Clear the sidebar image
Window:SetSidebarImage(nil)
```

When X and Y are both `0` the image is automatically centered horizontally and pinned to the bottom of the sidebar just above the bottom bar. The height is capped automatically so it doesn't overlap the top bar.

### From a theme file

Add these fields to any theme `.txt` file (JSON):

```json
{
  "name": "My Theme",
  "AccentColor": "#7d55ff",
  "SidebarImage": "https://example.com/logo.png",
  "SidebarImageScale": 1.0,
  "SidebarImageX": 0,
  "SidebarImageY": 0
}
```

When the theme is applied (via ThemeManager or `community.loadTheme`) the image is loaded and displayed automatically.

---

## Notes

- Obsidian Matcha is built exclusively for Matcha. It does not target other executors.
- The Drawing API does not support rich text. Labels render plain strings only.
- Icons accept a Roblox asset ID (number or numeric string), a direct `https://` image URL, or a `rbxassetid://` string. The library resolves asset IDs to thumbnail URLs automatically using the Roblox Thumbnails API.
- Configs are saved locally under `Galax/Obsidian/Settings/Configs/`.
- Themes are saved locally under `Galax/Obsidian/Settings/Themes/`.
