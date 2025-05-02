local create, func_RFM = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV2.lua"))()

-- ===========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===========================================================

local IsLobby = game.Workspace:FindFirstChild("Lobby")

local EventRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")

local GameWorld = require(ReplicatedStorage.Shared.Info.GameWorld.Levels)
local CraftingRecipes = require(ReplicatedStorage.Shared.Info.CraftingRecipes)

-- ===========================================================

function SelectMap()
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
                for Chapter, ChapterData in pairs(WorldData) do
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] then
                            EventRemote:FireServer("Create")
                            wait(1)
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
                            if not string.find(Chapter, "Ranger") then
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
                            return
                        end
                    end
                end
            end
        end
    end
end

-- ===========================================================

local Window = create:Win("Plasma", 11390492777)

local AutoFarm = Window:Taps("Auto Farm")

local AutoFarm_1 = AutoFarm:newpage()
AutoFarm_1:Toggle("Auto Craft", getgenv().RFManager["Auto Craft"], false, function(t)
    getgenv().RFManager["Auto Craft"] = t
    func_RFM:Store()
    if t and IsLobby then
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

local meta = getrawmetatable(game)
local old = meta.__namecall

if setreadonly then
    setreadonly(meta, false)
else
    make_writeable(meta, true)
end

local callMethod = getnamecallmethod or get_namecall_method
local newClosure = newcclosure or function(f)
    return f
end

meta.__namecall = newClosure(function(Event, ...)
    local cmethod = callMethod()
    local fmethod = (tostring(cmethod) == "Fire") or nil
    local arguments = {...}
    if fmethod and tostring(Event) == "AddColorToTable" then
        return
    end
    return old(Event, ...)
end)

if setreadonly then
    setreadonly(meta, true)
else
    make_writeable(meta, false)
end

getgenv().RFManager.Loaded = true
