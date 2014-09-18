
--n-tuple implementation based on an index tree.
--Cosmin Apreutesei. Public domain.

if not ... then require'tuple_test'; return end

local weakvals_meta = {__mode = 'v'}

--make a table with weak values.
local function weakvals()
	return setmetatable({}, weakvals_meta)
end

--make a table with strong values, i.e. make a table.
local function strongvals()
	return {}
end

--convert nils and NaNs to be used as table keys.
local NIL = {}
local NAN = {}
local function tokey(v)
	return v == nil and NIL or v ~= v and NAN or v
end

--make a new tuple space, with weak or strong references.
--using strong references is faster but dead tuples won't get collected
--until the space is released.
local function space(weak)

	local weakvals = weak and weakvals or strongvals
	local index = weakvals() --{k1 = index1}; index1 = {k2 = index2}
	local tuples = weakvals() --{index1 = tuple(k1), index2 = tuple(k1, k2)}

	--find a matching tuple by going through the index tree.
	local function find(...)
		local t = {}
		local n = select('#',...)
		local index = index
		for i = 1, n do
			local k = tokey(select(i,...))
			index = index[k]
			if not index then
				return nil, n
			end
		end
		return tuples[index], n
	end

	--get a matching tuple, or make a new one and add it to the index.
	return function(...)
		local tuple, n = find(...)
		if not tuple then
			tuple = {n = n, ...}
			local index = index
			for i = 1, n do
				local k = tokey(select(i,...))
				local t = index[k]
				if not t then
					t = weakvals()
					index[k] = t
				end
				if weak and i < n then
					tuple[t] = true --anchor index table in the tuple.
				end
				index = t
			end
			tuples[index] = tuple
		end
		return tuple
	end
end

--tuple class

local tuple = {}
local tuple_meta = {__index = tuple, __newindex = false}

function wrap(t)
	return setmetatable(t, tuple_meta)
end

function tuple:unpack(i, j)
	return unpack(self, i, self.n)
end

tuple_meta.__call = tuple.unpack

function tuple_meta:__tostring()
	local t = {}
	for i=1,self.n do
		t[i] = tostring(self[i])
	end
	return string.format('(%s)', table.concat(t, ', '))
end

function tuple_meta:__pwrite(write, write_value)
	write'tuple('; write_value(self[1])
	for i=2,self.n do
		write','; write_value(self[i])
	end
	write')'
end

--default weak tuple space and tuple module

local tuple = space(true)

return setmetatable({
	space = space,
}, {
	__call = function(_, ...)
		return wrap(tuple(...))
	end
})

