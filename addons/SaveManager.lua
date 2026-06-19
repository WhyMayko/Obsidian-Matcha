local SaveManager = {
	Library = nil,
	_data = {},
	_ignore = {},
	_autoload = "",
}

local SettingsFolder = "Galax/Obsidian/Settings"
local ConfigFolder = SettingsFolder .. "/Config"
local DefaultConfigFile = SettingsFolder .. "/DefaultConfig.lua"

local function ensureFolder(path)
	if type(makefolder) ~= "function" then
		return
	end

	local current = ""
	for part in tostring(path):gmatch("[^/\\]+") do
		current = current == "" and part or (current .. "/" .. part)
		if type(isfolder) ~= "function" or not isfolder(current) then
			makefolder(current)
		end
	end
end

local function fileName(name)
	return tostring(name or "Config"):gsub("[^%w%s_%-]", "_") .. ".lua"
end

local function serialize(value, indent)
	indent = indent or ""
	local valueType = type(value)

	if valueType == "string" then
		return string.format("%q", value)
	elseif valueType == "number" or valueType == "boolean" then
		return tostring(value)
	elseif valueType == "table" then
		local nextIndent = indent .. "\t"
		local lines = { "{" }

		for key, item in pairs(value) do
			local keyText = type(key) == "number" and ("[" .. key .. "]") or ("[" .. string.format("%q", key) .. "]")
			lines[#lines + 1] = nextIndent .. keyText .. " = " .. serialize(item, nextIndent) .. ","
		end

		lines[#lines + 1] = indent .. "}"
		return table.concat(lines, "\n")
	end

	return "nil"
end

local function writeTable(path, data)
	if type(writefile) ~= "function" then
		return false, "writefile unavailable"
	end

	local folder = tostring(path):match("^(.*)[/\\][^/\\]+$")
	ensureFolder(folder or SettingsFolder)

	local ok, err = pcall(writefile, path, "return " .. serialize(data))
	if not ok then
		return false, err
	end

	return true
end

local function readTable(path)
	if type(isfile) == "function" and not isfile(path) then
		return nil
	end

	if type(readfile) ~= "function" then
		return nil
	end

	local ok, source = pcall(readfile, path)
	if not ok or type(source) ~= "string" then
		return nil
	end

	local chunk = loadstring(source)
	if not chunk then
		return nil
	end

	local loadedOk, data = pcall(chunk)
	if loadedOk and type(data) == "table" then
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
		local object = (Library.Options or {})[index] or (Library.Toggles or {})[index]

		if object and object.Set then
			pcall(object.Set, object, values[1])
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
	if type(isfile) ~= "function" or isfile(path) then
		delfile(path)
	end
	if self._autoload == name then
		self:DeleteAutoLoadConfig()
	end
	return true
end

function SaveManager:RefreshConfigList()
	ensureFolder(ConfigFolder)

	if type(listfiles) == "function" then
		for _, path in ipairs(listfiles(ConfigFolder) or {}) do
			local pathText = tostring(path)
			local baseName = pathText:match("([^/\\]+)$") or pathText
			if baseName:sub(1, 2) ~= "__" and baseName:match("%.lua$") then
				local data = readTable(pathText)
				local name = baseName:gsub("%.lua$", "")
				if data then
					self._data[name] = data
				end
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
	if not self._data[name] and not readTable(ConfigFolder .. "/" .. fileName(name)) then
		return false, "config not found"
	end

	self._autoload = name or ""
	return writeTable(DefaultConfigFile, { Name = self._autoload })
end

function SaveManager:DeleteAutoLoadConfig()
	self._autoload = ""

	if type(isfile) ~= "function" or isfile(DefaultConfigFile) then
		delfile(DefaultConfigFile)
	end

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

	if not self._data[self._autoload] and not readTable(ConfigFolder .. "/" .. fileName(self._autoload)) then
		self:DeleteAutoLoadConfig()
		return "none"
	end

	return self._autoload
end

function SaveManager:LoadAutoloadConfig()
	self:GetAutoloadConfig()

	if self._autoload ~= "" then
		local ok = self:Load(self._autoload)
		if not ok then
			self:DeleteAutoLoadConfig()
		end
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
		if self.AutoloadConfigLabel then
			self.AutoloadConfigLabel:SetText("Current autoload config: " .. tostring(self:GetAutoloadConfig()))
		end
	end)

	groupbox:AddButton("Refresh list", function()
		Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
		Options.SaveManager_ConfigList:SetValue(nil)
	end)

	groupbox:AddButton("Set as autoload", function()
		local name = Options.SaveManager_ConfigList.Value
		if not name then
			Library:Notify("No config selected", 4)
			return
		end

		local ok, err = self:SaveAutoloadConfig(name)
		if not ok then
			Library:Notify("Failed: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Autoload config: %q", name), 4)
		if self.AutoloadConfigLabel then
			self.AutoloadConfigLabel:SetText("Current autoload config: " .. name)
		end
	end)

	groupbox:AddButton("Reset autoload", function()
		local name = self:GetAutoloadConfig()
		if name == "none" then
			Library:Notify("Autoload reset / No config", 4)
			if self.AutoloadConfigLabel then
				self.AutoloadConfigLabel:SetText("Current autoload config: none")
			end
			return
		end

		local ok, err = self:Load(name)
		if not ok then
			Library:Notify("Failed to load autoload config: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Loaded autoload config: %q", name), 4)
		if self.AutoloadConfigLabel then
			self.AutoloadConfigLabel:SetText("Current autoload config: " .. name)
		end
	end)


	self.AutoloadConfigLabel = groupbox:AddLabel("Current autoload config: " .. tostring(self:GetAutoloadConfig()))

	self:SetIgnoreIndexes({
		"SaveManager_ConfigName",
		"SaveManager_ConfigList",
	})
end

_G.ObsidianMatchaAddons = _G.ObsidianMatchaAddons or {}
_G.ObsidianMatchaAddons["addons/SaveManager.lua"] = SaveManager

return SaveManager
