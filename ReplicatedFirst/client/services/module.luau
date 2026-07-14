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
	libs = { "promise" },
	
	constructor = function(self: self)
		print(self)
		self.SOME_SETTING = "here"
	end,
	
	ready = function(self: self)
		self.libs.promise.new(function(resolve:(...any) -> (), reject:(...any) -> ())
			print("promise resolved!")
			resolve()
		end)
	end,
}