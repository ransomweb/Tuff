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

local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local userinputservice = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local ts = game:GetService("TweenService")

local victim = nil
local targeting = false
local guiEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CentralAimAssistGUI"
screenGui.Parent = game.CoreGui
screenGui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
mainFrame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Text = "Central Aim Assist"
titleText.Size = UDim2.new(1, -30, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.Parent = titleBar

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 30)
tabFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
tabFrame.BorderSizePixel = 0
tabFrame.Parent = mainFrame

local mainTab = Instance.new("TextButton")
mainTab.Text = "Main Settings"
mainTab.Size = UDim2.new(0.5, 0, 1, 0)
mainTab.Position = UDim2.new(0, 0, 0, 0)
mainTab.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
mainTab.TextColor3 = Color3.fromRGB(0, 0, 0)
mainTab.Font = Enum.Font.SourceSans
mainTab.TextSize = 14
mainTab.Parent = tabFrame

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.new(0, 10, 0, 70)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 5
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
contentFrame.Parent = mainFrame

local function createSetting(labelText, defaultValue, yPos, isBool)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = contentFrame

    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local textbox = Instance.new("TextBox")
    textbox.Text = tostring(defaultValue)
    textbox.Size = UDim2.new(0.5, -5, 1, 0)
    textbox.Position = UDim2.new(0.5, 5, 0, 0)
    textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textbox.TextColor3 = Color3.fromRGB(0, 0, 0)
    textbox.Font = Enum.Font.SourceSans
    textbox.TextSize = 14
    textbox.BorderSizePixel = 1
    textbox.BorderColor3 = Color3.fromRGB(200, 200, 200)
    textbox.Parent = container

    if isBool then
        textbox.Text = tostring(defaultValue)
        textbox.FocusLost:Connect(function()
            local text = string.lower(textbox.Text)
            if text == "true" or text == "false" then
                getgenv().settings[labelText] = (text == "true")
                textbox.Text = tostring(getgenv().settings[labelText])
            else
                textbox.Text = tostring(getgenv().settings[labelText])
            end
        end)
    else
        textbox.Text = tostring(defaultValue)
        textbox.FocusLost:Connect(function()
            local num = tonumber(textbox.Text)
            if num then
                getgenv().settings[labelText] = num
                textbox.Text = tostring(num)
            else
                textbox.Text = tostring(getgenv().settings[labelText])
            end
        end)
    end

    return textbox
end

createSetting("prediction", getgenv().settings.prediction, 0)
createSetting("smoothness", getgenv().settings.smoothness, 40)
createSetting("JumpAdjustment", getgenv().settings.JumpAdjustment, 80)
createSetting("FallAdjustment", getgenv().settings.FallAdjustment, 120)
createSetting("JumpSmoothing", getgenv().settings.JumpSmoothing, 160)
createSetting("FallSmoothing", getgenv().settings.FallSmoothing, 200)
createSetting("offset", getgenv().settings.offset, 240)
createSetting("resolver", getgenv().settings.resolver, 280, true)
createSetting("usePrediction", getgenv().settings.usePrediction, 320, true)

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Text = "Keybind: C (Fixed)"
keybindLabel.Size = UDim2.new(1, 0, 0, 30)
keybindLabel.Position = UDim2.new(0, 0, 0, 360)
keybindLabel.BackgroundTransparency = 1
keybindLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
keybindLabel.Font = Enum.Font.SourceSans
keybindLabel.TextSize = 14
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = contentFrame

local function toggleGUI()
    guiEnabled = not guiEnabled
    screenGui.Enabled = guiEnabled
end

closeButton.MouseButton1Click:Connect(toggleGUI)

userinputservice.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then toggleGUI() end
end)

local function target()
    local target = nil
    local shortdistance = math.huge
    for _, v in next, workspace:GetDescendants() do
        if v.Parent and v:IsA("Model") and v ~= localplayer.Character then
            if v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0 then
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
    return target and (target.PrimaryPart or target:FindFirstChildOfClass("Humanoid").RootPart)
end

local velocity = Vector3.new(0, 0, 0)
local oldpos = Vector3.new(0, 0, 0)

runservice.Heartbeat:Connect(function(deltaTime)
    if victim and victim.Parent then
        local currentpos = victim.Position
        local displacement = currentpos - oldpos
        local vector = displacement / deltaTime
        velocity = velocity:Lerp(Vector3.new(vector.X, vector.Y * 0.94 * getgenv().settings.offset, vector.Z), 0.4)
        oldpos = currentpos
    end
end)

userinputservice.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == getgenv().settings.keybind then
        targeting = not targeting
        victim = targeting and target() or nil
    end
end)

runservice.RenderStepped:Connect(function()
    if targeting and victim and victim.Parent and victim.Parent:FindFirstChildOfClass("Humanoid") and victim.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
        local humanoid = victim.Parent:FindFirstChildOfClass("Humanoid")
        local yVelocity = humanoid.RootPart.Velocity.Y
        local pos = getgenv().settings.usePrediction and 
                   (getgenv().settings.resolver and victim.Position + (velocity * getgenv().settings.prediction) or 
                   victim.Position + (victim.Velocity * getgenv().settings.prediction)) or victim.Position
        
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
end)

print("Central Aim Assist Loaded | GUI: Right Ctrl | Keybind: C")
