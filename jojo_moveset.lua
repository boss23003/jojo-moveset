--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local drag = nil
local start = nil
local pos = nil

local a = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local remotes = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local misc = Instance.new("Folder")
local Examples = Instance.new("Frame")
local examplefunction = Instance.new("TextButton")
local text = Instance.new("TextLabel")
local img = Instance.new("ImageLabel")
local exampleevent = Instance.new("TextButton")
local img_2 = Instance.new("ImageLabel")
local text_2 = Instance.new("TextLabel")
local stuff = Instance.new("Frame")
local output = Instance.new("TextBox")
local stuff_2 = Instance.new("ScrollingFrame")
local clearlogs = Instance.new("TextButton")
local copy = Instance.new("TextButton")
local run = Instance.new("TextButton")
local clearexcludions = Instance.new("TextButton")
local exclude = Instance.new("TextButton")
local scrpt = Instance.new("TextButton")
local minimize = Instance.new("TextButton")
local close = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")

a.Name = "a"
a.Parent = gethui()
a.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = a
Frame.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.061047256, 0, 0.0684079602, 0)
Frame.Size = UDim2.new(0, 890, 0, 531)

remotes.Name = "remotes"
remotes.Parent = Frame
remotes.Active = true
remotes.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
remotes.BorderColor3 = Color3.fromRGB(0, 0, 0)
remotes.BorderSizePixel = 0
remotes.Position = UDim2.new(0, 0, 0.0640301332, 0)
remotes.Size = UDim2.new(0, 248, 0, 497)
remotes.BottomImage = ""
remotes.BottomImage = ""
remotes.MidImage = ""
remotes.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
remotes.ScrollBarImageTransparency = 1
remotes.TopImage = ""
remotes.ScrollBarThickness = 0
remotes.TopImage = ""

UIListLayout.Parent = remotes
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

misc.Name = "misc"
misc.Parent = Frame

Examples.Name = "Examples"
Examples.Parent = misc
Examples.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Examples.BorderColor3 = Color3.fromRGB(0, 0, 0)
Examples.BorderSizePixel = 0
Examples.Position = UDim2.new(1.04831457, 0, 0.212806031, 0)
Examples.Size = UDim2.new(0, 100, 0, 100)
Examples.Visible = false

examplefunction.Name = "examplefunction"
examplefunction.Parent = Examples
examplefunction.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
examplefunction.BorderColor3 = Color3.fromRGB(0, 0, 0)
examplefunction.BorderSizePixel = 0
examplefunction.Size = UDim2.new(0, 248, 0, 26)
examplefunction.Font = Enum.Font.SourceSans
examplefunction.Text = ""
examplefunction.TextColor3 = Color3.fromRGB(0, 0, 0)
examplefunction.TextSize = 14.000

text.Name = "text"
text.Parent = examplefunction
text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
text.BackgroundTransparency = 1.000
text.BorderColor3 = Color3.fromRGB(0, 0, 0)
text.BorderSizePixel = 0
text.Position = UDim2.new(0.10290429, 0, 0, 0)
text.Size = UDim2.new(0, 222, 0, 26)
text.Font = Enum.Font.FredokaOne
text.Text = "name"
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.TextScaled = true
text.TextSize = 14.000
text.TextWrapped = true

img.Name = "img"
img.Parent = examplefunction
img.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
img.BackgroundTransparency = 1.000
img.BorderColor3 = Color3.fromRGB(0, 0, 0)
img.BorderSizePixel = 0
img.Position = UDim2.new(-0.00193448225, 0, 0, 0)
img.Size = UDim2.new(0, 26, 0, 26)
img.Image = "rbxassetid://13936070051"

exampleevent.Name = "exampleevent"
exampleevent.Parent = Examples
exampleevent.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
exampleevent.BorderColor3 = Color3.fromRGB(0, 0, 0)
exampleevent.BorderSizePixel = 0
exampleevent.Size = UDim2.new(0, 248, 0, 26)
exampleevent.Font = Enum.Font.SourceSans
exampleevent.Text = ""
exampleevent.TextColor3 = Color3.fromRGB(0, 0, 0)
exampleevent.TextSize = 14.000

img_2.Name = "img"
img_2.Parent = exampleevent
img_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
img_2.BackgroundTransparency = 1.000
img_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
img_2.BorderSizePixel = 0
img_2.Position = UDim2.new(-0.00193448225, 0, 0, 0)
img_2.Size = UDim2.new(0, 26, 0, 26)
img_2.Image = "rbxassetid://13936075598"

text_2.Name = "text"
text_2.Parent = exampleevent
text_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
text_2.BackgroundTransparency = 1.000
text_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
text_2.BorderSizePixel = 0
text_2.Position = UDim2.new(0.10290429, 0, 0, 0)
text_2.Size = UDim2.new(0, 222, 0, 26)
text_2.Font = Enum.Font.FredokaOne
text_2.Text = "name"
text_2.TextColor3 = Color3.fromRGB(255, 255, 255)
text_2.TextScaled = true
text_2.TextSize = 14.000
text_2.TextWrapped = true

stuff.Name = "stuff"
stuff.Parent = Frame
stuff.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
stuff.BorderColor3 = Color3.fromRGB(0, 0, 0)
stuff.BorderSizePixel = 0
stuff.Position = UDim2.new(0.278651685, 0, 0.0640301332, 0)
stuff.Size = UDim2.new(0, 642, 0, 497)

output.Name = "output"
output.Parent = stuff
output.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
output.BorderColor3 = Color3.fromRGB(0, 0, 0)
output.BorderSizePixel = 0
output.Size = UDim2.new(0, 642, 0, 327)
output.Font = Enum.Font.SourceSans
output.Text = ""
output.ClearTextOnFocus = false
output.TextScaled = true
output.TextColor3 = Color3.fromRGB(255, 255, 255)
output.TextSize = 14.000
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top

stuff_2.Name = "stuff"
stuff_2.Parent = stuff
stuff_2.Active = true
stuff_2.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
stuff_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
stuff_2.BorderSizePixel = 0
stuff_2.Position = UDim2.new(0, 0, 0.657947659, 0)
stuff_2.Size = UDim2.new(0, 641, 0, 170)
stuff_2.BottomImage = ""
stuff_2.BottomImage = ""
stuff_2.MidImage = ""
stuff_2.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
stuff_2.ScrollBarImageTransparency = 1
stuff_2.TopImage = ""
stuff_2.ScrollBarThickness = 0
stuff_2.TopImage = ""

clearlogs.Name = "clearlogs"
clearlogs.Parent = stuff_2
clearlogs.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
clearlogs.BorderColor3 = Color3.fromRGB(0, 0, 0)
clearlogs.BorderSizePixel = 0
clearlogs.Size = UDim2.new(0, 200, 0, 31)
clearlogs.Font = Enum.Font.FredokaOne
clearlogs.Text = "Clear Logs"
clearlogs.TextColor3 = Color3.fromRGB(255, 255, 255)
clearlogs.TextScaled = true
clearlogs.TextSize = 14.000
clearlogs.TextWrapped = true

copy.Name = "copy"
copy.Parent = stuff_2
copy.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
copy.BorderColor3 = Color3.fromRGB(0, 0, 0)
copy.BorderSizePixel = 0
copy.Position = UDim2.new(0.340093613, 0, 0, 0)
copy.Size = UDim2.new(0, 200, 0, 31)
copy.Font = Enum.Font.FredokaOne
copy.Text = "Copy Output"
copy.TextColor3 = Color3.fromRGB(255, 255, 255)
copy.TextScaled = true
copy.TextSize = 14.000
copy.TextWrapped = true

run.Name = "run"
run.Parent = stuff_2
run.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
run.BorderColor3 = Color3.fromRGB(0, 0, 0)
run.BorderSizePixel = 0
run.Position = UDim2.new(0.686427474, 0, 0, 0)
run.Size = UDim2.new(0, 200, 0, 31)
run.Font = Enum.Font.FredokaOne
run.Text = "Run  Output"
run.TextColor3 = Color3.fromRGB(255, 255, 255)
run.TextScaled = true
run.TextSize = 14.000
run.TextWrapped = true

clearexcludions.Name = "clearexcludions"
clearexcludions.Parent = stuff_2
clearexcludions.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
clearexcludions.BorderColor3 = Color3.fromRGB(0, 0, 0)
clearexcludions.BorderSizePixel = 0
clearexcludions.Position = UDim2.new(0, 0, 0, 45)
clearexcludions.Size = UDim2.new(0, 200, 0, 31)
clearexcludions.Font = Enum.Font.FredokaOne
clearexcludions.Text = "Clear Excludions"
clearexcludions.TextColor3 = Color3.fromRGB(255, 255, 255)
clearexcludions.TextScaled = true
clearexcludions.TextSize = 14.000
clearexcludions.TextWrapped = true

exclude.Name = "exclude"
exclude.Parent = stuff_2
exclude.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
exclude.BorderColor3 = Color3.fromRGB(0, 0, 0)
exclude.BorderSizePixel = 0
exclude.Position = UDim2.new(0.340000004, 0, 0, 45)
exclude.Size = UDim2.new(0, 200, 0, 31)
exclude.Font = Enum.Font.FredokaOne
exclude.Text = "Exclude Remote"
exclude.TextColor3 = Color3.fromRGB(255, 255, 255)
exclude.TextScaled = true
exclude.TextSize = 14.000
exclude.TextWrapped = true

scrpt.Name = "scrpt"
scrpt.Parent = stuff_2
scrpt.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
scrpt.BorderColor3 = Color3.fromRGB(0, 0, 0)
scrpt.BorderSizePixel = 0
scrpt.Position = UDim2.new(0.68599999, 0, 0, 45)
scrpt.Size = UDim2.new(0, 200, 0, 31)
scrpt.Font = Enum.Font.FredokaOne
scrpt.Text = "Make Script"
scrpt.TextColor3 = Color3.fromRGB(255, 255, 255)
scrpt.TextScaled = true
scrpt.TextSize = 14.000
scrpt.TextWrapped = true

minimize.Name = "minimize"
minimize.Parent = Frame
minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimize.BackgroundTransparency = 1.000
minimize.BorderColor3 = Color3.fromRGB(0, 0, 0)
minimize.BorderSizePixel = 0
minimize.Position = UDim2.new(0.904049218, 0, 0, 0)
minimize.Size = UDim2.new(0, 35, 0, 34)
minimize.Font = Enum.Font.SourceSansBold
minimize.Text = "−"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.TextSize = 44.000

close.Name = "close"
close.Parent = Frame
close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundTransparency = 1.000
close.BorderColor3 = Color3.fromRGB(0, 0, 0)
close.BorderSizePixel = 0
close.Position = UDim2.new(0.958566368, 0, 0, 0)
close.Size = UDim2.new(0, 35, 0, 34)
close.Font = Enum.Font.Unknown
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 25.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(0, 326, 0, 34)
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.Text = " Alqvirqq's RemoteSpy {v0.01}"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

local function update(input)
	local delta = input.Position - start
	local position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X,
	pos.Y.Scale, pos.Y.Offset + delta.Y)
	game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.25), {Position = position}):Play()
end

Frame.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
		drag = true
		start = input.Position
		pos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				drag = false
			end
		end)
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if drag then
			update(input)
		end
	end
end)

local logs = {}
local excluded = {}

local function fixargs(...)
    local args = {...}
    local strings = {}

    local function serialize(arg)
        if typeof(arg) == "string" then
            return string.format("\"%s\"", arg)
        elseif typeof(arg) == "Instance" then
            return string.format("\"%s\"", arg:GetFullName())
        elseif typeof(arg) == "table" then
            local serialized = {}
            for k, v in pairs(arg) do
                if typeof(k) == "string" then
                    table.insert(serialized, string.format("\"%s\"", k))
                end
                if typeof(v) == "string" then
                    table.insert(serialized, string.format("\"%s\"", v))
                elseif typeof(v) == "Instance" then
                    table.insert(serialized, string.format("\"%s\"", v:GetFullName()))
                else
                    table.insert(serialized, tostring(v))
                end
            end
            return "{" .. table.concat(serialized, ", ") .. "}"
        else
            return tostring(arg)
        end
    end

    for _, v in ipairs(args) do
        table.insert(strings, serialize(v))
    end

    return "local args = {\n    " .. table.concat(strings, ",\n    ") .. "\n}"
end

local function log(remote, method, ...)
    if excluded[remote] then
        return
    end

    local args = fixargs(...)
    local fullPath = "game."..remote:GetFullName()
    local txt = string.format("%s\n%s:%s(args)", args, fullPath, method)

    if not logs[remote] then
        local button = (method == "FireClient" and exampleevent or examplefunction):Clone()
        button.text.Text = remote.Name
        button.Visible = true
        button.Parent = remotes

        button.MouseButton1Click:Connect(function()
            output.Text = txt
        end)

        logs[remote] = button
    end
end

for _, remote in ipairs(game:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            log(remote, "FireClient", ...)
        end)
    elseif remote:IsA("RemoteFunction") then
        remote.OnClientInvoke = function(...)
            log(remote, "InvokeClient", ...)
        end
    end
end

game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("RemoteEvent") then
        descendant.OnClientEvent:Connect(function(...)
            log(descendant, "FireClient", ...)
        end)
    elseif descendant:IsA("RemoteFunction") then
        descendant.OnClientInvoke = function(...)
            log(descendant, "InvokeClient", ...)
        end
    end
end)


local function generate()
    local final = string.format("local active = true\nwhile active do\nwait(1) \n    %s\nend", output.Text)
    output.Text = final
end

exclude.MouseButton1Click:Connect(function()
    if output.Text == "" then
	    --nothing
	else
    for remote, button in pairs(logs) do
        if button == selected then
            excluded[remote] = true
            selected:Destroy()
            break
        end
    end
	end
end)

copy.MouseButton1Click:Connect(function()
    if output.Text == "" then
	    --nothing
	else
        setclipboard(output.Text)
	end
end)

run.MouseButton1Click:Connect(function()
    if output.Text == "" then
	    --nothing
	else
        loadstring(output.Text)()
	end
end)

scrpt.MouseButton1Click:Connect(function()
    if output.Text == "" then
	    --nothing
	else
        generate()
	end
end)

clearlogs.MouseButton1Click:Connect(function()
    output.Text = ""
    for _, child in ipairs(remotes:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    logs = {}
    excluded = {}
end)

close.MouseButton1Click:Connect(function()
    a:Destroy()
end)
