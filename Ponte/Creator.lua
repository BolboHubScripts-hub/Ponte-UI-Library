local TweenService = game:GetService("TweenService")

local Creator = {}

-- Theme Interface
Creator.Theme = {
	Accent = Color3.fromRGB(0, 255, 255), -- Light Blue
	GradientStart = Color3.fromRGB(0, 200, 255),
	GradientEnd = Color3.fromRGB(0, 100, 200),
	
	Background = Color3.fromRGB(15, 15, 15), -- Black/Dark
	SectionBackground = Color3.fromRGB(25, 25, 25),
	ElementBackground = Color3.fromRGB(35, 35, 35),
	
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(170, 170, 170),
	
	CornerRadius = UDim.new(0, 6)
}

function Creator.New(ClassName, Properties, Children)
	local Instance = Instance.new(ClassName)
	
	for Property, Value in pairs(Properties or {}) do
		if Property ~= "Parent" then
			Instance[Property] = Value
		end
	end
	
	for _, Child in pairs(Children or {}) do
		Child.Parent = Instance
	end
	
	if Properties.Parent then
		Instance.Parent = Properties.Parent
	end
	
	return Instance
end

function Creator.AddCorner(Instance, Radius)
	local Corner = Creator.New("UICorner", {
		CornerRadius = Radius or Creator.Theme.CornerRadius,
		Parent = Instance
	})
	return Corner
end

function Creator.AddStroke(Instance, Color, Thickness, Transparency)
	local Stroke = Creator.New("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color or Color3.fromRGB(50, 50, 50),
		Thickness = Thickness or 1,
		Transparency = Transparency or 0,
		Parent = Instance
	})
	return Stroke
end

function Creator.AddPadding(Instance, Padding)
    local Pad = Creator.New("UIPadding", {
        PaddingTop = UDim.new(0, Padding),
        PaddingBottom = UDim.new(0, Padding),
        PaddingLeft = UDim.new(0, Padding),
        PaddingRight = UDim.new(0, Padding),
        Parent = Instance
    })
    return Pad
end

function Creator.AddGradient(Instance)
	local Gradient = Creator.New("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Creator.Theme.GradientStart),
			ColorSequenceKeypoint.new(1, Creator.Theme.GradientEnd)
		},
		Rotation = 45,
		Parent = Instance
	})
	return Gradient
end

function Creator.Tween(Instance, Properties, Time)
	local TweenInfo = TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Tween = TweenService:Create(Instance, TweenInfo, Properties)
	Tween:Play()
	return Tween
end

function Creator.Drag(Frame, DragHandle)
    local UserInputService = game:GetService("UserInputService")
	local Dragging, DragInput, DragStart, StartPos

	local function Update(Input)
		local Delta = Input.Position - DragStart
		Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
	end
    
    DragHandle = DragHandle or Frame

	DragHandle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPos = Frame.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	DragHandle.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)
end

return Creator
