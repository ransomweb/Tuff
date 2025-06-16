-- Central Aim Assist (Textbox Edition)
-- Toggle GUI: Right Ctrl

-- Default Settings
getgenv().settings = {
    prediction = 0.0217727,
    offset = 0,
    resolver = false,
    smoothness = 0.120,
    JumpAdjustment = 3.6,
    FallAdjustment = 1.9,
    JumpSmoothing = 0.07,
    FallSmoothing = 0.07,
    keybind = Enum.KeyCode.C,
    usePrediction = true
}

-- Core Services
local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local userinputservice = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local ts = game:GetService("TweenService")

-- Variables
local victim = nil
local targeting = false
local guiEnabled = false

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CentralAimAssistGUI"
screenGui.Parent = game.CoreGui
screenGui.Enabled = false

-- Blur Effect
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game:GetService("Lighting")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Text = "CENTRAL AIM ASSIST"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = closeButton

-- Scroll Frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
scrollFrame.Parent = mainFrame

-- Function to create textbox setting
local function createTextboxSetting(name, defaultValue, yPosition)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.Position = UDim2.new(0, 0, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Text = tostring(defaultValue)
    textbox.Size = UDim2.new(0.4, 0, 0, 25)
    textbox.Position = UDim2.new(0.55, 0, 0.5, -12)
    textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14
    textbox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = textbox

    textbox.FocusLost:Connect(function()
        local value = tonumber(textbox.Text)
        if value then
            getgenv().settings[name] = value
        else
            textbox.Text = tostring(getgenv().settings[name])
        end
    end)

    return textbox
end

-- Function to create toggle setting
local function createToggleSetting(name, defaultValue, yPosition)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.Position = UDim2.new(0, 0, 0, yPosition)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleTextbox = Instance.new("TextBox")
    toggleTextbox.Text = tostring(defaultValue)
    toggleTextbox.Size = UDim2.new(0.2, 0, 0, 25)
    toggleTextbox.Position = UDim2.new(0.8, 0, 0.5, -12)
    toggleTextbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    toggleTextbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleTextbox.Font = Enum.Font.Gotham
    toggleTextbox.TextSize = 14
    toggleTextbox.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = toggleTextbox

    toggleTextbox.FocusLost:Connect(function()
        local text = string.lower(toggleTextbox.Text)
        if text == "true" or text == "false" then
            getgenv().settings[name] = (text == "true")
            toggleTextbox.Text = tostring(getgenv().settings[name])
        else
            toggleTextbox.Text = tostring(getgenv().settings[name])
        end
    end)

    return toggleTextbox
end

-- Create all settings
createTextboxSetting("prediction", getgenv().settings.prediction, 0)
createTextboxSetting("smoothness", getgenv().settings.smoothness, 50)
createTextboxSetting("JumpAdjustment", getgenv().settings.JumpAdjustment, 100)
createTextboxSetting("FallAdjustment", getgenv().settings.FallAdjustment, 150)
createTextboxSetting("JumpSmoothing", getgenv().settings.JumpSmoothing, 200)
createTextboxSetting("FallSmoothing", getgenv().settings.FallSmoothing, 250)
createTextboxSetting("offset", getgenv().settings.offset, 300)
createToggleSetting("resolver", getgenv().settings.resolver, 350)
createToggleSetting("usePrediction", getgenv().settings.usePrediction, 400)

-- Keybind label (non-editable)
local keybindLabel = Instance.new("TextLabel")
keybindLabel.Text = "Keybind: C (Fixed)"
keybindLabel.Size = UDim2.new(1, 0, 0, 30)
keybindLabel.Position = UDim2.new(0, 0, 0, 450)
keybindLabel.BackgroundTransparency = 1
keybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextSize = 14
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = scrollFrame

-- GUI toggle function
local function toggleGUI()
    guiEnabled = not guiEnabled
    screenGui.Enabled = guiEnabled
    
    if guiEnabled then
        ts:Create(blur, TweenInfo.new(0.3), {Size = 24}):Play()
        mainFrame.BackgroundTransparency = 0.2
    else
        ts:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
        mainFrame.BackgroundTransparency = 1
        wait(0.3)
        if not guiEnabled then
            mainFrame.BackgroundTransparency = 0.2
        end
    end
end

-- Close button functionality
closeButton.MouseButton1Click:Connect(toggleGUI)

-- Right Ctrl to toggle GUI
userinputservice.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleGUI()
    end
end)

-- Target finding function
local function target()
    local target = nil
    local shortdistance = math.huge

    for _, v in next, workspace:GetDescendants() do
        if v.Parent and v:IsA("Model") and v ~= localplayer.Character then
            if v:FindFirstChildOfClass("Humanoid") then
                if v:FindFirstChildOfClass("Humanoid").Health > 0 then
                    pcall(function()
                        local worldtoviewportpoint, onscreen = currentCamera:WorldToViewportPoint(v:FindFirstChildOfClass("Humanoid").RootPart.Position or v.PrimaryPart.Position)
                        local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(worldtoviewportpoint.X, worldtoviewportpoint.Y)).Magnitude
                        if math.huge > distance and distance < shortdistance and onscreen then
                            target = v
                            shortdistance = distance
                        end
                    end)
                end
            end
        end
    end
    return target and (target.PrimaryPart or target:FindFirstChildOfClass("Humanoid").RootPart)
end

-- Aim assist functionality
local velocity = Vector3.new(0, 0, 0)
local oldpos = Vector3.new(0, 0, 0)

runservice.Heartbeat:Connect(function(deltaTime)
    if victim and victim.Parent then
        local currentpos = victim.Position
        local displacement = currentpos - oldpos
        local vector = displacement / deltaTime

        velocity = velocity:Lerp(Vector3.new(
            vector.X,
            vector.Y * 0.94 * getgenv().settings.offset,
            vector.Z
        ), 0.4)

        oldpos = currentpos
    end
end)

userinputservice.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == getgenv().settings.keybind then
        targeting = not targeting
        if targeting then
            victim = target()
        else
            victim = nil
        end
    end
end)

runservice.RenderStepped:Connect(function()
    if targeting and victim and victim.Parent then
        if victim.Parent:FindFirstChildOfClass("Humanoid") then
            if victim.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                local humanoid = victim.Parent:FindFirstChildOfClass("Humanoid")
                local yVelocity = humanoid.RootPart.Velocity.Y
                local pos

                if getgenv().settings.usePrediction then
                    if getgenv().settings.resolver then
                        pos = victim.Position + (velocity * getgenv().settings.prediction)
                    else
                        pos = victim.Position + (victim.Velocity * getgenv().settings.prediction)
                    end
                else
                    pos = victim.Position
                end

                local smoothness = getgenv().settings.smoothness

                if yVelocity > 1 then
                    pos = pos + Vector3.new(0, getgenv().settings.JumpAdjustment, 0)
                    smoothness = getgenv().settings.JumpSmoothing
                elseif yVelocity < -1 then
                    pos = pos + Vector3.new(0, -getgenv().settings.FallAdjustment, 0)
                    smoothness = getgenv().settings.FallSmoothing
                end

                currentCamera.CFrame = currentCamera.CFrame:Lerp(CFrame.new(currentCamera.CFrame.Position, pos), smoothness)
            end
        end
    end
end)

print("Central Aim Assist Loaded | GUI: Right Ctrl | Keybind: C")
