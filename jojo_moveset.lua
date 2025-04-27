-- Enhanced Blox Fruits Auto Farm Script
-- Complete game file analyzer and smart quest handler
-- Created by Claude

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Blox Fruits Smart Auto Farm", "Ocean")

-- Variables
local Farming = false
local QuestFarming = false
local AutoQuest = true
local AttackKey = "Z" -- Default skill key
local AttackDelay = 0.2 -- Attack delay
local AnalysisComplete = false
local GameStructure = {}
local QuestSystem = {}
local MobLocations = {}
local CurrentQuest = nil
local GameFiles = {}

-- Get player and services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Main Tabs
local FarmTab = Window:NewTab("Auto Farm")
local AnalysisTab = Window:NewTab("Game Analysis")
local SettingsTab = Window:NewTab("Settings")

-- Game Analysis Section
local AnalysisSection = AnalysisTab:NewSection("Game Structure Analysis")
local AnalysisStatus = AnalysisSection:NewLabel("Status: Not Started")
local AnalysisProgress = AnalysisSection:NewLabel("Progress: 0%")

AnalysisSection:NewButton("Analyze Game Files", "Scan game structure and find all key elements", function()
    AnalysisStatus:UpdateLabel("Status: Analysis in progress...")
    AnalyzeGameStructure()
end)

-- Auto Farm Section
local QuestSection = FarmTab:NewSection("Auto Quest")
local QuestStatus = QuestSection:NewLabel("Quest Status: No Quest")
local FarmStatus = QuestSection:NewLabel("Farm Status: Idle")

QuestSection:NewToggle("Auto Farm", "Automatically farm enemies and complete quests", function(state)
    QuestFarming = state
    if state then
        QuestFarm()
    else
        FarmStatus:UpdateLabel("Farm Status: Idle")
    end
end)

QuestSection:NewToggle("Auto Quest", "Automatically accept quests", function(state)
    AutoQuest = state
end)

-- Settings Section
local SettingsSection = SettingsTab:NewSection("Farm Settings")

SettingsSection:NewSlider("Attack Delay", "Adjust attack delay in seconds", 0.1, 1, 10, 0.1, function(value)
    AttackDelay = value
end)

SettingsSection:NewDropdown("Attack Skill", "Choose skill key to use", {"Z", "X", "C", "V"}, function(selected)
    AttackKey = selected
end)

-- Deep game file analysis function
function DeepAnalyzeGameFiles()
    GameFiles = {}
    
    -- Analyze client-side game scripts and modules
    local function ScanInstance(instance, path)
        -- Add to our game files collection
        table.insert(GameFiles, {
            Instance = instance,
            Path = path,
            Type = instance.ClassName
        })
        
        -- Special handling for scripts and modules
        if instance:IsA("ModuleScript") or instance:IsA("Script") or instance:IsA("LocalScript") then
            -- Try to analyze script contents for quest related functions
            local success, result = pcall(function()
                if instance:IsA("ModuleScript") then
                    local module = require(instance)
                    return module
                end
                return nil
            end)
            
            if success and result then
                -- Check if this module contains quest data
                if type(result) == "table" then
                    -- Look for quest-related keys
                    for key, value in pairs(result) do
                        if string.find(string.lower(key), "quest") or 
                           string.find(string.lower(key), "mission") or
                           string.find(string.lower(key), "task") then
                            -- Found quest-related data
                            if not QuestSystem.QuestData then QuestSystem.QuestData = {} end
                            
                            -- Try to extract quest information
                            if type(value) == "table" then
                                for questName, questInfo in pairs(value) do
                                    if type(questInfo) == "table" then
                                        table.insert(QuestSystem.QuestData, {
                                            Source = "Module",
                                            Module = instance.Name,
                                            QuestName = tostring(questName),
                                            Level = questInfo.Level or questInfo["Level"] or questInfo.level or 0,
                                            Mob = questInfo.Mob or questInfo["Mob"] or questInfo.Enemy or questInfo["Enemy"] or "",
                                            NPC = questInfo.NPC or questInfo["NPC"] or questInfo.QuestGiver or questInfo["QuestGiver"] or ""
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Recurse through children
        for _, child in pairs(instance:GetChildren()) do
            ScanInstance(child, path .. "." .. child.Name)
        end
    end
    
    -- Start scanning from key game services
    ScanInstance(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
    ScanInstance(game:GetService("ReplicatedFirst"), "ReplicatedFirst")
    ScanInstance(game:GetService("StarterGui"), "StarterGui")
    
    -- Extract remote events for quest interaction
    QuestSystem.RemoteEvents = {}
    for _, fileInfo in pairs(GameFiles) do
        if fileInfo.Instance:IsA("RemoteEvent") or fileInfo.Instance:IsA("RemoteFunction") then
            local name = fileInfo.Instance.Name:lower()
            if name:find("quest") or name:find("mission") or name:find("task") or name:find("npc") then
                table.insert(QuestSystem.RemoteEvents, {
                    Name = fileInfo.Instance.Name,
                    Path = fileInfo.Path,
                    Instance = fileInfo.Instance,
                    Type = fileInfo.Instance.ClassName
                })
            end
        end
    end
    
    -- Return analysis results
    return #GameFiles > 0
end

-- Function to analyze game structure
function AnalyzeGameStructure()
    coroutine.wrap(function()
        -- Step 1: Identify important game services and folders
        AnalysisProgress:UpdateLabel("Progress: 10% - Scanning services...")
        wait(0.2)
        
        -- Check ReplicatedStorage for key scripts and modules
        GameStructure.ReplicatedStorage = {}
        for _, item in pairs(ReplicatedStorage:GetDescendants()) do
            if item:IsA("ModuleScript") then
                table.insert(GameStructure.ReplicatedStorage, {Name = item.Name, Path = GetFullPath(item)})
                if item.Name:find("Quest") or item.Name:find("Mob") or item.Name:find("NPC") then
                    -- Found potentially important module
                    if not QuestSystem.QuestModules then QuestSystem.QuestModules = {} end
                    table.insert(QuestSystem.QuestModules, {Name = item.Name, Path = GetFullPath(item), Instance = item})
                end
            end
        end
        
        AnalysisProgress:UpdateLabel("Progress: 25% - Analyzing workspace...")
        wait(0.2)
        
        -- Analyze workspace for NPCs, enemies, and quest-related objects
        GameStructure.Workspace = {}
        
        -- Find all NPCs
        QuestSystem.NPCs = FindAllNPCs()
        
        -- Find quest givers specifically
        QuestSystem.QuestGivers = FindQuestGivers()
        
        AnalysisProgress:UpdateLabel("Progress: 40% - Deep analyzing game files...")
        wait(0.2)
        
        -- Perform deep game file analysis
        local success = DeepAnalyzeGameFiles()
        
        AnalysisProgress:UpdateLabel("Progress: 50% - Identifying quest UI elements...")
        wait(0.2)
        
        -- Analyze player GUI for quest UI elements
        GameStructure.PlayerGUI = {}
        QuestSystem.QuestUI = AnalyzeQuestUI()
        
        AnalysisProgress:UpdateLabel("Progress: 75% - Mapping enemy locations...")
        wait(0.2)
        
        -- Map enemy locations
        MobLocations = MapEnemyLocations()
        
        -- Determine quest data based on level
        if not QuestSystem.QuestData or #QuestSystem.QuestData == 0 then
            QuestSystem.QuestData = DetermineQuestData()
        end
        
        -- Setup real-time monitoring
        SetupRealTimeMonitoring()
        
        AnalysisProgress:UpdateLabel("Progress: 100% - Analysis complete!")
        AnalysisStatus:UpdateLabel("Status: Complete - Found " .. #QuestSystem.QuestGivers .. " quest givers, " .. #QuestSystem.NPCs .. " NPCs, " .. #MobLocations .. " enemy zones")
        
        -- Update UI with findings
        UpdateAnalysisUI()
        
        AnalysisComplete = true
    end)()
end

-- Function to set up real-time monitoring
function SetupRealTimeMonitoring()
    -- Monitor workspace for new enemies
    workspace.ChildAdded:Connect(function(child)
        wait(1) -- Wait for the instance to initialize
        if child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            -- Check if it's an enemy
            local enemyName = child.Name:gsub("%d+", "") -- Remove numbers from name
            
            -- Update enemy locations
            local found = false
            for i, zone in ipairs(MobLocations) do
                if zone.EnemyType == enemyName then
                    found = true
                    -- Update centroid position
                    zone.Position = (zone.Position * zone.Count + child.HumanoidRootPart.Position) / (zone.Count + 1)
                    zone.Count = zone.Count + 1
                    break
                end
            end
            
            if not found then
                table.insert(MobLocations, {
                    EnemyType = enemyName,
                    Position = child.HumanoidRootPart.Position,
                    Count = 1,
                    Level = child:FindFirstChild("Level") and child.Level.Value or 0
                })
            end
        end
    end)
    
    -- Monitor for quest UI changes
    LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            -- Analyze new GUI for quest elements
            for _, elem in pairs(child:GetDescendants()) do
                if elem:IsA("Frame") and (elem.Name:find("Quest") or elem.Name:find("Task")) then
                    QuestSystem.QuestUI.QuestFrame = elem
                elseif elem:IsA("TextLabel") and (elem.Text:find("ЗАДАНИЕ") or elem.Text:find("QUEST")) then
                    QuestSystem.QuestUI.QuestHeader = elem
                elseif elem:IsA("TextLabel") and (elem.Text:find("Defeat") or elem.Text:find("Collect")) then
                    QuestSystem.QuestUI.QuestDescription = elem
                elseif elem:IsA("TextButton") and (elem.Text:find("Бандиты") or elem.Text:find("Bandits")) then
                    QuestSystem.QuestUI.QuestSelectButton = elem
                elseif elem:IsA("TextButton") and (elem.Text:find("Подтвердить") or elem.Text:find("Confirm")) then
                    QuestSystem.QuestUI.QuestConfirmButton = elem
                end
            end
        end
    end)
    
    -- Monitor remote events for quest interactions
    if QuestSystem.RemoteEvents then
        for _, remoteEvent in pairs(QuestSystem.RemoteEvents) do
            -- Hook remote event to detect quest interactions
            local old
            old = hookfunction(remoteEvent.Instance.FireServer, function(self, ...)
                local args = {...}
                
                -- Log quest interaction
                print("[Quest System] Remote event fired: " .. remoteEvent.Name)
                if #args > 0 then
                    print("[Quest System] Args:", unpack(args))
                end
                
                -- Return original call
                return old(self, ...)
            end)
        end
    end
}

-- Function to get full path of an instance
function GetFullPath(instance)
    local path = instance.Name
    local parent = instance.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return path
end

-- Function to find all NPCs in the workspace
function FindAllNPCs()
    local npcs = {}
    
    -- Check in NPCs folder if exists
    if workspace:FindFirstChild("NPCs") then
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
                table.insert(npcs, {
                    Name = npc.Name,
                    Position = npc.HumanoidRootPart.Position,
                    Instance = npc
                })
            end
        end
    end
    
    -- Check direct in workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            -- Check if it's likely an NPC (not player or enemy)
            if not obj.Name:find("Model") and Players:FindFirstChild(obj.Name) == nil then
                -- Verify it's not a common enemy type
                if not obj.Name:find("Bandit") and not obj.Name:find("Marine") and not obj.Name:find("Pirate") then
                    table.insert(npcs, {
                        Name = obj.Name,
                        Position = obj.HumanoidRootPart.Position,
                        Instance = obj
                    })
                end
            end
        end
    end
    
    return npcs
end

-- Function to find quest givers specifically
function FindQuestGivers()
    local questGivers = {}
    
    -- Check all NPCs we found for quest giver characteristics
    for _, npc in pairs(QuestSystem.NPCs) do
        -- Check if name suggests quest giver
        if npc.Name:find("Quest") or npc.Name:find("Giver") or npc.Name:find("Mission") then
            table.insert(questGivers, npc)
        end
        
        -- Check if it has quest-related UI when approached
        local instance = npc.Instance
        if instance:FindFirstChild("QuestUI") or instance:FindFirstChild("Dialog") then
            table.insert(questGivers, npc)
        end
    end
    
    -- If we found no quest givers using those methods, use known quest givers
    if #questGivers == 0 then
        -- Common quest giver names in Blox Fruits
        local commonQuestGivers = {
            "Bandit Quest Giver",
            "Marine Recruiter",
            "Desert Bandit Leader",
            "Jungle Quest Giver",
            "Pirate Quest Giver",
            "Snow Bandit Leader",
            "Blox Fruit Dealer"
        }
        
        for _, commonName in pairs(commonQuestGivers) do
            for _, npc in pairs(QuestSystem.NPCs) do
                if npc.Name:find(commonName) or npc.Name == commonName then
                    table.insert(questGivers, npc)
                end
            end
        end
    end
    
    return questGivers
end

-- Function to analyze quest UI elements
function AnalyzeQuestUI()
    local questUI = {}
    
    -- Check player GUI for quest-related UI elements
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                -- Look for quest-related frames and labels
                for _, elem in pairs(gui:GetDescendants()) do
                    if elem:IsA("Frame") and (elem.Name:find("Quest") or elem.Name:find("Task")) then
                        questUI.QuestFrame = elem
                    elseif elem:IsA("TextLabel") and (elem.Text:find("ЗАДАНИЕ") or elem.Text:find("QUEST")) then
                        questUI.QuestHeader = elem
                    elseif elem:IsA("TextLabel") and (elem.Text:find("Defeat") or elem.Text:find("Collect")) then
                        questUI.QuestDescription = elem
                    elseif elem:IsA("TextButton") and (elem.Text:find("Бандиты") or elem.Text:find("Bandits")) then
                        questUI.QuestSelectButton = elem
                    elseif elem:IsA("TextButton") and (elem.Text:find("Подтвердить") or elem.Text:find("Confirm")) then
                        questUI.QuestConfirmButton = elem
                    end
                end
            end
        end
    end
    
    return questUI
end

-- Function to map enemy locations
function MapEnemyLocations()
    local enemyZones = {}
    
    -- Check Workspace.Enemies if it exists
    if workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") then
                local enemyName = enemy.Name:gsub("%d+", "") -- Remove numbers from name
                
                -- Check if we already have this enemy type
                local found = false
                for i, zone in ipairs(enemyZones) do
                    if zone.EnemyType == enemyName then
                        found = true
                        -- Update centroid position
                        zone.Position = (zone.Position * zone.Count + enemy.HumanoidRootPart.Position) / (zone.Count + 1)
                        zone.Count = zone.Count + 1
                        break
                    end
                end
                
                if not found then
                    table.insert(enemyZones, {
                        EnemyType = enemyName,
                        Position = enemy.HumanoidRootPart.Position,
                        Count = 1,
                        Level = enemy:FindFirstChild("Level") and enemy.Level.Value or 0
                    })
                end
            end
        end
    end
    
    -- Check direct in workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            -- Check if it's an enemy (common enemy types)
            if obj.Name:find("Bandit") or obj.Name:find("Marine") or obj.Name:find("Pirate") or obj.Name:find("Beast") then
                local enemyName = obj.Name:gsub("%d+", "") -- Remove numbers from name
                
                -- Check if we already have this enemy type
                local found = false
                for i, zone in ipairs(enemyZones) do
                    if zone.EnemyType == enemyName then
                        found = true
                        -- Update centroid position
                        zone.Position = (zone.Position * zone.Count + obj.HumanoidRootPart.Position) / (zone.Count + 1)
                        zone.Count = zone.Count + 1
                        break
                    end
                end
                
                if not found then
                    table.insert(enemyZones, {
                        EnemyType = enemyName,
                        Position = obj.HumanoidRootPart.Position,
                        Count = 1,
                        Level = obj:FindFirstChild("Level") and obj.Level.Value or 0
                    })
                end
            end
        end
    end
    
    return enemyZones
end

-- Function to determine quest data based on game analysis
function DetermineQuestData()
    local questData = {}
    
    -- If we have direct quest data from game modules, use it
    if QuestSystem.QuestModules and #QuestSystem.QuestModules > 0 then
        for _, module in pairs(QuestSystem.QuestModules) do
            local success, result = pcall(function()
                return require(module.Instance)
            end)
            
            if success and type(result) == "table" then
                -- Extract quest data from module
                for key, data in pairs(result) do
                    if type(data) == "table" and (data.Level or data.level) then
                        table.insert(questData, {
                            Level = data.Level or data.level or 0,
                            NPC = data.NPC or data.Giver or data.QuestGiver or "",
                            Mob = data.Mob or data.Monster or data.Enemy or "",
                            QuestName = key,
                            Position = data.Position or Vector3.new(0, 0, 0)
                        })
                    end
                end
            end
        end
    end
    
    -- If we have mapped enemy zones, we can infer quest data
    if #questData == 0 then
        for i, enemy in ipairs(MobLocations) do
            -- Find quest giver closest to this enemy zone
            local closestQuestGiver = nil
            local minDistance = math.huge
            
            for _, questGiver in ipairs(QuestSystem.QuestGivers) do
                local distance = (questGiver.Position - enemy.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestQuestGiver = questGiver
                end
            end
            
            if closestQuestGiver and minDistance < 500 then -- Reasonable distance for quest giver to enemy
                table.insert(questData, {
                    Level = enemy.Level,
                    NPC = closestQuestGiver.Name,
                    Mob = enemy.EnemyType,
                    QuestName = enemy.EnemyType .. "Quest",
                    Position = closestQuestGiver.Position
                })
            end
        end
    end
    
    -- If we couldn't determine quest data, use default data
    if #questData == 0 then
        questData = {
            {Level = 0, NPC = "Bandit Quest Giver", Mob = "Bandit", QuestName = "BanditQuest1"},
            {Level = 10, NPC = "Bandit Quest Giver", Mob = "Bandit", QuestName = "BanditQuest2"},
            {Level = 25, NPC = "Marine Recruiter", Mob = "Marine", QuestName = "MarineQuest"},
            {Level = 40, NPC = "Blox Fruit Dealer", Mob = "Gorilla", QuestName = "GorillaQuest"}
        }
    end
    
    -- Sort quests by level
    table.sort(questData, function(a, b)
        return a.Level < b.Level
    end)
    
    return questData
end

-- Function to update analysis UI with findings
function UpdateAnalysisUI()
    local DetailsSection = AnalysisTab:NewSection("Game Details")
    
    -- Add quest givers to the UI
    for i, questGiver in ipairs(QuestSystem.QuestGivers) do
        if i <= 5 then -- Limit to 5 to avoid cluttering UI
            DetailsSection:NewLabel("Quest Giver #" .. i .. ": " .. questGiver.Name)
        end
    end
    
    -- Add enemy zones to the UI
    DetailsSection:NewLabel("----------")
    for i, zone in ipairs(MobLocations) do
        if i <= 5 then -- Limit to 5 to avoid cluttering UI
            DetailsSection:NewLabel("Enemy #" .. i .. ": " .. zone.EnemyType .. " (x" .. zone.Count .. ")")
        end
    end
    
    -- Show available quests based on analysis
    DetailsSection:NewLabel("----------")
    DetailsSection:NewLabel("Available Quests:")
    
    for i, quest in ipairs(QuestSystem.QuestData) do
        if i <= 5 then -- Limit to 5
            DetailsSection:NewLabel("Lvl " .. quest.Level .. ": " .. quest.QuestName .. " - " .. quest.Mob)
        end
    end
    
    -- Update main farm UI with information
    QuestSection:NewDropdown("Select Enemy", "Choose enemy to farm", GetEnemyList(), function(value)
        for _, zone in ipairs(MobLocations) do
            if zone.EnemyType == value then
                CurrentQuest = {
                    Mob = zone.EnemyType,
                    Position = zone.Position,
                    Level = zone.Level
                }
                QuestStatus:UpdateLabel("Quest Status: Manual - " .. value)
                break
            end
        end
    end)
    
    -- Add auto-quest dropdown
    local questNames = {}
    for _, quest in ipairs(QuestSystem.QuestData) do
        table.insert(questNames, quest.QuestName .. " (Lvl " .. quest.Level .. ")")
    end
    
    if #questNames > 0 then
        QuestSection:NewDropdown("Select Quest", "Choose a specific quest", questNames, function(value)
            -- Extract quest name from selection
            local questName = string.match(value, "(.+) %(Lvl")
            
            -- Find the quest data
            for _, quest in ipairs(QuestSystem.QuestData) do
                if quest.QuestName == questName then
                    CurrentQuest = quest
                    QuestStatus:UpdateLabel("Quest Status: Manual - " .. questName)
                    break
                end
            end
        end)
    end
end

-- Function to get list of enemy types
function GetEnemyList()
    local enemyList = {}
    for _, zone in ipairs(MobLocations) do
        table.insert(enemyList, zone.EnemyType)
    end
    return enemyList
end

-- Function to get player's level
function GetPlayerLevel()
    if LocalPlayer and LocalPlayer.Data and LocalPlayer.Data.Level then
        return LocalPlayer.Data.Level.Value
    else
        -- Try different ways to get level based on game structure
        for _, v in pairs(LocalPlayer:GetChildren()) do
            if v:IsA("IntValue") and (v.Name == "Level" or v.Name:find("Level")) then
                return v.Value
            end
        end
        
        -- Additional check for other common level paths
        if LocalPlayer.leaderstats and LocalPlayer.leaderstats:FindFirstChild("Level") then
            return LocalPlayer.leaderstats.Level.Value
        end
        
        -- Default level if none found
        return 1
    end
end

-- Function to determine appropriate quest for player's level
function GetAppropriateQuest()
    if QuestSystem.QuestData and #QuestSystem.QuestData > 0 then
        local playerLevel = GetPlayerLevel()
        local bestQuest = QuestSystem.QuestData[1]
        
        for _, quest in pairs(QuestSystem.QuestData) do
            if playerLevel >= quest.Level and quest.Level >= bestQuest.Level then
                bestQuest = quest
            end
        end
        
        return bestQuest
    else
        -- Default quest if we don't have quest data
        return {Level = 0, NPC = "Bandit Quest Giver", Mob = "Bandit", QuestName = "BanditQuest1"}
    end
end

-- Function to find NPC by name in workspace
function FindNPC(name)
    -- Try matching to our analyzed NPCs first
    if QuestSystem.NPCs then
        for _, npc in pairs(QuestSystem.NPCs) do
            if npc.Name == name or npc.Name:find(name) then
                return npc.Instance
            end
        end
    end
    
    -- Traditional search methods
    if workspace:FindFirstChild("NPCs") then
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            if npc.Name == name or npc.Name:find(name) then
                return npc
            end
        end
    end
    
    for _, npc in pairs(workspace:GetChildren()) do
        if npc.Name == name or npc.Name:find(name) then
            return npc
        end
    end
    
    return nil
end

-- Function to get closest enemy by name with improved targeting
function GetClosestEnemy(mobName, range)
    local closest = nil
    local maxDistance = range or 1000
    
    -- If we have analyzed enemy locations, use those for targeting
    for _, zone in ipairs(MobLocations) do
        if zone.EnemyType:find(mobName) or mobName:find(zone.EnemyType) then
            -- Go to the enemy zone center and find specific enemies
            Character.HumanoidRootPart.CFrame = CFrame.new(zone.Position + Vector3.new(0, 10, 0))
            wait(0.5) -- Give time for enemies to load
            break
        end
    end
    
    -- Try to find in Workspace.Enemies
    if workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if (enemy.Name:find(mobName) or mobName:find(enemy.Name)) and 
               enemy:FindFirstChild("HumanoidRootPart") and 
               enemy:FindFirstChild("Humanoid") and 
               enemy.Humanoid.Health > 0 then
                local distance = (Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance < maxDistance then
                    maxDistance = distance
                    closest = enemy
                end
            end
        end
    end
    
    -- Try direct in Workspace
    if not closest then
        for _, enemy in pairs(workspace:GetChildren()) do
            if (enemy.Name:find(mobName) or mobName:find(enemy.Name)) and 
               enemy:FindFirstChild("HumanoidRootPart") and 
               enemy:FindFirstChild("Humanoid") and 
               enemy.Humanoid.Health > 0 then
                local distance = (Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance < maxDistance then
                    maxDistance = distance
                    closest = enemy
                end
            end
        end
    end
    
    return closest
end

-- Function to teleport to position with tweening
function TeleportTo(position)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local distance = (Character.HumanoidRootPart.Position - position).Magnitude
        local speed = 25
        local time = distance / (speed * 10)
local tweenInfo = TweenInfo.new(
            time,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out,
            0,
            false,
            0
        )
        
        local tween = TweenService:Create(Character.HumanoidRootPart, tweenInfo, {
            CFrame = CFrame.new(position)
        })
        
        tween:Play()
        return tween
    end
    return nil
end

-- Function to fly to enemy
function FlyToEnemy(enemy, height)
    height = height or 8
    if enemy and enemy:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = enemy.HumanoidRootPart.Position + Vector3.new(0, height, 0)
        return TeleportTo(targetPosition)
    end
    return nil
end

-- Advanced function to check if quest is active with multiple UI detection methods
function HasActiveQuest(mobName)
    -- Method 1: Check for "ЗАДАНИЕ" or "QUEST" label with quest info
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("TextLabel") and (frame.Text == "ЗАДАНИЕ" or frame.Text:find("QUEST")) then
                        -- Found quest header, check if quest details contain mob name
                        local parent = frame.Parent
                        for _, label in pairs(parent:GetDescendants()) do
                            if label:IsA("TextLabel") and (
                               label.Text:find("Defeat") or 
                               label.Text:find("Убить") or
                               label.Text:find("Собрать") or
                               label.Text:find("Collect") or
                               label.Text:find(mobName)) then
                                return true, label.Text -- Return true and the quest text
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Method 2: Check for quest progress counter UI
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, frame in pairs(gui:GetDescendants()) do
                if frame:IsA("TextLabel") and (
                   frame.Text:find("%d+/%d+") or 
                   frame.Text:find(mobName)) then
                    return true, frame.Text
                end
            end
        end
    end
    
    -- Method 3: Check quest tracking in player data
    if LocalPlayer:FindFirstChild("CurrentQuest") then
        return true, LocalPlayer.CurrentQuest.Value
    end
    
    -- Method 4: Check by remote event interception (set up in the real-time monitoring)
    -- This is handled by the remote event hooking setup earlier
    
    return false, "No quest active"
end

-- Smart function to accept quest using UI detection and remote events
function AcceptQuest(questNPC)
    -- Find the Quest NPC
    local npc = FindNPC(questNPC)
    if not npc or not npc:FindFirstChild("HumanoidRootPart") then
        print("[Quest System] Quest NPC not found: " .. questNPC)
        return false
    end
    
    -- Teleport to NPC
    local tween = TeleportTo(npc.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
    if tween then
        tween.Completed:Wait()
        wait(1)
        
        -- Method 1: Try using quest remote events if we found them
        local usedRemote = false
        if QuestSystem.RemoteEvents and #QuestSystem.RemoteEvents > 0 then
            for _, remoteEvent in pairs(QuestSystem.RemoteEvents) do
                if remoteEvent.Name:find("Quest") then
                    -- Try different common quest remote event patterns
                    local success, result
                    
                    -- Pattern 1: Accept quest by NPC name
                    success, result = pcall(function()
                        return remoteEvent.Instance:FireServer(questNPC)
                    end)
                    
                    -- Pattern 2: Accept quest by quest name
                    if not success then
                        for _, questData in pairs(QuestSystem.QuestData) do
                            if questData.NPC == questNPC then
                                success, result = pcall(function()
                                    return remoteEvent.Instance:FireServer(questData.QuestName)
                                end)
                                if success then break end
                            end
                        end
                    end
                    
                    -- Pattern 3: Just fire event with no args
                    if not success then
                        success, result = pcall(function()
                            return remoteEvent.Instance:FireServer()
                        end)
                    end
                    
                    if success then
                        usedRemote = true
                        print("[Quest System] Used remote event to accept quest: " .. remoteEvent.Name)
                        wait(1)
                        break
                    end
                end
            end
        end
        
        -- Method 2: UI interaction if remote event didn't work
        if not usedRemote then
            -- First click the NPC
            local screenPosition = workspace.CurrentCamera:WorldToScreenPoint(npc.HumanoidRootPart.Position)
            VirtualUser:MoveMouse(Vector2.new(screenPosition.X, screenPosition.Y))
            wait(0.3)
            VirtualUser:ClickButton1(Vector2.new(screenPosition.X, screenPosition.Y))
            wait(1)
            
            -- Now find and click quest UI elements
            local success = false
            
            -- Use the UI elements we found during analysis if available
            if QuestSystem.QuestUI and QuestSystem.QuestUI.QuestSelectButton then
                local btn = QuestSystem.QuestUI.QuestSelectButton
                local buttonPos = btn.AbsolutePosition + btn.AbsoluteSize/2
                
                -- Click the button
                VirtualUser:MoveMouse(Vector2.new(buttonPos.X, buttonPos.Y))
                wait(0.3)
                VirtualUser:ClickButton1(Vector2.new(buttonPos.X, buttonPos.Y))
                wait(0.5)
                success = true
                
                -- Click confirm button
                if QuestSystem.QuestUI.QuestConfirmButton then
                    btn = QuestSystem.QuestUI.QuestConfirmButton
                    buttonPos = btn.AbsolutePosition + btn.AbsoluteSize/2
                    
                    VirtualUser:MoveMouse(Vector2.new(buttonPos.X, buttonPos.Y))
                    wait(0.3)
                    VirtualUser:ClickButton1(Vector2.new(buttonPos.X, buttonPos.Y))
                    wait(0.5)
                end
            else
                -- Fallback to searching for buttons by text
                local function clickButtonByText(textToFind)
                    for _, ui in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetDescendants()) do
                        if (ui:IsA("TextButton") or ui:IsA("TextLabel")) and ui.Visible then
                            if ui.Text == textToFind or ui.Text:find(textToFind) then
                                -- Get screen position
                                local buttonPos = ui.AbsolutePosition + ui.AbsoluteSize/2
                                
                                -- Click the button
                                VirtualUser:MoveMouse(Vector2.new(buttonPos.X, buttonPos.Y))
                                wait(0.3)
                                VirtualUser:ClickButton1(Vector2.new(buttonPos.X, buttonPos.Y))
                                wait(0.5)
                                success = true
                                return true
                            end
                        end
                    end
                    return false
                end
                
                -- Try different language UIs
                local clickOptions = {
                    "Бандиты", "Bandits", "Accept", "Принять", "Start",
                    "Начать", "Pirates", "Marines", "Пираты", "Морские пехотинцы"
                }
                
                for _, option in pairs(clickOptions) do
                    if clickButtonByText(option) then
                        wait(0.5)
                        break
                    end
                end
                
                -- Try confirm buttons after selecting quest
                local confirmOptions = {
                    "Подтвердить", "Confirm", "Yes", "Да", "OK"
                }
                
                for _, option in pairs(confirmOptions) do
                    if clickButtonByText(option) then
                        break
                    end
                end
            end
        }
        
        -- Wait a moment for quest to register
        wait(1)
        
        -- Verify quest activation with detailed feedback
        local hasQuest, questText = HasActiveQuest("Bandit")
        if hasQuest then
            print("[Quest System] Successfully accepted quest: " .. questText)
            return true, questText
        else
            print("[Quest System] Failed to accept quest")
            return false
        end
    end
    
    return false
end

-- Function to use normal attack
function NormalAttack()
    VirtualUser:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    wait(0.05)
    VirtualUser:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Function to use skill
function UseSkill(key)
    VirtualUser:SendKeyEvent(true, key, false, game)
    wait(0.1)
    VirtualUser:SendKeyEvent(false, key, false, game)
end

-- Function to detect and use available skills based on cooldowns
function UseAvailableSkills()
    -- Common skill keys in Blox Fruits
    local skillKeys = {"Z", "X", "C", "V", "F"}
    
    -- Try to detect skill cooldowns through UI
    local cooldowns = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("ImageLabel") or obj:IsA("Frame") then
                        -- Check if this might be a cooldown indicator
                        if obj.Name:find("Cooldown") or obj.Name:find("CD") then
                            local key = obj.Name:match("([ZXCVF])") or "Z"
                            local isCooldown = obj.Visible
                            if not isCooldown then
                                table.insert(cooldowns, key)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- If we found available skills, use them in priority order
    if #cooldowns > 0 then
        for _, key in pairs(cooldowns) do
            UseSkill(key)
            wait(AttackDelay * 2)
        end
        return true
    else
        -- If we couldn't detect cooldowns, use the primary skill
        UseSkill(AttackKey)
        return true
    end
end

-- Function to check and use any active Blox Fruits abilities
function UseBloxFruitAbilities()
    -- Try to detect if player has an active Blox Fruit
    local hasFruit = false
    
    -- Method 1: Check for fruit specific UI elements
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:find("Fruit") or gui.Name:find("Devil")) then
                hasFruit = true
                break
            end
        end
    end
    
    -- Method 2: Check for fruit specific tools/abilities
    if not hasFruit then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find("Fruit") then
                hasFruit = true
                break
            end
        end
    end
    
    if hasFruit then
        -- Use fruit abilities (typically bound to these keys)
        local fruitKeys = {"Z", "X", "C", "V"}
        for _, key in pairs(fruitKeys) do
            UseSkill(key)
            wait(AttackDelay * 2)
        end
        return true
    end
    
    return false
end

-- Function to collect dropped items and rewards
function CollectDrops()
    -- Search for common drop objects
    local drops = {}
    
    -- Check workspace for drops
    for _, obj in pairs(workspace:GetChildren()) do
        -- Common drop names in Blox Fruits
        if obj.Name == "Drop" or obj.Name == "Chest" or obj.Name == "Fruit" or obj.Name:find("Chest") then
            if obj:IsA("Model") or obj:IsA("Part") then
                table.insert(drops, obj)
            end
        end
    end
    
    -- If we found drops, collect them
    for _, drop in pairs(drops) do
        if drop:FindFirstChild("TouchInterest") or drop:FindFirstChild("ProximityPrompt") then
            -- Get position to touch
            local touchPos
            if drop:IsA("Model") and drop:FindFirstChild("HumanoidRootPart") then
                touchPos = drop.HumanoidRootPart.Position
            else
                touchPos = drop.Position
            end
            
            -- Move to the drop
            local tween = TeleportTo(touchPos)
            if tween then
                tween.Completed:Wait()
                wait(0.5)
                
                -- If it has a proximity prompt, trigger it
                if drop:FindFirstChild("ProximityPrompt") then
                    fireproximityprompt(drop.ProximityPrompt)
                end
            end
        end
    end
    
    return #drops > 0
end

-- Enhanced quest auto-farm function with real-time checks
function QuestFarm()
    -- Ensure we've analyzed the game
    if not AnalysisComplete then
        FarmStatus:UpdateLabel("Farm Status: Analyzing game first...")
        AnalyzeGameStructure()
        
        -- Wait for analysis to complete
        local timeout = 0
        while not AnalysisComplete and timeout < 100 do
            wait(0.1)
            timeout = timeout + 1
        end
        
        if not AnalysisComplete then
            FarmStatus:UpdateLabel("Farm Status: Analysis timed out, using defaults")
        end
    end
    
    while QuestFarming do
        -- Update status
        FarmStatus:UpdateLabel("Farm Status: Active")
        
        -- Get appropriate quest based on player level or current selected quest
        local questInfo
        if CurrentQuest then
            questInfo = CurrentQuest
        else
            questInfo = GetAppropriateQuest()
        end
        
        -- Show what quest we're targeting
        QuestStatus:UpdateLabel("Quest Status: " .. (questInfo.QuestName or questInfo.Mob) .. " (" .. questInfo.Mob .. ")")
        
        -- Check if we have the quest already
        local hasQuest, questText = HasActiveQuest(questInfo.Mob)
        
        -- If we don't have the quest, go get it
        if not hasQuest and AutoQuest then
            FarmStatus:UpdateLabel("Farm Status: Getting quest")
            local success, newQuestText = AcceptQuest(questInfo.NPC)
            if not success then
                FarmStatus:UpdateLabel("Farm Status: Failed to get quest, retrying...")
                wait(3)
                continue
            else
                FarmStatus:UpdateLabel("Farm Status: Got quest - " .. newQuestText)
            end
            wait(1)
        end
        
        -- Collect any nearby drops before moving on
        CollectDrops()
        
        -- Farm the mob for the quest
        FarmStatus:UpdateLabel("Farm Status: Searching for enemies")
        local enemy = GetClosestEnemy(questInfo.Mob, 1000)
        
        if enemy then
            FarmStatus:UpdateLabel("Farm Status: Found enemy - " .. enemy.Name)
            -- Teleport to the enemy
            local tween = FlyToEnemy(enemy, 8)
            if tween then
                tween.Completed:Wait()
                
                -- Attack loop
                FarmStatus:UpdateLabel("Farm Status: Attacking " .. enemy.Name)
                local attackStart = tick()
                while enemy and enemy.Parent and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and tick() - attackStart < 15 and QuestFarming do
                    if Character and Character:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("HumanoidRootPart") then
                        -- Position above enemy
                        Character.HumanoidRootPart.CFrame = CFrame.new(
                            enemy.HumanoidRootPart.Position + Vector3.new(0, 8, 0),
                            enemy.HumanoidRootPart.Position
                        )
                        
                        -- First try to use Blox Fruit abilities
                        UseBloxFruitAbilities()
                        
                        -- Then try to use normal skills
                        UseAvailableSkills()
                        
                        -- Finally fall back to normal attacks
                        NormalAttack()
                        wait(AttackDelay)
                    else
                        break
                    end
                    
                    wait()
                end
                
                -- Check if enemy died and collect drops
                if not enemy or not enemy.Parent or (enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health <= 0) then
                    FarmStatus:UpdateLabel("Farm Status: Enemy defeated")
                    CollectDrops()
                end
            }
        else
            FarmStatus:UpdateLabel("Farm Status: No enemies found, searching...")
            -- If we have analyzed enemy locations, go to the zone center
            local foundEnemyZone = false
            for _, zone in ipairs(MobLocations) do
                if zone.EnemyType:find(questInfo.Mob) or questInfo.Mob:find(zone.EnemyType) then
                    FarmStatus:UpdateLabel("Farm Status: Moving to " .. zone.EnemyType .. " zone")
                    local tween = TeleportTo(zone.Position + Vector3.new(0, 10, 0))
                    if tween then
                        tween.Completed:Wait()
                        wait(1)
                        foundEnemyZone = true
                        break
                    end
                end
            end
            
            -- If we didn't find a specific zone, search in a spiral pattern
            if not foundEnemyZone then
                local currentPos = Character.HumanoidRootPart.Position
                local searchRadius = 50
                local searchAngles = {0, 90, 180, 270, 45, 135, 225, 315}
                
                for _, angle in pairs(searchAngles) do
                    if not QuestFarming then break end
                    
                    local radians = math.rad(angle)
                    local searchPos = currentPos + Vector3.new(
                        math.cos(radians) * searchRadius,
                        0,
                        math.sin(radians) * searchRadius
                    )
                    
                    FarmStatus:UpdateLabel("Farm Status: Searching area " .. angle .. "°")
                    local tween = TeleportTo(searchPos)
                    if tween then
                        tween.Completed:Wait()
                        wait(1)
                    end
                end
            }
        }
        
        -- Check if quest completed
        local hasQuest, questText = HasActiveQuest(questInfo.Mob)
        if not hasQuest and AutoQuest then
            FarmStatus:UpdateLabel("Farm Status: Quest completed, getting new quest")
            -- Wait a moment before getting new quest
            wait(1)
        end
        
        -- Add a small delay between cycles
        wait(0.5)
    end
}

-- Initialize character tracking
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
})

-- Real-time version checking and updating
coroutine.wrap(function()
    while wait(60) do -- Check every minute
        if QuestFarming then
            -- Real-time quest progress tracking
            if CurrentQuest then
                local hasQuest, questText = HasActiveQuest(CurrentQuest.Mob)
                if hasQuest then
                    QuestStatus:UpdateLabel("Quest Status: " .. questText)
                end
            end
            
            -- Update mob locations periodically
            if #MobLocations > 0 then
                MapEnemyLocations()
            end
        end
    end
end)()

-- Execute analysis when script loads
AnalyzeGameStructure()

print("Enhanced Blox Fruits Auto Farm loaded successfully!")
print("Analyze the game first, then start auto-farming")
