 
getgenv().HitboxExpander = true
getgenv().HitboxSize = 6
getgenv().HitboxRefreshTime = 5

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


for _, v in ipairs(workspace:GetChildren()) do
    if v:IsA("Part") and v.Name == "FakeHitbox" then
        v:Destroy()
    end
end

while getgenv().HitboxExpander do
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= LocalPlayer.Character then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local root = humanoid and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)

            if humanoid and humanoid.Health > 0 and root then
                local isPlayer = Players:GetPlayerFromCharacter(model)
                if not isPlayer then
                    
                    local existingHitbox = model:FindFirstChild("FakeHitbox")
                    if not existingHitbox then
                        
                        local fake = Instance.new("Part")
                        fake.Name = "FakeHitbox"
                        fake.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                        fake.Transparency = 1
                        fake.Anchored = false
                        fake.CanCollide = false
                        fake.Massless = true
                        fake.CFrame = root.CFrame
                        fake.Parent = model

                        
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = root
                        weld.Part1 = fake
                        weld.Parent = fake
                    end
                end
            end
        end
    end
    task.wait(getgenv().HitboxRefreshTime)
end

make the visuals good. the box not broken, make it like this, u have to toggle it to a person or bots. with E, and the box is like this

Blue little transparent main color
Light blue outline thinn so thin
light blue outline highlight on player/bot

and it has stats GUI or Target GUI
and its on the player/npc thats toggled to. Like it follows them smoothly. but instantly.

and its like this

<gray background>
<darker panel for below here>
<line gradient from light blue to transparent>
<gaps>
<locked player image avatar> (if its a bot, just say "???")
<locked player name above health bar> (if bot, just say some nonsense error that skid dont understand, in lua)
<separator>
<health bar gradient>
<label tool name>

<on left bottom ui, theres text says "Central Target GUI">

and its like this

<background>
<background> <panel> <background
<background>

like that, panel in middle. but still fits ui. and fits everything.

and everything so good improved implemented all logic, ALLAHUAKBAR. no comments! ALLAHUAKBAR ALLAHUAKBAR ALHAMDULILLAH 

use code font. and make the avatar background color like gray, and make it like this

<settings>

<main code>
so its like

getgenv().centralhb = {

make it low end PC friendly, and it has like lightning particle in the hitbox expander, doesnt reset when u respawn or when toggled person die or respawn. and make it u can configure the size, the color too. recommended size is 25
