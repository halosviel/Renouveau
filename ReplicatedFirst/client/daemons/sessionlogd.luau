--[=[
	[INFO]
	author: @halosviel
	created: 2026 July 16
	
	[DESCRIPTION]
	Logs the session duration after the client leaves.
	Made for Studio playtest stats.
]=]

local types = require("../types/daemons")
type self = types.SessionLogD

return {
	runsFirst = true,
	dependencies = {},
	packages = {},
	libs = {},
	
	constructor = function(self: self)
		self.version = "1.0.0"
	end,
	
	ready = function(self: self)
		--## Session Start ##--
		
		print(`Renouveau {self.version}\n`)
		
		--## Session End ##--
		
		local startTimestamp: number = os.clock()
		
		local con: RBXScriptConnection
		con = game.Players.PlayerRemoving:Connect(function(player: Player)
			if player ~= game.Players.LocalPlayer then
				return
			end
			
			con:Disconnect()
			con = nil
			
			local playtime: number = math.floor(os.clock() - startTimestamp)
			print(`Goodbye! | Played for {playtime}s`)
		end)
	end,
}