-- Delta Executor Compatible Enhanced Mod Menu
-- Optimized for Delta and other mobile executors

print("🔄 Loading Delta-Compatible Mod Menu...")
wait(0.2)
print("📱 Optimized for mobile executors...")
wait(0.2)
print("✅ Delta compatibility enabled!")

-- Services (Delta-safe method)
local success, Players = pcall(function() return game:GetService("Players") end)
if not success then Players = game.Players end

local success, RunService = pcall(function() return game:GetService("RunService") end)
if not success then RunService = game["Run Service"] end

local success, UserInputService = pcall(function() return game:GetService("UserInputService") end)
if not success then UserInputService = game.UserInputService end

local success, TweenService = pcall(function() return game:GetService("TweenService") end)
if not success then TweenService = game.TweenService end

local success, CoreGui = pcall(function() return game:GetService("CoreGui") end)
if not success then CoreGui = game.CoreGui end

local LocalPlayer = Players.LocalPlayer

-- Configuration (Delta-optimized)
local config = {
    hitboxSize = 20,
    hitboxEnabled = false,
    speedEnabled = false,
    jumpEnabled = false,
    noclipEnabled = false,
    flyEnabled = false,
    espEnabled = false,
    flySpeed = 40
}

-- Storage
local storage = {
    originalSizes = {},
    hitboxParts = {},
    espParts = {},
    connections = {},
    flyBodyVelocity = nil,
    flyBodyAngularVelocity = nil
}

-- Delta-safe GUI creation
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaModMenu_" .. math.random(1000, 9999)
    screenGui.ResetOnSpawn = false
    
    -- Try CoreGui first, fallback to PlayerGui
    local success = pcall(function()
        screenGui.Parent = CoreGui
    end)
    
    if not success then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return screenGui
end

local screenGui = createGui()

-- Main Frame (Mobile-optimized size)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 480) -- Smaller for mobile
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Add corner rounding (Delta-safe)
local success = pcall(function()
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
end)

-- Add stroke (Delta-safe)
local success = pcall(function()
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
header.BorderSizePixel = 0
header.Parent = mainFrame

-- Header corner (Delta-safe)
pcall(function()
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
end)

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -70, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 DELTA MOD MENU"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold -- Delta-compatible font
titleLabel.Parent = header

-- Subtitle
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, -70, 0, 20)
subtitleLabel.Position = UDim2.new(0, 10, 0, 35)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Mobile Executor Compatible"
subtitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
subtitleLabel.TextScaled = true
subtitleLabel.Font = Enum.Font.SourceSans
subtitleLabel.TextTransparency = 0.3
subtitleLabel.Parent = header

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.SourceSansBold
closeButton.BorderSizePixel = 0
closeButton.Parent = header

-- Content area
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -80)
contentFrame.Position = UDim2.new(0, 10, 0, 70)
contentFrame.BackgroundTransparency = 1
contentFrame.ScrollBarThickness = 6
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = contentFrame

-- Delta-safe function to create sections
local function createSection(text, icon)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 35)
    section.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    section.BorderSizePixel = 0
    section.Parent = contentFrame

    pcall(function()
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 8)
        sectionCorner.Parent = section
    end)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = icon .. " " .. text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = section

    return section
end

-- Delta-safe function to create buttons
local function createButton(text, icon, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 45)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.BorderSizePixel = 0
    button.Parent = contentFrame

    pcall(function()
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
    end)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = icon .. " " .. text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSans
    textLabel.Parent = button

    -- Delta-safe connection
    local connection = button.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    table.insert(storage.connections, connection)

    return button, textLabel
end

-- Delta-safe hitbox functions
local function updateHitbox(player)
    if player == LocalPlayer then return end
    
    pcall(function()
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Remove old hitbox
        local oldHitbox = character:FindFirstChild("ExtendedHitbox")
        if oldHitbox then
            pcall(function() oldHitbox:Destroy() end)
        end
        
        -- Create new hitbox
        local hitbox = Instance.new("Part")
        hitbox.Name = "ExtendedHitbox"
        hitbox.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
        hitbox.CFrame = humanoidRootPart.CFrame
        hitbox.Anchored = false
        hitbox.CanCollide = false
        hitbox.Transparency = 0.9
        hitbox.BrickColor = BrickColor.new("Really red")
        hitbox.Material = Enum.Material.Neon
        hitbox.Shape = Enum.PartType.Ball
        
        -- Weld
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = hitbox
        weld.Parent = hitbox
        
        hitbox.Parent = character
        storage.hitboxParts[player] = hitbox
        
        -- Store original size
        if not storage.originalSizes[player] then
            storage.originalSizes[player] = humanoidRootPart.Size
        end
        humanoidRootPart.Size = Vector3.new(config.hitboxSize, config.hitboxSize, config.hitboxSize)
    end)
end

local function restoreHitbox(player)
    pcall(function()
        if storage.hitboxParts[player] then
            storage.hitboxParts[player]:Destroy()
            storage.hitboxParts[player] = nil
        end
        
        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local extendedHitbox = player.Character:FindFirstChild("ExtendedHitbox")
            
            if extendedHitbox then
                extendedHitbox:Destroy()
            end
            
            if humanoidRootPart and storage.originalSizes[player] then
                humanoidRootPart.Size = storage.originalSizes[player]
            end
        end
    end)
end

local function updateAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if config.hitboxEnabled then
                updateHitbox(player)
            else
                restoreHitbox(player)
            end
        end
    end
end

-- Delta-safe ESP functions
local function createESP(player)
    if player == LocalPlayer then return end
    
    pcall(function()
        local character = player.Character
        if not character then return end
        
        -- Remove old ESP
        local oldESP = character:FindFirstChild("ESP_Highlight")
        if oldESP then oldESP:Destroy() end
        
        -- Create highlight (Delta-safe)
        local success, highlight = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "ESP_Highlight"
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.Parent = character
            return h
        end)
        
        if success then
            storage.espParts[player] = highlight
        end
    end)
end

local function removeESP(player)
    pcall(function()
        if storage.espParts[player] then
            storage.espParts[player]:Destroy()
            storage.espParts[player] = nil
        end
        
        if player.Character then
            local esp = player.Character:FindFirstChild("ESP_Highlight")
            if esp then esp:Destroy() end
        end
    end)
end

-- Delta-safe fly functions
local function enableFly()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        storage.flyBodyVelocity = Instance.new("BodyVelocity")
        storage.flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        storage.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        storage.flyBodyVelocity.Parent = humanoidRootPart
    end)
end

local function disableFly()
    pcall(function()
        if storage.flyBodyVelocity then
            storage.flyBodyVelocity:Destroy()
            storage.flyBodyVelocity = nil
        end
    end)
end

-- Create GUI elements
createSection("RAGE ABILITIES", "🔥")

local hitboxButton, hitboxText = createButton("Sensitive Hitbox: OFF", "🎯", function()
    config.hitboxEnabled = not config.hitboxEnabled
    hitboxText.Text = "🎯 Sensitive Hitbox: " .. (config.hitboxEnabled and "ON" or "OFF")
    hitboxButton.BackgroundColor3 = config.hitboxEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    updateAllPlayers()
    print("🎯 Delta Hitbox:", config.hitboxEnabled and "Enabled" or "Disabled")
end)

createButton("Increase Hitbox Size", "📈", function()
    config.hitboxSize = math.min(40, config.hitboxSize + 3) -- Smaller increments for Delta
    if config.hitboxEnabled then updateAllPlayers() end
    print("📈 Hitbox size:", config.hitboxSize)
end)

createButton("Decrease Hitbox Size", "📉", function()
    config.hitboxSize = math.max(5, config.hitboxSize - 3)
    if config.hitboxEnabled then updateAllPlayers() end
    print("📉 Hitbox size:", config.hitboxSize)
end)

createSection("MOVEMENT HACKS", "⚡")

local speedButton, speedText = createButton("Super Speed: OFF", "🚀", function()
    config.speedEnabled = not config.speedEnabled
    pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = config.speedEnabled and 80 or 16 -- Lower speed for Delta stability
            speedText.Text = "🚀 Super Speed: " .. (config.speedEnabled and "ON" or "OFF")
            speedButton.BackgroundColor3 = config.speedEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
            print("🚀 Delta Speed:", config.speedEnabled and "Enabled" or "Disabled")
        end
    end)
end)

local jumpButton, jumpText = createButton("Super Jump: OFF", "🦘", function()
    config.jumpEnabled = not config.jumpEnabled
    pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = config.jumpEnabled and 150 or 50 -- Lower jump for Delta stability
            jumpText.Text = "🦘 Super Jump: " .. (config.jumpEnabled and "ON" or "OFF")
            jumpButton.BackgroundColor3 = config.jumpEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
            print("🦘 Delta Jump:", config.jumpEnabled and "Enabled" or "Disabled")
        end
    end)
end)

local flyButton, flyText = createButton("Fly Mode: OFF", "🕊️", function()
    config.flyEnabled = not config.flyEnabled
    if config.flyEnabled then
        enableFly()
    else
        disableFly()
    end
    flyText.Text = "🕊️ Fly Mode: " .. (config.flyEnabled and "ON" or "OFF")
    flyButton.BackgroundColor3 = config.flyEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    print("🕊️ Delta Fly:", config.flyEnabled and "Enabled" or "Disabled")
end)

createSection("VISUAL HACKS", "👁️")

local espButton, espText = createButton("Player ESP: OFF", "🔍", function()
    config.espEnabled = not config.espEnabled
    if config.espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
    espText.Text = "🔍 Player ESP: " .. (config.espEnabled and "ON" or "OFF")
    espButton.BackgroundColor3 = config.espEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 70)
    print("🔍 Delta ESP:", config.espEnabled and "Enabled" or "Disabled")
end)

-- Delta-safe toggle function
local function toggleMenu()
    pcall(function()
        mainFrame.Visible = not mainFrame.Visible
        
        if mainFrame.Visible then
            -- Simple show animation for Delta compatibility
            mainFrame.Size = UDim2.new(0, 50, 0, 50)
            mainFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
            
            -- Delta-safe tween
            local success = pcall(function()
                local tween = TweenService:Create(mainFrame, 
                    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    {
                        Size = UDim2.new(0, 320, 0, 480),
                        Position = UDim2.new(0.5, -160, 0.5, -240)
                    }
                )
                tween:Play()
            end)
            
            if not success then
                -- Fallback for Delta
                mainFrame.Size = UDim2.new(0, 320, 0, 480)
                mainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
            end
        end
    end)
end

-- Delta-safe input handling
pcall(function()
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        pcall(function()
            if input.KeyCode == Enum.KeyCode.RightControl then
                toggleMenu()
            end
        end)
    end)
    table.insert(storage.connections, connection)
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    pcall(function()
        mainFrame.Visible = false
    end)
end)

-- Delta-safe player events
pcall(function()
    local connection1 = Players.PlayerAdded:Connect(function(player)
        pcall(function()
            local connection2 = player.CharacterAdded:Connect(function()
                wait(1)
                if config.hitboxEnabled then updateHitbox(player) end
                if config.espEnabled then createESP(player) end
            end)
            table.insert(storage.connections, connection2)
        end)
    end)
    table.insert(storage.connections, connection1)
end)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        pcall(function()
            if player.Character then
                local connection = player.CharacterAdded:Connect(function()
                    wait(1)
                    if config.hitboxEnabled then updateHitbox(player) end
                    if config.espEnabled then createESP(player) end
                end)
                table.insert(storage.connections, connection)
                
                if config.hitboxEnabled then updateHitbox(player) end
                if config.espEnabled then createESP(player) end
            else
                local connection = player.CharacterAdded:Connect(function()
                    wait(1)
                    if config.hitboxEnabled then updateHitbox(player) end
                    if config.espEnabled then createESP(player) end
                end)
                table.insert(storage.connections, connection)
            end
        end)
    end
end

-- Delta-safe main loop
pcall(function()
    local connection = RunService.Heartbeat:Connect(function()
        pcall(function()
            -- Update hitboxes
            if config.hitboxEnabled then
                for player, hitbox in pairs(storage.hitboxParts) do
                    if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
                        storage.hitboxParts[player] = nil
                    elseif not hitbox or not hitbox.Parent then
                        updateHitbox(player)
                    end
                end
            end
            
            -- Update fly
            if config.flyEnabled and storage.flyBodyVelocity then
                -- Simple fly controls for Delta
                local camera = workspace.CurrentCamera
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    local moveVector = camera.CFrame:VectorToWorldSpace(Vector3.new(humanoid.MoveDirection.X, 0, humanoid.MoveDirection.Z))
                    storage.flyBodyVelocity.Velocity = moveVector * config.flySpeed
                else
                    storage.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end)
    table.insert(storage.connections, connection)
end)

-- Cleanup function for Delta
local function cleanup()
    pcall(function()
        for _, connection in pairs(storage.connections) do
            if connection then
                connection:Disconnect()
            end
   
