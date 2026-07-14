--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 11
	
	[DESCRIPTION]
	The framework's module loader.
	
	`root` in this case, is referred to the container (usually a folder) that
	the `services` and `daemons` folders are contained within. As long as those
	two folders are there, nothing else in the root matters.
	
	Instead of using requires,
	
	[NOTES]
	- The `runsFirst` property works only on the client. Server modules that use
	this property will be ignored.
]=]

-- [REQUIRES]
local expect = require("./expect")
local log = require("./log")
-->

return function(root: Folder)
	expect("Folder", root)
	
	local services: Folder? = root:FindFirstChild("services")
	if not services then
		log(2, "Missing `services` folder in root", _, {{ "root", root:GetFullName() }})
	end
	
	local daemons: Folder? = root:FindFirstChild("daemons")
	if not daemons then
		log(2, "Missing `daemons` folder in root", _, {{ "root", root:GetFullName() }})
	end
	
	
end 