--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 12
	
	[DESCRIPTION]
	Module for validating variables. Meant to replace assert.
]=]

return setmetatable({}, {
	__call = function(_, types: string, query: any)
		assert(typeof(types) == "string", `[!] Given \`target\` was not a string (got {typeof(types)})`)
		assert(query, `[!] Given \`query\` was not a non-nil value (got {typeof(types)})`)
		
		
	end,
})