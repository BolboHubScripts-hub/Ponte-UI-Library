local Creator = require(script.Parent.Parent.Creator)
local Section = require(script.Parent.Section)

local Tab = {}
Tab.__index = Tab

function Tab.New(Config, Window)
	local NewTab = setmetatable({}, Tab)
	
	NewTab.Window = Window
	NewTab.Title = Config.Title or "Tab"
	NewTab.Icon = Config.Icon or "" -- TODO: Image support
	NewTab.Selected = false
	
	-- Sidebar Button
	NewTab.TabButton = Creator.New("TextButton", {
		Name = NewTab.Title .. "Button",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = ""
	})
	
	NewTab.TabLabel = Creator.New("TextLabel", {
		Name = "Title",
		Text = NewTab.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Creator.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Parent = NewTab.TabButton
	})
	
	-- Interaction
	NewTab.TabButton.MouseButton1Click:Connect(function()
		NewTab:Select()
	end)
	
	-- Content Frame (Scrolling)
	NewTab.ContentFrame = Creator.New("ScrollingFrame", {
		Name = NewTab.Title .. "Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Creator.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	Creator.New("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = NewTab.ContentFrame
	})
	Creator.AddPadding(NewTab.ContentFrame, 5)
	
	-- Auto Canvas Size
	NewTab.ContentFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		NewTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, NewTab.ContentFrame.UIListLayout.AbsoluteContentSize.Y + 10)
	end)
	
	return NewTab
end

function Tab:Select()
	-- Deselect all others
	for _, OtherTab in pairs(self.Window.Tabs) do
		OtherTab.Selected = false
		OtherTab.TabButton.BackgroundTransparency = 1
		OtherTab.TabLabel.TextColor3 = Creator.Theme.SubText
		OtherTab.ContentFrame.Visible = false
	end
	
	-- Select this one
	self.Selected = true
	self.TabButton.BackgroundTransparency = 0
	self.TabButton.BackgroundColor3 = Creator.Theme.ElementBackground
	self.TabLabel.TextColor3 = Creator.Theme.Text
	self.ContentFrame.Visible = true
	
	-- Add simple visual indicator
	-- (Optional: Add a small bar on the left)
end

function Tab:AddSection(Config)
	local NewSection = Section.New(Config, self)
	NewSection.Frame.Parent = self.ContentFrame
	return NewSection
end

-- Shortcuts to add elements directly to tab (wraps in a default section or appends to scrollframe if supported by design)
-- For Ponte, we will likely want Elements inside Sections, but let's allow direct add for flexibility if needed.
-- We can add element methods here later if we want "Sectionless" elements.

return Tab
