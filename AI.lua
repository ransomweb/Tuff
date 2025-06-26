local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local mapTemplate = ReplicatedStorage:WaitForChild("MapTemplate"):WaitForChild("Map")
local currentMapFolder = Workspace:FindFirstChild("CurrentMap")

-- Function to reset map
local function resetMap()
	-- Remove previous map if any
	for _, child in pairs(currentMapFolder:GetChildren()) do
		child:Destroy()
	end

	-- Clone the original map
	local newMap = mapTemplate:Clone()
	newMap.Parent = currentMapFolder
end

-- Load once at game start
resetMap()

-- Listen to chat
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message:lower() == "!resetmap" then
			resetMap()
		end
	end)
end)
