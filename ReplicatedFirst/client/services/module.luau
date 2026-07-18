--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	Module template.
]=]

local coreGui = require("@game/ReplicatedFirst/renouveau/packages/coreGui")

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	packages = {},
	libs = {},
	
	constructor = function(self: self)
		coreGui:setChatEnabled(false)
		task.wait(3)
		coreGui:setAllEnabled(false)
	end,
	
	ready = function(self: self)
		
	end,
}