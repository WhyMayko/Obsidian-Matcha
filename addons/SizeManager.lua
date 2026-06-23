local SizeManager = {}

SizeManager.Version = "1.0.0"

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

SizeManager.TextManager = nil

SizeManager.SidebarWidths = {
    MinLogical    = 400,
    IconLevel     = 48,
    CompactLevel  = 140,
    FullMin       = 128,
    FullMax       = 200,
    FullFraction  = 0.26,
}

SizeManager.ColumnConfig = {
    MinLogicalWidth = 300,
    PaddingX = 10,
    ColumnGap = 18,
}

function SizeManager:SetTextManager(tm)
    self.TextManager = tm
end

function SizeManager:GetSidebarMode(window, logicalW, scale)
    local compactSidebarW = math.floor(self.SidebarWidths.CompactLevel * scale)
    local textArea = compactSidebarW - math.floor(42 * scale)

    if textArea < 50 then
        return "icon"
    end

    local TM = self.TextManager
    if TM and window.Tabs and #window.Tabs > 0 then
        local maxTextW = 0
        for _, tab in ipairs(window.Tabs) do
            local w = TM:Measure(tab.Name or "", 16, Drawing.Fonts.Monospace, scale)
            if w and w > maxTextW then
                maxTextW = w
            end
        end
        if maxTextW > textArea - 10 then
            return "icon"
        end
    end

    if logicalW <= self.SidebarWidths.MinLogical then
        return "icon"
    end

    return "compact"
end

function SizeManager:GetWindowState(window)
    local scale = window:GetScale()
    local physicalW = window.Size.X
    local logicalW = physicalW / scale
    local mode = self:GetSidebarMode(window, logicalW, scale)
    local sidebarW

    if mode == "icon" then
        sidebarW = math.floor(self.SidebarWidths.IconLevel * scale)
    else
        sidebarW = math.ceil(physicalW * self.SidebarWidths.FullFraction)
        local minW = math.floor(self.SidebarWidths.FullMin * scale)
        local maxW = math.floor(self.SidebarWidths.FullMax * scale)
        sidebarW = clamp(sidebarW, minW, maxW)
    end

    local contentW = (physicalW - sidebarW) / scale
    local colConfig = self.ColumnConfig
    local usableContent = contentW - colConfig.PaddingX * 2
    local perColumn = (usableContent - colConfig.ColumnGap) / 2
    local twoColumns = perColumn >= colConfig.MinLogicalWidth

    return {
        SidebarMode  = mode,
        SidebarWidth = sidebarW,
        UseTwoColumns = twoColumns,
        LogicalWidth = logicalW,
        Scale = scale,
    }
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/SizeManager.lua"] = SizeManager

return SizeManager
