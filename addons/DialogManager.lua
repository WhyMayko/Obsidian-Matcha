local DialogManager = {}

function DialogManager:SetLibrary(library)
	self.Library = library
	self.TextManager = library and library.TextManager
end

function DialogManager:Dialog(options)
	options = options or {}
	local Library = self.Library
	local win = Library and Library.ActiveWindow
	if not win then
		return nil
	end

	local dialog = {
		title = options.Title or options.title or "Dialog",
		message = options.Description or options.Message or options.message or "",
		buttons = options.Buttons or options.buttons or {},
		width = options.Width or options.width or 320,
		closable = options.Closable ~= false,
		closed = false,
		onClose = options.OnClose or options.onClose,
		z = 200,
	}

	if #dialog.buttons == 0 then
		dialog.buttons = { { Text = "OK", Callback = function() end, Primary = true } }
	end

	win.Dialogs = win.Dialogs or {}
	win.Dialogs[#win.Dialogs + 1] = dialog

	function dialog:Destroy()
		self.closed = true
	end

	function dialog:SetTitle(text)
		self.title = text or ""
	end

	function dialog:SetMessage(text)
		self.message = text or ""
	end

	return dialog
end

function DialogManager:RenderDialogs(window)
	if not window.Dialogs or #window.Dialogs == 0 then
		return nil
	end

	local scale = window:GetScale()
	local vp = workspace.CurrentCamera.ViewportSize
	local z = 200
	local TM = self.TextManager

	for i = #window.Dialogs, 1, -1 do
		local dialog = window.Dialogs[i]
		if dialog.closed then
			if dialog.onClose then
				local ok, err = pcall(dialog.onClose)
				if not ok then error("DialogManager onClose: " .. tostring(err), 2) end
			end
			table.remove(window.Dialogs, i)
		end
	end

	for _, dialog in ipairs(window.Dialogs) do
		local dw = math.floor(dialog.width * scale)
		local dh = math.floor(math.max(120, 80 + #dialog.buttons * 10) * scale)
		local dx = math.floor((vp.X - dw) / 2)
		local dy = math.floor((vp.Y - dh) / 2)

		window:_square(0, 0, vp.X, vp.Y, Color3.new(0, 0, 0), true, 0.6, 0, z)
		window:_square(dx, dy, dw, dh, Color3.new(0.07, 0.07, 0.12), true, 1, 8, z + 1)
		window:_square(dx, dy, dw, dh, Color3.new(0.2, 0.2, 0.3), false, 1, 8, z + 2)

		local pad = math.floor(12 * scale)
		local titleY = dy + pad
		window:_text(
			TM:Fit(dialog.title, dw - pad * 2, 16, window.Theme.Font),
			dx + pad, titleY,
			window.Theme.Text, 16,
			Drawing.Fonts.Monospace, false, false, z + 3
		)

		window:_line(dx + pad, titleY + math.floor(22 * scale), dx + dw - pad, titleY + math.floor(22 * scale), window.Theme.Outline, 1, z + 3)

		local msgY = titleY + math.floor(30 * scale)
		local msg = TM:Fit(dialog.message, dw - pad * 2, 12, window.Theme.Font)
		window:_text(msg, dx + pad, msgY, window.Theme.Muted, 12, Drawing.Fonts.Monospace, false, false, z + 3)

		local btnY = dy + dh - math.floor(36 * scale)
		local btnGap = math.floor(8 * scale)
		local btnH = math.floor(28 * scale)
		local btnWidths = {}
		local totalBtnW = 0

		for i, btn in ipairs(dialog.buttons) do
			local bw = math.max(math.floor(60 * scale), math.floor(TM:Measure(btn.Text or "OK", 13, window.Theme.Font) + math.floor(24 * scale)))
			btnWidths[i] = bw
			totalBtnW = totalBtnW + bw + (i > 1 and btnGap or 0)
		end

		local btnStartX = dx + math.floor((dw - totalBtnW) / 2)
		for i, btn in ipairs(dialog.buttons) do
			local bx = btnStartX
			for j = 1, i - 1 do
				bx = bx + btnWidths[j] + btnGap
			end
			local bw = btnWidths[i]
			local primary = btn.Primary == true
			local btnColor = primary and window.Theme.Accent or window.Theme.Main2
			local hovered = window:_over(bx, btnY, bw, btnH)
			if hovered then
				btnColor = primary and window.Theme.Accent or window.Theme.Main3
			end

			window:_square(bx, btnY, bw, btnH, btnColor, true, 1, 5, z + 4)
			window:_square(bx, btnY, bw, btnH, window.Theme.Outline, false, 1, 5, z + 5)
			window:_text(
				TM:Fit(btn.Text or "OK", bw - math.floor(12 * scale), 13, window.Theme.Font),
				bx + math.floor(bw / 2), btnY + math.floor(6 * scale),
				primary and Color3.new(1, 1, 1) or window.Theme.Text,
				13, Drawing.Fonts.Monospace, true, false, z + 6
			)

			if hovered and window:_focusClick(bx, btnY, bw, btnH, dialog) then
				if btn.Callback then
					local ok, err = pcall(btn.Callback, dialog)
					if not ok then error("DialogManager btn.Callback: " .. tostring(err), 2) end
				end
				if btn.Close ~= false then
					dialog:Destroy()
				end
				window.Mouse1Clicked = false
			end
		end
	end
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/DialogManager.lua"] = DialogManager

return DialogManager
