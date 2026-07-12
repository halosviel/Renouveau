--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 12
	
	[DESCRIPTION]
	Module for validating variables. Meant to replace assert.
	If the query does not match any of the given types, it will throw a type error.
	
	Fixes a few issues from Pip's params module. Now you can use the "|" separator
	(inspired by Unix's Grep) in the query instead of a different function, and
	include an optional context string to pass to the Log module.
]=]

-- [REQUIRES]
local log = require("./log")

return function(types: string, query: any, context: string?)
	assert(typeof(types) == "string", `[!] Given \`target\` was not a string (got {typeof(types)})`)
	assert(query ~= nil, `[!] Given \`query\` was not a non-nil value (got {typeof(types)})`)
	
	if context ~= nil then
		assert(typeof(context) == "string", `[!] Given \`context\` was not a string (got {typeof(context)})`)
	end
	
	local typesArr: { string } = types:split("|")
	local matched: boolean = false
	
	for _, _type: string in ipairs(typesArr) do
		--# taken from params (Pip)
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
		log(1, "Type mismatch", context, {{ "types", table.concat(typesArr, ", ")}, { "queryType", typeof(query) }})
	end
end