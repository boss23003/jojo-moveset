-- TSB_ScriptHub_v2.1.lua: Улучшенный хаб для 101 мувсета в The Strongest Battlegrounds
-- Архивный ID: X9-TSB-EXPANDED-RB
-- ВНИМАНИЕ: Используй в тени. Мегакорпы на подходе.
-- Создано: 30 мая 2025, 21:50 EEST

-- Служебные сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TSB_ScriptHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Градиентный фон
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
})
UIGradient.Parent = MainFrame

-- Неоновая рамка
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "TSB Script Hub v2.1"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- Статус-бар
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatusLabel.Text = "Статус: Ожидание..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame
local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 5)
StatusCorner.Parent = StatusLabel

-- Прокручиваемый список
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = ScrollingFrame

-- Список всех мувсетов (80 из TSB_ExpandedMovesetPack_v2.0 + 21 новый)
local movesets = {
    {name = "Goku", character = "Saitama", inspired = "Goku (Dragon Ball)", url = "https://raw.githubusercontent.com/DragonMasterX/TSB_GokuMoveset/main/Goku.lua"},
    {name = "Vegeta", character = "Garou", inspired = "Vegeta (Dragon Ball)", url = "https://raw.githubusercontent.com/SaiyanPride/TSB_VegetaMoveset/main/Vegeta.lua"},
    {name = "All Might", character = "Saitama", inspired = "All Might (My Hero Academia)", url = "https://raw.githubusercontent.com/HeroSymbol/TSB_AllMightMoveset/main/AllMight.lua"},
    {name = "Asta", character = "Atomic Samurai", inspired = "Asta (Black Clover)", url = "https://raw.githubusercontent.com/AntiMagicX/TSB_AstaMoveset/main/Asta.lua"},
    {name = "Yami", character = "Atomic Samurai", inspired = "Yami Sukehiro (Black Clover)", url = "https://raw.githubusercontent.com/DarknessCaptain/TSB_YamiMoveset/main/Yami.lua"},
    {name = "Escanor", character = "Saitama", inspired = "Escanor (Seven Deadly Sins)", url = "https://raw.githubusercontent.com/LionPride/TSB_EscanorMoveset/main/Escanor.lua"},
    {name = "Meliodas", character = "Garou", inspired = "Meliodas (Seven Deadly Sins)", url = "https://raw.githubusercontent.com/DemonKingX/TSB_MeliodasMoveset/main/Meliodas.lua"},
    {name = "Natsu", character = "Saitama", inspired = "Natsu Dragneel (Fairy Tail)", url = "https://raw.githubusercontent.com/FireDragonX/TSB_NatsuMoveset/main/Natsu.lua"},
    {name = "Gray", character = "Garou", inspired = "Gray Fullbuster (Fairy Tail)", url = "https://raw.githubusercontent.com/IceMageX/TSB_GrayMoveset/main/Gray.lua"},
    {name = "Erza", character = "Atomic Samurai", inspired = "Erza Scarlet (Fairy Tail)", url = "https://raw.githubusercontent.com/TitaniaX/TSB_ErzaMoveset/main/Erza.lua"},
    {name = "Deku", character = "Saitama", inspired = "Izuku Midoriya (My Hero Academia)", url = "https://raw.githubusercontent.com/OneForAllX/TSB_DekuMoveset/main/Deku.lua"},
    {name = "Todoroki", character = "Garou", inspired = "Shoto Todoroki (My Hero Academia)", url = "https://raw.githubusercontent.com/FireIceX/TSB_TodorokiMoveset/main/Todoroki.lua"},
    {name = "Dabi", character = "Atomic Samurai", inspired = "Dabi (My Hero Academia)", url = "https://raw.githubusercontent.com/BlueFlameX/TSB_DabiMoveset/main/Dabi.lua"},
    {name = "Gon", character = "Saitama", inspired = "Gon Freecss (Hunter x Hunter)", url = "https://raw.githubusercontent.com/HunterXHunter/TSB_GonMoveset/main/Gon.lua"},
    {name = "Hisoka", character = "Garou", inspired = "Hisoka Morow (Hunter x Hunter)", url = "https://raw.githubusercontent.com/MagicianX/TSB_HisokaMoveset/main/Hisoka.lua"},
    {name = "Meruem", character = "Atomic Samurai", inspired = "Meruem (Hunter x Hunter)", url = "https://raw.githubusercontent.com/ChimeraKing/TSB_MeruemMoveset/main/Meruem.lua"},
    {name = "Tanjiro", character = "Atomic Samurai", inspired = "Tanjiro Kamado (Demon Slayer)", url = "https://raw.githubusercontent.com/WaterBreath/TSB_TanjiroMoveset/main/Tanjiro.lua"},
    {name = "Zenitsu", character = "Garou", inspired = "Zenitsu Agatsuma (Demon Slayer)", url = "https://raw.githubusercontent.com/ThunderBreath/TSB_ZenitsuMoveset/main/Zenitsu.lua"},
    {name = "Inosuke", character = "Saitama", inspired = "Inosuke Hashibira (Demon Slayer)", url = "https://raw.githubusercontent.com/BeastBreath/TSB_InosukeMoveset/main/Inosuke.lua"},
    {name = "Muzan", character = "Atomic Samurai", inspired = "Muzan Kibutsuji (Demon Slayer)", url = "https://raw.githubusercontent.com/DemonLordX/TSB_MuzanMoveset/main/Muzan.lua"},
    {name = "Akaza", character = "Garou", inspired = "Akaza (Demon Slayer)", url = "https://raw.githubusercontent.com/UpperMoonX/TSB_AkazaMoveset/main/Akaza.lua"},
    {name = "Doma", character = "Atomic Samurai", inspired = "Doma (Demon Slayer)", url = "https://raw.githubusercontent.com/IceDemonX/TSB_DomaMoveset/main/Doma.lua"},
    {name = "Kokushibo", character = "Atomic Samurai", inspired = "Kokushibo (Demon Slayer)", url = "https://raw.githubusercontent.com/MoonBreath/TSB_KokushiboMoveset/main/Kokushibo.lua"},
    {name = "Yoriichi", character = "Atomic Samurai", inspired = "Yoriichi Tsugikuni (Demon Slayer)", url = "https://raw.githubusercontent.com/SunBreath/TSB_YoriichiMoveset/main/Yoriichi.lua"},
    {name = "Guts", character = "Atomic Samurai", inspired = "Guts (Berserk)", url = "https://raw.githubusercontent.com/BlackKnightX/TSB_GutsMoveset/main/Guts.lua"},
    {name = "Griffith", character = "Garou", inspired = "Griffith (Berserk)", url = "https://raw.githubusercontent.com/GodHandX/TSB_GriffithMoveset/main/Griffith.lua"},
    {name = "Joker", character = "Saitama", inspired = "Joker (DC Comics)", url = "https://raw.githubusercontent.com/ChaosClownX/TSB_JokerMoveset/main/Joker.lua"},
    {name = "Batman", character = "Garou", inspired = "Batman (DC Comics)", url = "https://raw.githubusercontent.com/DarkKnightX/TSB_BatmanMoveset/main/Batman.lua"},
    {name = "Superman", character = "Saitama", inspired = "Superman (DC Comics)", url = "https://raw.githubusercontent.com/ManOfSteelX/TSB_SupermanMoveset/main/Superman.lua"},
    {name = "Flash", character = "Garou", inspired = "The Flash (DC Comics)", url = "https://raw.githubusercontent.com/SpeedsterX/TSB_FlashMoveset/main/Flash.lua"},
    {name = "Thanos", character = "Saitama", inspired = "Thanos (Marvel Comics)", url = "https://raw.githubusercontent.com/TitanX/TSB_ThanosMoveset/main/Thanos.lua"},
    {name = "Iron Man", character = "Atomic Samurai", inspired = "Iron Man (Marvel Comics)", url = "https://raw.githubusercontent.com/StarkIndustriesX/TSB_IronManMoveset/main/IronMan.lua"},
    {name = "Thor", character = "Saitama", inspired = "Thor (Marvel Comics)", url = "https://raw.githubusercontent.com/GodOfThunderX/TSB_ThorMoveset/main/Thor.lua"},
    {name = "Hulk", character = "Garou", inspired = "Hulk (Marvel Comics)", url = "https://raw.githubusercontent.com/GreenGiantX/TSB_HulkMoveset/main/Hulk.lua"},
    {name = "Spider-Man", character = "Garou", inspired = "Spider-Man (Marvel Comics)", url = "https://raw.githubusercontent.com/WebSlingerX/TSB_SpiderManMoveset/main/SpiderMan.lua"},
    {name = "Wolverine", character = "Atomic Samurai", inspired = "Wolverine (Marvel Comics)", url = "https://raw.githubusercontent.com/AdamantiumX/TSB_WolverineMoveset/main/Wolverine.lua"},
    {name = "Deadpool", character = "Garou", inspired = "Deadpool (Marvel Comics)", url = "https://raw.githubusercontent.com/MercWithAMouthX/TSB_DeadpoolMoveset/main/Deadpool.lua"},
    {name = "Captain America", character = "Saitama", inspired = "Captain America (Marvel Comics)", url = "https://raw.githubusercontent.com/FirstAvengerX/TSB_CaptainAmericaMoveset/main/CaptainAmerica.lua"},
    {name = "Black Panther", character = "Garou", inspired = "Black Panther (Marvel Comics)", url = "https://raw.githubusercontent.com/WakandaForeverX/TSB_BlackPantherMoveset/main/BlackPanther.lua"},
    {name = "Doctor Strange", character = "Atomic Samurai", inspired = "Doctor Strange (Marvel Comics)", url = "https://raw.githubusercontent.com/SorcererSupremeX/TSB_DoctorStrangeMoveset/main/DoctorStrange.lua"},
    {name = "Luffy", character = "Saitama", inspired = "Monkey D. Luffy (One Piece)", url = "https://raw.githubusercontent.com/StrawHatX/TSB_LuffyMoveset/main/Luffy.lua"},
    {name = "Zoro", character = "Atomic Samurai", inspired = "Roronoa Zoro (One Piece)", url = "https://raw.githubusercontent.com/SwordMasterX/TSB_ZoroMoveset/main/Zoro.lua"},
    {name = "Sanji", character = "Garou", inspired = "Sanji (One Piece)", url = "https://raw.githubusercontent.com/BlackLegX/TSB_SanjiMoveset/main/Sanji.lua"},
    {name = "Naruto", character = "Saitama", inspired = "Naruto Uzumaki (Naruto)", url = "https://raw.githubusercontent.com/HokageX/TSB_NarutoMoveset/main/Naruto.lua"},
    {name = "Sasuke", character = "Atomic Samurai", inspired = "Sasuke Uchiha (Naruto)", url = "https://raw.githubusercontent.com/UchihaX/TSB_SasukeMoveset/main/Sasuke.lua"},
    {name = "Kakashi", character = "Garou", inspired = "Kakashi Hatake (Naruto)", url = "https://raw.githubusercontent.com/CopyNinjaX/TSB_KakashiMoveset/main/Kakashi.lua"},
    {name = "Ichigo", character = "Atomic Samurai", inspired = "Ichigo Kurosaki (Bleach)", url = "https://raw.githubusercontent.com/SoulReaperX/TSB_IchigoMoveset/main/Ichigo.lua"},
    {name = "Aizen", character = "Garou", inspired = "Sosuke Aizen (Bleach)", url = "https://raw.githubusercontent.com/HypnosisX/TSB_AizenMoveset/main/Aizen.lua"},
    {name = "Byakuya", character = "Atomic Samurai", inspired = "Byakuya Kuchiki (Bleach)", url = "https://raw.githubusercontent.com/SakuraX/TSB_ByakuyaMoveset/main/Byakuya.lua"},
    {name = "Saitama Serious", character = "Saitama", inspired = "Saitama (One Punch Man)", url = "https://raw.githubusercontent.com/SeriousPunchX/TSB_SaitamaSeriousMoveset/main/SaitamaSerious.lua"},
    {name = "Garou Cosmic", character = "Garou", inspired = "Cosmic Garou (One Punch Man)", url = "https://raw.githubusercontent.com/CosmicHunterX/TSB_GarouCosmicMoveset/main/GarouCosmic.lua"},
    {name = "Genos", character = "Atomic Samurai", inspired = "Genos (One Punch Man)", url = "https://raw.githubusercontent.com/CyborgX/TSB_GenosMoveset/main/Genos.lua"},
    {name = "Levi", character = "Atomic Samurai", inspired = "Levi Ackerman (Attack on Titan)", url = "https://raw.githubusercontent.com/AckermanX/TSB_LeviMoveset/main/Levi.lua"},
    {name = "Eren", character = "Saitama", inspired = "Eren Yeager (Attack on Titan)", url = "https://raw.githubusercontent.com/TitanX/TSB_ErenMoveset/main/Eren.lua"},
    {name = "Mikasa", character = "Garou", inspired = "Mikasa Ackerman (Attack on Titan)", url = "https://raw.githubusercontent.com/ScarletX/TSB_MikasaMoveset/main/Mikasa.lua"},
    {name = "Jotaro", character = "Saitama", inspired = "Jotaro Kujo (JoJo’s Bizarre Adventure)", url = "https://raw.githubusercontent.com/StandUserX/TSB_JotaroMoveset/main/Jotaro.lua"},
    {name = "Dio", character = "Garou", inspired = "Dio Brando (JoJo’s Bizarre Adventure)", url = "https://raw.githubusercontent.com/VampireX/TSB_DioMoveset/main/Dio.lua"},
    {name = "Giorno", character = "Atomic Samurai", inspired = "Giorno Giovanna (JoJo’s Bizarre Adventure)", url = "https://raw.githubusercontent.com/GoldenX/TSB_GiornoMoveset/main/Giorno.lua"},
    {name = "Alucard", character = "Garou", inspired = "Alucard (Hellsing)", url = "https://raw.githubusercontent.com/VampireKingX/TSB_AlucardMoveset/main/Alucard.lua"},
    {name = "Saber", character = "Atomic Samurai", inspired = "Saber (Fate/stay night)", url = "https://raw.githubusercontent.com/KingArthurX/TSB_SaberMoveset/main/Saber.lua"},
    {name = "Gilgamesh", character = "Saitama", inspired = "Gilgamesh (Fate/stay night)", url = "https://raw.githubusercontent.com/GoldenKingX/TSB_GilgameshMoveset/main/Gilgamesh.lua"},
    {name = "Archer", character = "Garou", inspired = "Archer (Fate/stay night)", url = "https://raw.githubusercontent.com/RedBowX/TSB_ArcherMoveset/main/Archer.lua"},
    {name = "Madara", character = "Saitama", inspired = "Madara Uchiha (Naruto)", url = "https://raw.githubusercontent.com/UchihaGodX/TSB_MadaraMoveset/main/Madara.lua"},
    {name = "Itachi", character = "Garou", inspired = "Itachi Uchiha (Naruto)", url = "https://raw.githubusercontent.com/CrowX/TSB_ItachiMoveset/main/Itachi.lua"},
    {name = "Pain", character = "Atomic Samurai", inspired = "Pain (Naruto)", url = "https://raw.githubusercontent.com/SixPathsX/TSB_PainMoveset/main/Pain.lua"},
    {name = "L", character = "Garou", inspired = "L (Death Note)", url = "https://raw.githubusercontent.com/GeniusX/TSB_LMoveset/main/L.lua"},
    {name = "Light", character = "Saitama", inspired = "Light Yagami (Death Note)", url = "https://raw.githubusercontent.com/KiraX/TSB_LightMoveset/main/Light.lua"},
    {name = "Ryuk", character = "Atomic Samurai", inspired = "Ryuk (Death Note)", url = "https://raw.githubusercontent.com/ShinigamiX/TSB_RyukMoveset/main/Ryuk.lua"},
    {name = "Killua", character = "Garou", inspired = "Killua Zoldyck (Hunter x Hunter)", url = "https://raw.githubusercontent.com/AssassinX/TSB_KilluaMoveset/main/Killua.lua"},
    {name = "Kurapika", character = "Atomic Samurai", inspired = "Kurapika (Hunter x Hunter)", url = "https://raw.githubusercontent.com/ChainMasterX/TSB_KurapikaMoveset/main/Kurapika.lua"},
    {name = "Sukuna", character = "Garou", inspired = "Ryomen Sukuna (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/CurseKingX/TSB_SukunaMoveset/main/Sukuna.lua"},
    {name = "Gojo", character = "Saitama", inspired = "Satoru Gojo (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/InfinityX/TSB_GojoMoveset/main/Gojo.lua"},
    {name = "Yuji", character = "Garou", inspired = "Yuji Itadori (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/DivergentX/TSB_YujiMoveset/main/Yuji.lua"},
    {name = "Megumi", character = "Atomic Samurai", inspired = "Megumi Fushiguro (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/ShadowX/TSB_MegumiMoveset/main/Megumi.lua"},
    {name = "Aang", character = "Saitama", inspired = "Aang (Avatar: The Last Airbender)", url = "https://raw.githubusercontent.com/AvatarX/TSB_AangMoveset/main/Aang.lua"},
    {name = "Zuko", character = "Garou", inspired = "Zuko (Avatar: The Last Airbender)", url = "https://raw.githubusercontent.com/FireLordX/TSB_ZukoMoveset/main/Zuko.lua"},
    {name = "Toph", character = "Atomic Samurai", inspired = "Toph Beifong (Avatar: The Last Airbender)", url = "https://raw.githubusercontent.com/EarthMasterX/TSB_TophMoveset/main/Toph.lua"},
    {name = "Geralt", character = "Atomic Samurai", inspired = "Geralt of Rivia (The Witcher)", url = "https://raw.githubusercontent.com/WhiteWolfX/TSB_GeraltMoveset/main/Geralt.lua"},
    {name = "Kratos", character = "Saitama", inspired = "Kratos (God of War)", url = "https://raw.githubusercontent.com/GodOfWarX/TSB_KratosMoveset/main/Kratos.lua"},
    {name = "Dante", character = "Garou", inspired = "Dante (Devil May Cry)", url = "https://raw.githubusercontent.com/DevilHunterX/TSB_DanteMoveset/main/Dante.lua"},
    -- Новые скрипты
    {name = "DIO Garou", character = "Hero Hunter", inspired = "Dio Brando (JoJo's Bizarre Adventure)", url = "https://raw.githubusercontent.com/Medley-Taboritsky/RobloxScripting/refs/heads/main/DIO_Garou_TSB"},
    {name = "Sonic Moveset", character = "Hero Hunter", inspired = "Sonic the Hedgehog", url = "https://raw.githubusercontent.com/Darker-TheDarkestGuy/Scripts/refs/heads/main/Sonic%20Moveset"},
    {name = "Jotaro Hub", character = "Hero Hunter", inspired = "Jotaro Kujo (JoJo's Bizarre Adventure)", url = "https://raw.githubusercontent.com/h8h88/hubfr/main/hubfr"},
    {name = "Arcaura", character = "Hero Hunter", inspired = "Arcaura (Original Character)", url = "https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/ARCAURA.lua"},
    {name = "Goku Moveset", character = "Hero Hunter", inspired = "Goku (Dragon Ball)", url = "https://rawscripts.net/raw/The-Strongest-Battlegrounds-Hero-hunter-moveset-into-OP-goku-moveset-17468"},
    {name = "Yuji Itadori", character = "Hero Hunter", inspired = "Yuji Itadori (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/kaledagoat/-kendjendjen/refs/heads/main/yuji%20itadori.lua"},
    {name = "Okarun", character = "Hero Hunter", inspired = "Okarun (Dandadan)", url = "https://raw.githubusercontent.com/Kenjihin69/Kenjihin69/refs/heads/main/Hero%20hunter%20to%20okarun%20fr"},
    {name = "Freddy Fazbear", character = "Hero Hunter", inspired = "Freddy Fazbear (Five Nights at Freddy's)", url = "https://pastebin.com/raw/Ft5psDmD"},
    {name = "Minos Prime v2", character = "Hero Hunter", inspired = "Minos Prime (Ultrakill)", url = "https://raw.githubusercontent.com/Bre5be123/Ha/refs/heads/main/Mino%20v2"},
    {name = "Suiryu", character = "Hero Hunter", inspired = "Suiryu (One Punch Man)", url = "https://gist.githubusercontent.com/kjremaker/b092496fc11a57e2c50477154176fa3e/raw/2148f00a036a179"},
    {name = "A-60 Moveset", character = "Destructive Cyborg", inspired = "A-60 (Doors)", url = "https://raw.githubusercontent.com/Darker-TheDarkestGuy/Scripts/refs/heads/main/A-60%20moveset"},
    {name = "Genos v3", character = "Destructive Cyborg", inspired = "Goku (Dragon Ball)", url = "https://raw.githubusercontent.com/Qaiddanial2904/Sea-blue-and-ai/refs/heads/main/Genos%20v3"},
    {name = "Toji Fushiguro", character = "Deadly Ninja", inspired = "Toji Fushiguro (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/Wi-sp/Limitless-legacy/refs/heads/main/GUI"},
    {name = "Volta", character = "Deadly Ninja", inspired = "Volta (Original Character)", url = "https://raw.githubusercontent.com/Reapvitalized/TSB/refs/heads/main/VOLTA.lua"},
    {name = "Apophenia", character = "Brutal Demon", inspired = "Apophenia (Original Character)", url = "https://raw.githubusercontent.com/Reapvitalized/TSB/main/APOPHENIA.lua"},
    {name = "Sukuna Atomic", character = "Blade Master", inspired = "Sukuna (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/zyrask/Nexus-Base/main/atomic-blademaster%20to%20sukuna"},
    {name = "Zoro Blade", character = "Blade Master", inspired = "Roronoa Zoro (One Piece)", url = "https://freenote.biz/raw/gtd4gdmszj"},
    {name = "Sukuna Beta", character = "Blade Master", inspired = "Sukuna V3 (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/berrizscript/Scripts_/refs/heads/main/Sukuna%20Beta"},
    {name = "Sans [REDACTED]", character = "Wild Psychic", inspired = "Sans (Undertale)", url = "https://raw.githubusercontent.com/Qaiddanial2904/ROBLOX-FREAKY-GOJO-REAL/refs/heads/main/SANS%20%5BREDACTED%5D"},
    {name = "Gojo Glacier", character = "Wild Psychic", inspired = "Gojo Satoru (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/xVicity/GLACIER/main/LATEST.lua"},
    {name = "Mahito", character = "Martial Artist", inspired = "Mahito (Jujutsu Kaisen)", url = "https://raw.githubusercontent.com/GreatestLime4K/mahitotsb/refs/heads/main/Protected_6381580361331378.txt"},
}

-- Функция создания кнопки мувсета
local function createMovesetButton(parent, moveset)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = moveset.name .. " (" .. moveset.character .. " - " .. moveset.inspired .. ")"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 14
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        StatusLabel.Text = "Статус: Загрузка " .. moveset.name .. "..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

        local success, response = pcall(function()
            return game:HttpGet(moveset.url)
        end)

        if not success then
            StatusLabel.Text = "Статус: Ошибка HTTP: " .. tostring(response)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            warn("[Injector] Ошибка HTTP для " .. moveset.name .. ": " .. tostring(response))
            return
        elseif not response or #response == 0 then
            StatusLabel.Text = "Статус: Пустой ответ от " .. moveset.name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            warn("[Injector] Пустой ответ от " .. moveset.url)
            return
        end

        local success, result = pcall(function()
            loadstring(response)()
        end)

        if success then
            StatusLabel.Text = "Статус: Успешно: " .. moveset.name
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            print("[Injector] Успешно инжектирован: " .. moveset.name)
        else
            StatusLabel.Text = "Статус: Ошибка выполнения: " .. tostring(result)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            warn("[Injector] Ошибка выполнения для " .. moveset.name .. ": " .. tostring(result))
        end
    end)

    return Button
end

-- Генерация кнопок для всех мувсетов
for _, moveset in pairs(movesets) do
    local Button = createMovesetButton(ScrollingFrame, moveset)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

-- Обработчик кнопки закрытия
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    print("[TSB_ScriptHub_v2.1] GUI закрыт.")
end)

print("[TSB_ScriptHub_v2.1] Активен. Выбери мувсет для инжекта.")
