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
		sound:onDestroy(function()
			sound = nil
			print("sound gone", sound)
		end)
		sound:onDestroy(function()
			print("sound gone x2", sound)
		end)
	end,
	
	ready = function(self: self)
		
	end,
}