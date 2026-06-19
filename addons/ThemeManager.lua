local ThemeFields = {
	"BackgroundColor",
	"MainColor",
	"AccentColor",
	"OutlineColor",
	"FontColor",
	"Outline2",
	"Surface2",
	"Muted",
	"DimText",
	"PopupHover",
	"Bottombar",
	"BottombarBorder",
	"FooterText",
}

local BuiltInThemes = {
	{ name = "Default", FontColor = "#ffffff", MainColor = "#191919", AccentColor = "#7d55ff", BackgroundColor = "#0f0f0f", OutlineColor = "#282828", Outline2 = "#323232", Surface2 = "#212121", Muted = "#828282", DimText = "#4c4c4c", PopupHover = "#191919", Bottombar = "#171717", BottombarBorder = "#323232", FooterText = "#b9b9b9" },
	{ name = "BBot", FontColor = "#ffffff", MainColor = "#1e1e1e", AccentColor = "#7e48a3", BackgroundColor = "#232323", OutlineColor = "#141414", Outline2 = "#2c2c2c", Surface2 = "#282828", Muted = "#b0b0b0", DimText = "#676767", PopupHover = "#1e1e1e", Bottombar = "#252525", BottombarBorder = "#343434", FooterText = "#c8c8c8" },
	{ name = "Fatality", FontColor = "#ffffff", MainColor = "#1e1842", AccentColor = "#c50754", BackgroundColor = "#191335", OutlineColor = "#3c355d", Outline2 = "#514a74", Surface2 = "#282052", Muted = "#b7b1ce", DimText = "#716a93", PopupHover = "#1e1842", Bottombar = "#211943", BottombarBorder = "#3c355d", FooterText = "#d0cbe5" },
	{ name = "Jester", FontColor = "#ffffff", MainColor = "#242424", AccentColor = "#db4467", BackgroundColor = "#1c1c1c", OutlineColor = "#373737", Outline2 = "#454545", Surface2 = "#2c2c2c", Muted = "#b5b5b5", DimText = "#707070", PopupHover = "#242424", Bottombar = "#202020", BottombarBorder = "#373737", FooterText = "#cfcfcf" },
	{ name = "Mint", FontColor = "#ffffff", MainColor = "#242424", AccentColor = "#3db488", BackgroundColor = "#1c1c1c", OutlineColor = "#373737", Outline2 = "#454545", Surface2 = "#2c2c2c", Muted = "#b5b5b5", DimText = "#707070", PopupHover = "#242424", Bottombar = "#202020", BottombarBorder = "#373737", FooterText = "#cfcfcf" },
	{ name = "Tokyo Night", FontColor = "#ffffff", MainColor = "#191925", AccentColor = "#6759b3", BackgroundColor = "#16161f", OutlineColor = "#323232", Outline2 = "#44445a", Surface2 = "#222233", Muted = "#a9abc6", DimText = "#62657f", PopupHover = "#191925", Bottombar = "#1a1a25", BottombarBorder = "#323244", FooterText = "#c3c6df" },
	{ name = "Ubuntu", FontColor = "#ffffff", MainColor = "#3e3e3e", AccentColor = "#e2581e", BackgroundColor = "#323232", OutlineColor = "#191919", Outline2 = "#505050", Surface2 = "#474747", Muted = "#c9c9c9", DimText = "#7a7a7a", PopupHover = "#3e3e3e", Bottombar = "#363636", BottombarBorder = "#505050", FooterText = "#dddddd" },
	{ name = "Quartz", FontColor = "#ffffff", MainColor = "#232330", AccentColor = "#426e87", BackgroundColor = "#1d1b26", OutlineColor = "#27232f", Outline2 = "#3b3545", Surface2 = "#2d2b3a", Muted = "#b7b3c5", DimText = "#6c6879", PopupHover = "#232330", Bottombar = "#211f2b", BottombarBorder = "#383340", FooterText = "#d0cbdd" },
	{ name = "Nord", FontColor = "#eceff4", MainColor = "#3b4252", AccentColor = "#88c0d0", BackgroundColor = "#2e3440", OutlineColor = "#4c566a", Outline2 = "#5e6a82", Surface2 = "#434c5e", Muted = "#d8dee9", DimText = "#8f9aaa", PopupHover = "#3b4252", Bottombar = "#343b49", BottombarBorder = "#4c566a", FooterText = "#d8dee9" },
	{ name = "Dracula", FontColor = "#f8f8f2", MainColor = "#44475a", AccentColor = "#ff79c6", BackgroundColor = "#282a36", OutlineColor = "#6272a4", Outline2 = "#7587bf", Surface2 = "#505467", Muted = "#d6d6d0", DimText = "#8f91a2", PopupHover = "#44475a", Bottombar = "#303241", BottombarBorder = "#6272a4", FooterText = "#f8f8f2" },
	{ name = "Monokai", FontColor = "#f8f8f2", MainColor = "#272822", AccentColor = "#f92672", BackgroundColor = "#1e1f1c", OutlineColor = "#49483e", Outline2 = "#5d5b50", Surface2 = "#32332b", Muted = "#d8d8d2", DimText = "#858578", PopupHover = "#272822", Bottombar = "#24251f", BottombarBorder = "#49483e", FooterText = "#e6e6df" },
	{ name = "Gruvbox", FontColor = "#ebdbb2", MainColor = "#3c3836", AccentColor = "#fb4934", BackgroundColor = "#282828", OutlineColor = "#504945", Outline2 = "#665c54", Surface2 = "#49413e", Muted = "#d5c4a1", DimText = "#928374", PopupHover = "#3c3836", Bottombar = "#302f2d", BottombarBorder = "#504945", FooterText = "#d5c4a1" },
	{ name = "Solarized", FontColor = "#839496", MainColor = "#073642", AccentColor = "#cb4b16", BackgroundColor = "#002b36", OutlineColor = "#586e75", Outline2 = "#6c8188", Surface2 = "#0c4350", Muted = "#93a1a1", DimText = "#657b83", PopupHover = "#073642", Bottombar = "#06323d", BottombarBorder = "#586e75", FooterText = "#93a1a1" },
	{ name = "Catppuccin", FontColor = "#d9e0ee", MainColor = "#302d41", AccentColor = "#f5c2e7", BackgroundColor = "#1e1e2e", OutlineColor = "#575268", Outline2 = "#6e6880", Surface2 = "#3b374f", Muted = "#c9cbff", DimText = "#8b88a8", PopupHover = "#302d41", Bottombar = "#26263a", BottombarBorder = "#575268", FooterText = "#d9e0ee" },
	{ name = "One Dark", FontColor = "#abb2bf", MainColor = "#282c34", AccentColor = "#c678dd", BackgroundColor = "#21252b", OutlineColor = "#5c6370", Outline2 = "#707886", Surface2 = "#313640", Muted = "#c8ccd4", DimText = "#7f848e", PopupHover = "#282c34", Bottombar = "#252a31", BottombarBorder = "#5c6370", FooterText = "#c8ccd4" },
	{ name = "Cyberpunk", FontColor = "#f9f9f9", MainColor = "#262335", AccentColor = "#00ff9f", BackgroundColor = "#1a1a2e", OutlineColor = "#413c5e", Outline2 = "#555078", Surface2 = "#302b45", Muted = "#d6f7ec", DimText = "#708a94", PopupHover = "#262335", Bottombar = "#202039", BottombarBorder = "#413c5e", FooterText = "#e4fff6" },
	{ name = "Oceanic Next", FontColor = "#d8dee9", MainColor = "#1b2b34", AccentColor = "#6699cc", BackgroundColor = "#16232a", OutlineColor = "#343d46", Outline2 = "#4f5b66", Surface2 = "#243844", Muted = "#c0c5ce", DimText = "#65737e", PopupHover = "#1b2b34", Bottombar = "#1a2a33", BottombarBorder = "#343d46", FooterText = "#d8dee9" },
	{ name = "Material", FontColor = "#eeffff", MainColor = "#212121", AccentColor = "#82aaff", BackgroundColor = "#151515", OutlineColor = "#424242", Outline2 = "#555555", Surface2 = "#2b2b2b", Muted = "#cfd8dc", DimText = "#757575", PopupHover = "#212121", Bottombar = "#1d1d1d", BottombarBorder = "#424242", FooterText = "#eeffff" },
}

local ThemeManager = {
	Library = nil,
	CustomThemes = {},
	BuiltInThemes = {},
	DefaultTheme = { Type = "web", Name = "Default" },
}

local ThemeFolder = "Galax/Obsidian/Settings/Themes"
local DefaultThemeFile = ThemeFolder .. "/__default.lua"

local function ensureFolder(path)
	if type(makefolder) ~= "function" then
		return
	end

	local current = ""
	for part in tostring(path):gmatch("[^/\\]+") do
		current = current == "" and part or (current .. "/" .. part)
		if type(isfolder) ~= "function" or not isfolder(current) then
			pcall(makefolder, current)
		end
	end
end

local function fileName(name)
	return tostring(name or "Theme"):gsub("[^%w%s_%-]", "_") .. ".lua"
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
	ensureFolder(ThemeFolder)
	return pcall(writefile, path, "return " .. serialize(data))
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

local function colorToHex(color)
	if not color or typeof(color) ~= "Color3" then
		return nil
	end

	local r = math.floor(color.R * 255 + 0.5)
	local g = math.floor(color.G * 255 + 0.5)
	local b = math.floor(color.B * 255 + 0.5)

	return string.format("#%02x%02x%02x", r, g, b)
end

local function hexToColor3(hex)
	if typeof(hex) == "Color3" then
		return hex
	end

	if type(hex) ~= "string" then
		return nil
	end

	hex = hex:gsub("#", "")
	if #hex ~= 6 then
		return nil
	end

	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)

	if not r or not g or not b then
		return nil
	end

	return Color3.fromRGB(r, g, b)
end

local function currentThemeSnapshot(Library, name)
	local theme = { name = name }
	local current = Library.ActiveWindow and Library.ActiveWindow:GetTheme() or {}

	theme.BackgroundColor = colorToHex(current.Background)
	theme.MainColor = colorToHex(current.Main)
	theme.AccentColor = colorToHex(current.Accent)
	theme.OutlineColor = colorToHex(current.Outline)
	theme.FontColor = colorToHex(current.Text)
	theme.Outline2 = colorToHex(current.Outline2)
	theme.Surface2 = colorToHex(current.Surface2)
	theme.Muted = colorToHex(current.Muted)
	theme.DimText = colorToHex(current.DimText)
	theme.PopupHover = colorToHex(current.PopupHover)
	theme.Bottombar = colorToHex(current.Bottombar)
	theme.BottombarBorder = colorToHex(current.BottombarBorder)
	theme.FooterText = colorToHex(current.FooterText)

	if Library.Options and Library.Options.FontFace then
		theme.FontFace = Library.Options.FontFace.Value
	end

	return theme
end

for index, entry in ipairs(BuiltInThemes) do
	entry.index = index
	ThemeManager.BuiltInThemes[entry.name] = entry
end

function ThemeManager:SetLibrary(library)
	self.Library = library
end

function ThemeManager:ThemeUpdate()
	local Library = self.Library
	if not Library then
		return
	end

	local theme = {}

	for _, field in ipairs(ThemeFields) do
		local option = Library.Options and Library.Options[field]
		if option and option.Get then
			theme[field] = option:Get()
		end
	end

	if Library.Options and Library.Options.FontFace then
		theme.FontFace = Library.Options.FontFace.Value
	end

	if Library.ActiveWindow then
		Library.ActiveWindow:SetTheme(theme)
	end
end

function ThemeManager:ApplyTheme(name, themeType)
	local Library = self.Library
	local data

	if themeType == "web" then
		data = self.BuiltInThemes[name]
	elseif themeType == "custom" then
		data = self.CustomThemes[name]
	else
		data = self.CustomThemes[name] or self.BuiltInThemes[name]
	end

	if not Library or not data then
		return
	end

	if Library.ActiveWindow then
		Library.ActiveWindow:SetTheme(data)
	end

	for _, field in ipairs(ThemeFields) do
		local option = Library.Options and Library.Options[field]
		local color = hexToColor3(data[field])
		if option and option.SetValueRGB and color then
			option:SetValueRGB(color)
		end
	end

	if data.FontFace and Library.Options and Library.Options.FontFace then
		Library.Options.FontFace:SetValue(data.FontFace)
	end
end

function ThemeManager:SaveCustomTheme(name)
	local Library = self.Library

	if not Library then
		return
	end

	local theme = currentThemeSnapshot(Library, name)

	for _, field in ipairs(ThemeFields) do
		local option = Library.Options and Library.Options[field]
		if option and option.Get then
			theme[field] = colorToHex(option:Get()) or theme[field]
		end
	end

	if Library.Options and Library.Options.FontFace then
		theme.FontFace = Library.Options.FontFace.Value
	end

	self.CustomThemes[name] = theme
	writeTable(ThemeFolder .. "/" .. fileName(name), theme)
end

function ThemeManager:Delete(name)
	self.CustomThemes[name] = nil
	local path = ThemeFolder .. "/" .. fileName(name)
	if type(delfile) == "function" and (type(isfile) ~= "function" or isfile(path)) then
		pcall(delfile, path)
	end
	return true
end

function ThemeManager:ReloadCustomThemes()
	ensureFolder(ThemeFolder)

	if type(listfiles) == "function" then
		for _, path in ipairs(listfiles(ThemeFolder) or {}) do
			local pathText = tostring(path)
			local baseName = pathText:match("([^/\\]+)$") or pathText
			if baseName ~= "__default.lua" and baseName:match("%.lua$") then
				local data = readTable(pathText)
				if data and data.name then
					self.CustomThemes[data.name] = data
				end
			end
		end
	end

	local names = {}

	for name in pairs(self.CustomThemes) do
		names[#names + 1] = name
	end

	table.sort(names)
	return names
end

function ThemeManager:LoadDefault()
	local Library = self.Library
	local saved = readTable(DefaultThemeFile)
	if saved and saved.Type and saved.Name then
		self.DefaultTheme = saved
	end

	local themeType = self.DefaultTheme.Type or "web"
	local themeName = self.DefaultTheme.Name or "Default"

	self:ReloadCustomThemes()

	if themeType == "custom" then
		if Library and Library.Options and Library.Options.ThemeManager_CustomThemeList then
			Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Library.Options.ThemeManager_CustomThemeList:SetValue(themeName)
		end

		self:ApplyTheme(themeName, "custom")
		return
	end

	if Library and Library.Options and Library.Options.ThemeManager_ThemeList then
		Library.Options.ThemeManager_ThemeList:SetValue(themeName)
	end
end

function ThemeManager:GetDefaultTheme()
	local saved = readTable(DefaultThemeFile)
	if saved and saved.Type and saved.Name then
		self.DefaultTheme = saved
	end

	return self.DefaultTheme.Type or "web", self.DefaultTheme.Name or "Default"
end

function ThemeManager:SaveDefault(name, themeType)
	self.DefaultTheme = {
		Type = themeType or (self.CustomThemes[name] and "custom" or "web"),
		Name = name or "Default",
	}

	writeTable(DefaultThemeFile, self.DefaultTheme)
	return true
end

function ThemeManager:ResetDefault()
	local themeType, themeName = self:GetDefaultTheme()

	self:ReloadCustomThemes()
	self:ApplyTheme(themeName, themeType)

	return true, themeType, themeName
end

function ThemeManager:CreateGroupBox(tab)
	return tab:AddLeftGroupbox("Themes")
end

function ThemeManager:CreateThemeManager(groupbox)
	local Library = self.Library
	if not Library then
		return
	end

	local function refreshCustomThemeList()
		if Library.Options.ThemeManager_CustomThemeList then
			Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
		end
	end

	local function resetDefaultTheme()
		local _, themeType, themeName = self:ResetDefault()

		if themeType == "custom" then
			if Library.Options.ThemeManager_CustomThemeList then
				Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
				Library.Options.ThemeManager_CustomThemeList:SetValue(themeName)
			end
		else
			if Library.Options.ThemeManager_ThemeList then
				Library.Options.ThemeManager_ThemeList:SetValue(themeName)
			end
			if Library.Options.ThemeManager_CustomThemeList then
				Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
			end
		end

		Library:Notify(string.format("Reset theme to default %q", tostring(themeName)), 4)
	end

	groupbox:AddLabel("Background color"):AddColorPicker("BackgroundColor", { Default = Color3.fromRGB(15, 15, 15) })
	groupbox:AddLabel("Main color"):AddColorPicker("MainColor", { Default = Color3.fromRGB(25, 25, 25) })
	groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", { Default = Color3.fromRGB(125, 85, 255) })
	groupbox:AddLabel("Outline color"):AddColorPicker("OutlineColor", { Default = Color3.fromRGB(40, 40, 40) })
	groupbox:AddLabel("Font color"):AddColorPicker("FontColor", { Default = Color3.fromRGB(255, 255, 255) })

	local fontValues = {}
	if Library.FontMap then
		for name in pairs(Library.FontMap) do
			fontValues[#fontValues + 1] = name
		end
	end
	table.sort(fontValues)

	groupbox:AddDropdown("FontFace", {
		Text = "Font Face",
		Values = fontValues,
		Default = "Monospace",
	})

	local themeNames = {}
	for name in pairs(self.BuiltInThemes) do
		themeNames[#themeNames + 1] = name
	end
	table.sort(themeNames, function(a, b)
		return (self.BuiltInThemes[a].index or 99) < (self.BuiltInThemes[b].index or 99)
	end)

	groupbox:AddDivider()

	groupbox:AddDropdown("ThemeManager_ThemeList", {
		Text = "Theme list",
		Values = themeNames,
		Default = themeNames[1],
	})

	groupbox:AddButton("Set as default", function()
		local themeName = Library.Options.ThemeManager_ThemeList.Value
		self:SaveDefault(themeName, "web")
		Library:Notify(string.format("Set default theme to %q", tostring(themeName)), 4)
	end)

	groupbox:AddButton("Reset default", resetDefaultTheme)

	if Library.Options.ThemeManager_ThemeList then
		Library.Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Library.Options.ThemeManager_ThemeList.Value, "web")
		end)
	end

	groupbox:AddDivider()

	groupbox:AddInput("ThemeManager_CustomThemeName", {
		Text = "Custom theme name",
	})

	groupbox:AddButton("Create theme", function()
		local name = Library.Options.ThemeManager_CustomThemeName.Value

		if not name or name:gsub(" ", "") == "" then
			Library:Notify("Invalid theme name (empty)", 4)
			return
		end

		self:SaveCustomTheme(name)
		Library:Notify(string.format("Created theme %q", name), 4)
		refreshCustomThemeList()
	end)

	groupbox:AddDivider()

	groupbox:AddDropdown("ThemeManager_CustomThemeList", {
		Text = "Custom themes",
		Values = self:ReloadCustomThemes(),
		AllowNull = true,
	})

	groupbox:AddButton("Load theme", function()
		local name = Library.Options.ThemeManager_CustomThemeList.Value
		if name then
			self:ApplyTheme(name, "custom")
			Library:Notify(string.format("Loaded theme %q", name), 4)
		end
	end)

	groupbox:AddButton("Overwrite theme", function()
		local name = Library.Options.ThemeManager_CustomThemeList.Value
		if name then
			self:SaveCustomTheme(name)
			Library:Notify(string.format("Overwrote theme %q", name), 4)
		end
	end)

	groupbox:AddButton("Delete theme", function()
		local name = Library.Options.ThemeManager_CustomThemeList.Value
		if not name then
			return
		end

		local ok, err = self:Delete(name)
		if not ok then
			Library:Notify("Failed to delete theme: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Deleted theme %q", name), 4)
		refreshCustomThemeList()
	end)

	groupbox:AddButton("Refresh list", function()
		refreshCustomThemeList()
	end)

	groupbox:AddButton("Set as default", function()
		local name = Library.Options.ThemeManager_CustomThemeList.Value
		if not name then
			Library:Notify("No custom theme selected", 4)
			return
		end

		self:SaveDefault(name, "custom")
		Library:Notify(string.format("Set default custom theme to %q", name), 4)
	end)

	groupbox:AddButton("Reset default", resetDefaultTheme)

	local function updateTheme()
		self:ThemeUpdate()
	end

	for _, field in ipairs({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor" }) do
		if Library.Options[field] then
			Library.Options[field]:OnChanged(updateTheme)
		end
	end

	if Library.Options.FontFace then
		Library.Options.FontFace:OnChanged(function(value)
			if Library.ActiveWindow then
				Library.ActiveWindow:SetTheme({ FontFace = value })
			end
		end)
	end

	self:LoadDefault()
end

function ThemeManager:ApplyToTab(tab)
	self:CreateThemeManager(self:CreateGroupBox(tab))
end

function ThemeManager:ApplyToGroupbox(groupbox)
	self:CreateThemeManager(groupbox)
end

_G.ObsidianMatchaAddons = _G.ObsidianMatchaAddons or {}
_G.ObsidianMatchaAddons["addons/ThemeManager.lua"] = ThemeManager

return ThemeManager
