--[[    Galax Obsidian Lib - UI Library for Matcha External    Based on Obsidian's visual style and migrated to Matcha's limited Drawing API.    Rendering prioritizes the lightweight base UI first and popups/lists last.    USAGE:    local Library = loadstring(game:HttpGet(".../Galax-Obsidian-Lib.lua"))()    local Win = Library:CreateWindow({        Title = "Galax Hub",        Subtitle = "Matcha External",        Icon = 95816097006870,        Size = Vector2.new(620, 430),        MenuKey = 0x70    })    local Tab = Win:AddTab("Combat")    local Sec = Tab:AddSection("Aimbot")    Sec:AddToggle("Enabled", false, function(v) end, 0x46)    Sec:AddSlider("FOV", { Min = 1, Max = 360, Default = 90, Suffix = " deg" }, function(v) end)    Sec:AddDropdown("Mode", { "Closest", "FOV", "Distance" }, "Closest", { MaxVisible = 5 }, function(v) end)    Win:Notify("Loaded", "Galax", 3)]]
local GalaxObsidian = {}

-- ======================================================================
-- LIBRARY METADATA & POLYFILLS
-- ======================================================================
-- ---- Version ----
GalaxObsidian.Version = "1.0.0"

-- ---- Color3.fromRGB Polyfill ----
if not Color3.fromRGB then
    Color3.fromRGB = function(r, g, b)
        return Color3.new(r / 255, g / 255, b / 255)
    end
end

-- ---- Color3.fromHSV Polyfill ----
if not Color3.fromHSV then
    Color3.fromHSV = function(h, s, v)
        local r, g, b
        if s == 0 then
            r, g, b = v, v, v
        else
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - s * f)
            local t = v * (1 - s * (1 - f))
            if i % 6 == 0 then
                r, g, b = v, t, p
            elseif i % 6 == 1 then
                r, g, b = q, v, p
            elseif i % 6 == 2 then
                r, g, b = p, v, t
            elseif i % 6 == 3 then
                r, g, b = p, q, v
            elseif i % 6 == 4 then
                r, g, b = t, p, v
            else
                r, g, b = v, p, q
            end
        end
        return Color3.new(r, g, b)
    end
end

-- ======================================================================
-- LIBRARY STATE & DEFAULTS
-- ======================================================================
-- ---- Image Cache ----
GalaxObsidian.ImageCache = GalaxObsidian.ImageCache or {}

-- ---- Asset URLs ----
GalaxObsidian.TransparencyTextureUrl =
    "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/assets/TransparencyTexture.png"
GalaxObsidian.IconUrls = {
    move = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/main/Library/Obsidian/assets/icons/move.png",
    search = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/main/Library/Obsidian/assets/icons/search.png",
    settings = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/main/Library/Obsidian/assets/icons/settings.png",
    user = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/main/Library/Obsidian/assets/icons/user.png",
    key = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/main/Library/Obsidian/assets/icons/key.png",
}

-- ---- Behavior Flags ----
GalaxObsidian.ForceCheckbox = false
GalaxObsidian.ShowToggleFrameInKeybinds = true
GalaxObsidian.Options = {}

-- ---- Toggles Registry ----
GalaxObsidian.Toggles = {}

-- ---- Unload System ----
GalaxObsidian.Unloaded = false
GalaxObsidian.UnloadCallbacks = {}

-- ---- Window / UI Defaults ----
GalaxObsidian.NotifySide = "Right"
GalaxObsidian.KeybindFrame = nil
GalaxObsidian.ToggleKeybind = nil
GalaxObsidian.CornerRadius = 0
GalaxObsidian.DPIScale = 100

-- ---- Internal Module State ----
local DraggableLabels = {}
local ConnectionHandles = {}
local WindowMetatable = {}
WindowMetatable.__index = WindowMetatable
local Theme



local AddonRepo = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/"


local function loadCoreAddon(path)
    local source = game:HttpGet(AddonRepo .. path)
    local chunk, err = loadstring(source)
    if not chunk then error(path .. ": " .. tostring(err), 2) end
    chunk()
    local module = _G.Galax and _G.Galax[path]
    if type(module) ~= "table" then error(path .. " did not load", 2) end
    return module
end

local TextManager = loadCoreAddon("addons/TextManager.lua")

local IconManager = loadCoreAddon("addons/IconManager.lua")

local AnimationManager = loadCoreAddon("addons/AnimationManager.lua")


GalaxObsidian.TextManager = TextManager
GalaxObsidian.IconManager = IconManager
GalaxObsidian.AnimationManager = AnimationManager
-- ======================================================================
-- MATH & COLOR HELPERS
-- ======================================================================
-- ---- Numeric Helpers ----
local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end
local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return nil
    end
    local ok, result = pcall(callback, ...)
    if ok then
        return result
    end
    return nil
end

-- ---- Color Conversion ----
local function rgbToHsv(color)
    local str = tostring(color)
    local r, g, b = str:match("([%d%.]+)%D+([%d%.]+)%D+([%d%.]+)")
    if not r then
        r, g, b = 0, 0, 0
    end
    r, g, b = tonumber(r), tonumber(g), tonumber(b)
    local maxValue = math.max(r, g, b)
    local minValue = math.min(r, g, b)
    local delta = maxValue - minValue
    local hue = 0
    if delta > 0 then
        if maxValue == r then
            hue = ((g - b) / delta) % 6
        elseif maxValue == g then
            hue = ((b - r) / delta) + 2
        else
            hue = ((r - g) / delta) + 4
        end
        hue = hue / 6
    end
    local saturation = 0
    if maxValue > 0 then
        saturation = delta / maxValue
    end
    return hue, saturation, maxValue
end
local function hsvToRgb(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local r, g, b
    local ri = i % 6
    if ri == 0 then
        r, g, b = v, t, p
    elseif ri == 1 then
        r, g, b = q, v, p
    elseif ri == 2 then
        r, g, b = p, v, t
    elseif ri == 3 then
        r, g, b = p, q, v
    elseif ri == 4 then
        r, g, b = t, p, v
    else
        r, g, b = v, p, q
    end
    return r, g, b
end

-- ======================================================================
-- WIDGET HANDLE FACTORY
-- ======================================================================
local function makeHandle(widget)
    local handle = {}
    handle.Widget = widget
    handle.__index = handle

    -- ---- Value Access ----
    function handle:Get()
        if widget.type == "toggle" or widget.type == "checkbox" then
            return widget.value == true
        elseif widget.type == "slider" then
            return widget.value
        elseif widget.type == "dropdown" then
            return widget.value
        elseif widget.type == "multidropdown" then
            local result = {}

            for _, v in ipairs(widget.options) do
                if widget.selected[v] then
                    result[#result + 1] = v
                end
            end
            return result
        elseif widget.type == "colorpicker" then
            return widget.value, widget.transparency
        elseif widget.type == "keybind" then
            return widget.value
        elseif widget.type == "textbox" or widget.type == "keybox" then
            return widget.value
        elseif widget.type == "label" then
            return widget.text
        end
        return widget.value
    end
    function handle:GetState()
        if widget.type == "keybind" then
            return widget._state == true
        end
        return widget.value == true
    end

    -- ---- Value Mutation ----
    function handle:Set(value)
        if widget.type == "toggle" or widget.type == "checkbox" then
            widget.value = value == true
            safeCall(widget.callback, widget.value)
            safeCall(widget.changed, widget.value)
        elseif widget.type == "slider" then
            local v = clamp(value, widget.min, widget.max)
            widget.value = v
            safeCall(widget.callback, widget.value)
            safeCall(widget.changed, widget.value)
        elseif widget.type == "dropdown" then
            widget.value = value
            safeCall(widget.callback, widget.value)
            safeCall(widget.changed, widget.value)
        elseif widget.type == "multidropdown" then
            widget.selected = {}

            if value then
                for _, v in ipairs(value) do
                    widget.selected[v] = true
                end
            end
            safeCall(widget.callback, widget.selected)
            safeCall(widget.changed, widget.selected)
        elseif widget.type == "textbox" or widget.type == "keybox" then
            widget.value = tostring(value or "")
            safeCall(widget.callback, widget.value)
            safeCall(widget.changed, widget.value)
        elseif widget.type == "keybind" then
            if type(value) == "table" then
                widget.value = value[1] or value.Key or value.key or widget.value
                widget.mode = value[2] or value.Mode or value.mode or widget.mode
                widget.modifiers = value.Modifiers or value.modifiers
            else
                widget.value = value
            end
            safeCall(widget.changed, widget.value, widget.modifiers)
        end
    end
    function handle:SetValue(value)
        return handle:Set(value)
    end
    function handle:SetValueRGB(color, transparency)
        if widget.type == "colorpicker" then
            widget.value = color
            widget.transparency = widget.transparencyEnabled and (transparency or 0) or 0
            widget.hue, widget.sat, widget.vib = rgbToHsv(color)
            safeCall(widget.callback, widget.value, widget.transparency)
            safeCall(widget.changed, widget.value, widget.transparency)
        end
    end

    -- ---- Callbacks & Display ----
    function handle:OnChanged(cb)
        widget.changed = cb
    end
    function handle:OnClick(cb)
        if widget.type == "keybind" then
            if widget.callback then
                local old = widget.callback
                widget.callback = function(v)
                    old(v)
                    cb(v)
                end
            else
                widget.callback = cb
            end
        else
            widget.callback = cb
        end
    end
    function handle:SetText(text)
        widget.label = tostring(text or "")
        widget.text = tostring(text or "")
    end
    function handle:SetVisible(visible)
        widget.visible = visible == true
    end
    function handle:SetDisabled(disabled)
        widget.disabled = disabled == true
    end
    function handle:SetTooltip(tooltip)
        widget.tooltip = tooltip and tostring(tooltip) or nil
    end
    function handle:SetKey(key)
        widget.keybind = key
    end

    -- ---- Slider Bounds & Formatting ----
    function handle:SetMin(value)
        if widget.type == "slider" then
            widget.min = value
        end
    end
    function handle:SetMax(value)
        if widget.type == "slider" then
            widget.max = value
        end
    end
    function handle:SetPrefix(value)
        if widget.type == "slider" then
            widget.prefix = tostring(value or "")
        end
    end
    function handle:SetSuffix(value)
        if widget.type == "slider" then
            widget.suffix = tostring(value or "")
        end
    end

    -- ---- Dropdown Options ----
    function handle:Refresh(newOptions, newDefault)
        if widget.type == "dropdown" or widget.type == "multidropdown" then
            widget.options = newOptions or {}

            if newDefault ~= nil then
                widget.value = newDefault
            end
        end
    end
    function handle:SetValues(values)
        if widget.type == "dropdown" or widget.type == "multidropdown" then
            widget.options = values or {}
        end
    end
    function handle:AddValues(values)
        if widget.type == "dropdown" or widget.type == "multidropdown" then
            for _, v in ipairs(values or {}) do
                widget.options[#widget.options + 1] = v
            end
        end
    end
    function handle:GetActiveValues()
        if widget.type == "multidropdown" then
            local result = {}

            for _, v in ipairs(widget.options) do
                if widget.selected[v] then
                    result[#result + 1] = v
                end
            end
            return result
        end
        if widget.value == nil or widget.value == "" then
            return {}
        end
        return { widget.value }
    end

    -- ---- Metatable Sugar (.Value / .Transparency) ----
    setmetatable(handle, {
        __index = function(t, k)
            if k == "Value" then
                return t:Get()
            end
            if k == "Transparency" and widget.type == "colorpicker" then
                return widget.transparency
            end
            if k == "Modifiers" then
                return widget.modifiers
            end
            if k == "Mode" then
                return widget.mode
            end
            return rawget(t, k)
        end,
        __newindex = function(t, k, v)
            if k == "Value" then
                return t:Set(v)
            end
            if k == "Mode" then
                widget.mode = v
                return
            end
            rawset(t, k, v)
        end,
    })
    return handle
end

-- ======================================================================
-- LIBRARY LIFECYCLE API
-- ======================================================================
-- ---- Unload Hooks ----
function GalaxObsidian:OnUnload(callback)
    self.UnloadCallbacks[#self.UnloadCallbacks + 1] = callback
end
function GalaxObsidian:Unload()
    self.Unloaded = true
    for _, cb in ipairs(self.UnloadCallbacks) do
        pcall(cb)
    end
    for _, d in ipairs(DraggableLabels) do
        if d.Remove then
            pcall(function()
                d:Remove()
            end)
        end
    end
    DraggableLabels = {}

    if self.ActiveWindow then
        self.ActiveWindow:Destroy()
    end
end
local function getMousePos()
    local players = game:GetService("Players")
    if players and players.LocalPlayer then
        local m = players.LocalPlayer:GetMouse()
        if m then
            return m.X, m.Y
        end
    end
    return 0, 0
end

local function estimateTextWidth(text, size, font)
    local scale = GalaxObsidian.ActiveWindow and GalaxObsidian.ActiveWindow:GetScale() or 1.0
    local textSize = math.floor((size or GalaxObsidian.FontSize or 13) * scale + 0.5)
    return TextManager:Measure(text, textSize, font or Theme.Font)
end
local function fitTextToWidth(text, maxWidth, size, font)
    local scale = GalaxObsidian.ActiveWindow and GalaxObsidian.ActiveWindow:GetScale() or 1.0
    local textSize = math.floor((size or GalaxObsidian.FontSize or 13) * scale + 0.5)
    return TextManager:Fit(text, maxWidth, textSize, font or Theme.Font)
end

-- ---- Display Settings ----
function GalaxObsidian:SetNotifySide(side)
    self.NotifySide = tostring(side) == "Left" and "Left" or "Right"
    if self.ActiveWindow then
        self.ActiveWindow.NotifySide = self.NotifySide
    end
end
function GalaxObsidian:SetDPIScale(percent)
    percent = tonumber(percent) or 100
    percent = math.floor(clamp(percent, 50, 200) + 0.5)
    self.DPIScale = percent
    if self.ActiveWindow and self.ActiveWindow.SetDPIScale then
        self.ActiveWindow:SetDPIScale(percent)
    end
end

-- ======================================================================
-- DEFAULT THEME
-- ======================================================================
Theme = {
    Background = Color3.fromRGB(17, 17, 17),
    Topbar = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Bottombar = Color3.fromRGB(23, 23, 23),
    BottombarBorder = Color3.fromRGB(50, 50, 50),
    FooterText = Color3.fromRGB(185, 185, 185),
    Main = Color3.fromRGB(25, 25, 25),
    Surface = Color3.fromRGB(25, 25, 25),
    Surface2 = Color3.fromRGB(33, 33, 33),
    Outline = Color3.fromRGB(40, 40, 40),
    Outline2 = Color3.fromRGB(50, 50, 50),
    SoftOutline = Color3.fromRGB(40, 40, 40),
    DimText = Color3.fromRGB(76, 76, 76),
    PopupHover = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(125, 85, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Muted = Color3.fromRGB(130, 130, 130),
    Dark = Color3.fromRGB(0, 0, 0),
    Red = Color3.fromRGB(255, 50, 50),
    Font = Drawing.Fonts.Monospace,
}

-- ======================================================================
-- DRAGGABLE LABEL FEATURE
-- ======================================================================
function GalaxObsidian:AddDraggableLabel(text)
    local outline = Drawing.new("Square")
    outline.Filled = true
    outline.Color = Theme.Outline2
    outline.Corner = 4
    outline.Transparency = 1
    outline.ZIndex = 198
    local bg = Drawing.new("Square")
    bg.Size = Vector2.new(10, 10)
    bg.Color = Theme.Background
    bg.Filled = true
    bg.Corner = 4
    bg.Transparency = 1
    bg.ZIndex = 199
    local label = Drawing.new("Text")
    label.Text = tostring(text)
    label.Color = Theme.Muted
    label.Size = 15
    label.Font = Theme.Font
    label.Center = true
    label.Outline = false
    label.Transparency = 1
    label.ZIndex = 200
    label.Visible = true
    local px, py = 100, 100
    label.Position = Vector2.new(px, py)
    local dragging = false
    local doffX, doffY = 0, 0
    local font = Theme.Font
    local tw = estimateTextWidth(tostring(text), 15, font) + 24
    local th = 28
    local bgX = px - tw / 2
    local bgY = py - th / 2
    bg.Position = Vector2.new(bgX, bgY)
    bg.Size = Vector2.new(tw, th)
    bg.Visible = true
    outline.Position = Vector2.new(bgX - 1, bgY - 1)
    outline.Size = Vector2.new(tw + 2, th + 2)
    outline.Visible = true
    table.insert(DraggableLabels, outline)
    table.insert(DraggableLabels, bg)
    table.insert(DraggableLabels, label)
    task.spawn(function()
        while not GalaxObsidian.Unloaded do
            task.wait(0.01)
            if isrbxactive() then
                local mx, my = getMousePos()
                if ismouse1pressed() then
                    if not dragging then
                        local bgx = bg.Position.X
                        local bgy = bg.Position.Y
                        local bgw = bg.Size.X
                        local bgh = bg.Size.Y
                        if mx >= bgx and mx <= bgx + bgw and my >= bgy and my <= bgy + bgh then
                            dragging = true
                            doffX = mx - px
                            doffY = my - py
                        end
                    end
                else
                    dragging = false
                end
                label.Visible = true
                bg.Visible = true
                outline.Visible = true
                if dragging then
                    px = mx - doffX
                    py = my - doffY
                    label.Position = Vector2.new(px, py)
                    local newBgX = px - tw / 2
                    local newBgY = py - th / 2
                    bg.Position = Vector2.new(newBgX, newBgY)
                    outline.Position = Vector2.new(newBgX - 1, newBgY - 1)
                end
            else
                label.Visible = false
                bg.Visible = false
                outline.Visible = false
            end
        end
        pcall(function()
            label:Remove()
            bg:Remove()
            outline:Remove()
        end)
    end)
end

-- ======================================================================
-- TEXT, COLOR & IMAGE HELPERS
-- ======================================================================
-- ---- Font & Key Helpers ----
local FontMap = {
    UI = Drawing.Fonts.UI,
    System = Drawing.Fonts.System,
    SystemBold = Drawing.Fonts.SystemBold,
    Minecraft = Drawing.Fonts.Minecraft,
    Monospace = Drawing.Fonts.Monospace,
    Pixel = Drawing.Fonts.Pixel,
    Fortnite = Drawing.Fonts.Fortnite,
}
GalaxObsidian.FontMap = FontMap
local TextChars = TextManager.TextChars
local function keyName(key)
    return TextManager:KeyName(key)
end
local KeyAliasMap = {
    MB1 = 1,
    M1 = 1,
    MOUSE1 = 1,
    MOUSEBUTTON1 = 1,
    MB2 = 2,
    M2 = 2,
    MOUSE2 = 2,
    MOUSEBUTTON2 = 2,
    MB3 = 4,
    M3 = 4,
    MOUSE3 = 4,
    MOUSEBUTTON3 = 4,
    MB4 = 5,
    M4 = 5,
    MOUSE4 = 5,
    MOUSEBUTTON4 = 5,
    MB5 = 6,
    M5 = 6,
    MOUSE5 = 6,
    MOUSEBUTTON5 = 6,
}
local function keyCodeFromName(key)
    if key == nil or key == false or key == "" or key == "None" then
        return nil
    end
    if type(key) == "number" then
        return key
    end
    local text = tostring(key)
    local numberKey = tonumber(text)
    if numberKey then
        return numberKey
    end
    local upper = text:upper():gsub("%s+", "")
    if KeyAliasMap[upper] then
        return KeyAliasMap[upper]
    end
    if upper:match("^F%d+$") then
        local n = tonumber(upper:sub(2))
        if n and n >= 1 and n <= 24 then
            return 111 + n
        end
    end
    if #upper == 1 then
        local byte = string.byte(upper)
        if byte and byte >= 32 and byte <= 126 then
            return byte
        end
    end
    return key
end

-- ---- Image Data Detection ----
local function isImageData(data)
    if type(data) ~= "string" or #data < 12 then
        return false
    end
    local b1, b2, b3, b4, b5, b6, b7, b8 = string.byte(data, 1, 8)
    if b1 == 137 and b2 == 80 and b3 == 78 and b4 == 71 and b5 == 13 and b6 == 10 and b7 == 26 and b8 == 10 then
        return true
    end
    if b1 == 255 and b2 == 216 and b3 == 255 then
        return true
    end
    if string.sub(data, 1, 4) == "RIFF" and string.sub(data, 9, 12) == "WEBP" then
        return true
    end
    return false
end

-- ---- Text Wrapping ----
local function wrapTextLines(text, maxWidth, size, maxLines, font)
    text = tostring(text or "")
    local lines = {}
    maxLines = maxLines or 8

    local function push(line)
        if #lines >= maxLines then
            return nil
        end
        lines[#lines + 1] = line
    end
    for rawLine in (text .. "\n"):gmatch("(.-)\n") do
        if rawLine == "" then
            push("")
        else
            local current = ""
            for word in rawLine:gmatch("%S+") do
                local nextLine = current == "" and word or (current .. " " .. word)
                if estimateTextWidth(nextLine, size, font) <= maxWidth then
                    current = nextLine
                else
                    if current ~= "" then
                        push(current)
                        current = word
                    end
                    if estimateTextWidth(current, size, font) > maxWidth then
                        push(fitTextToWidth(current, maxWidth, size, font))
                        current = ""
                    end
                end
                if #lines >= maxLines then
                    break
                end
            end
            if current ~= "" and #lines < maxLines then
                push(current)
            end
        end
        if #lines >= maxLines then
            break
        end
    end
    if #lines == 0 then
        lines[1] = ""
    end
    return lines
end
local function widestLineWidth(lines, size, font)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, estimateTextWidth(line, size, font))
    end
    return width
end

-- ---- Color Helpers ----
local function colorComponents(color)
    local str = tostring(color)
    local r, g, b = str:match("([%d%.]+)%D+([%d%.]+)%D+([%d%.]+)")
    if not r then
        return 0, 0, 0
    end
    return tonumber(r), tonumber(g), tonumber(b)
end
local function inactiveTextColor()
    return Theme.Muted or Theme.DimText
end
local function themeColor(value)
    if typeof(value) == "Color3" then
        return value
    end
    if type(value) == "string" then
        local hex = value:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if r and g and b then
                return Color3.fromRGB(r, g, b)
            end
        end
    end
    return value
end

-- ---- Image URL Helpers ----
local function robloxThumbnailUrl(assetId)
    return string.format(
        "https://thumbnails.roblox.com/v1/assets?assetIds=%s&size=150x150&format=Png&isCircular=false",
        tostring(assetId)
    )
end
local function imageUrl(value)
    if value == nil or value == "" then
        return nil
    end
    if type(value) == "number" then
        return robloxThumbnailUrl(value)
    end
    if type(value) == "string" and value:match("^%d+$") then
        return robloxThumbnailUrl(value)
    end
    return value
end
local function thumbnailImageUrl(data)
    if type(data) ~= "string" then
        return nil
    end
    local url = data:match('"imageUrl"%s*:%s*"(.-)"')
    if not url or url == "" then
        return nil
    end
    url = url:gsub("\\/", "/")
    return url
end

-- ---- Color Formatting ----
local function colorToHex(color)
    local r, g, b = colorComponents(color)
    r = math.floor(r * 255 + 0.5)
    g = math.floor(g * 255 + 0.5)
    b = math.floor(b * 255 + 0.5)
    return string.format("#%02X%02X%02X", r, g, b)
end
local function colorToRgbText(color)
    local r, g, b = colorComponents(color)
    return table.concat({ math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5) }, ", ")
end
local function darkerColor(color)
    local h, s, v = rgbToHsv(color)
    return Color3.fromHSV(h, s, v / 2)
end

-- ---- Mouse Helper ----
local function getMouse()
    local players = game:GetService("Players")
    if not players or not players.LocalPlayer then
        return nil
    end
    return players.LocalPlayer:GetMouse()
end

local DefaultKeybindModePopupModes = { "Toggle", "Hold", "Press" }

local function normalizeKeybindModePopupConfig(config, fallbackModes)
    if config == false then
        return false, {}
    end

    local modes = fallbackModes or DefaultKeybindModePopupModes
    local enabled = true

    if type(config) == "table" then
        if config.Enabled ~= nil then
            enabled = config.Enabled == true
        elseif config.Enabled == false then
            enabled = false
        end

        if #config > 0 then
            modes = config
        elseif type(config.Modes) == "table" then
            modes = config.Modes
        end
    elseif config == true or config == nil then
        enabled = true
    end

    local clean = {}
    local seen = {}

    for _, mode in ipairs(modes or {}) do
        mode = tostring(mode)
        if (mode == "Toggle" or mode == "Hold" or mode == "Press") and not seen[mode] then
            clean[#clean + 1] = mode
            seen[mode] = true
        end
    end

    if #clean == 0 then
        clean = { "Toggle", "Hold", "Press" }
    end

    return enabled ~= false, clean
end

local function resolveKeybindPopupConfig(popupConfig)
    if popupConfig == nil then
        return nil, nil
    end
    local enabled, modes = normalizeKeybindModePopupConfig(popupConfig)
    return enabled, modes
end

-- ======================================================================
-- WINDOW FACTORY (CreateWindow)
-- ======================================================================
-- ---- Option Resolution ----
function GalaxObsidian:CreateWindow(options)
    options = options or {}
    local mouse = getMouse()
    if not mouse then
        return nil
    end
    local optSize = options.Size
    local resolvedSize = Vector2.new(820, 600)
    if typeof(optSize) == "Vector2" then
        resolvedSize = optSize
    elseif type(optSize) == "table" and #optSize >= 2 then
        resolvedSize = Vector2.new(optSize[1], optSize[2])
    end
    local optMinSize = options.MinSize or options.MinimumSize
    local resolvedMinSize = Vector2.new(560, 360)
    if typeof(optMinSize) == "Vector2" then
        resolvedMinSize = optMinSize
    elseif type(optMinSize) == "table" and #optMinSize >= 2 then
        resolvedMinSize = Vector2.new(optMinSize[1], optMinSize[2])
    end

    -- ---- Window State Table ----
    local keybindMenuOptions = options.KeybindMenu or {}
    local keybindPopupEnabled, keybindPopupModes = normalizeKeybindModePopupConfig(options.KeybindModePopup or options.KeybindPopup)
    local initialDPIScale = tonumber(GalaxObsidian.DPIScale) or 100
    local initialScale = clamp(initialDPIScale / 100, 0.5, 2)
    local Window = {
        Title = options.Title or "",
        Subtitle = options.Subtitle or "",
        Footer = options.Footer or "",
        IconUrl = imageUrl(options.IconUrl or options.Icon or options.LogoUrl),
        IconData = options.IconData,
        IconReady = options.IconData ~= nil,
        IconSize = options.IconSize or 24,
        ImagesEnabled = options.EnableImages ~= false,
        TransparencyTextureData = GalaxObsidian.ImageCache[GalaxObsidian.TransparencyTextureUrl],
        LogicalSize = resolvedSize,
        Size = Vector2.new(math.floor(resolvedSize.X * initialScale + 0.5), math.floor(resolvedSize.Y * initialScale + 0.5)),
        MinSize = resolvedMinSize,
        DPIScale = initialDPIScale,
        Resizable = options.Resizable ~= false,
        MenuKey = options.MenuKey or 0x70,
        Position = Vector2.new(options.X or 180, options.Y or 130),
        Accent = options.Accent or Theme.Accent,
        SearchPlaceholder = options.SearchPlaceholder or "Search",
        SearchText = "",
        SearchFocused = false,
        ShowSearch = options.ShowSearch ~= false,
        ShowKeybindMenu = options.ShowKeybindMenu == true,
        KeybindMenuX = options.KeybindMenuX or keybindMenuOptions.X,
        KeybindMenuY = options.KeybindMenuY or keybindMenuOptions.Y,
        KeybindMenuWidth = options.KeybindMenuWidth or keybindMenuOptions.Width,
        NotifySide = options.NotifySide or "Right",
        Open = options.StartMinimized ~= true,
        Running = true,
        Tabs = {},
        ActiveTab = nil,
        TabScroll = {},
        ScrollTarget = nil,
        ScrollDragOffset = 0,
        Notifications = {},
        Pool = { Square = {}, Text = {}, Line = {}, Circle = {}, Image = {} },
        Index = { Square = 0, Text = 0, Line = 0, Circle = 0, Image = 0 },
        ImageDataByObject = {},
        IconAssets = {},
        IconPool = {},
        IconIndex = {},
        PrevKeys = {},
        PrevMouse1 = false,
        PrevMouse2 = false,
        HoldKey = nil,
        HoldStarted = 0,
        HoldLastRepeat = 0,
        Mouse1Clicked = false,
        Mouse1Held = false,
        Mouse2Clicked = false,
        Mouse2Held = false,
        DragOffset = nil,
        ResizeOffset = nil,
        SliderTarget = nil,
        DropdownTarget = nil,
        ColorPickerTarget = nil,
        ColorPickerDrag = nil,
        KeyListenTarget = nil,
        KeyListenStarted = 0,
        KeybindModePopupEnabled = keybindPopupEnabled,
        KeybindModePopupModes = keybindPopupModes,
        KeybindModeTarget = nil,
        KeybindModePopup = nil,
        TextTarget = nil,
        DropdownSearch = nil,
        TooltipText = nil,
        MouseLockOwner = nil,
        KeybindMenuDrag = nil,
        LastRobloxInputBlocked = nil,
        BlockClicks = false,
        _cornerRadius = GalaxObsidian.CornerRadius or 0,
        Options = GalaxObsidian.Options,
        Toggles = GalaxObsidian.Toggles,
    }

    -- ---- Active Window Registration & Image Preload ----
    GalaxObsidian.ActiveWindow = Window
    local ImageLoading = {}
    local function RequestImage(url, callback)
        if not url or url == "" then
            return nil
        end
        local cached = GalaxObsidian.ImageCache[url]
        if cached then
            if type(callback) == "function" then
                task.spawn(function()
                    pcall(callback, cached)
                end)
            end
            return cached
        end
        if ImageLoading[url] then
            if type(callback) == "function" then
                ImageLoading[url][#ImageLoading[url] + 1] = callback
            end
            return nil
        end
        ImageLoading[url] = {}

        if type(callback) == "function" then
            ImageLoading[url][#ImageLoading[url] + 1] = callback
        end
        task.spawn(function()
            local ok, data = pcall(function()
                return game:HttpGet(url)
            end)
            if ok and not isImageData(data) then
                local resolvedUrl = thumbnailImageUrl(data)
                if resolvedUrl then
                    ok, data = pcall(function()
                        return game:HttpGet(resolvedUrl)
                    end)
                    if ok and isImageData(data) then
                        GalaxObsidian.ImageCache[resolvedUrl] = data
                    end
                end
            end
            if ok and isImageData(data) then
                GalaxObsidian.ImageCache[url] = data
                for _, cb in ipairs(ImageLoading[url]) do
                    pcall(cb, data)
                end
            end
            ImageLoading[url] = nil
        end)
        return nil
    end
    if Window.ImagesEnabled and Window.IconUrl and not Window.IconReady then
        RequestImage(Window.IconUrl, function(data)
            Window.IconData = data
            Window.IconReady = true
        end)
    end
    if Window.ImagesEnabled and not Window.TransparencyTextureData then
        RequestImage(GalaxObsidian.TransparencyTextureUrl, function(data)
            Window.TransparencyTextureData = data
        end)
    end
    if Window.ImagesEnabled and not IconManager then
        for name, url in pairs(GalaxObsidian.IconUrls) do
            RequestImage(url, function(data)
                Window.IconAssets[name] = data
            end)
        end
    end

    -- ======================================================================
    -- RENDERING CORE — POOL, CLIPPING & PRIMITIVES
    -- ======================================================================
    -- ---- Object Pool ----
    function Window:_resetPool()
        self.Index.Square = 0
        self.Index.Text = 0
        self.Index.Line = 0
        self.Index.Circle = 0
        self.Index.Image = 0
        for name in pairs(self.IconIndex) do
            self.IconIndex[name] = 0
        end
    end
    function Window:_hideUnused()
        for kind, list in pairs(self.Pool) do
            for i = self.Index[kind] + 1, #list do
                list[i].Visible = false
            end
        end
        for name, list in pairs(self.IconPool) do
            local used = self.IconIndex[name] or 0
            for i = used + 1, #list do
                list[i].Visible = false
            end
        end
    end
    function Window:_get(kind)
        self.Index[kind] = self.Index[kind] + 1
        local object = self.Pool[kind][self.Index[kind]]
        if not object then
            object = Drawing.new(kind)
            self.Pool[kind][self.Index[kind]] = object
        end
        object.Visible = true
        return object
    end

    -- ---- Clip Region Checks ----
    function Window:_clipAllowsBox(y, h)
        if not self._clipTop or not self._clipBottom then
            return true
        end
        if not y or not h then
            return true
        end
        return y >= self._clipTop and y + h <= self._clipBottom
    end
    function Window:_clipAllowsLine(y1, y2)
        if not self._clipTop or not self._clipBottom then
            return true
        end
        local top = math.min(y1 or 0, y2 or 0)
        local bottom = math.max(y1 or 0, y2 or 0)
        return top >= self._clipTop and bottom <= self._clipBottom
    end

    -- ---- Square & Text ----
    function Window:_square(x, y, w, h, color, filled, transparency, corner, z)
        if not w or not h or w <= 0 or h <= 0 then
            return nil
        end
        if not self:_clipAllowsBox(y, h) then
            return nil
        end
        local object = self:_get("Square")
        object.Position = Vector2.new(x, y)
        object.Size = Vector2.new(w, h)
        if color then
            pcall(function()
                object.Color = color
            end)
        end
        object.Filled = filled ~= false
        object.Corner = corner or 0
        object.Transparency = transparency or 1
        object.ZIndex = z or 1
        return object
    end
    function Window:_text(text, x, y, color, size, font, center, outline, z)
        local content = tostring(text or "")
        local scale = self:GetScale()
        local textSize = math.floor((size or GalaxObsidian.FontSize or 13) * scale + 0.5)
        if not self:_clipAllowsBox(y, textSize) then
            return nil
        end
        local object = self:_get("Text")
        local resolvedFont = (font == Drawing.Fonts.Monospace and Theme.Font) or font or Theme.Font
        object.Text = content
        local tx = x
        if center == true then
            tx = tx - estimateTextWidth(content, size or GalaxObsidian.FontSize or 13, resolvedFont) / 2
        end
        local yOffset = scale > 1 and -math.floor((scale - 1) * 3) or 0
        object.Position = Vector2.new(math.floor(tx + 0.5), math.floor(y + yOffset + 0.5))
        if color then
            pcall(function()
                object.Color = color
            end)
        end
        object.Size = textSize
        object.Font = resolvedFont
        object.Center = false
        object.Outline = outline == true
        object.Transparency = 1
        object.ZIndex = z or 5
        return object
    end

    -- ---- Lines & Circles ----
    function Window:_line(x1, y1, x2, y2, color, thickness, z)
        if not self:_clipAllowsLine(y1, y2) then
            return nil
        end
        local object = self:_get("Line")
        object.From = Vector2.new(x1, y1)
        object.To = Vector2.new(x2, y2)
        if color then
            pcall(function()
                object.Color = color
            end)
        end
        object.Thickness = thickness or 1
        object.Transparency = 1
        object.ZIndex = z or 4
        return object
    end
    function Window:_circle(x, y, radius, color, filled, thickness, z)
        radius = radius or 0
        if not self:_clipAllowsBox(y - radius, radius * 2) then
            return nil
        end
        local object = self:_get("Circle")
        object.Position = Vector2.new(x, y)
        object.Radius = radius
        if color then
            pcall(function()
                object.Color = color
            end)
        else
            pcall(function()
                object.Color = Theme.Accent
            end)
        end
        object.Filled = filled ~= false
        object.Thickness = thickness or 1
        object.NumSides = 24
        object.Transparency = 1
        object.ZIndex = z or 5
        return object
    end

    -- ---- Images & Icons ----
    function Window:_image(data, x, y, w, h, rounding, z)
        if self.ImagesEnabled ~= true then
            return nil
        end
        if not data or data == "" or w <= 0 or h <= 0 then
            return nil
        end
        if not self:_clipAllowsBox(y, h) then
            return nil
        end
        if not isImageData(data) then
            return nil
        end
        local object = self:_get("Image")
        if self.ImageDataByObject[object] ~= data then
            object.Data = data
            self.ImageDataByObject[object] = data
        end
        object.Position = Vector2.new(x, y)
        object.Size = Vector2.new(w, h)
        object.Rounding = rounding or 0
        object.Transparency = 1
        object.ZIndex = z or 6
        return object
    end
    function Window:_iconImage(name, data, x, y, w, h, rounding, z)
        if self.ImagesEnabled ~= true then
            return nil
        end
        if not data or data == "" or w <= 0 or h <= 0 then
            return nil
        end
        if not self:_clipAllowsBox(y, h) then
            return nil
        end
        if not isImageData(data) then
            return nil
        end
        name = tostring(name or "icon")
        self.IconPool[name] = self.IconPool[name] or {}
        self.IconIndex[name] = (self.IconIndex[name] or 0) + 1
        local index = self.IconIndex[name]
        local object = self.IconPool[name][index]
        if not object then
            object = Drawing.new("Image")
            object.Data = data
            self.IconPool[name][index] = object
        end
        object.Position = Vector2.new(x, y)
        object.Size = Vector2.new(w, h)
        object.Rounding = rounding or 0
        object.Transparency = 1
        object.ZIndex = z or 6
        object.Visible = true
        return object
    end

    -- ======================================================================
    -- LAYOUT, VIEWPORT & INPUT HELPERS
    -- ======================================================================
    -- ---- Viewport Placement ----
    function Window:_over(x, y, w, h)
        return mouse.X >= x and mouse.X <= x + w and mouse.Y >= y and mouse.Y <= y + h
    end
    function Window:_clampToViewport(x, y, w, h, margin, screenOnly)
        margin = margin or 6
        if not screenOnly and self.Open and self.Position and self.Size then
            local minX = self.Position.X + margin
            local minY = self.Position.Y + margin
            local maxX = self.Position.X + self.Size.X - w - margin
            local maxY = self.Position.Y + self.Size.Y - h - margin
            if maxX < minX then
                maxX = minX
            end
            if maxY < minY then
                maxY = minY
            end
            return clamp(x, minX, maxX), clamp(y, minY, maxY)
        end
        local camera = workspace.CurrentCamera
        if not camera or not camera.ViewportSize then
            return x, y
        end
        local viewport = camera.ViewportSize
        local maxX = viewport.X - w - margin
        local maxY = viewport.Y - h - margin
        if maxX < margin then
            maxX = margin
        end
        if maxY < margin then
            maxY = margin
        end
        return clamp(x, margin, maxX), clamp(y, margin, maxY)
    end
    function Window:_placeNearMouse(w, h, offsetX, offsetY, margin, screenOnly)
        margin = margin or 6
        offsetX = offsetX or 12
        offsetY = offsetY or 14
        local x = mouse.X + offsetX
        local y = mouse.Y + offsetY
        local boundX, boundY = nil, nil
        if not screenOnly and self.Open and self.Position and self.Size then
            boundX = self.Position.X + self.Size.X
            boundY = self.Position.Y + self.Size.Y
        else
            local camera = workspace.CurrentCamera
            if camera and camera.ViewportSize then
                boundX = camera.ViewportSize.X
                boundY = camera.ViewportSize.Y
            end
        end
        if boundX and x + w > boundX - margin then
            x = mouse.X - w - 10
        end
        if boundY and y + h > boundY - margin then
            y = mouse.Y - h - 10
        end
        return self:_clampToViewport(x, y, w, h, margin, screenOnly)
    end

    -- ---- Ownership Checks ----
    function Window:_mouseAllowed(owner)
        if self.DropdownTarget and owner ~= self.DropdownTarget then
            return false
        end
        if self.ColorPickerTarget and owner ~= self.ColorPickerTarget then
            return false
        end
        if self.KeybindModeTarget and owner ~= self.KeybindModeTarget then
            return false
        end
        if not self.MouseLockOwner then
            return true
        end
        return owner ~= nil and self.MouseLockOwner == owner
    end
    function Window:_mouseCanTake(owner)
        return self:_mouseAllowed(owner)
    end

    -- ---- Hover & Tooltip ----
    function Window:_hover(x, y, w, h, owner)
        if not self:_clipAllowsBox(y, h) then
            return false
        end
        return self:_mouseAllowed(owner) and self:_over(x, y, w, h)
    end
    function Window:_tooltip(widget, x, y, w, h, owner)
        if self:_hotInteraction() then
            return nil
        end
        if widget and widget.tooltip and self:_hover(x, y, w, h, owner) then
            self.TooltipText = widget.tooltip
        end
    end

    -- ---- Click Detection ----
    function Window:_click(x, y, w, h, owner)
        return self.Mouse1Clicked and not self.BlockClicks and self:_hover(x, y, w, h, owner)
    end
    function Window:_focusClick(x, y, w, h, owner)
        if not self:_clipAllowsBox(y, h) then
            return false
        end
        local dropdown = self.DropdownTarget
        local popup = dropdown and dropdown.popup
        if dropdown and dropdown ~= owner and popup then
            local popupH = popup.h or (4 + math.min(#dropdown.options, dropdown.maxVisible or 6) * 21)
            if self:_over(popup.x, popup.y - 22, popup.w, popupH + 22) then
                return false
            end
        end
        local picker = self.ColorPickerTarget
        local pickerPopup = picker and picker.popup
        if picker and picker ~= owner and pickerPopup then
            if self:_over(pickerPopup.x, pickerPopup.y - 22, pickerPopup.w, pickerPopup.h + 22) then
                return false
            end
        end
        return self.Mouse1Clicked and not self.BlockClicks and self:_mouseCanTake(owner) and self:_over(x, y, w, h)
    end
    function Window:_clickFor(owner, x, y, w, h)
        return self:_click(x, y, w, h, owner)
    end

    -- ---- Outside-Click & Input Blocking ----
    function Window:_consumeOutsideFloatingClick()
        if not self.Mouse1Clicked then
            return false
        end
        local dropdown = self.DropdownTarget
        local dropdownPopup = dropdown and dropdown.popup
        if dropdown and dropdownPopup then
            local popupH = dropdownPopup.h or (4 + math.min(#dropdown.options, dropdown.maxVisible or 6) * 21)
            local insideDropdown = self:_over(dropdownPopup.x, dropdownPopup.y - 22, dropdownPopup.w, popupH + 22)
            if not insideDropdown then
                dropdown._searchText = ""
                self.DropdownTarget = nil
                self.DropdownSearch = nil
                self:_releaseInteraction(dropdown)
                self.Mouse1Clicked = false
                return true
            end
            return false
        end
        local picker = self.ColorPickerTarget
        local pickerPopup = picker and picker.popup
        if picker and pickerPopup then
            local insidePicker = self:_over(pickerPopup.x, pickerPopup.y - 22, pickerPopup.w, pickerPopup.h + 22)
            if not insidePicker then
                self.ColorPickerTarget = nil
                self.ColorPickerDrag = nil
                self:_releaseInteraction(picker)
                self.Mouse1Clicked = false
                return true
            end
            return false
        end
        if self.TextTarget and self.TextTarget.hitbox then
            local hitbox = self.TextTarget.hitbox
            if not self:_over(hitbox.x, hitbox.y, hitbox.w, hitbox.h) then
                local target = self.TextTarget
                self.TextTarget = nil
                self:_releaseInteraction(target)
                self.Mouse1Clicked = false
                return true
            end
        end
        if self.SearchFocused and self.SearchHitbox then
            local hitbox = self.SearchHitbox
            if not self:_over(hitbox.x, hitbox.y, hitbox.w, hitbox.h) then
                self.SearchFocused = false
                self:_releaseInteraction("Search")
                self.Mouse1Clicked = false
                return true
            end
        end
        return false
    end
    function Window:_updateInputBlock()
        local shouldBlock = self.Open == true
        if shouldBlock == self.LastRobloxInputBlocked then
            return nil
        end
        setrobloxinput(not shouldBlock)
        task.spawn(function()
            task.wait(0.1)
            mouse1click()
        end)
        self.Mouse1Clicked = false
        self.Mouse1Held = false
        self.LastRobloxInputBlocked = shouldBlock
    end

    -- ======================================================================
    -- ICON, ANIMATION & KEYBOARD INPUT
    -- ======================================================================
    -- ---- Icon & Animation Shortcuts ----
    function Window:_drawIcon(name, x, y, size, color, z)
        name = tostring(name or ""):lower()
        size = size or 14
        if IconManager and IconManager:Draw(self, name, x, y, size, color, z) then
            return true
        end
        if self.IconAssets and self.IconAssets[name] then
            self:_iconImage(name, self.IconAssets[name], x - size / 2, y - size / 2, size, size, 0, z)
            return true
        end
        return false
    end
    function Window:_anim(owner, key, target, speed)
        return AnimationManager:Approach(owner or self, key, target, speed or 14)
    end
    function Window:_hotInteraction()
        return self.DragOffset ~= nil or self.ResizeOffset ~= nil or self.ScrollTarget ~= nil
    end
    function Window:_animOrSnap(owner, key, target, speed, snap)
        if snap or self:_hotInteraction() then
            AnimationManager:Reset(owner or self, key)
            return target
        end
        return self:_anim(owner, key, target, speed)
    end
    function Window:_openKeybindModePopup(widget, x, y, w)
        local popupEnabled = widget.popupEnabled
        local popupModes = widget.popupModes
        if popupEnabled == nil then
            popupEnabled = self.KeybindModePopupEnabled
            popupModes = self.KeybindModePopupModes or DefaultKeybindModePopupModes
        end
        if not popupEnabled or not widget or widget.disabled == true then
            return nil
        end
        local modes = popupModes or DefaultKeybindModePopupModes
        if #modes <= 0 then
            return nil
        end
        local scale = self:GetScale()
        self:_closeFloating("keybindMode")
        self.KeybindModeTarget = widget
        self.KeybindModePopup = { x = x, y = y + math.floor(23 * scale), w = math.max(math.floor(82 * scale), w), h = math.floor(6 * scale) + #modes * math.floor(20 * scale), z = 135 }
        self:_claimInteraction(widget)
        self.Mouse2Clicked = false
    end
    function Window:_chevron(x, y, w, h, down, color, z)
        return self:_drawIcon(
            down and "chevron-down" or "chevron-up",
            x + w / 2,
            y + h / 2,
            math.min(w, h) + 2,
            color,
            z
        )
    end
    function Window:_checkMark(x, y, size, color, z)
        return self:_drawIcon("check", x + size / 2, y + size / 2, size, color, z)
    end

    -- ---- Key State Polling ----
    function Window:_keyPressed(key)
        key = keyCodeFromName(key)
        if key == nil then
            return false
        end
        local current = iskeypressed(key) == true
        local previous = self.PrevKeys[key] == true
        self.PrevKeys[key] = current
        return current and not previous
    end
    function Window:_updateInput()
        local down = ismouse1pressed() == true
        self.Mouse1Clicked = down and not self.PrevMouse1
        self.Mouse1Held = down
        self.PrevMouse1 = down
        local down2 = type(ismouse2pressed) == "function" and ismouse2pressed() == true or false
        self.Mouse2Clicked = down2 and not self.PrevMouse2
        self.Mouse2Held = down2
        self.PrevMouse2 = down2
    end

    -- ---- Text Input Reading ----
    function Window:_readListenKey()
        for key = 7, 255 do
            if self:_keyPressed(key) then
                return key
            end
        end
        return nil
    end
    function Window:_readTextInput()
        if self:_keyPressed(0x08) then
            return "backspace"
        end
        if self:_keyPressed(0x0D) then
            return "enter"
        end
        if self:_keyPressed(0x20) then
            return " "
        end
        for key, char in pairs(TextChars) do
            if self:_keyPressed(key) then
                if iskeypressed(0x10) then
                    return string.upper(char)
                end
                return char
            end
        end
        return nil
    end
    function Window:_renderTextInputValue(value, placeholder, x, y, w, size, focused, disabled, z, outline, align)
        return TextManager:RenderInput(
            self,
            value,
            placeholder,
            x,
            y,
            w,
            {
                Size = size,
                Font = Theme.Font,
                Focused = focused and not self:_hotInteraction(),
                Disabled = disabled,
                Color = Theme.Text,
                PlaceholderColor = Theme.Muted,
                DisabledColor = Theme.DimText,
                Outline = outline ~= false,
                Align = align,
                ZIndex = z,
            }
        )
    end
    function Window:_readBackspaceRepeat()
        local down = iskeypressed(0x08) == true
        if not down then
            if self.HoldKey == 0x08 then
                self.HoldKey = nil
                self.HoldStarted = 0
                self.HoldLastRepeat = 0
            end
            return false
        end
        local now = tick()
        if self.HoldKey ~= 0x08 then
            self.HoldKey = 0x08
            self.HoldStarted = now
            self.HoldLastRepeat = now
            return false
        end
        if now - self.HoldStarted >= 0.35 and now - self.HoldLastRepeat >= 0.1 then
            self.HoldLastRepeat = now
            return true
        end
        return false
    end

    -- ======================================================================
    -- INTERACTION STATE MANAGEMENT
    -- ======================================================================
    -- ---- Visibility & Interaction Claims ----
    function Window:_setAllVisible(visible)
        for _, list in pairs(self.Pool) do
            for _, object in ipairs(list) do
                object.Visible = visible
            end
        end
    end
    function Window:_clearInteraction()
        if self.DropdownTarget then
            self.DropdownTarget._searchText = ""
        end
        self.DropdownTarget = nil
        self.ColorPickerTarget = nil
        self.ColorPickerDrag = nil
        self.KeyListenTarget = nil
        self.KeyListenStarted = 0
        self.KeybindModeTarget = nil
        self.KeybindModePopup = nil
        self.TextTarget = nil
        self.TooltipText = nil
        self.SearchFocused = false
        self.DropdownSearch = nil
        self.SliderTarget = nil
        self.HoldKey = nil
        self.HoldStarted = 0
        self.HoldLastRepeat = 0
        self.MouseLockOwner = nil
        self.DragOffset = nil
        self.ResizeOffset = nil
        self.KeybindMenuDrag = nil
        self.BlockClicks = false
    end
    function Window:_claimInteraction(owner)
        self.MouseLockOwner = owner
        self.Mouse1Clicked = false
    end
    function Window:_releaseInteraction(owner, keepClick)
        if owner == nil or self.MouseLockOwner == owner then
            self.MouseLockOwner = nil
        end
        if keepClick ~= true then
            self.Mouse1Clicked = false
        end
    end
    function Window:_closeFloating(except)
        if except ~= "dropdown" then
            if self.DropdownTarget then
                self.DropdownTarget._searchText = ""
            end
            self.DropdownTarget = nil
        end
        if except ~= "colorpicker" then
            self.ColorPickerTarget = nil
            self.ColorPickerDrag = nil
        end
        if except ~= "textbox" then
            self.TextTarget = nil
        end
        if except ~= "search" then
            self.SearchFocused = false
        end
        if except ~= "dropdown" then
            self.DropdownSearch = nil
        end
        if except ~= "keybindMode" then
            if self.KeybindModeTarget then
                self:_releaseInteraction(self.KeybindModeTarget)
            end
            self.KeybindModeTarget = nil
            self.KeybindModePopup = nil
        end
    end

    -- ---- Corner Radius & Open State ----
    function Window:SetCornerRadius(radius)
        self._cornerRadius = math.min(10, math.max(0, math.floor(radius or 0)))
        GalaxObsidian.CornerRadius = self._cornerRadius
    end
    function Window:_setOpen(state)
        self.Open = state == true
        self:_clearInteraction()
        self:_updateInputBlock()
    end

    -- ---- Global Hotkeys ----
    function Window:_handleGlobalInput()
        if self:_keyPressed(self.MenuKey) then
            self:_setOpen(not self.Open)
        end
        if self.KeyListenTarget then
            local key = self:_readListenKey()
            if key then
                if self.KeyListenTarget.type == "toggle" or self.KeyListenTarget.type == "checkbox" then
                    self.KeyListenTarget.keybind = key
                else
                    self.KeyListenTarget.value = key
                    safeCall(self.KeyListenTarget.changed, key)
                end
                self.KeyListenTarget.listening = false
                self.KeyListenTarget = nil
                self.KeyListenStarted = 0
                self:_releaseInteraction()
            elseif (self.Mouse1Clicked or self.Mouse2Clicked) and tick() - self.KeyListenStarted > 0.1 then
                self.KeyListenTarget.listening = false
                self.KeyListenTarget = nil
                self.KeyListenStarted = 0
                self:_releaseInteraction()
            end
        end
        if self.SearchFocused then
            local char = self:_readTextInput()
            if char == "backspace" or self:_readBackspaceRepeat() then
                self.SearchText = string.sub(self.SearchText, 1, math.max(0, #self.SearchText - 1))
            elseif char == "enter" then
            elseif char then
                self.SearchText = self.SearchText .. char
            end
            return nil
        end
        if self.DropdownSearch then
            local char = self:_readTextInput()
            if char == "backspace" or self:_readBackspaceRepeat() then
                self.DropdownSearch._searchText = string.sub(
                    self.DropdownSearch._searchText or "",
                    1,
                    math.max(0, #(self.DropdownSearch._searchText or "") - 1)
                )
                self.DropdownSearch._dropdownScroll = 0
            elseif char == "enter" then
                self.DropdownSearch._dropdownScroll = 0
            elseif char then
                self.DropdownSearch._searchText = (self.DropdownSearch._searchText or "") .. char
                self.DropdownSearch._dropdownScroll = 0
            end
            return nil
        end
        if self.TextTarget then
            local char = self:_readTextInput()
            local target = self.TextTarget
            if char == "backspace" or self:_readBackspaceRepeat() then
                target.value = string.sub(target.value, 1, math.max(0, #target.value - 1))
                if target.type ~= "keybox" and not target.finished then
                    safeCall(target.callback, target.value)
                    safeCall(target.changed, target.value)
                end
            elseif char == "enter" then
                if target.finished then
                    safeCall(target.callback, target.value)
                    safeCall(target.changed, target.value)
                    self.TextTarget = nil
                    self:_releaseInteraction(target, true)
                end
            elseif char then
                if target.numeric then
                    if char:match("^[%d%.%-]$") then
                        target.value = target.value .. char
                    end
                else
                    target.value = target.value .. char
                end
                if target.type ~= "keybox" and not target.finished then
                    safeCall(target.callback, target.value)
                    safeCall(target.changed, target.value)
                end
            end
        end
        self:_processHotkeys()
    end
    function Window:_processHotkeys()
        if self.SearchFocused or self.TextTarget or self.KeyListenTarget or self.DropdownSearch then
            return nil
        end
        if #self.Tabs <= 0 then
            return nil
        end
        local function processWidget(widget)
            if widget.type == "sectiontabs" then
                local active = widget.tabs[widget.active or 1]
                if active then
                    for _, child in ipairs(active.widgets) do
                        processWidget(child)
                    end
                end
                return nil
            end
            if widget.type == "label" then
                local addons = widget.addons or {}
                for _, addon in ipairs(addons) do
                    if addon.type == "keybind" then
                        processWidget(addon)
                    end
                end
                return nil
            end
            if
                (widget.type == "toggle" or widget.type == "checkbox")
                and widget.keybind
                and widget.disabled ~= true
                and widget.listening ~= true
            then
                if self:_keyPressed(widget.keybind) then
                    widget.value = not widget.value
                    if widget.type == "toggle" then
                        widget._toggleAnimateUntil = tick() + 0.2
                    end
                    safeCall(widget.callback, widget.value)
                    safeCall(widget.changed, widget.value)
                end
            elseif
                widget.type == "keybind"
                and widget.value
                and widget.disabled ~= true
                and widget.listening ~= true
            then
                local resolvedKey = keyCodeFromName(widget.value)
                local keyHeld = resolvedKey ~= nil and iskeypressed(resolvedKey) == true
                local wasHeld = widget._prevHeld == true
                local mode = tostring(widget.mode or "Hold")
                if mode == "Hold" then
                    if widget._state ~= keyHeld then
                        widget._state = keyHeld
                        safeCall(widget.callback, keyHeld)
                    end
                elseif mode == "Toggle" then
                    if keyHeld and not wasHeld then
                        widget._state = not widget._state
                        if widget.parent and (widget.parent.type == "toggle" or widget.parent.type == "checkbox") then
                            widget.parent.value = widget._state
                            if widget.parent.type == "toggle" then
                                widget.parent._toggleAnimateUntil = tick() + 0.2
                            end
                            safeCall(widget.parent.callback, widget.parent.value)
                            safeCall(widget.parent.changed, widget.parent.value)
                        else
                            safeCall(widget.callback, widget._state)
                        end
                    end
                elseif mode == "Press" then
                    if keyHeld and not wasHeld then
                        widget._state = true
                        safeCall(widget.callback, true)
                        widget._state = false
                    end
                end
                widget._prevHeld = keyHeld
            end
        end
        for _, tab in ipairs(self.Tabs) do
            for _, section in ipairs(tab.Sections or {}) do
                for _, widget in ipairs(section.widgets or {}) do
                    processWidget(widget)
                end
            end
        end
    end

    -- ======================================================================
    -- WIDGET HANDLE BINDING
    -- ======================================================================
    function Window:_widgetHandle(widget, getters)
        local handle = makeHandle(widget)
        if getters then
            for k, v in pairs(getters) do
                handle[k] = v
            end
        end
        do
            local TypeMap = {
                toggle = "Toggle",
                checkbox = "Toggle",
                slider = "Slider",
                dropdown = "Dropdown",
                multidropdown = "Dropdown",
                colorpicker = "ColorPicker",
                keybind = "KeyPicker",
                keybox = "Input",
                textbox = "Input",
            }
            handle.Type = TypeMap[widget.type] or widget.type:sub(1, 1):upper() .. widget.type:sub(2)
        end
        handle.AddColorPicker = function(_, name, info)
            info = info or {}
            widget.addons = widget.addons or {}
            local default = info.Default or Color3.new(1, 1, 1)
            local hue, sat, vib = rgbToHsv(default)
            local addon = {
                type = "colorpicker",
                id = name,
                label = info.Text or info.Label or info.Title or tostring(name or "Color"),
                title = info.Title,
                value = default,
                hue = hue,
                sat = sat,
                vib = vib,
                transparency = info.Transparency or 0,
                transparencyEnabled = info.Transparency ~= nil,
                callback = info.Callback,
                changed = info.Changed,
                tooltip = info.Tooltip,
                disabled = info.Disabled == true,
                visible = info.Visible ~= false,
                popup = nil,
            }
            widget.addons[#widget.addons + 1] = addon
            return Window:_widgetHandle(addon)
        end
        handle.AddKeyPicker = function(_, name, info)
            info = info or {}
            if widget.type == "toggle" or widget.type == "checkbox" then
                widget.keybind = info.Default or 0
                widget.keybindMode = info.Mode or "Hold"
                widget.keybindChanged = info.Changed
                widget.keybindCallback = info.Callback
                if info.Popup ~= nil then
                    local enabled, modes = resolveKeybindPopupConfig(info.Popup)
                    widget.popupEnabled = enabled
                    widget.popupModes = modes
                end
                return Window:_widgetHandle(widget)
            end
            widget.addons = widget.addons or {}
            local addon = {
                type = "keybind",
                id = name,
                label = info.Text or info.Label or tostring(name or "Keybind"),
                value = info.Default or 0,
                mode = info.Mode or "Hold",
                callback = info.Callback,
                changed = info.Changed or info.ChangedCallback,
                tooltip = info.Tooltip,
                disabled = info.Disabled == true,
                waitForCallback = info.WaitForCallback == true,
                visible = info.Visible ~= false,
                _state = false,
                _prevHeld = false,
                popup = nil,
            }
            if info.Popup ~= nil then
                local enabled, modes = resolveKeybindPopupConfig(info.Popup)
                addon.popupEnabled = enabled
                addon.popupModes = modes
            end
            widget.addons[#widget.addons + 1] = addon
            return Window:_widgetHandle(addon)
        end
        if widget.id then
            if widget.type == "toggle" or widget.type == "checkbox" then
                self.Toggles[widget.id] = handle
            else
                self.Options[widget.id] = handle
            end
        end
        return handle
    end

    -- ======================================================================
    -- SEARCH & LAYOUT MEASUREMENT
    -- ======================================================================
    -- ---- Search Matching ----
    function Window:_matchesSearch(widget, section)
        if widget.visible == false then
            return false
        end
        local search = string.lower(self.SearchText or "")
        if search == "" then
            return true
        end
        local text = tostring(widget.label or widget.text or section.Name or "")
        if widget.type == "colorpair" then
            text = tostring(
                (widget.left and widget.left.label or "") .. " " .. (widget.right and widget.right.label or "")
            )
        elseif widget.type == "buttonpair" then
            text = tostring(
                (widget.left and widget.left.label or "") .. " " .. (widget.right and widget.right.label or "")
            )
        elseif widget.type == "sectiontabs" then
            text = ""
            for _, tab in ipairs(widget.tabs) do
                text = text .. " " .. tostring(tab.name or "")
                for _, child in ipairs(tab.widgets) do
                    text = text .. " " .. tostring(child.label or child.text or "")
                end
            end
        end
        return string.find(string.lower(text), search, 1, true) ~= nil
    end

    -- ---- Height Measurement ----
    function Window:_widgetHeight(widget)
        if widget.visible == false then
            return 0
        end
        local scale = self:GetScale()
        local base = 30
        if widget.type == "divider" then
            base = 13
        elseif widget.type == "colorpicker" then
            base = 32
        elseif widget.type == "colorpair" then
            base = 32
        elseif widget.type == "buttonpair" then
            base = 31
        elseif widget.type == "sectiontabs" then
            base = 40
            local height = math.floor(base * scale + 0.5)
            local active = widget.tabs[widget.active or 1]
            if active then
                for _, child in ipairs(active.widgets) do
                    if child.visible ~= false then
                        height = height + self:_widgetHeight(child)
                    end
                end
            end
            return height
        elseif widget.type == "label" then
            local textSize = math.floor(14 * scale)
            local lines = wrapTextLines(widget.text or "", 200 * scale, textSize, 8, Theme.Font)
            local hasAddon = widget.addons and #widget.addons > 0
            base = math.max(hasAddon and 28 or 20, #lines * 14 + 5)
        elseif widget.type == "slider" then
            base = 39
        elseif widget.type == "toggle" or widget.type == "checkbox" then
            base = 30
        elseif widget.type == "dropdown" or widget.type == "multidropdown" then
            base = 54
        elseif widget.type == "textbox" then
            base = 54
        elseif widget.type == "keybox" or widget.type == "keybind" then
            base = 32
        end
        return math.floor(base * scale + 0.5)
    end
    function Window:_sectionHeight(section)
        local scale = self:GetScale()
        local height = math.floor(55 * scale)
        if section.Name and section.Name:sub(1, 2) == "__" then
            height = math.floor(16 * scale)
        end
        local count = 0
        for _, widget in ipairs(section.widgets) do
            if self:_matchesSearch(widget, section) then
                height = height + self:_widgetHeight(widget)
                count = count + 1
            end
        end
        if count > 1 then
            height = height + (count - 1) * math.floor(4 * scale)
        end
        return height
    end

    -- ---- Section Visibility ----
    function Window:_sectionVisible(section)
        for _, widget in ipairs(section.widgets) do
            if self:_matchesSearch(widget, section) then
                return true
            end
        end
        return string.lower(self.SearchText or "") == ""
    end

    -- ======================================================================
    -- WIDGET RENDERERS
    -- ======================================================================
    -- ---- Checkbox ----
    function Window:_renderCheckbox(widget, x, y, w, z)
        local scale = self:GetScale()
        local boxX = x
        local disabled = widget.disabled == true
        local keyLabel = widget.keybind and (widget.listening and "..." or keyName(widget.keybind)) or nil
        local keyTextSize = math.floor(14 * scale)
        local keyH = math.floor(22 * scale)
        local keyW = keyLabel and math.max(math.floor(40 * scale), math.floor(estimateTextWidth(keyLabel, keyTextSize, Theme.Font) + math.floor(26 * scale))) or 0
        local keyX = keyLabel and (x + w - keyW) or nil
        local labelMaxW = widget.keybind and (w - keyW - math.floor(34 * scale)) or (w - math.floor(26 * scale))
        local overBox = not disabled and self:_hover(x, y, w, math.floor(24 * scale), widget)
        local checkBoxBg = self:_anim(widget, "checkbox.bg", overBox and Theme.Surface2 or Theme.Main, 16)
        local checkBoxOutline = self:_anim(
            widget,
            "checkbox.outline",
            widget.value and Theme.Outline2 or (overBox and Theme.Outline2 or Theme.Outline),
            16
        )
        local checkText = self:_anim(widget, "checkbox.text", widget.value and Theme.Text or inactiveTextColor(), 16)
        self:_tooltip(widget, x, y, w, 27, widget)
        local boxY = y + math.floor(5 * scale)
        local boxSize = math.floor(15 * scale)
        self:_square(boxX, boxY, boxSize, boxSize, checkBoxBg, true, disabled and 0.55 or 1, 2, z + 1)
        self:_square(boxX, boxY, boxSize, boxSize, checkBoxOutline, false, disabled and 0.55 or 1, 2, z + 2)
        if widget.value then
            self:_drawIcon("check", boxX + math.floor(7.5 * scale), y + math.floor(12.5 * scale), math.floor(12 * scale), Theme.Text, z + 4)
        end
        self:_text(
            fitTextToWidth(widget.label, labelMaxW, 15, Theme.Font),
            x + math.floor(23 * scale),
            y + math.floor(4 * scale),
            checkText,
            15,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 2
        )
        if keyLabel then
            local overKey = self:_hover(keyX, y + 2, keyW, keyH, widget)
            local keyBg = self:_anim(widget, "checkbox.key.bg", overKey and Theme.Surface2 or Theme.Surface, 16)
            local keyOutline = self:_anim(
                widget,
                "checkbox.key.outline",
                widget.listening and Theme.Text or (overKey and Theme.Outline2 or Theme.Outline),
                16
            )
            local keyText = self:_anim(widget, "checkbox.key.text", widget.listening and Theme.Text or Theme.Text, 16)
            local kY = y + math.floor(2 * scale)
            self:_square(keyX, kY, keyW, keyH, keyBg, true, 1, 2, z + 1)
            self:_square(keyX, kY, keyW, keyH, keyOutline, false, 1, 2, z + 2)
            self:_text(
                fitTextToWidth(keyLabel, keyW - math.floor(10 * scale), keyTextSize, Theme.Font),
                keyX + 6,
                y + 5,
                keyText,
                keyTextSize,
                Theme.Font,
                false,
                true,
                z + 3
            )
            if not disabled and self:_click(keyX, y + 2, keyW, keyH) then
                widget.listening = true
                self.KeyListenTarget = widget
                self.KeyListenStarted = tick()
                self.BlockClicks = true
                self:_claimInteraction(widget)
            end
        end
        if not disabled and self:_click(x, y, w, 24) then
            widget.value = not widget.value
            widget._toggleAnimateUntil = tick() + 0.2
            safeCall(widget.callback, widget.value)
            safeCall(widget.changed, widget.value)
        end
    end

    -- ---- Toggle ----
    function Window:_renderToggle(widget, x, y, w, z)
        local disabled = widget.disabled == true
        local scale = self:GetScale()
        local switchW = math.floor(36 * scale)
        local switchH = math.floor(20 * scale)
        local switchX = x + w - switchW
        local switchY = y + math.floor(3 * scale)
        local keyLabel = widget.listening and "..." or (widget.keybind and keyName(widget.keybind) or nil)
        local keyTextSize = math.floor(14 * scale)
        local keyH = math.floor(22 * scale)
        local keyW = keyLabel and math.max(40, math.floor(estimateTextWidth(keyLabel, keyTextSize, Theme.Font) + 26)) or 0
        local addons = widget.addons or {}
        local addonCount = 0
        for _, addon in ipairs(addons) do
            if addon.visible ~= false then
                addonCount = addonCount + 1
            end
        end
        local addonSize = math.floor(18 * scale)
        local addonGap = math.floor(4 * scale)
        local addonAreaW = addonCount > 0 and (addonCount * addonSize + (addonCount - 1) * addonGap + math.floor(4 * scale)) or 0
        local addonStartX = switchX - addonAreaW - math.floor(6 * scale)
        local keyX = addonStartX - keyW - math.floor(6 * scale)
        local toggleText = self:_anim(widget, "toggle.text", widget.value and Theme.Text or inactiveTextColor(), 16)
        self:_tooltip(widget, x, y, w, math.floor(28 * scale), widget)
        self:_text(
            fitTextToWidth(widget.label, w - switchW - keyW - addonAreaW - math.floor(18 * scale), 15, Theme.Font),
            x,
            y + math.floor(5 * scale),
            toggleText,
            15,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 2
        )
        if keyLabel then
            local keyBg = self:_anim(widget, "toggle.key.bg", Theme.Surface, 16)
            local keyOutline =
                self:_anim(widget, "toggle.key.outline", widget.listening and Theme.Text or Theme.Outline, 16)
            local keyText = self:_anim(widget, "toggle.key.text", widget.listening and Theme.Text or Theme.Text, 16)
            local kY = y + math.floor(2 * scale)
            self:_square(keyX, kY, keyW, keyH, keyBg, true, 1, 2, z + 1)
            self:_square(keyX, kY, keyW, keyH, keyOutline, false, 1, 2, z + 2)
            self:_text(
                fitTextToWidth(keyLabel, keyW - math.floor(10 * scale), keyTextSize, Theme.Font),
                keyX + math.floor(6 * scale),
                y + math.floor(5 * scale),
                keyText,
                keyTextSize,
                Theme.Font,
                false,
                true,
                z + 3
            )
            if not disabled and self:_click(keyX, kY, keyW, keyH) then
                widget.listening = true
                self.KeyListenTarget = widget
                self.KeyListenStarted = tick()
                self.BlockClicks = true
                self:_claimInteraction(widget)
            end
        end
        local ai = 0
        for _, addon in ipairs(addons) do
            if addon.visible ~= false then
                local swatchX = addonStartX + ai * (addonSize + addonGap)
                self:_renderColorSwatch(addon, swatchX, y + math.floor(3 * scale), addonSize, z + 1)
                ai = ai + 1
            end
        end
        local thumbR = math.floor(switchH / 2) - 2
        local targetTrack = widget.value and self.Accent or Theme.Surface
        local targetBorder = widget.value and self.Accent or Theme.Outline
        local targetThumb = widget.value and Theme.Text or Theme.DimText
        local thumbMinX = switchX + thumbR + 3
        local thumbMaxX = switchX + switchW - thumbR - 3
        local thumbProgress =
            self:_animOrSnap(widget, "toggle.thumbProgress", widget.value and 1 or 0, 18, self:_hotInteraction())
        local thumbX = thumbMinX + (thumbMaxX - thumbMinX) * thumbProgress
        local trackColor = self:_anim(widget, "toggle.track", targetTrack, 16)
        local borderColor = self:_anim(widget, "toggle.border", targetBorder, 16)
        local thumbColor = self:_anim(widget, "toggle.thumbColor", targetThumb, 16)
        self:_square(switchX, switchY, switchW, switchH, trackColor, true, disabled and 0.55 or 1, switchH, z + 1)
        self:_square(switchX, switchY, switchW, switchH, borderColor, false, disabled and 0.55 or 1, switchH, z + 2)
        self:_circle(thumbX, switchY + switchH / 2, thumbR, thumbColor, true, 1, z + 3)
        if not disabled and self:_focusClick(x, y, w, math.floor(31 * scale), widget) then
            widget.value = not widget.value
            widget._toggleAnimateUntil = tick() + 0.2
            safeCall(widget.callback, widget.value)
            safeCall(widget.changed, widget.value)
            self:_releaseInteraction(widget)
        end
    end

    -- ---- Slider ----
    function Window:_renderSlider(widget, x, y, w, z)
        local disabled = widget.disabled == true
        local compact = widget.compact == true
        local currentText = tostring(math.floor(widget.value * 100 + 0.5) / 100)
        local maxText = tostring(math.floor((widget.max or 0) * 100 + 0.5) / 100)
        if widget.formatDisplayValue then
            local custom = widget.formatDisplayValue(widget, widget.value)
            if custom ~= nil then
                currentText = tostring(custom)
                maxText = ""
            end
        end
        local hasAffix = tostring(widget.prefix or "") ~= "" or tostring(widget.suffix or "") ~= ""
        local valueText = ""
        if hasAffix then
            valueText = tostring(widget.prefix or "")
            if currentText ~= "" then
                valueText = valueText .. currentText
            end
            if widget.suffix then
                valueText = valueText .. tostring(widget.suffix)
            end
        elseif widget.hideMax then
            valueText = currentText
        else
            valueText = currentText .. "/" .. maxText
        end
        if not compact then
            local scale = self:GetScale()
            self:_tooltip(widget, x, y, w, math.floor(30 * scale), widget)
            local sliderLabelText =
                self:_anim(widget, "slider.label.text", disabled and Theme.DimText or Theme.Text, 16)
            self:_text(
                fitTextToWidth(widget.label, w, 12, Theme.Font),
                x,
                y + math.floor(1 * scale),
                sliderLabelText,
                12,
                Drawing.Fonts.Monospace,
                false,
                true,
                z + 2
            )
        end
        local scale = self:GetScale()
        local labelH = compact and 0 or math.floor(17 * scale)
        local barH = math.floor(13 * scale)
        local barX, barY, barW = x, y + labelH, w
        if compact then
            barY = y + math.floor(2 * scale)
        end
        local percent = 0
        if widget.max ~= widget.min then
            percent = clamp((widget.value - widget.min) / (widget.max - widget.min), 0, 1)
        end
        local fillW = math.floor(self:_anim(widget, "slider.fill", barW * percent, 18) + 0.5)
        local sliderFillColor = self:_anim(widget, "slider.fillColor", disabled and Theme.Outline2 or self.Accent, 16)
        self:_square(barX, barY, barW, barH, Theme.Main, true, disabled and 0.45 or 1, 3, z + 1)
        self:_square(barX, barY, barW, barH, Theme.Outline, false, disabled and 0.45 or 1, 3, z + 2)
        if fillW > 0 then
            self:_square(barX, barY, fillW, barH, sliderFillColor, true, 1, 3, z + 3)
        end
        local centeredValueW = estimateTextWidth(valueText, math.floor(11 * scale), Theme.Font)
        local sliderValueText = self:_anim(widget, "slider.value.text", disabled and Theme.DimText or Theme.Text, 16)
        self:_text(
            valueText,
            barX + math.floor((barW - centeredValueW) / 2),
            barY + math.floor(1 * scale),
            sliderValueText,
            11,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 4
        )
        if not disabled and self:_click(barX, barY - math.floor(4 * scale), barW, barH + math.floor(8 * scale)) then
            self.SliderTarget = widget
            self:_claimInteraction(widget)
        end
        if self.SliderTarget == widget and self.Mouse1Held then
            local nextPercent = clamp((mouse.X - barX) / barW, 0, 1)
            local nextValue = widget.min + (widget.max - widget.min) * nextPercent
            if widget.round then
                nextValue = math.floor(nextValue + 0.5)
            end
            if widget.integer then
                nextValue = math.floor(nextValue)
            end
            if widget.value ~= nextValue then
                widget.value = nextValue
                safeCall(widget.callback, widget.value)
                safeCall(widget.changed, widget.value)
            end
        elseif self.SliderTarget == widget then
            self.SliderTarget = nil
            self:_releaseInteraction(widget)
        end
    end

    -- ---- Dropdown ----
    function Window:_renderDropdown(widget, x, y, w, z, multi)
        local disabled = widget.disabled == true
        local searchable = widget.searchable == true
        local isOpen = self.DropdownTarget == widget
        local searchActive = isOpen and searchable and self.DropdownSearch == widget
        local display = widget.value
        if multi then
            local list = {}

            for _, option in ipairs(widget.options) do
                if widget.selected[option] then
                    list[#list + 1] = option
                end
            end
            display = #list > 0 and table.concat(list, ", ") or "---"
        elseif display == nil or display == "" then
            display = widget.placeholder or "---"
        end
        if widget.formatDisplayValue and not multi then
            local formatted = widget.formatDisplayValue(display)
            if formatted ~= nil then
                display = formatted
            end
        end
        local searchText = widget._searchText or ""
        local showSearchText = searchable and isOpen
        local buttonDisplay = showSearchText and searchText or display
        local buttonPlaceholder = showSearchText and "Search..." or ""
        local dropdownBg = self:_anim(widget, "dropdown.bg", isOpen and Theme.Surface2 or Theme.Surface, 16)
        local dropdownOutline =
            self:_anim(widget, "dropdown.outline", (isOpen or searchActive) and Theme.SoftOutline or Theme.Outline, 16)
        local dropdownIcon = self:_anim(
            widget,
            "dropdown.icon",
            disabled and Theme.DimText or (isOpen and Theme.Text or Theme.Muted),
            16
        )
        local dropdownLabel = self:_anim(widget, "dropdown.label.text", disabled and Theme.Muted or Theme.Text, 16)
        local scale = self:GetScale()
        local boxY = y + math.floor(20 * scale)
        local boxH = math.floor(25 * scale)
        local textY = y + math.floor(27 * scale)
        local iconY = y + math.floor(33 * scale)
        local popupY = y + math.floor(44 * scale)
        self:_tooltip(widget, x, y, w, math.floor(47 * scale), widget)
        self:_text(
            fitTextToWidth(widget.label, w, 14, Theme.Font),
            x,
            y + math.floor(1 * scale),
            dropdownLabel,
            14,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 2
        )
        self:_square(x, boxY, w, boxH, dropdownBg, true, 1, 3, z + 1)
        self:_square(x, boxY, w, boxH, dropdownOutline, false, disabled and 0.45 or 1, 3, z + 2)
        self:_renderTextInputValue(
            buttonDisplay,
            buttonPlaceholder,
            x + math.floor(7 * scale),
            textY,
            w - math.floor(42 * scale),
            13,
            searchActive,
            disabled,
            z + 3,
            true
        )
        self:_drawIcon(isOpen and "chevron-up" or "chevron-down", x + w - math.floor(14 * scale), iconY, math.floor(14 * scale), dropdownIcon, z + 3)
        widget.popup = { x = x, y = popupY, w = w, z = 120, multi = multi }

        if not disabled and self:_focusClick(x, boxY, w, boxH, widget) then
            if self.DropdownTarget == widget then
                if searchable then
                    self.DropdownSearch = widget
                    self:_claimInteraction(widget)
                else
                    self.DropdownTarget = nil
                    self.DropdownSearch = nil
                    self:_releaseInteraction(widget)
                end
            else
                self:_closeFloating("dropdown")
                self.DropdownTarget = widget
                widget._dropdownScroll = 0
                widget._searchText = ""
                self.DropdownSearch = nil
                self:_claimInteraction(widget)
            end
        end
    end

    -- ---- Keybind ----
    function Window:_renderKeybind(widget, x, y, w, z)
        local disabled = widget.disabled == true
        local label = widget.listening and "..." or keyName(widget.value)
        local scale = self:GetScale()
        local keyTextSize = 14
        local scaledKeyTextSize = math.floor(keyTextSize * scale + 0.5)
        local keyH = math.floor(22 * scale)
        local keyBtnY = y + math.floor(5 * scale)
        local keyW = math.max(math.floor(40 * scale), math.floor(estimateTextWidth(label, keyTextSize, Theme.Font) + math.floor(26 * scale)))
        local keyX = x + w - keyW
        local overKey = not disabled and self:_hover(keyX, keyBtnY, keyW, keyH, widget)
        local keyBg = self:_anim(widget, "keybind.bg", overKey and Theme.Surface2 or Theme.Surface, 16)
        local keyOutline = self:_anim(
            widget,
            "keybind.outline",
            widget.listening and Theme.Text or (overKey and Theme.Outline2 or Theme.Outline),
            16
        )
        self:_tooltip(widget, x, y, w, math.floor(24 * scale), widget)
        local labelTextSize = 14
        local scaledLabelTextSize = math.floor(labelTextSize * scale + 0.5)
        local widgetH = math.floor(32 * scale)
        local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
        self:_text(
            fitTextToWidth(widget.label, w - keyW - math.floor(10 * scale), labelTextSize, Theme.Font),
            x,
            y + math.floor(widgetH / 2) - math.floor(scaledLabelTextSize / 2) - yOfs,
            Theme.Text,
            labelTextSize,
            Theme.Font,
            false,
            true,
            z + 2
        )
        self:_square(keyX, keyBtnY, keyW, keyH, keyBg, true, 1, 2, z + 1)
        self:_square(keyX, keyBtnY, keyW, keyH, keyOutline, false, 1, 2, z + 2)
        self:_text(
            fitTextToWidth(label, keyW - math.floor(10 * scale), keyTextSize, Theme.Font),
            keyX + math.floor(6 * scale),
            keyBtnY + math.floor(keyH / 2) - math.floor(scaledKeyTextSize / 2) - yOfs,
            Theme.Text,
            keyTextSize,
            Theme.Font,
            false,
            true,
            z + 3
        )
        if not disabled and self.Mouse2Clicked and self:_over(keyX, keyBtnY, keyW, keyH) then
            self:_openKeybindModePopup(widget, keyX, keyBtnY, keyW)
        end
        if not disabled and self:_click(keyX, keyBtnY, keyW, keyH) then
            widget.listening = true
            self.KeyListenTarget = widget
            self.KeyListenStarted = tick()
            self.BlockClicks = true
            self:_claimInteraction(widget)
        end
    end

    -- ---- Textbox ----
    function Window:_renderTextbox(widget, x, y, w, z)
        local scale = self:GetScale()
        local boxY = y + math.floor(20 * scale)
        local boxH = math.floor(25 * scale)
        local textY = y + math.floor(27 * scale)
        local focused = self.TextTarget == widget
        local disabled = widget.disabled == true
        widget.hitbox = { x = x, y = boxY, w = w, h = boxH }
        local overBox = not disabled and self:_hover(x, boxY, w, boxH, widget)
        local boxBg = self:_anim(widget, "textbox.bg", overBox and Theme.Surface2 or Theme.Surface, 16)
        local boxOutline = self:_anim(
            widget,
            "textbox.outline",
            focused and self.Accent or (overBox and Theme.Outline2 or Theme.Outline),
            16
        )
        self:_tooltip(widget, x, y, w, math.floor(47 * scale), widget)
        self:_text(
            fitTextToWidth(widget.label or widget.text or "", w, 14, Theme.Font),
            x,
            y + math.floor(1 * scale),
            Theme.Text,
            14,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 2
        )
        self:_square(x, boxY, w, boxH, boxBg, true, 1, 3, z + 1)
        self:_square(x, boxY, w, boxH, boxOutline, false, disabled and 0.45 or 1, 3, z + 2)
        self:_renderTextInputValue(
            widget.value,
            widget.placeholder,
            x + math.floor(7 * scale),
            textY,
            w - math.floor(14 * scale),
            13,
            focused,
            disabled,
            z + 3,
            true
        )
        if not disabled and self:_focusClick(x, boxY, w, boxH, widget) then
            if not focused then
                if widget.clearTextOnFocus then
                    widget.value = ""
                end
            end
            self.TextTarget = widget
            self:_closeFloating("textbox")
            self:_claimInteraction(widget)
            if widget.finished then
                self.Mouse1Clicked = false
            end
        elseif self.Mouse1Clicked and not self:_over(x, boxY, w, boxH) and focused then
            self.TextTarget = nil
            self:_releaseInteraction(widget, true)
        end
    end

    -- ---- Key Box ----
    function Window:_renderKeyBox(widget, x, y, w, z)
        local scale = self:GetScale()
        local buttonW = math.floor(68 * scale)
        local gap = math.floor(8 * scale)
        local boxW = w - buttonW - gap
        local boxH = math.floor(25 * scale)
        local boxY = y + math.floor(2 * scale)
        local textY = y + math.floor(9 * scale)
        local focused = self.TextTarget == widget
        widget.hitbox = { x = x, y = boxY, w = boxW, h = boxH }
        self:_square(x, boxY, boxW, boxH, Theme.Surface, true, 1, 3, z + 1)
        self:_square(x, boxY, boxW, boxH, focused and self.Accent or Theme.Outline, false, 1, 3, z + 2)
        self:_renderTextInputValue(
            widget.value,
            widget.placeholder,
            x + math.floor(7 * scale),
            y + math.floor(9 * scale),
            boxW - math.floor(14 * scale),
            13,
            focused,
            false,
            z + 3,
            true
        )
        local bx = x + boxW + gap
        local over = self:_hover(bx, boxY, buttonW, boxH, widget)
        self:_square(bx, boxY, buttonW, boxH, over and Theme.Surface2 or Theme.Surface, true, 1, 3, z + 1)
        self:_square(bx, boxY, buttonW, boxH, over and Theme.Outline2 or Theme.Outline, false, 1, 3, z + 2)
        self:_text(
            fitTextToWidth("Execute", buttonW - math.floor(10 * scale), 13, Theme.Font),
            bx + buttonW / 2,
            textY,
            Theme.Text,
            13,
            Drawing.Fonts.Monospace,
            true,
            true,
            z + 3
        )
        if self:_focusClick(x, boxY, boxW, boxH, widget) then
            self.TextTarget = widget
            self:_closeFloating("textbox")
            self:_claimInteraction(widget)
        elseif self:_click(bx, boxY, buttonW, boxH, widget) then
            safeCall(widget.executeCallback, widget.value)
            self:_releaseInteraction(widget)
        elseif self.Mouse1Clicked and focused and not self:_over(x, boxY, boxW, boxH) then
            self.TextTarget = nil
            self:_releaseInteraction(widget, true)
        end
    end

    -- ---- Color Swatch ----
    function Window:_renderColorSwatch(widget, swatchX, swatchY, swatchSize, z)
        local disabled = widget.disabled == true
        local scale = self:GetScale()
        if widget.transparencyEnabled and self.TransparencyTextureData then
            self:_image(self.TransparencyTextureData, swatchX, swatchY, swatchSize, swatchSize, 3, z + 1)
        else
            self:_square(
                swatchX,
                swatchY,
                swatchSize,
                swatchSize,
                Theme.Background,
                true,
                disabled and 0.55 or 1,
                3,
                z + 1
            )
        end
        local swatchAlpha = widget.transparencyEnabled and (1 - clamp(widget.transparency or 0, 0, 1)) or 1
        local swatchColor = widget.value
        local swatchOutline = self.ColorPickerTarget == widget and Theme.Text or Theme.Outline
        self:_square(
            swatchX,
            swatchY,
            swatchSize,
            swatchSize,
            swatchColor,
            true,
            disabled and 0.55 or swatchAlpha,
            3,
            z + 2
        )
        self:_square(swatchX, swatchY, swatchSize, swatchSize, swatchOutline, false, disabled and 0.55 or 1, 3, z + 3)
        local popupPad = math.floor(6 * scale)
        local popupTitleH = widget.title and math.floor(16 * scale) or 0
        local popupMapSize = math.floor(200 * scale)
        local popupValueH = math.floor(20 * scale)
        local popupH = popupPad + popupTitleH + popupMapSize + math.floor(8 * scale) + popupValueH + popupPad
        widget.popup = {
            x = swatchX - (widget.transparencyEnabled and math.floor(238 * scale) or math.floor(216 * scale)),
            y = swatchY + swatchSize + math.floor(3 * scale),
            w = widget.transparencyEnabled and math.floor(256 * scale) or math.floor(234 * scale),
            h = popupH,
            z = 125,
        }

        if not disabled and self:_focusClick(swatchX, swatchY, swatchSize, swatchSize, widget) then
            local close = self.ColorPickerTarget == widget
            self.ColorPickerTarget = close and nil or widget
            self:_closeFloating("colorpicker")
            if close then
                self:_releaseInteraction(widget)
            else
                self:_claimInteraction(widget)
            end
        end
    end

    -- ---- Color Picker ----
    function Window:_renderColorPicker(widget, x, y, w, z)
        local disabled = widget.disabled == true
        local scale = self:GetScale()
        local swatchSize = math.floor(18 * scale)
        local swatchX = x + w - swatchSize
        local swatchY = y + math.floor(7 * scale)
        self:_tooltip(widget, x, y, w, math.floor(23 * scale), widget)
        self:_text(
            fitTextToWidth(widget.label or widget.title or "ColorPicker", w - math.floor(30 * scale), 13, Theme.Font),
            x,
            y + math.floor(8 * scale),
            disabled and Theme.Muted or Theme.Text,
            13,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 2
        )
        self:_renderColorSwatch(widget, swatchX, swatchY, swatchSize, z)
    end

    -- ---- Button ----
    function Window:_renderButtonWidget(widget, x, y, w, z)
        local scale = self:GetScale()
        local disabled = widget.disabled == true
        local btnH = math.floor(26 * scale)
        local btnY = y + math.floor(2 * scale)
        local over = not disabled and self:_hover(x, btnY, w, btnH, widget)
        local buttonBg = self:_anim(
            widget,
            "button.bg",
            disabled and Theme.Background or Theme.Surface,
            16
        )
        local buttonOutline = self:_anim(
            widget,
            "button.outline",
            disabled and Theme.SoftOutline or Theme.Outline,
            16
        )
        local buttonText =
            self:_anim(widget, "button.text", disabled and Theme.DimText or (over and Theme.Text or Theme.Muted), 16)
        self:_tooltip(widget, x, btnY, w, btnH, widget)
        self:_square(x, btnY, w, btnH, buttonBg, true, 1, 3, z + 1)
        self:_square(x, btnY, w, btnH, buttonOutline, false, 1, 3, z + 2)
        if widget._doubleConfirm and widget._confirmPending then
            self:_text(
                fitTextToWidth("Are you sure?", w - 12, 13, Theme.Font),
                x + w / 2,
                y + math.floor(8 * scale),
                self.Accent,
                13,
                Drawing.Fonts.Monospace,
                true,
                true,
                z + 3
            )
            if not disabled and self:_click(x, btnY, w, btnH, widget) then
                widget._confirmPending = false
                self.Mouse1Clicked = false
                safeCall(widget.callback)
            end
        else
            self:_text(
                fitTextToWidth(widget.label, w - math.floor(12 * scale), 13, Theme.Font),
                x + w / 2,
                y + math.floor(8 * scale),
                buttonText,
                13,
                Drawing.Fonts.Monospace,
                true,
                true,
                z + 3
            )
            if not disabled and self:_click(x, btnY, w, btnH, widget) then
                if widget._doubleConfirm then
                    widget._confirmPending = true
                    self.Mouse1Clicked = false
                else
                    safeCall(widget.callback)
                end
            end
        end
        if
            widget._doubleConfirm
            and widget._confirmPending
            and self.Mouse1Clicked
            and not self:_over(x, y + 2, w, 26)
        then
            widget._confirmPending = false
        end
    end

    -- ---- Section Tabs ----
    function Window:_renderSectionTabs(widget, x, y, w, z)
        local scale = self:GetScale()
        local tabBarH = math.floor(28 * scale)
        local tabBarClickH = math.floor(25 * scale)
        local tabTextY = y + math.floor(8 * scale)
        local count = math.max(1, #widget.tabs)
        local tabW = math.floor(w / count)
        for i, tab in ipairs(widget.tabs) do
            local tx = x + (i - 1) * tabW
            local tw = (i == count) and (w - tabW * (i - 1)) or tabW
            local active = (widget.active or 1) == i
            local over = self:_hover(tx, y + 1, tw, tabBarClickH, widget)
            local tabBg = self:_anim(
                widget,
                "sectiontab." .. tostring(i) .. ".bg",
                active and Theme.Background or Theme.Surface,
                16
            )
            local tabText = self:_anim(
                widget,
                "sectiontab." .. tostring(i) .. ".text",
                active and Theme.Text or Theme.Muted,
                16
            )
            self:_square(tx, y + 1, tw, tabBarH, tabBg, true, 1, 3, z + 1)
            self:_text(
                fitTextToWidth(tab.name, tw - math.floor(12 * scale), 13, Theme.Font),
                tx + tw / 2,
                tabTextY,
                tabText,
                13,
                Drawing.Fonts.Monospace,
                true,
                true,
                z + 3
            )
            if self:_click(tx, y + 1, tw, tabBarClickH, widget) then
                widget.active = i
                self.Mouse1Clicked = false
            end
        end
        self:_square(x, y + 1, w, tabBarH, Theme.Outline, false, 1, 3, z + 2)
        local active = widget.tabs[widget.active or 1]
        if not active then
            return nil
        end
        local cy = y + math.floor(36 * scale)
        for _, child in ipairs(active.widgets) do
            if child.visible ~= false then
                local childH = self:_widgetHeight(child)
                self:_renderWidget(child, x, cy, w, z + 4)
                cy = cy + childH
            end
        end
    end

    -- ======================================================================
    -- WIDGET DISPATCH & CLEANUP
    -- ======================================================================
    -- ---- Render Dispatch ----
    function Window:_renderWidget(widget, x, y, w, z, clipTop, clipBottom)
        local previousClipTop, previousClipBottom = self._clipTop, self._clipBottom
        if clipTop ~= nil or clipBottom ~= nil then
            self._clipTop = clipTop
            self._clipBottom = clipBottom
        end
        if widget.type == "divider" then
            local scale = self:GetScale()
            self:_line(x, y + math.floor(6 * scale), x + w, y + math.floor(6 * scale), Theme.Outline, 1, z + 2)
        elseif widget.type == "colorpicker" then
            self:_renderColorPicker(widget, x, y, w, z)
        elseif widget.type == "colorpair" then
            local scale = self:GetScale()
            local gap = math.floor(14 * scale)
            local itemW = math.floor((w - gap) / 2)
            self:_renderColorPicker(widget.left, x, y, itemW, z)
            self:_renderColorPicker(widget.right, x + itemW + gap, y, w - itemW - gap, z)
        elseif widget.type == "label" then
            local scale = self:GetScale()
            self:_tooltip(widget, x, y, w, math.floor(18 * scale), widget)
            local addons = widget.addons or {}
            local addonSize = math.floor(22 * scale)
            local addonGap = math.floor(4 * scale)
            local addonTextSize = 14
            local addonCount = 0
            local addonTotalW = 0
            local addonWidths = {}
            for i, a in ipairs(addons) do
                if a.visible ~= false then
                    local aw = addonSize
                    if a.type == "keybind" then
                        local keyLabel = a.listening and "..." or keyName(a.value or 0)
                        local textW = estimateTextWidth(keyLabel, addonTextSize, Theme.Font)
                        aw = math.max(addonSize, textW + math.floor(12 * scale))
                    end
                    addonWidths[i] = aw
                    addonTotalW = addonTotalW + aw
                    addonCount = addonCount + 1
                end
            end
            local addonAreaW = addonCount > 0 and (addonTotalW + (addonCount - 1) * addonGap) or 0
            local addonStartX = addonCount > 0 and (x + w - addonAreaW) or nil
            local labelMaxW = addonCount > 0 and (addonStartX - x - 6) or w
            local lines = wrapTextLines(widget.text or "", math.max(50, labelMaxW), 14, 8, Theme.Font)
            local scaledLabelTextSize = math.floor(14 * scale + 0.5)
            local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
            local firstLineY = y + math.floor(addonCount > 0 and math.floor(28 * scale) / 2 or math.floor(20 * scale) / 2) - math.floor(scaledLabelTextSize / 2) - yOfs
            for i, line in ipairs(lines) do
                self:_text(
                    fitTextToWidth(line, labelMaxW, 14, Theme.Font),
                    x,
                    firstLineY + (i - 1) * math.floor(14 * scale),
                    Theme.Text,
                    14,
                    Drawing.Fonts.Monospace,
                    false,
                    true,
                    z + 2
                )
            end
            if addonCount > 0 and addonStartX then
                local ax = addonStartX
                for i, addon in ipairs(addons) do
                    if addon.visible ~= false then
                        local aw = addonWidths[i] or addonSize
                        if addon.type == "keybind" then
                            local keyLabel = addon.listening and "..." or keyName(addon.value)
                            self:_square(ax, y + math.floor(3 * scale), aw, addonSize, Theme.Surface, true, 1, 2, z + 1)
                            self:_square(
                                ax,
                                y + math.floor(3 * scale),
                                aw,
                                addonSize,
                                addon.listening and Theme.Text or Theme.Outline,
                                false,
                                1,
                                2,
                                z + 2
                            )
                            local scaledAddonTextSize = math.floor(addonTextSize * scale + 0.5)
                            local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
                            self:_text(
                                fitTextToWidth(keyLabel, aw - math.floor(10 * scale), addonTextSize, Theme.Font),
                                ax + math.floor(aw / 2),
                                y + math.floor(3 * scale) + math.floor(addonSize / 2) - math.floor(scaledAddonTextSize / 2) - yOfs,
                                addon.listening and Theme.Text or Theme.Text,
                                addonTextSize,
                                Theme.Font,
                                true,
                                true,
                                z + 3
                            )
                            if addon.disabled ~= true and self.Mouse2Clicked and self:_over(ax, y + math.floor(3 * scale), aw, addonSize) then
                                self:_openKeybindModePopup(addon, ax, y + math.floor(3 * scale), aw)
                            end
                            if addon.disabled ~= true and self:_click(ax, y + math.floor(3 * scale), aw, addonSize) then
                                addon.listening = true
                                self.KeyListenTarget = addon
                                self.KeyListenStarted = tick()
                                self.BlockClicks = true
                                self:_claimInteraction(addon)
                            end
                        else
                            self:_renderColorSwatch(addon, ax, y + math.floor(3 * scale), addonSize, z + 1)
                        end
                        ax = ax + aw + addonGap
                    end
                end
            end
        elseif widget.type == "button" then
            self:_renderButtonWidget(widget, x, y, w, z)
        elseif widget.type == "buttonpair" then
            local scale = self:GetScale()
            local gap = math.floor(8 * scale)
            local itemW = math.floor((w - gap) / 2)
            self:_renderButtonWidget(widget.left, x, y, itemW, z)
            self:_renderButtonWidget(widget.right, x + itemW + gap, y, w - itemW - gap, z)
        elseif widget.type == "sectiontabs" then
            self:_renderSectionTabs(widget, x, y, w, z)
        elseif widget.type == "checkbox" then
            self:_renderCheckbox(widget, x, y, w, z)
        elseif widget.type == "toggle" then
            self:_renderToggle(widget, x, y, w, z)
        elseif widget.type == "slider" then
            self:_renderSlider(widget, x, y, w, z)
        elseif widget.type == "dropdown" then
            self:_renderDropdown(widget, x, y, w, z, false)
        elseif widget.type == "multidropdown" then
            self:_renderDropdown(widget, x, y, w, z, true)
        elseif widget.type == "keybind" then
            self:_renderKeybind(widget, x, y, w, z)
        elseif widget.type == "textbox" then
            self:_renderTextbox(widget, x, y, w, z)
        elseif widget.type == "keybox" then
            self:_renderKeyBox(widget, x, y, w, z)
        end
        self._clipTop, self._clipBottom = previousClipTop, previousClipBottom
    end

    -- ---- Target Containment & Popup Cleanup ----
    function Window:_widgetContainsTarget(widget, target)
        if not widget or not target then
            return false
        end
        if widget == target then
            return true
        end
        for _, addon in ipairs(widget.addons or {}) do
            if addon == target then
                return true
            end
        end
        if widget.type == "colorpair" then
            return widget.left == target or widget.right == target
        end
        if widget.type == "buttonpair" then
            return widget.left == target or widget.right == target
        end
        if widget.type == "sectiontabs" then
            for _, tab in ipairs(widget.tabs or {}) do
                for _, child in ipairs(tab.widgets or {}) do
                    if self:_widgetContainsTarget(child, target) then
                        return true
                    end
                end
            end
        end
        return false
    end
    function Window:_closeClippedWidget(widget)
        if self:_widgetContainsTarget(widget, self.DropdownTarget) then
            if self.DropdownTarget then
                self.DropdownTarget._searchText = ""
            end
            self.DropdownTarget = nil
            self.DropdownSearch = nil
            self:_releaseInteraction(nil)
        end
        if self:_widgetContainsTarget(widget, self.ColorPickerTarget) then
            self.ColorPickerTarget = nil
            self.ColorPickerDrag = nil
            self:_releaseInteraction(nil)
        end
        if self:_widgetContainsTarget(widget, self.SliderTarget) then
            self.SliderTarget = nil
            self:_releaseInteraction(nil)
        end
        if self:_widgetContainsTarget(widget, self.TextTarget) then
            self.TextTarget = nil
            self:_releaseInteraction(nil)
        end
    end

    -- ======================================================================
    -- SECTION & TAB LAYOUT RENDERING
    -- ======================================================================
    function Window:_renderSections(tab, x, y, w, h, z, clipTopOverride, clipBottomOverride)
        if tab.IsKeyTab then
            local section = tab.Sections[1]
            if not section then
                return nil
            end
            local contentW = math.floor(w * 0.75)
            local sx = x + math.floor((w - contentW) / 2)
            local totalH = 0
            local visibleCount = 0
            local scale = self:GetScale()
            for _, widget in ipairs(section.widgets) do
                if widget.visible ~= false then
                    totalH = totalH + self:_widgetHeight(widget)
                    visibleCount = visibleCount + 1
                end
            end
            if visibleCount > 1 then
                totalH = totalH + (visibleCount - 1) * math.floor(4 * scale)
            end
            local wy = y
                + math.floor((h - totalH) / 2)
                - (type(self.TabScroll[tab]) == "number" and self.TabScroll[tab] or 0)
            local clipTop = clipTopOverride or y
            local clipBottom = clipBottomOverride or (y + h)
            for _, widget in ipairs(section.widgets) do
                if widget.visible ~= false then
                    local wh = self:_widgetHeight(widget)
                    if wy < clipBottom and wy + wh > clipTop then
                        self:_renderWidget(widget, sx, wy, contentW, z + 5, clipTop, clipBottom)
                    else
                        self:_closeClippedWidget(widget)
                    end
                    wy = wy + wh + math.floor(4 * scale)
                end
            end
            return nil
        end
        local scale = self:GetScale()
        local pad = math.floor(10 * scale)
        local columnGap = math.floor(18 * scale)
        local scrollTrackW = math.floor(10 * scale)
        local scrollGap = math.floor(4 * scale)
        local scrollSlot = scrollTrackW + scrollGap
        local useTwoColumns = w >= math.floor(440 * scale)
        local columnW = useTwoColumns and math.floor((w - pad * 2 - columnGap) / 2) or math.floor(w - pad * 2)
        local leftY = y + pad
        local rightY = y + pad
        local layouts = {}
        tab._scrollOwners = tab._scrollOwners or { Left = {}, Right = {} }
        if type(self.TabScroll[tab]) ~= "table" then
            self.TabScroll[tab] = { Left = 0, Right = 0 }
        end
        local scrollState = self.TabScroll[tab]

        for index, section in ipairs(tab.Sections) do
            if self:_sectionVisible(section) then
                local side = section.side
                if not side then
                    side = (useTwoColumns and index % 2 == 0) and "Right" or "Left"
                end
                local sideName = useTwoColumns and side == "Right" and "Right" or "Left"
                local useRight = sideName == "Right"
                local sx = x + pad
                local sy = leftY
                if useRight then
                    sx = x + pad + columnW + columnGap
                    sy = rightY
                end
                local sh = self:_sectionHeight(section)
                layouts[#layouts + 1] = { section = section, side = sideName, x = sx, y = sy, w = columnW, h = sh }

                if useRight then
                    rightY = rightY + sh + math.floor(10 * scale)
                else
                    leftY = leftY + sh + math.floor(10 * scale)
                end
            end
        end
        local columnHeights = { Left = leftY - y, Right = rightY - y }
        local scrollMax = { Left = math.max(0, columnHeights.Left - h), Right = math.max(0, columnHeights.Right - h) }
        scrollState.Left = clamp(scrollState.Left or 0, 0, scrollMax.Left)
        scrollState.Right = clamp(scrollState.Right or 0, 0, scrollMax.Right)
        for _, layout in ipairs(layouts) do
            if (scrollMax[layout.side] or 0) > 0 then
                layout.w = math.max(40, columnW - scrollSlot)
            else
                layout.w = columnW
            end
        end
        local animScroll = {
            Left = self:_anim(tab, "scroll.Left", scrollState.Left, 22),
            Right = self:_anim(tab, "scroll.Right", scrollState.Right, 22),
        }

        -- ---- Column Scrollbars ----
        local function renderColumnScroll(sideName, trackX)
            local maxScroll = scrollMax[sideName] or 0
            local totalH = columnHeights[sideName] or 0
            local owner = tab._scrollOwners[sideName]
            if maxScroll <= 0 then
                if self.ScrollTarget == owner then
                    self.ScrollTarget = nil
                    self:_releaseInteraction(owner)
                end
                return nil
            end
            local trackW = scrollTrackW
            local trackY = y + math.floor(8 * scale)
            local trackH = h - math.floor(16 * scale)
            local thumbH = math.max(28, math.floor(trackH * (h / totalH)))
            local thumbRange = math.max(1, trackH - thumbH)
            local visualScroll = animScroll[sideName]
            local thumbY = trackY + math.floor((visualScroll / maxScroll) * thumbRange + 0.5)
            local thumbColor =
                self:_anim(owner, "columnScroll.thumb", self.ScrollTarget == owner and Theme.Muted or Theme.Outline, 18)
            self:_square(trackX, trackY, trackW, trackH, Theme.Background, true, 1, 5, z + 30)
            self:_square(trackX, trackY, trackW, trackH, Theme.Outline, false, 1, 5, z + 31)
            self:_square(trackX + 2, thumbY, trackW - 4, thumbH, thumbColor, true, 1, 5, z + 32)
            if self:_focusClick(trackX - 3, trackY, trackW + 6, trackH, owner) then
                self.ScrollTarget = owner
                self.ScrollDragOffset = clamp(mouse.Y - thumbY, 0, thumbH)
                self:_claimInteraction(owner)
                self.Mouse1Clicked = false
            end
            if self.ScrollTarget == owner and self.Mouse1Held then
                local ratio = clamp((mouse.Y - self.ScrollDragOffset - trackY) / thumbRange, 0, 1)
                scrollState[sideName] = ratio * maxScroll
            elseif self.ScrollTarget == owner then
                self.ScrollTarget = nil
                self:_releaseInteraction(owner)
            end
        end
        if useTwoColumns then
            renderColumnScroll("Left", x + pad + columnW - scrollTrackW)
            renderColumnScroll("Right", x + pad + columnW + columnGap + columnW - scrollTrackW)
        else
            renderColumnScroll("Left", x + pad + columnW - scrollTrackW)
        end
        local clipTop = clipTopOverride or y
        local clipBottom = clipBottomOverride or (y + h)
        for _, layout in ipairs(layouts) do
            local section = layout.section
            local sx = layout.x
            local sy = layout.y - (animScroll[layout.side] or 0)
            local sh = layout.h
            local sectionTop = math.max(sy, clipTop)
            local sectionBottom = math.min(sy + sh, clipBottom)
            local sectionVisibleH = sectionBottom - sectionTop
            if sectionVisibleH > 0 then
                layout.renderX = sx
                layout.renderY = sy
                layout.renderTop = sectionTop
                layout.renderBottom = sectionBottom
                layout.renderVisibleH = sectionVisibleH
                self:_square(sx, sectionTop, layout.w, sectionVisibleH, Theme.Sidebar, true, 1, 4, z + 1)
                self:_square(sx, sectionTop, layout.w, sectionVisibleH, Theme.Outline, false, 1, 4, z + 2)
            else
                layout.renderVisibleH = 0
                self:_closeClippedWidget(section)
            end
        end
        for _, layout in ipairs(layouts) do
            if (layout.renderVisibleH or 0) > 0 then
                local section = layout.section
                local sx = layout.renderX
                local sy = layout.renderY
                local sectionTop = layout.renderTop
                local sectionBottom = layout.renderBottom
                if section.Name and section.Name:sub(1, 2) ~= "__" and sy >= clipTop and sy + math.floor(34 * scale) <= clipBottom then
                    self:_line(sx, sy + math.floor(34 * scale), sx + layout.w, sy + math.floor(34 * scale), Theme.Outline, 1, z + 3)
                    self:_text(
                        fitTextToWidth(section.Name, layout.w - math.floor(24 * scale), 15, Theme.Font),
                        sx + math.floor(12 * scale),
                        sy + math.floor(10 * scale),
                        Theme.Text,
                        15,
                        Drawing.Fonts.Monospace,
                        false,
                        true,
                        z + 4
                    )
                end
                local headerH = (section.Name and section.Name:sub(1, 2) ~= "__") and math.floor(42 * scale) or math.floor(10 * scale)
                local gap = math.floor(4 * scale)
                local wy = sy + headerH
                for _, widget in ipairs(section.widgets) do
                    if self:_matchesSearch(widget, section) then
                        local wh = self:_widgetHeight(widget)
                        if wy < sectionBottom and wy + wh > sectionTop then
                            self:_renderWidget(widget, sx + math.floor(10 * scale), wy, layout.w - math.floor(20 * scale), z + 5, sectionTop, sectionBottom)
                        else
                            self:_closeClippedWidget(widget)
                        end
                        wy = wy + wh + gap
                    end
                end
            end
        end
    end

    -- ======================================================================
    -- POPUPS
    -- ======================================================================
    -- ---- Dropdown Popup ----
    function Window:_renderDropdownPopup()
        local widget = self.DropdownTarget
        if not widget or not widget.popup then
            return nil
        end
        local info = widget.popup
        local disabled = widget.disabled == true
        local searchable = widget.searchable == true
        local searchText = (widget._searchText or ""):lower()
        local filteredOptions = {}

        if searchable and searchText ~= "" then
            for _, opt in ipairs(widget.options) do
                if tostring(opt):lower():find(searchText, 1, true) then
                    filteredOptions[#filteredOptions + 1] = opt
                end
            end
        else
            filteredOptions = widget.options
        end
        local dpiScale = math.max(1, (self.DPIScale or 100) / 100)
        local defaultMaxVisible = math.floor(6 * dpiScale + 0.5)
        local maxVisible = widget.maxVisible or defaultMaxVisible
        local totalCount = #filteredOptions
        local visibleCount = math.min(totalCount, maxVisible)
        local hasScroll = totalCount > maxVisible
        local scale = self:GetScale()
        local scrollBarW = hasScroll and math.floor(7 * scale) or 0
        local itemH = math.floor(21 * scale)
        local height = visibleCount * itemH + math.floor(4 * scale)
        info.h = height
        info.x, info.y = self:_clampToViewport(info.x, info.y, info.w, height, 6, true)
        widget._dropdownScroll = math.max(0, math.min(widget._dropdownScroll or 0, totalCount - visibleCount))
        local scrollOffset = widget._dropdownScroll
        local visualDropdownScroll = self:_anim(widget, "dropdown.scroll.offset", scrollOffset, 18)
        if hasScroll then
            local trackX = info.x + info.w - scrollBarW - math.floor(2 * scale)
            local trackY = info.y + math.floor(2 * scale)
            local trackH = height - 4
            local thumbH = math.max(16, math.floor(trackH * visibleCount / totalCount))
            local thumbRange = math.max(1, trackH - thumbH)
            local thumbY = trackY + math.floor((visualDropdownScroll / (totalCount - visibleCount)) * thumbRange + 0.5)
            local thumbColor = self:_anim(
                widget,
                "dropdown.scroll.thumb",
                self.ScrollTarget == widget and Theme.Muted or Theme.Outline,
                18
            )
            self:_square(trackX, trackY, scrollBarW, trackH, Theme.Background, true, 1, 3, info.z + 1)
            self:_square(trackX + 1, thumbY, scrollBarW - 2, thumbH, thumbColor, true, 1, 3, info.z + 2)
            if self:_clickFor(widget, trackX, trackY, scrollBarW, trackH) then
                self.ScrollTarget = widget
                self.ScrollDragOffset = clamp(mouse.Y - thumbY, 0, thumbH)
                self:_claimInteraction(widget)
                self.Mouse1Clicked = false
            end
            if self.ScrollTarget == widget and self.Mouse1Held then
                local ratio = clamp((mouse.Y - self.ScrollDragOffset - trackY) / thumbRange, 0, 1)
                widget._dropdownScroll = math.floor(ratio * (totalCount - visibleCount) + 0.5)
            elseif self.ScrollTarget == widget then
                self.ScrollTarget = nil
                self:_releaseInteraction(widget)
            end
        end
        self:_square(info.x, info.y, info.w, height, Theme.Background, true, 1, 3, info.z)
        self:_square(info.x, info.y, info.w, height, Theme.SoftOutline, false, 1, 3, info.z + 1)
        local listPad = math.floor(2 * scale)
        local listW = info.w - scrollBarW - (hasScroll and math.floor(2 * scale) or 0)
        local listStartY = info.y + math.floor(2 * scale)
        for i = 1, visibleCount do
            local optionIndex = i + scrollOffset
            local option = filteredOptions[optionIndex]
            if not option then
                break
            end
            local oy = listStartY + (i - 1) * itemH
            local selected = false
            if info.multi then
                selected = widget.selected[option] == true
            else
                selected = widget.value == option
            end
            local isDisabled = false
            for _, dv in ipairs(widget.disabledValues or {}) do
                if dv == option then
                    isDisabled = true
                    break
                end
            end
            local optionX = info.x + listPad
            local optionW = listW - listPad - 2
            local optionKey = "dropdown.option." .. tostring(optionIndex)
            local optionBg = self:_anim(widget, optionKey .. ".bg", selected and Theme.Surface2 or Theme.Background, 18)
            local optionText = self:_anim(
                widget,
                optionKey .. ".text",
                (selected and not isDisabled) and Theme.Text or (isDisabled and Theme.DimText or Theme.Muted),
                16
            )
            self:_square(optionX, oy, optionW, itemH, optionBg, true, 1, 0, info.z + 2)
            self:_text(
                fitTextToWidth(option, listW - math.floor(25 * scale), 11, Theme.Font),
                info.x + math.floor(18 * scale),
                oy + math.floor(5 * scale),
                optionText,
                11,
                Drawing.Fonts.Monospace,
                false,
                true,
                info.z + 6
            )
            if not disabled and not isDisabled and self:_clickFor(widget, optionX, oy, optionW, itemH) then
                if info.multi then
                    local isSelected = widget.selected[option]
                    local selectedCount = 0
                    for _, v in pairs(widget.selected) do
                        if v then
                            selectedCount = selectedCount + 1
                        end
                    end
                    local minLimit = widget.min or 1
                    local maxLimit = widget.max or math.huge
                    if isSelected and selectedCount <= minLimit then
                    elseif not isSelected and selectedCount >= maxLimit then
                    else
                        widget.selected[option] = not isSelected
                        local list = {}

                        for _, item in ipairs(widget.options) do
                            if widget.selected[item] then
                                list[#list + 1] = item
                            end
                        end
                        safeCall(widget.callback, list)
                        safeCall(widget.changed, list)
                    end
                else
                    if selected and widget.allowNull == true then
                        widget.value = nil
                        safeCall(widget.callback, widget.value)
                        safeCall(widget.changed, widget.value)
                    else
                        widget.value = option
                        safeCall(widget.callback, widget.value)
                        safeCall(widget.changed, widget.value)
                    end
                end
                self.Mouse1Clicked = false
            end
        end
        if
            self.Mouse1Clicked
            and self.MouseLockOwner == widget
            and not self:_over(info.x, info.y - 22, info.w, height + 22)
        then
            widget._searchText = ""
            self.DropdownTarget = nil
            self.DropdownSearch = nil
            self:_releaseInteraction(widget)
        end
    end

    -- ---- Color Picker Popup ----
    function Window:_renderColorPickerPopup()
        local widget = self.ColorPickerTarget
        if not widget or not widget.popup then
            return nil
        end
        local scale = self:GetScale()
        local info = widget.popup
        info.x, info.y = self:_clampToViewport(info.x, info.y, info.w, info.h, math.floor(6 * scale), true)
        local x, y, z = info.x, info.y, info.z
        local pad = math.floor(6 * scale)
        local titleH = widget.title and math.floor(16 * scale) or 0
        local svX = x + pad
        local svY = y + pad + titleH
        local svSize = math.floor(200 * scale)
        local hueX = svX + svSize + math.floor(6 * scale)
        local barW = math.floor(16 * scale)
        local alphaX = hueX + barW + math.floor(6 * scale)
        local infoY = svY + svSize + math.floor(8 * scale)
        self:_square(x, y, info.w, info.h, Theme.Background, true, 1, 4, z)
        self:_square(x, y, info.w, info.h, Theme.Outline, false, 1, 4, z + 1)
        if widget.title then
            local titleCenter = y + pad + math.floor(titleH / 2)
            local scaledTitleSize = math.floor(14 * scale)
            local yOfs = scale > 1 and -math.floor((scale-1)*3) or 0
            self:_text(
                fitTextToWidth(widget.title, info.w - pad * 2, 14, Theme.Font),
                x + pad,
                titleCenter - math.floor(scaledTitleSize / 2) - yOfs,
                Theme.Text,
                14,
                Drawing.Fonts.Monospace,
                false,
                true,
                z + 2
            )
        end
        local framePad = math.floor(2 * scale)
        local mapX = svX + framePad
        local mapY = svY + framePad
        local mapSize = svSize - framePad * 2
        local hueInnerX = hueX + framePad
        local hueInnerY = svY + framePad
        local barInnerW = barW - framePad * 2
        local barInnerH = svSize - framePad * 2
        local alphaInnerX = alphaX + framePad
        if self.Mouse1Clicked then
            if self:_over(svX, svY, svSize, svSize) then
                self.ColorPickerDrag = "sv"
                self:_claimInteraction(widget)
            elseif self:_over(hueX, svY, barW, svSize) then
                self.ColorPickerDrag = "hue"
                self:_claimInteraction(widget)
            elseif widget.transparencyEnabled and self:_over(alphaX, svY, barW, svSize) then
                self.ColorPickerDrag = "alpha"
                self:_claimInteraction(widget)
            end
        end
        if not self.Mouse1Held then
            self.ColorPickerDrag = nil
        elseif self.ColorPickerDrag then
            local oldVal, oldAlpha = widget.value, widget.transparency
            if self.ColorPickerDrag == "sv" then
                widget.sat = clamp((mouse.X - mapX) / mapSize, 0, 1)
                widget.vib = clamp(1 - ((mouse.Y - mapY) / mapSize), 0, 1)
                widget.value = Color3.fromHSV(widget.hue or 0, widget.sat or 0, widget.vib or 0)
            elseif self.ColorPickerDrag == "hue" then
                widget.hue = clamp((mouse.Y - hueInnerY) / barInnerH, 0, 1)
                widget.value = Color3.fromHSV(widget.hue or 0, widget.sat or 0, widget.vib or 0)
            elseif self.ColorPickerDrag == "alpha" then
                widget.transparency = clamp((mouse.Y - hueInnerY) / barInnerH, 0, 1)
            end
            if widget.value ~= oldVal or widget.transparency ~= oldAlpha then
                safeCall(widget.callback, widget.value, widget.transparency)
                safeCall(widget.changed, widget.value, widget.transparency)
            end
        end
        self:_square(svX, svY, svSize, svSize, Theme.Background, true, 1, 4, z + 2) -- SV grid: only recalculate colors when hue changes (dragging sat/vib never changes the grid palette).
        if widget._cachedGridHue ~= (widget.hue or 0) then
            widget._cachedGridHue = (widget.hue or 0)
            widget._cachedGridColors = {}
            local cols, rows = 64, 48
            for row = 0, rows - 1 do
                local value = 1 - (row / (rows - 1))
                for col = 0, cols - 1 do
                    widget._cachedGridColors[row * cols + col + 1] =
                        Color3.fromHSV((widget.hue or 0), col / (cols - 1), value)
                end
            end
        end
        local cols, rows = 64, 48
        local gridColors = widget._cachedGridColors or {}

        for row = 0, rows - 1 do
            local cy0 = mapY + math.floor(row * mapSize / rows)
            local cy1 = mapY + math.floor((row + 1) * mapSize / rows)
            local ch = math.max(1, cy1 - cy0)
            for col = 0, cols - 1 do
                local cx0 = mapX + math.floor(col * mapSize / cols)
                local cx1 = mapX + math.floor((col + 1) * mapSize / cols)
                local cw = math.max(1, cx1 - cx0)
                self:_square(
                    cx0,
                    cy0,
                    cw,
                    ch,
                    gridColors[row * cols + col + 1] or Color3.new(0, 0, 0),
                    true,
                    1,
                    0,
                    z + 3
                )
            end
        end
        self:_square(svX, svY, svSize, svSize, Theme.Background, false, 1, 4, z + 4)
        self:_square(svX - 1, svY - 1, svSize + 2, svSize + 2, Theme.Outline, false, 1, 4, z + 5) -- Cursor position updates every frame regardless of dirty state.
        if not widget.sat or not widget.vib then
            widget.sat, widget.vib = 0, 0
        end
        self:_circle(mapX + widget.sat * mapSize, mapY + (1 - widget.vib) * mapSize, math.floor(4 * scale), Theme.Text, true, 1, z + 6)
        self:_square(hueX, svY, barW, svSize, Theme.Background, true, 1, 3, z + 2)
        local hueSegments = 96
        for i = 0, hueSegments - 1 do
            local y0 = hueInnerY + math.floor(i * barInnerH / hueSegments)
            local y1 = hueInnerY + math.floor((i + 1) * barInnerH / hueSegments)
            local segH = math.max(1, y1 - y0)
            self:_square(hueInnerX, y0, barInnerW, segH, Color3.fromHSV(i / hueSegments, 1, 1), true, 1, 0, z + 3)
        end
        self:_square(hueX, svY, barW, svSize, Theme.Background, false, 1, 3, z + 4)
        self:_square(hueX - 1, svY - 1, barW + 2, svSize + 2, Theme.Outline, false, 1, 3, z + 5)
        local hueY = hueInnerY + (widget.hue or 0) * barInnerH
        self:_line(hueX - 1, hueY, hueX + barW + 1, hueY, Theme.Text, 1, z + 6)
        if widget.transparencyEnabled then
            self:_square(alphaX, svY, barW, svSize, Theme.Background, true, 1, 3, z + 2)
            if self.TransparencyTextureData then
                local tileSize = math.max(1, math.floor(barInnerW / 2))
                local totalH = barInnerH
                local fullRows = math.floor((totalH + tileSize - 1) / tileSize)
                for row = 0, fullRows - 1 do
                    local rowH = tileSize
                    local ty = hueInnerY + totalH - (row + 1) * tileSize
                    if ty < hueInnerY then
                        rowH = tileSize - (hueInnerY - ty)
                        ty = hueInnerY
                    end
                    for col = 0, 1 do
                        local tx = alphaInnerX + col * tileSize
                        local tw = math.min(tileSize, alphaInnerX + barInnerW - tx)
                        self:_image(self.TransparencyTextureData, tx, ty, tw, rowH, 0, z + 3)
                    end
                end
            end
            local alphaSegments = 96
            for i = 0, alphaSegments - 1 do
                local alpha = 1 - (i / (alphaSegments - 1))
                local y0 = hueInnerY + math.floor(i * barInnerH / alphaSegments)
                local y1 = hueInnerY + math.floor((i + 1) * barInnerH / alphaSegments)
                local segH = math.max(1, y1 - y0)
                self:_square(alphaInnerX, y0, barInnerW, segH, widget.value, true, alpha, 0, z + 4)
            end
            self:_square(alphaX, svY, barW, svSize, Theme.Background, false, 1, 3, z + 5)
            self:_square(alphaX - 1, svY - 1, barW + 2, svSize + 2, Theme.Outline, false, 1, 3, z + 6)
            local alphaY = hueInnerY + clamp(widget.transparency or 0, 0, 1) * barInnerH
            self:_line(alphaX - 1, alphaY, alphaX + barW + 1, alphaY, Theme.Text, 1, z + 7)
        end
        local boxH = math.floor(20 * scale)
        local boxW = (info.w - pad * 2 - math.floor(8 * scale)) / 2
        local boxTextSize = 11
        local scaledBoxTextSize = math.floor(boxTextSize * scale)
        local yOfs = scale > 1 and -math.floor((scale-1)*3) or 0
        local boxTextY = infoY + math.floor(boxH / 2) - math.floor(scaledBoxTextSize / 2) - yOfs
        local hexBoxX = x + pad
        local rgbBoxX = x + pad + boxW + math.floor(8 * scale)
        local hexTextX = hexBoxX + math.floor(5 * scale)
        local rgbTextX = rgbBoxX + math.floor(5 * scale)
        self:_square(hexBoxX, infoY, boxW, boxH, Theme.Main, true, 1, 3, z + 2)
        self:_square(hexBoxX, infoY, boxW, boxH, Theme.Outline, false, 1, 3, z + 3)
        local displayR, displayG, displayB = hsvToRgb(widget.hue, widget.sat or 0, widget.vib or 0)
        local displayHex = string.format(
            "#%02X%02X%02X",
            math.floor(clamp(displayR * 255 + 0.5, 0, 255)),
            math.floor(clamp(displayG * 255 + 0.5, 0, 255)),
            math.floor(clamp(displayB * 255 + 0.5, 0, 255))
        )
        local displayRgb = table.concat(
            {
                math.floor(clamp(displayR * 255 + 0.5, 0, 255)),
                math.floor(clamp(displayG * 255 + 0.5, 0, 255)),
                math.floor(clamp(displayB * 255 + 0.5, 0, 255)),
            },
            ", "
        )
        self:_text(
            fitTextToWidth(displayHex, boxW - math.floor(12 * scale), boxTextSize, Theme.Font),
            hexTextX,
            boxTextY,
            Theme.Text,
            boxTextSize,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 4
        )
        self:_square(rgbBoxX, infoY, boxW, boxH, Theme.Main, true, 1, 3, z + 2)
        self:_square(rgbBoxX, infoY, boxW, boxH, Theme.Outline, false, 1, 3, z + 3)
        self:_text(
            fitTextToWidth(displayRgb, boxW - math.floor(12 * scale), boxTextSize, Theme.Font),
            rgbTextX,
            boxTextY,
            Theme.Text,
            boxTextSize,
            Drawing.Fonts.Monospace,
            false,
            true,
            z + 4
        )
        if self.Mouse1Clicked and self.MouseLockOwner == widget and not self:_over(x, y - math.floor(22 * scale), info.w, info.h + math.floor(22 * scale)) then
            self.ColorPickerTarget = nil
            self.ColorPickerDrag = nil
            self:_releaseInteraction(widget)
        end
    end

    -- ======================================================================
    -- NOTIFICATIONS, KEYBIND MENU & TOOLTIP
    -- ======================================================================
    -- ---- Notifications ----
    function Window:_renderNotifications()
        local now = tick()
        local camera = workspace.CurrentCamera
        if not camera or not camera.ViewportSize then
            return nil
        end
        local viewport = camera.ViewportSize
        local notifW = 260
        local margin = 18
        local slideTime = 0.22
        local startY = margin
        for i = #self.Notifications, 1, -1 do
            local notif = self.Notifications[i]
            if now >= notif.expires + slideTime then
                table.remove(self.Notifications, i)
            end
        end
        local stackY = 0
        for i, notif in ipairs(self.Notifications) do
            local textSize = 11
            local pad = 10
            local lineH = 15
            local fullText = notif.title and notif.title ~= "" and (notif.title .. "\n" .. notif.message)
                or notif.message
            local lines = wrapTextLines(fullText, notifW - pad * 2, textSize, 6, Theme.Font)
            local currentNotifW =
                math.max(60, math.min(notifW, math.floor(widestLineWidth(lines, textSize, Theme.Font) + pad * 2 + 10)))
            local notifH = pad * 2 + (#lines * lineH) + 7
            local finalX = self.NotifySide == "Left" and margin or (viewport.X - currentNotifW - margin)
            local hiddenX = self.NotifySide == "Left" and (-currentNotifW - 8) or (viewport.X + 8)
            local enter = clamp((now - notif.created) / slideTime, 0, 1)
            local leave = now > notif.expires and (1 - clamp((now - notif.expires) / slideTime, 0, 1)) or 1
            local slide = math.min(enter, leave)
            slide = 1 - ((1 - slide) * (1 - slide))
            local x = hiddenX + (finalX - hiddenX) * slide
            local y = startY + stackY
            local remaining = clamp((notif.expires - now) / notif.duration, 0, 1)
            self:_square(x, y, currentNotifW, notifH, Theme.Background, true, 1, 7, 140)
            self:_square(x, y, currentNotifW, notifH, Theme.SoftOutline, false, 1, 7, 141)
            for lineIndex, line in ipairs(lines) do
                self:_text(
                    line,
                    x + pad,
                    y + pad + (lineIndex - 1) * lineH,
                    lineIndex == 1 and Theme.Text or Theme.Muted,
                    textSize,
                    Drawing.Fonts.Monospace,
                    false,
                    false,
                    143
                )
            end
            self:_square(x + 8, y + notifH - 6, currentNotifW - 16, 2, Theme.Main, true, 1, 1, 142)
            self:_square(x + 8, y + notifH - 6, (currentNotifW - 16) * remaining, 2, self.Accent, true, 1, 1, 144)
            stackY = stackY + notifH + 10
        end
    end

    -- ---- Keybind Menu ----
    function Window:_collectKeybindRows()
        local rows = {}
        local function push(widget)
            if widget.visible == false or widget.popupEnabled == false then
                return nil
            end
            if widget.type == "keybind" and widget.value then
                local mode = tostring(widget.mode or "Hold")
                rows[#rows + 1] = {
                    text = TextManager:FormatKeybind(widget.value, widget.label or "Keybind", mode),
                    toggle = mode == "Toggle",
                    checked = (widget.parent and widget.parent.value) or widget._state == true,
                    widget = widget,
                }
            elseif (widget.type == "toggle" or widget.type == "checkbox") and widget.keybind then
                rows[#rows + 1] = {
                    text = TextManager:FormatKeybind(widget.keybind, widget.label or "Toggle", "Toggle"),
                    toggle = true,
                    checked = widget.value == true,
                    widget = widget,
                }
            elseif widget.type == "sectiontabs" then
                local active = widget.tabs[widget.active or 1]
                if active then
                    for _, child in ipairs(active.widgets) do
                        push(child)
                    end
                end
            end
            for _, addon in ipairs(widget.addons or {}) do
                push(addon)
            end
        end
        for _, tab in ipairs(self.Tabs) do
            for _, section in ipairs(tab.Sections) do
                for _, widget in ipairs(section.widgets) do
                    push(widget)
                end
            end
        end
        return rows
    end
    function Window:_renderKeybindMenu()
        if not self.ShowKeybindMenu then
            return nil
        end
        local scale = self:GetScale()
        local rows = self:_collectKeybindRows()
        local rowH = math.floor(24 * scale)
        local logicalWidth = self.KeybindMenuWidth or 260
        local width = math.floor(logicalWidth * scale)
        local dragH = math.floor(32 * scale)
        local height = dragH + math.floor(28 * scale) + #rows * rowH
        if self.KeybindMenuX == nil then
            local camera = workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize
            self.KeybindMenuX = 10
            self.KeybindMenuY = viewport and math.floor((viewport.Y - height) / 2) or 120
        end
        local x, y = self.KeybindMenuX, self.KeybindMenuY
        x, y = self:_clampToViewport(x, y, width, height, 6, true)
        local overDrag = self:_over(x, y, width, dragH)
        if overDrag and self:_click(x, y, width, dragH) then
            self.KeybindMenuDrag = { offsetX = mouse.X - x, offsetY = mouse.Y - y }
            self.Mouse1Clicked = false
        end
        if self.KeybindMenuDrag and self.Mouse1Held then
            x = mouse.X - self.KeybindMenuDrag.offsetX
            y = mouse.Y - self.KeybindMenuDrag.offsetY
            x, y = self:_clampToViewport(x, y, width, height, 6, true)
            self.KeybindMenuX, self.KeybindMenuY = x, y
        elseif self.KeybindMenuDrag then
            self.KeybindMenuDrag = nil
        end
        self.KeybindMenuX, self.KeybindMenuY = x, y
        self:_square(x, y, width, height, Theme.Background, true, 1, 4, 95)
        self:_square(x, y, width, height, Theme.Outline, false, 1, 4, 96)
        self:_text("Keybinds", x + math.floor(10 * scale), y + math.floor(10 * scale), Theme.Text, 14, Drawing.Fonts.Monospace, false, true, 97)
        self:_line(x + math.floor(4 * scale), y + dragH - math.floor(2 * scale), x + width - math.floor(4 * scale), y + dragH - math.floor(2 * scale), Theme.Outline, 1, 97)
        if #rows == 0 then
            self:_text(
                    "No keybinds",
                x + math.floor(10 * scale),
                y + dragH + math.floor(8 * scale),
                Theme.DimText,
                13,
                Drawing.Fonts.Monospace,
                false,
                true,
                97
            )
        else
            for i, row in ipairs(rows) do
                local ry = y + dragH + math.floor(8 * scale) + (i - 1) * rowH
                local textX = x + math.floor(10 * scale)
                if row.toggle then
                    local cbX = x + math.floor(10 * scale)
                    local cbSize = math.floor(12 * scale)
                    local cbY = ry + math.floor((rowH - cbSize) / 2)
                    local rowKey = "keybindMenu.checkbox." .. tostring(i)
                    local checkboxBg =
                        self:_anim(self, rowKey .. ".bg", row.checked and Theme.Surface or Theme.Main, 16)
                    local checkboxOutline =
                        self:_anim(self, rowKey .. ".outline", row.checked and Theme.Outline2 or Theme.Outline, 16)
                    self:_square(cbX, cbY, cbSize, cbSize, checkboxBg, true, 1, 2, 97)
                    self:_square(cbX, cbY, cbSize, cbSize, checkboxOutline, false, 1, 2, 98)
                    if row.checked then
                        self:_drawIcon("check", cbX + math.floor(cbSize / 2), cbY + math.floor(cbSize / 2), math.floor(10 * scale), Theme.Text, 99)
                    end
                    if self:_click(cbX, cbY, cbSize, cbSize) then
                        local target = row.widget
                        if target and (target.type == "toggle" or target.type == "checkbox") then
                            target.value = not target.value
                            if target.type == "toggle" then
                                target._toggleAnimateUntil = tick() + 0.2
                            end
                            safeCall(target.callback, target.value)
                            safeCall(target.changed, target.value)
                        elseif target and target.type == "keybind" then
                            if target.parent and (target.parent.type == "toggle" or target.parent.type == "checkbox") then
                                target.parent.value = not target.parent.value
                                if target.parent.type == "toggle" then
                                    target.parent._toggleAnimateUntil = tick() + 0.2
                                end
                                safeCall(target.parent.callback, target.parent.value)
                                safeCall(target.parent.changed, target.parent.value)
                            else
                                target._state = not target._state
                                safeCall(target.callback, target._state)
                            end
                        end
                        self.Mouse1Clicked = false
                    end
                    textX = x + math.floor(28 * scale)
                end
                local textColor = self:_anim(self, "keybindMenu.text." .. tostring(i), row.checked and Theme.Text or Theme.Muted, 16)
                local scaledRowTextSize = math.floor(13 * scale + 0.5)
                local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
                self:_text(
                    fitTextToWidth(row.text, width - (textX - x) - math.floor(10 * scale), 13, Theme.Font),
                    textX,
                    ry + math.floor(rowH / 2) - math.floor(scaledRowTextSize / 2) - yOfs,
                    textColor,
                    13,
                    Drawing.Fonts.Monospace,
                    false,
                    true,
                    97
                )
            end
        end
    end
    function Window:_renderKeybindModePopup()
        local popup = self.KeybindModePopup
        local target = self.KeybindModeTarget
        if not popup or not target or target.disabled == true then
            if target then
                self:_releaseInteraction(target)
            end
            self.KeybindModePopup = nil
            self.KeybindModeTarget = nil
            return nil
        end
        local scale = self:GetScale()
        local x, y, w, h, z = popup.x, popup.y, popup.w, popup.h, popup.z or 135
        local rowH = math.floor(20 * scale)
        local popupEnabled = target.popupEnabled
        local popupModes = target.popupModes
        if popupEnabled == nil then
            popupEnabled = self.KeybindModePopupEnabled
            popupModes = self.KeybindModePopupModes or DefaultKeybindModePopupModes
        end
        local modes = popupModes or DefaultKeybindModePopupModes
        if not popupEnabled or #modes <= 0 then
            self:_releaseInteraction(target)
            self.KeybindModePopup = nil
            self.KeybindModeTarget = nil
            return nil
        end
        h = math.floor(6 * scale) + #modes * rowH
        popup.h = h
        x, y = self:_clampToViewport(x, y, w, h, 4, true)
        popup.x, popup.y = x, y
        if (self.Mouse1Clicked or self.Mouse2Clicked) and not self:_over(x, y, w, h) then
            self:_releaseInteraction(target)
            self.KeybindModePopup = nil
            self.KeybindModeTarget = nil
            self.Mouse1Clicked = false
            self.Mouse2Clicked = false
            return nil
        end
        self:_square(x, y, w, h, Theme.Background, true, 1, 3, z)
        self:_square(x, y, w, h, Theme.Outline, false, 1, 3, z + 1)
        for i, mode in ipairs(modes) do
            local ry = y + math.floor(3 * scale) + (i - 1) * rowH
            local selected = tostring(target.mode or "Hold") == mode
            if selected then
                self:_square(x + math.floor(3 * scale), ry, w - math.floor(6 * scale), rowH - 1, Theme.Surface2, true, 1, 2, z + 1)
            end
            if selected then
                self:_drawIcon("check", x + math.floor(12 * scale), ry + math.floor(rowH / 2), math.floor(10 * scale), self.Accent, z + 3)
            end
            local scaledModeTextSize = math.floor(12 * scale + 0.5)
            local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
            self:_text(mode, x + math.floor(22 * scale), ry + math.floor(rowH / 2) - math.floor(scaledModeTextSize / 2) - yOfs, selected and Theme.Text or Theme.Muted, 12, Drawing.Fonts.Monospace, false, true, z + 3)
            if self:_click(x + math.floor(3 * scale), ry, w - math.floor(6 * scale), rowH - 1, target) then
                target.mode = mode
                safeCall(target.changed, target.value, target.modifiers)
                self:_releaseInteraction(target)
                self.KeybindModePopup = nil
                self.KeybindModeTarget = nil
                self.Mouse1Clicked = false
                break
            end
        end
    end

    -- ---- Tooltip ----
    function Window:_renderTooltip()
        local text = self.TooltipText
        if not text or text == "" or self.Mouse1Held then
            return nil
        end
        local scale = self:GetScale()
        local pad = math.floor(6 * scale)
        local maxTextW = math.floor(220 * scale)
        local lineH = math.floor(14 * scale)
        local textSize = math.floor(11 * scale + 0.5)
        local lines = wrapTextLines(text, maxTextW, 11, 8, Theme.Font)
        local w = math.floor(widestLineWidth(lines, 11, Theme.Font) + pad * 2 + math.floor(26 * scale))
        local h = pad * 2 + #lines * lineH
        local x, y = self:_placeNearMouse(w, h, math.floor(12 * scale), math.floor(14 * scale), 6, true)
        self:_square(x, y, w, h, Theme.Background, true, 1, 3, 145)
        self:_square(x, y, w, h, Theme.SoftOutline, false, 1, 3, 146)
        for i, line in ipairs(lines) do
            self:_text(
                fitTextToWidth(line, w - math.floor(10 * scale), 11, Drawing.Fonts.Monospace),
                x + math.floor(5 * scale),
                y + pad + (i - 1) * lineH + math.floor((lineH - textSize) / 2),
                Theme.Text,
                11,
                Drawing.Fonts.Monospace,
                false,
                false,
                147
            )
        end
    end

    -- ======================================================================
    -- MAIN RENDER LOOP
    -- ======================================================================
    function Window:GetScale()
        return math.max(0.5, (self.DPIScale or 100) / 100)
    end

    function Window:_render()
        self:_resetPool()
        self.BlockClicks = false
        self.TooltipText = nil
        if not self.Open then
            self:_renderKeybindMenu()
            self:_renderKeybindModePopup()
            self:_renderNotifications()
            self:_renderTooltip()
            self:_hideUnused()
            return nil
        end
        local x, y = self.Position.X, self.Position.Y
        local w, h = self.Size.X, self.Size.Y
        local scale = self:GetScale()
        local compact = w <= 420
        local sidebarW = compact and math.floor(48 * scale) or math.ceil(w * 0.26)
        if sidebarW < math.floor(128 * scale) and not compact then
            sidebarW = math.floor(128 * scale)
        end
        if sidebarW > math.floor(200 * scale) and not compact then
            sidebarW = math.floor(200 * scale)
        end
        local topH = math.floor(50 * scale)
        local bottomH = math.floor(20 * scale)
        local topPad = math.floor(8 * scale)
        local searchH = topH - topPad * 2
        local dragBox = searchH
        local dragSize = math.floor(30 * scale)
        local dragMargin = math.floor(8 * scale)
        local dragBoxX = x + w - dragMargin - dragBox
        local dragBoxY = y + topPad
        local dragX = dragBoxX + dragBox / 2
        local dragY = dragBoxY + dragBox / 2
        local searchGap = math.floor(8 * scale)
        local searchX = x + sidebarW + searchGap
        local searchY = y + topPad
        local searchW = math.max(0, dragBoxX - searchGap - searchX)
        local searchVisible = self.ShowSearch and searchW > 40
        self.SearchHitbox = searchVisible and { x = searchX, y = searchY, w = searchW, h = searchH } or nil
        self:_consumeOutsideFloatingClick()
        local overSearch = searchVisible and self:_over(searchX, searchY, searchW, searchH)
        if self:_click(x, y, w, topH) and not overSearch then
            self.DragOffset = Vector2.new(mouse.X - x, mouse.Y - y)
            self:_claimInteraction("WindowDrag")
        end
        if self.DragOffset and self.Mouse1Held then
            self.Position = Vector2.new(mouse.X - self.DragOffset.X, mouse.Y - self.DragOffset.Y)
            x, y = self.Position.X, self.Position.Y
        elseif self.DragOffset then
            self.DragOffset = nil
            self:_releaseInteraction("WindowDrag")
        end
        if self.Resizable then
            local resizeHitW = 28
            local resizeHitH = bottomH
            local resizeX = x + w - resizeHitW
            local resizeY = y + h - resizeHitH
            if self:_focusClick(resizeX, resizeY, resizeHitW, resizeHitH, "WindowResize") then
                self.ResizeOffset = Vector2.new(x + w - mouse.X, y + h - mouse.Y)
                self:_claimInteraction("WindowResize")
                self.Mouse1Clicked = false
            end
            if self.ResizeOffset and self.Mouse1Held then
                local minSizeX = math.floor((self.MinSize and self.MinSize.X or 560) * scale)
                local minSizeY = math.floor((self.MinSize and self.MinSize.Y or 360) * scale)
                local nextW = math.max(minSizeX, mouse.X - x + self.ResizeOffset.X)
                local nextH = math.max(minSizeY, mouse.Y - y + self.ResizeOffset.Y)
                local camera = workspace.CurrentCamera
                if camera and camera.ViewportSize then
                    nextW = math.min(nextW, math.max(minSizeX, camera.ViewportSize.X - x - 4))
                    nextH = math.min(nextH, math.max(minSizeY, camera.ViewportSize.Y - y - 4))
                end
                self.Size = Vector2.new(math.floor(nextW + 0.5), math.floor(nextH + 0.5))
                local dpiScale = clamp((self.DPIScale or 100) / 100, 0.5, 2)
                self.LogicalSize = Vector2.new(self.Size.X / dpiScale, self.Size.Y / dpiScale)
                w, h = self.Size.X, self.Size.Y
            elseif self.ResizeOffset then
                self.ResizeOffset = nil
                self:_releaseInteraction("WindowResize")
            end
        end
        -- Base structure: window shadow, background, global outline.
        local windowCorner =
            math.min(10, math.max(0, math.floor(self._cornerRadius or GalaxObsidian.CornerRadius or 0)))
        self:_square(x - 1, y - 1, w + 2, h + 2, Theme.Dark, true, 1, windowCorner, 1)
        self:_square(x, y, w, h, Theme.Background, true, 1, windowCorner, 2)
        self:_square(x, y, w, h, Theme.SoftOutline, false, 1, windowCorner, 3)
        -- Content area backgrounds (drawn before chrome so chrome overdaws them).
        self:_square(x, y + topH, sidebarW, h - topH - bottomH, Theme.Sidebar, true, 1, 0, 4)
        self:_square(
            x + sidebarW + 1,
            y + topH + 1,
            w - sidebarW - 2,
            h - topH - bottomH - 2,
            Theme.Background,
            true,
            1,
            0,
            4
        )
        -- Tab click handling (must happen before chrome overdraw).
        local tabEntryH = math.floor(40 * scale)
        local tabY = y + topH
        for _, tab in ipairs(self.Tabs) do
            if self:_click(x, tabY, sidebarW, tabEntryH) then
                self.ActiveTab = tab
                self:_closeFloating()
            end
            tabY = tabY + tabEntryH
        end
        -- Chrome base primitives are intentionally emitted before heavier section content.
        -- ZIndex keeps them on top while the pool order keeps drag/resize visuals responsive.
        local chromeZ = 88
        self:_square(x, y, w, topH, Theme.Topbar, true, 1, windowCorner, chromeZ)
        self:_line(x, y + topH, x + w, y + topH, Theme.Outline, 1, chromeZ + 1)
        self:_square(x, y + topH, sidebarW, h - topH - bottomH, Theme.Sidebar, true, 1, 0, chromeZ)
        self:_line(x + sidebarW, y, x + sidebarW, y + h - bottomH - 1, Theme.Outline, 1, chromeZ + 1)
        self:_square(x, y + h - bottomH, w, bottomH, Theme.Bottombar, true, 1, windowCorner, chromeZ + 1)
        self:_line(x, y + h - bottomH, x + w, y + h - bottomH, Theme.BottombarBorder, 1, chromeZ + 2)
        -- Chrome content is emitted before heavier sections for drag/resize responsiveness.
        -- Its higher ZIndex keeps it visually above the content layer.
        local footerTextSize = 14
        local scaledFooterTextSize = math.floor(footerTextSize * scale + 0.5)
        local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
        local footerText = fitTextToWidth(self.Footer or "", w - math.floor(10 * scale), footerTextSize, Drawing.Fonts.Monospace)
        local footerX = x + math.floor((w - estimateTextWidth(footerText, footerTextSize, Drawing.Fonts.Monospace)) / 2)
        self:_text(
            footerText,
            footerX,
            y + h - bottomH + math.floor((bottomH - scaledFooterTextSize) / 2) - yOfs,
            Theme.FooterText,
            footerTextSize,
            Drawing.Fonts.Monospace,
            false,
            true,
            chromeZ + 4
        )
        if self.Resizable then
            self:_drawIcon(
                "move-diagonal-2",
                x + w - math.floor(14 * scale),
                y + h - bottomH / 2,
                math.floor(16 * scale),
                self.ResizeOffset and Theme.Text or Theme.Muted,
                chromeZ + 5
            )
        end -- Title (icon + text).
        local chromeTitleIconSize = (self.IconReady and self.IconData) and math.min(math.floor((self.IconSize or 24) * scale), math.floor(26 * scale)) or 0
        local chromeTitleGap = chromeTitleIconSize > 0 and math.floor(6 * scale) or 0
        local chromeTitleSize = 21
        local scaledChromeTitleSize = math.floor(chromeTitleSize * scale + 0.5)
        local chromeTitleText = fitTextToWidth(
            self.Title,
            sidebarW - chromeTitleIconSize - chromeTitleGap - math.floor(24 * scale),
            chromeTitleSize,
            Theme.Font
        )
        local chromeTitleW = estimateTextWidth(chromeTitleText, chromeTitleSize, Theme.Font)
        local chromeTitleTotalW = chromeTitleIconSize + chromeTitleGap + chromeTitleW
        local chromeTitleX = x + math.floor((sidebarW - chromeTitleTotalW) / 2)
        if chromeTitleIconSize > 0 then
            self:_image(
                self.IconData,
                chromeTitleX,
                y + math.floor((topH - chromeTitleIconSize) / 2),
                chromeTitleIconSize,
                chromeTitleIconSize,
                0,
                chromeZ + 4
            )
        end
        chromeTitleX = chromeTitleX + chromeTitleIconSize + chromeTitleGap
        local yOfs = scale > 1 and -math.floor((scale - 1) * 3) or 0
        self:_text(
            chromeTitleText,
            chromeTitleX,
            y + math.floor((topH - scaledChromeTitleSize) / 2) - yOfs,
            Theme.Text,
            chromeTitleSize,
            Drawing.Fonts.Monospace,
            false,
            true,
            chromeZ + 4
        ) -- Search bar.
        if searchVisible then
            self:_square(searchX, searchY, searchW, searchH, Theme.Main, true, 1, 4, chromeZ + 3)
            self:_square(
                searchX,
                searchY,
                searchW,
                searchH,
                self.SearchFocused and self.Accent or Theme.Outline,
                false,
                1,
                4,
                chromeZ + 4
            )
            self:_drawIcon("search", searchX + math.floor(17 * scale), searchY + searchH / 2, math.floor(17 * scale), Theme.Muted, chromeZ + 5)
            self:_renderTextInputValue(
                self.SearchText,
                self.SearchPlaceholder,
                searchX + math.floor(44 * scale),
                searchY + math.floor((searchH - math.floor(16 * scale)) / 2),
                searchW - math.floor(70 * scale),
                16,
                self.SearchFocused,
                false,
                chromeZ + 5,
                false,
                "Center"
            )
            if self:_focusClick(searchX, searchY, searchW, searchH, "Search") then
                self.SearchFocused = true
                self:_closeFloating("search")
                self:_claimInteraction("Search")
            end
        end
        if self.Mouse1Clicked and (not searchVisible or not self:_over(searchX, searchY, searchW, searchH)) then
            self.SearchFocused = false
            self:_releaseInteraction("Search", true)
        end
        self:_drawIcon("move", dragX, dragY, dragSize, Theme.Outline2, chromeZ + 5) -- Tab list (sidebar entries).
        local chromeTabY = y + topH
        for _, tab in ipairs(self.Tabs) do
            local active = tab == self.ActiveTab
            local over = self:_hover(x, chromeTabY, sidebarW, tabEntryH, tab)
            local sidebarBg = self:_animOrSnap(
                tab,
                "sidebar.bg",
                active and Theme.Surface or Theme.Sidebar,
                16
            )
            if active then
                self:_square(x, chromeTabY, sidebarW, tabEntryH, sidebarBg, true, 1, 0, chromeZ + 2)
            end
            local iconX = x + (compact and math.floor(sidebarW / 2) or math.floor(21 * scale))
            local iconY = chromeTabY + math.floor(tabEntryH / 2)
            local tabColor = self:_animOrSnap(tab, "sidebar.text", (active or over) and Theme.Text or Theme.Muted, 16)
            local iconColor = self:_animOrSnap(tab, "sidebar.icon", active and self.Accent or tabColor, 16)
            self:_drawIcon(tab.Icon or tab.Name, iconX, iconY, math.floor(19 * scale), iconColor, chromeZ + 4)
            if not compact then
                self:_text(
                    fitTextToWidth(tab.Name, sidebarW - math.floor(42 * scale), 16, Theme.Font),
                    x + math.floor(42 * scale),
                    chromeTabY + math.floor(12 * scale),
                    tabColor,
                    16,
                    Drawing.Fonts.Monospace,
                    false,
                    true,
                    chromeZ + 5
                )
            end
            chromeTabY = chromeTabY + tabEntryH
        end
        -- Sidebar image (rendered after tabs, at the bottom of the sidebar)
        if self.SidebarImageReady and self.SidebarImageData then
            local maxH = h - topH - bottomH

            local imgScale = tonumber(self.SidebarImageScale) or 1.0

            local nativeW = tonumber(self.SidebarImageNativeW)
            local nativeH = tonumber(self.SidebarImageNativeH)
            if not nativeW or nativeW <= 0 then nativeW = sidebarW end
            if not nativeH or nativeH <= 0 then nativeH = sidebarW end
            local aspectRatio = nativeW / nativeH  -- width / height

            -- W: scale based on sidebar width; H derived from W/H aspect
            local imgW = math.floor(sidebarW * imgScale)
            local imgH = (aspectRatio > 0) and math.floor(imgW / aspectRatio) or imgW

            -- Cap to max height to avoid overlapping topbar
            if imgH > maxH then
                imgH = maxH
                imgW = math.floor(imgH * aspectRatio)
            end

            local rawOX = tonumber(self.SidebarImageX)
            local rawOY = tonumber(self.SidebarImageY)
            local imgX, imgY
            if rawOX and rawOY and (rawOX ~= 0 or rawOY ~= 0) then
                imgX = x + rawOX
                imgY = y + topH + rawOY
            else
                imgX = x + math.floor((sidebarW - imgW) / 2)
                imgY = y + h - bottomH - imgH
            end
            self:_image(self.SidebarImageData, imgX, imgY, imgW, imgH, 0, chromeZ + 3)
        end
        -- Render content sections after chrome updates; ZIndex keeps them below.
        if self.ActiveTab then
            self:_renderSections(self.ActiveTab, x + sidebarW, y + topH, w - sidebarW, h - topH - bottomH, 10, y, y + h)
        end
        -- Popups and overlays (always on top of everything).
        self:_renderDropdownPopup()
        self:_renderColorPickerPopup()
        self:_renderKeybindMenu()
        self:_renderKeybindModePopup()
        self:_renderNotifications()
        self:_renderTooltip()
        self:_hideUnused()
    end

    -- ======================================================================
    -- WINDOW PUBLIC API
    -- ======================================================================
    -- ---- Notifications & Visibility ----
    function Window:Notify(message, title, duration)
        if type(message) == "table" then
            local info = message
            title = info.Title or info.title or title
            duration = info.Time or info.Duration or info.duration or duration
            message = info.Description or info.Text or info.Message or info.description or ""
        end
        if type(title) == "number" and duration == nil then
            duration = title
            title = nil
        end
        local life = duration or 3
        self.Notifications[#self.Notifications + 1] = {
            message = message or "",
            title = title,
            created = tick(),
            duration = life,
            expires = tick() + life,
        }
    end
    function Window:SetVisible(state)
        self:_setOpen(state == true)
    end
    function Window:SetIconUrl(url)
        url = imageUrl(url)
        self.IconUrl = url
        self.IconReady = false
        self.IconData = nil
        if not url or url == "" then
            return nil
        end
        RequestImage(url, function(data)
            self.IconData = data
            self.IconReady = true
        end)
    end
    function Window:SetIconData(data)
        self.IconUrl = nil
        self.IconData = data
        self.IconReady = data ~= nil and data ~= ""
    end
    function Window:SetSidebarImage(url, scale, imgX, imgY)
        local resolved = url and imageUrl(url) or nil
        if not resolved or resolved == "" then
            self.SidebarImage = nil
            self.SidebarImageData = nil
            self.SidebarImageReady = false
            return
        end
        self.SidebarImage = resolved
        self.SidebarImageScale = scale or 1.0
        self.SidebarImageX = imgX
        self.SidebarImageY = imgY
        self.SidebarImageReady = false
        self.SidebarImageData = nil
        RequestImage(resolved, function(data)
            self.SidebarImageData = data
            
            local parsedW, parsedH
            if data and data:sub(2, 4) == "PNG" then
                parsedW = string.unpack(">I4", data:sub(17, 20))
                parsedH = string.unpack(">I4", data:sub(21, 24))
            end
            
            if parsedW and parsedH and parsedW > 0 and parsedH > 0 then
                self.SidebarImageNativeW = parsedW
                self.SidebarImageNativeH = parsedH
            else
                pcall(function()
                    local img = Drawing.new("Image")
                    img.Data = data
                    self.SidebarImageNativeW = img.Size.X
                    self.SidebarImageNativeH = img.Size.Y
                    img:Remove()
                end)
            end
            
            self.SidebarImageReady = true
        end)
    end
    function Window:SetNotifySide(side)
        side = tostring(side or "Right")
        self.NotifySide = side == "Left" and "Left" or "Right"
    end
    function Window:SetKeybindMenuVisible(state)
        self.ShowKeybindMenu = state == true
    end
    function Window:SetKeybindMenuPosition(x, y)
        self.KeybindMenuX = x
        self.KeybindMenuY = y
    end
    function Window:SetKeybindMenuWidth(width)
        self.KeybindMenuWidth = width
    end
    function Window:SetDPIScale(percent)
        percent = tonumber(percent) or 100
        percent = math.floor(clamp(percent, 50, 200) + 0.5)
        local oldSize = self.Size or self.LogicalSize or Vector2.new(820, 600)
        local center = Vector2.new(self.Position.X + oldSize.X / 2, self.Position.Y + oldSize.Y / 2)
        local oldScale = clamp((self.DPIScale or 100) / 100, 0.5, 2)
        local logical = self.LogicalSize
        if not logical then
            logical = Vector2.new(oldSize.X / oldScale, oldSize.Y / oldScale)
        end
        local scale = clamp(percent / 100, 0.5, 2)
        local newSize = Vector2.new(math.floor(logical.X * scale + 0.5), math.floor(logical.Y * scale + 0.5))

        self.DPIScale = percent
        self.LogicalSize = logical
        self.Size = newSize
        self.Position = Vector2.new(math.floor(center.X - newSize.X / 2 + 0.5), math.floor(center.Y - newSize.Y / 2 + 0.5))
        GalaxObsidian.DPIScale = percent
    end
    function Window:SetKeybindModePopup(config, modes)
        if type(config) == "boolean" and modes ~= nil then
            config = { Enabled = config, Modes = modes }
        end

        local enabled, resolvedModes = normalizeKeybindModePopupConfig(config, self.KeybindModePopupModes)
        self.KeybindModePopupEnabled = enabled
        self.KeybindModePopupModes = resolvedModes

        if not enabled then
            if self.KeybindModeTarget then
                self:_releaseInteraction(self.KeybindModeTarget)
            end
            self.KeybindModePopup = nil
            self.KeybindModeTarget = nil
        end
    end

    -- ---- Theming ----
    function Window:GetTheme()
        local copy = {}

        for key, value in pairs(Theme) do
            copy[key] = value
        end
        copy.Accent = self.Accent
        return copy
    end
    function Window:SetTheme(values)
        values = values or {}
        local background = themeColor(values.BackgroundColor)
        local main = themeColor(values.MainColor)
        local accent = themeColor(values.AccentColor)
        local outline = themeColor(values.OutlineColor)
        local outline2 = themeColor(values.Outline2)
        local surface2 = themeColor(values.Surface2)
        local muted = themeColor(values.Muted)
        local dimText = themeColor(values.DimText)
        local popupHover = themeColor(values.PopupHover)
        local font = themeColor(values.FontColor)
        local bottombar = themeColor(values.Bottombar)
        local bottombarBorder = themeColor(values.BottombarBorder)
        local footerText = themeColor(values.FooterText)
        local fontFace = values.FontFace
        if background then
            Theme.Background = background
            Theme.Topbar = background
            Theme.Sidebar = background
        end
        if main then
            Theme.Main = main
            Theme.Surface = main
        end
        if accent then
            Theme.Accent = accent
            self.Accent = accent
        end
        if outline then
            Theme.Outline = outline
            Theme.SoftOutline = outline
        end
        if outline2 then
            Theme.Outline2 = outline2
        end
        if surface2 then
            Theme.Surface2 = surface2
        end
        if muted then
            Theme.Muted = muted
        end
        if dimText then
            Theme.DimText = dimText
        end
        if popupHover then
            Theme.PopupHover = popupHover
        end
        if font then
            Theme.Text = font
        end
        if bottombar then
            Theme.Bottombar = bottombar
        end
        if bottombarBorder then
            Theme.BottombarBorder = bottombarBorder
        end
        if footerText then
            Theme.FooterText = footerText
        end
        if fontFace and FontMap[tostring(fontFace)] then
            Theme.Font = FontMap[tostring(fontFace)]
        end
    end

    -- ---- Destroy / Cleanup ----
    function Window:Destroy()
        self.Running = false
        self:_setOpen(false)
        for _, list in pairs(self.Pool) do
            for _, object in ipairs(list) do
                pcall(function()
                    object:Remove()
                end)
            end
        end
        for _, list in pairs(self.IconPool) do
            for _, object in ipairs(list) do
                pcall(function()
                    object:Remove()
                end)
            end
        end
        self.ImageDataByObject = {}
        self.IconPool = {}
        self.IconIndex = {}
    end

    -- ======================================================================
    -- TAB & SECTION BUILDERS
    -- ======================================================================
    -- ---- Tab Factory ----
    function Window:AddTab(name, icon)
        local tabName = name
        local tabIcon = icon
        if type(name) == "table" then
            tabName = name.Name or name.Title or name.Text
            tabIcon = name.Icon or name.IconName or tabIcon
        end
        local Tab = { Name = tabName or "Tab", Icon = tabIcon, Sections = {} }

        if not self.ActiveTab then
            self.ActiveTab = Tab
        end
        self.Tabs[#self.Tabs + 1] = Tab

        -- ---- Section Setup ----
        function Tab:AddSection(sectionName, side)
            if type(sectionName) == "table" then
                side = sectionName.Side or sectionName.side or side
                sectionName = sectionName.Name or sectionName.Text
            end
            local Section = { Name = sectionName or "Section", widgets = {}, side = side }
            self.Sections[#self.Sections + 1] = Section

            local function register(widget)
                if widget.visible == nil then
                    widget.visible = true
                end
                Section.widgets[#Section.widgets + 1] = widget
                return widget
            end
            local function infoArgs(label, info)
                if type(label) == "table" then
                    return label, label
                end
                if type(info) == "table" then
                    return label, info
                end
                return label, nil
            end

            -- ---- Label ----
            function Section:AddLabel(text, doesWrap, idx)
                local _, info = infoArgs(text)
                local id = idx or (info and (info.Index or info.Idx)) or text
                local widget = register({
                    type = "label",
                    id = id,
                    text = info and (info.Text or info.Label) or text or "",
                    tooltip = info and info.Tooltip,
                    visible = not (info and info.Visible == false),
                })
                local handle = Window:_widgetHandle(widget)
                return handle
            end

            -- ---- Button ----
            function Section:AddButton(label, callback)
                local _, info = infoArgs(label, callback)
                local widget = register({
                    type = "button",
                    label = info and (info.Text or info.Label) or label or "Button",
                    callback = info and (info.Callback or info.Func) or callback,
                    tooltip = info and info.Tooltip,
                    disabled = info and info.Disabled == true,
                    visible = not (info and info.Visible == false),
                })
                local handle = Window:_widgetHandle(widget)
                handle.AddButton = function(_, subInfo)
                    subInfo = type(subInfo) == "table" and subInfo or { Text = tostring(subInfo or "Sub button") }
                    widget.visible = false
                    local origCb = subInfo.Callback or subInfo.Func
                    local rightWidget = {
                        type = "button",
                        label = subInfo.Text or subInfo.Label or "Sub button",
                        callback = origCb,
                        tooltip = subInfo.Tooltip,
                        disabled = subInfo.Disabled == true,
                        visible = subInfo.Visible ~= false,
                        _doubleConfirm = true,
                        _confirmPending = false,
                    }
                    register({ type = "buttonpair", left = widget, right = rightWidget, visible = true })
                    return Window:_widgetHandle(rightWidget)
                end
                return handle
            end

            -- ---- Button Pair ----
            function Section:AddButtonPair(left, right)
                local _, leftInfo = infoArgs(left)
                local _, rightInfo = infoArgs(right)
                leftInfo = leftInfo or {}
                rightInfo = rightInfo or {}
                local leftWidget = {
                    type = "button",
                    label = leftInfo.Text or leftInfo.Label or tostring(left or "Button"),
                    callback = leftInfo.Callback or leftInfo.Func,
                    tooltip = leftInfo.Tooltip,
                    disabled = leftInfo.Disabled == true,
                    visible = leftInfo.Visible ~= false,
                }
                local rightWidget = {
                    type = "button",
                    label = rightInfo.Text or rightInfo.Label or tostring(right or "Sub button"),
                    callback = rightInfo.Callback or rightInfo.Func,
                    tooltip = rightInfo.Tooltip,
                    disabled = rightInfo.Disabled == true,
                    visible = rightInfo.Visible ~= false,
                    _doubleConfirm = true,
                    _confirmPending = false,
                }
                register({ type = "buttonpair", left = leftWidget, right = rightWidget, visible = true })
                return Window:_widgetHandle(leftWidget), Window:_widgetHandle(rightWidget)
            end

            -- ---- Tabbox ----
            function Section:AddTabbox(tabNames)
                local widget = register({ type = "sectiontabs", tabs = {}, active = 1, visible = true })
                local Tabbox = { Widget = widget, Tabs = widget.tabs }
                local function addChild(tab, child)
                    if child.visible == nil then
                        child.visible = true
                    end
                    tab.widgets[#tab.widgets + 1] = child
                    return child
                end
                local function attachTabApi(tab)
                    function tab:AddLabel(text)
                        local _, info = infoArgs(text)
                        local child = addChild(
                            tab,
                            {
                                type = "label",
                                text = info and (info.Text or info.Label) or text or "",
                                tooltip = info and info.Tooltip,
                                visible = not (info and info.Visible == false),
                            }
                        )
                        return Window:_widgetHandle(child)
                    end
                    function tab:AddButton(label, callback)
                        local _, info = infoArgs(label, callback)
                        local child = addChild(
                            tab,
                            {
                                type = "button",
                                label = info and (info.Text or info.Label) or label or "Button",
                                callback = info and (info.Callback or info.Func) or callback,
                                tooltip = info and info.Tooltip,
                                disabled = info and info.Disabled == true,
                                visible = not (info and info.Visible == false),
                            }
                        )
                        return Window:_widgetHandle(child)
                    end
                    function tab:AddToggle(label, default, callback, keybind)
                        local _, info = infoArgs(label, default)
                        local child = addChild(
                            tab,
                            {
                                type = "toggle",
                                label = info and (info.Text or info.Label) or label or "Toggle",
                                value = info and info.Default == true or default == true,
                                callback = info and info.Callback or callback,
                                changed = info and info.Changed or nil,
                                keybind = info and info.Keybind or keybind,
                                tooltip = info and info.Tooltip,
                                listening = false,
                                disabled = info and info.Disabled == true,
                                visible = not (info and info.Visible == false),
                            }
                        )
                        return Window:_widgetHandle(child, {
                            Get = function()
                                return child.value
                            end,
                            Set = function(_, value)
                                child.value = value == true
                                safeCall(child.callback, child.value)
                                safeCall(child.changed, child.value)
                            end,
                            SetValue = function(selfHandle, value)
                                return selfHandle:Set(value)
                            end,
                            SetKey = function(_, key)
                                child.keybind = key
                            end,
                        })
                    end
                    tab.AddCheckbox = tab.AddToggle
                    return tab
                end
                function Tabbox:AddTab(name)
                    local tab =
                        attachTabApi({ name = tostring(name or ("Tab " .. tostring(#widget.tabs + 1))), widgets = {} })
                    widget.tabs[#widget.tabs + 1] = tab
                    return tab
                end
                function Tabbox:GetTab(index)
                    return widget.tabs[index]
                end
                function Tabbox:SetActive(index)
                    if widget.tabs[index] then
                        widget.active = index
                    end
                end
                if type(tabNames) == "table" then
                    for _, name in ipairs(tabNames) do
                        Tabbox:AddTab(name)
                    end
                elseif type(tabNames) == "string" then
                    Tabbox:AddTab(tabNames)
                end
                return Tabbox
            end
            Section.AddTabs = Section.AddTabbox
            Section.AddSubButton = Section.AddButtonPair

            -- ---- Toggle ----
            function Section:AddToggle(label, default, callback, keybind)
                local _, info = infoArgs(label, default)
                local id = info and (info.Index or info.Idx) or label
                local widget = register({
                    type = "toggle",
                    id = id,
                    label = info and (info.Text or info.Label) or label or "Toggle",
                    value = info and info.Default == true or default == true,
                    callback = info and info.Callback or callback,
                    changed = info and info.Changed or nil,
                    keybind = info and info.Keybind or keybind,
                    tooltip = info and info.Tooltip,
                    disabledTooltip = info and info.DisabledTooltip,
                    listening = false,
                    disabled = info and info.Disabled == true,
                    visible = not (info and info.Visible == false),
                })
                local handle = Window:_widgetHandle(widget, {
                    Get = function()
                        return widget.value
                    end,
                    Set = function(_, value)
                        widget.value = value == true
                        safeCall(widget.callback, widget.value)
                        safeCall(widget.changed, widget.value)
                    end,
                    SetValue = function(_, value)
                        widget.value = value == true
                        safeCall(widget.callback, widget.value)
                        safeCall(widget.changed, widget.value)
                    end,
                    SetKey = function(_, key)
                        widget.keybind = key
                    end,
                    OnChanged = function(_, cb)
                        widget.changed = cb
                    end,
                })
                handle.AddColorPicker = function(_, name, info)
                    info = info or {}
                    widget.addons = widget.addons or {}
                    local default = info.Default or Color3.new(1, 1, 1)
                    local hue, sat, vib = rgbToHsv(default)
                    local addon = {
                        type = "colorpicker",
                        id = name,
                        label = info.Text or info.Label or info.Title or tostring(name or "Color"),
                        title = info.Title,
                        value = default,
                        hue = hue,
                        sat = sat,
                        vib = vib,
                        transparency = info.Transparency or 0,
                        transparencyEnabled = info.Transparency ~= nil,
                        callback = info.Callback,
                        changed = info.Changed,
                        tooltip = info.Tooltip,
                        disabled = info.Disabled == true,
                        visible = info.Visible ~= false,
                        popup = nil,
                    }
                    widget.addons[#widget.addons + 1] = addon
                    return Window:_widgetHandle(addon, {
                        Get = function()
                            return addon.value, addon.transparency
                        end,
                        SetValueRGB = function(_, color, transparency)
                            addon.value = color
                            addon.transparency = addon.transparencyEnabled and (transparency or 0) or 0
                            addon.hue, addon.sat, addon.vib = rgbToHsv(color)
                            safeCall(addon.callback, addon.value, addon.transparency)
                            safeCall(addon.changed, addon.value, addon.transparency)
                        end,
                    })
                end
                handle.AddKeyPicker = function(_, name, info)
                    info = info or {}
                    widget.addons = widget.addons or {}
                    local addon = {
                        type = "keybind",
                        id = name,
                        label = info.Text or info.Label or tostring(name or "Keybind"),
                        value = info.Default or 0,
                        mode = info.Mode or "Hold",
                        callback = info.Callback,
                        changed = info.Changed or info.ChangedCallback,
                        tooltip = info.Tooltip,
                        disabled = info.Disabled == true,
                        
                        waitForCallback = info.WaitForCallback == true,
                        visible = info.Visible ~= false,
                        _state = false,
                        _prevHeld = false,
                        popup = nil,
                        parent = widget,
                    }
                    if info.Popup ~= nil then
                        local enabled, modes = resolveKeybindPopupConfig(info.Popup)
                        addon.popupEnabled = enabled
                        addon.popupModes = modes
                    end
                    widget.addons[#widget.addons + 1] = addon
                    return Window:_widgetHandle(addon, {
                        Get = function()
                            return addon.value
                        end,
                        SetValue = function(_, val, mode)
                            if type(val) == "table" then
                                addon.value = val[1] or val.Key or val.key or addon.value
                                addon.mode = val[2] or val.Mode or val.mode or addon.mode
                                addon.modifiers = val.Modifiers or val.modifiers
                            else
                                addon.value = val
                                addon.mode = mode or addon.mode
                            end
                            safeCall(addon.changed, addon.value, addon.modifiers)
                        end,
                        OnChanged = function(_, cb)
                            addon.changed = cb
                        end,
                        OnClick = function(_, cb)
                            if addon.callback then
                                local old = addon.callback
                                addon.callback = function(v)
                                    old(v)
                                    cb(v)
                                end
                            else
                                addon.callback = cb
                            end
                        end,
                    })
                end
                return handle
            end

            -- ---- Checkbox ----
            function Section:AddCheckbox(label, default, callback, keybind)
                local _, info = infoArgs(label, default)
                local id = info and (info.Index or info.Idx) or label
                local widget = register({
                    type = "checkbox",
                    id = id,
                    label = info and (info.Text or info.Label) or label or "Checkbox",
                    value = info and info.Default == true or default == true,
                    callback = info and info.Callback or callback,
                    changed = info and info.Changed or nil,
                    keybind = info and info.Keybind or keybind,
                    tooltip = info and info.Tooltip,
                    disabledTooltip = info and info.DisabledTooltip,
                    listening = false,
                    disabled = info and info.Disabled == true,
                    visible = not (info and info.Visible == false),
                })
                local handle = Window:_widgetHandle(widget, {
                    Get = function()
                        return widget.value
                    end,
                    Set = function(_, value)
                        widget.value = value == true
                        safeCall(widget.callback, widget.value)
                        safeCall(widget.changed, widget.value)
                    end,
                    SetValue = function(_, value)
                        widget.value = value == true
                        safeCall(widget.callback, widget.value)
                        safeCall(widget.changed, widget.value)
                    end,
                    SetKey = function(_, key)
                        widget.keybind = key
                    end,
                    OnChanged = function(_, cb)
                        widget.changed = cb
                    end,
                })
                handle.AddColorPicker = function(_, name, info)
                    info = info or {}
                    widget.addons = widget.addons or {}
                    local default = info.Default or Color3.new(1, 1, 1)
                    local hue, sat, vib = rgbToHsv(default)
                    local addon = {
                        type = "colorpicker",
                        id = name,
                        label = info.Text or info.Label or info.Title or tostring(name or "Color"),
                        title = info.Title,
                        value = default,
                        hue = hue,
                        sat = sat,
                        vib = vib,
                        transparency = info.Transparency or 0,
                        transparencyEnabled = info.Transparency ~= nil,
                        callback = info.Callback,
                        changed = info.Changed,
                        tooltip = info.Tooltip,
                        disabled = info.Disabled == true,
                        visible = info.Visible ~= false,
                        popup = nil,
                    }
                    widget.addons[#widget.addons + 1] = addon
                    return Window:_widgetHandle(addon, {
                        Get = function()
                            return addon.value, addon.transparency
                        end,
                        SetValueRGB = function(_, color, transparency)
                            addon.value = color
                            addon.transparency = addon.transparencyEnabled and (transparency or 0) or 0
                            addon.hue, addon.sat, addon.vib = rgbToHsv(color)
                            safeCall(addon.callback, addon.value, addon.transparency)
                            safeCall(addon.changed, addon.value, addon.transparency)
                        end,
                    })
                end
                handle.AddKeyPicker = function(_, name, info)
                    info = info or {}
                    widget.addons = widget.addons or {}
                    local addon = {
                        type = "keybind",
                        id = name,
                        label = info.Text or info.Label or tostring(name or "Keybind"),
                        value = info.Default or 0,
                        mode = info.Mode or "Hold",
                        callback = info.Callback,
                        changed = info.Changed or info.ChangedCallback,
                        tooltip = info.Tooltip,
                        disabled = info.Disabled == true,
                        
                        waitForCallback = info.WaitForCallback == true,
                        visible = info.Visible ~= false,
                        _state = false,
                        _prevHeld = false,
                        popup = nil,
                        parent = widget,
                    }
                    if info.Popup ~= nil then
                        local enabled, modes = resolveKeybindPopupConfig(info.Popup)
                        addon.popupEnabled = enabled
                        addon.popupModes = modes
                    end
                    widget.addons[#widget.addons + 1] = addon
                    return Window:_widgetHandle(addon, {
                        Get = function()
                            return addon.value
                        end,
                        SetValue = function(_, val, mode)
                            if type(val) == "table" then
                                addon.value = val[1] or val.Key or val.key or addon.value
                                addon.mode = val[2] or val.Mode or val.mode or addon.mode
                                addon.modifiers = val.Modifiers or val.modifiers
                            else
                                addon.value = val
                                addon.mode = mode or addon.mode
                            end
                            safeCall(addon.changed, addon.value, addon.modifiers)
                        end,
                        OnChanged = function(_, cb)
                            addon.changed = cb
                        end,
                        OnClick = function(_, cb)
                            if addon.callback then
                                local old = addon.callback
                                addon.callback = function(v)
                                    old(v)
                                    cb(v)
                                end
                            else
                                addon.callback = cb
                            end
                        end,
                    })
                end
                return handle
            end

            -- ---- Slider ----
            function Section:AddSlider(label, config, callback)
                local _, info = infoArgs(label, config)
                if info then
                    config = info
                end
                config = config or {}
                local id = config.Index or config.Idx or label
                local minValue = config.Min or 0
                local maxValue = config.Max or 100
                local default = config.Default
                if default == nil then
                    default = minValue
                end
                local widget = register({
                    type = "slider",
                    id = id,
                    label = config.Text or config.Label or label or "Slider",
                    min = minValue,
                    max = maxValue,
                    value = clamp(default, minValue, maxValue),
                    prefix = config.Prefix or "",
                    suffix = config.Suffix or "",
                    round = config.Round == true or (config.Rounding or 0) == 0,
                    integer = config.Integer == true,
                    compact = config.Compact == true,
                    hideMax = config.HideMax == true,
                    formatDisplayValue = config.FormatDisplayValue,
                    callback = config.Callback or callback,
                    changed = config.Changed,
                    tooltip = config.Tooltip,
                    disabled = config.Disabled == true,
                    visible = config.Visible ~= false,
                })
                return Window:_widgetHandle(widget)
            end
            local function listPlayers(excludeLocal)
                local players = game:GetService("Players")
                local result = {}

                for _, p in ipairs(players:GetPlayers()) do
                    if not (excludeLocal and p == players.LocalPlayer) then
                        result[#result + 1] = p.Name
                    end
                end
                table.sort(result)
                return result
            end
            local function listTeams()
                local result = {}
                local svc = game:GetService("Teams")
                if svc then
                    for _, t in ipairs(svc:GetChildren()) do
                        if t:IsA("Team") then
                            result[#result + 1] = t.Name
                        end
                    end
                    table.sort(result)
                end
                return result
            end

            -- ---- Dropdown ----
            function Section:AddDropdown(label, optionsList, default, config, callback)
                local info = nil
                if type(label) == "table" then
                    info = label
                elseif
                    type(optionsList) == "table"
                    and (
                        optionsList.Values ~= nil
                        or optionsList.Options ~= nil
                        or optionsList.Text ~= nil
                        or optionsList.Label ~= nil
                        or optionsList.Default ~= nil
                        or optionsList.Multi ~= nil
                    )
                then
                    info = optionsList
                end
                if info then
                    optionsList = info.Values or info.Options or {}
                    default = info.Default
                    config = info
                    callback = info.Callback
                end
                if type(config) == "function" then
                    callback = config
                    config = {}
                end
                config = config or {}

                if config.SpecialType == "Player" then
                    local excludeLocal = config.ExcludeLocalPlayer == true
                    local refreshInterval = config.RefreshInterval or 2
                    optionsList = listPlayers(excludeLocal)
                    task.spawn(function()
                        while not GalaxObsidian.Unloaded do
                            task.wait(refreshInterval)
                            local newList = listPlayers(excludeLocal)
                            if widget then
                                widget.options = newList
                            end
                        end
                    end)
                elseif config.SpecialType == "Team" then
                    optionsList = listTeams()
                    task.spawn(function()
                        while not GalaxObsidian.Unloaded do
                            task.wait(5)
                            local newList = listTeams()
                            if widget then
                                widget.options = newList
                            end
                        end
                    end)
                end
                if config.Multi == true then
                    return Section:AddMultiDropdown(label, optionsList, default, config, callback)
                end
                optionsList = optionsList or {}
                local searchable = config.Searchable == true
                local id = config.Index or config.Idx or label
                if type(default) == "number" and optionsList[default] then
                    default = optionsList[default]
                end
                local widget = register({
                    type = "dropdown",
                    id = id,
                    label = config.Text or config.Label or label or "Dropdown",
                    options = optionsList,
                    value = default,
                    allowNull = config.AllowNull == true,
                    placeholder = config.Placeholder or "---",
                    maxVisible = config.MaxVisible or config.MaxVisibleDropdownItems or 6,
                    callback = callback,
                    changed = config.Changed,
                    tooltip = config.Tooltip,
                    disabledTooltip = config.DisabledTooltip,
                    disabled = config.Disabled == true,
                    disabledValues = config.DisabledValues or {},
                    searchable = searchable,
                    _searchText = searchable and "" or nil,
                    specialType = config.SpecialType,
                    formatDisplayValue = config.FormatDisplayValue,
                    visible = config.Visible ~= false,
                    popup = nil,
                })
                return Window:_widgetHandle(widget)
            end

            -- ---- Multi Dropdown ----
            function Section:AddMultiDropdown(label, optionsList, default, config, callback)
                local info = nil
                if type(label) == "table" then
                    info = label
                elseif
                    type(optionsList) == "table"
                    and (
                        optionsList.Values ~= nil
                        or optionsList.Options ~= nil
                        or optionsList.Text ~= nil
                        or optionsList.Label ~= nil
                        or optionsList.Default ~= nil
                        or optionsList.Multi ~= nil
                    )
                then
                    info = optionsList
                end
                if info then
                    optionsList = info.Values or info.Options or {}
                    default = info.Default
                    config = info
                    callback = info.Callback
                end
                if type(config) == "function" then
                    callback = config
                    config = {}
                end
                config = config or {}
                optionsList = optionsList or {}
                local selected = {}

                if default then
                    if type(default) == "table" then
                        for _, value in ipairs(default) do
                            selected[value] = true
                        end
                    else
                        selected[default] = true
                    end
                end
                local searchable = config.Searchable == true
                local id = config.Index or config.Idx or label
                local widget = register({
                    type = "multidropdown",
                    id = id,
                    label = config.Text or config.Label or label or "MultiDropdown",
                    options = optionsList,
                    selected = selected,
                    min = config.Min or 1,
                    max = config.Max or math.huge,
                    maxVisible = config.MaxVisible or config.MaxVisibleDropdownItems or 6,
                    callback = callback,
                    changed = config.Changed,
                    tooltip = config.Tooltip,
                    disabled = config.Disabled == true,
                    disabledValues = config.DisabledValues or {},
                    searchable = searchable,
                    _searchText = searchable and "" or nil,
                    formatDisplayValue = config.FormatDisplayValue,
                    visible = config.Visible ~= false,
                    popup = nil,
                })
                return Window:_widgetHandle(widget)
            end

            -- ---- Keybind ----
            function Section:AddKeybind(label, default, callback)
                local _, info = infoArgs(label, default)
                local id = info and (info.Index or info.Idx) or label
                local widget = register({
                    type = "keybind",
                    id = id,
                    label = info and (info.Text or info.Label) or label or "Keybind",
                    value = info and (info.Default or "None") or default or 0,
                    mode = info and (info.Mode or info.ModeName) or "Hold",
                    callback = info and (info.Callback or info.Clicked) or callback,
                    changed = info and (info.Changed or info.ChangedCallback) or nil,
                    tooltip = info and info.Tooltip,
                    listening = false,
                    disabled = info and info.Disabled == true,
                    waitForCallback = info and info.WaitForCallback == true,
                    visible = not (info and info.Visible == false),
                    _state = false,
                    _prevHeld = false,
                })
                if info and info.Popup ~= nil then
                    local enabled, modes = resolveKeybindPopupConfig(info.Popup)
                    widget.popupEnabled = enabled
                    widget.popupModes = modes
                end
                return Window:_widgetHandle(widget, {
                    Get = function()
                        return widget.value
                    end,
                    Set = function(_, value)
                        if type(value) == "table" then
                            widget.value = value[1] or value.Key or value.key or widget.value
                            widget.mode = value[2] or value.Mode or value.mode or widget.mode
                            widget.modifiers = value.Modifiers or value.modifiers
                        else
                            widget.value = value
                        end
                        safeCall(widget.changed, widget.value, widget.modifiers)
                    end,
                    SetValue = function(selfHandle, value)
                        return selfHandle:Set(value)
                    end,
                    OnClick = function(_, cb)
                        widget.callback = cb
                    end,
                })
            end

            -- ---- Color Picker ----
            function Section:AddColorPicker(label, info)
                local _, config = infoArgs(label, info)
                config = config or {}
                local id = config.Index or config.Idx or label
                local default = config.Default or Color3.new(1, 1, 1)
                local hue, sat, vib = rgbToHsv(default)
                local widget = register({
                    type = "colorpicker",
                    id = id,
                    label = config.Text or config.Label or label or "ColorPicker",
                    title = config.Title,
                    value = default,
                    hue = hue,
                    sat = sat,
                    vib = vib,
                    transparency = config.Transparency or 0,
                    transparencyEnabled = config.Transparency ~= nil,
                    callback = config.Callback,
                    changed = config.Changed,
                    tooltip = config.Tooltip,
                    disabled = config.Disabled == true,
                    visible = config.Visible ~= false,
                    popup = nil,
                })
                local handle = Window:_widgetHandle(widget, {
                    Get = function()
                        return widget.value, widget.transparency
                    end,
                    SetHSVFromRGB = function(_, color)
                        widget.hue, widget.sat, widget.vib = rgbToHsv(color)
                    end,
                    SetValue = function(selfHandle, hsv, transparency)
                        if typeof(hsv) == "Color3" then
                            return selfHandle:SetValueRGB(hsv, transparency)
                        end
                        local color = Color3.fromHSV(hsv[1] or 0, hsv[2] or 0, hsv[3] or 0)
                        widget.value = color
                        widget.transparency = widget.transparencyEnabled and (transparency or 0) or 0
                        widget.hue, widget.sat, widget.vib = rgbToHsv(color)
                        safeCall(widget.callback, widget.value, widget.transparency)
                        safeCall(widget.changed, widget.value, widget.transparency)
                    end,
                    SetValueRGB = function(_, color, transparency)
                        widget.value = color
                        widget.transparency = widget.transparencyEnabled and (transparency or 0) or 0
                        widget.hue, widget.sat, widget.vib = rgbToHsv(color)
                        safeCall(widget.callback, widget.value, widget.transparency)
                        safeCall(widget.changed, widget.value, widget.transparency)
                    end,
                })
                return handle
            end

            -- ---- Color Picker Pair ----
            function Section:AddColorPickerPair(leftLabel, leftInfo, rightLabel, rightInfo)
                local function makeWidget(labelValue, infoValue)
                    local _, config = infoArgs(labelValue, infoValue)
                    config = config or {}
                    local default = config.Default or Color3.new(1, 1, 1)
                    local hue, sat, vib = rgbToHsv(default)
                    return {
                        type = "colorpicker",
                        label = config.Text or config.Label or labelValue or "ColorPicker",
                        title = config.Title,
                        value = default,
                        hue = hue,
                        sat = sat,
                        vib = vib,
                        transparency = config.Transparency or 0,
                        transparencyEnabled = config.Transparency ~= nil,
                        callback = config.Callback,
                        changed = config.Changed,
                        tooltip = config.Tooltip,
                        disabled = config.Disabled == true,
                        visible = config.Visible ~= false,
                        popup = nil,
                    }
                end
                local leftWidget = makeWidget(leftLabel, leftInfo)
                local rightWidget = makeWidget(rightLabel, rightInfo)
                register({ type = "colorpair", left = leftWidget, right = rightWidget, visible = true })

                local function makeHandle(widget)
                    return Window:_widgetHandle(widget, {
                        Get = function()
                            return widget.value, widget.transparency
                        end,
                        SetHSVFromRGB = function(_, color)
                            widget.hue, widget.sat, widget.vib = rgbToHsv(color)
                        end,
                        SetValue = function(selfHandle, hsv, transparency)
                            if typeof(hsv) == "Color3" then
                                return selfHandle:SetValueRGB(hsv, transparency)
                            end
                            local color = Color3.fromHSV(hsv[1] or 0, hsv[2] or 0, hsv[3] or 0)
                            widget.value = color
                            widget.transparency = widget.transparencyEnabled and (transparency or 0) or 0
                            widget.hue, widget.sat, widget.vib = rgbToHsv(color)
                            safeCall(widget.callback, widget.value, widget.transparency)
                            safeCall(widget.changed, widget.value, widget.transparency)
                        end,
                        SetValueRGB = function(_, color, transparency)
                            widget.value = color
                            widget.transparency = widget.transparencyEnabled and (transparency or 0) or 0
                            widget.hue, widget.sat, widget.vib = rgbToHsv(color)
                            safeCall(widget.callback, widget.value, widget.transparency)
                            safeCall(widget.changed, widget.value, widget.transparency)
                        end,
                    })
                end
                return makeHandle(leftWidget), makeHandle(rightWidget)
            end

            -- ---- Textbox ----
            function Section:AddTextbox(label, default, callback, placeholder)
                local _, info = infoArgs(label, default)
                local id = info and (info.Index or info.Idx) or label
                local widget = register({
                    type = "textbox",
                    id = id,
                    label = info and (info.Text or info.Label) or label or "Textbox",
                    value = info and tostring(info.Default or "") or (default ~= nil and tostring(default) or ""),
                    callback = info and info.Callback or callback,
                    changed = info and info.Changed or nil,
                    tooltip = info and info.Tooltip,
                    placeholder = info and (info.Placeholder or "") or placeholder or "...",
                    numeric = info and info.Numeric == true,
                    finished = info and info.Finished == true,
                    clearTextOnFocus = info and info.ClearTextOnFocus ~= false,
                    disabled = info and info.Disabled == true,
                    visible = not (info and info.Visible == false),
                })
                return Window:_widgetHandle(widget)
            end

            -- ---- Aliases & Divider ----
            Section.AddInput = Section.AddTextbox
            Section.AddKeyPicker = Section.AddKeybind
            Section.AddDivider = function()
                return Window:_widgetHandle(register({ type = "divider", visible = true }))
            end
            return Section
        end

        -- ---- Groupbox & Tabbox Aliases ----
        Tab.AddGroupbox = Tab.AddSection
        function Tab:AddLeftGroupbox(name)
            return Tab:AddSection(name, "Left")
        end
        function Tab:AddRightGroupbox(name)
            return Tab:AddSection(name, "Right")
        end
        function Tab:AddLeftTabbox()
            local section = Tab:AddSection("__tabbox", "Left")
            return section:AddTabbox()
        end
        function Tab:AddRightTabbox()
            local section = Tab:AddSection("__tabbox", "Right")
            return section:AddTabbox()
        end

        -- ---- Key Box Widget ----
        function Tab:AddKeyBox(callback)
            local section = Tab.Sections[1] or Tab:AddSection("__keytab", "Left")
            section.keyTab = true
            local widget = {
                type = "keybox",
                value = "",
                placeholder = "Key",
                executeCallback = callback,
                visible = true,
            }
            section.widgets[#section.widgets + 1] = widget
            return Window:_widgetHandle(widget, {
                Get = function()
                    return widget.value
                end,
                Set = function(_, value)
                    widget.value = tostring(value or "")
                end,
                SetValue = function(selfHandle, value)
                    return selfHandle:Set(value)
                end,
            })
        end
        return Tab
    end

    -- ======================================================================
    -- KEY TAB SYSTEM
    -- ======================================================================
    function Window:AddKeyTab(name, icon)
        local tab = self:AddTab(name or "Key System", icon or "key")
        tab.IsKeyTab = true
        local section = tab:AddSection("__keytab", "Left")
        section.keyTab = true
        function tab:AddLabel(text)
            local info = type(text) == "table" and text or nil
            local widget = {
                type = "label",
                text = info and (info.Text or info.Label) or tostring(text or ""),
                tooltip = info and info.Tooltip,
                visible = not (info and info.Visible == false),
            }
            section.widgets[#section.widgets + 1] = widget
            return Window:_widgetHandle(widget)
        end
        return tab
    end

    -- ======================================================================
    -- RENDER LOOP STARTUP
    -- ======================================================================
    task.spawn(function()
        while Window.Running do
            task.wait(0.01)
            if isrbxactive() then
                Window:_updateInput()
                Window:_render()
                Window:_handleGlobalInput()
                Window:_updateInputBlock()
            else
                Window:_setAllVisible(false)
                Window:_updateInputBlock()
            end
        end
    end)
    return Window
end

-- ======================================================================
-- MODULE-LEVEL UTILITIES
-- ======================================================================
local function keysOf(map)
    local list = {}

    for key in pairs(map) do
        list[#list + 1] = key
    end
    table.sort(list)
    return list
end
local function colorToHexStr(color)
    local r, g, b = colorComponents(color)
    return string.format(
        "%02X%02X%02X",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5)
    )
end

-- ======================================================================
-- LIBRARY PUBLIC API — GLOBAL TOGGLE & NOTIFY
-- ======================================================================
function GalaxObsidian:Toggle(state)
    if not self.ActiveWindow then
        return nil
    end
    if state == nil then
        self.ActiveWindow:SetVisible(not self.ActiveWindow.Open)
    else
        self.ActiveWindow:SetVisible(state == true)
    end
end
function GalaxObsidian:Notify(message, title, duration)
    if not self.ActiveWindow then
        return nil
    end
    return self.ActiveWindow:Notify(message, title, duration)
end
_G.Galax = _G.Galax or {}
_G.Galax["Library.lua"] = GalaxObsidian

return GalaxObsidian
