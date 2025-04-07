-- core.lua — JoJo модификация для The Strongest Battlegrounds
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Удалим старый стенд если есть
if char:FindFirstChild("Stand") then char.Stand:Destroy() end

-- Создаём стенд
local stand = char:Clone()
stand.Name = "Stand"
stand.Parent = char
stand.HumanoidRootPart.Anchored = true
stand.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, 3)
stand.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

-- Цвет и прозрачность
for _, v in ipairs(stand:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Transparency = 0.5
		v.Color = Color3.fromRGB(128, 0, 255)
		v.CanCollide = false
	elseif v:IsA("Decal") or v:IsA("Texture") then
		v:Destroy()
	end
end

-- Анимация позы (скрещённые руки)
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://507771019" -- Пример эмоции
local track = stand.Humanoid:LoadAnimation(anim)
track:Play()
track.Looped = true

-- Привязка к игроку
game:GetService("RunService").RenderStepped:Connect(function()
	if stand and stand:FindFirstChild("HumanoidRootPart") then
		stand.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, 3)
	end
end)

-- ЗАМЕНА СКИЛЛОВ
-- Пример: второй скилл — бараж + звук ora ora ora
local function playOraSound()
	local sound = Instance.new("Sound", root)
	sound.SoundId = "rbxassetid://3762437241" -- Звук ora ora
	sound.Volume = 3
	sound:Play()
	game.Debris:AddItem(sound, 5)
end

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Two then
		playOraSound()
	end
end)

-- Остальные скиллы и визуальные эффекты можно добавить аналогично (анимации и звуки по taste)
