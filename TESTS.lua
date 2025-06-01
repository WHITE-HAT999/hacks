local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Interface
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "PowerMenu"
gui.ResetOnSpawn = false

-- Menu principal
local mainMenu = Instance.new("Frame", gui)
mainMenu.Size = UDim2.new(0, 200, 0, 235)
mainMenu.Position = UDim2.new(0, 20, 0, 100)
mainMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Noir
mainMenu.Visible = true
local listLayout = Instance.new("UIListLayout", mainMenu)
listLayout.Padding = UDim.new(0, 6)

-- Sous-menu
local subMenu = Instance.new("Frame", gui)
subMenu.Size = UDim2.new(0, 220, 0, 150)
subMenu.Position = UDim2.new(0, 230, 0, 100)
subMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Noir
subMenu.Visible = false
Instance.new("UIListLayout", subMenu).Padding = UDim.new(0, 5)

-- Toggle GUI
UIS.InputBegan:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.F then
		mainMenu.Visible = not mainMenu.Visible
		subMenu.Visible = false
	end
end)

local function createButton(text, parent, backgroundColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 20
	btn.BackgroundColor3 = backgroundColor or Color3.fromRGB(0, 255, 0)  -- Vert
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0
	btn.Parent = parent
	return btn
end

local function clearSubMenu()
	for _, child in pairs(subMenu:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

-- === VOLER ===
local flying = false
local flyVelocity
local flyDirection = Vector3.zero

local function setupFlyMenu()
	clearSubMenu()
	subMenu.Visible = true

	local toggle = createButton("Activer Vol", subMenu)
	toggle.MouseButton1Click:Connect(function()
		flying = not flying
		toggle.Text = flying and "Désactiver Vol" or "Activer Vol"

		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")

		if flying then
			flyVelocity = Instance.new("BodyVelocity")
			flyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e9
			flyVelocity.Velocity = Vector3.zero
			flyVelocity.P = 10000
			flyVelocity.Parent = hrp

			RunService:BindToRenderStep("Flying", Enum.RenderPriority.Input.Value, function()
				if flying and flyVelocity then
					flyVelocity.Velocity = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(flyDirection)) * 80
				end
			end)
		else
			RunService:UnbindFromRenderStep("Flying")
			if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
		end
	end)
end

UIS.InputBegan:Connect(function(input, gp)
	if not flying then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then flyDirection += Vector3.new(0, 0, -1) end
	if key == Enum.KeyCode.S then flyDirection += Vector3.new(0, 0, 1) end
	if key == Enum.KeyCode.A then flyDirection += Vector3.new(-1, 0, 0) end
	if key == Enum.KeyCode.D then flyDirection += Vector3.new(1, 0, 0) end
	if key == Enum.KeyCode.E then flyDirection += Vector3.new(0, 1, 0) end
	if key == Enum.KeyCode.Q then flyDirection += Vector3.new(0, -1, 0) end
end)

UIS.InputEnded:Connect(function(input)
	if not flying then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then flyDirection -= Vector3.new(0, 0, -1) end
	if key == Enum.KeyCode.S then flyDirection -= Vector3.new(0, 0, 1) end
	if key == Enum.KeyCode.A then flyDirection -= Vector3.new(-1, 0, 0) end
	if key == Enum.KeyCode.D then flyDirection -= Vector3.new(1, 0, 0) end
	if key == Enum.KeyCode.E then flyDirection -= Vector3.new(0, 1, 0) end
	if key == Enum.KeyCode.Q then flyDirection -= Vector3.new(0, -1, 0) end
end)

-- === XRAY ===
local xrayEnabled = false

local function setupXrayMenu()
	clearSubMenu()
	subMenu.Visible = true

	local toggle = createButton("Activer X-Ray", subMenu)
	toggle.MouseButton1Click:Connect(function()
		xrayEnabled = not xrayEnabled
		toggle.Text = xrayEnabled and "Désactiver X-Ray" or "Activer X-Ray"

		for _, part in ipairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
				if xrayEnabled then
					part.LocalTransparencyModifier = 0.8
				else
					part.LocalTransparencyModifier = 0
				end
			end
		end
	end)
end

-- === VITESSE ===
local speedEnabled = false
local walkSpeed = 16

local function setupSpeedMenu()
	clearSubMenu()
	subMenu.Visible = true

	local toggle = createButton("Activer Vitesse", subMenu)
	local speedUp = createButton("↑ Vitesse", subMenu)
	local speedDown = createButton("↓ Vitesse", subMenu)

	toggle.MouseButton1Click:Connect(function()
		speedEnabled = not speedEnabled
		toggle.Text = speedEnabled and "Désactiver Vitesse" or "Activer Vitesse"
		LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and walkSpeed or 16
	end)

	speedUp.MouseButton1Click:Connect(function()
		if speedEnabled then
			walkSpeed += 5
			LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
		end
	end)

	speedDown.MouseButton1Click:Connect(function()
		if speedEnabled and walkSpeed > 10 then
			walkSpeed -= 5
			LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
		end
	end)
end

-- === GODMODE ===
local godModeEnabled = false

local function setupGodModeMenu()
	clearSubMenu()
	subMenu.Visible = true

	local toggle = createButton("Activer Godmode", subMenu)
	toggle.MouseButton1Click:Connect(function()
		godModeEnabled = not godModeEnabled
		toggle.Text = godModeEnabled and "Désactiver Godmode" or "Activer Godmode"

		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid = char:WaitForChild("Humanoid")

		if godModeEnabled then
			humanoid.Health = humanoid.MaxHealth  -- Réinitialise la santé
			humanoid.HealthChanged:Connect(function()
				if humanoid.Health < humanoid.MaxHealth then
					humanoid.Health = humanoid.MaxHealth  -- Réinitialise encore si la santé descend
				end
			end)
		end
	end)
end



-- === ESP ===
local espEnabled = false
local processedCharacters = {}
local NPCFolder = Workspace:FindFirstChild("NPCs") or Workspace

local function createESP(character, labelName, isNPC)
	if not character or processedCharacters[character] then return end
	local head = character:FindFirstChild("Head")
	if not head or head:FindFirstChild("ESP_GUI") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_GUI"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 20)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = espEnabled
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = labelName
	label.TextColor3 = isNPC and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = billboard

	processedCharacters[character] = billboard
end

local function updateESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			createESP(player.Character, player.Name, false)
		end
	end
	for _, model in ipairs(NPCFolder:GetDescendants()) do
		if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) and model:FindFirstChild("Humanoid") then
			createESP(model, model.Name, true)
		end
	end
end

local function setupESPMenu()
	clearSubMenu()
	subMenu.Visible = true

	local toggle = createButton("Activer ESP", subMenu)
	toggle.MouseButton1Click:Connect(function()
		espEnabled = not espEnabled
		toggle.Text = espEnabled and "Désactiver ESP" or "Activer ESP"

		for character, gui in pairs(processedCharacters) do
			if character and character:FindFirstChild("Head") then
				local espGui = character.Head:FindFirstChild("ESP_GUI")
				if espGui then
					espGui.Enabled = espEnabled
				end
			end
		end
	end)
end

RunService.RenderStepped:Connect(updateESP)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		wait(1)
		createESP(char, player.Name, false)
	end)
end)


-- === MENU PRINCIPAL ===
createButton("✈️ Voler ✈️", mainMenu).MouseButton1Click:Connect(setupFlyMenu)
createButton("👁️ X-Ray 👁️", mainMenu).MouseButton1Click:Connect(setupXrayMenu)
createButton("🏃‍♂️ Vitesse 🏃‍♂️", mainMenu).MouseButton1Click:Connect(setupSpeedMenu)
createButton("🛡️ Godmode 🛡️", mainMenu).MouseButton1Click:Connect(setupGodModeMenu)
createButton("👁️ ESP 👁️", mainMenu).MouseButton1Click:Connect(setupESPMenu)
