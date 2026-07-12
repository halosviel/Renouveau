--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 11
	
	[DESCRIPTION]
	The framework's logging module.
	
	Logged messages take the form of blocks, with multiple lines
	
	[NOTES]
	- A "field", both in the codes module and here, refers to a row (key value pair) in dictionaries.
]=]

-- [CONFIG]
local SEPARATOR = "==>" --# the beginning string at the start of a new line
local INFO_LEVEL = 3 --# how deep debug.info will initially search
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

--# taken from Pip :P
local function getSource() : ( string, string )
	local infoLevel = INFO_LEVEL
	
	local path: string = debug.info(infoLevel, "s")
	local scriptName: string = path and path:match("[^%.]+$") or "Unknown"
	
	--# june 29 update: hardcoded case - if it comes from params module, add 1 to the level
	--# fixes ambiguous message since params becomes the source
	if scriptName == "params" then
		infoLevel += 1
		--# just recalc
		path = debug.info(infoLevel, "s")
		scriptName = path and path:match("[^%.]+$") or "Unknown"
	end
	
	local result = scriptName:gsub("(%u)", " %1")
	
	local line: number = debug.info(infoLevel, "l") or "0"
	return scriptName, line
end

return function(code: number, text: string, context: string?, fields: { Field }?)
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
	local fieldsStr: string? = fields ~= nil and (function()
		assert(#fields > 0, `[!] Given \`fields\` is an empty table - populate it!`)
		local strings = {}
		for _, field: Field in fields do
			assert(typeof(field.title) == "string", `[!] Given field \`title\` was not a string (got {typeof(field.title)})`)
			--# no need to assert field.content. let's just auto-stringify it :D
			local str: string = `{SEPARATOR} {field.title}: {tostring(field.content)}`
			table.insert(strings, str)
		end
		return table.concat(strings, "\n")
	end)()
	
	local message = `{codeInfo.title}\n{textField}`
	if contextField then
		message = `{message}\n{contextField}`
	end
	if fieldsStr then
		message = `{message}\n{fieldsStr}`
	end
	
	local scriptName: string, line: string = getSource()
	message = `{message}\n{SEPARATOR} at line {line} of {scriptName}`
	
	codeInfo.callback(message)
end