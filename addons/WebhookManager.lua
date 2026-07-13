local WebhookManager = {
	Library = nil,
	Webhooks = {},
	Templates = {},
	DefaultWebhook = { Name = "GalaxHub", Url = "https://galax-team.vercel.app/Webhook" },
	AutoloadWebhook = nil,
	ProxyUrl = "https://galax-team.vercel.app/Webhook",
}

local HttpService = game:GetService("HttpService")
local SettingsFolder = "Galax/Obsidian/Settings"
local WebhookFolder = SettingsFolder .. "/Webhooks"
local DefaultWebhookFile = SettingsFolder .. "/DefaultWebhook.txt"

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
	return tostring(name or "Webhook"):gsub("[^%w%s_%-]", "_") .. ".txt"
end

local function writeTable(path, data)
	local folder = tostring(path):match("^(.*)[/\\][^/\\]+$")
	ensureFolder(folder or SettingsFolder)

	local encoded
	local ok, _ = pcall(function()
		local parts = {}
		for k, v in pairs(data) do
			table.insert(parts, string.format('\t%q: %s', tostring(k), HttpService:JSONEncode(v)))
		end
		table.sort(parts)
		encoded = "{\n" .. table.concat(parts, ",\n") .. "\n}"
	end)
	if not encoded then
		encoded = HttpService:JSONEncode(data)
	end
	writefile(path, encoded)
	return true
end

local function readTable(path)
	if not isfile(path) then
		return nil
	end

	local source = readfile(path)
	if type(source) ~= "string" then
		error("WebhookManager readTable: file read failed for " .. path, 2)
	end

	local ok, data = pcall(function() return HttpService:JSONDecode(source) end)
	if not ok then
		error("WebhookManager readTable: failed to decode JSON from " .. path, 2)
	end

	if type(data) == "table" then
		return data
	end

	error("WebhookManager readTable: decoded JSON is not a table for " .. path, 2)
end

local function deepCopy(t)
	if type(t) ~= "table" then return t end
	local r = {}
	for k, v in pairs(t) do
		r[k] = deepCopy(v)
	end
	return r
end

local function compilePlaceholders(str, vars)
	if type(str) ~= "string" then return str end
	return str:gsub("%{(%w+)%}", function(key)
		local v = vars[key]
		if v ~= nil then return tostring(v) end
		return "{" .. key .. "}"
	end)
end

local function compileTable(t, vars)
	if type(t) ~= "table" then return compilePlaceholders(t, vars) end
	local r = {}
	for k, v in pairs(t) do
		r[k] = compileTable(v, vars)
	end
	return r
end

function WebhookManager:SetLibrary(library)
	self.Library = library
end

function WebhookManager:Add(name, url)
	if not name or not url then
		return false, "name and url required"
	end
	self.Webhooks[name] = { Name = name, Url = url }

	local path = WebhookFolder .. "/" .. fileName(name)
	local ok, err = writeTable(path, { Name = name, Url = url })
	if not ok then
		self.Webhooks[name] = nil
		return false, err
	end

	return true
end

function WebhookManager:AddTemplate(name, template)
	if not name or not template then
		return false, "name and template required"
	end
	self.Templates[name] = deepCopy(template)
	return true
end

function WebhookManager:GetTemplate(name)
	return self.Templates[name]
end

function WebhookManager:GetCurrent()
	if self.AutoloadWebhook then
		local name = self.AutoloadWebhook.Name
		local data = self.Webhooks[name]
		if data then
			return data
		end
	end
	return self.DefaultWebhook
end

function WebhookManager:Compile(templateName, variables)
	local template = self.Templates[templateName]
	if not template then
		return nil, "template not found: " .. tostring(templateName)
	end

	local payload = compileTable(template, variables or {})

	if payload.Embeds then
		for i, embed in ipairs(payload.Embeds) do
			if type(embed) == "table" then
				if embed.Footer and type(embed.Footer) == "table" then
					embed.Footer.Text = compilePlaceholders(embed.Footer.Text, variables or {})
				end
				if embed.Author and type(embed.Author) == "table" then
					embed.Author.Name = compilePlaceholders(embed.Author.Name, variables or {})
				end
			end
		end
	end

	return payload
end

function WebhookManager:SendPayload(url, payload)
	if not url or url == "" then
		return false, "no webhook url"
	end

	local body = HttpService:JSONEncode(payload)

	local ok, err = pcall(function()
		return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson, false)
	end)

	if not ok then
		return false, tostring(err)
	end

	return true, "sent"
end

function WebhookManager:Send(webhookName, templateName, variables)
	local webhook
	if webhookName then
		webhook = self.Webhooks[webhookName]
		if not webhook then
			return false, "webhook not found: " .. tostring(webhookName)
		end
	else
		webhook = self:GetCurrent()
	end

	if not webhook then
		return false, "no webhook configured"
	end

	local payload, err = self:Compile(templateName, variables)
	if not payload then
		return false, err
	end

	return self:SendPayload(self.ProxyUrl, payload)
end

function WebhookManager:SendRaw(url, payload)
	return self:SendPayload(url, payload)
end

function WebhookManager:Test(webhookName, message)
	return self:SendPayload(self.ProxyUrl, {
		content = tostring(message or "Test from GalaxHub"),
	})
end

function WebhookManager:Refresh()
	ensureFolder(WebhookFolder)

	for _, path in ipairs(listfiles(WebhookFolder) or {}) do
		local pathText = tostring(path)
		local baseName = pathText:match("([^/\\]+)$") or pathText
		if baseName:match("%.txt$") then
			local data = readTable(pathText)
			if data and data.Name and data.Url then
				self.Webhooks[data.Name] = { Name = data.Name, Url = data.Url }
			end
		end
	end

	local names = {}
	for name in pairs(self.Webhooks) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

function WebhookManager:Delete(name)
	if not name then
		return false, "no name"
	end

	self.Webhooks[name] = nil
	local path = WebhookFolder .. "/" .. fileName(name)
	if isfile(path) then
		delfile(path)
	end

	if self.AutoloadWebhook and self.AutoloadWebhook.Name == name then
		self:ResetDefault()
	end

	return true
end

function WebhookManager:GetAutoloadWebhook()
	local saved = readTable(DefaultWebhookFile)
	if saved and saved.Name and saved.Url then
		self.AutoloadWebhook = saved
	end

	if self.AutoloadWebhook then
		local name = self.AutoloadWebhook.Name
		if not self.Webhooks[name] then
			self:Refresh()
			if not self.Webhooks[name] then
				self:ResetDefault()
			end
		end
	end

	if not self.AutoloadWebhook then
		return self.DefaultWebhook.Name
	end

	return self.AutoloadWebhook.Name
end

function WebhookManager:SetDefault(name)
	if not name then
		return false, "no name"
	end

	local data = self.Webhooks[name]
	if not data then
		return false, "webhook not found"
	end

	self.AutoloadWebhook = data
	return writeTable(DefaultWebhookFile, { Name = data.Name, Url = data.Url })
end

function WebhookManager:ResetDefault()
	self.AutoloadWebhook = nil

	writeTable(DefaultWebhookFile, {})

	return true
end

function WebhookManager:LoadAutoload()
	self:GetAutoloadWebhook()

	if self.AutoloadWebhook then
		return self.AutoloadWebhook
	end

	return self.DefaultWebhook
end

function WebhookManager:BuildWebhookSection(tab)
	local Library = self.Library
	if not Library then
		error("WebhookManager:BuildWebhookSection requires Library (call SetLibrary first)", 2)
	end

	local saveManager = _G.Galax and _G.Galax["addons/SaveManager.lua"]
	if saveManager then
		saveManager:SetIgnoreIndexes({ "WebhookManager_TestMessage" })
	end

	local Options = Library.Options

	local testSection = tab:AddLeftGroupbox("Test")

	testSection:AddInput("WebhookManager_TestMessage", {
		Text = "Test message",
		Placeholder = "Enter a test message...",
	})

	testSection:AddButton("Send Test", function()
		local webhook = self:GetCurrent()
		if not webhook or not webhook.Url then
			Library:Notify("No webhook selected", 4)
			return
		end

		local message = Options and Options.WebhookManager_TestMessage and Options.WebhookManager_TestMessage.Value or "Test from GalaxHub"
		if not message or message == "" then
			message = "Test from GalaxHub"
		end

		local ok, err = self:Test(nil, message)
		if ok then
			Library:Notify(string.format("Test sent to %q", webhook.Name), 4)
		else
			Library:Notify("Test failed: " .. tostring(err), 4)
		end
	end)

	local function refreshWebhookList()
		if Options.WebhookManager_WebhookList then
			Options.WebhookManager_WebhookList:SetValues(self:Refresh())
			Options.WebhookManager_WebhookList:SetValue(nil)
		end
	end

	local webhookSection = tab:AddRightGroupbox("Webhooks")

	webhookSection:AddDropdown("WebhookManager_WebhookList", {
		Text = "Webhook list",
		Values = self:Refresh(),
		AllowNull = true,
	})

	webhookSection:AddButton("Set as Default", function()
		local name = Options.WebhookManager_WebhookList:Get()
		if not name then
			Library:Notify("No webhook selected", 4)
			return
		end

		local ok, err = self:SetDefault(name)
		if not ok then
			Library:Notify("Failed to set default: " .. tostring(err), 4)
			return
		end

		Library:Notify(string.format("Default webhook set to %q", name), 4)
		if self.AutoloadWebhookLabel then
			self.AutoloadWebhookLabel:SetText("Current autoload: " .. tostring(self:GetAutoloadWebhook()))
		end
	end)

	webhookSection:AddButton("Refresh list", function()
		refreshWebhookList()
	end)

	webhookSection:AddButton({
		Text = "Delete webhook",
		DoubleClick = true,
		Func = function()
			local name = Options.WebhookManager_WebhookList:Get()
			if not name then
				return
			end

			local ok, err = self:Delete(name)
			if not ok then
				Library:Notify("Failed to delete webhook: " .. tostring(err), 4)
				return
			end

			Library:Notify(string.format("Deleted webhook %q", name), 4)
			refreshWebhookList()

			if self.AutoloadWebhookLabel then
				self.AutoloadWebhookLabel:SetText("Current autoload: " .. tostring(self:GetAutoloadWebhook()))
			end
		end
	})

	webhookSection:AddButton("Reset Default", function()
		self:ResetDefault()
		Library:Notify("Default webhook reset to GalaxHub", 4)
		if self.AutoloadWebhookLabel then
			self.AutoloadWebhookLabel:SetText("Current autoload: " .. tostring(self:GetAutoloadWebhook()))
		end
	end)

	self.AutoloadWebhookLabel = webhookSection:AddLabel("Current autoload: " .. tostring(self:GetAutoloadWebhook()))

	self:LoadAutoload()
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/WebhookManager.lua"] = WebhookManager

_G.webhook = _G.webhook or {}
_G.webhook.load = function(name, url)
	local wm = _G.Galax and _G.Galax["addons/WebhookManager.lua"]
	if not wm then
		warn("webhook.load: WebhookManager not loaded")
		return false
	end
	local ok, err = wm:Add(name, url)
	if not ok then
		warn("webhook.load: " .. tostring(err))
		return false
	end
	print(string.format("webhook.load: loaded %q", name))
	return true
end

return WebhookManager
