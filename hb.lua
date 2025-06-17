-- <settings>
getgenv().centralhb = {
    Hitbox = {
        Size = 25,
        Transparency = 0.7,
        Color = Color3.fromRGB(0, 100, 255),
        OutlineColor = Color3.fromRGB(100, 200, 255),
        RefreshTime = 0.1,
        Lightning = {
            Enabled = true,
            Color = Color3.fromRGB(150, 200, 255),
            Transparency = 0.5,
            Emission = 0.5
        }
    },
    
    Visuals = {
        MainColor = Color3.fromRGB(40, 40, 40),
        SecondaryColor = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
        Gradient = {
            Color1 = Color3.fromRGB(0, 100, 255),
            Color2 = Color3.fromRGB(0, 50, 150),
            Rotation = 90
        },
        FadeSpeed = 0.1
    },
    
    Target = {
        LockKey = Enum.KeyCode.E,
        MaxDistance = 50,
        AvatarBG = Color3.fromRGB(60, 60, 60)
    }
}

-- <main code>
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CurrentTarget = nil
local TargetGUI = nil
local ActiveHitboxes = {}

local function CreateLightning(part)
    if not getgenv().centralhb.Hitbox.Lightning.Enabled then return end
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = part
    local attachment2 = Instance.new("Attachment")
    attachment2.Position = Vector3.new(0, part.Size.Y, 0)
    attachment2.Parent = part
    
    local lightning = Instance.new("Beam")
    lightning.Attachment0 = attachment1
    lightning.Attachment1 = attachment2
    lightning.Color = ColorSequence.new(getgenv().centralhb.Hitbox.Lightning.Color)
    lightning.Transparency = NumberSequence.new(getgenv().centralhb.Hitbox.Lightning.Transparency)
    lightning.LightEmission = getgenv().centralhb.Hitbox.Lightning.Emission
    lightning.LightInfluence = 0
    lightning.Width0 = 0.2
    lightning.Width1 = 0.2
    lightning.Texture = "rbxassetid://446111271"
    lightning.TextureSpeed = 2
    lightning.Parent = part
end

local function FadeIn(frame)
    frame.Visible = true
    frame.BackgroundTransparency = 1
    local tween = TweenService:Create(frame, TweenInfo.new(getgenv().centralhb.Visuals.FadeSpeed), {
        BackgroundTransparency = 0.3
    })
    tween:Play()
end

local function FadeOut(frame)
    local tween = TweenService:Create(frame, TweenInfo.new(getgenv().centralhb.Visuals.FadeSpeed), {
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        frame.Visible = false
    })
end

local function CreateTargetGUI(target)
    if TargetGUI then 
        FadeOut(TargetGUI.MainFrame)
        task.wait(getgenv().centralhb.Visuals.FadeSpeed)
        TargetGUI:Destroy() 
    end
    
    TargetGUI = Instance.new("ScreenGui")
    TargetGUI.Name = "TargetGUI"
    TargetGUI.Parent = game.CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 150)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = getgenv().centralhb.Visuals.MainColor
    MainFrame.BackgroundTransparency = 1
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = TargetGUI
    
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, getgenv().centralhb.Visuals.Gradient.Color1),
        ColorSequenceKeypoint.new(1, getgenv().centralhb.Visuals.Gradient.Color2)
    })
    UIGradient.Rotation = getgenv().centralhb.Visuals.Gradient.Rotation
    UIGradient.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = getgenv().centralhb.Visuals.SecondaryColor
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = "central"
    Title.TextColor3 = getgenv().centralhb.Visuals.TextColor
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.Code
    Title.TextSize = 16
    Title.Parent = TopBar
    
    local GradientLine = Instance.new("Frame")
    GradientLine.Size = UDim2.new(1, 0, 0, 2)
    GradientLine.Position = UDim2.new(0, 0, 0, 30)
    GradientLine.BackgroundColor3 = getgenv().centralhb.Hitbox.Color
    GradientLine.BackgroundTransparency = 0.5
    GradientLine.BorderSizePixel = 0
    GradientLine.Parent = MainFrame
    
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Size = UDim2.new(0, 80, 0, 80)
    AvatarFrame.Position = UDim2.new(0, 10, 0, 40)
    AvatarFrame.BackgroundColor3 = getgenv().centralhb.Target.AvatarBG
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.Parent = MainFrame
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(1, -10, 1, -10)
    Avatar.Position = UDim2.new(0, 5, 0, 5)
    Avatar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Avatar.BorderSizePixel = 0
    Avatar.Parent = AvatarFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 200, 0, 20)
    NameLabel.Position = UDim2.new(0, 100, 0, 40)
    NameLabel.Text = "Loading..."
    NameLabel.TextColor3 = getgenv().centralhb.Visuals.TextColor
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.Code
    NameLabel.TextSize = 16
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = MainFrame
    
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(0, 200, 0, 1)
    Separator.Position = UDim2.new(0, 100, 0, 65)
    Separator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Separator.BorderSizePixel = 0
    Separator.Parent = MainFrame
    
    local HealthBarBack = Instance.new("Frame")
    HealthBarBack.Size = UDim2.new(0, 200, 0, 20)
    HealthBarBack.Position = UDim2.new(0, 100, 0, 75)
    HealthBarBack.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HealthBarBack.BorderSizePixel = 0
    HealthBarBack.Parent = MainFrame
    
    local HealthBar = Instance.new("Frame")
    HealthBar.Size = UDim2.new(1, 0, 1, 0)
    HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    HealthBar.BorderSizePixel = 0
    HealthBar.Parent = HealthBarBack
    
    local ToolLabel = Instance.new("TextLabel")
    ToolLabel.Size = UDim2.new(0, 200, 0, 20)
    ToolLabel.Position = UDim2.new(0, 100, 0, 100)
    ToolLabel.Text = "Tool: None"
    ToolLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToolLabel.BackgroundTransparency = 1
    ToolLabel.Font = Enum.Font.Code
    ToolLabel.TextSize = 14
    ToolLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToolLabel.Parent = MainFrame
    
    FadeIn(MainFrame)
    
    local function UpdateGUI()
        if not target or not target.Parent then
            FadeOut(MainFrame)
            task.wait(getgenv().centralhb.Visuals.FadeSpeed)
            TargetGUI:Destroy()
            return
        end
        
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        
        if humanoid and root then
            local isPlayer = Players:GetPlayerFromCharacter(target)
            
            if isPlayer then
                NameLabel.Text = isPlayer.Name
                Avatar.Image = Players:GetUserThumbnailAsync(isPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            else
                NameLabel.Text = "ERR: 0x"..string.format("%X", math.random(100000, 999999))
                Avatar.Image = ""
            end
            
            HealthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            HealthBar.BackgroundColor3 = Color3.fromRGB(
                255 - (humanoid.Health / humanoid.MaxHealth * 255),
                humanoid.Health / humanoid.MaxHealth * 255,
                0
            )
            
            local tool = target:FindFirstChildOfClass("Tool")
            ToolLabel.Text = "Tool: "..(tool and tool.Name or "None")
        end
    end
    
    RunService.Heartbeat:Connect(UpdateGUI)
end

local function CreateHitbox(character)
    if ActiveHitboxes[character] then return ActiveHitboxes[character] end
    
    local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not root then return end
    
    local fake = Instance.new("Part")
    fake.Name = "CentralHitbox"
    fake.Size = Vector3.new(getgenv().centralhb.Hitbox.Size, getgenv().centralhb.Hitbox.Size, getgenv().centralhb.Hitbox.Size)
    fake.Transparency = getgenv().centralhb.Hitbox.Transparency
    fake.Color = getgenv().centralhb.Hitbox.Color
    fake.Material = Enum.Material.Neon
    fake.Anchored = false
    fake.CanCollide = false
    fake.Massless = true
    fake.CFrame = root.CFrame
    fake.Parent = character
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = fake
    weld.Parent = fake
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "HitboxHighlight"
    highlight.Adornee = fake
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = getgenv().centralhb.Hitbox.Color
    highlight.FillTransparency = 0.9
    highlight.OutlineColor = getgenv().centralhb.Hitbox.OutlineColor
    highlight.OutlineTransparency = 0
    highlight.Parent = fake
    
    CreateLightning(fake)
    ActiveHitboxes[character] = fake
    
    character.Destroying:Connect(function()
        ActiveHitboxes[character] = nil
    end)
    
    return fake
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == getgenv().centralhb.Target.LockKey and not gameProcessed then
        local target = nil
        local closestDistance = math.huge
        
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model ~= LocalPlayer.Character then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local root = humanoid and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
                
                if humanoid and humanoid.Health > 0 and root then
                    local distance = (LocalPlayer:GetMouse().Hit.Position - root.Position).Magnitude
                    if distance < closestDistance and distance < getgenv().centralhb.Target.MaxDistance then
                        closestDistance = distance
                        target = model
                    end
                end
            end
        end
        
        if target then
            CurrentTarget = target
            CreateTargetGUI(target)
            CreateHitbox(target)
        end
    end
end)

local function CharacterAdded(character)
    if character == LocalPlayer.Character then return end
    task.wait(1)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        CreateHitbox(character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(CharacterAdded)
end

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant ~= LocalPlayer.Character then
        task.wait(1)
        local humanoid = descendant:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            CreateHitbox(descendant)
        end
    end
end)

while getgenv().centralhb.Hitbox.Enabled do
    if CurrentTarget and CurrentTarget.Parent then
        CreateHitbox(CurrentTarget)
    end
    task.wait(getgenv().centralhb.Hitbox.RefreshTime)
end
