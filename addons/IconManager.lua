
local IconManager = {}

IconManager.Version = "0.1.0"
IconManager.DefaultStrokeWidth = 2

local aliases = {
	["chevron"] = "chevron-down",
	["chevrondown"] = "chevron-down",
	["chevron_down"] = "chevron-down",
	["chevron-up"] = "chevron-up",
	["chevronup"] = "chevron-up",
	["chevron-left"] = "chevron-left",
	["chevronleft"] = "chevron-left",
	["chevron-right"] = "chevron-right",
	["chevronright"] = "chevron-right",
	["move"] = "move",
	["drag"] = "move",
	["resize"] = "move-diagonal-2",
	["movediagonal2"] = "move-diagonal-2",
	["move-diagonal"] = "move-diagonal-2",
	["settings"] = "settings",
	["search"] = "search",
	["user"] = "user",
	["key"] = "key",
	["check"] = "check",
	["x"] = "x",
	["close"] = "x",
	["plus"] = "plus",
	["minus"] = "minus",
}

local function normalizeName(name)
	name = tostring(name or ""):lower()
	return aliases[name] or name
end

local function makeScale(x, y, size)
	local scale = (size or 24) / 24
	local left = x - (size or 24) / 2
	local top = y - (size or 24) / 2

	return function(px, py)
		return left + px * scale, top + py * scale
	end, scale
end

local function drawLine(window, point, a, b, color, thickness, z)
	local x1, y1 = point(a[1], a[2])
	local x2, y2 = point(b[1], b[2])
	return window:_line(x1, y1, x2, y2, color, thickness, z)
end

local function drawPolyline(window, point, points, color, thickness, z)
	local drawn = false

	for index = 1, #points - 1 do
		if drawLine(window, point, points[index], points[index + 1], color, thickness, z) then
			drawn = true
		end
	end

	for index = 2, #points - 1 do
		local x, y = point(points[index][1], points[index][2])
		if window:_circle(x, y, math.max(1, thickness / 2), color, true, 1, z) then
			drawn = true
		end
	end

	return drawn
end

local function drawCircle(window, point, cx, cy, radius, color, thickness, z)
	local x, y = point(cx, cy)
	return window:_circle(x, y, radius, color, false, thickness, z)
end

local function drawRect(window, point, x, y, w, h, color, thickness, z)
	local x1, y1 = point(x, y)
	local x2, y2 = point(x + w, y + h)
	local drawn = false

	if window:_square(x1, y1, x2 - x1, y2 - y1, color, false, 1, 0, z) then
		drawn = true
	end

	return drawn
end

local icons = {}

icons["check"] = function(window, point, color, thickness, z)
	return drawPolyline(window, point, {
		{ 20, 6 },
		{ 9, 17 },
		{ 4, 12 },
	}, color, thickness, z)
end

icons["chevron-down"] = function(window, point, color, thickness, z)
	return drawPolyline(window, point, {
		{ 6, 9 },
		{ 12, 15 },
		{ 18, 9 },
	}, color, thickness, z)
end

icons["chevron-up"] = function(window, point, color, thickness, z)
	return drawPolyline(window, point, {
		{ 18, 15 },
		{ 12, 9 },
		{ 6, 15 },
	}, color, thickness, z)
end

icons["chevron-left"] = function(window, point, color, thickness, z)
	return drawPolyline(window, point, {
		{ 15, 18 },
		{ 9, 12 },
		{ 15, 6 },
	}, color, thickness, z)
end

icons["chevron-right"] = function(window, point, color, thickness, z)
	return drawPolyline(window, point, {
		{ 9, 18 },
		{ 15, 12 },
		{ 9, 6 },
	}, color, thickness, z)
end

icons["x"] = function(window, point, color, thickness, z)
	local first = drawLine(window, point, { 18, 6 }, { 6, 18 }, color, thickness, z)
	local second = drawLine(window, point, { 6, 6 }, { 18, 18 }, color, thickness, z)
	return first or second
end

icons["plus"] = function(window, point, color, thickness, z)
	local first = drawLine(window, point, { 12, 5 }, { 12, 19 }, color, thickness, z)
	local second = drawLine(window, point, { 5, 12 }, { 19, 12 }, color, thickness, z)
	return first or second
end

icons["minus"] = function(window, point, color, thickness, z)
	return drawLine(window, point, { 5, 12 }, { 19, 12 }, color, thickness, z)
end

icons["search"] = function(window, point, color, thickness, z, scale)
	local circle = drawCircle(window, point, 11, 11, 8 * scale, color, thickness, z)
	local handle = drawLine(window, point, { 21, 21 }, { 16.66, 16.66 }, color, thickness, z)
	return circle or handle
end

icons["user"] = function(window, point, color, thickness, z, scale)
	local head = drawCircle(window, point, 12, 7, 4 * scale, color, thickness, z)
	local body = drawPolyline(window, point, {
		{ 5, 21 },
		{ 5, 19 },
		{ 5.5, 17.6 },
		{ 6.7, 16.3 },
		{ 9, 15 },
		{ 15, 15 },
		{ 17.3, 16.3 },
		{ 18.5, 17.6 },
		{ 19, 19 },
		{ 19, 21 },
	}, color, thickness, z)
	return head or body
end

icons["grip"] = function(window, point, color, thickness, z)
	local drawn = false
	local points = {
		{ 9, 5 }, { 15, 5 },
		{ 9, 12 }, { 15, 12 },
		{ 9, 19 }, { 15, 19 },
	}

	for _, dot in ipairs(points) do
		local x, y = point(dot[1], dot[2])
		if window:_circle(x, y, math.max(1, thickness), color, true, 1, z) then
			drawn = true
		end
	end

	return drawn
end

icons["move"] = function(window, point, color, thickness, z)
	local drawn = false
	local segments = {
		{ { 12, 2 }, { 12, 22 } },
		{ { 15, 19 }, { 12, 22 } },
		{ { 12, 22 }, { 9, 19 } },
		{ { 19, 9 }, { 22, 12 } },
		{ { 22, 12 }, { 19, 15 } },
		{ { 2, 12 }, { 22, 12 } },
		{ { 5, 9 }, { 2, 12 } },
		{ { 2, 12 }, { 5, 15 } },
		{ { 9, 5 }, { 12, 2 } },
		{ { 12, 2 }, { 15, 5 } },
	}

	for _, segment in ipairs(segments) do
		if drawLine(window, point, segment[1], segment[2], color, thickness, z) then
			drawn = true
		end
	end

	local joints = {
		{ 12, 2 },
		{ 22, 12 },
		{ 12, 22 },
		{ 2, 12 },
		{ 12, 12 },
	}

	for _, joint in ipairs(joints) do
		local x, y = point(joint[1], joint[2])
		if window:_circle(x, y, math.max(1, thickness / 2), color, true, 1, z) then
			drawn = true
		end
	end

	return drawn
end

icons["move-diagonal-2"] = function(window, point, color, thickness, z)
	local drawn = false
	local segments = {
		{ { 19, 13 }, { 19, 19 } },
		{ { 19, 19 }, { 13, 19 } },
		{ { 5, 11 }, { 5, 5 } },
		{ { 5, 5 }, { 11, 5 } },
		{ { 5, 5 }, { 19, 19 } },
	}

	for _, segment in ipairs(segments) do
		if drawLine(window, point, segment[1], segment[2], color, thickness, z) then
			drawn = true
		end
	end

	local joints = {
		{ 5, 5 },
		{ 19, 19 },
	}

	for _, joint in ipairs(joints) do
		local x, y = point(joint[1], joint[2])
		if window:_circle(x, y, math.max(1, thickness / 2), color, true, 1, z) then
			drawn = true
		end
	end

	return drawn
end

icons["key"] = function(window, point, color, thickness, z, scale)
	local head = drawCircle(window, point, 7.5, 15.5, 5.5 * scale, color, thickness, z)
	local shaft = drawLine(window, point, { 21, 2 }, { 11.4, 11.6 }, color, thickness, z)
	local top = drawPolyline(window, point, {
		{ 15.5, 7.5 },
		{ 17.8, 9.8 },
		{ 19.2, 9.8 },
		{ 21.3, 7.7 },
		{ 21.3, 6.3 },
		{ 19, 4 },
	}, color, thickness, z)
	return head or shaft or top
end

icons["settings"] = function(window, point, color, thickness, z, scale)
	local center = drawCircle(window, point, 12, 12, 3 * scale, color, thickness, z)
	local gear = drawPolyline(window, point, {
		{ 9.67, 4.14 },
		{ 10.18, 2.82 },
		{ 11.06, 2.16 },
		{ 12.00, 2.00 },
		{ 12.94, 2.16 },
		{ 13.82, 2.82 },
		{ 14.33, 4.14 },
		{ 14.92, 5.58 },
		{ 16.20, 6.15 },
		{ 17.65, 6.05 },
		{ 18.95, 5.72 },
		{ 20.01, 6.26 },
		{ 20.67, 7.30 },
		{ 20.75, 8.48 },
		{ 19.98, 10.08 },
		{ 19.15, 11.10 },
		{ 19.15, 12.90 },
		{ 19.98, 13.92 },
		{ 20.75, 15.52 },
		{ 20.67, 16.70 },
		{ 20.01, 17.74 },
		{ 18.95, 18.28 },
		{ 17.65, 17.95 },
		{ 16.20, 17.85 },
		{ 14.92, 18.42 },
		{ 14.33, 19.86 },
		{ 13.82, 21.18 },
		{ 12.94, 21.84 },
		{ 12.00, 22.00 },
		{ 11.06, 21.84 },
		{ 10.18, 21.18 },
		{ 9.67, 19.86 },
		{ 9.08, 18.42 },
		{ 7.80, 17.85 },
		{ 6.35, 17.95 },
		{ 5.05, 18.28 },
		{ 3.99, 17.74 },
		{ 3.33, 16.70 },
		{ 3.25, 15.52 },
		{ 4.02, 13.92 },
		{ 4.85, 12.90 },
		{ 4.85, 11.10 },
		{ 4.02, 10.08 },
		{ 3.25, 8.48 },
		{ 3.33, 7.30 },
		{ 3.99, 6.26 },
		{ 5.05, 5.72 },
		{ 6.35, 6.05 },
		{ 7.80, 6.15 },
		{ 9.08, 5.58 },
		{ 9.67, 4.14 },
	}, color, thickness, z)
	return center or gear
end

icons["square"] = function(window, point, color, thickness, z)
	return drawRect(window, point, 5, 5, 14, 14, color, thickness, z)
end

function IconManager:Has(name)
	return icons[normalizeName(name)] ~= nil
end

function IconManager:Draw(window, name, x, y, size, color, z, options)
	if not window then
		return false
	end

	local icon = icons[normalizeName(name)]
	if not icon then
		return false
	end

	options = options or {}
	local point, scale = makeScale(x or 0, y or 0, size or 24)
	local thickness = options.Thickness or options.StrokeWidth or math.max(1, math.floor((size or 24) / 24 * self.DefaultStrokeWidth + 0.5))

	return icon(window, point, color, thickness, z, scale) == true
end

function IconManager:Register(name, draw)
	if type(name) ~= "string" or type(draw) ~= "function" then
		return false
	end

	icons[normalizeName(name)] = draw
	return true
end

function IconManager:List()
	local list = {}

	for name in pairs(icons) do
		list[#list + 1] = name
	end

	table.sort(list)
	return list
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/IconManager.lua"] = IconManager

return IconManager
