local Creator = require(script.Parent.Parent.Creator)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.New(Config, Container)
	local NewToggle = setmetatable({}, Toggle)
	
	NewToggle.Container = Container
	NewToggle.Title = Config.Title or "Toggle"
	NewToggle.Value = Config.Default or false
	NewToggle.Callback = Config.Callback or function() end
	
	NewToggle.Frame = Creator.New("TextButton", {
		Name = "Toggle",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Creator.Theme.ElementBackground,
		AutoButtonColor = false,
		Text = "",
		Parent = Container.Content
	})
	Creator.AddCorner(NewToggle.Frame)
	
	NewToggle.Label = Creator.New("TextLabel", {
		Name = "Title",
		Text = NewToggle.Title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Parent = NewToggle.Frame
	})
	
	-- Switch Background
	NewToggle.Switch = Creator.New("Frame", {
		Name = "Switch",
		Size = UDim2.fromOffset(40, 20),
		Position = UDim2.new(1, -50, 0.5, -10),
		BackgroundColor3 = Creator.Theme.Background,
		Parent = NewToggle.Frame
	})
	Creator.AddCorner(NewToggle.Switch, UDim.new(1, 0))
	Creator.AddStroke(NewToggle.Switch, Creator.Theme.SectionBackground, 1)
	
	-- Knob
	NewToggle.Knob = Creator.New("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Creator.Theme.SubText,
		Parent = NewToggle.Switch
	})
	Creator.AddCorner(NewToggle.Knob, UDim.new(1, 0))
	
	-- Logic
	function NewToggle:Set(Value)
		self.Value = Value
		
		if Value then
			Creator.Tween(self.Switch, {BackgroundColor3 = Creator.Theme.Accent})
			Creator.Tween(self.Knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Creator.Theme.Text})
		else
			Creator.Tween(self.Switch, {BackgroundColor3 = Creator.Theme.Background})
			Creator.Tween(self.Knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Creator.Theme.SubText})
		end
		
		self.Callback(Value)
	end
	
	NewToggle.Frame.MouseButton1Click:Connect(function()
		NewToggle:Set(not NewToggle.Value)
	end)
	
	-- Initial State
	NewToggle:Set(NewToggle.Value)
	
	return NewToggle
end

return Toggle
