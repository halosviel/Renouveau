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
	dependencies = {},
	packages = {},
	libs = { },
	
	constructor = function(self: self)
	end,

	test = function(self: self)
		warn('wsg gng')
	end,
	
	ready = function(self: self)
	end,
}