local WaxWare = {
    Config = {
        Main = {
            Enabled = false,
            AimlockKey = "c",
            Prediction = 0.142,
            JumpOffset = 0,
            AimPart = 'HumanoidRootPart',
            Notifications = true,
            RectangleColor = Color3.fromRGB(0, 0, 0),
            Target = nil
        },
        Visuals = {
            FOV = {
                Enabled = false,
                Size = 100,
                Spikes = 0,
                Spinning = false,
                Color = Color3.fromRGB(255, 255, 255),
                Circle = nil
            },
            Crosshair = {
                Enabled = false,
                Size = 10,
                Gap = 5,
                Spinning = false,
                Color = Color3.fromRGB(255, 255, 255),
                LineX = nil,
                LineY = nil
            },
            Fog = {
                Enabled = false,
                Color = Color3.fromRGB(100, 100, 100)
            }
        }
    },
    Instances = {
        Box = nil,
        Marker = nil,
        Connections = {}
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        Lighting = game:GetService("Lighting"),
        StarterGui = game:GetService("StarterGui"),
        Workspace = game:GetService("Workspace")
    },
    Library = nil,
    GUI = {
        Window = nil,
        MainPage = nil,
        VisualsPage = nil
    }
}

-- Initialize the library
function WaxWare:InitLibrary()
    self.Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/matas3535/PoopLibrary/main/Library.lua"))()
end

-- Create GUI
function WaxWare:CreateGUI()
    self.GUI.Window = self.Library:New({
        "WaxWare",
        Vector2.new(500, 400),
        Color3.fromRGB(255, 50, 50)
    })

    self.GUI.MainPage = self.GUI.Window:Page({"Main"})
    self.GUI.VisualsPage = self.GUI.Window:Page({"Visuals"})

    self:CreateMainSection()
    self:CreateVisualsSection()
end

-- Main section
function WaxWare:CreateMainSection()
    local MainSection = self.GUI.MainPage:Section({
        "Aimbot",
        "Left"
    })

    MainSection:Toggle({
        "Enabled",
        self.Config.Main.Enabled,
        "AimbotToggle",
        function(state)
            self.Config.Main.Enabled = state
            if state then
                self:FindClosestUser()
                if self.Config.Main.Notifications then
                    self:Notify("WaxWare", "Try confusing my prediction; " .. tostring(self.Config.Main.Target.Character.Humanoid.DisplayName))
                end
            else
                if self.Config.Main.Notifications then
                    self:Notify("WaxWare", "Unlocked")
                end
            end
        end
    })

    MainSection:Keybind({
        "Aimlock Key",
        false,
        "Toggle",
        "AimlockKey",
        "Keybind",
        function(key)
            self.Config.Main.AimlockKey = key
        end
    })

    MainSection:Textbox({
        "Prediction",
        tostring(self.Config.Main.Prediction),
        "PredictionValue",
        function(text)
            local num = tonumber(text)
            if num then
                self.Config.Main.Prediction = num
            end
        end
    })

    MainSection:Textbox({
        "Jump Offset",
        tostring(self.Config.Main.JumpOffset),
        "JumpOffsetValue",
        function(text)
            local num = tonumber(text)
            if num then
                self.Config.Main.JumpOffset = num
            end
        end
    })

    MainSection:Dropdown({
        "Aim Part",
        {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
        "HumanoidRootPart",
        "AimPart",
        function(option)
            self.Config.Main.AimPart = option
        end
    })

    MainSection:Colorpicker({
        "Rectangle Color",
        "Changes the color of the target marker",
        false,
        1,
        "RectangleColor",
        function(color)
            self.Config.Main.RectangleColor = color
            if self.Instances.Box and self.Instances.Box:FindFirstChild("Wuss.Private") then
                self.Instances.Box["Wuss.Private"].Frame.BackgroundColor3 = color
            end
        end
    })
end

-- Visuals section
function WaxWare:CreateVisualsSection()
    local VisualsSection = self.GUI.VisualsPage:Section({
        "Visuals",
        "Left"
    })

    VisualsSection:Toggle({
        "FOV Circle",
        self.Config.Visuals.FOV.Enabled,
        "FOVToggle",
        function(state)
            self.Config.Visuals.FOV.Enabled = state
            self:UpdateFOV()
        end
    })

    VisualsSection:Slider({
        "FOV Size",
        100,
        50,
        300,
        "",
        0,
        "FOVSize",
        function(value)
            self.Config.Visuals.FOV.Size = value
            self:UpdateFOV()
        end
    })

    VisualsSection:Slider({
        "FOV Spikes",
        0,
        0,
        20,
        "",
        0,
        "FOVSpikes",
        function(value)
            self.Config.Visuals.FOV.Spikes = value
            self:UpdateFOV()
        end
    })

    VisualsSection:Toggle({
        "Spinning FOV",
        self.Config.Visuals.FOV.Spinning,
        "FOVSpin",
        function(state)
            self.Config.Visuals.FOV.Spinning = state
        end
    })

    VisualsSection:Colorpicker({
        "FOV Color",
        "Changes FOV circle color",
        false,
        1,
        "FOVColor",
        function(color)
            self.Config.Visuals.FOV.Color = color
            self:UpdateFOV()
        end
    })

    VisualsSection:Toggle({
        "Crosshair",
        self.Config.Visuals.Crosshair.Enabled,
        "CrosshairToggle",
        function(state)
            self.Config.Visuals.Crosshair.Enabled = state
            self:UpdateCrosshair()
        end
    })

    VisualsSection:Slider({
        "Crosshair Size",
        10,
        5,
        30,
        "",
        0,
        "CrosshairSize",
        function(value)
            self.Config.Visuals.Crosshair.Size = value
            self:UpdateCrosshair()
        end
    })

    VisualsSection:Slider({
        "Crosshair Gap",
        5,
        0,
        20,
        "",
        0,
        "CrosshairGap",
        function(value)
            self.Config.Visuals.Crosshair.Gap = value
            self:UpdateCrosshair()
        end
    })

    VisualsSection:Toggle({
        "Spinning Crosshair",
        self.Config.Visuals.Crosshair.Spinning,
        "CrosshairSpin",
        function(state)
            self.Config.Visuals.Crosshair.Spinning = state
        end
    })

    VisualsSection:Colorpicker({
        "Crosshair Color",
        "Changes crosshair color",
        false,
        1,
        "CrosshairColor",
        function(color)
            self.Config.Visuals.Crosshair.Color = color
            self:UpdateCrosshair()
        end
    })

    VisualsSection:Toggle({
        "Fog",
        self.Config.Visuals.Fog.Enabled,
        "FogToggle",
        function(state)
            self.Config.Visuals.Fog.Enabled = state
            self:UpdateFog()
        end
    })

    VisualsSection:Colorpicker({
        "Fog Color",
        "Changes fog color",
        false,
        1,
        "FogColor",
        function(color)
            self.Config.Visuals.Fog.Color = color
            self:UpdateFog()
        end
    })
end

-- Visuals functions
function WaxWare:UpdateFOV()
    if not self.Config.Visuals.FOV.Circle then
        self.Config.Visuals.FOV.Circle = Drawing.new("Circle")
    end

    local FOV = self.Config.Visuals.FOV
    FOV.Circle.Visible = FOV.Enabled
    FOV.Circle.Radius = FOV.Size
    FOV.Circle.Color = FOV.Color
    FOV.Circle.Thickness = 1
    FOV.Circle.Position = Vector2.new(self.Services.UserInputService:GetMouseLocation().X, self.Services.UserInputService:GetMouseLocation().Y)
    
    if FOV.Spikes > 0 then
        -- Implement spike logic here
    end
end

function WaxWare:UpdateCrosshair()
    if not self.Config.Visuals.Crosshair.LineX then
        self.Config.Visuals.Crosshair.LineX = Drawing.new("Line")
        self.Config.Visuals.Crosshair.LineY = Drawing.new("Line")
    end

    local center = Vector2.new(self.Services.UserInputService:GetMouseLocation().X, self.Services.UserInputService:GetMouseLocation().Y)
    local Crosshair = self.Config.Visuals.Crosshair
    
    Crosshair.LineX.Visible = Crosshair.Enabled
    Crosshair.LineY.Visible = Crosshair.Enabled
    
    Crosshair.LineX.Color = Crosshair.Color
    Crosshair.LineY.Color = Crosshair.Color
    
    Crosshair.LineX.Thickness = 1
    Crosshair.LineY.Thickness = 1
    
    Crosshair.LineX.From = Vector2.new(center.X - Crosshair.Size - Crosshair.Gap, center.Y)
    Crosshair.LineX.To = Vector2.new(center.X - Crosshair.Gap, center.Y)
    
    Crosshair.LineY.From = Vector2.new(center.X, center.Y - Crosshair.Size - Crosshair.Gap)
    Crosshair.LineY.To = Vector2.new(center.X, center.Y - Crosshair.Gap)
    
    Crosshair.LineX.From = Vector2.new(center.X + Crosshair.Gap, center.Y)
    Crosshair.LineX.To = Vector2.new(center.X + Crosshair.Size + Crosshair.Gap, center.Y)
    
    Crosshair.LineY.From = Vector2.new(center.X, center.Y + Crosshair.Gap)
    Crosshair.LineY.To = Vector2.new(center.X, center.Y + Crosshair.Size + Crosshair.Gap)
end

function WaxWare:UpdateFog()
    if self.Config.Visuals.Fog.Enabled then
        self.Services.Lighting.FogColor = self.Config.Visuals.Fog.Color
        self.Services.Lighting.FogEnd = 1000
        self.Services.Lighting.FogStart = 0
    else
        self.Services.Lighting.FogEnd = 100000
    end
end

-- Aimbot functions
function WaxWare:FindClosestUser()
    local closestPlayer
    local ShortestDistance = math.huge
    
    for _, player in pairs(self.Services.Players:GetPlayers()) do
        if player ~= self.Services.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health ~= 0 and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = self.Services.Workspace.CurrentCamera:WorldToViewportPoint(player.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(self.Services.UserInputService:GetMouseLocation().X, self.Services.UserInputService:GetMouseLocation().Y)).magnitude
            
            if magnitude < ShortestDistance then
                closestPlayer = player
                ShortestDistance = magnitude
            end
        end
    end
    
    self.Config.Main.Target = closestPlayer
    return closestPlayer
end

function WaxWare:MakeMarker(Parent, Adornee, Color, Size, Size2)
    local box = Instance.new("BillboardGui", Parent)
    box.Name = "Wuss.Private"
    box.Adornee = Adornee
    box.Size = UDim2.new(Size, Size2, Size, Size2)
    box.AlwaysOnTop = true
    
    local a = Instance.new("Frame", box)
    a.Size = UDim2.new(1.5, 0, 3, 0)
    a.BackgroundColor3 = Color
    
    local g = Instance.new("UICorner", a)
    g.CornerRadius = UDim.new(50, 25)
    return box
end

-- Notification helper
function WaxWare:Notify(title, text)
    self.Services.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text
    })
end

-- Initialize the aimbot
function WaxWare:Init()
    -- Initialize library and GUI
    self:InitLibrary()
    self:CreateGUI()

    -- Create box instance
    self.Instances.Box = Instance.new("Part", self.Services.Workspace)
    self.Instances.Box.Anchored = true
    self.Instances.Box.CanCollide = false
    self.Instances.Box.Size = Vector3.new(3.3, 5, 3)
    self.Instances.Box.Transparency = 0.7
    self:MakeMarker(self.Instances.Box, self.Instances.Box, self.Config.Main.RectangleColor, 0.40, 1)

    -- Keybind connection
    table.insert(self.Instances.Connections, self.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode[self.Config.Main.AimlockKey:upper()] then
            if self.Config.Main.Enabled then
                self.Config.Main.Enabled = false
                if self.Config.Main.Notifications then
                    self:Notify("WaxWare", "Unlocked")
                end
            else
                self:FindClosestUser()
                self.Config.Main.Enabled = true
                if self.Config.Main.Notifications and self.Config.Main.Target then
                    self:Notify("WaxWare", "Try confusing my prediction; " .. tostring(self.Config.Main.Target.Character.Humanoid.DisplayName))
                end
            end
        end
    end))

    -- Stepped connection for visuals and aimbot
    table.insert(self.Instances.Connections, self.Services.RunService.Stepped:Connect(function()
        -- Update visuals
        if self.Config.Visuals.FOV.Enabled then
            self.Config.Visuals.FOV.Circle.Position = Vector2.new(self.Services.UserInputService:GetMouseLocation().X, self.Services.UserInputService:GetMouseLocation().Y)
            
            if self.Config.Visuals.FOV.Spinning then
                -- Implement spinning logic here
            end
        end
        
        if self.Config.Visuals.Crosshair.Enabled then
            self:UpdateCrosshair()
            
            if self.Config.Visuals.Crosshair.Spinning then
                -- Implement spinning logic here
            end
        end
        
        -- Update aimbot
        if self.Config.Main.Enabled and self.Config.Main.Target and self.Config.Main.Target.Character and self.Config.Main.Target.Character:FindFirstChild("HumanoidRootPart") then
            local jumpOffset = Vector3.new(0, 0, 0)
            if self.Config.Main.Target.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                jumpOffset = Vector3.new(0, self.Config.Main.JumpOffset, 0)
            end
            
            self.Instances.Box.CFrame = CFrame.new(
                self.Config.Main.Target.Character[self.Config.Main.AimPart].Position + 
                (self.Config.Main.Target.Character.UpperTorso.Velocity * self.Config.Main.Prediction) + 
                jumpOffset
            )
        else
            self.Instances.Box.CFrame = CFrame.new(0, 9999, 0)
        end
    end))

    -- Death notification
    table.insert(self.Instances.Connections, self.Services.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid").Died:Connect(function()
            if self.Config.Main.Notifications and self.Config.Main.Enabled then
                self:Notify("WaxWare", "Nigga died. ggs.")
            end
        end)
    end))

    -- Mouse hook
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(...)
        local args = {...}
        if self.Config.Main.Enabled and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" and 
           self.Config.Main.Target and self.Config.Main.Target.Character and self.Config.Main.Target.Character:FindFirstChild(self.Config.Main.AimPart) then
            local jumpOffset = Vector3.new(0, 0, 0)
            if self.Config.Main.Target.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                jumpOffset = Vector3.new(0, self.Config.Main.JumpOffset, 0)
            end
            
            args[3] = self.Config.Main.Target.Character[self.Config.Main.AimPart].Position + 
                     (self.Config.Main.Target.Character[self.Config.Main.AimPart].Velocity * self.Config.Main.Prediction) + 
                     jumpOffset
            return old(unpack(args))
        end
        return old(...)
    end)

    -- Initialize visuals
    self:UpdateFOV()
    self:UpdateCrosshair()
    self:UpdateFog()
end

-- Start the script
WaxWare:Init()
