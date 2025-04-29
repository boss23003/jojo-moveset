local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "MapAnalyzer"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.Text = "Анализ данных..."
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 18

local CopyButton = Instance.new("TextButton", Frame)
CopyButton.Size = UDim2.new(1, -20, 0, 40)
CopyButton.Position = UDim2.new(0, 10, 0, 60)
CopyButton.Text = "Ждите..."
CopyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CopyButton.TextColor3 = Color3.new(1, 1, 1)
CopyButton.Font = Enum.Font.SourceSansBold
CopyButton.TextSize = 18
CopyButton.AutoButtonColor = false
CopyButton.Active = false
Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 6)

-- Данные
local resultData = {}

-- Поиск данных
task.spawn(function()
    local data = {
        Items = {},
        Remotes = {},
        AntiCheat = {}
    }

    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            -- Предметы
            if child:IsA("BasePart") then
                table.insert(data.Items, {
                    Name = child:GetFullName(),
                    Position = child.Position
                })
            end

            -- Remote'ы
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                table.insert(data.Remotes, child:GetFullName())
            end

            -- Поиск античита по имени
            local nameLower = string.lower(child.Name)
            if nameLower:find("anticheat") or nameLower:find("kick") or nameLower:find("ban") or nameLower:find("exploit") then
                table.insert(data.AntiCheat, child:GetFullName())
            end

            -- Поиск в скриптах
            if child:IsA("Script") or child:IsA("LocalScript") then
                local src
                pcall(function()
                    src = child.Source
                end)
                if src and (src:lower():find("kick") or src:lower():find("ban") or src:lower():find("anticheat")) then
                    table.insert(data.AntiCheat, child:GetFullName())
                end
            end

            scan(child)
        end
    end

    -- Сканируем основные сервисы
    for _, service in ipairs({
        game.Workspace,
        game.ReplicatedStorage,
        game.StarterGui,
        game.StarterPlayer,
        game.Lighting,
        game:GetService("Players"),
        game:GetService("ReplicatedFirst")
    }) do
        scan(service)
    end

    resultData = HttpService:JSONEncode(data)
    StatusLabel.Text = "Анализ завершён"
    CopyButton.Text = "Скопировать"
    CopyButton.Active = true
    CopyButton.AutoButtonColor = true
end)

-- Кнопка копирования
CopyButton.MouseButton1Click:Connect(function()
    if resultData ~= "" then
        local success = pcall(function()
            setclipboard(resultData)
        end)
        if success then
            CopyButton.Text = "Скопировано!"
        else
            CopyButton.Text = "Ошибка"
        end
        wait(2)
        CopyButton.Text = "Скопировать"
    end
end)
