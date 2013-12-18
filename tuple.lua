--n-tuple tree-based implementation; supports nils and NaNs

local weak_values = {__mode = 'v'}
local pins = setmetatable({}, weak_values) --{space_kN = e}

local function find(space, e, n)
	for i=1,n do
		local t = space[e[i]]
		if t == nil then return end
		space = t
	end
	return space
end

local function set(space, e, n)
	local de = find(space, e, n)
	if de ~= nil then return de end
	for i=1,n-1 do
		local t = space[e[i]]
		if not t then
			t = setmetatable({}, weak_values)
			space[e[i]] = t
			pins[t] = e
		end
		space = t
	end
	space[e[n]] = e
	return e
end

local space = setmetatable({}, weak_values) --{k1 = space_k1}; space_k1 = {k2 = space_k2}
local meta = {}
local NIL = {}
local NAN = {}

local function tuple(...)
	local n = select('#', ...)
	assert(n > 0)
	local e = setmetatable({...}, meta)
	for i=1,n do
		if e[i] == nil then e[i] = NIL elseif e[i] ~= e[i] then e[i] = NAN end
	end
	return set(space, e, n)
end

local function unnil(v,...)
	if v == NIL then v = nil elseif v == NAN then v = 0/0 end
	if select('#',...) == 0 then return v end
	return v, unnil(...)
end

local function unpack(e)
	return unnil(_G.unpack(e, 1, #e))
end

function meta.__tostring(e)
	local t = {}
	for i=1,#e do
		local v = e[i]
		if v == NIL then v = nil elseif v == NAN then v = 0/0 end
		t[i] = tostring(v)
	end
	return string.format('(%s)', table.concat(t, ', '))
end

meta.__call = unpack

meta.__pwrite = function(t, write, write_value)
	write'tuple('; write_value(t[1])
	for i=2,#t do
		write','; write_value(t[i])
	end
	write')'
end

return tuple
