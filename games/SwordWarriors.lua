
if game.PlaceId ~= 12986400307 then return end

local LocalPlayer = game.Players.LocalPlayer
local create, func_RFM = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV3.lua"))()
local requestt = http_request or request or syn.request or HttpGet or HttpPost

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

-- setup

local ForScript = workspace:WaitForChild("ForScript")
local CurRemotes = ReplicatedStorage:WaitForChild("CurRemotes")
local MonsterEvent = CurRemotes:WaitForChild("MonsterEvent")

function canWalkToPart(targetPart)
  local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
  local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

  if not humanoid or not root then
      return false
  end

  local path = PathfindingService:CreatePath({
      AgentRadius = 2,
      AgentHeight = 5,
      AgentCanJump = true,
      AgentJumpHeight = 7,
      AgentMaxSlope = 45
  })

  path:ComputeAsync(root.Position, targetPart.Position)

  return path.Status == Enum.PathStatus.Success
end

function AtkMonster(MonsterFolder)
  local tablemon = MonsterFolder:GetChildren()
  if #tablemon == 0 then return end
  for _,mon in pairs(tablemon) do
    pcall(function()
      if mon:FindFirstChild("Hp") and mon:FindFirstChild("Hp").Value > 0 then
        mon.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0, (getgenv().RFManager["DistanceMon"] or 15) * -1)
        MonsterEvent:FireServer(
          "DamToMonster",
          mon,
          {
            damtype = "normal"
          }
        )
      end
    end)
  end
end

-- UI

local Window = create:Win("Plasma", 11390492777)

local AutoFarm = Window:Taps("AutoFarm")
local AutoFarm_1 = AutoFarm:newpage()

AutoFarm_1:Toggle("Kill Aura Story", getgenv().RFManager["KillAura"], false, function(toggle)
  if getgenv().RFManager["KillAura"] ~= toggle then
    getgenv().RFManager["KillAura"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["KillAura"] do
    task.wait()
    local NowMap
    for _,map in pairs(ForScript:WaitForChild("Monster"):WaitForChild("P" .. tostring(LocalPlayer.InMap.Value)):GetChildren()) do
      if map.Player:FindFirstChild(LocalPlayer.Name) then
        NowMap = map
        break
      end
    end
    if NowMap then
      local MonsterFolder = NowMap:FindFirstChild("Monster_")
      while getgenv().RFManager["KillAura"] and NowMap.Player:FindFirstChild(LocalPlayer.Name) do
        task.wait()
        AtkMonster(MonsterFolder)
      end
    end
  end
end)

AutoFarm_1:Toggle("Kill Aura Inf", getgenv().RFManager["KillAura_Inf"], false, function(toggle)
  if getgenv().RFManager["KillAura_Inf"] ~= toggle then
    getgenv().RFManager["KillAura_Inf"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["KillAura_Inf"] do
    task.wait()
    local NowMap
    for _,map in pairs(ForScript:WaitForChild("InfiniteMap"):GetChildren()) do
      if map.Player:FindFirstChild(LocalPlayer.Name) then
        NowMap = map
        break
      end
    end
    if NowMap then
      local MonsterFolder = NowMap:FindFirstChild("Monster_")
      while getgenv().RFManager["KillAura_Inf"] and NowMap.Player:FindFirstChild(LocalPlayer.Name) do
        task.wait()
        AtkMonster(MonsterFolder)
      end
    end
  end
end)

AutoFarm_1:Toggle("Kill Aura Drill", getgenv().RFManager["KillAura_Drill"], false, function(toggle)
  if getgenv().RFManager["KillAura_Drill"] ~= toggle then
    getgenv().RFManager["KillAura_Drill"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["KillAura_Drill"] do
    task.wait()
    local NowMap
    for _,map in pairs(ForScript:WaitForChild("DrilRaid"):GetChildren()) do
      if map.Player:FindFirstChild(LocalPlayer.Name) then
        NowMap = map
        break
      end
    end
    if NowMap then
      local MonsterFolder = NowMap:FindFirstChild("Monster_")
      while getgenv().RFManager["KillAura_Drill"] and NowMap.Player:FindFirstChild(LocalPlayer.Name) do
        task.wait()
        AtkMonster(MonsterFolder)
      end
    end
  end
end)


AutoFarm_1:Toggle("Kill Aura Memory", getgenv().RFManager["KillAura_Memory"], false, function(toggle)
  if getgenv().RFManager["KillAura_Memory"] ~= toggle then
    getgenv().RFManager["KillAura_Memory"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["KillAura_Memory"] do
    task.wait()
    local NowMap = ForScript:FindFirstChild("Skibi4")
    if NowMap then
      local MonsterFolder = NowMap:FindFirstChild("Monster_")
      while getgenv().RFManager["KillAura_Memory"] and NowMap.Player:FindFirstChild(LocalPlayer.Name) do
        task.wait()
        AtkMonster(MonsterFolder)
      end
    end
  end
end)


local AutoFarm_2 = AutoFarm:newpage()

AutoFarm_2:Toggle("Auto Walk", getgenv().RFManager["AutoWalk"], false, function(toggle)
  if getgenv().RFManager["AutoWalk"] ~= toggle then
    getgenv().RFManager["AutoWalk"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["AutoWalk"] do
    wait(1)
    local MovePoint = workspace.ForScript.MovePoint:FindFirstChild("MovePoint"..tostring(LocalPlayer.InMap.Value))
    if MovePoint and canWalkToPart(MovePoint) then
      LocalPlayer.Character.HumanoidRootPart.CFrame = MovePoint.CFrame
      wait(2)
    end
  end
end)

AutoFarm_2:Toggle("Auto Rebirth", getgenv().RFManager["AutoRebirth"], false, function(toggle)
  if getgenv().RFManager["AutoRebirth"] ~= toggle then
    getgenv().RFManager["AutoRebirth"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["AutoRebirth"] do
    wait(1)
    if LocalPlayer.PlayerGui.MainGui.MainFrame.MenuFrame.Rebirth.jindu.Text == "100%" then
      CurRemotes:WaitForChild("DataChange_Rebirth"):FireServer("rebirth")
    end
  end
end)

AutoFarm_2:Toggle("Auto Upgrade", getgenv().RFManager["AutoUpgrade"], false, function(toggle)
  if getgenv().RFManager["AutoUpgrade"] ~= toggle then
    getgenv().RFManager["AutoUpgrade"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["AutoUpgrade"] do
    local pointText = LocalPlayer.PlayerGui.MainGui.UpgradeFrame.Points.Text:gsub("Points:%s*", "")
    local point = tonumber(pointText)
    if point > 0 then
      local critText = LocalPlayer.PlayerGui.MainGui.UpgradeFrame.main.GCriticalHit.Plus.Rnum.Text:gsub("Lv.%s*", "")
      local critLv = tonumber(critText)
      local pointAdd = 250 - critLv
      if pointAdd > 0 then
        CurRemotes:WaitForChild("DataChange_Points"):FireServer(
          "ClickPoints",
          {
            Obj = "GCriticalHit",
            Points = pointAdd
          }
        )
        local newCritLv = 0
        repeat wait()
          critText = LocalPlayer.PlayerGui.MainGui.UpgradeFrame.main.GCriticalHit.Plus.Rnum.Text:gsub("Lv.%s*", "")
          newCritLv = tonumber(critText)
        until newCritLv == critLv + pointAdd
        wait(1)
      else
        CurRemotes:WaitForChild("DataChange_Points"):FireServer(
          "ClickPoints",
          {
            Obj = "GDamage",
            Points = point
          }
        )
      end
    end
    wait(1)
  end
end)

AutoFarm_2:Slider("Distance", false,false, 1, 50, getgenv().RFManager["DistanceMon"] or 15, 3, false, function(value)
  getgenv().RFManager["DistanceMon"] = tonumber(value)
  func_RFM:Store()
end)


AutoFarm_2:Toggle("Auto Skill", getgenv().RFManager["AutoSkill"], false, function(toggle)
  if getgenv().RFManager["AutoSkill"] ~= toggle then
    getgenv().RFManager["AutoSkill"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["AutoSkill"] do
    wait()
    local args = {
      "CheckSkillE",
      "CheckSkillQ",
      "CheckSkillF",
    }
    for _,skill in pairs(args) do
      CurRemotes:WaitForChild("SkillEvent"):FireServer(skill)
      wait()
    end
  end
end)


AutoFarm_2:Toggle("Auto Online Reward", getgenv().RFManager["OnlineReward"], true, function(toggle)
  if getgenv().RFManager["OnlineReward"] ~= toggle then
    getgenv().RFManager["OnlineReward"] = toggle
    func_RFM:Store()
  end

  while getgenv().RFManager["OnlineReward"] do
    for i = 1,6 do
      wait(.5)
      CurRemotes:WaitForChild("DataChange_Online"):FireServer("getonlinereward", i)
    end
    wait(60)
  end
end)


local Setting = Window:Taps("Settings")
local Setting_1 = Setting:newpage()

Setting_1:Button("Pet Menu", function()
  LocalPlayer.PlayerGui.MainGui.PetFrame.Visible = true
end)

Setting_1:Button("Redeem Code", function()
  local codes = {
    "HAPPYHALLOWEEN99",
    "HAPPYAUTUMN25",
    "THANKYOU485K",
    "THANKYOU475K",
    "ENDLESSYES",
    "EASTERGIFT2025",
    "HAPPYNEWYEAR",
    "KB83IHUS462CO",
    "WORLD13BACKROOMS",
  }
  for _, code in pairs(codes) do
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CDK"):FireServer("RedeemCode", code)
    wait(.5)
  end
end)



Setting_1:Button("Rejoin", function()
    TeleportService:Teleport(game.PlaceId)
end)

-- for _, fn in ipairs(getgc(true)) do
--   if typeof(fn) == "function" and islclosure(fn) and debug.getinfo(fn).name == "MonsterBeh_SetAttackObj" then
--     print("hooking internal MonsterBeh_SetAttackObj")
--     hookfunction(fn, function(...)
--       return
--     end)
--   end
-- end

-- Bypass Hack Check

local meta = getrawmetatable(game)
local old = meta.__namecall
setreadonly(meta, false)
meta.__namecall = newcclosure(function(Event, ...)
  local args = { ... }
  local Method = tostring(getnamecallmethod())
  if Method == "FireServer" then
    if tostring(Event) == "MonsterEvent" then
      if args[1] == "HackCheck" then
        wait(math.huge)
        return
      end
    end
  end
  return old(Event, ...)
end)
setreadonly(meta, true)


getgenv().Loaded = true