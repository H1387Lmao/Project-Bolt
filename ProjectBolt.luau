local projectbolt = {}
projectbolt.__index = projectbolt

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function projectbolt.init(player: Player)
	local self = setmetatable({}, projectbolt)
	self.player = player
	self.categories = {}
	self.frames = {}
	self.minimized = false
	return self
end

function projectbolt:exists()
	for _, v in ipairs(self.player.PlayerGui:GetChildren()) do
		if v.Name == "ProjectBolt" then return true end
	end
	return false
end

function projectbolt:generate_gui()
	if self:exists() then return end

	local screenGUI = Instance.new("ScreenGui")
	screenGUI.Name = "ProjectBolt"
	screenGUI.ResetOnSpawn = false

	local loadingFrame = Instance.new("Frame")
	loadingFrame.Name = "Frame"
	loadingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	loadingFrame.Position = UDim2.fromScale(0.5, 0.5)
	loadingFrame.Size = UDim2.fromScale(0, 0)
	loadingFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	loadingFrame.BorderSizePixel = 0
	loadingFrame.Parent = screenGUI

	Instance.new("UICorner", loadingFrame)

	local loadingText = Instance.new("TextLabel")
	loadingText.Name = "TextLabel"
	loadingText.Size = UDim2.fromScale(0, 0)
	loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
	loadingText.Position = UDim2.fromScale(0.5, 0.5)
	loadingText.BackgroundTransparency = 1
	loadingText.TextScaled = true
	loadingText.TextStrokeTransparency = 1
	loadingText.Text = "Project Bolt Loading."
	loadingText.TextColor3 = Color3.new(0.3, 0.3, 0.8)
	loadingText.Parent = loadingFrame

	return screenGUI
end

function projectbolt:CreateCategory(name)
	local category = {name = name}
	table.insert(self.categories, category)
	return category
end

function projectbolt:add_option(category_table, display, option_type, initial, callback)
	local frame = self.frames[category_table]
	if not frame then return end

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = frame

	-- Label first
	local label = Instance.new("TextLabel")
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Text = display
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.SourceSans
	label.TextSize = 18
	label.Parent = container

	if option_type == "CheckBox" then
		local box = Instance.new("TextButton")
		box.Size = UDim2.new(0, 20, 0, 20)
		box.Position = UDim2.new(0, 0, 0.5, -10) -- temporarily set
		box.BackgroundColor3 = initial and Color3.new(0.2, 0.6, 1) or Color3.new(0.2, 0.2, 0.2)
		box.Text = ""
		box.Parent = container
		Instance.new("UICorner", box)

		-- Adjust position after label is sized
		label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			box.Position = UDim2.new(0, label.AbsoluteSize.X + 10, 0.5, -10)
		end)

		local state = initial
		box.MouseButton1Click:Connect(function()
			state = not state
			box.BackgroundColor3 = state and Color3.new(0.2, 0.6, 1) or Color3.new(0.2, 0.2, 0.2)
			if callback then callback(state) end
		end)

	elseif option_type == "Choices" and typeof(initial) == "table" then
		local choices = initial
		local index = 1


		local choiceBtn = #choices ~= 1 and Instance.new("TextButton") or Instance.new("TextLabel")
		choiceBtn.Size = UDim2.new(0, 100, 0, 25)
		choiceBtn.Position = UDim2.new(0, 0, 0.5, -12) -- temporarily set
		choiceBtn.Text = choices[index]
		choiceBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		choiceBtn.TextColor3 = Color3.new(1, 1, 1)
		choiceBtn.Font = Enum.Font.SourceSans
		choiceBtn.TextSize = 18
		choiceBtn.Parent = container
		Instance.new("UICorner", choiceBtn)

		label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			choiceBtn.Position = UDim2.new(0, label.AbsoluteSize.X + 10, 0.5, -12)
		end)

		if #choices ~= 1 then
			choiceBtn.MouseButton1Click:Connect(function()
				index = (index % #choices) + 1
				choiceBtn.Text = choices[index]
				if callback then callback(choices[index]) end
			end)
		end
	end
end

function projectbolt:close() 
	local gui = self.player.PlayerGui:FindFirstChild("ProjectBolt")
	if not gui then return end

	local frame = gui:FindFirstChild("Frame")
	if frame then
		local tweenClose = TweenService:Create(frame, TweenInfo.new(0.5), {
			Size = UDim2.fromScale(0, 0),
			Position = UDim2.fromScale(0.5, 0.5)
		})
		tweenClose:Play()
		tweenClose.Completed:Wait()
	end

	gui:Destroy()
end

function projectbolt:toggle_minimize()
	if not self.mainFrame then return end
	self.minimized = not self.minimized

	if self.minimized then
		-- Store current position and size before minimizing
		self.storedPosition = self.mainFrame.Position
		self.storedSize = self.mainFrame.Size

		-- Create minimize button
		local minBtn = Instance.new("TextButton")
		minBtn.Name = "MinimizedButton"
		minBtn.Size = UDim2.fromOffset(120, 40)
		minBtn.Position = UDim2.fromScale(0,0)
		minBtn.AnchorPoint = Vector2.new(0, 0)
		minBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
		minBtn.Text = "Project Bolt"
		minBtn.TextColor3 = Color3.new(1, 1, 1)
		minBtn.Font = Enum.Font.SourceSansBold
		minBtn.TextSize = 18
		minBtn.Parent = self.mainFrame.Parent
		minBtn.ZIndex = 100
		Instance.new("UICorner", minBtn)

		-- Click to restore (only when not dragging)
		minBtn.MouseButton1Click:Connect(function()
			if not isDragging then
				self:toggle_minimize()
			end
		end)

		-- Hide the main frame
		self.mainFrame.Visible = false
		self.minimizedButton = minBtn

	else
		-- Restore the main frame
		self.mainFrame.Visible = true
		self.mainFrame.Position = self.storedPosition
		self.mainFrame.Size = self.storedSize

		-- Remove the minimized button
		if self.minimizedButton then
			self.minimizedButton:Destroy()
			self.minimizedButton = nil
		end
	end
end

function projectbolt:show()
	while not game:IsLoaded() do task.wait() end
	task.wait(1)

	local gui = self:generate_gui()
	gui.Parent = self.player.PlayerGui

	local frame = gui.Frame
	self.mainFrame = frame  -- Store for later access
	
	frame.ClipsDescendants = true

	local tween = TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(0.5, 0.4)})
	local tweenText = TweenService:Create(frame.TextLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(0.8, 0.5)})

	tween:Play()
	tweenText:Play()
	tweenText.Completed:Wait()

	local fadeColor = frame.TextLabel.TextColor3
	for i = 1, 10 do
		local multiplier = 1 - 0.05 * i
		local newColor = Color3.new(fadeColor.R * multiplier, fadeColor.G * multiplier, fadeColor.B * multiplier)
		local flash = TweenService:Create(frame.TextLabel, TweenInfo.new(0.1), {TextColor3 = newColor})
		flash:Play()
		flash.Completed:Wait()
	end

	local tweenTextShrink = TweenService:Create(frame.TextLabel, TweenInfo.new(0.4), {Size = UDim2.fromScale(0, 0)})
	tweenTextShrink:Play()

	local tweenExpand = TweenService:Create(frame, TweenInfo.new(0.5), {Size = UDim2.fromScale(0.675, 0.9)})
	tweenExpand:Play()
	tweenExpand.Completed:Wait()

	-- Create top bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 30)
	topBar.BackgroundColor3 = Color3.new(0.25, 0.25, 0.3)
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 10
	topBar.Parent = frame

	-- Title
	local title = Instance.new("TextLabel")
	title.Text = "Project Bolt"
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 18
	title.Parent = topBar
	title.ZIndex = 100

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -30, 0, 0)
	closeBtn.BackgroundColor3 = Color3.new(0.3, 0.2, 0.2)
	closeBtn.BorderSizePixel = 0
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 24
	closeBtn.Parent = topBar
	closeBtn.ZIndex = 100

	-- Minimize button
	local minBtn = Instance.new("TextButton")
	minBtn.Text = "-"
	minBtn.Size = UDim2.new(0, 30, 0, 30)
	minBtn.Position = UDim2.new(1, -60, 0, 0)
	minBtn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.3)
	minBtn.BorderSizePixel = 0
	minBtn.TextColor3 = Color3.new(1, 1, 1)
	minBtn.Font = Enum.Font.SourceSansBold
	minBtn.TextSize = 24
	minBtn.Parent = topBar
	minBtn.ZIndex = 100

	-- Make draggable
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X,
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	-- Button functionality
	closeBtn.MouseButton1Click:Connect(function()
		self:close()
	end)

	minBtn.MouseButton1Click:Connect(function()
		self:toggle_minimize()
	end)

	-- Create category area below top bar
	local category_screen = Instance.new("ScrollingFrame")
	category_screen.Name = "Categories"
	category_screen.Parent = frame
	category_screen.Size = UDim2.fromScale(0.25, 1)
	category_screen.Position = UDim2.fromOffset(0, 30)  -- Below top bar
	category_screen.Size = UDim2.new(0.25, 0, 1, -30)  -- Account for top bar
	category_screen.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	category_screen.BorderSizePixel = 0
	category_screen.CanvasSize = UDim2.new(0, 0, 0, 0)
	category_screen.AutomaticCanvasSize = Enum.AutomaticSize.Y
	category_screen.ScrollBarThickness = 5
	Instance.new("UICorner", category_screen)

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 5)
	layout.Parent = category_screen
	
	

	-- Create categories BEFORE building UI elements
	local credits = self:CreateCategory("Info")

	-- Build category UI elements
	for i, category in ipairs(self.categories) do
		local btn = Instance.new("TextButton")
		local name = category.name
		btn.Text = name
		btn.Size = UDim2.new(1, -10, 0, 40)
		btn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 20
		btn.LayoutOrder = i
		btn.Parent = category_screen

		Instance.new("UICorner", btn)

		local categoryFrame = Instance.new("Frame")
		categoryFrame.Name = "Category_" .. name
		categoryFrame.Size = UDim2.new(0.75, 0, 1, -30)  -- Account for top bar
		categoryFrame.Position = UDim2.new(0.25, 0, 0, 30)  -- Below top bar
		categoryFrame.BackgroundTransparency = 1
		categoryFrame.Visible = i == 1
		categoryFrame.Parent = frame
		categoryFrame.ZIndex = i

		local categoryLayout = Instance.new("UIListLayout")
		categoryLayout.Parent = categoryFrame
		categoryLayout.FillDirection = Enum.FillDirection.Vertical
		categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
		categoryLayout.Padding = UDim.new(0, 5)

		self.frames[category] = categoryFrame

		btn.MouseButton1Click:Connect(function()
			for _, f in pairs(self.frames) do
				f.Visible = false
			end
			categoryFrame.Visible = true
		end)
	end

	-- Add credits option AFTER UI is built
	self:add_option(credits, "Project Bolt Created By", "Choices", {"noth1387"})
	-- Removed the "Close UI" button as requested
end
