if game.PlaceId == 17850641257 or game.PlaceId == 17850769550 then

local create, func_RFM = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV3.lua"))()
local requestt = http_request or request or syn.request or HttpGet or HttpPost

local Window = create:Win("Plasma", 11390492777)

-- ===========================================================

local IsLobby = game.PlaceId == 17850641257
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

local UnitDataLocal = {}
if not IsLobby then
  local UnitsData = require(ReplicatedStorage.Modules.UnitsData)
  for i=1,3 do
    local slot = LocalPlayer.CharValue["Slot"..i]
    local unitName = slot.Units.Value
    if unitName ~= "" then
      local data = UnitsData[unitName]
      local SkillStore = {}
      for n = 1,4 do
        local skill = "Skill" .. n
        local skillData = data[skill] 
        if skillData then
          SkillStore[skill] = skillData
        else
          break
        end
      end
      UnitDataLocal[unitName] = SkillStore
    end
  end
end

-- ===========================================================

local function isOutsideHitbox(posXZ, hitbox)
	local worldPos = Vector3.new(posXZ.X, hitbox.Position.Y, posXZ.Z)
	local relative = hitbox.CFrame:PointToObjectSpace(worldPos)
	local halfX = hitbox.Size.X / 2
	local halfZ = hitbox.Size.Z / 2
	return math.abs(relative.X) > halfX or math.abs(relative.Z) > halfZ
end

local function isSafe(posXZ)
	for _, hitbox in workspace.PartEffect:GetChildren() do
    -- pcall(function()
      if hitbox.Name == "Hitbox1" and hitbox.Parent then
        if not isOutsideHitbox(posXZ, hitbox) then
          return false
        end
      end
    -- end)
	end
	return true
end

local function spiralSearch(targetPosition, maxRadius, step)
	local directions = {
		Vector2.new(1, 0),   -- ขวา
		Vector2.new(0, 1),   -- ลง
		Vector2.new(-1, 0),  -- ซ้าย
		Vector2.new(0, -1),  -- ขึ้น
	}

	local x, z = 0, 0
	local dirIndex = 1
	local stepsTaken = 0
	local segmentLength = 1
	local segmentPassed = 0

	while math.max(math.abs(x), math.abs(z)) * step <= maxRadius do
    task.wait()
		local checkPos = CFrame.new(
			targetPosition.X + x * step,
			targetPosition.Y,
			targetPosition.Z + z * step
		)

		if isSafe(checkPos) then
			return checkPos
		end

		local dir = directions[dirIndex]
		x = x + dir.X
		z = z + dir.Z
		stepsTaken = stepsTaken + 1
		segmentPassed = segmentPassed + 1

		if segmentPassed >= segmentLength then
			dirIndex = dirIndex % 4 + 1
			segmentPassed = 0

			if dirIndex == 1 or dirIndex == 3 then
				segmentLength = segmentLength + 1
			end
		end
	end

	return nil
end

function Body_Noclip()
  local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
  if not HumanoidRootPart:FindFirstChild("Body Noclip") then
    local Body_Noclip = Instance.new("BodyVelocity")
    Body_Noclip.Name = "Body Noclip"
    Body_Noclip.Velocity = Vector3.new()
    Body_Noclip.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    Body_Noclip.Parent = HumanoidRootPart
    return Body_Noclip
  end
end

local function moveTo(cframe, lookat)
  Body_Noclip()
  local speed = getgenv().RFManager["Tween Speed"] or 75
  local HRP = LocalPlayer.Character.HumanoidRootPart
  local targetPos = Vector3.new(cframe.X, cframe.Y, cframe.Z)
  local distance = (HRP.Position - targetPos).Magnitude
  if lookat then
    cframe = CFrame.new(targetPos, lookat)
  end
  if distance > 2000 then
    return
  elseif distance > 500 then
    speed = speed / 3
  elseif distance > 250 then
    speed = speed * 2 / 3
  end
  local tween = TweenService:Create(
    HRP,
    TweenInfo.new(distance/speed, Enum.EasingStyle.Linear),
    {
      CFrame = cframe * CFrame.new(3.16,-3,0)
    }
  )
  tween:Play()
  return tween
  -- if distance < 80 then
  --   HRP.CFrame = cframe
  -- end
    
  --   tween.Completed:Wait()
  -- end
end

if not IsLobby then
  for i, v in pairs(getgc(true)) do
    if typeof(v) == "function" and islclosure(v) then
      local info = debug.getinfo(v)
      if info.name == "Combat" then
        _G.combat = v
        break
      end
    end
  end
end

local followPart = Instance.new("Part")
followPart.Size = Vector3.new(3,2,3)
followPart.Anchored = true
followPart.Transparency = 1
followPart.Parent = workspace
-- ===========================================================

local AutoFarm = Window:Taps("Auto Farm")

local AutoFarm_1 = AutoFarm:newpage()

AutoFarm_1:Toggle("Auto Mob", getgenv().RFManager["Auto Mob"], false, function(toggle)
  if getgenv().RFManager["Auto Mob"] ~= toggle then
    getgenv().RFManager["Auto Mob"] = toggle
    func_RFM:Store()
  end
  if IsLobby then return end

  if toggle then
    while getgenv().RFManager["Auto Mob"] do
      task.wait()
      local Mob = workspace.Enemy.Mob
      for _,mob in pairs(Mob:GetChildren()) do
        if getgenv().RFManager["Auto Mob"] and mob.Parent == Mob and mob:FindFirstChild("RealPos") then
          -- Camera.CameraSubject = mob.Head
          local tempVec = mob.HumanoidRootPart.Position
          local tween = moveTo(CFrame.new(tempVec.X, tempVec.Y, tempVec.Z))
          if tween then
            tween.Completed:Wait()
          end
          spawn(function()
            while getgenv().RFManager["Auto Mob"] and mob.Parent == Mob do
              task.wait()
              pcall(function()
                -- for unit, UnitData in pairs(UnitDataLocal) do
                local slot = LocalPlayer.CharValue["Slot" .. LocalPlayer.Character.Onslot.Value]
                local unit = slot.Units.Value
                local UnitData = UnitDataLocal[unit]
                  local selectSkill
                  for _,skill in pairs(getgenv().RFManager["Skills"]) do
                    local SkillData = UnitData[skill]
                    if not LocalPlayer.Character.Cooldow:FindFirstChild(unit.."/"..skill) then
                      if LocalPlayer.Character.Mana.Value >= SkillData.Mana then
                        selectSkill = {
                          skill,
                          SkillData.HonIdTime
                        }
                        break
                      end
                    end
                  end
                  if selectSkill then
                    local mobPos = mob.HumanoidRootPart.Position
                    if mobPos.Y < -50 then
                      return
                    end
                    if selectSkill[2] == 0 then
                      ReplicatedStorage.Events.Skill:FireServer(
                        selectSkill[1],
                        LocalPlayer.Character.HumanoidRootPart.CFrame,
                        mobPos,
                        "OnSkill"
                      )
                    else
                      ReplicatedStorage.Events.Skill:FireServer(
                        selectSkill[1],
                        LocalPlayer.Character.HumanoidRootPart.CFrame,
                        mob.HumanoidRootPart.Position,
                        "OnHold"
                      )
                      task.wait(selectSkill[2])
                      ReplicatedStorage.Events.Skill:FireServer(
                        selectSkill[1],
                        LocalPlayer.Character.HumanoidRootPart.CFrame,
                        mob.HumanoidRootPart.Position,
                        "EndHold"
                      )
                    end
                  else
                    _G.combat()
                  end
                -- end
              end)
            end
          end)
          while getgenv().RFManager["Auto Mob"] and mob.Parent == Mob do
            task.wait()
            pcall(function()
              local posTP
              local monCF = mob.HumanoidRootPart.CFrame
              local Y = monCF.Y - (mob.HumanoidRootPart.Size.Y)
              -- Camera.CameraSubject = mob.Head
              if false and workspace.PartEffect:FindFirstChild("Hitbox1") then
                local temp = spiralSearch(Vector3.new(monCF.X, monCF.Y, monCF.Z), 500, 10)
                if temp then
                  posTP = temp
                else
                  return
                end
              else
                posTP = monCF * CFrame.new(0, 0, getgenv().RFManager["Distance"] or 10)
              end
              moveTo(posTP, mob.HumanoidRootPart.Position)
            end)
          end
        end
      end
      wait(1)
    end
  else
    -- Camera.CameraSubject = LocalPlayer.Character.Head
    local bdnp = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Body Noclip")
    if bdnp then
      wait(1)
      bdnp:Destroy()
    end
  end
end)

AutoFarm_1:Slider("Distance", false, false, 1, 100, getgenv().RFManager["Distance"] or 10, 5, false, function(val)
  getgenv().RFManager["Distance"] = val
  func_RFM:Store()
end)

AutoFarm_1:Slider("Tween Speed", false, false, 75, 500, getgenv().RFManager["Tween Speed"] or 75, 10, false, function(val)
  getgenv().RFManager["Tween Speed"] = val
  func_RFM:Store()
end)

AutoFarm_1:MutiDrop("Auto Skill", getgenv().RFManager["Skills"], {"Skill1", "Skill2", "Skill3", "Skill4"}, function(arry)
  getgenv().RFManager["Skills"] = arry
  func_RFM:Store()
end)

local AutoFarm_2 = AutoFarm:newpage()

AutoFarm_2:Toggle("Auto Start", getgenv().RFManager["Auto Start"], true, function(toggle)
  if getgenv().RFManager["Auto Start"] ~= toggle then
    getgenv().RFManager["Auto Start"] = toggle
    func_RFM:Store()
  end

  if not IsLobby and toggle then
    if LocalPlayer.PlayerGui.RoomUi:FindFirstChild("Ready") then
      LocalPlayer.PlayerGui.RoomUi.Ready.Frame.StartButton.Butom.LocalScript.RemoteEvent:FireServer()
    end
  end
end)


AutoFarm_2:Toggle("Auto Replay", getgenv().RFManager["Auto Replay"], false, function(toggle)
  if getgenv().RFManager["Auto Replay"] ~= toggle then
    getgenv().RFManager["Auto Replay"] = toggle
    func_RFM:Store()
  end
  
  -- if not IsLobby and toggle then
  --   ReplicatedStorage.Events.WinEvent.Buttom:FireServer("RPlay")
  -- end
end)

AutoFarm_2:Toggle("Auto Next", getgenv().RFManager["Auto Next"], false, function(toggle)
  if getgenv().RFManager["Auto Next"] ~= toggle then
    getgenv().RFManager["Auto Next"] = toggle
    func_RFM:Store()
  end

  -- if not IsLobby and toggle then
  --   ReplicatedStorage.Events.WinEvent.Buttom:FireServer("NextLv")
  -- end
end)

if not IsLobby then
  spawn(function()
    repeat wait(1) until LocalPlayer.PlayerGui:FindFirstChild("Win")
    local UI = LocalPlayer.PlayerGui:FindFirstChild("Win")
    if getgenv().RFManager["Auto Replay"] then
      ReplicatedStorage.Events.WinEvent.Buttom:FireServer("RPlay")
    elseif getgenv().RFManager["Auto Next"] then
      ReplicatedStorage.Events.WinEvent.Buttom:FireServer("NextLv")
    end
  end)

  RunService.RenderStepped:Connect(function()
    if getgenv().RFManager["Auto Mob"] then
      local character = LocalPlayer.Character
      local leftFoot = character:WaitForChild("Left Leg")
      local pos = leftFoot.Position
      followPart.CanCollide = true
      followPart.Position = Vector3.new(pos.X, pos.Y-(leftFoot.Size.Y/2), pos.Z)
    else
      followPart.CanCollide = false
    end
  end)
else
  for i=1,10 do
    game:GetService("ReplicatedStorage").Event.Quest:FireServer("Daily", i)
    game:GetService("ReplicatedStorage").Event.Quest:FireServer("Weekly", i)
  end
end


getgenv().Loaded = true
end
