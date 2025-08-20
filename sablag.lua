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
mainFrame.Size = UDim2.new(0, 280, 0, 150)
mainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

-- Rounded corners for main frame
local mainUICorner = Instance.new("UICorner")
mainUICorner.CornerRadius = UDim.new(0, 8)
mainUICorner.Parent = mainFrame

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
local antiLagEnabled = true -- ON by default

-- Track part spawns with timestamps
local spawnTracker = {}
local SPAM_THRESHOLD = 10
local TIME_WINDOW = 3 -- seconds

-- Helper: clean old timestamps
local function cleanOldEntries(timestamps)
    local now = tick()
    for i = #timestamps, 1, -1 do
        if now - timestamps[i] > TIME_WINDOW then
            table.remove(timestamps, i)
        end
    end
end

local function trackPartSpawn(part)
    if not (part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation")) then return end

    local name = part.Name
    spawnTracker[name] = spawnTracker[name] or {}

    -- Insert current time
    table.insert(spawnTracker[name], tick())
    cleanOldEntries(spawnTracker[name])

    -- If over threshold, remove this new part
    if #spawnTracker[name] > SPAM_THRESHOLD then
        if part and part.Parent then
            part:Destroy()
            print("AntiLag: Removed spam part", name)
            -- Remove the timestamp for destroyed part since it no longer exists
            table.remove(spawnTracker[name])
        end
    end
end

local function removeLagParts()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        elseif obj:IsA("Decal") then
            if obj.Transparency < 0.2 then
                obj:Destroy()
            end
        elseif obj:IsA("Sound") then
            obj:Stop()
        end
    end
end

local function disablePostProcessing()
    for _, effectClass in ipairs({"BloomEffect", "BlurEffect", "SunRaysEffect", "ColorCorrectionEffect", "DepthOfFieldEffect"}) do
        local effect = Lighting:FindFirstChildOfClass(effectClass)
        if effect then
            effect.Enabled = false
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

-- Connect ChildAdded to track new parts spawning
workspace.ChildAdded:Connect(function(child)
    if antiLagEnabled then
        -- Delay a tiny bit to allow part properties to settle
        task.defer(function()
            trackPartSpawn(child)
        end)
    end
end)

-- Main anti-lag loop
task.spawn(function()
    while true do
        if antiLagEnabled then
            removeLagParts()
            disablePostProcessing()
        end
        task.wait(0.5)
    end
end)

-- Initialize UI state
updateUI()
