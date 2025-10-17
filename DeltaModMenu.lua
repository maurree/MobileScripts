function BrawlRecorder:logEvent(eventType, data)
    if not self.isRecording then return end
    if #self.combatEvents >= self.maxEvents then 
        warn("⚠️ Max events reached, stopping recording")
        self:stopRecording()
        return 
    end
    
    safeCall(function()
        local eventData = {
            type = eventType,
            time = tick() - self.startTime,
            data = data or {}
        }
        
        -- Add position data if available
        local char = safeGetCharacter()
        if char then
            local root = safeGetRootPart(char)
            if root then
                eventData.position = serializeVector3(root.Position)
            end
        end
        
        -- Add to events table
        table.insert(self.combatEvents, eventData)
        
        -- Update UI if needed
        if tick() >= self._throttle.uiUpdateNext then
            self:updateUI()
            self._throttle.uiUpdateNext = tick() + 0.5
        end
    end)
end

-- ============================================
-- UI UPDATE FUNCTION
-- ============================================

function BrawlRecorder:updateUI()
    safeCall(function()
        if self.statusLabel and self.isRecording then
            local elapsed = math.floor(tick() - self.startTime)
            local minutes = math.floor(elapsed / 60)
            local seconds = elapsed % 60
            self.statusLabel.Text = string.format("🔴 Recording: %02d:%02d | Events: %d", 
                minutes, seconds, #self.combatEvents)
        end
    end)
end

-- ============================================
-- START RECORDING
-- ============================================

function BrawlRecorder:startRecording()
    if self.isRecording then return end
    
    self.isRecording = true
    self.startTime = tick()
    self.combatEvents = {}
    self.errorCount = 0
    
    print("✅ Recording started!")
    
    -- Log start event
    self:logEvent("SESSION_START", {
        player = player.Name,
        userId = player.UserId,
        placeId = game.PlaceId
    })
    
    -- Setup all tracking
    self:setupInputTracking()
    self:setupCharacterTracking()
    self:setupCombatTracking()
    self:setupEnemyTracking()
    
    -- Update UI
    if self.recordButton then
        self.recordButton.Text = "⏹️ Stop"
        self.recordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
    
    self:updateUI()
end

-- ============================================
-- STOP RECORDING
-- ============================================

function BrawlRecorder:stopRecording()
    if not self.isRecording then return end
    
    self.isRecording = false
    
    -- Log end event
    self:logEvent("SESSION_END", {
        totalEvents = #self.combatEvents,
        duration = tick() - self.startTime
    })
    
    print("✅ Recording stopped! Total events:", #self.combatEvents)
    
    -- Disconnect all tracking
    self:_disconnectAll(self._charConns)
    self:_disconnectAll(self._toolConns)
    self:_disconnectAll(self._animConns)
    self:_disconnectAll(self._hitboxConns)
    
    -- Update UI
    if self.recordButton then
        self.recordButton.Text = "⏺️ Record"
        self.recordButton.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    end
    
    if self.statusLabel then
        self.statusLabel.Text = "⏸️ Stopped | Events: " .. #self.combatEvents
    end
    
    -- Auto-save if enabled
    if self.autoSaveOnStop and #self.combatEvents > 0 then
        self:exportData()
    end
end

-- ============================================
-- INPUT TRACKING
-- ============================================

function BrawlRecorder:setupInputTracking()
    if not isMobile then return end
    
    -- Touch input tracking
    self:_connect(self._conns, UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
        if not self.isRecording then return end
        if tick() < self._throttle.touchMoveNext then return end
        
        local direction = getInputDirection(touch.Position)
        if direction then
            self:logEvent("TOUCH_MOVE", {
                direction = direction,
                position = {touch.Position.X, touch.Position.Y}
            })
        end
        
        self._throttle.touchMoveNext = tick() + (1 / self.touchMoveHz)
    end))
    
    -- Button press tracking
    self:_connect(self._conns, UserInputService.TouchTap:Connect(function(touchPositions, gameProcessed)
        if not self.isRecording then return end
        
        for _, pos in ipairs(touchPositions) do
            local direction = getInputDirection(pos)
            if direction then
                self:logEvent("BUTTON_PRESS", {
                    button = direction,
                    position = {pos.X, pos.Y}
                })
            end
        end
    end))
end

-- ============================================
-- CHARACTER TRACKING
-- ============================================

function BrawlRecorder:setupCharacterTracking()
    local char = safeGetCharacter()
    if not char then return end
    
    local humanoid = safeGetHumanoid(char)
    local root = safeGetRootPart(char)
    
    if not humanoid or not root then return end
    
    -- Position sampling
    self:_connect(self._charConns, RunService.Heartbeat:Connect(function()
        if not self.isRecording then return end
        if tick() < self._throttle.posSampleNext then return end
        
        self:logEvent("POSITION", {
            pos = serializeVector3(root.Position),
            velocity = serializeVector3(root.AssemblyLinearVelocity or Vector3.new())
        })
        
        self._throttle.posSampleNext = tick() + (1 / self.posSampleHz)
    end))
    
    -- Health tracking
    self:_connect(self._charConns, humanoid.HealthChanged:Connect(function(health)
        if not self.isRecording then return end
        
        self:logEvent("HEALTH_CHANGE", {
            health = math.floor(health),
            maxHealth = humanoid.MaxHealth
        })
    end))
    
    -- Death tracking
    self:_connect(self._charConns, humanoid.Died:Connect(function()
        if not self.isRecording then return end
        
        self:logEvent("PLAYER_DIED", {
            position = serializeVector3(root.Position)
        })
    end))
end

-- ============================================
-- COMBAT TRACKING
-- ============================================

function BrawlRecorder:setupCombatTracking()
    local char = safeGetCharacter()
    if not char then return end
    
    -- Tool tracking
    self:_connect(self._charConns, char.ChildAdded:Connect(function(child)
        if not self.isRecording then return end
        if not child:IsA("Tool") then return end
        
        self:logEvent("TOOL_EQUIPPED", {
            tool = child.Name
        })
        
        -- Track tool activation
        self:_connect(self._toolConns, child.Activated:Connect(function()
            if not self.isRecording then return end
            
            self:logEvent("ATTACK", {
                tool = child.Name,
                position = serializeVector3(safeGetRootPart(char).Position)
            })
            
            self.lastAttackTime = tick()
        end))
    end))
end

-- ============================================
-- ENEMY TRACKING
-- ============================================

function BrawlRecorder:setupEnemyTracking()
    self:_connect(self._conns, RunService.Heartbeat:Connect(function()
        if not self.isRecording then return end
        if tick() < self._throttle.enemyPosNext then return end
        
        local myChar = safeGetCharacter()
        local myRoot = safeGetRootPart(myChar)
        if not myRoot then return end
        
        local nearbyEnemies = {}
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local theirChar = otherPlayer.Character
                local theirRoot = safeGetRootPart(theirChar)
                
                if theirRoot then
                    local distance = getDistance(myRoot.Position, theirRoot.Position)
                    
                    if distance < 100 then
                        table.insert(nearbyEnemies, {
                            name = otherPlayer.Name,
                            distance = math.floor(distance),
                            position = serializeVector3(theirRoot.Position)
                        })
                    end
                end
            end
        end
        
        if #nearbyEnemies > 0 then
            self:logEvent("ENEMY_POSITIONS", {
                enemies = nearbyEnemies
            })
        end
        
        self._throttle.enemyPosNext = tick() + (1 / self.enemyPosHz)
    end))
end

-- ============================================
-- EXPORT DATA
-- ============================================

function BrawlRecorder:exportData()
    safeCall(function()
        local jsonData = HttpService:JSONEncode({
            version = "1.0",
            player = player.Name,
            userId = player.UserId,
            placeId = game.PlaceId,
            recordingStart = self.startTime,
            events = self.combatEvents
        })
        
        if self.exportTextBox then
            self.exportTextBox.Text = jsonData
            self.exportViewer.Visible = true
        end
        
        -- Copy to clipboard if possible
        if setclipboard then
            setclipboard(jsonData)
            print("✅ Data copied to clipboard!")
        end
        
        print("✅ Export complete! Events:", #self.combatEvents)
    end)
end

-- ============================================
-- CREATE UI
-- ============================================

function BrawlRecorder:createUI()
    -- Main holder
    self.holder = Instance.new("Frame")
    self.holder.Name = "BrawlRecorderHolder"
    self.holder.Size = UDim2.new(0, 300, 0, 150)
    self.holder.Position = UDim2.new(0.5, -150, 0, 20)
    self.holder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.holder.BorderSizePixel = 0
    self.holder.Parent = existingGui
    
    -- Make draggable
    local
