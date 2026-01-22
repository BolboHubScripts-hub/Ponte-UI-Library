local Creator = require(script.Parent.Parent.Creator)

local Button = {}
Button.__index = Button

function Button.New(Config, Container)
	local NewButton = setmetatable({}, Button)
	
	NewButton.Container = Container
	NewButton.Title = Config.Title or "Button"
	NewButton.Callback = Config.Callback or function() end
	
	NewButton.Frame = Creator.New("TextButton", {
		Name = "Button",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Creator.Theme.ElementBackground,
		AutoButtonColor = false,
		Text = "",
		Parent = Container.Content
	})
	Creator.AddCorner(NewButton.Frame)
	
	NewButton.Label = Creator.New("TextLabel", {
		Name = "Title",
		Text = NewButton.Title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Parent = NewButton.Frame
	})
	
	NewButton.Icon = Creator.New("ImageLabel", {
		Image = "rbxassetid://6034818372", -- Placeholder icon
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -30, 0.5, -10),
		BackgroundTransparency = 1,
		Visible = false, -- Default hidden
		Parent = NewButton.Frame
	})
	
	-- Hover Effects
	NewButton.Frame.MouseEnter:Connect(function()
		Creator.Tween(NewButton.Frame, {BackgroundColor3 = Creator.Theme.SectionBackground}) -- Lighter
	end)
	
	NewButton.Frame.MouseLeave:Connect(function()
		Creator.Tween(NewButton.Frame, {BackgroundColor3 = Creator.Theme.ElementBackground})
	end)
	
	-- Click
	NewButton.Frame.MouseButton1Click:Connect(function()
		Creator.Tween(NewButton.Frame, {BackgroundColor3 = Creator.Theme.Accent}, 0.1)
		task.wait(0.1)
		Creator.Tween(NewButton.Frame, {BackgroundColor3 = Creator.Theme.SectionBackground}, 0.1)
		NewButton.Callback()
	end)
	
	return NewButton
end

return Button
