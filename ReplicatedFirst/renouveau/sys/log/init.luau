--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 11
	
	[DESCRIPTION]
	The framework's logging module.
	
	Logged messages take the form of blocks,  with multiple lines
]=]

type Field = {
	name: string,
	content: string
}

local codes = require("@self/codes")

--[[
	Define the logging method for each code.
]]
local codeFunctionMap = {
	[1] = warn,
	[2] = warn,
	[3] = warn,
	[4] = print
}

return setmetatable({}, {
	__call = function(_, code: number, text: string, fields: { Field }?)
		assert(typeof(code) == "number", `[!] Given code was not a number (got {typeof(code)})`)
		
		local title: string? = codes[code]
		if title == nil then
			error(`[!] {code} is not a valid code`)
		end
		
		
	end,
})