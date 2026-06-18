-- RemotePayload.lua
-- Put this file in GitHub and load it through the local test loader.

local STATE_KEY = "ObsidianMatchaRemoteTest"

_G[STATE_KEY] = _G[STATE_KEY] or {}

local state = _G[STATE_KEY]

if state.Running then
	print("[RemoteTest] Payload is already running.")
	return state
end

state.Running = true
state.StartedAt = tick()
state.TickCount = 0

function state:Stop()
	self.Running = false
	print("[RemoteTest] Stop requested.")
end

function state:IsRunning()
	return self.Running == true
end

task.spawn(function()
	print("[RemoteTest] Remote payload started.")

	while state.Running do
		state.TickCount = state.TickCount + 1
		print("[RemoteTest] Running tick:", state.TickCount)

		if notify and state.TickCount == 1 then
			pcall(function()
				notify("Remote payload is running.", "Obsidian Matcha", 3)
			end)
		end

		task.wait(2)
	end

	print("[RemoteTest] Remote payload stopped after ticks:", state.TickCount)
end)

return state
