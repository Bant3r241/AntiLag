local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Create GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AntiLaggerGUI"
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 150)
mainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true

-- Rounded corners for main frame
local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 12) -- Adjust radius as needed
mainFrameCorner.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Anti Lagger"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 OFF"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Toggle Button
local toggleButton = Instance.new("TextButton", mainFrame)
toggleButton.Size = UDim2.new(0.85, 0, 0, 40)
toggleButton.Position = UDim2.new(0.075, 0, 0.55, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Turn ON"
toggleButton.TextSize = 18
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true

-- Rounded corners for toggle button
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 8)
uicorner.Parent = toggleButton

-- Keybind Label
local keybindLabel = Instance.new("TextLabel", mainFrame)
keybindLabel.Size = UDim2.new(1, 0, 0, 20)
keybindLabel.Position = UDim2.new(0, 0, 1, -20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Press F to turn ON/OFF"
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
keybindLabel.TextSize = 14
keybindLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Anti-Lag Logic
local antiLagEnabled = false

local function isHugePart(part)
    local maxSize = 50 -- max allowed size in studs for any dimension
    return part.Size.X > maxSize or part.Size.Y > maxSize or part.Size.Z > maxSize
end

local function removeLagParts()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            -- Remove huge parts
            if isHugePart(obj) then
                obj:Destroy()
            -- Remove invisible and unanchored parts (often spam)
            elseif obj.Transparency == 1 and not obj.Anchored then
                obj:Destroy()
            -- Remove Neon parts (can cause lag)
            elseif obj.Material == Enum.Material.Neon then
                obj:Destroy()
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        elseif obj:IsA("Decal") then
            -- Remove Decals with low transparency (very visible)
            if obj.Transparency < 0.2 then
                obj:Destroy()
            end
        elseif obj:IsA("Sound") then
            obj:Stop()
        end
    end
end

local function updateUI()
    if antiLagEnabled then
        statusLabel.Text = "🟢 ON"
        toggleButton.Text = "Turn OFF"
    else
        statusLabel.Text = "🔴 OFF"
        toggleButton.Text = "Turn ON"
    end
end

-- Toggle Function
local function toggleAntiLag()
    antiLagEnabled = not antiLagEnabled
    updateUI()
    if antiLagEnabled then
        print("Anti-Lagging Started: Blocking Laggers...")
    else
        print("Anti-Lagging Stopped.")
    end
end

-- Button Click
toggleButton.MouseButton1Click:Connect(toggleAntiLag)

-- Keybind (F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleAntiLag()
    end
end)

-- FPS Boost function
local function boostFPS()
    -- Lower graphics quality (0 is lowest, 10 highest)
    pcall(function()
        UserSettings().Rendering.QualityLevel = 1
    end)

    -- Turn off shadows
    Lighting.GlobalShadows = false

    -- Reduce ambient light to lower rendering load
    Lighting.Ambient = Color3.fromRGB(100, 100, 100)
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
end

boostFPS()

-- Loop to remove laggy parts
task.spawn(function()
    while true do
        if antiLagEnabled then
            removeLagParts()
        end
        task.wait(0.5)
    end
end)

-- Initialize UI state
updateUI()

-- Dragging logic
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)
