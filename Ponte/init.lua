local Ponte = {
	Version = "1.0.0"
}

local Components = script.Components
local Window = require(Components.Window)

function Ponte:CreateWindow(Config)
	return Window.New(Config)
end

return Ponte
