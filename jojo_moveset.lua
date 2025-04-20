-- CRYSTALCHEAT - Advanced Roblox Cheat GUI
-- Optimized version with smooth fly and notifications

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Constants
local CRYSTAL_VERSION = "1.3"
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local DEFAULT_FLY_SPEED = 50
local KEYBIND_NONE = "None"
local FLY_SMOOTHNESS = 0.2 -- Меньшее значение = более плавный полёт (0.1-0.3 оптимально)
local FLY_DAMPING = 0.85 -- Коэффициент затухания для плавности (0.8-0.95 оптимально)

-- Original values storage
local OriginalValues = {
    WalkSpeed = DEFAULT_SPEED,
    JumpPower = DEFAULT_JUMP,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- State
local Settings = {
    Fly = {Enabled = false, Speed = DEFAULT_FLY_SPEED, Keybind = "F"},
    Speed = {Enabled = false, Value = 50, Keybind = "C"},
    Noclip = {Enabled = false, Keybind = "V"},
    ESP = {Enabled = false, Keybind = "X"},
    InfJump = {Enabled = false, Keybind = "Space"},
    Teleport = {Enabled = false, Keybind = "T"},
    Xray = {Enabled = false, Keybind = "Z"},
    FullBright = {Enabled = false, Keybind = "B"},
    NoFall = {Enabled = false, Keybind = KEYBIND_NONE}
}

-- UI State
local ActiveTab = "Movement"
local IsDragging = false
local DragOffset = Vector2.new(0, 0)
local IsMinimized = false

-- Feature variables
local FlyPart = nil
local FlyConnection = nil
local NoclipConnection = nil
local ESPObjects = {}
local XrayTransparency = 0.6
local FlyKeys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false,
    LeftShift = false
}

-- Smooth fly variables
local FlyVelocity = Vector3.new(0, 0, 0)
local TargetFlyVelocity = Vector3.new(0, 0, 0)

-- Connections storage for cleanup
local Connections = {}

-- Function to store and disconnect connections
local function AddConnection(connection)
    table.insert(Connections, connection)
    return connection
end

-- Function to clean up all connections
local function CleanupConnections()
    for _, connection in ipairs(Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    Connections = {}
end

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    return instance
end

local function ApplyShadow(frame, strength)
    strength = strength or 4
    local shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, strength),
        Size = UDim2.new(1, strength * 2, 1, strength * 2),
        ZIndex = frame.ZIndex - 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Parent = frame
    })
    return shadow
end

local function ApplyGradient(frame, colorTop, colorBottom)
    local gradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colorTop),
            ColorSequenceKeypoint.new(1, colorBottom)
        }),
        Rotation = 90,
        Parent = frame
    })
    return gradient
end

local function CreateRoundedFrame(properties)
    local frame = CreateInstance("Frame", properties)
    local corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = frame
    })
    return frame
end

local function CreateStroke(parent, color, thickness)
    local stroke = CreateInstance("UIStroke", {
        Color = color,
        Thickness = thickness or 1.5,
        Parent = parent
    })
    return stroke
end

-- Notification System
local NotificationSystem = {}
local NotificationsFrame

function NotificationSystem.Init(parent)
    NotificationsFrame = CreateInstance("Frame", {
        Name = "NotificationsFrame",
        Size = UDim2.new(0, 250, 1, 0),
        Position = UDim2.new(1, -260, 0, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
end

function NotificationSystem.Show(title, message, color, duration)
    duration = duration or 3
    color = color or Color3.fromRGB(60, 120, 255)
    
    -- Create notification frame
    local notifFrame = CreateRoundedFrame({
        Name = "Notification_" .. os.time(),
        Size = UDim2.new(1, -10, 0, 60),
        Position = UDim2.new(0, 5, 1, 10), -- Start below screen
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Parent = NotificationsFrame
    })
    
    ApplyShadow(notifFrame, 5)
    ApplyGradient(notifFrame, Color3.fromRGB(40, 40, 40), Color3.fromRGB(25, 25, 25))
    
    -- Add colored indicator
    local indicator = CreateRoundedFrame({
        Name = "Indicator",
        Size = UDim2.new(0, 4, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = color,
        Parent = notifFrame
    })
    
    -- Add title
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 5),
        Text = title,
        TextColor3 = color,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame
    })
    
    -- Add message
    local messageLabel = CreateInstance("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 15, 0, 30),
        Text = message,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame
    })
    
    -- Reposition existing notifications
    local existingNotifs = {}
    for _, child in pairs(NotificationsFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= notifFrame then
            table.insert(existingNotifs, child)
        end
    end
    
    for i, notif in ipairs(existingNotifs) do
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.new(0, 5, 1, -70 * i - 60)
        }):Play()
    end
    
    -- Animate in
    TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0, 5, 1, -60)
    }):Play()
    
    -- Auto remove after duration
    spawn(function()
        wait(duration)
        
        -- Animate out
        TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 10, 1, -60)
        }):Play()
        
        wait(0.6)
        notifFrame:Destroy()
    end)
    
    return notifFrame
end

-- Feature Functions
local function HandleFlyInput(input, isPressed)
    if input.KeyCode == Enum.KeyCode.W then
        FlyKeys.W = isPressed
    elseif input.KeyCode == Enum.KeyCode.A then
        FlyKeys.A = isPressed
    elseif input.KeyCode == Enum.KeyCode.S then
        FlyKeys.S = isPressed
    elseif input.KeyCode == Enum.KeyCode.D then
        FlyKeys.D = isPressed
    elseif input.KeyCode == Enum.KeyCode.Space then
        FlyKeys.Space = isPressed
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        FlyKeys.LeftShift = isPressed
    end
end

local function ToggleFly(enabled)
    Settings.Fly.Enabled = enabled
    
    if enabled then
        -- Create fly part if needed
        if not FlyPart then
            FlyPart = Instance.new("Part")
            FlyPart.Name = "FlyPart"
            FlyPart.Size = Vector3.new(1, 1, 1)
            FlyPart.Transparency = 1
            FlyPart.CanCollide = false
            FlyPart.Anchored = true
            FlyPart.Parent = workspace
        end
        
        -- Reset fly velocities
        FlyVelocity = Vector3.new(0, 0, 0)
        TargetFlyVelocity = Vector3.new(0, 0, 0)
        
        -- Position fly part at character
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            FlyPart.CFrame = character.HumanoidRootPart.CFrame
            
            -- Connect input events for flying
            local flyInputBeganConnection = AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed then
                    HandleFlyInput(input, true)
                end
            end))
            
            local flyInputEndedConnection = AddConnection(UserInputService.InputEnded:Connect(function(input, gameProcessed)
                if not gameProcessed then
                    HandleFlyInput(input, false)
                end
            end))
            
            -- Connect fly update loop
            if FlyConnection then FlyConnection:Disconnect() end
            
            FlyConnection = AddConnection(RunService.RenderStepped:Connect(function(deltaTime)
                if not Settings.Fly.Enabled then return end
                
                -- Check if character still exists
                if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then
                    ToggleFly(false)
                    return
                end
                
                -- Calculate target velocity based on input
                local targetVelocity = Vector3.new(0, 0, 0)
                
                -- Forward/backward movement based on camera direction
                if FlyKeys.W then
                    targetVelocity = targetVelocity + Camera.CFrame.LookVector
                end
                if FlyKeys.S then
                    targetVelocity = targetVelocity - Camera.CFrame.LookVector
                end
                
                -- Left/right movement based on camera right vector
                if FlyKeys.A then
                    targetVelocity = targetVelocity - Camera.CFrame.RightVector
                end
                if FlyKeys.D then
                    targetVelocity = targetVelocity + Camera.CFrame.RightVector
                end
                
                -- Up/down movement
                if FlyKeys.Space then
                    targetVelocity = targetVelocity + Vector3.new(0, 1, 0)
                end
                if FlyKeys.LeftShift then
                    targetVelocity = targetVelocity - Vector3.new(0, 1, 0)
                end
                
                -- Normalize and apply speed
                if targetVelocity.Magnitude > 0 then
                    targetVelocity = targetVelocity.Unit * (Settings.Fly.Speed / 10)
                end
                
                -- Set target velocity
                TargetFlyVelocity = targetVelocity
                
                -- Smoothly interpolate current velocity towards target velocity
                FlyVelocity = FlyVelocity:Lerp(TargetFlyVelocity, FLY_SMOOTHNESS)
                
                -- Apply damping when no keys are pressed
                if TargetFlyVelocity.Magnitude == 0 then
                    FlyVelocity = FlyVelocity * FLY_DAMPING
                end
                
                -- Update fly part position
                FlyPart.CFrame = FlyPart.CFrame + FlyVelocity
                
                -- Make character follow fly part with smooth interpolation
                local targetCFrame = CFrame.new(FlyPart.Position)
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame:Lerp(targetCFrame, 0.2)
                character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end))
        end
        
        NotificationSystem.Show("Fly", "Плавный полёт включен", Color3.fromRGB(0, 255, 0))
    else
        -- Clean up fly resources
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        
        if FlyPart then
            FlyPart:Destroy()
            FlyPart = nil
        end
        
        -- Reset fly keys
        for key in pairs(FlyKeys) do
            FlyKeys[key] = false
        end
        
        -- Reset velocities
        FlyVelocity = Vector3.new(0, 0, 0)
        TargetFlyVelocity = Vector3.new(0, 0, 0)
        
        NotificationSystem.Show("Fly", "Полёт отключен", Color3.fromRGB(255, 0, 0))
    end
end

local function UpdateFlySpeed(value)
    Settings.Fly.Speed = value
    NotificationSystem.Show("Fly Speed", "Установлена скорость: " .. value, Color3.fromRGB(0, 200, 255))
end

local function ToggleSpeed(enabled)
    Settings.Speed.Enabled = enabled
    
    if enabled then
        -- Set character speed
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed.Value
        end)
        NotificationSystem.Show("Speed", "Скорость включена: " .. Settings.Speed.Value, Color3.fromRGB(0, 255, 0))
    else
        -- Reset character speed
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = OriginalValues.WalkSpeed
        end)
        NotificationSystem.Show("Speed", "Скорость отключена", Color3.fromRGB(255, 0, 0))
    end
end

local function UpdateSpeed(value)
    Settings.Speed.Value = value
    
    if Settings.Speed.Enabled then
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
        NotificationSystem.Show("Speed", "Установлена скорость: " .. value, Color3.fromRGB(0, 200, 255))
    end
end

local function ToggleNoclip(enabled)
    Settings.Noclip.Enabled = enabled
    
    if enabled then
        if NoclipConnection then NoclipConnection:Disconnect() end
        
        NoclipConnection = AddConnection(RunService.Stepped:Connect(function()
            if not LocalPlayer.Character then return end
            
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end))
        
        NotificationSystem.Show("Noclip", "Noclip включен", Color3.fromRGB(0, 255, 0))
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        
        -- Reset collision
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        
        NotificationSystem.Show("Noclip", "Noclip отключен", Color3.fromRGB(255, 0, 0))
    end
end

local function CreateESPBox(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    -- Create ESP components
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = CoreGui
    
    -- Box
    local boxPart = Instance.new("BoxHandleAdornment")
    boxPart.Name = "Box"
    boxPart.Size = Vector3.new(4, 5, 1)
    boxPart.Color3 = Color3.fromRGB(255, 0, 0)
    boxPart.Transparency = 0.7
    boxPart.AlwaysOnTop = true
    boxPart.ZIndex = 10
    boxPart.Adornee = character:FindFirstChild("HumanoidRootPart")
    boxPart.Parent = espFolder
    
    -- Name label
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NameTag"
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Adornee = character:FindFirstChild("Head")
    billboardGui.Parent = espFolder
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboardGui
    
    -- Health bar
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 0, 5)
    healthBar.Position = UDim2.new(0, 0, 0, 20)
    healthBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = billboardGui
    
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBar
    
    -- Update health bar
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local function updateHealth()
            healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            
            -- Change color based on health
            local healthRatio = humanoid.Health / humanoid.MaxHealth
            if healthRatio > 0.5 then
                healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif healthRatio > 0.2 then
                healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            else
                healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
        
        updateHealth()
        AddConnection(humanoid.HealthChanged:Connect(updateHealth))
    end
    
    -- Store ESP objects
    ESPObjects[player.Name] = espFolder
    
    -- Clean up when character is removed
    AddConnection(character.AncestryChanged:Connect(function(_, parent)
        if not parent and ESPObjects[player.Name] then
            ESPObjects[player.Name]:Destroy()
            ESPObjects[player.Name] = nil
        end
    end))
    
    -- Clean up when player leaves
    AddConnection(player.AncestryChanged:Connect(function(_, parent)
        if not parent and ESPObjects[player.Name] then
            ESPObjects[player.Name]:Destroy()
            ESPObjects[player.Name] = nil
        end
    end))
end

local function ToggleESP(enabled)
    Settings.ESP.Enabled = enabled
    
    if enabled then
        -- Create ESP for existing players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESPBox(player)
            end
        end
        
        -- Connect player added event
        AddConnection(Players.PlayerAdded:Connect(function(player)
            if Settings.ESP.Enabled then
                player.CharacterAdded:Connect(function(character)
                    if Settings.ESP.Enabled then
                        CreateESPBox(player)
                    end
                end)
                
                if player.Character then
                    CreateESPBox(player)
                end
            end
        end))
        
        NotificationSystem.Show("ESP", "ESP включен", Color3.fromRGB(0, 255, 0))
    else
        -- Remove all ESP objects
        for _, espObject in pairs(ESPObjects) do
            espObject:Destroy()
        end
        
        ESPObjects = {}
        NotificationSystem.Show("ESP", "ESP отключен", Color3.fromRGB(255, 0, 0))
    end
end

local function ToggleInfJump(enabled)
    Settings.InfJump.Enabled = enabled
    
    if enabled then
        AddConnection(UserInputService.JumpRequest:Connect(function()
            if Settings.InfJump.Enabled then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        
        NotificationSystem.Show("Infinite Jump", "Бесконечные прыжки включены", Color3.fromRGB(0, 255, 0))
    else
        NotificationSystem.Show("Infinite Jump", "Бесконечные прыжки отключены", Color3.fromRGB(255, 0, 0))
    end
end

local function ToggleTeleport(enabled)
    Settings.Teleport.Enabled = enabled
    
    if enabled then
        AddConnection(Mouse.Button1Down:Connect(function()
            if Settings.Teleport.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                    NotificationSystem.Show("Teleport", "Телепортация выполнена", Color3.fromRGB(0, 200, 255))
                end
            end
        end))
        
        NotificationSystem.Show("Teleport", "Телепортация включена (CTRL + Click)", Color3.fromRGB(0, 255, 0))
    else
        NotificationSystem.Show("Teleport", "Телепортация отключена", Color3.fromRGB(255, 0, 0))
    end
end

local function ToggleXray(enabled)
    Settings.Xray.Enabled = enabled
    
    if enabled then
        -- Make all parts semi-transparent
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) and not part.Name == "Terrain" then
                if not part:GetAttribute("OriginalTransparency") then
                    part:SetAttribute("OriginalTransparency", part.Transparency)
                end
                part.Transparency = math.max(part.Transparency, XrayTransparency)
            end
        end
        
        NotificationSystem.Show("X-Ray", "X-Ray включен", Color3.fromRGB(0, 255, 0))
    else
        -- Restore original transparency
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part:GetAttribute("OriginalTransparency") then
                part.Transparency = part:GetAttribute("OriginalTransparency")
            end
        end
        
        NotificationSystem.Show("X-Ray", "X-Ray отключен", Color3.fromRGB(255, 0, 0))
    end
end

local function ToggleFullBright(enabled)
    Settings.FullBright.Enabled = enabled
    
    if enabled then
        -- Store original lighting settings
        OriginalValues.Brightness = Lighting.Brightness
        OriginalValues.Ambient = Lighting.Ambient
        OriginalValues.OutdoorAmbient = Lighting.OutdoorAmbient
        
        -- Apply full brightness
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        NotificationSystem.Show("FullBright", "FullBright включен", Color3.fromRGB(0, 255, 0))
    else
        -- Restore original lighting
        Lighting.Brightness = OriginalValues.Brightness
        Lighting.Ambient = OriginalValues.Ambient
        Lighting.OutdoorAmbient = OriginalValues.OutdoorAmbient
        
        NotificationSystem.Show("FullBright", "FullBright отключен", Color3.fromRGB(255, 0, 0))
    end
end

local function ToggleNoFall(enabled)
    Settings.NoFall.Enabled = enabled
    
    if enabled then
        -- Connect to the character to prevent fall damage
        AddConnection(LocalPlayer.Character.ChildAdded:Connect(function(child)
            if Settings.NoFall.Enabled and child.Name == "FallDamageScript" then
                child:Destroy()
            end
        end))
        
        NotificationSystem.Show("No Fall Damage", "Защита от падения включена", Color3.fromRGB(0, 255, 0))
    else
        NotificationSystem.Show("No Fall Damage", "Защита от падения отключена", Color3.fromRGB(255, 0, 0))
    end
end

-- UI Components
local function CreateCheckbox(parent, position, text, initialState, callback)
    local container = CreateInstance("Frame", {
        Name = text .. "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Position = position,
        Parent = parent
    })
    
    local label = CreateInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local checkbox = CreateRoundedFrame({
        Name = "Checkbox",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = initialState and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(40, 40, 40),
        Parent = container
    })
    
    ApplyShadow(checkbox, 2)
    
    local checkmark = CreateInstance("ImageLabel", {
        Name = "Checkmark",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.15, 0, 0.15, 0),
        Image = "rbxassetid://7072706620",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = initialState and 0 or 1,
        Parent = checkbox
    })
    
    local button = CreateInstance("TextButton", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = container
    })
    
    local isChecked = initialState
    
    button.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        
        local targetColor = isChecked and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(40, 40, 40)
        local targetTransparency = isChecked and 0 or 1
        
        TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(checkmark, TweenInfo.new(0.2), {ImageTransparency = targetTransparency}):Play()
        
        callback(isChecked)
    end)
    
    local keybindButton = CreateInstance("TextButton", {
        Name = "KeybindButton",
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = container
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = keybindButton
    })
    
    ApplyShadow(keybindButton, 2)
    
    local keybindText = CreateInstance("TextLabel", {
        Name = "KeybindText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = Settings[text] and Settings[text].Keybind or KEYBIND_NONE,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        Parent = keybindButton
    })
    
    local isSettingKeybind = false
    
    keybindButton.MouseButton1Click:Connect(function()
        isSettingKeybind = true
        keybindText.Text = "..."
    end)
    
    AddConnection(UserInputService.InputBegan:Connect(function(input)
        if isSettingKeybind then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                keybindText.Text = keyName
                isSettingKeybind = false
                
                -- Update keybind in settings
                if text == "Fly" then
                    Settings.Fly.Keybind = keyName
                elseif text == "Speed" then
                    Settings.Speed.Keybind = keyName
                elseif text == "Noclip" then
                    Settings.Noclip.Keybind = keyName
                elseif text == "ESP" then
                    Settings.ESP.Keybind = keyName
                elseif text == "Infinite Jump" then
                    Settings.InfJump.Keybind = keyName
                elseif text == "Teleport" then
                    Settings.Teleport.Keybind = keyName
                elseif text == "X-Ray" then
                    Settings.Xray.Keybind = keyName
                elseif text == "FullBright" then
                    Settings.FullBright.Keybind = keyName
                elseif text == "No Fall Damage" then
                    Settings.NoFall.Keybind = keyName
                end
                
                NotificationSystem.Show("Keybind", text .. " keybind set to " .. keyName, Color3.fromRGB(0, 200, 255))
            end
        end
    end))
    
    return {
        Container = container,
        Checkbox = checkbox,
        Checkmark = checkmark,
        Button = button,
        KeybindButton = keybindButton,
        KeybindText = keybindText,
        SetState = function(state)
            isChecked = state
            local targetColor = isChecked and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(40, 40, 40)
            local targetTransparency = isChecked and 0 or 1
            
            checkbox.BackgroundColor3 = targetColor
            checkmark.ImageTransparency = targetTransparency
        end
    }
end

local function CreateSlider(parent, position, text, min, max, initialValue, callback)
    local container = CreateInstance("Frame", {
        Name = text .. "Container",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50),
        Position = position,
        Parent = parent
    })
    
    local label = CreateInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local valueLabel = CreateInstance("TextLabel", {
        Name = "ValueLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -50, 0, 0),
        Text = tostring(initialValue),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local sliderBg = CreateRoundedFrame({
        Name = "SliderBackground",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Parent = container
    })
    
    ApplyShadow(sliderBg, 2)
    
    local sliderFill = CreateRoundedFrame({
        Name = "SliderFill",
        Size = UDim2.new((initialValue - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(60, 120, 255),
        Parent = sliderBg
    })
    
    ApplyGradient(sliderFill, Color3.fromRGB(80, 140, 255), Color3.fromRGB(40, 100, 235))
    
    local sliderButton = CreateInstance("TextButton", {
        Name = "SliderButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = sliderBg
    })
    
    local isDragging = false
    local value = initialValue
    
    local function updateSlider(input)
        local pos = input.Position.X
        local relativePos = math.clamp((pos - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (relativePos * (max - min)))
        
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        callback(value)
    end
    
    sliderButton.MouseButton1Down:Connect(function(x, y)
        isDragging = true
        updateSlider({Position = Vector2.new(x, y)})
    end)
    
    AddConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end))
    
    AddConnection(UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            updateSlider(input)
        end
    end))
    
    return {
        Container = container,
        SliderBg = sliderBg,
        SliderFill = sliderFill,
        Value = value,
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            local relativePos = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    }
end

local function CreateButton(parent, position, text, callback)
    local button = CreateRoundedFrame({
        Name = text .. "Button",
        Size = UDim2.new(1, -20, 0, 30),
        Position = position,
        BackgroundColor3 = Color3.fromRGB(60, 120, 255),
        Parent = parent
    })
    
    ApplyShadow(button, 3)
    ApplyGradient(button, Color3.fromRGB(80, 140, 255), Color3.fromRGB(40, 100, 235))
    
    local label = CreateInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        Parent = button
    })
    
    local clickButton = CreateInstance("TextButton", {
        Name = "ClickButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = button
    })
    
    clickButton.MouseButton1Click:Connect(callback)
    
    clickButton.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 255)}):Play()
    end)
    
    clickButton.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}):Play()
    end)
    
    clickButton.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 110, 245)}):Play()
    end)
    
    clickButton.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 130, 255)}):Play()
    end)
    
    return button
end

local function CreateTabButton(parent, position, text, isActive, callback)
    local button = CreateInstance("TextButton", {
        Name = text .. "Tab",
        Size = UDim2.new(0, 80, 1, -10),
        Position = position,
        BackgroundColor3 = isActive and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30),
        Text = text,
        TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        Parent = parent
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button
    })
    
    if isActive then
        ApplyShadow(button, 2)
        CreateStroke(button, Color3.fromRGB(60, 120, 255), 1)
    end
    
    button.MouseButton1Click:Connect(function()
        callback(text)
    end)
    
    return button
end

-- Create GUI
local CrystalCheat = CreateInstance("ScreenGui", {
    Name = "CrystalCheat",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = CoreGui
})

-- Initialize notification system
NotificationSystem.Init(CrystalCheat)

-- Main Frame
local MainFrame = CreateRoundedFrame({
    Name = "MainFrame",
    Size = UDim2.new(0, 400, 0, 350),
    Position = UDim2.new(0.5, -200, 0.5, -175),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    Parent = CrystalCheat
})

ApplyShadow(MainFrame, 8)

-- Title Bar
local TitleBar = CreateRoundedFrame({
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    Parent = MainFrame
})

ApplyGradient(TitleBar, Color3.fromRGB(30, 30, 30), Color3.fromRGB(20, 20, 20))

-- Title
local Title = CreateInstance("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    Text = "CRYSTALCHEAT v" .. CRYSTAL_VERSION,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

-- Crystal Logo
local Logo = CreateInstance("ImageLabel", {
    Name = "Logo",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(0, 10, 0.5, -12),
    Image = "rbxassetid://7734010488",
    ImageColor3 = Color3.fromRGB(60, 120, 255),
    Parent = TitleBar
})

Title.Position = UDim2.new(0, 40, 0, 0)

-- Close Button
local CloseButton = CreateInstance("TextButton", {
    Name = "CloseButton",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0, 5),
    BackgroundColor3 = Color3.fromRGB(255, 70, 70),
    Text = "X",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})

CreateInstance("UICorner", {
    CornerRadius = UDim.new(0, 6),
    Parent = CloseButton
})

-- Minimize Button
local MinimizeButton = CreateInstance("TextButton", {
    Name = "MinimizeButton",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0, 5),
    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    Parent = TitleBar
})

CreateInstance("UICorner", {
    CornerRadius = UDim.new(0, 6),
    Parent = MinimizeButton
})

-- Tab Bar
local TabBar = CreateInstance("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = MainFrame
})

CreateInstance("UICorner", {
    CornerRadius = UDim.new(0, 6),
    Parent = TabBar
})

-- Content Frame
local ContentFrame = CreateRoundedFrame({
    Name = "ContentFrame",
    Size = UDim2.new(1, -20, 1, -90),
    Position = UDim2.new(0, 10, 0, 80),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Parent = MainFrame
})

ApplyShadow(ContentFrame, 4)

-- Tab Content Frames
local MovementContent = CreateInstance("ScrollingFrame", {
    Name = "MovementContent",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255),
    CanvasSize = UDim2.new(0, 0, 0, 300),
    Visible = true,
    Parent = ContentFrame
})

local VisualsContent = CreateInstance("ScrollingFrame", {
    Name = "VisualsContent",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255),
    CanvasSize = UDim2.new(0, 0, 0, 300),
    Visible = false,
    Parent = ContentFrame
})

local MiscContent = CreateInstance("ScrollingFrame", {
    Name = "MiscContent",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255),
    CanvasSize = UDim2.new(0, 0, 0, 300),
    Visible = false,
    Parent = ContentFrame
})

local SettingsContent = CreateInstance("ScrollingFrame", {
    Name = "SettingsContent",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255),
    CanvasSize = UDim2.new(0, 0, 0, 300),
    Visible = false,
    Parent = ContentFrame
})

-- Function to update tabs
local function UpdateTabs()
    -- Update content visibility
    MovementContent.Visible = (ActiveTab == "Movement")
    VisualsContent.Visible = (ActiveTab == "Visuals")
    MiscContent.Visible = (ActiveTab == "Misc")
    SettingsContent.Visible = (ActiveTab == "Settings")
    
    -- Update tab buttons
    for _, tab in pairs(TabBar:GetChildren()) do
        if tab:IsA("TextButton") then
            local isActive = (tab.Text == ActiveTab)
            
            -- Update appearance
            tab.BackgroundColor3 = isActive and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(30, 30, 30)
            tab.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            
            -- Remove existing strokes
            for _, child in pairs(tab:GetChildren()) do
                if child:IsA("UIStroke") then
                    child:Destroy()
                end
            end
            
            -- Add stroke if active
            if isActive then
                CreateStroke(tab, Color3.fromRGB(60, 120, 255), 1)
                ApplyShadow(tab, 2)
            end
        end
    end
    
    NotificationSystem.Show("Tab", "Switched to " .. ActiveTab .. " tab", Color3.fromRGB(0, 200, 255))
end

-- Tab Buttons
local MovementTab = CreateTabButton(TabBar, UDim2.new(0, 10, 0, 5), "Movement", true, function(tab)
    ActiveTab = tab
    UpdateTabs()
end)

local VisualsTab = CreateTabButton(TabBar, UDim2.new(0, 100, 0, 5), "Visuals", false, function(tab)
    ActiveTab = tab
    UpdateTabs()
end)

local MiscTab = CreateTabButton(TabBar, UDim2.new(0, 190, 0, 5), "Misc", false, function(tab)
    ActiveTab = tab
    UpdateTabs()
end)

local SettingsTab = CreateTabButton(TabBar, UDim2.new(0, 280, 0, 5), "Settings", false, function(tab)
    ActiveTab = tab
    UpdateTabs()
end)

-- Movement Tab Content
local FlyCheckbox = CreateCheckbox(MovementContent, UDim2.new(0, 10, 0, 10), "Fly", Settings.Fly.Enabled, function(state)
    ToggleFly(state)
end)

local FlySpeedSlider = CreateSlider(MovementContent, UDim2.new(0, 10, 0, 50), "Fly Speed", 10, 200, Settings.Fly.Speed, function(value)
    UpdateFlySpeed(value)
end)

local SpeedCheckbox = CreateCheckbox(MovementContent, UDim2.new(0, 10, 0, 110), "Speed", Settings.Speed.Enabled, function(state)
    ToggleSpeed(state)
end)

local SpeedSlider = CreateSlider(MovementContent, UDim2.new(0, 10, 0, 150), "Walk Speed", 16, 200, Settings.Speed.Value, function(value)
    UpdateSpeed(value)
end)

local NoclipCheckbox = CreateCheckbox(MovementContent, UDim2.new(0, 10, 0, 210), "Noclip", Settings.Noclip.Enabled, function(state)
    ToggleNoclip(state)
end)

local InfJumpCheckbox = CreateCheckbox(MovementContent, UDim2.new(0, 10, 0, 250), "Infinite Jump", Settings.InfJump.Enabled, function(state)
    ToggleInfJump(state)
end)

-- Visuals Tab Content
local ESPCheckbox = CreateCheckbox(VisualsContent, UDim2.new(0, 10, 0, 10), "ESP", Settings.ESP.Enabled, function(state)
    ToggleESP(state)
end)

local XrayCheckbox = CreateCheckbox(VisualsContent, UDim2.new(0, 10, 0, 50), "X-Ray", Settings.Xray.Enabled, function(state)
    ToggleXray(state)
end)

local FullBrightCheckbox = CreateCheckbox(VisualsContent, UDim2.new(0, 10, 0, 90), "FullBright", Settings.FullBright.Enabled, function(state)
    ToggleFullBright(state)
end)

-- Misc Tab Content
local TeleportCheckbox = CreateCheckbox(MiscContent, UDim2.new(0, 10, 0, 10), "Teleport", Settings.Teleport.Enabled, function(state)
    ToggleTeleport(state)
end)

local TeleportInfo = CreateInstance("TextLabel", {
    Name = "TeleportInfo",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 40),
    Text = "Hold CTRL + Click to teleport",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = MiscContent
})

local NoFallCheckbox = CreateCheckbox(MiscContent, UDim2.new(0, 10, 0, 90), "No Fall Damage", Settings.NoFall.Enabled, function(state)
    ToggleNoFall(state)
end)

-- Settings Tab Content
local ResetButton = CreateButton(SettingsContent, UDim2.new(0, 10, 0, 10), "Reset All Settings", function()
    -- Reset all settings
    ToggleFly(false)
    ToggleSpeed(false)
    ToggleNoclip(false)
    ToggleESP(false)
    ToggleInfJump(false)
    ToggleTeleport(false)
    ToggleXray(false)
    ToggleFullBright(false)
    ToggleNoFall(false)
    
    -- Reset UI
    FlyCheckbox.SetState(false)
    SpeedCheckbox.SetState(false)
    NoclipCheckbox.SetState(false)
    ESPCheckbox.SetState(false)
    InfJumpCheckbox.SetState(false)
    TeleportCheckbox.SetState(false)
    XrayCheckbox.SetState(false)
    FullBrightCheckbox.SetState(false)
    NoFallCheckbox.SetState(false)
    
    -- Reset speeds
    FlySpeedSlider.SetValue(DEFAULT_FLY_SPEED)
    SpeedSlider.SetValue(DEFAULT_SPEED)
    
    NotificationSystem.Show("Settings", "All settings reset to default", Color3.fromRGB(255, 150, 0))
end)

local VersionInfo = CreateInstance("TextLabel", {
    Name = "VersionInfo",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 50),
    Text = "CRYSTALCHEAT v" .. CRYSTAL_VERSION,
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SettingsContent
})

local Credits = CreateInstance("TextLabel", {
    Name = "Credits",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 70),
    Text = "Created with ♥",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SettingsContent
})

-- Make the frame draggable
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsDragging = true
        DragOffset = MainFrame.AbsolutePosition - Vector2.new(input.Position.X, input.Position.Y)
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsDragging = false
    end
end)

AddConnection(UserInputService.InputChanged:Connect(function(input)
    if IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        MainFrame.Position = UDim2.new(0, DragOffset.X + input.Position.X, 0, DragOffset.Y + input.Position.Y)
    end
end))

-- Function to restore all settings
local function RestoreAllSettings()
    -- Disable all features
    if Settings.Fly.Enabled then ToggleFly(false) end
    if Settings.Speed.Enabled then ToggleSpeed(false) end
    if Settings.Noclip.Enabled then ToggleNoclip(false) end
    if Settings.ESP.Enabled then ToggleESP(false) end
    if Settings.Xray.Enabled then ToggleXray(false) end
    if Settings.FullBright.Enabled then ToggleFullBright(false) end
    
    -- Clean up all connections
    CleanupConnections()
    
    -- Reset character properties
    pcall(function()
        LocalPlayer.Character.Humanoid.WalkSpeed = OriginalValues.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = OriginalValues.JumpPower
    end)
    
    -- Reset lighting
    Lighting.Brightness = OriginalValues.Brightness
    Lighting.Ambient = OriginalValues.Ambient
    Lighting.OutdoorAmbient = OriginalValues.OutdoorAmbient
    
    -- Show notification
    NotificationSystem.Show("CRYSTALCHEAT", "All settings restored", Color3.fromRGB(255, 150, 0))
end

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    -- Restore all settings
    RestoreAllSettings()
    
    -- Destroy GUI
    CrystalCheat:Destroy()
end)

-- Minimize button functionality
MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    
    if IsMinimized then
        MainFrame.Size = UDim2.new(0, 400, 0, 40)
        ContentFrame.Visible = false
        TabBar.Visible = false
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 400, 0, 350)
        ContentFrame.Visible = true
        TabBar.Visible = true
        MinimizeButton.Text = "-"
    end
end)

-- Keybind handling
AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyPressed = input.KeyCode.Name
        
        -- Check keybinds
        if keyPressed == Settings.Fly.Keybind then
            local newState = not Settings.Fly.Enabled
            ToggleFly(newState)
            FlyCheckbox.SetState(newState)
        elseif keyPressed == Settings.Speed.Keybind then
            local newState = not Settings.Speed.Enabled
            ToggleSpeed(newState)
            SpeedCheckbox.SetState(newState)
        elseif keyPressed == Settings.Noclip.Keybind then
            local newState = not Settings.Noclip.Enabled
            ToggleNoclip(newState)
            NoclipCheckbox.SetState(newState)
        elseif keyPressed == Settings.ESP.Keybind then
            local newState = not Settings.ESP.Enabled
            ToggleESP(newState)
            ESPCheckbox.SetState(newState)
        elseif keyPressed == Settings.Xray.Keybind then
            local newState = not Settings.Xray.Enabled
            ToggleXray(newState)
            XrayCheckbox.SetState(newState)
        elseif keyPressed == Settings.FullBright.Keybind then
            local newState = not Settings.FullBright.Enabled
            ToggleFullBright(newState)
            FullBrightCheckbox.SetState(newState)
        elseif keyPressed == Settings.NoFall.Keybind then
            local newState = not Settings.NoFall.Enabled
            ToggleNoFall(newState)
            NoFallCheckbox.SetState(newState)
        end
    end
end))

-- Toggle GUI with Insert key
AddConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        NotificationSystem.Show("CRYSTALCHEAT", MainFrame.Visible and "GUI показан" or "GUI скрыт", Color3.fromRGB(0, 200, 255))
    end
end))

-- Character respawn handling
AddConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Store original values
    OriginalValues.WalkSpeed = Humanoid.WalkSpeed
    OriginalValues.JumpPower = Humanoid.JumpPower
    
    -- Reapply settings
    if Settings.Speed.Enabled then
        Humanoid.WalkSpeed = Settings.Speed.Value
    end
    
    if Settings.Fly.Enabled then
        ToggleFly(false)
        wait(1)
        ToggleFly(true)
    end
    
    if Settings.Noclip.Enabled then
        ToggleNoclip(false)
        wait(1)
        ToggleNoclip(true)
    end
    
    NotificationSystem.Show("Character", "Персонаж возродился, настройки применены", Color3.fromRGB(0, 200, 255))
end))

-- Store original values
OriginalValues.WalkSpeed = Humanoid.WalkSpeed
OriginalValues.JumpPower = Humanoid.JumpPower

-- Welcome notification
NotificationSystem.Show("CRYSTALCHEAT", "Добро пожаловать в CRYSTALCHEAT v" .. CRYSTAL_VERSION, Color3.fromRGB(60, 120, 255), 5)
NotificationSystem.Show("Управление", "Нажмите INSERT для переключения GUI", Color3.fromRGB(0, 200, 255), 5)
NotificationSystem.Show("Fly", "Добавлен плавный полёт!", Color3.fromRGB(0, 255, 100), 5)

-- Initialize
UpdateTabs()
