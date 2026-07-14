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
	- The module will perform a shallow search of the root folder for modules,
	meaning that nested modules will not be required.
	- The `runsFirst` property works only on the client. Server modules that use
	this property will be ignored.
]=]

-- [REQUIRES]
local expect = require("./expect")
local log = require("./log")

-- [TYPES]
type Module = {
	constructor: ( self: Module ) -> nil,
	ready: ( self: Module ) -> nil
} & any

type ClientModule = { --# appended to Module
	runsFirst: boolean
}

-->

return function(root: Folder)
	--## Validate ##--
	
	expect("Folder", root)
	
	local services: Folder? = root:FindFirstChild("services")
	if not services then
		log(2, "Missing `services` folder in root", _, {{ "root", root:GetFullName() }})
	end
	
	local daemons: Folder? = root:FindFirstChild("daemons")
	if not daemons then
		log(2, "Missing `daemons` folder in root", _, {{ "root", root:GetFullName() }})
	end
	
	--## Get collective module scripts ##--
	
	local moduleScripts: { ModuleScript } = {}
	local nonModuleScriptInstances: number = 0
	
	local function addCollectiveChildren(folder: Folder)
		for _, moduleScript: ModuleScript in folder:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				nonModuleScriptInstances += 1
				continue
			end
			table.insert(moduleScripts, moduleScript)
		end
	end
	
	addCollectiveChildren(services)
	addCollectiveChildren(daemons)
	
	if nonModuleScriptInstances > 0 then
		log(4, `{nonModuleScriptInstances} non-ModuleScript instances found. Did you misplace some instances?`, "ModuleScript caching")
	end
	
	--## Require modules ##--
	
	local modules: { Module } = {}
	
	local function errorHandler(moduleScript: ModuleScript, err: string)
		local moduleName: string = moduleScript.Name
		local moduleType: string = moduleScript.Parent.Name --# `service` or `daemon`
		
		log(4,
			`Module \`{moduleName}\` experienced a runtime error`,
			"Requiring modules",
			{
				{ "moduleType", moduleType },
				{ "err", err }
			}
		)
	end
	
	for _, moduleScript: ModuleScript in moduleScripts do
		local _, module: Module = xpcall(function()
			return require(moduleScript)
		end, function(err: string)
			errorHandler(moduleScript.Name, err)
		end)
		
		expect("function", module.constructor)
		expect("function", module.ready)
	end
end 