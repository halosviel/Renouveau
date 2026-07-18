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
		task.delay(2, function()
			applyKnockback(workspace.Rig.HumanoidRootPart, Vector3.new(50, 0, 50), 0.5, 10)
		end)
	end,
	
	ready = function(self: self)
		
	end,
}