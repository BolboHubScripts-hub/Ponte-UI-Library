local Creator = require(script.Parent.Parent.Creator)

local Label = {}
Label.__index = Label

function Label.New(Config, Container)
	local NewLabel = setmetatable({}, Label)
	
	NewLabel.Container = Container
	NewLabel.Title = Config.Title or "Label"
	
	NewLabel.Frame = Creator.New("TextLabel", {
		Name = "Label",
		Text = NewLabel.Title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 20), -- Auto size based on text bounds later?
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Parent = Container.Content
	})
	
	return NewLabel
end

return Label
