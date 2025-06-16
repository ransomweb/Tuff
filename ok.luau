getgenv().prediction = 0.0217727 
getgenv().offset = 0
getgenv().resolver = false
getgenv().smoothness = 0.87172

getgenv().JumpAdjustment = 3.6
getgenv().FallAdjustment = 1.9
getgenv().JumpSmoothing = 0.07
getgenv().FallSmoothing = 0.07

local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local userinputservice = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera

local victim = nil
local targeting = false

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

userinputservice.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.C then  -- Keybind: C
        targeting = not targeting
        if targeting then
            victim = target()
        else
            victim = nil
        end
    end
end)

local velocity = Vector3.new(0, 0, 0)
local oldpos = Vector3.new(0, 0, 0)

runservice.Heartbeat:Connect(function(deltaTime)
    if victim and victim.Parent then
        local currentpos = victim.Position
        local displacement = currentpos - oldpos
        local vector = displacement / deltaTime

        velocity = velocity:Lerp(Vector3.new(
            vector.X,
            vector.Y * 0.94 * getgenv().offset,
            vector.Z
        ), 0.4)

        oldpos = currentpos
    end
end)

runservice.RenderStepped:Connect(function()
    if targeting and victim and victim.Parent then
        if victim.Parent:FindFirstChildOfClass("Humanoid") then
            if victim.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                local humanoid = victim.Parent:FindFirstChildOfClass("Humanoid")
                local yVelocity = humanoid.RootPart.Velocity.Y
                local pos

                if getgenv().usePrediction then
                    if getgenv().resolver then
                        pos = victim.Position + (velocity * getgenv().prediction)  -- Using new prediction value
                    else
                        pos = victim.Position + (victim.Velocity * getgenv().prediction)  -- Using new prediction value
                    end
                else
                    pos = victim.Position
                end

                local smoothness = getgenv().smoothness

                if yVelocity > 1 then
                    pos = pos + Vector3.new(0, getgenv().JumpAdjustment, 0)
                    smoothness = getgenv().JumpSmoothing
                elseif yVelocity < -1 then
                    pos = pos + Vector3.new(0, -getgenv().FallAdjustment, 0)
                    smoothness = getgenv().FallSmoothing
                end

                currentCamera.CFrame = currentCamera.CFrame:Lerp(CFrame.new(currentCamera.CFrame.Position, pos), smoothness)
            end
        end
    end
end)

print("Central Aim Assist Loaded | Keybind: C | Prediction: " .. getgenv().prediction)
