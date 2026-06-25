local TextManager = {}

local Fonts = {
	UI = Drawing.Fonts.UI,
	System = Drawing.Fonts.System,
	SystemBold = Drawing.Fonts.SystemBold,
	Minecraft = Drawing.Fonts.Minecraft,
	Monospace = Drawing.Fonts.Monospace,
	Pixel = Drawing.Fonts.Pixel,
	Fortnite = Drawing.Fonts.Fortnite,
}

local FontNamesByValue = {}
for name, value in pairs(Fonts) do
	FontNamesByValue[value] = name
end

local FontMetrics = {
	UI = {
		Scale = 0.505,
		Chars = {
			A = 1.100, B = 1.060, C = 1.060, D = 1.040, E = 1.060, F = 1.100, G = 1.080,
			H = 1.040, I = 1.060, J = 1.000, K = 1.120, L = 1.060, M = 1.060, N = 1.060,
			O = 1.060, P = 1.120, Q = 1.040, R = 1.060, S = 1.060, T = 1.060, U = 1.120,
			V = 1.060, W = 1.060, X = 1.020, Y = 1.080, Z = 1.120,
			a = 1.000, b = 1.060, c = 1.040, d = 1.060, e = 1.000, f = 1.180, g = 1.060,
			h = 1.060, i = 1.060, j = 1.040, k = 1.120, l = 1.000, m = 1.120, n = 1.060,
			o = 1.060, p = 1.040, q = 1.060, r = 1.060, s = 1.120, t = 1.060, u = 1.060,
			v = 1.060, w = 1.120, x = 0.980, y = 1.120, z = 1.060,
			["0"] = 1.060, ["1"] = 1.060, ["2"] = 1.060, ["3"] = 1.040, ["4"] = 1.160,
			["5"] = 1.020, ["6"] = 1.080, ["7"] = 1.040, ["8"] = 1.120, ["9"] = 1.040,
			[" "] = 1.070, ["."] = 1.100, ["_"] = 1.040, ["-"] = 0.980, [":"] = 1.100, ["/"] = 1.120,
		},
	},
	System = {
		Scale = 0.530,
		Chars = {
			A = 1.120, B = 1.000, C = 1.120, D = 1.200, E = 0.880, F = 0.880, G = 1.140,
			H = 1.200, I = 0.480, J = 0.840, K = 1.000, L = 0.880, M = 1.450, N = 1.120,
			O = 1.200, P = 1.000, Q = 1.200, R = 1.020, S = 1.000, T = 1.000, U = 1.140,
			V = 1.060, W = 1.570, X = 1.140, Y = 1.060, Z = 0.960,
			a = 0.880, b = 1.060, c = 0.880, d = 1.000, e = 0.860, f = 0.540, g = 1.060,
			h = 1.000, i = 0.440, j = 0.440, k = 0.880, l = 0.440, m = 1.450, n = 1.060,
			o = 0.840, p = 1.000, q = 1.000, r = 0.580, s = 0.880, t = 0.560, u = 1.000,
			v = 0.880, w = 1.330, x = 0.820, y = 0.880, z = 0.940,
			["0"] = 1.000, ["1"] = 0.760, ["2"] = 1.000, ["3"] = 1.060, ["4"] = 0.960,
			["5"] = 1.000, ["6"] = 1.000, ["7"] = 0.880, ["8"] = 1.020, ["9"] = 1.000,
			[" "] = 0.380, ["."] = 0.380, ["_"] = 0.760, ["-"] = 0.720, [":"] = 0.380, ["/"] = 0.620,
		},
	},
	SystemBold = {
		Scale = 0.540,
		Chars = {
			A = 1.100, B = 0.980, C = 1.100, D = 1.120, E = 0.860, F = 0.860, G = 1.120,
			H = 1.120, I = 0.420, J = 0.860, K = 1.000, L = 0.800, M = 1.350, N = 1.120,
			O = 1.240, P = 0.980, Q = 1.240, R = 0.980, S = 0.980, T = 1.000, U = 1.100,
			V = 1.060, W = 1.470, X = 1.120, Y = 0.980, Z = 1.060,
			a = 0.900, b = 1.000, c = 0.820, d = 0.980, e = 0.800, f = 0.620, g = 0.980,
			h = 1.000, i = 0.420, j = 0.380, k = 0.860, l = 0.380, m = 1.350, n = 0.980,
			o = 0.880, p = 0.980, q = 0.980, r = 0.620, s = 0.860, t = 0.620, u = 0.940,
			v = 0.920, w = 1.230, x = 0.860, y = 0.880, z = 0.860,
			["0"] = 0.980, ["1"] = 0.740, ["2"] = 1.000, ["3"] = 1.040, ["4"] = 0.980,
			["5"] = 0.940, ["6"] = 0.980, ["7"] = 0.900, ["8"] = 1.020, ["9"] = 0.960,
			[" "] = 0.400, ["."] = 0.400, ["_"] = 0.740, ["-"] = 0.620, [":"] = 0.400, ["/"] = 0.800,
		},
	},
	Minecraft = {
		Scale = 0.570,
		Chars = {
			A = 1.040, B = 1.220, C = 1.340, D = 1.240, E = 1.280, F = 1.060, G = 1.280,
			H = 1.220, I = 0.720, J = 0.920, K = 1.120, L = 1.040, M = 1.180, N = 1.220,
			O = 1.460, P = 1.240, Q = 1.460, R = 1.520, S = 1.120, T = 1.220, U = 1.200,
			V = 1.200, W = 1.160, X = 1.120, Y = 1.280, Z = 1.260,
			a = 1.020, b = 1.240, c = 1.100, d = 1.000, e = 1.000, f = 0.900, g = 0.940,
			h = 0.960, i = 0.280, j = 0.880, k = 0.940, l = 0.240, m = 1.580, n = 1.100,
			o = 1.000, p = 1.060, q = 0.980, r = 0.940, s = 0.940, t = 0.700, u = 0.940,
			v = 1.220, w = 1.300, x = 1.220, y = 1.000, z = 0.940,
			["0"] = 0.930, ["1"] = 0.760, ["2"] = 0.990, ["3"] = 0.930, ["4"] = 1.050,
			["5"] = 1.230, ["6"] = 1.050, ["7"] = 0.950, ["8"] = 0.990, ["9"] = 1.000,
			[" "] = 0.520, ["."] = 0.300, ["_"] = 0.960, ["-"] = 0.760, [":"] = 0.420, ["/"] = 1.000,
		},
	},
	Monospace = {
		Scale = 0.480,
		Chars = {
			A = 0.940, B = 0.980, C = 0.900, D = 0.980, E = 0.960, F = 0.980, G = 0.980,
			H = 0.900, I = 0.960, J = 0.900, K = 1.060, L = 0.960, M = 0.980, N = 0.960,
			O = 0.920, P = 0.960, Q = 0.980, R = 1.040, S = 1.020, T = 0.860, U = 0.960,
			V = 0.980, W = 0.960, X = 0.980, Y = 0.980, Z = 1.040,
			a = 0.900, b = 0.900, c = 0.980, d = 0.960, e = 0.900, f = 0.980, g = 0.980,
			h = 1.040, i = 0.960, j = 0.900, k = 0.980, l = 0.980, m = 0.900, n = 0.960,
			o = 0.960, p = 0.920, q = 0.980, r = 0.900, s = 0.960, t = 1.060, u = 0.900,
			v = 0.960, w = 0.980, x = 1.040, y = 0.980, z = 0.900,
			["0"] = 0.960, ["1"] = 0.980, ["2"] = 0.980, ["3"] = 0.960, ["4"] = 0.900,
			["5"] = 0.980, ["6"] = 0.980, ["7"] = 0.960, ["8"] = 0.980, ["9"] = 1.000,
			[" "] = 0.960, ["."] = 0.860, ["_"] = 1.040, ["-"] = 1.000, [":"] = 1.000, ["/"] = 1.000,
		},
	},
	Pixel = {
		Scale = 0.520,
		Chars = {
			A = 1.000, B = 0.960, C = 1.040, D = 1.020, E = 1.080, F = 1.040, G = 1.080,
			H = 1.020, I = 0.780, J = 0.960, K = 1.080, L = 1.040, M = 1.220, N = 1.020,
			O = 1.020, P = 1.020, Q = 1.000, R = 1.060, S = 1.080, T = 0.720, U = 1.020,
			V = 0.760, W = 1.160, X = 1.100, Y = 0.700, Z = 1.020,
			a = 1.020, b = 1.040, c = 1.020, d = 1.020, e = 1.040, f = 1.020, g = 1.020,
			h = 1.020, i = 0.780, j = 1.020, k = 1.100, l = 1.020, m = 1.220, n = 1.020,
			o = 1.020, p = 1.040, q = 1.020, r = 1.020, s = 1.040, t = 0.760, u = 0.960,
			v = 0.700, w = 1.220, x = 1.100, y = 0.700, z = 1.020,
			["0"] = 1.040, ["1"] = 0.820, ["2"] = 1.020, ["3"] = 1.040, ["4"] = 1.020,
			["5"] = 1.020, ["6"] = 1.040, ["7"] = 1.020, ["8"] = 1.020, ["9"] = 1.000,
			[" "] = 1.120, ["."] = 0.440, ["_"] = 1.040, ["-"] = 0.760, [":"] = 0.460, ["/"] = 1.000,
		},
	},
	Fortnite = {
		Scale = 0.540,
		Chars = {
			A = 0.850, B = 0.850, C = 0.810, D = 0.870, E = 0.670, F = 0.690, G = 0.910,
			H = 0.870, I = 0.440, J = 0.730, K = 0.810, L = 0.670, M = 1.050, N = 0.810,
			O = 0.810, P = 0.850, Q = 0.870, R = 0.870, S = 0.790, T = 0.750, U = 0.790,
			V = 0.890, W = 1.150, X = 0.850, Y = 0.690, Z = 0.750,
			a = 0.860, b = 0.860, c = 0.740, d = 0.880, e = 0.800, f = 0.680, g = 0.920,
			h = 0.860, i = 0.380, j = 0.480, k = 0.880, l = 0.480, m = 1.250, n = 0.860,
			o = 0.840, p = 0.820, q = 0.860, r = 0.800, s = 0.680, t = 0.680, u = 0.820,
			v = 0.740, w = 1.050, x = 0.740, y = 0.740, z = 0.740,
			["0"] = 0.850, ["1"] = 0.560, ["2"] = 0.870, ["3"] = 0.870, ["4"] = 0.910,
			["5"] = 0.870, ["6"] = 0.810, ["7"] = 0.730, ["8"] = 0.870, ["9"] = 0.850,
			[" "] = 0.320, ["."] = 0.420, ["_"] = 0.500, ["-"] = 0.620, [":"] = 0.360, ["/"] = 1.000,
		},
	},
}

local KeyNameMap = {
	["1"] = "M1", ["2"] = "M2", ["4"] = "M3", ["5"] = "M4", ["6"] = "M5",
	["8"] = "BACK", ["9"] = "TAB", ["12"] = "CLEAR", ["13"] = "ENTER",
	["16"] = "SHIFT", ["17"] = "CTRL", ["18"] = "ALT", ["19"] = "PAUSE",
	["20"] = "CAPS", ["27"] = "ESC", ["32"] = "SPACE", ["33"] = "PAGEUP",
	["34"] = "PAGEDOWN", ["35"] = "END", ["36"] = "HOME", ["37"] = "LEFT",
	["38"] = "UP", ["39"] = "RIGHT", ["40"] = "DOWN", ["41"] = "SELECT",
	["42"] = "PRINT", ["43"] = "EXECUTE", ["44"] = "PRTSC", ["45"] = "INS",
	["46"] = "DEL", ["47"] = "HELP",
	["48"] = "0", ["49"] = "1", ["50"] = "2", ["51"] = "3", ["52"] = "4",
	["53"] = "5", ["54"] = "6", ["55"] = "7", ["56"] = "8", ["57"] = "9",
	["65"] = "A", ["66"] = "B", ["67"] = "C", ["68"] = "D", ["69"] = "E",
	["70"] = "F", ["71"] = "G", ["72"] = "H", ["73"] = "I", ["74"] = "J",
	["75"] = "K", ["76"] = "L", ["77"] = "M", ["78"] = "N", ["79"] = "O",
	["80"] = "P", ["81"] = "Q", ["82"] = "R", ["83"] = "S", ["84"] = "T",
	["85"] = "U", ["86"] = "V", ["87"] = "W", ["88"] = "X", ["89"] = "Y",
	["90"] = "Z", ["91"] = "LWIN", ["92"] = "RWIN", ["93"] = "APPS", ["95"] = "SLEEP",
	["96"] = "NUM0", ["97"] = "NUM1", ["98"] = "NUM2", ["99"] = "NUM3",
	["100"] = "NUM4", ["101"] = "NUM5", ["102"] = "NUM6", ["103"] = "NUM7",
	["104"] = "NUM8", ["105"] = "NUM9", ["106"] = "NUM*", ["107"] = "NUM+",
	["108"] = "NUMSEP", ["109"] = "NUM-", ["110"] = "NUM.", ["111"] = "NUM/",
	["112"] = "F1", ["113"] = "F2", ["114"] = "F3", ["115"] = "F4",
	["116"] = "F5", ["117"] = "F6", ["118"] = "F7", ["119"] = "F8",
	["120"] = "F9", ["121"] = "F10", ["122"] = "F11", ["123"] = "F12",
	["124"] = "F13", ["125"] = "F14", ["126"] = "F15", ["127"] = "F16",
	["128"] = "F17", ["129"] = "F18", ["130"] = "F19", ["131"] = "F20",
	["132"] = "F21", ["133"] = "F22", ["134"] = "F23", ["135"] = "F24",
	["144"] = "NUMLOCK", ["145"] = "SCROLL",
	["160"] = "LSHIFT", ["161"] = "RSHIFT", ["162"] = "LCTRL", ["163"] = "RCTRL",
	["164"] = "LALT", ["165"] = "RALT",
	["166"] = "BROWSER_BACK", ["167"] = "BROWSER_FORWARD", ["168"] = "BROWSER_REFRESH",
	["169"] = "BROWSER_STOP", ["170"] = "BROWSER_SEARCH", ["171"] = "BROWSER_FAVORITES",
	["172"] = "BROWSER_HOME", ["173"] = "VOLUME_MUTE", ["174"] = "VOLUME_DOWN",
	["175"] = "VOLUME_UP", ["176"] = "MEDIA_NEXT", ["177"] = "MEDIA_PREV",
	["178"] = "MEDIA_STOP", ["179"] = "MEDIA_PLAY", ["180"] = "MAIL",
	["181"] = "MEDIA_SELECT", ["182"] = "APP1", ["183"] = "APP2",
	["186"] = ";", ["187"] = "=", ["188"] = ",", ["189"] = "-",
	["190"] = ".", ["191"] = "/", ["192"] = "`", ["219"] = "[",
	["220"] = "\\", ["221"] = "]", ["222"] = "'", ["226"] = "OEM102",
	["229"] = "PROCESS", ["246"] = "ATTN", ["247"] = "CRSEL", ["248"] = "EXSEL",
	["249"] = "EREOF", ["250"] = "PLAY", ["251"] = "ZOOM", ["252"] = "NONAME",
	["253"] = "PA1", ["254"] = "CLEAR2",
}

local TextChars = {}
for i = 48, 57 do
	TextChars[i] = string.char(i)
end
for i = 65, 90 do
	TextChars[i] = string.char(i + 32)
end

TextManager.Fonts = Fonts
TextManager.FontMetrics = FontMetrics
TextManager.KeyNameMap = KeyNameMap
TextManager.TextChars = TextChars

local NativeMeasureText

local function fontNameFromValue(font)
	if type(font) == "string" and FontMetrics[font] then
		return font
	end

	return FontNamesByValue[font] or "Monospace"
end

local function vectorX(value)
	if type(value) == "number" then
		return value
	end

	if type(value) == "table" then
		return value.X or value.x or value[1]
	end

	return nil
end

local function nativeMeasure(text, size, font)
	if NativeMeasureText == false then
		return nil
	end

	if not NativeMeasureText then
		local ok, object = pcall(function()
			return Drawing.new("Text")
		end)
		if not ok or not object then
			NativeMeasureText = false
			return nil
		end

		NativeMeasureText = object
	end

	local object = NativeMeasureText
	local ok = pcall(function()
		object.Text = tostring(text or "")
		object.Size = size or 13
		object.Font = font or Drawing.Fonts.Monospace
		object.Position = Vector2.new(-10000, -10000)
		object.Visible = true
	end)
	if not ok then
		return nil
	end

	for _, property in ipairs({ "TextBounds", "TextSize", "Bounds", "SizeBounds", "AbsoluteSize" }) do
		local readOk, value = pcall(function()
			return object[property]
		end)
		local x = readOk and vectorX(value) or nil
		if x and x > 0 then
			return x
		end
	end

	return nil
end

local function charUnit(char, metrics)
	local chars = metrics and metrics.Chars
	if chars and chars[char] then
		return chars[char]
	end

	if char == " " then
		return 0.75
	elseif char:find("[ilI1%|%.%,:;!'`]", 1) then
		return 0.5
	elseif char:find("[mwMW@#%%&]", 1) then
		return 1.25
	elseif char:find("[%u]", 1) then
		return 1.05
	elseif char:find("[%d]", 1) then
		return 0.95
	elseif char:find("[%p]", 1) then
		return 0.5
	end

	return 1
end

function TextManager:Measure(text, size, font, scale)
	text = tostring(text or "")
	size = size or 13
	if scale then
		size = math.floor((size) * scale + 0.5)
	end
	font = font or Drawing.Fonts.Monospace

	local native = nativeMeasure(text, size, font)
	if native then
		return native
	end

	local metrics = FontMetrics[fontNameFromValue(font)] or FontMetrics.Monospace
	local units = 0

	for i = 1, #text do
		units = units + charUnit(text:sub(i, i), metrics)
	end

	return units * size * (metrics.Scale or 0.5)
end

function TextManager:Fit(text, maxWidth, size, font, scale)
	text = tostring(text or "")
	if not maxWidth or maxWidth <= 0 then
		return ""
	end

	size = size or 13
	if scale then
		size = math.floor(size * scale + 0.5)
	end

	if self:Measure(text, size, font) <= maxWidth then
		return text
	end

	local suffix = "..."
	local available = maxWidth - self:Measure(suffix, size, font)
	if available <= 0 then
		return suffix
	end

	local result = ""
	for i = 1, #text do
		local nextText = text:sub(1, i)
		if self:Measure(nextText, size, font) > available then
			break
		end
		result = nextText
	end

	return result .. suffix
end

function TextManager:AlignX(text, x, width, size, font, align)
	align = tostring(align or "Left"):lower()
	if align == "center" or align == "centre" then
		return x + (width - self:Measure(text, size, font)) / 2
	elseif align == "right" then
		return x + width - self:Measure(text, size, font)
	end

	return x
end

function TextManager:KeyName(key)
	if key == nil or key == false or key == "" or key == "None" then
		return "None"
	end

	local numberKey = tonumber(key)
	if numberKey then
		return KeyNameMap[tostring(numberKey)] or ("0x" .. string.format("%X", numberKey))
	end

	return tostring(key)
end

function TextManager:ReadTextKey(key, shift)
	local char = TextChars[key]
	if not char then
		return nil
	end

	if shift then
		return string.upper(char)
	end

	return char
end

function TextManager:FormatKeybind(key, label, mode)
	local parts = { "[" .. self:KeyName(key) .. "]" }
	if label and label ~= "" then
		parts[#parts + 1] = tostring(label)
	end
	if mode and mode ~= "" then
		parts[#parts + 1] = "(" .. tostring(mode) .. ")"
	end
	return table.concat(parts, " ")
end

function TextManager:Draw(drawText, text, x, y, width, options)
	options = options or {}
	local size = options.Size or options.size or 13
	local font = options.Font or options.font or Drawing.Fonts.Monospace
	local scale = options.Scale or options.scale
	local display = options.Fit == false and tostring(text or "") or self:Fit(text, width or math.huge, size, font, scale)
	local tx = self:AlignX(display, x or 0, width or 0, size, font, options.Align or options.align)

	return drawText(
		display,
		math.floor(tx + 0.5),
		y or 0,
		options.Color or options.color,
		size,
		font,
		false,
		options.Outline ~= false,
		options.ZIndex or options.z or 1
	), display, tx
end

function TextManager:RenderInput(window, value, placeholder, x, y, width, options)
	options = options or {}
	local raw = tostring(value or "")
	local empty = raw == ""
	local text = empty and tostring(placeholder or "") or raw
	local size = options.Size or 13
	local font = options.Font or Drawing.Fonts.Monospace
	local scale = window:GetScale()
	local scaledSize = math.floor(size * scale + 0.5)
	local fitted = self:Fit(text, width, scaledSize, font)
	local color = options.Disabled and options.DisabledColor or (empty and options.PlaceholderColor or options.Color)
	local tx = self:AlignX(fitted, x, width, scaledSize, font, options.Align or options.align)

	window:_text(fitted, tx, y, color, size, font, false, options.Outline ~= false, options.ZIndex or 1)

	if options.Focused and not options.Disabled and math.floor(tick() * 2) % 2 == 0 then
		local caretX = empty and tx or (tx + math.min(width, math.floor(self:Measure(fitted, scaledSize, font) + 2)))
		local caretH = math.floor(size * scale + 0.5)
		window:_line(caretX, y + 1, caretX, y + caretH + 1, color, 1, (options.ZIndex or 1) + 1)
	end

	return fitted
end

function TextManager:GetMetrics(font)
	return FontMetrics[fontNameFromValue(font)] or FontMetrics.Monospace
end

function TextManager:IsNativeMeasureAvailable()
	return nativeMeasure("Test", 13, Drawing.Fonts.Monospace) ~= nil
end

function TextManager:ClearActiveInput(window)
	if not window then return "" end
	if window.SearchFocused then
		window.SearchText = ""
	elseif window.DropdownSearch then
		window.DropdownSearch._searchText = ""
		window.DropdownSearch._dropdownScroll = 0
	elseif window.TextTarget then
		local t = window.TextTarget
		t.value = ""
		if type(t.callback) == "function" then
			local ok, err = pcall(t.callback, "")
			if not ok then error("TextManager.ClearActiveInput callback: " .. tostring(err), 2) end
		end
		if type(t.changed) == "function" then
			local ok, err = pcall(t.changed, "")
			if not ok then error("TextManager.ClearActiveInput changed: " .. tostring(err), 2) end
		end
	end
	return ""
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/TextManager.lua"] = TextManager

return TextManager
