local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
Library = _G.Galax["Library.lua"]

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
ThemeManager = _G.Galax["addons/ThemeManager.lua"]

local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
SaveManager = _G.Galax["addons/SaveManager.lua"]

local EssentialsManager = loadstring(game:HttpGet(repo .. "addons/EssentialsManager.lua"))()
EssentialsManager = _G.Galax["addons/EssentialsManager.lua"]

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Obsidian Matcha",
    Footer = "example",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowSearch = true,
    Resizable = true,
    Size = Vector2.new(820, 600),
    Position = Vector2.new(180, 130),
    MenuKey = 0x70,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Key = Window:AddKeyTab("Key System"),
    Settings = Window:AddTab("UI Settings", "settings"),
}

local MainLeft = Tabs.Main:AddLeftGroupbox("Main", "boxes")
local MainRight = Tabs.Main:AddRightGroupbox("Dropdowns")

MainLeft:AddToggle("MyToggle", {
    Text = "This is a toggle",
    Default = true,
    Tooltip = "Toggle with two color pickers",
    Callback = function(value)
        print("[cb] MyToggle:", value)
    end,
})
    :AddColorPicker("ColorPicker1", {
        Default = Color3.fromRGB(255, 0, 0),
        Title = "Primary color",
        Transparency = 0,
        Callback = function(value, transparency)
            print("[cb] ColorPicker1:", value, transparency)
        end,
    })
    :AddColorPicker("ColorPicker2", {
        Default = Color3.fromRGB(0, 255, 0),
        Title = "Secondary color",
        Callback = function(value)
            print("[cb] ColorPicker2:", value)
        end,
    })

Toggles.MyToggle:OnChanged(function()
    print("MyToggle changed:", Toggles.MyToggle.Value)
end)

MainLeft:AddCheckbox("MyCheckbox", {
    Text = "This is a checkbox",
    Default = true,
    Callback = function(value)
        print("[cb] MyCheckbox:", value)
    end,
})

local Button = MainLeft:AddButton({
    Text = "Button",
    Func = function()
        Library:Notify("You clicked the button", "Button", 3)
    end,
    Tooltip = "Simple button",
})

Button:AddButton({
    Text = "Sub button",
    DoubleClick = true,
    Func = function()
        print("Sub button clicked")
    end,
})

MainLeft:AddLabel("This is a label")
MainLeft:AddLabel({
    Text = "This label wraps across multiple lines.",
    DoesWrap = true,
})
MainLeft:AddLabel({
    Index = "EditableLabel",
    Text = "This label is exposed in Options",
    DoesWrap = true,
})

MainLeft:AddDivider()

MainLeft:AddSlider("MySlider", {
    Text = "Slider",
    Default = 3,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Suffix = " units",
    Presets = { 0, 1, 2, 3, 4, 5 },
    Callback = function(value)
        print("[cb] MySlider:", value)
    end,
})

Options.MySlider:OnChanged(function()
    print("MySlider changed:", Options.MySlider.Value)
end)

MainLeft:AddInput("MyTextbox", {
    Text = "Textbox",
    Default = "My textbox!",
    Placeholder = "Type here...",
    ClearTextOnFocus = true,
    Callback = function(value)
        print("[cb] Textbox:", value)
    end,
})

MainLeft:AddLabel("Color"):AddColorPicker("ColorPicker", {
    Default = Color3.fromRGB(0, 255, 140),
    Title = "Label color picker",
    Transparency = 0,
    Callback = function(value, transparency)
        print("[cb] Label color:", value, transparency)
    end,
})

MainLeft:AddLabel("Keybind"):AddKeyPicker("KeyPicker", {
    Default = 0x02,
    Mode = "Toggle",
    Text = "Example keybind",
    Popup = true,
    Callback = function(active)
        print("[cb] Keybind active:", active)
    end,
    ChangedCallback = function(key)
        print("[cb] Keybind changed:", key)
    end,
})

Options.KeyPicker:OnClick(function()
    print("Keybind state:", Options.KeyPicker:GetState())
end)

MainLeft:AddLabel("Press keybind"):AddKeyPicker("KeyPicker2", {
    Default = 0x58,
    Mode = "Press",
    Text = "Press X",
    Popup = { "Press" },
    Callback = function()
        print("Pressed X")
    end,
})

MainRight:AddDropdown("MyDropdown", {
    Text = "Dropdown",
    Values = { "This", "is", "a", "dropdown" },
    Default = "This",
    Callback = function(value)
        print("[cb] Dropdown:", value)
    end,
})

MainRight:AddDropdown("MySearchableDropdown", {
    Text = "Searchable dropdown",
    Values = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon" },
    Default = "Alpha",
    Searchable = true,
})

MainRight:AddDropdown("MyMultiDropdown", {
    Text = "Multi dropdown",
    Values = { "This", "is", "a", "dropdown" },
    Default = { "This", "is" },
    Multi = true,
    Callback = function(values)
        print("[cb] Multi dropdown:")
        for value, enabled in pairs(values) do
            print(value, enabled)
        end
    end,
})

MainRight:AddDropdown("MyDisabledValueDropdown", {
    Text = "Disabled value",
    Values = { "This", "is", "disabled", "value" },
    DisabledValues = { "disabled" },
    Default = "This",
})

MainRight:AddDropdown("MyVeryLongDropdown", {
    Text = "Long dropdown",
    Values = {
        "One", "Two", "Three", "Four", "Five", "Six",
        "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve",
    },
    Default = "One",
    MaxVisibleDropdownItems = 8,
})

MainRight:AddDropdown("MyPlayerDropdown", {
    Text = "Players",
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
})

MainRight:AddDropdown("MyTeamDropdown", {
    Text = "Teams",
    SpecialType = "Team",
})

local TabBox = Tabs.Main:AddRightTabbox()
local Tab1 = TabBox:AddTab("Tab 1")
Tab1:AddToggle("Tab1Toggle", { Text = "Tab 1 toggle" })
Tab1:AddButton("Tab 1 button", function()
    print("Tab 1 button clicked")
end)

local Tab2 = TabBox:AddTab("Tab 2")
Tab2:AddLabel("Tab 2 label")
Tab2:AddToggle("Tab2Toggle", { Text = "Tab 2 toggle" })

local ScrollGroup = Tabs.Main:AddLeftGroupbox("More")
ScrollGroup:AddLabel({
    Text = "Long content makes the section scroll.\n\nLine 1\nLine 2\nLine 3\nLine 4",
    DoesWrap = true,
})

Tabs.Key:AddLabel({
    Text = "Key: Banana",
    DoesWrap = true,
    Size = 16,
})

Tabs.Key:AddKeyBox(function(receivedKey)
    local success = receivedKey == "Banana"
    Library:Notify({
        Title = "Key check",
        Description = "Received: " .. tostring(receivedKey) .. "\nSuccess: " .. tostring(success),
        Time = 4,
    })
end)

Library:AddDraggableLabel("Draggable label")

Library:OnUnload(function()
    print("Unloaded")
end)

EssentialsManager:SetLibrary(Library)
EssentialsManager:BuildSection(Tabs.Settings)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library:Notify("Example loaded", "Obsidian Matcha", 4)
