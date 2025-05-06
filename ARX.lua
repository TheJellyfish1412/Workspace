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
local GameMode = ReplicatedStorage.Values.Game.Gamemode.Value

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

    if getgenv().RFManager["Claim Hourly Egg"] then
        local Egg = workspace.Lobby.HourlyEgg.Egg
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Egg.Position + Vector3.new(8,0,8))
        wait(1)
        fireproximityprompt(Egg.ProximityPrompt)
    end

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
                local function temp(Chapter, ChapterData, IsRanger)
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] then
                            if IsRanger or Requirement[ItemData.Name] > Player_Data_Local.Items[ItemData.Name].Amount.Value then
                                if not IsRanger or not Player_Data_Local.RangerStage:FindFirstChild(Chapter) then
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
                    if temp(Chapter, ChapterData, true) then
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
        local ItemCheckSell = {
            [1] = "Onigiri",
            [2] = "French Fries",
            [3] = "Ramen",
            [4] = "Green Bean",
            [5] = "Rubber Fruit",
        }

        for _, item in pairs(ItemCheckSell) do
            local ItemData = Player_Data_Local.Items[item]
            if ItemData and ItemData.Amount.Value > 230 then
                ReplicatedStorage.Remote.Server.Items.Sell:FireServer(ItemData, {
                    ["Amount"] = ItemData.Amount.Value - 230
                })
            end
        end
        
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
                local function temp(Chapter, ChapterData, IsRanger)
                    for _, ItemData in pairs(ChapterData.Items) do
                        if Requirement[ItemData.Name] then
                            if IsRanger or Requirement[ItemData.Name] > Player_Data_Local.Items[ItemData.Name].Amount.Value then
                                if not IsRanger or not Player_Data_Local.RangerStage:FindFirstChild(Chapter) then
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
                    if temp(Chapter, ChapterData, true) then
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
        if GameMode == "Event" then
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
        if GameMode == "Challenge" then
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
AutoFarm_1:Toggle("Auto Craft", getgenv().RFManager["Auto Craft"], false, function(toggle)
    if getgenv().RFManager["Auto Craft"] ~= toggle then
        getgenv().RFManager["Auto Craft"] = toggle
        func_RFM:Store()
    end

    if toggle and IsLobby then
        print("Start Select Map")
        SelectMap()
    end
end)

AutoFarm_1:Toggle("Auto Easter", getgenv().RFManager["Auto Easter"], false, function(toggle)
    if getgenv().RFManager["Auto Easter"] ~= toggle then
        getgenv().RFManager["Auto Easter"] = toggle
        func_RFM:Store()
    end

    if toggle and IsLobby then
        print("Start Select Map")
        SelectMap()
    end
end)

AutoFarm_1:Toggle("Delay Easter", getgenv().RFManager["Delay Easter"], false, function(toggle)
    if getgenv().RFManager["Delay Easter"] ~= toggle then
        getgenv().RFManager["Delay Easter"] = toggle
        func_RFM:Store()
    end
end)

AutoFarm_1:Toggle("Auto Challenge", getgenv().RFManager["Auto Challenge"], false, function(toggle)
    if getgenv().RFManager["Auto Challenge"] ~= toggle then
        getgenv().RFManager["Auto Challenge"] = toggle
        func_RFM:Store()
    end
    if toggle and IsLobby then
        print("Start Select Map")
        SelectMap()
    end
end)

local AutoFarm_2 = AutoFarm:newpage()

AutoFarm_2:Toggle("Auto Upgrade", getgenv().RFManager["Auto Upgrade"], true, function(toggle)
    if getgenv().RFManager["Auto Upgrade"] ~= toggle then
        getgenv().RFManager["Auto Upgrade"] = toggle
        func_RFM:Store()
    end

    if not IsLobby then
        local HUD = LocalPlayer.PlayerGui:WaitForChild("HUD")
        local List_Unit = HUD.InGame.UnitsManager.Main.Main.ScrollingFrame
        while getgenv().RFManager["Auto Upgrade"] do
            local pass, err = pcall(function()
                local Unit_Table = LocalPlayer.UnitsFolder:GetChildren()
                table.sort(Unit_Table, function(a, b)
                    return (List_Unit[a.Name].LayoutOrder or 0) < (List_Unit[b.Name].LayoutOrder or 0)
                end)
                
                for _,FolderUnit in pairs(Unit_Table) do
                    local UnitData = Units[FolderUnit.Name]
                    local MaxLevel = #UnitData.Upgrade

                    while getgenv().RFManager["Auto Upgrade"] and FolderUnit.Upgrade_Folder.Level.Value <= MaxLevel do
                        task.wait(0.2)
                        pcall(function()
                            if (LocalPlayer.Yen.Value >= FolderUnit.Upgrade_Folder.Upgrade_Cost.Value) then
                                ReplicatedStorage.Remote.Server.Units.Upgrade:FireServer(FolderUnit)
                            end
                        end)
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


AutoFarm_2:Toggle("Auto Vote Start", getgenv().RFManager["VoteStart"], true, function(toggle)
    if getgenv().RFManager["VoteStart"] ~= toggle then
        getgenv().RFManager["VoteStart"] = toggle
        func_RFM:Store()
    end

    if not IsLobby then
        local timeout = os.time()
        repeat wait() until LocalPlayer.PlayerGui:FindFirstChild("LoadingDataUI") or os.time() - timeout > 10
        repeat wait() until not LocalPlayer.PlayerGui.LoadingDataUI.Enabled or os.time() - timeout > 10
        local voteStart = function(x)
            if x and getgenv().RFManager["VoteStart"] then
                ReplicatedStorage.Remote.Server.OnGame.Voting.VotePlaying:FireServer()
                TimeStart = os.time()
            end
        end
        ReplicatedStorage.Values.Game.VotePlaying.VoteEnabled.Changed:Connect(voteStart)
        voteStart(toggle)
    end
end)

AutoFarm_2:Toggle("Auto Vote Retry", getgenv().RFManager["VoteRetry"], false, function(toggle)
    if getgenv().RFManager["VoteRetry"] ~= toggle then
        getgenv().RFManager["VoteRetry"] = toggle
        func_RFM:Store()
    end
end)

AutoFarm_2:Toggle("Auto Vote Next", getgenv().RFManager["VoteNext"], false, function(toggle)
    if getgenv().RFManager["VoteNext"] ~= toggle then
        getgenv().RFManager["VoteNext"] = toggle
        func_RFM:Store()
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
    TempCraft:Toggle(name, getgenv().RFManager["Craft"][name], false, function(toggle)
        if getgenv().RFManager["Craft"][name] ~= toggle then
            getgenv().RFManager["Craft"][name] = toggle
            func_RFM:Store()
        end
    end)
end
n = nil
TempCraft = nil

-- ==============================


local Setting = Window:Taps("Setting")
local Setting_1 = Setting:newpage()

Setting_1:Toggle("Claim All Quest", getgenv().RFManager["Claim All Quest"], true, function(toggle)
    if getgenv().RFManager["Claim All Quest"] ~= toggle then
        getgenv().RFManager["Claim All Quest"] = toggle
        func_RFM:Store()
    end

    if toggle and IsLobby then
        ReplicatedStorage.Remote.Server.Gameplay.QuestEvent:FireServer("ClaimAll")
    end
end)

Setting_1:Toggle("Discord Notify", getgenv().RFManager["Discord Notify"], false, function(toggle)
    if toggle then
        if getgenv().RFManager["webhook"] then
            if getgenv().RFManager["Discord Notify"] ~= toggle then
                getgenv().RFManager["Discord Notify"] = toggle
                func_RFM:Store()
            end
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

Setting_1:Toggle("Claim Hourly Egg", getgenv().RFManager["Claim Hourly Egg"], true, function(toggle)
    if getgenv().RFManager["Claim Hourly Egg"] ~= toggle then
        getgenv().RFManager["Claim Hourly Egg"] = toggle
        func_RFM:Store()
    end

    if toggle and IsLobby then
        SelectMap()
    end
end)

Setting_1:Line()

Setting_1:Toggle("No Render3D", getgenv().RFManager["Render"], false, function(toggle)
    if getgenv().RFManager["Render"] ~= toggle then
        getgenv().RFManager["Render"] = toggle
        func_RFM:Store()
    end

    RunService:Set3dRenderingEnabled(not toggle)
end)

-- ==============================

if not IsLobby then
    -- spawn(function()
    --     game.Workspace.Visual.ChildAdded:Connect(function(child)
    --         if child:IsA("Model") and child:FindFirstChildOfClass("Highlight") then
    --             child:Destroy()
    --         end
    --     end)

    --     while true do
    --         local x = LocalPlayer.PlayerGui.Visual:FindFirstChild("Showcase_Units")
    --         if x then
    --             x:Destroy()
    --         end
    --         local y = LocalPlayer.PlayerGui:FindFirstChild("GameEndedAnimationUI")
    --         if y then
    --             y:Destroy()
    --         end
    --         wait(1)
    --     end
    -- end)

    local CheckReward = false
    local GameResult = {}
    ReplicatedStorage.Remote.Client.UI.GameEndedUI.OnClientEvent:Connect(function(...)
        local x = {...}
        if x[1] == "GameEnded_TextAnimation" then
            if x[2] == "Won" then
                GameResult["State"] = "`🏆`: Victory"
            else
                GameResult["State"] = "`❌`: Lose"
            end
            GameResult["Items"] = {}
        elseif x[1] == "Rewards - Items" then
            for _,item in pairs(LocalPlayer.RewardsShow:GetChildren()) do
                GameResult["Items"][item.Name] = item.Amount.Value
            end
        elseif x[1] == "Update - EndedScreen" then
            GameResult["Time"] = x[2]["TotalTime"]
            if getgenv().RFManager["Discord Notify"] then
                local userId = LocalPlayer.UserId
                local date = os.date("!*t") -- UTC
                local timestamp = string.format("%04d-%02d-%02dT%02d:%02d:%02dZ", date.year, date.month, date.day, date.hour, date.min, date.sec)
                
                local itemText = "```\n"
                for name, amount in pairs(GameResult["Items"]) do
                    itemText = itemText .. string.format("`%s` : x%d\n", name, amount)
                end
                itemText = itemText .. "```"

                if not PlayerImage then
                    local res = requestt({Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=48x48&format=Png&isCircular=false"})
                    local decoded = func_RFM:Decode(res.Body)
                    PlayerImage = decoded.data[1].imageUrl
                end
                
                local description = ""
                description = description .. GameResult["State"] .. "\n"
                description = description .. "`🕹️`Mode: " .. GameMode .. "\n"
                description = description .. "`🏜️`Stage: " .. ReplicatedStorage.Values.Game.Level.Value .. "\n"
                description = description .. "`🕒`Time: " .. GameResult["Time"] .. "s\n"
                description = description .. itemText .. "\n"
                local ItemDisplay = {
                    ["Egg Token"] = {
                        Emoji = "<:Egg_Capsule:1369190920116899922>",
                        Amount = Player_Data_Local.Data.Egg.Value,
                    },
                    -- ["Egg Capsule"] = {
                    --     Emoji = "<:Egg_Capsule:1369190920116899922>",
                    -- },
                    ["Stats Key"] = {
                        Emoji = "<:Stats_Key:1369190926957678612>",
                    },
                    ["Perfect Stats Key"] = {
                        Emoji = "<:Perfect_Stats_Key:1369190922469769286>",
                    },
                    ["Dr. Megga Punk"] = {
                        Emoji = "<:Megga_Punk:1369190929533239306>",
                    },
                    ["Ranger Crystal"] = {
                        Emoji = "<:Ranger_Crystal:1369190924726566912>",
                    },
                    ["Cursed Finger"] = {
                        Emoji = "<:Cursed_Finger:1369190917600317460>",
                    },
                }
                local fields = {}
                for name, data in pairs(ItemDisplay) do
                    local amount = data.Amount or Player_Data_Local.Items[name].Amount.Value
                    local field = {
                        name = data.Emoji .. " " .. name,
                        value = amount,
                        inline = true
                    }
                    table.insert(fields, field)
                end
                local body = {
                    embeds = {
                        {
                            title = func_RFM:GameName(),
                            description = description,
                            color = 16711680,
                            author = {
                                name = LocalPlayer.Name,
                                url = "https://www.roblox.com/users/" .. userId .. "/profile",
                                icon_url = PlayerImage
                            },
                            thumbnail = {
                                url = "https://tr.rbxcdn.com/180DAY-a3cb04972cc273b5299ed96fafee5f0c/256/256/Image/Webp/noFilter"
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

            -- =============================================

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

    -- local rewardsUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("RewardsUI")
    -- rewardsUI:GetPropertyChangedSignal("Enabled"):Connect(function()
    --     if rewardsUI.Enabled then
    --         repeat wait() until CheckReward
    --         CheckReward = false
    --         print("Game End. Start Select Map")
    --         if SelectMapEnded() then
    --             if getgenv().RFManager["VoteRetry"] and ReplicatedStorage.Values.Game.VoteRetry.VoteEnabled then
    --                 ReplicatedStorage.Remote.Server.OnGame.Voting.VoteRetry:FireServer()
    --                 TimeStart = os.time()
    --             elseif getgenv().RFManager["VoteNext"] and ReplicatedStorage.Values.Game.VoteNext.VoteEnabled then
    --                 ReplicatedStorage.Remote.Server.OnGame.Voting.VoteNext:FireServer()
    --             end
    --         end
    --     end
    -- end)
end


-- local ws = WebSocket.connect("ws://26.145.139.40:5001/RFManager/ws")

-- ws.OnMessage:Connect(function(message)
-- 	print("New msg")
-- 	print(message)
-- end)

-- ws.OnClose:Connect(function()
-- 	print("Closed")
-- end)

if (getgenv().RFManager["Delay Easter"]) and (not IsLobby) and (GameMode == "Event") then
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
