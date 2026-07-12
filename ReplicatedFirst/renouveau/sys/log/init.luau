--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 11
	
	[DESCRIPTION]
	The framework's logging module.
	
	Logged messages take the form of blocks, with multiple lines
	
	[NOTES]
	A "field", both in the codes module and here, refers to a row (key value pair) in dictionaries.
]=]

-- [CONFIG]
local SEPARATOR = "==>" -- the beginning string at the start of a new line
-->

type Field = {
	title: string,
	content: string
}

local codes = require("@self/codes")

--# validate codes modules
for code: number, codeInfo: codes.CodeInfo in codes do
	assert(typeof(codeInfo.title) == "string", `[!] \`title\` for {tostring(code)} was not a number (got {typeof(codeInfo.title)})`)
	assert(typeof(codeInfo.callback) == "function", `[!] \`callback\` for {tostring(code)} was not a callback (got {typeof(codeInfo.callback)})`)
end

-->

return setmetatable({}, {
	__call = function(_, code: number, text: string, context: string?, fields: { Field }?)
		--# validate input
		
		local codeStr: string = tostring(code)
		assert(typeof(code) == "number", `[!] Given \`code\` was not a number (got {typeof(code)})`)
		
		local codeInfo: codes.CodeInfo? = codes[code]
		if codeInfo == nil then
			error(`[!] No code info found for code {codeStr}`)
		end
		
		assert(typeof(text) == "string", `[!] Given \`text\` was not a string (got {typeof(text)})`)
		
		if context ~= nil then
			assert(typeof(context) == "string", `[!] Given \`context\` was not a string (got {typeof(context)})`)
		end
		
		if fields ~= nil then
			assert(typeof(fields) == "table", `[!] Given \`context\` was not a table (got {typeof(fields)})`)
		end
		
		--# output message
		
		local textField: string = `{SEPARATOR} text: {text}`
		local contextField: string? = context ~= nil and `{SEPARATOR} context: {context}`
		local fieldsStr: string? = fields ~= nil and function()
			local str: string = ""
			for _, field: Field in fields do
				assert(typeof(field.title) == "string", `[!] Given field \`title\` was not a string (got {typeof(field.title)})`)
				--# no need to assert field.content. let's just auto-stringify it :D
				str = `{str}{SEPARATOR} {field.title}: {tostring(field.content)}\n`
			end
		end
		
		local message = `{codeInfo.title}\n{textField}`
		if contextField then
			message = `{message}\n{contextField}`
		end
		if fieldsStr then
			message = `{message}\n{fieldsStr}`
		end
		message = `{message}\n{SEPARATOR} at TODO}`
		
		codeInfo.callback(message)
	end,
})