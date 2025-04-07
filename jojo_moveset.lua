-- Загрузка необходимых файлов и библиотек
loadstring(game:HttpGet("https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/VOLTA.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hamletirl/sunjingwoo/refs/heads/main/sunjingwoo"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/VEXOR.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/FLOATING_GIRL.lua"))()

-- Настройка персонажа и скиллов
local player = game.Players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")

-- Создание стенда
local stand = Instance.new("Model")
stand.Name = "Stand"
stand.Parent = workspace

-- Модель стенда (будет копией персонажа, но с фиолетовым цветом и прозрачностью)
local standBody = character:Clone()
for _, part in pairs(standBody:GetChildren()) do
    if part:IsA("Part") then
        part.Color = Color3.fromRGB(128, 0, 128) -- Фиолетовый
        part.Transparency = 0.5 -- Полупрозрачный
    end
end

standBody.Parent = stand

-- Позиционирование стенда за спиной
stand:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2))

-- Анимации и поведение стенда (следует за персонажем)
local function updateStandPosition()
    stand:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2))
end

game:GetService("RunService").Heartbeat:Connect(updateStandPosition)

-- Замена скиллов на JoJo-стиль
local skills = {
    -- Пример второго скилла с быстрыми ударами (ORA ORA ORA)
    [2] = function()
        -- Воспроизведение скилла с анимацией и звуками
        humanoid:LoadAnimation(jojoSkillAnimation)  -- Используй свою анимацию здесь
        game:GetService("SoundService"):PlayLocalSound(game.SoundService:FindFirstChild("OraSound"))
        -- Порой удары
        for i = 1, 5 do
            -- Реализация самого удара (вызываем кастомную анимацию удара)
            humanoid:LoadAnimation(oraAttackAnimation) -- Анимация атаки
            wait(0.1) -- Маленькие задержки между ударами
        end
    end,

    -- Пример ульты (без изменений)
    [3] = function()
        -- Стандартная ульта, не изменяется
        -- Механика ульты как есть
    end,
}

-- Привязка скиллов к кнопкам
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        skills[1]()  -- Пример использования первого скилла
    elseif input.KeyCode == Enum.KeyCode.E then
        skills[2]()  -- Пример использования второго скилла
    elseif input.KeyCode == Enum.KeyCode.G then
        skills[3]()  -- Ульта
    end
end)

-- Анимации для атак
local jojoSkillAnimation = Instance.new("Animation")
jojoSkillAnimation.AnimationId = "rbxassetid://1234567890"  -- Пример ID анимации с JoJo стилем

local oraAttackAnimation = Instance.new("Animation")
oraAttackAnimation.AnimationId = "rbxassetid://0987654321"  -- ID для анимации "ORA ORA ORA"
