local SaveManager = {
	Library = nil,
	_data = {},
	_ignore = {},
	_allowed = nil,
	_autoload = "",
}

local SettingsFolder = "Galax/Obsidian/Settings"
local ConfigFolder = SettingsFolder .. "/Config"
local DefaultConfigFile = SettingsFolder .. "/DefaultConfig.lua"

local HttpService = game:GetService("HttpService")

local function ensureFolder(path)
	local current = ""
	for part in tostring(path):gmatch("[^/\\]+") do
		current = current == "" and part or (current .. "/" .. part)
		if not isfolder(current) then
			makefolder(current)
		end
	end
end

local function fileName(name)
	return tostring(name or "Config"):gsub("[^%w%s_%-]", "_") .. ".txt"
end

local function writeTable(path, data)
	local folder = tostring(path):match("^(.*)[/\\][^/\\]+$")
	ensureFolder(folder or SettingsFolder)

	local encoded = HttpService:JSONEncode(data)
	writefile(path, encoded)
	return true
end

local function readTable(path)
	if not isfile(path) then
		return nil
	end

	local source = readfile(path)
	if type(source) ~= "string" then
		return nil
	end

	local ok, data = pcall(function() return HttpService:JSONDecode(source) end)
	if not ok then
		return nil
	end

	if type(data) == "table" then
		return data
	end

	return nil
end

function SaveManager:SetLibrary(library)
	self.Library = library
end

function SaveManager:SetIgnoreIndexes(indexes)
	for _, index in ipairs(indexes or {}) do
		self._ignore[index] = true
	end
end

function SaveManager:SetAllowedIndexes(indexes)
	self._allowed = {}

	for _, index in ipairs(indexes or {}) do
		self._allowed[index] = true
	end
end

function SaveManager:IsAllowedIndex(index)
	if self._ignore[index] then
		return false
	end

	if self._allowed and not self._allowed[index] then
		return false
	end

	return true
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
		if self:IsAllowedIndex(index) and option.Get then
			if option.Type == "KeyPicker" then
				data[index] = { Key = option:Get(), Mode = option.Mode, Modifiers = option.Modifiers }
			else
				data[index] = { option:Get() }
			end
		end
	end

	for index, toggle in pairs(Library.Toggles or {}) do
		if self:IsAllowedIndex(index) and toggle.Get then
			data[index] = { toggle:Get() }
		end
	end

	self._data[name] = data
	local ok, err = writeTable(ConfigFolder .. "/" .. fileName(name), data)
	if not ok then
		self._data[name] = nil
		return false, err
	end

	return true
end

function SaveManager:Load(name)
	local Library = self.Library
	local data = self._data[name] or readTable(ConfigFolder .. "/" .. fileName(name))

	if not Library then
		return false, "library not set"
	end

	if not data then
		return false, "not found"
	end

	for index, values in pairs(data) do
		local object = self:IsAllowedIndex(index) and ((Library.Options or {})[index] or (Library.Toggles or {})[index])

		if object and object.Set then
			if values[2] ~= nil or values.Modifiers ~= nil then
				object:Set(values)
			else
				object:Set(values[1])
			end
		end
	end

	return true
end

function SaveManager:Delete(name)
	if not name or name == "" then
		return false, "no name"
	end

	self._data[name] = nil
	local path = ConfigFolder .. "/" .. fileName(name)
	if isfile(path) then
		delfile(path)
	end
	if self._autoload == name then
		self:DeleteAutoLoadConfig()
	end
	return true
end

function SaveManager:RefreshConfigList()
	ensureFolder(ConfigFolder)

	for _, path in ipairs(listfiles(ConfigFolder) or {}) do
		local pathText = tostring(path)
			local baseName = pathText:match("([^/\\]+)$") or pathText
			if baseName:sub(1, 2) ~= "__" and baseName:match("%.txt$") then
				local data = readTable(pathText)
				local name = baseName:gsub("%.txt$", "")
				if data then
					self._data[name] = data
				end
			end
		end

	local names = {}

	for name in pairs(self._data) do
		names[#names + 1] = name
	end

	table.sort(names)
	return names
end

function SaveManager:SaveAutoloadConfig(name)
	if not name or name == "" then
		return false, "no name"
	end
	self:RefreshConfigList()
	if not self._data[name] and not readTable(ConfigFolder .. "/" .. fileName(name)) then
		return false, "config not found"
	end

	self._autoload = name or ""
	return writeTable(DefaultConfigFile, { Name = self._autoload })
end

function SaveManager:DeleteAutoLoadConfig()
	self._autoload = ""

	writeTable(DefaultConfigFile, { Name = self._autoload })

	return true
end

function SaveManager:GetAutoloadConfig()
	local saved = readTable(DefaultConfigFile)
	if saved and saved.Name ~= nil then
		self._autoload = saved.Name
	end

	if self._autoload == "" then
		return "none"
	end

	return self._autoload
end

function SaveManager:LoadAutoloadConfig()
	self:GetAutoloadConfig()

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
		local name = Options.SaveManager_ConfigList:Get()
		local ok, err = self:Load(name)

		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Loaded config: %q", name), 4)
	end)

	groupbox:AddButton("Overwrite config", function()
		local name = Options.SaveManager_ConfigList:Get()
		local ok, err = self:Save(name)

		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Overwrote config: %q", name), 4)
	end)

	groupbox:AddButton("Delete config", function()
		local name = Options.SaveManager_ConfigList:Get()
		local ok, err = self:Delete(name)

		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Deleted config: %q", name), 4)
		Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Options.SaveManager_ConfigList:SetValue(nil)
		if self.AutoloadConfigLabel then
			self.AutoloadConfigLabel:SetText("Current autoload config: " .. tostring(self:GetAutoloadConfig()))
		end
	end)

	groupbox:AddButton("Refresh list", function()
		Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	groupbox:AddButton("Set as autoload", function()
		local name = Options.SaveManager_ConfigList:Get()
		if not name then
			Library:Notify("No config selected", 4)
			return
		end

		local ok, err = self:SaveAutoloadConfig(name)
		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Autoload config set: %q", name), 4)
		if self.AutoloadConfigLabel then
			self.AutoloadConfigLabel:SetText("Current autoload config: " .. name)
		end
	end)

	groupbox:AddButton("Reset autoload", function()
		self:DeleteAutoLoadConfig()
		Library:Notify("Autoload reset", 4)
		if self.AutoloadConfigLabel then
			self.AutoloadConfigLabel:SetText("Current autoload config: none")
		end
	end)


	self.AutoloadConfigLabel = groupbox:AddLabel("Current autoload config: " .. tostring(self:GetAutoloadConfig()))

	self:SetIgnoreIndexes({
		"SaveManager_ConfigName",
		"SaveManager_ConfigList",
	})

	self:LoadAutoloadConfig()
end

_G.ObsidianMatchaAddons = _G.ObsidianMatchaAddons or {}
_G.ObsidianMatchaAddons["addons/SaveManager.lua"] = SaveManager

return SaveManager
