local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Create GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "AntiLaggerGUI"
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 170)
mainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
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

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 ON"
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
toggleButton.Text = "Turn OFF"
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

-- Anti-Lag and FPS Boost Logic
local antiLagEnabled = true  -- Turn ON by default

local function removeLagParts()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Part") then
            if obj.Name == "UnwantedPart" then
                obj:Destroy()
            elseif obj.Size.X > 100 or obj.Size.Y > 100 or obj.Size.Z > 100 then
                obj:Destroy()
            elseif obj.Transparency > 0.95 and obj.Anchored == false then
                obj:Destroy()
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") then
            obj.Enabled = false
        elseif obj:IsA("Decal") then
            if obj.Transparency < 0.1 then
                obj:Destroy()
            end
        end
    end
end

local function boostFPS()
    pcall(function()
        if UserSettings().GameSettings then
            UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.Level1
            UserSettings().GameSettings.GraphicsQualityLevel = 1
        end
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.FogEnd = 1000

        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") then
                effect.Enabled = false
            end
        end

        if RunService.Set3dRenderingEnabled then
            RunService:Set3dRenderingEnabled(true)
        end
    end)
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

local function toggleAntiLag()
    antiLagEnabled = not antiLagEnabled
    updateUI()
    if antiLagEnabled then
        print("Anti-Lagging Started: Blocking Laggers and boosting FPS...")
        boostFPS()
    else
        print("Anti-Lagging Stopped.")
        -- Optional: add revert FPS changes here
    end
end

toggleButton.MouseButton1Click:Connect(toggleAntiLag)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleAntiLag()
    end
end)

task.spawn(function()
    while true do
        if antiLagEnabled then
            removeLagParts()
        end
        task.wait(0.5)
    end
end)

-- Initialize UI and start boost immediately
updateUI()
print("Anti-Lagging Started: Blocking Laggers and boosting FPS...")
boostFPS()
