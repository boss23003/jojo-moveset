-- JoJo-стиль кастомизация для персонажа Сайтама в The Strongest Battlegrounds
-- Авторский скрипт под loadstring

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Функция для поиска существующих анимаций в игре
local function findAnimation(name)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Animation") and v.Name == name then
            return v.AnimationId
        end
    end
    return nil
end

-- Анимации скиллов
local skills = {
    [1] = findAnimation("Punch") or "rbxassetid://507771019",   -- Удар рукой вперед
    [2] = findAnimation("RapidPunches") or "rbxassetid://10921154034", -- Быстрые удары (ORA ORA)
    [3] = findAnimation("Kick") or "rbxassetid://507767968",   -- Толчок ногой
    [4] = findAnimation("Uppercut") or "rbxassetid://10921099718", -- Удар ногой вверх
}

-- Создание стенда
local stand = character:Clone()
stand.Name = "Stand"

-- Удаление ненужных объектов из стенда
for _, v in pairs(stand:GetDescendants()) do
    if v:IsA("Tool") or v:IsA("Script") or v:IsA("LocalScript") then
        v:Destroy()
    end
end

-- Настройка внешнего вида стенда
for _, v in pairs(stand:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Transparency = 0.5
        v.CanCollide = false
        v.Material = Enum.Material.ForceField
        v.Color = Color3.fromRGB(150, 0, 255)
    end
end

local standHumanoid = stand:FindFirstChildWhichIsA("Humanoid")

-- Применение боевой позы из эмоций
local poseAnim = findAnimation("BattlePose") or "rbxassetid://507766388"
local pose = Instance.new("Animation")
pose.AnimationId = poseAnim
local poseTrack = standHumanoid:LoadAnimation(pose)
poseTrack.Looped = true
poseTrack:Play()

stand.Parent = workspace

-- Синхронизация позиции стенда с персонажем
RunService.RenderStepped:Connect(function()
    if character and character:FindFirstChild("HumanoidRootPart") then
        stand:PivotTo(character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3 + math.sin(tick() * 2) * 0.5))
    end
end)

-- Функция для воспроизведения анимации скилла
local function playSkill(skillIndex)
    local anim = Instance.new("Animation")
    anim.AnimationId = skills[skillIndex]
    local track = humanoid:LoadAnimation(anim)
    track:Play()

    -- Стенд повторяет анимацию
    local standAnim = Instance.new("Animation")
    standAnim.AnimationId = skills[skillIndex]
    local standTrack = standHumanoid:LoadAnimation(standAnim)
    standTrack:Play()
end

-- Функция для воспроизведения звука ORA
local function playORA()
    local sound = Instance.new("Sound", character)
    sound.SoundId = "rbxassetid://1093100474"
    sound.Volume = 2
    sound:Play()
    Debris:AddItem(sound, 3)
end

-- Обработка ввода пользователя для активации скиллов
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.One then
        playSkill(1)
    elseif input.KeyCode == Enum.KeyCode.Two then
        for _ = 1, 5 do
            playSkill(2)
            playORA()
            wait(0.15)
        end
    elseif input.KeyCode == Enum.KeyCode.Three then
        playSkill(3)
    elseif input.KeyCode == Enum.KeyCode.Four then
        playSkill(4)
    end
end)

print("[JoJo Moveset] Скрипт активирован!")
