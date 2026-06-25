-- example script by https://github.com/mstudio45/LinoriaLib/blob/main/Example.lua and modified by deivid
-- Adapted for Obsidian Matcha by Galax
-- You can suggest changes with a pull request or something

local repo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"

-- Load the Library
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
Library = (_G.Galax["Library.lua"])

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
ThemeManager = (_G.Galax["addons/ThemeManager.lua"])

local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
SaveManager = (_G.Galax["addons/SaveManager.lua"])

local EssentialsManager = loadstring(game:HttpGet(repo .. "addons/EssentialsManager.lua"))()
EssentialsManager = (_G.Galax["addons/EssentialsManager.lua"])

local Options = Library.Options
local Toggles = Library.Toggles

-- Use AddCheckbox for checkbox-style toggles (separate from AddToggle)
-- Keybinds: toggle keybind controls are built into the keybind menu

local Window = Library:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Set Resizable to true if you want to have in-game resizable Window
	-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)

	Title = "mspaint",
	Footer = "version: example",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowSearch = true,
})

-- CALLBACK NOTE:
-- Passing callback functions via the initial element parameters works.
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... end) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code:
-- Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a preference.
-- Matcha uses image assets where available instead of the full original Lucide icon module.
local Tabs = {
	-- Creates a new tab titled Main
	Main = Window:AddTab("Main", "user"),
	Key = Window:AddKeyTab("Key System"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

--[[
Example of how to add a warning box to a tab.
The original Obsidian supports rich text here. Matcha Drawing text does not guarantee rich text rendering yet.

local UISettingsTab = Tabs["UI Settings"]

UISettingsTab:UpdateWarningBox({
	Visible = true,
	Title = "Warning",
	Text = "This is a warning box!",
})
]]

-- Groupbox and Tabbox inherit the same functions.
-- Except Tabboxes: you have to call the functions on a tab (Tabbox:AddTab(Name)).
local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox", "boxes")

-- We can also get our Main tab through Window.Tabs once that compatibility field is exposed:
-- local LeftGroupBox = Window.Tabs.Main:AddLeftGroupbox("Groupbox", "boxes")

-- Tabboxes are a tiny bit different, but here's a basic example:
--[[
local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab("Tab 1")
local Tab2 = TabBox:AddTab("Tab 2")

-- You can now call AddToggle, AddSlider, AddLabel, etc. on the tabs you added to the Tabbox.
]]

-- Groupbox:AddToggle
-- Arguments: Index, Options
LeftGroupBox:AddToggle("MyToggle", {
	Text = "This is a toggle",
	Tooltip = "This is a tooltip", -- Information shown when you hover over the toggle
	DisabledTooltip = "I am disabled!", -- Information shown when you hover over the toggle while it's disabled

	Default = true, -- Default value (true / false)
	Disabled = false, -- Will disable the toggle (true / false)
	Visible = true, -- Will make the toggle invisible (true / false)
	Risky = false, -- Makes the text red where supported by the renderer

	Callback = function(Value)
		print("[cb] MyToggle changed to:", Value)
	end,
})
	:AddColorPicker("ColorPicker1", {
		Default = Color3.new(1, 0, 0),
		Title = "Some color1", -- Optional. Allows a custom color picker title when opened
		Transparency = 0, -- Optional. Enables transparency changing for this color picker

		Callback = function(Value)
			print("[cb] Color changed!", Value)
		end,
	})
	:AddColorPicker("ColorPicker2", {
		Default = Color3.new(0, 1, 0),
		Title = "Some color2",

		Callback = function(Value)
			print("[cb] Color changed!", Value)
		end,
	})

-- Fetching a toggle object for later use:
-- Toggles.MyToggle.Value

-- Toggles is a table exposed by the library.
-- You index Toggles with the specified index, in this case "MyToggle".
-- To get the state of the toggle you do toggle.Value.

-- Calls the passed function when the toggle is updated.
Toggles.MyToggle:OnChanged(function()
	print("MyToggle changed to:", Toggles.MyToggle.Value)
end)

-- This should print to the console: "MyToggle changed to: false"
Toggles.MyToggle:SetValue(false)

LeftGroupBox:AddCheckbox("MyCheckbox", {
	Text = "This is a checkbox",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Default = true,
	Disabled = false,
	Visible = true,
	Risky = false,

	Callback = function(Value)
		print("[cb] MyCheckbox changed to:", Value)
	end,
})

Toggles.MyCheckbox:OnChanged(function()
	print("MyCheckbox changed to:", Toggles.MyCheckbox.Value)
end)

--[[
	Groupbox:AddButton
	Arguments: {
		Text = string,
		Func = function,
		DoubleClick = boolean,
		Tooltip = string,
	}

	You can call :AddButton on a button to add a SubButton.
]]

local MyButton = LeftGroupBox:AddButton({
	Text = "Button",
	Func = function()
		print("You clicked a button!")
	end,
	DoubleClick = false,

	Tooltip = "This is the main button",
	DisabledTooltip = "I am disabled!",

	Disabled = false,
	Visible = true,
	Risky = false,
})

MyButton:AddButton({
	Text = "Sub button",
	Func = function()
		print("You clicked a sub button!")
	end,
	DoubleClick = true, -- You will have to click this button twice to trigger the callback
	Tooltip = "This is the sub button",
	DisabledTooltip = "I am disabled!",
})

LeftGroupBox:AddButton({
	Text = "Disabled Button",
	Func = function()
		print("You somehow clicked a disabled button!")
	end,
	DoubleClick = false,
	Tooltip = "This is a disabled button",
	DisabledTooltip = "I am disabled!",
	Disabled = true,
})

--[[
	NOTE: You can chain the button methods!
	EXAMPLE:

	LeftGroupBox:AddButton({ Text = "Kill all", Func = Functions.KillAll, Tooltip = "This will kill everyone in the game!" })
		:AddButton({ Text = "Kick all", Func = Functions.KickAll, Tooltip = "This will kick everyone in the game!" })
]]

-- Groupbox:AddLabel
-- Arguments: Text, DoesWrap, Idx
-- Arguments: Idx, Options
LeftGroupBox:AddLabel("This is a label")
LeftGroupBox:AddLabel("This is a label\n\nwhich wraps its text!", true)
LeftGroupBox:AddLabel("This is a label exposed to Options", true, "TestLabel")
LeftGroupBox:AddLabel("SecondTestLabel", {
	Text = "This is a label made with table options and an index",
	DoesWrap = true,
})

LeftGroupBox:AddLabel("SecondTestLabel", {
	Text = "This is a label that doesn't wrap it's own text",
	DoesWrap = false,
})

-- Options is a table exposed by the library.
-- You index Options with the specified index, in this case "SecondTestLabel" & "TestLabel".
-- To set the text of the label you do label:SetText.

-- Options.TestLabel:SetText("first changed!")
-- Options.SecondTestLabel:SetText("second changed!")

-- Groupbox:AddDivider
-- Arguments: None
LeftGroupBox:AddDivider()

--[[
	Groupbox:AddSlider
	Arguments: Idx, SliderOptions

	SliderOptions: {
		Text = string,
		Default = number,
		Min = number,
		Max = number,
		Suffix = string,
		Rounding = number,
		Compact = boolean,
		HideMax = boolean,
	}

	Text, Default, Min, Max, Rounding should be specified.
	Suffix is optional.
	Rounding is the number of decimal places for precision.
]]

LeftGroupBox:AddSlider("MySlider", {
	Text = "This is my slider!",
	Default = 0,
	Min = 0,
	Max = 5,
	Rounding = 1,
	Compact = false,

	Callback = function(Value)
		print("[cb] MySlider was changed! New value:", Value)
	end,

	Tooltip = "I am a slider!",
	DisabledTooltip = "I am disabled!",

	Disabled = false,
	Visible = true,
})

Options.MySlider:OnChanged(function()
	print("MySlider was changed! New value:", Options.MySlider.Value)
end)

Options.MySlider:SetValue(3)

LeftGroupBox:AddSlider("MySlider2", {
	Text = "This is my custom display slider!",
	Default = 0,
	Min = 0,
	Max = 5,
	Rounding = 0,
	Compact = false,

	FormatDisplayValue = function(slider, value)
		if value == slider.Max then return "Everything" end
		if value == slider.Min then return "Nothing" end
		-- If you return nil, the default formatting will be applied.
	end,

	Tooltip = "I am a slider!",
	DisabledTooltip = "I am disabled!",

	Disabled = false,
	Visible = true,
})

-- Groupbox:AddInput
-- Arguments: Idx, Info
LeftGroupBox:AddInput("MyTextbox", {
	Default = "My textbox!",
	Numeric = false, -- true / false, only allows numbers
	Finished = false, -- true / false, only calls callback when you press enter
	ClearTextOnFocus = true, -- if false, the text will not clear when focused

	Text = "This is a textbox",
	Tooltip = "This is a tooltip",

	Placeholder = "Placeholder text",
	-- MaxLength is also an option in the original library.

	Callback = function(Value)
		print("[cb] Text updated. New text:", Value)
	end,
})

Options.MyTextbox:OnChanged(function()
	print("Text updated. New text:", Options.MyTextbox.Value)
end)

-- Groupbox:AddDropdown
-- Arguments: Idx, Info
local DropdownGroupBox = Tabs.Main:AddRightGroupbox("Dropdowns")

DropdownGroupBox:AddDropdown("MyDropdown", {
	Values = { "This", "is", "a", "dropdown" },
	Default = 1, -- number index of the value / string
	Multi = false,

	Text = "A dropdown",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Searchable = false,

	Callback = function(Value)
		print("[cb] Dropdown got changed. New value:", Value)
	end,

	Disabled = false,
	Visible = true,
})

Options.MyDropdown:OnChanged(function()
	print("Dropdown got changed. New value:", Options.MyDropdown.Value)
end)

Options.MyDropdown:SetValue("This")

DropdownGroupBox:AddDropdown("MySearchableDropdown", {
	Values = { "This", "is", "a", "searchable", "dropdown" },
	Default = 1,
	Multi = false,

	Text = "A searchable dropdown",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Searchable = true,

	Callback = function(Value)
		print("[cb] Dropdown got changed. New value:", Value)
	end,

	Disabled = false,
	Visible = true,
})

DropdownGroupBox:AddDropdown("MyDisplayFormattedDropdown", {
	Values = { "This", "is", "a", "formatted", "dropdown" },
	Default = 1,
	Multi = false,

	Text = "A display formatted dropdown",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	FormatDisplayValue = function(Value)
		if Value == "formatted" then
			return "display formatted"
		end

		return Value
	end,

	Searchable = false,

	Callback = function(Value)
		print("[cb] Display formatted dropdown got changed. New value:", Value)
	end,

	Disabled = false,
	Visible = true,
})

-- Multi dropdowns
DropdownGroupBox:AddDropdown("MyMultiDropdown", {
	Values = { "This", "is", "a", "dropdown" },
	Default = { "This" },
	Multi = true,

	Text = "A multi dropdown",
	Tooltip = "This is a tooltip",

	Callback = function(Value)
		print("[cb] Multi dropdown got changed:")

		for key, value in pairs(Value) do
			print(key, value)
		end
	end,
})

Options.MyMultiDropdown:SetValue({
	"This",
	"is",
})

DropdownGroupBox:AddDropdown("MyDisabledDropdown", {
	Values = { "This", "is", "a", "dropdown" },
	Default = 1,
	Multi = false,

	Text = "A disabled dropdown",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Callback = function(Value)
		print("[cb] Disabled dropdown got changed. New value:", Value)
	end,

	Disabled = true,
	Visible = true,
})

DropdownGroupBox:AddDropdown("MyDisabledValueDropdown", {
	Values = { "This", "is", "a", "dropdown", "with", "disabled", "value" },
	DisabledValues = { "disabled" },
	Default = 1,
	Multi = false,

	Text = "A dropdown with disabled value",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Callback = function(Value)
		print("[cb] Dropdown with disabled value got changed. New value:", Value)
	end,

	Disabled = false,
	Visible = true,
})

DropdownGroupBox:AddDropdown("MyVeryLongDropdown", {
	Values = {
		"This", "is", "a", "very", "long", "dropdown", "with", "a", "lot", "of",
		"values", "but", "you", "can", "see", "more", "than", "8", "values",
	},
	Default = 1,
	Multi = false,

	MaxVisibleDropdownItems = 12,

	Text = "A very long dropdown",
	Tooltip = "This is a tooltip",
	DisabledTooltip = "I am disabled!",

	Searchable = false,

	Callback = function(Value)
		print("[cb] Very long dropdown got changed. New value:", Value)
	end,

	Disabled = false,
	Visible = true,
})

DropdownGroupBox:AddDropdown("MyPlayerDropdown", {
	SpecialType = "Player",
	ExcludeLocalPlayer = true,
	Text = "A player dropdown",
	Tooltip = "This is a tooltip",

	Callback = function(Value)
		print("[cb] Player dropdown got changed:", Value)
	end,
})

DropdownGroupBox:AddDropdown("MyTeamDropdown", {
	SpecialType = "Team",
	Text = "A team dropdown",
	Tooltip = "This is a tooltip",

	Callback = function(Value)
		print("[cb] Team dropdown got changed:", Value)
	end,
})

-- Label:AddColorPicker
-- Arguments: Idx, Info

-- You can add ColorPicker & KeyPicker to labels and toggles.
LeftGroupBox:AddLabel("Color"):AddColorPicker("ColorPicker", {
	Default = Color3.new(0, 1, 0),
	Title = "Some color",
	Transparency = 0,

	Callback = function(Value)
		print("[cb] Color changed!", Value)
	end,
})

Options.ColorPicker:OnChanged(function()
	print("Color changed!", Options.ColorPicker.Value)
	print("Transparency changed!", Options.ColorPicker.Transparency)
end)

Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

-- Label:AddKeyPicker
-- Arguments: Idx, Info
LeftGroupBox:AddLabel("Keybind"):AddKeyPicker("KeyPicker", {
	-- Matcha keybinds use Win32 virtual-key codes.
	-- MB2 = 0x02, X = 0x58, RightShift = 0xA1.

	Default = 0x02,
	SyncToggleState = false,

	Mode = "Toggle", -- Modes: Toggle, Hold, Press

	Text = "Auto lockpick safes",
	Popup = true,

	Callback = function(Value)
		print("[cb] Keybind clicked!", Value)
	end,

	ChangedCallback = function(NewKey)
		print("[cb] Keybind changed!", NewKey)
	end,
})

Options.KeyPicker:OnClick(function()
	print("Keybind clicked!", Options.KeyPicker:GetState())
end)

Options.KeyPicker:OnChanged(function()
	print("Keybind changed!", Options.KeyPicker.Value)
end)

task.spawn(function()
	while task.wait(1) do
		local state = Options.KeyPicker:GetState()
		if state then
			print("KeyPicker is being held down")
		end

		if Library.Unloaded then
			break
		end
	end
end)

Options.KeyPicker:SetValue({ 0x02, "Hold" })

-- Label:KeyPicker (Press Mode)
local KeybindNumber = 0

LeftGroupBox:AddLabel("Press Keybind"):AddKeyPicker("KeyPicker2", {
	Default = 0x58,
	Mode = "Press",
	WaitForCallback = false,

	Text = "Increase Number",

	Callback = function()
		KeybindNumber = KeybindNumber + 1
		print("[cb] Keybind clicked! Number increased to:", KeybindNumber)
	end,
})

-- Long text label to demonstrate UI scrolling behaviour.
local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox("Groupbox #2")
LeftGroupBox2:AddLabel(
	"This label spans multiple lines! We're gonna run out of UI space...\nJust kidding! Scroll down!\n\n\nHello from below!",
	true
)

local TabBox = Tabs.Main:AddRightTabbox()

local Tab1 = TabBox:AddTab("Tab 1")
Tab1:AddToggle("Tab1Toggle", { Text = "Tab1 Toggle" })

local Tab2 = TabBox:AddTab("Tab 2")
Tab2:AddToggle("Tab2Toggle", { Text = "Tab2 Toggle" })

Library:OnUnload(function()
	print("Unloaded!")
end)

-- Anything we can do in a Groupbox, we can do in a Key tab.
Tabs.Key:AddLabel({
	Text = "Key: Banana",
	DoesWrap = true,
	Size = 16,
})

Tabs.Key:AddKeyBox(function(ReceivedKey)
	-- KeyBox only takes the callback for the button.
	-- You need to implement your own key check inside the callback.
	local Success = ReceivedKey == "Banana"

	print("Expected Key: Banana - Received Key:", ReceivedKey, "| Success:", Success)
	Library:Notify({
		Title = "Expected Key: Banana",
		Description = "Received Key: " .. tostring(ReceivedKey) .. "\nSuccess: " .. tostring(Success),
		Time = 4,
	})
end)

-- DraggableLabel
Library:AddDraggableLabel("This is a Draggable Label")

-- UI Settings — Essentials (MenuKeybind, DPI, Corner Radius, Notif Side)
EssentialsManager:SetLibrary(Library)
EssentialsManager:BuildSection(Tabs["UI Settings"])

-- Hand the library over to theme/config managers.
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Builds our config menu on the right side of our tab.
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- Builds our theme menu on the left side.
ThemeManager:ApplyToTab(Tabs["UI Settings"])
