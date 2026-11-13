-- SLOT PANEL INDEPENDIENTE
-- Extraído del sistema SLOT de Monster Versus.
-- Ejecuta este archivo por separado; no requiere el menú Monster/Miau.
-- Nota: la configuración se conserva en memoria durante la sesión del ejecutor.

-- SLOT PANEL INDEPENDIENTE — compact integration of the full uploaded Slot/gear logic.
-- Equip buttons, settings sliders, lock, keybinds, cooldown and inventory logic preserved.
-- ============================================================
task.spawn(function() -- keep Slot locals out of the main chunk local-register limit
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local previousSlotConnections = _G._SlotPanelConnectionBag
if type(previousSlotConnections) == "table" then
    for _, conn in ipairs(previousSlotConnections) do pcall(function() conn:Disconnect() end) end
end
local slotConnectionBag = {}
_G._SlotPanelConnectionBag = slotConnectionBag
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

-- Estado independiente del panel SLOT; se conserva al volver a ejecutar en esta sesión.
local CoreGui = game:GetService("CoreGui")
local SlotState = type(_G._StandaloneSlotPanelState) == "table" and _G._StandaloneSlotPanelState or {}
_G._StandaloneSlotPanelState = SlotState
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
    _G._StandaloneSlotPanelState = SlotState
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
    local oldSlotGui = guiParent:FindFirstChild("SlotPanel_SlotPanel")
    if oldSlotGui then pcall(function() oldSlotGui:Destroy() end) end
end
local screen = Instance.new("ScreenGui")
screen.Name = "SlotPanel_SlotPanel"
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
        if _G._SlotPanelConnectionBag == slotConnectionBag then _G._SlotPanelConnectionBag = nil end
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
    local tpGui = CoreGui:FindFirstChild("SlotPanel_AllGearOnTop") or playerGui:FindFirstChild("SlotPanel_AllGearOnTop")
    return tpGui and tpGui:FindFirstChild("SlotPanel_TPPanelMain") or nil
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

print("[SLOT] Panel independiente cargado")
end) -- end integrated SlotPanel Slot panel task
