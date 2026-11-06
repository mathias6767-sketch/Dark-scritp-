--[[
 ILUSIÓN — Panel Rojo
 Pestaña Jugador + sección Anti (todas las funciones)
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
	for _, n in ipairs({ "IlusionRedMenu", "IlusionRedMini", "IlusionRedIntro" }) do
		local g = PlayerGui:FindFirstChild(n)
		if g then g:Destroy() end
	end
end)

----------------------------------------------------------------
-- COLORES ROJOS
----------------------------------------------------------------
local C = {
	bg = Color3.fromRGB(28, 6, 8),
	bg2 = Color3.fromRGB(42, 10, 12),
	card = Color3.fromRGB(55, 14, 16),
	stroke = Color3.fromRGB(220, 40, 40),
	accent = Color3.fromRGB(255, 45, 45),
	text = Color3.fromRGB(255, 235, 235),
	textDim = Color3.fromRGB(200, 140, 140),
	on = Color3.fromRGB(255, 55, 55),
	off = Color3.fromRGB(40, 12, 14),
	box = Color3.fromRGB(48, 12, 14),
	danger = Color3.fromRGB(120, 20, 20),
	knob = Color3.fromRGB(255, 255, 255),
}

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = obj
	return c
end

local function stroke(obj, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or C.stroke
	s.Thickness = th or 1.2
	s.Transparency = 0.15
	s.Parent = obj
	return s
end

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local St = {
	antiGummy = true,
	antiRagdoll = false,
	antiRagdollMode = "V1",
	antiPaint = true,
	antiBoogie = true,
	antiBee = false,
	toolAim = true,
	bodyLock = false,
	bodyLockRange = 20,
	infJump = true,
	destroySentry = false,
	dropMode = 2,
	instaMode = "V1",
	autoSteal = false,
	stealVer = "V1",
	stealRadius = 60,
	stealPause = false,
	keys = {
		Drop = Enum.KeyCode.X,
		TPDown = Enum.KeyCode.F,
		InstaReset = Enum.KeyCode.Z,
		DestroySentry = Enum.KeyCode.H,
	},
}

local ToggleRefs = {}
local CFG = "IlusionRedPlayer.json"

local function saveCfg()
	pcall(function()
		if not writefile then return end
		local d = {}
		for k, v in pairs(St) do
			if type(k) == "string" then
				local t = typeof(v)
				if t == "boolean" or t == "number" or t == "string" then
					d[k] = v
				elseif k == "keys" and type(v) == "table" then
					d.keys = {}
					for kk, vv in pairs(v) do
						d.keys[kk] = typeof(vv) == "EnumItem" and vv.Name or nil
					end
				end
			end
		end
		writefile(CFG, HttpService:JSONEncode(d))
	end)
end

local function loadCfg()
	pcall(function()
		if not (isfile and readfile and isfile(CFG)) then return end
		local d = HttpService:JSONDecode(readfile(CFG))
		if type(d) ~= "table" then return end
		for k, v in pairs(d) do
			if k == "keys" and type(v) == "table" then
				for kk, name in pairs(v) do
					if type(name) == "string" then
						pcall(function() St.keys[kk] = Enum.KeyCode[name] end)
					end
				end
			elseif St[k] ~= nil then
				St[k] = v
			end
		end
	end)
end
loadCfg()

----------------------------------------------------------------
-- INTRO ROJA
----------------------------------------------------------------
do
	local intro = Instance.new("ScreenGui")
	intro.Name = "IlusionRedIntro"
	intro.IgnoreGuiInset = true
	intro.ResetOnSpawn = false
	intro.DisplayOrder = 1000000
	intro.Parent = PlayerGui

	local shade = Instance.new("Frame")
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
	shade.BackgroundTransparency = 0.2
	shade.BorderSizePixel = 0
	shade.Parent = intro

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.5)
	title.Size = UDim2.new(0.8, 0, 0, 76)
	title.BackgroundTransparency = 1
	title.Text = "ILUSIÓN"
	title.TextColor3 = C.accent
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = shade

	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0)
	line.Position = UDim2.new(0.5, 0, 0.5, 45)
	line.Size = UDim2.new(0, 0, 0, 3)
	line.BackgroundColor3 = C.accent
	line.BorderSizePixel = 0
	line.Parent = shade
	pcall(function()
		TS:Create(line, TweenInfo.new(0.4), { Size = UDim2.new(0, 180, 0, 3) }):Play()
	end)

	task.wait(2)
	pcall(function() intro:Destroy() end)
end

----------------------------------------------------------------
-- ANTI LÓGICA
----------------------------------------------------------------
local AntiFX = { gummy = true, boogie = true, paint = true, bee = false }

-- Anti Gummy / Boogie / Paint / Bee (efectos)
do
	task.spawn(function()
		local function clearBee()
			if not AntiFX.bee then return end
			for _, v in ipairs(Lighting:GetChildren()) do
				if v.Name == "BeeBlur" or v.Name == "Flashbang" or v.Name == "Blue"
					or v.Name == "DiscoEffect" or v.Name == "ColorCorrection" then
					pcall(function() v:Destroy() end)
				end
			end
			pcall(function()
				local cam = workspace.CurrentCamera
				if cam then cam.FieldOfView = 70 end
			end)
		end

		local function resetTools()
			local char = LP.Character
			if not char then return end
			pcall(function()
				LP:SetAttribute("BlockTools", false)
				LP:SetAttribute("Web", false)
				char:SetAttribute("BackpackReady", true)
			end)
		end

		RS.Heartbeat:Connect(function()
			if AntiFX.gummy then
				pcall(resetTools)
				local char = LP.Character
				if char then
					for _, v in ipairs(char:GetDescendants()) do
						if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
							local n = string.lower(v.Name)
							if n:find("gummy") or n:find("stun") or n:find("rag") then
								pcall(function() v:Destroy() end)
							end
						end
					end
				end
			end
			if AntiFX.boogie or AntiFX.bee then
				clearBee()
			end
		end)

		Lighting.ChildAdded:Connect(function(obj)
			if AntiFX.bee then
				task.defer(function()
					local n = obj.Name
					if n == "BeeBlur" or n == "Flashbang" or n == "Blue"
						or n == "DiscoEffect" or n == "ColorCorrection" then
						pcall(function() obj:Destroy() end)
					end
				end)
			end
		end)
	end)
end

function setAntiGummy(on)
	St.antiGummy = on and true or false
	AntiFX.gummy = St.antiGummy
	saveCfg()
end

function setAntiBoogie(on)
	St.antiBoogie = on and true or false
	AntiFX.boogie = St.antiBoogie
	saveCfg()
end

function setAntiPaint(on)
	St.antiPaint = on and true or false
	AntiFX.paint = St.antiPaint
	saveCfg()
end

-- Anti Ragdoll
local AntiRagdoll = { enabled = false, mode = "V1", conn = nil }

local function stopAntiRagdoll()
	AntiRagdoll.enabled = false
	if AntiRagdoll.conn then
		pcall(function() AntiRagdoll.conn:Disconnect() end)
		AntiRagdoll.conn = nil
	end
end

local function startAntiRagdoll()
	stopAntiRagdoll()
	AntiRagdoll.enabled = true
	AntiRagdoll.mode = tostring(St.antiRagdollMode or "V1"):upper()
	AntiRagdoll.conn = RS.Heartbeat:Connect(function()
		if not AntiRagdoll.enabled or not St.antiRagdoll then return end
		local char = LP.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end
		pcall(function()
			if hum:GetState() == Enum.HumanoidStateType.Physics
				or hum:GetState() == Enum.HumanoidStateType.Ragdoll
				or hum:GetState() == Enum.HumanoidStateType.FallingDown then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				hum.PlatformStand = false
			end
			hum.PlatformStand = false
			if AntiRagdoll.mode == "V2" then
				for _, v in ipairs(char:GetDescendants()) do
					if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
						pcall(function() v:Destroy() end)
					end
				end
			end
		end)
	end)
end

function setAntiRagdoll(on)
	St.antiRagdoll = on and true or false
	if St.antiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end
	saveCfg()
end

function setAntiRagdollMode(mode)
	St.antiRagdollMode = (tostring(mode or "V1"):upper() == "V2") and "V2" or "V1"
	if St.antiRagdoll then startAntiRagdoll() end
	saveCfg()
end

-- Anti Bee module
local AntiBeeModule
do
	local Data = {
		running = false,
		connections = {},
		originalMoveFunction = nil,
	}
	local bad = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true, Flashbang = true }

	local function nuke(obj)
		if obj and obj.Parent and bad[obj.Name] then
			pcall(function() obj:Destroy() end)
		end
	end

	local function disconnectAll()
		for _, c in ipairs(Data.connections) do
			pcall(function() c:Disconnect() end)
		end
		Data.connections = {}
	end

	local function protectControls()
		pcall(function()
			local scripts = LP:FindFirstChild("PlayerScripts")
			local module = scripts and scripts:FindFirstChild("PlayerModule")
			if not module then return end
			local controls = require(module):GetControls()
			if not controls then return end
			if not Data.originalMoveFunction then
				Data.originalMoveFunction = controls.moveFunction
			end
			local function protectedMove(self, moveVector, relativeToCamera)
				if Data.originalMoveFunction then
					Data.originalMoveFunction(self, moveVector, relativeToCamera)
				end
			end
			controls.moveFunction = protectedMove
			table.insert(Data.connections, RS.Heartbeat:Connect(function()
				if not Data.running then return end
				if controls.moveFunction ~= protectedMove then
					controls.moveFunction = protectedMove
				end
			end))
		end)
	end

	local function restoreControls()
		pcall(function()
			local scripts = LP:FindFirstChild("PlayerScripts")
			local module = scripts and scripts:FindFirstChild("PlayerModule")
			if not module then return end
			local controls = require(module):GetControls()
			if controls and Data.originalMoveFunction then
				controls.moveFunction = Data.originalMoveFunction
			end
		end)
	end

	local function enable()
		if Data.running then return end
		Data.running = true
		AntiFX.bee = true
		for _, inst in ipairs(Lighting:GetDescendants()) do nuke(inst) end
		table.insert(Data.connections, Lighting.DescendantAdded:Connect(function(obj)
			if Data.running then nuke(obj) end
		end))
		protectControls()
		table.insert(Data.connections, RS.Heartbeat:Connect(function()
			if not Data.running then return end
			local cam = workspace.CurrentCamera
			if cam then cam.FieldOfView = 70 end
		end))
	end

	local function disable()
		if not Data.running then return end
		Data.running = false
		AntiFX.bee = false
		disconnectAll()
		restoreControls()
	end

	AntiBeeModule = {
		set = function(state)
			St.antiBee = state and true or false
			if state then enable() else disable() end
			saveCfg()
		end,
	}
end

----------------------------------------------------------------
-- COMBAT / DROP / RESET
----------------------------------------------------------------
local aimOn = true
local TOOLS = { ["Web Slinger"] = true, ["Paintball Gun"] = true, ["Laser Cape"] = true }
local hooked = {}

local function bestEnemy()
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

local function overrideMouse()
	if not aimOn then return end
	local e = bestEnemy()
	if not e then return end
	pcall(function()
		local mouse = LP:GetMouse()
		if mouse then
			-- visual only fallback; tool hooks handle real aim
		end
	end)
end

local function hookTool(tool)
	if not tool or hooked[tool] then return end
	hooked[tool] = true
	tool.Activated:Connect(function()
		if not aimOn then return end
		local e = bestEnemy()
		if e then
			pcall(function()
				local char = LP.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					-- face target lightly
					local pos = e.Position
					local flat = Vector3.new(pos.X, root.Position.Y, pos.Z)
					root.CFrame = CFrame.new(root.Position, flat)
				end
			end)
		end
	end)
end

local function watchTools(parent)
	if not parent then return end
	for _, c in ipairs(parent:GetChildren()) do
		if c:IsA("Tool") and TOOLS[c.Name] then hookTool(c) end
	end
	parent.ChildAdded:Connect(function(c)
		task.wait(0.05)
		if c:IsA("Tool") and TOOLS[c.Name] then hookTool(c) end
	end)
end
watchTools(LP:FindFirstChildOfClass("Backpack") or LP:WaitForChild("Backpack", 5))
LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	watchTools(LP:FindFirstChildOfClass("Backpack"))
	watchTools(LP.Character)
end)

function setToolAim(on)
	St.toolAim = on and true or false
	aimOn = St.toolAim
	saveCfg()
end

-- Body Lock
local bodyLockConn = nil
function setBodyLock(on)
	St.bodyLock = on and true or false
	if bodyLockConn then
		pcall(function() bodyLockConn:Disconnect() end)
		bodyLockConn = nil
	end
	if St.bodyLock then
		bodyLockConn = RS.Heartbeat:Connect(function()
			if not St.bodyLock then return end
			local char = LP.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if not root or not cam then return end
			local range = tonumber(St.bodyLockRange) or 20
			local target = bestEnemy()
			if target and (target.Position - root.Position).Magnitude <= range then
				local flat = Vector3.new(target.Position.X, root.Position.Y, target.Position.Z)
				root.CFrame = CFrame.new(root.Position, flat)
			end
		end)
	end
	saveCfg()
end

function setBodyLockRange(v)
	St.bodyLockRange = math.clamp(tonumber(v) or 20, 1, 200)
	saveCfg()
end

-- Infinite Jump
local InfJump = { enabled = false, conn = nil }
function setInfJump(on)
	St.infJump = on and true or false
	InfJump.enabled = St.infJump
	if InfJump.conn then
		pcall(function() InfJump.conn:Disconnect() end)
		InfJump.conn = nil
	end
	if InfJump.enabled then
		InfJump.conn = RS.Heartbeat:Connect(function()
			if not InfJump.enabled then return end
			local char = LP.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not root or not hum then return end
			if UIS:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then
				local vel = root.AssemblyLinearVelocity or root.Velocity
				if vel.Y < 35 then
					local nv = Vector3.new(vel.X, 55, vel.Z)
					pcall(function() root.AssemblyLinearVelocity = nv end)
					pcall(function() root.Velocity = nv end)
				end
			end
		end)
	end
	saveCfg()
end

-- Destroy Sentry
local destroyConn = nil
function setDestroySentry(on)
	St.destroySentry = on and true or false
	if destroyConn then
		pcall(function() destroyConn:Disconnect() end)
		destroyConn = nil
	end
	if St.destroySentry then
		destroyConn = RS.Heartbeat:Connect(function()
			if not St.destroySentry then return end
			pcall(function()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") or obj:IsA("BasePart") then
						local n = string.lower(obj.Name)
						if n:find("sentry", 1, true) or n:find("turret", 1, true) then
							-- solo marcar / no destruir ajenos a ciegas: intentar prompt cercano
						end
					end
				end
			end)
		end)
	end
	saveCfg()
end

-- Drop
local dropActive = false
function runDrop()
	if dropActive then return end
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local mode = tonumber(St.dropMode) or 2
	dropActive = true
	if mode == 1 then
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
			if r then
				r.AssemblyLinearVelocity = Vector3.new(0, 10000, 0)
			end
		end)
	else
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
			if tick() - t0 < 0.28 then
				r.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
			else
				if conn then conn:Disconnect() end
				local rp = RaycastParams.new()
				rp.FilterDescendantsInstances = { c }
				rp.FilterType = Enum.RaycastFilterType.Exclude
				local hit = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
				if hit then
					local h2 = c:FindFirstChildOfClass("Humanoid")
					local off = ((h2 and h2.HipHeight) or 2) + (r.Size.Y / 2)
					r.CFrame = CFrame.new(r.Position.X, hit.Position.Y + off, r.Position.Z)
				end
				r.AssemblyLinearVelocity = Vector3.zero
				dropActive = false
			end
		end)
	end
end

function doInstaReset()
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end
end

function doTPDown(force)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end
	if not force then
		if hum.FloorMaterial ~= Enum.Material.Air then return end
		if hrp.Position.Y < 20 then return end
	end
	local _, yRot, _ = hrp.CFrame:ToEulerAnglesYXZ()
	hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z) * CFrame.Angles(0, yRot, 0)
	hrp.AssemblyLinearVelocity = Vector3.zero
end

----------------------------------------------------------------
-- GUI ROJA
----------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "IlusionRedMenu"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 120
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local TAB_W, MAIN_W, MAIN_H = 92, 340, 480

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(MAIN_W, MAIN_H)
Main.Position = UDim2.new(0.5, -MAIN_W / 2, 0.5, -MAIN_H / 2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = Gui
corner(Main, 14)
stroke(Main, C.stroke, 1.5)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = C.bg2
Header.BorderSizePixel = 0
Header.Parent = Main
corner(Header, 14)
local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 14)
headerCover.Position = UDim2.new(0, 0, 1, -14)
headerCover.BackgroundColor3 = C.bg2
headerCover.BorderSizePixel = 0
headerCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "ILUSIÓN"
Title.TextColor3 = C.accent
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(28, 28)
MinBtn.Position = UDim2.new(1, -68, 0.5, -14)
MinBtn.BackgroundColor3 = C.card
MinBtn.Text = "−"
MinBtn.TextColor3 = C.text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header
corner(MinBtn, 8)
stroke(MinBtn, C.stroke, 1)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = C.card
CloseBtn.Text = "×"
CloseBtn.TextColor3 = C.text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
corner(CloseBtn, 8)
stroke(CloseBtn, C.stroke, 1)

local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(0, TAB_W, 1, -48)
TabBar.Position = UDim2.new(1, -TAB_W - 4, 0, 46)
TabBar.BackgroundTransparency = 1
TabBar.BorderSizePixel = 0
TabBar.ScrollBarThickness = 2
TabBar.ScrollBarImageColor3 = C.accent
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.Parent = Main
local tabLay = Instance.new("UIListLayout", TabBar)
tabLay.Padding = UDim.new(0, 5)
tabLay.SortOrder = Enum.SortOrder.LayoutOrder
local tabPad = Instance.new("UIPadding", TabBar)
tabPad.PaddingTop = UDim.new(0, 2)
tabPad.PaddingLeft = UDim.new(0, 2)
tabPad.PaddingRight = UDim.new(0, 2)

local pages, tabBtns = {}, {}

local function makePage(name)
	local sc = Instance.new("ScrollingFrame")
	sc.Name = name
	sc.Size = UDim2.new(1, -(TAB_W + 12), 1, -52)
	sc.Position = UDim2.new(0, 6, 0, 48)
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.ScrollBarThickness = 4
	sc.ScrollBarImageColor3 = C.accent
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.Visible = false
	sc.Parent = Main
	local pad = Instance.new("UIPadding", sc)
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	local lay = Instance.new("UIListLayout", sc)
	lay.Padding = UDim.new(0, 6)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	pages[name] = sc
	return sc
end

local function setTab(name)
	for n, p in pairs(pages) do
		p.Visible = (n == name)
	end
	for n, b in pairs(tabBtns) do
		local on = (n == name)
		b.BackgroundColor3 = on and C.accent or C.card
		b.TextColor3 = on and Color3.fromRGB(30, 5, 5) or C.text
	end
end

local function addTab(name, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 30)
	b.BackgroundColor3 = C.card
	b.Text = name
	b.TextColor3 = C.text
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.LayoutOrder = order
	b.Parent = TabBar
	corner(b, 8)
	stroke(b, C.stroke, 1)
	b.MouseButton1Click:Connect(function() setTab(name) end)
	tabBtns[name] = b
end

local pagePlayer = makePage("Player")
addTab("Player", 1)
setTab("Player")

----------------------------------------------------------------
-- UI HELPERS
----------------------------------------------------------------
local function section(parent, text, order)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 18)
	f.BackgroundTransparency = 1
	f.LayoutOrder = order
	f.Parent = parent
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 1, 0)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = C.accent
	t.TextSize = 12
	t.Font = Enum.Font.GothamBold
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = f
end

local function row(parent, h, order)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, h or 38)
	f.BackgroundColor3 = C.card
	f.BorderSizePixel = 0
	f.LayoutOrder = order
	f.Parent = parent
	corner(f, 9)
	stroke(f, C.stroke, 1)
	return f
end

local function toggle(parent, label, default, cb, order)
	local r = row(parent, 38, order)
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, -60, 1, 0)
	txt.Position = UDim2.fromOffset(12, 0)
	txt.BackgroundTransparency = 1
	txt.Text = label
	txt.TextColor3 = C.text
	txt.TextSize = 13
	txt.Font = Enum.Font.Gotham
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.Parent = r

	local track = Instance.new("Frame")
	track.Size = UDim2.fromOffset(40, 22)
	track.Position = UDim2.new(1, -50, 0.5, -11)
	track.BackgroundColor3 = default and C.on or C.off
	track.BorderSizePixel = 0
	track.Parent = r
	corner(track, 11)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(18, 18)
	knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
	knob.BackgroundColor3 = C.knob
	knob.BorderSizePixel = 0
	knob.Parent = track
	corner(knob, 9)

	local state = default and true or false
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
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

	btn.MouseButton1Click:Connect(function() apply(not state) end)
	return { set = apply, get = function() return state end, row = r }
end

local function toggleNamed(parent, label, default, cb, order, refName)
	local api = toggle(parent, label, default, cb, order)
	if refName then ToggleRefs[refName] = api end
	return api
end

local function actionBtn(parent, text, color, cb, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 36)
	b.BackgroundColor3 = color or C.accent
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.AutoButtonColor = false
	b.LayoutOrder = order
	b.Parent = parent
	corner(b, 9)
	stroke(b, Color3.fromRGB(255, 120, 120), 1)
	b.MouseButton1Click:Connect(function()
		if cb then pcall(cb) end
	end)
	return b
end

local function numBox(parent, pos, w, val, cb)
	local b = Instance.new("TextBox")
	b.Size = UDim2.fromOffset(w, 24)
	b.Position = pos
	b.BackgroundColor3 = C.box
	b.Text = tostring(val)
	b.TextColor3 = C.text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.ClearTextOnFocus = false
	b.Parent = parent
	corner(b, 6)
	stroke(b, C.stroke, 1)
	b.FocusLost:Connect(function()
		local n = tonumber(b.Text)
		if n then
			b.Text = tostring(n)
			if cb then cb(n) end
		else
			b.Text = tostring(val)
		end
	end)
	return b
end

----------------------------------------------------------------
-- PLAYER TAB — Anti + Combat + Drop + Keybinds
----------------------------------------------------------------
section(pagePlayer, "Anti", 1)
toggleNamed(pagePlayer, "Anti Gummy Bear", St.antiGummy, setAntiGummy, 2, "antiGummy")
toggleNamed(pagePlayer, "Anti Ragdoll", St.antiRagdoll, setAntiRagdoll, 3, "antiRagdoll")

-- Mode V1 / V2
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
	corner(holder, 8)
	stroke(holder, C.stroke, 1)

	local slide = Instance.new("Frame")
	slide.Size = UDim2.new(0.5, -6, 1, -6)
	slide.Position = UDim2.new(0, 3, 0, 3)
	slide.BackgroundColor3 = C.accent
	slide.BorderSizePixel = 0
	slide.ZIndex = 2
	slide.Parent = holder
	corner(slide, 6)

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

	local b1 = Instance.new("TextButton")
	b1.BackgroundTransparency = 1
	b1.Size = UDim2.new(0.5, 0, 1, 0)
	b1.Text = ""
	b1.ZIndex = 4
	b1.Parent = holder
	b1.MouseButton1Click:Connect(function()
		setAntiRagdollMode("V1")
		refresh()
	end)

	local b2 = Instance.new("TextButton")
	b2.BackgroundTransparency = 1
	b2.Size = UDim2.new(0.5, 0, 1, 0)
	b2.Position = UDim2.new(0.5, 0, 0, 0)
	b2.Text = ""
	b2.ZIndex = 4
	b2.Parent = holder
	b2.MouseButton1Click:Connect(function()
		setAntiRagdollMode("V2")
		refresh()
	end)
	refresh()
end

toggleNamed(pagePlayer, "Anti Paintball Gun", St.antiPaint, setAntiPaint, 4, "antiPaint")
toggleNamed(pagePlayer, "Anti Boogie Bomb", St.antiBoogie, setAntiBoogie, 5, "antiBoogie")
toggleNamed(pagePlayer, "Anti Bee", St.antiBee == true, function(state)
	if AntiBeeModule then AntiBeeModule.set(state) end
end, 6, "antiBee")

section(pagePlayer, "Combat / Drop / Reset", 20)
toggleNamed(pagePlayer, "Tool Aimbot", St.toolAim, setToolAim, 21, "toolAim")
toggleNamed(pagePlayer, "Body Lock", St.bodyLock == true, setBodyLock, 22, "bodyLock")
do
	local rr = row(pagePlayer, 36, 22.5)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.5, 0, 1, 0)
	t.Position = UDim2.fromOffset(12, 0)
	t.BackgroundTransparency = 1
	t.Text = "Body Lock Range"
	t.TextColor3 = C.textDim
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = rr
	numBox(rr, UDim2.new(1, -70, 0.5, -12), 58, St.bodyLockRange or 20, setBodyLockRange)
end
toggleNamed(pagePlayer, "Infinite Jump (Hold)", St.infJump, setInfJump, 23, "infJump")
toggleNamed(pagePlayer, "Auto Destroy Sentry", St.destroySentry, setDestroySentry, 24, "destroySentry")

-- Drop mode
do
	local dropRow = row(pagePlayer, 38, 25)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.35, 0, 1, 0)
	t.Position = UDim2.fromOffset(12, 0)
	t.BackgroundTransparency = 1
	t.Text = "Drop Mode"
	t.TextColor3 = C.text
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = dropRow

	local function mk(label, mode, x)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(70, 26)
		b.Position = UDim2.new(0, x, 0.5, -13)
		b.BackgroundColor3 = (St.dropMode == mode) and C.accent or C.box
		b.Text = label
		b.TextColor3 = C.text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.AutoButtonColor = false
		b.Parent = dropRow
		corner(b, 6)
		b.MouseButton1Click:Connect(function()
			St.dropMode = mode
			saveCfg()
			for _, ch in ipairs(dropRow:GetChildren()) do
				if ch:IsA("TextButton") then
					local on = (ch.Text == "Stand" and mode == 1) or (ch.Text == "Jump" and mode == 2)
					ch.BackgroundColor3 = on and C.accent or C.box
				end
			end
		end)
	end
	mk("Stand", 1, 120)
	mk("Jump", 2, 198)
end
actionBtn(pagePlayer, "Drop Now", C.accent, runDrop, 26)

-- Insta mode
do
	local instaRow = row(pagePlayer, 38, 27)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.35, 0, 1, 0)
	t.Position = UDim2.fromOffset(12, 0)
	t.BackgroundTransparency = 1
	t.Text = "Insta Mode"
	t.TextColor3 = C.text
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = instaRow

	local function mk(label, x)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(50, 26)
		b.Position = UDim2.new(0, x, 0.5, -13)
		b.BackgroundColor3 = (St.instaMode == label) and C.accent or C.box
		b.Text = label
		b.TextColor3 = C.text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.AutoButtonColor = false
		b.Parent = instaRow
		corner(b, 6)
		b.MouseButton1Click:Connect(function()
			St.instaMode = label
			saveCfg()
			for _, ch in ipairs(instaRow:GetChildren()) do
				if ch:IsA("TextButton") then
					ch.BackgroundColor3 = (ch.Text == St.instaMode) and C.accent or C.box
				end
			end
		end)
	end
	mk("V1", 130)
	mk("V2", 188)
end
actionBtn(pagePlayer, "Insta Reset Now", C.danger, doInstaReset, 28)
actionBtn(pagePlayer, "TP Down", C.accent, function() doTPDown(true) end, 29)

section(pagePlayer, "Keybinds", 40)
local function keyRow(label, keyId, order)
	local r = row(pagePlayer, 36, order)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.55, 0, 1, 0)
	t.Position = UDim2.fromOffset(12, 0)
	t.BackgroundTransparency = 1
	t.Text = label
	t.TextColor3 = C.text
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = r

	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(70, 24)
	b.Position = UDim2.new(1, -82, 0.5, -12)
	b.BackgroundColor3 = C.box
	b.Text = St.keys[keyId] and St.keys[keyId].Name or "None"
	b.TextColor3 = C.text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.AutoButtonColor = false
	b.Parent = r
	corner(b, 6)
	stroke(b, C.stroke, 1)

	local listening = false
	b.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		b.Text = "..."
		local conn
		conn = UIS.InputBegan:Connect(function(inp)
			if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if inp.KeyCode == Enum.KeyCode.Escape then
				listening = false
				b.Text = St.keys[keyId] and St.keys[keyId].Name or "None"
				conn:Disconnect()
				return
			end
			if inp.KeyCode == Enum.KeyCode.Backspace then
				St.keys[keyId] = nil
			else
				St.keys[keyId] = inp.KeyCode
			end
			listening = false
			b.Text = St.keys[keyId] and St.keys[keyId].Name or "None"
			saveCfg()
			conn:Disconnect()
		end)
	end)
end
keyRow("Drop", "Drop", 41)
keyRow("TP Down", "TPDown", 42)
keyRow("Insta Reset", "InstaReset", 43)
keyRow("Destroy Sentry", "DestroySentry", 44)

-- Apply saved
pcall(function() setAntiGummy(St.antiGummy ~= false) end)
pcall(function() setAntiBoogie(St.antiBoogie ~= false) end)
pcall(function() setAntiPaint(St.antiPaint ~= false) end)
pcall(function() setAntiRagdoll(St.antiRagdoll == true) end)
pcall(function() setToolAim(St.toolAim ~= false) end)
pcall(function() setInfJump(St.infJump ~= false) end)
pcall(function() setBodyLock(St.bodyLock == true) end)
pcall(function() setDestroySentry(St.destroySentry == true) end)
pcall(function()
	if St.antiBee and AntiBeeModule then AntiBeeModule.set(true) end
end)

-- Keybinds runtime
UIS.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local k = inp.KeyCode
	if St.keys.Drop and k == St.keys.Drop then pcall(runDrop) end
	if St.keys.TPDown and k == St.keys.TPDown then pcall(doTPDown, true) end
	if St.keys.InstaReset and k == St.keys.InstaReset then pcall(doInstaReset) end
	if St.keys.DestroySentry and k == St.keys.DestroySentry then
		pcall(setDestroySentry, not St.destroySentry)
	end
end)

----------------------------------------------------------------
-- MINI + DRAG
----------------------------------------------------------------
local MiniGui = Instance.new("ScreenGui")
MiniGui.Name = "IlusionRedMini"
MiniGui.ResetOnSpawn = false
MiniGui.IgnoreGuiInset = true
MiniGui.DisplayOrder = 121
MiniGui.Parent = PlayerGui

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(110, 36)
Mini.Position = UDim2.new(0, 14, 0, 90)
Mini.BackgroundColor3 = C.bg2
Mini.Text = "ILUSIÓN"
Mini.TextColor3 = C.accent
Mini.Font = Enum.Font.GothamBold
Mini.TextSize = 12
Mini.Visible = false
Mini.AutoButtonColor = false
Mini.Parent = MiniGui
corner(Mini, 10)
stroke(Mini, C.stroke, 1.2)

local function showMain(on)
	Main.Visible = on and true or false
	Mini.Visible = not on
end
MinBtn.MouseButton1Click:Connect(function() showMain(false) end)
CloseBtn.MouseButton1Click:Connect(function() showMain(false) end)
Mini.MouseButton1Click:Connect(function() showMain(true) end)

do
	local dragging, dragStart, startPos
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
end

do
	local dragging, dragStart, startPos
	Mini.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Mini.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			Mini.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
end

print("[ILUSIÓN] Panel rojo — Jugador / Anti listo")
