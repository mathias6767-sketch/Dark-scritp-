-- KSK OP UPD21.txt – con Speed Carry de CLEAN HUB 9 (reemplazo completo)
repeat task.wait() until game:IsLoaded()
local Players, RunService, UIS, TS, Lighting, HS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("Lighting"), game:GetService("HttpService")
local LP = Players.LocalPlayer
local NS, CS = 60, 29
local LAGGER_SPEED_1 = 20
local LAGGER_SPEED_2 = 10
local speedMode, antiRagdollEnabled = false, false
local jumpMode = 1
local jumpEnabled = false
local tpDownMode = 1
local laggerToggled = false
local laggerLevel = 1
local medusaCounterEnabled = false
local batCounterEnabled = false
local unwalkEnabled = false
local medusaDebounce, medusaLastUsed, dropActive = false, 0, false
local autoLeftEnabled, autoRightEnabled = false, false
local autoLeftSetVisual, autoRightSetVisual = nil, nil
local speedLabel = nil
local enemySpeedLabels = {}
local autoBatEnabled = false
local autoBatSetVisual = nil
local resetAutoBatMotion = nil
local AUTO_BAT_SPEED, AUTO_BAT_VERT_SPEED, AUTO_BAT_DIST, AUTO_BAT_V_OFF = 58, 52, -2.8, 1
local ALTURA_RELATIVA = 3.5
local AUTO_BAT_TURN_SPEED = 480
local AUTO_BAT_MAX_TURN_RATE = 60
local setBatCounterVisual = nil
local startBatCounter, stopBatCounter
local antiLagEnabled = false
local removeAccessoriesEnabled = false
local autoLeftWasEnabled = false
local autoRightWasEnabled = false
local dropBrainrotWasActive = false
local dropBrainrotSetVisual = nil

-- ====== COOLDOWNS PARA EVITAR REINICIOS ACCIDENTALES ======
local _lastCarryToggle = 0
local _lastLaggerToggle = 0
local CARRY_TOGGLE_COOLDOWN = 0.2
local LAGGER_TOGGLE_COOLDOWN = 0.2

-- ====== STRETCH (original KSK) ======
local stretchEnabled = false
local stretchFOV = 120
local stretchConn = nil
local stretchFovConn = nil
local origFOV = 70

-- ====== FPS BOOST (desde Bless) ======
local stretchRezEnabled = false
local stretchRezConn = nil
local setStretchRezVisual = nil

-- ====== NUEVO DROP BRAINROT (versión del segundo script) ======
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150
local dropConnection = nil

local function runDropBrainrot()
    if dropActive then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    dropActive = true
    local t0 = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = char and char:FindFirstChild("HumanoidRootPart")
        if not r then
            conn:Disconnect()
            dropActive = false
            dropConnection = nil
            return
        end
        if tick() - t0 >= DROP_ASCEND_DURATION then
            conn:Disconnect()
            dropConnection = nil
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp)
            if rr then
                local hum2 = char:FindFirstChildOfClass("Humanoid")
                local off = (hum2 and hum2.HipHeight or 2) + (r.Size.Y / 2)
                r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            dropActive = false
            return
        end
        r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, DROP_ASCEND_SPEED, r.AssemblyLinearVelocity.Z)
    end)
    dropConnection = conn
end

local function stopDropBrainrot()
    if dropConnection then
        pcall(dropConnection.Disconnect, dropConnection)
        dropConnection = nil
    end
    dropActive = false
end

local function executeDropWithToggle(setVisual)
    if dropActive then return end
    task.spawn(function()
        if setVisual then setVisual(true) end
        runDropBrainrot()
        while dropActive do task.wait() end
        task.wait(0.1)
        if setVisual then setVisual(false) end
    end)
end
-- ====== FIN NUEVO DROP BRAINROT ======

-- ============================================================
-- ====== NUEVO SISTEMA SPEED CARRY (de CLEAN HUB 9) ======
-- ============================================================

-- Variables del sistema de velocidad
local speedLinearVelocity = nil
local speedAttachment = nil
local speedConnection = nil
local currentSpeedValue = NS
local speedEnabled = false
local lastPosition = nil
local lastTime = nil
local lagbackCooldown = 0
local ownershipTimer = 0

-- Funciones auxiliares
local function getCharParts()
    local char = LP.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return nil, nil end
    return hum, root
end

local function claimOwnership(root)
    pcall(function()
        root:SetNetworkOwner(LP)
    end)
end

local function cleanupSpeedPhysics()
    if speedLinearVelocity then
        speedLinearVelocity:Destroy()
        speedLinearVelocity = nil
    end
    if speedAttachment then
        speedAttachment:Destroy()
        speedAttachment = nil
    end
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    lastPosition = nil
    lastTime = nil
    speedEnabled = false
end

local function applySpeedWithLinearVelocity(spd)
    cleanupSpeedPhysics()
    if spd <= 0 then return end
    local hum, root = getCharParts()
    if not hum or not root then return end
    claimOwnership(root)

    speedAttachment = Instance.new("Attachment")
    speedAttachment.Name = "SpeedAttachment"
    speedAttachment.Parent = root

    speedLinearVelocity = Instance.new("LinearVelocity")
    speedLinearVelocity.Name = "SpeedLinearVelocity"
    speedLinearVelocity.Attachment0 = speedAttachment
    speedLinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    speedLinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    speedLinearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
    speedLinearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
    speedLinearVelocity.MaxForce = 100000
    speedLinearVelocity.PlaneVelocity = Vector2.zero
    speedLinearVelocity.Enabled = false
    speedLinearVelocity.Parent = root

    lastPosition = root.Position
    lastTime = tick()
    speedEnabled = true
    currentSpeedValue = spd

    speedConnection = RunService.Heartbeat:Connect(function(dt)
        if not speedEnabled then return end
        local hum2, root2 = getCharParts()
        if not hum2 or not root2 or not speedLinearVelocity then
            cleanupSpeedPhysics()
            return
        end

        ownershipTimer = ownershipTimer + dt
        if ownershipTimer >= 1.5 then
            claimOwnership(root2)
            ownershipTimer = 0
        end

        local dir = hum2.MoveDirection
        if dir.Magnitude < 0.1 then
            speedLinearVelocity.Enabled = false
            lastPosition = root2.Position
            lastTime = tick()
            return
        end

        speedLinearVelocity.Enabled = true
        speedLinearVelocity.PlaneVelocity = Vector2.new(dir.X * spd, dir.Z * spd)

        lagbackCooldown = lagbackCooldown - dt
        local now = tick()
        local elapsed = now - lastTime
        if elapsed > 0.1 and lastPosition then
            local expectedDist = spd * elapsed
            local actualDist = (root2.Position - lastPosition).Magnitude
            if actualDist < expectedDist * 0.3 and lagbackCooldown <= 0 then
                speedLinearVelocity.PlaneVelocity = Vector2.new(dir.X * spd * 1.2, dir.Z * spd * 1.2)
                lagbackCooldown = 0.3
            end
        end
        lastPosition = root2.Position
        lastTime = now
    end)
end

-- Funciones de toggle (reemplazo completo)
local function refreshSpeedModeLabel()
    if modeValLbl then
        if laggerToggled then
            modeValLbl.Text = laggerLevel == 1 and "Lagger Mode 1" or "Lagger Mode 2"
        elseif speedMode then
            modeValLbl.Text = "Carry Mode"
        else
            modeValLbl.Text = "Normal"
        end
    end
end

local function toggleCarryMode()
    if tick() - _lastCarryToggle < CARRY_TOGGLE_COOLDOWN then return end
    _lastCarryToggle = tick()
    if laggerToggled then
        laggerToggled = false
        laggerLevel = 1
        speedMode = true
    else
        speedMode = not speedMode
        if speedMode then
            laggerToggled = false
            laggerLevel = 1
        end
    end
    refreshSpeedModeLabel()
    if mobSetCarry then mobSetCarry(speedMode) end
    if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end
    if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end
end

local function toggleLaggerCycle()
    if tick() - _lastLaggerToggle < LAGGER_TOGGLE_COOLDOWN then return end
    _lastLaggerToggle = tick()
    if speedMode then
        speedMode = false
        if mobSetCarry then mobSetCarry(false) end
    end
    if not laggerToggled then
        laggerToggled = true
        laggerLevel = 1
    else
        laggerLevel = (laggerLevel == 1) and 2 or 1
    end
    refreshSpeedModeLabel()
    if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end
    if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end
end

-- ====== FIN NUEVO SISTEMA SPEED CARRY ======

-- ============================================================
--  AUTO STEAL NUEVO (sistema del segundo código)
-- ============================================================
ReplicatedStorage = game:GetService("ReplicatedStorage")
plots = workspace:FindFirstChild("Plots")
getconnections = getconnections or get_signal_cons or getconnects or (syn and syn.get_signal_cons)

CONFIG = {
    AUTO_STEAL_ENABLED = false,
    HOLD_MIN = 1.3,
    HOLD_MAX = 2.6,
    ENTRY_DELAY = 0.3,
    COOLDOWN = 0.05,
    STEAL_RANGE = 9,
    PRIME_RANGE = 80
}

StealState = {
    active = false,
    startTime = 0,
    phase = "idle",
    label = "",
    lastResult = "",
    lastResultTime = 0,
    totalSteals = 0,
    failedSteals = 0
}

allAnimalsCache = {}
PromptMemoryCache = {}
InternalStealCache = {}
stealConnection = nil
plotAnimalSync = { caches = {}, connections = {} }
syncRemotes = nil
AnimalsData = nil
progressLastFill = 0

progressFill = nil
progressPct = nil
progressRadLbl = nil
progressDot = nil
progressDotGlow = nil
progressStripe = nil
progressPillStroke = nil
pbFrame = nil

function initializeAutoStealSync()
    local ok = pcall(function()
        local Packages = ReplicatedStorage:FindFirstChild("Packages") or ReplicatedStorage:WaitForChild("Packages", 1)
        local Datas = ReplicatedStorage:FindFirstChild("Datas") or ReplicatedStorage:WaitForChild("Datas", 1)
        if not Packages or not Datas then return end
        AnimalsData = require(Datas:WaitForChild("Animals"))
        local folder = Packages:WaitForChild("Synchronizer")
        syncRemotes = {
            channelFolder = folder:WaitForChild("Channel"),
            routeRemote = folder:WaitForChild("CommunicationRoute"),
            requestData = folder:FindFirstChild("RequestData")
        }
    end)
    return ok and syncRemotes ~= nil
end

function splitSyncPath(path)
    if typeof(path) == "table" then return path end
    local out = {}
    for part in string.gmatch(tostring(path), "[^%.]+") do
        table.insert(out, tonumber(part) or part)
    end
    return out
end

function resolveSyncPath(path, root)
    local current = root
    local parent = nil
    local key = nil
    for _, part in ipairs(splitSyncPath(path)) do
        parent = current
        key = part
        current = current and current[part] or nil
    end
    return current, parent, key
end

function applyPlotSyncDiff(channelName, packet)
    local cache = plotAnimalSync.caches[channelName]
    if typeof(cache) ~= "table" then return end
    local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
    local current, parent, key = resolveSyncPath(path, cache)
    if action == "Changed" then
        if parent ~= nil then parent[key] = a end
    elseif action == "ArrayInsert" then
        if current ~= nil then table.insert(current, b, a) end
    elseif action == "ArrayRemoved" then
        if current ~= nil then table.remove(current, b) end
    elseif action == "DictionaryInsert" then
        if current ~= nil then current[b] = a end
    elseif action == "DictionaryRemoved" then
        if current ~= nil then current[b] = nil end
    end
end

function attachPlotChannel(remote)
    if not syncRemotes or plotAnimalSync.connections[remote] then return end
    local channelName = tostring(remote.Name)
    if not plots:FindFirstChild(channelName) then return end
    if syncRemotes.requestData and plotAnimalSync.caches[channelName] == nil then
        local ok, data = pcall(function() return syncRemotes.requestData:InvokeServer(channelName) end)
        plotAnimalSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
    elseif plotAnimalSync.caches[channelName] == nil then
        plotAnimalSync.caches[channelName] = {}
    end
    plotAnimalSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
        for _, packet in ipairs(queue) do
            applyPlotSyncDiff(channelName, packet)
        end
    end)
end

function detachPlotChannel(channelName)
    for remote, conn in pairs(plotAnimalSync.connections) do
        if tostring(remote.Name) == tostring(channelName) then
            conn:Disconnect()
            plotAnimalSync.connections[remote] = nil
            plotAnimalSync.caches[tostring(channelName)] = nil
            break
        end
    end
end

function startAutoStealSync()
    if not initializeAutoStealSync() then return false end
    for _, child in ipairs(syncRemotes.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then attachPlotChannel(child) end
    end
    syncRemotes.channelFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then attachPlotChannel(child) end
    end)
    syncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
        for _, action in ipairs(actions) do
            local kind, channelName = action[1], tostring(action[2])
            if not plots:FindFirstChild(channelName) then continue end
            if kind == "ListenerAdded" then
                local remote = syncRemotes.channelFolder:FindFirstChild(channelName)
                if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote) end
            elseif kind == "ListenerRemoved" then
                detachPlotChannel(channelName)
            end
        end
    end)
    return true
end

function getPlotChannelData(plotName)
    return plotAnimalSync.caches[plotName]
end

function getPlotOwner(plot)
    local sign = plot:FindFirstChild("PlotSign")
    local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
    local label = frame and frame:FindFirstChild("TextLabel")
    if not label or label.Text == "Empty Base" then return nil end
    return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end

function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot then return false end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    return getPlotOwner(plot) == LP.DisplayName
end

function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = PromptMemoryCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local attach = spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            PromptMemoryCache[animalData.uid] = p
            return p
        end
    end
    return nil
end

function getAnimalPosition(animalData)
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    local podium = podiums:FindFirstChild(animalData.slot)
    if not podium then return nil end
    return podium:GetPivot().Position
end

function distToAnimal(animalData)
    local character = LP.Character
    if not character then return math.huge end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
    if not hrp then return math.huge end
    local pos = getAnimalPosition(animalData)
    if not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end

function pickClosest()
    local character = LP.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, animalData in ipairs(allAnimalsCache) do
        if isMyBaseAnimal(animalData) then continue end
        local pos = getAnimalPosition(animalData)
        if not pos then continue end
        local dist = (hrp.Position - pos).Magnitude
        if dist > CONFIG.PRIME_RANGE then continue end
        if dist < bestDist then
            bestDist = dist
            best = animalData
        end
    end
    return best
end

function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, conns1 = false, nil
    if getconnections then ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan) end
    if ok1 and type(conns1) == "table" then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = false, nil
    if getconnections then ok2, conns2 = pcall(getconnections, prompt.Triggered) end
    if ok2 and type(conns2) == "table" then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
        InternalStealCache[prompt] = data
    end
end

function executeStealAsync(prompt, animalData)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    local label = animalData.name or "Animal"
    StealState.active = true
    StealState.startTime = tick()
    StealState.phase = "holding"
    StealState.label = label
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do
            task.spawn(fn)
        end
        task.wait(CONFIG.HOLD_MIN)
        StealState.phase = "waitingRange"
        local alreadyInRange = distToAnimal(animalData) <= CONFIG.STEAL_RANGE
        local fired = false
        while true do
            local elapsed = tick() - StealState.startTime
            if elapsed > CONFIG.HOLD_MAX then break end
            if not prompt.Parent then break end
            if distToAnimal(animalData) <= CONFIG.STEAL_RANGE then
                if not alreadyInRange then task.wait(CONFIG.ENTRY_DELAY) end
                for _, fn in ipairs(data.triggerCallbacks) do
                    task.spawn(fn)
                end
                fired = true
                break
            end
            task.wait()
        end
        if fired then
            StealState.totalSteals = StealState.totalSteals + 1
            StealState.lastResult = "Stole " .. label
            StealState.phase = "success"
        else
            StealState.failedSteals = StealState.failedSteals + 1
            StealState.lastResult = "Missed window: " .. label
            StealState.phase = "failed"
        end
        StealState.active = false
        StealState.lastResultTime = tick()
        task.wait(CONFIG.COOLDOWN)
        data.ready = true
    end)
    return true
end

function attemptSteal(prompt, animalData)
    if not prompt or not prompt.Parent then return false end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then return false end
    return executeStealAsync(prompt, animalData)
end

function scanAllPlots()
    local newCache = {}
    for _, plot in ipairs(plots:GetChildren()) do
        local cache = getPlotChannelData(plot.Name)
        if not cache then continue end
        local animalList = cache.AnimalList
        if typeof(animalList) ~= "table" then continue end
        for slot, animalData in pairs(animalList) do
            if type(animalData) == "table" then
                local animalName = animalData.Index
                local animalInfo = AnimalsData[animalName]
                if not animalInfo then continue end
                table.insert(newCache, {
                    name = animalInfo.DisplayName or animalName,
                    plot = plot.Name,
                    slot = tostring(slot),
                    uid = plot.Name .. "_" .. tostring(slot)
                })
            end
        end
    end
    allAnimalsCache = newCache
    return #allAnimalsCache
end

function startAutoSteal()
    if stealConnection then return end
    stealConnection = RunService.Heartbeat:Connect(function()
        if not CONFIG.AUTO_STEAL_ENABLED then return end
        if StealState.active then return end
        local target = pickClosest()
        if not target then return end
        local prompt = PromptMemoryCache[target.uid]
        if not prompt or not prompt.Parent then
            prompt = findProximityPromptForAnimal(target)
        end
        if prompt then
            attemptSteal(prompt, target)
        end
    end)
end

function stopAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
    StealState.active = false
    StealState.phase = "idle"
end

function updateCandyStealBar(dt)
    if not progressFill or not progressPct then return end
    local recent = StealState.lastResultTime > 0 and (tick() - StealState.lastResultTime) < 1.4
    local targetPct, targetColor, status = 0, Color3.fromRGB(128, 0, 255), CONFIG.AUTO_STEAL_ENABLED and "READY" or "STEAL!"
    if StealState.active then
        targetPct = math.clamp((tick() - StealState.startTime) / CONFIG.HOLD_MAX, 0, 1)
        if StealState.phase == "waitingRange" then
            status = "WAITING RANGE"
            targetColor = Color3.fromRGB(55, 220, 110)
        else
            status = "STEALING"
            targetColor = Color3.fromRGB(128, 0, 255)
        end
    elseif recent then
        local success = StealState.phase == "success" or string.find(StealState.lastResult, "Stole") ~= nil
        targetPct = 1
        status = success and "SUCCESS" or "FAILED"
        targetColor = success and Color3.fromRGB(80, 225, 125) or Color3.fromRGB(170, 95, 235)
    elseif StealState.phase ~= "idle" then
        StealState.phase = "idle"
    end
    progressLastFill = progressLastFill + (targetPct - progressLastFill) * math.min((dt or 0.016) * 14, 1)
    progressFill.Size = UDim2.new(progressLastFill, 0, 1, 0)
    progressFill.BackgroundColor3 = progressFill.BackgroundColor3:Lerp(targetColor, math.min((dt or 0.016) * 8, 1))
    progressPct.Text = status
    progressPct.TextColor3 = targetColor
    local blend = math.min((dt or 0.016) * 8, 1)
    if progressDot then
        progressDot.BackgroundColor3 = progressDot.BackgroundColor3:Lerp(targetColor, blend)
    end
    if progressDotGlow then
        progressDotGlow.Color = progressDotGlow.Color:Lerp(targetColor, blend)
    end
    if progressStripe then
        progressStripe.BackgroundColor3 = progressStripe.BackgroundColor3:Lerp(targetColor, blend)
    end
    if progressPillStroke then
        progressPillStroke.Color = progressPillStroke.Color:Lerp(targetColor, blend)
    end
end

RunService.RenderStepped:Connect(updateCandyStealBar)

task.spawn(function()
    if startAutoStealSync() then
        scanAllPlots()
        while task.wait(5) do
            scanAllPlots()
        end
    end
end)
-- ============================================================
--  FIN AUTO STEAL NUEVO
-- ============================================================

-- ====== LIMPIEZA TOTAL (actualizada con cleanupSpeedPhysics) ======
local function stopAllBackgroundTasks()
    if movementLoop then movementLoop:Disconnect(); movementLoop = nil end
    if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    if enemySpeedConn then enemySpeedConn:Disconnect(); enemySpeedConn = nil end
    if stretchEnabled then disableStretch() end
    if stretchConn then stretchConn:Disconnect(); stretchConn = nil end
    if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end
    disableStretchRez() -- FPS BOOST
    stopAntiRagdoll()
    stopJumpMode()
    stopBatCounter()
    stopMedusaCounter()
    stopAutoSteal()
    stopAutoTPDown()
    disableAutoBat()
    stopBypassAimbot()
    stopAutoLeft()
    stopAutoRight()
    if unwalkEnabled then stopUnwalk() end
    if antiLagEnabled then disableAntiLag() end
    if dropActive then stopDropBrainrot() end
    dropActive = false
    alPhase = 1
    arPhase = 1
    medusaDebounce = false
    medusaLastUsed = 0
    cleanupSpeedPhysics()  -- limpieza del nuevo sistema de velocidad
end

local function setMedusaCounterState(state)
    medusaCounterEnabled = state
    if state then
        if LP.Character then setupMedusa(LP.Character) else stopMedusaCounter() end
    else
        stopMedusaCounter()
    end
    if setMedusaVisual then setMedusaVisual(state) end
end

local BAT_AIMBOT_SPEED = 58
local BYPASS_AIMBOT_SPEED = 60
local bypassToggled = false
local bypassFloatingButton = nil
local bypassFloatingPos = nil
local bypassMode = 1
local bypassModeBtnRef = nil
local dropMode = 1
local lastDropTime = 0
local BAT_V2_SWING_COOLDOWN = 0.1

local AP = {
    L1 = Vector3.new(-476.48, -6.28, 92.73),
    L2 = Vector3.new(-483.12, -4.95, 94.80),
    L_FACE = Vector3.new(-482.25, -4.96, 92.09),
    R1 = Vector3.new(-476.16, -6.52, 25.62),
    R2 = Vector3.new(-483.06, -5.03, 25.48),
    R_FACE = Vector3.new(-482.06, -6.93, 35.47),
}

local Conns = {
    batCounter = nil,
    anchor = {},
    autoLeft = nil,
    autoRight = nil,
}
local progressFill = nil
local progressPct = nil
local progressRadLbl = nil
local pbFrame = nil

-- ====== STRETCH (original KSK) ======
local function applyStretchFOV(val)
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = val end)
    end
end

local function enableStretch()
    if stretchConn then return end
    stretchEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    origFOV = cam.FieldOfView or 70
    applyStretchFOV(stretchFOV)
    stretchConn = RunService.RenderStepped:Connect(function()
        if not stretchEnabled then
            stretchConn:Disconnect()
            stretchConn = nil
            return
        end
        local c = workspace.CurrentCamera
        if c then
            c.CFrame = c.CFrame * CFrame.new(0,0,0,1,0,0,0,0.7,0,0,0,1)
        end
    end)
    if stretchFovConn then stretchFovConn:Disconnect() end
    stretchFovConn = RunService.RenderStepped:Connect(function()
        if stretchEnabled then
            applyStretchFOV(stretchFOV)
        else
            stretchFovConn:Disconnect()
            stretchFovConn = nil
        end
    end)
end

local function disableStretch()
    stretchEnabled = false
    if stretchConn then
        stretchConn:Disconnect()
        stretchConn = nil
    end
    if stretchFovConn then
        stretchFovConn:Disconnect()
        stretchFovConn = nil
    end
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = origFOV or 70 end)
    end
end

-- ====== FPS BOOST (desde Bless) ======
local function enableStretchRez()
    if stretchRezEnabled then return end
    stretchRezEnabled = true
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = 107 end)
    end
    if stretchRezConn then stretchRezConn:Disconnect() end
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not stretchRezEnabled then
            stretchRezConn:Disconnect()
            stretchRezConn = nil
            return
        end
        local c = workspace.CurrentCamera
        if c then
            pcall(function() c.FieldOfView = 107 end)
        end
    end)
end

local function disableStretchRez()
    stretchRezEnabled = false
    if stretchRezConn then
        stretchRezConn:Disconnect()
        stretchRezConn = nil
    end
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = 70 end)
    end
end

-- ====== ENEMY SPEED ======
local enemySpeedConn = nil
local function updateEnemySpeedLabels()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local velocity = hrp.AssemblyLinearVelocity
                local speed = (Vector3.new(velocity.X, 0, velocity.Z).Magnitude)
                local label = enemySpeedLabels[player]
                if not label then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local bb = Instance.new("BillboardGui", head)
                        bb.Size = UDim2.new(0, 100, 0, 25)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Name = "EnemySpeedGui"
                        local textLabel = Instance.new("TextLabel", bb)
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = string.format("%.1f", speed)
                        textLabel.TextColor3 = Color3.fromRGB(128, 0, 255)
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextScaled = true
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label = textLabel
                        enemySpeedLabels[player] = label
                    end
                elseif label and label.Parent and label.Parent.Parent ~= char then
                    local head = char:FindFirstChild("Head")
                    if head then
                        label.Parent.Parent = head
                    end
                end
                if label then
                    label.Text = string.format("%.1f", speed)
                end
            else
                local label = enemySpeedLabels[player]
                if label and label.Parent and label.Parent.Parent then
                    label.Parent.Parent = nil
                end
                enemySpeedLabels[player] = nil
            end
        end
    end
    for player, label in pairs(enemySpeedLabels) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if label and label.Parent and label.Parent.Parent then
                label.Parent.Parent = nil
            end
            enemySpeedLabels[player] = nil
        end
    end
end

local function startEnemySpeed()
    if enemySpeedConn then enemySpeedConn:Disconnect() end
    enemySpeedConn = RunService.Heartbeat:Connect(function()
        updateEnemySpeedLabels()
    end)
end

local uiLocked = false
local MobilePanel = nil

local MobileButtons = {
    Visible = true,
    Frame = nil,
    Buttons = {}
}
local mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight
local mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2
local antiLagDescConn = nil
local unwalkSavedAnimate = nil
local _anyKeyListening = false
local autoTPHeight = 20

local KB = {
    DropBrainrot={kb=Enum.KeyCode.X,gp=nil},
    AutoLeft    ={kb=Enum.KeyCode.Z,gp=nil},
    AutoRight   ={kb=Enum.KeyCode.C,gp=nil},
    AutoBat     ={kb=Enum.KeyCode.E,gp=nil},
    TPFloor     ={kb=Enum.KeyCode.F,gp=nil},
    GuiHide     ={kb=Enum.KeyCode.LeftControl,gp=nil},
    CarryToggle={kb=Enum.KeyCode.Q,gp=nil},
    LaggerMode  ={kb=Enum.KeyCode.R,gp=nil},
    AutoTPDown  ={kb=Enum.KeyCode.T,gp=nil},
    JumpMode    ={kb=Enum.KeyCode.V,gp=nil},
    Bypass      ={kb=Enum.KeyCode.N,gp=nil},
}

local GAMEPAD_KEYS={
    [Enum.KeyCode.ButtonA]=true,[Enum.KeyCode.ButtonB]=true,[Enum.KeyCode.ButtonX]=true,[Enum.KeyCode.ButtonY]=true,
    [Enum.KeyCode.ButtonL1]=true,[Enum.KeyCode.ButtonR1]=true,[Enum.KeyCode.ButtonL2]=true,[Enum.KeyCode.ButtonR2]=true,
    [Enum.KeyCode.ButtonL3]=true,[Enum.KeyCode.ButtonR3]=true,[Enum.KeyCode.ButtonStart]=true,[Enum.KeyCode.ButtonSelect]=true,
    [Enum.KeyCode.DPadUp]=true,[Enum.KeyCode.DPadDown]=true,[Enum.KeyCode.DPadLeft]=true,[Enum.KeyCode.DPadRight]=true
}

local function isGamepadInput(inp)
    return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil
end

local function isBindableInput(inp)
    if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
    if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
    return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
end

local function kbMatch(entry, kc)
    return kc and (kc == entry.kb or (entry.gp and kc == entry.gp))
end

local MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
    [Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}

local steppedConn = nil
local movementLoop = nil

-- steppedConn (desactivar colisiones) se mantiene igual
steppedConn = RunService.Stepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- NUEVO movementLoop con el sistema de CLEAN HUB
movementLoop = RunService.RenderStepped:Connect(function()
    local char2 = LP.Character
    if not char2 then return end
    local hum = char2:FindFirstChildOfClass("Humanoid")
    local hrp = char2:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- Solo aplicar speed si no hay aimbots ni auto movimientos activos
    if not autoBatEnabled and not bypassToggled and not autoLeftEnabled and not autoRightEnabled then
        local spd
        if laggerToggled then
            spd = (laggerLevel == 2) and LAGGER_SPEED_2 or LAGGER_SPEED_1
        else
            spd = speedMode and CS or NS
        end

        if speedEnabled and currentSpeedValue ~= spd then
            cleanupSpeedPhysics()
        end
        if not speedEnabled and spd > 0 then
            applySpeedWithLinearVelocity(spd)
        end
    else
        if speedEnabled then
            cleanupSpeedPhysics()
        end
    end

    -- Actualizar label de velocidad
    if speedLabel then
        local v = hrp.Velocity
        local flatSpeed = math.sqrt(v.X * v.X + v.Z * v.Z)
        speedLabel.Text = string.format("%.1f", flatSpeed)
    end
end)

local alConn, arConn = nil, nil
local alPhase, arPhase = 1, 1

local function stopAutoLeft()
    if alConn then alConn:Disconnect(); alConn = nil end
    alPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobSetAutoLeft then mobSetAutoLeft(false) end
end

local function stopAutoRight()
    if arConn then arConn:Disconnect(); arConn = nil end
    arPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(Vector3.zero, false) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobSetAutoRight then mobSetAutoRight(false) end
end

local function disableAllAimbots()
    if autoBatEnabled then
        disableAutoBat()
        if autoBatSetVisual then autoBatSetVisual(false) end
        if mobSetAutoBat then mobSetAutoBat(false) end
    end
    if bypassToggled then
        toggleBypass(false)
    end
end

function startAutoLeft()
    if autoRightEnabled then
        autoRightEnabled = false
        stopAutoRight()
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
    end
    disableAllAimbots()
    if alConn then alConn:Disconnect() end
    alPhase = 1
    alConn = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if alPhase == 1 then
            local tgt = Vector3.new(AP.L1.X, root.Position.Y, AP.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP.L2 - root.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.L1 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = Vector3.new(AP.L2.X, root.Position.Y, AP.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                root.AssemblyLinearVelocity = Vector3.zero
                autoLeftEnabled = false
                if alConn then alConn:Disconnect(); alConn = nil end
                alPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if mobSetAutoLeft then mobSetAutoLeft(false) end
                local facePos = Vector3.new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = CFrame.new(root.Position, facePos)
                end
                return
            end
            local d = AP.L2 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

function startAutoRight()
    if autoLeftEnabled then
        autoLeftEnabled = false
        stopAutoLeft()
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
    end
    disableAllAimbots()
    if arConn then arConn:Disconnect() end
    arPhase = 1
    arConn = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if arPhase == 1 then
            local tgt = Vector3.new(AP.R1.X, root.Position.Y, AP.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP.R2 - root.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.R1 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = Vector3.new(AP.R2.X, root.Position.Y, AP.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                root.AssemblyLinearVelocity = Vector3.zero
                autoRightEnabled = false
                if arConn then arConn:Disconnect(); arConn = nil end
                arPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if mobSetAutoRight then mobSetAutoRight(false) end
                local facePos = Vector3.new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = CFrame.new(root.Position, facePos)
                end
                return
            end
            local d = AP.R2 - root.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

local function startUnwalk()
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop() end)
        end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        unwalkSavedAnimate = anim:Clone()
        anim:Destroy()
    end
end

local function stopUnwalk()
    local c = LP.Character
    if c then
        local existing = c:FindFirstChild("Animate")
        if not existing then
            local src = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterCharacterScripts")
            local starterAnim = src and src:FindFirstChild("Animate")
            if starterAnim then
                starterAnim:Clone().Parent = c
            elseif unwalkSavedAnimate then
                unwalkSavedAnimate:Clone().Parent = c
            end
        end
    end
    unwalkSavedAnimate = nil
end

local function setupSpeedIndicator(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    local oldBB = head:FindFirstChild("KSKSpeedIndicator")
    if oldBB then oldBB:Destroy() end
    local bb = Instance.new("BillboardGui", head)
    bb.Name = "KSKSpeedIndicator"
    bb.Size = UDim2.new(0, 180, 0, 56)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    local titleLabel = Instance.new("TextLabel", bb)
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "KSK OP"
    titleLabel.TextColor3 = Color3.fromRGB(128, 0, 255)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 18
    titleLabel.TextScaled = false
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    speedLabel = Instance.new("TextLabel", bb)
    speedLabel.Size = UDim2.new(1, 0, 0, 26)
    speedLabel.Position = UDim2.new(0, 0, 0, 24)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "0.0"
    speedLabel.TextColor3 = Color3.fromRGB(128, 0, 255)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextScaled = true
    speedLabel.TextStrokeTransparency = 0
    speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
end

local antiRagdollConn = nil

-- NUEVO ANTI RAGDOLL (reemplazo completo)
local function stopAntiRagdoll()
    if antiRagdollConn then
        antiRagdollConn:Disconnect()
        antiRagdollConn = nil
    end
end

local function startAntiRagdoll()
    if antiRagdollConn then return end
    antiRagdollConn = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        local isRagdolled = state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown
        if isRagdolled then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("Motor6D") then obj.Enabled = true end
                    if obj:IsA("Constraint") then obj.Enabled = true end
                end
                workspace.CurrentCamera.CameraSubject = hum
                local PM = LP.PlayerScripts:FindFirstChild("PlayerModule")
                if PM then
                    local CM = require(PM:FindFirstChild("ControlModule"))
                    if CM then CM:Enable() end
                end
                hum.AutoRotate = true
                hum.PlatformStand = false
                hum.Sit = false
            end)
        end
    end)
end
-- FIN NUEVO ANTI RAGDOLL

local MEDUSA_COOLDOWN = 25

local function findMedusa()
    local c = LP.Character
    if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if n:find("medusa") or n:find("head") or n:find("stone") then return t end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("medusa") or n:find("head") or n:find("stone") then return t end
            end
        end
    end
    return nil
end

local function useMedusaCounter()
    if medusaDebounce then return end
    if tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = LP.Character
    if not c then return end
    medusaDebounce = true
    local med = findMedusa()
    if not med then medusaDebounce = false; return end
    if med.Parent ~= c then
        local hum2 = c:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:EquipTool(med) end
    end
    pcall(function() med:Activate() end)
    medusaLastUsed = tick()
    medusaDebounce = false
end

local function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then useMedusaCounter() end
    end)
end

local function setupMedusa(char)
    for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
    Conns.anchor = {}
    if not char or not medusaCounterEnabled then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(Conns.anchor, onAnchorChanged(part))
        end
    end
    table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(Conns.anchor, onAnchorChanged(part))
        end
    end))
end

local function stopMedusaCounter()
    for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
    Conns.anchor = {}
end

local infJumpConn = nil
local holdJumpConn = nil
local holdJumpJumpConn = nil

local function startJumpMode()
    if not jumpEnabled then return end
    if jumpMode == 1 then
        if infJumpConn then infJumpConn:Disconnect() end
        infJumpConn = UIS.JumpRequest:Connect(function()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 56, root.Velocity.Z)
            end
        end)
        if holdJumpConn then holdJumpConn:Disconnect(); holdJumpConn = nil end
        if holdJumpJumpConn then holdJumpJumpConn:Disconnect(); holdJumpJumpConn = nil end
    else
        if holdJumpJumpConn then holdJumpJumpConn:Disconnect() end
        holdJumpJumpConn = UIS.JumpRequest:Connect(function()
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 54, root.Velocity.Z)
            end
        end)
        if holdJumpConn then holdJumpConn:Disconnect() end
        holdJumpConn = RunService.Heartbeat:Connect(function()
            if autoBatEnabled or bypassToggled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local jumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum and hum.Jump == true)
            if jumpHeld and root.Velocity.Y < 30 then
                root.Velocity = Vector3.new(root.Velocity.X, 54, root.Velocity.Z)
            end
            if root.Velocity.Y < -120 then
                root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
            end
        end)
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    end
end

local function stopJumpMode()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    if holdJumpConn then holdJumpConn:Disconnect(); holdJumpConn = nil end
    if holdJumpJumpConn then holdJumpJumpConn:Disconnect(); holdJumpJumpConn = nil end
end

RunService.Heartbeat:Connect(function()
    if not jumpEnabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.Velocity.Y < -120 then
        root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
    end
end)

local defLightBrightness,defLightClock,defLightAmbient,defGlobalShadows,defFogEnd

local function applyAntiLagDerender(obj)
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy()
        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _, t in ipairs(obj:GetPlayingAnimationTracks()) do
                pcall(function() t:Stop(0) end)
            end
        end
    end)
end

local function enableAntiLag()
    removeAccessoriesEnabled = true
    antiLagEnabled = true
    if defLightBrightness == nil then
        defLightBrightness = Lighting.Brightness
    end
    if defLightClock == nil then
        defLightClock = Lighting.ClockTime
    end
    if defLightAmbient == nil then
        defLightAmbient = Lighting.OutdoorAmbient
    end
    if defGlobalShadows == nil then
        defGlobalShadows = Lighting.GlobalShadows
    end
    if defFogEnd == nil then
        defFogEnd = Lighting.FogEnd
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 0
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
               e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or
               e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        applyAntiLagDerender(obj)
    end
    if antiLagDescConn then antiLagDescConn:Disconnect() end
    antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
        if removeAccessoriesEnabled then
            applyAntiLagDerender(obj)
        end
    end)
end

local function disableAntiLag()
    removeAccessoriesEnabled = false
    antiLagEnabled = false
    if antiLagDescConn then
        antiLagDescConn:Disconnect()
        antiLagDescConn = nil
    end
    if defLightBrightness ~= nil then
        Lighting.Brightness = defLightBrightness
    end
    if defLightClock ~= nil then
        Lighting.ClockTime = defLightClock
    end
    if defLightAmbient ~= nil then
        Lighting.OutdoorAmbient = defLightAmbient
    end
    if defGlobalShadows ~= nil then
        Lighting.GlobalShadows = defGlobalShadows
    end
    if defFogEnd ~= nil then
        Lighting.FogEnd = defFogEnd
    end
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
               e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or
               e:IsA("DepthOfFieldEffect") then
                e.Enabled = true
            end
        end)
    end
end

local BAT_COUNTER_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

local function findBatForCounter()
    local c = LP.Character
    if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    return nil
end

local function swingBatInstant(bat, char)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char and hum2 then
        pcall(function() hum2:EquipTool(bat) end)
        task.wait(0.05)
    end
    for _ = 1, 5 do
        pcall(function()
            local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
            else
                bat:Activate()
            end
        end)
        task.wait(0.03)
    end
end

local batCounterDebounce = false
local batCounterConn = nil

startBatCounter = function()
    if batCounterConn then return end
    batCounterConn = RunService.Heartbeat:Connect(function()
        if not batCounterEnabled then return end
        if batCounterDebounce then return end
        local character = LP.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Physics or
           state == Enum.HumanoidStateType.Ragdoll or
           state == Enum.HumanoidStateType.FallingDown then
            batCounterDebounce = true
            task.spawn(function()
                local bat = findBatForCounter()
                if bat then
                    swingBatInstant(bat, character)
                end
                task.wait(0.15)
                batCounterDebounce = false
            end)
        end
    end)
end

stopBatCounter = function()
    if batCounterConn then
        batCounterConn:Disconnect()
        batCounterConn = nil
    end
    batCounterDebounce = false
end

local function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
        end
    end
    return nil
end

local function isBatTool(tool)
    if not tool then return false end
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        if tool.Name == name then return true end
    end
    return tool.Name:lower():find("bat") or tool.Name:lower():find("slap")
end

local _aimbotConn = nil
local _prevAutoRotate = nil
local _hittingCooldown = false

local function getClosestTarget()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                end
            end
        end
    end
    return closest
end

local function trySwing()
    if _hittingCooldown then return end
    _hittingCooldown = true
    pcall(function()
        local char = LP.Character
        if not char then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool and not isBatTool(currentTool) then
            _hittingCooldown = false
            return
        end
        local bat = findBat()
        if bat then
            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            pcall(function() bat:Activate() end)
        end
    end)
    task.delay(0.1, function() _hittingCooldown = false end)
    task.delay(0.2, function()
        if _hittingCooldown then _hittingCooldown = false end
    end)
end

startAimbotAdapt = function()
    if _aimbotConn then return end
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
        hum0.AutoRotate = false
    end
    _aimbotConn = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target = getClosestTarget()
        if not target then return end
        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = Vector3.new(0,0,0) end
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end
        yVel = math.clamp(yVel, -70, 110)
        local desiredVel = Vector3.new(flatDir.X * BAT_AIMBOT_SPEED, yVel, flatDir.Z * BAT_AIMBOT_SPEED)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(
                Vector3.new(rx * 42, ry * 42, rz * 42)
            )
        end
        local distToTarget = (root.Position - target.Position).Magnitude
        if distToTarget <= 8 then
            trySwing()
        end
    end)
end

stopAimbotAdapt = function()
    if _aimbotConn then
        pcall(function() _aimbotConn:Disconnect() end)
        _aimbotConn = nil
    end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, -0.1, 0)
        root.AssemblyAngularVelocity = Vector3.zero
    end
    _prevAutoRotate = nil
    _hittingCooldown = false
end

enableAutoBat = function()
    if autoLeftEnabled then
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(false) end
        stopAutoRight()
    end
    if bypassToggled then
        bypassToggled = false
        if bypassFloatingButton then
            local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
            if btnFrame then
                btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                local lbl = btnFrame:FindFirstChild("TextLabel")
                if lbl then lbl.TextColor3 = Color3.fromRGB(192,192,192) end
            end
        end
        stopBypassAimbot()
    end
    autoBatEnabled = true
    if autoBatSetVisual then autoBatSetVisual(true) end
    if mobSetAutoBat then mobSetAutoBat(true) end
    startAimbotAdapt()
end

disableAutoBat = function()
    autoBatEnabled = false
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobSetAutoBat then mobSetAutoBat(false) end
    stopAimbotAdapt()
end

queueAutoBatStart = function()
    if autoLeftEnabled then
        autoLeftEnabled=false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled=false
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
        stopAutoRight()
    end
    if not autoBatEnabled then
        autoBatEnabled = true
        if autoBatSetVisual then autoBatSetVisual(true) end
        if mobSetAutoBat then mobSetAutoBat(true) end
        startAimbotAdapt()
    end
end

local BAT_V2_FOLLOW_DIST = 1.0
local BAT_V2_HEIGHT_OFFSET = 1.5
local BAT_V2_VERTICAL_OFFSET = 0.0
local BAT_V2_HIT_DIST = 4.5

local bypassHittingCooldown = false
local bypassConn = nil

local function getClosestPlayerV2()
    local char = LP.Character
    if not char then return nil, math.huge end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    local closest, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local ph = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and ph and ph.Health > 0 then
                local d = (hrp.Position - tr.Position).Magnitude
                if d < bestDist then bestDist = d; closest = p end
            end
        end
    end
    return closest, bestDist
end

local function tryHitBatV2()
    if bypassHittingCooldown then return end
    bypassHittingCooldown = true
    pcall(function()
        local char = LP.Character
        if not char then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool and not isBatTool(currentTool) then
            bypassHittingCooldown = false
            return
        end
        local bat = findBat()
        if bat then
            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            local remote = bat:FindFirstChildOfClass("RemoteEvent")
            if remote then pcall(function() remote:FireServer() end) else pcall(function() bat:Activate() end) end
        end
    end)
    task.delay(BAT_V2_SWING_COOLDOWN, function() bypassHittingCooldown = false end)
    task.delay(0.2, function()
        if bypassHittingCooldown then bypassHittingCooldown = false end
    end)
end

local function startBypassAimbot()
    if bypassConn then return end
    bypassConn = RunService.Heartbeat:Connect(function()
        if not bypassToggled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
            return
        end

        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target, dist = getClosestPlayerV2()
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                if bypassMode == 1 then
                    local targetVel = targetRoot.AssemblyLinearVelocity
                    local moveDir = targetVel.Magnitude > 0.1 and targetVel.Unit or targetRoot.CFrame.LookVector
                    local offset = moveDir * BAT_V2_FOLLOW_DIST + Vector3.new(0, BAT_V2_HEIGHT_OFFSET + BAT_V2_VERTICAL_OFFSET, 0)
                    local desiredPos = targetRoot.Position + offset
                    local toTarget = desiredPos - root.Position
                    if toTarget.Magnitude > 0.5 then
                        local moveVec = toTarget.Unit * BYPASS_AIMBOT_SPEED
                        root.AssemblyLinearVelocity = Vector3.new(moveVec.X, moveVec.Y, moveVec.Z)
                    else
                        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.95
                        if root.AssemblyLinearVelocity.Magnitude < 1 then root.AssemblyLinearVelocity = Vector3.zero end
                    end
                    local distToTarget = (root.Position - targetRoot.Position).Magnitude
                    if distToTarget <= BAT_V2_HIT_DIST then
                        tryHitBatV2()
                    end
                else
                    local tr = targetRoot
                    if tr then
                        pcall(function()
                            sethiddenproperty(root, "PhysicsRepRootPart", tr)
                        end)
                        local targetPos = tr.Position + Vector3.new(0, 0.9, 0)
                        if (root.Position - targetPos).Magnitude > 8 then
                            root.CFrame = CFrame.new(targetPos)
                        end
                        local cam = workspace.CurrentCamera
                        if cam then
                            cam.CFrame = CFrame.new(cam.CFrame.Position, tr.Position)
                        end
                        tryHitBatV2()
                    end
                end
            end
        else
            if bypassMode == 1 then
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.9
                if root.AssemblyLinearVelocity.Magnitude < 1 then root.AssemblyLinearVelocity = Vector3.zero end
            end
        end
    end)
end

local function stopBypassAimbot()
    if bypassConn then
        bypassConn:Disconnect()
        bypassConn = nil
    end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = true
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, -0.1, 0)
        root.AssemblyAngularVelocity = Vector3.zero
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end)
    end
    bypassHittingCooldown = false
end

local function toggleBypass(state)
    if state == nil then
        state = not bypassToggled
    end
    bypassToggled = state
    if bypassToggled then
        if autoBatEnabled then
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end
        if autoLeftEnabled then
            autoLeftEnabled = false
            if autoLeftSetVisual then autoLeftSetVisual(false) end
            if mobSetAutoLeft then mobSetAutoLeft(false) end
            stopAutoLeft()
        end
        if autoRightEnabled then
            autoRightEnabled = false
            if autoRightSetVisual then autoRightSetVisual(false) end
            if mobSetAutoRight then mobSetAutoRight(false) end
            stopAutoRight()
        end
        startBypassAimbot()
    else
        stopBypassAimbot()
    end
    if bypassFloatingButton then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        if btnFrame then
            local label = btnFrame:FindFirstChild("TextLabel")
            if bypassToggled then
                btnFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
                if label then label.TextColor3 = Color3.fromRGB(255,255,255) end
            else
                btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                if label then label.TextColor3 = Color3.fromRGB(128, 0, 255) end
            end
        end
    end
    if bypassSetVisual then bypassSetVisual(bypassToggled) end
end

local function toggleBypassMode()
    bypassMode = bypassMode == 1 and 2 or 1
    if bypassModeBtnRef then
        bypassModeBtnRef.Text = bypassMode == 1 and "Bypass" or "TP Bat"
    end
    if bypassToggled then
        stopBypassAimbot()
        startBypassAimbot()
    end
end

local autoTPDownEnabled = false
local autoTPDownConn = nil
local autoTPDownThreshold = 20

local function applyTPDown(sinkAmount, forwardForce)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics or
       state == Enum.HumanoidStateType.Ragdoll or
       state == Enum.HumanoidStateType.FallingDown then
        return
    end

    local oldHealth = hum.Health

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -500, 0), rayParams)
    if not ray then return end

    local groundY = ray.Position.Y
    local offset = (hum.HipHeight or 2) + (hrp.Size.Y / 2) - sinkAmount
    local targetY = groundY + offset

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)

    RunService.Heartbeat:Wait()

    if forwardForce > 0 then
        local forwardDir = hrp.CFrame.LookVector
        hrp.AssemblyLinearVelocity = Vector3.new(forwardDir.X * forwardForce, 0, forwardDir.Z * forwardForce)
    end

    if hum and hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end

    task.wait(0.05)
    if hum and hum.Health < oldHealth then
        hum.Health = oldHealth
    end
end

local function runTPFloor()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hrp.CFrame = CFrame.new(hrp.Position.X, -7.00, hrp.Position.Z)
        * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

local function executeTPDown()
    if tpDownMode == 1 then
        applyTPDown(0.8, 48)
    else
        runTPFloor()
    end
end

local function startAutoTPDown()
    if autoTPDownConn then autoTPDownConn:Disconnect() end
    autoTPDownConn = RunService.RenderStepped:Connect(function()
        if not autoTPDownEnabled then return end
        if autoLeftEnabled or autoRightEnabled or autoBatEnabled or bypassToggled then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics or
           state == Enum.HumanoidStateType.Ragdoll or
           state == Enum.HumanoidStateType.FallingDown then
            return
        end
        if hrp.Position.Y >= autoTPDownThreshold then
            if tpDownMode == 1 then
                applyTPDown(0.8, 48)
            else
                runTPFloor()
            end
        end
    end)
end

local function stopAutoTPDown()
    if autoTPDownConn then autoTPDownConn:Disconnect(); autoTPDownConn = nil end
end

local modeValLbl = nil
-- refreshSpeedModeLabel ya definida arriba

-- toggleCarryMode y toggleLaggerCycle ya definidas arriba

local function toggleLockUI(state)
    if state == nil then
        uiLocked = not uiLocked
    else
        uiLocked = state
    end
    if setLockUIVisual then setLockUIVisual(uiLocked) end
end

local function resetFloatingPositions()
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        container.Position = UDim2.new(1, -128 - 10, 0, 0)
    end
    if bypassFloatingButton and bypassFloatingButton:FindFirstChild("Frame") then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = UDim2.new(1, -10 - 60, 0, 294 + 10)
        bypassFloatingPos = nil
    end
    savedMobilePanelPos = nil
    bypassFloatingPos = nil
    pcall(saveAllSettings)
end

local CONFIG_FILE = "KSK.json"
local savedMobilePanelPos = nil
local savedProgressBarPos = nil
local savedBypassPos = nil
local lastSavedJSON = nil

local function buildConfigTable()
    local config = {
        normalSpeed = NS,
        carrySpeed = CS,
        laggerSpeed1 = LAGGER_SPEED_1,
        laggerSpeed2 = LAGGER_SPEED_2,
        stealRadius = CONFIG.STEAL_RANGE,
        autoTPHeight = autoTPHeight,
        antiRagdoll = antiRagdollEnabled,
        autoSteal = CONFIG.AUTO_STEAL_ENABLED,
        jumpEnabled = jumpEnabled,
        jumpMode = jumpMode,
        tpDownMode = tpDownMode,
        medusaCounter = medusaCounterEnabled,
        batCounter = batCounterEnabled,
        laggerToggled = laggerToggled,
        laggerLevel = laggerLevel,
        carryMode = speedMode,
        autoBat = autoBatEnabled,
        autoLeft = autoLeftEnabled,
        autoRight = autoRightEnabled,
        unwalk = unwalkEnabled,
        antiLag = antiLagEnabled,
        autoTPDownEnabled = autoTPDownEnabled,
        autoTPDownThreshold = autoTPDownThreshold,
        lockUI = uiLocked,
        batAimbotSpeed = BAT_AIMBOT_SPEED,
        bypassToggled = false,
        bypassSpeed = BYPASS_AIMBOT_SPEED,
        bypassMode = bypassMode,
        dropMode = dropMode,
        stretchEnabled = stretchEnabled,
        stretchFOV = stretchFOV,
        stretchRez = stretchRezEnabled,
        dropBrainrotKey = {kb = KB.DropBrainrot.kb and KB.DropBrainrot.kb.Name, gp = KB.DropBrainrot.gp and KB.DropBrainrot.gp.Name},
        autoLeftKey = {kb = KB.AutoLeft.kb and KB.AutoLeft.kb.Name, gp = KB.AutoLeft.gp and KB.AutoLeft.gp.Name},
        autoRightKey = {kb = KB.AutoRight.kb and KB.AutoRight.kb.Name, gp = KB.AutoRight.gp and KB.AutoRight.gp.Name},
        autoBatKey = {kb = KB.AutoBat.kb and KB.AutoBat.kb.Name, gp = KB.AutoBat.gp and KB.AutoBat.gp.Name},
        tpFloorKey = {kb = KB.TPFloor.kb and KB.TPFloor.kb.Name, gp = KB.TPFloor.gp and KB.TPFloor.gp.Name},
        carryToggleKey = {kb = KB.CarryToggle.kb and KB.CarryToggle.kb.Name, gp = KB.CarryToggle.gp and KB.CarryToggle.gp.Name},
        laggerModeKey = {kb = KB.LaggerMode.kb and KB.LaggerMode.kb.Name, gp = KB.LaggerMode.gp and KB.LaggerMode.gp.Name},
        autoTPDownKey = {kb = KB.AutoTPDown.kb and KB.AutoTPDown.kb.Name, gp = KB.AutoTPDown.gp and KB.AutoTPDown.gp.Name},
        jumpModeKey = {kb = KB.JumpMode.kb and KB.JumpMode.kb.Name, gp = KB.JumpMode.gp and KB.JumpMode.gp.Name},
        bypassKey = {kb = KB.Bypass.kb and KB.Bypass.kb.Name, gp = KB.Bypass.gp and KB.Bypass.gp.Name},
        bypassFloatingPos = bypassFloatingPos,
        introEnabled = _introEnabled,
    }
    if pbFrame then
        config.progressBarPos = {
            XScale = pbFrame.Position.X.Scale,
            XOffset = pbFrame.Position.X.Offset,
            YScale = pbFrame.Position.Y.Scale,
            YOffset = pbFrame.Position.Y.Offset
        }
    end
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        config.mobilePanelPos = {
            XScale = container.Position.X.Scale,
            XOffset = container.Position.X.Offset,
            YScale = container.Position.Y.Scale,
            YOffset = container.Position.Y.Offset
        }
    end
    return config
end

local function saveAllSettings()
    local config = buildConfigTable()
    local json = HS:JSONEncode(config)
    if json == lastSavedJSON then
        return true
    end
    local success, err = pcall(function()
        writefile(CONFIG_FILE, json)
    end)
    if success then
        lastSavedJSON = json
    end
    return success
end

local function loadAllSettings()
    if not isfile or not isfile(CONFIG_FILE) then return false end
    local success, data = pcall(function()
        return HS:JSONDecode(readfile(CONFIG_FILE))
    end)
    if not success or not data then return false end
    if data.normalSpeed then NS = data.normalSpeed end
    if data.carrySpeed then CS = data.carrySpeed end
    if data.laggerSpeed1 then LAGGER_SPEED_1 = data.laggerSpeed1 end
    if data.laggerSpeed2 then LAGGER_SPEED_2 = data.laggerSpeed2 end
    if data.stealRadius then CONFIG.STEAL_RANGE = data.stealRadius end
    if data.autoTPHeight then autoTPHeight = data.autoTPHeight end
    if data.autoTPDownEnabled ~= nil then autoTPDownEnabled = data.autoTPDownEnabled end
    if data.autoTPDownThreshold then autoTPDownThreshold = data.autoTPDownThreshold end
    if data.lockUI ~= nil then uiLocked = data.lockUI end
    if data.autoLeft ~= nil then autoLeftEnabled = data.autoLeft end
    if data.autoRight ~= nil then autoRightEnabled = data.autoRight end
    if data.antiRagdoll then antiRagdollEnabled = data.antiRagdoll end
    if data.autoSteal ~= nil then CONFIG.AUTO_STEAL_ENABLED = data.autoSteal end
    if data.jumpEnabled ~= nil then jumpEnabled = data.jumpEnabled end
    if data.jumpMode then jumpMode = data.jumpMode end
    if data.tpDownMode then tpDownMode = data.tpDownMode end
    if data.medusaCounter then medusaCounterEnabled = data.medusaCounter end
    if data.batCounter then batCounterEnabled = data.batCounter end
    if data.autoBat then autoBatEnabled = data.autoBat end
    if data.unwalk then unwalkEnabled = data.unwalk end
    if data.antiLag then antiLagEnabled = data.antiLag end
    if data.laggerToggled then
        laggerToggled = true
        speedMode = false
        laggerLevel = data.laggerLevel or 1
    elseif data.carryMode then
        speedMode = true
        laggerToggled = false
    else
        speedMode = false
        laggerToggled = false
        laggerLevel = 1
    end
    if data.stretchRez ~= nil then
        stretchRezEnabled = data.stretchRez
    end
    if data.jumpModeKey then
        local jk = data.jumpModeKey
        if jk.kb and Enum.KeyCode[jk.kb] then
            KB.JumpMode.kb = Enum.KeyCode[jk.kb]
            KB.JumpMode.gp = nil
        end
        if jk.gp and Enum.KeyCode[jk.gp] then
            KB.JumpMode.gp = Enum.KeyCode[jk.gp]
            KB.JumpMode.kb = nil
        end
    end
    if data.bypassKey then
        local bk = data.bypassKey
        if bk.kb and Enum.KeyCode[bk.kb] then
            KB.Bypass.kb = Enum.KeyCode[bk.kb]
            KB.Bypass.gp = nil
        end
        if bk.gp and Enum.KeyCode[bk.gp] then
            KB.Bypass.gp = Enum.KeyCode[bk.gp]
            KB.Bypass.kb = nil
        end
    end
    if data.bypassFloatingPos then
        bypassFloatingPos = data.bypassFloatingPos
    end
    if data.batAimbotSpeed then
        BAT_AIMBOT_SPEED = data.batAimbotSpeed
        if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end
    end
    if data.bypassSpeed then
        BYPASS_AIMBOT_SPEED = data.bypassSpeed
        if bypassSpeedBox then bypassSpeedBox.Text = tostring(BYPASS_AIMBOT_SPEED) end
    end
    bypassToggled = false
    if data.bypassMode then
        bypassMode = data.bypassMode
        if bypassModeBtnRef then
            bypassModeBtnRef.Text = bypassMode == 1 and "Bypass" or "TP Bat"
        end
    end
    dropMode = 1
    if data.stretchEnabled ~= nil then
        stretchEnabled = data.stretchEnabled
    end
    if data.stretchFOV then
        stretchFOV = data.stretchFOV
    end
    local function loadKey(kbData, target)
        if kbData and kbData.kb and Enum.KeyCode[kbData.kb] then
            target.kb = Enum.KeyCode[kbData.kb]
            target.gp = nil
        end
        if kbData and kbData.gp and Enum.KeyCode[kbData.gp] then
            target.gp = Enum.KeyCode[kbData.gp]
            target.kb = nil
        end
    end
    loadKey(data.dropBrainrotKey, KB.DropBrainrot)
    loadKey(data.autoLeftKey, KB.AutoLeft)
    loadKey(data.autoRightKey, KB.AutoRight)
    loadKey(data.autoBatKey, KB.AutoBat)
    loadKey(data.tpFloorKey, KB.TPFloor)
    loadKey(data.carryToggleKey, KB.CarryToggle)
    loadKey(data.laggerModeKey, KB.LaggerMode)
    loadKey(data.autoTPDownKey, KB.AutoTPDown)
    if data.progressBarPos then savedProgressBarPos = data.progressBarPos end
    if data.mobilePanelPos then savedMobilePanelPos = data.mobilePanelPos end
    if data.introEnabled ~= nil then _introEnabled = data.introEnabled end
    refreshSpeedModeLabel()
    lastSavedJSON = HS:JSONEncode(buildConfigTable())
    return true
end

local function resetToDefaults()
    stopAllBackgroundTasks()
    NS = 60
    CS = 30
    LAGGER_SPEED_1 = 15
    LAGGER_SPEED_2 = 10
    CONFIG.STEAL_RANGE = 9
    CONFIG.AUTO_STEAL_ENABLED = false
    autoTPHeight = 20
    autoTPDownThreshold = 20
    speedMode = false
    laggerToggled = false
    laggerLevel = 1
    antiRagdollEnabled = false
    jumpEnabled = false
    jumpMode = 1
    tpDownMode = 1
    medusaCounterEnabled = false
    batCounterEnabled = false
    autoBatEnabled = false
    autoLeftEnabled = false
    autoRightEnabled = false
    unwalkEnabled = false
    antiLagEnabled = false
    autoTPDownEnabled = false
    uiLocked = false
    BAT_AIMBOT_SPEED = 58
    BYPASS_AIMBOT_SPEED = 60
    bypassToggled = false
    bypassMode = 1
    dropMode = 1
    stretchEnabled = false
    stretchFOV = 120
    stretchRezEnabled = false
    _introEnabled = true
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPHeight) end
    if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end
    if bypassSpeedBox then bypassSpeedBox.Text = tostring(BYPASS_AIMBOT_SPEED) end
    if progressRadLbl then progressRadLbl.Text = "-- · --" end
    if autoBatSetVisual then autoBatSetVisual(false) end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if setBatCounterVisual then setBatCounterVisual(false) end
    if setMedusaVisual then setMedusaVisual(false) end
    if setAntiRagVisual then setAntiRagVisual(false) end
    if setJumpVisual then setJumpVisual(false) end
    if setUnwalkVisual then setUnwalkVisual(false) end
    if setAntiLagVisual then setAntiLagVisual(false) end
    if setAutoTPDownVisual then setAutoTPDownVisual(false) end
    if setLockUIVisual then setLockUIVisual(false) end
    if setStretchRezVisual then setStretchRezVisual(false) end
    if setInstaGrab then setInstaGrab(false) end
    if bypassSetVisual then bypassSetVisual(false) end
    if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
    if mobSetAutoBat then mobSetAutoBat(false) end
    if mobSetAutoLeft then mobSetAutoLeft(false) end
    if mobSetAutoRight then mobSetAutoRight(false) end
    if mobSetDropBR then mobSetDropBR(false) end
    if mobSetTpDown then mobSetTpDown(false) end
    if mobSetCarry then mobSetCarry(false) end
    if mobSetLagger1 then mobSetLagger1(false) end
    if mobSetLagger2 then mobSetLagger2(false) end
    if modeSelectBtn then
        modeSelectBtn.Text = jumpMode == 1 and "Tap Tap" or "Hold"
    end
    if tpModeSelectBtn then
        tpModeSelectBtn.Text = tpDownMode == 1 and "V1" or "V2"
    end
    if bypassModeBtnRef then
        bypassModeBtnRef.Text = bypassMode == 1 and "Bypass" or "TP Bat"
    end
    if setJumpToggleState then setJumpToggleState(false) end
    if setIntroVisual then setIntroVisual(_introEnabled) end
    refreshSpeedModeLabel()
    lastSavedJSON = HS:JSONEncode(buildConfigTable())
end

local function deleteAllSettings()
    local success = false
    if isfile and isfile(CONFIG_FILE) then
        success = pcall(function() delfile(CONFIG_FILE); return true end)
    end
    if isfile and isfile("LustHub_PanelPos.txt") then
        pcall(delfile, "LustHub_PanelPos.txt")
    end
    if isfile and isfile(INTRO_CONFIG_FILE) then
        pcall(delfile, INTRO_CONFIG_FILE)
    end
    resetToDefaults()
    if pbFrame then
        pbFrame.Position = UDim2.new(0.5, -140, 1, -66)
    end
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        container.Position = UDim2.new(1, -128 - 10, 0, 0)
    end
    bypassFloatingPos = nil
    if bypassFloatingButton and bypassFloatingButton:FindFirstChild("Frame") then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = UDim2.new(1, -10 - 60, 0, 294 + 10)
    end
    return success
end

local function updateProgressBarVisibility()
    if pbFrame then
        pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED
    end
end

local gui = nil
local main = nil
local miniBtn = nil

local function buildGui()
    local BLACK   = Color3.fromRGB(0,0,0)
    local AZUL    = Color3.fromRGB(128, 0, 255)
    local INP     = Color3.fromRGB(12,12,12)
    local CORNER  = 30
    local GUI_W, GUI_H = 350, 520

    local old=game:GetService("CoreGui"):FindFirstChild("KSK")
    if old then old:Destroy() end
    local pg=LP:FindFirstChild("PlayerGui")
    if pg then
        local o=pg:FindFirstChild("KSK")
        if o then o:Destroy() end
    end
    gui=Instance.new("ScreenGui")
    gui.Name="KSK"
    gui.ResetOnSpawn=false
    gui.DisplayOrder=10
    gui.IgnoreGuiInset=true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent=game:GetService("CoreGui") end) then gui.Parent=LP:WaitForChild("PlayerGui") end

    main=Instance.new("Frame",gui)
    main.Size=UDim2.new(0,GUI_W,0,GUI_H)
    main.Position=UDim2.new(0,20,0,2)
    main.BackgroundColor3 = BLACK
    main.BackgroundTransparency = 1
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner",main).CornerRadius=UDim.new(0,CORNER)

    local bgImage = Instance.new("ImageLabel", main)
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Position = UDim2.new(0, 0, 0, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.Image = "rbxassetid://82036967428637"
    bgImage.ZIndex = 0
    bgImage.ImageTransparency = 0

    local mainStroke=Instance.new("UIStroke",main)
    mainStroke.Color = AZUL
    mainStroke.Thickness=1.2
    mainStroke.Transparency=0.55

    local shadow = Instance.new("Frame", main)
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Position = UDim2.new(0, -4, 0, 4)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, CORNER)

    local brandFrame = Instance.new("Frame", main)
    brandFrame.Size = UDim2.new(1, -20, 0, 50)
    brandFrame.Position = UDim2.new(0, 10, 0, 8)
    brandFrame.BackgroundTransparency = 1

    local brandTitle = Instance.new("TextLabel", brandFrame)
    brandTitle.Size = UDim2.new(1, 0, 0, 20)
    brandTitle.Position = UDim2.new(0, 0, 0, 0)
    brandTitle.BackgroundTransparency = 1
    brandTitle.Text = "KSK OP"
    brandTitle.TextColor3 = AZUL
    brandTitle.Font = Enum.Font.GothamBold
    brandTitle.TextSize = 16
    brandTitle.TextXAlignment = Enum.TextXAlignment.Center

    local brandLine = Instance.new("Frame", brandFrame)
    brandLine.Size = UDim2.new(0.4, 0, 0, 2)
    brandLine.Position = UDim2.new(0.3, 0, 1, -4)
    brandLine.BackgroundColor3 = AZUL
    brandLine.BorderSizePixel = 0
    Instance.new("UICorner", brandLine).CornerRadius = UDim.new(1, 0)

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 10)
    closeBtn.BackgroundColor3 = BLACK
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "-"
    closeBtn.TextColor3 = AZUL
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 24
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 200
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    local closeStroke = Instance.new("UIStroke", closeBtn)
    closeStroke.Color = AZUL
    closeStroke.Thickness = 1.2
    closeStroke.Transparency = 0.3
    closeBtn.MouseEnter:Connect(function()
        closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
        closeStroke.Color = Color3.fromRGB(255,255,255)
        closeStroke.Transparency = 0
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.TextColor3 = AZUL
        closeBtn.BackgroundColor3 = BLACK
        closeStroke.Color = AZUL
        closeStroke.Transparency = 0.3
    end)

    miniBtn=Instance.new("TextButton",gui)
    miniBtn.Size=UDim2.new(0,118,0,30)
    miniBtn.Position=UDim2.new(0,16,0,58)
    miniBtn.BackgroundColor3 = BLACK
    miniBtn.BorderSizePixel=0
    miniBtn.Text="KSK OP"
    miniBtn.TextColor3 = AZUL
    miniBtn.Font=Enum.Font.GothamBold
    miniBtn.TextSize=12
    miniBtn.ZIndex=20
    miniBtn.Visible=false
    Instance.new("UICorner",miniBtn).CornerRadius=UDim.new(0,8)
    local miniStroke=Instance.new("UIStroke",miniBtn)
    miniStroke.Color = AZUL
    miniStroke.Thickness=1.2
    miniStroke.Transparency=0.4

    local function showGui()
        main.Visible=true
        miniBtn.Visible=false
    end

    local function hideGui()
        main.Visible=false
        miniBtn.Visible=true
    end

    closeBtn.MouseButton1Click:Connect(hideGui)
    miniBtn.MouseButton1Click:Connect(showGui)

    local contentArea = Instance.new("Frame", main)
    contentArea.Size = UDim2.new(1, -12, 1, -62)
    contentArea.Position = UDim2.new(0, 6, 0, 56)
    contentArea.BackgroundColor3 = Color3.fromRGB(20,20,20)
    contentArea.BackgroundTransparency = 0.5
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 16)
    local contentSt=Instance.new("UIStroke",contentArea)
    contentSt.Color = AZUL
    contentSt.Thickness=1
    contentSt.Transparency=0.15

    local pageHolder = Instance.new("Frame", contentArea)
    pageHolder.Size = UDim2.new(1, -6, 1, -6)
    pageHolder.Position = UDim2.new(0, 3, 0, 3)
    pageHolder.BackgroundTransparency = 1
    pageHolder.BorderSizePixel = 0

    local function buildPage()
        local p = Instance.new("ScrollingFrame", pageHolder)
        p.Size = UDim2.new(1, -2, 1, 0)
        p.Position = UDim2.new(0, 0, 0, 0)
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.ClipsDescendants = true
        p.ScrollBarThickness = 4
        p.ScrollBarImageColor3 = AZUL
        p.ScrollBarImageTransparency = 0.3
        p.CanvasSize = UDim2.new(0, 0, 0, 0)
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local ll = Instance.new("UIListLayout", p)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0, 5)
        local pd = Instance.new("UIPadding", p)
        pd.PaddingLeft = UDim.new(0, 4)
        pd.PaddingRight = UDim.new(0, 4)
        pd.PaddingTop = UDim.new(0, 4)
        pd.PaddingBottom = UDim.new(0, 4)
        return p
    end

    local scrollPage = buildPage()

    local function mkSect(txt)
        local f = Instance.new("Frame", scrollPage)
        f.Size = UDim2.new(1, 0, 0, 22)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -10, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt:upper()
        l.TextColor3 = AZUL
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        f.LayoutOrder = #scrollPage:GetChildren() + 1
        local line = Instance.new("Frame", f)
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Position = UDim2.new(0, 10, 1, -2)
        line.BackgroundColor3 = AZUL
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        return f
    end

    local function mkRow(h)
        local f = Instance.new("Frame", scrollPage)
        f.Size = UDim2.new(1, -2, 0, h or 38)
        f.BackgroundColor3 = BLACK
        f.BorderSizePixel = 0
        f.LayoutOrder = #scrollPage:GetChildren() + 1
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        return f
    end

    local function mkLabel(row, txt)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.55, 0, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = AZUL
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        return l
    end

    local function mkPill(row, offset)
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 42, 0, 22)
        pill.Position = UDim2.new(1, -(offset or 52), 0.5, -11)
        pill.BackgroundColor3 = Color3.fromRGB(42,42,42)
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local dot = Instance.new("Frame", pill)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(0, 3, 0.5, -8)
        dot.BackgroundColor3 = Color3.fromRGB(130,130,130)
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        return pill, dot
    end

    local function setPillState(pill, dot, on)
        if on then
            pill.BackgroundColor3 = AZUL
            dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            dot.Position = UDim2.new(1, -19, 0.5, -8)
        else
            pill.BackgroundColor3 = Color3.fromRGB(42,42,42)
            dot.BackgroundColor3 = Color3.fromRGB(130,130,130)
            dot.Position = UDim2.new(0, 3, 0.5, -8)
        end
    end

    local function mkToggle(txt, cb)
        local row = mkRow(38)
        mkLabel(row, txt)
        local pill, dot = mkPill(row, 52)
        local on = false
        local function sv(s) on=s; setPillState(pill,dot,s) end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1,0,1,0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.Activated:Connect(function()
            on = not on
            sv(on)
            pcall(cb, on)
        end)
        return sv
    end

    local function mkBox(parent, default, w, xOff, cb)
        local tb = Instance.new("TextBox", parent)
        local bw = w or 45
        local xo = math.max(xOff or 52, bw + 8)
        tb.Size = UDim2.new(0, bw, 0, 24)
        tb.Position = UDim2.new(1, -xo, 0.5, -12)
        tb.BackgroundColor3 = INP
        tb.BorderSizePixel = 0
        tb.Text = tostring(default)
        tb.TextColor3 = AZUL
        tb.Font = Enum.Font.GothamBold
        tb.TextSize = 10
        tb.ClearTextOnFocus = false
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", tb)
        bs.Color = AZUL
        bs.Thickness = 1
        bs.Transparency = 0.28
        tb.FocusLost:Connect(function()
            if cb then local n = tonumber(tb.Text); if n then cb(n) else tb.Text = tostring(default) end end
        end)
        return tb
    end

    local function mkSelector(parent, default, cb)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 46, 0, 22)
        btn.Position = UDim2.new(1, -52, 0.5, -11)
        btn.BackgroundColor3 = BLACK
        btn.BorderSizePixel = 0
        btn.Text = default
        btn.TextColor3 = AZUL
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 9
        btn.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = AZUL
        stroke.Thickness = 1
        btn.MouseButton1Click:Connect(function()
            if _anyKeyListening then return end
            if cb then cb(btn) end
        end)
        return btn
    end

    mkSect("Speed")
    do local row=mkRow(38); mkLabel(row,"Normal Speed"); normalBox=mkBox(row,NS,45,52,function(v) if v>0 and v<=500 then NS=v end end) end
    do local row=mkRow(38); mkLabel(row,"Carry Speed"); carryBox=mkBox(row,CS,45,52,function(v) if v>0 and v<=500 then CS=v end end) end
    do local row=mkRow(38); mkLabel(row,"Lagger 1 Speed"); laggerBox=mkBox(row,LAGGER_SPEED_1,45,52,function(v) if v>0 and v<=500 then LAGGER_SPEED_1=v end end) end
    do local row=mkRow(38); mkLabel(row,"Lagger 2 Speed"); lagger2Box=mkBox(row,LAGGER_SPEED_2,45,52,function(v) if v>0 and v<=500 then LAGGER_SPEED_2=v end end) end
    do local row=mkRow(38); mkLabel(row,"Current Mode"); modeValLbl=Instance.new("TextLabel",row); modeValLbl.Size=UDim2.new(0,90,1,0); modeValLbl.Position=UDim2.new(1,-94,0,0); modeValLbl.BackgroundTransparency=1; modeValLbl.Text="Normal"; modeValLbl.TextColor3=AZUL; modeValLbl.Font=Enum.Font.GothamBlack; modeValLbl.TextSize=11; modeValLbl.TextXAlignment=Enum.TextXAlignment.Right; local clk=Instance.new("TextButton",row); clk.Size=UDim2.new(1,0,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.Activated:Connect(function() if _anyKeyListening then return end; toggleCarryMode() end) end

    mkSect("Combat")
    autoBatSetVisual = mkToggle("Auto Bat", function(on)
        if on then enableAutoBat() else disableAutoBat() end
        if mobSetAutoBat then mobSetAutoBat(on) end
    end)
    do local row=mkRow(38); mkLabel(row,"Bat Speed"); batSpeedBox=mkBox(row,BAT_AIMBOT_SPEED,45,52,function(v) if v>0 and v<=200 then BAT_AIMBOT_SPEED=v end end) end

    bypassSetVisual = mkToggle("BAT OP", function(on)
        toggleBypass(on)
        if bypassFloatingButton then
            local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
            if btnFrame then
                local label = btnFrame:FindFirstChild("TextLabel")
                if on then
                    btnFrame.BackgroundColor3 = AZUL
                    if label then label.TextColor3 = Color3.fromRGB(255,255,255) end
                else
                    btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    if label then label.TextColor3 = AZUL end
                end
            end
        end
    end)
    if bypassSetVisual then bypassSetVisual(bypassToggled) end
    do local row=mkRow(38); mkLabel(row,"Bypass Speed"); bypassSpeedBox=mkBox(row,BYPASS_AIMBOT_SPEED,45,52,function(v) if v>0 and v<=200 then BYPASS_AIMBOT_SPEED=v end end) end
    do
        local row = mkRow(38)
        mkLabel(row, "Bypass Mode")
        bypassModeBtnRef = mkSelector(row, bypassMode == 1 and "Bypass" or "TP Bat", function(btn)
            toggleBypassMode()
            btn.Text = bypassMode == 1 and "Bypass" or "TP Bat"
        end)
    end

    setBatCounterVisual = mkToggle("Bat Counter", function(on)
        batCounterEnabled = on
        if on then startBatCounter() else stopBatCounter() end
    end)

    setMedusaVisual = mkToggle("Medusa Counter", function(on)
        setMedusaCounterState(on)
    end)

    setAntiRagVisual = mkToggle("Anti Ragdoll", function(on)
        antiRagdollEnabled = on
        if on then startAntiRagdoll() else stopAntiRagdoll() end
    end)

    mkSect("Mechanics")
    do
        local row = mkRow(38)
        mkLabel(row, "Infinite Jump")
        jumpPill, jumpDot = mkPill(row, 52)
        jumpOn = false
        setJumpToggleState = function(state)
            if jumpOn == state then return end
            jumpOn = state
            setPillState(jumpPill, jumpDot, state)
            if state then
                jumpEnabled = true
                startJumpMode()
            else
                jumpEnabled = false
                stopJumpMode()
            end
        end
        local jumpClk = Instance.new("TextButton", jumpPill)
        jumpClk.Size = UDim2.new(1,0,1,0)
        jumpClk.BackgroundTransparency = 1
        jumpClk.Text = ""
        jumpClk.Activated:Connect(function()
            if _anyKeyListening then return end
            setJumpToggleState(not jumpOn)
        end)
        setJumpVisual = function(state) setJumpToggleState(state) end
    end

    do
        local row = mkRow(38)
        mkLabel(row, "Jump Mode")
        modeSelectBtn = mkSelector(row, jumpMode == 1 and "Tap Tap" or "Hold", function(btn)
            local newMode = jumpMode == 1 and 2 or 1
            jumpMode = newMode
            btn.Text = jumpMode == 1 and "Tap Tap" or "Hold"
            if jumpEnabled then
                stopJumpMode()
                startJumpMode()
            end
        end)
    end

    setUnwalkVisual = mkToggle("Unwalk", function(on)
        unwalkEnabled = on
        if on then startUnwalk() else stopUnwalk() end
    end)

    dropBrainrotSetVisual = mkToggle("Drop Brainrot", function(on)
        if on then
            executeDropWithToggle(function(v)
                dropBrainrotSetVisual(v)
                if mobSetDropBR then mobSetDropBR(v) end
            end)
        end
    end)
    setDropVisual = dropBrainrotSetVisual

    setAntiLagVisual = mkToggle("Anti Lag", function(on)
        if on then enableAntiLag() else disableAntiLag() end
    end)

    mkSect("Auto Left / Right")
    autoLeftSetVisual = mkToggle("Auto Left", function(on)
        if on then
            autoLeftEnabled = true
            startAutoLeft()
        else
            autoLeftEnabled = false
            stopAutoLeft()
        end
        if mobSetAutoLeft then mobSetAutoLeft(on) end
    end)
    autoRightSetVisual = mkToggle("Auto Right", function(on)
        if on then
            autoRightEnabled = true
            startAutoRight()
        else
            autoRightEnabled = false
            stopAutoRight()
        end
        if mobSetAutoRight then mobSetAutoRight(on) end
    end)

    mkSect("Teleport")
    do
        local row = mkRow(38)
        mkLabel(row, "TP Down Mode")
        tpModeSelectBtn = mkSelector(row, tpDownMode == 1 and "V1" or "V2", function(btn)
            tpDownMode = tpDownMode == 1 and 2 or 1
            btn.Text = tpDownMode == 1 and "V1" or "V2"
        end)
    end
    setAutoTPDownVisual = mkToggle("Auto TP Down", function(on)
        autoTPDownEnabled = on
        if on then startAutoTPDown() else stopAutoTPDown() end
    end)
    do local row=mkRow(38); mkLabel(row,"Height Y"); autoTPHeightBox=mkBox(row,autoTPHeight,45,52,function(v) if v>=1 and v<=500 then autoTPHeight=v; autoTPDownThreshold=v end end) end

    mkSect("Steal")
    setInstaGrab = mkToggle("Auto Steal", function(on)
        CONFIG.AUTO_STEAL_ENABLED = on
        if on then
            pcall(startAutoSteal)
        else
            stopAutoSteal()
        end
        updateProgressBarVisibility()
    end)
    do local row=mkRow(38); mkLabel(row,"Steal Radius"); radInput=mkBox(row,CONFIG.STEAL_RANGE,45,52,function(v) if v>=0.5 and v<=300 then CONFIG.STEAL_RANGE=v end end) end

    mkSect("Interface")
    setLockUIVisual = mkToggle("Lock UI", function(on)
        toggleLockUI(on)
    end)

    setStretchRezVisual = mkToggle("FPS Boost", function(on)
        if on then
            enableStretchRez()
        else
            disableStretchRez()
        end
    end)

    setIntroVisual = mkToggle("Play Intro", function(on)
        _introEnabled = on
        if setIntroVisual then setIntroVisual(on) end
        pcall(saveAllSettings)
    end)

    mkSect("Config")
    do
        local row = mkRow(38)
        row.Size = UDim2.new(1, -8, 0, 38)
        local resetBtn = Instance.new("TextButton", row)
        resetBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
        resetBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
        resetBtn.BackgroundColor3 = BLACK
        resetBtn.BorderSizePixel = 0
        resetBtn.Text = "RESET POSITIONS"
        resetBtn.TextColor3 = AZUL
        resetBtn.Font = Enum.Font.Gotham
        resetBtn.TextSize = 10
        Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
        local resetStroke = Instance.new("UIStroke", resetBtn)
        resetStroke.Color = AZUL
        resetStroke.Thickness = 1.2
        resetBtn.Activated:Connect(function()
            resetFloatingPositions()
            resetBtn.Text = "RESET ✓"
            resetBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
            task.delay(1.2, function()
                if resetBtn and resetBtn.Parent then
                    resetBtn.Text = "RESET POSITIONS"
                    resetBtn.BackgroundColor3 = BLACK
                end
            end)
        end)
    end

    do
        local row = mkRow(44)
        row.Size = UDim2.new(1, -8, 0, 44)
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
        delBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
        delBtn.BackgroundColor3 = BLACK
        delBtn.BorderSizePixel = 0
        delBtn.Text = "DELETE SETTINGS"
        delBtn.TextColor3 = AZUL
        delBtn.Font = Enum.Font.Gotham
        delBtn.TextSize = 10
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
        local delStroke = Instance.new("UIStroke", delBtn)
        delStroke.Color = AZUL
        delStroke.Thickness = 1.2

        local deleteState=0
        local originalDeleteText="DELETE SETTINGS"
        delBtn.Activated:Connect(function()
            if deleteState==0 then
                deleteState=1
                delBtn.Text="CONFIRM?"
                delBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
                delBtn.TextColor3=Color3.fromRGB(255,255,255)
                task.delay(2,function()
                    if delBtn and delBtn.Parent and deleteState==1 then
                        deleteState=0
                        delBtn.Text=originalDeleteText
                        delBtn.BackgroundColor3=BLACK
                        delBtn.TextColor3=AZUL
                    end
                end)
            elseif deleteState==1 then
                local success=deleteAllSettings()
                if success then
                    delBtn.Text="DELETED ✓"
                    delBtn.BackgroundColor3=Color3.fromRGB(30,30,30)
                    delBtn.TextColor3=AZUL
                    task.delay(1.5,function()
                        if delBtn and delBtn.Parent then
                            deleteState=0
                            delBtn.Text=originalDeleteText
                            delBtn.BackgroundColor3=BLACK
                            delBtn.TextColor3=AZUL
                        end
                    end)
                else
                    delBtn.Text="NO FILE"
                    delBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
                    delBtn.TextColor3=Color3.fromRGB(255,255,255)
                    task.delay(1.2,function()
                        if delBtn and delBtn.Parent then
                            deleteState=0
                            delBtn.Text=originalDeleteText
                            delBtn.BackgroundColor3=BLACK
                            delBtn.TextColor3=AZUL
                        end
                    end)
                end
            end
        end)
    end

    mkSect("Keybinds")

    local keyButtonRefs = {}

    local function mkKeyButton(parent, kbEntry)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 75, 0, 24)
        btn.Position = UDim2.new(1, -83, 0.5, -12)
        btn.BackgroundColor3 = INP
        btn.BorderSizePixel = 0
        local function getLabel() return (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None" end
        btn.Text = getLabel()
        btn.TextColor3 = AZUL
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = AZUL
        bs.Thickness = 1
        local li = false; local lc; local pv = btn.Text; local listenStart = 0
        btn.Activated:Connect(function()
            if li then li=false; _anyKeyListening=false; if lc then lc:Disconnect(); lc=nil end; btn.Text=pv; btn.TextColor3=AZUL; return end
            pv = btn.Text; li = true; _anyKeyListening = true; listenStart = tick(); btn.Text = "..."; btn.TextColor3 = Color3.fromRGB(255,255,255)
            lc = UIS.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode == Enum.KeyCode.Escape then li=false; _anyKeyListening=false; if lc then lc:Disconnect(); lc=nil end; btn.Text=pv; btn.TextColor3=AZUL; return end
                local isGp = isGamepadInput(inp)
                if isGp and tick()-listenStart < 0.15 then return end
                if not isBindableInput(inp) then return end
                btn.Text = inp.KeyCode.Name; pv = inp.KeyCode.Name; btn.TextColor3 = AZUL
                li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc=nil end
                if isGp then kbEntry.gp = inp.KeyCode; kbEntry.kb = nil else kbEntry.kb = inp.KeyCode; kbEntry.gp = nil end
            end)
        end)
        return btn
    end

    local function addKeybindRow(labelText, kbEntry)
        local row = mkRow(34)
        mkLabel(row, labelText)
        local btn = mkKeyButton(row, kbEntry)
        table.insert(keyButtonRefs, {btn=btn, entry=kbEntry})
    end

    addKeybindRow("Carry Mode", KB.CarryToggle)
    addKeybindRow("Lagger Mode", KB.LaggerMode)
    addKeybindRow("Auto Left", KB.AutoLeft)
    addKeybindRow("Auto Right", KB.AutoRight)
    addKeybindRow("Auto Bat", KB.AutoBat)
    addKeybindRow("BAT OP", KB.Bypass)
    addKeybindRow("TP Down", KB.TPFloor)
    addKeybindRow("Drop Brainrot", KB.DropBrainrot)

    local spacer = Instance.new("Frame", scrollPage)
    spacer.Size = UDim2.new(1, 0, 0, 20)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 100
    spacer.Visible = true

    _G.keyButtonRefs = keyButtonRefs

    pbFrame = Instance.new("Frame", gui)
    pbFrame.Name = "StealPod"
    pbFrame.Size = UDim2.new(0, 300, 0, 52)
    pbFrame.Position = UDim2.new(0.5, -140, 1, -54)
    pbFrame.BackgroundColor3 = Color3.fromRGB(12, 6, 20)
    pbFrame.BorderSizePixel = 0
    pbFrame.ClipsDescendants = false
    pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED
    Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(0, 16)
    local pbGradBg = Instance.new("UIGradient", pbFrame)
    pbGradBg.Color = ColorSequence.new(Color3.fromRGB(32, 12, 52), Color3.fromRGB(12, 6, 20))
    pbGradBg.Rotation = 90
    local pbs = Instance.new("UIStroke", pbFrame)
    pbs.Color = Color3.fromRGB(128, 0, 255)
    pbs.Thickness = 1.4
    pbs.Transparency = 0.4
    pbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    progressStripe = Instance.new("Frame", pbFrame)
    progressStripe.Size = UDim2.new(0, 4, 1, -18)
    progressStripe.Position = UDim2.new(0, 8, 0, 9)
    progressStripe.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    progressStripe.BorderSizePixel = 0
    Instance.new("UICorner", progressStripe).CornerRadius = UDim.new(1, 0)

    local statusPill = Instance.new("Frame", pbFrame)
    statusPill.Size = UDim2.new(0, 158, 0, 24)
    statusPill.Position = UDim2.new(0, 20, 0, 7)
    statusPill.BackgroundColor3 = Color3.fromRGB(12, 6, 20)
    statusPill.BorderSizePixel = 0
    Instance.new("UICorner", statusPill).CornerRadius = UDim.new(1, 0)
    progressPillStroke = Instance.new("UIStroke", statusPill)
    progressPillStroke.Color = Color3.fromRGB(128, 0, 255)
    progressPillStroke.Thickness = 1
    progressPillStroke.Transparency = 0.45

    progressDot = Instance.new("Frame", statusPill)
    progressDot.Size = UDim2.new(0, 10, 0, 10)
    progressDot.Position = UDim2.new(0, 10, 0.5, -5)
    progressDot.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    progressDot.BorderSizePixel = 0
    Instance.new("UICorner", progressDot).CornerRadius = UDim.new(1, 0)
    progressDotGlow = Instance.new("UIStroke", progressDot)
    progressDotGlow.Color = Color3.fromRGB(128, 0, 255)
    progressDotGlow.Thickness = 2
    progressDotGlow.Transparency = 0.4
    task.spawn(function()
        while progressDot and progressDot.Parent do
            TS:Create(progressDotGlow, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {Transparency = 0.9, Thickness = 6}):Play()
            task.wait(0.78)
            TS:Create(progressDotGlow, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {Transparency = 0.3, Thickness = 2}):Play()
            task.wait(0.78)
        end
    end)

    progressPct = Instance.new("TextLabel", statusPill)
    progressPct.Size = UDim2.new(1, -30, 1, 0)
    progressPct.Position = UDim2.new(0, 26, 0, 0)
    progressPct.BackgroundTransparency = 1
    progressPct.Text = CONFIG.AUTO_STEAL_ENABLED and "READY" or "STEAL!"
    progressPct.TextColor3 = Color3.fromRGB(238, 225, 255)
    progressPct.Font = Enum.Font.GothamBlack
    progressPct.TextSize = 11
    progressPct.TextXAlignment = Enum.TextXAlignment.Left

    progressRadLbl = Instance.new("TextLabel", pbFrame)
    progressRadLbl.Size = UDim2.new(0, 104, 0, 24)
    progressRadLbl.Position = UDim2.new(1, -114, 0, 7)
    progressRadLbl.BackgroundTransparency = 1
    progressRadLbl.Text = string.format("◎ %.2g", CONFIG.STEAL_RANGE)
    progressRadLbl.TextColor3 = Color3.fromRGB(128, 0, 255)
    progressRadLbl.Font = Enum.Font.GothamBlack
    progressRadLbl.TextSize = 11
    progressRadLbl.TextXAlignment = Enum.TextXAlignment.Right

    local pbg = Instance.new("Frame", pbFrame)
    pbg.Size = UDim2.new(1, -40, 0, 9)
    pbg.Position = UDim2.new(0, 20, 1, -15)
    pbg.BackgroundColor3 = Color3.fromRGB(12, 6, 20)
    pbg.BorderSizePixel = 0
    Instance.new("UICorner", pbg).CornerRadius = UDim.new(1, 0)
    local pbgStroke = Instance.new("UIStroke", pbg)
    pbgStroke.Color = Color3.fromRGB(72, 28, 115)
    pbgStroke.Thickness = 1
    pbgStroke.Transparency = 0.45

    progressFill = Instance.new("Frame", pbg)
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    progressFill.BorderSizePixel = 0
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
    local fillGrad = Instance.new("UIGradient", progressFill)
    fillGrad.Color = ColorSequence.new(Color3.fromRGB(238, 225, 255), Color3.fromRGB(55, 220, 110))
    fillGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 0)})

    local function dragStealBar(f)
        local dn, ds, sp, di = false
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dn = true; ds = i.Position; sp = f.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dn = false end
                end)
            end
        end)
        f.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
        end)
        UIS.InputChanged:Connect(function(i)
            if i == di and dn then
                local nX = sp.X.Offset + (i.Position.X - ds.X)
                local nY = sp.Y.Offset + (i.Position.Y - ds.Y)
                f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
            end
        end)
    end
    dragStealBar(pbFrame)

    local function dragMain(f)
        local dn, ds, sp, di = false
        f.InputBegan:Connect(function(i)
            if uiLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dn = true; ds = i.Position; sp = f.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dn = false end
                end)
            end
        end)
        f.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
        end)
        UIS.InputChanged:Connect(function(i)
            if i == di and dn then
                if uiLocked then dn = false; return end
                local nX = sp.X.Offset + (i.Position.X - ds.X)
                local nY = sp.Y.Offset + (i.Position.Y - ds.Y)
                f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
            end
        end)
    end
    dragMain(main)

    task.spawn(function()
        local lastFrame = tick()
        local fpsSamples = {}
        local fpsAvg = 60
        RunService.RenderStepped:Connect(function()
            local now = tick()
            local dt = now - lastFrame
            lastFrame = now
            if dt > 0 then
                table.insert(fpsSamples, 1 / dt)
                if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
                local sum = 0
                for _, v in ipairs(fpsSamples) do sum = sum + v end
                fpsAvg = sum / #fpsSamples
            end
        end)
        while true do
            local ping = 0
            pcall(function()
                ping = LP:GetNetworkPing() * 1000
            end)
            if progressRadLbl then
                progressRadLbl.Text = string.format("%d FPS | %dms", math.floor(fpsAvg + 0.5), math.floor(ping + 0.5))
            end
            task.wait(0.5)
        end
    end)
end

local function updateUIFromLoaded()
    task.wait()
    if normalBox then normalBox.Text=tostring(NS) end
    if carryBox then carryBox.Text=tostring(CS) end
    if radInput then radInput.Text=tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text=tostring(LAGGER_SPEED_1) end
    if lagger2Box then lagger2Box.Text=tostring(LAGGER_SPEED_2) end
    if autoTPHeightBox then autoTPHeightBox.Text=tostring(autoTPHeight) end
    if batSpeedBox then batSpeedBox.Text = tostring(BAT_AIMBOT_SPEED) end
    if bypassSpeedBox then bypassSpeedBox.Text = tostring(BYPASS_AIMBOT_SPEED) end
    if tpModeSelectBtn then
        tpModeSelectBtn.Text = tpDownMode == 1 and "V1" or "V2"
    end
    if bypassModeBtnRef then
        bypassModeBtnRef.Text = bypassMode == 1 and "Bypass" or "TP Bat"
    end
    refreshSpeedModeLabel()
    if uiLocked and setLockUIVisual then setLockUIVisual(true) end
    if antiRagdollEnabled and setAntiRagVisual then setAntiRagVisual(true); startAntiRagdoll() end
    if CONFIG.AUTO_STEAL_ENABLED and setInstaGrab then setInstaGrab(true); pcall(startAutoSteal) end
    updateProgressBarVisibility()
    if jumpEnabled then
        if setJumpVisual then setJumpVisual(true) end
        startJumpMode()
    else
        if setJumpVisual then setJumpVisual(false) end
    end

    if medusaCounterEnabled then
        if setMedusaVisual then setMedusaVisual(true) end
        if LP.Character then setupMedusa(LP.Character) end
    else
        if setMedusaVisual then setMedusaVisual(false) end
        stopMedusaCounter()
    end

    if batCounterEnabled and setBatCounterVisual then
        setBatCounterVisual(true)
        startBatCounter()
    end
    if autoTPDownEnabled then if setAutoTPDownVisual then setAutoTPDownVisual(true) end; startAutoTPDown() end
    if autoBatEnabled and autoBatSetVisual then autoBatSetVisual(true); enableAutoBat() end
    if autoLeftEnabled and autoLeftSetVisual then autoLeftSetVisual(true) end
    if autoRightEnabled and autoRightSetVisual then autoRightSetVisual(true) end
    if unwalkEnabled and setUnwalkVisual then setUnwalkVisual(true); task.spawn(function() task.wait(0.5); startUnwalk() end) end
    if antiLagEnabled and setAntiLagVisual then enableAntiLag(); setAntiLagVisual(true) end

    if stretchEnabled then
        enableStretch()
    end
    if stretchRezEnabled then
        enableStretchRez()
        if setStretchRezVisual then setStretchRezVisual(true) end
    end
    if _G.keyButtonRefs then
        for _, ref in ipairs(_G.keyButtonRefs) do
            local entry = ref.entry
            local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
            ref.btn.Text = label
        end
    end

    if modeSelectBtn then
        modeSelectBtn.Text = jumpMode == 1 and "Tap Tap" or "Hold"
    end

    if setIntroVisual then setIntroVisual(_introEnabled) end

    if mobSetAutoBat then mobSetAutoBat(autoBatEnabled) end
    if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
    if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
    if mobSetCarry then mobSetCarry(speedMode) end
    if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel==1) end
    if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel==2) end

    startEnemySpeed()
end

local function createMobilePanel()
    local panel = Instance.new("ScreenGui")
    panel.Name = "KSKMobilePanel"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then
        panel.Parent = LP:WaitForChild("PlayerGui")
    end

    local BTN_W, BTN_H = 60, 60
    local GAP = 8
    local COLUMNS = 2
    local ROWS = 4
    local PANEL_W = BTN_W * COLUMNS + GAP * (COLUMNS - 1)
    local PANEL_H = BTN_H * ROWS + (GAP + 10) * (ROWS - 1)

    local container = Instance.new("Frame", panel)
    container.Name = "FloatingPanel"
    container.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    container.Position = UDim2.new(1, -PANEL_W - 10, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Active = true
    container.Selectable = true

    local btnContainer = Instance.new("Frame", container)
    btnContainer.Size = UDim2.new(1, 0, 1, 0)
    btnContainer.BackgroundTransparency = 1

    local grid = Instance.new("UIGridLayout", btnContainer)
    grid.CellSize = UDim2.new(0, BTN_W, 0, BTN_H)
    grid.CellPadding = UDim2.new(0, GAP, 0, GAP + 10)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.VerticalAlignment = Enum.VerticalAlignment.Top

    local AZUL = Color3.fromRGB(128, 0, 255)
    local INACTIVE_BG = Color3.fromRGB(10,10,10)
    local INACTIVE_TEXT = AZUL
    local STROKE_COLOR = Color3.fromRGB(70,70,70)
    local ACTIVE_BG = AZUL
    local ACTIVE_TEXT = Color3.fromRGB(255,255,255)

    local buttons = {}

    local function createButton(name, text, order, isToggle, callback)
        local btn = Instance.new("TextButton", btnContainer)
        btn.Name = name
        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        btn.BackgroundColor3 = INACTIVE_BG
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = STROKE_COLOR
        stroke.Thickness = 1.2
        stroke.Transparency = 0.4
        local label = Instance.new("TextLabel", btn)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = INACTIVE_TEXT
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.TextWrapped = true
        local active = false
        local function setActive(state, level)
            active = state
            if active then
                btn.BackgroundColor3 = ACTIVE_BG
                label.TextColor3 = ACTIVE_TEXT
                stroke.Color = Color3.fromRGB(255,255,255)
                stroke.Transparency = 0
            else
                btn.BackgroundColor3 = INACTIVE_BG
                label.TextColor3 = INACTIVE_TEXT
                stroke.Color = STROKE_COLOR
                stroke.Transparency = 0.4
            end
        end
        if callback then
            btn.MouseButton1Click:Connect(function()
                if isToggle then
                    callback(setActive, nil)
                else
                    callback(setActive, active)
                end
            end)
        end
        buttons[name] = {btn=btn, setActive=setActive, label=label}
        return setActive
    end

    mobSetDropBR = createButton("DropBR", "DROP\nBR", 0, true, function(setActive, _)
        if autoBatEnabled then return end
        setActive(true)
        executeDropWithToggle(function(v)
            if dropBrainrotSetVisual then dropBrainrotSetVisual(v) end
        end)
        task.delay(0.3, function() setActive(false) end)
    end)
    mobSetAutoLeft = createButton("AutoLeft", "AUTO\nLEFT", 1, true, function(setActive, _)
        autoLeftEnabled = not autoLeftEnabled
        setActive(autoLeftEnabled)
        if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
        if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
    end)
    mobSetAutoBat = createButton("AutoBat", "BAT\nAIMBOT", 2, true, function(setActive, _)
        if not autoBatEnabled then enableAutoBat() else disableAutoBat() end
        setActive(autoBatEnabled)
    end)
    mobSetAutoRight = createButton("AutoRight", "AUTO\nRIGHT", 3, true, function(setActive, _)
        autoRightEnabled = not autoRightEnabled
        setActive(autoRightEnabled)
        if autoRightEnabled then startAutoRight() else stopAutoRight() end
        if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
    end)
    mobSetTpDown = createButton("TpDown", "TP\nDOWN", 4, true, function(setActive, _)
        executeTPDown()
        setActive(true)
        task.delay(0.2, function() setActive(false) end)
    end)
    mobSetCarry = createButton("Carry", "CARRY\nSPD", 5, true, function(setActive, _)
        if not speedMode then
            speedMode=true; laggerToggled=false; laggerLevel=1; setActive(true)
            if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
            if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
        else
            speedMode=false; setActive(false)
        end
        refreshSpeedModeLabel()
    end)
    mobSetLagger1 = createButton("Lagger1", "LAGGER\nCARRY", 6, true, function(setActive, _)
        if speedMode then speedMode=false; if mobSetCarry then mobSetCarry(false) end end
        if not laggerToggled or laggerLevel ~= 1 then
            laggerToggled = true; laggerLevel = 1; setActive(true)
            if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
        else
            laggerToggled = false; laggerLevel = 1; setActive(false)
        end
        refreshSpeedModeLabel()
    end)
    mobSetLagger2 = createButton("Lagger2", "LAGGER\nMODE", 7, true, function(setActive, _)
        if speedMode then speedMode=false; if mobSetCarry then mobSetCarry(false) end end
        if not laggerToggled or laggerLevel ~= 2 then
            laggerToggled = true; laggerLevel = 2; setActive(true)
            if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
        else
            laggerToggled = false; laggerLevel = 1; setActive(false)
        end
        refreshSpeedModeLabel()
    end)

    if buttons.AutoBat then buttons.AutoBat.setActive(autoBatEnabled) end
    if buttons.AutoLeft then buttons.AutoLeft.setActive(autoLeftEnabled) end
    if buttons.AutoRight then buttons.AutoRight.setActive(autoRightEnabled) end
    if buttons.Carry then buttons.Carry.setActive(speedMode) end
    if buttons.Lagger1 then buttons.Lagger1.setActive(laggerToggled and laggerLevel==1) end
    if buttons.Lagger2 then buttons.Lagger2.setActive(laggerToggled and laggerLevel==2) end

    if savedMobilePanelPos then
        container.Position = UDim2.new(
            savedMobilePanelPos.XScale or 1,
            savedMobilePanelPos.XOffset or (-PANEL_W - 10),
            savedMobilePanelPos.YScale or 0,
            savedMobilePanelPos.YOffset or 0
        )
    end

    local dragging = false
    local dragStartPos = nil
    local dragStartMousePos = nil
    local function startDrag(input)
        if uiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = container.Position
            dragStartMousePos = input.Position
        end
    end
    local function onDrag(input)
        if not dragging or uiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragStartPos and dragStartMousePos then
                local delta = input.Position - dragStartMousePos
                local newX = dragStartPos.X.Offset + delta.X
                local newY = dragStartPos.Y.Offset + delta.Y
                container.Position = UDim2.new(dragStartPos.X.Scale, newX, dragStartPos.Y.Scale, newY)
            end
        end
    end
    local function endDrag()
        if dragging then
            dragging = false
            savedMobilePanelPos = {
                XScale = container.Position.X.Scale,
                XOffset = container.Position.X.Offset,
                YScale = container.Position.Y.Scale,
                YOffset = container.Position.Y.Offset
            }
            pcall(saveAllSettings)
        end
        dragStartPos = nil
        dragStartMousePos = nil
    end
    container.InputBegan:Connect(startDrag)
    container.InputEnded:Connect(endDrag)
    UIS.InputChanged:Connect(onDrag)
    for _, btnData in pairs(buttons) do
        btnData.btn.InputBegan:Connect(startDrag)
        btnData.btn.InputEnded:Connect(endDrag)
    end
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
    return panel
end

local function createBypassFloatingButton()
    local AZUL = Color3.fromRGB(128, 0, 255)
    local panel = Instance.new("ScreenGui")
    panel.Name = "BypassButton"
    panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    panel.DisplayOrder = 21
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then
        panel.Parent = LP:WaitForChild("PlayerGui")
    end

    local btnFrame = Instance.new("Frame", panel)
    btnFrame.Size = UDim2.new(0, 60, 0, 60)
    btnFrame.Name = "Frame"
    if bypassFloatingPos then
        btnFrame.Position = UDim2.new(bypassFloatingPos.XScale or 1,
                                      bypassFloatingPos.XOffset or (-10 - 60),
                                      bypassFloatingPos.YScale or 0,
                                      bypassFloatingPos.YOffset or (294 + 10))
    else
        btnFrame.Position = UDim2.new(1, -10 - 60, 0, 294 + 10)
    end
    btnFrame.BackgroundColor3 = bypassToggled and AZUL or Color3.fromRGB(0,0,0)
    btnFrame.BackgroundTransparency = 0
    btnFrame.BorderSizePixel = 0
    btnFrame.ZIndex = 20
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 18)

    local label = Instance.new("TextLabel", btnFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "BAT\nOP"
    label.TextColor3 = bypassToggled and Color3.fromRGB(255,255,255) or AZUL
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextWrapped = true
    label.ZIndex = 21

    local function setActive(state)
        if state then
            btnFrame.BackgroundColor3 = AZUL
            label.TextColor3 = Color3.fromRGB(255,255,255)
        else
            btnFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
            label.TextColor3 = AZUL
        end
    end

    local dragging = false
    local hasMoved = false
    local dragStart = nil
    local startPos = nil
    local dragThreshold = 5

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = btnFrame.Position
        end
    end

    local function onInputChanged(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold then
                hasMoved = true
            end
            if hasMoved then
                if not uiLocked then
                    btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                else
                    dragging = false
                end
            end
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                if not hasMoved then
                    setActive(not bypassToggled)
                    toggleBypass()
                elseif not uiLocked and hasMoved then
                    bypassFloatingPos = {
                        XScale = btnFrame.Position.X.Scale,
                        XOffset = btnFrame.Position.X.Offset,
                        YScale = btnFrame.Position.Y.Scale,
                        YOffset = btnFrame.Position.Y.Offset
                    }
                    pcall(saveAllSettings)
                end
                dragging = false
                hasMoved = false
                dragStart = nil
                startPos = nil
            end
        end
    end

    btnFrame.InputBegan:Connect(onInputBegan)
    btnFrame.InputChanged:Connect(onInputChanged)
    btnFrame.InputEnded:Connect(onInputEnded)

    bypassFloatingButton = panel
    return panel
end

local function setupPlayerESP()
    local function _safeDrawing(kind, props)
        if not Drawing or not Drawing.new then return nil end
        local ok, obj = pcall(function() return Drawing.new(kind) end)
        if not ok or not obj then return nil end
        for k, v in pairs(props or {}) do
            pcall(function() obj[k] = v end)
        end
        return obj
    end

    local _G_ESP_ENABLED = true
    local _G_ESP_BOX = true
    local _G_ESP_TRACER = true
    local AZUL_ESP = Color3.fromRGB(128, 0, 255)

    local PlayerESP = {
        enabled = false,
        playerData = {},
        conns = {}
    }

    local BoxedESPOptions = {
        box = _G_ESP_BOX,
        tracer = _G_ESP_TRACER
    }
    local BoxedESPData = {}
    local BoxedESPConn = nil

    local function _cleanupBoxedESPPlayer(player)
        local data = BoxedESPData[player]
        if not data then return end
        for _, obj in pairs(data) do
            pcall(function()
                if obj.Remove then obj:Remove()
                else obj.Visible = false end
            end)
        end
        BoxedESPData[player] = nil
    end

    local function _cleanupBoxedESP()
        for player, _ in pairs(BoxedESPData) do
            _cleanupBoxedESPPlayer(player)
        end
    end

    local function _updateBoxedESP()
        local cam = workspace.CurrentCamera
        if not cam then return end

        local anyOn = BoxedESPOptions.box or BoxedESPOptions.tracer
        if not anyOn then
            _cleanupBoxedESP()
            return
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LP then continue end

            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            if not root or not head then
                _cleanupBoxedESPPlayer(player)
                continue
            end

            local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
            local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.55, 0))

            local data = BoxedESPData[player]
            if not data then
                data = {
                    box = _safeDrawing("Square", {
                        Thickness = 2,
                        Filled = false,
                        Transparency = 1,
                        Color = AZUL_ESP
                    }),
                    tracer = _safeDrawing("Line", {
                        Thickness = 2,
                        Transparency = 1,
                        Color = AZUL_ESP
                    })
                }
                BoxedESPData[player] = data
            end

            local height = math.abs(headPos.Y - rootPos.Y) * 2.15
            if height < 20 or height ~= height then height = 65 end
            local width = height / 2.15

            local view = cam.ViewportSize
            local centerX, centerY = view.X / 2, view.Y / 2
            local targetX, targetY = rootPos.X, rootPos.Y + height / 2

            local targetVisible = onScreen and rootPos.Z > 0
            if not targetVisible then
                local dx = rootPos.X - centerX
                local dy = rootPos.Y - centerY
                if rootPos.Z <= 0 then
                    dx = -dx
                    dy = -dy
                end
                if math.abs(dx) < 1 and math.abs(dy) < 1 then
                    local rel = cam.CFrame:PointToObjectSpace(root.Position)
                    dx = rel.X
                    dy = -rel.Y
                    if rootPos.Z <= 0 then
                        dx = -dx
                        dy = -dy
                    end
                end
                local edgePad = 10
                local scaleX = (dx ~= 0) and ((view.X / 2 - edgePad) / math.abs(dx)) or math.huge
                local scaleY = (dy ~= 0) and ((view.Y / 2 - edgePad) / math.abs(dy)) or math.huge
                local scale = math.min(scaleX, scaleY)
                if scale == math.huge or scale ~= scale then scale = 1 end
                targetX = math.clamp(centerX + dx * scale, edgePad, view.X - edgePad)
                targetY = math.clamp(centerY + dy * scale, edgePad, view.Y - edgePad)
            end

            if data.box then
                data.box.Color = AZUL_ESP
                data.box.Size = Vector2.new(width, height)
                data.box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                data.box.Visible = BoxedESPOptions.box and targetVisible
            end

            if data.tracer then
                data.tracer.Color = AZUL_ESP
                local localChar = LP.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                local fromX, fromY
                if localRoot then
                    local localScreen = cam:WorldToViewportPoint(localRoot.Position)
                    fromX = localScreen.X
                    fromY = localScreen.Y + 15
                end
                if not fromX or not fromY then
                    fromX = cam.ViewportSize.X / 2
                    fromY = cam.ViewportSize.Y - 88
                end
                data.tracer.From = Vector2.new(fromX, fromY)
                data.tracer.To = Vector2.new(targetX, targetY)
                data.tracer.Visible = BoxedESPOptions.tracer
            end
        end
    end

    local function refreshBoxedESP()
        local anyOn = BoxedESPOptions.box or BoxedESPOptions.tracer
        if anyOn and not BoxedESPConn then
            BoxedESPConn = RunService.RenderStepped:Connect(_updateBoxedESP)
        elseif not anyOn and BoxedESPConn then
            BoxedESPConn:Disconnect()
            BoxedESPConn = nil
            _cleanupBoxedESP()
        end
    end

    local function stopPlayerESP()
        if not PlayerESP.enabled then return end
        PlayerESP.enabled = false
        for _, c in ipairs(PlayerESP.conns or {}) do
            pcall(c.Disconnect, c)
        end
        PlayerESP.conns = {}

        for player, data in pairs(PlayerESP.playerData or {}) do
            pcall(function()
                if data.highlight then data.highlight:Destroy() end
                if data.billboard then data.billboard:Destroy() end
            end)
        end
        PlayerESP.playerData = {}

        BoxedESPOptions.box = false
        BoxedESPOptions.tracer = false
        refreshBoxedESP()
        _G_ESP_ENABLED = false
    end

    local function startPlayerESP()
        if PlayerESP.enabled then return end
        PlayerESP.enabled = true
        _G_ESP_ENABLED = true
        BoxedESPOptions.box = _G_ESP_BOX
        BoxedESPOptions.tracer = _G_ESP_TRACER
        refreshBoxedESP()

        local function cleanupPlayer(player)
            local data = PlayerESP.playerData[player]
            if not data then return end
            pcall(function()
                if data.highlight then data.highlight:Destroy() end
                if data.billboard then data.billboard:Destroy() end
            end)
            if data.conns then
                for _, c in ipairs(data.conns) do pcall(c.Disconnect, c) end
            end
            PlayerESP.playerData[player] = nil
            _cleanupBoxedESPPlayer(player)
        end

        local function setupPlayer(player, character)
            if not PlayerESP.enabled or player == LP then return end
            cleanupPlayer(player)

            local hrp = character and (character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5))
            local head = character and (character:FindFirstChild("Head") or character:WaitForChild("Head", 5))
            if not hrp or not head then return end

            local highlight = Instance.new("Highlight")
            highlight.Name = "NyxHubESP"
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(35, 35, 35)
            highlight.FillTransparency = 0.72
            highlight.OutlineColor = AZUL_ESP
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NyxHubESPTag"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 2.7, 0)
            billboard.AlwaysOnTop = true
            billboard.LightInfluence = 0
            billboard.Parent = head

            local box = Instance.new("Frame", billboard)
            box.Size = UDim2.new(1, 0, 1, 0)
            box.BackgroundTransparency = 1
            box.BorderSizePixel = 0

            local speedLabel = Instance.new("TextLabel", box)
            speedLabel.Size = UDim2.new(1, -10, 1, 0)
            speedLabel.Position = UDim2.new(0, 5, 0, 0)
            speedLabel.BackgroundTransparency = 1
            speedLabel.TextColor3 = AZUL_ESP
            speedLabel.Font = Enum.Font.GothamBold
            speedLabel.TextSize = 16
            speedLabel.TextScaled = true
            speedLabel.TextStrokeTransparency = 0
            speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

            local conn = RunService.Heartbeat:Connect(function()
                if not PlayerESP.enabled or not hrp.Parent then return end
                local vel = hrp.AssemblyLinearVelocity or hrp.Velocity
                local speed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude + 0.5)
                speedLabel.Text = string.format("%d speed", speed)
            end)

            PlayerESP.playerData[player] = {
                highlight = highlight,
                billboard = billboard,
                conns = { conn }
            }
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP then
                if player.Character then
                    setupPlayer(player, player.Character)
                end
                local charConn = player.CharacterAdded:Connect(function(char)
                    task.defer(setupPlayer, player, char)
                end)
                table.insert(PlayerESP.conns, charConn)
            end
        end

        local addedConn = Players.PlayerAdded:Connect(function(player)
            if player == LP then return end
            local charConn = player.CharacterAdded:Connect(function(char)
                task.defer(setupPlayer, player, char)
            end)
            table.insert(PlayerESP.conns, charConn)
        end)
        table.insert(PlayerESP.conns, addedConn)

        local removedConn = Players.PlayerRemoving:Connect(cleanupPlayer)
        table.insert(PlayerESP.conns, removedConn)

        local boxedCleanup = Players.PlayerRemoving:Connect(_cleanupBoxedESPPlayer)
        table.insert(PlayerESP.conns, boxedCleanup)
    end

    startPlayerESP()
    _G.ESP_ENABLED = true
    _G.ESP_BOX = true
    _G.ESP_TRACER = true
    _G.startPlayerESP = startPlayerESP
    _G.stopPlayerESP = stopPlayerESP
end

-- ============================================================
-- NUEVA INTRO ANIMADA (desde dice source.txt, personalizada para KSK OP)
-- ============================================================
local function runDiceIntro()
    if not _introEnabled then return end

    -- Sonido de la intro
    local sound = nil
    local urlIntro = "https://files.catbox.moe/66xaq4.mp3"
    local numeFisier = "dicenew_introo.mp3"
    if isfile and not isfile(numeFisier) then
        pcall(function()
            local data = game:HttpGet(urlIntro)
            if data then writefile(numeFisier, data) end
        end)
    end
    if isfile and isfile(numeFisier) then
        sound = Instance.new("Sound")
        sound.SoundId = getcustomasset(numeFisier)
        sound.Volume = 3
        sound.Looped = false
        sound.Parent = game:GetService("CoreGui")
        sound:Play()
    end

    -- Crear el ScreenGui de la intro
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "KSKIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 9999
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(introGui) end end)
    if not pcall(function() introGui.Parent = game:GetService("CoreGui") end) then
        introGui.Parent = LP:WaitForChild("PlayerGui")
    end

    local stage = Instance.new("Frame", introGui)
    stage.Size = UDim2.fromScale(1, 1)
    stage.BackgroundTransparency = 1
    stage.ClipsDescendants = true

    -- La animación se ejecuta en un hilo separado para no bloquear el flujo principal
    task.spawn(function()
        local introStarted = tick()
        task.wait(0.35)

        -- Colores de la intro personalizados para KSK OP (dados negros con puntos morados)
        local ACC = {
            accent = Color3.fromRGB(128, 0, 255),      -- Morado KSK
            accentDark = Color3.fromRGB(80, 0, 200),   -- Morado oscuro
            accentBg = Color3.fromRGB(22, 22, 25),
            accentHover = Color3.fromRGB(75, 75, 80),
            accentRowHover = Color3.fromRGB(18, 18, 20)
        }

        local function waitForIntroSecond(second)
            local remaining = second - (tick() - introStarted)
            if remaining > 0 then task.wait(remaining) end
        end

        local function _gAccentGrad(t)
            local a = ACC.accent
            local d = ACC.accentDark
            local pulse = math.sin(t * 0.7) * 0.14
            local aR = math.clamp(math.floor(a.R * 255 * (1 + pulse)), 0, 255)
            local aG = math.clamp(math.floor(a.G * 255 * (1 + pulse)), 0, 255)
            local aB = math.clamp(math.floor(a.B * 255 * (1 + pulse)), 0, 255)
            local dR = math.clamp(math.floor(d.R * 255 * (0.75 + pulse * 0.25)), 0, 255)
            local dG = math.clamp(math.floor(d.G * 255 * (0.75 + pulse * 0.25)), 0, 255)
            local dB = math.clamp(math.floor(d.B * 255 * (0.75 + pulse * 0.25)), 0, 255)
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(dR, dG, dB)),
                ColorSequenceKeypoint.new(0.3, Color3.fromRGB(aR, aG, aB)),
                ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.82,Color3.fromRGB(aR, aG, aB)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(dR, dG, dB))
            })
        end

        local layouts = {
            [1] = {{0.5, 0.5}},
            [2] = {{0.28, 0.28}, {0.72, 0.72}},
            [3] = {{0.27, 0.27}, {0.5, 0.5}, {0.73, 0.73}},
            [4] = {{0.28, 0.28}, {0.72, 0.28}, {0.28, 0.72}, {0.72, 0.72}},
            [5] = {{0.27, 0.27}, {0.73, 0.27}, {0.5, 0.5}, {0.27, 0.73}, {0.73, 0.73}},
            [6] = {{0.28, 0.23}, {0.72, 0.23}, {0.28, 0.5}, {0.72, 0.5}, {0.28, 0.77}, {0.72, 0.77}},
        }

        local function makeIntroDie(size, pos, value)
            local group = Instance.new("CanvasGroup", stage)
            group.AnchorPoint = Vector2.new(0.5, 0.5)
            group.Position = pos
            group.Size = UDim2.fromOffset(size + 14, size + 16)
            group.BackgroundTransparency = 1
            group.ZIndex = 20
            group.ClipsDescendants = true

            local shadow = Instance.new("Frame", group)
            shadow.Size = UDim2.fromOffset(size, size)
            shadow.Position = UDim2.fromOffset(10, 11)
            shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            shadow.BackgroundTransparency = 0.48
            shadow.BorderSizePixel = 0
            Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, math.floor(size * 0.2))

            local depth = Instance.new("Frame", group)
            depth.Size = UDim2.fromOffset(size, size)
            depth.Position = UDim2.fromOffset(8, 8)
            depth.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            depth.BorderSizePixel = 0
            Instance.new("UICorner", depth).CornerRadius = UDim.new(0, math.floor(size * 0.2))

            -- Fondo del dado: NEGRO
            local face = Instance.new("Frame", group)
            face.Size = UDim2.fromOffset(size, size)
            face.Position = UDim2.fromOffset(7, 5)
            face.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Negro
            face.BorderSizePixel = 0
            face.ZIndex = 22
            Instance.new("UICorner", face).CornerRadius = UDim.new(0, math.floor(size * 0.2))

            local stroke = Instance.new("UIStroke", face)
            stroke.Color = ACC.accentDark
            stroke.Thickness = 2

            local grad = Instance.new("UIGradient", face)
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 20, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 60))
            })
            grad.Rotation = 35

            local rim = Instance.new("Frame", face)
            rim.Size = UDim2.new(1, -10, 1, -10)
            rim.Position = UDim2.fromOffset(5, 5)
            rim.BackgroundTransparency = 1
            rim.ZIndex = 23
            Instance.new("UICorner", rim).CornerRadius = UDim.new(0, math.floor(size * 0.15))
            local rimStroke = Instance.new("UIStroke", rim)
            rimStroke.Color = Color3.fromRGB(80, 80, 100)
            rimStroke.Transparency = 0.58
            rimStroke.Thickness = 1

            -- Puntos (pip) en color morado
            for _, point in ipairs(layouts[value]) do
                local pip = Instance.new("Frame", face)
                pip.AnchorPoint = Vector2.new(0.5, 0.5)
                pip.Position = UDim2.fromScale(point[1], point[2])
                pip.Size = UDim2.fromOffset(math.max(7, math.floor(size * 0.13)), math.max(7, math.floor(size * 0.13)))
                pip.BackgroundColor3 = Color3.fromRGB(128, 0, 255)  -- Morado
                pip.BorderSizePixel = 0
                pip.ZIndex = 24
                Instance.new("UICorner", pip).CornerRadius = UDim.new(1, 0)
                local pipStroke = Instance.new("UIStroke", pip)
                pipStroke.Color = Color3.fromRGB(255, 255, 255)
                pipStroke.Transparency = 0.8
                pipStroke.Thickness = 1
            end

            local scale = Instance.new("UIScale", group)
            return group, scale, grad
        end

        local dice = {}
        local routes = {
            {44, UDim2.new(-0.1, 0, 0.24, 0), UDim2.new(0.27, 0, 0.33, 0), 1, 900, 0.00},
            {54, UDim2.new(-0.12, 0, 0.65, 0), UDim2.new(0.31, 0, 0.62, 0), 4, 1080, 0.08},
            {38, UDim2.new(0.22, 0, -0.12, 0), UDim2.new(0.40, 0, 0.27, 0), 2, -900, 0.16},
            {46, UDim2.new(0.38, 0, 1.12, 0), UDim2.new(0.42, 0, 0.72, 0), 5, 1080, 0.12},
            {44, UDim2.new(1.1, 0, 0.25, 0), UDim2.new(0.73, 0, 0.34, 0), 3, -900, 0.00},
            {54, UDim2.new(1.12, 0, 0.68, 0), UDim2.new(0.69, 0, 0.63, 0), 6, -1080, 0.08},
            {38, UDim2.new(0.78, 0, -0.12, 0), UDim2.new(0.60, 0, 0.27, 0), 4, 900, 0.16},
            {46, UDim2.new(0.64, 0, 1.12, 0), UDim2.new(0.58, 0, 0.72, 0), 2, -1080, 0.12},
        }

        for _, route in ipairs(routes) do
            local die, scale, grad = makeIntroDie(route[1], route[2], route[4])
            scale.Scale = 0.35
            die.GroupTransparency = 0.18
            table.insert(dice, {die, scale, grad, route[3], route[5], route[2]})
            task.delay(route[6], function()
                TS:Create(die, TweenInfo.new(0.78, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = route[3],
                    Rotation = route[5],
                    GroupTransparency = 0
                }):Play()
                TS:Create(scale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
                TS:Create(grad, TweenInfo.new(0.78), {Rotation = route[5] > 0 and 395 or -325, Offset = Vector2.new(route[5] > 0 and 0.28 or -0.28, 0)}):Play()
            end)
        end

        task.wait(0.88)
        for i, item in ipairs(dice) do
            local drift = i % 2 == 0 and 32 or -32
            TS:Create(item[1], TweenInfo.new(0.48, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = item[1].Rotation + drift}):Play()
        end

        waitForIntroSecond(4.4)
        for _, item in ipairs(dice) do
            local direction = item[5] > 0 and 1 or -1
            local retreat = item[4]:Lerp(item[6], 0.42)
            TS:Create(item[1], TweenInfo.new(0.46, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
                Position = retreat,
                Rotation = item[1].Rotation + direction * 360
            }):Play()
            TS:Create(item[2], TweenInfo.new(0.46, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = 0.82}):Play()
            TS:Create(item[3], TweenInfo.new(0.46), {Offset = Vector2.new(-direction * 0.2, 0), Rotation = direction * 210}):Play()
        end

        waitForIntroSecond(5.0)
        for _, item in ipairs(dice) do
            local direction = item[5] > 0 and 1 or -1
            TS:Create(item[1], TweenInfo.new(0.58, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = item[4],
                Rotation = item[1].Rotation + direction * 720
            }):Play()
            TS:Create(item[2], TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
            TS:Create(item[3], TweenInfo.new(0.58), {Offset = Vector2.new(direction * 0.3, 0), Rotation = direction * 395}):Play()
        end

        local center, centerScale, centerGrad = makeIntroDie(98, UDim2.new(0.5, 0, 1.18, 0), 6)
        centerScale.Scale = 0.56
        center.GroupTransparency = 0.08
        center.ZIndex = 40
        TS:Create(center, TweenInfo.new(0.82, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = 1440,
            GroupTransparency = 0
        }):Play()
        TS:Create(centerScale, TweenInfo.new(0.66, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        TS:Create(centerGrad, TweenInfo.new(0.82), {Rotation = 430, Offset = Vector2.new(0.42, 0)}):Play()

        task.wait(0.76)
        local impact = Instance.new("Frame", stage)
        impact.AnchorPoint = Vector2.new(0.5, 0.5)
        impact.Position = UDim2.fromScale(0.5, 0.5)
        impact.Size = UDim2.fromOffset(80, 80)
        impact.BackgroundTransparency = 1
        impact.ZIndex = 15
        Instance.new("UICorner", impact).CornerRadius = UDim.new(1, 0)
        local impactStroke = Instance.new("UIStroke", impact)
        impactStroke.Color = ACC.accent
        impactStroke.Thickness = 3
        impactStroke.Transparency = 0.05
        TS:Create(impact, TweenInfo.new(0.52, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(310, 310)}):Play()
        TS:Create(impactStroke, TweenInfo.new(0.52), {Transparency = 1, Thickness = 1}):Play()

        for i = 1, 12 do
            local spark = Instance.new("Frame", stage)
            spark.AnchorPoint = Vector2.new(0.5, 0.5)
            spark.Position = UDim2.fromScale(0.5, 0.5)
            spark.Size = UDim2.fromOffset(i % 3 == 0 and 6 or 3, i % 3 == 0 and 18 or 12)
            spark.BackgroundColor3 = i % 2 == 0 and ACC.accent or Color3.fromRGB(245, 247, 255)
            spark.BorderSizePixel = 0
            spark.ZIndex = 16
            spark.Rotation = i * 30
            Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)
            local angle = math.rad(i * 30)
            local radius = 115 + (i % 3) * 18
            TS:Create(spark, TweenInfo.new(0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius),
                BackgroundTransparency = 1,
                Rotation = i * 30 + 90
            }):Play()
        end

        TS:Create(centerScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.88}):Play()
        task.wait(0.12)
        TS:Create(centerScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

        task.wait(0.55)
        for _, item in ipairs(dice) do
            TS:Create(item[1], TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Position = UDim2.fromScale(0.5, 0.5),
                Rotation = item[1].Rotation + 180,
                GroupTransparency = 1
            }):Play()
            TS:Create(item[2], TweenInfo.new(0.38), {Scale = 0.3}):Play()
        end
        TS:Create(center, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0.45, 0),
            Rotation = 1530,
            GroupTransparency = 1
        }):Play()
        TS:Create(centerScale, TweenInfo.new(0.34), {Scale = 0.55}):Play()

        task.wait(0.25)
        -- Título personalizado: KSK OP completamente en morado
        local title = Instance.new("TextLabel", stage)
        title.AnchorPoint = Vector2.new(0.5, 0.5)
        title.Position = UDim2.new(0.5, 0, 0.62, 0)
        title.Size = UDim2.new(0, 360, 0, 80)
        title.BackgroundTransparency = 1
        title.RichText = true
        title.Text = '<font color="rgb(128,0,255)">KSK OP</font>'
        title.TextColor3 = Color3.fromRGB(128, 0, 255)
        title.TextSize = 46
        title.Font = Enum.Font.GothamBlack
        title.TextTransparency = 1
        title.TextStrokeColor3 = Color3.fromRGB(10, 10, 16)
        title.TextStrokeTransparency = 1
        title.ZIndex = 30
        TS:Create(title, TweenInfo.new(0.52, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            TextTransparency = 0,
            TextStrokeTransparency = 0.3
        }):Play()

        local underline = Instance.new("Frame", stage)
        underline.AnchorPoint = Vector2.new(0.5, 0.5)
        underline.Position = UDim2.new(0.5, 0, 0.555, 0)
        underline.Size = UDim2.fromOffset(0, 2)
        underline.BackgroundColor3 = ACC.accent
        underline.BorderSizePixel = 0
        underline.ZIndex = 30
        Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)
        TS:Create(underline, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(148, 2)}):Play()

        task.wait(1.25)
        TS:Create(title, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0.42, 0),
            TextTransparency = 1,
            TextStrokeTransparency = 1
        }):Play()
        TS:Create(underline, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 2),
            BackgroundTransparency = 1
        }):Play()

        task.wait(0.4)
        pcall(function() introGui:Destroy() end)
        if sound then
            pcall(function() sound:Stop() end)
            pcall(function() sound:Destroy() end)
        end
    end)

    -- Esperar a que la intro se destruya para continuar
    while introGui and introGui.Parent do
        task.wait(0.1)
    end
end
-- ============================================================

-- ============================================================
-- INICIALIZACIÓN
-- ============================================================
local function initializeGUI()
    buildGui()
    if loadAllSettings() then
        updateUIFromLoaded()
    end

    MobilePanel = createMobilePanel()
    bypassFloatingButton = createBypassFloatingButton()

    task.spawn(setupPlayerESP)

    if LP.Character then
        task.wait(0.0)
        setupSpeedIndicator(LP.Character)
    end

    LP.CharacterAdded:Connect(function(char)
        stopAutoSteal()
        stopAutoLeft()
        stopAutoRight()
        stopBatCounter()
        stopMedusaCounter()
        stopAutoTPDown()
        stopAntiRagdoll()
        stopUnwalk()
        stopDropBrainrot()
        if autoBatEnabled then disableAutoBat() end
        if bypassToggled then stopBypassAimbot() end

        task.wait(0.1)
        while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do
            task.wait()
        end

        if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
        if movementLoop then movementLoop:Disconnect(); movementLoop = nil end

        steppedConn = RunService.Stepped:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    for _, part in ipairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)

        -- Re-crear movementLoop con la nueva lógica
        movementLoop = RunService.RenderStepped:Connect(function()
            local char2 = LP.Character
            if not char2 then return end
            local hum = char2:FindFirstChildOfClass("Humanoid")
            local hrp = char2:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end

            if not autoBatEnabled and not bypassToggled and not autoLeftEnabled and not autoRightEnabled then
                local spd
                if laggerToggled then
                    spd = (laggerLevel == 2) and LAGGER_SPEED_2 or LAGGER_SPEED_1
                else
                    spd = speedMode and CS or NS
                end

                if speedEnabled and currentSpeedValue ~= spd then
                    cleanupSpeedPhysics()
                end
                if not speedEnabled and spd > 0 then
                    applySpeedWithLinearVelocity(spd)
                end
            else
                if speedEnabled then
                    cleanupSpeedPhysics()
                end
            end

            if speedLabel then
                local v = hrp.Velocity
                local flatSpeed = math.sqrt(v.X * v.X + v.Z * v.Z)
                speedLabel.Text = string.format("%.1f", flatSpeed)
            end
        end)

        setupSpeedIndicator(char)

        if autoBatEnabled then enableAutoBat() end
        if autoLeftEnabled then startAutoLeft() end
        if autoRightEnabled then startAutoRight() end
        if bypassToggled then toggleBypass(true) end
        if CONFIG.AUTO_STEAL_ENABLED then pcall(startAutoSteal) end
        if jumpEnabled then startJumpMode() end
        if antiRagdollEnabled then startAntiRagdoll() end

        if medusaCounterEnabled then
            setupMedusa(char)
            if setMedusaVisual then setMedusaVisual(true) end
        else
            stopMedusaCounter()
            if setMedusaVisual then setMedusaVisual(false) end
        end

        if batCounterEnabled then startBatCounter() end
        if unwalkEnabled then startUnwalk() end
        if autoTPDownEnabled then startAutoTPDown() end

        refreshSpeedModeLabel()
    end)

    local lastLaggerToggle = 0
    local LAGGER_COOLDOWN = 0.3

    UIS.InputBegan:Connect(function(input, gpe)
        if _anyKeyListening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if gpe or UIS:GetFocusedTextBox() then return end
        elseif not isGamepadInput(input) then
            return
        end
        if not isBindableInput(input) then return end

        local kc = input.KeyCode
        if not kc then return end

        if kbMatch(KB.LaggerMode, kc) then
            if tick() - lastLaggerToggle >= LAGGER_COOLDOWN then
                lastLaggerToggle = tick()
                toggleLaggerCycle()
            end
            return
        end
        if kbMatch(KB.CarryToggle, kc) then
            if tick() - _lastCarryToggle >= CARRY_TOGGLE_COOLDOWN then
                _lastCarryToggle = tick()
                toggleCarryMode()
            end
            return
        end
        if kbMatch(KB.DropBrainrot, kc) then
            if not dropActive then
                if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
                executeDropWithToggle(dropBrainrotSetVisual)
            end
            return
        end
        if kbMatch(KB.TPFloor, kc) then executeTPDown() return end
        if kbMatch(KB.AutoLeft, kc) then
            autoLeftEnabled = not autoLeftEnabled
            if autoLeftEnabled then
                startAutoLeft()
            else
                stopAutoLeft()
            end
            if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
            if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
            return
        end
        if kbMatch(KB.AutoRight, kc) then
            autoRightEnabled = not autoRightEnabled
            if autoRightEnabled then
                startAutoRight()
            else
                stopAutoRight()
            end
            if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
            if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
            return
        end
        if kbMatch(KB.AutoBat, kc) then
            if not autoBatEnabled then
                enableAutoBat()
                if autoBatSetVisual then autoBatSetVisual(true) end
                if mobSetAutoBat then mobSetAutoBat(true) end
            else
                disableAutoBat()
                if autoBatSetVisual then autoBatSetVisual(false) end
                if mobSetAutoBat then mobSetAutoBat(false) end
            end
            return
        end
        if kbMatch(KB.Bypass, kc) then
            toggleBypass()
            return
        end
        if kbMatch(KB.AutoTPDown, kc) then
            autoTPDownEnabled = not autoTPDownEnabled
            if autoTPDownEnabled then
                startAutoTPDown()
            else
                stopAutoTPDown()
            end
            if setAutoTPDownVisual then setAutoTPDownVisual(autoTPDownEnabled) end
            return
        end
        if kbMatch(KB.JumpMode, kc) then
            if modeSelectBtn then
                local newMode = jumpMode == 1 and 2 or 1
                jumpMode = newMode
                modeSelectBtn.Text = jumpMode == 1 and "Tap Tap" or "Hold"
                if jumpEnabled then
                    stopJumpMode()
                    startJumpMode()
                end
            end
            return
        end
        if kbMatch(KB.GuiHide, kc) then
            if main then
                if main.Visible then hideGui() else showGui() end
            end
            return
        end
    end)

    task.spawn(function()
        while true do
            task.wait(5)
            pcall(saveAllSettings)
        end
    end)
end

-- ============================================================
-- CARGA DE CONFIGURACIÓN Y EJECUCIÓN DE INTRO
-- ============================================================

-- Se carga la configuración (incluye _introEnabled)
loadAllSettings()

-- Si está activada la intro, se reproduce la nueva intro de dados personalizada
if _introEnabled then
    runDiceIntro()
end

-- Finalmente se inicializa la GUI principal de KSK OP
initializeGUI()