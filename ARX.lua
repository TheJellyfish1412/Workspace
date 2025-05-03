local create, func_RFM = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV2.lua"))()

-- ===========================================================

local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===========================================================

local LocalPlayer = game.Players.LocalPlayer
local IsLobby = game.Workspace:FindFirstChild("Lobby")

local EventRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")

local GameWorld = require(ReplicatedStorage.Shared.Info.GameWorld.Levels)
local CraftingRecipes = require(ReplicatedStorage.Shared.Info.CraftingRecipes)

-- ===========================================================

local SelectingMap = false
function SelectMap()
    if not IsLobby then return end
    if SelectingMap then return end
    SelectingMap = true

    if getgenv().RFManager["Auto Craft"] then
        local CraftFound = false
        local Requirement = {}
        for ItemName, toggle in pairs(getgenv().RFManager["Craft"]) do
            if toggle then
                CraftFound = true
                for reqName, amount in pairs(CraftingRecipes[ItemName].Requirement) do
                    Requirement[reqName] = (Requirement[reqName] or 0) + amount
                end
            end
        end
        if CraftFound then
            for World, WorldData in pairs(GameWorld) do
                local function temp(Chapter, ChapterData)
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] and not ReplicatedStorage.Player_Data[LocalPlayer.Name].RangerStage:FindFirstChild(Chapter) then
                            EventRemote:FireServer("Create")
                            wait(1)
                            local IsRanger = string.find(Chapter, "Ranger")
                            if IsRanger then
                                EventRemote:FireServer(
                                    "Change-Mode",
                                    {
                                        Mode = "Ranger Stage"
                                    }
                                )
                                wait(1)
                            end
                            EventRemote:FireServer(
                                "Change-World",
                                {
                                    World = World
                                }
                            )
                            wait(1)
                            EventRemote:FireServer(
                                "Change-Chapter",
                                {
                                    Chapter = Chapter
                                }
                            )
                            wait(1)
                            if not IsRanger then
                                EventRemote:FireServer(
                                    "Change-Difficulty",
                                    {
                                        Difficulty = "Nightmare"
                                    }
                                )
                                wait(1)
                            end
                            EventRemote:FireServer("Submit")
                            wait(1)
                            EventRemote:FireServer("Start")

                            SelectingMap = false
                            return
                        end
                    end
                end

                local index_n = 1
                while WorldData[World.."_Chapter"..index_n] do
                    local Chapter = World.."_Chapter"..index_n
                    local ChapterData = WorldData[World.."_RangerStage"..index_n]
                    print("Check", Chapter)
                    temp(Chapter, ChapterData)
                    index_n = index_n + 1
                end
                index_n = 1
                while WorldData[World.."_RangerStage"..index_n] do
                    local Chapter = World.."_Chapter"..index_n
                    local ChapterData = WorldData[World.."_RangerStage"..index_n]
                    print("Check", Chapter)
                    temp(Chapter, ChapterData)
                    index_n = index_n + 1
                end
            end
        end
    end

    if getgenv().RFManager["Auto Easter"] then
        EventRemote:FireServer("Easter-Event")
        wait(1)
        EventRemote:FireServer("Start")
        SelectingMap = false
        return
    elseif getgenv().RFManager["Auto Challenge"] then
        EventRemote:FireServer(
            "Create",
            {
                ["CreateChallengeRoom"] = true
            }
        )
        wait(1)
        EventRemote:FireServer("Start")
        SelectingMap = false
        return
    end

    SelectingMap = false
end

local SelectingMapEnded = false
function SelectMapEnded()
    if IsLobby then return end
    if SelectingMapEnded then return end
    SelectingMapEnded = true

    if getgenv().RFManager["Auto Craft"] then
        local CraftFound = false
        local Requirement = {}
        for ItemName, toggle in pairs(getgenv().RFManager["Craft"]) do
            if toggle then
                CraftFound = true
                for reqName, amount in pairs(CraftingRecipes[ItemName].Requirement) do
                    Requirement[reqName] = (Requirement[reqName] or 0) + amount
                end
            end
        end
        if CraftFound then
            for World, WorldData in pairs(GameWorld) do
                local function temp(Chapter, ChapterData)
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] and not ReplicatedStorage.Player_Data[LocalPlayer.Name].RangerStage:FindFirstChild(Chapter) then
                            if ChapterData.Requirements.Required_Levels == ReplicatedStorage.Values.Game.Level.Value then
                                ReplicatedStorage.Remote.Server.OnGame.Voting.VoteNext:FireServer()
                            else
                                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                            end

                            SelectingMapEnded = false
                            return
                        end
                    end
                end

                local index_n = 1
                while WorldData[World.."_Chapter"..index_n] do
                    local Chapter = World.."_Chapter"..index_n
                    local ChapterData = WorldData[World.."_RangerStage"..index_n]
                    temp(Chapter, ChapterData)
                    index_n = index_n + 1
                end
                index_n = 1
                while WorldData[World.."_RangerStage"..index_n] do
                    local Chapter = World.."_Chapter"..index_n
                    local ChapterData = WorldData[World.."_RangerStage"..index_n]
                    temp(Chapter, ChapterData)
                    index_n = index_n + 1
                end
            end
        end
    end

    if getgenv().RFManager["Auto Easter"] then
        ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
        SelectingMapEnded = false
        return 
    elseif getgenv().RFManager["Auto Challenge"] then
        ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
        SelectingMapEnded = false
        return 
    end



    SelectingMapEnded = false
end

-- ===========================================================

local Window = create:Win("Plasma", 11390492777)

local AutoFarm = Window:Taps("Auto Farm")

local AutoFarm_1 = AutoFarm:newpage()
AutoFarm_1:Toggle("Auto Craft", getgenv().RFManager["Auto Craft"], false, function(t)
    getgenv().RFManager["Auto Craft"] = t
    func_RFM:Store()
    if t and IsLobby then
        print("Start Select Map")
        SelectMap()
    end
end)

AutoFarm_1:Toggle("Auto Easter", getgenv().RFManager["Auto Easter"], false, function(t)
    getgenv().RFManager["Auto Easter"] = t
    func_RFM:Store()
    if t and IsLobby then
        print("Start Select Map")
        SelectMap()
    end
end)

AutoFarm_1:Toggle("Auto Challenge", getgenv().RFManager["Auto Challenge"], false, function(t)
    getgenv().RFManager["Auto Challenge"] = t
    func_RFM:Store()
    if t and IsLobby then
        print("Start Select Map")
        SelectMap()
    end
end)

local AutoFarm_2 = AutoFarm:newpage()

AutoFarm_2:Toggle("Auto Vote Start", getgenv().RFManager["VoteStart"], true, function(t)
    getgenv().RFManager["VoteStart"] = t
    func_RFM:Store()

    if not IsLobby then
        local voteStart = function(x)
            if x and getgenv().RFManager["VoteStart"] then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VotePlaying:FireServer()
            end
        end
        ReplicatedStorage.Values.Game.VotePlaying.VoteEnabled.Changed:Connect(voteStart)
        voteStart(t)
    end
end)

AutoFarm_2:Toggle("Auto Vote Retry", getgenv().RFManager["VoteRetry"], false, function(t)
    getgenv().RFManager["VoteRetry"] = t
    func_RFM:Store()

    if not IsLobby then
        local voteRetry = function(x)
            if x and getgenv().RFManager["VoteRetry"] then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
            end
        end
        ReplicatedStorage.Values.Game.VoteRetry.VoteEnabled.Changed:Connect(voteRetry)
        voteRetry(t)
    end
end)

AutoFarm_2:Toggle("Auto Vote Next", getgenv().RFManager["VoteNext"], false, function(t)
    getgenv().RFManager["VoteNext"] = t
    func_RFM:Store()
    if not IsLobby then
        local voteNext = function(x)
            if x and getgenv().RFManager["VoteNext"] then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VoteNext:FireServer()
            end
        end
        ReplicatedStorage.Values.Game.VoteNext.VoteEnabled.Changed:Connect(voteNext)
        voteNext(t)
    end
end)


-- ===============================

local Craft = Window:Taps("Auto Craft")
if getgenv().RFManager["Craft"] == nil then
    getgenv().RFManager["Craft"] = {}
end
local n = 0
local TempCraft = Craft:newpage()
for name, data in pairs(CraftingRecipes) do
    n = n + 1
    if n > 8 then
        n = 1
        TempCraft = Craft:newpage()
    end
    TempCraft:Toggle(name, getgenv().RFManager["Craft"][name], false, function(t)
        getgenv().RFManager["Craft"][name] = t
        func_RFM:Store()
    end)
end
n = nil
TempCraft = nil

-- ==============================


local Setting = Window:Taps("Setting")
local Setting_1 = Setting:newpage()

Setting_1:Toggle("Claim All Quest", getgenv().RFManager["Claim All Quest"], true, function(mode)
    getgenv().RFManager["Claim All Quest"] = mode
    func_RFM:Store()

    if mode and IsLobby then
        ReplicatedStorage.Remote.Server.Gameplay.QuestEvent:FireServer("ClaimAll")
    end
end)

-- Setting_1:Toggle("Claim Hourly Egg", getgenv().RFManager["Claim Hourly Egg"], true, function(mode)
--     getgenv().RFManager["Claim Hourly Egg"] = mode
--     func_RFM:Store()

--     if mode and IsLobby then
--         ReplicatedStorage.Remote.Server.Gameplay.QuestEvent:FireServer("ClaimAll")
--     end
-- end)

Setting_1:Toggle("Render3D", getgenv().RFManager["Render"], true, function(mode)
    getgenv().RFManager["Render"] = mode
    func_RFM:Store()

    RunService:Set3dRenderingEnabled(mode)
end)

-- ==============================

if not IsLobby then
    ReplicatedStorage.Remote.Client.UI.GameEndedUI.OnClientEvent:Connect(function(...)
        local x = {...}
        if x[1] == "GameEnded_TextAnimation" then
            wait(2)
            print("Game End. Start Select Map")
            SelectMapEnded()
        end
    end)
end

-- local meta = getrawmetatable(game)
-- local old = meta.__namecall

-- if setreadonly then
--     setreadonly(meta, false)
-- else
--     make_writeable(meta, true)
-- end

-- local callMethod = getnamecallmethod or get_namecall_method
-- local newClosure = newcclosure or function(f)
--     return f
-- end

-- meta.__namecall = newClosure(function(Event, ...)
--     local cmethod = callMethod()
--     local fmethod = (tostring(cmethod) == "Fire") or nil
--     local arguments = {...}
--     if fmethod and tostring(Event) == "AddColorToTable" then
--         return
--     end
--     return old(Event, ...)
-- end)

-- if setreadonly then
--     setreadonly(meta, true)
-- else
--     make_writeable(meta, false)
-- end

getgenv().Loaded = true
