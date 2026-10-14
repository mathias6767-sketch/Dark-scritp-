--[[
 Elblue873 — Full Menu + Anti Trap
 Tab 1 Player: Anti Gummy/Ragdoll/Paintball/Boogie + Speed 3-mode (Vis S2 loop)
 + Tool Aimbot + Drop Jump/Stand + Insta V1/V2 + TP Down keybinds
 Tab 2 ESP: Player ESP + Tracker + Anti Lag (Vis logic)
 Tab 3 Settings: Mobile 3-mode buttons, Lock/Unlock, shape Box/Round/Square,
 per-button size +/-, Reset Mobile / Reset All
 Close menu: nút − | Open: mini kéo được | NO keybind to open/close
 + ANTI TRAP (Alas de Cupido) botón integrado
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
		"Elblue873HubFullMenu", "Elblue873HubFullMini", "Elblue873HubModeBar", "Elblue873HubActionButtons", "Elblue873Intro", "Elblue873HubIntro",
	}) do
		local g = PlayerGui:FindFirstChild(n)
		if g then g:Destroy() end
	end
end)

----------------------------------------------------------------
-- Elblue873.CC INTRO (red/black/white, music + skip)
----------------------------------------------------------------
do
	local TweenService = TS
	local SoundService = game:GetService("SoundService")
	local MUSIC_URL = "https://files.catbox.moe/qhpfe5.mp3"
	local MUSIC_FILE = "ShadowVS_Music.mp3"
	local MUSIC_VOLUME = 0.75
	local BPM = 100
	local BEAT = 60 / BPM
	local BACKGROUND_ID = "rbxassetid://77503307528071"
	local introActive = true
	local introFinished = false
	local introSound = nil
	local introGui = nil

	local function createIntro()
		for _, name in ipairs({"Elblue873Intro"}) do
			local old = PlayerGui:FindFirstChild(name)
			if old then old:Destroy() end
		end
		introGui = Instance.new("ScreenGui")
		introGui.Name = "Elblue873Intro"
		introGui.IgnoreGuiInset = true
		introGui.ResetOnSpawn = false
		introGui.DisplayOrder = 999999
		introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		introGui.Parent = PlayerGui

		local background = Instance.new("Frame", introGui)
		background.Size = UDim2.fromScale(1, 1)
		background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		background.BorderSizePixel = 0
		background.ClipsDescendants = true

		local bgImage = Instance.new("ImageLabel", background)
		bgImage.AnchorPoint = Vector2.new(0.5, 0.5)
		bgImage.Position = UDim2.fromScale(0.5, 0.5)
		bgImage.Size = UDim2.fromScale(1.08, 1.08)
		bgImage.BackgroundTransparency = 1
		bgImage.Image = BACKGROUND_ID
		bgImage.ImageTransparency = 1
		bgImage.ScaleType = Enum.ScaleType.Crop
		bgImage.ZIndex = 1

		local dark = Instance.new("Frame", background)
		dark.Size = UDim2.fromScale(1, 1)
		dark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dark.BackgroundTransparency = 0.35
		dark.BorderSizePixel = 0
		dark.ZIndex = 2

		local skip = Instance.new("TextButton", introGui)
		skip.AnchorPoint = Vector2.new(1, 0)
		skip.Position = UDim2.new(1, -14, 0, 14)
		skip.Size = UDim2.fromOffset(105, 36)
		skip.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
		skip.BackgroundTransparency = 0.15
		skip.BorderSizePixel = 0
		skip.Text = "SKIP INTRO"
		skip.TextColor3 = Color3.fromRGB(255, 255, 255)
		skip.TextSize = 12
		skip.Font = Enum.Font.GothamBold
		skip.AutoButtonColor = false
		skip.ZIndex = 500

		local skipCorner = Instance.new("UICorner", skip)
		skipCorner.CornerRadius = UDim.new(0, 7)
		local skipStroke = Instance.new("UIStroke", skip)
		skipStroke.Color = Color3.fromRGB(255, 0, 0)
		skipStroke.Transparency = 0.5
		skipStroke.Thickness = 1

		local flash = Instance.new("Frame", introGui)
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		flash.BackgroundTransparency = 1
		flash.BorderSizePixel = 0
		flash.ZIndex = 400

		local introTitle = Instance.new("TextLabel", background)
		introTitle.AnchorPoint = Vector2.new(0.5, 0.5)
		introTitle.Position = UDim2.fromScale(0.5, 0.47)
		introTitle.Size = UDim2.fromScale(1.1, 0.22)
		introTitle.BackgroundTransparency = 1
		introTitle.Text = "Elblue873"
		introTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
		introTitle.TextTransparency = 1
		introTitle.TextScaled = true
		introTitle.Font = Enum.Font.GothamBlack
		introTitle.ZIndex = 20

		local titleStroke = Instance.new("UIStroke", introTitle)
		titleStroke.Color = Color3.fromRGB(0, 0, 0)
		titleStroke.Thickness = 3
		titleStroke.Transparency = 1

		local introSubtitle = Instance.new("TextLabel", background)
		introSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
		introSubtitle.Position = UDim2.fromScale(0.5, 0.57)
		introSubtitle.Size = UDim2.fromScale(0.4, 0.08)
		introSubtitle.BackgroundTransparency = 1
		introSubtitle.Text = "cc"
		introSubtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		introSubtitle.TextTransparency = 1
		introSubtitle.TextScaled = true
		introSubtitle.Font = Enum.Font.GothamBold
		introSubtitle.ZIndex = 20

		local accentLine = Instance.new("Frame", background)
		accentLine.AnchorPoint = Vector2.new(0.5, 0.5)
		accentLine.Position = UDim2.fromScale(0.5, 0.52)
		accentLine.Size = UDim2.fromScale(0, 0.003)
		accentLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		accentLine.BackgroundTransparency = 1
		accentLine.BorderSizePixel = 0
		accentLine.ZIndex = 15

		local function loadMusic()
			local asset
			pcall(function()
				if isfile and isfile(MUSIC_FILE) then
					asset = getcustomasset(MUSIC_FILE)
				end
			end)
			if not asset then
				local success, data = pcall(function() return game:HttpGet(MUSIC_URL) end)
				if success and data and #data > 1000 then
					pcall(function() writefile(MUSIC_FILE, data) end)
					pcall(function() asset = getcustomasset(MUSIC_FILE) end)
				end
			end
			return asset
		end

		task.spawn(function()
			local asset = loadMusic()
			if not asset or not introActive then return end
			introSound = Instance.new("Sound")
			introSound.Name = "Elblue873IntroMusic"
			introSound.SoundId = asset
			introSound.Volume = MUSIC_VOLUME
			introSound.Looped = false
			introSound.Parent = SoundService
			pcall(function() introSound:Play() end)
		end)

		local function finishIntro()
			if introFinished then return end
			introFinished = true
			introActive = false
			if introSound then
				pcall(function()
					TweenService:Create(introSound, TweenInfo.new(0.35), { Volume = 0 }):Play()
				end)
				task.delay(0.4, function()
					pcall(function()
						introSound:Stop()
						introSound:Destroy()
					end)
				end)
			end
			pcall(function() introGui:Destroy() end)
		end

		skip.MouseButton1Click:Connect(finishIntro)
		skip.MouseEnter:Connect(function()
			TweenService:Create(skip, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(60, 0, 0) }):Play()
		end)
		skip.MouseLeave:Connect(function()
			TweenService:Create(skip, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(20, 0, 0) }):Play()
		end)

		TweenService:Create(bgImage, TweenInfo.new(1.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
		TweenService:Create(bgImage, TweenInfo.new(18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.fromScale(1.18, 1.18) }):Play()

		task.spawn(function()
			while introActive and introGui.Parent do
				flash.BackgroundTransparency = 0.75
				TweenService:Create(flash, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
				task.wait(BEAT)
			end
		end)

		task.wait(1.5)
		if not introActive then return end

		TweenService:Create(introTitle, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.9, 0.18), TextTransparency = 0
		}):Play()
		TweenService:Create(titleStroke, TweenInfo.new(0.5), { Transparency = 0 }):Play()
		TweenService:Create(accentLine, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.3, 0.003), BackgroundTransparency = 0
		}):Play()

		task.wait(1)
		for i = 1, 18 do
			if not introActive then return end
			introTitle.Position = UDim2.fromScale(0.5 + math.random(-8, 8) / 1000, 0.47 + math.random(-8, 8) / 1000)
			task.wait(0.025)
		end
		introTitle.Position = UDim2.fromScale(0.5, 0.47)

		TweenService:Create(introSubtitle, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()

		task.wait(7)
		if not introActive then return end
		for i = 1, 14 do
			if not introActive then return end
			flash.BackgroundTransparency = 0
			task.wait(0.025)
			flash.BackgroundTransparency = 1
			task.wait(0.065)
		end

		task.wait(2)
		if not introActive then return end

		TweenService:Create(introTitle, TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
		TweenService:Create(introSubtitle, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
		TweenService:Create(titleStroke, TweenInfo.new(1), { Transparency = 1 }):Play()
		TweenService:Create(accentLine, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(bgImage, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { ImageTransparency = 1 }):Play()
		TweenService:Create(dark, TweenInfo.new(1.5), { BackgroundTransparency = 1 }):Play()

		if introSound and introSound.Parent then
			TweenService:Create(introSound, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Volume = 0 }):Play()
		end

		local finalFade = Instance.new("Frame", introGui)
		finalFade.Size = UDim2.fromScale(1, 1)
		finalFade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		finalFade.BackgroundTransparency = 1
		finalFade.BorderSizePixel = 0
		finalFade.ZIndex = 1000
		TweenService:Create(finalFade, TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 0 }):Play()
		task.wait(1.6)
		finishIntro()
	end

	task.spawn(function() pcall(createIntro) end)
end

----------------------------------------------------------------
-- COLORS / STATE
----------------------------------------------------------------
local C = {
	bg = Color3.fromRGB(12, 12, 16), bg2 = Color3.fromRGB(18, 18, 24),
	card = Color3.fromRGB(24, 24, 32), stroke = Color3.fromRGB(60, 60, 80),
	accent = Color3.fromRGB(255, 20, 147), text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(160, 160, 180), on = Color3.fromRGB(60, 220, 110),
	off = Color3.fromRGB(40, 40, 52), box = Color3.fromRGB(32, 32, 44),
	danger = Color3.fromRGB(220, 70, 90),
	modeOnBg = Color3.fromRGB(255, 20, 147), modeOnTxt = Color3.fromRGB(255, 255, 255),
	modeOffBg = Color3.fromRGB(255, 255, 255), modeOffTxt = Color3.fromRGB(25, 25, 30),
	btnOn = Color3.fromRGB(50, 210, 100),
	btnOff = Color3.fromRGB(16, 16, 22),
}

-- [RESTO DEL SCRIPT ORIGINAL: TODO TU MENÚ, ESP, SPEED, AUTO STEAL, PANEL TP, LAGGER V2, SPEED BYPASS, ETC.]
-- ... (aquí va TODO el contenido de tu archivo Elblue873_ALL_GEAR.txt desde la línea después de COLORS/STATE hasta el final, sin cambios) ...

--==================================================
-- ANTI TRAP (Alas de Cupido) — botón integrado
--==================================================
task.spawn(function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

	local LP = Players.LocalPlayer
	if not LP then return end

	local AUTO_TOOL_NAME = "Alas de Cupido" -- ← Cambia por el nombre exacto
	local CHECK_TIME = 0.025
	local MOVEMENT_THRESHOLD = 0.015
	local COOLDOWN = 0.05

	local enabled = false
	local selectedToolName = nil
	local stuckTime = 0
	local lastPosition = nil
	local lastEquip = 0

	local function findTool(name)
		if not name then return nil end
		local backpack = LP:FindFirstChildOfClass("Backpack")
		if backpack then
			local tool = backpack:FindFirstChild(name)
			if tool and tool:IsA("Tool") then return tool end
		end
		local character = LP.Character
		if character then
			local tool = character:FindFirstChild(name)
			if tool and tool:IsA("Tool") then return tool end
		end
		return nil
	end

	local function activateTool(tool)
		pcall(function() tool:Activate() end)
		pcall(function()
			for _, c in ipairs(tool:GetDescendants()) do
				if c:IsA("RemoteEvent") then
					c:FireServer()
				elseif c:IsA("RemoteFunction") then
					pcall(function() c:InvokeServer() end)
				elseif c:IsA("ClickDetector") then
					pcall(function() c:FireServer() end)
				end
			end
		end)
	end

	local function equipAndInstantUnequip()
		if not enabled or not selectedToolName then return end
		local now = os.clock()
		if now - lastEquip < COOLDOWN then return end
		local character = LP.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local tool = findTool(selectedToolName)
		if not tool then return end
		lastEquip = now
		pcall(function() humanoid:EquipTool(tool) end)
		task.spawn(function()
			task.wait(0.03)
			activateTool(tool)
			task.wait(0.03)
			pcall(function() humanoid:UnequipTools() end)
		end)
	end

	task.spawn(function()
		task.wait(1)
		while not selectedToolName do
			local tool = findTool(AUTO_TOOL_NAME)
			if tool then
				selectedToolName = AUTO_TOOL_NAME
				print("[AntiTrap] Gear seleccionado: " .. AUTO_TOOL_NAME)
				break
			end
			task.wait(0.5)
		end
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		if not enabled or not selectedToolName then return end
		local character = LP.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root then return end
		if not lastPosition then
			lastPosition = root.Position
			return
		end
		local tryingToMove = humanoid.MoveDirection.Magnitude > 0.05
		local distance = (root.Position - lastPosition).Magnitude
		local actuallyMoving = distance > MOVEMENT_THRESHOLD
		if tryingToMove and not actuallyMoving then
			stuckTime += deltaTime
		else
			stuckTime = 0
		end
		lastPosition = root.Position
		if stuckTime >= CHECK_TIME then
			stuckTime = 0
			task.spawn(equipAndInstantUnequip)
		end
	end)

	local waited = 0
	while (not _G.Elblue873ApplyMobile) and waited < 10 do
		task.wait(0.2)
		waited += 0.2
	end

	local ActGui = nil
	pcall(function()
		local pg = LP:FindFirstChild("PlayerGui")
		ActGui = pg and pg:FindFirstChild("Elblue873HubActionButtons")
	end)
	if not ActGui then
		ActGui = Instance.new("ScreenGui")
		ActGui.Name = "Elblue873HubActionButtons"
		ActGui.ResetOnSpawn = false
		ActGui.IgnoreGuiInset = true
		ActGui.DisplayOrder = 2500
		ActGui.Enabled = true
		ActGui.Parent = LP:WaitForChild("PlayerGui")
	end

	local function applyCorner(btn, shape)
		if not btn then return end
		local s = shape or "Square"
		for _, ch in ipairs(btn:GetChildren()) do
			if ch:IsA("UICorner") then pcall(function() ch:Destroy() end) end
		end
		local rad
		if s == "Round" then rad = UDim.new(1, 0)
		elseif s == "Box" then rad = UDim.new(0, 12)
		elseif s == "Pill" then rad = UDim.new(0, 16)
		else rad = UDim.new(0, 2) end
		local c = Instance.new("UICorner")
		c.Name = "ShapeCorner"
		c.CornerRadius = rad
		c.Parent = btn
	end

	local function applyActBtnState(btn, on, onText, offText)
		if not btn then return end
		on = on and true or false
		if on then
			btn.BackgroundColor3 = Color3.fromRGB(0, 130, 45)
			btn.BackgroundTransparency = 0
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			if onText then btn.Text = onText end
			local tl = btn:FindFirstChild("BtnTextOverlay")
			if tl then
				if onText then tl.Text = onText end
				tl.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			local st = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(40, 255, 100); st.Transparency = 0; st.Thickness = 2.5 end
		else
			btn.BackgroundColor3 = C.btnOff or Color3.fromRGB(16, 16, 22)
			btn.BackgroundTransparency = 0.35
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			if offText then btn.Text = offText end
			local tl = btn:FindFirstChild("BtnTextOverlay")
			if tl then
				if offText then tl.Text = offText end
				tl.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			local st = btn:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(255, 80, 180); st.Transparency = 0.2; st.Thickness = 1.6 end
		end
	end

	local function getBtnSize()
		local St = _G.Elblue873St or nil
		local base = 56
		if St and St.btnSizes and St.btnSizes.steal then
			base = math.max(56, tonumber(St.btnSizes.steal) or 56)
		end
		local scale = 1
		if St and St.btnScale then scale = tonumber(St.btnScale) or 1 end
		return math.max(28, math.floor(base * scale))
	end

	local sz = getBtnSize()
	local holder = Instance.new("Frame")
	holder.Name = "A_antitrap"
	holder.Size = UDim2.new(0, sz, 0, sz)
	holder.Position = UDim2.new(1, -220, 0.5, 100)
	holder.BackgroundTransparency = 1
	holder.Active = true
	holder.ZIndex = 50
	holder.Parent = ActGui

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	btn.Text = "ANTI\nTRAP"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
	btn.Font = Enum.Font.GothamBold
	btn.TextWrapped = true
	btn.AutoButtonColor = false
	btn.Active = true
	btn.Selectable = true
	btn.ZIndex = 100
	btn.Parent = holder
	applyCorner(btn, "Square")

	local s = Instance.new("UIStroke")
	s.Name = "BtnBorder"
	s.Color = Color3.fromRGB(220, 220, 235)
	s.Thickness = 2
	s.Transparency = 0.15
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = btn

	local tl = Instance.new("TextLabel")
	tl.Name = "BtnTextOverlay"
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, -4, 1, -4)
	tl.Position = UDim2.new(0, 2, 0, 2)
	tl.Text = "ANTI\nTRAP"
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.TextStrokeTransparency = 0.35
	tl.TextStrokeColor3 = Color3.new(0, 0, 0)
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.TextWrapped = true
	tl.ZIndex = 105
	tl.Active = false
	tl.Parent = btn
	btn.TextTransparency = 1

	local dragging, dragStart, startPos = false, nil, nil
	local movedDistance = 0
	local TAP_MAX = 48

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			movedDistance = 0
			dragStart = input.Position
			startPos = holder.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not dragStart then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local d = input.Position - dragStart
		movedDistance = d.Magnitude
		if (St and St.guiLock) then return end
		if movedDistance > 8 then
			holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	btn.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if not dragging then return end
		dragging = false
		if movedDistance < TAP_MAX then
			enabled = not enabled
			stuckTime = 0
			local character = LP.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then lastPosition = root.Position end
			end
			applyActBtnState(btn, enabled, "ANTI\nTRAP\nON", "ANTI\nTRAP\nOFF")
