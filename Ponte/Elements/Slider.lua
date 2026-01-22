local UserInputService = game:GetService("UserInputService")
local Creator = require(script.Parent.Parent.Creator)

local Slider = {}
Slider.__index = Slider

function Slider.New(Config, Container)
	local NewSlider = setmetatable({}, Slider)
	
	NewSlider.Container = Container
	NewSlider.Title = Config.Title or "Slider"
	NewSlider.Min = Config.Min or 0
	NewSlider.Max = Config.Max or 100
	NewSlider.Value = Config.Default or NewSlider.Min
	NewSlider.Callback = Config.Callback or function() end
	
	NewSlider.Frame = Creator.New("Frame", {
		Name = "Slider",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Creator.Theme.ElementBackground,
		Parent = Container.Content
	})
	Creator.AddCorner(NewSlider.Frame)
	
	NewSlider.Label = Creator.New("TextLabel", {
		Name = "Title",
		Text = NewSlider.Title,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Parent = NewSlider.Frame
	})
	
	NewSlider.ValueLabel = Creator.New("TextLabel", {
		Name = "Value",
		Text = tostring(NewSlider.Value),
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Creator.Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Parent = NewSlider.Frame
	})
	
	-- Slide Bar/Track
	NewSlider.Track = Creator.New("Frame", {
		Name = "Track",
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.new(0, 10, 0, 30),
		BackgroundColor3 = Creator.Theme.Background,
		Parent = NewSlider.Frame
	})
	Creator.AddCorner(NewSlider.Track, UDim.new(1, 0))
	
	-- Fill
	NewSlider.Fill = Creator.New("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Creator.Theme.Accent,
		Parent = NewSlider.Track
	})
	Creator.AddCorner(NewSlider.Fill, UDim.new(1, 0))
	Creator.AddGradient(NewSlider.Fill)
	
	-- Sliding Logic
	local Dragging = false
	
	local function Update(Input)
		local SizeX = math.clamp((Input.Position.X - NewSlider.Track.AbsolutePosition.X) / NewSlider.Track.AbsoluteSize.X, 0, 1)
		local Value = math.floor(NewSlider.Min + ((NewSlider.Max - NewSlider.Min) * SizeX))
		
		NewSlider:Set(Value)
	end
	
	function NewSlider:Set(Value)
		self.Value = math.clamp(Value, self.Min, self.Max)
		self.ValueLabel.Text = tostring(self.Value)
		
		local Percent = (self.Value - self.Min) / (self.Max - self.Min)
		Creator.Tween(self.Fill, {Size = UDim2.fromScale(Percent, 1)}, 0.05)
		
		self.Callback(self.Value)
	end
	
	NewSlider.Frame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			Update(Input)
		end
	end)
	
	NewSlider.Frame.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			Update(Input)
		end
	end)
	
	-- Init
	NewSlider:Set(NewSlider.Value)
	
	return NewSlider
end

return Slider
