local Creator = require(script.Parent.Parent.Creator)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.New(Config, Container)
	local NewDropdown = setmetatable({}, Dropdown)
	
	NewDropdown.Container = Container
	NewDropdown.Title = Config.Title or "Dropdown"
	NewDropdown.Values = Config.Values or {}
	NewDropdown.Multi = Config.Multi or false
	NewDropdown.Default = Config.Default or 1
	NewDropdown.Value = NewDropdown.Values[NewDropdown.Default] or NewDropdown.Default
	NewDropdown.Callback = Config.Callback or function() end
	NewDropdown.Open = false
	
	-- Main Frame
	NewDropdown.Frame = Creator.New("Frame", {
		Name = "Dropdown",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Creator.Theme.ElementBackground,
		ClipsDescendants = true,
		Parent = Container.Content
	})
	Creator.AddCorner(NewDropdown.Frame)
	
	NewDropdown.Label = Creator.New("TextLabel", {
		Name = "Title",
		Text = NewDropdown.Title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Parent = NewDropdown.Frame
	})
	
	NewDropdown.ValueLabel = Creator.New("TextLabel", {
		Name = "Value",
		Text = tostring(NewDropdown.Value),
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -60, 0, 20),
		Position = UDim2.new(0, 10, 0, 25),
		BackgroundTransparency = 1,
		Parent = NewDropdown.Frame
	})
	
	NewDropdown.Arrow = Creator.New("ImageLabel", {
		Image = "rbxassetid://6034818372",
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -30, 0, 11),
		BackgroundTransparency = 1,
		Rotation = 180,
		Parent = NewDropdown.Frame
	})
	
	-- List Container
	NewDropdown.List = Creator.New("Frame", {
		Name = "List",
		Size = UDim2.new(1, -20, 0, 0), -- Auto size
		Position = UDim2.new(0, 10, 0, 50),
		BackgroundTransparency = 1,
		Parent = NewDropdown.Frame
	})
	
	local UIList = Creator.New("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = NewDropdown.List
	})
	
	-- Refresh Logic
	function NewDropdown:RefreshResults()
		-- Clear old
		for _, Child in pairs(NewDropdown.List:GetChildren()) do
			if Child:IsA("TextButton") then Child:Destroy() end
		end
		
		-- Add new
		for _, Option in pairs(NewDropdown.Values) do
			local OptionBtn = Creator.New("TextButton", {
				Name = "Option",
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = Creator.Theme.SectionBackground,
				Text = tostring(Option),
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = Option == NewDropdown.Value and Creator.Theme.Accent or Creator.Theme.SubText,
				Parent = NewDropdown.List
			})
			Creator.AddCorner(OptionBtn)
			
			OptionBtn.MouseButton1Click:Connect(function()
				NewDropdown:Set(Option)
				NewDropdown:Toggle()
			end)
		end
		
		-- Resize
		NewDropdown.List.Size = UDim2.new(1, -20, 0, UIList.AbsoluteContentSize.Y)
	end

	function NewDropdown:Toggle()
		NewDropdown.Open = not NewDropdown.Open
		
		if NewDropdown.Open then
			NewDropdown:RefreshResults()
			Creator.Tween(NewDropdown.Frame, {Size = UDim2.new(1, 0, 0, 50 + NewDropdown.List.Size.Y.Offset + 10)})
			Creator.Tween(NewDropdown.Arrow, {Rotation = 0})
		else
			Creator.Tween(NewDropdown.Frame, {Size = UDim2.new(1, 0, 0, 42)})
			Creator.Tween(NewDropdown.Arrow, {Rotation = 180})
		end
	end
	
	NewDropdown.Frame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Check if clicking header area to toggle
            if Input.Position.Y - NewDropdown.Frame.AbsolutePosition.Y < 42 then
			    NewDropdown:Toggle()
            end
		end
	end)
    
    function NewDropdown:Set(Val)
        self.Value = Val
        self.ValueLabel.Text = tostring(Val)
        self.Callback(Val)
    end
	
	return NewDropdown
end

return Dropdown
