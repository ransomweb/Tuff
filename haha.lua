-- yufi.asia - Complete Silent Aim with Obelus UI
-- Based on kabu.milk.txt logic

-- Services
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

-- Local Player
local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()
local camera = workspace.CurrentCamera

-- Initialize Obelus UI
local window = library:window({
    name = "yufi.asia",
    size = dim2(0, 516, 0, 563),
})

-- Main Tab
local MainTab = window:tab({ name = "Main" })

-- Left Column
local LeftColumn = MainTab:column({ fill = true })
local LeftSection = LeftColumn:section({ name = "Aim Settings" })

-- Right Column
local RightColumn = MainTab:column({ fill = true })
local RightSection = RightColumn:section({ name = "Beta Features" })

-- Settings
getgenv().Settings = {
    SilentAim = {
        Enabled = false,
        Key = Enum.KeyCode.Q,
        AutoPrediction = false,
        Prediction = 0.15,
        Airshot = false,
        AirshotPart = "HumanoidRootPart",
        HitParts = {"HumanoidRootPart"},
        JumpOffset = 0.19,
        ShowDot = true,
        ShowTracer = true,
        DotColor = Color3.fromRGB(170, 85, 235),
        FOV = 100,
        Resolver = false
    },
    Beta = {
        LookAt = false,
        CFrameFly = false,
        FlySpeed = 1
    }
}

-- UI Elements
-- Silent Aim Toggle with Keybind
local silentAimToggle = LeftSection:addToggle({
    name = "Silent Aim",
    flag = "silent_aim_enabled",
    default = false,
    callback = function(state)
        getgenv().Settings.SilentAim.Enabled = state
    end
})
silentAimToggle:addKeyBind({
    flag = "silent_aim_key",
    default = Enum.KeyCode.Q,
    callback = function(key)
        getgenv().Settings.SilentAim.Key = key
    end
})

-- Auto Prediction
LeftSection:addToggle({
    name = "Auto Prediction",
    flag = "auto_prediction",
    default = false,
    callback = function(state)
        getgenv().Settings.SilentAim.AutoPrediction = state
    end
})

-- Prediction Value
LeftSection:addTextBox({
    name = "Prediction",
    placeholder = "0.15",
    flag = "prediction_value",
    callback = function(text)
        getgenv().Settings.SilentAim.Prediction = tonumber(text) or 0.15
    end
})

-- Airshot Toggle
LeftSection:addToggle({
    name = "Airshot",
    flag = "airshot_enabled",
    default = false,
    callback = function(state)
        getgenv().Settings.SilentAim.Airshot = state
    end
})

-- Airshot Hitpart Dropdown
LeftSection:addDropdown({
    name = "Airshot Hitpart",
    items = {"Head", "HumanoidRootPart", "LeftFoot", "RightFoot"},
    flag = "airshot_part",
    callback = function(option)
        getgenv().Settings.SilentAim.AirshotPart = option
    end
})

-- Hitpart Multi-Dropdown
LeftSection:addDropdown({
    name = "Hitpart",
    items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    flag = "hit_parts",
    multi = true,
    callback = function(options)
        getgenv().Settings.SilentAim.HitParts = options
    end
})

-- Jump Offset Slider
LeftSection:addSlider({
    name = "Jump Offset",
    min = -1,
    max = 1,
    default = 0.19,
    interval = 0.01,
    flag = "jump_offset",
    callback = function(value)
        getgenv().Settings.SilentAim.JumpOffset = value
    end
})

-- Dot Toggle with Color Picker
local dotToggle = LeftSection:addToggle({
    name = "Dot",
    flag = "show_dot",
    default = true,
    callback = function(state)
        getgenv().Settings.SilentAim.ShowDot = state
    end
})
dotToggle:addColorPicker({
    flag = "dot_color",
    color = Color3.fromRGB(170, 85, 235),
    callback = function(color)
        getgenv().Settings.SilentAim.DotColor = color
    end
})

-- Tracer Toggle
LeftSection:addToggle({
    name = "Tracer",
    flag = "show_tracer",
    default = true,
    callback = function(state)
        getgenv().Settings.SilentAim.ShowTracer = state
    end
})

-- Right Column Elements (Beta Features)
-- LookAt Toggle
RightSection:addToggle({
    name = "LookAt (BETA)",
    flag = "look_at",
    default = false,
    callback = function(state)
        getgenv().Settings.Beta.LookAt = state
    end
})

-- CFrame Fly Toggle
local flyToggle = RightSection:addToggle({
    name = "CFrame Fly (BETA)",
    flag = "cframe_fly",
    default = false,
    callback = function(state)
        getgenv().Settings.Beta.CFrameFly = state
        if state then
            activateCFrameFly()
        else
            deactivateCFrameFly()
        end
    end
})

-- Fly Speed Slider
flyToggle:addSlider({
    name = "Fly Speed",
    min = 1,
    max = 10,
    default = 1,
    interval = 0.1,
    flag = "fly_speed",
    callback = function(value)
        getgenv().Settings.Beta.FlySpeed = value
    end
})

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Color = getgenv().Settings.SilentAim.DotColor
circle.Thickness = 1
circle.NumSides = 25
circle.Radius = getgenv().Settings.SilentAim.FOV
circle.Transparency = 0.7
circle.Visible = getgenv().Settings.SilentAim.ShowDot
circle.Filled = false

-- Silent Aim Logic
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = getgenv().Settings.SilentAim.FOV

    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            for _, partName in pairs(getgenv().Settings.SilentAim.HitParts) do
                local part = player.Character:FindFirstChild(partName)
                if part then
                    local pos = camera:WorldToViewportPoint(part.Position)
                    local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
                    if magnitude < shortestDistance then
                        closestPlayer = player
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Main Silent Aim Hook
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(...)
    local args = {...}
    local self = args[1]
    
    if getgenv().Settings.SilentAim.Enabled and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        local targetPlayer = getClosestPlayerToCursor()
        
        if targetPlayer and targetPlayer.Character then
            local selectedPart = getgenv().Settings.SilentAim.HitParts[1]
            
            -- Airshot logic
            if getgenv().Settings.SilentAim.Airshot and 
               targetPlayer.Character:FindFirstChild("Humanoid") and 
               targetPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                selectedPart = getgenv().Settings.SilentAim.AirshotPart
            end
            
            local part = targetPlayer.Character:FindFirstChild(selectedPart)
            if part then
                -- Apply prediction
                local prediction = getgenv().Settings.SilentAim.Prediction
                if getgenv().Settings.SilentAim.AutoPrediction then
                    -- Auto prediction based on ping
                    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
                    ping = tonumber(string.split(ping, "(")[1])
                    
                    if ping < 130 then prediction = 0.151
                    elseif ping < 125 then prediction = 0.149
                    elseif ping < 110 then prediction = 0.146
                    elseif ping < 105 then prediction = 0.138
                    elseif ping < 90 then prediction = 0.136
                    elseif ping < 80 then prediction = 0.134
                    elseif ping < 70 then prediction = 0.131
                    elseif ping < 60 then prediction = 0.1229
                    elseif ping < 50 then prediction = 0.1225
                    elseif ping < 40 then prediction = 0.1256
                    end
                end
                
                -- Apply jump offset if needed
                if selectedPart == "HumanoidRootPart" then
                    prediction = prediction + getgenv().Settings.SilentAim.JumpOffset
                end
                
                args[3] = part.Position + (part.Velocity * prediction)
                
                -- LookAt beta feature
                if getgenv().Settings.Beta.LookAt then
                    local char = localPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = CFrame.lookAt(
                            char.HumanoidRootPart.Position,
                            args[3]
                        )
                    end
                end
            end
        end
    end
    
    return old(unpack(args))
end)

-- CFrame Fly Implementation
local flyBodyVelocity
local flyBodyGyro

local function activateCFrameFly()
    local char = localPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            flyBodyVelocity = Instance.new("BodyVelocity", root)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            flyBodyGyro = Instance.new("BodyGyro", root)
            flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyBodyGyro.P = 10000
            flyBodyGyro.D = 100
        end
    end
end

local function deactivateCFrameFly()
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
end

-- Fly control
runService.Heartbeat:Connect(function()
    if getgenv().Settings.Beta.CFrameFly and flyBodyVelocity and flyBodyGyro then
        local char = localPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                flyBodyGyro.CFrame = camera.CFrame
                
                local moveDir = Vector3.new()
                if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * getgenv().Settings.Beta.FlySpeed
                end
                
                flyBodyVelocity.Velocity = moveDir
            end
        end
    end
end)

-- FOV Circle Update
runService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(mouse.X, mouse.Y + 35)
    circle.Color = getgenv().Settings.SilentAim.DotColor
    circle.Visible = getgenv().Settings.SilentAim.ShowDot
    circle.Radius = getgenv().Settings.SilentAim.FOV
end)

-- Tracer Implementation
local tracer = Drawing.new("Line")
tracer.Visible = false
tracer.Thickness = 1
tracer.Color = getgenv().Settings.SilentAim.DotColor

runService.RenderStepped:Connect(function()
    if getgenv().Settings.SilentAim.ShowTracer and getgenv().Settings.SilentAim.Enabled then
        local targetPlayer = getClosestPlayerToCursor()
        if targetPlayer and targetPlayer.Character then
            for _, partName in pairs(getgenv().Settings.SilentAim.HitParts) do
                local part = targetPlayer.Character:FindFirstChild(partName)
                if part then
                    local pos = camera:WorldToViewportPoint(part.Position)
                    if pos then
                        tracer.From = Vector2.new(mouse.X, mouse.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                        break
                    end
                end
            end
        else
            tracer.Visible = false
        end
    else
        tracer.Visible = false
    end
end)

-- Dot Implementation
local dots = {}
runService.RenderStepped:Connect(function()
    if getgenv().Settings.SilentAim.ShowDot and getgenv().Settings.SilentAim.Enabled then
        local targetPlayer = getClosestPlayerToCursor()
        if targetPlayer and targetPlayer.Character then
            -- Clear old dots
            for _, dot in pairs(dots) do
                dot:Remove()
            end
            dots = {}
            
            -- Create new dots for each hitpart
            for _, partName in pairs(getgenv().Settings.SilentAim.HitParts) do
                local part = targetPlayer.Character:FindFirstChild(partName)
                if part then
                    local pos = camera:WorldToViewportPoint(part.Position)
                    if pos then
                        local dot = Drawing.new("Circle")
                        dot.Position = Vector2.new(pos.X, pos.Y)
                        dot.Color = getgenv().Settings.SilentAim.DotColor
                        dot.Thickness = 1
                        dot.Radius = 4
                        dot.Filled = true
                        dot.Visible = true
                        table.insert(dots, dot)
                    end
                end
            end
        else
            -- No target, hide dots
            for _, dot in pairs(dots) do
                dot.Visible = false
            end
        end
    else
        -- Dot feature disabled, hide all
        for _, dot in pairs(dots) do
            dot.Visible = false
        end
    end
end)

-- Cleanup on script termination
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        for _, dot in pairs(dots) do
            dot:Remove()
        end
        tracer:Remove()
        circle:Remove()
        deactivateCFrameFly()
    end
end)
