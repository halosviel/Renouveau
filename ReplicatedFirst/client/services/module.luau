--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 14
	
	[DESCRIPTION]
	Module template.
]=]

local types = require("../types/services")
type self = types.MyModule

return {
	runsFirst = true,
	dependencies = { "module1" },
	packages = {},
	libs = {},
	
	constructor = function(self: self)
		
	end,
	
	ready = function(self: self)
		print(self)
		self.dependencies.module1:test()
	end,
}