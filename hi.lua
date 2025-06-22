local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/obelus.txt"))() -- Replace with actual library URL

-- Config with UI bindings
local config = {
    Enabled = library.flags.silent_aim_enabled,
    Prediction = library.flags.manual_prediction,
    Bone = library.flags.aim_part,
    Keybind = library.flags.silent_aim_keybind,
    TracerColor = library.flags.tracer_color,
    TracerOutlineColor = library.flags.tracer_outline_color,
    TracerThickness = 2,
    JumpOffset = library.flags.jump_offset,
    DotEnabled = library.flags.dot_enabled,
    CFrameSpeedEnabled = library.flags.cframe_speed_enabled,
    CFrameSpeedValue = library.flags.cframe_speed_value,
    CFrameFlyEnabled = library.flags.cframe_fly_enabled,
    CFrameFlySpeed = library.flags.cframe_fly_speed
}

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Drawing objects
local Tracer = Drawing.new("Line")
Tracer.Visible = false
Tracer.Color = config.TracerColor
Tracer.Thickness = config.TracerThickness

local Dot = Drawing.new("Circle")
Dot.Visible = false
Dot.Color = config.TracerColor
Dot.Thickness = 2
Dot.Radius = 4
Dot.Filled = true
Dot.NumSides = 12

-- Variables
local Target
local Final = Vector3.zero
local OriginalGravity
local OriginalWalkSpeed

-- Notification function
local function Notify(message)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Azurite",
        Text = message,
        Duration = 5
    })
end

-- Target finding function
local function GetClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = Vector2.new(Mouse.X, Mouse.Y)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(config.Bone) then
            local characterPart = player.Character[config.Bone]
            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(characterPart.Position)
            
            if onScreen then
                local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
                local distance = (mousePosition - screenPosition).Magnitude
                
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Auto prediction calculation
local function CalculateAutoPrediction()
    if not library.flags.auto_prediction then
        return tonumber(config.Prediction) or 0.166
    end
    
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    return math.clamp(ping / 1000 * 0.75, 0.1, 0.3) -- Adjusted auto prediction formula
end

-- CFrame Speed function
local function CFrameSpeed()
    if not config.CFrameSpeedEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Save original values if we haven't already
    if not OriginalWalkSpeed then
        OriginalWalkSpeed = humanoid.WalkSpeed
    end
    
    humanoid.WalkSpeed = config.CFrameSpeedValue
    
    -- Reset when disabled
    if not library.flags.cframe_speed_enabled and OriginalWalkSpeed then
        humanoid.WalkSpeed = OriginalWalkSpeed
        OriginalWalkSpeed = nil
    end
end

-- CFrame Fly function
local function CFrameFly()
    if not config.CFrameFlyEnabled then
        if OriginalGravity then
            workspace.Gravity = OriginalGravity
            OriginalGravity = nil
        end
        return
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Save original gravity if we haven't already
    if not OriginalGravity then
        OriginalGravity = workspace.Gravity
    end
    
    workspace.Gravity = 0
    
    -- Fly logic
    local flyDirection = Vector3.new()
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        flyDirection = flyDirection + (workspace.CurrentCamera.CFrame.LookVector * config.CFrameFlySpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        flyDirection = flyDirection - (workspace.CurrentCamera.CFrame.LookVector * config.CFrameFlySpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        flyDirection = flyDirection - (workspace.CurrentCamera.CFrame.RightVector * config.CFrameFlySpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        flyDirection = flyDirection + (workspace.CurrentCamera.CFrame.RightVector * config.CFrameFlySpeed)
    end
    
    humanoidRootPart.Velocity = flyDirection
end

-- Keybind handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Silent Aim toggle
    if input.KeyCode == config.Keybind then
        if Target then
            Target = nil
            Tracer.Visible = false
            Dot.Visible = false
            Notify("Target cleared")
        else
            local targetPlayer = GetClosestPlayerToMouse()
            if targetPlayer then
                Target = targetPlayer
                Notify("Targeting " .. targetPlayer.DisplayName)
            else
                Notify("No player near mouse")
            end
        end
    end
end)

-- Main render loop
RunService.RenderStepped:Connect(function()
    -- Update config values from UI
    config.Enabled = library.flags.silent_aim_enabled
    config.Bone = library.flags.aim_part
    config.TracerColor = library.flags.tracer_color
    config.TracerOutlineColor = library.flags.tracer_outline_color
    config.DotEnabled = library.flags.dot_enabled
    config.JumpOffset = library.flags.jump_offset
    config.CFrameSpeedEnabled = library.flags.cframe_speed_enabled
    config.CFrameSpeedValue = library.flags.cframe_speed_value
    config.CFrameFlyEnabled = library.flags.cframe_fly_enabled
    config.CFrameFlySpeed = library.flags.cframe_fly_speed
    
    -- Update prediction value
    if library.flags.auto_prediction then
        config.Prediction = CalculateAutoPrediction()
    else
        config.Prediction = library.flags.manual_prediction
    end
    
    -- Update drawing objects
    Tracer.Color = config.TracerColor
    Dot.Color = config.TracerColor
    
    -- Silent Aim logic
    if Target and Target.Character and Target.Character:FindFirstChild(config.Bone) then
        local characterPart = Target.Character[config.Bone]
        local predictedPosition = characterPart.Position
        
        -- Apply jump offset
        if Target.Character:FindFirstChildOfClass("Humanoid") and Target.Character.Humanoid.Jump then
            predictedPosition = predictedPosition + Vector3.new(0, config.JumpOffset, 0)
        end
        
        local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(predictedPosition)
        
        if onScreen then
            Final = predictedPosition
            Tracer.Visible = config.Enabled
            Dot.Visible = config.Enabled and config.DotEnabled
            
            -- Update tracer
            Tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            Tracer.To = Vector2.new(screenPoint.X, screenPoint.Y)
            
            -- Update dot
            Dot.Position = Vector2.new(screenPoint.X, screenPoint.Y)
        else
            Tracer.Visible = false
            Dot.Visible = false
        end
    else
        Final = Vector3.zero
        Tracer.Visible = false
        Dot.Visible = false
    end
    
    -- Movement functions
    CFrameSpeed()
    CFrameFly()
end)

-- Remote prediction hook (for games that use remote events for mouse position)
local Utility = { Method = "UpdateMousePos" }
local MainRemote

-- Game-specific detection
if game.PlaceId == 2788229376 or game.PlaceId == 7213786345 then
    Utility.Method = "UpdateMousePosI2"
    MainRemote = game.ReplicatedStorage:FindFirstChild("MainEvent")
elseif game.PlaceId == 84366677940861 or game.PlaceId == 77369032494150 then
    Utility.Method = "MOUSE"
    MainRemote = game.ReplicatedStorage:FindFirstChild("MAINEVENT")
else
    MainRemote = game.ReplicatedStorage:FindFirstChild("MainEvent")
    if MainRemote then
        Utility.Method = MainRemote:FindFirstChild("UpdateMousePosI2") and "UpdateMousePosI2" or "UpdateMousePos"
    end
end

-- Remote hook
if MainRemote then
    local oldFireServer = MainRemote.FireServer
    MainRemote.FireServer = function(self, ...)
        local args = {...}
        
        if config.Enabled and Target and Final ~= Vector3.zero then
            if args[1] == Utility.Method then
                args[2] = Final
            end
        end
        
        return oldFireServer(self, unpack(args))
    end
end

-- UI Creation
local window = library:window({
    name = "Azurite",
    size = UDim2.new(0, 500, 0, 450)
})

local Main = window:tab({name = "Main"})

-- Left Column
local leftColumn = Main:column({fill = true})
local silentAimSection = leftColumn:section({name = "Silent Aim"})

-- Silent Aim Toggle with Keybind
silentAimSection:addToggle({
    name = "Silent Aim",
    flag = "silent_aim_enabled",
    default = true
}):addKeyBind({
    flag = "silent_aim_keybind",
    default = Enum.KeyCode.Q
})

-- Auto Prediction Toggle
silentAimSection:addToggle({
    name = "Auto Prediction",
    flag = "auto_prediction",
    default = false
})

-- Prediction Textbox
silentAimSection:addTextBox({
    name = "Prediction",
    flag = "manual_prediction",
    default = "0.166",
    placeholder = "Enter prediction value"
})

-- Jump Offset Slider
silentAimSection:addSlider({
    name = "Jump Offset",
    flag = "jump_offset",
    min = -1,
    max = 1,
    default = 0,
    interval = 0.01,
    suffix = ""
})

-- Aimpart Dropdown
silentAimSection:addDropdown({
    name = "Aimpart",
    flag = "aim_part",
    items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftHand", "RightHand", "LeftFoot", "RightFoot"},
    default = "HumanoidRootPart"
})

-- Tracer Toggle with ColorPickers
local tracerToggle = silentAimSection:addToggle({
    name = "Tracer",
    flag = "tracer_enabled",
    folding = true
})
tracerToggle:addColorPicker({
    name = "Tracer Color",
    flag = "tracer_color",
    color = Color3.fromRGB(255, 255, 255)
})
tracerToggle:addColorPicker({
    name = "Outline Color",
    flag = "tracer_outline_color",
    color = Color3.fromRGB(0, 0, 0)
})

-- Dot Toggle
silentAimSection:addToggle({
    name = "Dot",
    flag = "dot_enabled",
    default = false
})

-- Right Column
local rightColumn = Main:column({fill = true})
local movementSection = rightColumn:section({name = "Movement"})

-- CFrame Speed Toggle with Keybind
local speedToggle = movementSection:addToggle({
    name = "CFrame Speed",
    flag = "cframe_speed_enabled"
}):addKeyBind({
    flag = "cframe_speed_keybind",
    default = Enum.KeyCode.E
})

-- Speed Slider
movementSection:addSlider({
    name = "Speed",
    flag = "cframe_speed_value",
    min = 1,
    max = 5000,
    default = 100,
    interval = 1,
    suffix = ""
})

-- CFrame Fly Toggle with Keybind
local flyToggle = movementSection:addToggle({
    name = "CFrame Fly",
    flag = "cframe_fly_enabled"
}):addKeyBind({
    flag = "cframe_fly_keybind",
    default = Enum.KeyCode.F
})

-- Fly Speed Slider
movementSection:addSlider({
    name = "Fly Speed",
    flag = "cframe_fly_speed",
    min = 1,
    max = 5000,
    default = 100,
    interval = 1,
    suffix = ""
})
