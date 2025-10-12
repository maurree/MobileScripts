-- LIVE GAMEPLAY COMBAT SYSTEM - Real-time Updates with Collision Prevention
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Live gameplay configuration
local liveGameplay = {
    -- Real-time states
    combatActive = false,
    speedActive = false,
    jumpActive = false,
    noclipActive = false,
    
    -- Live values (update instantly)
    combatMultiplier = 1,
    speedValue = 16,
    jumpValue = 50,
    
    -- Performance settings
    updateRate = 0.1,  -- Update every 0.1 seconds for smooth performance
    lastUpdate = 0
}

local gameplayData = {
    originalValues = {},
    activeConnections = {},
    combatTargets = {},
    playerLimbs = {}
}

-- Create always-visible mini GUI for live control
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LiveGameplayMods"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer.PlayerGui

-- Main live control panel
local livePanel = Instance.new("Frame")
livePanel.Size = UDim2.new(0, 300, 0, 400)
livePanel.Position = UDim2.new(0, 10, 0, 10)
livePanel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
livePanel.BorderSizePixel = 2
livePanel.BorderColor3 = Color3.fromRGB(0, 255, 0)
livePanel.Active = true
livePanel.Draggable = true
livePanel.Parent = screenGui

-- Live status header
local liveHeader = Instance.new("Frame")
liveHeader.Size = UDim2.new(1, 0, 0, 40)
liveHeader.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
liveHeader.BorderSizePixel = 0
liveHeader.Parent = livePanel

local liveTitle = Instance.new("TextLabel")
liveTitle.Size = UDim2.new(1, -80, 1, 0)
liveTitle.Position = UDim2.new(0, 5, 0, 0)
liveTitle.BackgroundTransparency = 1
liveTitle.Text = "🔴 LIVE GAMEPLAY"
liveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
liveTitle.TextScaled = true
liveTitle.Font = Enum.Font.SourceSansBold
liveTitle.Parent = liveHeader

-- Live indicator
local liveIndicator = Instance.new("Frame")
liveIndicator.Size = UDim2.new(0, 15, 0, 15)
liveIndicator.Position = UDim2.new(1, -70, 0, 12)
liveIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
liveIndicator.BorderSizePixel = 0
liveIndicator.Parent = liveHeader

-- Make indicator blink
spawn(function()
    while true do
        liveIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(0.5)
        liveIndicator.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        wait(0.5)
    end
end)

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
minimizeBtn.Text = "-"
minimizeBtn.TextScaled = true
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = liveHeader

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -10, 1, -50)
content.Position = UDim2.new(0, 5, 0, 45)
content.BackgroundTransparency = 1
content.Parent = livePanel

-- REAL-TIME COMBAT SYSTEM WITH COLLISION PREVENTION
local function updateLiveCombat()
    if not liveGameplay.combatActive then return end
    
    local currentTime = tick()
    if currentTime - liveGameplay.lastUpdate < liveGameplay.updateRate then return end
    liveGameplay.lastUpdate = currentTime
    
    -- Update all enemy hitboxes in real-time
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- Store original values once
                if not gameplayData.originalValues[player.Name] then
                    gameplayData.originalValues[player.Name] = {
                        size = hrp.Size,
                        transparency = hrp.Transparency,
                        color = hrp.BrickColor,
                        material = hrp.Material,
                        canCollide = hrp.CanCollide,
                        anchored = hrp.Anchored
                    }
                end
                
                -- Apply live scaling with collision prevention
                local original = gameplayData.originalValues[player.Name]
                local multiplier = liveGameplay.combatMultiplier
                
                hrp.Size = Vector3.new(
                    original.size.X * multiplier,
                    original.size.Y * multiplier,
                    original.size.Z * multiplier
                )
                
                -- PREVENT COLLISION PUSHBACK - Key changes here
                hrp.CanCollide = false  -- Disable collision completely
                hrp.Anchored = false    -- Keep unanchored for normal movement
                
                -- Create invisible collision detection part if needed
                local detectionPart = hrp:FindFirstChild("HitboxDetector")
                if not detectionPart and multiplier > 1 then
                    detectionPart = Instance.new("Part")
                    detectionPart.Name = "HitboxDetector"
                    detectionPart.Size = hrp.Size
                    detectionPart.CFrame = hrp.CFrame
                    detectionPart.Transparency = 1
                    detectionPart.CanCollide = false  -- No collision for detector either
                    detectionPart.Anchored = true     -- Anchored to prevent physics interference
                    detectionPart.Parent = hrp
                    
                    -- Weld detector to follow the player
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = hrp
                    weld.Part1 = detectionPart
                    weld.Parent = hrp
                end
                
                -- Update detector size if it exists
                if detectionPart then
                    detectionPart.Size = hrp.Size
                end
                
                -- Live visual feedback
                if multiplier > 1 then
                    hrp.Transparency = math.max(0.2, 1 - (multiplier * 0.1))
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = Enum.Material.ForceField
                else
                    hrp.Transparency = original.transparency
                    hrp.BrickColor = original.color
                    hrp.Material = original.material
                    hrp.CanCollide = original.canCollide  -- Restore original collision when not scaled
                    
                    -- Remove detector when not needed
                    if detectionPart then
                        detectionPart:Destroy()
                    end
                end
                
                -- Live hit detection setup using the detector or hrp
                local hitPart = detectionPart or hrp
                if not gameplayData.combatTargets[player.Name] then
                    gameplayData.combatTargets[player.Name] = {}
                    
                    local hitConnection = hitPart.Touched:Connect(function(hit)
                        if hit.Parent == LocalPlayer.Character then
                            -- Real-time hit processing
                            local damage = 10 * multiplier
                            local critChance = math.min(95, multiplier * 15)
                            local isCrit = math.random(1, 100) <= critChance
                            
                            if isCrit then damage = damage * 2 end
                            
                            print("🎯 LIVE HIT: " .. player.Name)
                            print("💥 Damage: " .. damage .. (isCrit and " (CRITICAL!)" or ""))
                            
                            -- Live hit effect (non-physical)
                            local effect = Instance.new("Explosion")
                            effect.Position = hrp.Position
                            effect.BlastRadius = multiplier * 2
                            effect.BlastPressure = 0  -- No physics force
                            effect.Parent = workspace
                        end
                    end)
                    
                    gameplayData.combatTargets[player.Name].connection = hitConnection
                end
            end
        end
    end
    
    -- Update player limbs in real-time with collision prevention
    local character = LocalPlayer.Character
    if character then
        local limbs = {"Left Arm", "Right Arm", "Left Leg", "Right Leg"}
        
        for _, limbName in pairs(limbs) do
            local limb = character:FindFirstChild(limbName)
            if limb then
                -- Store original limb data
                if not gameplayData.playerLimbs[limbName] then
                    gameplayData.playerLimbs[limbName] = {
                        size = limb.Size,
                        transparency = limb.Transparency,
                        color = limb.BrickColor,
                        canCollide = limb.CanCollide
                    }
                end
                
                -- Apply live limb scaling with collision prevention
                local original = gameplayData.playerLimbs[limbName]
                local reachMultiplier = 1 + (liveGameplay.combatMultiplier - 1) * 0.3
                
                limb.Size = original.size * reachMultiplier
                
                if liveGameplay.combatMultiplier > 1 then
                    limb.Transparency = 0.3
                    limb.BrickColor = BrickColor.new("Bright blue")
                    limb.CanCollide = false  -- Prevent limb collision pushback
                else
                    limb.Transparency = original.transparency
                    limb.BrickColor = original.color
                    limb.CanCollide = original.canCollide  -- Restore original collision
                end
                
                -- Live limb hit detection
                if not gameplayData.combatTargets["limb_" .. limbName] then
                    local limbConnection = limb.Touched:Connect(function(hit)
                        local hitCharacter = hit.Parent
                        if hitCharacter ~= character and hitCharacter:FindFirstChild("Humanoid") then
                            local combatPower = 15 * liveGameplay.combatMultiplier
                            print("👊 LIMB HIT: " .. hitCharacter.Name .. " | Power: " .. combatPower)
                            
                            -- Live combat effect (non-physical)
                            local combatEffect = Instance.new("Explosion")
                            combatEffect.Position = hit.Position
                            combatEffect.BlastRadius = liveGameplay.combatMultiplier
                            combatEffect.BlastPressure = 0  -- No physics force
                            combatEffect.Parent = workspace
                        end
                    end)
                    
                    gameplayData.combatTargets["limb_" .. limbName] = {
                        connection = limbConnection
                    }
                end
            end
        end
    end
end

-- REAL-TIME SPEED SYSTEM
local function updateLiveSpeed()
    if not liveGameplay.speedActive then return end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = liveGameplay.speedValue
        end
    end
end

-- REAL-TIME JUMP SYSTEM
local function updateLiveJump()
    if not liveGameplay.jumpActive then return end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = liveGameplay.jumpValue
        end
    end
end

-- REAL-TIME NOCLIP SYSTEM
local function updateLiveNoclip()
    if not liveGameplay.noclipActive then return end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end

-- Create live control function
local function createLiveControl(name, icon, yPos, activateFunc, deactivateFunc, hasSlider, minVal, maxVal, defaultVal)
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, 0, 0, hasSlider and 80 or 50)
    controlFrame.Position = UDim2.new(0, 0, 0, yPos)
    controlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    controlFrame.BorderSizePixel = 1
    controlFrame.BorderColor3 = Color3.fromRGB(50, 50, 70)
    controlFrame.Parent = content
    
    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.Position = UDim2.new(0, 5, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    toggleBtn.Text = icon .. " " .. name .. ": OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.SourceSans
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = controlFrame
    
    local isActive = false
    local currentValue = defaultVal or 1
    
    -- Slider for live adjustment
    if hasSlider then
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, -10, 0, 25)
        sliderFrame.Position = UDim2.new(0, 5, 0, 50)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = controlFrame
        
        local sliderButton = Instance.new("TextButton")
        sliderButton.Size = UDim2.new(0, 20, 1, 0)
        sliderButton.Position = UDim2.new(0, 0, 0, 0)
        sliderButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        sliderButton.Text = ""
        sliderButton.BorderSizePixel = 0
        sliderButton.Parent = sliderFrame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 1, 0)
        valueLabel.Position = UDim2.new(1, -50, 0, 0)
        valueLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        valueLabel.Text = tostring(currentValue)
        valueLabel.TextScaled = true
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.BorderSizePixel = 0
        valueLabel.Parent = sliderFrame
        
        -- Live slider functionality
        local dragging = false
        
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = LocalPlayer:GetMouse()
                local framePos = sliderFrame.AbsolutePosition.X
                local frameSize = sliderFrame.AbsoluteSize.X - 20
                local mousePos = mouse.X - framePos
                
                local percentage = math.max(0, math.min(1, mousePos / frameSize))
                currentValue = minVal + (maxVal - minVal) * percentage
                
                if name:find("Combat") then
                    currentValue = math.floor(currentValue * 10) / 10  -- Round to 1 decimal
                else
                    currentValue = math.floor(currentValue)
                end
                
                sliderButton.Position = UDim2.new(percentage, 0, 0, 0)
                valueLabel.Text = tostring(currentValue)
                
                -- Update live values immediately
                if name:find("Combat") then
                    liveGameplay.combatMultiplier = currentValue
                elseif name:find("Speed") then
                    liveGameplay.speedValue = currentValue
                elseif name:find("Jump") then
                    liveGameplay.jumpValue = currentValue
                end
                
                print("🔄 LIVE UPDATE: " .. name .. " = " .. currentValue)
            end
        end)
    end
    
    -- Toggle functionality
    toggleBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        
        if isActive then
            toggleBtn.Text = icon .. " " .. name .. ": ON"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            activateFunc(currentValue)
            print("✅ " .. name .. " ACTIVATED (Live Mode)")
        else
            toggleBtn.Text = icon .. " " .. name .. ": OFF"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            deactivateFunc()
            print("❌ " .. name .. " DEACTIVATED")
        end
    end)
    
    return controlFrame
end

-- Create live controls
createLiveControl("Live Combat", "⚔️", 10, 
    function(value)
        liveGameplay.combatActive = true
        liveGameplay.combatMultiplier = value
    end,
    function()
        liveGameplay.combatActive = false
        -- Reset all combat effects
        for playerName, data in pairs(gameplayData.combatTargets) do
            if data.connection then data.connection:Disconnect() end
        end
        gameplayData.combatTargets = {}
        
        -- Reset hitboxes and restore collision
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and gameplayData.originalValues[player.Name] then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local original = gameplayData.originalValues[player.Name]
                    hrp.Size = original.size
                    hrp.Transparency = original.transparency
                    hrp.BrickColor = original.color
                    hrp.Material = original.material
                    hrp.CanCollide = original.canCollide  -- Restore collision
                    hrp.Anchored = original.anchored
                    
                    -- Remove detector part
                    local detector = hrp:FindFirstChild("HitboxDetector")
                    if detector then detector:Destroy() end
                end
            end
        end
        
        -- Reset player limbs collision
        local character = LocalPlayer.Character
        if character then
            local limbs = {"Left Arm", "Right Arm", "Left Leg", "Right Leg"}
            for _, limbName in pairs(limbs) do
                local limb = character:FindFirstChild(limbName)
                if limb and gameplayData.playerLimbs[limbName] then
                    local original = gameplayData.playerLimbs[limbName]
                    limb.CanCollide = original.canCollide
                end
            end
        end
    end,
    true, 1, 20, 1
)

createLiveControl("Live Speed", "🚀", 100, 
    function(value)
        liveGameplay.speedActive = true
        liveGameplay.speedValue = value
    end,
    function()
        liveGameplay.speedActive = false
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end,
    true, 16, 100, 16
)

createLiveControl("Live Jump", "🦘", 190, 
    function(value)
        liveGameplay.jumpActive = true
        liveGameplay.jumpValue = value
    end,
    function()
        liveGameplay.jumpActive = false
        local character = LocalPl.FillColor = Color3.fromRGB(255, 0, 0)
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
   
