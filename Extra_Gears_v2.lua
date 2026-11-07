-- EXTRA GEARS | Panel compacto
-- Selector del panel: muestra/oculta el boton flotante de cada herramienta.
-- El boton flotante activa la herramienta; al apagarlo, desaparece.

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local old = game:GetService("CoreGui"):FindFirstChild("MultiUI")
if old then old:Destroy() end

local SAVE_FILE = "MultiUI_Settings.json"

local GearData = {
    {name = "Potion", key = "ButtonT", keywords = {"giant", "khổng", "huge"}},
    {name = "Paintball", key = "ButtonPaintball", keywords = {"paintball"}},
    {name = "Candy Center", key = "ButtonCandy", keywords = {"candy center", "candy"}},
    {name = "Subspace", key = "ButtonSubspace", keywords = {"subspace"}},
    {name = "Blackhole", key = "ButtonBlackBomb", keywords = {"blackhole bomb", "black hole bomb", "blackholebomb"}},
    {name = "Sentry", key = "ButtonSentry", keywords = {"all seeing", "allseeing", "sentry"}},
    {name = "Web Sling", key = "ButtonWebSlinger", keywords = {"web slinger", "webslinger", "web"}},
    {name = "Medusa", key = "ButtonMedusa", keywords = {"medusa"}},
    {name = "Trap", key = "ButtonTrap", keywords = {"trap"}}
}

local Defaults = {
    PanelX = -140, PanelY = -180,
    Shape = "Rounded",
    Sizes = {},
    Positions = {}
}
for i, gear in ipairs(GearData) do
    Defaults.Sizes[gear.key] = 50
    Defaults.Positions[gear.key] = {X = -85 + ((i - 1) % 2) * 90, Y = -100 + math.floor((i - 1) / 2) * 75}
end

local Settings = {
    PanelX = Defaults.PanelX,
    PanelY = Defaults.PanelY,
    Shape = Defaults.Shape,
    Sizes = {},
    Positions = {}
}
for key, value in pairs(Defaults.Sizes) do Settings.Sizes[key] = value end
for key, value in pairs(Defaults.Positions) do
    Settings.Positions[key] = {X = value.X, Y = value.Y}
end

pcall(function()
    if isfile and isfile(SAVE_FILE) then
        local saved = HttpService:JSONDecode(readfile(SAVE_FILE))
        if type(saved) == "table" then
            Settings.PanelX = tonumber(saved.PanelX) or Settings.PanelX
            Settings.PanelY = tonumber(saved.PanelY) or Settings.PanelY
            Settings.Shape = saved.Shape == "Circle" and "Circle" or "Rounded"
            if type(saved.Sizes) == "table" then
                for key, value in pairs(saved.Sizes) do
                    if Settings.Sizes[key] then
                        Settings.Sizes[key] = math.clamp(tonumber(value) or 50, 30, 100)
                    end
                end
            end
            if type(saved.Positions) == "table" then
                for key, value in pairs(saved.Positions) do
                    if Settings.Positions[key] and type(value) == "table" then
                        Settings.Positions[key].X = tonumber(value.X) or Settings.Positions[key].X
                        Settings.Positions[key].Y = tonumber(value.Y) or Settings.Positions[key].Y
                    end
                end
            end
        end
    end
end)

local function SaveSettings()
    pcall(function()
        if writefile then writefile(SAVE_FILE, HttpService:JSONEncode(Settings)) end
    end)
end

local Colors = {
    panel = Color3.fromRGB(8, 15, 30),
    panel2 = Color3.fromRGB(18, 31, 53),
    button = Color3.fromRGB(7, 13, 25),
    blue = Color3.fromRGB(78, 148, 238),
    blueDark = Color3.fromRGB(31, 66, 117),
    border = Color3.fromRGB(77, 108, 151),
    white = Color3.fromRGB(245, 248, 255),
    muted = Color3.fromRGB(150, 174, 204),
    green = Color3.fromRGB(55, 175, 112)
}

local gui = Instance.new("ScreenGui")
gui.Name = "MultiUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = obj
end

local function addStroke(obj, thickness)
    local s = Instance.new("UIStroke")
    s.Color = Colors.border
    s.Thickness = thickness or 1.5
    s.Parent = obj
end

local function rounded(obj)
    if Settings.Shape == "Circle" then
        addCorner(obj, UDim.new(1, 0))
    else
        addCorner(obj, UDim.new(0, 12))
    end
end

local function makeButton(parent, text, size, pos, color)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = color or Colors.button
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Colors.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = true
    addCorner(b, UDim.new(0, 10))
    addStroke(b, 1.3)
    return b
end

-- Panel: aproximadamente la mitad del tamaño de un hub grande.
local panel = Instance.new("Frame")
panel.Name = "ExtraGearsPanel"
panel.Parent = gui
panel.Size = UDim2.fromOffset(285, 365)
panel.Position = UDim2.new(0.5, Settings.PanelX, 0.5, Settings.PanelY)
panel.BackgroundColor3 = Colors.panel
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
addCorner(panel, UDim.new(0, 20))
addStroke(panel, 2)

local header = Instance.new("Frame")
header.Parent = panel
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel")
title.Parent = header
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 5)
title.Size = UDim2.new(1, -65, 0, 27)
title.Text = "EXTRA GEARS"
title.TextColor3 = Colors.white
title.Font = Enum.Font.GothamBlack
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel")
subtitle.Parent = header
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(15, 31)
subtitle.Size = UDim2.new(1, -65, 0, 16)
subtitle.Text = "Gear menu"
subtitle.TextColor3 = Colors.muted
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = makeButton(header, "-", UDim2.fromOffset(34, 34), UDim2.new(1, -44, 0, 9), Colors.panel2)
closeButton.TextSize = 21

local topControls = Instance.new("Frame")
topControls.Parent = panel
topControls.BackgroundTransparency = 1
topControls.Position = UDim2.fromOffset(10, 59)
topControls.Size = UDim2.new(1, -20, 0, 36)

local lockButton = makeButton(topControls, "LOCK: OFF", UDim2.new(0.49, -3, 1, 0), UDim2.new(0, 0, 0, 0), Colors.panel2)
local shapeButton = makeButton(topControls, "SHAPE: CURVED", UDim2.new(0.49, -3, 1, 0), UDim2.new(0.51, 3, 0, 0), Colors.panel2)
lockButton.TextSize = 11
shapeButton.TextSize = 11

local sizeTitle = Instance.new("TextLabel")
sizeTitle.Parent = panel
sizeTitle.BackgroundTransparency = 1
sizeTitle.Position = UDim2.fromOffset(12, 101)
sizeTitle.Size = UDim2.new(1, -24, 0, 18)
sizeTitle.Text = "SELECT A GEAR  •  SIZE"
sizeTitle.TextColor3 = Colors.muted
sizeTitle.Font = Enum.Font.GothamBold
sizeTitle.TextSize = 10
sizeTitle.TextXAlignment = Enum.TextXAlignment.Left

local list = Instance.new("ScrollingFrame")
list.Parent = panel
list.Position = UDim2.fromOffset(10, 123)
list.Size = UDim2.new(1, -20, 1, -133)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = Colors.blue
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = list
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local rows = {}
local floating = {}
local locked = false
local selectedKey = nil
local panelOpen = true

-- Boton minimizado para volver a abrir el panel.
local launcher = makeButton(gui, "EXTRA\nGEARS", UDim2.fromOffset(58, 58),
    UDim2.new(0.5, Settings.PanelX + 112, 0.5, Settings.PanelY + 155), Colors.panel)
launcher.Visible = false
launcher.TextSize = 10
rounded(launcher)
addStroke(launcher, 2)

local function useTool(keywords)
    local character = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:UnequipTools() end
    task.wait(0.1)

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local lowerName = string.lower(tool.Name)
            for _, keyword in ipairs(keywords) do
                if string.find(lowerName, keyword, 1, true) then
                    tool.Parent = character
                    task.wait(0.2)
                    pcall(function() tool:Activate() end)
                    return
                end
            end
        end
    end
end

local function removeFloating(key)
    if floating[key] then
        floating[key]:Destroy()
        floating[key] = nil
    end
    if rows[key] then
        rows[key].selector.Text = rows[key].name
        rows[key].selector.BackgroundColor3 = Colors.button
    end
end

local function makeFloating(gear)
    if locked or floating[gear.key] then return end

    local size = Settings.Sizes[gear.key]
    local pos = Settings.Positions[gear.key]
    local b = Instance.new("TextButton")
    b.Name = gear.key .. "_FloatingButton"
    b.Parent = gui
    b.Size = UDim2.fromOffset(size, size)
    b.Position = UDim2.new(0.5, pos.X, 0.5, pos.Y)
    b.BackgroundColor3 = Colors.blueDark
    b.BorderSizePixel = 0
    b.Text = gear.name .. "\nON"
    b.TextColor3 = Colors.white
    b.Font = Enum.Font.GothamBlack
    b.TextScaled = true
    b.TextWrapped = true
    b.AutoButtonColor = true
    rounded(b)
    addStroke(b, 2)
    floating[gear.key] = b

    local dragging = false
    local dragStart, startPos
    b.InputBegan:Connect(function(input)
        if locked then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = b.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and not locked and
            (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            b.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Settings.Positions[gear.key].X = b.Position.X.Offset
            Settings.Positions[gear.key].Y = b.Position.Y.Offset
            SaveSettings()
        end
    end)

    b.MouseButton1Click:Connect(function()
        if locked then return end
        useTool(gear.keywords)
        removeFloating(gear.key)
    end)

    rows[gear.key].selector.Text = gear.name .. "  ON"
    rows[gear.key].selector.BackgroundColor3 = Colors.blueDark
end

for index, gear in ipairs(GearData) do
    local row = Instance.new("Frame")
    row.Parent = list
    row.Size = UDim2.new(1, -3, 0, 43)
    row.BackgroundTransparency = 1
    row.LayoutOrder = index

    local selector = makeButton(row, gear.name, UDim2.new(1, -91, 1, 0), UDim2.new(0, 0, 0, 0), Colors.button)
    selector.TextSize = 12

    local sizeBox = Instance.new("Frame")
    sizeBox.Parent = row
    sizeBox.Position = UDim2.new(1, -84, 0, 0)
    sizeBox.Size = UDim2.fromOffset(84, 43)
    sizeBox.BackgroundColor3 = Colors.panel2
    sizeBox.BorderSizePixel = 0
    addCorner(sizeBox, UDim.new(0, 9))

    local minus = makeButton(sizeBox, "-", UDim2.fromOffset(22, 31), UDim2.fromOffset(3, 6), Colors.panel2)
    minus.TextSize = 17

    local value = Instance.new("TextLabel")
    value.Parent = sizeBox
    value.BackgroundTransparency = 1
    value.Position = UDim2.fromOffset(26, 0)
    value.Size = UDim2.fromOffset(31, 43)
    value.Text = tostring(Settings.Sizes[gear.key])
    value.TextColor3 = Colors.blue
    value.Font = Enum.Font.GothamBlack
    value.TextSize = 13

    local plus = makeButton(sizeBox, "+", UDim2.fromOffset(22, 31), UDim2.fromOffset(59, 6), Colors.panel2)
    plus.TextSize = 17

    rows[gear.key] = {selector = selector, value = value, name = gear.name}

    selector.MouseButton1Click:Connect(function()
        if locked then return end
        if floating[gear.key] then
            removeFloating(gear.key)
        else
            selectedKey = gear.key
            makeFloating(gear)
        end
    end)

    local function changeSize(amount)
        if locked then return end
        Settings.Sizes[gear.key] = math.clamp(Settings.Sizes[gear.key] + amount, 30, 100)
        value.Text = tostring(Settings.Sizes[gear.key])
        if floating[gear.key] then
            floating[gear.key].Size = UDim2.fromOffset(Settings.Sizes[gear.key], Settings.Sizes[gear.key])
        end
        SaveSettings()
    end
    minus.MouseButton1Click:Connect(function() changeSize(-5) end)
    plus.MouseButton1Click:Connect(function() changeSize(5) end)
end

local function setShape()
    if locked then return end
    Settings.Shape = Settings.Shape == "Circle" and "Rounded" or "Circle"
    shapeButton.Text = Settings.Shape == "Circle" and "SHAPE: CIRCLE" or "SHAPE: CURVED"
    for _, b in pairs(floating) do
        for _, child in ipairs(b:GetChildren()) do
            if child:IsA("UICorner") then child:Destroy() end
        end
        rounded(b)
    end
    SaveSettings()
end
shapeButton.MouseButton1Click:Connect(setShape)

lockButton.MouseButton1Click:Connect(function()
    locked = not locked
    lockButton.Text = locked and "LOCK: ON" or "LOCK: OFF"
    lockButton.BackgroundColor3 = locked and Colors.green or Colors.panel2
end)

local function closePanel()
    panelOpen = false
    panel.Visible = false
    launcher.Visible = true
    launcher.Position = UDim2.new(0.5, panel.Position.X.Offset + 112,
                                  0.5, panel.Position.Y.Offset + 155)
end

local function openPanel()
    panelOpen = true
    panel.Visible = true
    launcher.Visible = false
end
closeButton.MouseButton1Click:Connect(closePanel)
launcher.MouseButton1Click:Connect(openPanel)

-- Arrastrar el panel desde el encabezado, excepto cuando esta bloqueado.
local draggingPanel = false
local panelDragStart, panelStartPos
header.InputBegan:Connect(function(input)
    if locked then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = true
        panelDragStart = input.Position
        panelStartPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingPanel = false end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingPanel and not locked and
        (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - panelDragStart
        panel.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X,
                                   panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
        Settings.PanelX = panel.Position.X.Offset
        Settings.PanelY = panel.Position.Y.Offset
        SaveSettings()
    end
end)

shapeButton.Text = Settings.Shape == "Circle" and "SHAPE: CIRCLE" or "SHAPE: CURVED"
SaveSettings()
