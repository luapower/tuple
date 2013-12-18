local tuple = require'tuple'

local function collectall()
	local after = collectgarbage'count'
	repeat
		local before = after
		collectgarbage()
		after = collectgarbage'count'
	until after >= before
end
local e0 = tuple('a')
local e1 = tuple('a',nil,1)
local e2 = tuple('a',nil,2)
local e3 = tuple('a',nil,2,nil)
local e4 = tuple('a',0/0,2,nil)
collectall()
assert(e0 == tuple('a'))
assert(e1 == tuple('a',nil,1))
assert(e2 == tuple('a',nil,2))
assert(e2 ~= tuple('a',nil,2,nil))
assert(e3 == tuple('a',nil,2,nil))
assert(e4 == tuple('a',0/0,2,nil))
local a,b,c,d = e4()
assert(a=='a' and b~=b and c==2 and d==nil)
assert(tostring(e4) == '(a, nan, 2, nil)') --only on luajit where tostring(0/0) == 'nan'
e0,e1,e2,e3,e4 = nil
collectall()
