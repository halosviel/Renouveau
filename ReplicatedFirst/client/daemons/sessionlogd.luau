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
		self.JOIN_LOGS_ENABLED = true
		self.VERSION = "1.0.0"
	end,
	
	ready = function(self: self)
		--## Session Start ##--
		
		if self.JOIN_LOGS_ENABLED == true then
			print(`Renouveau {self.VERSION}\n`)
			
			--# functions from Pip's kofetch
			local function getNetworkStatus() : string
				local ping = math.floor(game.Players.LocalPlayer:GetNetworkPing() or 9 * 1000)
				local map = {
					{ 10, "Exceptional" },
					{ 50, "Good" },
					{ 100, "Alright" }
				}

				for i = 1, #map do
					local set = map[i]
					if ping < set[1] then
						return set[2]
					end
				end

				return "Bad"
			end

			local function getInput() : string
				local input: Enum.PreferredInput = game.UserInputService.PreferredInput
				local map = {
					[Enum.PreferredInput.Touch] = "Touch",
					[Enum.PreferredInput.Gamepad] = "Controller",
					[Enum.PreferredInput.KeyboardAndMouse] = "Keyboard/Mouse",
				}
				return map[input] or "Unknown"
			end

			local function getLocale() : string
				return game.LocalizationService.RobloxLocaleId or "Unknown"
			end
			
			print(`User:    {game.Players.LocalPlayer.DisplayName}@{game.Players.LocalPlayer.Name}`)
			print(`Input:   {getInput()}`)
			print(`Network: {getNetworkStatus()}`)
			print(`Locale:  {getLocale()}\n`)
		end
		
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