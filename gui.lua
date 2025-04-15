local TweenService = game:GetService("TweenService")


local GUI_V1 = function()
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Frame_2 = Instance.new("Frame")
	local UICorner_2 = Instance.new("UICorner")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")

	ScreenGui.Parent = game.CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.251385659, 0, 0.228879645, 0)
	Frame.Size = UDim2.new(0.496314496, 0, 0.540453136, 0)

    local ui_toggle = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")
    local UIDragDetector = Instance.new("UIDragDetector")
    
    ui_toggle.Name = "ui_toggle"
    ui_toggle.Parent = ScreenGui
    ui_toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ui_toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ui_toggle.BorderSizePixel = 0
    ui_toggle.Position = UDim2.new(0.472950816, 0, 0.0472636819, 0)
    ui_toggle.Size = UDim2.new(0, 55, 0, 55)
    ui_toggle.Image = "http://www.roblox.com/asset/?id=119926900664966"
    
    UICorner.CornerRadius = UDim.new(0, 20)
    UICorner.Parent = ui_toggle
	
	UIDragDetector.Parent = ui_toggle
    
    ui_toggle.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)

	UICorner.Parent = Frame

	Frame_2.Parent = Frame
	Frame_2.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
	Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame_2.BorderSizePixel = 0
	Frame_2.Position = UDim2.new(0.0252157785, 0, 0.0474561527, 0)
	Frame_2.Size = UDim2.new(0.203156769, 0, 0.903057814, 0)

	UICorner_2.Parent = Frame_2

	ScrollingFrame.Parent = Frame_2
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.Position = UDim2.new(0, 0, -5.05892217e-08, 0)
	ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	ScrollingFrame.ScrollBarThickness = 7

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	local frame_store = {}
	local func = {}
	
	function func:Page(name)
		local page = Instance.new("Frame")
		local TextButton = Instance.new("TextButton")
		local Frame3 = Instance.new("Frame")
		table.insert(frame_store, Frame3)
		local UICorner = Instance.new("UICorner")
		
		page.Name = "page"
		page.Parent = ScrollingFrame
		page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		page.BackgroundTransparency = 1.000
		page.BorderColor3 = Color3.fromRGB(0, 0, 0)
		page.BorderSizePixel = 0
		page.Position = UDim2.new(0, 0, 3.78500467e-08, 0)
		page.Size = UDim2.new(1.00000012, 0, 0.465079576, 0)
		page.SizeConstraint = Enum.SizeConstraint.RelativeXX

		TextButton.Parent = page
		TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
		TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.BackgroundTransparency = 1.000
		TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextButton.BorderSizePixel = 0
		TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
		TextButton.Size = UDim2.new(1, 0, 0.5, 0)
		TextButton.Font = Enum.Font.FredokaOne
		TextButton.Text = name
		TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.TextScaled = true
		TextButton.TextSize = 30.000
		TextButton.TextStrokeTransparency = 0.000
		TextButton.TextWrapped = true
		
		TextButton.MouseButton1Click:Connect(function()
			for i,v in pairs(frame_store) do
				if (v == Frame3) then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end)


		Frame3.Parent = Frame
		Frame3.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
		Frame3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Frame3.BorderSizePixel = 0
		Frame3.Position = UDim2.new(0.264489919, 0, 0.0474561527, 0)
		Frame3.Size = UDim2.new(0.713057816, 0, 0.903057814, 0)
		Frame3.Visible = false

		UICorner.Parent = Frame3
		
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")

		ScrollingFrame.Parent = Frame3
		ScrollingFrame.Active = true
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.BackgroundTransparency = 1.000
		ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 3, 0)
		ScrollingFrame.ScrollBarThickness = 7

		UIListLayout.Parent = ScrollingFrame
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		
		local func_page = {}
		
		function func_page:Label(text)
			local Label = Instance.new("Frame")
			local TextLabel = Instance.new("TextLabel")
			
			Label.Name = "Label"
			Label.Parent = ScrollingFrame
			Label.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
			Label.BackgroundTransparency = 1.000
			Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Label.BorderSizePixel = 0
			Label.Position = UDim2.new(0, 0, 7.77714888e-08, 0)
			Label.Size = UDim2.new(0.999999881, 0, 0.0959789082, 0)
			Label.SizeConstraint = Enum.SizeConstraint.RelativeXX

			TextLabel.Parent = Label
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
			TextLabel.Size = UDim2.new(0.75, 0, 0.75, 0)
			TextLabel.Font = Enum.Font.FredokaOne
			TextLabel.Text = text
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 35.000
			TextLabel.TextStrokeTransparency = 0.000
			TextLabel.TextWrapped = true
			
			local extra_func = {}
			
			function extra_func:Change(text)
				TextLabel.Text = text
			end
			
			return extra_func
		end

		function func_page:Toggle(text, state, callback)
			local now_state = false

			local toggle = Instance.new("Frame")
			local TextLabel = Instance.new("TextLabel")
			local Frame = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local UIPadding = Instance.new("UIPadding")
			local TextButton = Instance.new("TextButton")
			local UICorner_2 = Instance.new("UICorner")

			toggle.Name = "toggle"
			toggle.Parent = ScrollingFrame
			toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggle.BackgroundTransparency = 1.000
			toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			toggle.BorderSizePixel = 0
			toggle.Position = UDim2.new(0, 0, 0.136422008, 0)
			toggle.Size = UDim2.new(0.999999881, 0, 0.145509675, 0)
			toggle.SizeConstraint = Enum.SizeConstraint.RelativeXX

			TextLabel.Parent = toggle
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.350000054, 0, 0.500000238, 0)
			TextLabel.Size = UDim2.new(0.699999988, 0, 0.400000006, 0)
			TextLabel.Font = Enum.Font.FredokaOne
			TextLabel.Text = text
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextStrokeTransparency = 0.000
			TextLabel.TextWrapped = true

			Frame.Parent = toggle
			Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			Frame.BackgroundColor3 = Color3.fromRGB(91, 91, 91)
			Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Frame.BorderSizePixel = 0
			Frame.Position = UDim2.new(0.800000012, 0, 0.5, 0)
			Frame.Size = UDim2.new(0.100000001, 0, 0.400000006, 0)

			UICorner.CornerRadius = UDim.new(1, 1)
			UICorner.Parent = Frame

			TextButton.Parent = Frame
			TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
			TextButton.BackgroundColor3 = Color3.fromRGB(34, 255, 0)
			TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextButton.BorderSizePixel = 0
			TextButton.Position = UDim2.new(0.25, 0, 0.5, 0)
			TextButton.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
			TextButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
			TextButton.Font = Enum.Font.SourceSans
			TextButton.Text = ""
			TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			TextButton.TextSize = 14.000

			UICorner_2.CornerRadius = UDim.new(1, 0)
			UICorner_2.Parent = TextButton

			UIPadding.Parent = Frame
			UIPadding.PaddingBottom = UDim.new(0, 2)
			UIPadding.PaddingLeft = UDim.new(0, 2)
			UIPadding.PaddingRight = UDim.new(0, 2)
			UIPadding.PaddingTop = UDim.new(0, 2)
			
			local moveButton = function()
				now_state = not now_state
				if (now_state) then
					local tween = TweenService:Create(
						TextButton,
						TweenInfo.new(.5),
						{
							Position = UDim2.new(0.75, 0, 0.5, 0)
						}
					)
					tween:Play()
				else
					local tween = TweenService:Create(
						TextButton,
						TweenInfo.new(.5),
						{
							Position = UDim2.new(0.25, 0, 0.5, 0)
						}
					)
					tween:Play()
				end
				coroutine.wrap(callback)(now_state)
			end
			
			TextButton.MouseButton1Click:Connect(moveButton)
			
			if state then
				moveButton()
			end
			
			local extra_func = {}
			function extra_func:SetState(setState)
				if (now_state ~= setState) then
					moveButton()
				end
			end
			return extra_func
		end
		

		function func_page:Drop(text, args, default, callback)
			local dropdown = Instance.new("Frame")
			local main = Instance.new("Frame")
			local TextButton = Instance.new("TextButton")
			local UICorner = Instance.new("UICorner")
			local TextLabel = Instance.new("TextLabel")
			local options = Instance.new("ScrollingFrame")
			local UIListLayout = Instance.new("UIListLayout")

			dropdown.Name = "dropdown"
			dropdown.Parent = ScrollingFrame
			dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			dropdown.BackgroundTransparency = 1.000
			dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
			dropdown.BorderSizePixel = 0
			dropdown.ClipsDescendants = true
			dropdown.Position = UDim2.new(0, 0, 0.343245655, 0)
			dropdown.Size = UDim2.new(1, 0, 0.1, 0)
			dropdown.SizeConstraint = Enum.SizeConstraint.RelativeXX

			main.Name = "main"
			main.Parent = dropdown
			main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			main.BackgroundTransparency = 1.000
			main.BorderColor3 = Color3.fromRGB(0, 0, 0)
			main.BorderSizePixel = 0
			main.Size = UDim2.new(1, 0, 0.100000001, 0)
			main.SizeConstraint = Enum.SizeConstraint.RelativeXX

			TextButton.Parent = main
			TextButton.AnchorPoint = Vector2.new(0, 0.5)
			TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			TextButton.BackgroundTransparency = 0.700
			TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextButton.BorderSizePixel = 0
			TextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
			TextButton.Size = UDim2.new(0.449999988, 0, 0.600000024, 0)
			TextButton.Font = Enum.Font.SourceSans
			TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextButton.TextScaled = true
			TextButton.TextSize = 14.000
			TextButton.TextStrokeColor3 = Color3.fromRGB(0, 81, 255)
			TextButton.TextStrokeTransparency = 0.000
			TextButton.TextWrapped = true
			if (default) then
				TextButton.Text = tostring(default)
			else
				TextButton.Text = ""
			end

			UICorner.CornerRadius = UDim.new(1, 0)
			UICorner.Parent = TextButton

			TextLabel.Parent = main
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0.25, 0, 0.5, 0)
			TextLabel.Size = UDim2.new(0.5, 0, 0.600000024, 0)
			TextLabel.Font = Enum.Font.FredokaOne
			TextLabel.Text = text
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextStrokeTransparency = 0.000
			TextLabel.TextWrapped = true

			options.Name = "options"
			options.Parent = main
			options.Active = true
			options.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
			options.BackgroundTransparency = 1.000
			options.BorderColor3 = Color3.fromRGB(0, 0, 0)
			options.BorderSizePixel = 0
			options.Position = UDim2.new(0.49999994, 0, 1, 0)
			options.Size = UDim2.new(0.449999958, 0, 2.67798591, 0)
			options.ZIndex = 2
			options.CanvasSize = UDim2.new(0, 0, 0, 140)
			options.ScrollBarThickness = 7

			UIListLayout.Parent = options
			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			
			local state
			local setWindowOption = function(setState)
				state = setState
				if (state) then
					local tween = TweenService:Create(
						dropdown,
						TweenInfo.new(.5),
						{
							Size = UDim2.new(1, 0, 0.368, 0)
						}
					)
					tween:Play()
				else
					local tween = TweenService:Create(
						dropdown,
						TweenInfo.new(.5),
						{
							Size = UDim2.new(1, 0, 0.1, 0)
						}
					)
					tween:Play()
				end
			end
			
			TextButton.MouseButton1Click:Connect(function()
				setWindowOption(not state)
			end)
			
			local itemWithButton = {}
			local extra_func = {}
			
			function extra_func:Add(item)
				local option = Instance.new("Frame")
				local TextButton4 = Instance.new("TextButton")
				local UICorner = Instance.new("UICorner")

				option.Name = "option"
				option.Parent = options
				option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				option.BackgroundTransparency = 1.000
				option.BorderColor3 = Color3.fromRGB(0, 0, 0)
				option.BorderSizePixel = 0
				option.Size = UDim2.new(0.89200002, 0, 0.200000003, 0)
				option.SizeConstraint = Enum.SizeConstraint.RelativeXX

				TextButton4.Parent = option
				TextButton4.AnchorPoint = Vector2.new(0.5, 0.5)
				TextButton4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				TextButton4.BackgroundTransparency = 0.700
				TextButton4.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton4.BorderSizePixel = 0
				TextButton4.Position = UDim2.new(0.5, 0, 0.5, 0)
				TextButton4.Size = UDim2.new(0.89200002, 0, 0.129999995, 0)
				TextButton4.SizeConstraint = Enum.SizeConstraint.RelativeXX
				TextButton4.Font = Enum.Font.SourceSans
				TextButton4.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton4.TextScaled = true
				TextButton4.TextSize = 14.000
				TextButton4.TextStrokeColor3 = Color3.fromRGB(0, 81, 255)
				TextButton4.TextStrokeTransparency = 0.000
				TextButton4.TextWrapped = true
				TextButton4.Text = tostring(item)

				UICorner.CornerRadius = UDim.new(1, 0)
				UICorner.Parent = TextButton4
				
				itemWithButton[tostring(item)] = option
				
				TextButton4.MouseButton1Click:Connect(function()
					coroutine.wrap(callback)(item)
					setWindowOption(false)
					TextButton.Text = tostring(item)
				end)
				
				options.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
			end
			
			function extra_func:Remove(item)
			    item = tostring(item)
				if itemWithButton[item] then
					itemWithButton[item]:Destroy()
					itemWithButton[item] = nil
				end
				options.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
			end
			
			for _,item in pairs(args) do
				extra_func:Add(item)
			end
			
			if default then
				coroutine.wrap(callback)(default)
			end
			
			return extra_func
		end
		
		return func_page
	end
	
	return func
end

return GUI_V1
