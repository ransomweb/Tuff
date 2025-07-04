local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local enabled = true
local airborne = false

rs.Heartbeat:Connect(function()
    if not enabled then return end
    if hum.FloorMaterial == Enum.Material.Air then
        airborne = true
        local dir = -workspace.CurrentCamera.CFrame.LookVector.Unit * 42
        hrp.Velocity = Vector3.new(dir.X, hrp.Velocity.Y, dir.Z)
    elseif airborne then
        airborne = false
        hrp.Velocity = Vector3.new(0, -500, 0)
    end
end)

uis.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then
        enabled = not enabled
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Pred Breaker",
                Text = enabled and "Enabled" or "Disabled",
                Duration = 2
            })
        end)
    end
end)
