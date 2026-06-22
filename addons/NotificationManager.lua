local NotificationManager = {}

local slideTime = 0.3

function NotificationManager:SetLibrary(library)
	self.Library = library
	self.TextManager = library and library.TextManager
end

function NotificationManager:Notify(message, title, duration)
	local Library = self.Library
	local win = Library and Library.ActiveWindow
	if not win then
		return nil
	end

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
	local notif = {
		message = message or "",
		title = title,
		created = tick(),
		duration = life,
		expires = tick() + life,
		onClick = nil,
		onDismiss = nil,
		closed = false,
	}

	notif.destroy = function()
		notif.closed = true
	end

	notif.setTitle = function(text)
		notif.title = text or ""
	end

	notif.setMessage = function(text)
		notif.message = text or ""
	end

	notif.onClick = function(cb)
		notif._onClick = cb
		return notif
	end

	notif.onDismiss = function(cb)
		notif._onDismiss = cb
		return notif
	end

	win.Notifications = win.Notifications or {}
	win.Notifications[#win.Notifications + 1] = notif
	return notif
end

function NotificationManager:Progress(title, message, duration)
	local notif = self:Notify(title, message, duration or 5)
	if not notif then
		return nil
	end
	notif.progress = 0
	notif.setProgress = function(value)
		notif.progress = clamp(value, 0, 1)
	end
	return notif
end

function NotificationManager:RenderNotifications(window)
	if not window.Notifications or #window.Notifications == 0 then
		return nil
	end

	local TM = self.TextManager
	local scale = window:GetScale()
	local now = tick()
	local vp = workspace.CurrentCamera.ViewportSize
	local margin = math.floor(10 * scale)
	local startY = margin
	local stackY = 0
	local notifW = math.floor(280 * scale)
	local side = window.NotifySide or "Right"

	for i = #window.Notifications, 1, -1 do
		local notif = window.Notifications[i]
		if notif.closed or now >= notif.expires + slideTime then
			if notif.closed and notif._onDismiss then
				pcall(notif._onDismiss)
			end
			table.remove(window.Notifications, i)
		end
	end

	for i, notif in ipairs(window.Notifications) do
		local textSize = 11
		local pad = math.floor(10 * scale)
		local lineH = math.floor(15 * scale)
		local fullText = notif.title and notif.title ~= "" and (notif.title .. "\n" .. notif.message)
			or notif.message
		local msgWidth = notifW - pad * 2
		local lines = {}
		local maxLines = 6

		local function pushLine(line)
			if #lines >= maxLines then return end
			lines[#lines + 1] = line
		end

		for rawLine in (fullText .. "\n"):gmatch("(.-)\n") do
			if rawLine == "" then
				pushLine("")
			else
				local current = ""
				for word in rawLine:gmatch("%S+") do
					local nextLine = current == "" and word or (current .. " " .. word)
					if TM:Measure(nextLine, textSize, window.Theme.Font) <= msgWidth then
						current = nextLine
					else
						if current ~= "" then
							pushLine(current)
							current = word
						else
							pushLine(word)
							current = ""
						end
					end
				end
				if current ~= "" and #lines < maxLines then
					pushLine(current)
				end
			end
		end

		local widestW = 0
		for _, line in ipairs(lines) do
			local lw = TM:Measure(line, textSize, window.Theme.Font)
			if lw > widestW then
				widestW = lw
			end
		end
		local currentNotifW = math.max(math.floor(60 * scale), math.min(notifW, math.floor(widestW + pad * 2 + math.floor(10 * scale))))
		local notifH = pad * 2 + (#lines * lineH) + math.floor(7 * scale)

		local finalX = side == "Left" and margin or (vp.X - currentNotifW - margin)
		local hiddenX = side == "Left" and (-currentNotifW - math.floor(8 * scale)) or (vp.X + math.floor(8 * scale))
		local enter = clamp((now - notif.created) / slideTime, 0, 1)
		local leave = now > notif.expires and (1 - clamp((now - notif.expires) / slideTime, 0, 1)) or 1
		local slide = math.min(enter, leave)
		slide = 1 - ((1 - slide) * (1 - slide))
		local x = hiddenX + (finalX - hiddenX) * slide
		local y = startY + stackY
		local remaining = clamp((notif.expires - now) / notif.duration, 0, 1)

		local over = window:_over(x, y, currentNotifW, notifH)
		if over and window.Mouse1Clicked then
			if notif._onClick then
				pcall(notif._onClick)
			end
		end

		window:_square(x, y, currentNotifW, notifH, window.Theme.Background, true, 1, 7, 140)
		window:_square(x, y, currentNotifW, notifH, window.Theme.SoftOutline, false, 1, 7, 141)
		for lineIndex, line in ipairs(lines) do
			window:_text(
				line,
				x + pad,
				y + pad + (lineIndex - 1) * lineH,
				lineIndex == 1 and window.Theme.Text or window.Theme.Muted,
				textSize,
				Drawing.Fonts.Monospace,
				false,
				false,
				143
			)
		end
		window:_square(x + math.floor(8 * scale), y + notifH - math.floor(6 * scale), currentNotifW - math.floor(16 * scale), math.floor(2 * scale), window.Theme.Main, true, 1, 1, 142)
		window:_square(x + math.floor(8 * scale), y + notifH - math.floor(6 * scale), (currentNotifW - math.floor(16 * scale)) * remaining, math.floor(2 * scale), window.Accent, true, 1, 1, 144)
		stackY = stackY + notifH + math.floor(10 * scale)
	end
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/NotificationManager.lua"] = NotificationManager

return NotificationManager
