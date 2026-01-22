local Creator = require(script.Parent.Parent.Creator)
local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

function Window.New(Config)
	local NewWindow = setmetatable({}, Window)
	
	NewWindow.Config = Config or {}
	NewWindow.Title = NewWindow.Config.Title or "Ponte UI"
	NewWindow.SubTitle = NewWindow.Config.SubTitle or ""
	NewWindow.Size = NewWindow.Config.Size or UDim2.fromOffset(580, 460)
	
	NewWindow.Tabs = {}
	
	-- Main ScreenGui
	NewWindow.ScreenGui = Creator.New("ScreenGui", {
		Name = "PonteUI",
		Parent = game.CoreGui,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	
	-- Main Frame
	NewWindow.Root = Creator.New("Frame", {
		Name = "Root",
		Size = NewWindow.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Creator.Theme.Background,
		Parent = NewWindow.ScreenGui
	})
	Creator.AddCorner(NewWindow.Root)
	Creator.AddStroke(NewWindow.Root, Creator.Theme.ElementBackground, 2)
	Creator.Drag(NewWindow.Root)
	
	-- Sidebar
	NewWindow.Sidebar = Creator.New("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 160, 1, 0),
		BackgroundColor3 = Creator.Theme.SectionBackground,
		BorderSizePixel = 0,
		Parent = NewWindow.Root
	})
	Creator.New("UICorner", {
		CornerRadius = Creator.Theme.CornerRadius,
		Parent = NewWindow.Sidebar
	})
	-- Patch the right corners of sidebar so it looks attached
	Creator.New("Frame", {
		Name = "Patch",
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		BackgroundColor3 = Creator.Theme.SectionBackground,
		BorderSizePixel = 0,
		Parent = NewWindow.Sidebar
	})
	
	-- Title
	local TitleLabel = Creator.New("TextLabel", {
		Name = "Title",
		Text = NewWindow.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 15, 0, 15),
		BackgroundTransparency = 1,
		Parent = NewWindow.Sidebar
	})
	
	if NewWindow.SubTitle ~= "" then
		Creator.New("TextLabel", {
			Name = "SubTitle",
			Text = NewWindow.SubTitle,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Creator.Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 15, 0, 40),
			BackgroundTransparency = 1,
			Parent = NewWindow.Sidebar
		})
	end
	
	-- Tab Container
	NewWindow.TabContainer = Creator.New("ScrollingFrame", {
		Name = "TabContainer",
		Size = UDim2.new(1, 0, 1, -80),
		Position = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		Parent = NewWindow.Sidebar
	})
	Creator.New("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = NewWindow.TabContainer
	})
	Creator.AddPadding(NewWindow.TabContainer, 10)
	
	-- Content Area
	NewWindow.ContentContainer = Creator.New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -170, 1, -20),
		Position = UDim2.new(0, 170, 0, 10),
		BackgroundTransparency = 1,
		Parent = NewWindow.Root
	})
	
	return NewWindow
end

function Window:AddTab(Config)
	local NewTab = Tab.New(Config, self)
	table.insert(self.Tabs, NewTab)
	
	-- Retrieve the buttons/frames from the Tab object
	NewTab.TabButton.Parent = self.TabContainer
	NewTab.ContentFrame.Parent = self.ContentContainer
	
	-- Select first tab by default
	if #self.Tabs == 1 then
		NewTab:Select()
	end
	
	return NewTab
end

return Window
