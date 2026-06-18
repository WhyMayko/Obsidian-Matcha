local SaveManager = {
	Library = nil,
	Folder = nil,
	SubFolder = nil,
	_data = {},
	_ignore = {},
	_autoload = "",
}

function SaveManager:SetLibrary(library)
	self.Library = library
end

function SaveManager:SetFolder(folder)
	self.Folder = folder
end

function SaveManager:SetSubFolder(folder)
	self.SubFolder = folder
end

function SaveManager:SetIgnoreIndexes(indexes)
	for _, index in ipairs(indexes or {}) do
		self._ignore[index] = true
	end
end

function SaveManager:IgnoreThemeSettings()
	local indexes = {
		"BackgroundColor",
		"MainColor",
		"AccentColor",
		"OutlineColor",
		"FontColor",
		"FontFace",
		"ThemeManager_ThemeList",
		"ThemeManager_CustomThemeName",
		"ThemeManager_CustomThemeList",
	}

	self:SetIgnoreIndexes(indexes)
end

function SaveManager:Save(name)
	local Library = self.Library

	if not Library then
		return false, "library not set"
	end

	if not name or name == "" then
		return false, "no name"
	end

	local data = {}

	for index, option in pairs(Library.Options or {}) do
		if not self._ignore[index] and option.Get then
			data[index] = { option:Get() }
		end
	end

	for index, toggle in pairs(Library.Toggles or {}) do
		if not self._ignore[index] and toggle.Get then
			data[index] = { toggle:Get() }
		end
	end

	self._data[name] = data
	return true
end

function SaveManager:Load(name)
	local Library = self.Library
	local data = self._data[name]

	if not Library then
		return false, "library not set"
	end

	if not data then
		return false, "not found"
	end

	for index, values in pairs(data) do
		local object = (Library.Options or {})[index] or (Library.Toggles or {})[index]

		if object and object.Set then
			pcall(object.Set, object, values[1])
		end
	end

	return true
end

function SaveManager:Delete(name)
	self._data[name] = nil
	return true
end

function SaveManager:RefreshConfigList()
	local names = {}

	for name in pairs(self._data) do
		names[#names + 1] = name
	end

	table.sort(names)
	return names
end

function SaveManager:SaveAutoloadConfig(name)
	self._autoload = name or ""
	return true
end

function SaveManager:DeleteAutoLoadConfig()
	self._autoload = ""
	return true
end

function SaveManager:GetAutoloadConfig()
	if self._autoload == "" then
		return "none"
	end

	return self._autoload
end

function SaveManager:LoadAutoloadConfig()
	if self._autoload ~= "" then
		self:Load(self._autoload)
	end
end

function SaveManager:BuildConfigSection(tab)
	local Library = self.Library
	if not Library then
		return
	end

	local Options = Library.Options
	local groupbox = tab:AddRightGroupbox("Configuration")

	groupbox:AddInput("SaveManager_ConfigName", {
		Text = "Config name",
	})

	groupbox:AddButton("Create config", function()
		local name = Options.SaveManager_ConfigName.Value

		if not name or name:gsub(" ", "") == "" then
			Library:Notify("Invalid config name", 4)
			return
		end

		local ok, err = self:Save(name)
		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Config created: %q", name), 4)
		Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	groupbox:AddDivider()

	groupbox:AddDropdown("SaveManager_ConfigList", {
		Text = "Config list",
		Values = self:RefreshConfigList(),
		AllowNull = true,
	})

	groupbox:AddButton("Load config", function()
		local name = Options.SaveManager_ConfigList.Value
		local ok, err = self:Load(name)

		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Loaded config: %q", name), 4)
	end)

	groupbox:AddButton("Overwrite config", function()
		local name = Options.SaveManager_ConfigList.Value
		local ok, err = self:Save(name)

		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Overwrote config: %q", name), 4)
	end)

	groupbox:AddButton("Delete config", function()
		local name = Options.SaveManager_ConfigList.Value
		local ok, err = self:Delete(name)

		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Deleted config: %q", name), 4)
		Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	groupbox:AddButton("Refresh list", function()
		Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	groupbox:AddButton("Set session autoload", function()
		local name = Options.SaveManager_ConfigList.Value
		if not name then
			Library:Notify("No config selected", 4)
			return
		end

		self:SaveAutoloadConfig(name)
		Library:Notify(string.format("Session autoload config: %q", name), 4)
	end)

	groupbox:AddButton("Reset autoload", function()
		self:DeleteAutoLoadConfig()
		Library:Notify("Autoload reset", 4)
	end)

	groupbox:AddLabel("Current autoload config: " .. tostring(self:GetAutoloadConfig()))

	self:SetIgnoreIndexes({
		"MenuKeybind",
		"SaveManager_ConfigName",
		"SaveManager_ConfigList",
	})
end

_G.ObsidianMatchaAddons = _G.ObsidianMatchaAddons or {}
_G.ObsidianMatchaAddons["addons/SaveManager.lua"] = SaveManager

return SaveManager
