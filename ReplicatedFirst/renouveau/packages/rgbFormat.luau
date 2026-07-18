--[=[
	[INFO]
	author: @halosviel
	created: 2026 January 27
	
	[DESCRIPTION]
	A handy tool that converts a Color3 into a string, to be used in rich text markups.
	
	[USAGE]
	local myColor = toRGB(Color3.fromRGB(255, 255, 255))
	textLabel.Text = `<font color="{myColor}">Hello world!</font>`
]=]

local expect = require("@game/ReplicatedFirst/renouveau/sys/expect")

return function(color3: Color3) : string
	expect("Color3", color3)
	return `rgb({math.floor(color3.R * 255)}, {math.floor(color3.G * 255)}, {math.floor(color3.B * 255)})`
end