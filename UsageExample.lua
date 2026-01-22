local Ponte = require(script.Parent.Ponte)

local Window = Ponte:CreateWindow({
	Title = "Ponte UI Library",
	SubTitle = "Example Script",
	Size = UDim2.fromOffset(580, 460)
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "" })
}

local MainSection = Tabs.Main:AddSection({
	Title = "Main Section"
})

MainSection:AddLabel({
	Title = "This is a label testing the new UI library!"
})

MainSection:AddButton({
	Title = "Click Me!",
	Callback = function()
		print("Button Clicked!")
	end
})

MainSection:AddToggle({
	Title = "Enable Features",
	Default = false,
	Callback = function(Value)
		print("Toggle is now:", Value)
	end
})

MainSection:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(Value)
        print("WalkSpeed set to:", Value)
    end
})

MainSection:AddDropdown({
    Title = "Select Team",
    Values = {"Red", "Blue", "Green", "Yellow"},
    Default = 1,
    Callback = function(Value)
        print("Selected Team:", Value)
    end
})

local SettingsSection = Tabs.Settings:AddSection({
    Title = "Configuration"
})

SettingsSection:AddToggle({
    Title = "Dark Mode",
    Default = true,
    Callback = function(Value)
        print("Dark Mode:", Value)
    end
})
