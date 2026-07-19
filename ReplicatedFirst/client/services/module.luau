--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	Module template.
]=]

local nodes = require("../nodes")

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	
	constructor = function(self: self)
	end,
	
	ready = function(self: self)
		
	end,
}