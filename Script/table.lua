local config = {
    Enabled = true,
    Prediction = 0.127,
    Bone = "HumanoidRootPart",
    Keybind = "T",
    FlyKey = Enum.KeyCode.Z,
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 2,
    FOVRadius = 60,
    FOVColor = Color3.fromRGB(255, 255, 255),
    HighlightFill = Color3.fromRGB(255, 0, 0),
    HighlightOutline = Color3.fromRGB(255, 255, 255),
    JumpOffset = 0,
    UIVisible = false
}

local gameMethodMap = {
    [2788229376] = "UpdateMousePosI2",
    [7213786345] = "UpdateMousePosI2",
    [84366677940861] = "MOUSE",
    [77369032494150] = "MOUSE",
[132813051297954] = "UpdateMousePos" -- yeno gay
}

local Utility = { Method = "UpdateMousePos" }
local placeId = game.PlaceId
Utility.Method = gameMethodMap[placeId] or "UpdateMousePos"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local Tracer = Drawing.new("Line")
Tracer.Visible = false
Tracer.Color = config.TracerColor
Tracer.Thickness = config.TracerThickness

local FOV = Drawing.new("Circle")
FOV.Visible = true
FOV.Color = config.FOVColor
FOV.Radius = config.FOVRadius
FOV.Filled = false
FOV.Thickness = 1

local Highlight = Instance.new("Highlight")
Highlight.FillColor = config.HighlightFill
Highlight.OutlineColor = config.HighlightOutline
Highlight.FillTransparency = 0.5
Highlight.OutlineTransparency = 0
Highlight.Enabled = false
Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
Highlight.Parent = game:GetService("CoreGui")

local Target
local Final = Vector3.zero
local MainRemote
local FlyEnabled = false

if game.ReplicatedStorage:FindFirstChild("MainEvent") then
    MainRemote = game.ReplicatedStorage.MainEvent
elseif game.ReplicatedStorage:FindFirstChild("MAINEVENT") then
    MainRemote = game.ReplicatedStorage.MAINEVENT
end

if not gameMethodMap[placeId] then
    if MainRemote and MainRemote:FindFirstChild("UpdateMousePosI2") then
        Utility.Method = "UpdateMousePosI2"
    end
end

local function Notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
end

-- Custom UI Creation
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SilentAimUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = config.UIVisible
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Title.Text = "Silent Aim Config"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = MainFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.Parent = MainFrame

    CloseButton.MouseButton1Click:Connect(function()
        config.UIVisible = false
        MainFrame.Visible = false
    end)

    local PredictionLabel = Instance.new("TextLabel")
    PredictionLabel.Name = "PredictionLabel"
    PredictionLabel.Size = UDim2.new(1, -20, 0, 20)
    PredictionLabel.Position = UDim2.new(0, 10, 0, 40)
    PredictionLabel.BackgroundTransparency = 1
    PredictionLabel.Text = "Prediction: " .. tostring(config.Prediction)
    PredictionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PredictionLabel.Font = Enum.Font.Gotham
    PredictionLabel.TextSize = 12
    PredictionLabel.TextXAlignment = Enum.TextXAlignment.Left
    PredictionLabel.Parent = MainFrame

    local PredictionBox = Instance.new("TextBox")
    PredictionBox.Name = "PredictionBox"
    PredictionBox.Size = UDim2.new(1, -20, 0, 25)
    PredictionBox.Position = UDim2.new(0, 10, 0, 60)
    PredictionBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    PredictionBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PredictionBox.Font = Enum.Font.Gotham
    PredictionBox.TextSize = 12
    PredictionBox.Text = tostring(config.Prediction)
    PredictionBox.Parent = MainFrame

    PredictionBox.FocusLost:Connect(function()
        local num = tonumber(PredictionBox.Text)
        if num then
            config.Prediction = num
            PredictionLabel.Text = "Prediction: " .. tostring(config.Prediction)
            Notify("Prediction Updated", "Set to: " .. tostring(config.Prediction))
        else
            PredictionBox.Text = tostring(config.Prediction)
        end
    end)

    local JumpOffsetLabel = Instance.new("TextLabel")
    JumpOffsetLabel.Name = "JumpOffsetLabel"
    JumpOffsetLabel.Size = UDim2.new(1, -20, 0, 20)
    JumpOffsetLabel.Position = UDim2.new(0, 10, 0, 95)
    JumpOffsetLabel.BackgroundTransparency = 1
    JumpOffsetLabel.Text = "Jump Offset: " .. tostring(config.JumpOffset)
    JumpOffsetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumpOffsetLabel.Font = Enum.Font.Gotham
    JumpOffsetLabel.TextSize = 12
    JumpOffsetLabel.TextXAlignment = Enum.TextXAlignment.Left
    JumpOffsetLabel.Parent = MainFrame

    local JumpOffsetBox = Instance.new("TextBox")
    JumpOffsetBox.Name = "JumpOffsetBox"
    JumpOffsetBox.Size = UDim2.new(1, -20, 0, 25)
    JumpOffsetBox.Position = UDim2.new(0, 10, 0, 115)
    JumpOffsetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    JumpOffsetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumpOffsetBox.Font = Enum.Font.Gotham
    JumpOffsetBox.TextSize = 12
    JumpOffsetBox.Text = tostring(config.JumpOffset)
    JumpOffsetBox.Parent = MainFrame

    JumpOffsetBox.FocusLost:Connect(function()
        local num = tonumber(JumpOffsetBox.Text)
        if num then
            config.JumpOffset = num
            JumpOffsetLabel.Text = "Jump Offset: " .. tostring(config.JumpOffset)
            Notify("Jump Offset Updated", "Set to: " .. tostring(config.JumpOffset))
        else
            JumpOffsetBox.Text = tostring(config.JumpOffset)
        end
    end)

    local FOVLabel = Instance.new("TextLabel")
    FOVLabel.Name = "FOVLabel"
    FOVLabel.Size = UDim2.new(1, -20, 0, 20)
    FOVLabel.Position = UDim2.new(0, 10, 0, 150)
    FOVLabel.BackgroundTransparency = 1
    FOVLabel.Text = "FOV Radius: " .. tostring(config.FOVRadius)
    FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVLabel.Font = Enum.Font.Gotham
    FOVLabel.TextSize = 12
    FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
    FOVLabel.Parent = MainFrame

    local FOVSlider = Instance.new("TextButton")
    FOVSlider.Name = "FOVSlider"
    FOVSlider.Size = UDim2.new(1, -20, 0, 25)
    FOVSlider.Position = UDim2.new(0, 10, 0, 170)
    FOVSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    FOVSlider.Text = ""
    FOVSlider.Parent = MainFrame

    local FOVFill = Instance.new("Frame")
    FOVFill.Name = "FOVFill"
    FOVFill.Size = UDim2.new((config.FOVRadius - 10) / 190, 0, 1, 0)
    FOVFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    FOVFill.BorderSizePixel = 0
    FOVFill.Parent = FOVSlider

    local FOVValue = Instance.new("TextLabel")
    FOVValue.Name = "FOVValue"
    FOVValue.Size = UDim2.new(1, 0, 1, 0)
    FOVValue.BackgroundTransparency = 1
    FOVValue.Text = tostring(config.FOVRadius)
    FOVValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    FOVValue.Font = Enum.Font.GothamBold
    FOVValue.TextSize = 12
    FOVValue.Parent = FOVSlider

    local dragging = false
    FOVSlider.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    FOVSlider.MouseMoved:Connect(function()
        if dragging then
            local x = (UIS:GetMouseLocation().X - FOVSlider.AbsolutePosition.X) / FOVSlider.AbsoluteSize.X
            x = math.clamp(x, 0, 1)
            local newValue = math.floor(10 + x * 190)
            config.FOVRadius = newValue
            FOV.Radius = newValue
            FOVFill.Size = UDim2.new(x, 0, 1, 0)
            FOVValue.Text = tostring(newValue)
            FOVLabel.Text = "FOV Radius: " .. tostring(newValue)
        end
    end)

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(1, -20, 0, 30)
    ToggleButton.Position = UDim2.new(0, 10, 1, -40)
    ToggleButton.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    ToggleButton.Text = config.Enabled and "ENABLED" or "DISABLED"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 14
    ToggleButton.Parent = MainFrame

    ToggleButton.MouseButton1Click:Connect(function()
        config.Enabled = not config.Enabled
        ToggleButton.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = config.Enabled and "ENABLED" or "DISABLED"
        Notify("Silent Aim", config.Enabled and "Enabled" or "Disabled")
    end)
end

CreateUI()

local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(config.Bone) then
            local part = player.Character[config.Bone]
            local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
                local distance = (mousePosition - screenPosition).Magnitude
                if distance < shortestDistance and distance <= config.FOVRadius then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- Toggle UI with Right Control
    if input.KeyCode == Enum.KeyCode.RightControl then
        config.UIVisible = not config.UIVisible
        local ui = game:GetService("CoreGui"):FindFirstChild("SilentAimUI")
        if ui then
            ui.MainFrame.Visible = config.UIVisible
        end
    end

    if input.KeyCode == Enum.KeyCode[config.Keybind.Name] and config.Enabled then
        if Target then
            Highlight.Enabled = false
            Highlight.Adornee = nil
            Target = nil
            Tracer.Visible = false
            Notify("Target cleared", "No target")
        else
            local targetPlayer = GetClosestPlayerToMouse()
            if targetPlayer then
                Target = targetPlayer
                Highlight.Adornee = Target.Character
                Highlight.Enabled = true
                Notify("Target Locked", "Locked to: " .. targetPlayer.DisplayName)
            else
                Notify("Target failed", "No player near mouse")
            end
        end
    end

    if input.KeyCode == config.FlyKey then
        FlyEnabled = not FlyEnabled
        Notify("CFrame Fly", FlyEnabled and "Fly Enabled" or "Fly Disabled")
    end
end)

RunService.RenderStepped:Connect(function()
    local screenSize = Camera.ViewportSize
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)

    if Target and Target.Character and Target.Character:FindFirstChild(config.Bone) then
        local part = Target.Character[config.Bone]
        -- Apply jump offset if target is jumping
        local jumpOffset = 0
        if Target.Character:FindFirstChildOfClass("Humanoid") and Target.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            jumpOffset = config.JumpOffset
        end
        
        local predicted = part.Position + part.Velocity * config.Prediction + Vector3.new(0, jumpOffset, 0)
        local screenPos, onScreen = Camera:WorldToViewportPoint(predicted)

        if onScreen then
            Final = predicted
            Tracer.Visible = true
            Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
            Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            FOV.Position = Vector2.new(screenPos.X, screenPos.Y)
        else
            Tracer.Visible = false
            FOV.Position = mousePos
        end
    else
        Final = Vector3.zero
        Tracer.Visible = false
        Highlight.Enabled = false
        FOV.Position = mousePos
    end

    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local direction = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0, 1, 0) end

        if direction.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + direction.Unit * 2
        end
    end
end)

local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if Target and Target.Character and Target.Character:FindFirstChild(config.Bone) and config.Enabled then
        if tostring(self):lower():find("mouse") or tostring(self):lower():find("pos") and method == "FireServer" then
            local part = Target.Character[config.Bone]
            
            local jumpOffset = 0
            if Target.Character:FindFirstChildOfClass("Humanoid") and Target.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                jumpOffset = config.JumpOffset
            end
            
            local predicted = part.Position + part.Velocity * config.Prediction + Vector3.new(0, jumpOffset, 0)
            args[1] = predicted
            return old(self, unpack(args))
        end
    end

    return old(self, ...)
end)

setreadonly(mt, true)
