if game.PlaceId ~= 99521272836282 and game.PlaceId ~= 79787558257549 then return end

local CACHE = "guiV3_cache.lua"
local URL   = "https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV3.lua"

if not isfile(CACHE) then
    writefile(CACHE, game:HttpGet(URL))
end

local create, func_RFM = loadstring(readfile(CACHE))()

local LocalPlayer = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

local _Index_Module = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index")
local _leifstout_networker = _Index_Module:FindFirstChild("leifstout_networker@0.3.0") or _Index_Module:FindFirstChild("leifstout_networker@0.3.1")
local _remotes = _leifstout_networker:WaitForChild("networker"):WaitForChild("_remotes")

--  ====================================================

function fireButtonClick(button, mode)
    if not button then
        return
    end

    mode = mode or "click"

    if mode == "up" then
        local conns = getconnections(button.MouseButton1Up)
        if conns and #conns > 0 then
            for _, conn in ipairs(conns) do
                if conn.Function then
                    conn.Function()
                end
            end
            return
        end

        pcall(function()
            button.MouseButton1Up:Fire()
        end)
        return
    end

    if mode == "click" then
        local conns = getconnections(button.MouseButton1Click)
        if conns and #conns > 0 then
            for _, conn in ipairs(conns) do
                if conn.Function then
                    conn.Function()
                end
            end
            return
        end

        pcall(function()
            button.MouseButton1Click:Fire()
            return
        end)
    end

    if button.Activated then
        pcall(function()
            button.Activated:Fire()
        end)
    end
end

_G.printTable = function(tbl, indent, maxDepth)
    local txt = ""
    indent = indent or 0
    maxDepth = maxDepth or math.huge
    if indent > maxDepth then
        return string.rep("   ", indent) .. "... (depth limit)\n"
    end
    for i, v in pairs(tbl) do
        local prefix = string.rep("   ", indent)  
        local keyDisplay = tostring(i)
        if type(i) == "string" then
            keyDisplay = '"' .. i .. '"'
        elseif type(i) == "userdata" then
            keyDisplay = "Instance: " .. i.Name
        end
        if type(v) == "table" then
            txt = txt .. prefix .. "[" .. keyDisplay .. "] = {\n"
            txt = txt .. _G.printTable(v, indent + 1, maxDepth)
            txt = txt .. prefix .. "},\n"
        else
            local valueDisplay = tostring(v)
            if type(v) == "string" then
                valueDisplay = '"' .. v .. '"'
            end
            txt = txt .. prefix .. "[" .. keyDisplay .. "] = " .. valueDisplay .. ",\n"
        end
    end
    return txt
end

_G.printt = function(v, copyToClipboard, maxDepth)
    local txt = ""
    if type(v) == "table" then
        txt = txt .. "{\n"
        txt = txt .. _G.printTable(v, 1, maxDepth)
        txt = txt .. "}"
    else
        txt = txt .. tostring(v)
    end
    if copyToClipboard then
        setclipboard(txt)
    end
    print(txt)
    return txt
end

local modify_names = {"Base"}
local modify_map = {}
for _, info in pairs(require(game:GetService("ReplicatedStorage").Shared.Modules.Data.ChallengeData)) do 
    table.insert(modify_names, info["name"])
    modify_map[info["name"]] = info["id"]
end

local grouped_upgrade = {}
local upgrade_names = {}
for key, data in pairs(require(game:GetService("ReplicatedStorage").Shared.Modules.Data.UpgradeData)) do
    if type(data) == "function" then continue end
    local rarity = data["Rarity"]
    
    if rarity then
        grouped_upgrade[rarity] = grouped_upgrade[rarity] or {}

        grouped_upgrade[rarity][key] = {
            name = data["name"],
            description = data["description"],
        }
        upgrade_names[data["name"]] = true
    end
end

local stat_limit_table = {
    ["lifesteal"] = {
        ["name"] = {"Lifesteal"},
        ["default"] = 20,
        ["min"] = 0,
        ["max"] = 200
    },
    ["luck"] = {
        ["name"] = {"Luck"},
        ["default"] = 500,
        ["min"] = 0,
        ["max"] = 1200
    },
    ["size"] = {
        ["name"] = {"Size"},
        ["default"] = 10,
        ["min"] = 0,
        ["max"] = 10
    },
    ["criticalChance"] = {
        ["name"] = {"Crit Chance"},
        ["default"] = 100,
        ["min"] = 1,
        ["max"] = 100
    },
    ["damage"] = {
        ["name"] = {"Damage"},
        ["default"] = 20,
        ["min"] = 1,
        ["max"] = 50
    },
    ["attackSpeed"] = {
        ["name"] = {"Attack Speed", "Soul of Swiftness"},
        ["default"] = 400,
        ["min"] = 1,
        ["max"] = 1000
    },
    ["armor"] = {
        ["name"] = {"Armor"},
        ["default"] = 50,
        ["min"] = 0,
        ["max"] = 50
    },
}
local stat_limit_map = {}
getgenv().RFManager["Limit"] = getgenv().RFManager["Limit"] or {}
for ui_name, info in pairs(stat_limit_table) do
    for _, name_upgrade in pairs(info["name"]) do 
        stat_limit_map[name_upgrade] = ui_name
    end
    if getgenv().RFManager["Limit"][ui_name] == nil then 
        getgenv().RFManager["Limit"][ui_name] = info["default"]
    end
end

local weapond_data = {}
local weapon_names = {}
for _, data in pairs(require(game:GetService("ReplicatedStorage").Shared.Modules.Data.WeaponData)) do
    if type(data) == "function" then continue end
    local rarity = data["rarity"]
    
    if rarity then
        weapond_data[data["name"]] = {
            name = data["name"],
            description = data["description"],
        }
        weapon_names[data["name"]] = true
    end
end

repeat task.wait() until game:IsLoaded() and game.CoreGui:FindFirstChild("RobloxPromptGui")
local promptOverlay = game.CoreGui.RobloxPromptGui.promptOverlay
promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        task.wait(1)
        while true do
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end)
            task.wait(4)
            -- fallback to any server
            pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
            task.wait(3)
        end
    end
end)

-- =====================================================

local Window = create:Win("Plasma", 11390492777)

local AutoFarms = Window:Taps("AutoFarm")
local AutoFarm_1 = AutoFarms:newpage()

getgenv().RFManager["fly_speed"] = getgenv().RFManager["fly_speed"] or 15
getgenv().RFManager["fly_radian"] = getgenv().RFManager["fly_radian"] or 40
getgenv().RFManager["fly_pos_y"] = getgenv().RFManager["fly_pos_y"] or 15

local gravity = Workspace.Gravity
AutoFarm_1:Toggle("AutoFarm", getgenv().RFManager["AutoFarm"], false, function(toggle)
    if getgenv().RFManager["AutoFarm"] ~= toggle then
        getgenv().RFManager["AutoFarm"] = toggle
        func_RFM:Store()
    end

    if toggle then
        repeat wait() until LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Frames")
        
        if game.PlaceId == 99521272836282 then
            repeat wait() until LocalPlayer.PlayerGui.Frames:FindFirstChild("Pop-UpFrame")
            if LocalPlayer.PlayerGui.Frames["Pop-UpFrame"].Visible then
                fireButtonClick(LocalPlayer.PlayerGui.Frames["Pop-UpFrame"].Rejoin.Buttons.Continue)
                return
            end
            wait(5)
            if not getgenv().RFManager["AutoFarm"] then 
                return
            end
            local WorldSelection = _remotes:WaitForChild("WorldSelection"):WaitForChild("RemoteEvent")
            local QueueService = _remotes:WaitForChild("QueueService"):WaitForChild("RemoteEvent")

            QueueService:FireServer("PlayPressed")
            task.wait(0.2)
            WorldSelection:FireServer("SetWorld", getgenv().RFManager["Select_Map"])
            task.wait(0.2)
            WorldSelection:FireServer("SetDifficulty", getgenv().RFManager["Select_Mode"])
            task.wait(0.2)
            if getgenv().RFManager["Select_Modify"] ~= "Base" then
                WorldSelection:FireServer("SetChallenge", modify_map[getgenv().RFManager["Select_Modify"]])
                task.wait(0.2)
            end
            task.wait(1)
            QueueService:FireServer("PartySizeSelected", 1)
            task.wait(0.2)
            QueueService:FireServer("Created")
        else
            repeat wait() until LocalPlayer.PlayerGui.Frames:FindFirstChild("Upgrades")
            local Upgrades = LocalPlayer.PlayerGui.Frames.Upgrades
            local CreateModel = require(game:GetService("ReplicatedStorage").Shared.UI.HUD.WeaponBar).CreateModel
            local Data_Stat = debug.getupvalue(CreateModel, 1)

            local function choosePriorityFromList(choices, priority)
                if not choices or #choices == 0 or not priority then
                    return nil
                end

                -- tool
                if type(priority) == "table" and #priority > 0 then
                    for _, name in ipairs(priority) do
                        for _, choice in ipairs(choices) do
                            if choice.name == name then
                                return choice
                            end
                        end
                    end
                    return nil
                end

                -- upgrade
                if choices[1] and choices[1].rarity then
                    local r = choices[1].rarity
                    local list = priority and priority[r]
                    if type(list) == "table" then
                        for _, name in ipairs(list) do
                            for _, choice in ipairs(choices) do
                                local stat_key_name = stat_limit_map[choice.name]
                                if stat_key_name then
                                    local val = Data_Stat[stat_key_name]
                                    local my_val = getgenv().RFManager["Limit"][stat_key_name]
                                    if val >= my_val then
                                        print(string.format("Limit [%s] : %s/%d | Skip", choice.name, tostring(val), my_val))
                                        continue
                                    end
                                    print(string.format("Limit [%s] : %s/%d | Pass", choice.name, tostring(val), my_val))
                                end
                                if choice.name == name then
                                    return choice
                                end
                            end
                        end
                    end
                end

                return nil
            end

            local function chooseRandomSelection(choices)
                if #choices == 0 then
                    return nil
                end
                return choices[math.random(#choices)]
            end

            local function fireSelectionClick(selection)
                fireButtonClick(Upgrades.Holder["Selection"..selection.index], "up")
            end

            local function fly()
                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local Root = Character:WaitForChild("HumanoidRootPart")

                local startPos = Root.Position
                local angle = 0

                local x = game:GetService("RunService").Heartbeat:Connect(function(dt)
                    if not Root or not Root.Parent then
                        return
                    end

                    if getgenv()["fly_toggle"] and getgenv().RFManager["Fly"] then
                        Workspace.Gravity = 0

                        if not workspace.Enemies:FindFirstChild("BossYeti") then
                            local speed = getgenv().RFManager["fly_speed"]
                            local radius = getgenv().RFManager["fly_radian"]
                            local height = getgenv().RFManager["fly_pos_y"]

                            angle += speed / 10 * dt

                            local x = startPos.X + math.cos(angle) * radius
                            local z = startPos.Z + math.sin(angle) * radius
                            local y = startPos.Y + height

                            Root.CFrame = CFrame.new(x, y, z)
                        else
                            local BossYeti = workspace.Enemies:FindFirstChild("BossYeti")
                            local danger = false
                            local Mod_CF = CFrame.new(0, 40, 30)
                            -- if workspace.VFX:FindFirstChild("DangerArea") then
                            --     for i,v in pairs(workspace.VFX:GetChildren()) do 
                            --         if v.Name == "DangerArea" then 
                            --             local p = v.Part
                            --             local BossCF = BossYeti.HumanoidRootPart.CFrame
                            --             local target_TP = BossCF * Mod_CF
                            --             local target_Pos = Vector3.new(target_TP.X, target_TP.Y, target_TP.Z)
                            --             if (target_Pos - p.Position).Magnitude <= 150 then 
                            --                 danger = true
                            --                 break
                            --             end
                            --         end
                            --     end
                            -- end
                            if danger then 
                                local speed = 10
                                local radius = 100
                                local height = 35
    
                                angle += speed / 10 * dt
    
                                local monPos = BossYeti.HumanoidRootPart.Position
    
                                local x = monPos.X + math.cos(angle) * radius
                                local z = monPos.Z + math.sin(angle) * radius
                                local y = monPos.Y + height
                                
                                Root.CFrame = CFrame.new(x, y, z)
                            else
                                local BossCF = BossYeti.HumanoidRootPart.CFrame
                                Root.CFrame = BossCF * Mod_CF
                            end                            
                        end
                    else
                        Workspace.Gravity = gravity
                    end
                end)
                return x
            end

            local function select_upgrade()
                if Upgrades.Visible then
                    repeat task.wait() until Upgrades.RerollFrame.Visible
                    local choices = {}
                    for i = 1, 3 do
                        local sel = Upgrades.Holder["Selection"..i]
                        if sel and sel.Visible then
                            local rarityText = nil
                            pcall(function()
                                if sel.FrameHolder and sel.FrameHolder.TitleLabel then
                                    rarityText = sel.FrameHolder.TitleLabel.Text
                                end
                            end)
                            table.insert(choices, {
                                name = sel.ItemTitle and sel.ItemTitle.Text or "",
                                index = i,
                                rarity = rarityText,
                            })
                        end
                    end

                    local selected
                    local firstChoice = choices[1] and choices[1].name
                    if firstChoice and weapon_names[firstChoice] then
                        selected = choosePriorityFromList(choices, getgenv().RFManager["SelectedTools"] or {})
                        if selected then
                            print("Priority weapon selected:", selected.name, "at slot", selected.index)
                            fireSelectionClick(selected)
                        else
                            if Upgrades.RerollFrame.RerollButton.TextValue.Text ~= "REROLL" then
                                print("No preferred weapon found, rerolling...")
                                local args = {
                                    "RerollUpgrade"
                                }
                                _remotes:WaitForChild("GameService"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
                                wait(3)
                                return
                            else
                                selected = chooseRandomSelection(choices)
                                if selected then
                                    print("Random weapon selected:", selected.name, "at slot", selected.index)
                                    fireSelectionClick(selected)
                                else
                                    print("No weapon choice found")
                                end
                            end
                        end
                    else
                        selected = choosePriorityFromList(choices, getgenv().RFManager["SelectedUpgrades"])
                        if selected then
                            print("Priority upgrade selected:", selected.name, "at slot", selected.index)
                            fireSelectionClick(selected)
                        else
                            selected = chooseRandomSelection(choices)
                            if selected then
                                print("Random upgrade selected:", selected.name, "at slot", selected.index)
                                fireSelectionClick(selected)
                            else
                                print("No upgrade choice found")
                            end
                        end
                    end
                end
            end

            task.spawn(function()
                local x = fly()
                while getgenv().RFManager["AutoFarm"] do
                    wait(1)
                    select_upgrade()
                end
                x:Disconnect()
            end)

            task.spawn(function()
                repeat
                    task.wait(1)
                until LocalPlayer.PlayerGui.Frames.DeathFrame.Visible or not getgenv().RFManager["AutoFarm"]
                if getgenv().RFManager["AutoFarm"] then
                    if getgenv().RFManager["webhook_url"] ~= "" then
                        local webhook = func_RFM.Webhook:create(getgenv().RFManager["webhook_url"])
                        webhook:setTitle("Reward Report")
                        webhook:setColor(14177041)

                        for name, val in pairs(Data_Stat["rewards"]) do 
                            webhook:addField(name, tostring(val), true)
                        end

                        local function formatNumber(n)
                            local str = tostring(math.floor(n))
                            return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                        end
                        local damage_report = ""
                        for name, val in pairs(Data_Stat["weaponDamage"]) do
                            damage_report = damage_report .. name .. " : " .. tostring(formatNumber(val)) .. "\n"
                        end
                        webhook:setDescription(damage_report)
                        webhook:send()
                    end

                    wait(5)
                    fireButtonClick(LocalPlayer.PlayerGui.Frames.DeathFrame.Buttons.Continue)
                    wait(5)
                    fireButtonClick(LocalPlayer.PlayerGui.Frames.RoundEnd.Buttons.Again)
                end
            end)

            getgenv()["fly_toggle"] = true
            repeat
                task.wait(1)
            until not getgenv().RFManager["AutoFarm"] or workspace.Map:FindFirstChild("BossPortal") and workspace.Map.BossPortal:FindFirstChild("PortalPrompt") and workspace.Map.BossPortal.PortalPrompt.Enabled and workspace.Map.BossPortal:FindFirstChild("Portal Effect")
            getgenv()["fly_toggle"] = false

            if not getgenv().RFManager["AutoFarm"] then 
                return
            end
            wait(2)

            local tar = workspace.Map.BossPortal:FindFirstChild("Portal Effect").Position + Vector3.new(0,5,0)
            if getgenv().RFManager["Tp_Center"] then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(tar.X, tar.Y, tar.Z)
            else
                LocalPlayer.Character.Humanoid:MoveTo(tar)
            end
        end
    else
        getgenv()["fly_toggle"] = false
        Workspace.Gravity = gravity
    end
end)

local AutoFarm_2 = AutoFarms:newpage()
AutoFarm_2:Toggle("Fly", getgenv().RFManager["Fly"], false, function(toggle)
    if getgenv().RFManager["Fly"] ~= toggle then
        getgenv().RFManager["Fly"] = toggle
        func_RFM:Store()
    end
end)
AutoFarm_2:Toggle("Tp Center", getgenv().RFManager["Tp_Center"], false, function(toggle)
    if getgenv().RFManager["Tp_Center"] ~= toggle then
        getgenv().RFManager["Tp_Center"] = toggle
        func_RFM:Store()
    end
end)
AutoFarm_2:Slider("Fly Y", false,false, 1, 300, getgenv().RFManager["fly_pos_y"], 5, false, function(value)
    getgenv().RFManager["fly_pos_y"] = tonumber(value)
    func_RFM:Store()
end)
AutoFarm_2:Slider("Fly Speed", false,false, 1, 100, getgenv().RFManager["fly_speed"], 5, false, function(value)
    getgenv().RFManager["fly_speed"] = tonumber(value)
    func_RFM:Store()
end)
AutoFarm_2:Slider("Fly Radiant", false,false, 1, 300, getgenv().RFManager["fly_radian"], 5, false, function(value)
    getgenv().RFManager["fly_radian"] = tonumber(value)
    func_RFM:Store()
end)

local maps_list = {}
local map_data = require(game:GetService("ReplicatedStorage").Shared.Modules.Data.WaveData)
for map_name, map_info in pairs(map_data) do
    if not map_info["totalWaves"] then continue end
    table.insert(maps_list, map_name)
end
map_data = nil
map_name = nil
map_info = nil

getgenv().RFManager["Select_Map"] = getgenv().RFManager["Select_Map"] or "Frost Forest"
AutoFarm_1:Drop("Select Maps", getgenv().RFManager["Select_Map"], maps_list, function(selected)
    getgenv().RFManager["Select_Map"] = selected
    func_RFM:Store()
end, false)

getgenv().RFManager["Select_Mode"] = getgenv().RFManager["Select_Mode"] or "Normal"
AutoFarm_1:Drop("Select Mode", getgenv().RFManager["Select_Mode"], {"Normal", "Hard", "Nightmare"}, function(selected)
    getgenv().RFManager["Select_Mode"] = selected
    func_RFM:Store()
end, false)

getgenv().RFManager["Select_Modify"] = getgenv().RFManager["Select_Modify"] or "Base"
AutoFarm_1:Drop("Select Modify", getgenv().RFManager["Select_Modify"], modify_names, function(selected)
    getgenv().RFManager["Select_Modify"] = selected
    func_RFM:Store()
end, false)


local AutoFarm_3 = AutoFarms:newpage()
AutoFarm_3:Label("Limit")
for ui_name, info in pairs(stat_limit_table) do
    AutoFarm_3:Slider(ui_name, false,false, info["min"], info["max"], getgenv().RFManager["Limit"][ui_name], 1, false, function(value)
        getgenv().RFManager["Limit"][ui_name] = tonumber(value)
        func_RFM:Store()
    end)
end


local Functions = Window:Taps("Function")
local Function_1 = Functions:newpage()

for chest, ssss in pairs(require(game:GetService("ReplicatedStorage").Shared.Modules.Data.ChestData)) do
    if chest == "VoidChest" then continue end
    Function_1:Button("Buy " .. chest, function()
        local args = {
            "OpenMultipleChests",
            chest,
            100
        }
        _remotes:WaitForChild("ChestService"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end)
end
ssss = nil

Function_1:Button("Buy VoidChest", function()
    local args = {
        "PurchaseChest",
        "VoidChest",
        100
    }
    _remotes:WaitForChild("ChestService"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    wait(1)
    local args = {
        "OpenMultipleChests",
        "VoidChest",
        100
    }
    _remotes:WaitForChild("ChestService"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end)

local Cards = Window:Taps("Cards")

getgenv().RFManager["SelectedTools"] = getgenv().RFManager["SelectedTools"] or {
    "Ban Hammer",
    "Firestaff",
    "Missile",
    "Frost Walker"
}
local selected_tools = getgenv().RFManager["SelectedTools"]

local tools_list = {}
for _, info in pairs(weapond_data) do
    table.insert(tools_list, info.name)
end
table.sort(tools_list)

local ToolPage = Cards:newpage()
ToolPage:Label("Tool Order")

local tool_labels = {}
local function updateToolLabels(selected)
    for i, optionText in ipairs(selected) do
        local labelText = string.format("%d. %s", i, optionText)
        if tool_labels[i] then
            tool_labels[i]:SetText(labelText)
        else
            tool_labels[i] = ToolPage:Label(labelText, false)
        end
    end

    for i = #selected + 1, #tool_labels do
        if tool_labels[i] then
            if typeof(tool_labels[i].Destroy) == "function" then
                tool_labels[i]:Destroy()
            end
            tool_labels[i] = nil
        end
    end
end

ToolPage:MutiDrop("Select Tools", selected_tools, tools_list, function(selected)
    selected_tools = selected
    getgenv().RFManager["SelectedTools"] = selected_tools
    func_RFM:Store()
    print("Selected tools:", selected_tools)
    updateToolLabels(selected_tools)
end, false)

if #selected_tools > 0 then
    updateToolLabels(selected_tools)
end

getgenv().RFManager["SelectedUpgrades"] = getgenv().RFManager["SelectedUpgrades"] or {
    ["Epic"] = {
        [1] = "Luck",
        [2] = "Giant's Strength",
        [3] = "Soul of Swiftness",
        [4] = "Size",
        [5] = "Lifesteal",
        [6] = "Armor",
        [7] = "Attack Speed",
        [8] = "Damage",
        [9] = "Health",
        [10] = "Projectile Count",
        [11] = "Bolt"
    },
    ["Legendary"] = {
        [1] = "Multishot",
        [2] = "Power Trio",
        [3] = "Projectile Count",
        [4] = "Luck",
        [5] = "Size",
        [6] = "Damage",
        [7] = "Attack Speed",
        [8] = "Health"
    },
    ["Common"] = {
        [1] = "Luck",
        [2] = "Crit Chance",
        [3] = "Attack Speed",
        [4] = "Damage",
        [5] = "Health"
    },
    ["Rare"] = {
        [1] = "Stand Strong",
        [2] = "Perilous Fervor",
        [3] = "Demon Slayer",
        [4] = "Freeze",
        [5] = "Blaze",
        [6] = "Lifesteal",
        [7] = "Crit Chance",
        [8] = "Luck",
        [9] = "Armor",
        [10] = "Size",
        [11] = "Attack Speed",
        [12] = "Damage",
        [13] = "Health"
    }
}
local selected_upgrades = getgenv().RFManager["SelectedUpgrades"]

local Card_1 = Cards:newpage()
local page_rarity = {}
local page_rarity_labels = {}

local function updateRarityLabels(rarity, selected)
    local labels = page_rarity_labels[rarity]
    if not labels then
        return
    end

    for i, optionText in ipairs(selected) do
        local labelText = string.format("%d. %s", i, optionText)
        if labels[i] then
            labels[i]:SetText(labelText)
        else
            labels[i] = page_rarity[rarity]:Label(labelText, false)
        end
    end

    for i = #selected + 1, #labels do
        if labels[i] then
            if typeof(labels[i].Destroy) == "function" then
                labels[i]:Destroy()
            end
            labels[i] = nil
        end
    end
end

for rarity, data in pairs(grouped_upgrade) do
    local Card_temp = Cards:newpage()
    Card_temp:Label(rarity)
    page_rarity[rarity] = Card_temp
    page_rarity_labels[rarity] = {}
end

for rarity, data in pairs(grouped_upgrade) do
    local options = {}
    for key, info in pairs(data) do
        table.insert(options, info.name)
    end
    table.sort(options)

    local defaultSelection = selected_upgrades[rarity] or {}
    local labels = page_rarity_labels[rarity]
    Card_1:MutiDrop(rarity, defaultSelection, options, function(selected)
        selected_upgrades[rarity] = selected
        getgenv().RFManager["SelectedUpgrades"] = selected_upgrades
        func_RFM:Store()
        print(selected_upgrades)

        updateRarityLabels(rarity, selected)
    end)

    if #defaultSelection > 0 then
        updateRarityLabels(rarity, defaultSelection)
    end
end

Card_1:Button("Copy Config", function()
    local temp = {
        ["SelectedTools"] = getgenv().RFManager["SelectedTools"],
        ["SelectedUpgrades"] = getgenv().RFManager["SelectedUpgrades"]
    }
    local x = _G.printt(temp)
    setclipboard("getgenv().RFManager = " .. x)
end)

-- ==============================================================================

local Setting = Window:Taps("Settings")
local Setting_1 = Setting:newpage()

Setting_1:Button("Update UI", function()
  writefile(CACHE, game:HttpGet(URL))
end)

Setting_1:Button("Rejoin", function()
    TeleportService:Teleport(game.PlaceId)
end)

Setting_1:Toggle("Test", getgenv().RFManager["Test"], true, function(toggle)
  if getgenv().RFManager["Test"] ~= toggle then
    getgenv().RFManager["Test"] = toggle
    func_RFM:Store()
  end

  print(toggle)
end)

Setting_1:Slider("Walk Speed", false,false, 1, 30, 17, 5, false, function(value)
  -- LocalPlayer.Character.Humanoid.WalkSpeed = value
  print(value)
end)

Setting_1:Button("Send Webhook", function()
    local webhook = func_RFM.Webhook:create(getgenv().RFManager["webhook_url"])
    webhook:send()
end)

Setting_1:Drop("Select Build", "", {"Option 1", "Option 2", "Option 3"}, function(selected)
    print("Selected:", selected)
end, false)

getgenv().RFManager["webhook_url"] = getgenv().RFManager["webhook_url"] or ""
local Setting_2 = Setting:newpage()
Setting_2:TextBox("webhook", "url webhook discord", function(txt)
    if string.find(txt, "https://discord.com/api/webhooks/") then 
        getgenv().RFManager["webhook_url"] = txt
    end
end)

Setting_2:Toggle("No Render", getgenv().RFManager["Render"], false, function(toggle)
    if getgenv().RFManager["Render"] ~= toggle then
        getgenv().RFManager["Render"] = toggle
        func_RFM:Store()
    end

    game:GetService("RunService"):Set3dRenderingEnabled(not toggle)
end)

getgenv().Loaded = true