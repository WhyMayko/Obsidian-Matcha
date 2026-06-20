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
	{ name = "Ayu Dark", FontColor = "#b3b1ad", MainColor = "#0f1419", AccentColor = "#e6b450", BackgroundColor = "#0a0e14", OutlineColor = "#273747", Outline2 = "#3e4b59", Surface2 = "#14191f", Muted = "#4d5a68", DimText = "#707a8c", PopupHover = "#0f1419", Bottombar = "#0d1116", BottombarBorder = "#273747", FooterText = "#b3b1ad" },
	{ name = "BBot", FontColor = "#ffffff", MainColor = "#1e1e1e", AccentColor = "#7e48a3", BackgroundColor = "#232323", OutlineColor = "#141414", Outline2 = "#2c2c2c", Surface2 = "#282828", Muted = "#b0b0b0", DimText = "#676767", PopupHover = "#1e1e1e", Bottombar = "#252525", BottombarBorder = "#343434", FooterText = "#c8c8c8" },
	{ name = "Blood Moon", FontColor = "#ffcccc", MainColor = "#1e0000", AccentColor = "#ff0000", BackgroundColor = "#140000", OutlineColor = "#330000", Outline2 = "#4d0000", Surface2 = "#290000", Muted = "#cc6666", DimText = "#994c4c", PopupHover = "#1e0000", Bottombar = "#0f0000", BottombarBorder = "#330000", FooterText = "#ffcccc" },
	{ name = "Catppuccin", FontColor = "#d9e0ee", MainColor = "#302d41", AccentColor = "#f5c2e7", BackgroundColor = "#1e1e2e", OutlineColor = "#575268", Outline2 = "#6e6880", Surface2 = "#3b374f", Muted = "#c9cbff", DimText = "#8b88a8", PopupHover = "#302d41", Bottombar = "#26263a", BottombarBorder = "#575268", FooterText = "#d9e0ee" },
	{ name = "Cyberpunk", FontColor = "#f9f9f9", MainColor = "#262335", AccentColor = "#00ff9f", BackgroundColor = "#1a1a2e", OutlineColor = "#413c5e", Outline2 = "#555078", Surface2 = "#302b45", Muted = "#d6f7ec", DimText = "#708a94", PopupHover = "#262335", Bottombar = "#202039", BottombarBorder = "#413c5e", FooterText = "#e4fff6" },
	{ name = "Discord", FontColor = "#dbdee1", MainColor = "#2b2d31", AccentColor = "#5865f2", BackgroundColor = "#313338", OutlineColor = "#1e1f22", Outline2 = "#3f4147", Surface2 = "#383a40", Muted = "#b5bac1", DimText = "#949ba4", PopupHover = "#2b2d31", Bottombar = "#1e1f22", BottombarBorder = "#1e1f22", FooterText = "#dbdee1" },
	{ name = "Dracula", FontColor = "#f8f8f2", MainColor = "#44475a", AccentColor = "#ff79c6", BackgroundColor = "#282a36", OutlineColor = "#6272a4", Outline2 = "#7587bf", Surface2 = "#505467", Muted = "#d6d6d0", DimText = "#8f91a2", PopupHover = "#44475a", Bottombar = "#303241", BottombarBorder = "#6272a4", FooterText = "#f8f8f2" },
	{ name = "Everforest", FontColor = "#d3c6aa", MainColor = "#323c41", AccentColor = "#a7c080", BackgroundColor = "#2b3339", OutlineColor = "#4b565c", Outline2 = "#5c6a72", Surface2 = "#3a454a", Muted = "#859289", DimText = "#9da9a0", PopupHover = "#323c41", Bottombar = "#2e373d", BottombarBorder = "#4b565c", FooterText = "#d3c6aa" },
	{ name = "Fatality", FontColor = "#ffffff", MainColor = "#1e1842", AccentColor = "#c50754", BackgroundColor = "#191335", OutlineColor = "#3c355d", Outline2 = "#514a74", Surface2 = "#282052", Muted = "#b7b1ce", DimText = "#716a93", PopupHover = "#1e1842", Bottombar = "#211943", BottombarBorder = "#3c355d", FooterText = "#d0cbe5" },
	{ name = "GitHub", FontColor = "#c9d1d9", MainColor = "#161b22", AccentColor = "#58a6ff", BackgroundColor = "#0d1117", OutlineColor = "#30363d", Outline2 = "#484f58", Surface2 = "#21262d", Muted = "#8b949e", DimText = "#6e7681", PopupHover = "#161b22", Bottombar = "#010409", BottombarBorder = "#30363d", FooterText = "#c9d1d9" },
	{ name = "Gruvbox", FontColor = "#ebdbb2", MainColor = "#3c3836", AccentColor = "#fb4934", BackgroundColor = "#282828", OutlineColor = "#504945", Outline2 = "#665c54", Surface2 = "#49413e", Muted = "#d5c4a1", DimText = "#928374", PopupHover = "#3c3836", Bottombar = "#302f2d", BottombarBorder = "#504945", FooterText = "#d5c4a1" },
	{ name = "Jester", FontColor = "#ffffff", MainColor = "#242424", AccentColor = "#db4467", BackgroundColor = "#1c1c1c", OutlineColor = "#373737", Outline2 = "#454545", Surface2 = "#2c2c2c", Muted = "#b5b5b5", DimText = "#707070", PopupHover = "#242424", Bottombar = "#202020", BottombarBorder = "#373737", FooterText = "#cfcfcf" },
	{ name = "Material", FontColor = "#eeffff", MainColor = "#212121", AccentColor = "#82aaff", BackgroundColor = "#151515", OutlineColor = "#424242", Outline2 = "#555555", Surface2 = "#2b2b2b", Muted = "#cfd8dc", DimText = "#757575", PopupHover = "#212121", Bottombar = "#1d1d1d", BottombarBorder = "#424242", FooterText = "#eeffff" },
	{ name = "Matrix", FontColor = "#00ff41", MainColor = "#111111", AccentColor = "#00ff41", BackgroundColor = "#0d0d0d", OutlineColor = "#003b00", Outline2 = "#005900", Surface2 = "#1a1a1a", Muted = "#008f11", DimText = "#00660c", PopupHover = "#111111", Bottombar = "#0a0a0a", BottombarBorder = "#003b00", FooterText = "#008f11" },
	{ name = "Mint", FontColor = "#ffffff", MainColor = "#242424", AccentColor = "#3db488", BackgroundColor = "#1c1c1c", OutlineColor = "#373737", Outline2 = "#454545", Surface2 = "#2c2c2c", Muted = "#b5b5b5", DimText = "#707070", PopupHover = "#242424", Bottombar = "#202020", BottombarBorder = "#373737", FooterText = "#cfcfcf" },
	{ name = "Monokai", FontColor = "#f8f8f2", MainColor = "#272822", AccentColor = "#f92672", BackgroundColor = "#1e1f1c", OutlineColor = "#49483e", Outline2 = "#5d5b50", Surface2 = "#32332b", Muted = "#d8d8d2", DimText = "#858578", PopupHover = "#272822", Bottombar = "#24251f", BottombarBorder = "#49483e", FooterText = "#e6e6df" },
	{ name = "Nebula", FontColor = "#e0e0e0", MainColor = "#1b1442", AccentColor = "#b06ab3", BackgroundColor = "#0f0c29", OutlineColor = "#302b63", Outline2 = "#484285", Surface2 = "#241d55", Muted = "#a0a0b0", DimText = "#808090", PopupHover = "#1b1442", Bottombar = "#0c0a20", BottombarBorder = "#302b63", FooterText = "#e0e0e0" },
	{ name = "Nord", FontColor = "#eceff4", MainColor = "#3b4252", AccentColor = "#88c0d0", BackgroundColor = "#2e3440", OutlineColor = "#4c566a", Outline2 = "#5e6a82", Surface2 = "#434c5e", Muted = "#d8dee9", DimText = "#8f9aaa", PopupHover = "#3b4252", Bottombar = "#343b49", BottombarBorder = "#4c566a", FooterText = "#d8dee9" },
	{ name = "Oceanic Next", FontColor = "#d8dee9", MainColor = "#1b2b34", AccentColor = "#6699cc", BackgroundColor = "#16232a", OutlineColor = "#343d46", Outline2 = "#4f5b66", Surface2 = "#243844", Muted = "#c0c5ce", DimText = "#65737e", PopupHover = "#1b2b34", Bottombar = "#1a2a33", BottombarBorder = "#343d46", FooterText = "#d8dee9" },
	{ name = "One Dark", FontColor = "#abb2bf", MainColor = "#282c34", AccentColor = "#c678dd", BackgroundColor = "#21252b", OutlineColor = "#5c6370", Outline2 = "#707886", Surface2 = "#313640", Muted = "#c8ccd4", DimText = "#7f848e", PopupHover = "#282c34", Bottombar = "#252a31", BottombarBorder = "#5c6370", FooterText = "#c8ccd4" },
	{ name = "Outrun", FontColor = "#00ffff", MainColor = "#1a0a3a", AccentColor = "#ff007f", BackgroundColor = "#0d0221", OutlineColor = "#2b1154", Outline2 = "#3c1874", Surface2 = "#240f4d", Muted = "#b3b3ff", DimText = "#8080ff", PopupHover = "#1a0a3a", Bottombar = "#0a011a", BottombarBorder = "#2b1154", FooterText = "#00ffff" },
	{ name = "Quartz", FontColor = "#ffffff", MainColor = "#232330", AccentColor = "#426e87", BackgroundColor = "#1d1b26", OutlineColor = "#27232f", Outline2 = "#3b3545", Surface2 = "#2d2b3a", Muted = "#b7b3c5", DimText = "#6c6879", PopupHover = "#232330", Bottombar = "#211f2b", BottombarBorder = "#383340", FooterText = "#d0cbdd" },
	{ name = "Rosé Pine", FontColor = "#e0def4", MainColor = "#1f1d2e", AccentColor = "#c4a7e7", BackgroundColor = "#191724", OutlineColor = "#26233a", Outline2 = "#44415a", Surface2 = "#2a273f", Muted = "#908caa", DimText = "#6e6a86", PopupHover = "#1f1d2e", Bottombar = "#1d1a29", BottombarBorder = "#26233a", FooterText = "#e0def4" },
	{ name = "Royal", FontColor = "#ffffff", MainColor = "#24243e", AccentColor = "#e94560", BackgroundColor = "#1a1a2e", OutlineColor = "#3a3a5a", Outline2 = "#4f4f7a", Surface2 = "#2d2d4a", Muted = "#b0b0c0", DimText = "#8a8a9a", PopupHover = "#24243e", Bottombar = "#151525", BottombarBorder = "#3a3a5a", FooterText = "#ffffff" },
	{ name = "Solarized", FontColor = "#839496", MainColor = "#073642", AccentColor = "#cb4b16", BackgroundColor = "#002b36", OutlineColor = "#586e75", Outline2 = "#6c8188", Surface2 = "#0c4350", Muted = "#93a1a1", DimText = "#657b83", PopupHover = "#073642", Bottombar = "#06323d", BottombarBorder = "#586e75", FooterText = "#93a1a1" },
	{ name = "Spotify", FontColor = "#ffffff", MainColor = "#181818", AccentColor = "#1db954", BackgroundColor = "#121212", OutlineColor = "#282828", Outline2 = "#333333", Surface2 = "#282828", Muted = "#b3b3b3", DimText = "#a7a7a7", PopupHover = "#181818", Bottombar = "#000000", BottombarBorder = "#282828", FooterText = "#ffffff" },
	{ name = "Synthwave", FontColor = "#f0f0f0", MainColor = "#2b213a", AccentColor = "#f92aad", BackgroundColor = "#262335", OutlineColor = "#36274e", Outline2 = "#4b396b", Surface2 = "#312642", Muted = "#9d8baf", DimText = "#756287", PopupHover = "#2b213a", Bottombar = "#281e35", BottombarBorder = "#36274e", FooterText = "#f0f0f0" },
	{ name = "Tokyo Night", FontColor = "#ffffff", MainColor = "#191925", AccentColor = "#6759b3", BackgroundColor = "#16161f", OutlineColor = "#323232", Outline2 = "#44445a", Surface2 = "#222233", Muted = "#a9abc6", DimText = "#62657f", PopupHover = "#191925", Bottombar = "#1a1a25", BottombarBorder = "#323244", FooterText = "#c3c6df" },
	{ name = "Twitch", FontColor = "#efeff1", MainColor = "#18181b", AccentColor = "#9146ff", BackgroundColor = "#0e0e10", OutlineColor = "#303032", Outline2 = "#464649", Surface2 = "#1f1f23", Muted = "#adadb8", DimText = "#848494", PopupHover = "#18181b", Bottombar = "#0e0e10", BottombarBorder = "#303032", FooterText = "#efeff1" },
	{ name = "Ubuntu", FontColor = "#ffffff", MainColor = "#3e3e3e", AccentColor = "#e2581e", BackgroundColor = "#323232", OutlineColor = "#191919", Outline2 = "#505050", Surface2 = "#474747", Muted = "#c9c9c9", DimText = "#7a7a7a", PopupHover = "#3e3e3e", Bottombar = "#363636", BottombarBorder = "#505050", FooterText = "#dddddd" },
	{ name = "Vampire", FontColor = "#ffb3c6", MainColor = "#24141c", AccentColor = "#ff3366", BackgroundColor = "#1a0f14", OutlineColor = "#3d1f2d", Outline2 = "#522a3d", Surface2 = "#2f1a25", Muted = "#cc6685", DimText = "#994d63", PopupHover = "#24141c", Bottombar = "#140b0f", BottombarBorder = "#3d1f2d", FooterText = "#ffb3c6" },
	{ name = "Vercel", FontColor = "#ededed", MainColor = "#111111", AccentColor = "#ffffff", BackgroundColor = "#000000", OutlineColor = "#333333", Outline2 = "#444444", Surface2 = "#222222", Muted = "#a1a1a1", DimText = "#888888", PopupHover = "#111111", Bottombar = "#000000", BottombarBorder = "#333333", FooterText = "#ededed" },
}

local ThemeManager = {
	Library = nil,
	CustomThemes = {},
	BuiltInThemes = {},
	DefaultTheme = { Type = "web", Name = "Default" },
}

local HttpService = game:GetService("HttpService")
local SettingsFolder = "Galax/Obsidian/Settings"
local ThemeFolder = SettingsFolder .. "/Themes"
local DefaultThemeFile = SettingsFolder .. "/DefaultTheme.txt"

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
	return tostring(name or "Theme"):gsub("[^%w%s_%-]", "_") .. ".txt"
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

	local data = HttpService:JSONDecode(source)
	if type(data) == "table" then
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
	elseif themeType == "local" or themeType == "custom" then
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
		return false, "library not set"
	end

	if not name or name:gsub(" ", "") == "" then
		return false, "no name"
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
	local ok, err = writeTable(ThemeFolder .. "/" .. fileName(name), theme)
	if not ok then
		self.CustomThemes[name] = nil
		return false, err
	end

	return true
end

function ThemeManager:Delete(name)
	self.CustomThemes[name] = nil
	local path = ThemeFolder .. "/" .. fileName(name)
	if isfile(path) then
		delfile(path)
	end
	if self.DefaultTheme.Type == "local" and self.DefaultTheme.Name == name then
		self:ResetDefault()
	end
	return true
end

function ThemeManager:ReloadCustomThemes()
	ensureFolder(ThemeFolder)

	for _, path in ipairs(listfiles(ThemeFolder) or {}) do
		local pathText = tostring(path)
			local baseName = pathText:match("([^/\\]+)$") or pathText
			if baseName:match("%.lua$") then
				local data = readTable(pathText)
				if data and data.name then
					self.CustomThemes[data.name] = data
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
	local themeType, themeName = self:GetDefaultTheme()

	if themeType == "local" then
		if Library and Library.Options and Library.Options.ThemeManager_CustomThemeList then
			Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Library.Options.ThemeManager_CustomThemeList:SetValue(themeName)
		end

		self:ApplyTheme(themeName, "local")
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

	local themeType = self.DefaultTheme.Type or "web"
	local themeName = self.DefaultTheme.Name or "Default"

	if themeType == "custom" then
		themeType = "local"
	end

	if themeType == "web" then
		if not self.BuiltInThemes[themeName] then
			themeName = "Default"
		end
	elseif themeType == "local" then
		self:ReloadCustomThemes()
		if not self.CustomThemes[themeName] then
			self:ResetDefault()
			themeType = "web"
			themeName = "Default"
		end
	else
		themeType = "web"
		themeName = "Default"
	end

	return themeType, themeName
end

function ThemeManager:LoadDefault()
	local themeType, themeName = self:GetDefaultTheme()
	self:ApplyTheme(themeName, themeType)
end

function ThemeManager:SaveDefault(name, themeType)
	local resolvedType = themeType == "custom" and "local" or (themeType or (self.CustomThemes[name] and "local" or "web"))
	local resolvedName = name or "Default"

	if resolvedType == "web" and not self.BuiltInThemes[resolvedName] then
		return false, "web theme not found"
	end
	if resolvedType == "local" and not self.CustomThemes[resolvedName] then
		self:ReloadCustomThemes()
		if not self.CustomThemes[resolvedName] then
			return false, "local theme not found"
		end
	end

	self.DefaultTheme = {
		Type = resolvedType,
		Name = resolvedName,
	}

	return writeTable(DefaultThemeFile, self.DefaultTheme)
end

function ThemeManager:ResetDefault()
	self.DefaultTheme = { Type = "web", Name = "Default" }

	writeTable(DefaultThemeFile, self.DefaultTheme)

	self:ApplyTheme("Default", "web")

	return true, "web", "Default"
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
		local themeType, themeName = self:GetDefaultTheme()
		self:ApplyTheme(themeName, themeType)

		if themeType == "local" then
			if Library.Options.ThemeManager_CustomThemeList then
				Library.Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
				Library.Options.ThemeManager_CustomThemeList:SetValue(themeName)
			end
			if Library.Options.ThemeManager_ThemeList then
				Library.Options.ThemeManager_ThemeList:SetValue(nil)
			end
		else
			if Library.Options.ThemeManager_ThemeList then
				Library.Options.ThemeManager_ThemeList:SetValue(themeName)
			end
			if Library.Options.ThemeManager_CustomThemeList then
				Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
			end
		end

		Library:Notify(string.format("Loaded default theme: %q", tostring(themeName)), 4)
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
		local ok, err = self:SaveDefault(themeName, "web")
		if not ok then
			Library:Notify("Failed to set default theme: " .. tostring(err), 4)
			return
		end
		Library:Notify(string.format("Set default theme to %q", tostring(themeName)), 4)
	end)

	if Library.Options.ThemeManager_ThemeList then
		Library.Options.ThemeManager_ThemeList:OnChanged(function()
			if Library.Options.ThemeManager_CustomThemeList then
				Library.Options.ThemeManager_CustomThemeList:SetValue(nil)
			end
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

		local ok, err = self:SaveCustomTheme(name)
		if not ok then
			Library:Notify("Failed to create theme: " .. tostring(err), 4)
			return
		end

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
			self:ApplyTheme(name, "local")
			Library:Notify(string.format("Loaded theme %q", name), 4)
		end
	end)

	groupbox:AddButton("Overwrite theme", function()
		local name = Library.Options.ThemeManager_CustomThemeList.Value
		if name then
			local ok, err = self:SaveCustomTheme(name)
			if not ok then
				Library:Notify("Failed to overwrite theme: " .. tostring(err), 4)
				return
			end
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

		local ok, err = self:SaveDefault(name, "local")
		if not ok then
			Library:Notify("Failed to set default theme: " .. tostring(err), 4)
			return
		end
		Library:Notify(string.format("Set default local theme to %q", name), 4)
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
