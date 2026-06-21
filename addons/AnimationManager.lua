local AnimationManager = {}

AnimationManager.Version = "0.1.0"
AnimationManager.DefaultSpeed = 14

local function now()
	if type(tick) == "function" then
		return tick()
	end
	return os.clock()
end

local function clamp(value, minValue, maxValue)
	if value < minValue then
		return minValue
	end
	if value > maxValue then
		return maxValue
	end
	return value
end

local function colorComponents(color)
	return color.R or color.r or 0, color.G or color.g or 0, color.B or color.b or 0
end

local function valueKind(value)
	if type(value) == "number" then
		return "number"
	end
	if typeof then
		local kind = typeof(value)
		if kind == "Color3" or kind == "Vector2" or kind == "Vector3" then
			return kind
		end
	end
	if type(value) == "table" then
		if value.R or value.r then
			return "Color3"
		end
		if value.X and value.Y and value.Z then
			return "Vector3"
		end
		if value.X and value.Y then
			return "Vector2"
		end
	end
	return type(value)
end

function AnimationManager:Lerp(fromValue, toValue, alpha)
	alpha = clamp(alpha or 0, 0, 1)
	local kind = valueKind(toValue)

	if kind == "number" then
		return fromValue + (toValue - fromValue) * alpha
	end

	if kind == "Color3" then
		local fr, fg, fb = colorComponents(fromValue)
		local tr, tg, tb = colorComponents(toValue)
		return Color3.new(fr + (tr - fr) * alpha, fg + (tg - fg) * alpha, fb + (tb - fb) * alpha)
	end

	if kind == "Vector2" then
		return Vector2.new(fromValue.X + (toValue.X - fromValue.X) * alpha, fromValue.Y + (toValue.Y - fromValue.Y) * alpha)
	end

	if kind == "Vector3" then
		return Vector3.new(fromValue.X + (toValue.X - fromValue.X) * alpha, fromValue.Y + (toValue.Y - fromValue.Y) * alpha, fromValue.Z + (toValue.Z - fromValue.Z) * alpha)
	end

	return toValue
end

function AnimationManager:Approach(owner, key, target, speed)
	if owner == nil or key == nil then
		return target
	end

	owner._animations = owner._animations or {}
	key = tostring(key)

	local timeNow = now()
	local kind = valueKind(target)
	local state = owner._animations[key]

	if not state or state.kind ~= kind then
		state = {
			kind = kind,
			value = target,
			target = target,
			time = timeNow,
		}
		owner._animations[key] = state
		return target
	end

	local dt = clamp(timeNow - (state.time or timeNow), 0, 0.1)
	state.time = timeNow
	state.target = target

	local alpha = 1 - math.exp(-(speed or self.DefaultSpeed) * dt)
	state.value = self:Lerp(state.value, target, alpha)
	return state.value
end

AnimationManager.Tween = AnimationManager.Approach

function AnimationManager:Color(owner, key, target, speed)
	return self:Approach(owner, key, target, speed)
end

function AnimationManager:Number(owner, key, target, speed)
	return self:Approach(owner, key, target, speed)
end

function AnimationManager:Vector2(owner, key, target, speed)
	return self:Approach(owner, key, target, speed)
end

function AnimationManager:Vector3(owner, key, target, speed)
	return self:Approach(owner, key, target, speed)
end

function AnimationManager:Reset(owner, key)
	if not owner or not owner._animations then
		return
	end
	if key == nil then
		owner._animations = {}
	else
		owner._animations[tostring(key)] = nil
	end
end

_G.Galax = _G.Galax or {}
_G.Galax["addons/AnimationManager.lua"] = AnimationManager

return AnimationManager
