-- YBA Улучшенный Авто Фарм с Обходом Античита
-- Версия: 2.0

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Настройки
local settings = {
    enabled = true,
    itemCheckDelay = 1,     -- Задержка между проверками новых предметов (в секундах)
    teleportDelay = 0.5,    -- Задержка между перемещениями (в секундах)
    collectRadius = 15,     -- Радиус для сбора предметов
    autoRejoin = true,      -- Автоматическое переподключение при ошибке или кике
    ignoreList = {},        -- Предметы, которые нужно игнорировать
    antiCheatBypass = true, -- Включить обход античита
    walkSpeed = 16,         -- Скорость ходьбы (по умолчанию)
    tweenSpeed = 20,        -- Скорость для Tween-перемещений
    debugMode = false,      -- Режим отладки
    useTP = false,          -- Использовать мгновенный телепорт (true) или плавное перемещение (false)
    farmMethod = "tween",   -- Метод фарма: "tween", "walk", "camera", "jump"
    simulatePlayer = true   -- Симулировать действия игрока (прыжки, повороты и т.д.)
}

-- Список целевых предметов и их приоритет (чем ниже число, тем выше приоритет)
local targetItems = {
    ["Rib Cage of The Saint's Corpse"] = 1,
    ["Lucky Arrow"] = 2,
    ["Pure Rokakaka"] = 3,
    ["Dio's Diary"] = 4,
    ["Mysterious Arrow"] = 5,
    ["Lucky Stone Mask"] = 6,
    ["Stone Mask"] = 7,
    ["Gold Coin"] = 8,
    ["Rokakaka"] = 9,
    ["Steel Ball"] = 10,
    ["Diamond"] = 11,
    ["Ancient Scroll"] = 12,
    ["Quinton's Glove"] = 13,
    ["Zeppeli's Hat"] = 14
}

-- Известные места спавна предметов (координаты из вашего анализа)
local knownSpawnLocations = {
    {name = "Gold Coin", position = Vector3.new(-45.982, 823.279, 324.551)},
    {name = "Pure Rokakaka", position = Vector3.new(-59.561, 823.272, 311.991)},
    {name = "Quinton's Glove", position = Vector3.new(-43.923, 823.998, 317.742)},
    {name = "Stone Mask", position = Vector3.new(-38.173, 1.45, 1)},
    {name = "Mysterious Arrow", position = Vector3.new(-57.39, 823.112, 312.835)},
    {name = "Rib Cage of The Saint's Corpse", position = Vector3.new(517.558, 804.033, 527.473)},
    {name = "Steel Ball", position = Vector3.new(196.6, 59.352, 286.288)},
    {name = "Dio's Diary", position = Vector3.new(382.348, 850.533, 216.661)},
    {name = "Ancient Scroll", position = Vector3.new(149.369, 825.432, 280.323)},
    {name = "Lucky Arrow", position = Vector3.new(-56.652, 823.505, 308.336)},
    {name = "Diamond", position = Vector3.new(133.173, 846.706, 451.465)},
    {name = "Redeemed Rokakaka", position = Vector3.new(104.071, -4.73, 313.781)},
    {name = "Rokakaka", position = Vector3.new(-63.981, 823.272, 314.284)},
    {name = "Lucky Stone Mask", position = Vector3.new(314.5, -3.55, 76)},
    {name = "Zeppeli's Hat", position = Vector3.new(-31.838, 0.737, -0.586)}
}

-- Данные для отслеживания
local farmStats = {
    itemsCollected = 0,
    attempts = 0, 
    lastItem = "Нет",
    farmStartTime = os.time(),
    itemList = {}
}

-- Переменные для обхода античита
local antiCheatData = {
    lastPosition = Vector3.new(0,0,0),
    detectAttempts = 0,
    knownScripts = {},
    bypassing = false,
    originalWalkSpeed = 16,
    originalJumpPower = 50
}

-- Функция для анализа игры и поиска скриптов античита
local function scanForAntiCheat()
    local antiCheatPaths = {}
    local antiCheatKeywords = {
        "anti", "cheat", "detect", "teleport", "check", "validate", "position", "exploit", "ban", "kick",
        "report", "speed", "hack", "illegal", "movement", "verify", "security"
    }
    
    local function scanObject(obj, path)
        if not obj then return end
        
        -- Проверяем имя объекта на ключевые слова
        for _, keyword in ipairs(antiCheatKeywords) do
            if string.find(string.lower(obj.Name), string.lower(keyword)) then
                table.insert(antiCheatPaths, path .. "/" .. obj.Name .. " [" .. obj.ClassName .. "]")
            end
        end
        
        -- Если это скрипт, проверяем содержимое (если можем)
        if obj:IsA("ModuleScript") or obj:IsA("Script") or obj:IsA("LocalScript") then
            table.insert(antiCheatPaths, path .. "/" .. obj.Name .. " [" .. obj.ClassName .. "]")
        end
        
        -- Рекурсивно проверяем дочерние объекты
        for _, child in ipairs(obj:GetChildren()) do
            scanObject(child, path .. "/" .. obj.Name)
        end
    end
    
    -- Сканируем важные локации
    local locationsToScan = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("ServerScriptService"),
        game:GetService("StarterPlayer")
    }
    
    for _, location in ipairs(locationsToScan) do
        scanObject(location, location.Name)
    end
    
    return antiCheatPaths
end

-- Создаем улучшенный UI для контроля скрипта
local function createImprovedUI()
    -- Удаляем старые интерфейсы
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "YBAFarmUI" or gui.Name == "YBAImprovedFarmUI" then
            gui:Destroy()
        end
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YBAImprovedFarmUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Защита от обнаружения
    if syn then
        syn.protect_gui(ScreenGui)
    end
    
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Основная рамка
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 390)
    MainFrame.Position = UDim2.new(0.8, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Верхняя панель
    local TopPanel = Instance.new("Frame")
    TopPanel.Name = "TopPanel"
    TopPanel.Size = UDim2.new(1, 0, 0, 35)
    TopPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    TopPanel.BorderSizePixel = 0
    TopPanel.Parent = MainFrame
    
    -- Эффект тени
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
    }
    UIGradient.Rotation = 90
    UIGradient.Parent = TopPanel
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "YBA Улучшенный Авто-Фарм"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopPanel
    
    -- Кнопка закрытия
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 2.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = TopPanel
    
    -- Делаем кнопку закрытия круглой
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = CloseButton
    
    -- Основное содержимое
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -45)
    Content.Position = UDim2.new(0, 10, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    -- Статус активности
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Size = UDim2.new(1, 0, 0, 40)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = Content
    
    local UICornerStatus = Instance.new("UICorner")
    UICornerStatus.CornerRadius = UDim.new(0, 8)
    UICornerStatus.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.65, 0, 1, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "СТАТУС: ВЫКЛЮЧЕН"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Position = UDim2.new(0, 15, 0, 0)
    StatusLabel.Parent = StatusFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 80, 0, 26)
    ToggleButton.Position = UDim2.new(1, -90, 0.5, -13)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "ВЫКЛ"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 12
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = StatusFrame
    
    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 6)
    UICornerToggle.Parent = ToggleButton
    
    -- Статистика фарма
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Name = "StatsFrame"
    StatsFrame.Size = UDim2.new(1, 0, 0, 110)
    StatsFrame.Position = UDim2.new(0, 0, 0, 50)
    StatsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    StatsFrame.BorderSizePixel = 0
    StatsFrame.Parent = Content
    
    local UICornerStats = Instance.new("UICorner")
    UICornerStats.CornerRadius = UDim.new(0, 8)
    UICornerStats.Parent = StatsFrame
    
    local StatsTitle = Instance.new("TextLabel")
    StatsTitle.Name = "StatsTitle"
    StatsTitle.Size = UDim2.new(1, 0, 0, 20)
    StatsTitle.Position = UDim2.new(0, 0, 0, 5)
    StatsTitle.BackgroundTransparency = 1
    StatsTitle.Text = "СТАТИСТИКА ФАРМА"
    StatsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatsTitle.Font = Enum.Font.GothamBold
    StatsTitle.TextSize = 12
    StatsTitle.Parent = StatsFrame
    
    local ItemsCollectedLabel = Instance.new("TextLabel")
    ItemsCollectedLabel.Name = "ItemsCollectedLabel"
    ItemsCollectedLabel.Size = UDim2.new(0.9, 0, 0, 18)
    ItemsCollectedLabel.Position = UDim2.new(0.05, 0, 0, 30)
    ItemsCollectedLabel.BackgroundTransparency = 1
    ItemsCollectedLabel.Text = "Собрано предметов: 0"
    ItemsCollectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ItemsCollectedLabel.Font = Enum.Font.Gotham
    ItemsCollectedLabel.TextSize = 12
    ItemsCollectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    ItemsCollectedLabel.Parent = StatsFrame
    
    local TimeRunningLabel = Instance.new("TextLabel")
    TimeRunningLabel.Name = "TimeRunningLabel"
    TimeRunningLabel.Size = UDim2.new(0.9, 0, 0, 18)
    TimeRunningLabel.Position = UDim2.new(0.05, 0, 0, 50)
    TimeRunningLabel.BackgroundTransparency = 1
    TimeRunningLabel.Text = "Время работы: 00:00:00"
    TimeRunningLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TimeRunningLabel.Font = Enum.Font.Gotham
    TimeRunningLabel.TextSize = 12
    TimeRunningLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeRunningLabel.Parent = StatsFrame
    
    local LastItemLabel = Instance.new("TextLabel")
    LastItemLabel.Name = "LastItemLabel"
    LastItemLabel.Size = UDim2.new(0.9, 0, 0, 18)
    LastItemLabel.Position = UDim2.new(0.05, 0, 0, 70)
    LastItemLabel.BackgroundTransparency = 1
    LastItemLabel.Text = "Последний предмет: Нет"
    LastItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    LastItemLabel.Font = Enum.Font.Gotham
    LastItemLabel.TextSize = 12
    LastItemLabel.TextXAlignment = Enum.TextXAlignment.Left
    LastItemLabel.Parent = StatsFrame
    
    local ItemPerHourLabel = Instance.new("TextLabel")
    ItemPerHourLabel.Name = "ItemPerHourLabel"
    ItemPerHourLabel.Size = UDim2.new(0.9, 0, 0, 18)
    ItemPerHourLabel.Position = UDim2.new(0.05, 0, 0, 90)
    ItemPerHourLabel.BackgroundTransparency = 1
    ItemPerHourLabel.Text = "Предметов в час: 0"
    ItemPerHourLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ItemPerHourLabel.Font = Enum.Font.Gotham
    ItemPerHourLabel.TextSize = 12
    ItemPerHourLabel.TextXAlignment = Enum.TextXAlignment.Left
    ItemPerHourLabel.Parent = StatsFrame
    
    -- Настройки
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Size = UDim2.new(1, 0, 0, 170)
    SettingsFrame.Position = UDim2.new(0, 0, 0, 170)
    SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.Parent = Content
    
    local UICornerSettings = Instance.new("UICorner")
    UICornerSettings.CornerRadius = UDim.new(0, 8)
    UICornerSettings.Parent = SettingsFrame
    
    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Name = "SettingsTitle"
    SettingsTitle.Size = UDim2.new(1, 0, 0, 20)
    SettingsTitle.Position = UDim2.new(0, 0, 0, 5)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Text = "НАСТРОЙКИ"
    SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.TextSize = 12
    SettingsTitle.Parent = SettingsFrame
    
    -- Кнопки методов фарма
    local methodLabels = {"Тип перемещения:"}
    local methodOptions = {
        {"Плавное", "tween"}, 
        {"Ходьба", "walk"}, 
        {"Прыжки", "jump"}
    }
    
    for i, labelText in ipairs(methodLabels) do
        local Label = Instance.new("TextLabel")
        Label.Name = "MethodLabel" .. i
        Label.Size = UDim2.new(0.9, 0, 0, 18)
        Label.Position = UDim2.new(0.05, 0, 0, 25 + (i-1) * 35)
        Label.BackgroundTransparency = 1
        Label.Text = labelText
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SettingsFrame
        
        local ButtonHolder = Instance.new("Frame")
        ButtonHolder.Name = "ButtonHolder" .. i
        ButtonHolder.Size = UDim2.new(0.9, 0, 0, 25)
        ButtonHolder.Position = UDim2.new(0.05, 0, 0, 45 + (i-1) * 35)
        ButtonHolder.BackgroundTransparency = 1
        ButtonHolder.Parent = SettingsFrame
        
        for j, option in ipairs(methodOptions) do
            local name, value = option[1], option[2]
            
            local Button = Instance.new("TextButton")
            Button.Name = "MethodButton_" .. value
            Button.Size = UDim2.new(1/3, -5, 1, 0)
            Button.Position = UDim2.new((j-1)/3, (j-1)*5, 0, 0)
            Button.BackgroundColor3 = settings.farmMethod == value and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(60, 60, 70)
            Button.BorderSizePixel = 0
            Button.Text = name
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 11
            Button.Parent = ButtonHolder
            
            local UICornerButton = Instance.new("UICorner")
            UICornerButton.CornerRadius = UDim.new(0, 5)
            UICornerButton.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                -- Сбрасываем цвет всех кнопок
                for _, child in pairs(ButtonHolder:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    end
                end
                
                -- Выделяем выбранную кнопку
                Button.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
                settings.farmMethod = value
            end)
        end
    end
    
    -- Слайдеры настройки
    local sliderSettings = {
        {name = "Скорость движения:", property = "tweenSpeed", min = 10, max = 50, default = 20},
        {name = "Задержка (сек):", property = "teleportDelay", min = 0.1, max = 2, default = 0.5}
    }
    
    for i, sliderInfo in ipairs(sliderSettings) do
        local yPos = 100 + (i-1) * 40
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = sliderInfo.property .. "Label"
        SliderLabel.Size = UDim2.new(0.5, 0, 0, 18)
        SliderLabel.Position = UDim2.new(0.05, 0, 0, yPos)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = sliderInfo.name .. " " .. settings[sliderInfo.property]
        SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextSize = 12
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SettingsFrame
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = sliderInfo.property .. "SliderFrame"
        SliderFrame.Size = UDim2.new(0.6, 0, 0, 6)
        SliderFrame.Position = UDim2.new(0.35, 0, 0, yPos + 10)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = SettingsFrame
        
        local UICornerSlider = Instance.new("UICorner")
        UICornerSlider.CornerRadius = UDim.new(0, 3)
        UICornerSlider.Parent = SliderFrame
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = sliderInfo.property .. "SliderButton"
        local initialPosition = (settings[sliderInfo.property] - sliderInfo.min) / (sliderInfo.max - sliderInfo.min)
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Position = UDim2.new(initialPosition, -8, 0.5, -8)
        SliderButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
        SliderButton.BorderSizePixel = 0
        SliderButton.Text = ""
        SliderButton.Parent = SliderFrame
        
        local UICornerSliderButton = Instance.new("UICorner")
        UICornerSliderButton.CornerRadius = UDim.new(0, 8)
        UICornerSliderButton.Parent = SliderButton
        
        SliderButton.MouseButton1Down:Connect(function()
            local function updateSlider(input)
                local percentage = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
                SliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
                
                local value = sliderInfo.min + (sliderInfo.max - sliderInfo.min) * percentage
                if sliderInfo.property == "teleportDelay" then
                    value = math.floor(value * 10) / 10 -- Округляем до 0.1
                else
                    value = math.floor(value) -- Округляем до целого
                end
                
                settings[sliderInfo.property] = value
                SliderLabel.Text = sliderInfo.name .. " " .. value
            end
            
            local inputConnection
            local inputEndedConnection
            
            inputConnection = game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(input)
                end
            end)
            
            inputEndedConnection = game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if inputConnection then
                        inputConnection:Disconnect()
                    end
                    if inputEndedConnection then
                        inputEndedConnection:Disconnect()
                    end
                end
            end)
        end)
    end
    
    -- Чекбоксы для настроек
    local checkboxSettings = {
        {name = "Обход античита", property = "antiCheatBypass"},
        {name = "Имитация игрока", property = "simulatePlayer"}
    }
    
    for i, checkboxInfo in ipairs(checkboxSettings) do
        local CheckboxFrame = Instance.new("Frame")
        CheckboxFrame.Name = checkboxInfo.property .. "Frame"
        CheckboxFrame.Size = UDim2.new(0.9, 0, 0, 18)
        CheckboxFrame.Position = UDim2.new(0.05, 0, 0, 180 + (i-1) * 25)
        CheckboxFrame.BackgroundTransparency = 1
        CheckboxFrame.Parent = SettingsFrame
        
        local CheckboxLabel = Instance.new("TextLabel")
        CheckboxLabel.Name = checkboxInfo.property .. "Label"
        CheckboxLabel.Size = UDim2.new(0.8, 0, 1, 0)
        CheckboxLabel.BackgroundTransparency = 1
        CheckboxLabel.Text = checkboxInfo.name
        CheckboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        CheckboxLabel.Font = Enum.Font.Gotham
        CheckboxLabel.TextSize = 12
        CheckboxLabel.TextXAlignment = Enum.TextXAlignment.Left
        CheckboxLabel.Parent = CheckboxFrame
        
        local Checkbox = Instance.new("Frame")
        Checkbox.Name = checkboxInfo.property .. "Checkbox"
        Checkbox.Size = UDim2.new(0, 16, 0, 16)
        Checkbox.Position = UDim2.new(1, -18, 0.5, -8)
        Checkbox.BackgroundColor3 = settings[checkboxInfo.property] and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(60, 60, 70)
        Checkbox.BorderSizePixel = 0
        Checkbox.Parent = CheckboxFrame
        
        local UICornerCheckbox = Instance.new("UICorner")
        UICornerCheckbox.CornerRadius = UDim.new(0, 3)
        UICornerCheckbox.Parent = Checkbox
        
        local CheckboxButton = Instance.new("TextButton")
        CheckboxButton.Name = checkbox
