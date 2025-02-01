local ReplicatedStorage = game:GetService("ReplicatedStorage")
local replicationEvent = ReplicatedStorage:WaitForChild("Replication")

-- Helper function to convert table to string, including nested tables
local function tableToString(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        local valueStr
        if type(v) == "table" then
            valueStr = tableToString(v)
        else
            valueStr = tostring(v)
        end
        result = result .. tostring(k) .. "=" .. valueStr .. ", "
    end
    return result .. "}"
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local HistoryFrame = Instance.new("ScrollingFrame")
local ToggleButton = Instance.new("TextButton")
local ClearButton = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(1, -320, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "RemoteEvent Logger"
Title.Parent = MainFrame

-- Add Clear Button
ClearButton.Size = UDim2.new(0, 80, 0, 30)
ClearButton.Position = UDim2.new(0.8, -50, 0, 35)
ClearButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearButton.Text = "Clear All"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.Parent = MainFrame

HistoryFrame.Size = UDim2.new(1, 0, 1, -70)
HistoryFrame.Position = UDim2.new(0, 0, 0, 70)
HistoryFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
HistoryFrame.BorderSizePixel = 0
HistoryFrame.ScrollBarThickness = 8
HistoryFrame.Parent = MainFrame

ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0.2, -50, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ToggleButton.Text = "Listening"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = MainFrame

-- Variables
local isListening = true
local eventHistory = {}

-- Clear button functionality
ClearButton.MouseButton1Click:Connect(function()
    for _, item in pairs(HistoryFrame:GetChildren()) do
        item:Destroy()
    end
    eventHistory = {}
    HistoryFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Toggle button functionality
ToggleButton.MouseButton1Click:Connect(function()
    isListening = not isListening
    ToggleButton.BackgroundColor3 = isListening and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    ToggleButton.Text = isListening and "Listening" or "Stopped"
end)

-- Function to add new event to history
local function addEventToHistory(params, effectName)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, (#eventHistory * 45))
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.Text = effectName or "Unnamed Event"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = HistoryFrame
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end)
    
    button.MouseButton1Click:Connect(function()
        local detailsFrame = Instance.new("Frame")
        detailsFrame.Size = UDim2.new(0, 300, 0, 200)
        detailsFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
        detailsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        detailsFrame.Parent = ScreenGui
        
        local detailsText = Instance.new("TextLabel")
        detailsText.Size = UDim2.new(1, -20, 1, -20)
        detailsText.Position = UDim2.new(0, 10, 0, 10)
        detailsText.BackgroundTransparency = 1
        detailsText.TextColor3 = Color3.fromRGB(255, 255, 255)
        detailsText.TextXAlignment = Enum.TextXAlignment.Left
        detailsText.TextYAlignment = Enum.TextYAlignment.Top
        detailsText.Text = params
        detailsText.TextWrapped = true
        detailsText.Parent = detailsFrame
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 20, 0, 20)
        closeButton.Position = UDim2.new(1, -25, 0, 5)
        closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        closeButton.Text = "X"
        closeButton.Parent = detailsFrame
        
        closeButton.MouseButton1Click:Connect(function()
            detailsFrame:Destroy()
        end)
    end)
    
    table.insert(eventHistory, params)
    HistoryFrame.CanvasSize = UDim2.new(0, 0, 0, #eventHistory * 45 + 5)
end

-- Connect to RemoteEvent
replicationEvent.OnClientEvent:Connect(function(...)
    if not isListening then return end
    
    local args = {...}
    local printableArgs = {}
    local effectName
    
    for i, arg in ipairs(args) do
        if typeof(arg) == "table" then
            if arg.Effect then
                effectName = tostring(arg.Effect)
            end
            printableArgs[i] = "Table: " .. tableToString(arg)
        else
            printableArgs[i] = tostring(arg)
        end
    end
    
    local currentParams = table.concat(printableArgs, " | ")
    addEventToHistory(currentParams, effectName)
end)
