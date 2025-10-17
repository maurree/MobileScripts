-- BrawlRecorder for Brawl 2 - UNBREAKABLE MOBILE VERSION
-- Features: Death-proof, Error-proof, Auto-reconnect, Full mobile optimization

loadstring(game:HttpGet("https://raw.githubusercontent.com/shakar60/scripts/refs/heads/main/ac%20bypass",true))()

task.wait(5)

print("🟡 Loading UNBREAKABLE BrawlRecorder with AC Bypass...")

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- AC BYPASS IMPLEMENTATION
-- ============================================

local plr = game:GetService("Players").LocalPlayer
local cclosure = syn_newcclosure or newcclosure or nil

if cclosure and hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", cclosure(function(self, ...)
        local NamecallMethod = getnamecallmethod()
        local args = { ... }
        if (NamecallMethod == "Kick" or NamecallMethod == "kick") and not checkcaller() then
            if self ~= plr then
                return oldNamecall(self, ...)
            end
            return
        end
        return oldNamecall(self, ...)
    end))
end

-- GC Hook for kick protection
for wendigo, iscool in pairs(getgc(true)) do
    if pcall(function() return rawget(iscool, "indexInstance") end) 
    and type(rawget(iscool, "indexInstance")) == "table" 
    and rawget(iscool, "indexInstance")[1] == "kick" then
        iscool.tvk = {"kick", function() 
            return game.Workspace:WaitForChild("") 
        end}
    end
end

-- Adonis Bypass
local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}
local Detected, Kill

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")

        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then
                        warn("Adonis AntiCheat flagged\nMethod: "..tostring(Action).."\nInfo: "..tostring(Info))
                    end
                end
                return true
            end)
            table.insert(Hooked, Detected)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
                if DEBUG then
                    warn("Adonis AntiCheat tried to kill (fallback): "..tostring(Info))
                end
            end)
            table.insert(Hooked, Kill)
        end
    end
end

local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...
    if Detected and LevelOrFunc == Detected then
        if DEBUG then
            warn("Adonis AntiCheat sanity check detected and broken")
        end
        return coroutine.yield(coroutine.running())
    end
    return Old(...)
end))

-- Game-specific detection bypass
local Bypass = true
local GameMT = getrawmetatable(game)
local OldIndexFunc = GameMT.__index
local OldNamecallFunc = GameMT.__namecall
setreadonly(GameMT, false)

if Bypass == true then
    GameMT.__namecall = newcclosure(function(self, ...) 
        local NamecallArgs = {...}

        local DETECTION_STRINGS = {
            'CHECKER_1',
            'CHECKER',
            'OneMoreTime',
            'checkingSPEED',
            'PERMAIDBAN',
            'BANREMOTE',
            'FORCEFIELD',
            'TeleportDetect',
        }

        if (table.find(DETECTION_STRINGS, NamecallArgs[1]) and getnamecallmethod() == 'FireServer') then 
            return
        end
        
        local suc, err = pcall(getfenv, 2)
        if not err then 
            if getfenv(2).crash then 
                hookfunction(getfenv(2).crash, function() end)
            end
        end
        return OldNamecallFunc(self, ...)
    end)
end

-- Camera protection
for _, con in next, getconnections(workspace.CurrentCamera.Changed) do
    pcall(function()
        con:Disable()
    end)
end
for _, con in next, getconnections(workspace.CurrentCamera:GetPropertyChangedSignal("CFrame")) do
    pcall(function()
        con:Disable()
    end)
end

print("✅ AC Bypass loaded")

-- ============================================
-- SAFE GUI FINDER (NEVER FAILS)
-- ============================================

local function getOrCreateGui()
    local existingGui = playerGui:FindFirstChildOfClass("ScreenGui")
    
    if not existingGui then
        warn("⚠️ No existing GUI found, creating persistent one...")
        existingGui = Instance.new("ScreenGui")
        existingGui.Name = "BrawlRecorderGui"
        existingGui.ResetOnSpawn = false -- CRITICAL: Survives death
        existingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        existingGui.Parent = playerGui
    end
    
    return existingGui
end

local existingGui = getOrCreateGui()
print("✅ Found/Created GUI:", existingGui.Name)

-- ============================================
-- UNBREAKABLE RECORDER SYSTEM
-- ============================================

local BrawlRecorder = {
    -- UI Elements
    holder = nil,
    statusLabel = nil,
    recordButton = nil,
    minimizeButton = nil,
    exportButton = nil,
    exportViewer = nil,
    exportTextBox = nil,
    exportStatusLabel = nil,
    settingsFrame = nil,
    
    -- Recording State
    isRecording = false,
    isMinimized = false,
    startTime = 0,
    combatEvents = {},
    secretUnlocked = false,
    
    -- Connection Storage
    _conns = {},
    _charConns = {},
    _toolConns = {},
    _animConns = {},
    _hitboxConns = {},
    _remoteConns = {},
    _guiConns = {},
    
    -- Throttling
    _throttle = {
        touchMoveNext = 0,
        posSampleNext = 0,
        enemyPosNext = 0,
        uiUpdateNext = 0,
    },
    
    -- Settings
    maxEvents = 15000,
    touchMoveHz = 12,
    posSampleHz = 3,
    enemyPosHz = 2,
    autoSaveOnStop = true,
    persistThroughDeath = true,
    
    -- Tracking Data
    trackedEnemies = {},
    activeHitboxes = {},
    trackedButtons = {},
    lastAttackTime = 0,
    lastHitConfirmed = 0,
    
    -- Error Recovery
    errorCount = 0,
    maxErrors = 50,
    lastError = "",
}

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================
-- UTILITY FUNCTIONS (ERROR-PROOF)
-- ============================================

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        BrawlRecorder.errorCount = BrawlRecorder.errorCount + 1
        BrawlRecorder.lastError = tostring(result)
        warn("⚠️ Safe call failed:", result)
    end
    return success, result
end

local function getScreenSize()
    local success, result = pcall(function()
        return workspace.CurrentCamera.ViewportSize
    end)
    if success and result then
        return result
    end
    return Vector2.new(1920, 1080)
end

local function getInputDirection(pos)
    local screen = getScreenSize()
    local x, y = pos.X, pos.Y
    if y < screen.Y * 0.3 then
        return "Up"
    elseif y > screen.Y * 0.7 then
        if x < screen.X * 0.5 then return "B" else return "A" end
    elseif x < screen.X * 0.3 then
        return "Left"
    elseif x > screen.X * 0.7 then
        return "Right"
    elseif y > screen.Y * 0.3 and y < screen.Y * 0.7 then
        if x > screen.X * 0.4 and x < screen.X * 0.6 then
            return "Down"
        end
    end
    return nil
end

local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function serializeVector3(v)
    return {
        math.floor(v.X * 100) / 100, 
        math.floor(v.Y * 100) / 100, 
        math.floor(v.Z * 100) / 100
    }
end

local function safeGetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function safeGetHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function safeGetRootPart(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
end

-- ============================================
-- CONNECTION MANAGEMENT (LEAK-PROOF)
-- ============================================

function BrawlRecorder:_connect(targetTable, conn)
    if conn then
        table.insert(targetTable, conn)
    end
    return conn
end

function BrawlRecorder:_disconnectAll(list)
    for _, c in ipairs(list) do
        safeCall(function()
            if c and typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end)
    end
    table.clear(list)
end

function BrawlRecorder:_disconnectEverything()
    self:_disconnectAll(self._conns)
    self:_disconnectAll(self._charConns)
    self:_disconnectAll(self._toolConns)
    self:_disconnectAll(self._animConns)
    self:_disconnectAll(self._hitboxConns)
    self:_disconnectAll(self._remoteConns)
    self:_disconnectAll(self._guiConns)
end

-- ============================================
-- EVENT LOGGING (NEVER FAILS)
-- ============================================

function BrawlRecorder:logEvent(eventType, data)
    if not self.isRecording then return end
    if #self.combatEvents >= self.maxEvents then 
        warn("⚠️ Max events reached, stopping recording")
        self:stopRecording()
        return 
    end
    
    safeCall(function()
        local eventData =rency
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
