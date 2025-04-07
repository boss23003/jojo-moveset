-- [✅ JoJo Moveset] Финальная рабочая версия

-- Удаление фоновой музыки
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("Sound") and v.Parent.Name == "Music" then
        v:Destroy()
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Создание стенда
local stand = character:Clone()
stand.Name = "Stand"
stand.Parent = workspace

-- Удаляем всё лишнее в стенде
for _,v in pairs(stand:GetDescendants()) do
    if v:IsA("Tool") or v:IsA("Script") or v:IsA("LocalScript") then
        v:Destroy()
    elseif v:IsA("BasePart") then
        v.Transparency = 0.5
        v.CanCollide = false
        v.Material = Enum.Material.ForceField
        v.Color = Color3.fromRGB(150, 0, 255)
    end
end

-- Постоянная анимация боевой позы (взята из эмоции)
local function loadEmoteAnimation(hum)
    for _,desc in pairs(game:GetDescendants()) do
        if desc:IsA("Animation") and desc.Name:lower():find("idle") then
            local anim = Instance.new("Animation")
            anim.AnimationId = desc.AnimationId
            local track = hum:LoadAnimation(anim)
            track:Play()
            track.Looped = true
            break
        end
    end
end

-- Стенд следует за игроком
RunService.RenderStepped:Connect(function()
    if character:FindFirstChild("HumanoidRootPart") then
        local offset = CFrame.new(2, 0, 3 + math.sin(tick()*2)*0.5)
        stand:PivotTo(character.HumanoidRootPart.CFrame * offset)
    end
end)

-- Анимации скиллов из других персонажей/эмоций
local skillAnims = {
    Punch = nil,
    OraBarrage = {},
    Kick = nil,
    Uppercut = nil
}

-- Автоматический выбор доступных анимаций из игры
for _,desc in pairs(game:GetDescendants()) do
    if desc:IsA("Animation") then
        local id = desc.AnimationId
        local name = desc.Name:lower()

        if name:find("kick") and not skillAnims.Kick then
            skillAnims.Kick = id
        elseif name:find("upper") and not skillAnims.Uppercut then
            skillAnims.Uppercut = id
        elseif name:find("punch") and not skillAnims.Punch then
            skillAnims.Punch = id
        elseif name:find("barrage") or name:find("spam") or name:find("rapid") then
            table.insert(skillAnims.OraBarrage, id)
        end
    end
end

-- Звук ORA ORA
local function playORA()
    local sound = Instance.new("Sound", character)
    sound.SoundId = "rbxassetid://1093100474" -- ORA ORA
    sound.Volume = 2
    sound:Play()
    game.Debris:AddItem(sound, 3)
end

-- Проиграть анимацию скила
local function playSkill(animId)
    if not animId then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    humanoid:LoadAnimation(anim):Play()
    local standHum = stand:FindFirstChildWhichIsA("Humanoid")
    if standHum then
        standHum:LoadAnimation(anim):Play()
    end
end

-- Навешиваем скиллы на кнопки
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.One then
        playSkill(skillAnims.Punch)
    elseif input.KeyCode == Enum.KeyCode.Two then
        playORA()
        for i = 1, 5 do
            local id = skillAnims.OraBarrage[math.random(1, #skillAnims.OraBarrage)]
            playSkill(id)
            wait(0.15)
        end
    elseif input.KeyCode == Enum.KeyCode.Three then
        playSkill(skillAnims.Kick)
    elseif input.KeyCode == Enum.KeyCode.Four then
        playSkill(skillAnims.Uppercut)
    end
end)

-- Стартовая поза для стенда
loadEmoteAnimation(stand:WaitForChild("Humanoid"))

print("[✅ JoJo Moveset] Загружен и активирован!")
