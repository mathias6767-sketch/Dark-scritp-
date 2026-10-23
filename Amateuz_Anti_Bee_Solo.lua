-- Amateuz Anti Bee standalone | ON/OFF | draggable | lock/unlock
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Bee = { running = false, connections = {}, controls = nil, originalMoveFunction = nil,
    badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true } }

local function disconnectConnections()
    for _, conn in ipairs(Bee.connections) do pcall(function() conn:Disconnect() end) end
    table.clear(Bee.connections)
end

local function removeEffect(obj)
    if obj and obj.Parent and Bee.badLightingNames[obj.Name] then
        pcall(function() obj:Destroy() end)
    end
end

local function protectControls()
    pcall(function()
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        local playerModule = scripts and scripts:FindFirstChild("PlayerModule")
        if not playerModule then return end
        local controls = require(playerModule):GetControls()
        if not controls then return end
        Bee.controls = controls
        if not Bee.originalMoveFunction then Bee.originalMoveFunction = controls.moveFunction end
        local original = Bee.originalMoveFunction
        Bee.protectedMoveFunction = function(self, moveVector, relativeToCamera)
            if original then return original(self, moveVector, relativeToCamera) end
        end
        controls.moveFunction = Bee.protectedMoveFunction
    end)
end

local function blockBuzz()
    pcall(function()
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        local beeScript = scripts and scripts:FindFirstChild("Bee", true)
        local sound = beeScript and beeScript:FindFirstChild("Buzzing", true)
        if sound and sound:IsA("Sound") then sound:Stop(); sound.Volume = 0 end
    end)
end

local function setAntiBee(enabled)
    if enabled == Bee.running then return end
    Bee.running = enabled
    if enabled then
        for _, obj in ipairs(Lighting:GetDescendants()) do removeEffect(obj) end
        table.insert(Bee.connections, Lighting.DescendantAdded:Connect(function(obj)
            if Bee.running then removeEffect(obj) end
        end))
        protectControls()
        local elapsed = 0
        table.insert(Bee.connections, RunService.Heartbeat:Connect(function(dt)
            if not Bee.running then return end
            elapsed += dt
            if elapsed < 0.25 then return end
            elapsed = 0
            pcall(function()
                if Bee.controls and Bee.protectedMoveFunction and Bee.controls.moveFunction ~= Bee.protectedMoveFunction then
                    Bee.controls.moveFunction = Bee.protectedMoveFunction
                elseif not Bee.controls then protectControls() end
            end)
            blockBuzz()
            pcall(function() if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = 70 end end)
        end))
    else
        pcall(function()
            if Bee.controls and Bee.originalMoveFunction then Bee.controls.moveFunction = Bee.originalMoveFunction end
        end)
        Bee.controls = nil
        disconnectConnections()
    end
    toggleBtn.Text = enabled and "ANTI BEE: ON" or "ANTI BEE: OFF"
    toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(30, 125, 65) or Color3.fromRGB(120, 35, 45)
end

local old = PlayerGui:FindFirstChild("AmateuzAntiBeePanel")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "AmateuzAntiBeePanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10020
gui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "AntiBeePanel"
panel.Size = UDim2.new(0, 390, 0, 155)
panel.Position = UDim2.new(0.5, -195, 0.5, -78)
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 24)
local outline = Instance.new("UIStroke", panel)
outline.Color = Color3.fromRGB(255, 255, 255)
outline.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -180, 0, 55)
title.Position = UDim2.new(0, 20, 0, 8)
title.BackgroundTransparency = 1
title.Text = "ANTI BEE"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local lock = Instance.new("TextButton")
lock.Size = UDim2.new(0, 115, 0, 44)
lock.Position = UDim2.new(1, -132, 0, 10)
lock.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
lock.BorderSizePixel = 0
lock.TextColor3 = Color3.new(1, 1, 1)
lock.Font = Enum.Font.GothamBold
lock.TextSize = 16
lock.Text = "UNLOCK"
lock.Parent = panel
Instance.new("UICorner", lock).CornerRadius = UDim.new(0, 14)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -28, 0, 64)
toggleBtn.Position = UDim2.new(0, 14, 0, 76)
toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 35, 45)
toggleBtn.BorderSizePixel = 0
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 22
toggleBtn.Text = "ANTI BEE: OFF"
toggleBtn.Parent = panel
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 16)
toggleBtn.Activated:Connect(function() setAntiBee(not Bee.running) end)

local locked = false
lock.Activated:Connect(function()
    locked = not locked
    lock.Text = locked and "LOCKED" or "UNLOCK"
    lock.BackgroundColor3 = locked and Color3.fromRGB(145, 45, 55) or Color3.fromRGB(35, 35, 40)
end)

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
panel.InputBegan:Connect(function(input)
    if locked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.Y <= panel.AbsolutePosition.Y + 64 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end
end)
panel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging or locked then return end
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

gui.Destroying:Connect(function()
    if Bee.running then setAntiBee(false) end
end)
