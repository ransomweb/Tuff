-- Azurite UI Library
-- A modern, feature-rich UI library for Roblox

local Azurite = {}
Azurite.__index = Azurite

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

-- Constants
local ACCENT_COLOR = Color3.fromRGB(100, 150, 255)
local BACKGROUND_COLOR = Color3.fromRGB(22, 22, 22)
local TEXT_COLOR = Color3.fromRGB(200, 200, 200)
local ELEMENT_COLOR = Color3.fromRGB(30, 30, 30)
local BORDER_COLOR = Color3.fromRGB(60, 60, 60)

-- Utility functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function Round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function DarkenColor(color, factor)
    return Color3.new(
        math.max(0, color.R * factor),
        math.max(0, color.G * factor),
        math.max(0, color.B * factor)
end

local function GetTextSize(text, fontSize, font)
    return TextService:GetTextSize(text, fontSize, font, Vector2.new(10000, 10000))
end

-- Main Window
function Azurite.new(options)
    options = options or {}
    local self = setmetatable({}, Azurite)
    
    self.Name = options.Name or "Azurite"
    self.Size = options.Size or Vector2.new(600, 400)
    self.Position = options.Position or UDim2.new(0.5, -300, 0.5, -200)
    self.AccentColor = options.AccentColor or ACCENT_COLOR
    self.Theme = {
        Background = options.BackgroundColor or BACKGROUND_COLOR,
        Text = options.TextColor or TEXT_COLOR,
        Element = options.ElementColor or ELEMENT_COLOR,
        Border = options.BorderColor or BORDER_COLOR
    }
    
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    self.Visible = options.Visible ~= false
    self.Tabs = {}
    self.ActiveTab = nil
    self.Flags = {}
    
    -- Create main UI
    self.ScreenGui = Create("ScreenGui", {
        Name = self.Name,
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    })
    
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, self.Size.X, 0, self.Size.Y),
        Position = self.Position,
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Active = true,
        Draggable = true,
        Parent = self.ScreenGui
    })
    
    -- Header
    self.Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = DarkenColor(self.Theme.Background, 0.8),
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    self.AccentBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Parent = self.Header
    })
    
    self.Title = Create("TextLabel", {
        Size = UDim2.new(0, 350, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = self.Header
    })
    
    -- Tab container
    self.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = DarkenColor(self.Theme.Background, 0.9),
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    self.TabListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabContainer
    })
    
    -- Content area
    self.ContentFrame = Create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1,
        Parent = self.MainFrame
    })
    
    -- Keybind setup
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)
    
    return self
end

function Azurite:Toggle()
    self.Visible = not self.Visible
    self.ScreenGui.Enabled = self.Visible
end

function Azurite:SetToggleKey(keyCode)
    self.ToggleKey = keyCode
end

-- Tab functions
function Azurite:AddTab(name)
    local tab = {
        Name = name,
        Parent = self,
        Sections = {}
    }
    
    -- Tab button
    tab.Button = Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = self.TabContainer
    })
    
    -- Tab content
    tab.Content = Create("Frame", {
        Name = name .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.ContentFrame
    })
    
    tab.ScrollingFrame = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = self.AccentColor,
        Parent = tab.Content
    })
    
    tab.ContentList = Create("UIListLayout", {
        Padding = UDim.new(0, 15),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.ScrollingFrame
    })
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SetActiveTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SetActiveTab(tab)
    end
    
    return setmetatable(tab, {
        __index = function(t, k)
            if k == "AddSection" then
                return function(_, options)
                    return self:AddSection(t, options)
                end
            end
            return rawget(t, k)
        end
    })
end

function Azurite:SetActiveTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Content.Visible = false
        self.ActiveTab.Button.BackgroundColor3 = self.Theme.Element
        self.ActiveTab.Button.TextColor3 = self.Theme.Text
    end
    
    self.ActiveTab = tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = DarkenColor(self.Theme.Element, 0.8)
    tab.Button.TextColor3 = self.AccentColor
end

-- Section functions
function Azurite:AddSection(tab, options)
    options = options or {}
    local section = {
        Name = options.Name or "Section",
        Size = options.Size or UDim2.new(1, -10, 0, 200),
        Parent = tab
    }
    
    section.Frame = Create("Frame", {
        Name = section.Name,
        Size = section.Size,
        BackgroundColor3 = DarkenColor(self.Theme.Background, 0.9),
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Parent = tab.ScrollingFrame
    })
    
    section.Accent = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Parent = section.Frame
    })
    
    section.Header = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = DarkenColor(self.Theme.Background, 0.8),
        BorderSizePixel = 0,
        Text = section.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = section.Frame
    })
    
    section.Content = Create("Frame", {
        Size = UDim2.new(1, -10, 1, -35),
        Position = UDim2.new(0, 5, 0, 30),
        BackgroundTransparency = 1,
        Parent = section.Frame
    })
    
    section.ListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = section.Content
    })
    
    -- Update scrolling frame canvas size
    section.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, section.ListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    return setmetatable(section, {
        __index = function(t, k)
            local componentFuncs = {
                AddToggle = function(_, options) return self:AddToggle(t, options) end,
                AddSlider = function(_, options) return self:AddSlider(t, options) end,
                AddDropdown = function(_, options) return self:AddDropdown(t, options) end,
                AddButton = function(_, options) return self:AddButton(t, options) end,
                AddKeybind = function(_, options) return self:AddKeybind(t, options) end,
                AddTextbox = function(_, options) return self:AddTextbox(t, options) end,
                AddLabel = function(_, options) return self:AddLabel(t, options) end
            }
            
            if componentFuncs[k] then
                return componentFuncs[k]
            end
            return rawget(t, k)
        end
    })
end

-- Component functions
function Azurite:AddToggle(section, options)
    options = options or {}
    local toggle = {
        Name = options.Name or "Toggle",
        Default = options.Default or false,
        Flag = options.Flag or options.Name or "Toggle",
        Callback = options.Callback or function() end
    }
    
    self.Flags[toggle.Flag] = toggle.Default
    
    toggle.Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    toggle.Button = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 15),
        Position = UDim2.new(0, 0, 0.5, -7.5),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = "",
        Parent = toggle.Frame
    })
    
    toggle.Indicator = Create("Frame", {
        Size = UDim2.new(0, 13, 0, 13),
        Position = UDim2.new(0, 1, 0.5, -6.5),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = toggle.Button
    })
    
    toggle.Label = Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = toggle.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggle.Frame
    })
    
    local function UpdateToggle(value)
        self.Flags[toggle.Flag] = value
        if value then
            toggle.Indicator.Position = UDim2.new(1, -14, 0.5, -6.5)
            toggle.Indicator.BackgroundColor3 = self.AccentColor
            toggle.Button.BackgroundColor3 = DarkenColor(self.AccentColor, 0.7)
        else
            toggle.Indicator.Position = UDim2.new(0, 1, 0.5, -6.5)
            toggle.Indicator.BackgroundColor3 = self.Theme.Background
            toggle.Button.BackgroundColor3 = self.Theme.Element
        end
        toggle.Callback(value)
    end
    
    toggle.Button.MouseButton1Click:Connect(function()
        UpdateToggle(not self.Flags[toggle.Flag])
    end)
    
    UpdateToggle(toggle.Default)
    
    return {
        AddColorPicker = function(_, options)
            return self:AddColorPicker(toggle.Frame, options)
        end,
        AddKeybind = function(_, options)
            return self:AddKeybind(toggle.Frame, options)
        end
    }
end

function Azurite:AddSlider(section, options)
    options = options or {}
    local slider = {
        Name = options.Name or "Slider",
        Min = options.Min or 0,
        Max = options.Max or 100,
        Default = options.Default or options.Min or 0,
        Decimals = options.Decimals or 1,
        Suffix = options.Suffix or "",
        Flag = options.Flag or options.Name or "Slider",
        Callback = options.Callback or function() end
    }
    
    self.Flags[slider.Flag] = slider.Default
    
    slider.Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    slider.Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = slider.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider.Frame
    })
    
    slider.ValueLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 15),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(slider.Default) .. slider.Suffix,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = slider.Frame
    })
    
    slider.Track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Parent = slider.Frame
    })
    
    slider.Fill = Create("Frame", {
        Size = UDim2.new((slider.Default - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Parent = slider.Track
    })
    
    slider.Dot = Create("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(slider.Fill.Size.X.Scale, -5, 0.5, -5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Parent = slider.Track
    })
    
    local function UpdateSlider(value)
        value = Round(math.clamp(value, slider.Min, slider.Max), slider.Decimals)
        self.Flags[slider.Flag] = value
        slider.ValueLabel.Text = tostring(value) .. slider.Suffix
        slider.Fill.Size = UDim2.new((value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0)
        slider.Dot.Position = UDim2.new(slider.Fill.Size.X.Scale, -5, 0.5, -5)
        slider.Callback(value)
    end
    
    local isDragging = false
    
    slider.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            local percent = (input.Position.X - slider.Track.AbsolutePosition.X) / slider.Track.AbsoluteSize.X
            UpdateSlider(slider.Min + (slider.Max - slider.Min) * percent)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = (input.Position.X - slider.Track.AbsolutePosition.X) / slider.Track.AbsoluteSize.X
            UpdateSlider(slider.Min + (slider.Max - slider.Min) * percent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UpdateSlider(slider.Default)
    
    return slider
end

function Azurite:AddDropdown(section, options)
    options = options or {}
    local dropdown = {
        Name = options.Name or "Dropdown",
        Options = options.Options or {"Option 1", "Option 2", "Option 3"},
        Default = options.Default or options.Options and options.Options[1] or "Option 1",
        MultiSelect = options.MultiSelect or false,
        Flag = options.Flag or options.Name or "Dropdown",
        Callback = options.Callback or function() end
    }
    
    self.Flags[dropdown.Flag] = dropdown.MultiSelect and {dropdown.Default} or dropdown.Default
    
    dropdown.Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    dropdown.Label = Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 15),
        BackgroundTransparency = 1,
        Text = dropdown.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown.Frame
    })
    
    dropdown.Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 15),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = dropdown.MultiSelect and dropdown.Default or tostring(dropdown.Default),
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = dropdown.Frame
    })
    
    dropdown.Arrow = Create("ImageLabel", {
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(564, 284),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = self.Theme.Text,
        Parent = dropdown.Frame
    })
    
    dropdown.OptionsFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = dropdown.Frame
    })
    
    dropdown.OptionsList = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdown.OptionsFrame
    })
    
    local isOpen = false
    
    local function UpdateDropdown()
        if dropdown.MultiSelect then
            local selectedText = ""
            for i, option in pairs(self.Flags[dropdown.Flag]) do
                selectedText = selectedText .. (i > 1 and ", " or "") .. option
            end
            dropdown.Button.Text = #self.Flags[dropdown.Flag] > 0 and selectedText or "None"
        else
            dropdown.Button.Text = tostring(self.Flags[dropdown.Flag])
        end
        dropdown.Callback(self.Flags[dropdown.Flag])
    end
    
    local function ToggleDropdown()
        isOpen = not isOpen
        dropdown.OptionsFrame.Visible = isOpen
        dropdown.Arrow.Rotation = isOpen and 180 or 0
        
        if isOpen then
            -- Clear existing options
            for _, child in ipairs(dropdown.OptionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Add new options
            for _, option in ipairs(dropdown.Options) do
                local optionButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundColor3 = self.Theme.Element,
                    BorderSizePixel = 0,
                    Text = option,
                    TextColor3 = self.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdown.OptionsFrame
                })
                
                if dropdown.MultiSelect then
                    optionButton.Text = (table.find(self.Flags[dropdown.Flag], option) and "✓ " or "  ") .. option
                end
                
                optionButton.MouseButton1Click:Connect(function()
                    if dropdown.MultiSelect then
                        local selected = self.Flags[dropdown.Flag]
                        local index = table.find(selected, option)
                        
                        if index then
                            table.remove(selected, index)
                        else
                            table.insert(selected, option)
                        end
                        
                        self.Flags[dropdown.Flag] = selected
                    else
                        self.Flags[dropdown.Flag] = option
                        ToggleDropdown()
                    end
                    
                    UpdateDropdown()
                end)
            end
            
            -- Update options frame size
            dropdown.OptionsFrame.Size = UDim2.new(1, 0, 0, #dropdown.Options * 25)
        end
    end
    
    dropdown.Button.MouseButton1Click:Connect(ToggleDropdown)
    
    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            if not dropdown.Frame:IsDescendantOf(input:GetMouseTarget()) then
                ToggleDropdown()
            end
        end
    end)
    
    UpdateDropdown()
    
    return dropdown
end

function Azurite:AddButton(section, options)
    options = options or {}
    local button = {
        Name = options.Name or "Button",
        Callback = options.Callback or function() end
    }
    
    button.Frame = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = button.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = section.Content
    })
    
    button.Frame.MouseButton1Click:Connect(button.Callback)
    
    -- Button animation
    button.Frame.MouseEnter:Connect(function()
        TweenService:Create(button.Frame, TweenInfo.new(0.1), {
            BackgroundColor3 = DarkenColor(self.Theme.Element, 0.9)
        }):Play()
    end)
    
    button.Frame.MouseLeave:Connect(function()
        TweenService:Create(button.Frame, TweenInfo.new(0.1), {
            BackgroundColor3 = self.Theme.Element
        }):Play()
    end)
    
    button.Frame.MouseButton1Down:Connect(function()
        TweenService:Create(button.Frame, TweenInfo.new(0.1), {
            BackgroundColor3 = self.AccentColor
        }):Play()
    end)
    
    button.Frame.MouseButton1Up:Connect(function()
        TweenService:Create(button.Frame, TweenInfo.new(0.1), {
            BackgroundColor3 = DarkenColor(self.Theme.Element, 0.9)
        }):Play()
    end)
    
    return button
end

function Azurite:AddKeybind(section, options)
    options = options or {}
    local keybind = {
        Name = options.Name or "Keybind",
        Default = options.Default or Enum.KeyCode.Unknown,
        Flag = options.Flag or options.Name or "Keybind",
        Callback = options.Callback or function() end,
        Mode = options.Mode or "Toggle" -- Toggle or Hold
    }
    
    self.Flags[keybind.Flag] = false
    
    keybind.Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    keybind.Label = Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 15),
        BackgroundTransparency = 1,
        Text = keybind.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybind.Frame
    })
    
    keybind.Button = Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 25),
        Position = UDim2.new(1, -60, 0, 5),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = keybind.Default.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = keybind.Frame
    })
    
    local isListening = false
    local currentKey = keybind.Default
    
    local function UpdateKeybind(key)
        currentKey = key
        keybind.Button.Text = key.Name
        keybind.Callback(key)
    end
    
    keybind.Button.MouseButton1Click:Connect(function()
        isListening = true
        keybind.Button.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isListening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                UpdateKeybind(input.KeyCode)
                isListening = false
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 then
                UpdateKeybind(input.UserInputType)
                isListening = false
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            if keybind.Mode == "Toggle" then
                self.Flags[keybind.Flag] = not self.Flags[keybind.Flag]
            elseif keybind.Mode == "Hold" then
                self.Flags[keybind.Flag] = true
            end
            keybind.Callback(self.Flags[keybind.Flag])
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey and keybind.Mode == "Hold" then
            self.Flags[keybind.Flag] = false
            keybind.Callback(self.Flags[keybind.Flag])
        end
    end)
    
    UpdateKeybind(keybind.Default)
    
    return keybind
end

function Azurite:AddTextbox(section, options)
    options = options or {}
    local textbox = {
        Name = options.Name or "Textbox",
        Default = options.Default or "",
        Placeholder = options.Placeholder or "Enter text...",
        Flag = options.Flag or options.Name or "Textbox",
        Callback = options.Callback or function() end
    }
    
    self.Flags[textbox.Flag] = textbox.Default
    
    textbox.Frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = section.Content
    })
    
    textbox.Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = textbox.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textbox.Frame
    })
    
    textbox.Input = Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 15),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Text = textbox.Default,
        PlaceholderText = textbox.Placeholder,
        TextColor3 = self.Theme.Text,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = textbox.Frame
    })
    
    textbox.Input.FocusLost:Connect(function()
        self.Flags[textbox.Flag] = textbox.Input.Text
        textbox.Callback(textbox.Input.Text)
    end)
    
    return textbox
end

function Azurite:AddLabel(section, options)
    options = options or {}
    local label = {
        Text = options.Text or "Label",
        Color = options.Color or self.Theme.Text
    }
    
    label.Frame = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = label.Text,
        TextColor3 = label.Color,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.Content
    })
    
    return label
end

function Azurite:AddColorPicker(parent, options)
    options = options or {}
    local colorpicker = {
        Name = options.Name or "Color",
        Default = options.Default or Color3.fromRGB(255, 255, 255),
        Flag = options.Flag or options.Name or "Color",
        Callback = options.Callback or function() end
    }
    
    self.Flags[colorpicker.Flag] = colorpicker.Default
    
    colorpicker.Frame = Create("Frame", {
        Size = UDim2.new(0, 30, 0, 15),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundColor3 = colorpicker.Default,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Parent = parent
    })
    
    colorpicker.PickerFrame = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 150),
        Position = UDim2.new(1, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderColor3 = self.Theme.Border,
        BorderSizePixel = 1,
        Visible = false,
        Parent = colorpicker.Frame
    })
    
    colorpicker.Saturation = Create("ImageLabel", {
        Size = UDim2.new(0, 150, 0, 150),
        Position = UDim2.new(0, 5, 0, 5),
        Image = "rbxassetid://4155801252",
        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
        Parent = colorpicker.PickerFrame
    })
    
    colorpicker.Hue = Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 150),
        Position = UDim2.new(1, -25, 0, 5),
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.new(1, 1, 1),
        Parent = colorpicker.PickerFrame
    })
    
    colorpicker.SaturationSelector = Create("Frame", {
        Size = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 1,
        Parent = colorpicker.Saturation
    })
    
    colorpicker.HueSelector = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 1,
        Parent = colorpicker.Hue
    })
    
    local isOpen = false
    local isDraggingHue = false
    local isDraggingSaturation = false
    local currentHue = 0
    
    local function UpdateColor(color)
        self.Flags[colorpicker.Flag] = color
        colorpicker.Frame.BackgroundColor3 = color
        colorpicker.Saturation.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        colorpicker.Callback(color)
    end
    
    local function TogglePicker()
        isOpen = not isOpen
        colorpicker.PickerFrame.Visible = isOpen
    end
    
    colorpicker.Frame.MouseButton1Click:Connect(TogglePicker)
    
    colorpicker.Hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            local percent = (input.Position.Y - colorpicker.Hue.AbsolutePosition.Y) / colorpicker.Hue.AbsoluteSize.Y
            currentHue = 1 - math.clamp(percent, 0, 1)
            colorpicker.HueSelector.Position = UDim2.new(0, 0, percent, -1)
            
            local saturationX = (colorpicker.SaturationSelector.Position.X.Scale * colorpicker.Saturation.AbsoluteSize.X + colorpicker.Saturation.AbsolutePosition.X - colorpicker.Saturation.AbsolutePosition.X) / colorpicker.Saturation.AbsoluteSize.X
            local saturationY = (colorpicker.SaturationSelector.Position.Y.Scale * colorpicker.Saturation.AbsoluteSize.Y + colorpicker.Saturation.AbsolutePosition.Y - colorpicker.Saturation.AbsolutePosition.Y) / colorpicker.Saturation.AbsoluteSize.Y
            
            UpdateColor(Color3.fromHSV(
                currentHue,
                math.clamp(saturationX, 0, 1),
                1 - math.clamp(saturationY, 0, 1)
            ))
        end
    end)
    
    colorpicker.Saturation.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSaturation = true
            local x = (input.Position.X - colorpicker.Saturation.AbsolutePosition.X) / colorpicker.Saturation.AbsoluteSize.X
            local y = (input.Position.Y - colorpicker.Saturation.AbsolutePosition.Y) / colorpicker.Saturation.AbsoluteSize.Y
            
            colorpicker.SaturationSelector.Position = UDim2.new(math.clamp(x, 0, 1), -2, math.clamp(y, 0, 1), -2)
            UpdateColor(Color3.fromHSV(
                currentHue,
                math.clamp(x, 0, 1),
                1 - math.clamp(y, 0, 1)
            ))
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = (input.Position.Y - colorpicker.Hue.AbsolutePosition.Y) / colorpicker.Hue.AbsoluteSize.Y
            currentHue = 1 - math.clamp(percent, 0, 1)
            colorpicker.HueSelector.Position = UDim2.new(0, 0, percent, -1)
            
            local saturationX = (colorpicker.SaturationSelector.Position.X.Scale * colorpicker.Saturation.AbsoluteSize.X + colorpicker.Saturation.AbsolutePosition.X - colorpicker.Saturation.AbsolutePosition.X) / colorpicker.Saturation.AbsoluteSize.X
            local saturationY = (colorpicker.SaturationSelector.Position.Y.Scale * colorpicker.Saturation.AbsoluteSize.Y + colorpicker.Saturation.AbsolutePosition.Y - colorpicker.Saturation.AbsolutePosition.Y) / colorpicker.Saturation.AbsoluteSize.Y
            
            UpdateColor(Color3.fromHSV(
                currentHue,
                math.clamp(saturationX, 0, 1),
                1 - math.clamp(saturationY, 0, 1)
            ))
        elseif isDraggingSaturation and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = (input.Position.X - colorpicker.Saturation.AbsolutePosition.X) / colorpicker.Saturation.AbsoluteSize.X
            local y = (input.Position.Y - colorpicker.Saturation.AbsolutePosition.Y) / colorpicker.Saturation.AbsoluteSize.Y
            
            colorpicker.SaturationSelector.Position = UDim2.new(math.clamp(x, 0, 1), -2, math.clamp(y, 0, 1), -2)
            UpdateColor(Color3.fromHSV(
                currentHue,
                math.clamp(x, 0, 1),
                1 - math.clamp(y, 0, 1)
            ))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = false
            isDraggingSaturation = false
        end
    end)
    
    -- Close when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            if not colorpicker.PickerFrame:IsDescendantOf(input:GetMouseTarget()) and 
               not colorpicker.Frame:IsDescendantOf(input:GetMouseTarget()) then
                TogglePicker()
            end
        end
    end)
    
    -- Initialize with default color
    local r, g, b = colorpicker.Default.R, colorpicker.Default.G, colorpicker.Default.B
    local h, s, v = Color3.toHSV(colorpicker.Default)
    currentHue = h
    colorpicker.HueSelector.Position = UDim2.new(0, 0, 1 - h, -1)
    colorpicker.SaturationSelector.Position = UDim2.new(s, -2, 1 - v, -2)
    colorpicker.Saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    
    return colorpicker
end

-- Config system
function Azurite:SaveConfig(name)
    if not name or name == "" then return end
    
    local config = {
        Flags = self.Flags,
        Theme = self.Theme,
        AccentColor = self.AccentColor,
        ToggleKey = self.ToggleKey.Name
    }
    
    local json = HttpService:JSONEncode(config)
    
    if not isfolder("Azurite") then
        makefolder("Azurite")
    end
    
    writefile("Azurite/" .. name .. ".json", json)
end

function Azurite:LoadConfig(name)
    if not name or name == "" then return end
    
    if isfile("Azurite/" .. name .. ".json") then
        local success, config = pcall(function()
            return HttpService:JSONDecode(readfile("Azurite/" .. name .. ".json"))
        end)
        
        if success and config then
            self.Flags = config.Flags or self.Flags
            self.Theme = config.Theme or self.Theme
            self.AccentColor = config.AccentColor or self.AccentColor
            self.ToggleKey = Enum.KeyCode[config.ToggleKey] or self.ToggleKey
            
            -- TODO: Update UI elements to reflect loaded config
        end
    end
end

return Azurite
