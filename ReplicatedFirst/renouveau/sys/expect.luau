--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 12
	
	[DESCRIPTION]
	Module for validating variables. Meant to replace assert.
	
	Combines functions from the old params module (Pip) into one that accepts
	multiple types as the first parameter (separated by "|").
]=]

-- [REQUIRES]
local log = require("./log")

return function(types: string, query: any)
	assert(typeof(types) == "string", `[!] Given \`target\` was not a string (got {typeof(types)})`)
	assert(query, `[!] Given \`query\` was not a non-nil value (got {typeof(types)})`)
	
	local typesArr: { string } = types:split("|")
	local matched: boolean = false
	
	for _type: string in typesArr do
		local match: boolean = _type == query
			or _type == typeof(query)
			or (typeof(query) == "Instance"
				and type(_type) == "string"
				and query:IsA(_type))
		
		if match then
			matched = true
			break
		end
	end
	
	if matched == false then
		log()
	end
end