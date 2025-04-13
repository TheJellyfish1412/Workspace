local TweenService = game:GetService("TweenService")


local GUI_V1 = function()
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local TextButton = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")

	ScreenGui.Parent = game.CoreGui

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(93, 64, 255)
	Frame.BackgroundTransparency = 0.900
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(0.5, 0, 1, 0)

	ScrollingFrame.Parent = Frame
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.Position = UDim2.new(0.00868332107, 0, 0.0250540171, 0)
	ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 20)

	TextButton.Parent = ScreenGui
	TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderSizePixel = 0
	TextButton.Position = UDim2.new(0.512049615, 0, 0.0130456537, 0)
	TextButton.Size = UDim2.new(0, 40, 0, 40)
	TextButton.Font = Enum.Font.Unknown
	TextButton.Text = "X"
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.TextScaled = true
	TextButton.TextSize = 14.000
	TextButton.TextWrapped = true

	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = TextButton
	
	TextButton.MouseButton1Click:Connect(function()
		Frame.Visible = not Frame.Visible
	end)
	
	local items = {}
	
    function items:label(text)
		local Frame = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")

		Frame.Parent = ScrollingFrame
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BackgroundTransparency = 1.000
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(0.406911135, 0, 0.03164557, 0)
		Frame.Size = UDim2.new(1, 0, 0, 40)

		TextLabel.Parent = Frame
		TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1.000
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		TextLabel.Size = UDim2.new(0.699999988, 0, 1, 0)
		TextLabel.Font = Enum.Font.SourceSansBold
		TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 14.000
		TextLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextWrapped = true
		TextLabel.Text = text

        local func = {}

        function func:change(text)
            TextLabel.Text = text
        end

        return func
    end

	function items:toggle(name, setup, callback)
		local Frame = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local Frame_2 = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local TextButton = Instance.new("TextButton")
		local UICorner_2 = Instance.new("UICorner")

		Frame.Parent = ScrollingFrame
		Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Frame.BackgroundTransparency = 1.000
		Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(0.406911135, 0, 0.03164557, 0)
		Frame.Size = UDim2.new(0.899999976, 0, 0, 40)

		TextLabel.Parent = Frame
		TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.BackgroundTransparency = 1.000
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0.400000006, 0, 0.5, 0)
		TextLabel.Size = UDim2.new(0.699999988, 0, 1, 0)
		TextLabel.Font = Enum.Font.SourceSansBold
		TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 14.000
		TextLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextWrapped = true
		TextLabel.Text = name

		Frame_2.Parent = Frame
		Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame_2.BackgroundColor3 = Color3.fromRGB(95, 35, 200)
		Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame_2.BorderSizePixel = 0
		Frame_2.Position = UDim2.new(0.81400001, 0, 0.5, 0)
		Frame_2.Size = UDim2.new(0.128999993, 0, 1, 0)

		UICorner.CornerRadius = UDim.new(0.5, 0)
		UICorner.Parent = Frame_2

		TextButton.Parent = Frame_2
		TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.BorderSizePixel = 0
		TextButton.Position = UDim2.new(0.0670000017, 0, 0.120999999, 0)
		TextButton.Size = UDim2.new(0.416666657, 0, 0.75757575, 0)
		TextButton.Font = Enum.Font.SourceSans
		TextButton.Text = ""
		TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.TextSize = 14.000

		UICorner_2.CornerRadius = UDim.new(0.5, 0)
		UICorner_2.Parent = TextButton
		
		
		if (setup) then
			TextButton.Position = UDim2.new(0.525, 0, 0.121, 0)
		else
			TextButton.Position = UDim2.new(0.067, 0, 0.121, 0)
		end
				
		local turnOn = setup
		TextButton.MouseButton1Click:Connect(function()
			if (turnOn == true) then
				local tween = TweenService:Create(
					TextButton,
					TweenInfo.new(.5),
					{
						Position = UDim2.new(0.067, 0, 0.121, 0)
					}
				)
				tween:Play()
			else
				local tween = TweenService:Create(
					TextButton,
					TweenInfo.new(.5),
					{
						Position = UDim2.new(0.525, 0, 0.121, 0)
					}
				)
				tween:Play()
			end
			turnOn = not turnOn
			callback(turnOn)
		end)
		if (turnOn) then
			callback(turnOn)
		end
	end
	
	function items:button(name, callback)
		local TextButton = Instance.new("TextButton")
		local UICorner = Instance.new("UICorner")

		TextButton.Parent = ScrollingFrame
		TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.BackgroundTransparency = 0.800
		TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.BorderSizePixel = 0
		TextButton.Size = UDim2.new(0.899999976, 0, 0, 40)
		TextButton.Font = Enum.Font.SourceSansBold
		TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.TextScaled = true
		TextButton.TextSize = 14.000
		TextButton.TextWrapped = true
		TextButton.Text = name

		UICorner.CornerRadius = UDim.new(0.800000012, 0)
		UICorner.Parent = TextButton
		
		TextButton.MouseButton1Click:Connect(function()
			callback()
		end)
	end
	
	return items
end

return GUI_V1
