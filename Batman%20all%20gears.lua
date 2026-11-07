-- BATMAN ALL GEARS
-- LocalScript para Roblox Studio.
-- Usa únicamente Tools que el jugador ya tenga en Backpack o Character.
-- No crea gears ni usa remotes/exploits para obtener objetos.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("BatmanAllGears")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "BatmanAllGears"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local COLORS = {
    panel = Color3.fromRGB(4, 8, 17),
    panelTop = Color3.fromRGB(13, 23, 43),
    button = Color3.fromRGB(7, 13, 23),
    buttonBorder = Color3.fromRGB(39, 57, 82),
    blue = Color3.fromRGB(75, 153, 255),
    blueDark = Color3.fromRGB(25, 54, 94),
    white = Color3.fromRGB(245, 248, 255),
    green = Color3.fromRGB(115, 175, 145),
    muted = Color3.fromRGB(150, 180, 215),
}

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
    return c
end

local function stroke(object, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 2
    s.Parent = object
    return s
end

local function makeButton(parent, text, size, position, bg)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = bg or COLORS.button
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = COLORS.white
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b, 22)
    stroke(b, COLORS.buttonBorder, 2)
    return b
end

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(360, 490)
panel.Position = UDim2.new(0, 35, 0.18, 0)
panel.BackgroundColor3 = COLORS.panel
panel.BorderSizePixel = 0
panel.Parent = gui
corner(panel, 30)
stroke(panel, Color3.fromRGB(87, 137, 190), 3)

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, -24, 0, 62)
header.Position = UDim2.fromOffset(12, 8)
header.BackgroundTransparency = 1
header.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -65, 0, 36)
title.Position = UDim2.fromOffset(8, 2)
title.BackgroundTransparency = 1
title.Text = "BATMAN HUB"
title.TextColor3 = COLORS.white
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBlack
title.TextSize = 25
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -65, 0, 23)
subtitle.Position = UDim2.fromOffset(9, 36)
subtitle.BackgroundTransparency = 1
subtitle.Text = "By Batman"
subtitle.TextColor3 = COLORS.green
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 17
subtitle.Parent = header

local closeButton = makeButton(header, "−", UDim2.fromOffset(48, 48), UDim2.new(1, -52, 0, 0), COLORS.panelTop)
corner(closeButton, 22)

local lockButton = makeButton(panel, "Lock: OFF", UDim2.new(0.47, -8, 0, 43), UDim2.fromOffset(16, 78))
local shapeButton = makeButton(panel, "Shape: Circle", UDim2.new(0.47, -8, 0, 43), UDim2.new(0.53, 0, 0, 78))
local displayButton = makeButton(panel, "Display Mode: Icon", UDim2.new(1, -32, 0, 48), UDim2.fromOffset(16, 132), COLORS.blue)
displayButton.TextColor3 = COLORS.white
displayButton.TextSize = 17

local list = Instance.new("ScrollingFrame")
list.Name = "GearList"
list.Size = UDim2.new(1, -24, 1, -197)
list.Position = UDim2.fromOffset(12, 190)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = COLORS.blue
list.CanvasSize = UDim2.new()
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 2)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 2)
padding.PaddingRight = UDim.new(0, 2)
padding.Parent = list

local gearNames = {
    "Blackhole",
    "Trap",
    "Demon Head",
    "Medusa Head",
    "Websling",
}

local gearRows = {}
local locked = false
local circleShape = true
local iconMode = true
local compact = false
local activeTools = {}

local function findTool(name)
    local backpack = player:FindFirstChildOfClass("Backpack")
    local character = player.Character

    if character then
        local tool = character:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            return tool
        end
    end

    if backpack then
        local tool = backpack:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            return tool
        end
    end

    return nil
end

local function setGearActive(name, button, active)
    local tool = findTool(name)
    if not tool then
        button.Text = name .. ": MISSING"
        button.BackgroundColor3 = COLORS.button
        activeTools[name] = false
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChildOfClass("Backpack")

    if active then
        if humanoid then
            humanoid:EquipTool(tool)
            task.wait(0.12)
            pcall(function()
                tool:Activate()
            end)
        end
        activeTools[name] = true
        button.BackgroundColor3 = COLORS.blue
        button.Text = name .. ": ON"
    else
        if humanoid and backpack and tool.Parent == character then
            humanoid:UnequipTools()
        end
        activeTools[name] = false
        button.BackgroundColor3 = COLORS.button
        button.Text = name .. ": OFF"
    end
end

local function updateCanvas()
    list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

for index, gearName in ipairs(gearNames) do
    local row = Instance.new("Frame")
    row.Name = gearName:gsub("%W", "") .. "Row"
    row.Size = UDim2.new(1, -4, 0, 76)
    row.BackgroundTransparency = 1
    row.LayoutOrder = index
    row.Parent = list

    local gearButton = makeButton(row, gearName .. ": OFF", UDim2.new(1, -91, 1, 0), UDim2.fromOffset(0, 0))
    local sizeButton = makeButton(row, "50", UDim2.fromOffset(78, 76), UDim2.new(1, -78, 0, 0), COLORS.panelTop)

    local currentSize = 50
    local sizes = {50, 57, 69, 83, 95}

    gearButton.MouseButton1Click:Connect(function()
        if locked then return end
        setGearActive(gearName, gearButton, not activeTools[gearName])
    end)

    sizeButton.MouseButton1Click:Connect(function()
        if locked then return end
        for i, value in ipairs(sizes) do
            if value == currentSize then
                currentSize = sizes[(i % #sizes) + 1]
                break
            end
        end
        sizeButton.Text = tostring(currentSize)
        -- Este control guarda el ajuste visual del botón. No cambia el tamaño
        -- interno del Gear, porque cada Tool implementa sus propias propiedades.
        gearButton.TextSize = math.clamp(16 + (currentSize - 50) / 7, 16, 22)
    end)

    gearRows[gearName] = {
        row = row,
        gear = gearButton,
        size = sizeButton,
    }
end

local function applyShape()
    local radius = circleShape and 28 or 13
    for _, controls in pairs(gearRows) do
        controls.gear:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, radius)
        controls.size:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, radius)
    end
    shapeButton.Text = circleShape and "Shape: Circle" or "Shape: Rounded"
end

shapeButton.MouseButton1Click:Connect(function()
    if locked then return end
    circleShape = not circleShape
    applyShape()
end)

displayButton.MouseButton1Click:Connect(function()
    if locked then return end
    iconMode = not iconMode
    displayButton.Text = iconMode and "Display Mode: Icon" or "Display Mode: Name"
    for name, controls in pairs(gearRows) do
        controls.gear.Text = iconMode and (name .. (activeTools[name] and ": ON" or ": OFF")) or
            (activeTools[name] and "ON" or "OFF")
    end
end)

lockButton.MouseButton1Click:Connect(function()
    locked = not locked
    lockButton.Text = locked and "Lock: ON" or "Lock: OFF"
    lockButton.BackgroundColor3 = locked and COLORS.blueDark or COLORS.button
end)

local mini = makeButton(gui, "EXTRA\nGEARS", UDim2.fromOffset(76, 76), UDim2.fromOffset(35, 100), COLORS.panelTop)
mini.Name = "ExtraGearsButton"
mini.Visible = false
mini.TextSize = 13
corner(mini, 50)
stroke(mini, Color3.fromRGB(87, 137, 190), 3)

closeButton.MouseButton1Click:Connect(function()
    panel.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    mini.Visible = false
    panel.Visible = true
end)

-- Arrastrar panel desde la cabecera. Lock bloquea también el movimiento.
local function makeDraggable(target, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if locked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or locked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(panel, header)
makeDraggable(mini, mini)

-- Actualiza el estado visual si el personaje reaparece.
player.CharacterAdded:Connect(function()
    for name, controls in pairs(gearRows) do
        activeTools[name] = false
        controls.gear.BackgroundColor3 = COLORS.button
        controls.gear.Text = name .. ": OFF"
    end
end)

updateCanvas()
