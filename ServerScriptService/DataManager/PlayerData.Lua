--[[ 
    ProfileStore Integration using MadStudioRoblox's ProfileStore module
    
    This script:
      • Creates a ProfileStore called "PlayerData" with default keys:
          - psid: a unique support id (generated if not present)
          - username: the player's name
          - coins: initial coin amount (0)
      • Loads or creates the player's profile on join,
        secures it with AddUserId(), and reconciles the default template.
      • On player leave, ends the session and saves their data.
--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ProfileStore = require(game.ServerScriptService:WaitForChild("ProfileStore"))

-- Default data template for each player's profile.
local DEFAULT_TEMPLATE = {
	psid = nil,      -- Unique support id (to be generated on first join)
	username = "",   -- Player's username
	coins = 0,       -- Starting coin count
}

-- Create the ProfileStore "PlayerData" using our default template.
local PlayerDataStore = ProfileStore.New("PlayerData", DEFAULT_TEMPLATE)

-- Table to keep track of active profiles.
local ActiveProfiles = {}

Players.PlayerAdded:Connect(function(player)
	-- Create a unique key for the player using their UserId.
	local profileKey = "Player_" .. tostring(player.UserId)

	-- Load (or create) the player's profile for an active session.
	local profile = PlayerDataStore:StartSessionAsync(profileKey, {Steal = false})

	if profile then
		-- Secure the profile by associating it with the player's UserId.
		profile:AddUserId(player.UserId)

		-- Reconcile the profile so that any missing keys from the template are filled.
		profile:Reconcile()

		-- Generate a unique psid if one isn’t present.
		if not profile.Data.psid then
			profile.Data.psid = HttpService:GenerateGUID(false)
		end

		-- Update the username with the player's current name.
		profile.Data.username = player.Name

		ActiveProfiles[player] = profile
	else
		-- If the profile fails to load, kick the player to avoid issues.
		player:Kick("Failed to load your profile. Please try rejoining.")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local profile = ActiveProfiles[player]
	if profile then
		-- End the session, which automatically saves the profile data.
		profile:EndSession()
		ActiveProfiles[player] = nil
	end
end)
