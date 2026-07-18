--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 11
	
	[DESCRIPTION]
	The framework's module loader.
	
	`root` in this case, is referred to the container (usually a folder) that
	the `services` and `daemons` folders are contained within. As long as those
	two folders are there, nothing else in the root matters.
	
	[TAGS]
	Tags you can assign to modules for customised boot behaviour:
	- Ignore: The module will not be required at all -> good for storage/util modules.
	- DontRun: The module will be required and have its dependencies injected, but
	  `constructor()` and `ready()` will not be called on it -> good for classes.
	
	[NOTES]
	- The module will perform a deep search of the root folder for modules,
	  meaning that nested modules will be required. Use the `Ignore` tag if you do NOT
	  want a module required.
	- Modules with runtime errors on require, `constructor`, or `ready` are not skipped/handled!
	  Errors in these stages must be immediately fixed.
	- The `runsFirst` property only works on the client. Server modules that use this
	  property will incur no effect.
	- No two module names can be the same!
]=]

local expect = require("./expect")
local log = require("./log")
local processClock = require("./processClock")

type Module = {
	dependencies: { string },
	constructor: ( self: Module ) -> nil,
	ready: ( self: Module ) -> nil
} & any

type ClientModule = { --# appended to Module
	runsFirst: boolean
}

type ModuleData = {
	moduleScript: ModuleScript,
	module: Module
}

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
	
	--## Start process clock ##--
	
	local clock: processClock.ProcessClock
	clock = processClock.new("Boot", function()
		clock = nil
	end)
	
	local startTimestamp: number = os.clock()
	
	--## Get collective module scripts ##--
	
	local moduleScripts: { ModuleScript } = {}
	local nonModuleScriptInstances: number = 0
	
	local function addCollectiveChildren(folder: Folder)
		for _, moduleScript: ModuleScript in folder:GetDescendants() do
			if moduleScript:IsA("Folder") then
				continue
			end
			
			if table.find(moduleScript:GetTags(), "BootIgnore") then
				continue
			end
			
			if not moduleScript:IsA("ModuleScript") then
				nonModuleScriptInstances += 1
				continue
			else
				table.insert(moduleScripts, moduleScript)
			end
		end
	end
	
	addCollectiveChildren(services)
	addCollectiveChildren(daemons)
	
	if nonModuleScriptInstances > 0 then
		log(2, `{nonModuleScriptInstances} non-ModuleScript instances found. Did you misplace some instances?`, "ModuleScript caching")
	end
	
	--## Require & cache modules ##--
	--# modules will be added to the tables below based on whether
	--# their `runsFirst` property is true.
	
	local priorityModules: { ModuleData } = {}
	local modules: { ModuleData } = {}
	local allModules: { ModuleData } = {} --# both tables ^ in one
	
	local function errorHandler(context: string, moduleScript: ModuleScript, err: string)
		local moduleName: string = moduleScript.Name
		local moduleType: string = moduleScript.Parent.Name:sub(1, #moduleScript.Parent.Name - 1) --# `service` or `daemon`
		
		log(4, --# warn instead of error bc ts is in a pcall
			`Module \`{moduleName}\` experienced an error`,
			context,
			{
				{ "err", err },
				{ "moduleType", moduleType }
			}
		)
	end
	
	for _, moduleScript: ModuleScript in moduleScripts do
		local _, module: Module = xpcall(function()
			return require(moduleScript)
		end, function(err: string)
			errorHandler("Requiring modules", moduleScript, err)
		end)
		
		--# validate structure
		expect("table", module)
		expect("table", module.dependencies)
		
		--# classes have new instead of constructor. Accept one or the other.
		if module.new == nil then
			expect("function", module.constructor)
		else
			expect("function", module.new)
		end
		
		expect("function", module.ready)
		
		local moduleData: ModuleData = {
			moduleScript = moduleScript,
			module = module
		} :: ModuleData
		
		if game.RunService:IsClient() then
			local clientModule: Module & ClientModule = module --# just add client type
			local targetTable = clientModule.runsFirst == true and priorityModules or modules

			--# we gotta keep track of the name & parent for error handling,
			--# so just add entire ModuleScript to make it easier.
			table.insert(targetTable, moduleData)
		else
			table.insert(modules, moduleData)
		end
		
		allModules[moduleData.moduleScript.Name] = moduleData
	end
	
	--## Add dependencies ##--
	--# This works by replacing each table with a new one, where its
	--# required module is the value, and the old reference as its key.
	--#
	--# Example:
	--#
	--# dependencies = { "someModule", "anotherModule" }
	--# to
	--#	dependencies = { someModule = SomeModule, anotherModule = AnotherModule } --# required modules
	--#
	
	local function getDependencies(source: { Module } | Instance, names: { string })
		local newTable: { [string]: any } = {}
		
		for _, name: string in names do
			if typeof(source) == "table" then
				local moduleData: ModuleData = source[name]
				newTable[name] = moduleData.module
			elseif typeof(source) == "Instance" then
				newTable[name] = require(source:FindFirstChild(name))
			end
		end
		
		return newTable
	end
	
	for _, moduleData: ModuleData in allModules do
		if #moduleData.module.dependencies > 0 then
			moduleData.module.dependencies = getDependencies(allModules, moduleData.module.dependencies)
		end
	end
	
	--## Call modules ##--
	
	local function init(_modules: { ModuleData })
		--## Call constructor ##--
		
		for _, moduleData: ModuleData in _modules do
			if table.find(moduleData.moduleScript:GetTags(), "DontRun") then
				continue
			end
			
			xpcall(function()
				moduleData.module:constructor()
			end, function(err: string)
				errorHandler("Running `constructor()`", moduleData.moduleScript, err)
			end)
		end
		
		--## Call ready ##--
		
		for _, moduleData: ModuleData in _modules do
			if table.find(moduleData.moduleScript:GetTags(), "DontRun") then
				continue
			end
			
			xpcall(function()
				moduleData.module:ready()
			end, function(err: string)
				errorHandler("Running `ready()`", moduleData.moduleScript, err)
			end)
		end
	end
	
	if game.RunService:IsClient() then
		init(priorityModules)
		
		--# non-priority modules
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
	end
	
	init(modules)
	clock:Destroy()
	
	print(`Booted {#priorityModules + #modules} modules in {math.floor((os.clock() - startTimestamp) * 100) / 100}s`)
end