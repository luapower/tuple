---
project: tuple
tagline: real tuples
---

## `local tuple = require'tuple'`

Real tuples are immutable lists that can be used as table keys because they have value semantics, i.e. the tuple constructor returns the same identity for the exact same list of identities. If you don't need this property, [vararg vararg.pack()] is a faster and more memory efficient way to store small lists of values.

## `tuple(e1,...) -> t`

Create or find a tuple given a list of elements. Elements can be anything, including nil and NaN.

## `t() -> e1,...`

Access the elements of a tuple.

### Example

~~~{.lua}
local tuple = require'tuple'

local tup = tuple('a',0/0,2,nil)
local t = {[tup] = 'here'}
assert(t[tuple('a',0/0,2,nil)] == 'here')
assert(t[tuple('a',0/0,2)] == nil)
print(tup())
> a	nan	2	nil
~~~

> __NOTE:__ all the tuple elements of all the tuples created with this function are indexed internally
with a global weak hash tree. This means that creating a tuple takes N hash lookups and M table creations,
where N+M is the number of elements of the tuple. Lookup time depends on how dense the tree is on the search path,
which depends on how many existing tuples share a first sequence of elements with the tuple being created.
In particular, creating tuples out of all permutations of a certain set of values hits the worst case for hash
lookup time, but creates the minimum amount of tables relative to the number of tuples.
