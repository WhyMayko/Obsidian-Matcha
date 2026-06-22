local ValueWatcher = {
	_watchers = {},
	_paused = false,
}

function ValueWatcher:SetLibrary(library)
	self.Library = library
end

function ValueWatcher:Watch(id, callback)
	if not id or not callback then
		return nil
	end
	local entry = { id = id, callback = callback, lastValue = nil }
	self._watchers[#self._watchers + 1] = entry

	local unwatch = function()
		for i = #self._watchers, 1, -1 do
			if self._watchers[i] == entry then
				table.remove(self._watchers, i)
				return
			end
		end
	end

	return unwatch
end

function ValueWatcher:WatchPattern(pattern, callback)
	if not pattern or not callback then
		return nil
	end
	local entry = { pattern = pattern, callback = callback }
	self._watchers[#self._watchers + 1] = entry

	local unwatch = function()
		for i = #self._watchers, 1, -1 do
			if self._watchers[i] == entry then
				table.remove(self._watchers, i)
				return
			end
		end
	end

	return unwatch
end

function ValueWatcher:Update()
	local Library = self.Library
	if not Library or self._paused then
		return nil
	end

	for _, watcher in ipairs(self._watchers) do
		local id = watcher.id
		local pattern = watcher.pattern

		if id then
			local option = Library.Options and Library.Options[id]
			local toggle = Library.Toggles and Library.Toggles[id]
			local value = (option and option.Value) or (toggle and toggle.Value) or nil
			if value ~= watcher.lastValue then
				watcher.lastValue = value
				local ok, err = pcall(watcher.callback, value, id)
				if not ok then error("ValueWatcher callback: " .. tostring(err), 2) end
			end
		elseif pattern then
			for optId, option in pairs(Library.Options or {}) do
				if tostring(optId):match(pattern) then
					local value = option.Value
					local key = ("opt:%s"):format(tostring(optId))
					if value ~= watcher["_last_" .. key] then
						watcher["_last_" .. key] = value
						local ok, err = pcall(watcher.callback, value, optId)
						if not ok then error("ValueWatcher callback: " .. tostring(err), 2) end
					end
				end
			end
			for togId, toggle in pairs(Library.Toggles or {}) do
				if tostring(togId):match(pattern) then
					local value = toggle.Value
					local key = ("tog:%s"):format(tostring(togId))
					if value ~= watcher["_last_" .. key] then
						watcher["_last_" .. key] = value
						local ok, err = pcall(watcher.callback, value, togId)
						if not ok then error("ValueWatcher callback: " .. tostring(err), 2) end
					end
				end
			end
		end
	end
end

function ValueWatcher:Pause()
	self._paused = true
end

function ValueWatcher:Resume()
	self._paused = false
end

function ValueWatcher:Clear()
	self._watchers = {}
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/ValueWatcher.lua"] = ValueWatcher

return ValueWatcher
