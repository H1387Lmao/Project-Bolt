# Project-Bolt
Project Bolt is a framework for making guis like admin panels easily

# Examples

```lua
local module = game:GetService("ReplicatedStorage"):WaitForChild("ProjectBolt")
local pb = require(module)

local bolt = pb.init(game.Players.LocalPlayer)
st=bolt:CreateCategory("Settings")
ctrls=bolt:CreateCategory("Controls")
bolt:show()

bolt:add_option(st, "Enable Music", "CheckBox", true, function(new)
	print("Music enabled:", new)
end)

bolt:add_option(st, "Enable Sounds", "CheckBox", true, function(new)
	print("Sounds enabled:", new)
end)

bolt:add_option(ctrls, "Camera Mode", "Choices", {"First Person", "Third Person"}, function(val)
	print("Camera mode set to:", val)
end)
```

<img width="1360" height="728" alt="image" src="https://github.com/user-attachments/assets/adac02b5-86ca-428c-a7a3-3b5c976b2404" />

# Usage

You are all free to use this module for any means, just credit me (by not removing my names associated to this

# Contributions

You are all free to contribute to this project to make this look better and function better
