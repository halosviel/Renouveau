--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 14
	
	[DESCRIPTION]
	Module template.
]=]

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	packages = {},
	libs = {},
	
	constructor = function(self: self)
	end,
	
	ready = function(self: self)
		
	end,
}