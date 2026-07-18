--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	Module template.
]=]

local soundUtils = require("@game/ReplicatedFirst/renouveau/packages/soundUtils")

local types = require("../types/services")
type self = types.Module

return {
	runsFirst = false,
	dependencies = {},
	
	constructor = function(self: self)
		local sound: soundUtils.Sound = soundUtils.wrap("nyaaaa")
	end,
	
	ready = function(self: self)
		
	end,
}