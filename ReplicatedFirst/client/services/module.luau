--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	Module template.
]=]

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	packages = { "soundUtils" },
	libs = {},
	
	constructor = function(self: self)
		self.packages.soundUtils.wrap("nyaaaa")
	end,
	
	ready = function(self: self)
		
	end,
}