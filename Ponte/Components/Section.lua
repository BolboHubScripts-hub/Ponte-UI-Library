local Creator = require(script.Parent.Parent.Creator)

local Section = {}
Section.__index = Section

function Section.New(Config, Tab)
	local NewSection = setmetatable({}, Section)
	
	NewSection.Tab = Tab
	NewSection.Title = Config.Title or "Section"
	NewSection.Open = true
	
	-- Main Frame
	NewSection.Frame = Creator.New("Frame", {
		Name = "Section",
		Size = UDim2.new(1, 0, 0, 30), -- Start collapsed/small, auto-resize
		BackgroundColor3 = Creator.Theme.SectionBackground,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	Creator.AddCorner(NewSection.Frame)
	
	-- Header Button (Toggle)
	NewSection.Header = Creator.New("TextButton", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = ""
	})
	NewSection.Header.Parent = NewSection.Frame
	
	NewSection.HeaderLabel = Creator.New("TextLabel", {
		Text = NewSection.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Parent = NewSection.Header
	})
	
	-- Chevron Icon
	NewSection.Chevron = Creator.New("ImageLabel", {
		Image = "rbxassetid://6034818372", -- General chevron info
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -25, 0.5, -10),
		BackgroundTransparency = 1,
		Rotation = 0, -- 180 when collapsed? we'll see
		Parent = NewSection.Header
	})
	
	-- Content Container
	NewSection.Content = Creator.New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = NewSection.Frame
	})
	
	local List = Creator.New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = NewSection.Content
	})
	Creator.AddPadding(NewSection.Content, 10)
	
	-- Handling Resize
	List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local ContentHeight = List.AbsoluteContentSize.Y + 20 -- Padding
		NewSection.Content.Size = UDim2.new(1, 0, 0, ContentHeight)
		if NewSection.Open then
			NewSection.Frame.Size = UDim2.new(1, 0, 0, ContentHeight + 30)
		end
	end)
	
	-- Toggle Logic
	NewSection.Header.MouseButton1Click:Connect(function()
		NewSection.Open = not NewSection.Open
		
		if NewSection.Open then
			Creator.Tween(NewSection.Frame, {Size = UDim2.new(1, 0, 0, NewSection.Content.Size.Y.Offset + 30)})
			Creator.Tween(NewSection.Chevron, {Rotation = 0})
		else
			Creator.Tween(NewSection.Frame, {Size = UDim2.new(1, 0, 0, 30)})
			Creator.Tween(NewSection.Chevron, {Rotation = 180})
		end
	end)
	
	return NewSection
end

-- Linking Elements
function Section:AddButton(Config)
	return require(script.Parent.Parent.Elements.Button).New(Config, self)
end

function Section:AddToggle(Config)
	return require(script.Parent.Parent.Elements.Toggle).New(Config, self)
end

function Section:AddSlider(Config)
	return require(script.Parent.Parent.Elements.Slider).New(Config, self)
end

function Section:AddDropdown(Config)
	return require(script.Parent.Parent.Elements.Dropdown).New(Config, self)
end

function Section:AddLabel(Config)
	return require(script.Parent.Parent.Elements.Label).New(Config, self)
end


return Section
