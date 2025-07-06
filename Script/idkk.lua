local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid") or nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IndicatorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local gaypanel8 = Instance.new("Frame")
gaypanel8.Name = "gaypanel8"
gaypanel8.Size = UDim2.new(0, 280, 0, 130)
gaypanel8.AnchorPoint = Vector2.new(0.5, 1)
gaypanel8.Position = UDim2.new(0.5, 0, 1, -100)
gaypanel8.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
gaypanel8.BorderColor3 = Color3.fromRGB(0, 198, 255)
gaypanel8.BorderSizePixel = 1
gaypanel8.Parent = screenGui

local outerIndicatorBar = Instance.new("Frame")
outerIndicatorBar.Size = UDim2.new(1, 0, 0, 22)
outerIndicatorBar.Position = UDim2.new(0, 0, 0, 0)
outerIndicatorBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
outerIndicatorBar.BorderSizePixel = 0
outerIndicatorBar.Parent = gaypanel8

local outerIndicatorText = Instance.new("TextLabel")
outerIndicatorText.Size = UDim2.new(0, 100, 1, 0)
outerIndicatorText.Position = UDim2.new(0, 6, 0, 0)
outerIndicatorText.BackgroundTransparency = 1
outerIndicatorText.Text = "Indicator"
outerIndicatorText.Font = Enum.Font.Code
outerIndicatorText.TextColor3 = Color3.fromRGB(200, 200, 200)
outerIndicatorText.TextSize = 14
outerIndicatorText.TextXAlignment = Enum.TextXAlignment.Left
outerIndicatorText.Parent = outerIndicatorBar

local gayInner1 = Instance.new("Frame")
gayInner1.Size = UDim2.new(1, -4, 1, -24)
gayInner1.Position = UDim2.new(0, 2, 0, 22)
gayInner1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
gayInner1.BorderColor3 = Color3.fromRGB(60, 60, 60)
gayInner1.BorderSizePixel = 1
gayInner1.Parent = gaypanel8

local gayInner2 = Instance.new("Frame")
gayInner2.Size = UDim2.new(1, -4, 1, -4)
gayInner2.Position = UDim2.new(0, 2, 0, 2)
gayInner2.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
gayInner2.BorderColor3 = Color3.fromRGB(40, 40, 40)
gayInner2.BorderSizePixel = 1
gayInner2.Parent = gayInner1

local outerFrame = Instance.new("Frame")
outerFrame.Size = UDim2.new(1, -20, 0, 95)
outerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
outerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
outerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
outerFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
outerFrame.BorderSizePixel = 1
outerFrame.Parent = gayInner2

local inner1 = Instance.new("Frame")
inner1.Size = UDim2.new(1, -4, 1, -4)
inner1.Position = UDim2.new(0, 2, 0, 2)
inner1.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
inner1.BorderColor3 = Color3.fromRGB(60, 60, 60)
inner1.BorderSizePixel = 1
inner1.Parent = outerFrame

local inner2 = Instance.new("Frame")
inner2.Size = UDim2.new(1, -4, 1, -4)
inner2.Position = UDim2.new(0, 2, 0, 2)
inner2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
inner2.BorderColor3 = Color3.fromRGB(40, 40, 40)
inner2.BorderSizePixel = 1
inner2.Parent = inner1

local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, 0, 0, 1)
separator.Position = UDim2.new(0, 0, 0, 0)
separator.BackgroundColor3 = Color3.fromRGB(0, 198, 255)
separator.BorderSizePixel = 0
separator.Parent = inner2

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -10, 0, 14)
info.Position = UDim2.new(0, 5, 0, 3)
info.BackgroundTransparency = 1
info.Text = "Info"
info.Font = Enum.Font.Code
info.TextColor3 = Color3.fromRGB(180, 180, 180)
info.TextSize = 12
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = inner2

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 50, 0, 50)
avatar.Position = UDim2.new(0, 5, 0, 22)
avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
avatar.BorderSizePixel = 0
avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
avatar.Parent = inner2

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -65, 0, 14)
nameLabel.Position = UDim2.new(0, 60, 0, 22)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = player.DisplayName .. " [ " .. player.Name .. " ]"
nameLabel.Font = Enum.Font.Code
nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
nameLabel.TextSize = 13
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = inner2

local hpBar = Instance.new("Frame")
hpBar.Size = UDim2.new(1, -65, 0, 12)
hpBar.Position = UDim2.new(0, 60, 0, 60)
hpBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hpBar.BorderSizePixel = 0
hpBar.ClipsDescendants = true
hpBar.Parent = inner2

local hpFill = Instance.new("Frame")
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
hpFill.BorderSizePixel = 0
hpFill.Parent = hpBar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 255, 144)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 150, 10))
}
gradient.Rotation = 0
gradient.Parent = hpFill

local hpText = Instance.new("TextLabel")
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Text = "100/100"
hpText.Font = Enum.Font.Code
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hpText.TextStrokeTransparency = 0
hpText.TextSize = 10
hpText.Parent = hpBar

local function updateHealth()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hpText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
	hpFill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
	hum.HealthChanged:Connect(function(newHealth)
		local maxHealth = hum.MaxHealth
		local ratio = math.clamp(newHealth / maxHealth, 0, 1)
		hpFill:TweenSize(UDim2.new(ratio, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
		hpText.Text = math.floor(newHealth) .. "/" .. math.floor(maxHealth)
	end)
end

if player.Character then
	updateHealth()
end
player.CharacterAdded:Connect(updateHealth)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local locked = false
local targetPlayer = nil

local function getClosestPlayerToMouse()
	local mouse = player:GetMouse()
	local minDist = math.huge
	local closest = nil
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = other.Character.HumanoidRootPart
			local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
				if dist < minDist then
					minDist = dist
					closest = other
				end
			end
		end
	end
	return closest
end

local function updateTargetInfo(target)
	local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
	local avatarImg = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	avatar.Image = avatarImg
	nameLabel.Text = target.DisplayName .. " [ " .. target.Name .. " ]"
	hpText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
	hpFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
	humanoid.HealthChanged:Connect(function(newHealth)
		local ratio = math.clamp(newHealth / humanoid.MaxHealth, 0, 1)
		hpFill:TweenSize(UDim2.new(ratio, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
		hpText.Text = math.floor(newHealth) .. "/" .. math.floor(humanoid.MaxHealth)
	end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.T then
		if locked then
			locked = false
			targetPlayer = nil
			info.Text = "Info"
			avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			nameLabel.Text = player.DisplayName .. " [ " .. player.Name .. " ]"
			updateHealth()
		else
			local closest = getClosestPlayerToMouse()
			if closest and closest.Character and closest.Character:FindFirstChildOfClass("Humanoid") then
				locked = true
				targetPlayer = closest
				info.Text = "Target Locked"
				updateTargetInfo(targetPlayer)
			end
		end
	end
end)
