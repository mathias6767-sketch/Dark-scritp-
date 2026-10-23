-- Amateuz Anti Bee Solo
-- Standalone Roblox LocalScript / executor script. No Ilusion Hub or Rara menu required.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end

local old = player:WaitForChild("PlayerGui"):FindFirstChild("AmateuzAntiBeeSolo")
if old then old:Destroy() end

local state = { enabled = false, locked = false, connections = {}, originalMoveFunction = nil, controlsProtected = false }
local badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true }
local function nuke(obj)
    if obj and obj.Parent and badLightingNames[obj.Name] then pcall(function() obj:Destroy() end) end
end
local function disconnectAll()
    for _, c in ipairs(state.connections) do pcall(function() c:Disconnect() end) end
    table.clear(state.connections)
end
local function protectControls()
    pcall(function()
        local scripts = player:FindFirstChild("PlayerScripts")
        local module = scripts and scripts:FindFirstChild("PlayerModule")
        if not module then return end
        local controls = require(module):GetControls()
        if not controls then return end
        if not state.originalMoveFunction then state.originalMoveFunction = controls.moveFunction end
        local function protectedMove(self, moveVector, relativeToCamera)
            if state.originalMoveFunction then state.originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        state.protectedMove = protectedMove
        local acc = 0
        table.insert(state.connections, RunService.Heartbeat:Connect(function(dt)
            if not state.enabled then return end
            acc += dt
            if acc >= 0.25 then
                acc = 0
                if controls.moveFunction ~= protectedMove then controls.moveFunction = protectedMove end
            end
        end))
        controls.moveFunction = protectedMove
        state.controlsProtected = true
    end)
end
local function restoreControls()
    pcall(function()
        local scripts = player:FindFirstChild("PlayerScripts")
        local module = scripts and scripts:FindFirstChild("PlayerModule")
        if not module then return end
        local controls = require(module):GetControls()
        if controls and state.originalMoveFunction then controls.moveFunction = state.originalMoveFunction end
    end)
    state.controlsProtected = false
end
local function blockBuzzing()
    pcall(function()
        local scripts = player:FindFirstChild("PlayerScripts")
        local beeScript = scripts and scripts:FindFirstChild("Bee", true)
        local buzzing = beeScript and beeScript:FindFirstChild("Buzzing")
        if buzzing and buzzing:IsA("Sound") then buzzing:Stop(); buzzing.Volume = 0 end
    end)
end
local function setEnabled(on)
    state.enabled = on
    if on then
        for _, inst in ipairs(Lighting:GetDescendants()) do nuke(inst) end
        table.insert(state.connections, Lighting.DescendantAdded:Connect(function(obj)
            if state.enabled then nuke(obj) end
        end))
        protectControls()
        local acc = 0
        table.insert(state.connections, RunService.Heartbeat:Connect(function(dt)
            if not state.enabled then return end
            acc += dt
            if acc >= 0.25 then
                acc = 0
                blockBuzzing()
                local cam = workspace.CurrentCamera
                if cam then cam.FieldOfView = 70 end
            end
        end))
    else
        disconnectAll()
        restoreControls()
    end
    toggle.Text = state.enabled and "ANTI BEE: ON" or "ANTI BEE: OFF"
    toggle.BackgroundColor3 = state.enabled and Color3.fromRGB(29, 128, 70) or Color3.fromRGB(55, 55, 60)
end

local gui = Instance.new("ScreenGui")
gui.Name = "AmateuzAntiBeeSolo"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(600, 245)
main.Position = UDim2.new(0.5, -300, 0.5, -122)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 32)
local outline = Instance.new("UIStroke", main)
outline.Color = Color3.fromRGB(245, 245, 245)
outline.Thickness = 3

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(28, 16)
title.Size = UDim2.new(1, -210, 0, 68)
title.Font = Enum.Font.GothamBold
title.Text = "ANTI BEE"
title.TextSize = 36
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local lock = Instance.new("TextButton")
lock.Size = UDim2.fromOffset(155, 62)
lock.Position = UDim2.new(1, -180, 0, 20)
lock.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
lock.BorderSizePixel = 0
lock.Font = Enum.Font.GothamBold
lock.TextSize = 21
lock.TextColor3 = Color3.new(1, 1, 1)
lock.Text = "UNLOCK"
lock.Parent = main
Instance.new("UICorner", lock).CornerRadius = UDim.new(0, 15)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -52, 0, 96)
toggle.Position = UDim2.fromOffset(26, 125)
toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
toggle.BorderSizePixel = 0
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 31
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "ANTI BEE: OFF"
toggle.Parent = main
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 18)
toggle.MouseButton1Click:Connect(function() setEnabled(not state.enabled) end)
lock.MouseButton1Click:Connect(function()
    state.locked = not state.locked
    lock.Text = state.locked and "LOCKED" or "UNLOCK"
end)

-- Drag panel from its top area; lock prevents movement.
local dragging, dragStart, startPos = false, nil, nil
main.InputBegan:Connect(function(input)
    if state.locked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local y = input.Position.Y - main.AbsolutePosition.Y
        if y <= 75 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and not state.locked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

player.CharacterRemoving:Connect(function()
    if state.enabled then disconnectAll(); restoreControls() end
end)
