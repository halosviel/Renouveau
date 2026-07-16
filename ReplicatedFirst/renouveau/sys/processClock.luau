--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 15
	
	[DESCRIPTION]
	A rewrite of Pip's processTimer module.
	
	The module allows scripts to create a class, which as long
	as it is alive, will push warns across milestones indicating
	that a process is still running and taking longer than expected.
	
	[USAGE]
	```
	local clock: processClock.ProcessClock
	clock = processClock.new("myProcessClock", function()
		clock = nil
	end)
	```
	
	[NOTES]
	- The second parameter is the on-finish/Destroy callback.
	- The class can be destroyed mid-execution :D
	- The callback is not pcalled. It assumes that the caller is just
	  setting the object to nil (what more are you to do when a
	  timer finishes anyway?).
]=]

local class = require("./class")
local expect = require("./expect")

type self = {
	MILESTONES: { number },
	name: string,
	callback: () -> nil,
	startTimestamp: number,
	thread: thread,
	destroyed: boolean,
	new: ( self: self ) -> nil,
	Destroy: ( self: self ) -> nil,
	ready: ( self: self ) -> nil
}
export type ProcessClock = self

return class {
	new = function(self: self, name: string, callback: () -> nil)
		expect("string", name)
		expect("function", callback)
		
		self.MILESTONES = { 2, 5, 10, 15, 30, 60, 120, 300, 600, 1000 }
		
		self.name = name
		self.callback = callback
		
		self.startTimestamp = os.clock()
		self.thread = nil
		self.destroyed = false
	end,
	
	Destroy = function(self: self)
		if self.destroyed == true then
			return
		end
		self.destroyed = true
		
		self.callback()
	end,
	
	ready = function(self: self)
		self.thread = task.spawn(function()
			local index: number = 1
			
			while true do
				task.wait(1)
				
				if self.destroyed == true then
					return
				end
				
				--# clanker warns of drift, but i doubt it
				if math.floor(os.clock() - self.startTimestamp) == self.MILESTONES[index] then
					--print(`milestone reached | index: {index} | milestone: {self.MILESTONES[index]}s`)
					index += 1
					
					if self.MILESTONES[index] == nil then
						--print(`processClock {self.name} finished`)
						self:Destroy()
						return
					end
				end
			end
		end)
	end,
}