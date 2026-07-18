--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	Module template.
]=]

local applyKnockback = require("@game/ReplicatedFirst/renouveau/packages/applyKnockback")

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	packages = {},
	libs = {},
	
	constructor = function(self: self)
		applyKnockback(workspace.Rig.HumanoidRootPart)
	end,
	
	ready = function(self: self)
		
	end,
}