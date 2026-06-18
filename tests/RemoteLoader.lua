-- RemoteLoader.lua
-- Execute this locally in Matcha to test loading and starting a remote script.

local REMOTE_URL = "https://raw.githubusercontent.com/WhyMayko/Obsidian-Matcha/refs/heads/main/tests/RemotePayload.lua"

local function fetch(url)
	local ok, result = pcall(function()
		return game:HttpGet(url)
	end)

	if not ok then
		return nil, "HttpGet failed: " .. tostring(result)
	end

	if type(result) ~= "string" or result == "" then
		return nil, "empty response"
	end

	if result:find("<!DOCTYPE", 1, true) then
		return nil, "GitHub returned HTML instead of raw Lua"
	end

	return result, nil
end

local source, fetchError = fetch(REMOTE_URL)
if not source then
	warn("[RemoteTest] " .. fetchError)
	return
end

local chunk, compileError = loadstring(source, "RemotePayload")
if not chunk then
	warn("[RemoteTest] Compile failed: " .. tostring(compileError))
	return
end

local ok, remoteState = pcall(chunk)
if not ok then
	warn("[RemoteTest] Runtime failed: " .. tostring(remoteState))
	return
end

print("[RemoteTest] Loader executed remote payload.")
print("[RemoteTest] To stop it, run:")
print("_G.ObsidianMatchaRemoteTest:Stop()")

return remoteState
