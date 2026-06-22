-- ============================================================
-- EssentialsManager — Global UI settings
-- Adds: Menu Keybind, DPI Scale, Corner Radius, Notification Side
-- Saved by SaveManager as part of normal configs.
-- Usage:
--   local EssentialsManager = loadstring(game:HttpGet(repo .. "addons/EssentialsManager.lua"))()
--   EssentialsManager = (_G.Galax["addons/EssentialsManager.lua"])
--
--   EssentialsManager:SetLibrary(Library)
--   EssentialsManager:BuildSection(Tabs["UI Settings"])
-- ============================================================

local EssentialsManager = {
	Library = nil,
}

-- ---- SetLibrary ----
function EssentialsManager:SetLibrary(library)
	self.Library = library
end

-- ---- BuildSection ----
-- Adds Menu/Essentials controls to a Tab.
-- Call this AFTER building your tabs but BEFORE SaveManager:BuildConfigSection.
function EssentialsManager:BuildSection(tab)
	local Library = self.Library
	assert(Library, "EssentialsManager: call SetLibrary first")

	local MenuGroup = tab:AddLeftGroupbox("Menu", "wrench")

	-- Keybind Menu toggle
	MenuGroup:AddToggle("KeybindMenuOpen", {
		Default = false,
		Text = "Open Keybind Menu",
		Callback = function(Value)
			if not Library.ActiveWindow then
				error("EssentialsManager: no active window for KeybindMenuOpen", 2)
			end
			Library.ActiveWindow:SetKeybindMenuVisible(Value)
		end,
	})

	-- Notification side
	MenuGroup:AddDropdown("NotificationSide", {
		Values = { "Left", "Right" },
		Default = "Right",
		Text = "Notification Side",
		Callback = function(Value)
			Library.NotifySide = Value
		end,
	})

	-- DPI Scale
	MenuGroup:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%", "225%", "250%" },
		Default = "100%",
		Text = "DPI Scale",
		Callback = function(Value)
			if not Library.ActiveWindow then
				error("EssentialsManager: no active window for DPIDropdown", 2)
			end
			local pct = tonumber(Value:match("%d+")) or 100
			Library.ActiveWindow:SetDPIScale(pct)
		end,
	})

	-- Corner Radius
	MenuGroup:AddSlider("UICornerSlider", {
		Text = "Corner Radius",
		Default = 0,
		Min = 0,
		Max = 10,
		Rounding = 0,
		Callback = function(Value)
			if not Library.ActiveWindow then
				error("EssentialsManager: no active window for UICornerSlider", 2)
			end
			Library.CornerRadius = Value
			Library.ActiveWindow:SetCornerRadius(Value)
		end,
	})

	MenuGroup:AddDivider()

	-- Menu bind — does NOT show mode popup
	MenuGroup:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", {
			Default = 0x70, -- F1
			Mode = "Toggle",
			Popup = false,
			Text = "Menu keybind",
		})

	Library.Options.MenuKeybind:OnChanged(function(Value)
		Library.Options.MenuKeybind.Mode = "Toggle"
		Library.ActiveWindow.MenuKey = Value
	end)

	-- Wire ToggleKeybind so Library knows which key toggles the UI
	Library.ToggleKeybind = Library.Options.MenuKeybind

	MenuGroup:AddButton("Unload", function()
		Library:Unload()
	end)

	return MenuGroup
end

-- Register in _G.Galax for repo-style loading
_G.Galax = _G.Galax or {}
if _G.Galax then
	_G.Galax["addons/EssentialsManager.lua"] = EssentialsManager
end

return EssentialsManager
