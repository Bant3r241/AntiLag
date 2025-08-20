-- LocalScript for Anti-Lag GUI with Console Output
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.Name = "AntiLaggerGui"

-- Create a Main Frame for the GUI
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add a Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "AntiLagger"
titleLabel.TextSize = 30
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextStrokeTransparency = 0.8
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = mainFrame

-- Create a Toggle Button for Anti-Lag
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -100, 0.5, -25)  -- Center it in the middle of the frame
toggleButton.Text = "OFF"
toggleButton.TextSize = 24
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.BackgroundTransparency = 0.1
toggleButton.BorderSizePixel = 0
toggleButton.Parent = mainFrame

-- Boolean to track toggle state and anti-lag status
local isOn = false
local antiLagEnabled = false

-- Function to remove unwanted parts (anti-lag feature)
local function removeUnwantedParts()
    for _, object in pairs(workspace:GetChildren()) do
        if object:IsA("Part") and object.Name == "UnwantedPart" then
            object:Destroy()
        end
    end
end

-- Function to toggle button text and anti-lag state
local function toggle()
    isOn = not isOn
    if isOn then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- Green background for ON state
        antiLagEnabled = true
        print("Anti-Lagging Started: Blocking Laggers...")  -- Console message when anti-lag starts
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red background for OFF state
        antiLagEnabled = false
        print("Anti-Lagging Stopped: Lag Blocker Disabled.")  -- Console message when anti-lag stops
    end
end

-- Function to manage the anti-lag while the button is "ON"
local function antiLagLoop()
    while antiLagEnabled do
        removeUnwantedParts()  -- Call the anti-lag function to remove parts
        wait(0.5)  -- Check every 0.5 seconds to reduce performance impact
    end
end

-- Connect the toggle function to the button click
toggleButton.MouseButton1Click:Connect(toggle)

-- Start anti-lag loop
spawn(function()
    while true do
        if antiLagEnabled then
            antiLagLoop()
        end
        wait(0.1)  -- Ensure loop runs consistently but doesn't overload the system
    end
end)
