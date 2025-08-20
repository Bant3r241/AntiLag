local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true

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

-- Status Indicator (Dot + Text)
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 OFF"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextWrapped = true
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

-- Logic
local antiLagEnabled = false

local function removeLagParts()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Part") and obj.Name == "UnwantedPart" then
            obj:Destroy()
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

toggleButton.MouseButton1Click:Connect(function()
    antiLagEnabled = not antiLagEnabled
    updateUI()
    if antiLagEnabled then
        print("Anti-Lagging Started: Blocking Laggers...")
    else
        print("Anti-Lagging Stopped.")
    end
end)

-- Keybind Support (F to toggle)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleButton:Activate()
    end
end)

-- Anti-Lag Loop
task.spawn(function()
    while true do
        if antiLagEnabled then
            removeLagParts()
        end
        task.wait(0.5)
    end
end)

-- Initial UI setup
updateUI()
