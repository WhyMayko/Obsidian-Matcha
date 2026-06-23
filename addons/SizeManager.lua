local SizeManager = {}

SizeManager.Version = "1.0.0"

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

SizeManager.TextManager = nil

SizeManager.SidebarWidths = {
    MinLogical    = 300,
    IconLevel     = 48,
    FullMin       = 128,
    FullMax       = 200,
    FullFraction  = 0.26,
}

SizeManager.ColumnConfig = {
    MinLogicalWidth = 260,
    MinContentWidth = 490,
    PaddingX = 10,
    ColumnGap = 18,
}

function SizeManager:SetTextManager(tm)
    self.TextManager = tm
end

function SizeManager:GetWindowState(window)
    local scale = window:GetScale()
    local physicalW = window.Size.X
    local logicalW = physicalW / scale

    local iconSidebarW = math.floor(self.SidebarWidths.IconLevel * scale)
    local maxSidebarW = math.floor(self.SidebarWidths.FullMax * scale)
    local textOffset = math.floor(42 * scale)
    local minContentPhysical = math.floor(self.ColumnConfig.MinContentWidth * scale)

    local TM = self.TextManager
    local neededTextArea = 0
    if TM and window.Tabs then
        local maxTextW = 0
        for _, tab in ipairs(window.Tabs) do
            local name = tab.Name or ""
            if name ~= "" then
                local w = TM:Measure(name, 16, Drawing.Fonts.Monospace, scale)
                if w and w > maxTextW then
                    maxTextW = w
                end
            end
        end
        neededTextArea = maxTextW + 10
    end

    local minWidthForText = neededTextArea + textOffset
    local canFitText = neededTextArea == 0 or minWidthForText <= maxSidebarW

    local mode, sidebarW

    if logicalW <= self.SidebarWidths.MinLogical or not canFitText then
        mode = "icon"
        sidebarW = iconSidebarW
    else
        local maxSidebarForContent = math.max(iconSidebarW, physicalW - minContentPhysical)
        local ideal = math.ceil(physicalW * self.SidebarWidths.FullFraction)
        sidebarW = clamp(ideal, math.max(iconSidebarW, minWidthForText), math.min(maxSidebarW, maxSidebarForContent))

        if sidebarW < minWidthForText then
            mode = "icon"
            sidebarW = iconSidebarW
        else
            mode = "compact"
        end
    end

    local contentW = (physicalW - sidebarW) / scale
    local usableContent = contentW - self.ColumnConfig.PaddingX * 2
    local perColumn = (usableContent - self.ColumnConfig.ColumnGap) / 2
    local twoColumns = perColumn >= self.ColumnConfig.MinLogicalWidth
    if mode == "icon" then
        twoColumns = false
    end

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
