loadstring(game:HttpGet("https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/VEXOR.lua"))()

-- wait for character
repeat wait() until game.Players.LocalPlayer.Character
local plr = game.Players.LocalPlayer
local char = plr.Character
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- === STAND ===
local stand = char:Clone()
stand.Name = "Stand"
stand.Parent = workspace
stand.HumanoidRootPart.Anchored = true
stand.HumanoidRootPart.CanCollide = false
stand.HumanoidRootPart.Transparency = 1

-- Set visual
for _,v in pairs(stand:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("Decal") then
		v.Transparency = v.Transparency < 1 and 0.5 or v.Transparency
		if v:IsA("BasePart") then
			v.Color = Color3.fromRGB(128, 64, 255)
		end
	end
end

-- Remove tools from stand
for _, tool in pairs(stand:GetChildren()) do
	if tool:IsA("Tool") then tool:Destroy() end
end

-- idle animation (crossed arms)
local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://10921240139" -- пример: emotion-crossed arms
local idleTrack = stand.Humanoid:LoadAnimation(idleAnim)
idleTrack:Play()

-- float effect
task.spawn(function()
	while stand.Parent == workspace do
		for i = 1, 30 do
			stand:PivotTo(hrp.CFrame * CFrame.new(2, 3 + math.sin(tick()*2)/2, 0))
			wait(0.033)
		end
	end
end)

-- follow animations
local function copyAnimTracks()
	for _, track in pairs(hum:GetPlayingAnimationTracks()) do
		local new = stand.Humanoid:LoadAnimation(track.Animation)
		new:Play()
	end
end

hum.AnimationPlayed:Connect(function(anim)
	local clone = stand.Humanoid:LoadAnimation(anim)
	clone:Play()
end)

-- === ORA ORA on 2nd Skill ===
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Two then
		task.spawn(function()
			for i = 1, 6 do
				local sound = Instance.new("Sound", hrp)
				sound.SoundId = "rbxassetid://10478533824" -- ORA ORA ORA звук
				sound.Volume = 2
				sound:Play()
				game:GetService("Debris"):AddItem(sound, 1)
				wait(0.2)
			end
		end)
	end
end)
