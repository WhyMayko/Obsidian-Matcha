-- ============================================================
-- EssentialsManager — Global persistent UI settings
-- Saves: MenuKeybind, DPI Scale, Corner Radius, Notification Side
-- Loaded once at startup, independent of per-game configs.
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

local HttpService = game:GetService("HttpService")

local SettingsFolder = "Galax/Obsidian/Settings"
local EssentialsFile = SettingsFolder .. "/Essentials.txt"

-- ---- Folder helpers ----
local function ensureFolder(path)
	local current = ""
	for part in tostring(path):gmatch("[^/\\]+") do
		current = current == "" and part or (current .. "/" .. part)
		if not isfolder(current) then
			makefolder(current)
		end
	end
end

local function writeTable(path, data)
	local folder = tostring(path):match("^(.*)[/\\][^/\\]+$")
	ensureFolder(folder or SettingsFolder)
	local encoded
	local ok, _ = pcall(function()
		local parts = {}
		for k, v in pairs(data) do
			table.insert(parts, string.format('\t%q: %s', tostring(k), HttpService:JSONEncode(v)))
		end
		table.sort(parts)
		encoded = "{\n" .. table.concat(parts, ",\n") .. "\n}"
	end)
	if not encoded then
		encoded = HttpService:JSONEncode(data)
	end
	writefile(path, encoded)
	return true
end

local function readTable(path)
	if not isfile(path) then
		return nil
	end
	local source = readfile(path)
	if type(source) ~= "string" then return nil end
	local ok, data = pcall(function() return HttpService:JSONDecode(source) end)
	if not ok or type(data) ~= "table" then return nil end
	return data
end

-- ---- Save / Load ----
function EssentialsManager:Save()
	local Library = self.Library
	if not Library then return false, "library not set" end

	local data = {}

	-- MenuKeybind
	if Library.Options and Library.Options.MenuKeybind then
		local kb = Library.Options.MenuKeybind
		data.MenuKeybind = { Key = kb:Get(), Mode = kb.Mode or "Toggle" }
	end

	-- DPI Scale
	if Library.Options and Library.Options.DPIDropdown then
		data.DPIScale = Library.Options.DPIDropdown:Get()
	end

	-- Corner Radius
	if Library.Options and Library.Options.UICornerSlider then
		data.CornerRadius = Library.Options.UICornerSlider:Get()
	end

	-- Notification Side
	if Library.Options and Library.Options.NotificationSide then
		data.NotificationSide = Library.Options.NotificationSide:Get()
	end

	return writeTable(EssentialsFile, data)
end

function EssentialsManager:Load()
	local Library = self.Library
	if not Library then return false, "library not set" end

	local data = readTable(EssentialsFile)
	if not data then return false, "no essentials file" end

	-- MenuKeybind
	if data.MenuKeybind and Library.Options and Library.Options.MenuKeybind then
		local kb = Library.Options.MenuKeybind
		if kb.SetValue then
			kb:SetValue(data.MenuKeybind)
		end
	end

	-- DPI Scale
	if data.DPIScale and Library.Options and Library.Options.DPIDropdown then
		Library.Options.DPIDropdown:SetValue(data.DPIScale)
	end

	-- Corner Radius
	if data.CornerRadius ~= nil and Library.Options and Library.Options.UICornerSlider then
		Library.Options.UICornerSlider:SetValue(data.CornerRadius)
	end

	-- Notification Side
	if data.NotificationSide and Library.Options and Library.Options.NotificationSide then
		Library.Options.NotificationSide:SetValue(data.NotificationSide)
	end

	return true
end

-- ---- SetLibrary ----
function EssentialsManager:SetLibrary(library)
	self.Library = library
end

-- ---- BuildSection ----
-- Adds Menu/Essentials controls to a Tab and wires auto-save on every change.
-- Call this AFTER building your tabs but BEFORE SaveManager:BuildConfigSection.
function EssentialsManager:BuildSection(tab)
	local Library = self.Library
	assert(Library, "EssentialsManager: call SetLibrary first")

	local function autoSave()
		task.defer(function()
			self:Save()
		end)
	end

	local MenuGroup = tab:AddLeftGroupbox("Menu", "wrench")

	-- Keybind Menu toggle
	MenuGroup:AddToggle("KeybindMenuOpen", {
		Default = false,
		Text = "Open Keybind Menu",
		Callback = function(Value)
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
			autoSave()
		end,
	})

	-- DPI Scale
	MenuGroup:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%", "225%", "250%" },
		Default = "100%",
		Text = "DPI Scale",
		Callback = function(Value)
			local pct = tonumber(Value:match("%d+")) or 100
			Library.ActiveWindow:SetDPIScale(pct)
			autoSave()
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
			Library.CornerRadius = Value
			Library.ActiveWindow.CornerRadius = Value
			autoSave()
		end,
	})

	MenuGroup:AddDivider()

	-- Menu bind — loads from essentials, no mode popup (Popup = false)
	MenuGroup:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", {
			Default = 0x70, -- F1
			Mode = "Toggle",
			Popup = false,
			NoUI = false,
			Text = "Menu keybind",
		})

	Library.Options.MenuKeybind:OnChanged(function(Value)
		Library.ActiveWindow.MenuKey = Value
		autoSave()
	end)

	-- Wire ToggleKeybind so Library knows which key toggles the UI
	Library.ToggleKeybind = Library.Options.MenuKeybind

	MenuGroup:AddButton("Unload", function()
		Library:Unload()
	end)

	-- Auto-load saved essentials on build
	task.defer(function()
		self:Load()
	end)

	return MenuGroup
end

-- Register in _G.Galax for repo-style loading
if _G.Galax then
	_G.Galax["addons/EssentialsManager.lua"] = EssentialsManager
end

return EssentialsManager
