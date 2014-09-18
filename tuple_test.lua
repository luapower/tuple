local tuple = require'tuple'

local function collectall()
	local after = collectgarbage'count'
	repeat
		local before = after
		collectgarbage()
		after = collectgarbage'count'
	until after >= before
end

--test: leaf index found but has no tuple.
local t1 = tuple('a','b','c')
local t2 = tuple('a','b')
assert(t1 ~= t2)

--test: nil and nan values.
local ab = 'a'..string.char(string.byte('b')) --because constants are not collected
local e0 = tuple(ab)             assert(e0() == ab)
local e1 = tuple(ab,nil,1)       assert(e1(2) == nil); assert(e1(3) == 1)
local e2 = tuple(ab,nil,2)       assert(e2(2) == nil); assert(e2(3) == 2)
local e3 = tuple(ab,nil,2,nil)   assert(select('#', e3()) == 4)
local e4 = tuple(ab,0/0,2,nil)   assert(e4(2) ~= e4(2))
local a,b,c,d = e4()
assert(a==ab and b~=b and c==2 and d==nil)

--test: anchoring of index tables (insufficient).
ab = nil
collectall()
local ab = 'a'..'b'
assert(e0 == tuple(ab))
assert(e1 == tuple(ab,nil,1))
assert(e2 == tuple(ab,nil,2))
assert(e2 ~= tuple(ab,nil,2,nil))
assert(e3 == tuple(ab,nil,2,nil))
assert(e4 == tuple(ab,0/0,2,nil))

--test: tostring()
assert(tostring(e0) == '(ab)')
assert(tostring(tuple('b', 1, 'd')) == '(b, 1, d)')
if jit then --only luajit has 'nan' for 0/0
	assert(tostring(e4) == '(ab, nan, 2, nil)')
end

--test: anchoring of index tables.
local t = {}
for i=1,20 do
	for j = 1,20 do
		t[tuple(i, j)] = true
	end
end
collectall()
for i=1,20 do
	for j = 1,20 do
		assert(t[tuple(i, j)])
	end
end

e0,e1,e2,e3,e4 = nil
collectall()

