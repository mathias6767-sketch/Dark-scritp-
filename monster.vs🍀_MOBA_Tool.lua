--[[
 monster.vs🍀
 Tab 1 Player: Speed 3-mode first + player controls
 + Tool Aimbot + Drop Jump/Stand + Chilli Fast Reset / Insta Reset V2 + TP Down / TP Best keybinds
 Tab 2 ESP: Player ESP + Tracker + Anti Lag + Nuke Optimize + Trap/Subspace ESP
 Tab 3 Settings: mobile action buttons, shape, reset
 Close/minimize: nút − | Reopen: mini hoặc RightShift | Ace-style lock + UI layout
]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local RunService = RS
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Remove old global FPS slider listeners on re-execution.
if type(_G.__12HubFPSControlConnections) == "table" then
    for _, connection in ipairs(_G.__12HubFPSControlConnections) do
        pcall(function() connection:Disconnect() end)
    end
end
_G.__12HubFPSControlConnections = {}

-- Tear down our previous Chilli-compatible runtime if this script is re-executed.
if type(_G.__12HubChilliRuntimeCleanup) == "function" then
    pcall(_G.__12HubChilliRuntimeCleanup)
end

local LP = Players.LocalPlayer
if not LP then
	repeat task.wait() until Players.LocalPlayer
	LP = Players.LocalPlayer
end
local PlayerGui = LP:WaitForChild("PlayerGui", 30) or LP:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

pcall(function()
	for _, n in ipairs({
 "12Hub_AceMainGui", "Rana.VSHubFullMenu", "Rana.VSHubFullMini", "Rana.VS_LaPeakMenu", "Rana.VSHybridMenu", "Rana.VSHybridGui", "Rana.VSIntro", "Rana.VSHubIntro", "RanaVSStealSpeedButtonGui",
	}) do
 local g = PlayerGui:FindFirstChild(n)
 if g then g:Destroy() end
	end
	local CoreGui = game:GetService("CoreGui")
	for _, n in ipairs({"12Hub_AllGearOnTop", "ZenoneTop_AnimeUI"}) do
		local g = CoreGui:FindFirstChild(n)
		if g then g:Destroy() end
	end
end)
-- Disconnect only our previous Steal Speed UI/WalkSpeed monitor connections on re-execution.
for _, stateKey in ipairs({"_12HubStealSpeedButtonConnections", "_12HubAutoStealWalkSpeedConnections"}) do
    local oldConnections = _G[stateKey]
    if type(oldConnections) == "table" then
        for _, connection in ipairs(oldConnections) do
            pcall(function() connection:Disconnect() end)
        end
    end
    _G[stateKey] = {}
end

----------------------------------------------------------------
-- COLORS / STATE
----------------------------------------------------------------
local C = {
	-- ACE Theme 2: black/charcoal, white text, muted grey and subtle slate-blue.
	bg = Color3.fromRGB(9, 11, 14), bg2 = Color3.fromRGB(16, 19, 23),
	card = Color3.fromRGB(13, 16, 20), stroke = Color3.fromRGB(48, 55, 65),
	accent = Color3.fromRGB(104, 116, 132), text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(138, 142, 148), on = Color3.fromRGB(156, 169, 186),
	off = Color3.fromRGB(18, 21, 26), box = Color3.fromRGB(15, 18, 22),
	danger = Color3.fromRGB(190, 70, 78),
	modeOnBg = Color3.fromRGB(25, 43, 58), modeOnTxt = Color3.fromRGB(255, 255, 255),
	modeOffBg = Color3.fromRGB(18, 21, 26), modeOffTxt = Color3.fromRGB(138, 142, 148),
	btnOn = Color3.fromRGB(210, 218, 228),
	btnOff = Color3.fromRGB(18, 21, 26),
}


local St = {
	antiGummy = true, antiBee = false, antiRagdoll = false, antiPaint = true, antiBoogie = true,
	antiTrap = false, antiTrapGear = "Cupid's Wings",
	-- Trap ESP / Anti-Trap extensions
	trapESP = false, trapDistanceESP = true, trapOutlineESP = true, subspaceESP = true,
	antiTrapZeroM = false, trapScanRange = 250,
	toolAim = true, speedOn = true, infJump = true,
	activeMode = "Normal",
    -- Steal speed is an explicit state: hotkey may enter it, the UI button returns to Normal.
    autoChangeOnSteal = true, -- Default ON; automatically use steal speed while Humanoid.WalkSpeed < 25.
    stealSpeedKey = "None",
    stealSpeedActive = false,
    stealSpeedButtonSize = 70,
    stealSpeedButtonPos = nil,
	modes = {
 Normal = { norm = 60, steal = 30 },
 Lagger = { norm = 40, steal = 24 },
 Custom = { norm = 47, steal = 22 },
	},
	dropMode = 2, -- 1 Stand/Fling, 2 Jump
	instaMode = "Fast Reset",
		mobileBtns = true, guiLock = false, -- default ON: Drop / Insta / TP buttons
	showStealBtn = true, -- mobile action visibility
	medOn = false, psOn = false,
	btnShape = "FOUNDED", -- FOUNDED | CIRCLE | SQUARE
	btnScale = 0.75,
	menuScale = 0.7,
	menuGuiLocked = false, uiLayout = "RIGHT",
	btnSizes = { drop = 70, insta = 70, tp = 70, tpBest = 70, sentry = 70, steal = 70, med = 70, ps = 70, antiTrap = 70, websinger = 70 },
	keys = {
 Drop = Enum.KeyCode.X,
 TPDown = Enum.KeyCode.F,
 InstaReset = Enum.KeyCode.Z,
 DestroySentry = Enum.KeyCode.H,
 AutoSteal = nil,
 TpBest = Enum.KeyCode.B,
 MedEquip = Enum.KeyCode.M,
 AntiTrap = Enum.KeyCode.N,
		Websinger = Enum.KeyCode.G,
	},
	speedKeys = { Normal = Enum.KeyCode.T, Lagger = Enum.KeyCode.E, Custom = Enum.KeyCode.F },
	esp = false, tracer = false, antiLag = false, nukeOptimiserEnabled = false,
	antiKick = true, wallOpacity = 0.12, speedMethod = "Velocity",
	destroySentry = false,
	spamLaser = false, spamPaint = false,
	counterLaser = false, counterBoogie = false, counterSwapBody = false,
	equipOnDrop = false,
}
local ToggleRefs = {} -- để Reset All cập nhật UI

-- Legacy menu handles kept only as nil compatibility references.
local Main = nil
local Mini = nil
local MiniGui = nil
local applyMenuScale = function() end
local setTab = function() end
local pageSpeed, pagePlayer, pageVis, pageSpam, pageCounter, pageSet, pageKeys = nil,nil,nil,nil,nil,nil,nil

local CFG = "12HubOntop.json"
local _saveToken = 0
function autoSaveDebounced()
	_saveToken = _saveToken + 1
	local t = _saveToken
	task.delay(0.35, function()
 if t == _saveToken then pcall(saveCfg) end
	end)
end
function _serializeValue(v, depth)
	depth = depth or 0
	if depth > 6 then return nil end
	local t = typeof(v)
	if t == "number" or t == "string" or t == "boolean" then
 return v
	elseif t == "EnumItem" then
 return v.Name
	elseif t == "table" then
 local out = {}
 for k2, v2 in pairs(v) do
 local kt = type(k2)
 if kt == "string" or kt == "number" then
 local sv = _serializeValue(v2, depth + 1)
 if sv ~= nil then out[k2] = sv end
 end
 end
 return out
	end
	return nil
end
function saveCfg()
	local d = {}
	-- dump TOÀN BỘ St (mọi key có thể JSON được)
	for k, v in pairs(St) do
 if type(k) == "string" then
 -- không lưu base/pet TP — chỉ nhớ vị trí panel
 if k == "_saveBase" or k == "_savePet" or k == "saveBase" or k == "savePet"
 or k == "_delayBase" or k == "_delayPet" then
 -- skip
 elseif k == "modes" or k == "keys" or k == "speedKeys" then
 -- skip, handle below
 else
 local sv = _serializeValue(v)
 if sv ~= nil then d[k] = sv end
 end
 end
	end
	d.modes = {}
	for k, m in pairs(St.modes or {}) do
 if type(m) == "table" then
 d.modes[k] = {
 norm = tonumber(m.norm) or 16,
 steal = tonumber(m.steal) or 16,
 }
 end
	end
	d.keys = {}
	for k, v in pairs(St.keys or {}) do
 d.keys[k] = (typeof(v) == "EnumItem" and v.Name) or tostring(v)
	end
	d.speedKeys = {}
	for k, v in pairs(St.speedKeys or {}) do
		d.speedKeys[k] = (typeof(v) == "EnumItem" and v.Name) or tostring(v)
	end
	local ok, err = pcall(function()
 if not writefile then error("no writefile") end
 d._saveBase = nil
	d._savePet = nil
	d.saveBase = nil
	d.savePet = nil
	d._delayBase = nil
	d._delayPet = nil
	writefile(CFG, HttpService:JSONEncode(d))
	end)
	if not ok then
 warn("[12Hub] saveCfg fail:", err)
	end
	return ok
end
function loadCfg()
	local ok, data = pcall(function()
 if isfile and readfile then
 if isfile(CFG) then
 return HttpService:JSONDecode(readfile(CFG))
 end
 for _, old in ipairs({"Rana.VSAllgear.json", "RaraOnflop.json", "Rana.VSHub_FullMenu_v1.json", "Rana.VSHub_Config.json", "Rana.VS.json"}) do
 if isfile(old) then
 local d = HttpService:JSONDecode(readfile(old))
 pcall(function() writefile(CFG, HttpService:JSONEncode(d)) end)
 return d
 end
 end
 end
	end)
	if not (ok and type(data) == "table") then return false end
	for k, v in pairs(data) do
 if type(k) == "string" and k ~= "modes" and k ~= "keys" then
 St[k] = v
 end
	end
	if type(data.modes) == "table" then
 for k, m in pairs(data.modes) do
 if type(m) == "table" then
 St.modes[k] = St.modes[k] or { norm = 59, steal = 30 }
 St.modes[k].norm = tonumber(m.norm) or St.modes[k].norm
 St.modes[k].steal = tonumber(m.steal) or St.modes[k].steal
 end
 end
	end
	if type(data.keys) == "table" then
 St.keys = St.keys or {}
 for k, name in pairs(data.keys) do
  local keyName = tostring(name)
  if keyName == "None" then
   St.keys[k] = "None"
  else
   pcall(function()
    local keyCode = Enum.KeyCode[keyName]
    if keyCode then St.keys[k] = keyCode end
   end)
  end
 end
	end
	if type(data.speedKeys) == "table" then
		St.speedKeys = St.speedKeys or {}
		for k, name in pairs(data.speedKeys) do
   local keyName = tostring(name)
   if keyName == "None" then
    St.speedKeys[k] = "None"
   else
    pcall(function()
     local keyCode = Enum.KeyCode[keyName]
     if keyCode then St.speedKeys[k] = keyCode end
    end)
   end
		end
	end
	if type(data.btnSizes) == "table" then
 St.btnSizes = data.btnSizes
 for k,v in pairs(St.btnSizes) do
 St.btnSizes[k] = math.clamp(tonumber(v) or 70, 20, 200)
 end
 -- Migrate the previous built-in mobile-button default (50) to the new default 70.
 for _, k in ipairs({"drop","insta","tp","tpBest","sentry","steal","med","ps","antiTrap","websinger"}) do
  if tonumber(St.btnSizes[k]) == 50 then St.btnSizes[k] = 70 end
 end
	end
 St.btnSizes = St.btnSizes or {}
 for _, k in ipairs({"drop","insta","tp","tpBest","sentry","steal","med","ps","antiTrap","websinger"}) do
  St.btnSizes[k] = math.clamp(tonumber(St.btnSizes[k]) or 70, 20, 200)
 end
	if type(data._btnPos) == "table" then St._btnPos = data._btnPos end
	St.stealRadius = tonumber(St.stealRadius) or 60
	if St.stealVer == "V1" or St.stealVer == "V2" then St.stealVer = "Normal-" .. St.stealVer end
	if St.stealVer ~= "Normal-V1" and St.stealVer ~= "Normal-V2" and St.stealVer ~= "Semi-V1" and St.stealVer ~= "Semi-V2" then St.stealVer = "Normal-V2" end
	if St.btnShape == "Round" then St.btnShape = "CIRCLE" elseif St.btnShape == "Box" then St.btnShape = "FOUNDED" elseif St.btnShape == "Square" then St.btnShape = "SQUARE" end
	if St.btnShape ~= "FOUNDED" and St.btnShape ~= "CIRCLE" and St.btnShape ~= "SQUARE" then St.btnShape = "FOUNDED" end
	local savedMode, savedVersion = tostring(St.stealVer):match("^(Normal|Semi)%-(V[12])$")
	selectedStealMode = savedMode or "Normal"
	autoStealV2Version = savedVersion or "V2"
	if type(St.modes) == "table" then
		if St.modes.Normal and tonumber(St.modes.Normal.norm) == 59 then St.modes.Normal.norm = 60 end
		if St.modes.Lagger and tonumber(St.modes.Lagger.norm) == 18 then St.modes.Lagger.norm = 40 end
		if St.modes.Custom and tonumber(St.modes.Custom.norm) == 33 then St.modes.Custom.norm = 47 end
		if St.modes.Custom and tonumber(St.modes.Custom.steal) == 33 then St.modes.Custom.steal = 22 end
	end
	St.stealBarScale = tonumber(St.stealBarScale) or 1
	if St.showStealBtn == nil then St.showStealBtn = true end
	autoStealRadius = St.stealRadius
	return true
end
local _menuScaleConfigLoaded = loadCfg()

-- Dedicated speed persistence for the last selected mode and each configured speed.
local SPEED_CFG = "monster.vs_speed.json"
local function loadSpeedSettings()
    local ok, data = pcall(function()
        if isfile and readfile and isfile(SPEED_CFG) then
            return HttpService:JSONDecode(readfile(SPEED_CFG))
        end
        return nil
    end)
    if not ok or type(data) ~= "table" then return end
    if type(data.modes) == "table" then
        for _, modeName in ipairs({"Normal", "Lagger", "Custom"}) do
            local saved = data.modes[modeName]
            if type(saved) == "table" then
                St.modes[modeName] = St.modes[modeName] or {norm=60, steal=30}
                local norm, steal = tonumber(saved.norm), tonumber(saved.steal)
                if norm then St.modes[modeName].norm = math.clamp(norm, 1, 200) end
                if steal then St.modes[modeName].steal = math.clamp(steal, 1, 200) end
            end
        end
    end
    if data.activeMode == "Normal" or data.activeMode == "Lagger" or data.activeMode == "Custom" then
        St.activeMode = data.activeMode
    end
    if type(data.speedOn) == "boolean" then St.speedOn = data.speedOn end
end
local function saveSpeedSettings()
    pcall(saveCfg)
    pcall(function()
        if not writefile then error("writefile unavailable") end
        local payload = {
            activeMode = St.activeMode,
            speedOn = St.speedOn == true,
            modes = {
                Normal = {norm=tonumber(St.modes.Normal and St.modes.Normal.norm) or 60, steal=tonumber(St.modes.Normal and St.modes.Normal.steal) or 30},
                Lagger = {norm=tonumber(St.modes.Lagger and St.modes.Lagger.norm) or 40, steal=tonumber(St.modes.Lagger and St.modes.Lagger.steal) or 24},
                Custom = {norm=tonumber(St.modes.Custom and St.modes.Custom.norm) or 47, steal=tonumber(St.modes.Custom and St.modes.Custom.steal) or 22}
            }
        }
        writefile(SPEED_CFG, HttpService:JSONEncode(payload))
    end)
end
loadSpeedSettings()
-- Normalize newly added speed controls while preserving the existing 12HubOntop.json config.
if St.autoChangeOnSteal == nil then
    St.autoChangeOnSteal = true
else
    St.autoChangeOnSteal = (St.autoChangeOnSteal == true)
end
St.stealSpeedActive = St.stealSpeedActive == true
St.stealSpeedKey = tostring(St.stealSpeedKey or "None")
St.stealSpeedButtonSize = math.clamp(tonumber(St.stealSpeedButtonSize) or 70, 40, 120)
if type(St.stealSpeedButtonPos) ~= "table" or #St.stealSpeedButtonPos < 4 then
    St.stealSpeedButtonPos = nil
end
-- One-time migration: the previous implementation defaulted this feature OFF.
-- Start this revised WalkSpeed-based behavior ON once, then preserve the user's saved choice.
if St._stealSpeedAutoModeMigrated ~= true then
    St.autoChangeOnSteal = true
    St._stealSpeedAutoModeMigrated = true
    pcall(saveCfg)
end
if St.stealSpeedKey ~= "None" and not Enum.KeyCode[St.stealSpeedKey] then
    St.stealSpeedKey = "None"
end
-- Clear a stale saved steal key if it collides with an existing mode/action bind.
if St.stealSpeedKey ~= "None" then
    local reservedStealKey = false
    for _, modeKey in pairs(St.speedKeys or {}) do
        if typeof(modeKey) == "EnumItem" and modeKey.Name == St.stealSpeedKey then reservedStealKey = true break end
    end
    for _, actionKey in pairs(St.keys or {}) do
        if typeof(actionKey) == "EnumItem" and actionKey.Name == St.stealSpeedKey then reservedStealKey = true break end
    end
    if reservedStealKey then St.stealSpeedKey = "None" end
end
-- Migrate the old experimental header into the Ace-like main-window layout once.
if St._aceFullMenuMigrated ~= true then
    St.uiLayout = "RIGHT"
    St._aceFullMenuMigrated = true
    pcall(saveCfg)
end
-- Ace-style migration: one lock switch controls menu drag + floating/mobile UI drag.
St.menuGuiLocked = (St.menuGuiLocked == true) or (St.guiLock == true)
St.guiLock = St.menuGuiLocked
_G._AceGuiLocked = St.menuGuiLocked
if St._aceStealBarLayoutV2 ~= true then
    St._stealBarPos = nil
    St._aceStealBarLayoutV2 = true
end
if St.uiLayout ~= "LEFT" and St.uiLayout ~= "RIGHT" and St.uiLayout ~= "TOP" and St.uiLayout ~= "BOTTOM" then
    St.uiLayout = "RIGHT"
end
-- Ace GUI scale is a saved percentage multiplier (50%-150%); new installs default to 70%.
-- Keep the existing 12HubOntop.json config and all saved values/positions intact.
do
    local loadedMenuScale = tonumber(St.menuScale)
    St.menuScale = math.clamp(loadedMenuScale or 0.7, 0.5, 1.5)
    St._aceMenuScaleV2 = true

    -- Convert a legacy center-anchored position to Ace's top-left/center-Y model once,
    -- instead of deleting the user's saved position as the experimental migration did.
    if St._acePositionModelV2 ~= true then
        local savedMainPos = St._mainPos
        if type(savedMainPos) == "table" and #savedMainPos >= 4 then
            local sx = tonumber(savedMainPos[1]) or 0
            local ox = tonumber(savedMainPos[2]) or 0
            local sy = tonumber(savedMainPos[3]) or 0
            local oy = tonumber(savedMainPos[4]) or 0
            if math.abs(sx - 0.5) < 0.0001 and math.abs(sy - 0.5) < 0.0001 then
                local camera = workspace.CurrentCamera
                local view = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
                local touch = UIS.TouchEnabled and not UIS.KeyboardEnabled
                local factor = 1
                if touch then
                    factor = (math.min(view.X, view.Y) < 600) and 0.6 or 0.82
                end
                local scale = St.menuScale * factor
                local width = (St.uiLayout == "LEFT" or St.uiLayout == "RIGHT") and 420 or 348
                local height = (St.uiLayout == "LEFT" or St.uiLayout == "RIGHT") and 528 or 540
                local left = view.X * sx + ox - (width * scale * 0.5)
                local top = view.Y * sy + oy - (height * scale * 0.5)
                St._mainPos = {0, left, 0.5, top - (view.Y * 0.5)}
            end
        end
        St._acePositionModelV2 = true
    end
    if _menuScaleConfigLoaded then pcall(saveCfg) end
end
if St.instaMode == "V1" then St.instaMode = "Fast Reset" end
if St.instaMode ~= "Fast Reset" and St.instaMode ~= "V2" then St.instaMode = "Fast Reset" end
St.autoFastReset = nil
St.autoResetBalloon = nil
-- Trap/anti-trap defaults are applied after config load so older configs migrate cleanly.
St.antiTrapGear = tostring(St.antiTrapGear or "Cupid's Wings")
St.trapESP = St.trapESP == true
St.trapDistanceESP = St.trapDistanceESP ~= false
St.trapOutlineESP = St.trapOutlineESP ~= false
St.subspaceESP = St.subspaceESP ~= false
-- Auto Equip Trap 0M shares the Anti Trap master toggle; do not restore a stale ON state.
St.antiTrapZeroM = St.antiTrap == true
St.trapScanRange = math.clamp(tonumber(St.trapScanRange) or 250, 10, 1000)
St.nukeOptimiserEnabled = St.nukeOptimiserEnabled == true
St.fpsCap = math.clamp(math.floor(tonumber(St.fpsCap) or 240), 30, 1000)
St.optimizerEnabled = St.optimizerEnabled == true
-- Legacy 3-mode GUI size values are ignored; the speed buttons use a fixed size.
St.speedModeSizes = nil
St.speedModeScale = nil
-- One-time migration for the requested mobile PS / MED layout:
-- both stay directly above the first two action buttons (DROP / INSTA).
do
    if St._mobilePSMedLayoutV1 ~= true then
        St._btnPos = St._btnPos or {}
        St._btnPos.A_ps = nil
        St._btnPos.A_med = nil
        St._mobilePSMedLayoutV1 = true
        pcall(saveCfg)
    end
end

-- Body Lock has been removed completely. Strip any keys from older configs.
St.bodyLock = nil
St.bodyLockRange = nil

local _RanaPersistedStealVer = tostring(St.stealVer or "Normal-V2")
local _savedStealMode, _savedStealVersion = _RanaPersistedStealVer:match("^(Normal|Semi)%-(V[12])$")
selectedStealMode = _savedStealMode or ((tostring(selectedStealMode or "Normal") == "Semi") and "Semi" or "Normal")
autoStealV2Version = _savedStealVersion or "V2"
selectedNormalMode = (selectedStealMode == "Normal" and autoStealV2Version) or "V2"
selectedSemiMode = (selectedStealMode == "Semi" and autoStealV2Version) or "V2"
St.stealVer = selectedStealMode .. "-" .. autoStealV2Version
task.spawn(function()
    -- Interaction callbacks still save immediately; periodic writes are only a fallback.
    -- A 10-second interval avoids repeated executor file I/O stutters on mobile.
    while true do
        task.wait(10)
        local ok, err = pcall(saveCfg)
        if not ok then warn("[12Hub] autosave fallback failed:", err) end
    end
end)

----------------------------------------------------------------
----------------------------------------------------------------
-- SPEED — full Empire multi-method loop (Velocity / LV / CFrame / ...)
----------------------------------------------------------------
local speedConnection = nil
local currentSpeedValue = 16
St.speedMethod = St.speedMethod or "Velocity"
St.hyperMult = tonumber(St.hyperMult) or 4

local _spd = {
	lastMethod = nil,
	lastMoveDir = Vector3.zero,
	anchoredBySpeed = nil,
	bodyVel = nil, bodyPosition = nil, bodyForce = nil, bodyThrust = nil,
	linearVel = nil, vectorForce = nil, alignPos = nil,
	rocket = nil, rocketTarget = nil,
	attLinVel = nil, attVecForce = nil, attAlign = nil,
	speedTween = nil,
}

local MOVE_KEYS = {
	[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
	[Enum.KeyCode.Up] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Right] = true,
}

function getCharParts()
	local char = LP.Character
	if not char then return nil, nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return nil, nil end
	return hum, root
end


----------------------------------------------------------------
-- SPEED LOOP + INF JUMP — FULL EMPIRE (fetched) — no old leftovers
-- 3 mode (Normal/Lagger/Custom) = St.modes + getActiveMoveSpeed
----------------------------------------------------------------
_spd = _spd or {
	lastMethod = nil,
	lastMoveDir = Vector3.zero,
	anchoredBySpeed = nil,
	bodyVel = nil, bodyPosition = nil, bodyForce = nil, bodyThrust = nil,
	linearVel = nil, vectorForce = nil, alignPos = nil,
	rocket = nil, rocketTarget = nil,
	attLinVel = nil, attVecForce = nil, attAlign = nil,
	speedTween = nil,
}
speedConnection = nil
currentSpeedValue = 16

function isCarryingBrainrot(char)
	if not char then return false end
	local ok, st = pcall(function() return LP:GetAttribute("Stealing") end)
	if ok and st == true then return true end
	local ok2, st2 = pcall(function() return char:GetAttribute("Stealing") end)
	if ok2 and st2 == true then return true end
	for _, v in ipairs(char:GetChildren()) do
 if v:IsA("Tool") or v:IsA("Model") or v:IsA("Folder") then
 local n = string.lower(tostring(v.Name))
 if n:find("brainrot", 1, true) or n:find("carriedbrain", 1, true) then
 return true
 end
 end
	end
	return false
end

function getActiveMoveSpeed()
	-- 3 mode speed: Normal / Lagger / Custom (UI + V2 bar)
	local mode = St.activeMode
	if not mode or not St.modes[mode] then
 mode = "Normal"
 St.activeMode = "Normal"
	end
	local m = St.modes[mode] or { norm = 59, steal = 30 }
	local norm = math.clamp(tonumber(m.norm) or 59, 1, 200)
	local steal = math.clamp(tonumber(m.steal) or 30, 1, 200)
	if St.stealSpeedActive == true or isCarryingBrainrot(LP.Character) then
 return steal
	end
	return norm
end

function ensureSpeedAttachment(hrp, key, name)
	local att = _spd[key]
	if not att or att.Parent ~= hrp then
 if att then pcall(function() att:Destroy() end) end
 att = Instance.new("Attachment")
 att.Name = name or "miauw_vsEmpireSpeedAtt"
 att.Parent = hrp
 _spd[key] = att
	end
	return att
end

function destroySpeedObjects() if _spd.anchoredBySpeed then pcall(function() _spd.anchoredBySpeed.Anchored = false end); _spd.anchoredBySpeed = nil end if _spd.bodyVel then pcall(function() _spd.bodyVel:Destroy() end); _spd.bodyVel = nil end if _spd.bodyPosition then pcall(function() _spd.bodyPosition:Destroy() end); _spd.bodyPosition = nil end if _spd.bodyForce then pcall(function() _spd.bodyForce:Destroy() end); _spd.bodyForce = nil end if _spd.bodyThrust then pcall(function() _spd.bodyThrust:Destroy() end); _spd.bodyThrust = nil end if _spd.linearVel then pcall(function() _spd.linearVel:Destroy() end); _spd.linearVel = nil end if _spd.vectorForce then pcall(function() _spd.vectorForce:Destroy() end); _spd.vectorForce = nil end if _spd.alignPos then pcall(function() _spd.alignPos:Destroy() end); _spd.alignPos = nil end if _spd.rocket then pcall(function() _spd.rocket:Destroy() end); _spd.rocket = nil end if _spd.rocketTarget then pcall(function() _spd.rocketTarget:Destroy() end); _spd.rocketTarget = nil end if _spd.attLinVel then pcall(function() _spd.attLinVel:Destroy() end); _spd.attLinVel = nil end if _spd.attVecForce then pcall(function() _spd.attVecForce:Destroy() end); _spd.attVecForce = nil end if _spd.attAlign then pcall(function() _spd.attAlign:Destroy() end); _spd.attAlign = nil end if _spd.speedTween then pcall(function() _spd.speedTween:Cancel() end); _spd.speedTween = nil end end function applySpeedMethod(hrp, hum, dir, spd, dt) local step = dt or 1/60 local m = (St.speedMethod or "Velocity") if _spd.lastMethod ~= m then destroySpeedObjects() if m ~= "WalkSpeed" and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end _spd.lastMethod = m end local char = hrp.Parent local targetPos = hrp.Position + (dir * spd * step) local function massImpulse(direction, targetSpeed) local mass = hrp.AssemblyMass or 1 local current = hrp.AssemblyLinearVelocity local desired = Vector3.new(direction.X * targetSpeed, current.Y, direction.Z * targetSpeed) local delta = desired - current pcall(function() hrp:ApplyImpulse(Vector3.new(delta.X, 0, delta.Z) * mass) end) end if m == "Velocity" then massImpulse(dir, spd) elseif m == "AssemblyLinearVelocity" then massImpulse(dir, spd) elseif m == "Velocity Lerp" then local current = hrp.AssemblyLinearVelocity local desired = Vector3.new(dir.X*spd, current.Y, dir.Z*spd) local blended = current:Lerp(desired, 0.6) local mass = hrp.AssemblyMass or 1 pcall(function() hrp:ApplyImpulse(Vector3.new(blended.X - current.X, 0, blended.Z - current.Z) * mass) end) elseif m == "AssemblyLinearVelocity Lerp" then local current = hrp.AssemblyLinearVelocity local desired = Vector3.new(dir.X*spd, current.Y, dir.Z*spd) local blended = current:Lerp(desired, 0.6) local mass = hrp.AssemblyMass or 1 pcall(function() hrp:ApplyImpulse(Vector3.new(blended.X - current.X, 0, blended.Z - current.Z) * mass) end) elseif m == "CFrame" then hrp.CFrame = hrp.CFrame + (dir * spd * step) elseif m == "CFrame Lerp" then hrp.CFrame = hrp.CFrame:Lerp(hrp.CFrame + (dir * spd * step), 0.5) elseif m == "Hyper CFrame" then hrp.CFrame = hrp.CFrame + (dir * spd * ((St.hyperMult or 4) or 4) * step) elseif m == "Anchored CFrame" then if not hrp.Anchored then hrp.Anchored = true _spd.anchoredBySpeed = hrp end hrp.CFrame = hrp.CFrame + (dir * spd * step) elseif m == "PivotTo" then hrp:PivotTo(hrp.CFrame + (dir * spd * step)) elseif m == "Model PivotTo" then if char and char:IsA("Model") then char:PivotTo(char:GetPivot() + (dir * spd * step)) else hrp:PivotTo(hrp.CFrame + (dir * spd * step)) end elseif m == "Tween CFrame" then if _spd.speedTween then pcall(function() _spd.speedTween:Cancel() end) end _spd.speedTween = TS:Create(hrp, TweenInfo.new(step, Enum.EasingStyle.Linear), {CFrame = hrp.CFrame + (dir * spd * step)}) _spd.speedTween:Play() elseif m == "WalkSpeed" then hum.WalkSpeed = spd elseif m == "Humanoid Move" then hum.WalkSpeed = spd hum:Move(dir) elseif m == "Humanoid MoveTo" then hum:MoveTo(targetPos, hrp) elseif m == "BodyVelocity" then if not _spd.bodyVel or _spd.bodyVel.Parent ~= hrp then if _spd.bodyVel then pcall(function() _spd.bodyVel:Destroy() end) end _spd.bodyVel = Instance.new("BodyVelocity") _spd.bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge) _spd.bodyVel.Parent = hrp end _spd.bodyVel.Velocity = Vector3.new(dir.X*spd, _spd.bodyVel.Velocity.Y, dir.Z*spd) elseif m == "BodyPosition" then if not _spd.bodyPosition or _spd.bodyPosition.Parent ~= hrp then if _spd.bodyPosition then pcall(function() _spd.bodyPosition:Destroy() end) end _spd.bodyPosition = Instance.new("BodyPosition") _spd.bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge) _spd.bodyPosition.P = 500 _spd.bodyPosition.D = 50 _spd.bodyPosition.Parent = hrp end _spd.bodyPosition.Position = targetPos elseif m == "BodyForce" then if not _spd.bodyForce or _spd.bodyForce.Parent ~= hrp then if _spd.bodyForce then pcall(function() _spd.bodyForce:Destroy() end) end _spd.bodyForce = Instance.new("BodyForce") _spd.bodyForce.Parent = hrp end _spd.bodyForce.Force = Vector3.new(dir.X*spd, 0, dir.Z*spd) * 100 elseif m == "BodyThrust" then if not _spd.bodyThrust or _spd.bodyThrust.Parent ~= hrp then if _spd.bodyThrust then pcall(function() _spd.bodyThrust:Destroy() end) end _spd.bodyThrust = Instance.new("BodyThrust") _spd.bodyThrust.Force = Vector3.new(math.huge, math.huge, math.huge) _spd.bodyThrust.Parent = hrp end _spd.bodyThrust.Force = Vector3.new(dir.X*spd, 0, dir.Z*spd) * 100 elseif m == "LinearVelocity" then if not _spd.linearVel or _spd.linearVel.Parent ~= hrp then if _spd.linearVel then pcall(function() _spd.linearVel:Destroy() end) end local att = ensureSpeedAttachment(hrp, "attLinVel", "MoveeLinVelAtt") _spd.linearVel = Instance.new("LinearVelocity") _spd.linearVel.Attachment0 = att _spd.linearVel.MaxForce = 1e8 _spd.linearVel.RelativeTo = Enum.ActuatorRelativeTo.World _spd.linearVel.Parent = hrp end _spd.linearVel.VectorVelocity = Vector3.new(dir.X*spd, _spd.linearVel.VectorVelocity.Y, dir.Z*spd) elseif m == "VectorForce" then if not _spd.vectorForce or _spd.vectorForce.Parent ~= hrp then if _spd.vectorForce then pcall(function() _spd.vectorForce:Destroy() end) end local att = ensureSpeedAttachment(hrp, "attVecForce", "MoveeVecForceAtt") _spd.vectorForce = Instance.new("VectorForce") _spd.vectorForce.Attachment0 = att _spd.vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World _spd.vectorForce.Parent = hrp end _spd.vectorForce.Force = Vector3.new(dir.X*spd, 0, dir.Z*spd) * 100 elseif m == "AlignPosition" then if not _spd.alignPos or _spd.alignPos.Parent ~= hrp then if _spd.alignPos then pcall(function() _spd.alignPos:Destroy() end) end local att = ensureSpeedAttachment(hrp, "attAlign", "MoveeAlignAtt") _spd.alignPos = Instance.new("AlignPosition") _spd.alignPos.Attachment0 = att _spd.alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment _spd.alignPos.MaxForce = math.huge _spd.alignPos.Responsiveness = 15 _spd.alignPos.RigidityEnabled = false _spd.alignPos.Parent = hrp end _spd.alignPos.Position = targetPos elseif m == "ApplyImpulse" then local mass = hrp.AssemblyMass or 1 local current = hrp.AssemblyLinearVelocity local desired = Vector3.new(dir.X * spd, current.Y, dir.Z * spd) local delta = desired - current pcall(function() hrp:ApplyImpulse(Vector3.new(delta.X, 0, delta.Z) * mass) end) elseif m == "RocketPropulsion" then if not _spd.rocket or _spd.rocket.Parent ~= hrp or not _spd.rocketTarget then if _spd.rocket then pcall(function() _spd.rocket:Destroy() end) end if _spd.rocketTarget then pcall(function() _spd.rocketTarget:Destroy() end) end _spd.rocketTarget = Instance.new("Part") _spd.rocketTarget.Name = "MoveeRocketTarget" _spd.rocketTarget.Anchored = true _spd.rocketTarget.CanCollide = false _spd.rocketTarget.Transparency = 1 _spd.rocketTarget.Size = Vector3.new(1,1,1) _spd.rocketTarget.Parent = workspace _spd.rocket = Instance.new("RocketPropulsion") _spd.rocket.MaxThrust = 3000 _spd.rocket.MaxTorque = 1000 _spd.rocket.ThrustP = 100 _spd.rocket.ThrustD = 20 _spd.rocket.TurnP = 100 _spd.rocket.TurnD = 10 _spd.rocket.Target = _spd.rocketTarget _spd.rocket.Parent = hrp end _spd.rocketTarget.Position = targetPos pcall(function() _spd.rocket:Fire() end) end end 

function stopSpeedBoost()
	if speedConnection then
 pcall(function() speedConnection:Disconnect() end)
 speedConnection = nil
	end
	pcall(destroySpeedObjects)
end

function startSpeedBoost()
	if not St.speedOn then
 stopSpeedBoost()
 return
	end
	currentSpeedValue = getActiveMoveSpeed()
	if speedConnection then
 pcall(function() speedConnection:Disconnect() end)
 speedConnection = nil
	end
	-- EMPIRE full loop (RenderStepped)
	speedConnection = RS.RenderStepped:Connect(function(dt)
 if not St.speedOn then return end
 local char = LP.Character
 if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid")
 local hrp = char:FindFirstChild("HumanoidRootPart")
 if not hum or not hrp then return end
 -- ragdoll → stop
 local stt = hum:GetState()
 if stt == Enum.HumanoidStateType.Physics
 or stt == Enum.HumanoidStateType.Ragdoll
 or stt == Enum.HumanoidStateType.FallingDown
 or hum.Health <= 0 then
 _spd.lastMoveDir = Vector3.zero
 destroySpeedObjects()
 return
 end
 local md = hum.MoveDirection
 local spd = getActiveMoveSpeed()
 currentSpeedValue = spd
 local dir = Vector3.zero
 if md.Magnitude > 0.01 then
 _spd.lastMoveDir = md
 dir = md
 else
 -- giữ hướng khi anti ragdoll + phím còn giữ (Empire style)
 local anyHeld = false
 if type(MOVE_KEYS) == "table" then
 for key in pairs(MOVE_KEYS) do
 if UIS:IsKeyDown(key) then anyHeld = true break end
 end
 end
 if anyHeld and _spd.lastMoveDir and _spd.lastMoveDir.Magnitude > 0.01 then
 dir = _spd.lastMoveDir
 end
 end
 if dir.Magnitude > 0.01 then
 applySpeedMethod(hrp, hum, dir.Unit, spd, dt)
 else
 destroySpeedObjects()
 end
	end)
end

function setSpeedOn(on)
	St.speedOn = on and true or false
	if St.speedOn then startSpeedBoost() else stopSpeedBoost() end
	saveSpeedSettings()
end

function setActiveMode(mode)
	if not St.modes[mode] then return end
	St.activeMode = mode
	currentSpeedValue = getActiveMoveSpeed()
	if St.speedOn then
 startSpeedBoost() -- restart Empire loop
	end
	if _G.RanaVSRefreshModeBar then pcall(_G.RanaVSRefreshModeBar) end
	if _G.RanaVSRefreshV2ModeBar then pcall(_G.RanaVSRefreshV2ModeBar) end
	if _G.RanaVSRefreshModeCards then pcall(_G.RanaVSRefreshModeCards) end
	if _G.RanaVSRefreshSpeedTab then pcall(_G.RanaVSRefreshSpeedTab) end
	if _G.RanaVSRefreshStealSpeedControls then pcall(_G.RanaVSRefreshStealSpeedControls) end
	saveSpeedSettings()
end

----------------------------------------------------------------

local function setStealSpeedActive2(on, saveIt)
    St.stealSpeedActive = (on == true)
    currentSpeedValue = getActiveMoveSpeed()
    if St.speedOn then
        startSpeedBoost()
    end
    if _G.RanaVSRefreshStealSpeedControls then pcall(_G.RanaVSRefreshStealSpeedControls) end
    if _G.RanaVSRefreshFloatingStealSpeedButton then pcall(_G.RanaVSRefreshFloatingStealSpeedButton) end
    if saveIt ~= false then pcall(saveCfg) end
    return St.stealSpeedActive
end
_G.RanaVSSetStealSpeedActive = setStealSpeedActive2

-- WalkSpeed-based auto switching (<25 = carrying/steal slowdown). This uses property
-- change events instead of a per-frame loop to avoid adding FPS overhead.
do
    local monitoredHumanoid2 = nil
    local walkSpeedConnection2 = nil
    local healthConnection2 = nil
    local characterConnection2 = nil
    local function syncWalkSpeed2(humanoid2)
        if St.autoChangeOnSteal ~= true then return end
        local shouldUseSteal2 = humanoid2 ~= nil and humanoid2.Parent ~= nil
            and humanoid2.Health > 0 and tonumber(humanoid2.WalkSpeed) ~= nil
            and humanoid2.WalkSpeed < 25
        if St.stealSpeedActive ~= shouldUseSteal2 then
            setStealSpeedActive2(shouldUseSteal2, false)
        end
    end
    local function bindCharacter2(character2)
        if walkSpeedConnection2 then pcall(function() walkSpeedConnection2:Disconnect() end); walkSpeedConnection2 = nil end
        if healthConnection2 then pcall(function() healthConnection2:Disconnect() end); healthConnection2 = nil end
        monitoredHumanoid2 = nil
        local humanoid2 = character2 and (character2:FindFirstChildOfClass("Humanoid") or character2:WaitForChild("Humanoid", 8))
        if not humanoid2 then
            syncWalkSpeed2(nil)
            return
        end
        monitoredHumanoid2 = humanoid2
        syncWalkSpeed2(humanoid2)
        walkSpeedConnection2 = humanoid2:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            syncWalkSpeed2(humanoid2)
        end)
        healthConnection2 = humanoid2:GetPropertyChangedSignal("Health"):Connect(function()
            syncWalkSpeed2(humanoid2)
        end)
        table.insert(_G._12HubAutoStealWalkSpeedConnections, walkSpeedConnection2)
        table.insert(_G._12HubAutoStealWalkSpeedConnections, healthConnection2)
    end
    characterConnection2 = LP.CharacterAdded:Connect(function(character2)
        task.defer(bindCharacter2, character2)
    end)
    table.insert(_G._12HubAutoStealWalkSpeedConnections, characterConnection2)
    if LP.Character then task.defer(bindCharacter2, LP.Character) end
    _G.RanaVSRefreshAutoStealWalkSpeed = function()
        syncWalkSpeed2(monitoredHumanoid2)
    end
end

-- INFINITE JUMP — FULL EMPIRE (hold + manual 2 mode)
----------------------------------------------------------------
InfJumpState = { enabled = false, mode = "hold", jumpHeld = false }
local _holdInfJumpConn = nil

function stopHoldInfJump()
	if _holdInfJumpConn then
 pcall(function() _holdInfJumpConn:Disconnect() end)
 _holdInfJumpConn = nil
	end
end

function startHoldInfJump()
	stopHoldInfJump()
	-- FULL Empire hold infinite jump (Velocity)
	_holdInfJumpConn = RS.Heartbeat:Connect(function()
 if not InfJumpState.enabled then return end
 local char = LP.Character
 if not char then return end
 local root = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")
 if not root or not hum then return end
 local isJumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump == true) or (InfJumpState.jumpHeld == true)
 local vel = root.Velocity
 pcall(function()
 local av = root.AssemblyLinearVelocity
 if av then vel = av end
 end)
 if isJumpHeld and vel.Y < 35 then
 local nv = Vector3.new(vel.X, 55, vel.Z)
 pcall(function() root.Velocity = nv end)
 pcall(function() root.AssemblyLinearVelocity = nv end)
 end
 if vel.Y < -120 then
 local nv = Vector3.new(vel.X, -120, vel.Z)
 pcall(function() root.Velocity = nv end)
 pcall(function() root.AssemblyLinearVelocity = nv end)
 end
	end)
end

function startInfJump()
	InfJumpState.enabled = true
	InfJumpState.mode = St.infJumpMode or "hold"
	startHoldInfJump()
end

function stopInfJump()
	InfJumpState.enabled = false
	InfJumpState.jumpHeld = false
	stopHoldInfJump()
end

function setInfJump(on)
	St.infJump = on and true or false
	if St.infJump then startInfJump() else stopInfJump() end
	saveCfg()
end

function setInfJumpMode(mode)
	-- "hold" | "manual" — Empire dùng cùng loop; manual chỉ pulse jumpHeld
	St.infJumpMode = mode
	InfJumpState.mode = mode
	if St.infJump then startInfJump() end
	saveCfg()
end

-- Mobile JumpButton + Space (Empire)
if not _G._VisEmpireJumpHook then
	_G._VisEmpireJumpHook = true
	task.spawn(function()
 local pg = LP:WaitForChild("PlayerGui", 15)
 if not pg then return end
 local function hookJumpButton(btn)
 if btn:IsA("GuiButton") and btn.Name == "JumpButton" and not btn:GetAttribute("Rana.VSInfJumpHooked") then
 btn:SetAttribute("Rana.VSInfJumpHooked", true)
 btn.MouseButton1Down:Connect(function()
 if InfJumpState.enabled then InfJumpState.jumpHeld = true end
 end)
 btn.MouseButton1Up:Connect(function()
 InfJumpState.jumpHeld = false
 end)
 end
 end
 for _, d in ipairs(pg:GetDescendants()) do hookJumpButton(d) end
 pg.DescendantAdded:Connect(hookJumpButton)
	end)
	UIS.JumpRequest:Connect(function()
 if not InfJumpState.enabled then return end
 if InfJumpState.mode == "manual" then
 InfJumpState.jumpHeld = true
 task.defer(function() InfJumpState.jumpHeld = false end)
 end
	end)
	UIS.InputEnded:Connect(function(inp)
 if inp.KeyCode == Enum.KeyCode.Space then
 InfJumpState.jumpHeld = false
 end
	end)
end


-- ANTI KICK (Empire full) — LUÔN BẬT, không bao giờ OFF
----------------------------------------------------------------
local AntiKickState = { enabled = true, brainrotDetected = false, conn = nil }
function enableAntiKick()
	AntiKickState.enabled = true
	St.antiKick = true
	-- namecall Kick shield (executor)
	pcall(function()
 if hookmetamethod and not _G._FAGAntiKickHooked then
 _G._FAGAntiKickHooked = true
 local old
 old = hookmetamethod(game, "__namecall", function(self, ...)
 local method = (getnamecallmethod and getnamecallmethod()) or ""
 if tostring(method) == "Kick" then
 if self == LP or (typeof(self) == "Instance" and self:IsA("Player") and self == LP) then
 return -- block LocalPlayer:Kick
 end
 end
 return old(self, ...)
 end)
 end
	end)
	-- block Players.LocalPlayer:Kick via hookfunction if available
	pcall(function()
 if hookfunction and not _G._FAGKickFnHooked then
 _G._FAGKickFnHooked = true
 local oldKick = LP.Kick
 if typeof(oldKick) == "function" then
 hookfunction(oldKick, function(self, ...)
 return -- never kick self
 end)
 end
 end
	end)
	if AntiKickState.conn then return end
	AntiKickState.conn = task.spawn(function()
 while true do -- forever
 AntiKickState.enabled = true
 St.antiKick = true
 task.wait(0.5)
 local char = LP.Character
 local found = false
 if char then
 for _, tool in ipairs(char:GetChildren()) do
 if tool:IsA("Tool") then
 local n = tool.Name:lower()
 if n:find("brainrot") or n:find("skibidi") or n:find("toilet") then
 found = true
 break
 end
 end
 end
 end
 AntiKickState.brainrotDetected = found
 end
	end)
end
function disableAntiKick()
	-- KHÔNG BAO GIỜ TẮT — bỏ qua
	enableAntiKick()
end
function setAntiKick(on)
	enableAntiKick()
	saveCfg()
end
task.defer(enableAntiKick)



-- VX7 Anti Ragdoll V1 / V2 FULL CORE
-- Replaced the previous La Peak Anti Ragdoll implementation.
St.antiRagdollMode = (St.antiRagdollMode == "V2") and "V2" or "V1"
_G.__LaPeakVX7AR = _G.__LaPeakVX7AR or {
    conn = nil,
    character = nil,
    humanoid = nil,
    root = nil,
    lastFalling = nil,
}

local function _vx7ARCacheCharacter()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root then
        return false
    end
    local S = _G.__LaPeakVX7AR
    S.character, S.humanoid, S.root = char, hum, root
    pcall(function()
        if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = hum
        end
    end)
    return true
end

local function _vx7ARIsRagdolled()
    local S = _G.__LaPeakVX7AR
    local hum = S.humanoid
    if not hum or not hum.Parent then
        return false
    end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or hum.PlatformStand then
        S.lastFalling = nil
        return true
    end
    if state == Enum.HumanoidStateType.FallingDown then
        S.lastFalling = S.lastFalling or os.clock()
        return os.clock() - S.lastFalling >= 0.18
    end
    S.lastFalling = nil
    local et = LP:GetAttribute("RagdollEndTime")
    return et ~= nil and (et - workspace:GetServerTimeNow()) > 0
end

local function _vx7ARRemoveConstraints()
    local char = _G.__LaPeakVX7AR.character
    if not char then return end
    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint")
            or (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            pcall(function() descendant:Destroy() end)
        end
    end
end

local function _vx7ARForceExit()
    local S = _G.__LaPeakVX7AR
    local hum, root = S.humanoid, S.root
    if not hum or not root or not hum.Parent or not root.Parent then return end
    local batTpEnabled = false
    pcall(function()
        batTpEnabled = Config and (Config.batTpEnabled or Config._smartBatTpDriving) or false
    end)
    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    if hum.Health > 0 then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    root.Anchored = false
    if not batTpEnabled then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        if Config and Config._vxSyncSpoof then
            pcall(Config._vxSyncSpoof, Vector3.zero)
        end
    end
    if not batTpEnabled and not (Config and Config.batAimbotToggled) then
        pcall(function()
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)
        end)
    end
    pcall(function()
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
    end)
end

local function _vx7ARRecoverV2()
    local S = _G.__LaPeakVX7AR
    local char, hum, root = S.character, S.humanoid, S.root
    if not char or not hum or not root then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, descendant in ipairs(char:GetDescendants()) do
            if descendant:IsA("Motor6D") or descendant:IsA("Constraint") then
                descendant.Enabled = true
            end
        end
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
        local playerScripts = LP:FindFirstChild("PlayerScripts")
        local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
        local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
        if controlModule then
            local ok, module = pcall(require, controlModule)
            if ok and module and module.Enable then pcall(module.Enable, module) end
        end
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

local function _vx7ARStartV1()
    local S = _G.__LaPeakVX7AR
    if S.conn and S.conn.Connected then return end
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    if not _vx7ARCacheCharacter() then return end
    S.conn = RS.RenderStepped:Connect(function()
        if not St.antiRagdoll or St.antiRagdollMode ~= "V1" then return end
        if Config and Config._instaResetInProgress then return end
        if not S.humanoid or not S.humanoid.Parent or not S.root or not S.root.Parent then
            _vx7ARCacheCharacter()
            return
        end
        if _vx7ARIsRagdolled() then
            _vx7ARRemoveConstraints()
            _vx7ARForceExit()
        end
    end)
end

local function _vx7ARStartV2()
    local S = _G.__LaPeakVX7AR
    if S.conn and S.conn.Connected then return end
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    if not _vx7ARCacheCharacter() then return end
    S.conn = RS.Heartbeat:Connect(function()
        if not St.antiRagdoll or St.antiRagdollMode ~= "V2" then return end
        if Config and Config._instaResetInProgress then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return end
        if _G.dropActive then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
            local now = os.clock()
            local S2 = _G.__LaPeakVX7AR
            if state ~= Enum.HumanoidStateType.FallingDown or now - (S2.lastFalling or now) >= 0.15 then
                S2.lastFalling = now
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    for _, descendant in ipairs(char:GetDescendants()) do
                        if descendant:IsA("Motor6D") or descendant:IsA("Constraint") then
                            descendant.Enabled = true
                        end
                    end
                    if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
                    local playerScripts = LP:FindFirstChild("PlayerScripts")
                    local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
                    local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
                    if controlModule then
                        local ok, module = pcall(require, controlModule)
                        if ok and module and module.Enable then pcall(module.Enable, module) end
                    end
                    hum.AutoRotate = true
                    hum.PlatformStand = false
                    hum.Sit = false
                end)
            end
        end
    end)
end

local function startAntiRagdoll()
    St.antiRagdoll = true
    local S = _G.__LaPeakVX7AR
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    if St.antiRagdollMode == "V2" then
        _vx7ARStartV2()
    else
        _vx7ARStartV1()
    end
end

local function stopAntiRagdoll()
    St.antiRagdoll = false
    local S = _G.__LaPeakVX7AR
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    S.character, S.humanoid, S.root, S.lastFalling = nil, nil, nil, nil
end


function setAntiRagdollMode(mode)
    mode = tostring(mode or "V1"):upper()
    St.antiRagdollMode = (mode == "V2") and "V2" or "V1"
    if St.antiRagdoll then
        pcall(stopAntiRagdoll)
        pcall(startAntiRagdoll)
    end
    pcall(function() if _G.RanaVSRefreshAntiRagMode then _G.RanaVSRefreshAntiRagMode() end end)
    pcall(saveCfg)
end
_G.RanaVSSetAntiRagdollMode = setAntiRagdollMode

local function setAntiRagdoll(on)
    St.antiRagdoll = on == true
    if St.antiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end
    if type(saveCfg) == "function" then
        task.defer(function() pcall(saveCfg) end)
    end
end

-- Keep Anti Ragdoll alive across respawns and transient runtime disconnects.
local _adaptAntiRagdollCharacterConn
local _adaptAntiRagdollWatchdogStarted = false
local function _adaptAntiRagdollRuntimeAlive()
    if not St.antiRagdoll then return true end
    local S = _G.__LaPeakVX7AR
    return S and S.conn and S.conn.Connected == true
end

if not _adaptAntiRagdollCharacterConn then
    _adaptAntiRagdollCharacterConn = LP.CharacterAdded:Connect(function()
        if not St.antiRagdoll then return end
        task.delay(0.35, function()
            if St.antiRagdoll then
                pcall(startAntiRagdoll)
                
            end
        end)
    end)
end

if not _adaptAntiRagdollWatchdogStarted then
    _adaptAntiRagdollWatchdogStarted = true
    task.spawn(function()
        while task.wait(0.25) do
            if St.antiRagdoll and not _adaptAntiRagdollRuntimeAlive() then
                pcall(startAntiRagdoll)
            end
            
        end
    end)
end


-- ANTI GUMMY / BOOGIE / PAINTBALL (RanaVS full) — LUÔN BẬT
--------------------------------------------------------------
-- Anti Gummy / Boogie / Bee / Paintball (from Tp Heatseeker)
-- Always ON, no GUI
-- ============================================================
if not _G._FAG_VisAntiGummyFullLoaded then
	_G._FAG_VisAntiGummyFullLoaded = true
	task.spawn(function()
 local Players = game:GetService("Players")
 local RunService = game:GetService("RunService")
 local Lighting = game:GetService("Lighting")
 local ReplicatedStorage = game:GetService("ReplicatedStorage")
 local LocalPlayer = Players.LocalPlayer

 local AntiGummy, AntiBoogie, AntiBee = true, true, false -- no Anti Bee
 local ANTI_PAINTBALL_ALWAYS_ON = true

 local function ResetTool(Char)
 if not Char then Char = LocalPlayer.Character end
 if not Char then return end
 pcall(function()
 LocalPlayer:SetAttribute("BlockTools", false)
 LocalPlayer:SetAttribute("Web", false)
 Char:SetAttribute("BackpackReady", true)
 end)
 end

 local function ClearEffect()
 if AntiBee then
 for _, V in pairs(Lighting:GetChildren()) do
 if V.Name == "BeeBlur" or V.Name == "Flashbang" then
 pcall(function() V:Destroy() end)
 end
 end
 local Ctrl = ReplicatedStorage:FindFirstChild("Controllers")
 if Ctrl then
 local BC = Ctrl:FindFirstChild("BeeLauncherController")
 if BC then
 local B = BC:FindFirstChild("Buzzing")
 if B then pcall(function() B:Stop() end) end
 end
 end
 end
 if AntiBoogie then
 for _, V in pairs(Lighting:GetChildren()) do
 if V.Name == "DiscoEffect" then
 pcall(function() V:Destroy() end)
 end
 end
 local Ctrl = ReplicatedStorage:FindFirstChild("Controllers")
 if Ctrl then
 local BC = Ctrl:FindFirstChild("BoogieBombController")
 if BC then
 local B = BC:FindFirstChild("BOOM")
 if B then pcall(function() B:Stop() end) end
 end
 end
 end
 end

 local function getMainHudGui()
 local pg = LocalPlayer:FindFirstChild("PlayerGui")
 return pg and pg:FindFirstChild("Main")
 end

 local function isPaintballSplatGui(gui)
 if not gui or gui.Parent ~= getMainHudGui() then return false end
 if not (gui:IsA("ImageLabel") or gui:IsA("ImageButton")) then return false end
 if gui:GetAttribute("__UGPaintballIgnore") or gui:GetAttribute("__UGPaintballShrunk") then return false end
 return math.abs(gui.Rotation) > 0.01
 end

 local function shrinkPaintballSplat(gui)
 if not gui or gui:GetAttribute("__UGPaintballShrunk") then return end
 gui:SetAttribute("__UGPaintballShrunk", true)
 gui.Size = UDim2.fromOffset(6, 6)
 end

 local function runAntiPaintballSweep()
 if not ANTI_PAINTBALL_ALWAYS_ON then return end
 task.spawn(function()
 for _ = 1, 8 do
 local main = getMainHudGui()
 if not main then break end
 for _, c in ipairs(main:GetChildren()) do
 if isPaintballSplatGui(c) then
 pcall(shrinkPaintballSplat, c)
 end
 end
 task.wait(0.05)
 end
 end)
 end

 -- Paintball continuous sweep
 task.spawn(function()
 while task.wait(0.25) do
 if ANTI_PAINTBALL_ALWAYS_ON then
 pcall(runAntiPaintballSweep)
 end
 end
 end)

 -- Event-driven Anti Gummy / Boogie / Bee.
 -- Do not scan Lighting every Heartbeat: that can cause unnecessary FPS drops.
 -- Anti Bee is handled by the dedicated event-driven block below.
 task.spawn(function()
     while task.wait(0.5) do
         if AntiGummy then
             pcall(ResetTool)
         end
         if AntiBoogie then
             pcall(ClearEffect)
         end
     end
 end)

 -- Also clear on Lighting child added (instant)
 pcall(function()
 Lighting.ChildAdded:Connect(function(child)
 if not child then return end
 local n = child.Name
 if AntiBee and (n == "BeeBlur" or n == "Flashbang") then
 task.defer(function() pcall(function() child:Destroy() end) end)
 end
 if AntiBoogie and n == "DiscoEffect" then
 task.defer(function() pcall(function() child:Destroy() end) end)
 end
 end)
 end)

 -- Paintball: shrink when new splat appears on Main HUD
 pcall(function()
 local function hookMain(main)
 if not main or main:GetAttribute("_VisAntiPaintballHooked") then return end
 main:SetAttribute("_VisAntiPaintballHooked", true)
 main.ChildAdded:Connect(function(c)
 task.defer(function()
 if isPaintballSplatGui(c) then
 pcall(shrinkPaintballSplat, c)
 end
 end)
 end)
 end
 local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
 if pg then
 hookMain(pg:FindFirstChild("Main"))
 pg.ChildAdded:Connect(function(ch)
 if ch.Name == "Main" then
 task.defer(function() hookMain(ch) end)
 end
 end)
 end
 end)

 -- CharacterAdded: ensure tools unblocked
 LocalPlayer.CharacterAdded:Connect(function(char)
 task.defer(function()
 pcall(ResetTool, char)
 end)
 end)

 print("[Vis AllGear] Anti Gummy / Boogie / Bee / Paintball ON (silent)")
	end)
end

-- Setters: luôn ON, không OFF được
function setAntiGummy(on)
	St.antiGummy = true
	AntiFX.gummy = true
	saveCfg()
end

-- ============================================================================
-- ANTI BEE — MERGED FULL ENGINE
-- Sources integrated:
--   1) La Peak's existing Anti Bee block
--   2) antibee.lua.txt: broad visual blacklist + FOV 70 + touch/gamepad move loop
--   3) message (7).txt: exact Bee/Lighting names + BeeLauncherController sound
--
-- Design:
--   - One toggle controls the complete system.
--   - Event-driven first, with targeted sweeps so it does not scan Lighting every
--     Heartbeat.
--   - Covers both class-based post-effects and game-specific named Bee effects.
--   - Re-checks after respawn and catches recreated Bee/Buzzing instances.
--   - Restores FOV/sound state when disabled instead of leaving permanent changes.
-- ============================================================================
do
    local AntiBeeFull = {
        enabled = false,
        conns = {},
        originalMoveFunction = nil,
        controlsProtected = false,
        originalFOV = nil,
        savedSoundVolumes = {},
        hookedSounds = {},
        movementLockUntil = 0,
        movementLockDuration = 0.45,
    }

    -- Class/type blacklist from the standalone Anti Bee source.
    local effectClasses = {
        "BlurEffect", "ColorCorrectionEffect", "BloomEffect", "SunRaysEffect",
        "DepthOfFieldEffect", "Atmosphere", "Sky", "Smoke", "ParticleEmitter",
        "Beam", "Trail", "Highlight", "PostEffect", "SurfaceAppearance", "Fire",
        "Sparkles", "Explosion", "PointLight", "SpotLight", "SurfaceLight",
        "Shadows", "Blur", "Fog", "ColorGradingEffect", "ToneMappingEffect",
        "VignetteEffect", "GodRays", "Glare", "ChromaticAberrationEffect",
        "DistortionEffect", "LensFlare", "SunFlare", "LightInfluence",
        "AmbientOcclusionEffect", "RefractionEffect", "HeatDistortion",
        "GlitchEffect", "ScreenSpaceReflection", "MotionBlur", "VolumetricLight",
        "RainEffect", "SnowEffect", "LightningEffect", "NeonGlow", "ContrastCorrection",
        "ShadowMap", "Bloom", "Clouds", "FogVolume", "WaterEffect", "WindEffect",
        "PixelateEffect", "FilmGrainEffect", "CRTShader", "NightVisionEffect",
        "InfraredEffect", "HazeEffect", "ColorBalanceEffect", "DynamicLight",
        "AmbientEffect", "ScreenDistortion", "ScanlineEffect", "UnderwaterEffect",
        "ThermalVision", "ShockwaveEffect", "FlashEffect", "ExplosionLight",
        "VFXPart", "GlitchScreen", "ScreenFlash", "OverlayEffect", "ShadowEffect",
        "GhostEffect", "FogEmitter", "WindEmitter", "HeatWave", "SunGlow",
        "ColorOverlay", "VisionDistort", "EchoEffect", "ScreenOverlay", "VisualEffect",
        "LightingEffect", "CameraEffect", "WeatherEffect", "SmokeTrail", "FireTrail",
        "NeonEffect", "RefractionLayer", "PostProcessingEffect", "VisualNoise",
        "ScreenNoise",
    }

    -- Game-specific names found across the supplied Anti Bee implementations.
    local effectNames = {
        BeeBlur = true,
        Flashbang = true,
        Blue = true,
        DiscoEffect = true,
        ColorCorrection = true,
    }

    local SOUND_NAMES = {
        Buzzing = true,
    }

    local function isBlacklisted(obj)
        if not obj then return false end

        local n = obj.Name
        if effectNames[n] then
            return true
        end

        for _, className in ipairs(effectClasses) do
            local ok, result = pcall(function()
                return obj:IsA(className)
            end)
            if ok and result then
                return true
            end
        end

        return false
    end

    local function lockMovementForBee()
        if not AntiBeeFull.enabled then return end
        AntiBeeFull.movementLockUntil = math.max(
            AntiBeeFull.movementLockUntil or 0,
            os.clock() + (AntiBeeFull.movementLockDuration or 0.45)
        )
    end

    local function beeMovementLocked()
        return AntiBeeFull.enabled and os.clock() < (AntiBeeFull.movementLockUntil or 0)
    end

    local function rememberAndSilenceSound(sound)
        if not sound or not sound:IsA("Sound") then return end
        -- Buzzing is one of the exact Bee-hit signals from the supplied Anti Bee sources.
        lockMovementForBee()
        if not AntiBeeFull.savedSoundVolumes[sound] then
            AntiBeeFull.savedSoundVolumes[sound] = sound.Volume
        end
        pcall(function()
            sound:Stop()
            sound.Volume = 0
        end)
    end

    local function hookBuzzingSound(sound)
        if not sound or not sound:IsA("Sound") then return end
        rememberAndSilenceSound(sound)

        if AntiBeeFull.hookedSounds[sound] then
            return
        end
        AntiBeeFull.hookedSounds[sound] = true

        table.insert(AntiBeeFull.conns, sound.Played:Connect(function()
            if AntiBeeFull.enabled and sound.Parent then
                task.defer(function()
                    if AntiBeeFull.enabled and sound.Parent then
                        rememberAndSilenceSound(sound)
                    end
                end)
            end
        end))
    end

    local function restoreSoundVolumes()
        for sound, volume in pairs(AntiBeeFull.savedSoundVolumes) do
            if sound and sound.Parent then
                pcall(function()
                    sound.Volume = volume
                end)
            end
        end
        AntiBeeFull.savedSoundVolumes = {}
        AntiBeeFull.hookedSounds = {}
    end

    local function scanLighting()
        local root = Lighting
        if not root then return end

        for _, obj in ipairs(root:GetDescendants()) do
            if isBlacklisted(obj) then
                -- These are the Bee/Disco visual-hit signals supplied by the
                -- reference Anti Bee implementations. Lock movement before removal.
                if effectNames[obj.Name] then
                    lockMovementForBee()
                end
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
    end

    local function scanForBeeSounds()
        -- Supplied source #3: ReplicatedStorage.Controllers.BeeLauncherController.Buzzing
        pcall(function()
            local controllers = ReplicatedStorage:FindFirstChild("Controllers")
            local beeController = controllers and controllers:FindFirstChild("BeeLauncherController")
            local buzzing = beeController and beeController:FindFirstChild("Buzzing", true)
            if buzzing and buzzing:IsA("Sound") then
                hookBuzzingSound(buzzing)
            end
        end)

        -- Supplied source #2/#3: PlayerScripts/Bee/.../Buzzing
        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            if not playerScripts then return end

            local beeRoot = playerScripts:FindFirstChild("Bee", true)
            if beeRoot then
                local buzzing = beeRoot:FindFirstChild("Buzzing", true)
                if buzzing and buzzing:IsA("Sound") then
                    hookBuzzingSound(buzzing)
                end
            end

            -- Extra catch-all for recreated/renamed Bee sound instances that still
            -- use the supplied "Buzzing" sound name.
            for _, obj in ipairs(playerScripts:GetDescendants()) do
                if obj:IsA("Sound") and SOUND_NAMES[obj.Name] then
                    hookBuzzingSound(obj)
                end
            end
        end)
    end

    local function disconnectAll()
        for _, conn in ipairs(AntiBeeFull.conns) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        AntiBeeFull.conns = {}
        AntiBeeFull.controlsProtected = false
    end

    local function protectControls()
        if AntiBeeFull.controlsProtected then return end

        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
            if not playerModule then return end

            local controlsModule = require(playerModule)
            local controls = controlsModule and controlsModule.GetControls and controlsModule:GetControls()
            if not controls then return end

            if not AntiBeeFull.originalMoveFunction then
                AntiBeeFull.originalMoveFunction = controls.moveFunction
            end

            local protectedMove = function(self, moveVector, relativeToCamera)
                if AntiBeeFull.originalMoveFunction then
                    -- While a Bee-hit signal is active, discard the player's movement
                    -- vector briefly so the Bee cannot reverse/flip the character.
                    if beeMovementLocked() then
                        return AntiBeeFull.originalMoveFunction(self, Vector3.zero, relativeToCamera)
                    end
                    return AntiBeeFull.originalMoveFunction(self, moveVector, relativeToCamera)
                end
            end

            controls.moveFunction = protectedMove
            AntiBeeFull.controlsProtected = true

            local acc = 0
            table.insert(AntiBeeFull.conns, RunService.Heartbeat:Connect(function(dt)
                if not AntiBeeFull.enabled then return end
                acc += dt
                if acc < 0.50 then return end
                acc = 0

                pcall(function()
                    if controls.moveFunction ~= protectedMove then
                        controls.moveFunction = protectedMove
                    end
                end)
            end))
        end)
    end

    local function restoreControls()
        if not AntiBeeFull.originalMoveFunction then
            AntiBeeFull.controlsProtected = false
            return
        end

        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
            if not playerModule then return end

            local controlsModule = require(playerModule)
            local controls = controlsModule and controlsModule.GetControls and controlsModule:GetControls()
            if controls then
                controls.moveFunction = AntiBeeFull.originalMoveFunction
            end
        end)

        AntiBeeFull.originalMoveFunction = nil
        AntiBeeFull.controlsProtected = false
    end

    local function applyFOVLock()
        local cam = workspace.CurrentCamera
        if not cam then return end

        if AntiBeeFull.originalFOV == nil then
            AntiBeeFull.originalFOV = cam.FieldOfView
        end

        cam.FieldOfView = 70
    end

    local function restoreFOV()
        local cam = workspace.CurrentCamera
        if cam and AntiBeeFull.originalFOV ~= nil then
            pcall(function()
                cam.FieldOfView = AntiBeeFull.originalFOV
            end)
        end
        AntiBeeFull.originalFOV = nil
    end

    local function handleLightingAdded(obj)
        if not AntiBeeFull.enabled or not obj then return end
        if not obj:IsDescendantOf(Lighting) then return end

        task.defer(function()
            if not AntiBeeFull.enabled or not obj.Parent then return end
            if not obj:IsDescendantOf(Lighting) then return end
            if isBlacklisted(obj) then
                if effectNames[obj.Name] then
                    lockMovementForBee()
                end
                pcall(function()
                    obj:Destroy()
                end)
            end
        end)
    end

    local function handleDescendantAdded(obj)
        if not AntiBeeFull.enabled or not obj then return end

        -- Lighting effect protection.
        handleLightingAdded(obj)

        -- Sound protection for recreated Bee/Buzzing objects.
        if obj:IsA("Sound") and SOUND_NAMES[obj.Name] then
            task.defer(function()
                if AntiBeeFull.enabled and obj.Parent then
                    hookBuzzingSound(obj)
                end
            end)
        end
    end

    local function startAntiBee()
        if AntiBeeFull.enabled then return end

        disconnectAll()
        AntiBeeFull.enabled = true

        -- Immediate cleanup on enable.
        scanLighting()
        scanForBeeSounds()
        protectControls()
        applyFOVLock()

        -- Fast event-driven Lighting protection.
        table.insert(AntiBeeFull.conns, Lighting.DescendantAdded:Connect(handleLightingAdded))

        -- Catch recreated Bee/Buzzing nodes under PlayerScripts.
        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            if playerScripts then
                table.insert(AntiBeeFull.conns, playerScripts.DescendantAdded:Connect(function(obj)
                    if not AntiBeeFull.enabled then return end
                    handleDescendantAdded(obj)
                end))
            end
        end)

        -- Catch Bee controller descendants when the controller is recreated.
        pcall(function()
            table.insert(AntiBeeFull.conns, ReplicatedStorage.DescendantAdded:Connect(function(obj)
                if not AntiBeeFull.enabled or not obj then return end
                if obj.Name == "Buzzing" and obj:IsA("Sound") then
                    local beeController = obj:FindFirstAncestor("BeeLauncherController")
                    if beeController then
                        task.defer(function()
                            if AntiBeeFull.enabled and obj.Parent then
                                hookBuzzingSound(obj)
                            end
                        end)
                    end
                end
            end))
        end)

        -- The hook above listens to Sound.Played, matching the supplied
        -- controller-level anti-Bee behavior while also surviving recreated sounds.

        -- FPS-safe movement protection. Do not call Humanoid:Move every frame.
        -- PlayerModule.moveFunction is already protected above; only force zero
        -- movement during the short Bee lock, at a low frequency.
        local beeTick = 0
        table.insert(AntiBeeFull.conns, RunService.Heartbeat:Connect(function(dt)
            if not AntiBeeFull.enabled then return end
            beeTick += dt
            if beeTick < 0.10 then return end
            beeTick = 0

            if beeMovementLocked() then
                local char = LP.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function() humanoid:Move(Vector3.zero, true) end)
                end
            end

            local cam = workspace.CurrentCamera
            if cam and math.abs(cam.FieldOfView - 70) > 0.05 then
                cam.FieldOfView = 70
            end
        end))

        -- Respawn recovery.
        table.insert(AntiBeeFull.conns, LP.CharacterAdded:Connect(function()
            task.defer(function()
                if not AntiBeeFull.enabled then return end
                scanLighting()
                scanForBeeSounds()
                protectControls()
                applyFOVLock()
            end)
        end))

        _G.RanaVS_AntiBeeFullActive = true
    end

    local function stopAntiBee()
        AntiBeeFull.enabled = false
        AntiBeeFull.movementLockUntil = 0
        disconnectAll()
        restoreControls()
        restoreSoundVolumes()
        restoreFOV()
        _G.RanaVS_AntiBeeFullActive = false
    end

    function setAntiBee(on)
        local enable = on == true
        St.antiBee = enable

        if enable then
            startAntiBee()
        else
            stopAntiBee()
        end

        pcall(saveCfg)
        if _G.RanaVSRefreshAntiBeeBtn then
            pcall(_G.RanaVSRefreshAntiBeeBtn)
        end
    end

    _G.RanaVSSetAntiBee = setAntiBee
    _G.RanaVSStartAntiBee = startAntiBee
    _G.RanaVSStopAntiBee = stopAntiBee
end
-- ============================================================================
-- ============================================================================
-- ANTI TRAP — merged detector/equip logic from Anti trampa.lua
-- Standalone AntiTrap GUI removed: 12Hub owns the UI.
-- Adds zero-meter trap detection, fuzzy 5-gear tool matching, and trap ESP.
-- ============================================================================
do
	local AntiTrapState = {
		enabled = false,
		gear = "Cupid's Wings",
		stuckTime = 0,
		lastPosition = nil,
		lastEquip = 0,
		lastTrapEquip = 0,
		lastZeroMScan = 0,
		conn = nil,
	}

	local ANTI_TRAP_CHECK_TIME = 0.025
	local ANTI_TRAP_MOVEMENT_THRESHOLD = 0.015
	local ANTI_TRAP_COOLDOWN = 0.15
	-- "0M" is treated as touching/overlapping range with a small physics epsilon.
	local ANTI_TRAP_ZERO_M_EPSILON = 1.25

	local ANTI_TRAP_GEARS = {
		"Cupid's Wings",
		"Santa's Sleigh",
		"Witch's Broom",
		"Flying Carpet",
		"Waverider",
	}

	local TRAP_NAME_WORDS = {
		"trap",
		"tripmine",
		"trip mine",
		"landmine",
		"land mine",
		"beartrap",
		"bear trap",
		"snare",
		"subspace",
	}

	local TOOL_ALIASES = {
		["Cupid's Wings"] = {"cupid's wings", "cupids wings", "cupid wings", "cupid"},
		["Santa's Sleigh"] = {"santa's sleigh", "santas sleigh", "santa sleigh", "sleigh", "santa"},
		["Witch's Broom"] = {"witch's broom", "witchs broom", "witch broom", "broom", "witch"},
		["Flying Carpet"] = {"flying carpet", "carpet"},
		["Waverider"] = {"waverider", "wave rider", "waverider", "rider", "wave"},
	}

	for _, gearName in ipairs(ANTI_TRAP_GEARS) do
		if St.antiTrapGear == gearName then
			AntiTrapState.gear = gearName
			break
		end
	end
	St.antiTrapGear = AntiTrapState.gear

	local function normalizeToolName(name)
		name = tostring(name or ""):lower()
		name = name:gsub("[%[%]%(%){}]", " ")
		name = name:gsub("[^%w%s]", " ")
		name = name:gsub("%s+", " ")
		return name:gsub("^%s+", ""):gsub("%s+$", "")
	end

	local function compactName(name)
		return normalizeToolName(name):gsub("%s+", "")
	end

	local function scoreToolName(targetName, candidateName)
		local target = compactName(targetName)
		local candidate = compactName(candidateName)
		if target == "" or candidate == "" then return 0 end
		if target == candidate then return 1000 end

		local best = 0
		local aliases = TOOL_ALIASES[targetName] or {}
		for _, alias in ipairs(aliases) do
			local a = compactName(alias)
			if a ~= "" then
				if candidate == a then
					best = math.max(best, 950)
				elseif candidate:find(a, 1, true) or a:find(candidate, 1, true) then
					best = math.max(best, 850)
				end
			end
		end

		if candidate:find(target, 1, true) then
			best = math.max(best, 900)
		elseif target:find(candidate, 1, true) and #candidate >= 4 then
			best = math.max(best, 780)
		end

		local targetTokens = {}
		for tok in normalizeToolName(targetName):gmatch("%S+") do
			targetTokens[tok] = true
		end
		local candidateTokens = {}
		for tok in normalizeToolName(candidateName):gmatch("%S+") do
			candidateTokens[tok] = true
		end

		local overlap, total = 0, 0
		for tok in pairs(targetTokens) do
			total += 1
			if candidateTokens[tok] then overlap += 1 end
		end
		if total > 0 and overlap > 0 then
			best = math.max(best, 600 + math.floor(300 * overlap / total))
		end
		return best
	end

	local function getAllPlayerTools()
		local out, seen = {}, {}
		local function scan(container)
			if not container then return end
			for _, obj in ipairs(container:GetDescendants()) do
				if obj:IsA("Tool") and not seen[obj] then
					seen[obj] = true
					table.insert(out, obj)
				end
			end
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Tool") and not seen[obj] then
					seen[obj] = true
					table.insert(out, obj)
				end
			end
		end
		scan(LP:FindFirstChildOfClass("Backpack"))
		scan(LP.Character)
		return out
	end

	local function antiTrapFindTool(name)
		if type(name) ~= "string" or name == "" then return nil end
		local bestTool, bestScore = nil, -1
		for _, tool in ipairs(getAllPlayerTools()) do
			local score = scoreToolName(name, tool.Name)
			if score > bestScore then
				bestScore = score
				bestTool = tool
			end
		end
		-- Require a real name match; prevents equipping an unrelated tool.
		if bestScore >= 600 then
			return bestTool
		end
		return nil
	end

	-- Inventory-first resolver: prefer the selected gear if it is actually owned,
	-- otherwise select the first owned alternative from the supported gear list.
	-- This scans Backpack + Character only (never Workspace) and is called on
	-- enable/trigger rather than every Heartbeat, to keep it lightweight.
	local function resolveAvailableAntiTrapTool(preferredName)
		local tools = getAllPlayerTools()
		local function matchInInventory(name)
			if type(name) ~= "string" or name == "" then return nil end
			local bestTool, bestScore = nil, -1
			for _, tool in ipairs(tools) do
				if tool and tool.Parent and tool:IsA("Tool") then
					local score = scoreToolName(name, tool.Name)
					if score > bestScore then
						bestTool, bestScore = tool, score
					end
				end
			end
			if bestScore >= 600 then return bestTool end
			return nil
		end

		local chosenName = preferredName or AntiTrapState.gear
		local chosenTool = matchInInventory(chosenName)
		if chosenTool then return chosenTool, chosenName end

		for _, gearName in ipairs(ANTI_TRAP_GEARS) do
			if gearName ~= chosenName then
				local tool = matchInInventory(gearName)
				if tool then
					AntiTrapState.gear = gearName
					St.antiTrapGear = gearName
					pcall(saveCfg)
					task.defer(function()
						if _G.RanaVSRefreshAntiTrapGearUI then pcall(_G.RanaVSRefreshAntiTrapGearUI) end
					end)
					return tool, gearName
				end
			end
		end
		return nil, nil
	end

	-- ------------------------------------------------------------
	-- TRAP CANDIDATE / POSITION HELPERS
	-- ------------------------------------------------------------
	local TrapESP = {
		data = {},
		candidates = {},
		lastScan = 0,
		visualAccum = 0,
		heartbeat = nil,
		visualConn = nil,
		_conns = {},
	}

	local function containsTrapWord(name)
		local s = tostring(name or ""):lower()
		for _, word in ipairs(TRAP_NAME_WORDS) do
			if s:find(word, 1, true) then
				return true
			end
		end
		return false
	end

	local function isLocalCharacterObject(obj)
		local char = LP.Character
		return char and obj and obj:IsDescendantOf(char)
	end

	local function trapRootFromObject(obj)
		if not obj then return nil end
		if isLocalCharacterObject(obj) then return nil end

		local current = obj
		local best = nil
		for _ = 1, 8 do
			if not current or current == workspace then break end
			if containsTrapWord(current.Name) then
				if current:IsA("Model") or current:IsA("BasePart") then
					best = current
				end
			end
			current = current.Parent
		end
		if best then return best end
		if containsTrapWord(obj.Name) and (obj:IsA("Model") or obj:IsA("BasePart")) then
			return obj
		end
		return nil
	end

	local function trapPosition(obj)
		if not obj or not obj.Parent then return nil end
		if obj:IsA("BasePart") then return obj.Position end
		if obj:IsA("Model") then
			local ok, cf = pcall(function() return obj:GetPivot() end)
			if ok and cf then return cf.Position end
			local p = obj:FindFirstChildWhichIsA("BasePart", true)
			return p and p.Position or nil
		end
		if obj:IsA("Attachment") then return obj.WorldPosition end
		local p = obj:FindFirstChildWhichIsA("BasePart", true)
		return p and p.Position or nil
	end

	local function collectTrapCandidates()
		local map = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if (obj:IsA("Model") or obj:IsA("BasePart")) and not isLocalCharacterObject(obj) then
				local root = trapRootFromObject(obj)
				if root then
					map[root] = true
				end
			end
		end
		TrapESP.candidates = map
		TrapESP.lastScan = os.clock()
		return map
	end

	local function getTrapCandidates()
		-- Full workspace scan is only used to seed the cache once; subsequent
		-- additions/removals update TrapESP.candidates incrementally.
		if TrapESP.lastScan <= 0 then
			return collectTrapCandidates()
		end
		return TrapESP.candidates
	end

	local function nearestTrap()
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil, math.huge end

		local best, bestDistance = nil, math.huge
		local maxRange = tonumber(St.trapScanRange) or 250
		for trap in pairs(getTrapCandidates()) do
			local pos = trapPosition(trap)
			if pos then
				local d = (hrp.Position - pos).Magnitude
				if d < bestDistance and d <= maxRange then
					best, bestDistance = trap, d
				end
			end
		end
		return best, bestDistance
	end

	local function isSubspaceTrap(trap)
		return trap and containsTrapWord(trap.Name) and tostring(trap.Name):lower():find("subspace", 1, true) ~= nil
	end

	-- ------------------------------------------------------------
	-- TRAP ESP
	-- ------------------------------------------------------------
	local function getTrapAdorneePart(trap)
		if not trap then return nil end
		if trap:IsA("BasePart") then return trap end
		return trap:FindFirstChildWhichIsA("BasePart", true)
	end

	local function trapEspCleanup(trap)
		local d = TrapESP.data[trap]
		if not d then return end
		pcall(function() if d.hl then d.hl:Destroy() end end)
		pcall(function() if d.bb then d.bb:Destroy() end end)
		TrapESP.data[trap] = nil
	end

	local function trapEspSetup(trap)
		if not St.trapESP then return end
		if isSubspaceTrap(trap) and not St.subspaceESP then return end
		local adorneePart = getTrapAdorneePart(trap)
		if not trap or not adorneePart then return end
		trapEspCleanup(trap)

		local hl = Instance.new("Highlight")
		hl.Name = "12Hub_TrapOutline"
		hl.Adornee = trap
		hl.FillColor = isSubspaceTrap(trap) and Color3.fromRGB(180, 70, 255) or Color3.fromRGB(255, 70, 70)
		hl.FillTransparency = 0.86
		hl.OutlineColor = isSubspaceTrap(trap) and Color3.fromRGB(220, 120, 255) or Color3.fromRGB(255, 80, 80)
		hl.OutlineTransparency = St.trapOutlineESP and 0 or 1
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = trap

		local bb
		if St.trapDistanceESP or St.subspaceESP then
			bb = Instance.new("BillboardGui")
			bb.Name = "12Hub_TrapDistance"
			bb.Adornee = adorneePart
			bb.Size = UDim2.fromOffset(120, 28)
			bb.StudsOffset = Vector3.new(0, 2.2, 0)
			bb.AlwaysOnTop = true
			bb.MaxDistance = math.max(tonumber(St.trapScanRange) or 250, 100)
			bb.Parent = trap

			local label = Instance.new("TextLabel")
			label.Name = "Distance"
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextStrokeTransparency = 0.35
			label.Font = Enum.Font.GothamBlack
			label.TextSize = 11
			label.Parent = bb
		end

		TrapESP.data[trap] = {hl = hl, bb = bb, part = adorneePart}
	end

	local function refreshTrapVisuals()
		for trap in pairs(TrapESP.data) do
			if not trap or not trap.Parent then
				trapEspCleanup(trap)
			end
		end
		if not St.trapESP then
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
			return
		end
		for trap in pairs(getTrapCandidates()) do
			if not TrapESP.data[trap] then
				trapEspSetup(trap)
			end
		end
	end

	local function setTrapESP(on)
		St.trapESP = on == true
		if St.trapESP then
			collectTrapCandidates()
			refreshTrapVisuals()
		else
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
		end
		pcall(saveCfg)
	end

	local function setTrapDistanceESP(on)
		St.trapDistanceESP = on == true
		if St.trapESP then
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
			refreshTrapVisuals()
		end
		pcall(saveCfg)
	end

	local function setTrapOutlineESP(on)
		St.trapOutlineESP = on == true
		for trap,d in pairs(TrapESP.data) do
			if d.hl then d.hl.OutlineTransparency = St.trapOutlineESP and 0 or 1 end
		end
		pcall(saveCfg)
	end

	local function setSubspaceESP(on)
		St.subspaceESP = on == true
		if St.trapESP then
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
			refreshTrapVisuals()
		end
		pcall(saveCfg)
	end

	local function setTrapScanRange(n)
		St.trapScanRange = math.clamp(tonumber(n) or 250, 10, 1000)
		pcall(saveCfg)
	end

	local function setAntiTrapZeroM(on)
		-- Alias the ESP control to the same master switch as the Anti Trap toggle/button.
		local enabled = on == true
		if type(setAntiTrap) == "function" then
			setAntiTrap(enabled)
		else
			St.antiTrap = enabled
			St.antiTrapZeroM = enabled
			if enabled and TrapESP.lastScan <= 0 then collectTrapCandidates() end
			pcall(saveCfg)
		end
	end

	-- Render distance text without creating per-trap Heartbeat connections.
	TrapESP.visualConn = RunService.RenderStepped:Connect(function(deltaTime)
		if not St.trapESP then return end
		TrapESP.visualAccum = TrapESP.visualAccum + (tonumber(deltaTime) or 0)
		if TrapESP.visualAccum < 0.10 then return end
		TrapESP.visualAccum = 0
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for trap,d in pairs(TrapESP.data) do
			local pos = trapPosition(trap)
			if not pos or not trap.Parent then
				trapEspCleanup(trap)
			else
				if d.bb then
					local label = d.bb:FindFirstChild("Distance")
					if label then
						local meters = math.max(0, math.floor((hrp.Position - pos).Magnitude * 10 + 0.5) / 10)
						if isSubspaceTrap(trap) then
							label.Text = "SUBSPACE • " .. tostring(meters) .. "M"
							label.TextColor3 = Color3.fromRGB(220, 130, 255)
							label.Visible = St.subspaceESP or St.trapDistanceESP
						else
							label.Text = "TRAP • " .. tostring(meters) .. "M"
							label.TextColor3 = Color3.new(1, 1, 1)
							label.Visible = St.trapDistanceESP
						end
					end
				end
				if d.hl then
					d.hl.OutlineTransparency = St.trapOutlineESP and 0 or 1
				end
			end
		end
	end)

	-- Incremental trap cache: a workspace-wide scan per new effect/object was
	-- causing repeated FPS drops. Seed once; thereafter update only the changed object.
	table.insert(TrapESP._conns, workspace.DescendantAdded:Connect(function(obj)
		if not obj or (not obj:IsA("Model") and not obj:IsA("BasePart")) then return end
		if isLocalCharacterObject(obj) then return end
		local root = trapRootFromObject(obj)
		if not root or not root.Parent then return end
		TrapESP.candidates[root] = true
		if St.trapESP and not TrapESP.data[root] then
			task.defer(function()
				if St.trapESP and root.Parent and not TrapESP.data[root] then trapEspSetup(root) end
			end)
		end
	end))
	table.insert(TrapESP._conns, workspace.DescendantRemoving:Connect(function(obj)
		TrapESP.candidates[obj] = nil
		if TrapESP.data[obj] then trapEspCleanup(obj) end
	end))

	local function antiTrapEquipAndInstantUnequip(reason)
		if not AntiTrapState.enabled then return false end
		local selectedToolName = AntiTrapState.gear
		if not selectedToolName then return false end

		local now = os.clock()
		if now - AntiTrapState.lastEquip < ANTI_TRAP_COOLDOWN then return false end
		AntiTrapState.lastEquip = now

		local character = LP.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return false end

		-- Resolve inventory on each real trigger. If the selected gear is not owned,
		-- switch to an owned alternative instead of silently doing nothing.
		local tool, resolvedGear = resolveAvailableAntiTrapTool(selectedToolName)
		if not tool then return false end
		if resolvedGear then
			AntiTrapState.gear = resolvedGear
			St.antiTrapGear = resolvedGear
			selectedToolName = resolvedGear
		end
		local equipped = pcall(function()
			humanoid:EquipTool(tool)
		end)
		if not equipped then return false end

		AntiTrapState.lastEquipReason = reason
		task.spawn(function()
			pcall(function()
				-- Give Roblox one simulation step to register the equip before activating it.
				RunService.Heartbeat:Wait()
				local activeCharacter = LP.Character
				local activeHumanoid = activeCharacter and activeCharacter:FindFirstChildOfClass("Humanoid")
				if not activeCharacter or not activeHumanoid or activeHumanoid.Health <= 0 then return end
				if not tool or not tool.Parent then return end
				if tool.Parent ~= activeCharacter then activeHumanoid:EquipTool(tool) end
				tool:Activate()
				task.wait(0.05)
				activeHumanoid:UnequipTools()
			end)
		end)
		return true
	end

	local function stopAntiTrap()
		AntiTrapState.enabled = false
		AntiTrapState.stuckTime = 0
		AntiTrapState.lastPosition = nil
		if AntiTrapState.conn then
			pcall(function() AntiTrapState.conn:Disconnect() end)
			AntiTrapState.conn = nil
		end
		_G.RanaVS_AntiTrapActive = false
	end

	local function startAntiTrap()
		stopAntiTrap()
		AntiTrapState.enabled = true
		if St.antiTrapZeroM and TrapESP.lastScan <= 0 then collectTrapCandidates() end

		AntiTrapState.conn = RunService.Heartbeat:Connect(function(deltaTime)
			if not AntiTrapState.enabled then return end
			if not AntiTrapState.gear then return end

			local character = LP.Character
			if not character then return end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root or humanoid.Health <= 0 then return end

			-- Full Anti trampa movement detector.
			if not AntiTrapState.lastPosition then
				AntiTrapState.lastPosition = root.Position
			else
				local tryingToMove = humanoid.MoveDirection.Magnitude > 0.05
				local distance = (root.Position - AntiTrapState.lastPosition).Magnitude
				local actuallyMoving = distance > ANTI_TRAP_MOVEMENT_THRESHOLD

				if tryingToMove and not actuallyMoving then
					AntiTrapState.stuckTime += deltaTime
				else
					AntiTrapState.stuckTime = 0
				end
				AntiTrapState.lastPosition = root.Position

				if AntiTrapState.stuckTime >= ANTI_TRAP_CHECK_TIME then
					AntiTrapState.stuckTime = 0
					if (os.clock() - AntiTrapState.lastEquip) >= ANTI_TRAP_COOLDOWN then
						task.spawn(antiTrapEquipAndInstantUnequip, "STUCK")
					end
				end
			end

			-- ESP trap 0M trigger: auto-equip when a recognized trap is at contact range.
			if St.antiTrapZeroM and (os.clock() - AntiTrapState.lastZeroMScan) >= 0.10 then
				AntiTrapState.lastZeroMScan = os.clock()
				local trap, distance = nearestTrap()
				if trap and distance <= ANTI_TRAP_ZERO_M_EPSILON then
					if (os.clock() - AntiTrapState.lastTrapEquip) >= ANTI_TRAP_COOLDOWN then
						AntiTrapState.lastTrapEquip = os.clock()
						task.spawn(antiTrapEquipAndInstantUnequip, isSubspaceTrap(trap) and "SUBSPACE_0M" or "TRAP_0M")
					end
				end
			end
		end)

		_G.RanaVS_AntiTrapActive = true
	end

	function setAntiTrap(on)
		local enable = on == true
		-- One master state: Player toggle, mobile Anti Trap button, and ESP Auto Equip 0M.
		St.antiTrap = enable
		St.antiTrapZeroM = enable
		if enable then
			-- Immediately detect which supported gear is in Backpack/Character.
			-- Preserve the selected item when owned; otherwise auto-select an available one.
			resolveAvailableAntiTrapTool(AntiTrapState.gear)
			startAntiTrap()
		else
			stopAntiTrap()
		end
		pcall(saveCfg)
		if ToggleRefs and ToggleRefs.antiTrap and ToggleRefs.antiTrap.setVisual then
			pcall(ToggleRefs.antiTrap.setVisual, enable)
		end
		if ToggleRefs and ToggleRefs.antiTrapZeroM and ToggleRefs.antiTrapZeroM.setVisual then
			pcall(ToggleRefs.antiTrapZeroM.setVisual, enable)
		end
		pcall(function()
			if _G.RanaVSRefreshAntiTrapBtn then _G.RanaVSRefreshAntiTrapBtn() end
		end)
	end

	function setAntiTrapGear(name)
		name = tostring(name or "")
		for _, gearName in ipairs(ANTI_TRAP_GEARS) do
			if name == gearName then
				AntiTrapState.gear = gearName
				St.antiTrapGear = gearName
				AntiTrapState.lastPosition = nil
				-- If this gear is not in the current inventory, fall back immediately.
				local tool, availableName = resolveAvailableAntiTrapTool(gearName)
				if tool and availableName then
					AntiTrapState.gear = availableName
					St.antiTrapGear = availableName
				end
				pcall(saveCfg)
				task.defer(function()
					if _G.RanaVSRefreshAntiTrapGearUI then pcall(_G.RanaVSRefreshAntiTrapGearUI) end
				end)
				return true
			end
		end
		return false
	end

	function getAntiTrapToolMatch()
		local tool, availableName = resolveAvailableAntiTrapTool(AntiTrapState.gear)
		if tool and availableName then
			AntiTrapState.gear = availableName
			St.antiTrapGear = availableName
		end
		return tool
	end

	_G.RanaVSSetAntiTrap = setAntiTrap
	_G.RanaVSSetAntiTrapGear = setAntiTrapGear
	_G.RanaVSAntiTrapGears = ANTI_TRAP_GEARS
	_G.RanaVSFindAntiTrapTool = getAntiTrapToolMatch
	_G.RanaVSHasAntiTrapGear = function(name) return antiTrapFindTool(tostring(name or "")) ~= nil end
	_G.RanaVSNearestTrap = nearestTrap
	_G.RanaVSSetTrapESP = setTrapESP
	_G.RanaVSSetTrapDistanceESP = setTrapDistanceESP
	_G.RanaVSSetTrapOutlineESP = setTrapOutlineESP
	_G.RanaVSSetSubspaceESP = setSubspaceESP
	_G.RanaVSSetTrapScanRange = setTrapScanRange
	_G.RanaVSSetAntiTrapZeroM = setAntiTrapZeroM

	LP.CharacterAdded:Connect(function()
		AntiTrapState.lastPosition = nil
		AntiTrapState.stuckTime = 0
	end)

	-- Initialize trap cache without forcing the UI/ESP on.
	task.defer(function()
		pcall(collectTrapCandidates)
		if St.trapESP then pcall(refreshTrapVisuals) end
	end)
end

function setAntiBoogie(on)
	St.antiBoogie = true
	AntiFX.boogie = true
	saveCfg()
end
function setAntiPaint(on)
	St.antiPaint = true
	AntiFX.paint = true
	saveCfg()
end

----------------------------------------------------------------
-- TOOL AIMBOT (miauw_vs full) — LUÔN BẬT
----------------------------------------------------------------
local aimOn = true
local TOOLS = { ["Web Slinger"] = true, ["Paintball Gun"] = true, ["Laser Cape"] = true }
local hooked = {}
local mouseMod, lastAimUp = nil, 0
function getMouse()
	if mouseMod then return mouseMod end
	pcall(function()
 local pkg = ReplicatedStorage:FindFirstChild("Packages")
 if pkg then mouseMod = require(pkg:WaitForChild("PlayerMouse", 5)) end
	end)
	return mouseMod
end
function bestEnemy()
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not root or not cam then return nil end
	local best, score = nil, math.huge
	local camPos, camDir = cam.CFrame.Position, cam.CFrame.LookVector
	for _, plr in ipairs(Players:GetPlayers()) do
 if plr ~= LP and plr.Character then
 local r = plr.Character:FindFirstChild("HumanoidRootPart")
 local h = plr.Character:FindFirstChildOfClass("Humanoid")
 if r and h and h.Health > 0 then
 local d = (r.Position - root.Position).Magnitude
 if d <= 100 then
 local to = r.Position - camPos
 if to.Magnitude > 0.01 then
 local ang = math.deg(math.acos(math.clamp(camDir:Dot(to.Unit), -1, 1)))
 local sc = d + (ang > 200 and 1000 or 0)
 if sc < score then score, best = sc, r end
 end
 end
 end
 end
	end
	return best
end
function overrideMouse()
	if not aimOn then return end
	local pm = getMouse()
	if not pm then return end
	local e = bestEnemy()
	if e and e.Parent then
 local vel = e.AssemblyLinearVelocity or Vector3.zero
 pcall(function()
 pm.Hit = CFrame.new(e.Position + vel * 0.1)
 pm.Target = e
 end)
	end
end
function hookTool(tool)
	if hooked[tool] or not tool then return end
	hooked[tool] = true
	tool.Activated:Connect(overrideMouse)
	tool.Equipped:Connect(function()
 task.wait(0.1)
 local pm = getMouse()
 if pm and aimOn then
 local old = pm.Button1Down
 pm.Button1Down = function(...)
 overrideMouse()
 if old then old(...) end
 end
 end
	end)
end
function watchTools(parent)
	if not parent then return end
	for _, c in ipairs(parent:GetChildren()) do
 if TOOLS[c.Name] then hookTool(c) end
	end
	parent.ChildAdded:Connect(function(c)
 task.wait(0.05)
 if TOOLS[c.Name] then hookTool(c) end
	end)
end
watchTools(LP.Backpack)
if LP.Character then watchTools(LP.Character) end
LP.CharacterAdded:Connect(function(c)
	task.wait(0.2)
	watchTools(c)
	watchTools(LP.Backpack)
end)
RS.RenderStepped:Connect(function()
	if not aimOn then return end
	if tick() - lastAimUp > 0.1 then lastAimUp = tick(); bestEnemy() end
	if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then overrideMouse() end
end)
function setToolAim(on)
	-- LUÔN BẬT tool aimbot
	aimOn = true
	St.toolAim = true
	local char = LP.Character
	if char then pcall(watchTools, char) end
	local bp = LP:FindFirstChild("Backpack")
	if bp then pcall(watchTools, bp) end
	saveCfg()
end
-- boot tool aim
task.defer(function()
	aimOn = true
	St.toolAim = true
	pcall(function()
 if LP.Character then watchTools(LP.Character) end
 if LP.Backpack then watchTools(LP.Backpack) end
	end)
end)

----------------------------------------------------------------

-- Compatibilidad con los controles de spam ya presentes en Monster Versus.
-- El sistema importado conserva su comportamiento original de Miauw.
_G.__12HubChilliAim = {
    update = overrideMouse,
    restore = function() end,
    refresh = function()
        aimOn = true
    end,
}


-- DROP JUMP / STAND (Vis Clean)
----------------------------------------------------------------
local dropActive = false
local DROP_SPD, DROP_DUR = 200, 0.28
function runDrop()
	if dropActive then return end
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local mode = tonumber(St.dropMode) or 2
	if mode == 1 then
 -- Stand / Fling style burst
 dropActive = true
 local t0 = tick()
 local conn
 conn = RS.Heartbeat:Connect(function()
 if not dropActive or tick() - t0 > 0.25 then
 if conn then conn:Disconnect() end
 dropActive = false
 if root and root.Parent then
 root.AssemblyLinearVelocity = Vector3.zero
 end
 return
 end
 local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not r then return end
 local v = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
 r.AssemblyLinearVelocity = v * 10000 + Vector3.new(0, 10000, 0)
 end)
 return
	end
	-- Jump ascend
	dropActive = true
	local t0 = tick()
	local conn
	conn = RS.Heartbeat:Connect(function()
 local c = LP.Character
 local r = c and c:FindFirstChild("HumanoidRootPart")
 if not r or not dropActive then
 if conn then conn:Disconnect() end
 dropActive = false
 return
 end
 if tick() - t0 >= DROP_DUR then
 if conn then conn:Disconnect() end
 local rp = RaycastParams.new()
 rp.FilterDescendantsInstances = { c }
 rp.FilterType = Enum.RaycastFilterType.Exclude
 local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
 if rr then
 local h2 = c:FindFirstChildOfClass("Humanoid")
 local off = ((h2 and h2.HipHeight) or 2) + (r.Size.Y / 2)
 r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
 end
 r.AssemblyLinearVelocity = Vector3.zero
 r.AssemblyAngularVelocity = Vector3.zero
 dropActive = false
 return
 end
 r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, DROP_SPD, r.AssemblyLinearVelocity.Z)
	end)
end

----------------------------------------------------------------
-- INSTA RESET V1 / V2 (Vis; V1 camera lock removed)
----------------------------------------------------------------
local _resetBusy = false
local _resetCD = false
local INST_V2_POS = CFrame.new(2000.5, 9911.9, 4000.2)
-- INSTA RESET V2 — adapted LaPeak/VX7 reset core
local _VX7IR = {
    busy = false,
    character = nil,
    respawnConn = nil,
    token = nil,
    collisions = {},
}

_G._AdaptInstantResetBusy = false
_G.AdaptInstantResetInProgress = false
_G.AdaptInstantResetVersion = 2

local function _VX7IRSetButton(on)
    local e = actRefs and actRefs.insta
    if e and e.btn then
        pcall(function()
            applyActBtnState(e.btn, on == true, "INSTA\nRESET", "INSTA\nRESET")
        end)
    end
end

local function _VX7IRClearVelocity(root)
    if not root then return end
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

_VX7IR.finish = function(newHumanoid)
    if _VX7IR.respawnConn then
        pcall(function() _VX7IR.respawnConn:Disconnect() end)
        _VX7IR.respawnConn = nil
    end

    for part, oldCanCollide in pairs(_VX7IR.collisions) do
        if part and part.Parent then
            pcall(function() part.CanCollide = oldCanCollide end)
        end
    end
    _VX7IR.collisions = {}

    local character = LP.Character
    local humanoid = newHumanoid or (character and character:FindFirstChildOfClass("Humanoid"))
    local camera = workspace.CurrentCamera
    if camera then
        pcall(function()
            if humanoid then camera.CameraSubject = humanoid end
            camera.CameraType = Enum.CameraType.Custom
        end)
    end

    _VX7IR.busy = false
    _VX7IR.character = nil
    _VX7IR.token = nil
    _G._AdaptInstantResetBusy = false
    _G.AdaptInstantResetInProgress = false
    _resetBusy = false
    _resetCD = false
    _VX7IRSetButton(false)
end

_G.AdaptInstantReset = function()
    if _VX7IR.busy then return end

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local token = {}
    _VX7IR.busy = true
    _VX7IR.character = character
    _VX7IR.token = token
    _G._AdaptInstantResetBusy = true
    _G.AdaptInstantResetInProgress = true
    _G.AdaptInstantResetVersion = 2
    _resetBusy = true
    _VX7IRSetButton(true)

    _VX7IR.respawnConn = LP.CharacterAdded:Connect(function(newCharacter)
        local conn = _VX7IR.respawnConn
        _VX7IR.respawnConn = nil
        if conn then pcall(function() conn:Disconnect() end) end

        task.wait(0.1)
        local newHumanoid = newCharacter:WaitForChild("Humanoid", 3)
        if _VX7IR.token ~= token then return end
        _VX7IR.finish(newHumanoid)
    end)

    local ok, err = pcall(function()
        local camera = workspace.CurrentCamera
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = camera.CFrame
        end

        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                _VX7IR.collisions[descendant] = descendant.CanCollide
                descendant.CanCollide = false
            end
        end

        _VX7IRClearVelocity(root)

        if sethiddenproperty then
            pcall(sethiddenproperty, root, "PhysicsRepRootPart", nil)
        end

        root.AssemblyLinearVelocity = Vector3.new(0, 3000000, 0)
    end)

    if not ok then
        _VX7IR.finish()
        warn("LaPeak/VX7 Insta Reset: " .. tostring(err))
        return
    end

    task.delay(5, function()
        if _VX7IR.token ~= token then return end
        if LP.Character == character and root.Parent then
            _VX7IRClearVelocity(root)
        end
        _VX7IR.finish()
    end)
end

_G.AdaptStopInstantReset = function()
    if not _VX7IR.busy then return end
    local token = _VX7IR.token
    _VX7IR.token = nil
    if _VX7IR.respawnConn then
        pcall(function() _VX7IR.respawnConn:Disconnect() end)
        _VX7IR.respawnConn = nil
    end
    if token then _VX7IR.finish() end
end

_G.AdaptGetInstantResetState = function()
    return _VX7IR.busy == true
end

LP.CharacterAdded:Connect(function(character)
    if not _VX7IR.busy then return end
    local token = _VX7IR.token
    _VX7IR.token = nil
    if _VX7IR.respawnConn then
        pcall(function() _VX7IR.respawnConn:Disconnect() end)
        _VX7IR.respawnConn = nil
    end
    if token then
        task.defer(function()
            if LP.Character == character then
                _VX7IR.finish(character:FindFirstChildOfClass("Humanoid"))
            end
        end)
    end
end)

function InstaResetV2()
    _G.AdaptInstantReset()
end

-- CHILLI FAST RESET — manual Fast Reset core ported from Chilli.
-- Auto Fast Reset and Auto Reset Balloon are intentionally removed. Legacy V1 now dispatches here; V2 remains unchanged.
local ChilliFastReset = {
    alive = true,
    autoEnabled = false,
    balloonEnabled = false,
    busy = false,
    generation = 0,
    characterConnections = {},
    resetConnection = nil,
    characterConnection = nil,
    runtimeFolder = nil,
    shared = { ProtectedHumanoid = nil, RescueSerial = 0 },
}

local ChilliFastResetCoreGui = game:GetService("CoreGui")
local oldFastResetRuntime = ChilliFastResetCoreGui:FindFirstChild("__12HubChilliFastResetRuntime")
if oldFastResetRuntime then
    local oldCleanup = oldFastResetRuntime:FindFirstChild("Cleanup")
    if oldCleanup and oldCleanup:IsA("BindableEvent") then
        pcall(function() oldCleanup:Fire() end)
    end
    pcall(function() oldFastResetRuntime:Destroy() end)
end
local fastResetRuntime = Instance.new("Folder")
fastResetRuntime.Name = "__12HubChilliFastResetRuntime"
fastResetRuntime.Archivable = false
fastResetRuntime.Parent = ChilliFastResetCoreGui
local fastResetCleanupEvent = Instance.new("BindableEvent")
fastResetCleanupEvent.Name = "Cleanup"
fastResetCleanupEvent.Parent = fastResetRuntime
ChilliFastReset.runtimeFolder = fastResetRuntime

local function fastResetDisconnectList(list)
    for _, connection in ipairs(list) do
        if typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
    end
    table.clear(list)
end

local function fastResetDisconnectCharacterListeners()
    fastResetDisconnectList(ChilliFastReset.characterConnections)
end

local function fastResetIsDropActive()
    return LP:GetAttribute("ChilliDropBrainrotActive") == true
end

startChilliFastReset = function(character, allowDead)
    if not ChilliFastReset.alive or ChilliFastReset.busy then return false end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or character ~= LP.Character or not humanoid or (not allowDead and humanoid.Health <= 0) then
        return false
    end
    if fastResetIsDropActive() then return false end

    local suspended = false
    local bridge = rawget(_G, "tbl")
    if type(bridge) == "table" and type(bridge.SuspendForReset) == "function" then
        local ok, result = pcall(bridge.SuspendForReset, character)
        suspended = ok and result == true
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        if suspended and type(bridge) == "table" and type(bridge.ResumeIfRequested) == "function" then
            pcall(bridge.ResumeIfRequested, character)
        end
        return false
    end

    ChilliFastReset.busy = true
    ChilliFastReset.generation += 1
    local runGeneration = ChilliFastReset.generation
    ChilliFastReset.shared.ProtectedHumanoid = humanoid

    local originalCFrame = root.CFrame
    local originalLinearVelocity = root.AssemblyLinearVelocity
    local originalAngularVelocity = root.AssemblyAngularVelocity
    local originalHealth = humanoid.Health
    local originalDeadStateEnabled = true
    pcall(function()
        originalDeadStateEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        if humanoid.Health <= 0 then
            humanoid.Health = math.max(humanoid.MaxHealth, 1)
        end
    end)

    local healthConnection = humanoid.HealthChanged:Connect(function(health)
        if ChilliFastReset.alive and ChilliFastReset.busy
            and ChilliFastReset.generation == runGeneration
            and LP.Character == character and health <= 0 then
            pcall(function()
                humanoid.Health = math.max(humanoid.MaxHealth, originalHealth, 1)
            end)
        end
    end)
    ChilliFastReset.resetConnection = healthConnection

    task.spawn(function()
        local targetCFrame = originalCFrame + Vector3.new(0, 31000, 0)
        while ChilliFastReset.alive and ChilliFastReset.busy
            and ChilliFastReset.generation == runGeneration and LP.Character == character do
            if root.Parent then
                pcall(function() root.CFrame = targetCFrame end)
            end
            if humanoid.Parent and humanoid.Health <= 0 then
                pcall(function()
                    humanoid.Health = math.max(humanoid.MaxHealth, originalHealth, 1)
                end)
            end
            task.wait()
        end

        pcall(function() healthConnection:Disconnect() end)
        if ChilliFastReset.resetConnection == healthConnection then
            ChilliFastReset.resetConnection = nil
        end
        local characterChanged = LP.Character ~= character
        if not characterChanged then
            if root.Parent then
                pcall(function()
                    root.CFrame = originalCFrame
                    root.AssemblyLinearVelocity = originalLinearVelocity
                    root.AssemblyAngularVelocity = originalAngularVelocity
                end)
            end
            if humanoid.Parent then
                pcall(function()
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, originalDeadStateEnabled)
                    if originalHealth > 0 and humanoid.Health <= 0 then
                        humanoid.Health = originalHealth
                    end
                end)
            end
        end
        if ChilliFastReset.generation == runGeneration then
            ChilliFastReset.busy = false
            ChilliFastReset.shared.ProtectedHumanoid = nil
        end
    end)
    return true
end

function ChilliFastResetNow()
    return startChilliFastReset(LP.Character, false)
end

local function fastResetCleanup()
    if not ChilliFastReset.alive then return end
    ChilliFastReset.alive = false
    ChilliFastReset.autoEnabled = false
    ChilliFastReset.generation += 1
    ChilliFastReset.busy = false
    fastResetDisconnectCharacterListeners()
    ChilliFastReset.shared.ProtectedHumanoid = nil
    if ChilliFastReset.resetConnection then
        pcall(function() ChilliFastReset.resetConnection:Disconnect() end)
        ChilliFastReset.resetConnection = nil
    end
end

fastResetCleanupEvent.Event:Connect(fastResetCleanup)
fastResetRuntime.Destroying:Connect(fastResetCleanup)
_G.__12HubFastResetCleanup = fastResetCleanup

function doInstaReset()
    local mode = tostring(St.instaMode or "Fast Reset")
    if mode == "V2" then
        InstaResetV2()
    else
        ChilliFastResetNow()
    end
end

----------------------------------------------------------------
-- TP DOWN (Vis)
----------------------------------------------------------------
function doTPDown(force)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end
	if not force then
 if hum.FloorMaterial ~= Enum.Material.Air then return end
 if hrp.Position.Y < 20 then return end
	end
	hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z)
 * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
	hrp.AssemblyLinearVelocity = Vector3.zero
end

----------------------------------------------------------------
-- ESP + TRACER + ANTI LAG
----------------------------------------------------------------
local ESP = { on = false, data = {}, conns = {} }
function espCleanup(plr)
	local d = ESP.data[plr]
	if not d then return end
	pcall(function() if d.hl then d.hl:Destroy() end end)
	pcall(function() if d.bb then d.bb:Destroy() end end)
	pcall(function() if d.tracer then d.tracer:Remove() end end)
	ESP.data[plr] = nil
end
function espSetup(plr, char)
	if not ESP.on or plr == LP or not char then return end
	espCleanup(plr)
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
	local head = char:FindFirstChild("Head")
	if not hrp then return end
	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.FillColor = Color3.fromRGB(35, 35, 35)
	hl.FillTransparency = 0.7
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
	local bb, tracer
	if head then
 bb = Instance.new("BillboardGui")
 bb.Adornee = head
 bb.Size = UDim2.new(0, 100, 0, 20)
 bb.StudsOffset = Vector3.new(0, 2.5, 0)
 bb.AlwaysOnTop = true
 bb.Parent = head
 local t = Instance.new("TextLabel", bb)
 t.Size = UDim2.new(1, 0, 1, 0)
 t.BackgroundTransparency = 1
 t.Text = plr.DisplayName or plr.Name
 t.TextColor3 = Color3.new(1, 1, 1)
 t.TextSize = 12
 t.Font = Enum.Font.GothamBold
 t.TextStrokeTransparency = 0.5
	end
	if St.tracer then
 tracer = Drawing and Drawing.new and Drawing.new("Line")
 if tracer then
 tracer.Thickness = 1
 tracer.Color = Color3.fromRGB(255, 255, 255)
 tracer.Visible = true
 end
	end
	ESP.data[plr] = { hl = hl, bb = bb, tracer = tracer, hrp = hrp }
end
function startESP()
	if ESP.on then return end
	ESP.on = true
	for _, plr in ipairs(Players:GetPlayers()) do
 if plr ~= LP and plr.Character then espSetup(plr, plr.Character) end
 table.insert(ESP.conns, plr.CharacterAdded:Connect(function(c)
 task.defer(espSetup, plr, c)
 end))
	end
	table.insert(ESP.conns, Players.PlayerAdded:Connect(function(plr)
 table.insert(ESP.conns, plr.CharacterAdded:Connect(function(c)
 task.defer(espSetup, plr, c)
 end))
	end))
	table.insert(ESP.conns, RS.RenderStepped:Connect(function()
 if not St.tracer then return end
 local cam = workspace.CurrentCamera
 local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not cam or not my then return end
 local origin = cam:WorldToViewportPoint(my.Position)
 for plr, d in pairs(ESP.data) do
 if d.tracer and d.hrp and d.hrp.Parent then
 local p, onScreen = cam:WorldToViewportPoint(d.hrp.Position)
 d.tracer.From = Vector2.new(origin.X, origin.Y)
 d.tracer.To = Vector2.new(p.X, p.Y)
 d.tracer.Visible = onScreen and p.Z > 0
 elseif d.tracer then
 d.tracer.Visible = false
 end
 end
	end))
end
function stopESP()
	ESP.on = false
	for _, c in ipairs(ESP.conns) do pcall(function() c:Disconnect() end) end
	ESP.conns = {}
	for plr in pairs(ESP.data) do espCleanup(plr) end
end
function setESP(on)
	St.esp = on
	if on then startESP() else stopESP() end
	saveCfg()
end
function setTracer(on)
	St.tracer = on
	if St.esp then stopESP(); startESP() end
	saveCfg()
end

-- Anti Lag (full implementation from source file 2)
antiLagVisualEnabled = St.antiLag == true
_G.AdaptZombieAntiLag = _G.AdaptZombieAntiLag or {
    conn=nil,
    active=false,
    defBrightness=nil,
    defFog=nil,
    defDiffuse=nil,
    defSpecular=nil,
}

function _applyAntiLagObj(obj)
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Fire")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _,tr in ipairs(obj:GetPlayingAnimationTracks()) do
                pcall(function() tr:Stop(0) end)
            end
        end
    end)
end

function enableAntiLag()
    antiLagVisualEnabled = true
    local S = _G.AdaptZombieAntiLag
    if S.active == true and S.conn and S.conn.Connected then return end
    S.active = true
    S.defBrightness = S.defBrightness or Lighting.Brightness
    S.defFog = S.defFog or Lighting.FogEnd
    S.defDiffuse = S.defDiffuse or Lighting.EnvironmentDiffuseScale
    S.defSpecular = S.defSpecular or Lighting.EnvironmentSpecularScale

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    for _,e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect")
                or e:IsA("SunRaysEffect")
                or e:IsA("ColorCorrectionEffect")
                or e:IsA("BloomEffect")
                or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end)
    end

    if S.conn then S.conn:Disconnect() end
    S.conn = workspace.DescendantAdded:Connect(function(obj)
        if S.active then _applyAntiLagObj(obj) end
    end)
    antiLagDescConn = S.conn
    S.scanGeneration = (tonumber(S.scanGeneration) or 0) + 1
    local scanGeneration = S.scanGeneration
    local scanItems = workspace:GetDescendants()
    task.spawn(function()
        for index, obj in ipairs(scanItems) do
            if not S.active or S.scanGeneration ~= scanGeneration then return end
            _applyAntiLagObj(obj)
            if index % 160 == 0 then task.wait() end
        end
    end)
end

function disableAntiLag()
    antiLagVisualEnabled = false
    local S = _G.AdaptZombieAntiLag
    S.active = false
    S.scanGeneration = (tonumber(S.scanGeneration) or 0) + 1

    if S.conn then
        S.conn:Disconnect()
        S.conn = nil
    end
    antiLagDescConn = nil

    pcall(function()
        Lighting.GlobalShadows = true
        if S.defBrightness then Lighting.Brightness = S.defBrightness end
        if S.defFog then Lighting.FogEnd = S.defFog end
        if S.defDiffuse then Lighting.EnvironmentDiffuseScale = S.defDiffuse end
        if S.defSpecular then Lighting.EnvironmentSpecularScale = S.defSpecular end

        for _,e in pairs(Lighting:GetChildren()) do
            pcall(function()
                if e:IsA("BlurEffect")
                    or e:IsA("SunRaysEffect")
                    or e:IsA("ColorCorrectionEffect")
                    or e:IsA("BloomEffect")
                    or e:IsA("DepthOfFieldEffect") then
                    e.Enabled = true
                end
            end)
        end
    end)
end

-- Compatibility alias for any legacy caller.
function applyDerender(obj)
    _applyAntiLagObj(obj)
end

function setAntiLag(on)
    St.antiLag = on == true
    if St.antiLag then
        enableAntiLag()
    else
        disableAntiLag()
    end
    saveCfg()
end


-- Nuke Optimize (full implementation from source file 2).
-- This feature can remove clothing/textures and some map objects; it is OFF by default.
V = V or {}
nukeOptimiserEnabled = St.nukeOptimiserEnabled == true
_nukeOptimizerOn = false
_nukeOptimizerGeneration = 0
_nukeOptimizerConns = {}
_nukeOptimizerThreads = {}
function enableNukeOptimizer()
if _nukeOptimizerOn then return end
_nukeOptimizerGeneration = (tonumber(_nukeOptimizerGeneration) or 0) + 1
local nukeGeneration = _nukeOptimizerGeneration
_nukeOptimizerOn = true
nukeOptimiserEnabled = true
V.nukeOptEnabled = true
local MaterialService = game:GetService("MaterialService")
local nukePendingQueue = {}
local nukePendingQueued = setmetatable({}, { __mode = "k" })
local nukePendingHead, nukePendingTail = 1, 0
local nukePendingWorker = false
local function processNukeAddedObject(obj)
if not _nukeOptimizerOn or nukeGeneration ~= _nukeOptimizerGeneration or not obj then return end
if IsBase(obj) then
MakeTransparent(obj)
elseif IsClothing(obj) then
SafeDestroy(obj)
elseif IsInBase(obj) then
elseif IsCharacterPart(obj) then
elseif IsOutOfRange(obj) then
SafeDestroy(obj)
else
CleanObject(obj)
StripObject(obj)
end
end
local function queueNukeAddedObject(obj)
if not _nukeOptimizerOn or nukeGeneration ~= _nukeOptimizerGeneration or not obj then return end
if nukePendingQueued[obj] then return end
nukePendingQueued[obj] = true
nukePendingTail = nukePendingTail + 1
nukePendingQueue[nukePendingTail] = obj
if nukePendingWorker then return end
nukePendingWorker = true
table.insert(_nukeOptimizerThreads, task.spawn(function()
while _nukeOptimizerOn and nukeGeneration == _nukeOptimizerGeneration and nukePendingHead <= nukePendingTail do
local sliceStarted = os.clock()
local processed = 0
while _nukeOptimizerOn and nukeGeneration == _nukeOptimizerGeneration and nukePendingHead <= nukePendingTail and processed < 30 and (os.clock() - sliceStarted) < 0.0015 do
local queuedObject = nukePendingQueue[nukePendingHead]
nukePendingQueue[nukePendingHead] = nil
nukePendingHead = nukePendingHead + 1
if queuedObject then
nukePendingQueued[queuedObject] = nil
processNukeAddedObject(queuedObject)
end
processed = processed + 1
end
task.wait()
end
nukePendingQueue = {}
nukePendingQueued = setmetatable({}, { __mode = "k" })
nukePendingHead, nukePendingTail = 1, 0
nukePendingWorker = false
end))
end
local XMin, XMax = -560, -240
local ClothingClasses = {"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
local BASE_NAMES = {"baseplate","spawnlocation","spawn location","spawn"}
function SafeDestroy(obj)
if obj and obj.Name == "Overhead" then return end
pcall(function() obj:Destroy() end)
end
function IsClothing(obj)
for _, className in ipairs(ClothingClasses) do
if obj:IsA(className) then return true end
end
return false
end
function IsCharacterPart(obj)
if not obj then return false end
local ancestor = obj
while ancestor and ancestor ~= workspace do
    if ancestor:IsA("Model") and Players:GetPlayerFromCharacter(ancestor) then return true end
    ancestor = ancestor.Parent
end
return false
end
function IsOutOfRange(obj)
if obj:IsA("BasePart") then
local x = obj.Position.X
return x < XMin or x > XMax
end
return false
end
function IsBase(obj)
if not obj:IsA("BasePart") then return false end
local nl = obj.Name:lower()
for _, n in ipairs(BASE_NAMES) do
if nl:find(n, 1, true) then return true end
end
return false
end
function IsInBase(obj)
local p = obj.Parent
while p and p ~= workspace do
if IsBase(p) then return true end
p = p.Parent
end
return false
end
function MakeTransparent(obj)
pcall(function()
if IsBase(obj) and not IsCharacterPart(obj) then
obj.Transparency = 1
obj.CastShadow = false
end
end)
end
function StripObject(obj)
pcall(function()
if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
SafeDestroy(obj)
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
pcall(function() obj.Enabled = false end)
SafeDestroy(obj)
elseif obj:IsA("SurfaceAppearance") then
SafeDestroy(obj)
elseif obj:IsA("BasePart") then
obj.CastShadow = false
obj.Material = Enum.Material.Plastic
obj.MaterialVariant = ""
obj.Reflectance = 0
end
end)
end
function CleanObject(obj)
pcall(function()
if obj:IsA("SurfaceAppearance") then
SafeDestroy(obj)
elseif obj:IsA("Decal") or obj:IsA("Texture") then
if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then SafeDestroy(obj) end
elseif obj:IsA("SpecialMesh") then
obj.TextureId = ""
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
SafeDestroy(obj)
elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
SafeDestroy(obj)
elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
SafeDestroy(obj)
elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
SafeDestroy(obj)
elseif obj:IsA("BasePart") then
obj.CastShadow = false
obj.Material = Enum.Material.Plastic
obj.MaterialVariant = ""
obj.Reflectance = 0
end
end)
end
function ApplyGreySky()
pcall(function()
for _, obj in ipairs(Lighting:GetChildren()) do
if obj:IsA("Sky") then obj:Destroy() end
end
local sky = Instance.new("Sky")
sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
sky.CelestialBodiesShown = false
sky.Name = "_AdaptDuelsNukeSky"
sky.Parent = Lighting
end)
end
function OptimizeLighting()
pcall(function()
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.FogStart = 9e9
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.Brightness = 1.5
Lighting.Ambient = Color3.fromRGB(60,60,60)
for _, v in ipairs(Lighting:GetChildren()) do
if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
v:Destroy()
end
end
ApplyGreySky()
end)
end
function ApplyTerrain()
pcall(function()
local terrain = workspace:FindFirstChildOfClass("Terrain")
if terrain then
terrain.Decoration = false
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 1
end
end)
end
function OptimizeCharacter(char)
if not char then return end
local generation = _nukeOptimizerGeneration
task.spawn(function()
task.wait(0.3)
if not _nukeOptimizerOn or generation ~= _nukeOptimizerGeneration then return end
for _, obj in ipairs(char:GetDescendants()) do
if not _nukeOptimizerOn or generation ~= _nukeOptimizerGeneration then return end
if IsClothing(obj) then SafeDestroy(obj) else CleanObject(obj) end
end
end)
end
pcall(function()
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
end)
-- FPS cap is managed only by setFPSCap / the FPS Cap slider (Chilli behavior).
table.insert(_nukeOptimizerThreads, task.spawn(function()
if not game:IsLoaded() then game.Loaded:Wait() end
OptimizeLighting()
ApplyTerrain()
local optimizerItems = workspace:GetDescendants()
local sliceStarted = os.clock()
local sliceCount = 0
for _, obj in ipairs(optimizerItems) do
if not _nukeOptimizerOn or nukeGeneration ~= _nukeOptimizerGeneration then return end
processNukeAddedObject(obj)
sliceCount = sliceCount + 1
if sliceCount >= 50 or (os.clock() - sliceStarted) >= 0.0015 then
 task.wait()
 sliceStarted = os.clock()
 sliceCount = 0
end
end
end))
table.insert(_nukeOptimizerConns, workspace.DescendantAdded:Connect(function(obj)
queueNukeAddedObject(obj)
end))
table.insert(_nukeOptimizerConns, Lighting.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then SafeDestroy(obj) end
end))
table.insert(_nukeOptimizerConns, MaterialService.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
SafeDestroy(obj)
end))
for _, plr in ipairs(Players:GetPlayers()) do
OptimizeCharacter(plr.Character)
table.insert(_nukeOptimizerConns, plr.CharacterAdded:Connect(OptimizeCharacter))
end
table.insert(_nukeOptimizerConns, Players.PlayerAdded:Connect(function(plr)
table.insert(_nukeOptimizerConns, plr.CharacterAdded:Connect(OptimizeCharacter))
end))
end
function disableNukeOptimizer()
_nukeOptimizerOn = false
_nukeOptimizerGeneration = (tonumber(_nukeOptimizerGeneration) or 0) + 1
nukeOptimiserEnabled = false
V.nukeOptEnabled = false
for _, c in ipairs(_nukeOptimizerConns) do pcall(function() c:Disconnect() end) end
_nukeOptimizerConns = {}
_nukeOptimizerThreads = {}
end

function setNukeOptimizer(on)
    St.nukeOptimiserEnabled = on == true
    nukeOptimiserEnabled = St.nukeOptimiserEnabled
    if St.nukeOptimiserEnabled then
        enableNukeOptimizer()
    else
        disableNukeOptimizer()
    end
    saveCfg()
end


do -- Chilli FPS Cap + Optimizer module scope.
----------------------------------------------------------------
-- CHILLIHUB FPS CAP (30..1000) + RESTORABLE OPTIMIZER
----------------------------------------------------------------
local fpsCapUnavailableWarned = false
function setFPSCap(value, shouldSave)
    local cap = math.clamp(math.floor(tonumber(value) or 240), 30, 1000)
    St.fpsCap = cap
    local supported = false
    if type(setfpscap) == "function" then
        local ok = pcall(setfpscap, cap)
        supported = ok
    end
    if not supported and not fpsCapUnavailableWarned then
        fpsCapUnavailableWarned = true
        warn("[12Hub] FPS Cap is unavailable in this executor (setfpscap missing or failed).")
    end
    if shouldSave ~= false then autoSaveDebounced() end
    return supported
end

local ChilliOptimizer = {
    enabled = false,
    generation = 0,
    connections = {},
    savedProperties = setmetatable({}, { __mode = "k" }),
    restoreGlobals = {},
    pendingQueue = {},
    pendingQueued = setmetatable({}, { __mode = "k" }),
    pendingHead = 1,
    pendingTail = 0,
    queueWorkerRunning = false,
    queueWorkerGeneration = 0,
}

local function chilliOptimizerSetProperty(instance, propertyName, newValue)
    if not instance then return end
    local record = ChilliOptimizer.savedProperties[instance]
    if not record then
        record = {}
        ChilliOptimizer.savedProperties[instance] = record
    end
    if record[propertyName] == nil then
        local ok, oldValue = pcall(function() return instance[propertyName] end)
        if not ok then return end
        record[propertyName] = { value = oldValue, changed = false }
    end
    local propertyRecord = record[propertyName]
    local ok = pcall(function() instance[propertyName] = newValue end)
    if ok then propertyRecord.changed = true end
end

local function chilliOptimizerSetGlobal(getter, setter, newValue)
    local ok, oldValue = pcall(getter)
    if not ok then return end
    table.insert(ChilliOptimizer.restoreGlobals, function()
        pcall(setter, oldValue)
    end)
    pcall(setter, newValue)
end

local function chilliOptimizerApplyObject(instance, generation)
    if not ChilliOptimizer.enabled or generation ~= ChilliOptimizer.generation or not instance then
        return
    end
    pcall(function()
        if instance:IsA("ParticleEmitter") then
            chilliOptimizerSetProperty(instance, "Enabled", false)
            chilliOptimizerSetProperty(instance, "Rate", 0)
        elseif instance:IsA("Trail") or instance:IsA("Beam") then
            chilliOptimizerSetProperty(instance, "Enabled", false)
        elseif instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") then
            chilliOptimizerSetProperty(instance, "Enabled", false)
            chilliOptimizerSetProperty(instance, "Brightness", 0)
        elseif instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") then
            chilliOptimizerSetProperty(instance, "Enabled", false)
        elseif instance:IsA("Explosion") then
            chilliOptimizerSetProperty(instance, "Visible", false)
        elseif instance:IsA("SpecialMesh") then
            chilliOptimizerSetProperty(instance, "TextureId", "")
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            if not (instance.Name == "face" and instance.Parent and instance.Parent.Name == "Head") then
                chilliOptimizerSetProperty(instance, "Transparency", 1)
            end
        elseif instance:IsA("BasePart") then
            chilliOptimizerSetProperty(instance, "CastShadow", false)
            chilliOptimizerSetProperty(instance, "Material", Enum.Material.Plastic)
            chilliOptimizerSetProperty(instance, "Reflectance", 0)
        elseif instance:IsA("PostEffect") then
            chilliOptimizerSetProperty(instance, "Enabled", false)
        elseif instance:IsA("Atmosphere") then
            chilliOptimizerSetProperty(instance, "Density", 0)
            chilliOptimizerSetProperty(instance, "Haze", 0)
            chilliOptimizerSetProperty(instance, "Glare", 0)
        end
    end)
end

local function chilliOptimizerQueueObject(instance, generation)
    if not instance or not ChilliOptimizer.enabled or generation ~= ChilliOptimizer.generation then return end
    if ChilliOptimizer.pendingQueued[instance] == generation then return end
    ChilliOptimizer.pendingQueued[instance] = generation
    ChilliOptimizer.pendingTail = ChilliOptimizer.pendingTail + 1
    ChilliOptimizer.pendingQueue[ChilliOptimizer.pendingTail] = { instance = instance, generation = generation }

    if ChilliOptimizer.queueWorkerRunning and ChilliOptimizer.queueWorkerGeneration == generation then return end
    ChilliOptimizer.queueWorkerRunning = true
    ChilliOptimizer.queueWorkerGeneration = generation
    task.spawn(function()
        while ChilliOptimizer.enabled and ChilliOptimizer.generation == generation do
            local sliceStarted = os.clock()
            local processed = 0
            while ChilliOptimizer.enabled
                and ChilliOptimizer.pendingHead <= ChilliOptimizer.pendingTail
                and ChilliOptimizer.generation == generation
                and processed < 40
                and (os.clock() - sliceStarted) < 0.0015 do
                local item = ChilliOptimizer.pendingQueue[ChilliOptimizer.pendingHead]
                ChilliOptimizer.pendingQueue[ChilliOptimizer.pendingHead] = nil
                ChilliOptimizer.pendingHead = ChilliOptimizer.pendingHead + 1
                if item then
                    if ChilliOptimizer.pendingQueued[item.instance] == item.generation then
                        ChilliOptimizer.pendingQueued[item.instance] = nil
                    end
                    if item.generation == ChilliOptimizer.generation then
                        chilliOptimizerApplyObject(item.instance, item.generation)
                    end
                end
                processed = processed + 1
            end
            if ChilliOptimizer.pendingHead > ChilliOptimizer.pendingTail then
                ChilliOptimizer.pendingQueue = {}
                ChilliOptimizer.pendingHead = 1
                ChilliOptimizer.pendingTail = 0
                break
            end
            RS.Heartbeat:Wait()
        end
        if ChilliOptimizer.queueWorkerGeneration == generation then
            ChilliOptimizer.queueWorkerRunning = false
            ChilliOptimizer.queueWorkerGeneration = 0
        end
    end)
end

local function chilliOptimizerRestore()
    ChilliOptimizer.enabled = false
    ChilliOptimizer.generation = ChilliOptimizer.generation + 1
    for _, connection in ipairs(ChilliOptimizer.connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(ChilliOptimizer.connections)

    ChilliOptimizer.pendingQueue = {}
    ChilliOptimizer.pendingQueued = setmetatable({}, { __mode = "k" })
    ChilliOptimizer.pendingHead = 1
    ChilliOptimizer.pendingTail = 0

    local restoredCount = 0
    local restoreSliceStarted = os.clock()
    for instance, propertyMap in pairs(ChilliOptimizer.savedProperties) do
        if instance and instance.Parent then
            for propertyName, savedRecord in pairs(propertyMap) do
                if savedRecord.changed then
                    pcall(function() instance[propertyName] = savedRecord.value end)
                end
            end
        end
        restoredCount = restoredCount + 1
        -- Match Chilli's batched cleanup so disabling the feature does not freeze the UI.
        if restoredCount % 50 == 0 or (os.clock() - restoreSliceStarted) >= 0.0015 then
            pcall(function() RS.Heartbeat:Wait() end)
            restoreSliceStarted = os.clock()
        end
    end
    ChilliOptimizer.savedProperties = setmetatable({}, { __mode = "k" })

    for index = #ChilliOptimizer.restoreGlobals, 1, -1 do
        pcall(ChilliOptimizer.restoreGlobals[index])
    end
    table.clear(ChilliOptimizer.restoreGlobals)
end

local function chilliOptimizerStart()
    if ChilliOptimizer.enabled then return end
    ChilliOptimizer.enabled = true
    ChilliOptimizer.generation = ChilliOptimizer.generation + 1
    local generation = ChilliOptimizer.generation

    local rendering = nil
    local terrain = nil
    pcall(function() rendering = settings().Rendering end)
    pcall(function() terrain = Workspace.Terrain end)

    if rendering then
        chilliOptimizerSetGlobal(function() return rendering.QualityLevel end, function(value) rendering.QualityLevel = value end, Enum.QualityLevel.Level01)
        chilliOptimizerSetGlobal(function() return rendering.MeshPartDetailLevel end, function(value) rendering.MeshPartDetailLevel = value end, Enum.MeshPartDetailLevel.Level01)
        pcall(function()
            chilliOptimizerSetGlobal(function() return rendering.EditQualityLevel end, function(value) rendering.EditQualityLevel = value end, Enum.QualityLevel.Level01)
        end)
    end

    chilliOptimizerSetGlobal(function() return Workspace.StreamingEnabled end, function(value) Workspace.StreamingEnabled = value end, true)
    chilliOptimizerSetGlobal(function() return Workspace.StreamingMinRadius end, function(value) Workspace.StreamingMinRadius = value end, 64)
    chilliOptimizerSetGlobal(function() return Workspace.StreamingTargetRadius end, function(value) Workspace.StreamingTargetRadius = value end, 256)
    pcall(function()
        chilliOptimizerSetGlobal(function() return Workspace.StreamingIntegrityMode end, function(value) Workspace.StreamingIntegrityMode = value end, Enum.StreamingIntegrityMode.MinimumRadiusPause)
    end)

    chilliOptimizerSetGlobal(function() return Lighting.GlobalShadows end, function(value) Lighting.GlobalShadows = value end, false)
    chilliOptimizerSetGlobal(function() return Lighting.FogEnd end, function(value) Lighting.FogEnd = value end, 9e9)
    pcall(function()
        chilliOptimizerSetGlobal(function() return Lighting.Technology end, function(value) Lighting.Technology = value end, Enum.Technology.Legacy)
    end)
    chilliOptimizerSetGlobal(function() return Lighting.EnvironmentDiffuseScale end, function(value) Lighting.EnvironmentDiffuseScale = value end, 0)
    chilliOptimizerSetGlobal(function() return Lighting.EnvironmentSpecularScale end, function(value) Lighting.EnvironmentSpecularScale = value end, 0)

    if terrain then
        chilliOptimizerSetGlobal(function() return terrain.Decoration end, function(value) terrain.Decoration = value end, false)
        chilliOptimizerSetGlobal(function() return terrain.WaterWaveSize end, function(value) terrain.WaterWaveSize = value end, 0)
        chilliOptimizerSetGlobal(function() return terrain.WaterWaveSpeed end, function(value) terrain.WaterWaveSpeed = value end, 0)
        chilliOptimizerSetGlobal(function() return terrain.WaterReflectance end, function(value) terrain.WaterReflectance = value end, 0)
        chilliOptimizerSetGlobal(function() return terrain.WaterTransparency end, function(value) terrain.WaterTransparency = value end, 1)
    end

    local okCore, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if okCore and coreGui then
        local oldRuntime = coreGui:FindFirstChild("__12HubChilliOptimizerRuntime")
        if oldRuntime then pcall(function() oldRuntime:Destroy() end) end
        local runtimeFolder = Instance.new("Folder")
        runtimeFolder.Name = "__12HubChilliOptimizerRuntime"
        runtimeFolder.Archivable = false
        runtimeFolder.Parent = coreGui
        -- Chilli-compatible cleanup event; use a 12Hub-specific name to avoid cross-script collisions.
        local cleanupEvent = Instance.new("BindableEvent")
        cleanupEvent.Name = "Cleanup"
        cleanupEvent.Parent = runtimeFolder
        ChilliOptimizer.runtimeFolder = runtimeFolder
        ChilliOptimizer.cleanupEvent = cleanupEvent
        table.insert(ChilliOptimizer.connections, cleanupEvent.Event:Connect(function()
            if ChilliOptimizer.enabled then chilliOptimizerRestore() end
        end))
        table.insert(ChilliOptimizer.connections, runtimeFolder.Destroying:Connect(function()
            if ChilliOptimizer.enabled then chilliOptimizerRestore() end
        end))
    end

    table.insert(ChilliOptimizer.connections, Workspace.DescendantAdded:Connect(function(instance)
        if not ChilliOptimizer.enabled or generation ~= ChilliOptimizer.generation then return end
        chilliOptimizerQueueObject(instance, generation)
    end))
    table.insert(ChilliOptimizer.connections, Lighting.DescendantAdded:Connect(function(instance)
        if not ChilliOptimizer.enabled or generation ~= ChilliOptimizer.generation then return end
        chilliOptimizerQueueObject(instance, generation)
    end))

    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        local scans = { Workspace, Lighting }
        for _, container in ipairs(scans) do
            if not ChilliOptimizer.enabled or generation ~= ChilliOptimizer.generation then return end
            local descendants = container:GetDescendants()
            local sliceStarted = os.clock()
            local sliceCount = 0
            for _, instance in ipairs(descendants) do
                if not ChilliOptimizer.enabled or generation ~= ChilliOptimizer.generation then return end
                chilliOptimizerApplyObject(instance, generation)
                sliceCount = sliceCount + 1
                -- Time-budget the startup scan to avoid noticeable frame-time spikes.
                if sliceCount >= 50 or (os.clock() - sliceStarted) >= 0.0015 then
                    RS.Heartbeat:Wait()
                    sliceStarted = os.clock()
                    sliceCount = 0
                end
            end
        end
    end)
end

function setOptimizer(on, skipSave)
    St.optimizerEnabled = on == true
    if St.optimizerEnabled then
        chilliOptimizerStart()
    else
        chilliOptimizerRestore()
        if ChilliOptimizer.runtimeFolder then
            pcall(function() ChilliOptimizer.runtimeFolder:Destroy() end)
            ChilliOptimizer.runtimeFolder = nil
        end
    end
    if not skipSave then saveCfg() end
end
end -- Chilli FPS Cap + Optimizer module scope




----------------------------------------------------------------
-- INFINITE JUMP (Vis BloodHounds hold)
----------------------------------------------------------------
local InfJump = { enabled = false, conn = nil, last = 0 }
-- (InfJump moved above with BloodHounds speed)

-- AUTO DESTROY SENTRY (full from AutoDestroyTurret)
----------------------------------------------------------------
local GTurret = { AutoDestroyTurret = false }
local turretBusy = setmetatable({}, { __mode = "k" })
local turretQueued = setmetatable({}, { __mode = "k" })
local turretCD = setmetatable({}, { __mode = "k" })
local activeTurretAtk = 0
function isEnemyTurret(obj)
	if not obj or not obj:IsA("BasePart") then return false end
	local name, nameLower = obj.Name, obj.Name:lower()
	local ownerId = name:match("^Sentry_(%d+)$") or name:match("^sentry_(%d+)$")
	if not ownerId then
 ownerId = name:match("^CandySentry_(%d+)$") or name:match("^Candy_Sentry_(%d+)$")
 or name:match("^candy_sentry_(%d+)$") or nameLower:match("^candy[_%-]?sentry_(%d+)$")
	end
	if not ownerId and nameLower:find("candy") and nameLower:find("sentry") then
 ownerId = name:match("(%d+)$")
	end
	if not ownerId then ownerId = name:match("^[Tt]urret_(%d+)$") end
	if not ownerId and nameLower:find("sentry") then ownerId = name:match("(%d+)$") end
	return ownerId ~= nil and tostring(ownerId) ~= tostring(LP.UserId)
end
function setTurretNoClip(turret)
	if not isEnemyTurret(turret) then return end
	pcall(function()
 turret.CanCollide = false
 turret.Anchored = true
 turret.AssemblyLinearVelocity = Vector3.zero
 turret.AssemblyAngularVelocity = Vector3.zero
	end)
end
function getTurretTimeLabel(turret)
	if not turret or not turret.Parent then return nil end
	local sf = turret:FindFirstChild("SetupFrame")
	local mf = sf and sf:FindFirstChild("MainFrame")
	local tl = mf and mf:FindFirstChild("Time")
	if tl and tl:IsA("TextLabel") then return tl end
	for _, d in ipairs(turret:GetDescendants()) do
 if d:IsA("TextLabel") then
 local n = d.Name:lower()
 if n == "time" or n == "timer" or n == "countdown" then return d end
 end
	end
	return nil
end
function shouldAttackTurret(turret)
	if LP:GetAttribute("Stealing") ~= nil then return false end
	if not isEnemyTurret(turret) then return false end
	setTurretNoClip(turret)
	local timeLabel = getTurretTimeLabel(turret)
	if timeLabel then
 local ok, text = pcall(function() return timeLabel.Text end)
 if not ok then return false end
 text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
 if text == "" then return false end
 if string.find(text, "^%d+%s*[sS]!?$") or string.find(text, "^%d+$") then return true end
 return false
	end
	return true
end
function bringTurretInFront(turret, hrp)
	if not turret or not hrp then return end
	local forward = hrp.CFrame.LookVector
	local targetPos = hrp.Position + forward * 2.8 + Vector3.new(0, 1.15, 0)
	pcall(function()
 turret.AssemblyLinearVelocity = Vector3.zero
 turret.CFrame = CFrame.lookAt(targetPos, targetPos + forward)
	end)
end
function findBat()
	local char = LP.Character
	if not char then return nil end
	local bat = char:FindFirstChild("Bat") or LP.Backpack:FindFirstChild("Bat")
	if bat then return bat end
	for _, t in ipairs(char:GetChildren()) do
 if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
	end
	for _, t in ipairs(LP.Backpack:GetChildren()) do
 if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
	end
	return nil
end
function ensureBat(hum, char)
	local held = char:FindFirstChildOfClass("Tool")
	if held and (held.Name == "Bat" or held.Name:lower():find("bat")) then return held end
	local bat = findBat()
	if not bat then return nil end
	pcall(function() hum:EquipTool(bat) end)
	return char:FindFirstChild("Bat") or bat
end
function attackTurret(turret)
	local now = os.clock()
	if turretBusy[turret] or turretQueued[turret] then return end
	if activeTurretAtk >= 2 then return end
	if not shouldAttackTurret(turret) then return end
	if (turretCD[turret] or 0) > now then return end
	turretQueued[turret] = true
	turretCD[turret] = now + 0.15
	task.spawn(function()
 turretQueued[turret] = nil
 if activeTurretAtk >= 2 or turretBusy[turret] or not shouldAttackTurret(turret) then return end
 activeTurretAtk = activeTurretAtk + 1
 turretBusy[turret] = true
 pcall(function()
 local attempts, batReady = 0, false
 while attempts < 18 and GTurret.AutoDestroyTurret do
 if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
 local char = LP.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health <= 0 then break end
 local okD, dist = pcall(function() return (turret.Position - hrp.Position).Magnitude end)
 if okD and dist > 250 then break end
 setTurretNoClip(turret)
 bringTurretInFront(turret, hrp)
 local bat
 if not batReady then
 bat = ensureBat(hum, char)
 batReady = bat ~= nil
 else
 bat = char:FindFirstChild("Bat") or findBat()
 local held = char:FindFirstChildOfClass("Tool")
 if held and held.Name ~= "Bat" and not held.Name:lower():find("bat") then break end
 end
 if bat then pcall(function() bat:Activate() end) end
 attempts = attempts + 1
 task.wait(0.045)
 end
 end)
 turretBusy[turret] = nil
 activeTurretAtk = math.max(0, activeTurretAtk - 1)
	end)
end
workspace.DescendantAdded:Connect(function(obj)
	if isEnemyTurret(obj) then setTurretNoClip(obj) end
	if GTurret.AutoDestroyTurret and shouldAttackTurret(obj) then task.defer(attackTurret, obj) end
end)
task.spawn(function()
	while task.wait(0.25) do
 if GTurret.AutoDestroyTurret then
 local pending = {}
 for _, obj in ipairs(workspace:GetDescendants()) do
 if isEnemyTurret(obj) then
 setTurretNoClip(obj)
 if shouldAttackTurret(obj) and not turretBusy[obj] then
 table.insert(pending, obj)
 end
 end
 end
 local char = LP.Character
 local hrp = char and char:FindFirstChild("HumanoidRootPart")
 if hrp and #pending > 0 then
 table.sort(pending, function(a, b)
 return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
 end)
 for i = 1, math.min(2, #pending) do attackTurret(pending[i]) end
 end
 end
	end
end)
function setDestroySentry(on)
	St.destroySentry = on and true or false
	GTurret.AutoDestroyTurret = St.destroySentry
	if ToggleRefs and ToggleRefs.destroySentry and ToggleRefs.destroySentry.setVisual then
		pcall(ToggleRefs.destroySentry.setVisual, St.destroySentry)
	end
	if _G.RanaVSRefreshSentryBtn then pcall(_G.RanaVSRefreshSentryBtn) end
	pcall(saveCfg)
end

----------------------------------------------------------------
do -- Scoped Chilli spam-loop internals.
-- SPAM LASER CAPE / PAINTBALL (ChilliHub Auto Laser Cape / Auto Paintball logic)
-- Each feature owns a generation-guarded loop; turning one off does not stop the other.
local spamLaserGeneration = 0
local spamPaintGeneration = 0
local SPAM_LOOP_INTERVAL = 0.04

local function runChilliAutoSpam(toolName, stateKey, getGeneration, setGeneration)
    setGeneration(getGeneration() + 1)
    local generation = getGeneration()
    -- Chilli attempts to obtain/equip the selected tool when the feature is enabled.
    pcall(function() equipExactTool(toolName) end)
    task.spawn(function()
        while St[stateKey] == true and getGeneration() == generation and LP.Parent do
            local char = LP.Character
            local tool = char and char:FindFirstChild(toolName)
            if tool and tool:IsA("Tool") and tool.Name == toolName then
                _G.__12HubChilliAim.update()
                pcall(function() tool:Activate() end)
            end
            task.wait(SPAM_LOOP_INTERVAL)
        end
        if not (St.toolAim or St.spamLaser or St.spamPaint) then
            _G.__12HubChilliAim.restore()
        end
    end)
end

local function bumpLaserGeneration(value)
    spamLaserGeneration = value
end
local function bumpPaintGeneration(value)
    spamPaintGeneration = value
end
local function getLaserGeneration()
    return spamLaserGeneration
end
local function getPaintGeneration()
    return spamPaintGeneration
end

function startSpamLoop()
    if St.spamLaser then
        runChilliAutoSpam("Laser Cape", "spamLaser", getLaserGeneration, bumpLaserGeneration)
    end
    if St.spamPaint then
        runChilliAutoSpam("Paintball Gun", "spamPaint", getPaintGeneration, bumpPaintGeneration)
    end
    _G.__12HubChilliAim.refresh()
end

function stopSpamLoopIfIdle()
    if not St.spamLaser then spamLaserGeneration = spamLaserGeneration + 1 end
    if not St.spamPaint then spamPaintGeneration = spamPaintGeneration + 1 end
    if not (St.spamLaser or St.spamPaint or St.toolAim) then
        _G.__12HubChilliAim.restore()
    end
end

function setSpamLaser(on)
    local enabled = on == true
    St.spamLaser = enabled
    if enabled then
        runChilliAutoSpam("Laser Cape", "spamLaser", getLaserGeneration, bumpLaserGeneration)
    else
        spamLaserGeneration = spamLaserGeneration + 1
        local char = LP.Character
        local tool = char and char:FindFirstChild("Laser Cape")
        if tool and tool:IsA("Tool") then pcall(function() tool:Deactivate() end) end
    end
    _G.__12HubChilliAim.refresh()
    if not (St.toolAim or St.spamLaser or St.spamPaint) then _G.__12HubChilliAim.restore() end
    saveCfg()
end

function setSpamPaint(on)
    local enabled = on == true
    St.spamPaint = enabled
    if enabled then
        runChilliAutoSpam("Paintball Gun", "spamPaint", getPaintGeneration, bumpPaintGeneration)
    else
        spamPaintGeneration = spamPaintGeneration + 1
        local char = LP.Character
        local tool = char and char:FindFirstChild("Paintball Gun")
        if tool and tool:IsA("Tool") then pcall(function() tool:Deactivate() end) end
    end
    _G.__12HubChilliAim.refresh()
    if not (St.toolAim or St.spamLaser or St.spamPaint) then _G.__12HubChilliAim.restore() end
    saveCfg()
end

_G.__12HubChilliRuntimeCleanup = function()
    pcall(function()
        spamLaserGeneration = spamLaserGeneration + 1
        spamPaintGeneration = spamPaintGeneration + 1
        St.spamLaser = false
        St.spamPaint = false
        St.toolAim = false
    end)
    pcall(function() if _G.__12HubChilliAim then _G.__12HubChilliAim.refresh() end end)
    pcall(function()
        if _G.__12HubChilliAim and _G.__12HubChilliAim.restore then
            _G.__12HubChilliAim.restore()
        end
    end)
    pcall(function() setOptimizer(false, true) end)
end
end -- Chilli spam-loop scope

----------------------------------------------------------------
-- COUNTER: Laser Cape / Boogie Bomb / Swap Body / Equip on Drop
----------------------------------------------------------------
local counterConn = nil
local COUNTER_TOOL_NAMES = {
	laser = { "Laser Cape", "LaserCape", "laser cape" },
	boogie = { "Boogie Bomb", "BoogieBomb", "boogie bomb", "Disco Ball" },
	swap = { "Body Swap Potion", "Swap Body", "Body Swap", "SwapBody", "Potion of Body Swap" },
}

local function findToolByNames(names)
	local char = LP.Character
	local bp = LP:FindFirstChild("Backpack")
	for _, nm in ipairs(names) do
 if char then
 local t = char:FindFirstChild(nm)
 if t and t:IsA("Tool") then return t end
 end
 if bp then
 local t = bp:FindFirstChild(nm)
 if t and t:IsA("Tool") then return t end
 end
	end
	-- fuzzy
	local function scan(parent)
 if not parent then return nil end
 for _, ch in ipairs(parent:GetChildren()) do
 if ch:IsA("Tool") then
 local ln = string.lower(ch.Name)
 for _, nm in ipairs(names) do
 if ln:find(string.lower(nm), 1, true) then return ch end
 end
 end
 end
 return nil
	end
	return scan(char) or scan(bp)
end

local function equipAndActivate(tool)
	if not tool then return end
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	pcall(function()
 if tool.Parent ~= char then
 hum:EquipTool(tool)
 end
	end)
	task.defer(function()
 pcall(function() tool:Activate() end)
	end)
end

function startCounterLoop()
	-- No spam Activate khi chọn counter — chỉ dùng lúc Drop
	if counterConn then
 pcall(function() counterConn:Disconnect() end)
 counterConn = nil
	end
end

function stopCounterLoopIfIdle()
	if not (St.counterLaser or St.counterBoogie or St.counterSwapBody or St.equipOnDrop) then
 if counterConn then pcall(function() counterConn:Disconnect() end) counterConn = nil end
	end
end

local function _counterExclusive(which)
	-- Chỉ 1 counter ON: OFF các cái còn lại
	St.counterLaser = (which == "laser")
	St.counterBoogie = (which == "boogie")
	St.counterSwapBody = (which == "swap")
	if ToggleRefs then
 for k, flag in pairs({counterLaser = (which=="laser"), counterBoogie = (which=="boogie"), counterSwapBody = (which=="swap")}) do
 local r = ToggleRefs[k]
 if r and r.setVisual then pcall(r.setVisual, flag) end
 end
	end
end

function setCounterLaser(on)
	if on then
 _counterExclusive("laser")
 -- chỉ lưu lựa chọn; equip+activate x2 khi Drop
 stopCounterLoopIfIdle()
	else
 St.counterLaser = false
 stopCounterLoopIfIdle()
	end
	saveCfg()
end
function setCounterBoogie(on)
	if on then
 _counterExclusive("boogie")
 -- chỉ lưu lựa chọn; equip+activate x2 khi Drop
 stopCounterLoopIfIdle()
	else
 St.counterBoogie = false
 stopCounterLoopIfIdle()
	end
	saveCfg()
end
function setCounterSwapBody(on)
	if on then
 _counterExclusive("swap")
 -- chỉ lưu lựa chọn; equip+activate x2 khi Drop
 stopCounterLoopIfIdle()
	else
 St.counterSwapBody = false
 stopCounterLoopIfIdle()
	end
	saveCfg()
end
function setEquipOnDrop(on)
	St.equipOnDrop = on and true or false
	saveCfg()
end

-- Equip + activate khi Drop xong
_G.RanaVSCounterOnDrop = function()
	-- Counter đã chọn: equip 1 + activate 2 khi Drop (Fling & Jump)
	local anyCounter = St.counterLaser or St.counterBoogie or St.counterSwapBody
	if not anyCounter and not St.equipOnDrop then return end
	if _G._VisCounterDropBusy == true then return end
	_G._VisCounterDropBusy = true
	task.spawn(function()
 local char = LP.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local prevTool = char and char:FindFirstChildOfClass("Tool")
 local prevName = prevTool and prevTool.Name or nil
 task.wait(0.2)
 local function runOnce(names)
 local tool = findToolByNames(names)
 if not tool then return end
 equipAndActivate(tool) -- equip + activate #1
 task.wait(0.15)
 pcall(function() tool:Activate() end) -- activate #2
 task.wait(0.1)
 end
 if St.counterLaser then runOnce(COUNTER_TOOL_NAMES.laser) end
 if St.counterBoogie then runOnce(COUNTER_TOOL_NAMES.boogie) end
 if St.counterSwapBody then runOnce(COUNTER_TOOL_NAMES.swap) end
 task.wait(0.1)
 pcall(function()
 local c = LP.Character
 local h = c and c:FindFirstChildOfClass("Humanoid")
 if not h or not prevName then return end
 local pl = string.lower(prevName)
 local isCounter = false
 for _, names in pairs(COUNTER_TOOL_NAMES) do
 for _, nm in ipairs(names) do
 if pl:find(string.lower(nm), 1, true) then isCounter = true break end
 end
 if isCounter then break end
 end
 if not isCounter then
 local bp = LP:FindFirstChild("Backpack")
 local t = (c and c:FindFirstChild(prevName)) or (bp and bp:FindFirstChild(prevName))
 if t and t:IsA("Tool") then h:EquipTool(t) end
 end
 end)
 _G._VisCounterDropBusy = false
	end)
end

-- Bật toggle Counter: equip 1 + activate 2 (một lần)
_G.RanaVSCounterOneShot = function(kind)
	if _G._VisCounterDropBusy then return end
	_G._VisCounterDropBusy = true
	task.spawn(function()
 local names = COUNTER_TOOL_NAMES[kind]
 if not names then _G._VisCounterDropBusy = false return end
 local tool = findToolByNames(names)
 if tool then
 equipAndActivate(tool)
 task.wait(0.15)
 pcall(function() tool:Activate() end)
 end
 _G._VisCounterDropBusy = false
	end)
end



function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end
function stroke(p, col)
	local s = Instance.new("UIStroke")
	s.Color = col or C.stroke
	s.Thickness = 1
	s.Transparency = 0.35
	s.Parent = p
	return s
end

-- ============================================================================
-- LEGACY RANA MAIN MENU REMOVED
-- All old Main/Tab/mini menu construction is deleted. The only main menu UI
-- is the LaPeak shell built later in this file.
-- ============================================================================

----------------------------------------------------------------
-- MOBILE: 3 mode + Drop + Insta + TP
----------------------------------------------------------------
local ModeGui = Instance.new("ScreenGui")
ModeGui.Name = "Rana.VSHubModeBar"
ModeGui.ResetOnSpawn = false
ModeGui.IgnoreGuiInset = true
ModeGui.DisplayOrder = 2501
ModeGui.Enabled = false
ModeGui.Parent = PlayerGui

local ActGui = Instance.new("ScreenGui")
ActGui.Name = "Rana.VSHubActionButtons"
ActGui.ResetOnSpawn = false
ActGui.IgnoreGuiInset = true
ActGui.DisplayOrder = 2500
ActGui.Enabled = false
ActGui.Parent = PlayerGui

local ACE_MODE = {
    bg = Color3.fromRGB(18, 21, 26),
    hover = Color3.fromRGB(22, 25, 30),
    line = Color3.fromRGB(48, 55, 65),
    muted = Color3.fromRGB(138, 142, 148),
    white = Color3.fromRGB(255, 255, 255),
    accent = Color3.fromRGB(104, 116, 132),
    -- Same dark slate-blue selected fill used by the Drop Mode (Stand/Jump) selector.
    accent2 = Color3.fromRGB(78, 119, 151),
    pale = Color3.fromRGB(210, 218, 228),
    shade = Color3.fromRGB(34, 49, 63),
    dark = Color3.fromRGB(35, 51, 65),
    selectedFlat = Color3.fromRGB(47, 77, 101),
}
local function setAceModeVisual(btn, active, strokeName)
    if not btn or not btn.Parent then return end
    local gradient = btn:FindFirstChild("AceModeBackgroundGradient")
    local stroke = btn:FindFirstChild(strokeName or "AceModeStroke") or btn:FindFirstChildOfClass("UIStroke")
    if active then
        btn.BackgroundColor3 = ACE_MODE.selectedFlat
        btn.BackgroundTransparency = 0
        btn.TextColor3 = ACE_MODE.white
        btn.Font = Enum.Font.GothamBlack
        if not gradient then
            gradient = Instance.new("UIGradient")
            gradient.Name = "AceModeBackgroundGradient"
            gradient.Rotation = 90
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, ACE_MODE.shade),
                ColorSequenceKeypoint.new(0.48, ACE_MODE.accent2),
                ColorSequenceKeypoint.new(1, ACE_MODE.dark),
            })
            gradient.Parent = btn
        end
        if stroke then
            stroke.Name = strokeName or "AceModeStroke"
            stroke.Color = ACE_MODE.accent2
            stroke.Transparency = 0.06
            stroke.Thickness = 1.5
        end
    else
        if gradient then gradient:Destroy() end
        btn.BackgroundColor3 = ACE_MODE.bg
        btn.BackgroundTransparency = 0
        btn.TextColor3 = ACE_MODE.muted
        btn.Font = Enum.Font.GothamBold
        if stroke then
            stroke.Name = strokeName or "AceModeStroke"
            stroke.Color = ACE_MODE.line
            stroke.Transparency = 0.30
            stroke.Thickness = 1
        end
    end
end

-- Floating Steal Speed button. Visible only while automatic switching is disabled.
-- Dragging is independent of the main-menu lock; position/size persist in the existing config.
do
    local stealSpeedGui2 = Instance.new("ScreenGui")
    stealSpeedGui2.Name = "RanaVSStealSpeedButtonGui"
    stealSpeedGui2.ResetOnSpawn = false
    stealSpeedGui2.IgnoreGuiInset = true
    stealSpeedGui2.DisplayOrder = 2605
    stealSpeedGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    stealSpeedGui2.Parent = PlayerGui

    local buttonSize2 = math.clamp(tonumber(St.stealSpeedButtonSize) or 70, 40, 120)
    local button2 = Instance.new("TextButton")
    button2.Name = "StealSpeedFloatingButton"
    button2.Size = UDim2.fromOffset(buttonSize2, buttonSize2)
    if type(St.stealSpeedButtonPos) == "table" and #St.stealSpeedButtonPos >= 4 then
        button2.Position = UDim2.new(tonumber(St.stealSpeedButtonPos[1]) or 1, tonumber(St.stealSpeedButtonPos[2]) or -96,
            tonumber(St.stealSpeedButtonPos[3]) or 0.58, tonumber(St.stealSpeedButtonPos[4]) or 0)
    else
        button2.Position = UDim2.new(1, -96, 0.58, 0)
    end
    button2.BackgroundColor3 = ACE_MODE.bg
    button2.BorderSizePixel = 0
    button2.AutoButtonColor = false
    button2.Active = true
    button2.Selectable = false
    button2.Text = "STEAL\nSPEED"
    button2.TextWrapped = true
    button2.TextSize = 12
    button2.Font = Enum.Font.GothamBlack
    button2.TextColor3 = ACE_MODE.white
    button2.ZIndex = 10
    button2.Parent = stealSpeedGui2
    local round2 = Instance.new("UICorner")
    round2.CornerRadius = UDim.new(0, 12)
    round2.Parent = button2
    local gradient2 = Instance.new("UIGradient")
    gradient2.Name = "LaPeakButtonGradient"
    gradient2.Rotation = 90
    gradient2.Parent = button2

    local stroke2 = Instance.new("UIStroke")
    stroke2.Name = "StealSpeedButtonStroke"
    stroke2.Color = Color3.fromRGB(105, 105, 112)
    stroke2.Thickness = 1.15
    stroke2.Transparency = 0.05
    stroke2.Parent = button2

    local function uiDragLocked2()
        -- Match the global Lock UI state used by the other floating action buttons.
        return St.menuGuiLocked == true or St.guiLock == true or _G._AceGuiLocked == true
    end

    local function refreshFloating2()
        if not button2.Parent then return end
        local active2 = St.stealSpeedActive == true
        local size2 = math.clamp(tonumber(St.stealSpeedButtonSize) or 70, 40, 120)
        button2.Visible = St.autoChangeOnSteal ~= true
        button2.Size = UDim2.fromOffset(size2, size2)
        button2.BackgroundTransparency = 0
        button2.Text = active2 and "STEAL\nSPEED ON" or "STEAL\nSPEED"
        -- Match applyActBtnState() / the Auto Steal floating button exactly:
        -- OFF = white gradient + dark medium text; ON = black/grey gradient + white bold text.
        button2.BackgroundColor3 = active2 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        button2.TextColor3 = active2 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 30)
        button2.Font = active2 and Enum.Font.GothamBlack or Enum.Font.GothamMedium
        gradient2.Color = active2 and ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(185, 185, 190)),
            ColorSequenceKeypoint.new(0.62, Color3.fromRGB(72, 72, 78)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8, 8, 10)),
        }) or ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235, 235, 238)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170, 170, 178)),
        })
        gradient2.Transparency = NumberSequence.new(0)
        stroke2.Color = active2 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(105, 105, 112)
        stroke2.Thickness = active2 and 1.8 or 1.15
        stroke2.Transparency = 0.05
    end
    _G.RanaVSRefreshFloatingStealSpeedButton = refreshFloating2
    _G.RanaVSSetStealSpeedButtonSize = function(value2, saveIt2)
        St.stealSpeedButtonSize = math.clamp(math.floor(tonumber(value2) or 70), 40, 120)
        refreshFloating2()
        if saveIt2 ~= false then pcall(saveCfg) end
        return St.stealSpeedButtonSize
    end

    local dragActive2, dragStart2, startPosition2, moved2 = false, nil, nil, false
    local suppressClickUntil2 = 0
    local connections2 = _G._12HubStealSpeedButtonConnections
    table.insert(connections2, button2.InputBegan:Connect(function(input2)
        if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
            -- Lock UI freezes the floating button in place, but does not disable clicking it.
            if uiDragLocked2() then
                dragActive2 = false
                dragStart2, startPosition2 = nil, nil
                moved2 = false
                return
            end
            dragActive2 = true
            moved2 = false
            dragStart2 = input2.Position
            startPosition2 = button2.Position
        end
    end))
    table.insert(connections2, UIS.InputChanged:Connect(function(input2)
        if not dragActive2 or not dragStart2 or not startPosition2 then return end
        if uiDragLocked2() then
            -- If Lock UI is enabled mid-drag, stop movement immediately.
            dragActive2 = false
            moved2 = false
            dragStart2, startPosition2 = nil, nil
            return
        end
        if input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch then
            local delta2 = input2.Position - dragStart2
            if math.abs(delta2.X) > 3 or math.abs(delta2.Y) > 3 then
                moved2 = true
                suppressClickUntil2 = os.clock() + 0.3
                button2.Position = UDim2.new(startPosition2.X.Scale, startPosition2.X.Offset + delta2.X,
                    startPosition2.Y.Scale, startPosition2.Y.Offset + delta2.Y)
            end
        end
    end))
    table.insert(connections2, UIS.InputEnded:Connect(function(input2)
        if dragActive2 and (input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch) then
            dragActive2 = false
            if moved2 then
                St.stealSpeedButtonPos = {button2.Position.X.Scale, button2.Position.X.Offset, button2.Position.Y.Scale, button2.Position.Y.Offset}
                pcall(saveCfg)
            end
            dragStart2, startPosition2 = nil, nil
        end
    end))
    table.insert(connections2, button2.Activated:Connect(function()
        if os.clock() < suppressClickUntil2 then return end
        setStealSpeedActive2(not (St.stealSpeedActive == true))
    end))
    refreshFloating2()
end

local modeRefs = {}
local actRefs = {}

-- Shape chỉ áp dụng cho ACTION buttons (Drop/Insta/TP/Sentry/Steal).
-- 3-mode speed (Normal/Lagger/Custom) LUÔN giữ style mặc định (Pill) như video.
function applyCorner(btn, forceShape)
	if not btn then return end
	local shape = tostring(forceShape or St.btnShape or "FOUNDED"):upper()
	if shape == "ROUND" then shape = "CIRCLE" elseif shape == "BOX" then shape = "FOUNDED" end
	-- Xoá hết UICorner cũ rồi tạo lại (tránh kẹt radius cũ)
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("UICorner") then pcall(function() ch:Destroy() end) end
	end
	local rad
	if shape == "CIRCLE" then
 rad = UDim.new(1, 0)
 elseif shape == "SQUARE" then
 rad = UDim.new(0, 4)
 else
 rad = UDim.new(0, 12)
 end
	local c = Instance.new("UICorner")
	c.Name = "ShapeCorner"
	c.CornerRadius = rad
	c.Parent = btn
	-- đồng bộ ảnh nền / dim
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("ImageLabel") or (ch:IsA("Frame") and ch.Name ~= "BtnTextOverlay") then
 for _, sub in ipairs(ch:GetChildren()) do
 if sub:IsA("UICorner") then pcall(function() sub:Destroy() end) end
 end
 local c2 = Instance.new("UICorner")
 c2.Name = "ShapeCorner"
 c2.CornerRadius = rad
 c2.Parent = ch
 end
	end
end

function applyCornerToChildren(btn, shape)
	if not btn then return end
	shape = tostring(shape or St.btnShape or "FOUNDED"):upper()
	if shape == "ROUND" then shape = "CIRCLE" elseif shape == "BOX" then shape = "FOUNDED" end
	local rad
	if shape == "CIRCLE" then rad = UDim.new(1, 0)
	elseif shape == "SQUARE" then rad = UDim.new(0, 4)
	else rad = UDim.new(0, 12)
	end
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("ImageLabel") or (ch:IsA("Frame") and ch.Name ~= "BtnTextOverlay") then
 for _, sub in ipairs(ch:GetChildren()) do
 if sub:IsA("UICorner") then pcall(function() sub:Destroy() end) end
 end
 local c = Instance.new("UICorner")
 c.Name = "ShapeCorner"
 c.CornerRadius = rad
 c.Parent = ch
 end
	end
end

local MOB_BTN_IMAGE_IDS = {
	126832513729779, 81347949983999, 76940707345653, 100648743625857,
	73857705647948, 86237559415852, 81474116937197, 86668822094069,
	108384375206363, 86791880986403, 126414648469223,
}
function applyEmpireBtnBg(btn, index)
	if not btn then return end
	local old = btn:FindFirstChild("BtnBgImage")
	if old then old:Destroy() end
	local list = MOB_BTN_IMAGE_IDS
	local id = list[((tonumber(index) or 1) - 1) % #list + 1]
	if not id or id <= 0 then return end
	-- nền đậm hơn (12Hub style) nhưng chữ vẫn đọc được
	btn.BackgroundTransparency = 0.35
	btn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	local bgImg = Instance.new("ImageLabel")
	bgImg.Name = "BtnBgImage"
	bgImg.BackgroundTransparency = 1
	bgImg.Image = "rbxassetid://" .. tostring(id)
	bgImg.ImageTransparency = 0.08 -- đậm hơn (thấp = rõ ảnh hơn)
	bgImg.ScaleType = Enum.ScaleType.Crop
	bgImg.Size = UDim2.new(1, 0, 1, 0)
	bgImg.ZIndex = (btn.ZIndex or 1)
	bgImg.Active = false
	bgImg.Selectable = false
	bgImg.Parent = btn
	-- lớp tối nhẹ để chữ trắng nổi
	local dim = Instance.new("Frame")
	dim.Name = "BtnDim"
	dim.Size = UDim2.new(1, 0, 1, 0)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.45
	dim.BorderSizePixel = 0
	dim.ZIndex = (btn.ZIndex or 1) + 1
	dim.Active = false
	dim.Selectable = false
	dim.Parent = btn
	local currentShape = tostring(St.btnShape or "FOUNDED"):upper()
	if currentShape == "ROUND" then currentShape = "CIRCLE" elseif currentShape == "BOX" then currentShape = "FOUNDED" end
	local rad
	if currentShape == "CIRCLE" then rad = UDim.new(1, 0)
	elseif currentShape == "SQUARE" then rad = UDim.new(0, 4)
	else rad = UDim.new(0, 12)
	end
	local c = Instance.new("UICorner")
	c.CornerRadius = rad
	c.Parent = bgImg
	local c2 = Instance.new("UICorner")
	c2.CornerRadius = rad
	c2.Parent = dim
	-- chữ trên cùng
	btn.TextTransparency = 0
	btn.TextStrokeTransparency = 0.4
	btn.TextStrokeColor3 = Color3.new(0, 0, 0)
	pcall(function() btn.ZIndex = math.max(btn.ZIndex or 1, 100) end)
	-- Empire gradient stroke on button
	local st = btn:FindFirstChildOfClass("UIStroke")
	if st and not st:FindFirstChild("EmpireOutlineGrad") then
 st.Thickness = 1.6
 st.Transparency = 0.1
 local g = Instance.new("UIGradient")
 g.Name = "EmpireOutlineGrad"
 g.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
 ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 80, 180)),
 ColorSequenceKeypoint.new(0.7, Color3.fromRGB(180, 80, 255)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
 })
 g.Parent = st
 task.spawn(function()
 local t0 = tick()
 while st and st.Parent do
 g.Rotation = ((tick() - t0) * 50) % 360
 task.wait(0.04)
 end
 end)
	end
end

----------------------------------------------------------------
-- SPEED V2 MODE BAR (full GUI from RanaVS Clean) — 3 mode
----------------------------------------------------------------
local v2BarButtons = {}
function _G.RanaVSBuildV2ModeBar()
	_G.RanaVSSpeedMethod = "V2"
	pcall(function()
 local old = PlayerGui:FindFirstChild("Rana.VSV2ModeBar")
 if old then old:Destroy() end
	end)
	if not St.mobileBtns then return end
 local sc = 1
	local function modeHeight(modeName)
		return 50
	end
	local V2_BTN_W = math.max(72, math.floor(88 * sc))
	local V2_CORNER = 12
	local MODE_COLORS = {
        Normal = { onBg = ACE_MODE.selectedFlat, onTxt = ACE_MODE.white, offBg = ACE_MODE.bg, offTxt = ACE_MODE.muted, stroke = ACE_MODE.accent2 },
        Lagger = { onBg = ACE_MODE.selectedFlat, onTxt = ACE_MODE.white, offBg = ACE_MODE.bg, offTxt = ACE_MODE.muted, stroke = ACE_MODE.accent2 },
        Custom = { onBg = ACE_MODE.selectedFlat, onTxt = ACE_MODE.white, offBg = ACE_MODE.bg, offTxt = ACE_MODE.muted, stroke = ACE_MODE.accent2 },
    }
    local gui = Instance.new("ScreenGui")
	gui.Name = "Rana.VSV2ModeBar"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 95
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	v2BarButtons = {}
	local function styleV2Btn(btn, modeName, active)
        local col = MODE_COLORS[modeName] or MODE_COLORS.Normal
        btn.BackgroundColor3 = active and col.onBg or col.offBg
        btn.BackgroundTransparency = 0
        btn.TextColor3 = active and col.onTxt or col.offTxt
        btn.Font = active and Enum.Font.GothamBlack or Enum.Font.GothamBold
        local baseStroke = btn:FindFirstChild("V2BaseStroke") or btn:FindFirstChildOfClass("UIStroke")
        if baseStroke then
            baseStroke.Name = "V2BaseStroke"
            baseStroke.Color = active and col.stroke or ACE_MODE.line
            baseStroke.Transparency = active and 0.06 or 0.30
            baseStroke.Thickness = active and 1.5 or 1
        end
        local oldGlow = btn:FindFirstChild("V2ActiveGradient")
        if oldGlow then oldGlow:Destroy() end
        local oldBackgroundGradient = btn:FindFirstChild("AceModeBackgroundGradient")
        if active then
            if not oldBackgroundGradient then
                local bgGradient = Instance.new("UIGradient")
                bgGradient.Name = "AceModeBackgroundGradient"
                bgGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, ACE_MODE.shade),
                    ColorSequenceKeypoint.new(0.48, ACE_MODE.accent2),
                    ColorSequenceKeypoint.new(1, ACE_MODE.dark),
                })
                bgGradient.Rotation = 0
                bgGradient.Parent = btn
            end
        elseif oldBackgroundGradient then
            oldBackgroundGradient:Destroy()
        end
    end
    local function posFromSaved(modeName, order)
 local key = "V2_" .. modeName
 local t = St._btnPos and St._btnPos[key]
 if type(t) == "table" and t[1] ~= nil then
 return UDim2.new(t[1], t[2], t[3], t[4])
 end
 local gap = 10
 local total = (V2_BTN_W + gap) * 3 - gap
 return UDim2.new(0.5, -total / 2 + (order - 1) * (V2_BTN_W + gap), 1, -118)
	end
	local function saveV2Pos(modeName, holder)
 St._btnPos = St._btnPos or {}
 St._btnPos["V2_" .. modeName] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 }
 pcall(saveCfg)
	end
	local function makeV2ModeBtn(modeName, label, order)
 local holder = Instance.new("Frame")
 holder.Name = "V2MH_" .. modeName
 holder.Size = UDim2.new(0, V2_BTN_W, 0, modeHeight(modeName))
 holder.Position = posFromSaved(modeName, order)
 holder.BackgroundTransparency = 1
 holder.BorderSizePixel = 0
 holder.ZIndex = 10
 holder.Active = true
 holder.Parent = gui
 local btn = Instance.new("TextButton")
 btn.Name = "V2Bar_" .. modeName
 btn.Size = UDim2.new(1, 0, 1, 0)
 btn.BackgroundColor3 = ACE_MODE.bg
 btn.Text = label
 btn.TextColor3 = ACE_MODE.muted
 btn.Font = Enum.Font.GothamBlack
 btn.TextSize = 13
 btn.AutoButtonColor = false
 btn.ZIndex = 12
 btn.Parent = holder
 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, V2_CORNER)
 local st = Instance.new("UIStroke", btn)
 st.Thickness = 1
 st.Transparency = 0.30
 st.Color = ACE_MODE.line
 st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 styleV2Btn(btn, modeName, St.activeMode == modeName)
 local activeInput, pressPos, holderStart = nil, nil, nil
 local moved, lastClick = false, 0
 local function runClick()
 local now = tick()
 if now - lastClick < 0.08 then return end
 lastClick = now
 if type(setActiveMode) == "function" then
 setActiveMode(modeName)
 else
 St.activeMode = modeName
 end
 for n, e in pairs(v2BarButtons) do
 if e and e.btn then styleV2Btn(e.btn, n, n == modeName) end
 end
 -- sync old modeRefs if any
 for n, e in pairs(modeRefs or {}) do
 if e and e.style then pcall(e.style, n == modeName)
 elseif e and e.btn then
 setAceModeVisual(e.btn, n == modeName)
 end
 end
 end
 btn.InputBegan:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
 activeInput = input
 pressPos = input.Position
 holderStart = holder.Position
 moved = false
 input.Changed:Connect(function()
 if input.UserInputState ~= Enum.UserInputState.End or activeInput ~= input then return end
 activeInput = nil
 if not moved then
 runClick()
 elseif not St.guiLock then
 saveV2Pos(modeName, holder)
 end
 end)
 end)
 btn.Activated:Connect(function()
 if moved then return end
 runClick()
 end)
 UIS.InputChanged:Connect(function(input)
 if not activeInput or not pressPos or not holderStart then return end
 if activeInput.UserInputType == Enum.UserInputType.Touch then
 if input ~= activeInput then return end
 elseif activeInput.UserInputType == Enum.UserInputType.MouseButton1 then
 if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
 else return end
 local dx = input.Position.X - pressPos.X
 local dy = input.Position.Y - pressPos.Y
 if math.abs(dx) > 4 or math.abs(dy) > 4 then moved = true end
 if moved and not St.guiLock then
 holder.Position = UDim2.new(holderStart.X.Scale, holderStart.X.Offset + dx, holderStart.Y.Scale, holderStart.Y.Offset + dy)
 end
 end)
 v2BarButtons[modeName] = { holder = holder, btn = btn }
 return btn
	end
	makeV2ModeBtn("Normal", "NORMAL", 1)
	makeV2ModeBtn("Lagger", "LAGGER", 2)
	makeV2ModeBtn("Custom", "CUSTOM", 3)
	_G.RanaVSRefreshV2ModeBar = function()
 for n, e in pairs(v2BarButtons) do
 if e and e.btn then styleV2Btn(e.btn, n, St.activeMode == n) end
 end
	end
end


function makeModeBtn(name, order)
	-- Size Speed 3Mode: tăng chiều cao; width ổn định
	local sc = 1
	local modeBase = 50
	local V2_CORNER = 12
	local h = modeBase
	local w = 88
	local holder = Instance.new("Frame")
	holder.Name = "M_" .. name
	holder.Size = UDim2.new(0, w, 0, h)
	local gap = 10
	local total = (w + gap) * 3 - gap
	holder.Position = UDim2.new(0.5, -total / 2 + (order - 1) * (w + gap), 1, -118)
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.ZIndex = 10
	holder.Active = true
	holder.Parent = ModeGui
	-- restore saved pos
	pcall(function()
 local p = St._btnPos and St._btnPos["M_" .. name]
 if type(p) == "table" and p[1] ~= nil then
 holder.Position = UDim2.new(p[1], p[2], p[3], p[4])
 end
	end)
	local btn = Instance.new("TextButton")
	btn.Name = "ModeBtn"
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = ACE_MODE.bg
	btn.Text = name:upper()
	if name == "Normal" then btn.Text = "NORMAL" end
	btn.TextColor3 = ACE_MODE.muted
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = math.clamp(math.floor(h * 0.36), 11, 14)
	btn.AutoButtonColor = false
	btn.ZIndex = 12
	btn.Active = true
	btn.Parent = holder
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, V2_CORNER)
	local st = Instance.new("UIStroke", btn)
	st.Thickness = 1
	st.Transparency = 0.30
	st.Color = ACE_MODE.line
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Name = "AceModeStroke"
	local function styleMode(on)
        setAceModeVisual(btn, on, "AceModeStroke")
 end
	styleMode(St.activeMode == name)
	local dragging, dragStart, startPos, moved = false, nil, nil, false
	local movedDistance = 0
	local TAP_MAX = 22
	btn.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 moved = false
 movedDistance = 0
 dragStart = input.Position
 startPos = holder.Position
 end
	end)
	btn.InputChanged:Connect(function(input)
 if not dragging or not dragStart then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - dragStart
 movedDistance = d.Magnitude
 if movedDistance > 8 then moved = true end
 if not St.guiLock and moved then
 holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end
	end)
	local function pick()
 setActiveMode(name)
 -- refresh all mode styles
 for n, e in pairs(modeRefs) do
 if e and e.btn and e.style then
 e.style(St.activeMode == n)
 elseif e and e.btn then
 local on = St.activeMode == n
 setAceModeVisual(e.btn, on)
 e.btn.TextColor3 = on and ACE_MODE.white or ACE_MODE.muted
 end
 end
 styleMode(true)
	end
	btn.InputEnded:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
 if not dragging then return end
 dragging = false
 if not moved and movedDistance < TAP_MAX then
 pick()
 elseif moved and not St.guiLock then
 savePos(holder, "M_" .. name)
 end
 movedDistance = 0
 dragStart = nil
	end)
	btn.MouseButton1Click:Connect(function()
 if moved then return end
 pick()
	end)
	btn.Activated:Connect(function()
 if moved then return end
 pick()
	end)
	modeRefs[name] = { holder = holder, btn = btn, style = styleMode }
end


local psLoopConn = nil
local function findToolExact(toolName)
    local char = LP.Character
    local bp = LP:FindFirstChildOfClass("Backpack")
    local function scan(container)
        if not container then return nil end
        local exact = container:FindFirstChild(toolName)
        if exact and exact:IsA("Tool") and exact.Name == toolName then return exact end
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("Tool") and type(obj.Name) == "string" and obj.Name:lower():sub(1, #toolName) == toolName:lower() then return obj end
        end
        return nil
    end
    return scan(char) or scan(bp)
end

local function equipExactTool(toolName)
    local tool = findToolExact(toolName)
    if not tool then return nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:EquipTool(tool) end) end
    return tool
end

local function isEquippedExact(toolName)
    local char = LP.Character
    if not char then return false end
    local tool = char:FindFirstChild(toolName)
    if tool and tool:IsA("Tool") and tool.Name == toolName then return true end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and type(obj.Name) == "string" and obj.Name:lower():sub(1, #toolName) == toolName:lower() then return true end
    end
    return false
end

-- Web Slinger support for the mobile action button. This detects the equipped
-- Tool, matching Nova Moon's own readiness check. Target-character CFrame forcing
-- from the source script is intentionally not used; the action calls Tool:Activate().
local function isWebSlingerTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local normalized = tostring(tool.Name):lower():gsub("[%s_%-]", "")
    return normalized == "webslinger" or normalized == "websinger"
end

local function findWebSlingerTool()
    local char = LP.Character
    local backpack = LP:FindFirstChildOfClass("Backpack")
    for _, container in ipairs({char, backpack}) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if isWebSlingerTool(child) then return child end
            end
        end
    end
    return nil
end

local function isWebSlingerEquipped()
    local char = LP.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if isWebSlingerTool(child) then return true end
    end
    return false
end


-- ═══════════════════════════════════════════════════════════════
--  NOVAMOON KILL PORT (full logic from NovaMoonHub_NoRed)
--  KILL loop: fling target ±20 studs via Heartbeat, ESP arrow +
--  distance label and death detection. On confirmed target death, swap tools; no teleport.
-- ═══════════════════════════════════════════════════════════════
local NM_KILL_GUI_OK = false
local NM_isKilling = false
local NM_killLoop = nil
local NM_currentTarget = nil
local NM_diedConn = nil
local NM_healthConn = nil
local NM_charConn = nil

local NM_notifyGui = Instance.new("ScreenGui")
NM_notifyGui.Name = "RanaVS_NMKill_Notify"
NM_notifyGui.ResetOnSpawn = false
NM_notifyGui.IgnoreGuiInset = true
NM_notifyGui.DisplayOrder = 999
local okNg = pcall(function() NM_notifyGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okNg then NM_notifyGui.Parent = PlayerGui end

local function NMNotify(text, green)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 280, 0, 36)
    notif.Position = UDim2.new(0.5, -140, 0, 10)
    notif.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    notif.BackgroundTransparency = 0.1
    notif.Text = tostring(text)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 13
    notif.TextColor3 = green and Color3.fromRGB(120, 220, 130) or Color3.fromRGB(240, 240, 240)
    notif.ZIndex = 999
    notif.Parent = NM_notifyGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke")
    st.Thickness = 1
    st.Color = Color3.fromRGB(255, 255, 255)
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = notif
    task.delay(3, function() notif:Destroy() end)
end

local NM_espGui = Instance.new("ScreenGui")
NM_espGui.Name = "RanaVS_NMKill_ESP"
NM_espGui.ResetOnSpawn = false
NM_espGui.IgnoreGuiInset = true
NM_espGui.DisplayOrder = 998
local okEsp = pcall(function() NM_espGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okEsp then NM_espGui.Parent = PlayerGui end

local NM_arrow = Instance.new("ImageLabel")
NM_arrow.Name = "TargetArrow"
NM_arrow.Size = UDim2.new(0, 36, 0, 36)
NM_arrow.BackgroundTransparency = 1
NM_arrow.Image = "rbxassetid://13221883044"
NM_arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
NM_arrow.Visible = false
NM_arrow.Parent = NM_espGui

local NM_distLbl = Instance.new("TextLabel")
NM_distLbl.Name = "DistanceText"
NM_distLbl.Size = UDim2.new(0, 100, 0, 20)
NM_distLbl.BackgroundTransparency = 1
NM_distLbl.Text = ""
NM_distLbl.Font = Enum.Font.GothamBold
NM_distLbl.TextSize = 14
NM_distLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
NM_distLbl.TextStrokeTransparency = 0.5
NM_distLbl.Visible = false
NM_distLbl.Parent = NM_espGui

local function NMHasTool(toolName)
    local char = LP.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and child.Name == toolName then return true end
    end
    for _, handName in ipairs({"RightHand", "LeftHand", "Right Arm", "Left Arm"}) do
        local hand = char:FindFirstChild(handName)
        if hand then
            for _, child in ipairs(hand:GetChildren()) do
                if child.Name == toolName then return true end
            end
        end
    end
    return false
end

local function NMHasWebSlinger()
    -- Require the real WebSlinger/WebSinger Tool equipped in this character.
    -- Do not begin the kill loop when only a similarly named object is present elsewhere.
    return isWebSlingerEquipped()
end

local function NMHasFlyingCarpet()
    return NMHasTool("Flying Carpet")
end

local function NMEquipFlyingCarpet()
    -- Inventory-only swap: explicitly put Webslinger away, then equip the
    -- player's own Flying Carpet. Never search or move Tools out of Workspace.
    local char = LP.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local backpack = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    local carpet = char:FindFirstChild("Flying Carpet")
    if not (carpet and carpet:IsA("Tool")) and backpack then
        carpet = backpack:FindFirstChild("Flying Carpet")
    end
    if not (carpet and carpet:IsA("Tool")) then return false end

    local okUnequip = pcall(function() humanoid:UnequipTools() end)
    if not okUnequip then return false end
    RS.Heartbeat:Wait()
    if LP.Character ~= char or not char.Parent or humanoid.Health <= 0 or not carpet.Parent then return false end
    local okEquip = pcall(function() humanoid:EquipTool(carpet) end)
    if not okEquip then return false end
    RS.Heartbeat:Wait()
    local equipped = LP.Character == char and carpet.Parent == char
    if equipped then NMNotify("✅ Webslinger unequipped · Flying Carpet equipped", true) end
    return equipped
end

local function NMGetNearestPlayer()
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myChar or not myHum or myHum.Health <= 0 or not hrp then return nil, nil end
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Parent == Players then
            local targetChar = p.Character
            if targetChar and targetChar:IsDescendantOf(workspace) and Players:GetPlayerFromCharacter(targetChar) == p then
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                local part = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHum and targetHum.Health > 0 and part and part:IsA("BasePart") then
                    local mag = (part.Position - hrp.Position).Magnitude
                    if mag <= 100 and mag < dist then
                        dist, closest = mag, p
                    end
                end
            end
        end
    end
    return closest, closest and dist or nil
end

local function NMUpdateESP(target)
    local camera = workspace.CurrentCamera
    if not target or not target.Character or not camera then
        NM_arrow.Visible = false
        NM_distLbl.Visible = false
        return
    end
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp or not myHrp then
        NM_arrow.Visible = false
        NM_distLbl.Visible = false
        return
    end
    local targetPos = targetHrp.Position
    local myPos = myHrp.Position
    local distance = (targetPos - myPos).Magnitude
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    if onScreen then
        NM_arrow.Position = UDim2.new(0, screenPos.X - 18, 0, screenPos.Y - 45)
        NM_arrow.Rotation = 0
        NM_arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    else
        local camPos = camera.CFrame.Position
        local camLook = camera.CFrame.LookVector
        local toTarget = (targetPos - camPos).Unit
        local right = camera.CFrame.RightVector
        local angle = math.atan2(toTarget:Dot(right), toTarget:Dot(camLook))
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local edgeDist = math.min(camera.ViewportSize.X, camera.ViewportSize.Y) * 0.4
        local arrowX = screenCenter.X + math.sin(angle) * edgeDist
        local arrowY = screenCenter.Y - math.cos(angle) * edgeDist * 0.8
        NM_arrow.Position = UDim2.new(0, arrowX - 18, 0, arrowY - 18)
        NM_arrow.Rotation = math.deg(angle)
        NM_arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
    NM_arrow.Visible = true
    NM_distLbl.Text = string.format("%.1f studs", distance)
    NM_distLbl.Position = UDim2.new(0, NM_arrow.Position.X.Offset + 42, 0, NM_arrow.Position.Y.Offset + 8)
    NM_distLbl.Visible = true
end

local function NMSetupDeathDetection(target)
    if NM_diedConn then NM_diedConn:Disconnect(); NM_diedConn = nil end
    if NM_healthConn then NM_healthConn:Disconnect(); NM_healthConn = nil end
    if NM_charConn then NM_charConn:Disconnect(); NM_charConn = nil end
    if not target or not target.Character then return end
    local trackedCharacter = target.Character
    local humanoid = trackedCharacter:FindFirstChildOfClass("Humanoid")
    local function stopForTargetDeath(reason)
        task.defer(function()
            if NM_isKilling and NM_currentTarget == target then
                if _G.RanaVSNMStopKill then _G.RanaVSNMStopKill(reason or "target-dead") end
            end
        end)
    end
    if humanoid then
        NM_diedConn = humanoid.Died:Connect(function()
            stopForTargetDeath("target-dead")
        end)
        NM_healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health <= 0 then stopForTargetDeath("target-dead") end
        end)
    end
    NM_charConn = target.CharacterRemoving:Connect(function(removingCharacter)
        if removingCharacter == trackedCharacter then
            local finalHumanoid = humanoid or trackedCharacter:FindFirstChildOfClass("Humanoid")
            if finalHumanoid and finalHumanoid.Health <= 0 then
                stopForTargetDeath("target-dead")
            else
                stopForTargetDeath("target-lost")
            end
        end
    end)
end

function _G.RanaVSNMStopKill(reason)
    if not NM_isKilling then return end
    reason = tostring(reason or "manual")
    local stoppedTarget = NM_currentTarget
    NM_isKilling = false
    NM_currentTarget = nil
    if _G.RanaVSNMStickyTarget == stoppedTarget then _G.RanaVSNMStickyTarget = nil end
    if _G.RanaVSWebSlingerAimTarget == stoppedTarget then _G.RanaVSWebSlingerAimTarget = nil end
    if NM_diedConn then NM_diedConn:Disconnect(); NM_diedConn = nil end
    if NM_healthConn then NM_healthConn:Disconnect(); NM_healthConn = nil end
    if NM_charConn then NM_charConn:Disconnect(); NM_charConn = nil end
    if NM_killLoop then NM_killLoop:Disconnect(); NM_killLoop = nil end
    NM_arrow.Visible = false
    NM_distLbl.Visible = false
    NMNotify("🛑 Kill stopped", false)
    -- Never teleport after stopping a Webslinger kill. When the target is
    -- confirmed dead, cleanly unequip Webslinger and equip Flying Carpet instead.
    if reason == "target-dead" then
        task.spawn(function()
            local swapped = NMEquipFlyingCarpet()
            if not swapped then
                NMNotify("⚠️ Flying Carpet is not in your inventory", false)
            end
        end)
    end
    if _G.RanaVSRefreshWebsingerBtn then task.defer(_G.RanaVSRefreshWebsingerBtn) end
end

function _G.RanaVSNMKillState()
    return NM_isKilling == true
end

function _G.RanaVSNMStartKill()
    if NM_isKilling then return end
    local char = LP.Character
    local localHumanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not localHumanoid or localHumanoid.Health <= 0 then return end

    -- The Tool can be in Backpack initially; equip the recognized WebSlinger first.
    local slingTool = findWebSlingerTool()
    if not slingTool then
        NMNotify("❌ Need Web Slinger!", false)
        return
    end
    if slingTool.Parent ~= char then
        local equipOk = pcall(function() localHumanoid:EquipTool(slingTool) end)
        if not equipOk then return end
        task.wait(0.12)
    end
    if not NMHasWebSlinger() then
        NMNotify("❌ Equip Web Slinger first", false)
        return
    end

    -- Kill must use the SAME target currently recognized and locked by WebSlinger aim.
    -- Do not fall back to an arbitrary nearest player when aim has no valid target.
    local localRoot = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = nil
    if type(bestEnemy) == "function" then
        local aimOk, aimResult = pcall(bestEnemy)
        if aimOk and aimResult and aimResult:IsA("BasePart") then
            targetRoot = aimResult
        end
    end
    local targetCharacter = targetRoot and targetRoot.Parent
    local target = targetCharacter and Players:GetPlayerFromCharacter(targetCharacter)
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
    local recognizedRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot or not target or target == LP or target.Parent ~= Players
        or not targetCharacter or not targetCharacter:IsDescendantOf(workspace)
        or Players:GetPlayerFromCharacter(targetCharacter) ~= target
        or not targetHumanoid or targetHumanoid.Health <= 0
        or not recognizedRoot or recognizedRoot ~= targetRoot then
        _G.RanaVSWebSlingerAimTarget = nil
        NMNotify("❌ No recognized living player locked by WebSlinger aim", false)
        return
    end
    local dist = (recognizedRoot.Position - localRoot.Position).Magnitude
    if dist > 100 then
        NMNotify("❌ WebSlinger aim target is out of range", false)
        return
    end
    NM_isKilling = true
    NM_currentTarget = target
    _G.RanaVSNMStickyTarget = target
    _G.RanaVSWebSlingerAimTarget = target
    NMSetupDeathDetection(target)
    NMNotify(string.format("🎯 Locked %s (%.0f studs)", target.Name, dist or 0), true)
    if _G.RanaVSRefreshWebsingerBtn then task.defer(_G.RanaVSRefreshWebsingerBtn) end

    local above = true
    local updateAccumulator = 0
    NM_killLoop = RS.Heartbeat:Connect(function(dt)
        -- Target CFrame/ESP work was running at every rendered physics frame (60+ Hz).
        -- Keep the same alternating movement logic at 12 Hz to avoid flooding physics/network updates.
        updateAccumulator = updateAccumulator + (tonumber(dt) or 0)
        if updateAccumulator < (1 / 12) then return end
        updateAccumulator = 0

        if not NMHasWebSlinger() then
            _G.RanaVSNMStopKill("tool-lost")
            return
        end
        local currentTarget = NM_currentTarget
        if not currentTarget or currentTarget.Parent ~= Players then
            _G.RanaVSNMStopKill("target-lost")
            return
        end
        local targetChar = currentTarget.Character
        if not targetChar or not targetChar:IsDescendantOf(workspace) or Players:GetPlayerFromCharacter(targetChar) ~= currentTarget then
            _G.RanaVSNMStopKill("target-lost")
            return
        end
        local tHrp = targetChar:FindFirstChild("HumanoidRootPart")
        local tHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        -- Check confirmed death before treating a missing root as a disconnect;
        -- this ensures the post-kill Flying Carpet swap runs reliably.
        if tHumanoid and tHumanoid.Health <= 0 then
            _G.RanaVSNMStopKill("target-dead")
            return
        end
        if not tHrp or not tHumanoid then
            _G.RanaVSNMStopKill("target-lost")
            return
        end
        local localChar = LP.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localRoot or (tHrp.Position - localRoot.Position).Magnitude > 100 then
            _G.RanaVSNMStopKill("target-lost")
            return
        end
        if above then
            tHrp.CFrame = tHrp.CFrame + Vector3.new(0, 20, 0)
        else
            tHrp.CFrame = tHrp.CFrame + Vector3.new(0, -20, 0)
        end
        above = not above
        NMUpdateESP(currentTarget)
    end)

    task.delay(10, function()
        if NM_isKilling then _G.RanaVSNMStopKill("timeout") end
    end)
end

-- Grab detection: keep the same recognition logic, but cache it at 4 Hz instead of scanning
-- Workspace:GetChildren() on every Heartbeat (which was a recurring avoidable FPS cost).
local NMGrabCached = false
local function NMScanGrabbingPlayer()
    local char = LP.Character
    if not char then return false end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("RopeConstraint") then
            local a0, a1 = obj.Attachment0, obj.Attachment1
            if a0 and a1 then
                local p0, p1 = a0.Parent, a1.Parent
                local myChar, otherChar = nil, nil
                if p0 and p0:IsA("BasePart") then
                    local pc = p0.Parent
                    if pc == char then myChar = pc
                    elseif pc and Players:GetPlayerFromCharacter(pc) and Players:GetPlayerFromCharacter(pc) ~= LP then otherChar = pc end
                end
                if p1 and p1:IsA("BasePart") then
                    local pc = p1.Parent
                    if pc == char then myChar = pc
                    elseif pc and Players:GetPlayerFromCharacter(pc) and Players:GetPlayerFromCharacter(pc) ~= LP then otherChar = pc end
                end
                if myChar and otherChar then return true end
            end
        end
    end
    return false
end
_G.RanaVSIsGrabbingPlayer = function()
    return NMGrabCached == true
end

function _G.RanaVSNMKillToggle()
    if NM_isKilling then
        _G.RanaVSNMStopKill("manual")
    else
        _G.RanaVSNMStartKill()
    end
end
-- ═══════════════ END NOVAMOON KILL PORT ═══════════════

local function runWebsingerAction()
    -- This action runs only when the user presses the mobile button or its keybind.
    -- It aims the equipped Web Slinger using the existing Tool Aimbot target, then
    -- activates the Tool normally. It does not force another character's CFrame.
    local tool = findWebSlingerTool()
    if not tool then
        warn("[12Hub] Web Slinger not found in Character or Backpack.")
        return
    end

    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid or humanoid.Health <= 0 then return end

    if tool.Parent ~= char then
        local equipped = pcall(function() humanoid:EquipTool(tool) end)
        if not equipped then return end
        task.wait(0.12)
    end
    if tool.Parent ~= char then
        warn("[12Hub] Web Slinger could not be equipped.")
        return
    end

    -- Use the same nearby target selected by the existing Tool Aimbot.
    local targetRoot = nil
    if type(bestEnemy) == "function" then
        local ok, result = pcall(bestEnemy)
        if ok then targetRoot = result end
    end
    if not targetRoot or not targetRoot.Parent or not targetRoot:IsA("BasePart") then
        warn("[12Hub] No valid nearby Tool Aimbot target (within its normal range).")
        if _G.RanaVSRefreshWebsingerBtn then task.defer(_G.RanaVSRefreshWebsingerBtn) end
        return
    end

    local targetCharacter = targetRoot.Parent
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    if not targetPlayer or targetPlayer == LP or targetPlayer.Parent ~= Players
        or Players:GetPlayerFromCharacter(targetCharacter) ~= targetPlayer
        or not targetHumanoid or targetHumanoid.Health <= 0 then
        warn("[12Hub] Aimbot target is no longer a recognized living player.")
        _G.RanaVSWebSlingerAimTarget = nil
        return
    end
    _G.RanaVSWebSlingerAimTarget = targetPlayer

    -- Set the PlayerMouse aim immediately before activation so this press uses
    -- the current target rather than waiting for the next RenderStepped update.
    local pm = nil
    if type(getMouse) == "function" then
        local ok, result = pcall(getMouse)
        if ok then pm = result end
    end
    if pm then
        pcall(function()
            local velocity = targetRoot.AssemblyLinearVelocity or Vector3.zero
            pm.Hit = CFrame.new(targetRoot.Position + velocity * 0.1)
            pm.Target = targetRoot
        end)
    elseif type(overrideMouse) == "function" then
        pcall(overrideMouse)
    end

    local activated, err = pcall(function() tool:Activate() end)
    if not activated then
        warn("[12Hub] Web Slinger activation failed:", err)
    end

    if _G.RanaVSRefreshWebsingerBtn then
        task.defer(_G.RanaVSRefreshWebsingerBtn)
    end
end

local function refreshToolButtonVisuals()
    local medEquipped = isEquippedExact("Medusa")
    local psEquipped = isEquippedExact("Paintball Gun")
    St.medOn = medEquipped
    St.psOn = psEquipped
    local med = actRefs and actRefs.med
    local ps = actRefs and actRefs.ps
    if med and med.btn then
        applyActBtnState(med.btn, false, "MED\nEQUIP", "MED\nEQUIP")
    end
    if ps and ps.btn then
        applyActBtnState(ps.btn, psEquipped, "PS", "PS")
    end
end

local function setMedButton()
    local tool = equipExactTool("Medusa")
    St.medOn = tool ~= nil and isEquippedExact("Medusa") or false
    refreshToolButtonVisuals()
end

local function stopPS()
    St.psOn = false
    if psLoopConn then
        pcall(function() psLoopConn:Disconnect() end)
        psLoopConn = nil
    end
    refreshToolButtonVisuals()
end

local function startPS()
    local tool = equipExactTool("Paintball Gun")
    if not tool or not isEquippedExact("Paintball Gun") then
        St.psOn = false
        refreshToolButtonVisuals()
        return
    end
    St.psOn = true
    if psLoopConn then pcall(function() psLoopConn:Disconnect() end) end
    psLoopConn = RS.Heartbeat:Connect(function()
        if not St.psOn then return end
        local current = LP.Character and LP.Character:FindFirstChild("Paintball Gun")
        -- Do not re-equip from Backpack. Selecting another Tool must turn PS off.
        if not current or not current:IsA("Tool") or current.Name ~= "Paintball Gun" then
            stopPS()
            return
        end
        pcall(function() current:Activate() end)
    end)
    refreshToolButtonVisuals()
end

local function togglePS()
    if isEquippedExact("Paintball Gun") then
        stopPS()
    else
        startPS()
    end
end

-- LaPeak-style equipped-tool watcher. Visual state is based on the Tool actually
-- held by the player; merely owning the Tool in Backpack does not keep the button ON.
if not _G.__RanaLaPeakToolVisualWatcher then
    _G.__RanaLaPeakToolVisualWatcher = true
    local function hookCharacter(char)
        if not char then return end
        char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") and (obj.Name == "Paintball Gun" or obj.Name == "Medusa") then
                task.defer(refreshToolButtonVisuals)
            end
        end)
        char.ChildRemoved:Connect(function(obj)
            if obj:IsA("Tool") and (obj.Name == "Paintball Gun" or obj.Name == "Medusa") then
                task.defer(refreshToolButtonVisuals)
            end
        end)
        task.defer(refreshToolButtonVisuals)
    end
    if LP.Character then hookCharacter(LP.Character) end
    LP.CharacterAdded:Connect(function(char)
        if psLoopConn then pcall(function() psLoopConn:Disconnect() end); psLoopConn = nil end
        St.psOn = false
        St.medOn = false
        hookCharacter(char)
    end)
end
local function flashActionButton(entry)
    if not entry or not entry.btn or not entry.btn.Parent then return end
    local btn = entry.btn
    local stroke = entry.stroke
    local grad = entry.gradient
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamMedium
    if stroke then
        stroke.Color = Color3.fromRGB(255,255,255)
        stroke.Thickness = 1.8
        stroke.Transparency = 0.05
    end
    if grad then
        grad.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
        grad.Transparency = NumberSequence.new(0)
    end
    task.delay(0.12, function()
        if entry.btn and entry.btn.Parent then
            if entry.key == "drop" or entry.key == "tp" or entry.key == "tpBest" or entry.key == "insta" or entry.key == "med" then
                -- Momentary action buttons always return to the normal white/black-text state.
                entry.btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
                entry.btn.BackgroundTransparency = 0
                entry.btn.TextColor3 = Color3.fromRGB(25,25,30)
                entry.btn.Font = Enum.Font.GothamMedium
                if entry.stroke then
                    entry.stroke.Color = Color3.fromRGB(105,105,112)
                    entry.stroke.Thickness = 1.15
                    entry.stroke.Transparency = 0.05
                end
                if entry.gradient then
                    entry.gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
                    })
                    entry.gradient.Transparency = NumberSequence.new(0)
                end
                entry.btn.Text = entry.offText
            else
                local on = false
                if entry.key == "steal" then on = St.autoSteal == true end
                if entry.key == "sentry" then on = St.destroySentry == true end
                if entry.key == "ps" then on = isEquippedExact("Paintball Gun") end
                applyActBtnState(entry.btn, on, entry.onText, entry.offText)
            end
        end
    end)
end

function makeActBtn(key, label, pos, cb)
    local baseSz = (St.btnSizes[key] or 50)
    local sz = math.max(28, math.floor(baseSz * (St.btnScale or 1)))

    local holder = Instance.new("Frame")
    holder.Name = "A_" .. key
    holder.Size = UDim2.fromOffset(sz, sz)
    holder.Position = pos
    holder.BackgroundTransparency = 1
    holder.Active = true
    holder.ZIndex = 50
    holder.Parent = ActGui

    local btn = Instance.new("TextButton")
    btn.Name = "LaPeakMobileButton"
    btn.Size = UDim2.fromScale(1,1)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(25,25,30)
    btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
    btn.Font = Enum.Font.GothamMedium
    btn.TextWrapped = true
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Selectable = true
    btn.Modal = false
    btn.ZIndex = 100
    btn.Parent = holder

    applyCorner(btn, St.btnShape or "FOUNDED")
    applyCornerToChildren(btn, St.btnShape or "FOUNDED")

    local stroke = Instance.new("UIStroke")
    stroke.Name = "BtnBorder"
    stroke.Color = Color3.fromRGB(105,105,112)
    stroke.Thickness = 1.15
    stroke.Transparency = 0.05
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    local grad = Instance.new("UIGradient")
    grad.Name = "LaPeakButtonGradient"
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
    })
    grad.Transparency = NumberSequence.new(0)
    grad.Parent = btn

    local pressScale = Instance.new("UIScale")
    pressScale.Name = "LaPeakPressScale"
    pressScale.Scale = 1
    pressScale.Parent = holder

    local entry = {
        holder=holder, btn=btn, stroke=stroke, gradient=grad, key=key,
        state=false, onText=label, offText=label
    }
    actRefs[key] = entry

    local function paint(active, pressed)
        local on = active == true or pressed == true
        btn.BackgroundColor3 = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0
        btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,25,30)
        btn.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
        stroke.Color = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(105,105,112)
        stroke.Thickness = on and 1.8 or 1.15
        stroke.Transparency = 0.05
        if on then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(185,185,190)),
                ColorSequenceKeypoint.new(0.62, Color3.fromRGB(72,72,78)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8,8,10)),
            })
        else
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
            })
        end
    end

    entry.setVisual = function(active, pressed)
        entry.state = active == true
        paint(active, pressed)
    end

    local function stateForButton()
        if key == "steal" then return St.autoSteal == true end
        if key == "sentry" then return St.destroySentry == true end
        if key == "ps" then return isEquippedExact("Paintball Gun") end
        if key == "med" then return false end
        if key == "antiTrap" then return St.antiTrap == true end
        if key == "websinger" then return isWebSlingerEquipped() end
        return false
    end

    local down, dragging, inputStart, startPos, dragInput, suppress = false, false, nil, nil, nil, false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        down = true
        dragging = false
        suppress = false
        inputStart = input.Position
        startPos = holder.Position
        btn:SetAttribute("LaPeakPressed", true)
        if key == "drop" or key == "tp" or key == "tpBest" or key == "insta" or key == "med" then
            -- Action buttons use a brief black/white flash only; never keep
            -- the pressed/bold state while the input is held.
            paint(false, false)
        else
            paint(stateForButton(), true)
        end
        pcall(function()
            TS:Create(pressScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=0.92}):Play()
        end)
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not down or St.guiLock or not inputStart then return end
        if input ~= dragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - inputStart
        if delta.Magnitude > 6 then dragging = true; suppress = true end
        if dragging then
            holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not down then return end
        local wasDrag = dragging
        down = false
        dragging = false
        dragInput = nil
        btn:SetAttribute("LaPeakPressed", false)
        pcall(function()
            TS:Create(pressScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1}):Play()
        end)
        if wasDrag and not St.guiLock then savePos(holder, "A_" .. key) end
    end)

    btn.Activated:Connect(function()
        -- LaPeak input model: Activated is the click/tap event. Do not require
        -- `down == false` here because on touch Activated may fire before
        -- InputEnded; that old guard made every mobile action look clickable
        -- while never executing its callback.
        if suppress or dragging then
            suppress = false
            return
        end
        pcall(cb)
        if key == "drop" or key == "tp" or key == "tpBest" or key == "insta" or key == "med" then
            flashActionButton(entry)
        elseif key == "steal" then
            task.defer(function() applyActBtnState(btn, St.autoSteal == true, "STEAL ON", "AUTO STEAL") end)
        elseif key == "sentry" then
            task.defer(function() applyActBtnState(btn, St.destroySentry == true, "DESTROY ON", "DESTROY") end)
        elseif key == "ps" then
            task.defer(refreshToolButtonVisuals)
        elseif key == "antiTrap" then
            task.defer(function() applyActBtnState(btn, St.antiTrap == true, "ANTI\nTRAP ON", "ANTI\nTRAP") end)
        elseif key == "websinger" then
            task.defer(function()
                if _G.RanaVSRefreshWebsingerBtn then _G.RanaVSRefreshWebsingerBtn() end
            end)
        else
            paint(stateForButton(), false)
        end
    end)

    entry.onText = (key == "steal" and "STEAL ON") or (key == "sentry" and "DESTROY ON") or (key == "antiTrap" and "ANTI\nTRAP ON") or (key == "websinger" and "KILL") or label
    entry.offText = (key == "steal" and "AUTO STEAL") or (key == "sentry" and "DESTROY") or (key == "antiTrap" and "ANTI\nTRAP") or (key == "tpBest" and "TP\nBEST") or (key == "websinger" and "WEBSINGER") or label
    paint(stateForButton(), false)
    return entry
end

function restorePos(holder, key, defaultPos)
	local t = St._btnPos and St._btnPos[key]
	if type(t) == "table" and t[1] ~= nil then
 holder.Position = UDim2.new(tonumber(t[1]) or 0, tonumber(t[2]) or 0, tonumber(t[3]) or 0, tonumber(t[4]) or 0)
 if t[5] and t[6] then
 local s = tonumber(t[5])
 local h = tonumber(t[6])
 if s and h and s > 10 and h > 10 then
 holder.Size = UDim2.new(0, s, 0, h)
 end
 end
	elseif defaultPos then
 holder.Position = defaultPos
	end
end

function savePos(holder, key)
	St._btnPos = St._btnPos or {}
	St._btnPos[key] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 holder.Size.X.Offset, holder.Size.Y.Offset
	}
	saveCfg()
end

function rebuildMobile()
	for _, e in pairs(modeRefs) do if e.holder then e.holder:Destroy() end end
	for _, e in pairs(actRefs) do if e.holder then e.holder:Destroy() end end
	modeRefs, actRefs = {}, {}
	-- Full Speed V2 GUI bar (authoritative 3-mode speed UI)
	pcall(function()
 if ModeGui then
 for _, ch in ipairs(ModeGui:GetChildren()) do
 if ch:IsA("Frame") and tostring(ch.Name):match("^M_") then
 ch.Visible = false
 end
 end
 end
 if _G.RanaVSBuildV2ModeBar then _G.RanaVSBuildV2ModeBar() end
 if St.speedOn then
 currentSpeedValue = getActiveMoveSpeed()
 pcall(startSpeedBoost)
 end
	end)
	makeActBtn("drop", "DROP", UDim2.new(1, -150, 0.5, -40), function()
        runDrop()
        if _G.RanaVSCounterOnDrop then pcall(_G.RanaVSCounterOnDrop) end
    end)
	makeActBtn("insta", St.instaMode == "V2" and "INSTA\nRESET" or "FAST\nRESET", UDim2.new(1, -80, 0.5, -40), function()
        doInstaReset()
    end)
	makeActBtn("tp", "TP\nDOWN", UDim2.new(1, -230, 0.5, 30), function()
        doTPDown(true)
    end)
	makeActBtn("sentry", "DESTROY", UDim2.new(1, -150, 0.5, 30), function()
 local on = not (St.destroySentry == true)
 if type(setDestroySentry) == "function" then
 setDestroySentry(on)
 else
 St.destroySentry = on
 end
 if _G.RanaVSRefreshSentryBtn then pcall(_G.RanaVSRefreshSentryBtn) end
	end)
	makeActBtn("steal", "AUTO\nSTEAL", UDim2.new(1, -150, 0.5, 100), function()
 local on = not (St.autoSteal == true)
 if type(setAutoSteal) == "function" then
 setAutoSteal(on)
 elseif type(_G.setAutoSteal) == "function" then
 _G.setAutoSteal(on)
  else
  St.autoSteal = on
  autoStealEnabled = on
  end
 if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
 if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
 pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
 end
	end)
	makeActBtn("med", "MED\nEQUIP", UDim2.new(1, -80, 0.5, -110), function()
        setMedButton()
    end)
	makeActBtn("ps", "PS", UDim2.new(1, -150, 0.5, -110), function()
        togglePS()
    end)
	makeActBtn("tpBest", "TP\nBEST", UDim2.new(1, -80, 0.5, 30), function()
	  local action = _G.RanaVSTPBestTeleport
	  if type(action) == "function" then pcall(action) end
	end)
	makeActBtn("antiTrap", "ANTI\nTRAP", UDim2.new(1, -80, 0.5, 100), function()
	  if type(setAntiTrap) == "function" then
		setAntiTrap(not (St.antiTrap == true))
	  end
	  if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
	end)
    makeActBtn("websinger", "WEBSINGER", UDim2.new(1, -230, 0.5, 100), function()
        _G.RanaVSNMKillToggle()
    end)
	-- restore saved positions
	for key, e in pairs(actRefs) do
 if e.holder then restorePos(e.holder, "A_" .. key) end
	end
	for key, e in pairs(modeRefs) do
 if e.holder then restorePos(e.holder, "M_" .. key) end
	end
	_G.RanaVSRefreshModeBar()
	_G.RanaVSRefreshSentryBtn()
	if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
	if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
end



-- Empire-style: nút ON = xanh đậm rõ, OFF = tối
function applyActBtnState(btn, on, onText, offText)
    if not btn then return end
    on = on == true
    btn.BackgroundColor3 = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency = 0
    btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,25,30)
    btn.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
    if onText and on then btn.Text = onText elseif offText and not on then btn.Text = offText end
    local grad = btn:FindFirstChild("LaPeakButtonGradient")
    if grad then
        grad.Color = on and ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(185,185,190)),
            ColorSequenceKeypoint.new(0.62, Color3.fromRGB(72,72,78)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8,8,10)),
        }) or ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
        })
        grad.Transparency = NumberSequence.new(0)
    end
    local stroke = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(105,105,112)
        stroke.Thickness = on and 1.8 or 1.15
        stroke.Transparency = 0.05
    end
end

function _G.RanaVSRefreshStealBtn()
	local e = actRefs and actRefs.steal
	if not e or not e.holder then return end
	local show = (St.showStealBtn ~= false)
	e.holder.Visible = show
	if e.btn then
 e.btn.Visible = show
 applyActBtnState(e.btn, St.autoSteal == true, "STEAL\nON", "AUTO\nSTEAL")
	end
end

function _G.RanaVSRefreshSentryBtn()
	local e = actRefs and actRefs.sentry
	if e and e.btn then
 applyActBtnState(e.btn, St.destroySentry == true, "DESTROY\nON", "DESTROY")
	end
end


function _G.RanaVSRefreshAntiTrapBtn()
	local e = actRefs and actRefs.antiTrap
	if e and e.btn then
	 applyActBtnState(e.btn, St.antiTrap == true, "ANTI\nTRAP ON", "ANTI\nTRAP")
	end
end

function _G.RanaVSRefreshWebsingerBtn()
    local e = actRefs and actRefs.websinger
    if not e or not e.btn then return end
    local grabbing = NMGrabCached == true
    local equipped = isWebSlingerEquipped() or grabbing
    local killing = (type(_G.RanaVSNMKillState) == "function" and _G.RanaVSNMKillState()) or false
    e.onText = killing and "STOP" or "KILL"
    e.offText = "WEBSINGER"
    applyActBtnState(e.btn, equipped, e.onText, "WEBSINGER")
end

-- Low-frequency grab watcher: update the cached detected-player state at 4 Hz.
local NMGrabAccumulator = 0
RS.Heartbeat:Connect(function(dt)
    NMGrabAccumulator = NMGrabAccumulator + (tonumber(dt) or 0)
    if NMGrabAccumulator < 0.25 then return end
    NMGrabAccumulator = 0
    if NM_isKilling then return end
    local wasGrabbing = NMGrabCached
    NMGrabCached = NMScanGrabbingPlayer()
    _G.RanaVSCachedWebSlingerGrab = NMGrabCached
    if wasGrabbing ~= NMGrabCached and _G.RanaVSRefreshWebsingerBtn then
        task.defer(_G.RanaVSRefreshWebsingerBtn)
    end
end)

function _G.RanaVSRefreshModeBar()
    for n, e in pairs(modeRefs) do
        if e and e.btn then
            local isActive = St.activeMode == n
            applyCorner(e.btn, "FOUNDED")
            if e.style then
                pcall(e.style, isActive)
            else
                setAceModeVisual(e.btn, isActive)
            end
            local label = e.btn:FindFirstChild("BtnTextOverlay")
            if label then
                label.TextColor3 = isActive and ACE_MODE.white or ACE_MODE.muted
                label.Text = n
            else
                e.btn.TextColor3 = isActive and ACE_MODE.white or ACE_MODE.muted
            end
        end
    end
end

-- Cập nhật size + shape TRỰC TIẾP (không destroy → giữ vị trí kéo)
_G.RanaVSForceApplyShape = function(shape)
	shape = shape or (St and St.btnShape) or "FOUNDED"
	if St then St.btnShape = shape end
	local refs = actRefs
	if type(refs) ~= "table" then return end
	for key, e in pairs(refs) do
 if e and e.btn then
 pcall(function()
 applyCorner(e.btn, shape)
 if applyCornerToChildren then applyCornerToChildren(e.btn, shape) end
 end)
 end
	end
end

function _G.RanaVSUpdateMobileVisuals()
	for n, e in pairs(modeRefs) do
 if e and e.holder and e.btn then
 local w = 98
 local h = 36
 e.holder.Size = UDim2.new(0, w, 0, h)
 e.btn.TextSize = math.clamp(math.floor(h * 0.36), 11, 14)
 local c = e.btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", e.btn)
 c.CornerRadius = UDim.new(0, 12) -- V2 bo góc chữ nhật
 if e.style then e.style(St.activeMode == n) end
 end
	end
	for key, e in pairs(actRefs) do
 if e and e.holder and e.btn then
 local base = (St.btnSizes[key] or 70)
 local sz = math.max(28, math.floor(base * (St.btnScale or 1)))
 e.holder.Size = UDim2.new(0, sz, 0, sz)
 e.btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
 applyCorner(e.btn, St.btnShape or "Round")
 applyCornerToChildren(e.btn, St.btnShape or "Round")
 -- viền
 local s = e.btn:FindFirstChild("BtnBorder") or e.btn:FindFirstChildOfClass("UIStroke")
 if not s then
 s = Instance.new("UIStroke")
 s.Name = "BtnBorder"
 s.Parent = e.btn
 end
 s.Color = Color3.fromRGB(220, 220, 235)
 s.Thickness = 2
 s.Transparency = 0.15
 end
	end
	if _G.RanaVSRefreshModeBar then pcall(_G.RanaVSRefreshModeBar) end
	if _G.RanaVSRefreshSentryBtn then pcall(_G.RanaVSRefreshSentryBtn) end
	if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
	if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
    if _G.RanaVSRefreshWebsingerBtn then pcall(_G.RanaVSRefreshWebsingerBtn) end
	local med = actRefs and actRefs.med; if med and med.btn then applyActBtnState(med.btn, false, "MED\nEQUIP", "MED\nEQUIP") end
	local ps = actRefs and actRefs.ps; if ps and ps.btn then applyActBtnState(ps.btn, isEquippedExact("Paintball Gun"), "PS", "PS") end
	-- Apply each Speed V2 mode size independently; never use one shared scale.
	pcall(function()
        if _G.RanaVSApplySpeedModeSizes then
            _G.RanaVSApplySpeedModeSizes()
        end
    end)
end

function _G.RanaVSApplyMobile()
	ModeGui.Enabled = false
	ActGui.Enabled = St.mobileBtns == true
	local hasMode = next(modeRefs) ~= nil
	local hasAct = next(actRefs) ~= nil
	if not hasMode or not hasAct then
 rebuildMobile()
	end
	-- luôn áp shape/size (Box/Round/Square) kể cả khi đã có nút
	if _G.RanaVSUpdateMobileVisuals then pcall(_G.RanaVSUpdateMobileVisuals) end
end
function _G.RanaVSResetMobilePos()
	St._btnPos = {}
	rebuildMobile()
	pcall(saveCfg)
end
_G.RanaVSApplyMobile()

----------------------------------------------------------------
-- KEYBINDS (Drop / TP / Insta / Sentry / Auto Steal) — no speed-mode keybind
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
	if gp or listening or _G.RanaVSKeybindingCapture == true or _G._12HubCapturingStealSpeedKey == true then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local k = input.KeyCode
    -- Manual keybind is available only when Auto Change on Steal is OFF.
    if St.autoChangeOnSteal ~= true and St.stealSpeedKey ~= "None" and k.Name == St.stealSpeedKey then
        setStealSpeedActive2(true)
        return
    end
	for modeName, modeKey in pairs(St.speedKeys or {}) do
		if modeKey and k == modeKey then setActiveMode(modeName); return end
	end
	if k == St.keys.Drop then runDrop()
	elseif k == St.keys.TPDown then doTPDown(true)
	elseif k == St.keys.InstaReset then doInstaReset()
	elseif k == St.keys.DestroySentry then setDestroySentry(not St.destroySentry)
	elseif St.keys.AutoSteal and St.keys.AutoSteal ~= "None" and k == St.keys.AutoSteal then
  if type(setAutoSteal) == "function" then
   setAutoSteal(not (St.autoSteal == true))
   if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
    pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
   end
  end
	elseif St.keys.TpBest and St.keys.TpBest ~= "None" and k == St.keys.TpBest then
  local action = _G.RanaVSTPBestTeleport
  if type(action) == "function" then pcall(action) end
	elseif St.keys.MedEquip and St.keys.MedEquip ~= "None" and k == St.keys.MedEquip then
  if type(setMedButton) == "function" then pcall(setMedButton) end
	elseif St.keys.AntiTrap and St.keys.AntiTrap ~= "None" and k == St.keys.AntiTrap then
  if type(setAntiTrap) == "function" then pcall(setAntiTrap, not (St.antiTrap == true)) end
  if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
    elseif St.keys.Websinger and St.keys.Websinger ~= "None" and k == St.keys.Websinger then
        if type(runWebsingerAction) == "function" then pcall(runWebsingerAction) end
	end
end)

----------------------------------------------------------------
-- BOOT
----------------------------------------------------------------

-- ============================================================
-- REAPPLY ALL LOGIC (fix/rejoin/respawn) — không nút ảo
-- ============================================================
function reapplyAllLogic(reason)
	reason = tostring(reason or "boot")
	-- Speed
	pcall(function()
 if St.speedOn then
 -- force restart loop
 if speedConnection then
 pcall(function() speedConnection:Disconnect() end)
 speedConnection = nil
 end
 startSpeedBoost()
 if St.activeMode and setActiveMode then setActiveMode(St.activeMode) end
 else
 if stopSpeedBoost then stopSpeedBoost() end
 end
	end)
	-- Inf Jump
	pcall(function()
 if St.infJump then
 InfJumpState.enabled = true
 InfJumpState.mode = St.infJumpMode or "hold"
 if startInfJump then startInfJump() elseif setInfJump then setInfJump(true) end
 else
 if stopInfJump then stopInfJump() end
 end
	end)
	-- Anti Bee
	pcall(function()
	  if St.antiBee then
		if _G.RanaVSStartAntiBee then _G.RanaVSStartAntiBee() end
	  elseif _G.RanaVSStopAntiBee then
		_G.RanaVSStopAntiBee()
	  end
	end)
	-- Anti Trap
	pcall(function()
	  if St.antiTrap then
		if type(setAntiTrap) == "function" then setAntiTrap(true) end
	  elseif type(setAntiTrap) == "function" then
		setAntiTrap(false)
	  end
	end)
	-- Anti ragdoll
	pcall(function()
 if St.antiRagdoll then
 if AntiRagdollV2 then AntiRagdollV2.Enabled = true end
 if startAntiRagdoll then startAntiRagdoll() end
 else
 if stopAntiRagdoll then stopAntiRagdoll() end
 end
	end)
	-- Anti FX flags
	pcall(function()
 if AntiFX then
 AntiFX.gummy = true
 AntiFX.boogie = true
 AntiFX.paint = true
 St.antiGummy = true
 St.antiBoogie = true
 St.antiPaint = true
 end
	end)
	-- Tool aim (Chilli runtime)
	pcall(function()
        if type(setToolAim) == "function" then setToolAim(St.toolAim == true, true) end
	end)
	-- Destroy sentry
	pcall(function()
 if St.destroySentry and setDestroySentry then setDestroySentry(true) end
	end)
	-- ESP / tracer / antilag
	pcall(function() if St.esp and setESP then setESP(true) end end)
	pcall(function() if St.tracer and setTracer then setTracer(true) end end)
	pcall(function() if St.antiLag and setAntiLag then setAntiLag(true) end end)
	-- Spam
	pcall(function() if St.spamLaser and setSpamLaser then setSpamLaser(true) end end)
	pcall(function() if St.spamPaint and setSpamPaint then setSpamPaint(true) end end)
	-- Auto steal
	pcall(function()
 if St.autoSteal then
 if type(setAutoSteal) == "function" then setAutoSteal(true) end
 if _G.RanaVSSyncAutoSteal then pcall(_G.RanaVSSyncAutoSteal) end
 end
	end)
	-- Ragdoll TP
	pcall(function()
	end)
	-- Mobile buttons
	pcall(function()
 if ModeGui then ModeGui.Enabled = St.mobileBtns == true end
 if ActGui then ActGui.Enabled = St.mobileBtns == true end
 if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
	end)
	-- Sync toggle UI + ép logic chạy nếu đang ON
	pcall(function()
 for name, ref in pairs(ToggleRefs or {}) do
 if ref and St[name] ~= nil then
 local on = St[name] == true
 if ref.setVisual then
 pcall(ref.setVisual, on)
 end
 end
 end
	end)
end
_G.RanaVSReapplyAllLogic = reapplyAllLogic


-- Re-apply ALL saved states so toggles that show ON actually work
pcall(function() setAntiGummy(St.antiGummy ~= false) end)
pcall(function() setAntiBee(St.antiBee == true) end)
pcall(function() setAntiTrap(St.antiTrap == true) end)
pcall(function() setAntiBoogie(St.antiBoogie ~= false) end)
pcall(function() setAntiPaint(St.antiPaint ~= false) end)
pcall(function() setAntiRagdoll(St.antiRagdoll == true) end)
pcall(function() setToolAim(St.toolAim ~= false) end)
pcall(function() setInfJump(St.infJump ~= false) end)
pcall(function() setDestroySentry(St.destroySentry == true) end)
pcall(function() setSpeedOn(St.speedOn ~= false) end)
pcall(function() setActiveMode(St.activeMode or "Normal") end)
pcall(function() setESP(St.esp == true) end)
pcall(function() setTracer(St.tracer == true) end)
pcall(function() setAntiLag(St.antiLag == true) end)
pcall(function() setFPSCap(St.fpsCap, false) end)
pcall(function() setNukeOptimizer(St.nukeOptimiserEnabled == true) end)
pcall(function() setOptimizer(St.optimizerEnabled == true, true) end)
pcall(function() setSpamLaser(St.spamLaser == true) end)
pcall(function() setSpamPaint(St.spamPaint == true) end)
-- Auto Steal after setups exist
task.defer(function()
	pcall(function()
 if type(setAutoSteal) == "function" then
 setAutoSteal(St.autoSteal == true)
 end
 if St.autoSteal and _G.RanaVSSyncAutoSteal then
 pcall(_G.RanaVSSyncAutoSteal)
 end
	end)
end)
-- Legacy menu bootstrap removed; LaPeak menu owns initial tab.
task.defer(function()
	task.wait(0.6)
	pcall(function() if reapplyAllLogic then reapplyAllLogic("boot") end end)
end)
task.defer(function()
	-- rejoin server: re-apply sau 2s (chờ character/plot load)
	task.wait(2)
	pcall(function() if reapplyAllLogic then reapplyAllLogic("boot-delayed") end end)
end)
-- Sync toggle UI to match actual state
task.defer(function()
	-- sync toggle UI
	for name, ref in pairs(ToggleRefs or {}) do
 if ref and ref.set and St[name] ~= nil then
 pcall(function() ref.set(St[name] == true) end)
 end
	end
	-- force-apply runtime features (sau load / rejoin) — logic thật, không chỉ UI
	pcall(function() if St.speedOn and startSpeedBoost then startSpeedBoost() end end)
	pcall(function() if St.antiRagdoll and startAntiRagdoll then startAntiRagdoll() end end)
	pcall(function()
 if St.infJump then
 InfJumpState.enabled = true
 InfJumpState.mode = St.infJumpMode or "hold"
 end
	end)
	pcall(function() if St.toolAim and setToolAim then setToolAim(true) end end)
	pcall(function()
 if ModeGui then ModeGui.Enabled = St.mobileBtns == true end
 if ActGui then ActGui.Enabled = St.mobileBtns == true end
 if next(modeRefs) == nil or next(actRefs) == nil then
 if _G.RanaVSApplyMobile then _G.RanaVSApplyMobile() end
 end
	end)
	pcall(function() if St.activeMode and setActiveMode then setActiveMode(St.activeMode) end end)
	pcall(function() if St.autoSteal and type(setAutoSteal) == "function" then setAutoSteal(true) end end)
	pcall(function() if St.destroySentry and setDestroySentry then setDestroySentry(true) end end)
end)


-- Re-apply features on respawn / rejoin (full logic, không nút ảo)
if _G._VisHubCharReapplyConn then
	pcall(function() _G._VisHubCharReapplyConn:Disconnect() end)
	_G._VisHubCharReapplyConn = nil
end
_G._VisHubCharReapplyConn = LP.CharacterAdded:Connect(function(char)
	task.wait(0.4)
	pcall(function()
 if reapplyAllLogic then
 reapplyAllLogic("CharacterAdded")
 else
 if St.speedOn and startSpeedBoost then
 if speedConnection then pcall(function() speedConnection:Disconnect() end); speedConnection = nil end
 startSpeedBoost()
 end
 if St.infJump and setInfJump then setInfJump(true) end
 if St.antiRagdoll and startAntiRagdoll then startAntiRagdoll() end
 if St.toolAim and setToolAim then setToolAim(true) end
 if St.autoSteal and _G.RanaVSSyncAutoSteal then pcall(_G.RanaVSSyncAutoSteal) end
 end
	end)
end)

print("[12Hub Full] Player(Anti+Speed S2+Aim+Drop+Insta) | ESP | Settings mobile/lock/shape/size")



-- ============================================================
-- EXTENSION: InfJump 2-mode | FULL LAPEAK AUTO STEAL V1/V2 | Steal Bar | Panel TP
-- [12Hub] FULL LAPEAK AUTO STEAL ENGINE: Normal V1/V2 + Semi V1/V2
-- ============================================================
-- AUTO STEAL ENGINE: Ambitious Normal -> Lonely Normal V1
-- Ambitious percentage engine -> Lonely Normal V2 (Pause %; default 75; reset budget 5s)
-- Ambitious Semi V1/V2 -> Lonely Semi V1/V2
-- No public Semi V3 selector; Semi exposes V1/V2 only.
-- ============================================================
_G.AmbitiousStealRadii = _G.AdaptStealRadii or _G.AmbitiousStealRadii or {
    Normal = 62, Semi = 60, SemiV2Radius = 60, SemiV2SemiRadius = 8
}
_G.AdaptStealRadii = _G.AmbitiousStealRadii
_G.AmbitiousStealRadii.Normal = tonumber(_G.AmbitiousStealRadii.Normal) or 62
_G.AmbitiousStealRadii.Semi = tonumber(_G.AmbitiousStealRadii.Semi) or 60
_G.AmbitiousStealRadii.SemiV2Radius = tonumber(_G.AmbitiousStealRadii.SemiV2Radius) or 60
_G.AmbitiousStealRadii.SemiV2SemiRadius = tonumber(_G.AmbitiousStealRadii.SemiV2SemiRadius) or 8
_G.__AdaptSetupNormalAutoSteal = function()
  _G.AmbitiousNormalSteal = _G.AmbitiousNormalSteal or {
    enabled = false,
    radius = 62,
    duration = 1.3,
    animals = {},
    promptCache = {},
    internalCache = {},
    scannerStarted = false,
    scanning = false,
    isStealing = false,
    stealConn = nil,
    refreshThread = nil,
    lastSteal = 0,
    cooldown = 0.08,
  }
  if _G.AmbitiousNormalSteal.stealConn then pcall(function() _G.AmbitiousNormalSteal.stealConn:Disconnect() end); _G.AmbitiousNormalSteal.stealConn = nil end
  _G.AmbitiousNormalSteal.enabled = false
  _G.AmbitiousNormalSteal.isStealing = false

  local function barProgress(p)
    p = math.clamp(tonumber(p) or 0, 0, 1)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState("STEALING")
        _G.StealBar.SetProgress(p)
      end
    end)
  end

  local function resetBar()
    pcall(function()
      if _G.StealBar then _G.StealBar.Reset() end
    end)
  end

  local function getRoot()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
  end

  local function isMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    local yourBase = sign and sign:FindFirstChild("YourBase")
    return yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled == true
  end

  local function scanPlots()
    local a = _G.AmbitiousNormalSteal
    a.animals = {}
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
      if plot:IsA("Model") and not isMyBase(plot.Name) then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
          for _, podium in ipairs(podiums:GetChildren()) do
            if podium:IsA("Model") then
              local base = podium:FindFirstChild("Base")
              local spawn = base and base:FindFirstChild("Spawn")
              if spawn then
                table.insert(a.animals, {
                  plot = plot.Name,
                  slot = podium.Name,
                  worldPosition = spawn.Position,
                  uid = plot.Name .. "_" .. podium.Name,
                })
              end
            end
          end
        end
      end
    end
  end

  local function ensureScanner()
    local a = _G.AmbitiousNormalSteal
    if a.scannerStarted then return end
    a.scannerStarted = true
    task.spawn(function()
      task.wait(1)
      while _G.AmbitiousNormalSteal do
        if _G.AmbitiousNormalSteal.enabled then
          pcall(scanPlots)
        end
        task.wait(3)
      end
    end)
  end

  local function findPrompt(data)
    if not data then return nil end
    local a = _G.AmbitiousNormalSteal
    local cached = a.promptCache[data.uid]
    if cached and cached.Parent then return cached end
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(data.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    local podium = podiums and podiums:FindFirstChild(data.slot)
    local base = podium and podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, prompt in ipairs(attach:GetChildren()) do
      if prompt:IsA("ProximityPrompt") then
        a.promptCache[data.uid] = prompt
        return prompt
      end
    end
    return nil
  end

  local function cacheCallbacks(prompt)
    local a = _G.AmbitiousNormalSteal
    if a.internalCache[prompt] then return end
    local data = {hold = {}, trigger = {}, ready = true}
    pcall(function()
      if getconnections then
        for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
          if type(conn.Function) == "function" then table.insert(data.hold, conn.Function) end
        end
        for _, conn in ipairs(getconnections(prompt.Triggered)) do
          if type(conn.Function) == "function" then table.insert(data.trigger, conn.Function) end
        end
      end
    end)
    if #data.hold > 0 or #data.trigger > 0 then
      a.internalCache[prompt] = data
    end
  end

  -- Stesso identico check delle modalita' Semi: distanza dal prompt vivo
  -- (prompt.Parent.Parent = la parte Spawn), non da una posizione salvata.
  local function stillInRange(prompt)
    local a = _G.AmbitiousNormalSteal
    local root = getRoot()
    if not root or not prompt.Parent or not prompt.Parent.Parent then return false end
    return (root.Position - prompt.Parent.Parent.Position).Magnitude <= (tonumber(a.radius) or 62)
  end

  local function doSteal(prompt)
    local a = _G.AmbitiousNormalSteal
    if not prompt or not prompt.Parent or a.isStealing then return end
    if tick() - (a.lastSteal or 0) < (a.cooldown or 0.08) then return end
    cacheCallbacks(prompt)
    local data = a.internalCache[prompt]
    if not data or not data.ready then return end
    data.ready = false
    a.isStealing = true
    a.lastSteal = tick()
    pcall(function() if _G.StealBar then _G.StealBar.SetState("STEALING") end end)
    task.spawn(function()
      if #data.hold > 0 then
        for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end
      end
      local startTime = tick()
      local dur = 1.3
      a.duration = dur
      -- La barra si riempie in 1.25s e resta piena per gli ultimi 0.05s:
      -- cosi' il 100% e' visibile invece di comparire nello stesso frame del reset.
      local fillDur = math.max(dur - 0.05, 0.05)
      local aborted = false
      while a.enabled and selectedStealMode == "Normal" and tick() - startTime < dur do
        if not stillInRange(prompt) then
          aborted = true
          break
        end
        barProgress((tick() - startTime) / fillDur)
        task.wait(0.02)
      end
      if aborted or not a.enabled or selectedStealMode ~= "Normal" then
        data.ready = true
        a.isStealing = false
        resetBar()
        return
      end
      barProgress(1)
      if #data.trigger > 0 then
        for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end
      end
      pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
      -- Engine restarts immediately; only the visual reset is delayed.
      data.ready = true
      a.isStealing = false
      resetBar(3.99)
    end)
  end

  local function nearestAnimal()
    local a = _G.AmbitiousNormalSteal
    local root = getRoot()
    if not root then return nil end
    local radius = tonumber(a.radius) or 62

    -- STESSA SCELTA DEL BERSAGLIO DELLA SEMI.
    -- Prima si guardava la lista costruita dallo scan della Normal, che
    -- contiene TUTTI i podi (anche quelli vuoti), e si usava la
    -- worldPosition salvata al momento della scansione. Due problemi in
    -- uno: si prendeva di mira un podio senza niente sopra, e anche
    -- quando l'animale spariva la posizione vecchia restava buona,
    -- quindi lo steal partiva lo stesso a vuoto.
    -- La lista della Semi nasce invece dall'AnimalList del plot (solo
    -- slot davvero occupati) e la posizione viene risolta ADESSO dal
    -- podio: se non c'e' piu' niente, animalPos ritorna nil e quella
    -- voce non e' un bersaglio.
    -- #list > 0 e non solo "e' una tabella": lo scan condiviso ci mette un
    -- attimo a partire (aspetta ReplicatedStorage), e con la lista ancora
    -- vuota si usciva subito senza bersaglio invece di ripiegare sulla
    -- scansione propria. Era per quello che la Normal sembrava morta
    -- finche' non passavi da Semi e tornavi indietro.
    if _G.AmbitiousStealAnimals then
      local list = _G.AmbitiousStealAnimals()
      if type(list) == "table" and #list > 0 then
        local best, bestDist = nil, math.huge
        for _, data in ipairs(list) do
          local mine = _G.AmbitiousStealIsMyBase and _G.AmbitiousStealIsMyBase(data)
          local occupied = (not _G.AmbitiousStealSlotOccupied)
                           or _G.AmbitiousStealSlotOccupied(data)
          if not mine and occupied then
            local pos = _G.AmbitiousStealAnimalPos and _G.AmbitiousStealAnimalPos(data)
            if pos then
              local dist = (root.Position - pos).Magnitude
              if dist <= radius and dist < bestDist then
                best, bestDist = data, dist
              end
            end
          end
        end
        return best
      end
    end

    -- Ripiego: la Semi non e' ancora stata inizializzata. Anche qui la
    -- posizione si risolve dal vivo, non dalla worldPosition salvata.
    local best, bestDist = nil, math.huge
    for _, data in ipairs(a.animals) do
      if not isMyBase(data.plot) then
        local plots = workspace:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild(data.plot)
        local podiums = plot and plot:FindFirstChild("AnimalPodiums")
        local podium = podiums and podiums:FindFirstChild(data.slot)
        if podium then
          local dist = (root.Position - podium:GetPivot().Position).Magnitude
          if dist <= radius and dist < bestDist then
            best, bestDist = data, dist
          end
        end
      end
    end
    return best
  end

  _G.AmbitiousNormalAutoStealSetRadius = function(v)
    _G.AmbitiousNormalSteal.radius = tonumber(v) or _G.AmbitiousNormalSteal.radius or 62
  end

  _G.AmbitiousNormalAutoStealStop = function()
    local a = _G.AmbitiousNormalSteal
    a.enabled = false
    a.isStealing = false
    if a.stealConn then a.stealConn:Disconnect(); a.stealConn = nil end
    resetBar()
  end

  _G.AmbitiousNormalAutoStealStart = function()
    local a = _G.AmbitiousNormalSteal
    a.radius = tonumber(autoStealRadius) or a.radius or 62
    a.duration = 1.3
    a.enabled = true
    ensureScanner()
    pcall(scanPlots)
    -- Lista condivisa con la Semi: va fatta partire, se no resta vuota e
    -- nearestAnimal non ha niente su cui lavorare.
    if _G.AmbitiousStealEnsureScan then pcall(_G.AmbitiousStealEnsureScan) end
    if a.stealConn then a.stealConn:Disconnect(); a.stealConn = nil end
    a.stealConn = RunService.Heartbeat:Connect(function()
      if not a.enabled then return end
      if selectedStealMode ~= "Normal" then _G.AmbitiousNormalAutoStealStop(); return end
      if a.isStealing then return end
      local target = nearestAnimal()
      if not target then return end
      local prompt = findPrompt(target)
      if prompt then doSteal(prompt) end
    end)
  end

  _G.AmbitiousNormalAutoStealSync = function()
    if selectedStealMode == "Normal" and autoStealEnabled then
      _G.AmbitiousNormalAutoStealStart()
    else
      _G.AmbitiousNormalAutoStealStop()
    end
  end
end

_G.__AdaptSetupSemiAutoSteal = function()
  _G.AmbitiousSemiSteal = _G.AmbitiousSemiSteal or {}
  local A = _G.AmbitiousSemiSteal
  if A.conn then pcall(function() A.conn:Disconnect() end); A.conn = nil end
  A.enabled    = false
  A.cooldown   = A.cooldown   or 0.05
  A.primeRange = A.primeRange or 80
  A.radius     = tonumber(autoStealRadius) or A.radius or 60
  -- applica valori salvati dal config (loadAmbitiousConfig gira prima di questo setup)
  local pending = _G._AmbitiousSemiStealPending
  A.autoGrabStopTime       = (pending and pending.autoGrabStopTime)       or A.autoGrabStopTime       or 1.29
  A.autoGrabStopPercent    = (pending and pending.autoGrabStopPercent)    or A.autoGrabStopPercent    or 75
  A.autoGrabSetDelayRadius = (pending and pending.autoGrabSetDelayRadius) or A.autoGrabSetDelayRadius or 8
  A.autoGrabStopEnabled    = true
  _G._AmbitiousSemiStealPending = nil


  A.conn = A.conn
  A.scanThread = A.scanThread
  A.plotSync = A.plotSync or {caches = {}, connections = {}}
  A.animals = A.animals or {}
  A.promptCache = A.promptCache or {}
  A.internalCache = A.internalCache or {}
  A.state = A.state or {active = false, startTime = 0, phase = "idle", label = "", lastResult = "", lastResultTime = 0}

  local function barSet(p, label)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState(label or "STEALING")
        _G.StealBar.SetProgress(math.clamp(tonumber(p) or 0, 0, 1))
      end
    end)
  end

  local function barReset()
    pcall(function()
      if _G.StealBar then _G.StealBar.Reset() end
    end)
  end

  local function rootPart()
    local char = LP.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")) or nil
  end

  local function splitPath(path)
    if typeof(path) == "table" then return path end
    local out = {}
    for part in string.gmatch(tostring(path), "[^%.]+") do
      table.insert(out, tonumber(part) or part)
    end
    return out
  end

  local function resolvePath(path, root)
    local current, parent, key = root, nil, nil
    for _, part in ipairs(splitPath(path)) do
      parent = current
      key = part
      current = current and current[part] or nil
    end
    return current, parent, key
  end

  local function applySyncDiff(channelName, packet)
    local cache = A.plotSync.caches[channelName]
    if typeof(cache) ~= "table" then return end
    local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
    local current, parent, key = resolvePath(path, cache)
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

  local function attachPlotChannel(remote, plots, requestData)
    if A.plotSync.connections[remote] then return end
    local channelName = tostring(remote.Name)
    if not plots:FindFirstChild(channelName) then return end
    if requestData and A.plotSync.caches[channelName] == nil then
      local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
      A.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
    elseif A.plotSync.caches[channelName] == nil then
      A.plotSync.caches[channelName] = {}
    end
    A.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
      for _, packet in ipairs(queue) do applySyncDiff(channelName, packet) end
    end)
  end

  local function ensureSync()
    if A.syncReady then return true end
    local ok = pcall(function()
      local rs = game:GetService("ReplicatedStorage")
      A.packages = rs:WaitForChild("Packages", 10)
      A.datas = rs:WaitForChild("Datas", 10)
      A.plots = workspace:WaitForChild("Plots", 10)
      if not (A.packages and A.datas and A.plots) then return end
      A.animalsData = require(A.datas:WaitForChild("Animals", 10))
      local sync = A.packages:WaitForChild("Synchronizer", 10)
      A.channelFolder = sync:WaitForChild("Channel", 10)
      A.routeRemote = sync:WaitForChild("CommunicationRoute", 10)
      A.requestData = sync:FindFirstChild("RequestData")
      for _, child in ipairs(A.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then attachPlotChannel(child, A.plots, A.requestData) end
      end
      A.channelFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then attachPlotChannel(child, A.plots, A.requestData) end
      end)
      A.routeRemote.OnClientEvent:Connect(function(actions)
        for _, action in ipairs(actions) do
          local kind, channelName = action[1], tostring(action[2])
          if A.plots and A.plots:FindFirstChild(channelName) then
            if kind == "ListenerAdded" then
              local remote = A.channelFolder and A.channelFolder:FindFirstChild(channelName)
              if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote, A.plots, A.requestData) end
            elseif kind == "ListenerRemoved" then
              for remote, conn in pairs(A.plotSync.connections) do
                if tostring(remote.Name) == channelName then
                  pcall(function() conn:Disconnect() end)
                  A.plotSync.connections[remote] = nil
                  A.plotSync.caches[channelName] = nil
                  break
                end
              end
            end
          end
        end
      end)
      A.syncReady = true
    end)
    return ok and A.syncReady == true
  end

  local function getPlotOwner(plot)
    local sign = plot and plot:FindFirstChild("PlotSign")
    local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
    local label = frame and frame:FindFirstChild("TextLabel")
    if not label or label.Text == "Empty Base" then return nil end
    return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
  end

  local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot or not A.plots then return false end
    local plot = A.plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    local owner = getPlotOwner(plot)
    return owner == LP.DisplayName or owner == LP.Name
  end

  local function podiumFor(animalData)
    local plot = A.plots and A.plots:FindFirstChild(animalData.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    return podiums and podiums:FindFirstChild(animalData.slot) or nil
  end

  local function animalPos(animalData)
    local podium = podiumFor(animalData)
    return podium and podium:GetPivot().Position or nil
  end

  local function distToAnimal(animalData)
    local root = rootPart()
    local pos = animalPos(animalData)
    return root and pos and (root.Position - pos).Magnitude or math.huge
  end

  local function findPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = A.promptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local podium = podiumFor(animalData)
    local base = podium and podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, prompt in ipairs(attach:GetChildren()) do
      if prompt:IsA("ProximityPrompt") then
        A.promptCache[animalData.uid] = prompt
        return prompt
      end
    end
    return nil
  end

  local function scanAllPlots()
    if not ensureSync() then return 0 end
    local newCache = {}
    for _, plot in ipairs(A.plots:GetChildren()) do
      local cache = A.plotSync.caches[plot.Name]
      local animalList = cache and cache.AnimalList
      if typeof(animalList) == "table" then
        for slot, animalData in pairs(animalList) do
          if type(animalData) == "table" then
            local animalName = animalData.Index
            local info = A.animalsData and A.animalsData[animalName]
            if info then
              table.insert(newCache, {
                name = info.DisplayName or animalName,
                plot = plot.Name,
                slot = tostring(slot),
                uid = plot.Name .. "_" .. tostring(slot),
              })
            end
          end
        end
      end
    end
    A.animals = newCache
    return #newCache
  end

  local function pickClosest()
    local root = rootPart()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, animalData in ipairs(A.animals) do
      if not isMyBaseAnimal(animalData) then
        local pos = animalPos(animalData)
        local dist = pos and (root.Position - pos).Magnitude or math.huge
        if dist <= (A.primeRange or 80) and dist < bestDist then
          best, bestDist = animalData, dist
        end
      end
    end
    return best
  end

  local function buildCallbacks(prompt)
    if A.internalCache[prompt] then return end
    local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
    local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if okHold and type(holds) == "table" then
      for _, conn in ipairs(holds) do
        if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
      end
    end
    local okTrigger, triggers = pcall(getconnections, prompt.Triggered)
    if okTrigger and type(triggers) == "table" then
      for _, conn in ipairs(triggers) do
        if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
      end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then A.internalCache[prompt] = data end
  end

  -- Valori semi steal
  A.autoGrabStopTime       = A.autoGrabStopTime       or 1.29  -- punto in cui la barra si ferma (V1, secondi)
  A.autoGrabStopPercent    = A.autoGrabStopPercent    or 75    -- Normal V2: Pause %, derivato da Ambitious Semi V3
  A.autoGrabSetDelayRadius = A.autoGrabSetDelayRadius or 8     -- raggio trigger del secondo step
  A.autoGrabStopEnabled    = true                              -- sempre attivo
  A.cooldown = A.cooldown or 0.05

  local function executeSemi(prompt, animalData)
    if not prompt or not prompt.Parent or not animalData then return false end
    buildCallbacks(prompt)
    local data = A.internalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    A.state.active  = true
    A.state.startTime = tick()
    A.state.phase   = "holding"
    A.state.label   = animalData.name or "Animal"

    task.spawn(function()
      local startTime = A.state.startTime
      local duration  = 1.3  -- durata fase hold (secondi)

      -- avvia hold callbacks
      for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end

      -- ====================== MODALITÀ STOP-AND-WAIT ======================
      -- Normal V2: identica alla base Ambitious Semi engine, ma lo stop e' una
      -- PERCENTUALE della barra. Semi V1 resta a tempo in secondi.
      local stopTime = A.autoGrabStopTime  -- es. 1.29s
      if selectedStealMode == "Normal" and selectedNormalMode == "V2" then
        local pct = math.clamp(tonumber(A.autoGrabStopPercent) or 75, 1, 100)
        stopTime = duration * (pct / 100)
      end

      -- fase 1: avanza fino a stopTime
      while A.enabled and (
        (selectedStealMode == "Semi" and selectedSemiMode ~= "V2")
        or (selectedStealMode == "Normal" and selectedNormalMode == "V2")
      ) do
        local elapsed = tick() - startTime
        if elapsed >= stopTime then break end
        barSet(math.clamp(elapsed / duration, 0, 1), "STEALING")
        local root = rootPart()
        if not root or not prompt.Parent or not prompt.Parent.Parent then break end
        if (root.Position - prompt.Parent.Parent.Position).Magnitude > (tonumber(A.radius) or 60) then break end
        task.wait()
      end

      local stopProgress = math.clamp(stopTime / duration, 0, 1)
      barSet(stopProgress, "STEALING")

      -- fase 2: aspetta entrata nel delayRadius oppure timeout
      -- Budget contato dall'inizio del ciclo. Semi giữ budget Ambitious 2.99s;
      -- Normal V2 dùng reset budget 5s theo yêu cầu.
      -- Dal budget si tolgono sia il tempo gia' speso nella fase 1
      -- (stopTime) sia quello necessario per completare la barra.
      -- stopTime e' sempre in secondi dopo la conversione della percentuale
      -- di Normal V2; Semi V1 usa direttamente il proprio stopTime.
      local phase2Budget = 2.99
      if selectedStealMode == "Normal" and selectedNormalMode == "V2" then
        phase2Budget = 3.99
      end
      local phase2Timeout
      if selectedStealMode == "Normal" and selectedNormalMode == "V2" then
        phase2Timeout = 3.99
      else
        phase2Timeout = math.max(phase2Budget - stopTime - math.max(duration - stopTime, 0), 0.05)
      end
      local phase2Start = tick()

      while A.enabled and (
        (selectedStealMode == "Semi" and selectedSemiMode ~= "V2")
        or (selectedStealMode == "Normal" and selectedNormalMode == "V2")
      ) do
        if tick() - phase2Start >= phase2Timeout then
          -- timeout: reset e riparti subito
          barReset()
          data.ready = true
          A.state.active = false
          A.state.phase  = "idle"
          executeSemi(prompt, animalData)
          return
        end

        if not prompt.Parent or not prompt.Parent.Parent then
          barReset()
          data.ready = true
          A.state.active = false
          A.state.phase  = "idle"
          return
        end

        local root = rootPart()
        if root then
          local dist = (root.Position - prompt.Parent.Parent.Position).Magnitude
          if dist <= (A.autoGrabSetDelayRadius or 8) then
            break  -- entrato nel raggio trigger
          elseif dist > (tonumber(A.radius) or 60) then
            barReset()
            data.ready = true
            A.state.active = false
            A.state.phase  = "idle"
            return
          end
        end
        task.wait()
      end

      -- fase 3: completa la barra da stopProgress a 1 e triggera
      if A.enabled and (
        (selectedStealMode == "Semi" and selectedSemiMode ~= "V2")
        or (selectedStealMode == "Normal" and selectedNormalMode == "V2")
      ) then
        -- Costo REALE della fase 3: nessun pavimento a 0.05, altrimenti il
        -- trigger slitta in avanti (con stopTime 1.29 restavano 0.01s ma se
        -- ne pagavano 0.05, quindi lo steal partiva 40ms tardi e il ciclo
        -- sforava la finestra di 2.99s).
        local fillDuration = math.max(duration - stopTime, 0)
        -- I 50ms sono solo l'anticipo VISIVO della barra: vengono presi da
        -- dentro fillDuration, non aggiunti dopo. Se la fase 3 dura meno di
        -- 50ms l'anticipo si accorcia insieme a lei.
        local barLead   = math.min(0.05, fillDuration)
        local fillRamp  = fillDuration - barLead
        local fillStart = tick()
        while true do
          local fp = (fillRamp > 0) and math.clamp((tick() - fillStart) / fillRamp, 0, 1) or 1
          barSet(stopProgress + fp * (1 - stopProgress), "STEALING")
          if fp >= 1 then break end
          task.wait()
        end
        barSet(1, "STEALING")
        if barLead > 0 then task.wait(barLead) end
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
        pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
        A.state.lastResult = "Stole " .. tostring(A.state.label)
      else
        A.state.lastResult = "Cancelled"
      end

      -- cleanup: nessun wait extra, ripartenza immediata
      A.state.active         = false
      A.state.phase          = "idle"
      A.state.lastResultTime = tick()
      data.ready = true
      barReset(3.99)
    end)
    return true
  end

  -- ---- lista bersagli condivisa con la modalita' Normal ----
  -- La Normal costruiva una lista sua scorrendo i podi: ci finiva DENTRO
  -- ogni podio esistente, pieno o vuoto che fosse. Questa invece nasce
  -- dall'AnimalList del plot, quindi contiene solo gli slot che hanno
  -- davvero un animale sopra. Esposta su _G perche' il blocco della
  -- Normal sta prima di questo nel file e non vede questi local.
  _G.AmbitiousStealAnimals   = function() return A.animals end
  _G.AmbitiousStealAnimalPos = function(d) return animalPos(d) end
  _G.AmbitiousStealIsMyBase  = function(d) return isMyBaseAnimal(d) end

  -- Lo slot ha ANCORA un animale sopra, adesso.
  -- La lista viene ricostruita ogni 5 secondi, quindi da sola non basta:
  -- un animale appena rubato resta in elenco fino al giro dopo, e il
  -- podio esiste comunque (vuoto), quindi anche la posizione risulta
  -- valida. Le cache dei plot sono invece aggiornate dal vivo dai
  -- RemoteEvent del Synchronizer: chiedendo a loro si sa in quell'istante
  -- se lo slot e' occupato.
  _G.AmbitiousStealSlotOccupied = function(d)
    if not d or not d.plot or not d.slot then return false end
    local cache = A.plotSync and A.plotSync.caches and A.plotSync.caches[d.plot]
    local list = cache and cache.AnimalList
    -- Cache non disponibile: non si puo' dire di no, se no con la sync
    -- non pronta la Normal non partirebbe mai.
    if typeof(list) ~= "table" then return true end
    -- Le chiavi possono essere numeri o stringhe a seconda di come
    -- arrivano dal server: si provano entrambe.
    local entry = list[d.slot] or list[tonumber(d.slot) or -1]
    return type(entry) == "table"
  end

  local function ensureScanThread()
    if A.scanThread then return end
    A.scanThread = task.spawn(function()
      while _G.AmbitiousSemiSteal do
        -- Lo scan gira anche per la Normal, che ora legge da qui.
        if A.enabled or (selectedStealMode == "Semi" or (selectedStealMode == "Normal" and selectedNormalMode == "V2"))
           or (selectedStealMode == "Normal" and autoStealEnabled) then
          pcall(scanAllPlots)
        end
        task.wait(5)
      end
    end)
  end

  -- Avvio dello scan su richiesta. La Normal ora legge da questa lista,
  -- ma il thread che la riempie partiva SOLO dall'avvio della Semi: senza
  -- aver mai acceso la Semi la lista restava vuota e la Normal non
  -- trovava mai un bersaglio. Da qui la puo' far partire chiunque.
  _G.AmbitiousStealEnsureScan = function()
    ensureScanThread()
    task.spawn(function() pcall(scanAllPlots) end)
  end

  _G.AmbitiousSemiAutoStealSetRadius = function(v)
    local n = tonumber(v)
    if n then A.radius = n end
  end

  _G.AmbitiousSemiAutoStealStop = function()
    A.enabled = false
    if A.conn then A.conn:Disconnect(); A.conn = nil end
    A.state.active = false
    A.state.phase = "idle"
    barReset()
  end

  _G.AmbitiousSemiAutoStealStart = function()
    A.radius = tonumber(autoStealRadius) or A.radius or 60
    A.enabled = true
    ensureSync()
    ensureScanThread()
    pcall(scanAllPlots)
    if A.conn then A.conn:Disconnect(); A.conn = nil end
    A.conn = RunService.Heartbeat:Connect(function()
      if not A.enabled then return end
      if not (selectedStealMode == "Semi" or (selectedStealMode == "Normal" and selectedNormalMode == "V2")) then _G.AmbitiousSemiAutoStealStop(); return end
      if A.state.active then return end
      local target = pickClosest()
      if not target then return end
      local prompt = findPromptForAnimal(target)
      if prompt then executeSemi(prompt, target) end
    end)
  end

  _G.AmbitiousSemiAutoStealSync = function()
    if (selectedStealMode == "Semi" or (selectedStealMode == "Normal" and selectedNormalMode == "V2")) and autoStealEnabled then
      _G.AmbitiousSemiAutoStealStart()
    else
      _G.AmbitiousSemiAutoStealStop()
    end
  end
end

-- ===== SEMI V2 ENGINE (logica da Ambitious.lua standalone) =====
_G.__AdaptSetupSemiV2AutoSteal = function()
  _G.AmbitiousSemiV2Steal = _G.AmbitiousSemiV2Steal or {}
  local B = _G.AmbitiousSemiV2Steal
  if B.conn then pcall(function() B.conn:Disconnect() end); B.conn = nil end
  B.enabled    = false
  -- Valori hardcoded (non mostrati in settings)
  B.holdMin    = 1.3
  B.holdMax    = 2.69
  B.entryDelay = 0.3
  B.cooldown   = 0.05
  -- Radius (prime range) e SemiRadius (steal range) presi da AmbitiousStealRadii
  B.radius     = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2Radius) or B.radius or 60
  B.semiRadius = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2SemiRadius) or B.semiRadius or 8
  B.plotSync   = B.plotSync or {caches = {}, connections = {}}
  B.animals    = B.animals or {}
  B.promptCache = B.promptCache or {}
  B.internalCache = B.internalCache or {}
  B.state = B.state or {active = false, startTime = 0, phase = "idle"}

  local function barSet(p, label)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState(label or "STEALING")
        _G.StealBar.SetProgress(math.clamp(tonumber(p) or 0, 0, 1))
      end
    end)
  end

  local function barReset()
    pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
  end

  local function rootPart()
    local char = LP.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")) or nil
  end

  local function splitPath(path)
    if typeof(path) == "table" then return path end
    local out = {}
    for part in string.gmatch(tostring(path), "[^%.]+") do
      table.insert(out, tonumber(part) or part)
    end
    return out
  end

  local function resolvePath(path, root)
    local current, parent, key = root, nil, nil
    for _, part in ipairs(splitPath(path)) do
      parent = current; key = part
      current = current and current[part] or nil
    end
    return current, parent, key
  end

  local function applySyncDiff(channelName, packet)
    local cache = B.plotSync.caches[channelName]
    if typeof(cache) ~= "table" then return end
    local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
    local current, parent, key = resolvePath(path, cache)
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

  local function attachPlotChannel(remote, plots, requestData)
    if B.plotSync.connections[remote] then return end
    local channelName = tostring(remote.Name)
    if not plots:FindFirstChild(channelName) then return end
    if requestData and B.plotSync.caches[channelName] == nil then
      local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
      B.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
    elseif B.plotSync.caches[channelName] == nil then
      B.plotSync.caches[channelName] = {}
    end
    B.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
      for _, packet in ipairs(queue) do applySyncDiff(channelName, packet) end
    end)
  end

  local function ensureSync()
    if B.syncReady then return true end
    local ok = pcall(function()
      local rs = game:GetService("ReplicatedStorage")
      B.packages = rs:WaitForChild("Packages", 10)
      B.datas    = rs:WaitForChild("Datas", 10)
      B.plots    = workspace:WaitForChild("Plots", 10)
      if not (B.packages and B.datas and B.plots) then return end
      B.animalsData = require(B.datas:WaitForChild("Animals", 10))
      local sync = B.packages:WaitForChild("Synchronizer", 10)
      B.channelFolder = sync:WaitForChild("Channel", 10)
      B.routeRemote   = sync:WaitForChild("CommunicationRoute", 10)
      B.requestData   = sync:FindFirstChild("RequestData")
      for _, child in ipairs(B.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then attachPlotChannel(child, B.plots, B.requestData) end
      end
      B.channelFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then attachPlotChannel(child, B.plots, B.requestData) end
      end)
      B.routeRemote.OnClientEvent:Connect(function(actions)
        for _, action in ipairs(actions) do
          local kind, channelName = action[1], tostring(action[2])
          if B.plots and B.plots:FindFirstChild(channelName) then
            if kind == "ListenerAdded" then
              local remote = B.channelFolder and B.channelFolder:FindFirstChild(channelName)
              if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote, B.plots, B.requestData) end
            elseif kind == "ListenerRemoved" then
              for remote, conn in pairs(B.plotSync.connections) do
                if tostring(remote.Name) == channelName then
                  pcall(function() conn:Disconnect() end)
                  B.plotSync.connections[remote] = nil
                  B.plotSync.caches[channelName] = nil
                  break
                end
              end
            end
          end
        end
      end)
      B.syncReady = true
    end)
    return ok and B.syncReady == true
  end

  local function getPlotOwner(plot)
    local sign = plot and plot:FindFirstChild("PlotSign")
    local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
    local label = frame and frame:FindFirstChild("TextLabel")
    if not label or label.Text == "Empty Base" then return nil end
    return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
  end

  local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot or not B.plots then return false end
    local plot = B.plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    local owner = getPlotOwner(plot)
    return owner == LP.DisplayName or owner == LP.Name
  end

  local function podiumFor(animalData)
    local plot = B.plots and B.plots:FindFirstChild(animalData.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    return podiums and podiums:FindFirstChild(animalData.slot) or nil
  end

  local function animalPos(animalData)
    local podium = podiumFor(animalData)
    return podium and podium:GetPivot().Position or nil
  end

  local function distToAnimal(animalData)
    local root = rootPart()
    local pos = animalPos(animalData)
    return root and pos and (root.Position - pos).Magnitude or math.huge
  end

  local function findPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = B.promptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local podium = podiumFor(animalData)
    local base = podium and podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, prompt in ipairs(attach:GetChildren()) do
      if prompt:IsA("ProximityPrompt") then
        B.promptCache[animalData.uid] = prompt
        return prompt
      end
    end
    return nil
  end

  local function scanAllPlots()
    if not ensureSync() then return 0 end
    local newCache = {}
    for _, plot in ipairs(B.plots:GetChildren()) do
      local cache = B.plotSync.caches[plot.Name]
      local animalList = cache and cache.AnimalList
      if typeof(animalList) == "table" then
        for slot, animalData in pairs(animalList) do
          if type(animalData) == "table" then
            local animalName = animalData.Index
            local info = B.animalsData and B.animalsData[animalName]
            if info then
              table.insert(newCache, {
                name = info.DisplayName or animalName,
                plot = plot.Name,
                slot = tostring(slot),
                uid = plot.Name .. "_" .. tostring(slot),
              })
            end
          end
        end
      end
    end
    B.animals = newCache
    return #newCache
  end

  local function pickClosest()
    local root = rootPart()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, animalData in ipairs(B.animals) do
      if not isMyBaseAnimal(animalData) then
        local pos = animalPos(animalData)
        local dist = pos and (root.Position - pos).Magnitude or math.huge
        if dist <= (B.radius or 60) and dist < bestDist then
          best, bestDist = animalData, dist
        end
      end
    end
    return best
  end

  local function buildCallbacks(prompt)
    if B.internalCache[prompt] then return end
    local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
    local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if okHold and type(holds) == "table" then
      for _, conn in ipairs(holds) do
        if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
      end
    end
    local okTrigger, triggers = pcall(getconnections, prompt.Triggered)
    if okTrigger and type(triggers) == "table" then
      for _, conn in ipairs(triggers) do
        if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
      end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then B.internalCache[prompt] = data end
  end

  local function executeV2(prompt, animalData)
    if not prompt or not prompt.Parent or not animalData then return false end
    buildCallbacks(prompt)
    local data = B.internalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    B.state.active    = true
    B.state.startTime = tick()
    B.state.phase     = "holding"
    B.state.barHold   = false

    task.spawn(function()
      local holdMin    = B.holdMin    or 1.3
      local holdMax    = B.holdMax    or 2.69
      local entryDelay = B.entryDelay or 0.3
      local stealRange = B.semiRadius or 8   -- STEAL_RANGE
      local primeRange = B.radius     or 60  -- PRIME_RANGE

      -- avvia hold callbacks
      for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end

      -- fase 1: aspetta holdMin (con check radius: se esci dal primeRange, abort)
      local t0 = tick()
      while tick() - t0 < holdMin do
        if distToAnimal(animalData) > primeRange then
          barReset()
          B.state.active = false
          B.state.phase  = "idle"
          task.wait(B.cooldown or 0.05)
          data.ready = true
          return
        end
        task.wait()
      end

      B.state.phase = "waitingRange"

      -- fase 2: aspetta entrata nello stealRange o scadenza holdMax
      -- se esci dal primeRange durante l'attesa → abort come Semi V1
      local alreadyInRange = distToAnimal(animalData) <= stealRange
      local fired = false
      while true do
        if tick() - B.state.startTime > holdMax then break end
        if not prompt.Parent then break end
        if selectedStealMode ~= "Semi" or selectedSemiMode ~= "V2" or not B.enabled then break end
        if distToAnimal(animalData) > primeRange then
          -- uscito dal radius durante la barra → reset e stop (uguale a Semi V1)
          barReset()
          B.state.active = false
          B.state.phase  = "idle"
          task.wait(B.cooldown or 0.05)
          data.ready = true
          return
        end
        if distToAnimal(animalData) <= stealRange then
          if not alreadyInRange then task.wait(entryDelay) end
          -- barra piena al momento del trigger (nessuna attesa aggiunta)
          B.state.barHold = true
          barSet(1, "STEALING")
          for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
          pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
          fired = true
          break
        end
        task.wait()
      end

      if fired then barReset(3.99) else barReset() end
      B.state.barHold = false
      B.state.active = false
      B.state.phase  = "idle"
      task.wait(B.cooldown or 0.05)
      data.ready = true
    end)
    return true
  end

  local function ensureScanThread()
    if B.scanThread then return end
    B.scanThread = task.spawn(function()
      while _G.AmbitiousSemiV2Steal do
        if B.enabled or (selectedStealMode == "Semi" and selectedSemiMode == "V2") then pcall(scanAllPlots) end
        task.wait(5)
      end
    end)
  end

  _G.AmbitiousSemiV2SetRadius = function(v)
    local n = tonumber(v)
    if n then B.radius = n end
  end

  _G.AmbitiousSemiV2SetSemiRadius = function(v)
    local n = tonumber(v)
    if n then B.semiRadius = n end
  end

  -- RenderStepped dedicato: aggiorna la barra continuamente mentre V2 è attivo
  if B.barConn then pcall(function() B.barConn:Disconnect() end); B.barConn = nil end
  B.barConn = RunService.RenderStepped:Connect(function()
    if not B.state.active then return end
    if B.state.barHold then return end   -- barra piena in attesa del trigger
    local elapsed = tick() - B.state.startTime
    local holdMax = B.holdMax or 2.69
    -- la barra arriva a 1 con 0.05s di anticipo (es. 2.64 invece di 2.69)
    local barFull = math.max(holdMax - 0.05, 0.05)
    local p = math.clamp(elapsed / barFull, 0, 1)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState("STEALING")
        _G.StealBar.SetProgress(p)
      end
    end)
  end)

  _G.AmbitiousSemiV2AutoStealStop = function()
    B.enabled = false
    if B.conn then B.conn:Disconnect(); B.conn = nil end
    B.state.active  = false
    B.state.phase   = "idle"
    B.state.barHold = false
    barReset()
  end

  _G.AmbitiousSemiV2AutoStealStart = function()
    B.radius     = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2Radius)     or B.radius     or 60
    B.semiRadius = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2SemiRadius) or B.semiRadius or 8
    B.enabled = true
    ensureSync()
    ensureScanThread()
    pcall(scanAllPlots)
    if B.conn then B.conn:Disconnect(); B.conn = nil end
    B.conn = RunService.Heartbeat:Connect(function()
      if not B.enabled then return end
      if selectedStealMode ~= "Semi" or selectedSemiMode ~= "V2" then _G.AmbitiousSemiV2AutoStealStop(); return end
      if B.state.active then return end
      local target = pickClosest()
      if not target then return end
      local prompt = findPromptForAnimal(target)
      if prompt then executeV2(prompt, target) end
    end)
  end

  _G.AmbitiousSemiV2AutoStealSync = function()
    if selectedStealMode == "Semi" and selectedSemiMode == "V2" and autoStealEnabled then
      _G.AmbitiousSemiV2AutoStealStart()
    else
      _G.AmbitiousSemiV2AutoStealStop()
    end
  end
end

_G.AmbitiousAutoStealSync = function()
    if not autoStealEnabled then
        if _G.AmbitiousNormalAutoStealStop then pcall(_G.AmbitiousNormalAutoStealStop) end
        if _G.AmbitiousSemiAutoStealStop then pcall(_G.AmbitiousSemiAutoStealStop) end
        if _G.AmbitiousSemiV2AutoStealStop then pcall(_G.AmbitiousSemiV2AutoStealStop) end
        return
    end

    if selectedStealMode == "Normal" then
        if _G.AmbitiousSemiV2AutoStealStop then pcall(_G.AmbitiousSemiV2AutoStealStop) end
        if selectedNormalMode == "V2" then
            if _G.AmbitiousNormalAutoStealStop then pcall(_G.AmbitiousNormalAutoStealStop) end
            if _G.AmbitiousSemiAutoStealStart then pcall(_G.AmbitiousSemiAutoStealStart) end
        else
            if _G.AmbitiousSemiAutoStealStop then pcall(_G.AmbitiousSemiAutoStealStop) end
            if _G.AmbitiousNormalAutoStealSync then pcall(_G.AmbitiousNormalAutoStealSync) end
        end
    elseif selectedStealMode == "Semi" then
        if _G.AmbitiousNormalAutoStealStop then pcall(_G.AmbitiousNormalAutoStealStop) end
        if selectedSemiMode == "V2" then
            if _G.AmbitiousSemiAutoStealStop then pcall(_G.AmbitiousSemiAutoStealStop) end
            if _G.AmbitiousSemiV2AutoStealSync then pcall(_G.AmbitiousSemiV2AutoStealSync) end
        else
            if _G.AmbitiousSemiV2AutoStealStop then pcall(_G.AmbitiousSemiV2AutoStealStop) end
            if _G.AmbitiousSemiAutoStealSync then pcall(_G.AmbitiousSemiAutoStealSync) end
        end
    end
end

_G.__AdaptSetupNormalAutoSteal()
_G.__AdaptSetupSemiAutoSteal()
_G.__AdaptSetupSemiV2AutoSteal()

_G.AdaptNormalAutoStealStart = _G.AmbitiousNormalAutoStealStart
_G.AdaptNormalAutoStealStop = _G.AmbitiousNormalAutoStealStop
_G.AdaptNormalAutoStealSync = _G.AmbitiousNormalAutoStealSync
_G.AdaptSemiAutoStealStart = _G.AmbitiousSemiAutoStealStart
_G.AdaptSemiAutoStealStop = _G.AmbitiousSemiAutoStealStop
_G.AdaptSemiAutoStealSync = _G.AmbitiousSemiAutoStealSync
_G.AdaptSemiV2AutoStealStart = _G.AmbitiousSemiV2AutoStealStart
_G.AdaptSemiV2AutoStealStop = _G.AmbitiousSemiV2AutoStealStop
_G.AdaptSemiV2AutoStealSync = _G.AmbitiousSemiV2AutoStealSync
_G.AdaptSemiAutoStealSetRadius = _G.AmbitiousSemiAutoStealSetRadius
_G.AdaptAutoStealSync = _G.AmbitiousAutoStealSync
_G.AdaptAutoStealSync = _G.AmbitiousAutoStealSync
task.spawn(function()
while task.wait(30) do
do end
end
end)

----------------------------------------------------------------
-- 12Hub Auto Steal bridge: connect file-1 UI/state to the full
-- LaPeak/Ambitious Normal V1/V2 + Semi V1/V2 engines above.
----------------------------------------------------------------
selectedNormalMode = (tostring(selectedNormalMode) == "V2") and "V2" or "V1"
selectedSemiMode = (tostring(selectedSemiMode) == "V2") and "V2" or "V1"

local function _12HubNormalizeStealSelection(mode, version)
    mode = (tostring(mode) == "Semi") and "Semi" or "Normal"
    version = (tostring(version) == "V1") and "V1" or "V2"
    selectedStealMode = mode
    autoStealV2Version = version
    if mode == "Normal" then
        selectedNormalMode = version
    else
        selectedSemiMode = version
    end
    St.stealVer = mode .. "-" .. version
    autoStealRadius = tonumber(St.stealRadius) or 60
end

local function _12HubSyncAutoSteal()
    _12HubNormalizeStealSelection(selectedStealMode, autoStealV2Version)
    autoStealEnabled = St.autoSteal == true
    _G.autoStealEnabled = autoStealEnabled
    if _G.AdaptAutoStealSync then
        pcall(_G.AdaptAutoStealSync)
    elseif _G.AmbitiousAutoStealSync then
        pcall(_G.AmbitiousAutoStealSync)
    end
end

function setAutoSteal(on)
    St.autoSteal = on and true or false
    autoStealEnabled = St.autoSteal
    _G.autoStealEnabled = autoStealEnabled
    _12HubSyncAutoSteal()
    if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
    if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
        pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal)
    end
    pcall(saveCfg)
end

_G.setAutoSteal = setAutoSteal
_G.RanaVSSyncAutoSteal = _12HubSyncAutoSteal

_G.RanaVSSelectAutoSteal = function(mode, version)
    _12HubNormalizeStealSelection(mode, version)
    _12HubSyncAutoSteal()
    pcall(function() if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end end)
    pcall(saveCfg)
end

_G.AdaptSetStealPause = function(p)
    local n = tonumber(tostring(p):match("%d+")) or 75
    local allowed = {[70]=true,[75]=true,[80]=true,[85]=true,[90]=true}
    if not allowed[n] then n = 75 end
    St.normalV2PausePercent = n
    _G.AdaptStealPausePreset = tostring(n)
    _G._AmbitiousSemiStealPending = _G._AmbitiousSemiStealPending or {}
    _G._AmbitiousSemiStealPending.autoGrabStopPercent = n
    if _G.AmbitiousSemiSteal then
        _G.AmbitiousSemiSteal.autoGrabStopPercent = n
    end
    -- Normal V2 shares the LaPeak percentage window through the Normal engine.
    if _G.AmbitiousNormalSteal then
        _G.AmbitiousNormalSteal.autoGrabStopPercent = n
    end
    pcall(saveCfg)
    if St.autoSteal then pcall(_12HubSyncAutoSteal) end
end

-- Keep radius synchronized with all four engines.
setStealRadius = function(v)
    local n = math.clamp(tonumber(v) or 60, 1, 250)
    St.stealRadius = n
    autoStealRadius = n
    _G.AmbitiousStealRadii = _G.AmbitiousStealRadii or {}
    _G.AmbitiousStealRadii.Normal = n
    _G.AmbitiousStealRadii.Semi = n
    _G.AmbitiousStealRadii.SemiV2Radius = n
    pcall(function() if _G.AmbitiousNormalAutoStealSetRadius then _G.AmbitiousNormalAutoStealSetRadius(n) end end)
    pcall(function() if _G.AmbitiousSemiAutoStealSetRadius then _G.AmbitiousSemiAutoStealSetRadius(n) end end)
    pcall(function() if _G.AmbitiousSemiV2SetRadius then _G.AmbitiousSemiV2SetRadius(n) end end)
    pcall(saveCfg)
end

-- Initial bridge state: restore the saved Normal/Semi + V1/V2 selector exactly.
_12HubNormalizeStealSelection(selectedStealMode, autoStealV2Version)
if St.normalV2PausePercent == nil then St.normalV2PausePercent = 75 end
_G.AdaptSetStealPause(St.normalV2PausePercent)
-- PANEL TP OLD/COMPACT REMOVED
-- The active TP panel below is the full uploaded allgearonetop GUI renamed to 12Hub.

-- BODY LOCK: removed completely; no runtime, range setting, or UI.
-- UI: Panel tab + Auto Steal + InfJump mode on existing pages
----------------------------------------------------------------
task.defer(function()
	-- Auto steal on Player page
	if not pagePlayer then warn("[12Hub] pagePlayer nil") return end
	section(pagePlayer, "* — AUTO STEAL", 20)
	local function safeSetAS(on)
 if type(setAutoSteal) == "function" then
 setAutoSteal(on)
 else
 St.autoSteal = on and true or false
 end
	end
	toggleNamed(pagePlayer, "Auto Steal", St.autoSteal == true, safeSetAS, 21, "autoSteal")
    -- Auto Steal selector: Mode = Normal/Semi, Version = V1/V2.
    local modeRow = row(pagePlayer, 36, 22)
    local modeLbl = Instance.new("TextLabel")
    modeLbl.Size = UDim2.new(0.28, 0, 1, 0)
    modeLbl.Position = UDim2.new(0, 10, 0, 0)
    modeLbl.BackgroundTransparency = 1
    modeLbl.Text = "Mode"
    modeLbl.TextColor3 = C.text
    modeLbl.TextSize = 12
    modeLbl.Font = Enum.Font.Gotham
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left
    modeLbl.Parent = modeRow

    local function setStealSelector(mode, version)
        mode = (mode == "Semi") and "Semi" or "Normal"
        version = (version == "V2") and "V2" or "V1"
        _12HubNormalizeStealSelection(mode, version)
        _12HubSyncAutoSteal()
        refreshStealSelector()
        saveCfg()
    end

    local modeButtons = {}
    local verButtons = {}
    local function refreshStealSelector()
        for n, x in pairs(modeButtons) do
            local on = selectedStealMode == n
            setAceModeVisual(x, on, "AceModeStroke")
        end
        for n, x in pairs(verButtons) do
            local on = autoStealV2Version == n
            setAceModeVisual(x, on, "AceModeStroke")
        end
    end
    for i, name in ipairs({"Normal", "Semi"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 76, 0, 26)
        b.Position = UDim2.new(1, -170 + (i-1)*80, 0.5, -13)
        b.BackgroundColor3 = (selectedStealMode == name) and C.modeOnBg or C.modeOffBg
        b.Text = name
        b.TextColor3 = (selectedStealMode == name) and C.modeOnTxt or C.modeOffTxt
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.Parent = modeRow
        corner(b, 7)
        local modeStroke = Instance.new("UIStroke")
        modeStroke.Name = "AceModeStroke"
        modeStroke.Color = ACE_MODE.line
        modeStroke.Thickness = 1
        modeStroke.Transparency = 0.30
        modeStroke.Parent = b
        modeButtons[name] = b
        local function chooseMode()
            setStealSelector(name, autoStealV2Version)
            refreshStealSelector()
        end
        b.Activated:Connect(chooseMode)
    end

    local verRow = row(pagePlayer, 36, 22.5)
    local verLbl = Instance.new("TextLabel")
    verLbl.Size = UDim2.new(0.28, 0, 1, 0)
    verLbl.Position = UDim2.new(0, 10, 0, 0)
    verLbl.BackgroundTransparency = 1
    verLbl.Text = "Version"
    verLbl.TextColor3 = C.text
    verLbl.TextSize = 12
    verLbl.Font = Enum.Font.Gotham
    verLbl.TextXAlignment = Enum.TextXAlignment.Left
    verLbl.Parent = verRow

    for i, name in ipairs({"V1", "V2"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 60, 0, 26)
        b.Position = UDim2.new(1, -140 + (i-1)*66, 0.5, -13)
        b.BackgroundColor3 = (autoStealV2Version == name) and C.modeOnBg or C.modeOffBg
        b.Text = name
        b.TextColor3 = (autoStealV2Version == name) and C.modeOnTxt or C.modeOffTxt
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.Parent = verRow
        corner(b, 7)
        local verStroke = Instance.new("UIStroke")
        verStroke.Name = "AceModeStroke"
        verStroke.Color = ACE_MODE.line
        verStroke.Thickness = 1
        verStroke.Transparency = 0.30
        verStroke.Parent = b
        verButtons[name] = b
        local function chooseVersion()
            setStealSelector(selectedStealMode, name)
            refreshStealSelector()
        end
        b.Activated:Connect(chooseVersion)
    end
    refreshStealSelector()
	-- radius box
	local rr = row(pagePlayer, 36, 24)
	local rl = Instance.new("TextLabel")
	rl.Size = UDim2.new(0.5, 0, 1, 0)
	rl.Position = UDim2.new(0, 10, 0, 0)
	rl.BackgroundTransparency = 1
	rl.Text = "Steal Radius"
	rl.TextColor3 = C.text
	rl.TextSize = 12
	rl.Font = Enum.Font.Gotham
	rl.TextXAlignment = Enum.TextXAlignment.Left
	rl.Parent = rr
	numBox(rr, UDim2.new(1, -70, 0.5, -12), 56, St.stealRadius, function(v)
 St.stealRadius = v
 saveCfg()
	end)
	-- force scroll size so AUTO STEAL is visible
	pcall(function()
 local lay = pagePlayer:FindFirstChildOfClass("UIListLayout")
 if lay then
 pagePlayer.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 40)
 end
	end)

	-- InfJump mode row near inf jump if exists
	section(pagePlayer, "* — INF JUMP MODE", 217)
	local ij = row(pagePlayer, 36, 218)
	for i, name in ipairs({"hold", "manual"}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 70, 0, 26)
 b.Position = UDim2.new(0, 12 + (i - 1) * 80, 0.5, -13)
 b.BackgroundColor3 = (St.infJumpMode == name) and C.modeOnBg or C.modeOffBg
 b.Text = name
 b.TextColor3 = (St.infJumpMode == name) and C.modeOnTxt or C.modeOffTxt
 b.TextSize = 11
 b.Font = Enum.Font.GothamBold
 b.Parent = ij
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
 local ijStroke = Instance.new("UIStroke")
 ijStroke.Name = "AceModeStroke"
 ijStroke.Color = ACE_MODE.line
 ijStroke.Thickness = 1
 ijStroke.Transparency = 0.30
 ijStroke.Parent = b
 setAceModeVisual(b, St.infJumpMode == name, "AceModeStroke")
 b.MouseButton1Click:Connect(function()
 setInfJumpMode(name)
 for _, ch in ipairs(ij:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = ch.Text == St.infJumpMode
 setAceModeVisual(ch, on, "AceModeStroke")
 end
 end
 end)
	end

	setTab("Player")
end)

print("[12Hub Ext] AutoSteal Normal/Semi V1/V2 + LaPeak bar | InfJump hold/manual | ToolAim ON")



-- ============================================================
-- TP TO BEST (Chilli style) — equip carpet + TP best brainrot
-- ============================================================
function parseGenValue(text)
	if not text then return 0 end
	text = tostring(text):gsub(",", ""):gsub("%s", ""):upper()
	-- $5M/s $1.2B 850M 7M/S 14.8B
	local best = 0
	for num, suffix in text:gmatch("([%d%.]+)([KMBTQA]?)") do
 local n = tonumber(num)
 if n then
 local mul = 1
 if suffix == "K" then mul = 1e3
 elseif suffix == "M" then mul = 1e6
 elseif suffix == "B" then mul = 1e9
 elseif suffix == "T" then mul = 1e12
 elseif suffix == "Q" or suffix == "QA" then mul = 1e15
 end
 local v = n * mul
 if v > best then best = v end
 end
	end
	return best
end

function isStealAction(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then return false end
	local act = tostring(prompt.ActionText or ""):lower()
	local obj = tostring(prompt.ObjectText or ""):lower()
	-- EN + ES + VI (Steal)
	if act:find("steal") or act:find("robar") or act:find("steal") or act:find("steal")
 or act:find("grab") or act:find("take") then
 return true
	end
	if obj:find("steal") or obj:find("steal") or obj:find("steal") or obj:find("robar") then
 return true
	end
	-- unicode normalize fallback
	local actRaw = tostring(prompt.ActionText or "")
	if actRaw:find("uop") or actRaw:find("Steal") or actRaw:find("steal") then return true end
	return false
end

function isOwnPlot(plot)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign") or plot:FindFirstChild("Sign")
	if sign then
 for _, d in ipairs(sign:GetDescendants()) do
 if d:IsA("BillboardGui") and (d.Name:lower():find("your") or d.Enabled) then
 if d.Name:lower():find("your") or d.Name:lower():find("base") then
 -- check owner attribute
 end
 end
 end
	end
	-- attribute / string value owner
	local ok, owner = pcall(function()
 return plot:GetAttribute("Owner") or plot:GetAttribute("OwnerId")
	end)
	if ok and owner and tostring(owner) == tostring(LP.UserId) then return true end
	local ok2, ownerName = pcall(function()
 return plot:GetAttribute("OwnerName")
	end)
	if ok2 and ownerName and tostring(ownerName) == LP.Name then return true end
	-- YourBase billboard
	for _, d in ipairs(plot:GetDescendants()) do
 if d:IsA("BillboardGui") and d.Name == "YourBase" and d.Enabled then
 return true
 end
	end
	return false
end

function findBestBrainrot()
	local roots = {}
	for _, name in ipairs({"Plots", "plots", "Bases", "Animals", "Pets", "Map"}) do
 local f = workspace:FindFirstChild(name)
 if f then table.insert(roots, f) end
	end
	if #roots == 0 then table.insert(roots, workspace) end

	local bestPrompt, bestVal, bestPart = nil, -1, nil
	local function consider(d)
 if not d:IsA("ProximityPrompt") then return end
 if not isStealAction(d) then return end
 if d.Enabled == false then return end
 -- skip own character
 if LP.Character and d:IsDescendantOf(LP.Character) then return end
 local part = d.Parent
 if not part then return end
 -- climb out of own plot
 local plot = d
 for _ = 1, 8 do
 if not plot.Parent or plot.Parent == workspace then break end
 plot = plot.Parent
 if isOwnPlot(plot) then return end
 end
 local basePart = part:IsA("BasePart") and part
 or (part:IsA("Model") and part:FindFirstChildWhichIsA("BasePart", true))
 or part:FindFirstAncestorWhichIsA("BasePart")
 if not basePart then return end
 local val = 0
 local searchRoot = part:IsA("Model") and part or part.Parent
 if searchRoot then
 for _, lab in ipairs(searchRoot:GetDescendants()) do
 if lab:IsA("TextLabel") or lab:IsA("TextButton") then
 local t = lab.Text or ""
 if t:find("%$") or t:find("/s") or t:find("/S") or t:upper():find("[KMBT]") then
 local v = parseGenValue(t)
 if v > val then val = v end
 end
 end
 end
 end
 local v2 = parseGenValue(d.ObjectText)
 if v2 > val then val = v2 end
 -- BillboardGui near prompt
 for _, bb in ipairs(workspace:GetDescendants()) do
 if bb:IsA("BillboardGui") and bb.Adornee then
 local okd, dist = pcall(function()
 return (bb.Adornee.Position - basePart.Position).Magnitude
 end)
 if okd and dist and dist < 12 then
 for _, lab in ipairs(bb:GetDescendants()) do
 if lab:IsA("TextLabel") then
 local v = parseGenValue(lab.Text)
 if v > val then val = v end
 end
 end
 end
 end
 end
 if val > bestVal or (val == bestVal and bestVal < 0) then
 bestVal = val
 bestPrompt = d
 bestPart = basePart
 elseif bestPrompt == nil then
 bestVal = val
 bestPrompt = d
 bestPart = basePart
 end
	end

	for _, root in ipairs(roots) do
 if root == workspace then
 -- limit scan
 for _, d in ipairs(workspace:GetDescendants()) do
 if d:IsA("ProximityPrompt") then consider(d) end
 end
 else
 for _, plot in ipairs(root:GetChildren()) do
 if not isOwnPlot(plot) then
 for _, d in ipairs(plot:GetDescendants()) do
 consider(d)
 end
 end
 end
 end
	end
	return bestPart, bestVal, bestPrompt
end

function equipFlyingCarpet(char)
	char = char or LP.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	local names = {
 "Flying Carpet", "Carpet", "Cloud", "Witch's Broom",
 "Magic Carpet", "Fly Carpet", "FlyingCarpet",
	}
	for _, n in ipairs(names) do
 local g = char:FindFirstChild(n) or LP.Backpack:FindFirstChild(n)
 if g and g:IsA("Tool") then
 pcall(function() hum:EquipTool(g) end)
 return true
 end
	end
	-- fuzzy
	for _, t in ipairs(LP.Backpack:GetChildren()) do
 if t:IsA("Tool") then
 local ln = t.Name:lower()
 if ln:find("carpet") or ln:find("broom") or ln:find("cloud") or ln:find("fly") then
 pcall(function() hum:EquipTool(t) end)
 return true
 end
 end
	end
	for _, t in ipairs(char:GetChildren()) do
 if t:IsA("Tool") then
 local ln = t.Name:lower()
 if ln:find("carpet") or ln:find("broom") or ln:find("cloud") then
 return true
 end
 end
	end
	return false
end

function tpToBestChilli()
	-- removed per request
end
_G.RanaVSTpToBest = tpToBestChilli

-- UI: button on Panel + mobile + keybind
if St.keys.TpBest == nil then St.keys.TpBest = Enum.KeyCode.B end

task.defer(function()
	local pagePanel = pages and pages["Panel"]
	if pagePanel then
 section(pagePanel, "* — PANEL TP", 10)
 -- TP BEST removed
	-- actionBtn panel removed
 local info = row(pagePanel, 44, 12)
 local t = Instance.new("TextLabel")
 t.Size = UDim2.new(1, -10, 1, 0)
 t.Position = UDim2.new(0, 6, 0, 0)
 t.BackgroundTransparency = 1
 t.Text = "Infinite Jump Hold/Manual — BloodHounds"
 t.TextColor3 = C.textDim
 t.TextSize = 10
 t.Font = Enum.Font.Gotham
 t.TextXAlignment = Enum.TextXAlignment.Left
 t.Parent = info
	end
	-- also on Player for easy test
	if pagePlayer then
 section(pagePlayer, "* — INFINITE JUMP", 40)
 -- TP BEST removed
	end
end)

-- Mobile external button
task.defer(function()
	local g = Instance.new("ScreenGui")
	g.Name = "Rana.VSTpBestBtn"
	g.Enabled = false -- removed TP BEST
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = 1003
	g.Parent = PlayerGui
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 110, 0, 36)
	b.Position = UDim2.new(0.5, -55, 0, 12)
	b.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
	b.Text = "INF JUMP"
	b.TextColor3 = Color3.fromRGB(120, 255, 160)
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 13
	b.Parent = g
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	local s = Instance.new("UIStroke", b)
	s.Color = Color3.fromRGB(80, 220, 120)
	s.Thickness = 1.5
	b.MouseButton1Click:Connect(tpToBestChilli)
	-- drag
	do
 local dragging, dragStart, startPos, moved
 b.InputBegan:Connect(function(input)
 if St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 moved = false
 dragStart = input.Position
 startPos = b.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then dragging = false end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if not dragging or St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - dragStart
 if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
 if moved then
 b.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end
 end)
	end
end)

-- TP Best keybind removed



----------------------------------------------------------------
-- ============================================================
-- 12Hub TP BEST (ported from Rara): save point, visible ESP marker, carpet + vertical TP
-- State is grouped in one table to avoid the Luau 200-local limit.
-- ============================================================
local TPBest = {
    savedPosition = nil,
    marker = nil,
    moving = false,
    saveButton = nil,
    goButton = nil,
    minHeightRequired = 50,
    liftDuration = 0.3,
    upwardSpeed = 300,
    saveLastAt = 0,
    hintGui = nil,
    hintGeneration = 0,
    -- Anti Die is scoped to one TP Best run and is fully cleaned up afterward.
    antiDie = {
        active = false,
        humanoid = nil,
        character = nil,
        conns = {},
        characterConn = nil,
        originalMaxHealth = nil,
        originalDeadEnabled = nil,
        originalBreakJointsOnDeath = nil,
        resetCallbackDisabled = false,
    },
}

pcall(function()
    local oldMarker = workspace:FindFirstChild("12Hub_TPBestMarker")
    if oldMarker then oldMarker:Destroy() end
end)

TPBest.updateButton = function(button, label)
    if button and button.Parent then button.Text = label end
end

-- Center-screen reminder shown only while TP Best has no saved destination.
-- Repeated presses refresh the two-second timer; saving a location removes it immediately.
TPBest.hideSaveHint = function()
    TPBest.hintGeneration = (TPBest.hintGeneration or 0) + 1
    local oldGui = TPBest.hintGui
    TPBest.hintGui = nil
    if oldGui then pcall(function() oldGui:Destroy() end) end
end

TPBest.showSaveHint = function()
    if TPBest.savedPosition then
        TPBest.hideSaveHint()
        return
    end

    TPBest.hideSaveHint()
    local generation = TPBest.hintGeneration
    local parent = nil
    pcall(function()
        if type(gethui) == "function" then parent = gethui() end
    end)
    if not parent then
        pcall(function()
            parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 2)
        end)
    end
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent then return end

    local ok, gui = pcall(function()
        local screen = Instance.new("ScreenGui")
        screen.Name = "12Hub_TPBestSaveHint"
        screen.IgnoreGuiInset = true
        screen.ResetOnSpawn = false
        screen.DisplayOrder = 999990
        screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame")
        frame.Name = "HintFrame"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.fromScale(0.5, 0.5)
        frame.Size = UDim2.new(0.82, 0, 0, 68)
        frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        frame.BackgroundTransparency = 0.08
        frame.BorderSizePixel = 0
        frame.ZIndex = 1
        frame.Parent = screen

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 85, 150)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.12
        stroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "HintText"
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Size = UDim2.new(1, -24, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = "Chỉnh Save TP Best ở menu"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.ZIndex = 2
        label.Parent = frame

        local sizeLimit = Instance.new("UITextSizeConstraint")
        sizeLimit.MinTextSize = 14
        sizeLimit.MaxTextSize = 22
        sizeLimit.Parent = label

        screen.Parent = parent
        return screen
    end)
    if not ok or not gui then return end
    TPBest.hintGui = gui

    task.delay(2, function()
        if TPBest.hintGeneration ~= generation then return end
        if TPBest.hintGui == gui then TPBest.hintGui = nil end
        pcall(function() gui:Destroy() end)
    end)
end

-- Port of the Anti Die protection from the second source file, but with a
-- strict TP Best lifecycle: listeners exist only while TP Best is active.
TPBest.restoreAntiDieHumanoid = function(humanoid)
    local state = TPBest.antiDie
    if not humanoid or not humanoid.Parent then return end
    pcall(function()
        local maxHealth = tonumber(state.originalMaxHealth) or 100
        humanoid.MaxHealth = maxHealth
        humanoid.Health = math.min(humanoid.Health, maxHealth)
        if state.originalDeadEnabled ~= nil then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, state.originalDeadEnabled)
        else
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
        if state.originalBreakJointsOnDeath ~= nil then
            humanoid.BreakJointsOnDeath = state.originalBreakJointsOnDeath
        end
    end)
end

TPBest.clearAntiDieHumanoidConnections = function()
    local state = TPBest.antiDie
    for _, connection in ipairs(state.conns) do
        pcall(function() connection:Disconnect() end)
    end
    state.conns = {}
end

TPBest.applyAntiDieToCharacter = function(character)
    local state = TPBest.antiDie
    if not state.active or not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if state.humanoid == humanoid then return end

    TPBest.clearAntiDieHumanoidConnections()
    if state.humanoid then
        TPBest.restoreAntiDieHumanoid(state.humanoid)
    end

    state.character = character
    state.humanoid = humanoid
    state.originalMaxHealth = humanoid.MaxHealth
    state.originalDeadEnabled = nil
    state.originalBreakJointsOnDeath = nil
    pcall(function()
        state.originalDeadEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead)
    end)
    pcall(function()
        state.originalBreakJointsOnDeath = humanoid.BreakJointsOnDeath
    end)

    -- God-mode portion from the source: max health, heal-on-damage, and no Dead state.
    pcall(function()
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid.BreakJointsOnDeath = false
    end)

    table.insert(state.conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if not state.active or not humanoid.Parent then return end
        pcall(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end))

    table.insert(state.conns, humanoid.Died:Connect(function()
        if not state.active or not humanoid.Parent then return end
        pcall(function()
            humanoid.Health = humanoid.MaxHealth
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end))
end

TPBest.startAntiDie = function()
    local state = TPBest.antiDie
    if state.active then return end
    state.active = true

    -- Temporarily disable the reset button while the TP Best action is running.
    state.resetCallbackDisabled = pcall(function()
        game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
    end)

    TPBest.applyAntiDieToCharacter(LP.Character)
    if state.characterConn then
        pcall(function() state.characterConn:Disconnect() end)
        state.characterConn = nil
    end
    state.characterConn = LP.CharacterAdded:Connect(function(character)
        if not state.active then return end
        task.defer(function()
            if state.active then TPBest.applyAntiDieToCharacter(character) end
        end)
    end)
end

TPBest.stopAntiDie = function()
    local state = TPBest.antiDie
    -- Flip the flag before disconnecting so callbacks cannot restart protection.
    state.active = false
    if state.characterConn then
        pcall(function() state.characterConn:Disconnect() end)
        state.characterConn = nil
    end
    TPBest.clearAntiDieHumanoidConnections()
    if state.humanoid then
        TPBest.restoreAntiDieHumanoid(state.humanoid)
    end
    state.humanoid = nil
    state.character = nil
    state.originalMaxHealth = nil
    state.originalDeadEnabled = nil
    state.originalBreakJointsOnDeath = nil

    if state.resetCallbackDisabled then
        pcall(function()
            game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
        end)
    end
    state.resetCallbackDisabled = false
end

TPBest.createMarker = function(position)
    if TPBest.marker then pcall(function() TPBest.marker:Destroy() end) end
    TPBest.marker = nil
    pcall(function()
        local oldMarker = workspace:FindFirstChild("12Hub_TPBestMarker")
        if oldMarker then oldMarker:Destroy() end
    end)

    local marker = Instance.new("Part")
    marker.Name = "12Hub_TPBestMarker"
    marker.Shape = Enum.PartType.Ball
    marker.Size = Vector3.new(2.5, 2.5, 2.5)
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(255, 20, 147)
    marker.Transparency = 0.08
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.Position = position + Vector3.new(0, 2, 0)
    marker.Parent = workspace

    local light = Instance.new("PointLight")
    light.Name = "TPBestMarkerLight"
    light.Color = marker.Color
    light.Brightness = 1.5
    light.Range = 14
    light.Parent = marker

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TPBestESP"
    billboard.Adornee = marker
    billboard.Size = UDim2.fromOffset(140, 26)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 1000
    billboard.Parent = marker

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "TP BEST ESP"
    label.TextColor3 = marker.Color
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.08
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 14
    label.TextScaled = false
    label.Parent = billboard

    TPBest.marker = marker
end

TPBest.savePosition = function()
    local now = os.clock()
    if TPBest.saveLastAt > 0 and now - TPBest.saveLastAt < 0.12 then return end
    TPBest.saveLastAt = now
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        TPBest.updateButton(TPBest.saveButton, "Character Not Ready")
        task.delay(1.2, function()
            if TPBest.saveButton and TPBest.saveButton.Parent then
                TPBest.saveButton.Text = "Save TP Best"
            end
        end)
        return
    end

    TPBest.savedPosition = root.Position
    -- A successful save permanently silences the unsaved-location reminder.
    TPBest.hideSaveHint()
    TPBest.createMarker(TPBest.savedPosition)
    TPBest.updateButton(TPBest.saveButton, "TP Best Saved ✓")
    task.delay(1.2, function()
        if TPBest.saveButton and TPBest.saveButton.Parent then
            TPBest.saveButton.Text = "Save TP Best"
        end
    end)
end

TPBest.equipCarpet = function()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local backpack = LP:FindFirstChild("Backpack")
    if not hum or not backpack then return false end
    local tool = char:FindFirstChild("Flying Carpet") or backpack:FindFirstChild("Flying Carpet")
    if tool and tool:IsA("Tool") then
        pcall(function() hum:EquipTool(tool) end)
        return true
    end
    return false
end

TPBest.teleport = function()
    if TPBest.moving then return end
    if not TPBest.savedPosition then
        -- This path is shared by the menu button, mobile button, and keybind.
        -- Never show the reminder once a valid TP Best position has been saved.
        TPBest.showSaveHint()
        return
    end

    TPBest.moving = true
    TPBest.updateButton(TPBest.goButton, "Going Up...")
    -- Keep TP Best running even if an executor rejects one Anti Die API call.
    pcall(TPBest.startAntiDie)
    TPBest.equipCarpet()
    local startedAt = os.clock()
    local connection
    local finished = false

    local function finishTPBest()
        if finished then return end
        finished = true
        if connection then pcall(function() connection:Disconnect() end) end
        -- TP Best has ended: stop Anti Die, restore normal Humanoid behavior,
        -- restore the reset button, and disconnect every temporary listener.
        pcall(TPBest.stopAntiDie)
        TPBest.moving = false
        TPBest.updateButton(TPBest.goButton, "TP Best")
    end

    local connectOk, heartbeatConnection = pcall(function()
        return RS.Heartbeat:Connect(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not root.Parent then
            finishTPBest()
            return
        end

        if os.clock() - startedAt >= TPBest.liftDuration then
            local target = TPBest.savedPosition
            if target and root.Position.Y >= target.Y + TPBest.minHeightRequired then
                root.CFrame = CFrame.new(target)
            end
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
            finishTPBest()
            return
        end

        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(0, TPBest.upwardSpeed, 0)
        end)
        end)
    end)
    if connectOk and heartbeatConnection then
        connection = heartbeatConnection
    else
        finishTPBest()
    end
end

-- Used by the mobile button, created earlier in the script.
_G.RanaVSTPBestTeleport = function()
    if TPBest and TPBest.teleport then return TPBest.teleport() end
end

-- OVERHEAD: real speed + discord (from RanaVS)
----------------------------------------------------------------
local overheadGui, overheadSpeedLabel
function setupOverheadInfo(char)
	char = char or LP.Character
	if not char then return end
	local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
	if not head then
 -- fallback HRP
 head = char:FindFirstChild("HumanoidRootPart")
 if not head then return end
	end
	pcall(function()
 local old = head:FindFirstChild("Rana.VSOverheadInfo")
 if old then old:Destroy() end
	end)
	if overheadGui then pcall(function() overheadGui:Destroy() end) end
	overheadGui = Instance.new("BillboardGui")
	overheadGui.Name = "Rana.VSOverheadInfo"
	overheadGui.Size = UDim2.new(0, 300, 0, 96)
	overheadGui.StudsOffset = Vector3.new(0, 2.8, 0)
	overheadGui.AlwaysOnTop = true
	overheadGui.MaxDistance = 200
	overheadGui.LightInfluence = 0
	overheadGui.Adornee = head
	overheadGui.Parent = head
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, 0, 0, 22)
	titleLbl.Position = UDim2.new(0, 0, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "monster.vs🍀"
	titleLbl.TextColor3 = Color3.fromRGB(255, 220, 100)
	titleLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	titleLbl.TextStrokeTransparency = 0
	titleLbl.Font = Enum.Font.Bangers
	titleLbl.TextSize = 17
	titleLbl.Parent = overheadGui
	local discordLbl = Instance.new("TextLabel")
	discordLbl.Size = UDim2.new(1, 0, 0, 20)
	discordLbl.Position = UDim2.new(0, 0, 0, 22)
	discordLbl.BackgroundTransparency = 1
	discordLbl.Text = "monster.vs🍀"
	discordLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	discordLbl.TextStrokeTransparency = 0
	discordLbl.Font = Enum.Font.Bangers
	discordLbl.TextSize = 16
	discordLbl.Parent = overheadGui
	overheadSpeedLabel = Instance.new("TextLabel")
	overheadSpeedLabel.Size = UDim2.new(1, 0, 0, 22)
	overheadSpeedLabel.Position = UDim2.new(0, 0, 0, 44)
	overheadSpeedLabel.BackgroundTransparency = 1
	overheadSpeedLabel.Text = "Speed: 0.0"
	overheadSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	overheadSpeedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	overheadSpeedLabel.TextStrokeTransparency = 0
	overheadSpeedLabel.Font = Enum.Font.Bangers
	overheadSpeedLabel.TextSize = 18
	overheadSpeedLabel.Parent = overheadGui
end
if not _G._VisOverheadLoop then
	_G._VisOverheadLoop = true
	LP.CharacterAdded:Connect(function(ch)
 task.wait(0.5)
 setupOverheadInfo(ch)
	end)
	if LP.Character then task.defer(function() setupOverheadInfo(LP.Character) end) end
	local overheadTextAccumulator = 0
	RS.Heartbeat:Connect(function(dt)
 overheadTextAccumulator += dt
 if overheadTextAccumulator < 0.10 then return end
 overheadTextAccumulator = overheadTextAccumulator % 0.10
 if not overheadSpeedLabel or not overheadSpeedLabel.Parent then return end
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local v = root.AssemblyLinearVelocity
 local actual = Vector3.new(v.X, 0, v.Z).Magnitude
 local target = 0
 pcall(function() target = getActiveMoveSpeed() end)
 local nextText
 if St.speedOn and target > 0 then
     nextText = string.format("Speed: %.0f", target)
 else
     nextText = string.format("Speed: %.1f", actual)
 end
 if overheadSpeedLabel.Text ~= nextText then overheadSpeedLabel.Text = nextText end
	end)
end


print("[12Hub] TP TO BEST (Chilli) ready | key B | nut TP BEST")



-- ============================================================
----------------------------------------------------------------
-- 12Hub: FULL AUTO STEAL is embedded directly from the LaPeak
-- engine above. No readfile dependency and no legacy Ace engine.
----------------------------------------------------------------
task.defer(function()
    _12HubNormalizeStealSelection(selectedStealMode, autoStealV2Version)
    if St.autoSteal then
        pcall(_12HubSyncAutoSteal)
    end
end)
-- Wallpaper list (12Hub style)
local VIS_WALLS = {
    -- Ace's five built-in main backgrounds + custom background requested by the user.
    "rbxassetid://131144372786668",
    "rbxassetid://140621499704884",
    "rbxassetid://119732827199607",
    "rbxassetid://88365163058110",
    "rbxassetid://127036597369559",
    "rbxassetid://130597903284552",
}
if St._aceLegacyWallpaperGalleryV2 ~= true then
    St.wallIndex = 2
    St._aceLegacyWallpaperGalleryV2 = true
end
St.wallIndex = math.clamp(math.floor(tonumber(St.wallIndex) or 2), 1, math.max(1, #VIS_WALLS))
task.defer(function()
	if not pageSet then return end
	section(pageSet, "* — WALLPAPER", 25)
	local wr = row(pageSet, 40, 28)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 56, 0, 32)
	img.Position = UDim2.new(0, 8, 0.5, -16)
	img.BackgroundColor3 = C.box
	img.ScaleType = Enum.ScaleType.Crop
	img.Image = VIS_WALLS[St.wallIndex] or VIS_WALLS[1]
	img.ZIndex = 2
	img.Parent = wr
	Instance.new("UICorner", img).CornerRadius = UDim.new(0, 6)
	local idxLbl = Instance.new("TextLabel")
	idxLbl.Size = UDim2.new(0, 48, 0, 20)
	idxLbl.Position = UDim2.new(0, 70, 0.5, -10)
	idxLbl.BackgroundTransparency = 1
	idxLbl.Text = "#" .. tostring(St.wallIndex) .. "/" .. tostring(#VIS_WALLS)
	idxLbl.TextColor3 = C.textDim
	idxLbl.Font = Enum.Font.GothamBold
	idxLbl.TextSize = 11
	idxLbl.ZIndex = 2
	idxLbl.Parent = wr
	local function applyWall()
 local n = #VIS_WALLS
 if n < 1 then return end
 St.wallIndex = ((tonumber(St.wallIndex) or 1) - 1) % n + 1
 local asset = VIS_WALLS[St.wallIndex]
 img.Image = asset
 idxLbl.Text = "#" .. tostring(St.wallIndex) .. "/" .. tostring(n)
 local bg = Main:FindFirstChild("WallBG")
 if not bg then
 bg = Instance.new("ImageLabel")
 bg.Name = "WallBG"
 bg.Size = UDim2.new(1, 0, 1, 0)
 bg.Position = UDim2.new(0, 0, 0, 0)
 bg.BackgroundTransparency = 1
 bg.ScaleType = Enum.ScaleType.Crop
 bg.ZIndex = 0
 bg.Active = false
 bg.Selectable = false
 bg.ZIndex = 0
 bg.Parent = Main
 -- dim overlay for deeper look while keeping UI clickable
 local dim = Instance.new("Frame")
 dim.Name = "WallDim"
 dim.Size = UDim2.new(1, 0, 1, 0)
 dim.BackgroundColor3 = Color3.new(0, 0, 0)
 dim.BackgroundTransparency = 0.45
 dim.BorderSizePixel = 0
 dim.ZIndex = 0
 dim.Active = false
 dim.Selectable = false
 dim.Parent = Main
 Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
 for _, ch in ipairs(Main:GetChildren()) do
 if ch ~= bg and ch.Name ~= "WallDim" and ch:IsA("GuiObject") then
 if ch.ZIndex < 2 then ch.ZIndex = 2 end
 end
 end
 end
 bg.Image = asset
 bg.ImageTransparency = math.clamp(tonumber(St.wallOpacity) or 0.12, 0, 0.85)
 pcall(function()
     if type(_G.RanaVSSetMainMenuWallpaper) == "function" then
         _G.RanaVSSetMainMenuWallpaper(asset)
     end
 end)
 bg.Active = false
 bg.Selectable = false
 bg.ScaleType = Enum.ScaleType.Crop
 bg.Visible = true
 Main.BackgroundTransparency = 0.55
 saveCfg()
	end
	applyWall()
	for i, sign in ipairs({"-", "+"}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 30, 0, 28)
 b.Position = UDim2.new(1, -72 + (i-1)*34, 0.5, -14)
 b.BackgroundColor3 = C.box
 b.Text = sign
 b.TextColor3 = C.text
 b.Font = Enum.Font.GothamBold
 b.TextSize = 16
 b.AutoButtonColor = true
 b.Active = true
 b.ZIndex = 3
 b.Parent = wr
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
 local function step()
 local n = #VIS_WALLS
 if n < 1 then return end
 St.wallIndex = (tonumber(St.wallIndex) or 1) + (sign == "+" and 1 or -1)
 if St.wallIndex < 1 then St.wallIndex = n end
 if St.wallIndex > n then St.wallIndex = 1 end
 applyWall()
 end
 b.MouseButton1Click:Connect(step)
 b.Activated:Connect(step)
	end
	-- V3 mode button in auto steal section
	if pagePlayer then
 -- add V3 option note via reusing stealVer
	end
end)

-- Mini = circle combat when closed
task.defer(function()
	local miniGui = PlayerGui:FindFirstChild("Rana.VSHubFullMini")
	local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
	if mini then
 mini.Size = UDim2.new(0, 110, 0, 36)
 mini.Text = "monster.vs🍀"
 mini.TextSize = 22
 local c0 = mini:FindFirstChildOfClass("UICorner")
 if c0 then c0.CornerRadius = UDim.new(0, 8) end
	end
	-- Title bar rectangle text
	local mainGui = PlayerGui:FindFirstChild("Rana.VSHubFullMenu")
	local main = mainGui and mainGui:FindFirstChild("Main")
	if main then
 local top = main:FindFirstChild("TopBar") or main:FindFirstChildWhichIsA("Frame")
 if top then
 for _, x in ipairs(top:GetDescendants()) do
 if x:IsA("TextLabel") and (x.Text:find("VIS") or x.Text:find("Vis")) then
 x.Text = "monster.vs🍀"
 end
 end
 end
	end
end)

-- Watchdog: nếu toggle ON mà logic chết → ON lại
if not _G._VisLogicWatchdog then
	_G._VisLogicWatchdog = true
	task.spawn(function()
 while true do
 task.wait(8)
 pcall(function()
 if St.speedOn then
 local alive = false
 if speedConnection then pcall(function() alive = speedConnection.Connected == true end) end
 if not alive and startSpeedBoost then
 speedConnection = nil
 startSpeedBoost()
 end
 end
 if St.infJump and InfJumpState and not InfJumpState.enabled then
 if startInfJump then startInfJump() end
 end
 if St.antiRagdoll and AntiRagdollV2 and not AntiRagdollV2.Enabled then
 if startAntiRagdoll then startAntiRagdoll() end
 end
 if St.autoSteal and _G.RanaVSSyncAutoSteal then
 pcall(_G.RanaVSSyncAutoSteal)
 end
 end)
 end
	end)
end

print("[Free All Gear] Speed | InfJump Empire | RagdollTP | AutoSteal | Wallpaper | Control")


-- Auto-save UI state as a fallback every 10s; drag/toggle callbacks save immediately.
task.spawn(function()
	while task.wait(10) do
 pcall(function()
 -- Main menu: only visibility persists; position resets to center on every run.
 local _ownedMain = _G.RanaVSLaPeakHybridMain or Main
 if _ownedMain and _ownedMain.Parent then
 St.menuOpen = _ownedMain.Visible == true
 end
 -- Mini open button
 local miniGui = PlayerGui:FindFirstChild("Rana.VSHubFullMini")
 local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
 if mini then
 St._miniPos = {mini.Position.X.Scale, mini.Position.X.Offset, mini.Position.Y.Scale, mini.Position.Y.Offset}
 end
 -- Mode bar
 local mb = PlayerGui:FindFirstChild("Rana.VSHubModeBar")
 if mb then
 local f = mb:FindFirstChildWhichIsA("Frame")
 if f then
 St._modeBarPos = {f.Position.X.Scale, f.Position.X.Offset, f.Position.Y.Scale, f.Position.Y.Offset}
 end
 end
 -- Action + Mode buttons: lưu POSITION của Frame holder (A_* / M_*), không phải TextButton
 St._btnPos = St._btnPos or {}
 local function snapHolders(gui)
 if not gui then return end
 for _, holder in ipairs(gui:GetChildren()) do
 if holder:IsA("Frame") or holder:IsA("TextButton") then
 local key = holder.Name
 if key and (key:sub(1,2) == "A_" or key:sub(1,2) == "M_") then
 St._btnPos[key] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 holder.Size.X.Offset, holder.Size.Y.Offset
 }
 end
 end
 end
 end
 snapHolders(PlayerGui:FindFirstChild("Rana.VSHubActionButtons"))
 snapHolders(PlayerGui:FindFirstChild("Rana.VSHubModeBar"))
 -- 12Hub All Gear TP panel intentionally resets to center every run; no position persistence.
 -- Auto Steal floating GUI pos if any
 local asg = PlayerGui:FindFirstChild("Rana.VSAutoStealGui")
 if asg then
 local mf = asg:FindFirstChildWhichIsA("Frame")
 if mf then
 St._stealGuiPos = {mf.Position.X.Scale, mf.Position.X.Offset, mf.Position.Y.Scale, mf.Position.Y.Offset}
 end
 end
 saveCfg() -- dump toàn bộ St
 end)
	end
end)

-- Main menu position intentionally resets to center on each execution.

-- Legacy mini/menu visibility restore removed; LaPeak menu owns open/close state.

-- ============================================================
-- ============================================================
-- PANEL TP 12HUB — full GUI logic from uploaded allgearonetop file.
-- Starts centered every execution and stays on top.
-- ============================================================
do -- isolate legacy All Gear TP panel locals
local a = game:GetService("Players")
local b = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local c = a.LocalPlayer

local _0x0001 = nil
local _0x0002 = nil
local _0x0004 = nil
local _0x0005 = nil

local currentKeybind = Enum.KeyCode.T
local isSettingKeybind = false

local function _0xMARKER_CREATE(pos, col)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(2.5,2.5,2.5)
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Position = pos + Vector3.new(0,2,0)
	part.Color = col
	part.Name = "MarkerPoint"
	part.Parent = workspace
	return part
end

-- ==================== GIAO DIỆN PHONG CÁCH ANIME ====================
local _0xSCREEN = Instance.new("ScreenGui")
_0xSCREEN.Name = "12Hub_AllGearOnTop"
_0xSCREEN.ResetOnSpawn = false
_0xSCREEN.IgnoreGuiInset = true
_0xSCREEN.DisplayOrder = 100000
_0xSCREEN.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_0xSCREEN.Enabled = St.showTPPanel ~= false
_0xSCREEN.Parent = game.CoreGui

-- Khung chính chứa ảnh nền Anime
local _0xMAIN = Instance.new("ImageLabel")
_0xMAIN.Parent = _0xSCREEN
_0xMAIN.Name = "12Hub_TPPanelMain"
_0xMAIN.Size = UDim2.new(0,230,0,270)
_0xMAIN.Position = UDim2.new(0.5,-115,0.5,-135)
-- Sử dụng ID ảnh nền Anime chất lượng cao (Bạn có thể đổi ID khác nếu muốn)
_0xMAIN.Image = "rbxassetid://130597903284552" 
_0xMAIN.ImageColor3 = Color3.fromRGB(220, 220, 220) -- Làm dịu bớt độ chói của ảnh
_0xMAIN.ScaleType = Enum.ScaleType.Crop
_0xMAIN.Active = true
-- The general 12Hub LOCK also freezes the floating TP panel.
_0xMAIN.Draggable = St.menuGuiLocked ~= true

Instance.new("UICorner", _0xMAIN).CornerRadius = UDim.new(0,16)

-- Lớp phủ màu tối nhẹ để chữ nổi bật trên nền ảnh Anime
local _0xOVERLAY = Instance.new("Frame")
_0xOVERLAY.Parent = _0xMAIN
_0xOVERLAY.Size = UDim2.new(1,0,1,0)
_0xOVERLAY.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
_0xOVERLAY.BackgroundTransparency = 0.45 -- Độ trong suốt của lớp phủ
_0xOVERLAY.BorderSizePixel = 0
Instance.new("UICorner", _0xOVERLAY).CornerRadius = UDim.new(0,16)

-- Viền Neon phát sáng phong cách Anime
local _0xSTROKE = Instance.new("UIStroke")
_0xSTROKE.Parent = _0xMAIN
_0xSTROKE.Color = Color3.fromRGB(255, 105, 180) -- Màu hồng Neon Anime
_0xSTROKE.Thickness = 3

task.spawn(function()
	while true do
		b:Create(_0xSTROKE, TweenInfo.new(1.5), {Color = Color3.fromRGB(255, 105, 180)}):Play()
		task.wait(1.5)
		b:Create(_0xSTROKE, TweenInfo.new(1.5), {Color = Color3.fromRGB(140, 85, 255)}):Play() -- Chuyển màu sang tím Neon
		task.wait(1.5)
	end
end)

local _0xTITLE = Instance.new("TextLabel")
_0xTITLE.Parent = _0xMAIN
_0xTITLE.Size = UDim2.new(1,0,0,35)
_0xTITLE.BackgroundTransparency = 1
_0xTITLE.Text = "monster.vs🍀"
_0xTITLE.TextColor3 = Color3.fromRGB(255, 255, 255)
_0xTITLE.Font = Enum.Font.FredokaOne -- Font chữ phong cách dễ thương/Anime
_0xTITLE.TextSize = 22
_0xTITLE.TextStrokeTransparency = 0.5
_0xTITLE.TextStrokeColor3 = Color3.fromRGB(0,0,0)

local _0xCLOSE = Instance.new("TextButton")
_0xCLOSE.Parent = _0xMAIN
_0xCLOSE.Size = UDim2.new(0,24,0,24)
_0xCLOSE.Position = UDim2.new(0,8,0,6)
_0xCLOSE.BackgroundColor3 = Color3.fromRGB(255, 65, 110)
_0xCLOSE.Text = "X"
_0xCLOSE.TextColor3 = Color3.fromRGB(255,255,255)
_0xCLOSE.Font = Enum.Font.GothamBold
_0xCLOSE.TextSize = 14
Instance.new("UICorner", _0xCLOSE).CornerRadius = UDim.new(1,0)

local function _0xCREATE_BTN(text, pos, color)
	local btn = Instance.new("TextButton")
	btn.Parent = _0xMAIN
	btn.Size = UDim2.new(0,195,0,38)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.15 -- Nút hơi trong suốt chuẩn UI Anime hiện đại
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15
	btn.TextStrokeTransparency = 0.7
	btn.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
	
	-- Hiệu ứng lướt chuột qua nút (Hover Effect)
	btn.MouseEnter:Connect(function()
		b:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	end)
	btn.MouseLeave:Connect(function()
		b:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
	end)
	
	return btn
end

-- Đổi màu các nút theo tông Anime dễ thương và nổi bật
local _0xBTN1 = _0xCREATE_BTN("📍 Base người khác", UDim2.new(0.5,-97,0,50), Color3.fromRGB(150, 90, 255))
local _0xBTN2 = _0xCREATE_BTN("🐾 Lưu pet người khác", UDim2.new(0.5,-97,0,100), Color3.fromRGB(255, 130, 45))
local _0xBTN3 = _0xCREATE_BTN("🧪 Auto Potion : OFF", UDim2.new(0.5,-97,0,150), Color3.fromRGB(255, 75, 90))
local _0xBTN4 = _0xCREATE_BTN("⚡ TP [T]", UDim2.new(0.5,-97,0,200), Color3.fromRGB(0, 185, 135))

local _0xAUTOPOT = false
_0xBTN3.MouseButton1Click:Connect(function()
	_0xAUTOPOT = not _0xAUTOPOT
	if _0xAUTOPOT then
		_0xBTN3.Text = "🧪 Auto Potion : ON"
		_0xBTN3.BackgroundColor3 = Color3.fromRGB(45, 200, 85)
	else
		_0xBTN3.Text = "🧪 Auto Potion : OFF"
		_0xBTN3.BackgroundColor3 = Color3.fromRGB(255, 75, 90)
	end
end)

local _0xMINI = false
_0xCLOSE.MouseButton1Click:Connect(function()
	_0xMINI = not _0xMINI
	if _0xMINI then
		_0xBTN1.Visible = false
		_0xBTN2.Visible = false
		_0xBTN3.Visible = false
		_0xMAIN.Size = UDim2.new(0,230,0,95)
		_0xBTN4.Position = UDim2.new(0.5,-97,0,45)
		_0xCLOSE.Text = "+"
	else
		_0xBTN1.Visible = true
		_0xBTN2.Visible = true
		_0xBTN3.Visible = true
		_0xMAIN.Size = UDim2.new(0,230,0,270)
		_0xBTN4.Position = UDim2.new(0.5,-97,0,200)
		_0xCLOSE.Text = "X"
	end
end)

_0xBTN1.MouseButton1Click:Connect(function()
	local hrp = c.Character and c.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		_0x0001 = hrp.Position
		if _0x0004 then _0x0004:Destroy() end
		_0x0004 = _0xMARKER_CREATE(_0x0001, Color3.fromRGB(255, 105, 180))
		_0xBTN1.Text = "✨ Đã lưu base ✨"
		task.wait(0.8)
		_0xBTN1.Text = "📍 Base người khác"
	end
end)

_0xBTN2.MouseButton1Click:Connect(function()
	local hrp = c.Character and c.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		_0x0002 = hrp.Position
		if _0x0005 then _0x0005:Destroy() end
		_0x0005 = _0xMARKER_CREATE(_0x0002, Color3.fromRGB(255, 140, 0))
		_0xBTN2.Text = "✨ Đã lưu pet ✨"
		task.wait(0.8)
		_0xBTN2.Text = "🐾 Lưu pet người khác"
	end
end)

local function _0xEQUIP_CAR()
	local char = c.Character
	local bp = c:FindFirstChild("Backpack")
	if not char or not bp then return false end
	for _,tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then tool.Parent = bp end
	end
	for _,tool in pairs(bp:GetChildren()) do
		if tool:IsA("Tool") and string.find(tool.Name:lower(),"carpet") then
			tool.Parent = char
			return true
		end
	end
	return false
end

local function DO_TELEPORT()
	if not _0x0001 or not _0x0002 then
		_0xBTN4.Text = "❌ Chưa đủ điểm"
		task.wait(1)
		_0xBTN4.Text = "⚡ TP [" .. currentKeybind.Name .. "]"
		return
	end

	local char = c.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	_0xBTN4.Text = "💫 Đang TP..."
	_0xEQUIP_CAR()

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(_0x0001 + Vector3.new(0,3,0))
	task.wait(0.1)
	hrp.CFrame = CFrame.new(_0x0002 + Vector3.new(0,3,0))

	_0xBTN4.Text = "⭐ Đã TP x2 ⭐"

	if _0xAUTOPOT then
		local bp = c:FindFirstChild("Backpack")
		task.wait(0.15)
		for _,tool in pairs(bp:GetChildren()) do
			if tool:IsA("Tool") then
				local n = tool.Name:lower()
				if n:find("giant") or n:find("huge") or n:find("gigant") then
					tool.Parent = c.Character
					task.wait(0.1)
					tool:Activate()
					break
				end
			end
		end
	end

	task.wait(0.8)
	_0xBTN4.Text = "⚡ TP [" .. currentKeybind.Name .. "]"
end

_0xBTN4.MouseButton1Click:Connect(function()
	if not isSettingKeybind then
		DO_TELEPORT()
	end
end)

_0xBTN4.MouseButton2Click:Connect(function()
	if not isSettingKeybind then
		isSettingKeybind = true
		_0xBTN4.Text = "🌸 Nhấn phím mới..."
		_0xBTN4.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
	end
end)

uis.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if isSettingKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
		currentKeybind = input.KeyCode
		isSettingKeybind = false
		_0xBTN4.Text = "⚡ TP [" .. currentKeybind.Name .. "]"
		_0xBTN4.BackgroundColor3 = Color3.fromRGB(0, 185, 135)
		return
	end
	
	if input.KeyCode == currentKeybind and not isSettingKeybind then
		DO_TELEPORT()
	end
end)

print("[12Hub] All Gear TP panel loaded successfully!")
end -- end isolated All Gear TP panel

-- ============================================================
-- ============================================================
-- ACE-STYLE STEAL BAR — Ace-like 300x52 HUD, shared lock, persistent drag/scale.
-- Keeps the existing StealBar API used by all embedded Auto Steal engines.
-- ============================================================
task.spawn(function()
    local previousStealBarConnections = _G._12HubStealBarConnections
    if type(previousStealBarConnections) == "table" then
        for _, conn in ipairs(previousStealBarConnections) do pcall(function() conn:Disconnect() end) end
    end
    local stealBarConnections = {}
    _G._12HubStealBarConnections = stealBarConnections
    local function connectStealBar(signal, callback)
        local conn = signal:Connect(callback)
        table.insert(stealBarConnections, conn)
        return conn
    end

    local oldNamesBar = {"Rana.VSStealBarOnly", "AceStealBar", "RaVeStealHUD"}
    for _, oldNameBar in ipairs(oldNamesBar) do
        local oldBar = PlayerGui:FindFirstChild(oldNameBar)
        if oldBar then pcall(function() oldBar:Destroy() end) end
    end

    local barGui = Instance.new("ScreenGui")
    barGui.Name = "Rana.VSStealBarOnly"
    barGui.ResetOnSpawn = false
    barGui.IgnoreGuiInset = true
    barGui.DisplayOrder = 200000
    barGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    barGui.Parent = PlayerGui
    connectStealBar(barGui.AncestryChanged, function(_, parent)
        if parent == nil then
            for _, conn in ipairs(stealBarConnections) do pcall(function() conn:Disconnect() end) end
            if _G._12HubStealBarConnections == stealBarConnections then _G._12HubStealBarConnections = nil end
        end
    end)

    local barScaleValue = math.clamp(tonumber(St.stealBarScale) or 1, 0.5, 1.5)
    local barFrame = Instance.new("Frame")
    barFrame.Name = "StealBar"
    barFrame.Size = UDim2.fromOffset(300, 52)
    barFrame.AnchorPoint = Vector2.new(0.5, 1)
    barFrame.Position = type(St._stealBarPos) == "table"
        and UDim2.new(tonumber(St._stealBarPos[1]) or 0.5, tonumber(St._stealBarPos[2]) or 0,
            tonumber(St._stealBarPos[3]) or 1, tonumber(St._stealBarPos[4]) or -12)
        or UDim2.new(0.5, 0, 1, -12)
    barFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 5)
    barFrame.BackgroundTransparency = 0.02
    barFrame.BorderSizePixel = 0
    barFrame.Active = true
    barFrame.ZIndex = 50
    barFrame.Parent = barGui
    Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 8)

    local barScale = Instance.new("UIScale")
    barScale.Name = "StealBarUIScale"
    barScale.Scale = barScaleValue
    barScale.Parent = barFrame

    local barGradient = Instance.new("UIGradient")
    barGradient.Rotation = 90
    barGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 14, 18)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 3, 5)),
    })
    barGradient.Parent = barFrame

    local barStroke = Instance.new("UIStroke")
    barStroke.Name = "AceStealBarStroke"
    barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    barStroke.Thickness = 1.4
    barStroke.Color = Color3.fromRGB(70, 78, 90)
    barStroke.Transparency = 0.32
    barStroke.Parent = barFrame

    local barPlayer = Players.LocalPlayer or LP
    local barAvatar = Instance.new("ImageLabel")
    barAvatar.Name = "PlayerStealIcon"
    barAvatar.Size = UDim2.fromOffset(28, 28)
    barAvatar.Position = UDim2.fromOffset(7, 12)
    barAvatar.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
    barAvatar.BackgroundTransparency = 0
    barAvatar.BorderSizePixel = 0
    barAvatar.ImageColor3 = Color3.fromRGB(255,255,255)
    barAvatar.ImageTransparency = 0
    barAvatar.ScaleType = Enum.ScaleType.Crop
    barAvatar.Visible = true
    barAvatar.ZIndex = 56
    barAvatar.Parent = barFrame
    Instance.new("UICorner", barAvatar).CornerRadius = UDim.new(1, 0)
    local avatarStroke = Instance.new("UIStroke", barAvatar)
    avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    avatarStroke.Color = Color3.fromRGB(156, 169, 186)
    avatarStroke.Thickness = 1
    avatarStroke.Transparency = 0.30
    -- Set a thumbnail URI immediately so the icon is not blank while the web thumbnail resolves.
    if barPlayer then
        barAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(barPlayer.UserId) .. "&w=150&h=150"
    end
    task.spawn(function()
        if not barPlayer then return end
        for attempt = 1, 6 do
            if not (barAvatar and barAvatar.Parent) then return end
            local okThumb, thumb, isReady = pcall(function()
                return Players:GetUserThumbnailAsync(barPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if okThumb and type(thumb) == "string" and thumb ~= "" then
                barAvatar.Image = thumb
                if isReady then return end
            end
            task.wait(0.35)
        end
    end)

    local divider = Instance.new("Frame")
    divider.Name = "IconDivider"
    divider.Size = UDim2.fromOffset(1, 30)
    divider.Position = UDim2.fromOffset(42, 7)
    divider.BackgroundColor3 = Color3.fromRGB(80, 86, 96)
    divider.BackgroundTransparency = 0.38
    divider.BorderSizePixel = 0
    divider.ZIndex = 51
    divider.Parent = barFrame

    local percentLabel = Instance.new("TextLabel")
    percentLabel.Name = "Percent"
    percentLabel.Size = UDim2.fromOffset(88, 24)
    percentLabel.Position = UDim2.fromOffset(51, 3)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    percentLabel.Font = Enum.Font.GothamBlack
    percentLabel.TextSize = 17
    percentLabel.TextXAlignment = Enum.TextXAlignment.Left
    percentLabel.ZIndex = 52
    percentLabel.Parent = barFrame

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "PerformanceStats"
    statsLabel.Size = UDim2.new(1, -146, 0, 15)
    statsLabel.Position = UDim2.new(1, -8, 0, 8)
    statsLabel.AnchorPoint = Vector2.new(1, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.RichText = true
    statsLabel.Text = "<b>FPS 0  PING 0ms</b>"
    statsLabel.TextColor3 = Color3.fromRGB(170, 176, 186)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextSize = 9
    statsLabel.TextXAlignment = Enum.TextXAlignment.Right
    statsLabel.TextTruncate = Enum.TextTruncate.AtEnd
    statsLabel.ZIndex = 52
    statsLabel.Parent = barFrame

    local stateLabel = Instance.new("TextLabel")
    stateLabel.Name = "AutoStealState"
    stateLabel.Size = UDim2.new(1, -146, 0, 12)
    stateLabel.Position = UDim2.new(1, -8, 0, 23)
    stateLabel.AnchorPoint = Vector2.new(1, 0)
    stateLabel.BackgroundTransparency = 1
    stateLabel.Text = "AUTO STEAL · OFF"
    stateLabel.TextColor3 = Color3.fromRGB(142, 148, 158)
    stateLabel.Font = Enum.Font.GothamMedium
    stateLabel.TextSize = 8
    stateLabel.TextXAlignment = Enum.TextXAlignment.Right
    stateLabel.TextTruncate = Enum.TextTruncate.AtEnd
    stateLabel.ZIndex = 52
    stateLabel.Parent = barFrame

    local track = Instance.new("Frame")
    track.Name = "ProgressTrack"
    track.Size = UDim2.new(1, -50, 0, 8)
    track.Position = UDim2.new(0, 48, 1, -5)
    track.AnchorPoint = Vector2.new(0, 1)
    track.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.ZIndex = 51
    track.Parent = barFrame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Name = "ProgressFill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(225, 229, 235)
    fill.BorderSizePixel = 0
    fill.ZIndex = 52
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(242, 244, 247)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 140, 154)),
    })
    fillGradient.Parent = fill

    -- Ace's restrained floating pixel lanes, in grey/white rather than adding a new accent palette.
    local lanes = {}
    local rng = Random.new()
    for laneIndex = 1, 8 do
        local dotSize = (laneIndex % 3 == 0) and 3 or 2
        local dot = Instance.new("Frame")
        dot.Name = "Dot" .. laneIndex
        dot.Size = UDim2.fromOffset(dotSize, dotSize)
        dot.Position = UDim2.new(rng:NextNumber(0.15, 0.92), 0, rng:NextNumber(0.2, 0.7), 0)
        dot.BackgroundColor3 = Color3.fromRGB(194, 200, 210)
        dot.BackgroundTransparency = rng:NextNumber(0.62, 0.84)
        dot.BorderSizePixel = 0
        dot.Active = false
        dot.ZIndex = 51
        dot.Parent = barFrame
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        lanes[#lanes + 1] = {dot = dot, x = dot.Position.X.Scale, y = dot.Position.Y.Scale, speed = rng:NextNumber(0.02, 0.055), phase = rng:NextNumber(0, 6.28)}
    end

    local explicitState = "OFF"
    local resetToken = 0
    _G.AceStealBarProgress = math.clamp(tonumber(_G.AceStealBarProgress) or 0, 0, 1)

    -- The engines publish a target progress value. Render it every frame with a short,
    -- frame-rate-independent catch-up so progress never stalls at the old 12 Hz throttle.
    local displayedProgress = math.clamp(tonumber(_G.AceStealBarProgress) or 0, 0, 1)
    local lastShownPercent = -1
    local lastStateText = ""
    local lastStateColor = nil
    local lastStrokeTransparency = nil
    local laneAcc = 0
    local function refreshBar(dt, snapProgress)
        if not barFrame.Parent or not barFrame.Visible then return end
        dt = math.clamp(tonumber(dt) or (1 / 60), 0, 0.1)
        local isOn = (St.autoSteal == true) or (autoStealEnabled == true)
        local targetProgress = isOn and math.clamp(tonumber(_G.AceStealBarProgress) or 0, 0, 1) or 0
        if snapProgress then
            displayedProgress = targetProgress
        else
            -- ~35 ms response constant: responsive to each engine update, but visually smooth.
            local alpha = 1 - math.exp(-dt * 28)
            displayedProgress += (targetProgress - displayedProgress) * alpha
            if math.abs(targetProgress - displayedProgress) < 0.001 then
                displayedProgress = targetProgress
            end
        end
        fill.Size = UDim2.new(math.clamp(displayedProgress, 0, 1), 0, 1, 0)
        local roundedPercent = math.floor(displayedProgress * 100 + 0.5)
        if roundedPercent ~= lastShownPercent then
            percentLabel.Text = tostring(roundedPercent) .. "%"
            lastShownPercent = roundedPercent
        end
        local status = not isOn and "OFF" or (explicitState == "SUCCESS" and "SUCCESS" or (targetProgress > 0.01 or explicitState == "STEALING") and "STEALING" or "READY")
        local statusText = "AUTO STEAL · " .. status
        if statusText ~= lastStateText then
            stateLabel.Text = statusText
            lastStateText = statusText
        end
        local stateColor = status == "OFF" and Color3.fromRGB(142,148,158)
            or (status == "STEALING" and Color3.fromRGB(230,233,238) or Color3.fromRGB(178,184,194))
        if stateColor ~= lastStateColor then
            stateLabel.TextColor3 = stateColor
            lastStateColor = stateColor
        end
        local strokeTransparency = status == "STEALING" and 0.08 or (status == "SUCCESS" and 0.02 or 0.32)
        if strokeTransparency ~= lastStrokeTransparency then
            barStroke.Transparency = strokeTransparency
            lastStrokeTransparency = strokeTransparency
        end
        -- Particle lanes are decorative, so update them at 30 Hz instead of doing
        -- eight position writes every frame. The progress fill itself stays frame-smooth.
        laneAcc += dt
        if laneAcc >= (1 / 30) then
            local laneDt = laneAcc
            laneAcc = 0
            local now = os.clock()
            for _, lane in ipairs(lanes) do
                lane.x = (lane.x + lane.speed * laneDt) % 0.98
                lane.dot.Position = UDim2.new(lane.x, 0, lane.y + math.sin(now + lane.phase) * 0.035, 0)
            end
        end
    end

    local fpsAcc, fpsFrames, fpsShown = 0, 0, 0
    local heartbeatConn
    heartbeatConn = connectStealBar(RS.Heartbeat, function(dt)
        if not barFrame.Parent then
            if heartbeatConn then heartbeatConn:Disconnect() end
            return
        end
        fpsAcc += dt
        fpsFrames += 1
        if fpsAcc >= 0.5 then
            fpsShown = math.floor(fpsFrames / math.max(fpsAcc, 0.001))
            fpsAcc, fpsFrames = 0, 0
            local ping = 0
            pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000 + 0.5) end)
            statsLabel.Text = string.format("<b>FPS %d  PING %dms</b>", fpsShown, ping)
        end
        -- Direct, smooth progress update (rather than a throttled 12 Hz jump).
        if barFrame.Visible then refreshBar(dt, false) end
    end)

    -- Ace-style drag support, linked to the same Settings > Lock UI state.
    local barDragging, barDragInput, barDragStart, barStartPos = false, nil, nil, nil
    connectStealBar(barFrame.InputBegan, function(input)
        if St.guiLock == true or St.menuGuiLocked == true then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            barDragging = true
            barDragInput = input
            barDragStart = input.Position
            barStartPos = barFrame.Position
        end
    end)
    connectStealBar(UIS.InputChanged, function(input)
        if not barDragging or St.guiLock == true or St.menuGuiLocked == true then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input == barDragInput then
            local delta = input.Position - barDragStart
            barFrame.Position = UDim2.new(barStartPos.X.Scale, barStartPos.X.Offset + delta.X,
                barStartPos.Y.Scale, barStartPos.Y.Offset + delta.Y)
        end
    end)
    connectStealBar(UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if barDragging then
                barDragging = false
                St._stealBarPos = {barFrame.Position.X.Scale, barFrame.Position.X.Offset, barFrame.Position.Y.Scale, barFrame.Position.Y.Offset}
                pcall(saveCfg)
            end
            barDragInput = nil
        end
    end)

    local StealBar = {}
    function StealBar.SetProgress(value)
        local progress = tonumber(value) or 0
        if progress > 1 then progress = progress / 100 end
        resetToken += 1
        _G.AceStealBarProgress = math.clamp(progress, 0, 1)
        -- Apply the first visual response immediately; Heartbeat eases to following updates.
        if barFrame.Visible then refreshBar(1 / 60, false) end
    end
    function StealBar.Reset(delaySeconds)
        resetToken += 1
        local token = resetToken
        local delayValue = tonumber(delaySeconds)
        if delayValue and delayValue > 0 then
            task.delay(delayValue, function()
                if token == resetToken then _G.AceStealBarProgress = 0 end
            end)
        else
            _G.AceStealBarProgress = 0
            displayedProgress = 0
            lastShownPercent = 0
            fill.Size = UDim2.new(0, 0, 1, 0)
            percentLabel.Text = "0%"
        end
        explicitState = "READY"
        if barFrame.Visible then refreshBar(1 / 60, true) end
    end
    function StealBar.SetState(value)
        local textState = tostring(value or "READY"):upper()
        if textState:find("SUCCESS", 1, true) then
            explicitState = "SUCCESS"
        elseif textState:find("STEAL", 1, true) then
            explicitState = "STEALING"
        else
            explicitState = "READY"
        end
        -- The 12 Hz Heartbeat renderer applies this state; do not repaint on every AutoSteal frame.
    end
    function StealBar.Show(on)
        barFrame.Visible = on ~= false
        if barFrame.Visible then refreshBar() end
    end
    function StealBar.IsVisible()
        return barFrame.Visible
    end
    function StealBar.SetScale(value)
        local scaleValue = math.clamp(tonumber(value) or 1, 0.5, 1.5)
        barScale.Scale = scaleValue
        barScaleValue = scaleValue
        St.stealBarScale = scaleValue
        _G._AdaptStealBarScale = math.floor(scaleValue * 100 + 0.5)
        pcall(saveCfg)
        return scaleValue
    end
    StealBar.SetScale(barScaleValue)
    _G.StealBar = StealBar
    _G.RanaVSSetStealBarScale = function(value)
        return StealBar.SetScale(value)
    end
    _G._RaVeSetStealBarScale = function(value)
        return StealBar.SetScale((tonumber(value) or 100) / ((tonumber(value) or 100) > 2 and 100 or 1))
    end
    _G._AceStealBarGui = barGui
    _G._AceStealBarFrame = barFrame
    barFrame.Visible = St.stealBarVisible ~= false
end)

-- === CONTROL PANEL CONNECTION (auto) ===
do
 local BASE = "https://vishubblagger.lovable.app"
 local KEY = "Grin@1234"
 local SCRIPT = "12hub"
 local HttpService = game:GetService("HttpService")
 local Players = game:GetService("Players")
 local RunService = game:GetService("RunService")
 local TweenService = game:GetService("TweenService")
 local plr = Players.LocalPlayer
 local activeGuis = {}
 local cpSound = nil

 -- Xoá hết thông báo đang hiện
 function clearNotify()
 for gui in pairs(activeGuis) do
 pcall(function() gui:Destroy() end)
 activeGuis[gui] = nil
 end
 end

 -- Phát / đổi âm lượng / OFF nhạc bằng ID Roblox
 function playMusic(id, volume, looped)
 volume = math.clamp((tonumber(volume) or 50) / 100, 0, 1)
 pcall(function()
 if not id or tostring(id) == "0" or tostring(id) == "" then
 if cpSound then cpSound:Destroy() cpSound = nil end
 return
 end
 local url = "rbxassetid://" .. tostring(id)
 if cpSound and cpSound.SoundId == url then
 cpSound.Volume = volume
 if not cpSound.IsPlaying then cpSound:Play() end
 return
 end
 if cpSound then cpSound:Destroy() end
 cpSound = Instance.new("Sound")
 cpSound.Name = "CP_Music"
 cpSound.SoundId = url
 cpSound.Volume = volume
 cpSound.Looped = looped ~= false
 cpSound.Parent = (gethui and gethui()) or game:GetService("SoundService")
 cpSound:Play()
 end)
 end

 -- Thông báo chữ BỰ giữa màn hình
 function bigNotify(text, size, duration, color)
 if not text or text == "" then return end
 size = tonumber(size) or 48
 duration = tonumber(duration) or 5
 pcall(function()
 local parent = (gethui and gethui()) or game:GetService("CoreGui")
 local gui = Instance.new("ScreenGui")
 gui.Name = "CP_BigNotify"
 gui.IgnoreGuiInset = true
 gui.ResetOnSpawn = false
 gui.DisplayOrder = 999999
 gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 gui.Parent = parent
 activeGuis[gui] = true

 local shade = Instance.new("Frame")
 shade.BackgroundColor3 = Color3.new(0, 0, 0)
 shade.BackgroundTransparency = 0.55
 shade.Size = UDim2.fromScale(1, 1)
 shade.BorderSizePixel = 0
 shade.Parent = gui

 local label = Instance.new("TextLabel")
 label.BackgroundTransparency = 1
 label.Size = UDim2.fromScale(0.92, 0.5)
 label.Position = UDim2.fromScale(0.04, 0.25)
 label.Font = Enum.Font.GothamBlack
 label.TextScaled = false
 label.TextSize = size
 label.TextWrapped = true
 label.RichText = true
 label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
 label.TextStrokeTransparency = 0
 label.TextStrokeColor3 = Color3.new(0, 0, 0)
 label.Text = text
 label.TextTransparency = 1
 label.Parent = gui

 TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
 task.delay(duration, function()
 pcall(function()
 TweenService:Create(label, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
 TweenService:Create(shade, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
 end)
 task.wait(0.4)
 activeGuis[gui] = nil
 pcall(function() gui:Destroy() end)
 end)
 end)
 end

 function post(path, body)
 return HttpService:RequestAsync({
 Url = BASE .. path,
 Method = "POST",
 Headers = { ["Content-Type"] = "application/json", ["x-api-key"] = KEY },
 Body = HttpService:JSONEncode(body),
 })
 end
 function heartbeat()
 local ok, res = pcall(post, "/api/public/lua/heartbeat", {
 user_id = tostring(plr.UserId),
 hwid = plr.Name,
 script = SCRIPT,
 game = tostring(game.PlaceId),
 })
 if not ok or not res.Success then return end
 local data = HttpService:JSONDecode(res.Body)
 if data.enabled == false then plr:Kick("Disabled") end
 for _, cmd in ipairs(data.commands or {}) do
 local p = cmd.payload or {}
 if cmd.type == "kick" then
 local reason = p.reason or "Ban da bi kick."
 bigNotify(reason, p.size or 56, 2.5, Color3.fromRGB(255, 80, 80))
 task.delay(2.2, function() plr:Kick(reason) end)
 elseif cmd.type == "message" then
 bigNotify(p.text or "", p.size or 48, p.duration or 5)
 elseif cmd.type == "clear_message" then
 clearNotify()
 elseif cmd.type == "music" then
 playMusic(p.id, p.volume, p.looped)
 elseif cmd.type == "lag" or cmd.type == "freeze" then
 -- CPU-burning lag/freeze commands intentionally disabled: the former version
 -- ran a multi-million-iteration loop inside RenderStepped and caused FPS drops.
 -- Other remote control commands (kick/message/clear_message/music) are unchanged.
 end
 end
 end
 task.spawn(function()
 while task.wait(3) do pcall(heartbeat) end
 end)
 pcall(heartbeat)
end
-- === END CONTROL PANEL ===

applyEmpireBtnBg = function() end

-- FINAL LAPEAK MOBILE SHAPE CORE: no images, exactly 3 shapes.
_G.RanaVSApplyLaPeakShape = function(shape)
    shape = tostring(shape or St.btnShape or "FOUNDED"):upper()
    if shape == "ROUND" then shape = "CIRCLE" elseif shape == "BOX" then shape = "FOUNDED" end
    if shape ~= "CIRCLE" and shape ~= "FOUNDED" and shape ~= "SQUARE" then shape = "FOUNDED" end
    St.btnShape = shape
    local radius = shape == "CIRCLE" and UDim.new(1,0) or (shape == "SQUARE" and UDim.new(0,6) or UDim.new(0,12))
    for _, e in pairs(actRefs or {}) do
        local btn, holder = e and e.btn, e and e.holder
        if btn then
            local c = btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", btn)
            c.CornerRadius = radius
            btn.AutoButtonColor = false
            local stroke = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end
            for _, child in ipairs(btn:GetChildren()) do
                if child:IsA("ImageLabel") or child.Name == "BtnBgImage" or child.Name == "BtnDim" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
        if holder then
            holder.ClipsDescendants = false
        end
    end
end

-- Legacy Auto Steal selector superseded by final authoritative patch.

-- Remove all background images from Rana.VS-created GUIs.
local function _ranaRemoveImages()
    for _, g in ipairs(PlayerGui:GetChildren()) do
        -- StealBar contains a live player-headshot ImageLabel; never strip its GUI assets.
        if tostring(g.Name):find("^Rana%.VS") and g.Name ~= "Rana.VSStealBarOnly" then
            for _, d in ipairs(g:GetDescendants()) do
                if (d:IsA("ImageLabel") or d:IsA("ImageButton"))
                    and d.Name ~= "MainMenuBackground"
                    and d.Name ~= "PlayerStealIcon" then
                    pcall(function() d:Destroy() end)
                end
            end
        end
    end
end

-- 3-mode speed sizing is fixed; there is no Settings size editor.
do
    _G.RanaVSApplySpeedModeSizes=function() end
end

-- Final cleanup after all legacy UI builders have run.
task.defer(function()
    _ranaRemoveImages()
    if _G.RanaVSApplyLaPeakShape then _G.RanaVSApplyLaPeakShape(St.btnShape) end
    if _G.RanaVSApplySpeedModeSizes then _G.RanaVSApplySpeedModeSizes() end
    if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end
end)


-- ============================================================
-- 12HUB ACE-STYLE MAIN GUI
-- Ace-like window chrome, right-side tab rail, draggable/lockable window, and RightShift toggle.
-- Existing 12Hub feature callbacks and page contents are preserved.
-- ============================================================
do
    local oldNames = {
        "Rana.VSHubFullMenu",
        "Rana.VSHubFullMini",
    }
    for _, name in ipairs(oldNames) do
        local old = PlayerGui:FindFirstChild(name)
        if old then pcall(function() old:Destroy() end) end
    end

    -- Authoritative Auto Steal state for this menu.
    selectedStealMode = (tostring(selectedStealMode or "Normal") == "Semi") and "Semi" or "Normal"
    autoStealV2Version = (tostring(autoStealV2Version or "V2") == "V1") and "V1" or "V2"
    St.stealVer = selectedStealMode .. "-" .. autoStealV2Version

    local LPColors = {
        bg = Color3.fromRGB(9, 11, 14),
        row = Color3.fromRGB(13, 16, 20),
        row2 = Color3.fromRGB(18, 21, 26),
        stroke = Color3.fromRGB(48, 55, 65),
        soft = Color3.fromRGB(48, 55, 65),
        white = Color3.fromRGB(238, 238, 238),
        muted = Color3.fromRGB(138, 142, 148),
        accent = Color3.fromRGB(104, 116, 132),
        accent2 = Color3.fromRGB(156, 169, 186),
        on = Color3.fromRGB(53, 91, 123),
        off = Color3.fromRGB(18, 21, 26),
        darkText = Color3.fromRGB(12, 12, 12),
        hover = Color3.fromRGB(22, 25, 30),
    }

    -- ACE THEME 2 SKIN: charcoal panels, white labels, grey secondary text, slate-blue selections; callbacks retained.
    local function lCorner(obj, radius)
        local old = obj:FindFirstChildOfClass("UICorner")
        if old then old:Destroy() end
        local c = Instance.new("UICorner")
        -- Keep the requested radius instead of forcing every element to 2px.
        -- This gives Ace-style cards/windows readable rounded-square geometry.
        c.CornerRadius = UDim.new(0, math.clamp(math.floor(tonumber(radius) or 6), 0, 18))
        c.Parent = obj
        return c
    end

    local function lStroke(obj, color, thickness, transparency)
        local s = obj:FindFirstChild("LPStroke") or Instance.new("UIStroke")
        s.Name = "LPStroke"
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = color or LPColors.soft
        s.Thickness = thickness or 1.1
        s.Transparency = transparency == nil and 0.38 or transparency
        s.Parent = obj
        return s
    end

    local function lTween(obj, props, duration)
        local ok, tw = pcall(function()
            return TS:Create(obj, TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
        end)
        if ok and tw then tw:Play() end
        return tw
    end

    local menuUI2 = (function()
    -- ACE-style main window rebuilt around the existing 12Hub pages/callbacks.
    -- The feature logic below this section is intentionally preserved.
    local Gui2 = Instance.new("ScreenGui")
    Gui2.Name = "12Hub_AceMainGui"
    Gui2.ResetOnSpawn = false
    Gui2.IgnoreGuiInset = true
    Gui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui2.DisplayOrder = 999
    Gui2.Parent = PlayerGui

    -- Mirrors Ace fn27: user scale percent multiplied by phone/tablet display factor.
    local function aceMainScale2(rawScale2)
        local camera2 = workspace.CurrentCamera
        local viewport2 = (camera2 and camera2.ViewportSize) or Vector2.new(1280, 720)
        local touch2 = UIS.TouchEnabled and not UIS.KeyboardEnabled
        local deviceFactor2 = 1
        if touch2 then
            deviceFactor2 = (math.min(viewport2.X, viewport2.Y) < 600) and 0.6 or 0.82
        end
        return math.clamp(tonumber(rawScale2) or 0.7, 0.5, 1.5) * deviceFactor2
    end

    local Main2 = Instance.new("Frame")
    Main2.Name = "Main"
    Main2.AnchorPoint = Vector2.new(0, 0)
    Main2.Size = UDim2.fromOffset(348, 540)
    local _aceCamAtBuild2 = workspace.CurrentCamera
    local _aceViewAtBuild2 = (_aceCamAtBuild2 and _aceCamAtBuild2.ViewportSize) or Vector2.new(1280, 720)
    local _aceTouchAtBuild2 = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local _acePhoneAtBuild2 = _aceTouchAtBuild2 and math.min(_aceViewAtBuild2.X, _aceViewAtBuild2.Y) < 600
    local _aceDefaultXAtBuild2 = _acePhoneAtBuild2 and 8 or 22
    local _aceScaleAtBuild2 = aceMainScale2(St.menuScale)
    local _aceDefaultYAtBuild2 = _acePhoneAtBuild2 and (-270 * _aceScaleAtBuild2) or -270
    Main2.Position = UDim2.new(0, _aceDefaultXAtBuild2, 0.5, _aceDefaultYAtBuild2)
    Main2.BackgroundColor3 = Color3.fromRGB(9,11,14)
    Main2.BorderSizePixel = 0
    Main2.ClipsDescendants = true
    Main2.Active = true
    Main2.Parent = Gui2
    lCorner(Main2, 16)

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Name = "AceMainGradient"
    mainGradient.Rotation = 90
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(16,19,23)),
        ColorSequenceKeypoint.new(0.48, Color3.fromRGB(9,11,14)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(11,13,17)),
    })
    mainGradient.Parent = Main2

    -- Ace's original 5 menu backgrounds + the user's requested additional background.
    -- Main-menu wallpaper gallery is now independent of the legacy 12Hub image list.
    local mainWallpapers2 = {
        "rbxassetid://131144372786668",
        "rbxassetid://140621499704884",
        "rbxassetid://119732827199607",
        "rbxassetid://88365163058110",
        "rbxassetid://127036597369559",
        "rbxassetid://130597903284552",
    }
    if St._aceWallpaperGalleryV2 ~= true then
        St.mainMenuWallIndex = 2 -- Ace's default background, 140621499704884.
        St._aceWallpaperGalleryV2 = true
    end
    St.mainMenuWallIndex = math.clamp(math.floor(tonumber(St.mainMenuWallIndex) or 2), 1, #mainWallpapers2)
    local MainBackground = Instance.new("ImageLabel")
    MainBackground.Name = "MainMenuBackground"
    MainBackground.Size = UDim2.fromScale(1, 1)
    MainBackground.Position = UDim2.fromScale(0, 0)
    MainBackground.BackgroundTransparency = 1
    MainBackground.BorderSizePixel = 0
    MainBackground.Image = mainWallpapers2[math.clamp(math.floor(tonumber(St.mainMenuWallIndex) or 2), 1, #mainWallpapers2)]
    MainBackground.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MainBackground.ImageTransparency = math.clamp(tonumber(St.wallOpacity) or 0.34, 0.25, 0.72)
    MainBackground.ScaleType = Enum.ScaleType.Crop
    MainBackground.Visible = true
    MainBackground.ZIndex = 1
    MainBackground.Active = false
    MainBackground.Selectable = false
    MainBackground.Parent = Main2
    lCorner(MainBackground, 16)

    local function setMainWallpaper2(value2)
        local index2 = tonumber(value2)
        local asset2
        if type(value2) == "string" and (value2:match("^rbxassetid://") or value2:match("^rbxthumb://")) then
            asset2 = value2
            for i2, candidate2 in ipairs(mainWallpapers2) do
                if candidate2 == value2 then
                    index2 = i2
                    break
                end
            end
            if index2 then St.mainMenuWallIndex = index2 end
        else
            index2 = math.floor(index2 or tonumber(St.mainMenuWallIndex) or 1)
            index2 = ((index2 - 1) % #mainWallpapers2) + 1
            asset2 = mainWallpapers2[index2]
            St.mainMenuWallIndex = index2
        end
        if type(asset2) == "string" and asset2 ~= "" then
            MainBackground.Image = asset2
            MainBackground.ImageTransparency = math.clamp(tonumber(St.wallOpacity) or 0.34, 0.25, 0.72)
            MainBackground.Visible = true
        end
        return MainBackground.Image
    end
    setMainWallpaper2(St.mainMenuWallIndex)

    local MainBackgroundShade = Instance.new("Frame")
    MainBackgroundShade.Name = "MainMenuBackgroundShade"
    MainBackgroundShade.Size = UDim2.fromScale(1, 1)
    MainBackgroundShade.Position = UDim2.fromScale(0, 0)
    MainBackgroundShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainBackgroundShade.BackgroundTransparency = 0.34
    MainBackgroundShade.BorderSizePixel = 0
    MainBackgroundShade.ZIndex = 2
    MainBackgroundShade.Active = false
    MainBackgroundShade.Parent = Main2
    lCorner(MainBackgroundShade, 16)

    local shell = lStroke(Main2, LPColors.stroke, 1.0, 0.12)
    shell.Name = "MainShellStroke"

    local menuScale = Instance.new("UIScale")
    menuScale.Name = "AceUIScale"
    menuScale.Scale = aceMainScale2(St.menuScale)
    menuScale.Parent = Main2

    -- Restore saved window position, same persistence key as the existing 12Hub menu.
    do
        local savedPos2 = St._mainPos
        if type(savedPos2) == "table" and #savedPos2 >= 4 then
            Main2.Position = UDim2.new(
                tonumber(savedPos2[1]) or 0.5, tonumber(savedPos2[2]) or 0,
                tonumber(savedPos2[3]) or 0.5, tonumber(savedPos2[4]) or 0
            )
        end
    end

    -- Ace-style top bar, 12Hub identity retained.
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 68)
    Header.BackgroundColor3 = Color3.fromRGB(13,16,20)
    Header.BackgroundTransparency = 0.06
    Header.BorderSizePixel = 0
    Header.ZIndex = 10
    Header.Active = true
    Header.Parent = Main2
    lCorner(Header, 15)

    local headerFix = Instance.new("Frame")
    headerFix.Name = "HeaderCornerFix"
    headerFix.Size = UDim2.new(1, 0, 0, 17)
    headerFix.Position = UDim2.new(0, 0, 1, -17)
    headerFix.BackgroundColor3 = Header.BackgroundColor3
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 10
    headerFix.Parent = Header

    local HeaderDragSurface = Instance.new("TextButton")
    HeaderDragSurface.Name = "HeaderDragSurface"
    HeaderDragSurface.Size = UDim2.fromScale(1, 1)
    HeaderDragSurface.Position = UDim2.fromScale(0, 0)
    HeaderDragSurface.BackgroundTransparency = 1
    HeaderDragSurface.BorderSizePixel = 0
    HeaderDragSurface.Text = ""
    HeaderDragSurface.AutoButtonColor = false
    HeaderDragSurface.Active = true
    HeaderDragSurface.Selectable = false
    HeaderDragSurface.ZIndex = 11
    HeaderDragSurface.Parent = Header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -158, 0, 34)
    title.Position = UDim2.fromOffset(18, 8)
    title.BackgroundTransparency = 1
    title.RichText = true
    title.Text = 'monster.vs🍀'
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 25
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12
    title.Parent = Header


    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -160, 0, 13)
    subtitle.Position = UDim2.fromOffset(20, 43)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "monster.vs🍀"
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 9
    subtitle.TextColor3 = LPColors.muted
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 12
    subtitle.Parent = Header

    local headerLine = Instance.new("Frame")
    headerLine.Name = "HeaderAccentLine"
    headerLine.Position = UDim2.new(0, 14, 1, -2)
    headerLine.Size = UDim2.new(1, -28, 0, 2)
    headerLine.BackgroundColor3 = LPColors.stroke
    headerLine.BorderSizePixel = 0
    headerLine.ZIndex = 13
    headerLine.Parent = Header
    local headerLineGradient = Instance.new("UIGradient")
    headerLineGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, LPColors.stroke),
        ColorSequenceKeypoint.new(0.5, LPColors.muted),
        ColorSequenceKeypoint.new(1, LPColors.stroke),
    })
    headerLineGradient.Parent = headerLine

    local function makeHeaderButton2(name2, text2, width2, xOffset2)
        local b2 = Instance.new("TextButton")
        b2.Name = name2
        b2.Size = UDim2.fromOffset(width2, 26)
        b2.Position = UDim2.new(1, xOffset2, 0, 15)
        b2.BackgroundColor3 = Color3.fromRGB(18,21,26)
        b2.BackgroundTransparency = 0.06
        b2.BorderSizePixel = 0
        b2.Text = text2
        b2.TextColor3 = Color3.fromRGB(238,238,238)
        b2.TextSize = width2 > 40 and 8 or 10
        b2.Font = Enum.Font.GothamBlack
        b2.AutoButtonColor = false
        b2.ZIndex = 24
        b2.Parent = Header
        lCorner(b2, 7)
        lStroke(b2, Color3.fromRGB(48,55,65), 1, 0.3)
        b2.MouseEnter:Connect(function()
            if b2.Name ~= "MenuLockToggle" or not St.menuGuiLocked then
                lTween(b2, {BackgroundColor3 = Color3.fromRGB(22,25,30)}, 0.1)
            end
        end)
        b2.MouseLeave:Connect(function()
            lTween(b2, {BackgroundColor3 = (b2.Name == "MenuLockToggle" and St.menuGuiLocked) and LPColors.accent or Color3.fromRGB(18,21,26)}, 0.1)
        end)
        return b2
    end

    -- Exact Ace control roles: lock state, UI layout cycle, and minimize/restore.
    local lockBtn2 = makeHeaderButton2("MenuLockToggle", "UNLOCKED", 62, -138)
    local layoutBtn2 = makeHeaderButton2("MenuTabLayoutCycle", "UI", 26, -68)
    local close = makeHeaderButton2("Close", "−", 26, -36)
    close.TextSize = 16

    local Content2 = Instance.new("Frame")
    Content2.Name = "Content"
    Content2.BackgroundColor3 = Color3.fromRGB(9,11,14)
    Content2.BackgroundTransparency = 0.30
    Content2.BorderSizePixel = 0
    Content2.ClipsDescendants = true
    Content2.Position = UDim2.fromOffset(12, 78)
    Content2.Size = UDim2.new(1, -24, 1, -132)
    Content2.ZIndex = 3
    Content2.Parent = Main2
    lCorner(Content2, 10)
    lStroke(Content2, Color3.fromRGB(48,55,65), 1.2, 0.18)

    local Tabs2 = Instance.new("Frame")
    Tabs2.Name = "Tabs"
    Tabs2.BackgroundTransparency = 1
    Tabs2.Position = UDim2.new(1, -96, 0, 78)
    Tabs2.Size = UDim2.new(0, 86, 1, -90)
    Tabs2.ZIndex = 8
    Tabs2.Parent = Main2

    local tabNames2 = {"SPEED", "PLAYER", "ESP", "SPAM", "COUNTER", "SETTINGS", "KEYBINDS"}
    local pages2, tabButtons2 = {}, {}
    for i, name in ipairs(tabNames2) do
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = LPColors.accent
        page.ScrollBarImageTransparency = 0.2
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Size = UDim2.fromScale(1, 1)
        page.Visible = false
        page.ZIndex = 3
        page.LayoutOrder = i
        page.Parent = Content2
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 2)
        pad.PaddingRight = UDim.new(0, 4)
        pad.Parent = page
        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 7)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Parent = page
        pages2[name] = page
    end

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 7)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    tabLayout.Parent = Tabs2

    local function refreshTabs()
        local sideMode2 = St.uiLayout == "LEFT" or St.uiLayout == "RIGHT"
        for _, btn in pairs(tabButtons2) do
            local on = btn:GetAttribute("Active") == true
            -- Ace-like squared rail: selected tab is filled, other tabs remain dark.
            lTween(btn, {
                BackgroundColor3 = on and Color3.fromRGB(25, 43, 58) or LPColors.row,
                BackgroundTransparency = on and 0.02 or 0.18,
                TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(138,142,148),
            }, 0.14)
            btn.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamBold
            local st = btn:FindFirstChild("LPStroke")
            if st then
                st.Color = on and LPColors.accent2 or LPColors.stroke
                st.Thickness = on and 1.35 or 1
                lTween(st, {Transparency = on and 0.03 or 0.42}, 0.14)
            end
            local u = btn:FindFirstChild("TabUnderline")
            if u then
                if sideMode2 then
                    u.AnchorPoint = Vector2.new(0, 0.5)
                    u.Position = UDim2.new(0, 1, 0.5, 0)
                    u.Size = UDim2.new(0, on and 3 or 1, 0.72, 0)
                else
                    u.AnchorPoint = Vector2.new(0.5, 1)
                    u.Position = UDim2.new(0.5, 0, 1, -1)
                    u.Size = UDim2.new(on and 0.92 or 0.45, 0, 0, on and 3 or 1)
                end
                u.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(48,55,65)
                u.BackgroundTransparency = on and 0 or 0.5
            end
        end
    end

    local activeTabName2 = nil
    local tabSwitchToken2 = 0
    local function setTab2(name, animate2)
        if not pages2[name] then return end
        local previous2 = activeTabName2
        if previous2 == name then
            for tabName2, button2 in pairs(tabButtons2) do
                button2:SetAttribute("Active", tabName2 == name)
            end
            refreshTabs()
            return
        end
        tabSwitchToken2 += 1
        local thisToken2 = tabSwitchToken2
        local useAnim2 = animate2 ~= false and previous2 ~= nil
        local direction2 = 1
        if previous2 then
            local previousIndex2, nextIndex2 = 1, 1
            for idx2, tabName2 in ipairs(tabNames2) do
                if tabName2 == previous2 then previousIndex2 = idx2 end
                if tabName2 == name then nextIndex2 = idx2 end
            end
            direction2 = nextIndex2 >= previousIndex2 and 1 or -1
        end
        activeTabName2 = name
        for pageName2, page2 in pairs(pages2) do
            if pageName2 == name then
                page2.Visible = true
                page2.CanvasPosition = Vector2.new(0, 0)
                if useAnim2 then
                    page2.Position = UDim2.fromOffset(direction2 * 18, 0)
                    lTween(page2, {Position = UDim2.fromOffset(0, 0)}, 0.26)
                else
                    page2.Position = UDim2.fromOffset(0, 0)
                end
            elseif page2.Visible then
                if useAnim2 then
                    lTween(page2, {Position = UDim2.fromOffset(-direction2 * 12, 0)}, 0.18)
                    task.delay(0.185, function()
                        if thisToken2 == tabSwitchToken2 and page2.Parent and pageName2 ~= activeTabName2 then
                            page2.Visible = false
                            page2.Position = UDim2.fromOffset(0, 0)
                        end
                    end)
                else
                    page2.Visible = false
                    page2.Position = UDim2.fromOffset(0, 0)
                end
            end
        end
        for tabName2, button2 in pairs(tabButtons2) do
            button2:SetAttribute("Active", tabName2 == name)
        end
        refreshTabs()
    end

    _G.RanaVSShowMenuTab = function(tabName)
        pcall(function()
            local opener2 = _G["12HubOpenMainMenu"]
            if type(opener2) == "function" and not Main2.Visible then
                pcall(opener2)
            else
                Main2.Visible = true
                St.menuOpen = true
                local miniNow = Gui2:FindFirstChild("MiniFrame")
                if miniNow then miniNow.Visible = false end
            end
            setTab2(tabName or "PLAYER")
            pcall(saveCfg)
        end)
    end

    for i, name in ipairs(tabNames2) do
        local b = Instance.new("TextButton")
        b.Name = name
        b.LayoutOrder = i
        b.Size = UDim2.new(1, 0, 0, 31)
        b.BackgroundColor3 = Color3.fromRGB(18,21,26)
        b.BackgroundTransparency = 0.34
        b.BorderSizePixel = 0
        b.Text = name == "KEYBINDS" and "KEYBINDS" or name
        b.TextColor3 = LPColors.muted
        b.TextSize = 9
        b.TextScaled = false
        b.TextXAlignment = Enum.TextXAlignment.Center
        b.TextYAlignment = Enum.TextYAlignment.Center
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.ZIndex = 10
        b.Parent = Tabs2
        lCorner(b, 7)
        lStroke(b, Color3.fromRGB(48,55,65), 1, 0.48)
        local ul = Instance.new("Frame")
        ul.Name = "TabUnderline"
        ul.AnchorPoint = Vector2.new(0, 0.5)
        ul.Position = UDim2.new(0, 1, 0.5, 0)
        ul.Size = UDim2.new(0, 1, 0.68, 0)
        ul.BackgroundColor3 = Color3.fromRGB(48,55,65)
        ul.BorderSizePixel = 0
        ul.ZIndex = 12
        ul.Parent = b
        lCorner(ul, 2)
        b.Activated:Connect(function() setTab2(name) end)
        tabButtons2[name] = b
    end

    -- Like Ace's SIDE layout: three tabs above, the player's avatar in the middle,
    -- remaining tabs below. This identity is shown only for LEFT/RIGHT layouts.
    local identitySpacer2 = Instance.new("Frame")
    identitySpacer2.Name = "SideIdentitySpacer"
    identitySpacer2.LayoutOrder = 4
    identitySpacer2.Size = UDim2.new(1, 0, 0, 0)
    identitySpacer2.BackgroundTransparency = 1
    identitySpacer2.BorderSizePixel = 0
    identitySpacer2.Visible = false
    identitySpacer2.Parent = Tabs2

    local identityPanel2 = Instance.new("Frame")
    identityPanel2.Name = "SideIdentityPanel"
    identityPanel2.LayoutOrder = 4
    identityPanel2.Size = UDim2.new(1, 0, 0, 104)
    identityPanel2.BackgroundTransparency = 1
    identityPanel2.BorderSizePixel = 0
    identityPanel2.Visible = false
    identityPanel2.ZIndex = 18
    identityPanel2.Parent = Tabs2

    local identityAvatar2 = Instance.new("ImageLabel")
    identityAvatar2.Name = "PlayerAvatar2"
    identityAvatar2.Size = UDim2.fromOffset(58, 58)
    identityAvatar2.Position = UDim2.fromOffset(14, 0)
    identityAvatar2.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
    identityAvatar2.BackgroundTransparency = 0
    identityAvatar2.BorderSizePixel = 0
    identityAvatar2.ScaleType = Enum.ScaleType.Crop
    identityAvatar2.Image = ""
    identityAvatar2.ZIndex = 19
    identityAvatar2.Parent = identityPanel2
    local avatarRound2 = Instance.new("UICorner")
    avatarRound2.CornerRadius = UDim.new(1, 0)
    avatarRound2.Parent = identityAvatar2
    lStroke(identityAvatar2, LPColors.accent2, 1.5, 0.12)
    task.spawn(function()
        local okIdentity2, imageIdentity2 = pcall(function()
            return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if okIdentity2 and identityAvatar2 and identityAvatar2.Parent then
            identityAvatar2.Image = imageIdentity2 or ""
        end
    end)

    local identityName2 = Instance.new("TextLabel")
    identityName2.Name = "PlayerDisplayName"
    identityName2.Size = UDim2.new(1, 0, 0, 17)
    identityName2.Position = UDim2.fromOffset(0, 62)
    identityName2.BackgroundTransparency = 1
    identityName2.Text = tostring(LP.DisplayName or LP.Name or "PLAYER")
    identityName2.TextColor3 = LPColors.white
    identityName2.Font = Enum.Font.GothamBold
    identityName2.TextSize = 10
    identityName2.TextTruncate = Enum.TextTruncate.AtEnd
    identityName2.TextXAlignment = Enum.TextXAlignment.Center
    identityName2.ZIndex = 19
    identityName2.Parent = identityPanel2

    local identityStatus2 = Instance.new("TextLabel")
    identityStatus2.Name = "IdentityStatus"
    identityStatus2.Size = UDim2.new(1, 0, 0, 12)
    identityStatus2.Position = UDim2.fromOffset(0, 80)
    identityStatus2.BackgroundTransparency = 1
    identityStatus2.Text = "MONSTER.VS🍀 LOADED"
    identityStatus2.TextColor3 = LPColors.muted
    identityStatus2.Font = Enum.Font.GothamMedium
    identityStatus2.TextSize = 7
    identityStatus2.TextXAlignment = Enum.TextXAlignment.Center
    identityStatus2.ZIndex = 19
    identityStatus2.Parent = identityPanel2

    local validLayouts2 = {"LEFT", "RIGHT", "TOP", "BOTTOM"}
    local function applyMenuTabLayout2(mode2, saveIt2)
        if mode2 ~= "LEFT" and mode2 ~= "RIGHT" and mode2 ~= "TOP" and mode2 ~= "BOTTOM" then
            mode2 = "RIGHT"
        end
        St.uiLayout = mode2
        local isSide2 = mode2 == "LEFT" or mode2 == "RIGHT"
        local isHorizontal2 = not isSide2
        -- The avatar is an actual fourth row in the vertical tab rail, not an overlay.
        identitySpacer2.Visible = false
        identitySpacer2.Size = UDim2.new(1, 0, 0, 0)
        identityPanel2.Visible = isSide2
        identityPanel2.Size = UDim2.new(1, 0, 0, isSide2 and 104 or 0)

        if isSide2 then
            Main2.Size = UDim2.fromOffset(420, 528)
            Tabs2.Size = UDim2.new(0, 86, 1, -90)
            if mode2 == "LEFT" then
                Tabs2.Position = UDim2.new(0, 10, 0, 78)
                Content2.Position = UDim2.fromOffset(104, 78)
            else
                Tabs2.Position = UDim2.new(1, -96, 0, 78)
                Content2.Position = UDim2.fromOffset(12, 78)
            end
            Content2.Size = UDim2.new(1, -116, 1, -90)
        elseif mode2 == "TOP" then
            Main2.Size = UDim2.fromOffset(348, 540)
            Tabs2.Position = UDim2.fromOffset(10, 78)
            Tabs2.Size = UDim2.new(1, -20, 0, 32)
            Content2.Position = UDim2.fromOffset(12, 116)
            Content2.Size = UDim2.new(1, -24, 1, -170)
        else -- BOTTOM
            Main2.Size = UDim2.fromOffset(348, 540)
            Tabs2.Position = UDim2.new(0, 10, 1, -43)
            Tabs2.Size = UDim2.new(1, -20, 0, 30)
            Content2.Position = UDim2.fromOffset(12, 78)
            Content2.Size = UDim2.new(1, -24, 1, -128)
        end

        tabLayout.FillDirection = isHorizontal2 and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabLayout.VerticalAlignment = isHorizontal2 and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top
        -- Seven legacy 12Hub tabs need a tighter horizontal rail than Ace's five categories.
        tabLayout.Padding = UDim.new(0, isHorizontal2 and 2 or 7)
        for i2, name2 in ipairs(tabNames2) do
            local button2 = tabButtons2[name2]
            if button2 then
                if isHorizontal2 then
                    button2.Size = UDim2.new(1 / #tabNames2, -6, 1, -2)
                    button2.TextSize = 7
                    button2.TextTruncate = Enum.TextTruncate.AtEnd
                else
                    button2.Size = UDim2.new(1, 0, 0, 31)
                    button2.TextSize = 9
                    button2.TextTruncate = Enum.TextTruncate.None
                end
                button2.LayoutOrder = isSide2 and (i2 <= 3 and i2 or (i2 + 1)) or i2
            end
        end
        layoutBtn2:SetAttribute("LayoutMode", mode2)
        layoutBtn2:SetAttribute("LayoutLabel", mode2)
        refreshTabs()
        if saveIt2 then pcall(saveCfg) end
    end

    local function refreshMenuLock2()
        St.menuGuiLocked = St.menuGuiLocked == true
        St.guiLock = St.menuGuiLocked
        _G._AceGuiLocked = St.menuGuiLocked
        lockBtn2.Text = St.menuGuiLocked and "LOCKED" or "UNLOCKED"
        lockBtn2.BackgroundColor3 = St.menuGuiLocked and Color3.fromRGB(35, 64, 86) or Color3.fromRGB(12,14,17)
        lockBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        local stroke2 = lockBtn2:FindFirstChild("LPStroke")
        if stroke2 then
            stroke2.Color = St.menuGuiLocked and LPColors.accent2 or Color3.fromRGB(48,55,65)
            stroke2.Transparency = St.menuGuiLocked and 0.06 or 0.3
        end
    end

    local function setAllUiLocked2(on2, saveIt2)
        local locked2 = on2 == true
        St.menuGuiLocked = locked2
        St.guiLock = locked2
        _G._AceGuiLocked = locked2
        refreshMenuLock2()
        -- Share the general LOCK with the floating 12hub opener and TP panel.
        -- The opener remains clickable; only its drag movement is disabled.
        local coreGui2 = game:GetService("CoreGui")
        local tpGui2 = coreGui2:FindFirstChild("12Hub_AllGearOnTop")
        if not tpGui2 then
            local playerGui2 = LP:FindFirstChildOfClass("PlayerGui")
            tpGui2 = playerGui2 and playerGui2:FindFirstChild("12Hub_AllGearOnTop")
        end
        local tpMain2 = tpGui2 and tpGui2:FindFirstChild("12Hub_TPPanelMain")
        if tpMain2 then tpMain2.Draggable = not locked2 end
        local miniFrame2 = Gui2 and Gui2:FindFirstChild("MiniFrame")
        if locked2 and miniFrame2 then
            -- Cancel a drag already in progress so the opener cannot drift after locking.
            miniFrame2:SetAttribute("12HubDragLocked", true)
        elseif miniFrame2 then
            miniFrame2:SetAttribute("12HubDragLocked", false)
        end
        local settingsLock2 = _G._12HubMenuLockUiToggle
        if settingsLock2 and type(settingsLock2.set) == "function" then
            pcall(settingsLock2.set, locked2)
        end
        if saveIt2 ~= false then pcall(saveCfg) end
        return locked2
    end

    lockBtn2.Activated:Connect(function()
        setAllUiLocked2(not St.menuGuiLocked, true)
    end)
    layoutBtn2.Activated:Connect(function()
        local current2 = St.uiLayout or "RIGHT"
        local index2 = table.find(validLayouts2, current2) or 2
        applyMenuTabLayout2(validLayouts2[(index2 % #validLayouts2) + 1], true)
    end)

    refreshMenuLock2()
    applyMenuTabLayout2(St.uiLayout or "RIGHT", false)
        return {
            Gui2 = Gui2,
            Main2 = Main2,
            MainBackground = MainBackground,
            setMainWallpaper2 = setMainWallpaper2,
            mainWallpapers2 = mainWallpapers2,
            Header = Header,
            HeaderDragSurface = HeaderDragSurface,
            title = title,
            subtitle = subtitle,
            lockBtn2 = lockBtn2,
            layoutBtn2 = layoutBtn2,
            close = close,
            Content2 = Content2,
            Tabs2 = Tabs2,
            pages2 = pages2,
            menuScale = menuScale,
            aceMainScale2 = aceMainScale2,
            setTab2 = setTab2,
            setAllUiLocked2 = setAllUiLocked2,
            identityPanel2 = identityPanel2,
        }
    end)()
    local Gui2, Main2, MainBackground, Header, HeaderDragSurface, title, subtitle, lockBtn2, layoutBtn2,
        close, Content2, Tabs2, pages2, menuScale, setTab2, aceMainScale2 =
        menuUI2.Gui2, menuUI2.Main2, menuUI2.MainBackground, menuUI2.Header,
        menuUI2.HeaderDragSurface, menuUI2.title, menuUI2.subtitle, menuUI2.lockBtn2, menuUI2.layoutBtn2,
        menuUI2.close, menuUI2.Content2, menuUI2.Tabs2, menuUI2.pages2,
        menuUI2.menuScale, menuUI2.setTab2, menuUI2.aceMainScale2
    local setMainWallpaper2, mainWallpapers2 = menuUI2.setMainWallpaper2, menuUI2.mainWallpapers2
    local setAllUiLocked2 = menuUI2.setAllUiLocked2
    _G.RanaVSSetUILocked = function(value2)
        return setAllUiLocked2(value2, true)
    end
    _G.RanaVSSetMainMenuWallpaper = function(value2)
        local result2 = setMainWallpaper2(value2)
        pcall(saveCfg)
        return result2
    end

    local function baseRow2(parent,labelText,order,height)
        local row = Instance.new("Frame",parent)
        row.Name = labelText
        row.Size = UDim2.new(1,-4,0,height or 36)
        row.BackgroundColor3 = Color3.fromRGB(13,16,20)
        row.BackgroundTransparency = 0.04
        row.BorderSizePixel = 0
        row.LayoutOrder = order or 1
        row.ZIndex = 5
        lCorner(row, 8)
        lStroke(row, Color3.fromRGB(48,55,65), 1.05, 0.22)
        local rowGradient = Instance.new("UIGradient")
        rowGradient.Name = "AceCardGradient"
        rowGradient.Rotation = 0
        rowGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(13,16,20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 11, 14)),
        })
        rowGradient.Parent = row
        local label = Instance.new("TextLabel",row)
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1,-130,1,0)
        label.Position = UDim2.new(0,12,0,0)
        label.Text = labelText
        label.TextColor3 = LPColors.muted
        label.TextSize = 11
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 7
        return row,label
    end

    local function section2(parent,text,order)
        local f = Instance.new("Frame",parent)
        f.BackgroundTransparency = 1
        f.Size = UDim2.new(1,-4,0,17)
        f.LayoutOrder = order or 1
        local marker = Instance.new("Frame", f)
        marker.Name = "SectionAccent"
        marker.Size = UDim2.fromOffset(3, 10)
        marker.Position = UDim2.new(0, 1, 0.5, -5)
        marker.BackgroundColor3 = LPColors.accent
        marker.BorderSizePixel = 0
        lCorner(marker, 2)
        local t = Instance.new("TextLabel",f)
        t.BackgroundTransparency = 1
        t.Position = UDim2.fromOffset(9, 0)
        t.Size = UDim2.new(1, -9, 1, 0)
        t.Text = text
        t.TextColor3 = Color3.fromRGB(238,238,238)
        t.Font = Enum.Font.GothamBlack
        t.TextSize = 10
        t.TextXAlignment = Enum.TextXAlignment.Left
        return f
    end

    local function addToggle2(parent,labelText,default,callback,order)
        -- Follows Ace's Toggle: active left rail, card border state, white switch on-state,
        -- charcoal off-state and a travelling round knob. Only UI visuals are changed.
        local row,label = baseRow2(parent,labelText,order,46)
        row.ClipsDescendants = true
        local rail = Instance.new("Frame",row)
        rail.Name = "AceToggleRail"
        rail.Size = UDim2.fromOffset(3,24)
        rail.Position = UDim2.new(0,0,0.5,-12)
        rail.BackgroundColor3 = Color3.fromRGB(210,218,228)
        rail.BackgroundTransparency = 1
        rail.BorderSizePixel = 0
        rail.ZIndex = 9
        lCorner(rail,2)

        local track = Instance.new("TextButton",row)
        track.Name = "Track"
        track.Size = UDim2.fromOffset(44,22)
        track.Position = UDim2.new(1,-54,0.5,-11)
        track.BackgroundColor3 = Color3.fromRGB(40,40,41)
        track.BorderSizePixel = 0
        track.Text = ""
        track.AutoButtonColor = false
        track.ZIndex = 12
        lCorner(track,8)

        local knob = Instance.new("Frame",track)
        knob.Name = "Knob"
        knob.Size = UDim2.fromOffset(16,16)
        knob.Position = UDim2.new(0,3,0.5,-8)
        knob.BackgroundColor3 = Color3.fromRGB(185,185,185)
        knob.BorderSizePixel = 0
        knob.ZIndex = 13
        lCorner(knob,8)

        local state = default == true
        local busy = false
        local function visual(on)
            state = on == true
            rail.BackgroundTransparency = state and 0 or 1
            lTween(track,{BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(40,40,41)},0.14)
            lTween(knob,{
                Position=state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                BackgroundColor3=state and Color3.fromRGB(12,12,12) or Color3.fromRGB(185,185,185),
            },0.16)
            label.TextColor3 = Color3.fromRGB(238,238,238)
            label.Font = state and Enum.Font.GothamBold or Enum.Font.GothamMedium
            local st = row:FindFirstChild("LPStroke")
            if st then
                st.Color = state and Color3.fromRGB(156,169,186) or Color3.fromRGB(48,55,65)
                st.Thickness = state and 1.35 or 1
                st.Transparency = state and 0.10 or 0.42
            end
            row.BackgroundColor3 = state and Color3.fromRGB(16,19,23) or Color3.fromRGB(13,16,20)
            row.BackgroundTransparency = state and 0.02 or 0.08
        end
        visual(state)
        local refKey = ({["Auto Steal"]="autoSteal", ["Auto Destroy"]="destroySentry", ["Auto Destroy V2"]="destroySentry", ["Anti Trap"]="antiTrap", ["Auto Equip Trap 0M"]="antiTrapZeroM"})[labelText]
        if refKey then
            ToggleRefs[refKey] = {setVisual=visual, set=function(v) visual(v) end, get=function() return state end}
        end
        local function fire()
            if busy then return end
            busy = true
            local nextState = not state
            visual(nextState)
            -- Ace dispatches feature work asynchronously so the UI remains responsive.
            task.spawn(function()
                if callback then pcall(callback,nextState) end
                pcall(saveCfg)
            end)
            task.delay(0.12,function() busy=false end)
        end
        track.Activated:Connect(fire)
        row.MouseEnter:Connect(function()
            if not state then lTween(row,{BackgroundTransparency=0.02},0.09) end
        end)
        row.MouseLeave:Connect(function()
            if not state then lTween(row,{BackgroundTransparency=0.08},0.09) end
        end)
        return {row=row,set=function(v) visual(v) end,get=function() return state end}
    end

    local function addFPSCapControl2(parent, order)
        local row, label = baseRow2(parent, "FPS Cap", order, 52)
        label.Size = UDim2.new(1, -108, 0, 22)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.TextSize = 11
        local valueLabel = Instance.new("TextLabel", row)
        valueLabel.Name = "FPSCapValue"
        valueLabel.BackgroundTransparency = 1
        valueLabel.Size = UDim2.fromOffset(92, 22)
        valueLabel.Position = UDim2.new(1, -102, 0, 0)
        valueLabel.TextColor3 = LPColors.white
        valueLabel.TextSize = 10
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.ZIndex = 8

        local track = Instance.new("Frame", row)
        track.Name = "FPSCapTrack"
        track.Position = UDim2.new(0, 12, 1, -15)
        track.Size = UDim2.new(1, -24, 0, 7)
        track.BackgroundColor3 = Color3.fromRGB(4, 6, 8)
        track.BorderSizePixel = 0
        track.ZIndex = 8
        lCorner(track, 4)
        lStroke(track, Color3.fromRGB(48, 55, 65), 1, 0.2)

        local fill = Instance.new("Frame", track)
        fill.Name = "FPSCapFill"
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = LPColors.accent
        fill.BorderSizePixel = 0
        fill.ZIndex = 9
        lCorner(fill, 4)

        local knob = Instance.new("Frame", track)
        knob.Name = "FPSCapKnob"
        knob.Size = UDim2.fromOffset(12, 12)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = LPColors.white
        knob.BorderSizePixel = 0
        knob.ZIndex = 10
        lCorner(knob, 8)
        lStroke(knob, LPColors.accent, 1, 0.05)

        local dragging = false
        local updating = false
        local function paint(value)
            value = math.clamp(math.floor(tonumber(value) or 240), 30, 1000)
            local alpha = (value - 30) / 970
            valueLabel.Text = tostring(value) .. " FPS"
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        end
        local function setFromScreenX(screenX, persist)
            if updating then return end
            updating = true
            local width = math.max(track.AbsoluteSize.X, 1)
            local alpha = math.clamp((screenX - track.AbsolutePosition.X) / width, 0, 1)
            local value = math.clamp(math.floor(30 + alpha * 970 + 0.5), 30, 1000)
            paint(value)
            setFPSCap(value, false)
            if persist then autoSaveDebounced() end
            updating = false
        end
        local function beginDrag(input)
            local inputType = input.UserInputType
            if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then return end
            dragging = true
            setFromScreenX(input.Position.X, false)
        end
        track.InputBegan:Connect(beginDrag)
        knob.InputBegan:Connect(beginDrag)
        table.insert(_G.__12HubFPSControlConnections, UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                setFromScreenX(input.Position.X, false)
            end
        end))
        table.insert(_G.__12HubFPSControlConnections, UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    autoSaveDebounced()
                end
            end
        end))
        paint(St.fpsCap or 240)
        return {row=row, get=function() return St.fpsCap end, set=paint}
    end

    local function addButton2(parent,text,callback,order)
        local row = baseRow2(parent,text,order,36)
        local button = Instance.new("TextButton",row)
        button.Name = "ActionButton"
        button.Size = UDim2.fromScale(1,1)
        button.BackgroundColor3 = Color3.fromRGB(18,21,26)
        button.BackgroundTransparency = 0.04
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = LPColors.white
        button.TextSize = 11
        button.Font = Enum.Font.GothamBlack
        button.AutoButtonColor = false
        button.ZIndex = 20
        lCorner(button, 7)
        lStroke(button, Color3.fromRGB(48,55,65), 1.05, 0.22)
        button.MouseEnter:Connect(function()
            lTween(button,{BackgroundColor3=Color3.fromRGB(22,25,30)},0.08)
        end)
        button.MouseLeave:Connect(function()
            lTween(button,{BackgroundColor3=Color3.fromRGB(18,21,26)},0.08)
        end)
        local flashAction = text == "Drop Now" or text == "TP Down"
            or text == "Save TP Best" or text == "TP Best"
        local flashToken = 0
        button.Activated:Connect(function()
            if flashAction then
                flashToken = flashToken + 1
                local thisFlash = flashToken
                button.BackgroundColor3 = Color3.fromRGB(0,0,0)
                button.BackgroundTransparency = 0
                button.TextColor3 = Color3.fromRGB(255,255,255)
                button.Font = Enum.Font.GothamBlack
                task.delay(0.12,function()
                    if button.Parent and thisFlash == flashToken then
                        button.BackgroundTransparency = 0.04
                        button.BackgroundColor3 = Color3.fromRGB(18,21,26)
                        button.TextColor3 = LPColors.white
                    end
                end)
            end
            if callback then pcall(callback) end
        end)
        return row
    end

    local function addTextBox2(parent,labelText,value,callback,order,width)
        local row,label = baseRow2(parent,labelText,order,36)
        local box = Instance.new("TextBox",row)
        box.Name = "ValueBox"
        box.Size = UDim2.fromOffset(width or 60,24)
        box.Position = UDim2.new(1,-(width or 60)-10,0.5,-12)
        box.BackgroundColor3 = LPColors.row2
        box.BackgroundTransparency = 0.12
        box.BorderSizePixel = 0
        box.Text = tostring(value or "")
        box.TextColor3 = LPColors.white
        box.TextSize = 11
        box.Font = Enum.Font.GothamMedium
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Center
        lCorner(box,7)
        lStroke(box,LPColors.soft,1,0.42)
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then
                if callback then pcall(callback,n) end
            else
                box.Text = tostring(value or "")
            end
        end)
        return row,box
    end

    local function addChoiceRow2(parent,labelText,choices,current,callback,order)
        local row = baseRow2(parent,labelText,order,42)
        local label = row:FindFirstChild("Label")
        if label then
            label.Size = UDim2.new(0.42, -8, 1, 0)
            label.TextSize = 10
        end
        local startScale = 0.44
        local areaScale = 0.54
        local widthScale = areaScale / math.max(1, #choices)
        local track = Instance.new("Frame", row)
        track.Name = "AceModeTrack"
        track.Position = UDim2.new(startScale, 1, 0.5, -14)
        track.Size = UDim2.new(areaScale, -2, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(6, 7, 9)
        track.BorderSizePixel = 0
        track.ZIndex = 17
        lCorner(track, 7)
        lStroke(track, Color3.fromRGB(48, 55, 65), 1, 0.20)
        local selectedIndex = 1
        for i, name in ipairs(choices) do
            if tostring(current) == tostring(name) then selectedIndex = i break end
        end
        local selector = Instance.new("Frame", row)
        selector.Name = "AceModeSelector"
        selector.Position = UDim2.new(startScale + (selectedIndex - 1) * widthScale, 1, 0.5, -12)
        selector.Size = UDim2.new(widthScale, -4, 0, 24)
        selector.BackgroundColor3 = Color3.fromRGB(47, 77, 101)
        selector.BorderSizePixel = 0
        selector.ZIndex = 18
        lCorner(selector, 6)
        local selectorGradient = Instance.new("UIGradient", selector)
        selectorGradient.Rotation = 90
        selectorGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 49, 63)),
            ColorSequenceKeypoint.new(0.48, Color3.fromRGB(78, 119, 151)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 51, 65)),
        })
        local buttons = {}
        local activeName = choices[selectedIndex]
        local function paintChoice(name, animate)
            local idx = table.find(choices, name) or selectedIndex
            selectedIndex = idx
            activeName = choices[idx]
            local targetPosition = UDim2.new(startScale + (idx - 1) * widthScale, 1, 0.5, -12)
            if animate then
                lTween(selector, {Position = targetPosition}, 0.14)
            else
                selector.Position = targetPosition
            end
            for _, b in ipairs(buttons) do
                local on = b.Text == tostring(activeName)
                b:SetAttribute("SelectedMode", on)
                lTween(b, {TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(136,141,149)}, 0.12)
                b.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            end
        end
        for i, name in ipairs(choices) do
            local b = Instance.new("TextButton",row)
            b.Name = "Choice_"..tostring(name)
            b.Size = UDim2.new(widthScale, 0, 0, 28)
            b.Position = UDim2.new(startScale + (i-1)*widthScale, 0, 0.5, -14)
            b.BackgroundTransparency = 1
            b.BorderSizePixel = 0
            b.TextColor3 = i == selectedIndex and Color3.fromRGB(255,255,255) or Color3.fromRGB(136,141,149)
            b.Text = tostring(name)
            b.TextSize = 10
            b.Font = i == selectedIndex and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.ZIndex = 20
            buttons[#buttons + 1] = b
            b.MouseEnter:Connect(function()
                if b:GetAttribute("SelectedMode") ~= true then
                    lTween(b,{TextColor3=Color3.fromRGB(220,226,232)},0.08)
                end
            end)
            b.MouseLeave:Connect(function()
                local on = b:GetAttribute("SelectedMode") == true
                lTween(b,{TextColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(136,141,149)},0.08)
            end)
            b.Activated:Connect(function()
                if tostring(activeName) == tostring(name) then return end
                paintChoice(name, true)
                if callback then pcall(callback,name) end
                pcall(saveCfg)
            end)
        end
        paintChoice(activeName, false)
        return row
    end

    do -- isolate Speed tab locals
    -- ---------------- SPEED ----------------
    local speedPage = pages2.SPEED
    section2(speedPage,"SPEED V2 • 3 MODE",1)
    addToggle2(speedPage,"Speed On",St.speedOn,function(on)
        if setSpeedOn then setSpeedOn(on) end
    end,2)

    local speedOrder = {Normal=3,Lagger=4,Custom=5}
    local speedRows2 = {}
    for _,modeName in ipairs({"Normal","Lagger","Custom"}) do
        local row = baseRow2(speedPage,modeName.." Spd",speedOrder[modeName],42)
        local m = St.modes[modeName] or {norm=60,steal=30}
        St.modes[modeName] = m

        local nLabel = Instance.new("TextLabel",row)
        nLabel.BackgroundTransparency=1
        nLabel.Size=UDim2.fromOffset(72,18)
        nLabel.Position=UDim2.fromOffset(78,3)
        nLabel.Text="Normal"
        nLabel.TextColor3=LPColors.muted
        nLabel.Font=Enum.Font.GothamMedium
        nLabel.TextSize=9

        local nb = Instance.new("TextBox",row)
        nb.Size=UDim2.fromOffset(44,24)
        nb.Position=UDim2.fromOffset(76,16)
        nb.BackgroundColor3=LPColors.row2
        nb.BackgroundTransparency=0.10
        nb.BorderSizePixel=0
        nb.Text=tostring(m.norm or 60)
        nb.TextColor3=LPColors.white
        nb.TextSize=11
        nb.Font=Enum.Font.GothamBlack
        nb.ClearTextOnFocus=false
        nb.TextXAlignment=Enum.TextXAlignment.Center
        lCorner(nb,7); lStroke(nb,LPColors.soft,1,0.42)

        local kb = Instance.new("TextButton",row)
        kb.Name="PCKey"
        kb.Size=UDim2.fromOffset(34,24)
        kb.Position=UDim2.fromOffset(126,16)
        kb.BackgroundColor3=LPColors.row2
        kb.BackgroundTransparency=0.05
        kb.Text=(St.speedKeys and typeof(St.speedKeys[modeName])=="EnumItem" and St.speedKeys[modeName].Name) or "None"
        kb.TextColor3=LPColors.white
        kb.TextSize=10
        kb.Font=Enum.Font.GothamBlack
        kb.AutoButtonColor=false
        lCorner(kb,7); lStroke(kb,LPColors.accent,1,0.28)

        local sLabel = Instance.new("TextLabel",row)
        sLabel.BackgroundTransparency=1
        sLabel.Size=UDim2.fromOffset(48,18)
        sLabel.Position=UDim2.fromOffset(166,3)
        sLabel.Text="Steal"
        sLabel.TextColor3=LPColors.muted
        sLabel.Font=Enum.Font.GothamMedium
        sLabel.TextSize=9

        local sb = Instance.new("TextBox",row)
        sb.Size=UDim2.fromOffset(44,24)
        sb.Position=UDim2.fromOffset(164,16)
        sb.BackgroundColor3=LPColors.row2
        sb.BackgroundTransparency=0.10
        sb.BorderSizePixel=0
        sb.Text=tostring(m.steal or 30)
        sb.TextColor3=LPColors.white
        sb.TextSize=11
        sb.Font=Enum.Font.GothamBlack
        sb.ClearTextOnFocus=false
        sb.TextXAlignment=Enum.TextXAlignment.Center
        lCorner(sb,7); lStroke(sb,LPColors.soft,1,0.42)

        nb.FocusLost:Connect(function()
            local v=tonumber(nb.Text)
            if v then
                St.modes[modeName].norm=math.clamp(v,1,200)
                if St.activeMode==modeName and St.speedOn then startSpeedBoost() end
                saveSpeedSettings()
            end
            nb.Text=tostring(St.modes[modeName].norm)
        end)
        sb.FocusLost:Connect(function()
            local v=tonumber(sb.Text)
            if v then
                St.modes[modeName].steal=math.clamp(v,1,200)
                if St.activeMode==modeName and St.speedOn then startSpeedBoost() end
                saveSpeedSettings()
            end
            sb.Text=tostring(St.modes[modeName].steal)
        end)
        kb.MouseButton1Click:Connect(function()
            kb.Text="..."
            _G.RanaVSKeybindingCapture = true
            local conn
            conn=UIS.InputBegan:Connect(function(inp,gp)
                if _G._12HubCapturingStealSpeedKey == true then
                    if conn then conn:Disconnect() end
                    _G.RanaVSKeybindingCapture = false
                    return
                end
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                if inp.KeyCode==Enum.KeyCode.Escape then
                    kb.Text=(typeof(St.speedKeys[modeName])=="EnumItem" and St.speedKeys[modeName].Name) or "None"
                elseif St.autoChangeOnSteal ~= true and St.stealSpeedKey ~= "None" and inp.KeyCode.Name == St.stealSpeedKey then
                    kb.Text="KEY USED"
                    task.delay(0.6,function()
                        if kb and kb.Parent then kb.Text=(typeof(St.speedKeys[modeName])=="EnumItem" and St.speedKeys[modeName].Name) or "None" end
                    end)
                else
                    St.speedKeys[modeName]=inp.KeyCode
                    kb.Text=inp.KeyCode.Name
                    saveSpeedSettings()
                end
                if conn then conn:Disconnect() end
                _G.RanaVSKeybindingCapture = false
            end)
        end)
        speedRows2[modeName]={normal=nb,steal=sb,key=kb}
    end

    section2(speedPage,"ACTIVE SPEED MODE",7)
    local speedModeButtons2={}
    local modeRow = Instance.new("Frame",speedPage)
    modeRow.Name="ActiveSpeedMode"
    modeRow.Size=UDim2.new(1,-4,0,42)
    modeRow.BackgroundTransparency=1
    modeRow.LayoutOrder=8
    local modesList={"Normal","Lagger","Custom"}
    for i,name in ipairs(modesList) do
        local b=Instance.new("TextButton",modeRow)
        b.Size=UDim2.fromOffset(92,30)
        b.Position=UDim2.fromOffset(4+(i-1)*98,6)
        b.Text=name
        b.TextSize=10
        b.Font=Enum.Font.GothamBlack
        b.AutoButtonColor=false
        b.ZIndex=20
        lCorner(b,9); lStroke(b,LPColors.soft,1,0.38)
        speedModeButtons2[name]=b
        local function refresh()
            for n,x in pairs(speedModeButtons2) do
                local on=St.activeMode==n
                setAceModeVisual(x, on, "LPStroke")
            end
        end
        b.Activated:Connect(function() setActiveMode(name); refresh() end)
    end
    _G.RanaVSRefresh_LaPeakHybridSpeed = function()
        for n,x in pairs(speedModeButtons2) do
            local on=St.activeMode==n
            setAceModeVisual(x, on, "LPStroke")
        end
    end
    _G.RanaVSRefresh_LaPeakHybridSpeed()

    -- Auto Change on Steal + configurable hotkey + explicit state button.
    local stealSpeedKeyRow2, stealSpeedKeyButton2, stealSpeedStateButton2, stealSpeedStateRow2
    local function refreshStealSpeedControls2()
        local showManual2 = (St.autoChangeOnSteal ~= true)
        if stealSpeedKeyRow2 then
            stealSpeedKeyRow2.Visible = showManual2
        end
        if stealSpeedStateRow2 then
            stealSpeedStateRow2.Visible = showManual2
        end
        if _G.RanaVSRefreshFloatingStealSpeedButton then pcall(_G.RanaVSRefreshFloatingStealSpeedButton) end
        if stealSpeedKeyButton2 then
            local keyName = tostring(St.stealSpeedKey or "None")
            stealSpeedKeyButton2.Text = (keyName == "None") and "SET KEY" or keyName
        end
        if stealSpeedStateButton2 then
            local activeSteal = St.stealSpeedActive == true
            stealSpeedStateButton2.Text = activeSteal and "STEAL SPEED: ON" or "NORMAL SPEED: ON"
            setAceModeVisual(stealSpeedStateButton2, activeSteal, "LPStroke")
        end
    end

    section2(speedPage, "STEAL SPEED CONTROL", 9)
    local autoChangeRef2 = addToggle2(speedPage, "Auto Change on Steal", St.autoChangeOnSteal == true, function(on)
        St.autoChangeOnSteal = (on == true)
        if St.autoChangeOnSteal then
            if _G.RanaVSRefreshAutoStealWalkSpeed then pcall(_G.RanaVSRefreshAutoStealWalkSpeed) end
        else
            -- When auto mode is disabled, don't continue a state that was set automatically.
            setStealSpeedActive2(false, false)
        end
        refreshStealSpeedControls2()
        pcall(saveCfg)
    end, 10)

    local keyRow2, keyLabel2 = baseRow2(speedPage, "Steal Speed Keybind", 11, 42)
    keyLabel2.Size = UDim2.new(1, -124, 1, 0)
    stealSpeedKeyRow2 = keyRow2
    local keyButton2 = Instance.new("TextButton", keyRow2)
    keyButton2.Name = "StealSpeedKeybind"
    keyButton2.Size = UDim2.fromOffset(104, 26)
    keyButton2.Position = UDim2.new(1, -114, 0.5, -13)
    keyButton2.BackgroundColor3 = Color3.fromRGB(18, 21, 26)
    keyButton2.BorderSizePixel = 0
    keyButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton2.TextSize = 10
    keyButton2.Font = Enum.Font.GothamBlack
    keyButton2.AutoButtonColor = false
    keyButton2.ZIndex = 20
    lCorner(keyButton2, 7)
    lStroke(keyButton2, Color3.fromRGB(48, 55, 65), 1, 0.25)
    stealSpeedKeyButton2 = keyButton2

    local keyCaptureConnection2
    keyButton2.Activated:Connect(function()
        if keyCaptureConnection2 then
            pcall(function() keyCaptureConnection2:Disconnect() end)
            keyCaptureConnection2 = nil
        end
        _G.RanaVSKeybindingCapture = false
        _G._12HubCapturingStealSpeedKey = true
        keyButton2.Text = "PRESS KEY"
        keyCaptureConnection2 = UIS.InputBegan:Connect(function(input, gp)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local keyName = input.KeyCode.Name
            if keyName == "Escape" then
                St.stealSpeedKey = "None"
            else
                local conflict = false
                for _, modeKey in pairs(St.speedKeys or {}) do
                    if typeof(modeKey) == "EnumItem" and modeKey.Name == keyName then conflict = true break end
                end
                for _, actionKey in pairs(St.keys or {}) do
                    if typeof(actionKey) == "EnumItem" and actionKey.Name == keyName then conflict = true break end
                end
                if conflict then
                    keyButton2.Text = "KEY USED"
                    task.delay(0.65, function()
                        if keyButton2 and keyButton2.Parent then refreshStealSpeedControls2() end
                    end)
                else
                    St.stealSpeedKey = keyName
                end
            end
            if keyCaptureConnection2 then
                pcall(function() keyCaptureConnection2:Disconnect() end)
                keyCaptureConnection2 = nil
            end
            _G._12HubCapturingStealSpeedKey = false
            refreshStealSpeedControls2()
            pcall(saveCfg)
        end)
    end)

    local stateRow2, stateLabel2 = baseRow2(speedPage, "Current Speed State", 12, 42)
    stealSpeedStateRow2 = stateRow2
    stateLabel2.Size = UDim2.new(1, -154, 1, 0)
    local stateButton2 = Instance.new("TextButton", stateRow2)
    stateButton2.Name = "StealSpeedStateButton"
    stateButton2.Size = UDim2.fromOffset(142, 28)
    stateButton2.Position = UDim2.new(1, -152, 0.5, -14)
    stateButton2.BackgroundColor3 = Color3.fromRGB(18, 21, 26)
    stateButton2.BorderSizePixel = 0
    stateButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
    stateButton2.TextSize = 9
    stateButton2.Font = Enum.Font.GothamBlack
    stateButton2.AutoButtonColor = false
    stateButton2.ZIndex = 20
    lCorner(stateButton2, 8)
    lStroke(stateButton2, Color3.fromRGB(48, 55, 65), 1, 0.25)
    stealSpeedStateButton2 = stateButton2
    stateButton2.Activated:Connect(function()
        -- Manual state button is usable only when automatic switching is disabled.
        if St.autoChangeOnSteal == true then return end
        setStealSpeedActive2(not (St.stealSpeedActive == true))
    end)

    -- Compact size control for the floating Steal Speed button (40–120 px, step 5).
    -- Put the size control in SETTINGS, alongside other mobile/floating UI settings.
    section2(pages2.SETTINGS, "STEAL SPEED BUTTON", 21)
    local sizeRow2, sizeLabel2 = baseRow2(pages2.SETTINGS, "Steal Speed Button Size", 22, 42)
    sizeLabel2.Size = UDim2.new(1, -152, 1, 0)
    local sizeDown2 = Instance.new("TextButton", sizeRow2)
    sizeDown2.Name = "StealSpeedSizeDown"
    sizeDown2.Size = UDim2.fromOffset(28, 26)
    sizeDown2.Position = UDim2.new(1, -112, 0.5, -13)
    sizeDown2.BackgroundColor3 = Color3.fromRGB(18, 21, 26)
    sizeDown2.BorderSizePixel = 0
    sizeDown2.Text = "−"
    sizeDown2.TextSize = 15
    sizeDown2.Font = Enum.Font.GothamBlack
    sizeDown2.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeDown2.AutoButtonColor = false
    lCorner(sizeDown2, 7); lStroke(sizeDown2, Color3.fromRGB(48, 55, 65), 1, 0.25)
    local sizeValue2 = Instance.new("TextLabel", sizeRow2)
    sizeValue2.Name = "StealSpeedSizeValue"
    sizeValue2.Size = UDim2.fromOffset(48, 26)
    sizeValue2.Position = UDim2.new(1, -80, 0.5, -13)
    sizeValue2.BackgroundColor3 = Color3.fromRGB(13, 16, 20)
    sizeValue2.BorderSizePixel = 0
    sizeValue2.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeValue2.Font = Enum.Font.GothamBold
    sizeValue2.TextSize = 10
    sizeValue2.Text = tostring(St.stealSpeedButtonSize or 70) .. " px"
    lCorner(sizeValue2, 7); lStroke(sizeValue2, Color3.fromRGB(48, 55, 65), 1, 0.25)
    local sizeUp2 = Instance.new("TextButton", sizeRow2)
    sizeUp2.Name = "StealSpeedSizeUp"
    sizeUp2.Size = UDim2.fromOffset(28, 26)
    sizeUp2.Position = UDim2.new(1, -28, 0.5, -13)
    sizeUp2.BackgroundColor3 = Color3.fromRGB(18, 21, 26)
    sizeUp2.BorderSizePixel = 0
    sizeUp2.Text = "+"
    sizeUp2.TextSize = 15
    sizeUp2.Font = Enum.Font.GothamBlack
    sizeUp2.TextColor3 = Color3.fromRGB(255, 255, 255)
    sizeUp2.AutoButtonColor = false
    lCorner(sizeUp2, 7); lStroke(sizeUp2, Color3.fromRGB(48, 55, 65), 1, 0.25)
    local function changeStealButtonSize2(delta2)
        local current2 = math.clamp(tonumber(St.stealSpeedButtonSize) or 70, 40, 120)
        local next2 = math.clamp(current2 + delta2, 40, 120)
        if _G.RanaVSSetStealSpeedButtonSize then pcall(_G.RanaVSSetStealSpeedButtonSize, next2, false) else St.stealSpeedButtonSize = next2 end
        sizeValue2.Text = tostring(St.stealSpeedButtonSize) .. " px"
        pcall(saveCfg)
    end
    sizeDown2.Activated:Connect(function() changeStealButtonSize2(-5) end)
    sizeUp2.Activated:Connect(function() changeStealButtonSize2(5) end)

    _G.RanaVSRefreshStealSpeedControls = refreshStealSpeedControls2
    refreshStealSpeedControls2()
    keyRow2.AncestryChanged:Connect(function(_, parent)
        if not parent then
            _G._12HubCapturingStealSpeedKey = false
            if keyCaptureConnection2 then pcall(function() keyCaptureConnection2:Disconnect() end) end
        end
    end)

    end -- close preceding tab scope
    do -- isolate Player tab locals
    -- ---------------- PLAYER ----------------
    local playerPage=pages2.PLAYER
    section2(playerPage,"AUTO STEAL",1)
    -- AUTO STEAL: two 50/50 selector rows, Mode then Version.
    local asButtons={}
    local asVersionButtons={}

    local function refreshAutoStealButtons()
        for name, b in pairs(asButtons) do
            setAceModeVisual(b, name == selectedStealMode, "LPStroke")
        end
        for name, b in pairs(asVersionButtons) do
            setAceModeVisual(b, name == autoStealV2Version, "LPStroke")
        end
    end

    local function chooseAutoSteal(mode, version)
        mode=(tostring(mode)=="Semi") and "Semi" or "Normal"
        version=(tostring(version)=="V1") and "V1" or "V2"
        selectedStealMode=mode
        autoStealV2Version=version
        St.stealVer=mode.."-"..version
        autoStealRadius=tonumber(St.stealRadius) or 60

        -- Single authoritative switch. Stop both variants before starting the selected one.
        pcall(function()
            if _G.RanaVSSelectAutoSteal then
                _G.RanaVSSelectAutoSteal(mode,version)
            else
                _12HubNormalizeStealSelection(mode,version)
                _12HubSyncAutoSteal()
            end
        end)

        -- Re-assert the selected state so no legacy hook can force it back.
        selectedStealMode=mode
        autoStealV2Version=version
        St.stealVer=mode.."-"..version
        refreshAutoStealButtons()
        pcall(function() if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end end)
        if _G.RanaVSShowMenuTab then _G.RanaVSShowMenuTab("PLAYER") end
        pcall(saveCfg)
    end

    local asRow,asLabel=baseRow2(playerPage,"",2,42)
    asLabel.Text = ""
    for i,name in ipairs({"Normal","Semi"}) do
        local b=Instance.new("TextButton",asRow)
        b.Name="AutoSteal_"..name
        b.Size=UDim2.new(0.5,-4,1,-14)
        b.Position=(i==1) and UDim2.new(0,3,0,7) or UDim2.new(0.5,1,0,7)
        b.Text=name
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamMedium
        b.ZIndex=25
        lCorner(b,8); lStroke(b,LPColors.soft,1.1,0.42)
        asButtons[name]=b
        b.Activated:Connect(function() chooseAutoSteal(name,autoStealV2Version) end)
    end

    local versionRow,versionLabel=baseRow2(playerPage,"",3,42)
    versionLabel.Text = ""
    for i,name in ipairs({"V1","V2"}) do
        local b=Instance.new("TextButton",versionRow)
        b.Name="AutoStealVersion_"..name
        b.Size=UDim2.new(0.5,-4,1,-14)
        b.Position=(i==1) and UDim2.new(0,3,0,7) or UDim2.new(0.5,1,0,7)
        b.Text=name
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamMedium
        b.ZIndex=25
        lCorner(b,8); lStroke(b,LPColors.soft,1.1,0.42)
        asVersionButtons[name]=b
        b.Activated:Connect(function() chooseAutoSteal(selectedStealMode,name) end)
    end

    -- Normal V2 only: LaPeak/Ambitious-style pause percentage presets.
    local pauseRow=baseRow2(playerPage,"Pause",4,42)
    local pauseButtons={}
    local pausePresets={70,75,80,85,90}
    local function refreshPauseRow()
        local visible=(selectedStealMode=="Normal" and autoStealV2Version=="V2")
        pauseRow.Visible=visible
        for pct,b in pairs(pauseButtons) do
            local on=(tonumber(St.normalV2PausePercent) or 75)==pct
            setAceModeVisual(b, on, "LPStroke")
        end
    end
    for i,pct in ipairs(pausePresets) do
        local b=Instance.new("TextButton",pauseRow)
        b.Name="Pause_"..pct
        b.Size=UDim2.new(0.2,-7,1,-14)
        b.Position=UDim2.new((i-1)*0.2,4,0,7)
        b.Text=tostring(pct).."%"
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamMedium
        b.ZIndex=25
        lCorner(b,8); lStroke(b,LPColors.soft,1.1,0.42)
        pauseButtons[pct]=b
        b.Activated:Connect(function()
            St.normalV2PausePercent=pct
            refreshPauseRow()
            if _G.AdaptSetStealPause then
                pcall(_G.AdaptSetStealPause, pct)
            else
                St.normalV2PausePercent = pct
                pcall(saveCfg)
            end
        end)
    end

    refreshAutoStealButtons()
    refreshPauseRow()
    _G.RanaVSRefreshAutoStealSelector=function() refreshAutoStealButtons(); refreshPauseRow() end

    addToggle2(playerPage,"Auto Steal",St.autoSteal,function(on)
        selectedStealMode=(tostring(selectedStealMode)=="Semi") and "Semi" or "Normal"
        autoStealV2Version=(tostring(autoStealV2Version)=="V1") and "V1" or "V2"
        St.stealVer=selectedStealMode.."-"..autoStealV2Version
        setAutoSteal(on)
    end,1)
    addTextBox2(playerPage,"Steal Radius",St.stealRadius,function(v)
        if type(setStealRadius) == "function" then
            setStealRadius(v)
        else
            St.stealRadius=math.clamp(tonumber(v) or 60,1,250)
            autoStealRadius=St.stealRadius
            pcall(saveCfg)
        end
    end,4,62)

    section2(playerPage,"PLAYER / COMBAT",6)
    addToggle2(playerPage,"Anti Gummy Bear",St.antiGummy,setAntiGummy,7)
    addToggle2(playerPage,"Anti Bee",St.antiBee==true,setAntiBee,7.5)
    addToggle2(playerPage,"Anti Ragdoll",St.antiRagdoll,setAntiRagdoll,8)
    addChoiceRow2(playerPage,"Anti Ragdoll Mode",{"V1","V2"},tostring(St.antiRagdollMode or "V1"),function(name)
        if type(setAntiRagdollMode)=="function" then
            pcall(setAntiRagdollMode,name)
        else
            St.antiRagdollMode=(name=="V2") and "V2" or "V1"
        end
        pcall(saveCfg)
    end,8.5)
    addToggle2(playerPage,"Anti Paintball Gun",St.antiPaint,setAntiPaint,9)
    addToggle2(playerPage,"Anti Boogie Bomb",St.antiBoogie,setAntiBoogie,10)
    addToggle2(playerPage,"Tool Aimbot",St.toolAim,setToolAim,11)
    addToggle2(playerPage,"Infinite Jump",St.infJump,setInfJump,14)
    addToggle2(playerPage,"Auto Destroy V2",St.destroySentry,setDestroySentry,15)

    addChoiceRow2(playerPage,"Drop Mode",{"Stand","Jump"},St.dropMode==2 and "Jump" or "Stand",function(name)
        St.dropMode=(name=="Jump") and 2 or 1
        pcall(saveCfg)
    end,16)
    addButton2(playerPage,"Drop Now",runDrop,17)
    addChoiceRow2(playerPage,"Reset Mode",{"Fast Reset","V2"},St.instaMode,function(name)
        St.instaMode = name
        local resetEntry = actRefs and actRefs.insta
        if resetEntry and resetEntry.btn then
            local resetText = name == "V2" and "INSTA\nRESET" or "FAST\nRESET"
            resetEntry.btn.Text = resetText
            resetEntry.onText = resetText
            resetEntry.offText = resetText
        end
        pcall(saveCfg)
    end,18)
    addButton2(playerPage,"Fast Reset Now",doInstaReset,19)
    do
        local row = addButton2(playerPage,"Save TP Best",TPBest.savePosition,22)
        TPBest.saveButton = row and row:FindFirstChildOfClass("TextButton") or nil
        local label = row and row:FindFirstChild("Label")
        if label then label.Visible = false end
    end
    do
        local row = addButton2(playerPage,"TP Best",TPBest.teleport,23)
        TPBest.goButton = row and row:FindFirstChildOfClass("TextButton") or nil
        local label = row and row:FindFirstChild("Label")
        if label then label.Visible = false end
    end
    addButton2(playerPage,"TP Down",function() doTPDown(true) end,24)

    -- ---------------- ANTI TRAP ----------------
    section2(playerPage,"ANTI TRAP",25)
    addToggle2(playerPage,"Anti Trap",St.antiTrap==true,setAntiTrap,26)

    local antiTrapGearFrame = Instance.new("Frame",playerPage)
    antiTrapGearFrame.Name = "AntiTrapGearSelector"
    antiTrapGearFrame.Size = UDim2.new(1,-4,0,78)
    antiTrapGearFrame.BackgroundColor3 = LPColors.row
    antiTrapGearFrame.BackgroundTransparency = 0.22
    antiTrapGearFrame.BorderSizePixel = 0
    antiTrapGearFrame.LayoutOrder = 27
    lCorner(antiTrapGearFrame,9)
    lStroke(antiTrapGearFrame,LPColors.soft,1.1,0.42)

    local antiTrapGearTitle = Instance.new("TextLabel",antiTrapGearFrame)
    antiTrapGearTitle.BackgroundTransparency = 1
    antiTrapGearTitle.Size = UDim2.new(1,-12,0,20)
    antiTrapGearTitle.Position = UDim2.fromOffset(10,4)
    antiTrapGearTitle.Text = "ANTI TRAP GEAR"
    antiTrapGearTitle.TextColor3 = LPColors.white
    antiTrapGearTitle.Font = Enum.Font.GothamBlack
    antiTrapGearTitle.TextSize = 9
    antiTrapGearTitle.TextXAlignment = Enum.TextXAlignment.Left

    local antiTrapGearButtons = {}
    local antiTrapGearNames = {
        "Cupid's Wings",
        "Santa's Sleigh",
        "Witch's Broom",
        "Flying Carpet",
        "Waverider",
    }
    for i,gearName in ipairs(antiTrapGearNames) do
        local b = Instance.new("TextButton",antiTrapGearFrame)
        b.Name = "Gear_"..tostring(i)
        b.Size = UDim2.new(0.2,-5,0,40)
        b.Position = UDim2.new((i-1)*0.2,4,0,31)
        b.BackgroundColor3 = (St.antiTrapGear==gearName) and LPColors.accent or Color3.fromRGB(18,21,26)
        b.TextColor3 = (St.antiTrapGear==gearName) and Color3.fromRGB(255,255,255) or Color3.fromRGB(138,142,148)
        b.Text = gearName
        b.TextSize = 8
        b.TextWrapped = true
        b.Font = (St.antiTrapGear==gearName) and Enum.Font.GothamBlack or Enum.Font.GothamMedium
        b.AutoButtonColor = false
        b.ZIndex = 20
        lCorner(b,7)
        lStroke(b,(St.antiTrapGear==gearName) and LPColors.accent or Color3.fromRGB(48,55,65),1.0,(St.antiTrapGear==gearName) and 0.02 or 0.30)
        setAceModeVisual(b, St.antiTrapGear == gearName, "LPStroke")
        antiTrapGearButtons[gearName] = b
        b.Activated:Connect(function()
            if type(setAntiTrapGear)=="function" then
                setAntiTrapGear(gearName)
            else
                St.antiTrapGear = gearName
                pcall(saveCfg)
            end
            if _G.RanaVSFindAntiTrapTool then pcall(_G.RanaVSFindAntiTrapTool) end
            if _G.RanaVSRefreshAntiTrapGearUI then pcall(_G.RanaVSRefreshAntiTrapGearUI) end
        end)
    end

    local function refreshAntiTrapGearUI()
        if _G.RanaVSFindAntiTrapTool then pcall(_G.RanaVSFindAntiTrapTool) end
        for gearName, button in pairs(antiTrapGearButtons) do
            local selected = gearName == St.antiTrapGear
            local available = false
            if _G.RanaVSHasAntiTrapGear then
                local ok, result = pcall(_G.RanaVSHasAntiTrapGear, gearName)
                available = ok and result == true
            end
            setAceModeVisual(button, selected, "LPStroke")
            button.TextTransparency = available and 0 or 0.30
            button:SetAttribute("OwnedInInventory", available)
            button:SetAttribute("SelectedGear", selected)
        end
    end
    _G.RanaVSRefreshAntiTrapGearUI = refreshAntiTrapGearUI
    refreshAntiTrapGearUI()

    -- Backpack and respawn changes refresh only the small selector, not a full
    -- inventory/workspace scan every frame.
    if type(_G.RanaVSAntiTrapInventoryConnections) == "table" then
        for _, oldConnection in ipairs(_G.RanaVSAntiTrapInventoryConnections) do
            pcall(function() oldConnection:Disconnect() end)
        end
    end
    if _G.RanaVSAntiTrapGearCharacterConnection then
        pcall(function() _G.RanaVSAntiTrapGearCharacterConnection:Disconnect() end)
        _G.RanaVSAntiTrapGearCharacterConnection = nil
    end
    local antiTrapRefreshConnections = {}
    _G.RanaVSAntiTrapInventoryConnections = antiTrapRefreshConnections
    local antiTrapCharacterAddedConnection = nil
    local function bindAntiTrapInventoryEvents()
        -- Only replace Backpack/current-Character listeners here. Keep the one
        -- CharacterAdded listener alive across every respawn.
        for _, connection in ipairs(antiTrapRefreshConnections) do pcall(function() connection:Disconnect() end) end
        table.clear(antiTrapRefreshConnections)
        local backpack = LP:FindFirstChildOfClass("Backpack")
        local character = LP.Character
        local function refreshSoon()
            task.delay(0.12, function()
                if _G.RanaVSRefreshAntiTrapGearUI then pcall(_G.RanaVSRefreshAntiTrapGearUI) end
            end)
        end
        if backpack then
            table.insert(antiTrapRefreshConnections, backpack.ChildAdded:Connect(refreshSoon))
            table.insert(antiTrapRefreshConnections, backpack.ChildRemoved:Connect(refreshSoon))
        end
        if character then
            table.insert(antiTrapRefreshConnections, character.ChildAdded:Connect(refreshSoon))
            table.insert(antiTrapRefreshConnections, character.ChildRemoved:Connect(refreshSoon))
        end
    end
    bindAntiTrapInventoryEvents()
    antiTrapCharacterAddedConnection = LP.CharacterAdded:Connect(function()
        task.defer(bindAntiTrapInventoryEvents)
        task.delay(0.3, function()
            if _G.RanaVSRefreshAntiTrapGearUI then pcall(_G.RanaVSRefreshAntiTrapGearUI) end
        end)
    end)
    _G.RanaVSAntiTrapGearCharacterConnection = antiTrapCharacterAddedConnection

    end -- close preceding tab scope
    do -- isolate ESP tab locals
    -- ---------------- ESP ----------------
    local espPage=pages2.ESP
    section2(espPage,"ESP / TRACKER",1)
    addToggle2(espPage,"Player ESP",St.esp,setESP,2)
    addToggle2(espPage,"Tracker / Tracer",St.tracer,setTracer,3)
    addToggle2(espPage,"Anti Lag",St.antiLag,setAntiLag,4)
    addToggle2(espPage,"Nuke Optimize",St.nukeOptimiserEnabled == true,setNukeOptimizer,5)
    addToggle2(espPage,"Optimizer",St.optimizerEnabled == true,setOptimizer,6)
    addFPSCapControl2(espPage,7)

    section2(espPage,"TRAP ESP / ANTI TRAP",8)
    addToggle2(espPage,"Trap ESP",St.trapESP,function(on)
        if _G.RanaVSSetTrapESP then _G.RanaVSSetTrapESP(on) end
    end,9)
    addToggle2(espPage,"Trap Distance",St.trapDistanceESP,function(on)
        if _G.RanaVSSetTrapDistanceESP then _G.RanaVSSetTrapDistanceESP(on) end
    end,10)
    addToggle2(espPage,"Trap Outline",St.trapOutlineESP,function(on)
        if _G.RanaVSSetTrapOutlineESP then _G.RanaVSSetTrapOutlineESP(on) end
    end,11)
    addToggle2(espPage,"Subspace Trap ESP",St.subspaceESP,function(on)
        if _G.RanaVSSetSubspaceESP then _G.RanaVSSetSubspaceESP(on) end
    end,12)
    addToggle2(espPage,"Auto Equip Trap 0M",St.antiTrap==true,function(on)
        -- Toggling Auto Equip 0M also switches the shared Anti Trap control/button.
        if type(setAntiTrap) == "function" then
            setAntiTrap(on)
        elseif _G.RanaVSSetAntiTrapZeroM then
            _G.RanaVSSetAntiTrapZeroM(on)
        end
    end,13)
    addTextBox2(espPage,"Trap Scan Range",St.trapScanRange,function(v)
        if _G.RanaVSSetTrapScanRange then _G.RanaVSSetTrapScanRange(v) end
    end,14,70)

    end -- close preceding tab scope
    do -- isolate Spam tab locals
    -- ---------------- SPAM ----------------
    local spamPage=pages2.SPAM
    section2(spamPage,"AUTO SPAM",1)
    addToggle2(spamPage,"Spam Laser Cape",St.spamLaser,setSpamLaser,2)
    addToggle2(spamPage,"Spam Paintball Gun",St.spamPaint,setSpamPaint,3)

    end -- close preceding tab scope
    do -- isolate Counter tab locals
    -- ---------------- COUNTER ----------------
    local counterPage=pages2.COUNTER
    section2(counterPage,"COUNTER",1)
    addToggle2(counterPage,"Auto Laser Cape",St.counterLaser==true,setCounterLaser,2)
    addToggle2(counterPage,"Auto Boogie Bomb",St.counterBoogie==true,setCounterBoogie,3)
    addToggle2(counterPage,"Auto Swap Body",St.counterSwapBody==true,setCounterSwapBody,4)
    addToggle2(counterPage,"Equip & Activate on Drop",St.equipOnDrop==true,setEquipOnDrop,5)

    end -- close preceding tab scope
    do -- isolate Settings tab locals
    -- ---------------- SETTINGS ----------------
    local setPage=pages2.SETTINGS
    section2(setPage,"MENU / MOBILE",1)
    addToggle2(setPage,"Mobile Buttons",St.mobileBtns,function(on)
        St.mobileBtns=on
        if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
        if _G.RanaVSBuildV2ModeBar then pcall(_G.RanaVSBuildV2ModeBar) end
    end,2)
    addToggle2(setPage,"Show Auto Steal Button",St.showStealBtn~=false,function(on)
        St.showStealBtn=on
        if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
    end,3)
    addToggle2(setPage,"Show TP Panel",St.showTPPanel~=false,function(on)
        St.showTPPanel=on
        local g=game:GetService("CoreGui"):FindFirstChild("12Hub_AllGearOnTop")
        if g then g.Enabled=on end
        pcall(saveCfg)
    end,4)
    local lockUiToggle2 = addToggle2(setPage,"Lock UI",St.menuGuiLocked,function(on)
        if _G.RanaVSSetUILocked then
            _G.RanaVSSetUILocked(on)
        else
            St.menuGuiLocked = on == true
            St.guiLock = St.menuGuiLocked
            _G._AceGuiLocked = St.menuGuiLocked
            pcall(saveCfg)
        end
    end,5)
    _G._12HubMenuLockUiToggle = lockUiToggle2
    -- Restore the same state to the toggle without firing its callback.
    if lockUiToggle2 and lockUiToggle2.set then pcall(lockUiToggle2.set, St.menuGuiLocked == true) end
    if _G.RanaVSSetUILocked then pcall(_G.RanaVSSetUILocked, St.menuGuiLocked == true) end

    section2(setPage,"STEAL BAR",6)
    addToggle2(setPage,"Show Steal Bar",St.stealBarVisible~=false,function(on)
        St.stealBarVisible=on
        if _G.StealBar then pcall(function() _G.StealBar.Show(on) end) end
        pcall(saveCfg)
    end,6.1)
    local sbScaleRow=baseRow2(setPage,"Steal Bar Size",6.2,42)
    local sbVal=Instance.new("TextLabel",sbScaleRow)
    sbVal.Size=UDim2.fromOffset(54,30); sbVal.Position=UDim2.new(1,-64,0,6); sbVal.BackgroundTransparency=1
    sbVal.Text=tostring(math.floor((tonumber(St.stealBarScale) or 1)*100)).."%"; sbVal.Font=Enum.Font.GothamBlack; sbVal.TextSize=10; sbVal.TextColor3=LPColors.white
    local sbMinus=Instance.new("TextButton",sbScaleRow); sbMinus.Size=UDim2.fromOffset(30,30); sbMinus.Position=UDim2.new(1,-154,0,6); sbMinus.Text="−"; sbMinus.Font=Enum.Font.GothamBlack; sbMinus.TextSize=15; sbMinus.TextColor3=LPColors.white; sbMinus.BackgroundColor3=Color3.fromRGB(18,21,26); sbMinus.AutoButtonColor=false; lCorner(sbMinus,6); lStroke(sbMinus,LPColors.soft,1,0.25)
    local sbPlus=Instance.new("TextButton",sbScaleRow); sbPlus.Size=UDim2.fromOffset(30,30); sbPlus.Position=UDim2.new(1,-116,0,6); sbPlus.Text="+"; sbPlus.Font=Enum.Font.GothamBlack; sbPlus.TextSize=15; sbPlus.TextColor3=LPColors.white; sbPlus.BackgroundColor3=Color3.fromRGB(18,21,26); sbPlus.AutoButtonColor=false; lCorner(sbPlus,6); lStroke(sbPlus,LPColors.soft,1,0.25)
    local function changeSBScale(delta)
        local n=math.clamp((tonumber(St.stealBarScale) or 1)+delta,0.5,1.5)
        St.stealBarScale=math.floor(n*10+0.5)/10
        sbVal.Text=tostring(math.floor(St.stealBarScale*100)).."%"
        if _G.RanaVSSetStealBarScale then pcall(function() _G.RanaVSSetStealBarScale(St.stealBarScale) end) end
        pcall(saveCfg)
    end
    sbMinus.Activated:Connect(function() changeSBScale(-0.1) end)
    sbPlus.Activated:Connect(function() changeSBScale(0.1) end)

    section2(setPage,"BUTTON SHAPE",7)
    local shapeRow=Instance.new("Frame",setPage)
    shapeRow.Name="ButtonShape"
    shapeRow.Size=UDim2.new(1,-4,0,42)
    shapeRow.BackgroundTransparency=1
    shapeRow.LayoutOrder=8
    local shapeBtns={}
    for i,name in ipairs({"FOUNDED","CIRCLE","SQUARE"}) do
        local textName = name=="FOUNDED" and "Founded" or (name=="CIRCLE" and "Circle" or "Square")
        local b=Instance.new("TextButton",shapeRow)
        b.Size=UDim2.fromOffset(92,30)
        b.Position=UDim2.fromOffset(4+(i-1)*98,6)
        b.Text=textName
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamBlack
        local shapeSelected=(St.btnShape==name)
        b.BackgroundColor3=shapeSelected and LPColors.accent or Color3.fromRGB(18,21,26)
        b.TextColor3=shapeSelected and Color3.fromRGB(255,255,255) or Color3.fromRGB(138,142,148)
        lCorner(b, 6)
        lStroke(b, shapeSelected and LPColors.accent2 or Color3.fromRGB(48,55,65), 1.2, shapeSelected and 0.02 or 0.30)
        setAceModeVisual(b, shapeSelected, "LPStroke")
        shapeBtns[name]=b
        local function pick()
            St.btnShape=name
            if _G.RanaVSApplyLaPeakShape then pcall(_G.RanaVSApplyLaPeakShape,name) end
            for n,x in pairs(shapeBtns) do
                setAceModeVisual(x, n == St.btnShape, "LPStroke")
                lCorner(x, 6)
            end
            pcall(saveCfg)
        end
        b.Activated:Connect(pick)
    end

    section2(setPage,"8 MOBILE BUTTON SIZE",10)
    local mobileSizeRows = {
        {"drop","Drop"}, {"insta","Insta Reset"}, {"tp","TP Down"}, {"tpBest","TP Best"},
        {"sentry","Destroy"}, {"steal","Auto Steal"}, {"med","Med"}, {"ps","PS"},
        {"antiTrap","Anti Trap"}, {"websinger","Websinger / Kill"},
    }
    for i,pair in ipairs(mobileSizeRows) do
        local key,labelText=pair[1],pair[2]
        local r=baseRow2(setPage,"Size "..labelText,10+i,34)
        local val=Instance.new("TextBox",r)
        val.Size=UDim2.fromOffset(44,27)
        val.Position=UDim2.new(1,-112,0.5,-14)
        val.BackgroundColor3=LPColors.row2
        val.TextColor3=LPColors.white
        val.Font=Enum.Font.GothamBlack
        val.TextSize=11
        val.TextXAlignment=Enum.TextXAlignment.Center
        val.ClearTextOnFocus=false
        val.TextEditable=true
        val.MultiLine=false
        val.PlaceholderText="70"
        val.Text=tostring((St.btnSizes and St.btnSizes[key]) or 70)
        lCorner(val,7); lStroke(val,LPColors.soft,1,0.42)
        local minus=Instance.new("TextButton",r)
        local plus=Instance.new("TextButton",r)
        for _,b in ipairs({minus,plus}) do
            b.Size=UDim2.fromOffset(27,27)
            b.BackgroundColor3=LPColors.row2
            b.TextColor3=LPColors.white
            b.Font=Enum.Font.GothamBlack
            b.TextSize=14
            b.AutoButtonColor=false
            lCorner(b,7); lStroke(b,LPColors.soft,1,0.42)
        end
        minus.Position=UDim2.new(1,-66,0.5,-14); minus.Text="-"
        plus.Position=UDim2.new(1,-35,0.5,-14); plus.Text="+"
        local function getCurrent()
            St.btnSizes=St.btnSizes or {}
            return math.clamp(math.floor(tonumber(St.btnSizes[key]) or 70),20,200)
        end
        local function refreshValue()
            val.Text=tostring(getCurrent())
        end
        local function change(delta)
            local nextValue=math.clamp(getCurrent()+delta,20,200)
            St.btnSizes[key]=nextValue
            val.Text=tostring(nextValue)
            if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
            pcall(saveCfg)
        end
        local function commitTypedValue()
            local n=tonumber(val.Text)
            if n then
                n=math.clamp(math.floor(n),20,200)
                St.btnSizes[key]=n
            end
            refreshValue()
            if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
            pcall(saveCfg)
        end
        val.Focused:Connect(function()
            val.Text=""
        end)
        val.FocusLost:Connect(function()
            commitTypedValue()
        end)
        minus.Activated:Connect(function() change(-5) end)
        plus.Activated:Connect(function() change(5) end)
    end

    section2(setPage,"MENU SIZE",25)
    do
        local r=baseRow2(setPage,"Menu Size",26,58)
        local val=Instance.new("TextLabel",r)
        val.Name="MenuSizeValue"
        val.Size=UDim2.fromOffset(42,22)
        val.Position=UDim2.new(1,-126,0,3)
        val.BackgroundTransparency=1
        val.Text=tostring(math.floor((St.menuScale or 0.7)*100)).."%"
        val.TextColor3=LPColors.white; val.Font=Enum.Font.GothamBlack; val.TextSize=11
        val.TextXAlignment=Enum.TextXAlignment.Center
        val.ZIndex=9

        local minus=Instance.new("TextButton",r); local plus=Instance.new("TextButton",r)
        for _,b in ipairs({minus,plus}) do
            b.Size=UDim2.fromOffset(24,22); b.BackgroundColor3=LPColors.row2
            b.TextColor3=LPColors.white; b.Font=Enum.Font.GothamBlack; b.TextSize=14; b.AutoButtonColor=false
            b.ZIndex=10
            lCorner(b,6); lStroke(b,LPColors.soft,1,0.42)
        end
        minus.Position=UDim2.new(1,-80,0,3); minus.Text="−"
        plus.Position=UDim2.new(1,-51,0,3); plus.Text="+"

        local sizeTrack=Instance.new("Frame",r)
        sizeTrack.Name="MenuSizeTrack"
        sizeTrack.Position=UDim2.new(0,12,1,-12)
        sizeTrack.Size=UDim2.new(1,-24,0,4)
        sizeTrack.BackgroundColor3=Color3.fromRGB(22,25,30)
        sizeTrack.BorderSizePixel=0
        sizeTrack.ZIndex=8
        sizeTrack.Active=true
        lCorner(sizeTrack,4)
        local sizeFill=Instance.new("Frame",sizeTrack)
        sizeFill.Name="MenuSizeFill"
        sizeFill.Size=UDim2.new(0.2,0,1,0)
        sizeFill.BackgroundColor3=Color3.fromRGB(78,119,151)
        sizeFill.BorderSizePixel=0
        sizeFill.ZIndex=9
        lCorner(sizeFill,4)
        local sizeKnob=Instance.new("Frame",sizeTrack)
        sizeKnob.Name="MenuSizeKnob"
        sizeKnob.Size=UDim2.fromOffset(12,12)
        sizeKnob.Position=UDim2.new(0.2,-6,0.5,-6)
        sizeKnob.BackgroundColor3=Color3.fromRGB(238,242,247)
        sizeKnob.BorderSizePixel=0
        sizeKnob.Active=true
        sizeKnob.ZIndex=11
        lCorner(sizeKnob,6)
        lStroke(sizeKnob,Color3.fromRGB(78,119,151),1,0.12)

        local scaleDragging2=false
        local scaleDragInput2=nil
        local scaleDragType2=nil
        local function paintScaleControls2()
            local value2=math.clamp(tonumber(St.menuScale) or 0.7,0.5,1.5)
            local alpha2=math.clamp(value2-0.5,0,1)
            menuScale.Scale=aceMainScale2(value2)
            val.Text=tostring(math.floor(value2*100+0.5)).."%"
            sizeFill.Size=UDim2.new(alpha2,0,1,0)
            sizeKnob.Position=UDim2.new(alpha2,-6,0.5,-6)
        end
        local function setScale2(value2, saveNow2)
            St.menuScale=math.clamp(tonumber(value2) or 0.7,0.5,1.5)
            paintScaleControls2()
            if saveNow2 then pcall(saveCfg) end
        end
        local function updateScaleFromInput2(inp2)
            local trackWidth2=math.max(sizeTrack.AbsoluteSize.X,1)
            local alpha2=math.clamp((inp2.Position.X-sizeTrack.AbsolutePosition.X)/trackWidth2,0,1)
            setScale2(0.5+alpha2,false)
        end
        local function startScaleDrag2(inp2)
            if inp2.UserInputType~=Enum.UserInputType.MouseButton1 and inp2.UserInputType~=Enum.UserInputType.Touch then return end
            scaleDragging2=true
            scaleDragType2=inp2.UserInputType
            scaleDragInput2=inp2
            updateScaleFromInput2(inp2)
        end
        sizeTrack.InputBegan:Connect(startScaleDrag2)
        sizeKnob.InputBegan:Connect(startScaleDrag2)
        UIS.InputChanged:Connect(function(inp2)
            if not scaleDragging2 then return end
            local isMouseMove2=scaleDragType2==Enum.UserInputType.MouseButton1 and inp2.UserInputType==Enum.UserInputType.MouseMovement
            local isTouchMove2=scaleDragType2==Enum.UserInputType.Touch and inp2.UserInputType==Enum.UserInputType.Touch
            if isMouseMove2 or isTouchMove2 then updateScaleFromInput2(inp2) end
        end)
        UIS.InputEnded:Connect(function(inp2)
            if not scaleDragging2 then return end
            local endMouse2=scaleDragType2==Enum.UserInputType.MouseButton1 and inp2.UserInputType==Enum.UserInputType.MouseButton1
            local endTouch2=scaleDragType2==Enum.UserInputType.Touch and inp2.UserInputType==Enum.UserInputType.Touch
            if endMouse2 or endTouch2 then
                scaleDragging2=false
                scaleDragInput2=nil
                scaleDragType2=nil
                pcall(saveCfg)
            end
        end)
        local function change(delta2)
            setScale2((tonumber(St.menuScale) or 0.7)+delta2,true)
        end
        minus.Activated:Connect(function() change(-0.1) end)
        plus.Activated:Connect(function() change(0.1) end)
        paintScaleControls2()
    end
    -- Main menu wallpaper selector: updates the actual Ace-style main window.
    section2(setPage, "MAIN MENU WALLPAPER", 27)
    local wallpaperRow = Instance.new("Frame", setPage)
    wallpaperRow.Name = "MainMenuWallpaperControl"
    wallpaperRow.Size = UDim2.new(1, -4, 0, 48)
    wallpaperRow.LayoutOrder = 27.1
    wallpaperRow.BackgroundColor3 = Color3.fromRGB(13,16,20)
    wallpaperRow.BackgroundTransparency = 0.04
    wallpaperRow.BorderSizePixel = 0
    wallpaperRow.ZIndex = 5
    lCorner(wallpaperRow, 8)
    lStroke(wallpaperRow, Color3.fromRGB(48,55,65), 1.05, 0.22)
    local wallPreview = Instance.new("ImageLabel", wallpaperRow)
    wallPreview.Name = "MainMenuWallpaperPreview"
    wallPreview.Size = UDim2.fromOffset(54, 36)
    wallPreview.Position = UDim2.fromOffset(6, 6)
    wallPreview.BackgroundColor3 = Color3.fromRGB(18,21,26)
    wallPreview.BorderSizePixel = 0
    wallPreview.ZIndex = 6
    wallPreview.ScaleType = Enum.ScaleType.Crop
    wallPreview.Image = setMainWallpaper2(St.mainMenuWallIndex)
    lCorner(wallPreview, 6)
    lStroke(wallPreview, Color3.fromRGB(48,55,65), 1, 0.2)
    local wallLabel = Instance.new("TextLabel", wallpaperRow)
    wallLabel.Name = "WallpaperIndex"
    wallLabel.BackgroundTransparency = 1
    wallLabel.Size = UDim2.new(1, -152, 1, 0)
    wallLabel.Position = UDim2.fromOffset(68, 0)
    wallLabel.ZIndex = 7
    wallLabel.TextColor3 = LPColors.white
    wallLabel.Font = Enum.Font.GothamBold
    wallLabel.TextSize = 10
    wallLabel.TextXAlignment = Enum.TextXAlignment.Left
    local function refreshWallpaperControls()
        local n = #mainWallpapers2
        local idx = math.clamp(math.floor(tonumber(St.mainMenuWallIndex) or 1), 1, n)
        St.mainMenuWallIndex = idx
        wallPreview.Image = setMainWallpaper2(idx)
        wallLabel.Text = string.format("WALLPAPER  %02d / %02d", idx, n)
    end
    local function stepWallpaper(delta)
        local n = #mainWallpapers2
        St.mainMenuWallIndex = (((math.floor(tonumber(St.mainMenuWallIndex) or 1) - 1 + delta) % n) + 1)
        refreshWallpaperControls()
        pcall(saveCfg)
    end
    local function makeWallpaperStepButton(name, caption, xPos, callback)
        local b = Instance.new("TextButton", wallpaperRow)
        b.Name = name
        b.Size = UDim2.fromOffset(28, 28)
        b.Position = UDim2.new(1, xPos, 0.5, -14)
        b.BackgroundColor3 = Color3.fromRGB(22,25,30)
        b.BorderSizePixel = 0
        b.Text = caption
        b.TextColor3 = LPColors.white
        b.TextSize = 16
        b.Font = Enum.Font.GothamBlack
        b.AutoButtonColor = false
        b.ZIndex = 20
        lCorner(b, 6)
        lStroke(b, LPColors.soft, 1, 0.22)
        b.Activated:Connect(callback)
        b.MouseEnter:Connect(function()
            lTween(b, {BackgroundColor3 = Color3.fromRGB(22,25,30)}, 0.08)
        end)
        b.MouseLeave:Connect(function()
            lTween(b, {BackgroundColor3 = Color3.fromRGB(22,25,30)}, 0.08)
        end)
        return b
    end
    makeWallpaperStepButton("PreviousWallpaper", "‹", -66, function() stepWallpaper(-1) end)
    makeWallpaperStepButton("NextWallpaper", "›", -34, function() stepWallpaper(1) end)
    refreshWallpaperControls()

    addButton2(setPage,"Reset Mobile Positions",function()
        if _G.RanaVSResetMobilePos then pcall(_G.RanaVSResetMobilePos) end
        pcall(saveCfg)
    end,28)
    addButton2(setPage,"Save Now",function() pcall(saveCfg) end,29)

    end -- close preceding tab scope
    do -- isolate Keybinds tab locals
    -- ---------------- KEYBINDS ----------------
    local kbPage=pages2.KEYBINDS
    section2(kbPage,"PC KEYBINDS",1)

    -- Shared keybind-row builder; X and Backspace/Delete explicitly persist None.
    local function addKeybindRow2(parent,labelText,keyName,isSpeed,order)
        local row=baseRow2(parent,labelText,order,36)
        local bind=Instance.new("TextButton",row)
        bind.Name="KeybindButton"
        bind.Size=UDim2.fromOffset(62,26)
        bind.Position=UDim2.new(1,-96,0.5,-13)
        bind.BackgroundColor3=LPColors.row2
        bind.TextColor3=LPColors.white
        bind.TextSize=9
        bind.Font=Enum.Font.GothamBlack
        bind.AutoButtonColor=false
        lCorner(bind,7); lStroke(bind,LPColors.soft,1,0.42)

        local clear=Instance.new("TextButton",row)
        clear.Name="ClearKeybind"
        clear.Size=UDim2.fromOffset(20,20)
        clear.Position=UDim2.new(1,-27,0.5,-10)
        clear.BackgroundColor3=Color3.fromRGB(22,25,30)
        clear.Text="x"
        clear.TextColor3=Color3.fromRGB(238,238,238)
        clear.TextSize=11
        clear.Font=Enum.Font.GothamBlack
        clear.AutoButtonColor=false
        lCorner(clear,6); lStroke(clear,LPColors.soft,1,0.45)

        local captureConnection=nil
        local waitingForKey=false
        local function keyTable()
            return isSpeed and St.speedKeys or St.keys
        end
        local function refreshKeyText()
            local key=keyTable() and keyTable()[keyName]
            bind.Text=(typeof(key)=="EnumItem" and key.Name) or "None"
        end
        local function stopCapture()
            waitingForKey=false
            if captureConnection then
                pcall(function() captureConnection:Disconnect() end)
                captureConnection=nil
            end
            _G.RanaVSKeybindingCapture=false
            if _G.RanaVSStopKeybindCapture==stopCapture then
                _G.RanaVSStopKeybindCapture=nil
            end
            refreshKeyText()
        end
        local function listenForKey()
            if _G.RanaVSStopKeybindCapture then
                pcall(_G.RanaVSStopKeybindCapture)
            end
            waitingForKey=true
            _G.RanaVSKeybindingCapture=true
            _G.RanaVSStopKeybindCapture=stopCapture
            bind.Text="..."
            captureConnection=UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                if inp.KeyCode==Enum.KeyCode.Escape then
                    stopCapture()
                    return
                end
                if inp.KeyCode==Enum.KeyCode.Backspace or inp.KeyCode==Enum.KeyCode.Delete then
                    keyTable()[keyName]="None"
                else
                    keyTable()[keyName]=inp.KeyCode
                end
                stopCapture()
                pcall(saveCfg)
            end)
        end
        bind.Activated:Connect(function()
            if waitingForKey then
                stopCapture()
            else
                listenForKey()
            end
        end)
        clear.Activated:Connect(function()
            if _G.RanaVSStopKeybindCapture then
                pcall(_G.RanaVSStopKeybindCapture)
            end
            keyTable()[keyName]="None"
            refreshKeyText()
            pcall(saveCfg)
        end)
        refreshKeyText()
        return row
    end

    local kbDefs={{"Drop","Drop"},{"TP Down","TPDown"},{"Insta Reset","InstaReset"},{"Destroy","DestroySentry"},{"Auto Steal","AutoSteal"}}
    for i,def in ipairs(kbDefs) do
        addKeybindRow2(kbPage,def[1],def[2],false,i+1)
    end

    section2(kbPage,"SPEED 3-MODE HOTKEYS",8)
    for i,modeName in ipairs({"Normal","Lagger","Custom"}) do
        addKeybindRow2(kbPage,modeName,modeName,true,i+8)
    end

    section2(kbPage,"EXTERNAL BUTTON KEYBINDS",12)
    addKeybindRow2(kbPage,"Anti Trap","AntiTrap",false,13)
    addKeybindRow2(kbPage,"Med Equip","MedEquip",false,14)
    addKeybindRow2(kbPage,"TP Best","TpBest",false,15)
    -- Websinger's PC hotkey is independently configurable/clearable.
    addKeybindRow2(kbPage,"Websinger / Kill","Websinger",false,16)

    end -- close Keybinds tab scope
    -- Ace-style minimize/restore and keyboard toggle behavior.
    local mini=Instance.new("TextButton",Gui2)
    mini.Name="MiniFrame"
    mini.Size=UDim2.fromOffset(112,34)
    mini.Position=UDim2.new(0,14,0.48,-17)
    mini.BackgroundColor3=Color3.fromRGB(13,16,20)
    mini.BackgroundTransparency=0.08
    mini.Text="monster.vs🍀"
    mini.TextColor3=LPColors.white
    mini.TextSize=11
    mini.Font=Enum.Font.GothamBlack
    mini.AutoButtonColor=false
    mini.Visible=false
    mini.ZIndex=30
    mini.Active = true
    lCorner(mini,16)
    lStroke(mini,LPColors.stroke,1.0,0.25)
    do
        local savedMini2 = St._miniPos
        if type(savedMini2) == "table" and #savedMini2 >= 4 then
            mini.Position = UDim2.new(tonumber(savedMini2[1]) or 0, tonumber(savedMini2[2]) or 14,
                tonumber(savedMini2[3]) or 0.48, tonumber(savedMini2[4]) or -17)
        end
    end

    local menuAnimating2 = false
    local function saveMainPosition2()
        if not Main2 or not Main2.Parent then return end
        St._mainPos = {Main2.Position.X.Scale, Main2.Position.X.Offset, Main2.Position.Y.Scale, Main2.Position.Y.Offset}
        pcall(saveCfg)
    end
    local function expandedMenuSize2()
        if St.uiLayout == "LEFT" or St.uiLayout == "RIGHT" then
            return 420, 528
        end
        return 348, 540
    end
    local function closeMenu2()
        if menuAnimating2 or not Main2.Visible then return end
        menuAnimating2 = true
        saveMainPosition2()
        St.menuOpen = false
        local width2 = expandedMenuSize2()
        local currentWidth2 = Main2.Size.X.Offset > 0 and Main2.Size.X.Offset or width2
        mini.Visible = true
        mini.BackgroundTransparency = 1
        mini.TextTransparency = 1
        lTween(mini, {BackgroundTransparency = 0.08, TextTransparency = 0}, 0.18)
        local collapse2 = TS:Create(Main2, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(currentWidth2, 0)
        })
        collapse2:Play()
        collapse2.Completed:Connect(function()
            if St.menuOpen == false and Main2.Parent then
                Main2.Visible = false
                Main2.Size = UDim2.fromOffset(currentWidth2, 0)
            end
            menuAnimating2 = false
            pcall(saveCfg)
        end)
    end
    local function openMenu2()
        if menuAnimating2 then return end
        if Main2.Visible and Main2.Size.Y.Offset > 0 then
            St.menuOpen = true
            mini.Visible = false
            return
        end
        menuAnimating2 = true
        saveMainPosition2()
        -- Ace-style back-eased vertical expansion from the compact state.
        Main2.AnchorPoint = Vector2.new(0, 0)
        local width2, height2 = expandedMenuSize2()
        Main2.Size = UDim2.fromOffset(width2, 0)
        Main2.Visible = true
        mini.Visible = false
        St.menuOpen = true
        local expand2 = TS:Create(Main2, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(width2, height2)
        })
        expand2:Play()
        expand2.Completed:Connect(function()
            menuAnimating2 = false
            pcall(saveCfg)
        end)
    end
    close.Activated:Connect(closeMenu2)

    local miniPressInput2, miniPressStart2, miniStartPos2
    local miniMoved2 = false
    local miniIgnoreClickUntil2 = 0
    mini.InputBegan:Connect(function(inp)
        if St.menuGuiLocked == true then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            miniPressInput2 = inp
            miniPressStart2 = inp.Position
            miniStartPos2 = mini.Position
            miniMoved2 = false
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not miniPressInput2 then return end
        local matching = false
        if miniPressInput2.UserInputType == Enum.UserInputType.Touch then
            matching = inp == miniPressInput2
        elseif miniPressInput2.UserInputType == Enum.UserInputType.MouseButton1 then
            matching = inp.UserInputType == Enum.UserInputType.MouseMovement
        end
        if matching and St.menuGuiLocked ~= true then
            local delta = inp.Position - miniPressStart2
            if math.abs(delta.X) >= 4 or math.abs(delta.Y) >= 4 then miniMoved2 = true end
            if miniMoved2 then
                mini.Position = UDim2.new(miniStartPos2.X.Scale, miniStartPos2.X.Offset + delta.X,
                    miniStartPos2.Y.Scale, miniStartPos2.Y.Offset + delta.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if not miniPressInput2 then return end
        local matching = (miniPressInput2.UserInputType == Enum.UserInputType.Touch and inp == miniPressInput2)
            or (miniPressInput2.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseButton1)
        if not matching then return end
        if miniMoved2 and St.menuGuiLocked ~= true then
            St._miniPos = {mini.Position.X.Scale, mini.Position.X.Offset, mini.Position.Y.Scale, mini.Position.Y.Offset}
            miniIgnoreClickUntil2 = os.clock() + 0.30
            pcall(saveCfg)
        end
        miniPressInput2, miniPressStart2, miniStartPos2 = nil, nil, nil
        miniMoved2 = false
    end)
    mini.Activated:Connect(function()
        if os.clock() < miniIgnoreClickUntil2 then return end
        openMenu2()
    end)

    -- Ace's default window toggle key. Avoid toggling while typing into a TextBox.
    do
        local aceToggleKey2 = Enum.KeyCode.RightShift
        if _G.__12HubAceToggleConn then
            pcall(function() _G.__12HubAceToggleConn:Disconnect() end)
        end
        _G.__12HubAceToggleConn = UIS.InputBegan:Connect(function(input2, processed2)
            if processed2 or input2.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if UIS:GetFocusedTextBox() then return end
            if input2.KeyCode == aceToggleKey2 then
                if Main2.Visible then closeMenu2() else openMenu2() end
            end
        end)
        _G["12HubSetMainMenuToggleKey"] = function(key2)
            if typeof(key2) == "EnumItem" and key2.EnumType == Enum.KeyCode then
                aceToggleKey2 = key2
                return true
            end
            return false
        end
        _G["12HubGetMainMenuToggleKey"] = function() return aceToggleKey2 end
    end

    -- 12Hub authoritative open/close entry points.
    _G["12HubOpenMainMenu"] = openMenu2
    _G["12HubCloseMainMenu"] = closeMenu2
    _G["12HubToggleMainMenu"] = function()
        if Main2.Visible then
            closeMenu2()
        else
            openMenu2()
        end
    end
    Gui2.Enabled = true
    Main2.Active = true
    mini.Active = true

    -- Keep the menu/mini reliably available after character reset/respawn.
    if _G.__12HubMenuRespawnConn then
        pcall(function() _G.__12HubMenuRespawnConn:Disconnect() end)
        _G.__12HubMenuRespawnConn = nil
    end
    _G.__12HubMenuRespawnConn = LP.CharacterAdded:Connect(function()
        task.delay(0.45, function()
            pcall(function()
                if not Gui2.Parent then
                    Gui2.Parent = PlayerGui
                end
                Gui2.Enabled = true
                if St.menuOpen == false then
                    Main2.Visible = false
                    mini.Visible = true
                else
                    Main2.Visible = true
                    mini.Visible = false
                    St.menuOpen = true
                end
            end)
        end)
    end)

    -- Ace-style drag behavior: start from the real header (plus its transparent/text surfaces),
    -- ignore the three clickable header controls, drag with mouse/touch, and persist _mainPos.
    -- The main window is intentionally draggable while LOCKED and UNLOCKED.
    do
        local ContextActionService2 = (UIS.TouchEnabled and not UIS.KeyboardEnabled) and game:GetService("ContextActionService") or nil
        local dragActionName2 = "12HubAceMainDrag_" .. tostring(LP.UserId)
        local dragging2, moved2 = false, false
        local dragStart2, startPos2, touchInput2, dragInputType2
        local function unbindTouchDrag2()
            if ContextActionService2 then
                pcall(function() ContextActionService2:UnbindAction(dragActionName2) end)
            end
        end
        local function bindTouchDrag2()
            if not ContextActionService2 then return end
            unbindTouchDrag2()
            pcall(function()
                ContextActionService2:BindActionAtPriority(dragActionName2, function(_, state2, input2)
                    if dragging2 and input2 == touchInput2 and state2 == Enum.UserInputState.Change then
                        return Enum.ContextActionResult.Sink
                    end
                    return Enum.ContextActionResult.Pass
                end, false, 10001, Enum.UserInputType.Touch)
            end)
        end
        local function insideObject2(obj2, point2)
            if not obj2 or not obj2.Parent then return false end
            local p2, sz2 = obj2.AbsolutePosition, obj2.AbsoluteSize
            return point2.X >= p2.X and point2.X <= p2.X + sz2.X
                and point2.Y >= p2.Y and point2.Y <= p2.Y + sz2.Y
        end
        local function sameTouch2(input2, original2)
            if not original2 or input2.UserInputType ~= Enum.UserInputType.Touch then return false end
            if input2 == original2 then return true end
            local okA2, idA2 = pcall(function() return input2.TouchId end)
            local okB2, idB2 = pcall(function() return original2.TouchId end)
            return okA2 and okB2 and idA2 ~= nil and idA2 == idB2
        end
        local function beginMainDrag2(inp2)
            if not Main2.Visible then return end
            if inp2.UserInputType ~= Enum.UserInputType.MouseButton1 and inp2.UserInputType ~= Enum.UserInputType.Touch then return end
            -- Do not turn a tap on Lock/UI/Minimize into a window drag.
            local point2 = inp2.Position
            if insideObject2(lockBtn2, point2) or insideObject2(layoutBtn2, point2) or insideObject2(close, point2) then return end
            if dragging2 then return end
            dragging2 = true
            moved2 = false
            dragStart2 = point2
            startPos2 = Main2.Position
            dragInputType2 = inp2.UserInputType
            touchInput2 = inp2.UserInputType == Enum.UserInputType.Touch and inp2 or nil
            if touchInput2 then bindTouchDrag2() end
        end
        Header.InputBegan:Connect(beginMainDrag2)
        HeaderDragSurface.InputBegan:Connect(beginMainDrag2)
        title.InputBegan:Connect(beginMainDrag2)
        subtitle.InputBegan:Connect(beginMainDrag2)
        UIS.InputChanged:Connect(function(inp2)
            if not dragging2 or not dragStart2 or not startPos2 then return end
            local isMouseMove2 = dragInputType2 == Enum.UserInputType.MouseButton1 and inp2.UserInputType == Enum.UserInputType.MouseMovement
            local isTouchMove2 = touchInput2 ~= nil and sameTouch2(inp2, touchInput2)
            if isMouseMove2 or isTouchMove2 then
                local delta2 = inp2.Position - dragStart2
                if math.abs(delta2.X) >= 4 or math.abs(delta2.Y) >= 4 then moved2 = true end
                if moved2 then
                    Main2.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + delta2.X,
                        startPos2.Y.Scale, startPos2.Y.Offset + delta2.Y)
                end
            end
        end)
        UIS.InputEnded:Connect(function(inp2)
            local isMouseEnd2 = dragInputType2 == Enum.UserInputType.MouseButton1 and inp2.UserInputType == Enum.UserInputType.MouseButton1
            local isTouchEnd2 = touchInput2 ~= nil and sameTouch2(inp2, touchInput2)
            if not (isMouseEnd2 or isTouchEnd2) then return end
            if dragging2 and moved2 then saveMainPosition2() end
            dragging2, moved2 = false, false
            dragStart2, startPos2, touchInput2, dragInputType2 = nil, nil, nil, nil
            unbindTouchDrag2()
        end)
        Gui2.AncestryChanged:Connect(function(_, parent2)
            if not parent2 then
                dragging2, moved2 = false, false
                dragStart2, startPos2, touchInput2, dragInputType2 = nil, nil, nil, nil
                unbindTouchDrag2()
            end
        end)
    end

    -- LaPeak idle fade: PC only, full menu returns on interaction.
    do
        local IDLE=5
        local fadeState=false
        local activityToken=0
        local baseAlpha=setmetatable({}, {__mode="k"})
        local watched={Content2,Tabs2,Header,close}
        local function remember(o)
            if not o or baseAlpha[o] then return end
            local d={}
            pcall(function()
                if o:IsA("GuiObject") then d.bg=o.BackgroundTransparency end
                if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then d.text=o.TextTransparency end
                if o:IsA("UIStroke") then d.stroke=o.Transparency end
            end)
            baseAlpha[o]=d
        end
        local function setFade(on)
            fadeState=on
            for _,root in ipairs(watched) do
                remember(root)
                for _,d in ipairs(root:GetDescendants()) do remember(d) end
            end
            for o,d in pairs(baseAlpha) do
                if o and o.Parent and d then
                    local p={}
                    if d.bg~=nil then p.BackgroundTransparency=on and math.max(d.bg,0.78) or d.bg end
                    if d.text~=nil then p.TextTransparency=on and math.max(d.text,0.60) or d.text end
                    if d.stroke~=nil then p.Transparency=on and math.max(d.stroke,0.74) or d.stroke end
                    if next(p) then lTween(o,p,0.40) end
                end
            end
        end
        local function touch()
            activityToken += 1
            local token=activityToken
            if fadeState then setFade(false) end
            task.delay(IDLE,function()
                if token==activityToken and Main2.Visible and not St.guiLock then
                    setFade(true)
                end
            end)
        end
        for _,root in ipairs({Main2}) do
            root.InputBegan:Connect(touch)
            root.InputChanged:Connect(touch)
        end
        UIS.InputBegan:Connect(function(inp)
            if Main2.Visible and (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.Keyboard) then
                touch()
            end
        end)
        touch()
    end

    -- Remove legacy menu images but keep the requested 12Hub wallpaper.
    for _,d in ipairs(Main2:GetDescendants()) do
        if (d:IsA("ImageLabel") or d:IsA("ImageButton"))
            and d.Name ~= "MainMenuBackground"
            and d.Name ~= "MainMenuWallpaperPreview"
            and d.Name ~= "PlayerAvatar2" then
            pcall(function() d:Destroy() end)
        end
    end

    selectedStealMode=(tostring(selectedStealMode or "Normal")=="Semi") and "Semi" or "Normal"
    autoStealV2Version=(tostring(autoStealV2Version or "V2")=="V1") and "V1" or "V2"
    St.stealVer=selectedStealMode.."-"..autoStealV2Version
    -- Restore saved placement; when unset, use the same left/centered-Y default as Ace.
    Main2.AnchorPoint = Vector2.new(0, 0)
    do
        local savedPos2 = St._mainPos
        if type(savedPos2) == "table" and #savedPos2 >= 4 then
            Main2.Position = UDim2.new(tonumber(savedPos2[1]) or 0, tonumber(savedPos2[2]) or 22,
                tonumber(savedPos2[3]) or 0.5, tonumber(savedPos2[4]) or -270)
        else
            local cam2 = workspace.CurrentCamera
            local view2 = (cam2 and cam2.ViewportSize) or Vector2.new(1280, 720)
            local touch2 = UIS.TouchEnabled and not UIS.KeyboardEnabled
            local phone2 = touch2 and math.min(view2.X, view2.Y) < 600
            local x2 = phone2 and 8 or 22
            local scale2 = aceMainScale2(St.menuScale)
            local y2 = phone2 and (-270 * scale2) or -270
            Main2.Position = UDim2.new(0, x2, 0.5, y2)
        end
    end
    Gui2.Enabled = true
    if St.menuOpen == false then
        Main2.Visible=false
        mini.Visible=true
    else
        Main2.Visible=true
        mini.Visible=false
        St.menuOpen=true
    end
    setTab2("SPEED", false)
    pcall(function()
        if _G.RanaVSApplyLaPeakShape then _G.RanaVSApplyLaPeakShape(St.btnShape or "FOUNDED") end
    end)
    pcall(function()
        if _G.RanaVSBuildV2ModeBar then _G.RanaVSBuildV2ModeBar() end
    end)
    pcall(function() if _G.StealBar then _G.StealBar.Show(St.stealBarVisible ~= false) end end)

    _G.RanaVSLaPeakHybridMain = Main2
    _G.RanaVSLaPeakHybridGui = Gui2
    _G.RanaVSLaPeakHybridPages = pages2
end
-- ============================================================================
-- ============================================================================
-- 12HUB FINAL AUTO STEAL STATE REPAIR
-- Uses only the four embedded LaPeak/Ambitious engines.
-- ============================================================================
do
    local pages = _G.RanaVSLaPeakHybridPages or {}
    local playerPage = pages.PLAYER

    local persisted = tostring(St.stealVer or "Normal-V2")
    local mode, version = persisted:match("^(Normal|Semi)%-(V[12])$")
    mode = mode or "Normal"
    version = version or "V2"

    selectedStealMode = mode
    autoStealV2Version = version
    if mode == "Normal" then
        selectedNormalMode = version
    else
        selectedSemiMode = version
    end
    St.stealVer = mode .. "-" .. version
    autoStealEnabled = St.autoSteal == true
    _G.autoStealEnabled = autoStealEnabled

    _G.RanaVSSelectAutoSteal = function(newMode, newVersion)
        _12HubNormalizeStealSelection(newMode, newVersion)
        _12HubSyncAutoSteal()
        pcall(function() if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end end)
        pcall(saveCfg)
    end

    setAutoSteal = function(on)
        St.autoSteal = on and true or false
        autoStealEnabled = St.autoSteal
        _G.autoStealEnabled = autoStealEnabled
        _12HubSyncAutoSteal()
        pcall(function()
            if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
                ToggleRefs.autoSteal.setVisual(St.autoSteal)
            end
        end)
        pcall(function() if _G.RanaVSRefreshStealBtn then _G.RanaVSRefreshStealBtn() end end)
        pcall(saveCfg)
    end
    _G.setAutoSteal = setAutoSteal
    _G.RanaVSSyncAutoSteal = _12HubSyncAutoSteal

    if playerPage then
        pcall(function()
            if _G.RanaVSRefreshAutoStealSelector then
                _G.RanaVSRefreshAutoStealSelector()
            end
        end)
    end

    pcall(function() _12HubSyncAutoSteal() end)
end
-- FINAL LAPEAK MOBILE STATE NORMALIZER
-- ============================================================
do
    local function normalizeMobileActionVisuals()
        local refs = actRefs or {}
        for key,e in pairs(refs) do
            if e and e.btn then
                local on = false
                if key == "steal" then on = St.autoSteal == true
                elseif key == "sentry" then on = St.destroySentry == true
                elseif key == "ps" then on = isEquippedExact("Paintball Gun")
                elseif key == "med" then on = false
                elseif key == "antiTrap" then on = St.antiTrap == true end
                if key == "steal" then
                    applyActBtnState(e.btn,on,"STEAL ON","AUTO STEAL")
                elseif key == "sentry" then
                    applyActBtnState(e.btn,on,"DESTROY ON","DESTROY")
                elseif key == "ps" then
                    applyActBtnState(e.btn,on,"PS","PS")
                elseif key == "med" then
                    applyActBtnState(e.btn,false,"MED\nEQUIP","MED\nEQUIP")
                elseif key == "antiTrap" then
                    applyActBtnState(e.btn,on,"ANTI\nTRAP ON","ANTI\nTRAP")
                elseif key == "websinger" then
                    on = isWebSlingerEquipped()
                    applyActBtnState(e.btn,on,"KILL","WEBSINGER")
                end
            end
        end
    end
    _G.RanaVSRefreshMobileButtonStates = normalizeMobileActionVisuals
    pcall(normalizeMobileActionVisuals)
    task.spawn(function()
        while task.wait(0.5) do
            if _G.RanaVSRefreshWebsingerBtn then
                pcall(_G.RanaVSRefreshWebsingerBtn)
            end
        end
    end)
end

-- ============================================================
-- 12HUB SLOT PANEL — compact integration of the full uploaded Slot/gear logic.
-- Equip buttons, settings sliders, lock, keybinds, cooldown and inventory logic preserved.
-- ============================================================
task.spawn(function() -- keep Slot locals out of the main chunk local-register limit
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local previousSlotConnections = _G._12HubSlotConnectionBag
if type(previousSlotConnections) == "table" then
    for _, conn in ipairs(previousSlotConnections) do pcall(function() conn:Disconnect() end) end
end
local slotConnectionBag = {}
_G._12HubSlotConnectionBag = slotConnectionBag
local function slotConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(slotConnectionBag, conn)
    return conn
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

local TITLE = "SLOT"
-- Ace theme 2: charcoal cards, steel-grey borders, white text and slate selection.
local ACCENT = Color3.fromRGB(104, 116, 132)
local ACCENT2 = Color3.fromRGB(156, 169, 186)
local BG = Color3.fromRGB(9, 11, 14)
local BG2 = Color3.fromRGB(13, 16, 20)
local BG3 = Color3.fromRGB(18, 21, 26)
local TEXT = Color3.fromRGB(238, 238, 238)
local MUTED = Color3.fromRGB(138, 142, 148)
local GREEN = Color3.fromRGB(104, 116, 132)
local RED = Color3.fromRGB(239, 68, 75)

local DEFAULT_SIZE = 60
local settings = {}
local activeEquips = {}
local cooldowns = {}
local keybinds = {}
-- Forward-declare drag state so the Slot lock-button callback and drag handlers share the same locals.
local draggingMain, draggingToggle, draggingSettings = false, false, false
-- Shared drag handle for floating gear buttons; the header LOCK also freezes these.
local equipButtonDrag = nil

-- Reuse 12Hub's existing JSON config so Slot positions/settings survive re-execution.
local CoreGui = game:GetService("CoreGui")
local SlotState = (type(St) == "table" and type(St.slotPanelState) == "table") and St.slotPanelState or {}
SlotState.enabled = type(SlotState.enabled) == "table" and SlotState.enabled or {}
SlotState.settings = type(SlotState.settings) == "table" and SlotState.settings or {}
SlotState.keybinds = type(SlotState.keybinds) == "table" and SlotState.keybinds or {}
SlotState.buttonPositions = type(SlotState.buttonPositions) == "table" and SlotState.buttonPositions or {}
-- This lock belongs only to the Slot UI; never inherit the main menu's Lock UI state.
SlotState.panelDragLocked = SlotState.panelDragLocked == true

local function slotPositionToArray(pos)
    return {pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset}
end
local function slotArrayToPosition(data)
    if type(data) ~= "table" then return nil end
    local xs, xo, ys, yo = tonumber(data[1]), tonumber(data[2]), tonumber(data[3]), tonumber(data[4])
    if not xs or not xo or not ys or not yo then return nil end
    return UDim2.new(xs, xo, ys, yo)
end
local function saveSlotState()
    if type(St) == "table" then St.slotPanelState = SlotState end
    if type(saveCfg) == "function" then pcall(saveCfg) end
end
local slotSaveToken = 0
local function saveSlotStateDebounced()
    slotSaveToken = slotSaveToken + 1
    local token = slotSaveToken
    task.delay(0.4, function()
        if token == slotSaveToken then saveSlotState() end
    end)
end
local function getToolSettings(toolName)
    if settings[toolName] then return settings[toolName] end
    local saved = SlotState.settings[toolName]
    if type(saved) ~= "table" then saved = {} end
    local size = math.clamp(tonumber(saved.size) or DEFAULT_SIZE, 32, 110)
    local transparency = math.clamp(tonumber(saved.transparency) or 0, 0, 0.85)
    settings[toolName] = {
        size = size,
        locked = saved.locked == true,
        transparency = transparency,
    }
    local keyName = SlotState.keybinds[toolName]
    if type(keyName) == "string" and Enum.KeyCode[keyName] then
        keybinds[toolName] = Enum.KeyCode[keyName]
    end
    return settings[toolName]
end

for _, guiParent in ipairs({CoreGui, playerGui}) do
    local oldSlotGui = guiParent:FindFirstChild("12Hub_SlotPanel")
    if oldSlotGui then pcall(function() oldSlotGui:Destroy() end) end
end
local screen = Instance.new("ScreenGui")
screen.Name = "12Hub_SlotPanel"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.IgnoreGuiInset = true
screen.DisplayOrder = 100001
local screenParented = pcall(function() screen.Parent = CoreGui end)
if not screenParented or not screen.Parent then
    screen.Parent = playerGui
end
slotConnect(screen.AncestryChanged, function(_, parent)
    if parent == nil then
        for _, conn in ipairs(slotConnectionBag) do pcall(function() conn:Disconnect() end) end
        if _G._12HubSlotConnectionBag == slotConnectionBag then _G._12HubSlotConnectionBag = nil end
    end
end)

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 230, 0, 250)
local savedMainPosition = slotArrayToPosition(SlotState.mainPosition)
local slotDetached = SlotState.mainDetached == true and savedMainPosition ~= nil
main.Position = slotDetached and savedMainPosition or UDim2.new(0.5, -115, 0.5, 160)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = false
main.Parent = screen

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = ACCENT
mainStroke.Thickness = 1.8
mainStroke.Transparency = 0.45
mainStroke.Parent = main

local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1, 60, 1, 60)
glow.Position = UDim2.new(0, -30, 0, -30)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.ImageColor3 = ACCENT
glow.ImageTransparency = 0.9
glow.ScaleType = Enum.ScaleType.Slice
glow.SliceCenter = Rect.new(24, 24, 276, 276)
glow.ZIndex = 0
glow.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = BG2
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 18)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = BG2
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 3)
accentLine.Position = UDim2.new(0, 0, 1, -3)
accentLine.BackgroundColor3 = ACCENT
accentLine.BorderSizePixel = 0
accentLine.Parent = titleBar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, ACCENT),
	ColorSequenceKeypoint.new(0.5, ACCENT2),
	ColorSequenceKeypoint.new(1, ACCENT)
})
gradient.Parent = accentLine

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -126, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = TITLE
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 15
titleLabel.TextColor3 = ACCENT
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Independent drag-lock control for the Slot panel. Main-menu LOCKED state does not affect it.
local slotDragLockBtn = Instance.new("TextButton")
slotDragLockBtn.Name = "SlotDragLock"
slotDragLockBtn.Size = UDim2.new(0, 36, 0, 24)
slotDragLockBtn.Position = UDim2.new(1, -102, 0.5, -12)
slotDragLockBtn.BackgroundColor3 = SlotState.panelDragLocked and ACCENT or BG3
slotDragLockBtn.Text = SlotState.panelDragLocked and "LOCK" or "DRAG"
slotDragLockBtn.Font = Enum.Font.GothamBold
slotDragLockBtn.TextSize = 9
slotDragLockBtn.TextColor3 = TEXT
slotDragLockBtn.BorderSizePixel = 0
slotDragLockBtn.AutoButtonColor = false
slotDragLockBtn.Parent = titleBar
local slotDragLockCorner = Instance.new("UICorner")
slotDragLockCorner.CornerRadius = UDim.new(0, 7)
slotDragLockCorner.Parent = slotDragLockBtn
local slotDragLockStroke = Instance.new("UIStroke")
slotDragLockStroke.Color = ACCENT2
slotDragLockStroke.Thickness = 1
slotDragLockStroke.Transparency = SlotState.panelDragLocked and 0.15 or 0.55
slotDragLockStroke.Parent = slotDragLockBtn
local function refreshSlotDragLockButton()
    local locked = SlotState.panelDragLocked == true
    slotDragLockBtn.Text = locked and "LOCK" or "DRAG"
    slotDragLockBtn.BackgroundColor3 = locked and ACCENT or BG3
    slotDragLockBtn.TextColor3 = TEXT
    slotDragLockStroke.Transparency = locked and 0.15 or 0.55
end
slotDragLockBtn.Activated:Connect(function()
    SlotState.panelDragLocked = not SlotState.panelDragLocked
    if SlotState.panelDragLocked then
        draggingMain = false
        draggingToggle = false
        draggingSettings = false
        equipButtonDrag = nil
    end
    refreshSlotDragLockButton()
    saveSlotState()
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -62, 0.5, -13)
minBtn.BackgroundColor3 = BG3
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 17
minBtn.TextColor3 = TEXT
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 9)
minCorner.Parent = minBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
closeBtn.BackgroundColor3 = RED
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 19
closeBtn.TextColor3 = TEXT
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 9)
closeCorner.Parent = closeBtn

local header = Instance.new("Frame")
header.Size = UDim2.new(1, -20, 0, 18)
header.Position = UDim2.new(0, 10, 0, 42)
header.BackgroundTransparency = 1
header.Parent = main

local itemCount = Instance.new("TextLabel")
itemCount.Size = UDim2.new(1, 0, 1, 0)
itemCount.BackgroundTransparency = 1
itemCount.Text = "0 items"
itemCount.Font = Enum.Font.GothamMedium
itemCount.TextSize = 11
itemCount.TextColor3 = MUTED
itemCount.TextXAlignment = Enum.TextXAlignment.Left
itemCount.Parent = header

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -72)
scroll.Position = UDim2.new(0, 6, 0, 64)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = ACCENT
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scroll

draggingMain = false
local mainDragMoved = false
local dragStart, startPos

local minimized = SlotState.minimized == true
local fullSize = main.Size
if minimized then
    main.Size = UDim2.new(0, 230, 0, 38)
    scroll.Visible = false
    header.Visible = false
    minBtn.Text = "+"
else
    scroll.Visible = true
    header.Visible = true
    minBtn.Text = "—"
end
local adjustingTPAnchor = false
local slotToggleDetached = SlotState.toggleDetached == true and slotArrayToPosition(SlotState.togglePosition) ~= nil
local savedTogglePosition = slotArrayToPosition(SlotState.togglePosition)
local slotToggleBtn = Instance.new("TextButton")
slotToggleBtn.Name = "SlotPanelToggle"
slotToggleBtn.Size = UDim2.new(0, 76, 0, 26)
slotToggleBtn.Position = UDim2.new(0.5, -38, 0.5, 170)
slotToggleBtn.BackgroundColor3 = ACCENT
slotToggleBtn.Text = "Slot"
slotToggleBtn.Font = Enum.Font.GothamBold
slotToggleBtn.TextSize = 12
slotToggleBtn.TextColor3 = TEXT
slotToggleBtn.BorderSizePixel = 0
slotToggleBtn.AutoButtonColor = false
slotToggleBtn.Parent = screen
draggingToggle = false
local toggleDragMoved = false
local toggleDragStart, toggleStartPos
if slotToggleDetached and savedTogglePosition then slotToggleBtn.Position = savedTogglePosition end
local slotToggleCorner = Instance.new("UICorner")
slotToggleCorner.CornerRadius = UDim.new(0, 9)
slotToggleCorner.Parent = slotToggleBtn
local slotToggleStroke = Instance.new("UIStroke")
slotToggleStroke.Color = ACCENT2
slotToggleStroke.Thickness = 1.2
slotToggleStroke.Parent = slotToggleBtn

local function getTPPanelMain()
    local tpGui = CoreGui:FindFirstChild("12Hub_AllGearOnTop") or playerGui:FindFirstChild("12Hub_AllGearOnTop")
    return tpGui and tpGui:FindFirstChild("12Hub_TPPanelMain") or nil
end

local function syncSlotAnchor()
    if adjustingTPAnchor then return end
    local tpMain = getTPPanelMain()
    if not tpMain then
        if not slotDetached and not savedMainPosition then
            main.Position = UDim2.new(0.5, -115, 0.5, 40)
        end
        return
    end
    local tpPos = tpMain.AbsolutePosition
    local tpSize = tpMain.AbsoluteSize
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
    local x = math.clamp(tpPos.X, 4, math.max(4, viewport.X - 234))
    local toggleY = tpPos.Y + tpSize.Y + 6
    if toggleY + 26 > viewport.Y - 4 then toggleY = math.max(4, tpPos.Y - 32) end
    if not slotToggleDetached then
        slotToggleBtn.Position = UDim2.fromOffset(x, toggleY)
    end
    if not slotDetached then
        local mainY = tpPos.Y + tpSize.Y + 38
        local mainHeight = minimized and 38 or 250
        if mainY + mainHeight > viewport.Y - 4 then mainY = math.max(4, viewport.Y - mainHeight - 4) end
        main.Position = UDim2.fromOffset(x, mainY)
    end
end

local function saveMainPosition()
    SlotState.mainPosition = slotPositionToArray(main.Position)
    SlotState.mainDetached = slotDetached == true
    saveSlotState()
end
local function saveTogglePosition()
    SlotState.togglePosition = slotPositionToArray(slotToggleBtn.Position)
    SlotState.toggleDetached = slotToggleDetached == true
    saveSlotState()
end

-- Dragging the Slot title bar detaches it from TP and persists its coordinates; independent Slot lock controls it.
local function slotPointInside(guiObject, point)
    if not guiObject or not guiObject.Visible then return false end
    local p, sz = guiObject.AbsolutePosition, guiObject.AbsoluteSize
    return point.X >= p.X and point.X <= p.X + sz.X and point.Y >= p.Y and point.Y <= p.Y + sz.Y
end
titleBar.InputBegan:Connect(function(input)
    if SlotState.panelDragLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Buttons inside the title bar must stay clickable instead of starting a window drag.
        if slotPointInside(slotDragLockBtn, input.Position)
            or slotPointInside(minBtn, input.Position)
            or slotPointInside(closeBtn, input.Position) then
            return
        end
        draggingMain = true
        mainDragMoved = false
        dragStart = input.Position
        startPos = main.Position
    end
end)
slotToggleBtn.InputBegan:Connect(function(input)
    if SlotState.panelDragLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        toggleDragMoved = false
        toggleDragStart = input.Position
        toggleStartPos = slotToggleBtn.Position
    end
end)

slotConnect(UserInputService.InputChanged, function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if draggingMain then
        local delta = input.Position - dragStart
        if delta.Magnitude >= 4 then
            mainDragMoved = true
            slotDetached = true
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    if draggingToggle then
        local delta = input.Position - toggleDragStart
        if delta.Magnitude >= 4 then
            toggleDragMoved = true
            slotToggleDetached = true
            slotToggleBtn.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
        end
    end
end)
slotConnect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if draggingMain then
            draggingMain = false
            if mainDragMoved then saveMainPosition() end
        end
        if draggingToggle then
            draggingToggle = false
            if toggleDragMoved then
                saveTogglePosition()
                task.delay(0.08, function() toggleDragMoved = false end)
            end
        end
    end
end)

local function setSlotVisible(visible)
    main.Visible = visible
    slotToggleBtn.Text = visible and "Hide Slot" or "Slot"
    if visible then
        syncSlotAnchor()
    end
end

slotToggleBtn.MouseButton1Click:Connect(function()
    if toggleDragMoved then return end
    setSlotVisible(not main.Visible)
end)

-- Follow the TP panel until the user manually drags Slot elsewhere.
task.spawn(function()
    local tpMain
    for _ = 1, 100 do
        tpMain = getTPPanelMain()
        if tpMain then break end
        task.wait(0.1)
    end
    if not (screen and screen.Parent) then return end
    if tpMain then
        slotConnect(tpMain:GetPropertyChangedSignal("Position"), syncSlotAnchor)
        slotConnect(tpMain:GetPropertyChangedSignal("Size"), syncSlotAnchor)
        local camera = workspace.CurrentCamera
        if camera then slotConnect(camera:GetPropertyChangedSignal("ViewportSize"), syncSlotAnchor) end
        syncSlotAnchor()
    end
end)

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 230, 0, 38)}):Play()
		scroll.Visible = false
		header.Visible = false
		minBtn.Text = "+"
	else
		TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Size = fullSize}):Play()
		scroll.Visible = true
		header.Visible = true
		minBtn.Text = "—"
	end
	SlotState.minimized = minimized
	saveSlotState()
end)

closeBtn.MouseButton1Click:Connect(function()
    setSlotVisible(false)
end)

local equipHolder = Instance.new("Folder")
equipHolder.Name = "EquipButtons"
equipHolder.Parent = screen

local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 230, 0, 260)
settingsFrame.Position = slotArrayToPosition(SlotState.settingsPosition) or UDim2.new(0.5, -115, 0.5, -130)
settingsFrame.BackgroundColor3 = BG
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.ZIndex = 70
settingsFrame.Parent = screen

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 16)
setCorner.Parent = settingsFrame

local setStroke = Instance.new("UIStroke")
setStroke.Color = ACCENT
setStroke.Thickness = 2.5
setStroke.Transparency = 0.4
setStroke.Parent = settingsFrame

local setTitle = Instance.new("TextLabel")
setTitle.Size = UDim2.new(1, -62, 0, 42)
setTitle.Position = UDim2.new(0, 18, 0, 6)
setTitle.BackgroundTransparency = 1
setTitle.Text = "Settings"
setTitle.Font = Enum.Font.GothamBlack
setTitle.TextSize = 17
setTitle.TextColor3 = ACCENT
setTitle.TextXAlignment = Enum.TextXAlignment.Left
setTitle.ZIndex = 71
setTitle.Active = true
setTitle.Parent = settingsFrame

draggingSettings = false
local settingsDragMoved = false
local settingsDragStart, settingsStartPos
setTitle.InputBegan:Connect(function(input)
    if SlotState.panelDragLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSettings = true
        settingsDragMoved = false
        settingsDragStart = input.Position
        settingsStartPos = settingsFrame.Position
    end
end)
slotConnect(UserInputService.InputChanged, function(input)
    if draggingSettings and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - settingsDragStart
        if delta.Magnitude >= 4 then
            settingsDragMoved = true
            settingsFrame.Position = UDim2.new(settingsStartPos.X.Scale, settingsStartPos.X.Offset + delta.X, settingsStartPos.Y.Scale, settingsStartPos.Y.Offset + delta.Y)
        end
    end
end)
slotConnect(UserInputService.InputEnded, function(input)
    if draggingSettings and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingSettings = false
        if settingsDragMoved then
            SlotState.settingsPosition = slotPositionToArray(settingsFrame.Position)
            saveSlotState()
        end
        task.delay(0.08, function() settingsDragMoved = false end)
    end
end)

local setClose = Instance.new("TextButton")
setClose.Size = UDim2.new(0, 32, 0, 32)
setClose.Position = UDim2.new(1, -42, 0, 10)
setClose.BackgroundColor3 = RED
setClose.Text = "×"
setClose.Font = Enum.Font.GothamBold
setClose.TextSize = 17
setClose.TextColor3 = TEXT
setClose.BorderSizePixel = 0
setClose.ZIndex = 71
setClose.Parent = settingsFrame

local setCloseCorner = Instance.new("UICorner")
setCloseCorner.CornerRadius = UDim.new(0, 8)
setCloseCorner.Parent = setClose

setClose.MouseButton1Click:Connect(function()
	settingsFrame.Visible = false
end)

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, -36, 0, 20)
sizeLabel.Position = UDim2.new(0, 18, 0, 56)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Size: 60"
sizeLabel.Font = Enum.Font.GothamMedium
sizeLabel.TextSize = 14
sizeLabel.TextColor3 = TEXT
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.ZIndex = 71
sizeLabel.Parent = settingsFrame

local sizeBar = Instance.new("Frame")
sizeBar.Size = UDim2.new(1, -36, 0, 12)
sizeBar.Position = UDim2.new(0, 18, 0, 82)
sizeBar.BackgroundColor3 = BG3
sizeBar.BorderSizePixel = 0
sizeBar.ZIndex = 71
sizeBar.Parent = settingsFrame

local sizeBarCorner = Instance.new("UICorner")
sizeBarCorner.CornerRadius = UDim.new(1, 0)
sizeBarCorner.Parent = sizeBar

local sizeFill = Instance.new("Frame")
sizeFill.Size = UDim2.new(0.45, 0, 1, 0)
sizeFill.BackgroundColor3 = ACCENT
sizeFill.BorderSizePixel = 0
sizeFill.ZIndex = 72
sizeFill.Parent = sizeBar

local sizeFillCorner = Instance.new("UICorner")
sizeFillCorner.CornerRadius = UDim.new(1, 0)
sizeFillCorner.Parent = sizeFill

local sizeKnob = Instance.new("Frame")
sizeKnob.Size = UDim2.new(0, 20, 0, 20)
sizeKnob.Position = UDim2.new(0.45, -10, 0.5, -10)
sizeKnob.BackgroundColor3 = TEXT
sizeKnob.BorderSizePixel = 0
sizeKnob.ZIndex = 73
sizeKnob.Parent = sizeBar

local sizeKnobCorner = Instance.new("UICorner")
sizeKnobCorner.CornerRadius = UDim.new(1, 0)
sizeKnobCorner.Parent = sizeKnob

local lockLabel = Instance.new("TextLabel")
lockLabel.Size = UDim2.new(0.55, 0, 0, 26)
lockLabel.Position = UDim2.new(0, 18, 0, 114)
lockLabel.BackgroundTransparency = 1
lockLabel.Text = "Lock position"
lockLabel.Font = Enum.Font.GothamMedium
lockLabel.TextSize = 14
lockLabel.TextColor3 = TEXT
lockLabel.TextXAlignment = Enum.TextXAlignment.Left
lockLabel.ZIndex = 71
lockLabel.Parent = settingsFrame

local lockToggle = Instance.new("TextButton")
lockToggle.Size = UDim2.new(0, 58, 0, 30)
lockToggle.Position = UDim2.new(1, -76, 0, 112)
lockToggle.BackgroundColor3 = BG3
lockToggle.Text = "OFF"
lockToggle.Font = Enum.Font.GothamBold
lockToggle.TextSize = 10
lockToggle.TextColor3 = MUTED
lockToggle.BorderSizePixel = 0
lockToggle.ZIndex = 71
lockToggle.Parent = settingsFrame

local lockToggleCorner = Instance.new("UICorner")
lockToggleCorner.CornerRadius = UDim.new(0, 8)
lockToggleCorner.Parent = lockToggle

local transLabel = Instance.new("TextLabel")
transLabel.Size = UDim2.new(1, -36, 0, 20)
transLabel.Position = UDim2.new(0, 18, 0, 156)
transLabel.BackgroundTransparency = 1
transLabel.Text = "Transparency: 0%"
transLabel.Font = Enum.Font.GothamMedium
transLabel.TextSize = 14
transLabel.TextColor3 = TEXT
transLabel.TextXAlignment = Enum.TextXAlignment.Left
transLabel.ZIndex = 71
transLabel.Parent = settingsFrame

local transBar = Instance.new("Frame")
transBar.Size = UDim2.new(1, -36, 0, 12)
transBar.Position = UDim2.new(0, 18, 0, 182)
transBar.BackgroundColor3 = BG3
transBar.BorderSizePixel = 0
transBar.ZIndex = 71
transBar.Parent = settingsFrame

local transBarCorner = Instance.new("UICorner")
transBarCorner.CornerRadius = UDim.new(1, 0)
transBarCorner.Parent = transBar

local transFill = Instance.new("Frame")
transFill.Size = UDim2.new(0, 0, 1, 0)
transFill.BackgroundColor3 = ACCENT2
transFill.BorderSizePixel = 0
transFill.ZIndex = 72
transFill.Parent = transBar

local transFillCorner = Instance.new("UICorner")
transFillCorner.CornerRadius = UDim.new(1, 0)
transFillCorner.Parent = transFill

local transKnob = Instance.new("Frame")
transKnob.Size = UDim2.new(0, 20, 0, 20)
transKnob.Position = UDim2.new(0, -10, 0.5, -10)
transKnob.BackgroundColor3 = TEXT
transKnob.BorderSizePixel = 0
transKnob.ZIndex = 73
transKnob.Parent = transBar

local transKnobCorner = Instance.new("UICorner")
transKnobCorner.CornerRadius = UDim.new(1, 0)
transKnobCorner.Parent = transKnob

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0.38, 0, 0, 26)
keyLabel.Position = UDim2.new(0, 18, 0, 216)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Keybind"
keyLabel.Font = Enum.Font.GothamMedium
keyLabel.TextSize = 14
keyLabel.TextColor3 = TEXT
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.ZIndex = 71
keyLabel.Parent = settingsFrame

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0, 100, 0, 32)
keyBtn.Position = UDim2.new(1, -118, 0, 213)
keyBtn.BackgroundColor3 = BG3
keyBtn.Text = "None"
keyBtn.Font = Enum.Font.GothamBold
keyBtn.TextSize = 14
keyBtn.TextColor3 = MUTED
keyBtn.BorderSizePixel = 0
keyBtn.ZIndex = 71
keyBtn.Parent = settingsFrame

local keyBtnCorner = Instance.new("UICorner")
keyBtnCorner.CornerRadius = UDim.new(0, 8)
keyBtnCorner.Parent = keyBtn

local listeningKey = false
local currentSettingsTool = nil

local function applySettingsToButton(toolName)
	local data = activeEquips[toolName]
	if not data then return end
	local s = getToolSettings(toolName)
	data.button.Size = UDim2.new(0, s.size, 0, s.size)
	data.button.ImageTransparency = s.transparency
	data.button.BackgroundTransparency = s.transparency
end

local function openSettings(toolName)
	currentSettingsTool = toolName
	local s = getToolSettings(toolName)

	setTitle.Text = toolName
	sizeLabel.Text = "Size: " .. tostring(s.size)
	local sizePct = (s.size - 32) / (110 - 32)
	sizeFill.Size = UDim2.new(sizePct, 0, 1, 0)
	sizeKnob.Position = UDim2.new(sizePct, -10, 0.5, -10)

	lockToggle.Text = s.locked and "LOCK" or "DRAG"
	lockToggle.BackgroundColor3 = s.locked and GREEN or BG3
	lockToggle.TextColor3 = s.locked and TEXT or MUTED

	transLabel.Text = "Transparency: " .. math.floor(s.transparency * 100) .. "%"
	transFill.Size = UDim2.new(s.transparency, 0, 1, 0)
	transKnob.Position = UDim2.new(s.transparency, -10, 0.5, -10)

	local kb = keybinds[toolName]
	keyBtn.Text = kb and kb.Name or "None"
	keyBtn.TextColor3 = kb and TEXT or MUTED
	keyBtn.BackgroundColor3 = kb and ACCENT or BG3

	settingsFrame.Visible = true
end

local function setupSlider(bar, fill, knob, minVal, maxVal, onChange)
	local dragging = false
	local function update(input)
		local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -10, 0.5, -10)
		onChange(minVal + (maxVal - minVal) * rel)
	end
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	slotConnect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	slotConnect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

setupSlider(sizeBar, sizeFill, sizeKnob, 32, 110, function(val)
	if not currentSettingsTool then return end
	settings[currentSettingsTool].size = math.floor(val)
	sizeLabel.Text = "Size: " .. settings[currentSettingsTool].size
	applySettingsToButton(currentSettingsTool)
	SlotState.settings[currentSettingsTool] = settings[currentSettingsTool]
	saveSlotStateDebounced()
end)

setupSlider(transBar, transFill, transKnob, 0, 0.85, function(val)
	if not currentSettingsTool then return end
	settings[currentSettingsTool].transparency = val
	transLabel.Text = "Transparency: " .. math.floor(val * 100) .. "%"
	applySettingsToButton(currentSettingsTool)
	SlotState.settings[currentSettingsTool] = settings[currentSettingsTool]
	saveSlotStateDebounced()
end)

lockToggle.MouseButton1Click:Connect(function()
	if not currentSettingsTool then return end
	local s = settings[currentSettingsTool]
	s.locked = not s.locked
	lockToggle.Text = s.locked and "LOCK" or "DRAG"
	lockToggle.BackgroundColor3 = s.locked and GREEN or BG3
	lockToggle.TextColor3 = s.locked and TEXT or MUTED
	SlotState.settings[currentSettingsTool] = s
	saveSlotState()
end)

keyBtn.MouseButton1Click:Connect(function()
	if not currentSettingsTool then return end
	listeningKey = true
	keyBtn.Text = "..."
	keyBtn.TextColor3 = ACCENT2
end)

slotConnect(UserInputService.InputBegan, function(input, processed)
	if listeningKey and currentSettingsTool then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				keybinds[currentSettingsTool] = nil
				SlotState.keybinds[currentSettingsTool] = nil
				keyBtn.Text = "None"
				keyBtn.TextColor3 = MUTED
				keyBtn.BackgroundColor3 = BG3
			else
				keybinds[currentSettingsTool] = input.KeyCode
				SlotState.keybinds[currentSettingsTool] = input.KeyCode.Name
				keyBtn.Text = input.KeyCode.Name
				keyBtn.TextColor3 = TEXT
				keyBtn.BackgroundColor3 = ACCENT
			end
			SlotState.settings[currentSettingsTool] = getToolSettings(currentSettingsTool)
			saveSlotState()
			listeningKey = false
		end
	end
end)

local function getToolCooldown(tool)
	if not tool then return 1.5 end
	local cd = tool:FindFirstChild("Cooldown") or tool:FindFirstChild("CD") or tool:FindFirstChild("cooldown")
	if cd and (cd:IsA("NumberValue") or cd:IsA("IntValue")) then
		return cd.Value
	end
	local conf = tool:FindFirstChild("Config") or tool:FindFirstChild("Settings")
	if conf then
		local c = conf:FindFirstChild("Cooldown") or conf:FindFirstChild("CD")
		if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then
			return c.Value
		end
	end
	local attr = tool:GetAttribute("Cooldown") or tool:GetAttribute("CD")
	if typeof(attr) == "number" then
		return attr
	end
	return 1.5
end

local function equipTool(toolName)
	local now = tick()
	if cooldowns[toolName] and now < cooldowns[toolName] then return end

	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local target = backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
	if not target or not target:IsA("Tool") then
		for _, v in ipairs(backpack:GetChildren()) do
			if v:IsA("Tool") and v.Name == toolName then
				target = v
				break
			end
		end
	end
	if not target then return end

	local cdTime = getToolCooldown(target)
	humanoid:UnequipTools()
	task.wait(0.03)
	humanoid:EquipTool(target)
	cooldowns[toolName] = now + cdTime
end

slotConnect(UserInputService.InputBegan, function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	for name, key in pairs(keybinds) do
		if key == input.KeyCode and activeEquips[name] then
			equipTool(name)
			break
		end
	end
end)

equipButtonDrag = nil
local equipButtonDragMoved = {}
slotConnect(UserInputService.InputChanged, function(input)
    -- Header LOCK freezes every floating gear button as well as the Slot panel.
    if SlotState.panelDragLocked then
        equipButtonDrag = nil
        return
    end
    local drag = equipButtonDrag
    if not drag or not drag.button or not drag.button.Parent then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - drag.startInputPosition
    if delta.Magnitude >= 4 then
        drag.moved = true
        equipButtonDragMoved[drag.name] = true
    end
    if drag.moved then
        drag.button.Position = UDim2.new(drag.startPosition.X.Scale, drag.startPosition.X.Offset + delta.X,
            drag.startPosition.Y.Scale, drag.startPosition.Y.Offset + delta.Y)
    end
end)
slotConnect(UserInputService.InputEnded, function(input)
    local drag = equipButtonDrag
    if not drag then return end
    local pointerEnded = input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    if not pointerEnded then return end
    equipButtonDrag = nil
    if drag.moved and drag.button and drag.button.Parent then
        SlotState.buttonPositions[drag.name] = slotPositionToArray(drag.button.Position)
        saveSlotStateDebounced()
        task.delay(0.12, function() equipButtonDragMoved[drag.name] = nil end)
    else
        equipButtonDragMoved[drag.name] = nil
    end
end)

local function createEquipButton(tool)
	if activeEquips[tool.Name] then return end
	local s = getToolSettings(tool.Name)

	local btn = Instance.new("ImageButton")
	btn.Name = tool.Name
	btn.Size = UDim2.new(0, s.size, 0, s.size)
	local savedButtonPosition = slotArrayToPosition(SlotState.buttonPositions[tool.Name])
	btn.Position = savedButtonPosition or UDim2.new(1, -95 - math.random(0, 55), 0.18 + math.random() * 0.5, 0)
	if not savedButtonPosition then
		SlotState.buttonPositions[tool.Name] = slotPositionToArray(btn.Position)
		saveSlotStateDebounced()
	end
	btn.BackgroundColor3 = BG2
	btn.BorderSizePixel = 0
	btn.Image = (tool.TextureId ~= "" and tool.TextureId) or "rbxassetid://6031075931"
	btn.ImageTransparency = s.transparency
	btn.BackgroundTransparency = s.transparency
	btn.ScaleType = Enum.ScaleType.Fit
	btn.AutoButtonColor = false
	btn.Parent = equipHolder

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 15)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = ACCENT
	btnStroke.Thickness = 2.2
	btnStroke.Transparency = 0.25
	btnStroke.Parent = btn

	local cdOverlay = Instance.new("Frame")
	cdOverlay.Size = UDim2.new(1, 0, 1, 0)
	cdOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	cdOverlay.BackgroundTransparency = 0.45
	cdOverlay.BorderSizePixel = 0
	cdOverlay.Visible = false
	cdOverlay.ZIndex = 5
	cdOverlay.Parent = btn

	local cdCorner = Instance.new("UICorner")
	cdCorner.CornerRadius = UDim.new(0, 15)
	cdCorner.Parent = cdOverlay

	local cdText = Instance.new("TextLabel")
	cdText.Size = UDim2.new(1, 0, 1, 0)
	cdText.BackgroundTransparency = 1
	cdText.Text = "0"
	cdText.Font = Enum.Font.GothamBlack
	cdText.TextSize = 19
	cdText.TextColor3 = TEXT
	cdText.ZIndex = 6
	cdText.Parent = cdOverlay

	btn.InputBegan:Connect(function(input)
        if SlotState.panelDragLocked then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local st = settings[tool.Name]
		if st and st.locked then return end
        equipButtonDragMoved[tool.Name] = nil
        equipButtonDrag = {
            name = tool.Name,
            button = btn,
            input = input,
            startInputPosition = input.Position,
            startPosition = btn.Position,
            moved = false,
        }
	end)

	btn.Activated:Connect(function()
        -- Mastery behavior: LOCK prevents dragging only; tapping the slot still equips its Tool.
        local currentSettings = getToolSettings(tool.Name)
        if currentSettings.locked then
            equipButtonDragMoved[tool.Name] = nil
            equipTool(tool.Name)
            return
        end
		if equipButtonDragMoved[tool.Name] then return end
		equipTool(tool.Name)
	end)

	activeEquips[tool.Name] = {
		button = btn,
		cooldownOverlay = cdOverlay,
		cdText = cdText
	}
end

local function removeEquipButton(toolName)
    if equipButtonDrag and equipButtonDrag.name == toolName then equipButtonDrag = nil end
    equipButtonDragMoved[toolName] = nil
	if activeEquips[toolName] then
		activeEquips[toolName].button:Destroy()
		activeEquips[toolName] = nil
	end
end

-- Cooldown labels need no per-frame updates: 10 Hz keeps the visual responsive and cuts UI churn.
local cooldownUiAccumulator = 0
slotConnect(RunService.Heartbeat, function(dt)
    cooldownUiAccumulator += dt
    if cooldownUiAccumulator < 0.10 then return end
    cooldownUiAccumulator = cooldownUiAccumulator % 0.10
	local now = tick()
	for name, data in pairs(activeEquips) do
		local endTime = cooldowns[name]
		if endTime and now < endTime then
			local remaining = endTime - now
            if not data.cooldownOverlay.Visible then data.cooldownOverlay.Visible = true end
            local textValue
			if remaining >= 10 then
                textValue = tostring(math.ceil(remaining))
			else
                textValue = string.format("%.1f", remaining)
			end
            if data.cdText.Text ~= textValue then data.cdText.Text = textValue end
		else
            if data.cooldownOverlay.Visible then data.cooldownOverlay.Visible = false end
			cooldowns[name] = nil
		end
	end
end)

local function createItemRow(tool)
	if not tool:IsA("Tool") then return end
	if scroll:FindFirstChild(tool.Name) then return end

	local row = Instance.new("Frame")
	row.Name = tool.Name
	row.Size = UDim2.new(1, -10, 0, 42)
	row.BackgroundColor3 = BG2
	row.BorderSizePixel = 0
	row.Parent = scroll

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 13)
	rowCorner.Parent = row

	local rowStroke = Instance.new("UIStroke")
	rowStroke.Color = Color3.fromRGB(40, 40, 52)
	rowStroke.Thickness = 1.2
	rowStroke.Transparency = 0.45
	rowStroke.Parent = row

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 32, 0, 32)
	icon.Position = UDim2.new(0, 6, 0.5, -16)
	icon.BackgroundColor3 = BG3
	icon.BorderSizePixel = 0
	icon.Image = (tool.TextureId ~= "" and tool.TextureId) or "rbxassetid://6031075931"
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = row

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 8)
	iconCorner.Parent = icon

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -126, 1, 0)
	nameLabel.Position = UDim2.new(0, 44, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = tool.Name
	nameLabel.Font = Enum.Font.GothamMedium
	nameLabel.TextSize = 12
	nameLabel.TextColor3 = TEXT
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = row

	local gear = Instance.new("TextButton")
	gear.Size = UDim2.new(0, 25, 0, 25)
	gear.Position = UDim2.new(1, -78, 0.5, -12.5)
	gear.BackgroundColor3 = BG3
	gear.Text = "⚙"
	gear.Font = Enum.Font.GothamBold
	gear.TextSize = 13
	gear.TextColor3 = MUTED
	gear.BorderSizePixel = 0
	gear.AutoButtonColor = false
	gear.Parent = row

	local gearCorner = Instance.new("UICorner")
	gearCorner.CornerRadius = UDim.new(0, 9)
	gearCorner.Parent = gear

	gear.MouseButton1Click:Connect(function()
        -- Open this Tool's Mastery settings; its DRAG/LOCK state is independent per slot.
		openSettings(tool.Name)
	end)

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 42, 0, 25)
	toggle.Position = UDim2.new(1, -48, 0.5, -12.5)
	toggle.BackgroundColor3 = BG3
	toggle.Text = "OFF"
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 10
	toggle.TextColor3 = MUTED
	toggle.BorderSizePixel = 0
	toggle.AutoButtonColor = false
	toggle.Parent = row

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 9)
	toggleCorner.Parent = toggle

	local isOn = SlotState.enabled[tool.Name] == true
	local function refreshToggleVisual()
		toggle.Text = isOn and "ON" or "OFF"
		toggle.BackgroundColor3 = isOn and ACCENT or BG3
		toggle.TextColor3 = isOn and TEXT or MUTED
	end
	refreshToggleVisual()
	if isOn then createEquipButton(tool) end
	toggle.MouseButton1Click:Connect(function()
		isOn = not isOn
		SlotState.enabled[tool.Name] = isOn
		refreshToggleVisual()
		if isOn then
			createEquipButton(tool)
		else
			removeEquipButton(tool.Name)
		end
		saveSlotState()
	end)
end

local function scanInventory()
    if not (screen and screen.Parent and scroll and scroll.Parent) then return end
    local inventoryByName = {}
    local function collectTools(container)
        if not container then return end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                inventoryByName[item.Name] = item
                createItemRow(item)
            end
        end
    end
    collectTools(backpack)
    collectTools(player.Character)

    -- Remove rows/buttons only after the current Backpack and Character have both been scanned.
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") and not inventoryByName[child.Name] then
            removeEquipButton(child.Name)
            child:Destroy()
        end
    end
    for name, item in pairs(inventoryByName) do
        if SlotState.enabled[name] == true then
            createEquipButton(item)
        elseif activeEquips[name] then
            removeEquipButton(name)
        end
    end
    local count = 0
    for _ in pairs(inventoryByName) do count += 1 end
    itemCount.Text = count .. " item" .. (count ~= 1 and "s" or "")
    task.defer(function()
        if scroll and scroll.Parent and listLayout and listLayout.Parent then
            scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 14)
        end
    end)
end

local inventoryScanQueued = false
local function scheduleInventoryScan(delaySeconds)
    if inventoryScanQueued then return end
    inventoryScanQueued = true
    task.delay(delaySeconds or 0.06, function()
        inventoryScanQueued = false
        if screen and screen.Parent then scanInventory() end
    end)
end

local backpackConnections = {}
local function bindBackpack(newBackpack)
    for _, conn in ipairs(backpackConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(backpackConnections)
    if newBackpack and newBackpack:IsA("Backpack") then
        backpack = newBackpack
        table.insert(backpackConnections, slotConnect(backpack.ChildAdded, function() scheduleInventoryScan() end))
        table.insert(backpackConnections, slotConnect(backpack.ChildRemoved, function() scheduleInventoryScan() end))
    end
    scheduleInventoryScan(0.05)
end

local characterConnections = {}
local function bindCharacter(character)
    for _, conn in ipairs(characterConnections) do pcall(function() conn:Disconnect() end) end
    table.clear(characterConnections)
    if character then
        table.insert(characterConnections, slotConnect(character.ChildAdded, function() scheduleInventoryScan() end))
        table.insert(characterConnections, slotConnect(character.ChildRemoved, function() scheduleInventoryScan() end))
    end
    scheduleInventoryScan(0.08)
end

bindBackpack(backpack)
if player.Character then bindCharacter(player.Character) end
slotConnect(player.ChildAdded, function(child)
    if child:IsA("Backpack") or child.Name == "Backpack" then bindBackpack(child) end
end)
slotConnect(player.CharacterAdded, function(character)
    task.delay(0.35, function()
        bindCharacter(character)
        local currentBackpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
        if currentBackpack then bindBackpack(currentBackpack) else scheduleInventoryScan(0.2) end
    end)
end)
scanInventory()

task.spawn(function()
    while screen and screen.Parent do
        task.wait(5)
        scanInventory()
    end
    for _, conn in ipairs(backpackConnections) do pcall(function() conn:Disconnect() end) end
    for _, conn in ipairs(characterConnections) do pcall(function() conn:Disconnect() end) end
end)

print("[12Hub] Slot panel loaded")
end) -- end integrated 12Hub Slot panel task
