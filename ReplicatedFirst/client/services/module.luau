--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	Module template.
]=]

local controls = require("@game/ReplicatedFirst/renouveau/packages/controls")

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	packages = {},
	libs = {},
	
	constructor = function(self: self)
		controls.disable()
	end,
	
	ready = function(self: self)
		
	end,
}