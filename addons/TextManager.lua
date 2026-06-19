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
			A = 1.100, B = 1.060, C = 1.060, D = 1.020, E = 1.080, F = 1.160, G = 1.080,
			H = 0.980, I = 1.100, J = 1.060, K = 1.120, L = 1.080, M = 1.080, N = 1.060,
			O = 1.060, P = 1.080, Q = 1.100, R = 1.080, S = 1.120, T = 1.060, U = 1.120,
			V = 1.160, W = 1.040, X = 1.060, Y = 0.980, Z = 1.020,
			a = 1.000, b = 1.000, c = 1.000, d = 1.100, e = 1.000, f = 1.180, g = 1.060,
			h = 1.000, i = 1.160, j = 1.000, k = 1.100, l = 1.060, m = 1.080, n = 1.080,
			o = 1.080, p = 1.000, q = 1.060, r = 1.060, s = 1.120, t = 1.080, u = 1.060,
			v = 1.080, w = 1.120, x = 1.020, y = 1.020, z = 1.000,
			["0"] = 1.080, ["1"] = 1.080, ["2"] = 1.080, ["3"] = 1.080, ["4"] = 1.080,
			["5"] = 1.080, ["6"] = 1.080, ["7"] = 1.080, ["8"] = 1.080, ["9"] = 1.020,
			[" "] = 1.070, ["."] = 1.120, ["_"] = 1.120, ["-"] = 0.940, [":"] = 1.060, ["/"] = 1.340,
		},
	},
	System = {
		Scale = 0.530,
		Chars = {
			A = 1.220, B = 1.000, C = 1.180, D = 1.160, E = 0.880, F = 0.860, G = 1.140,
			H = 1.120, I = 0.500, J = 0.920, K = 1.000, L = 0.880, M = 1.490, N = 1.120,
			O = 1.180, P = 0.960, Q = 1.140, R = 1.040, S = 1.080, T = 1.020, U = 1.120,
			V = 1.100, W = 1.590, X = 1.160, Y = 1.100, Z = 0.980,
			a = 0.800, b = 1.000, c = 0.840, d = 1.000, e = 0.900, f = 0.540, g = 1.060,
			h = 0.980, i = 0.440, j = 0.480, k = 0.840, l = 0.440, m = 1.450, n = 1.100,
			o = 0.840, p = 1.020, q = 1.000, r = 0.580, s = 0.840, t = 0.580, u = 1.060,
			v = 0.880, w = 1.350, x = 0.860, y = 0.880, z = 0.940,
			["0"] = 1.000, ["1"] = 0.700, ["2"] = 0.980, ["3"] = 1.020, ["4"] = 0.980,
			["5"] = 1.000, ["6"] = 1.000, ["7"] = 0.920, ["8"] = 0.960, ["9"] = 0.960,
			[" "] = 0.320, ["."] = 0.460, ["_"] = 0.740, ["-"] = 0.740, [":"] = 0.380, ["/"] = 0.740,
		},
	},
	SystemBold = {
		Scale = 0.540,
		Chars = {
			A = 1.180, B = 0.980, C = 1.100, D = 1.100, E = 0.860, F = 0.840, G = 1.180,
			H = 1.100, I = 0.380, J = 0.860, K = 1.020, L = 0.880, M = 1.330, N = 1.100,
			O = 1.160, P = 1.000, Q = 1.220, R = 1.000, S = 1.020, T = 0.940, U = 1.120,
			V = 1.100, W = 1.410, X = 1.100, Y = 1.000, Z = 0.940,
			a = 0.880, b = 1.000, c = 0.860, d = 0.960, e = 0.840, f = 0.580, g = 1.000,
			h = 1.000, i = 0.340, j = 0.400, k = 0.900, l = 0.360, m = 1.390, n = 1.040,
			o = 0.920, p = 0.980, q = 1.000, r = 0.540, s = 0.880, t = 0.600, u = 0.980,
			v = 0.860, w = 1.270, x = 0.880, y = 0.860, z = 0.820,
			["0"] = 0.980, ["1"] = 0.680, ["2"] = 0.960, ["3"] = 0.960, ["4"] = 0.960,
			["5"] = 0.960, ["6"] = 0.960, ["7"] = 0.960, ["8"] = 0.960, ["9"] = 0.960,
			[" "] = 0.460, ["."] = 0.480, ["_"] = 0.620, ["-"] = 0.620, [":"] = 0.400, ["/"] = 0.780,
		},
	},
	Minecraft = {
		Scale = 0.570,
		Chars = {
			A = 1.120, B = 1.220, C = 1.380, D = 1.180, E = 1.220, F = 1.060, G = 1.320,
			H = 1.260, I = 0.680, J = 0.940, K = 1.080, L = 1.060, M = 1.200, N = 1.220,
			O = 1.480, P = 1.220, Q = 1.480, R = 1.440, S = 1.080, T = 1.220, U = 1.220,
			V = 1.220, W = 1.200, X = 1.160, Y = 1.220, Z = 1.260,
			a = 1.100, b = 1.180, c = 1.000, d = 0.960, e = 0.920, f = 0.960, g = 1.000,
			h = 0.920, i = 0.300, j = 0.940, k = 0.920, l = 0.260, m = 1.580, n = 1.060,
			o = 0.960, p = 1.000, q = 1.000, r = 0.920, s = 0.920, t = 0.700, u = 0.980,
			v = 1.240, w = 1.400, x = 1.200, y = 1.000, z = 0.940,
			["0"] = 0.950, ["1"] = 0.820, ["2"] = 0.990, ["3"] = 0.950, ["4"] = 1.070,
			["5"] = 1.190, ["6"] = 1.010, ["7"] = 0.950, ["8"] = 0.950, ["9"] = 0.950,
			[" "] = 0.520, ["."] = 0.300, ["_"] = 1.120, ["-"] = 0.700, [":"] = 0.420, ["/"] = 1.060,
		},
	},
	Monospace = {
		Scale = 0.480,
		Chars = {
			A = 1.000, B = 1.000, C = 0.920, D = 0.980, E = 1.000, F = 0.920, G = 0.960,
			H = 0.940, I = 0.960, J = 0.960, K = 0.980, L = 1.000, M = 1.000, N = 0.940,
			O = 0.920, P = 0.920, Q = 0.980, R = 0.960, S = 0.980, T = 0.980, U = 0.900,
			V = 1.040, W = 0.880, X = 0.940, Y = 0.980, Z = 0.960,
			a = 0.980, b = 0.980, c = 1.040, d = 0.980, e = 0.880, f = 1.000, g = 0.940,
			h = 1.000, i = 1.020, j = 1.080, k = 0.900, l = 0.900, m = 0.900, n = 0.920,
			o = 1.020, p = 0.980, q = 1.000, r = 0.900, s = 0.840, t = 1.000, u = 1.000,
			v = 1.000, w = 1.000, x = 0.800, y = 1.000, z = 1.000,
			["0"] = 1.000, ["1"] = 0.960, ["2"] = 1.040, ["3"] = 0.960, ["4"] = 0.980,
			["5"] = 0.980, ["6"] = 0.900, ["7"] = 0.960, ["8"] = 0.920, ["9"] = 1.000,
			[" "] = 0.980, ["."] = 0.880, ["_"] = 1.040, ["-"] = 1.000, [":"] = 1.000, ["/"] = 1.000,
		},
	},
	Pixel = {
		Scale = 0.520,
		Chars = {
			A = 1.120, B = 1.000, C = 1.060, D = 1.000, E = 1.020, F = 1.100, G = 1.020,
			H = 1.040, I = 0.780, J = 1.000, K = 1.000, L = 1.020, M = 1.120, N = 1.020,
			O = 1.040, P = 1.060, Q = 1.000, R = 1.000, S = 1.100, T = 0.740, U = 1.000,
			V = 0.800, W = 1.180, X = 1.100, Y = 0.740, Z = 0.980,
			a = 1.020, b = 1.080, c = 1.000, d = 1.000, e = 1.040, f = 0.940, g = 1.020,
			h = 1.020, i = 0.760, j = 1.000, k = 1.020, l = 1.040, m = 1.160, n = 1.040,
			o = 1.060, p = 1.040, q = 1.020, r = 1.020, s = 1.080, t = 0.760, u = 1.020,
			v = 0.700, w = 1.160, x = 1.060, y = 0.760, z = 1.020,
			["0"] = 1.040, ["1"] = 0.800, ["2"] = 1.020, ["3"] = 1.040, ["4"] = 1.000,
			["5"] = 1.060, ["6"] = 1.000, ["7"] = 1.000, ["8"] = 1.000, ["9"] = 1.000,
			[" "] = 1.080, ["."] = 0.420, ["_"] = 1.020, ["-"] = 0.800, [":"] = 0.460, ["/"] = 1.160,
		},
	},
	Fortnite = {
		Scale = 0.540,
		Chars = {
			A = 0.910, B = 0.810, C = 0.870, D = 0.850, E = 0.690, F = 0.670, G = 0.930,
			H = 0.870, I = 0.380, J = 0.790, K = 0.870, L = 0.630, M = 1.050, N = 0.810,
			O = 0.810, P = 0.850, Q = 0.870, R = 0.850, S = 0.830, T = 0.690, U = 0.850,
			V = 0.890, W = 1.150, X = 0.850, Y = 0.710, Z = 0.770,
			a = 0.800, b = 0.900, c = 0.800, d = 0.800, e = 0.800, f = 0.680, g = 0.920,
			h = 0.860, i = 0.380, j = 0.540, k = 0.860, l = 0.420, m = 1.230, n = 0.880,
			o = 0.860, p = 0.860, q = 0.860, r = 0.800, s = 0.780, t = 0.620, u = 0.860,
			v = 0.740, w = 1.050, x = 0.800, y = 0.740, z = 0.760,
			["0"] = 0.850, ["1"] = 0.560, ["2"] = 0.850, ["3"] = 0.850, ["4"] = 0.850,
			["5"] = 0.830, ["6"] = 0.810, ["7"] = 0.850, ["8"] = 0.850, ["9"] = 0.850,
			[" "] = 0.460, ["."] = 0.420, ["_"] = 0.500, ["-"] = 0.520, [":"] = 0.440, ["/"] = 0.940,
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

function TextManager:Measure(text, size, font)
	text = tostring(text or "")
	size = size or 13
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

function TextManager:Fit(text, maxWidth, size, font)
	text = tostring(text or "")
	if not maxWidth or maxWidth <= 0 then
		return ""
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

function TextManager:ReadKeyName(key)
	return self:KeyName(key)
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
	local display = options.Fit == false and tostring(text or "") or self:Fit(text, width or math.huge, size, font)
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
	local fitted = self:Fit(text, width, size, font)
	local color = options.Disabled and options.DisabledColor or (empty and options.PlaceholderColor or options.Color)

	window:_text(fitted, x, y, color, size, font, false, options.Outline ~= false, options.ZIndex or 1)

	if options.Focused and not options.Disabled and math.floor(tick() * 2) % 2 == 0 then
		local caretX = x + math.min(width, math.floor(self:Measure(fitted, size, font) + 2))
		window:_line(caretX, y + 1, caretX, y + size + 1, color, 1, (options.ZIndex or 1) + 1)
	end

	return fitted
end

function TextManager:GetMetrics(font)
	return FontMetrics[fontNameFromValue(font)] or FontMetrics.Monospace
end

function TextManager:IsNativeMeasureAvailable()
	return nativeMeasure("Test", 13, Drawing.Fonts.Monospace) ~= nil
end

_G.ObsidianMatchaAddons = _G.ObsidianMatchaAddons or {}
_G.ObsidianMatchaAddons["addons/TextManager.lua"] = TextManager

return TextManager
