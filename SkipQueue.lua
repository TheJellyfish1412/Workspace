local myGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/gui2.lua"))()()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Function to shorten numbers
local function shortenNumber(number)
	if number >= 1e12 then
		return string.format("%.1ft", number / 1e12)  -- trillion
	elseif number >= 1e9 then
		return string.format("%.1fb", number / 1e9)   -- billion
	elseif number >= 1e6 then
		return string.format("%.1fm", number / 1e6)   -- million
	elseif number >= 1e3 then
		return string.format("%.1fk", number / 1e3)   -- thousand
	else
		return tostring(number)
	end
end


-- Create and manage the floating money GUI for a player
local function createFloatingGui(player)
	if player == LocalPlayer then return end

	local billboard, textLabel
	local updateMoneyConnection

	local function attachGui(character)
		local head = character:WaitForChild("Head")

		-- Check if GUI already exists
		if head:FindFirstChild("FloatingGui") then return end

		-- Create the BillboardGui for the player's head
		billboard = Instance.new("BillboardGui")
		billboard.Name = "FloatingGui"
		billboard.Size = UDim2.new(0, 100, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.Adornee = head
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		-- Create the text label
		textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.Text = "Loading..."
		textLabel.Parent = billboard

		-- Update the GUI with player's money
		local function updateMoneyDisplay()
			local money = player:GetAttribute("Money")
			if money then
				textLabel.Text = shortenNumber(money)
			else
				textLabel.Text = "0"
			end
		end

		-- Initial update
		updateMoneyDisplay()

		-- Connect the money update event
		updateMoneyConnection = player:GetAttributeChangedSignal("Money"):Connect(updateMoneyDisplay)

		-- Disconnect the event when the player's character is removed or the GUI is cleaned up
		character:WaitForChild("Humanoid").Died:Connect(function()
			if updateMoneyConnection then
				updateMoneyConnection:Disconnect()
			end
		end)
	end

	-- Handle existing or future characters
	if player.Character then
		attachGui(player.Character)
	end
	player.CharacterAdded:Connect(attachGui)

	-- Disconnect when player leaves (important for memory management)
	player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			-- Player left the game
			if updateMoneyConnection then
				updateMoneyConnection:Disconnect()
			end
		end
	end)

	-- Return the billboard for toggling visibility
	return billboard
end

-- Table to store GUIs and manage visibility
_G.playerGUIs = {}

-- Handle new players
Players.PlayerAdded:Connect(function(player)
	local gui = createFloatingGui(player)
	_G.playerGUIs[player] = gui
end)

-- Handle players already in the game
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		local gui = createFloatingGui(player)
		_G.playerGUIs[player] = gui
	end
end


local countdown = myGui:label("Countdown : ")
local FirstTimePosition = workspace.FirstTimePosition
FirstTimePosition.Changed:Connect(function()
	countdown:change("Countdown : " .. FirstTimePosition.Value)
end)
myGui:toggle("Auto Cut Queue", false, function(t)
  _G.AutoCutQueue = t
  while _G.AutoCutQueue do
    wait()
    game:GetService("ReplicatedStorage").Events.PositionEvent:FireServer("SkipAhead")
  end
end)
myGui:toggle("Auto Return", false, function(t)
  _G.AutoReturn = t
  while _G.AutoReturn do
    wait(1)
    game:GetService("ReplicatedStorage").Events.PositionEvent:FireServer("ReturnLine")
  end
end)
myGui:toggle("Auto Quiz", false, function(t)
  _G.AutoQuiz = t
  while _G.AutoQuiz do
    wait(1)
    game:GetService("ReplicatedStorage").Events.QuizEvent:FireServer("ReturnLine")
  end
end)
myGui:toggle("Show Money", true, function(t)
    if t then
        for player, gui in pairs(_G.playerGUIs) do
            if gui and gui.Parent then
                gui.Enabled = true
            end
        end
        print("Show")
    else
        for player, gui in pairs(_G.playerGUIs) do
            if gui and gui.Parent then
                gui.Enabled = false
            end
        end
        print("Not Show")
    end
end)

print(time.Value)
