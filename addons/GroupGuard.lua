local GroupGuard = {
	Library = nil,
	GroupId = 416091513,
	DefaultAction = "Notify",
	Running = false,
	Busy = false,
	Fetched = {},
	Queue = {},
	Acted = {},
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local OffsetUrls = {
	"https://offsets.imtheo.lol/Offsets.json",
	"https://offsets.femboythighs.org/Offsets.json",
	"https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Offsets/Offsets.json",
}

local KickValue = 214481945688787

local function fetchJson(url)
	local ok, raw = pcall(function() return game:HttpGet(url) end)
	if not (ok and type(raw) == "string") or raw == "" then
		return nil
	end
	local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if ok2 and type(data) == "table" then
		return data
	end
	return nil
end

local function spGetPlayers()
	local ok, list = pcall(function() return Players:GetPlayers() end)
	return ok and list or {}
end

local function safeName(uid)
	for _, plr in ipairs(spGetPlayers()) do
		local ok, pid = pcall(function() return plr.UserId end)
		if ok and pid == uid then
			local okName, name = pcall(function() return plr.Name end)
			return okName and name or tostring(uid)
		end
	end
	return tostring(uid)
end

function GroupGuard:SetLibrary(library)
	self.Library = library
end

function GroupGuard:ResetState()
	self.Fetched = {}
	self.Queue = {}
	self.Acted = {}
end

function GroupGuard:Ranks()
	local data = fetchJson(string.format("https://groups.roblox.com/v1/groups/%d/roles", self.GroupId))
	local out = {}
	if data and type(data.roles) == "table" then
		for _, role in ipairs(data.roles) do
			if type(role) == "table" and type(role.name) == "string" then
				out[#out + 1] = role.name
			end
		end
		table.sort(out)
	end
	return out
end

function GroupGuard:MembershipRole(userId)
	local data = fetchJson(string.format("https://groups.roblox.com/v1/users/%d/groups/roles", userId))
	if data and type(data.data) == "table" then
		for _, entry in ipairs(data.data) do
			local group = (type(entry) == "table") and entry.group
			local role = (type(entry) == "table") and entry.role
			if type(group) == "table" and group.id == self.GroupId and type(role) == "table" and type(role.name) == "string" then
				return role.name
			end
		end
	end
	return nil
end

function GroupGuard:UserIdOffset()
	for _, url in ipairs(OffsetUrls) do
		local data = fetchJson(url)
		local o = data and (data.Offsets or data)
		if o and type(o.Player) == "table" and o.Player.UserId then
			return o.Player.UserId
		end
	end
	return nil
end

function GroupGuard:DoKick()
	local uidOff = self:UserIdOffset()
	if not uidOff then
		error("GroupGuard: no offsets source, cannot kick!")
	end
	local lp = Players.LocalPlayer
	local addr = lp and lp.Address
	if not addr then
		error("GroupGuard: local player not ready!")
	end
	memory_write("uintptr_t", addr + uidOff, KickValue)
end

function GroupGuard:handleMember(uid, role)
	if self.Acted[uid] then
		return
	end
	local Options = self.Library and self.Library.Options
	local selected = Options and Options.GroupGuard_Ranks and Options.GroupGuard_Ranks:Get()
	local match = false
	if selected then
		for _, rank in ipairs(selected) do
			if rank == role then
				match = true
				break
			end
		end
	end
	if not match then
		return
	end
	self.Acted[uid] = true
	local action = Options and Options.GroupGuard_Action and Options.GroupGuard_Action:Get() or self.DefaultAction
	if action == "Notify" or action == "Kick + Notify" then
		self.Library:Notify(string.format("%s ( %s )", safeName(uid), role), "Group Guard", 5)
	end
	if action == "Kick" or action == "Kick + Notify" then
		self:DoKick()
	end
end

function GroupGuard:Start()
	if self.Running then
		return
	end
	self:ResetState()
	self.Running = true
	self.Busy = false

	task.spawn(function()
		while self.Running do
			for _, plr in ipairs(spGetPlayers()) do
				local ok, uid = pcall(function() return plr.UserId end)
				if ok and uid and not self.Fetched[uid] then
					self.Fetched[uid] = false
					self.Queue[#self.Queue + 1] = uid
				end
			end
			task.wait(3)
		end
	end)

	task.spawn(function()
		while self.Running do
			if not self.Busy and #self.Queue > 0 then
				self.Busy = true
				local uid = table.remove(self.Queue, 1)
				local role = self:MembershipRole(uid)
				self.Fetched[uid] = true
				if role then
					self:handleMember(uid, role)
				end
				self.Busy = false
			end
			task.wait(1)
		end
	end)
end

function GroupGuard:Stop()
	self.Running = false
end

function GroupGuard:AddTab(window)
	local Library = self.Library
	if not Library then
		error("GroupGuard: call SetLibrary first!", 2)
	end

	local tab = window:AddTab("Group", "users")
	local detector = tab:AddLeftGroupbox("Rank Detector")
	local settings = tab:AddRightGroupbox("Settings")

	detector:AddMultiDropdown("GroupGuard_Ranks", {
		Text = "Watch these ranks",
		Values = {},
		Searchable = true,
		Min = 0,
	})

	detector:AddButton("Refresh ranks", function()
		self:RefreshRanks()
	end)

	settings:AddToggle("GroupGuard_Enabled", {
		Text = "Enabled",
		Default = false,
		Callback = function(value)
			if value then
				self:Start()
			else
				self:Stop()
			end
		end,
	})

	settings:AddDropdown("GroupGuard_Action", {
		Text = "Action on join",
		Values = { "Notify", "Kick", "Kick + Notify" },
		Default = "Notify",
	})

	self:RefreshRanks()

	return tab
end

function GroupGuard:RefreshRanks()
	local handle = self.Library.Options and self.Library.Options.GroupGuard_Ranks
	if not handle then
		return
	end
	handle:SetValues(self:Ranks())
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/GroupGuard.lua"] = GroupGuard

return GroupGuard