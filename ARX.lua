local create, func_RFM = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV2.lua"))()
local requestt = http_request or request or syn.request or HttpGet or HttpPost

local Window = create:Win("Plasma", 11390492777)

-- ===========================================================

local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===========================================================

local PlayerImage
local TimeStart = os.time()
local LocalPlayer = game.Players.LocalPlayer
local IsLobby = game.Workspace:FindFirstChild("Lobby")

local Player_Data_Local = ReplicatedStorage.Player_Data:FindFirstChild(LocalPlayer.Name)
while not Player_Data_Local do
    wait()
    Player_Data_Local = ReplicatedStorage.Player_Data:FindFirstChild(LocalPlayer.Name)
end

local EventRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")

local GameWorld = require(ReplicatedStorage.Shared.Info.GameWorld.Levels)
local CraftingRecipes = require(ReplicatedStorage.Shared.Info.CraftingRecipes)
local Units = require(ReplicatedStorage.Shared.Info.Units)

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
                task.wait()
                local function temp(Chapter, ChapterData)
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] then
                            if Requirement[ItemData.Name] > Player_Data_Local.Items[ItemData.Name].Amount.Value then
                                if not Player_Data_Local.RangerStage:FindFirstChild(Chapter) then
                                    Window:SetTextBottomLeft("Select " .. Chapter)
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
                                    return true
                                end
                            end
                        end
                    end
                end

                local index_n = 1
                while WorldData[World.."_RangerStage"..index_n] do
                    task.wait()
                    local Chapter = World.."_RangerStage"..index_n
                    Window:SetTextBottomLeft("Check " .. Chapter)
                    local ChapterData = WorldData[Chapter]
                    if temp(Chapter, ChapterData) then
                        return
                    end
                    index_n = index_n + 1
                end
                index_n = 1
                while WorldData[World.."_Chapter"..index_n] do
                    task.wait()
                    local Chapter = World.."_Chapter"..index_n
                    Window:SetTextBottomLeft("Check " .. Chapter)
                    local ChapterData = WorldData[Chapter]
                    if temp(Chapter, ChapterData) then
                        return
                    end
                    index_n = index_n + 1
                end
            end
        end
    end

    if getgenv().RFManager["Auto Easter"] then
        Window:SetTextBottomLeft("Select Easter Event")
        EventRemote:FireServer("Easter-Event")
        wait(1)
        EventRemote:FireServer("Start")
        SelectingMap = false
        return
    elseif getgenv().RFManager["Auto Challenge"] then
        Window:SetTextBottomLeft("Select Challenge")
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
                task.wait()
                local function temp(Chapter, ChapterData)
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] then
                            if Requirement[ItemData.Name] > Player_Data_Local.Items[ItemData.Name].Amount.Value then
                                if not Player_Data_Local.RangerStage:FindFirstChild(Chapter) then
                                    Window:SetTextBottomLeft("Select " .. Chapter)
                                    local NowChapter = ReplicatedStorage.Values.Game.Level.Value
                                    if WorldData[NowChapter] and WorldData[NowChapter].NextChapter == Chapter then
                                        ReplicatedStorage.Remote.Server.OnGame.Voting.VoteNext:FireServer()
                                    else
                                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                                    end
                                    
                                    SelectingMapEnded = false
                                    return true
                                end
                            end
                        end
                    end
                end

                local index_n = 1
                while WorldData[World.."_RangerStage"..index_n] do
                    task.wait()
                    local Chapter = World.."_RangerStage"..index_n
                    Window:SetTextBottomLeft("Check " .. Chapter)
                    local ChapterData = WorldData[Chapter]
                    if temp(Chapter, ChapterData) then
                        return
                    end
                    index_n = index_n + 1
                end
                index_n = 1
                while WorldData[World.."_Chapter"..index_n] do
                    task.wait()
                    local Chapter = World.."_Chapter"..index_n
                    Window:SetTextBottomLeft("Check " .. Chapter)
                    local ChapterData = WorldData[Chapter]
                    if temp(Chapter, ChapterData) then
                        return
                    end
                    index_n = index_n + 1
                end
            end
        end
    end

    if getgenv().RFManager["Auto Easter"] then
        if ReplicatedStorage.Values.Game.Gamemode.Value == "Event" then
            if ReplicatedStorage.Values.Game.VoteRetry.VoteEnabled then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
                TimeStart = os.time()
            end
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
        SelectingMapEnded = false
        return 
    elseif getgenv().RFManager["Auto Challenge"] then
        if ReplicatedStorage.Values.Game.Gamemode.Value == "Challenge" then
            if ReplicatedStorage.Values.Game.VoteRetry.VoteEnabled then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
                TimeStart = os.time()
            end
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
        SelectingMapEnded = false
        return 
    end

    SelectingMapEnded = false
    return true
end

-- ===========================================================

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

AutoFarm_1:Toggle("Delay Easter", getgenv().RFManager["Delay Easter"], false, function(t)
    getgenv().RFManager["Delay Easter"] = t
    func_RFM:Store()
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

AutoFarm_2:Toggle("Auto Upgrade", getgenv().RFManager["Auto Upgrade"], true, function(t)
    getgenv().RFManager["Auto Upgrade"] = t
    func_RFM:Store()

    if not IsLobby then
        while getgenv().RFManager["Auto Upgrade"] do
            local pass, err = pcall(function()
                for _,FolderUnit in pairs(LocalPlayer.UnitsFolder:GetChildren()) do
                    local UnitData = Units[FolderUnit.Name]
                    local MaxLevel = #UnitData.Upgrade

                    while getgenv().RFManager["Auto Upgrade"] and FolderUnit.Upgrade_Folder.Level.Value <= MaxLevel do
                        task.wait(0.2)
                        if (LocalPlayer.Yen.Value >= UnitData.Upgrade[FolderUnit.Upgrade_Folder.Level.Value+1].Cost) then
                            ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(FolderUnit)
                        end
                    end
                end
            end)
            -- if not pass then
            --     print(err)
            -- end
            task.wait(0.2)
        end
    end
end)

AutoFarm_2:Toggle("Auto Vote Start", getgenv().RFManager["VoteStart"], true, function(t)
    getgenv().RFManager["VoteStart"] = t
    func_RFM:Store()

    if not IsLobby then
        local voteStart = function(x)
            if x and getgenv().RFManager["VoteStart"] then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VotePlaying:FireServer()
                TimeStart = os.time()
            end
        end
        ReplicatedStorage.Values.Game.VotePlaying.VoteEnabled.Changed:Connect(voteStart)
        voteStart(t)
    end
end)

AutoFarm_2:Toggle("Auto Vote Retry", getgenv().RFManager["VoteRetry"], false, function(t)
    getgenv().RFManager["VoteRetry"] = t
    func_RFM:Store()
end)

AutoFarm_2:Toggle("Auto Vote Next", getgenv().RFManager["VoteNext"], false, function(t)
    getgenv().RFManager["VoteNext"] = t
    func_RFM:Store()
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

Setting_1:Toggle("Discord Notify", getgenv().RFManager["Discord Notify"], false, function(mode)
    if mode then
        if getgenv().RFManager["webhook"] then
            getgenv().RFManager["Discord Notify"] = mode
            func_RFM:Store()
        else
            create:Notify("Discord Notify Error", "Webhook Not Found", 2)
        end
    end
end)

Setting_1:TextBox("Webhook", "place webhook", function(url)
    if string.find(url, "https://discord.com/api/webhooks/") then
        getgenv().RFManager["webhook"] = url
        func_RFM:Store()
    else
        create:Notify("Webhook Error", "Link Invalid", 2)
    end
end)

-- Setting_1:Toggle("Claim Hourly Egg", getgenv().RFManager["Claim Hourly Egg"], true, function(mode)
--     getgenv().RFManager["Claim Hourly Egg"] = mode
--     func_RFM:Store()

--     if mode and IsLobby then
--         ReplicatedStorage.Remote.Server.Gameplay.QuestEvent:FireServer("ClaimAll")
--     end
-- end)

Setting_1:Line()

Setting_1:Toggle("No Render3D", getgenv().RFManager["Render"], false, function(mode)
    getgenv().RFManager["Render"] = mode
    func_RFM:Store()

    RunService:Set3dRenderingEnabled(not mode)
end)

-- ==============================

if not IsLobby then
    LocalPlayer.PlayerGui.Visual.ChildAdded:Connect(function(ui)
        if ui.Name == "Showcase_Units" then
            ui:Destroy()
        end
    end)

    local CheckReward = false
    local GameResult = {}
    ReplicatedStorage.Remote.Client.UI.GameEndedUI.OnClientEvent:Connect(function(...)
        local x = {...}
        if x[1] == "GameEnded_TextAnimation" then
            GameResult["State"] = x[2]
        elseif x[1] == "Rewards - Items" then
            GameResult["Items"] = {}
            for _,item in pairs(LocalPlayer.RewardsShow:GetChildren()) do
                GameResult["Items"][item.Name] = item.Amount.Value
            end
        elseif x[1] == "Update - EndedScreen" then
            GameResult["Time"] = x[2]["TotalTime"]
            if getgenv().RFManager["Discord Notify"] then
                local userId = LocalPlayer.UserId
                local date = os.date("!*t") -- UTC
                local timestamp = string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", date.year, date.month, date.day, date.hour, date.min, date.sec)
                
                local fields = {
                    {
                        name = "Status",
                        value = GameResult["State"],
                        inline = true
                    },
                    {
                        name = "Mode",
                        value = ReplicatedStorage.Values.Game.Gamemode.Value,
                        inline = true
                    },
                    {
                        name = "Time",
                        value = GameResult["Time"] .. "s",
                        inline = true
                    }
                }
                for name, amount in pairs(GameResult["Items"]) do
                    table.insert(fields, {
                        name = name,
                        value = "x"..amount
                    })
                end

                if not PlayerImage then
                    local res = requestt({Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=48x48&format=Png&isCircular=false"})
                    local decoded = func_RFM:Decode(res.Body)
                    PlayerImage = decoded.data[1].imageUrl
                end
                
                local body = {
                    embeds = {
                        {
                            title = "Game Result",
                            color = 65280,
                            author = {
                                name = LocalPlayer.Name,
                                url = "https://www.roblox.com/users/" .. userId .. "/profile",
                                icon_url = PlayerImage
                            },
                            fields = fields,
                            timestamp = timestamp
                        }
                    }
                }
                requestt({
                    Url = getgenv().RFManager["webhook"],
                    Method = "POST",
                    Headers = {
                        ["content-type"] = "application/json",
                    },
                    Body = func_RFM:Encode(body)
                })
            end
            GameResult = {}
            CheckReward = true
        end
    end)

    LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RewardsUI"):GetPropertyChangedSignal("Enabled"):Connect(function()
        if rewardsUI.Enabled then
            repeat wait() until CheckReward
            CheckReward = false
            print("Game End. Start Select Map")
            if SelectMapEnded() then
                if getgenv().RFManager["VoteRetry"] and ReplicatedStorage.Values.Game.VoteRetry.VoteEnabled then
                    ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
                    TimeStart = os.time()
                elseif getgenv().RFManager["VoteNext"] and ReplicatedStorage.Values.Game.VoteNext.VoteEnabled then
                    ReplicatedStorage.Remote.Server.OnGame.Voting.VoteNext:FireServer()
                end
            end
        end
    end)
end


-- local ws = WebSocket.connect("ws://26.145.139.40:5001/RFManager/ws")

-- ws.OnMessage:Connect(function(message)
-- 	print("New msg")
-- 	print(message)
-- end)

-- ws.OnClose:Connect(function()
-- 	print("Closed")
-- end)

if (getgenv().RFManager["Delay Easter"]) and (not IsLobby) and (ReplicatedStorage.Values.Game.Gamemode.Value == "Event") then
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
        local fmethod = (tostring(cmethod) == "FireServer") or nil
        local arguments = {...}
        if fmethod and tostring(Event) == "Deployment" and os.time() - TimeStart <= 39 then
            return
        end
        return old(Event, ...)
    end)

    if setreadonly then
        setreadonly(meta, true)
    else
        make_writeable(meta, false)
    end
end

getgenv().Loaded = true
