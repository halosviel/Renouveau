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
local signal = require("@game/ReplicatedFirst/renouveau/libs/cuteSignal")

type self = {
	MILESTONES: { number },
	name: string,
	callback: () -> nil,
	startTimestamp: number,
	thread: thread,
	destroyed: boolean,
	onUpdate: signal.Signal,
	new: ( self: self ) -> nil,
	Destroy: ( self: self ) -> nil,
	ready: ( self: self ) -> nil
}
export type ProcessClock = self

return class {
	new = function(self: self, name: string, callback: () -> nil)
		expect("string", name)
		expect("function", callback)
		
		self.MILESTONES = { 5, 15, 30, 60, 120, 300, 600, 1000 }
		
		self.name = name
		self.callback = callback
		
		self.startTimestamp = os.clock()
		self.thread = nil
		self.destroyed = false
		self.onUpdate = signal.new()
	end,
	
	Destroy = function(self: self)
		if self.destroyed == true then
			return
		end
		self.destroyed = true
		
		if self.onUpdate then
			self.onUpdate:Destroy()
			self.onUpdate = nil
		end
		
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
				
				local elapsed: number = math.floor(os.clock() - self.startTimestamp)
				self.onUpdate:Fire(elapsed)
				
				--# clanker warns of drift, but i doubt it
				if elapsed == self.MILESTONES[index] then
					warn(`Process \`{self.name}\` taking longer than usual ({self.MILESTONES[index]}s)`)
					index += 1
					
					if self.MILESTONES[index] == nil then
						warn(`Process \`{self.name}\` timed out ({self.MILESTONES[index - 1] or "?"}s)`)
						self:Destroy()
						return
					end
				end
			end
		end)
	end,
}