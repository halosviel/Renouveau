--[=[
	[INFO]
	author: @halosviel
	created: 2026 February 20
	
	[DESCRIPTION]
	Takes the standard module and turns it into OOP whilst preserving the
	framework syntax.
	
	Runs .new() & .ready() when a new class is created like Bootstrap.
	
	[USAGE]
	Just add `class` after `return` like this:
	```
	return class {
		...
	}
	```
	
	[NOTES]
	- Taken from Pip & modified.
	- Make sure to rename the constructor method to "new".
	- The ready method is OPTIONAL.
]=]

-- [REQUIRES]
local expect = require("@game/ReplicatedFirst/renouveau/sys/expect")
-->

return function(class) --# keep return type generic !!
	expect("table", class)
	expect("function", class.new)
	if class.ready then
		expect("function", class.ready)
	end
	
	class.__index = class
	local originalNewFuntion = class.new
	
	class.new = function(...)
		local self = setmetatable({}, class)
		originalNewFuntion(self, ...)
		
		--# optional btw
		if class.ready then
			class.ready(self)
		end
		
		return self
	end
	
	return class
end