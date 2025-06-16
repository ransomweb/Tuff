local player = game.Players.LocalPlayer

if player.Character and player.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
    return
end

local function AntiGoofy()
    local character = player.Character
    local animate = character:WaitForChild("Animate")

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end

    if animate:FindFirstChild("run") then
        animate:WaitForChild("run"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("jump") then
        animate:WaitForChild("jump"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("fall") then
        animate:WaitForChild("fall"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("climb") then
        animate:WaitForChild("climb"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("swim") then
        animate:WaitForChild("swim"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("swimidle") then
        animate:WaitForChild("swimidle"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("walk") then
        animate:WaitForChild("walk"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
    if animate:FindFirstChild("idle") then
        animate.idle:WaitForChild("Animation1").AnimationId = "http://www.roblox.com/asset/?id=0"
        animate.idle:WaitForChild("Animation2").AnimationId = "http://www.roblox.com/asset/?id=0"
    end
end

local function setAnimations()
    local character = player.Character
    local animate = character:WaitForChild("Animate")

    if animate:FindFirstChild("run") then
        animate:WaitForChild("run"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=616163682"
    end
    if animate:FindFirstChild("jump") then
        animate:WaitForChild("jump"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=10921242013"
    end
    if animate:FindFirstChild("fall") then
        animate:WaitForChild("fall"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=707829716"
    end
    if animate:FindFirstChild("climb") then
        animate:WaitForChild("climb"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=5319816685"
    end
    if animate:FindFirstChild("swim") then
        animate:WaitForChild("swim"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=707876443"
    end
    if animate:FindFirstChild("swimidle") then
        animate:WaitForChild("swimidle"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=707894699"
    end
    if animate:FindFirstChild("walk") then
        animate:WaitForChild("walk"):FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=10921269718"
    end
    if animate:FindFirstChild("idle") then
        animate.idle:WaitForChild("Animation1").AnimationId = "http://www.roblox.com/asset/?id=616158929"
        animate.idle:WaitForChild("Animation2").AnimationId = "http://www.roblox.com/asset/?id=616158929"
    end
end

local function onCharacterAdded(character)
    AntiGoofy()
    setAnimations()
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

getgenv().Time = 1
getgenv().Head = {113677448022534}

local function weldParts(part0, part1, c0, c1)
    local weld = Instance.new("Weld")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.C0 = c0
    weld.C1 = c1
    weld.Parent = part0
    return weld
end

local function findAttachment(rootPart, name)
    for _, descendant in pairs(rootPart:GetDescendants()) do
        if descendant:IsA("Attachment") and descendant.Name == name then
            return descendant
        end
    end
end

local function addAccessoryToCharacter(accessoryId, parentPart)
    local accessory = game:GetObjects("rbxassetid://" .. tostring(accessoryId))[1]
    accessory.Parent = game.Workspace

    local handle = accessory:FindFirstChild("Handle")
    if handle then
        local attachment = handle:FindFirstChildOfClass("Attachment")
        if attachment then
            local parentAttachment = findAttachment(parentPart, attachment.Name)
            if parentAttachment then
                weldParts(parentPart, handle, parentAttachment.CFrame, attachment.CFrame)
            end
        else
            handle.CFrame = parentPart.CFrame
            weldParts(parentPart, handle, CFrame.new(), CFrame.new())
        end
    end

    accessory.Parent = character
end

local function onCharacterAdded(char)
    wait(getgenv().Time)

    for _, accessoryId in ipairs(getgenv().Head) do
        local head = char:FindFirstChild("Head")
        if head then
            addAccessoryToCharacter(accessoryId, head)
        end
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

if character then
    onCharacterAdded(character)
end
