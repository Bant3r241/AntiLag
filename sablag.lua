-- LocalScript
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

-- Create a Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -100, 0.5, -25)  -- Center it on screen
toggleButton.Text = "OFF"  -- Default text
toggleButton.Parent = screenGui

-- Set button properties
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red background
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)    -- White text
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 30

-- Boolean to track toggle state
local isOn = false

-- Anti-lag functionality
local antiLagEnabled = false

-- Function to remove unwanted parts (anti-lag)
local function removeUnwantedParts()
    -- Example: Remove all parts with a specific name
    for _, object in pairs(workspace:GetChildren()) do
        if object:IsA("Part") and object.Name == "UnwantedPart" then
            object:Destroy()
        end
    end
end

-- Function to toggle the button's state
local function toggle()
    isOn = not isOn
    if isOn then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- Green background
        antiLagEnabled = true
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red background
        antiLagEnabled = false
    end
end

-- Function to manage the anti-lag while the button is "ON"
local function antiLagLoop()
    while antiLagEnabled do
        -- Remove unwanted parts every frame
        removeUnwantedParts()
        wait(0.5)  -- Check every half second to reduce CPU usage
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
        wait(0.1)  -- Keep the loop running
    end
end)
