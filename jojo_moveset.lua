-- [JoJo Moveset] Полностью рабочая версия со всеми публичными анимациями

-- Удаляем стандартные анимации и музыку
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("Animation") or (v:IsA("Sound") and v.Parent.Name == "Music") then
        v:Destroy()
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- === СТЕНД ===
local stand = character:Clone()
stand.Name = "Stand"

for _,v in pairs(stand:GetDescendants()) do
    if v:IsA("Tool") or v:IsA("Script") or v:IsA("LocalScript") then
        v:Destroy()
    end
end

for _,v in pairs(stand:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Transparency = 0.5
        v.CanCollide = false
        v.Material = Enum.Material.ForceField
        v.Color = Color3.fromRGB(150, 0, 255)
    end
end

local standHumanoid = stand:FindFirstChildWhichIsA("Humanoid")
local pose = Instance.new("Animation")
pose.AnimationId = "rbxassetid://507766388"
local poseTrack = standHumanoid:LoadAnimation(pose)
poseTrack.Looped = true
poseTrack:Play()

stand.Parent = workspace

RunService.RenderStepped:Connect(function()
    if character and character:FindFirstChild("HumanoidRootPart") then
        stand:PivotTo(character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3 + math.sin(tick()*2)*0.5))
    end
end)

-- === АНИМАЦИИ СКИЛЛОВ (рабочие публичные) ===
local skills = {
    [1] = "rbxassetid://507771019",   -- удар рукой вперёд
    [2] = "rbxassetid://10921154034", -- ORA ORA (быстрые удары)
    [3] = "rbxassetid://507767968",   -- толчок ногой
    [4] = "rbxassetid://10921099718", -- оперкот ногой
}

local function playSkill(skillIndex)
    local anim = Instance.new("Animation")
    anim.AnimationId = skills[skillIndex]
    local track = humanoid:LoadAnimation(anim)
    track:Play()

    -- Стенд повторяет
    local standAnim = Instance.new("Animation")
    standAnim.AnimationId = skills[skillIndex]
    local standTrack = standHumanoid:LoadAnimation(standAnim)
    standTrack:Play()
end

-- Звук ORA
local function playORA()
    local sound = Instance.new("Sound", character)
    sound.SoundId = "rbxassetid://1093100474"
    sound.Volume = 2
    sound:Play()
    Debris:AddItem(sound, 3)
end

-- Управление
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

print("[JoJo Moveset] Готово! Ora ora!")
