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

local LocalPlayer = game.Players.LocalPlayer

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
		local checkPos = Vector3.new(
			targetPosition.X + x * step,
			targetPosition.Y,
			targetPosition.Z + z * step
		)

		if isSafe(checkPos) then
			return checkPos
		end

		local dir = directions[dirIndex]
		x = x + dir.X
		z = z + dir.Y
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

local moveTo = function(cframe)
  local HRP = LocalPlayer.Character.HumanoidRootPart
  local distance = (HRP.Position - Vector3.new(cframe.X, cframe.Y, cframe.Z)).Magitude
  if distance < 20 then
    HRP.CFrame = cframe
  else
    local tween = TweenService:Create(
      HRP,
      TweenInfo.new(distance/15),
      {
        CFrame = goalCFrame
      }
    )
    tween:Play()
    tween.Completed:Wait()
  end
end


-- ===========================================================

local AutoFarm = Window:Taps("Auto Farm")

local AutoFarm_1 = AutoFarm:newpage()

AutoFarm_1:Toggle("Auto Mob", getgenv().RFManager["Auto Mob"], false, function(toggle)
  if getgenv().RFManager["Auto Mob"] ~= toggle then
    getgenv().RFManager["Auto Mob"] = toggle
    func_RFM:Store()
  end

  if toggle and not IsLobby then
    while getgenv().RFManager["Auto Mob"] do
      task.wait()
      local Mob = workspace.Enemy.Mob
      for _,mob in pairs(Mob:GetChildren()) do
        while getgenv().RFManager["Auto Mob"] and mob.Parent == Mob do
          task.wait()
          local posTP 
          if workspace.PartEffect:FindFirstChild("Hitbox1") then
            local temp = spiralSearch(mob.HumanoidRootPart.Position, 500, 5)
            posTP = CFrame.new(temp.X, temp.Y-1, temp.Z)
          else
            posTP = mob.HumanoidRootPart.CFrame * CFrame.new(0, -1, 10)
          end
          moveTo(posTP)
        end
      end
    end
  end
end)






end
