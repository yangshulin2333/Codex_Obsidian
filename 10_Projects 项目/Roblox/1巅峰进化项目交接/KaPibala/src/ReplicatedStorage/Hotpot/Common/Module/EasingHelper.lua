local module = {}

function Get(time, _EasingStyle, _EasingDirection)
	--_EasingStyle = _EasingStyle and "Sine"
	--_EasingDirection = _EasingDirection and "InOut"
	--if type(_EasingStyle) ~= "string" then
	--	_EasingStyle = string.sub(tostring(_EasingStyle), 18)
	--end
	--if type(_EasingDirection) ~= "string" then
	--	_EasingDirection = string.sub(tostring(_EasingDirection), 22)
	--end
	if _EasingStyle == "Circular" then
		_EasingStyle = "Circ"
	elseif _EasingStyle == "Exponential" then
		_EasingStyle = "Expo"
	end
	if not module[_EasingStyle .. _EasingDirection] then
		if _EasingStyle == "Linear" then

		else
			return
		end
	end
	if _EasingStyle == "Linear" then
		return time
	end

	return module[_EasingStyle .. _EasingDirection](time)
end

function module.QuadIn(_time)
	_time = _time / 1
	return 1 * math.pow(_time, 2) + 0
end

function module.QuadOut(_time)
	_time = _time / 1
	return -1 * _time * (_time - 2) + 0
end

function module.QuadInOut(_time)
	_time = _time / 1 * 2
	if _time < 1 then
		return 0.5 * math.pow(_time, 2) + 0
	end
	return -0.5 * ((_time - 1) * (_time - 3) - 1) + 0
end

function module.QuadOutIn(_time)
	if _time < 0.5 then
		return module.QuadOut(_time * 2)
	end
	return module.QuadIn(_time * 2 - 1)
end

function module.CubicIn(_time)
	_time = _time / 1
	return 1 * math.pow(_time, 3) + 0
end

function module.CubicOut(_time)
	_time = _time / 1 - 1
	return 1 * (math.pow(_time, 3) + 1) + 0
end

function module.CubicInOut(_time)
	_time = _time / 1 * 2
	if _time < 1 then
		return 0.5 * _time * _time * _time + 0
	end
	_time = _time - 2
	return 0.5 * (_time * _time * _time + 2) + 0
end

function module.CubicOutIn(_time)
	if _time < 0.5 then
		return module.CubicOut(_time * 2)
	end
	return module.CubicIn(_time * 2 - 1)
end

function module.QuartIn(_time)
	_time = _time / 1
	return 1 * math.pow(_time, 4) + 0
end

function module.QuartOut(_time)
	_time = _time / 1 - 1
	return -1 * (math.pow(_time, 4) - 1) + 0
end

function module.QuartInOut(_time)
	_time = _time / 1 * 2
	if _time < 1 then
		return 0.5 * math.pow(_time, 4) + 0
	end
	_time = _time - 2
	return -0.5 * (math.pow(_time, 4) - 2) + 0
end

function module.QuartOutIn(_time)
	if _time < 0.5 then
		return module.QuartOut(_time * 2)
	end
	return module.QuartIn(_time * 2 - 1)
end

function module.QuintIn(_time)
	_time = _time / 1
	return 1 * math.pow(_time, 5) + 0
end

function module.QuintOut(_time)
	_time = _time / 1 - 1
	return 1 * (math.pow(_time, 5) + 1) + 0
end

function module.QuintInOut(_time)
	_time = _time / 1 * 2
	if _time < 1 then
		return 0.5 * math.pow(_time, 5) + 0
	end
	_time = _time - 2
	return 0.5 * (math.pow(_time, 5) + 2) + 0
end

function module.QuintOutIn(_time)
	if _time < 0.5 then
		return module.QuintOut(_time * 2)
	end
	return module.QuintIn(_time * 2 - 1)
end

function module.SineIn(_time)
	return -1 * math.cos(_time / 1 * (math.pi / 2)) + 1 + 0
end

function module.SineOut(_time)
	return 1 * math.sin(_time / 1 * (math.pi / 2)) + 0
end

function module.SineInOut(_time)
	return -0.5 * (math.cos(math.pi * _time / 1) - 1) + 0
end

function module.SineOutIn(_time)
	if _time < 0.5 then
		return module.SineOut(_time * 2)
	end
	return module.SineIn(_time * 2)
end

function module.ExpoIn(_time)
	if _time == 0 then
		return 0
	end
	return 1 * math.pow(2, 10 * (_time / 1 - 1)) + 0 - 0.001
end

function module.ExpoOut(_time)
	if _time == 1 then
		return 1
	end
	return 1.001 * (-math.pow(2, -10 * _time / 1) + 1) + 0
end

function module.ExpoInOut(_time)
	if _time == 0 then
		return 0
	end
	if _time == 1 then
		return 1
	end
	_time = _time / 1 * 2
	if _time < 1 then
		return 0.5 * math.pow(2, 10 * (_time - 1)) + 0 - 0.0005
	end
	_time = _time - 1
	return 0.50025 * (-math.pow(2, -10 * _time) + 2) + 0
end

function module.ExpoOutIn(_time)
	if _time < 0.5 then
		return module.ExpoOut(_time * 2)
	end
	return module.ExpoIn(_time * 2 - 1)
end

function module.CircIn(_time)
	_time = _time / 1
	return -1 * (math.sqrt(1 - math.pow(_time, 2)) - 1) + 0
end

function module.CircOut(_time)
	_time = _time / 1 - 1
	return 1 * math.sqrt(1 - math.pow(_time, 2)) + 0
end

function module.CircInOut(_time)
	_time = _time / 1 * 2
	if _time < 1 then
		return -0.5 * (math.sqrt(1 - _time * _time) - 1) + 0
	end
	_time = _time - 2
	return 0.5 * (math.sqrt(1 - _time * _time) + 1) + 0
end

function module.CircOutIn(_time)
	if _time < 0.5 then
		return module.CircOut(_time * 2)
	end
	return module.CircIn(_time * 2 - 1)
end

function module.ElasticIn(_time)
	if _time == 0 then
		return 0
	end
	_time = _time / 1
	if _time == 1 then
		return 1
	end
	local value1 = nil
	local value2 = nil
	if not value1 then
		value1 = 0.3
	end
	local value3 = value1 / 4
	if not value2 or value2 < 1 then
		value2 = 1
		value3 = value1 / 4
	else
		value3 = value1 / (2 * math.pi) * math.asin(1 / value2)
	end
	_time = _time - 1
	return -(value2 * math.pow(2, 10 * _time) * math.sin((_time * 1 - value3) * (2 * math.pi) / value1)) + 0
end

function module.ElasticOut(_time)
	if _time == 0 then
		return 0
	end
	_time = _time / 1
	if _time == 1 then
		return 1
	end
	local value1 = nil
	local value2 = nil
	if not value1 then
		value1 = 0.3
	end
	local value3 = value1 / 4
	if not value2 or value2 < 1 then
		value2 = 1
	else
		value3 = value1 / (2 * math.pi) * math.asin(1 / value2)
	end
	return value2 * math.pow(2, -10 * _time) * math.sin((_time * 1 - value3) * (2 * math.pi) / value1) + 1 + 0
end

function module.ElasticInOut(_time)
	if _time == 0 then
		return 0
	end
	_time = _time / 1 * 2
	if _time == 2 then
		return 1
	end
	local value1 = nil
	local value2 = nil
	if not value1 then
		value1 = 0.44999999999999996
	end
	if not value2 then
		value2 = 0
	end
	local value3 = value1 / 4
	if not value2 or value2 < 1 then
		value2 = 1
	else
		value3 = value1 / (2 * math.pi) * math.asin(1 / value2)
	end
	if _time < 1 then
		_time = _time - 1
		return -0.5 * (value2 * math.pow(2, 10 * _time) * math.sin((_time * 1 - value3) * (2 * math.pi) / value1)) + 0
	end
	_time = _time - 1
	return value2 * math.pow(2, -10 * _time) * math.sin((_time * 1 - value3) * (2 * math.pi) / value1) * 0.5 + 1 + 0
end

function module.ElasticOutIn(_time)
	if _time < 0.5 then
		return module.ElasticOut(_time * 2)
	end
	return module.ElasticIn(_time * 2 - 1)
end

function module.BackIn(_time)
	_time = _time / 1
	return 1 * _time * _time * (2.70158 * _time - 1.70158) + 0
end

function module.BackOut(_time)
	_time = _time / 1 - 1
	return 1 * (_time * _time * (2.70158 * _time + 1.70158) + 1) + 0
end

function module.BackInOut(_time)
	local value1 = nil
	value1 = 2.5949095
	_time = _time / 1 * 2
	if _time < 1 then
		return 0.5 * (_time * _time * ((value1 + 1) * _time - value1)) + 0
	end
	_time = _time - 2
	return 0.5 * (_time * _time * ((value1 + 1) * _time + value1) + 2) + 0
end

function module.BackOutIn(_time)
	if _time < 0.5 then
		return module.BackOut(_time * 2)
	end
	return module.BackIn(_time * 2 - 1)
end

function module.BounceOut(_time)
	_time = _time / 1
	if _time < 0.36363636363636365 then
		return 1 * (7.5625 * _time * _time) + 0
	end
	if _time < 0.7272727272727273 then
		_time = _time - 0.5454545454545454
		return 1 * (7.5625 * _time * _time + 0.75) + 0
	end
	if _time < 0.9090909090909091 then
		_time = _time - 0.8181818181818182
		return 1 * (7.5625 * _time * _time + 0.9375) + 0
	end
	_time = _time - 0.9545454545454546
	return 1 * (7.5625 * _time * _time + 0.984375) + 0
end

function module.BounceIn(_time)
	return 1 - module.BounceOut(1 - _time) + 0
end

function module.BounceInOut(_time)
	if _time < 0.5 then
		return module.BounceIn(_time * 2) * 0.5 + 0
	end
	return module.BounceOut(_time * 2 - 1) * 0.5 + 0.5 + 0
end

function module.BounceOutIn(_time)
	if _time < 0.5 then
		return module.BounceOut(_time * 2)
	end
	return module.BounceIn(_time * 2 - 1)
end

return Get
