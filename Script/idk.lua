local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local enabled = true

rs.Heartbeat:Connect(function()
    if enabled and hum.FloorMaterial == Enum.Material.Air then
        local dir = -workspace.CurrentCamera.CFrame.LookVector.Unit * 42
        hrp.Velocity = Vector3.new(dir.X, hrp.Velocity.Y, dir.Z)
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
