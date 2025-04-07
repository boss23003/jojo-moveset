-- JoJo-стиль кастомизация для персонажа Сайтама в TSB
-- Авторский скрипт под loadstring

-- Удаление стандартных анимаций и музыки
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("Animation") or v:IsA("Sound") and v.Parent.Name == "Music" then
        v:Destroy()
    end
end

-- Создание стенда
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local stand = character:Clone()
stand.Name = "Stand"

-- Удаляем лишнее (инструменты и скрипты)
for _,v in pairs(stand:GetDescendants()) do
    if v:IsA("Tool") or v:IsA("Script") or v:IsA("LocalScript") then
        v:Destroy()
    end
end

-- Прозрачность и визуальный стиль
for _,v in pairs(stand:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Transparency = 0.5
        v.CanCollide = false
        v.Material = Enum.Material.ForceField
        v.Color = Color3.fromRGB(150, 0, 255)
    end
end

stand.Parent = workspace

-- Привязка к игроку
local runService = game:GetService("RunService")
runService.RenderStepped:Connect(function()
    if character and character:FindFirstChild("HumanoidRootPart") then
        stand:PivotTo(
            character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3 + math.sin(tick()*2)*0.5)
        )
    end
end)

-- Боевая поза: стойка с руками
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://507766388" -- Пример позы
local animTrack = stand:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(anim)
animTrack:Play()
animTrack.Looped = true

-- Анимации скиллов
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    local anims = {
        [1] = "rbxassetid://14884037181", -- обычная атака
        [2] = "rbxassetid://14884041959", -- ORA ORA спам
        [3] = "rbxassetid://507766666",   -- удар ногой
        [4] = "rbxassetid://11450616329", -- оперкот
    }

    for key, id in pairs(anims) do
        local a = Instance.new("Animation")
        a.AnimationId = id
        humanoid:LoadAnimation(a)
    end
end

-- Звук ORA ORA ORA
local function playORA()
    local sound = Instance.new("Sound", character)
    sound.SoundId = "rbxassetid://1093100474" -- ORA звук
    sound.Volume = 2
    sound:Play()
    game.Debris:AddItem(sound, 3)
end

-- Вешаем на 2 скилл активацию звука и повторение ударов
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Two then
        playORA()
        for _ = 1, 5 do
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://14884041959"
            local track = humanoid:LoadAnimation(anim)
            track:Play()
            wait(0.15)
        end
    end
end)

print("[JoJo Moveset] Скрипт активирован!")
