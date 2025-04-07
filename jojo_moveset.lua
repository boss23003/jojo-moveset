-- JoJo Moveset for The Strongest Battlegrounds (Saitama Base)

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Удаляем музыку и анимации из базы
for _, s in pairs(Character:GetDescendants()) do
	if s:IsA("Sound") then
		s:Destroy()
	elseif s:IsA("Animation") then
		s:Destroy()
	end
end

-- Создание стенда
local function createStand()
	local stand = Character:Clone()
	stand.Name = "Stand"
	
	for _, part in ipairs(stand:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.Transparency = 0.5
			part.Material = Enum.Material.ForceField
			part.Color = Color3.fromRGB(120, 0, 180)
		end
	end

	-- Анимация скрещённых рук
	local animate = stand:FindFirstChild("Animate")
	if animate then
		animate:Destroy()
	end

	local animator = stand:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = stand:FindFirstChildOfClass("Humanoid")
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://507770239" -- Пример: idle с руками на груди
	local track = animator:LoadAnimation(anim)
	track:Play()
	track.Looped = true

	-- Присоединить к игроку
	stand.Parent = workspace

	-- Обновлять позицию за игроком
	game:GetService("RunService").RenderStepped:Connect(function()
		if Character and stand then
			local root = Character:FindFirstChild("HumanoidRootPart")
			local standRoot = stand:FindFirstChild("HumanoidRootPart")
			if root and standRoot then
				local targetPos = root.CFrame * CFrame.new(0, 0, 3)
				standRoot.CFrame = standRoot.CFrame:Lerp(targetPos * CFrame.Angles(0, math.rad(180), 0), 0.1)
			end
		end
	end)
end

createStand()
