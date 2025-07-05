loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua",true))()
-- We ♥️ Yufi
local mt = getrawmetatable(game)
setreadonly(mt, false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    if typeof(self) == "Instance" then
        if m == "FireServer" and self:IsA("RemoteEvent") then
            print("\n[KingYufi] RemoteEvent: ", self:GetFullName())
            for i, v in ipairs({...}) do
                print(" [", i, "]", typeof(v), v)
            end
        elseif m == "InvokeServer" and self:IsA("RemoteFunction") then
            print("\n[KingYufi] RemoteFunction: , self:GetFullName())
            for i, v in ipairs({...}) do
                print(" [", i, "]", typeof(v), v)
            end
        end
    end
    return old(self, ...)
end)

setreadonly(mt, true)
