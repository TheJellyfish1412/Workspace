if game.PlaceId == 124608038008436 then
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local PositionData = require(ReplicatedStorage.Modules.Economy.PositionData)
    local TestQuestionData = require(ReplicatedStorage.Modules.Economy.TestQuestionData)
    
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
    			local price = PositionData[player:GetAttribute("Position")]["Money"]
    			if money then
    				textLabel.Text = shortenNumber(money) .. "/" .. shortenNumber(price)
    			else
    				textLabel.Text = "0/0"
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
    
    local DropListPlayer
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
    	createFloatingGui(player)
    	if DropListPlayer then
    	    DropListPlayer:Add(player.Name)
    	end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
    	if DropListPlayer then
    	    DropListPlayer:Remove(player.Name)
    	end
    end)
    
    -- Handle players already in the game
    for _, player in ipairs(Players:GetPlayers()) do
    	if player ~= LocalPlayer then
    		createFloatingGui(player)
    	end
    end
    
    
    local myGui = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/gui.lua"))()()
    
    local main = myGui:Page("Main")
    
    main:Toggle("Auto Cut Queue", false, function(t)
      _G.AutoCutQueue = t
      while _G.AutoCutQueue do
        task.wait()
        ReplicatedStorage.Events.PositionEvent:FireServer("SkipAhead")
      end
    end)
    main:Toggle("Auto Return", false, function(t)
      _G.AutoReturn = t
      while _G.AutoReturn do
        wait()
        if LocalPlayer:GetAttribute("Position") == -1 then
          ReplicatedStorage.Events.PositionEvent:FireServer("ReturnLine")
        end
      end
    end)
    main:Toggle("Auto Quiz", true, function(t)
      _G.AutoQuiz = t
      while _G.AutoQuiz do
        wait(5)
        ReplicatedStorage.Events.QuizEvent:FireServer(_G.Answer)
      end
    end)
    DropListPlayer = main:Drop("Players : ", Players:GetChildren(), false, function(t)
    	_G.target = tostring(t)
    end)
    DropListPlayer:Remove(LocalPlayer)
    main:Toggle("Auto Push", false, function(t)
        _G.AutoPush = t
        while _G.AutoPush do
            task.wait()
            local tarPla = Players:FindFirstChild(_G.target)
            if tarPla then
                local myPos = LocalPlayer:GetAttribute("Position")
                local tarPos = tarPla:GetAttribute("Position")
                if myPos < tarPos then
                    ReplicatedStorage.Events.PositionEvent:FireServer("SkipBehind")
                else
                    if myPos-tarPos == 1 then
                        ReplicatedStorage.Events.PositionEvent:FireServer("ShoveAhead")
                    else
                        ReplicatedStorage.Events.PositionEvent:FireServer("SkipAhead")
                    end
                end
            else
                ReplicatedStorage.Events.PositionEvent:FireServer("SkipBehind")
            end
        end
    end)
    main:Toggle("Auto Pull", false, function(t)
        _G.AutoPull = t
        while _G.AutoPull do
            task.wait()
            local tarPla = Players:FindFirstChild(_G.target)
            if tarPla then
                local myPos = LocalPlayer:GetAttribute("Position")
                local tarPos = tarPla:GetAttribute("Position")
                if myPos < tarPos + 2 then
                    ReplicatedStorage.Events.PositionEvent:FireServer("SkipBehind")
                else
                    if myPos - tarPos == 2 then
                        ReplicatedStorage.Events.PositionEvent:FireServer("ShoveAhead")
                    else
                        ReplicatedStorage.Events.PositionEvent:FireServer("SkipAhead")
                    end
                end
            else
                ReplicatedStorage.Events.PositionEvent:FireServer("SkipBehind")
            end
        end
    end)
    
    local ETC = myGui:Page("ETC")
    
    local countdown = ETC:Label("Countdown : ")
    local FirstTimePosition = workspace.FirstTimePosition
    FirstTimePosition.Changed:Connect(function()
    	countdown:Change("Countdown : " .. FirstTimePosition.Value)
    end)
    
    ETC:Toggle("Show Money", true, function(t)
        if t then
            for _, player in pairs(game.Players:GetChildren()) do
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local FloatingGui = head:FindFirstChild("FloatingGui")
                    if FloatingGui then
                        FloatingGui.Enabled = true
                    end
                end
            end
            print("Show")
        else
            for _, player in pairs(game.Players:GetChildren()) do
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local FloatingGui = head:FindFirstChild("FloatingGui")
                    if FloatingGui then
                        FloatingGui.Enabled = false
                    end
                end
            end
            print("Not Show")
        end
    end)
    
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Idel Detect")
    end)
    
    ReplicatedStorage.Events.QuizEvent.OnClientEvent:Connect(function(x)
        _G.Question = x.Question
        for _,data in pairs(TestQuestionData) do
            if data["question"] == x.Question then
                _G.Answer = data["answer"]
            end
        end
    end)
end
