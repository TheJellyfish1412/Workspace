local create, func_RFM = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV2.lua"))()

-- ===========================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===========================================================

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
                    totalReq[reqName] = (totalReq[reqName] or 0) + amount
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
    if t then
        SelectMap()
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




getgenv().RFManager.Loaded = true
