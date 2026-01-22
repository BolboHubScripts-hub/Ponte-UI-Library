--[[
    Ponte UI Library
    Bundled Version
    
    Usage:
    local Ponte = loadstring(game:HttpGet(".../main.lua"))()
    local Window = Ponte:CreateWindow(...)
]]

local Modules = {}

--// Utils //--
local function Require(Name)
    return Modules[Name]
end

--// Module: Creator //--
Modules["Creator"] = (function()
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
end)()

--// Module: Button //--
Modules["Button"] = (function()
    local Creator = Require("Creator")

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
            Image = "rbxassetid://6034818372",
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -30, 0.5, -10),
            BackgroundTransparency = 1,
            Visible = false, 
            Parent = NewButton.Frame
        })
        
        -- Hover Effects
        NewButton.Frame.MouseEnter:Connect(function()
            Creator.Tween(NewButton.Frame, {BackgroundColor3 = Creator.Theme.SectionBackground})
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
end)()

--// Module: Toggle //--
Modules["Toggle"] = (function()
    local Creator = Require("Creator")

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
end)()

--// Module: Slider //--
Modules["Slider"] = (function()
    local UserInputService = game:GetService("UserInputService")
    local Creator = Require("Creator")

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
end)()

--// Module: Dropdown //--
Modules["Dropdown"] = (function()
    local Creator = Require("Creator")

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
end)()

--// Module: Label //--
Modules["Label"] = (function()
    local Creator = Require("Creator")

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
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Parent = Container.Content
        })
        
        return NewLabel
    end

    return Label
end)()

--// Module: Section //--
Modules["Section"] = (function()
    local Creator = Require("Creator")
    
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
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Creator.Theme.SectionBackground,
            BorderSizePixel = 0,
            ClipsDescendants = true
        })
        Creator.AddCorner(NewSection.Frame)
        
        -- Header Button
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
        
        -- Chevron
        NewSection.Chevron = Creator.New("ImageLabel", {
            Image = "rbxassetid://6034818372",
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -25, 0.5, -10),
            BackgroundTransparency = 1,
            Rotation = 0,
            Parent = NewSection.Header
        })
        
        -- Content
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
            local ContentHeight = List.AbsoluteContentSize.Y + 20
            NewSection.Content.Size = UDim2.new(1, 0, 0, ContentHeight)
            if NewSection.Open then
                NewSection.Frame.Size = UDim2.new(1, 0, 0, ContentHeight + 30)
            end
        end)
        
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

    function Section:AddButton(Config)
        return Require("Button").New(Config, self)
    end

    function Section:AddToggle(Config)
        return Require("Toggle").New(Config, self)
    end

    function Section:AddSlider(Config)
        return Require("Slider").New(Config, self)
    end

    function Section:AddDropdown(Config)
        return Require("Dropdown").New(Config, self)
    end

    function Section:AddLabel(Config)
        return Require("Label").New(Config, self)
    end

    return Section
end)()

--// Module: Tab //--
Modules["Tab"] = (function()
    local Creator = Require("Creator")
    local Section = Require("Section") -- We don't have Section yet... WAIT. Section needs to be defined before Tab. Fixed.

    local Tab = {}
    Tab.__index = Tab

    function Tab.New(Config, Window)
        local NewTab = setmetatable({}, Tab)
        
        NewTab.Window = Window
        NewTab.Title = Config.Title or "Tab"
        NewTab.Icon = Config.Icon or "" 
        NewTab.Selected = false
        
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
        
        NewTab.TabButton.MouseButton1Click:Connect(function()
            NewTab:Select()
        end)
        
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
        
        NewTab.ContentFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            NewTab.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, NewTab.ContentFrame.UIListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        return NewTab
    end

    function Tab:Select()
        for _, OtherTab in pairs(self.Window.Tabs) do
            OtherTab.Selected = false
            OtherTab.TabButton.BackgroundTransparency = 1
            OtherTab.TabLabel.TextColor3 = Creator.Theme.SubText
            OtherTab.ContentFrame.Visible = false
        end
        
        self.Selected = true
        self.TabButton.BackgroundTransparency = 0
        self.TabButton.BackgroundColor3 = Creator.Theme.ElementBackground
        self.TabLabel.TextColor3 = Creator.Theme.Text
        self.ContentFrame.Visible = true
    end

    function Tab:AddSection(Config)
        local NewSection = Section.New(Config, self)
        NewSection.Frame.Parent = self.ContentFrame
        return NewSection
    end

    return Tab
end)()

--// Module: Window //--
Modules["Window"] = (function()
    local Creator = Require("Creator")
    local Tab = Require("Tab")

    local Window = {}
    Window.__index = Window

    function Window.New(Config)
        local NewWindow = setmetatable({}, Window)
        
        NewWindow.Config = Config or {}
        NewWindow.Title = NewWindow.Config.Title or "Ponte UI"
        NewWindow.SubTitle = NewWindow.Config.SubTitle or ""
        NewWindow.Size = NewWindow.Config.Size or UDim2.fromOffset(580, 460)
        
        NewWindow.Tabs = {}
        
        NewWindow.ScreenGui = Creator.New("ScreenGui", {
            Name = "PonteUI",
            Parent = game.CoreGui,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        
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
        
        Creator.New("Frame", {
            Name = "Patch",
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(1, -10, 0, 0),
            BackgroundColor3 = Creator.Theme.SectionBackground,
            BorderSizePixel = 0,
            Parent = NewWindow.Sidebar
        })
        
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
        
        NewTab.TabButton.Parent = self.TabContainer
        NewTab.ContentFrame.Parent = self.ContentContainer
        
        if #self.Tabs == 1 then
            NewTab:Select()
        end
        
        return NewTab
    end

    return Window
end)()

--// Main Ponte Module //--
local Ponte = {
    Version = "1.0.0"
}
local Window = Require("Window")

function Ponte:CreateWindow(Config)
    return Window.New(Config)
end

return Ponte
