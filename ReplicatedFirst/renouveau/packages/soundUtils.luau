--[=[
	[INFO]
	author: @halosviel
	created: 2026 March 24
	
	[DESCRIPTION]
	A module that makes configuring audio much easier and removes repetition
	that would otherwise be predominant in manual sound management.
	
	Works by caching all Sounds in SoundService on runtime, then indexing them
	when needed.
	
	[USAGE]
	(1) soundUtils.getSound("SomeSound")
	(2) soundUtils.playSound("SomeSound")
	(3)
	soundUtils.wrap("SomeSound")
		:clone()
		:autoDestroy()
		:setParent(workspace.static.Spawn)
		:setRandomPitch(0.2)
		:play()
	
	[NOTES] 
	- No sound name duplicates are allowed whatsoever.
	- All chainable functions on an object should only be used once.
	- If the sound instance that the object is attached to will/might be destroyed
	  while the object exists, it is recommended to use :onDestroy() to set the
	  variable to nil from the outside. Example:
	  ```
	  local sound = soundUtils.wrap(part.MySound)
	  sound:onDestroy(function()
	  	sound = nil
	  end)
	  -- somewhere else:
	  part:Destroy() -- if onDestroy() was not set, the object would not be GC'd and
	                 -- still remain in memory.
	  ```
]=]

-- [REQUIRES]
local expect = require("@game/ReplicatedFirst/renouveau/sys/expect")
local log = require("@game/ReplicatedFirst/renouveau/sys/log")

local maid = require("@game/ReplicatedFirst/renouveau/libs/maid")

-- [TYPES]
type self = {
	--# SoundService functions
	
	getSound: ( self: self ) -> Sound,
	playSound: ( self: self ) -> nil,
	
	--# Class functions
	
	instance: Sound,
	onDestroyCallbacks: { () -> nil },
	maid: maid.Maid,
	
	wrap: ( query: string | Instance ) -> self,
	get: ( self: self, ( sound: Sound ) -> nil ) -> self,
	clone: ( self: self ) -> self,
	setParent: ( self: self, parent: BasePart ) -> self,
	setVolume: ( self: self, volume: number ) -> self,
	onDestroy: ( self: self, callback: () -> nil ) -> self,
	
	setRandomPitch: ( self: self, value: number ) -> self,
	setRandomPitchRange: ( self: self, min: number, max: number ) -> self,
	setLifetime: ( self: self, value: number ) -> self,
	autoDestroy: ( self: self ) -> self,
	
	play: ( self: self ) -> self,
	stop: ( self: self ) -> self,
	
	Destroy: ( self: self ) -> nil
}
export type Sound = self

-->

--## Cache & Preload ##--

if game:GetService("RunService"):IsClient() then
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
end

local cacheStartTimestamp = os.clock()

local soundCache: { [string]: Sound } = {}
local conflicts: { string } = {}

local sounds: { Sound } = {}
local soundCount = 0

for _, sound: Sound in game.SoundService:GetDescendants() do
	if not sound:IsA("Sound") then
		continue
	end
	
	soundCount += 1
	
	local soundName = sound.Name
	if soundCache[soundName] then
		table.insert(conflicts, soundName)
		continue
	end
	
	table.insert(sounds, sound)
	soundCache[soundName] = sound
end

local cacheTotalDuration: number = os.clock() - cacheStartTimestamp
local conflictSuffix: string = #conflicts == 1 and "" or "s"

local soundCountSuffix: string = soundCount == 1 and "" or "s"
local cacheDuration: number = math.floor(cacheTotalDuration * 100) / 100
--print(`Cached {soundCount} sound{soundCountSuffix} in {cacheDuration}s ({#conflicts} conflict{conflictSuffix})`)

if #conflicts > 0 then
	log(2, `{tostring(#conflicts)} naming conflict{conflictSuffix} found`, "Caching sounds", {{ "conflicts", table.concat(conflicts, ", ") }})
end

task.spawn(function()
	xpcall(function()
		game.ContentProvider:PreloadAsync(sounds)
	end, function(err: string)
		log(4, "Sound preloading failed", "Post-cache sound preloading", {{ "err", err }})
	end)
end)


--## SoundService functions ##--

local SoundUtils = {} :: self

--[[
	Returns a sound from the sound cache.
]]
function SoundUtils.getSound(soundName: string) : Sound
	expect("string", soundName)
	
	local index: Sound? = soundCache[soundName]
	if index == nil then
		log(3, "Sound does not exist. Typo or setup error expected", "Called `.getSound()`", {{ "sound", soundName }})
		return
	end
	
	return index
end

--[[
	Play a sound from the sound cache.
	Note: Directly plays the sound in SoundService.
]]
function SoundUtils.playSound(soundName: string)
	expect("string", soundName)
	SoundUtils.getSound(soundName):Play()
end


--## Class functions ##--

--[[
	Takes a sound name or a sound instance and turns it into a class.
	If a string is passed, it will index the soundCache to find the sound.
	If a Sound instance is passed, it will use that instance directly.
]]
function SoundUtils.wrap(query: string | Instance) : self
	expect("string|Sound", query)
	
	local soundInstance: Sound = typeof(query) == "Instance" and query or SoundUtils.getSound(query)
	local self: self = setmetatable({
		instance = soundInstance,
		onDestroyCallbacks = {},
		maid = maid.new()
	}, SoundUtils :: self)
	
	self.maid:GiveTask(self.instance.AncestryChanged:Connect(function(_: Instance, parent: Instance)
		if parent == nil then
			log(4, "Destroyed Sound instance attached to class during lifecycle. Instance may not be GC'd", "`AncestryChanged` event fired",
				{{ "instanceName", self.instance.name }}
			)
			self:Destroy()
		end
	end))
	
	self.maid:GiveTask(self.instance.Destroying:Connect(function()
		log(4, "Destroyed Sound instance attached to class during lifecycle. Instance may not be GC'd", "`Destroyed` event fired",
			{{ "instanceName", self.instance.name }}
		)
		self:Destroy()
	end))
	
	return self
end

--[[
	Takes and calls the given callback, passing self.instance
	(the sound instance) as its only parameter.
]]
function SoundUtils:get(callback: ( sound: Sound ) -> nil) : self
	expect("function", callback)
	callback(self.instance)
	return self
end

--[[
	Reassigns self.instance as its clone, but does
	not destroy the original!!
	
	Use only once, there is no prot bc im too lazy.
]]
function SoundUtils:clone() : self
	self.instance = self.instance:Clone()
	return self
end

function SoundUtils:setParent(parent: BasePart) : self
	expect("Instance", parent)
	self.instance.Parent = parent
	return self
end

function SoundUtils:setVolume(volume: number) : self
	expect("number", volume)
	self.instance.Volume = volume
	return self
end

--[[
	Adds a callback to be called when Destroy() is called or when the sound
	is destroyed.
	
	[NOTES]
	- This method can be used to detect whether the sound has finished when
	  alongside `autoDestroy()`.
	- This method can be called multiple times! It will add each function to
	  an array where all functions within will be called when the object is
	  destroyed.
	- As the notes say, it is recommended to attach a :onDestroy() to a sound
	  object if its sound instance is expected to be destroyed during the
	  object's lifetime.
]]
function SoundUtils:onDestroy(callback: () -> nil) : self
	expect("function", callback)
	table.insert(self.onDestroyCallbacks, callback)
	return self
end

--[[
	If attached, the sound and object will destroy after playing once.
	
	[NOTES]
	- Does not support looped audios since `.Ended` would not fire.
	- Does not warn if so since this looping changed dynamically.
]]
function SoundUtils:autoDestroy() : self
	self.maid:GiveTask(self.instance.Ended:Once(function()
		self:Destroy()
	end))
	return self
end

--[[
	Assigns a random PlaybackSpeed from the range constructed from the value given.
]]
function SoundUtils:setRandomPitch(value: number) : self
	expect("number", value)
	self.instance.PlaybackSpeed += math.random(-value * 100, value * 100) / 100
	return self
end

--[[
	Assigns a random PlaybackSpeed from the range constructed from the range given.
]]
function SoundUtils:setRandomPitchRange(min: number, max: number) : self
	expect("number", min)
	expect("number", max)
	self.instance.PlaybackSpeed += math.random(-min * 100, max * 100) / 100
	return self
end

--[[
	Adds the sound to the Debris service with the lifetime being the value given.
]]
function SoundUtils:setLifetime(value: number) : self
	expect("number", value)
	game.Debris:AddItem(self.instance, value)
	return self
end

function SoundUtils:play() : self
	self.instance:Play()
	return self
end

function SoundUtils:stop() : self
	self.instance:Stop()
	return self
end

function SoundUtils:Destroy()
	pcall(function()
		self.instance:Destroy()
	end)
	
	if self.maid then
		self.maid:DoCleaning()
		self.maid = nil
	end
	
	for _, callback: () -> nil in self.onDestroyCallbacks do
		callback()
	end
	table.clear(self.onDestroyCallbacks)
	
	setmetatable(self, nil)
	table.clear(self)
end

SoundUtils.__index = SoundUtils
return SoundUtils