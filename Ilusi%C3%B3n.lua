repeat task.wait() until game:IsLoaded()

-- BATMAN ALL GEARS
-- Panel pequeño: los botones del panel muestran/ocultan cada botón Gear.
-- Tocar un botón Gear lo activa; tocarlo otra vez lo desactiva y lo oculta.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

pcall(function()
    local old = game.CoreGui:FindFirstChild("MultiUI")
    if old then old:Destroy() end
end)

local SaveFile = "MultiUI_Settings.json"

local GearInfo = {
    {key="ButtonT", name="Potion", keywords={"giant", "khổng", "huge"}, x=-80, y=-120},
    {key="ButtonPaintball", name="Paintball", keywords={"paintball"}, x=20, y=-120},
    {key="ButtonCandy", name="Candy", keywords={"candy"}, x=-80, y=-50},
    {key="ButtonSubspace", name="Subspace", keywords={"subspace"}, x=20, y=-50},
    {key="ButtonBlackBomb", name="Black Bomb", keywords={"blackhole bomb", "black hole bomb", "blackholebomb"}, x=-80, y=20},
    {key="ButtonSentry", name="Sentry", keywords={"all seeing", "allseeing"}, x=20, y=20},
    {key="ButtonWebSlinger", name="Web Slinger", keywords={"web slinger", "webslinger", "web"}, x=-80, y=90},
    {key="ButtonMedusa", name="Medusa", keywords={"medusa"}, x=20, y=90},
    {key="ButtonTrap", name="Trap", keywords={"trap"}, x=-80, y=160},
}

local Defaults = {
    Panel = {X=28, Y=85},
    Shape = "Circle",
    Lock = false,
}
for _, info in ipairs(GearInfo) do
    Defaults[info.key] = {X=info.x, Y=info.y, Size=50}
end

local Settings = {}
for k, v in pairs(Defaults) do
    if type(v) == "table" then
        Settings[k] = {}
        for k2, v2 in pairs(v) do Settings[k][k2] = v2 end
    else
        Settings[k] = v
    end
end

pcall(function()
    if isfile and readfile and isfile(SaveFile) then
        local data = HttpService:JSONDecode(readfile(SaveFile))
        for k, v in pairs(data) do
            if type(v) == "table" then
                Settings[k] = Settings[k] or {}
                for k2, v2 in pairs(v) do Settings[k][k2] = v2 end
            else
                Settings[k] = v
            end
        end
    end
end)

local function Save()
    pcall(function()
        if writefile then
            writefile(SaveFile, HttpService:JSONEncode(Settings))
        end
    end)
end

local Colors = {
    panel = Color3.fromRGB(3, 7, 15),
    panel2 = Color3.fromRGB(13, 25, 46),
    button = Color3.fromRGB(5, 12, 22),
    border = Color3.fromRGB(43, 62, 88),
    blue = Color3.fromRGB(70, 145, 245),
    blueDark = Color3.fromRGB(24, 53, 91),
    white = Color3.fromRGB(247, 249, 255),
    green = Color3.fromRGB(117, 174, 145),
}

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function Stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function Button(parent, text, size, pos, bg, radius)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = size
    b.Position = pos
    b.BackgroundColor3 = bg or Colors.button
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = Colors.white
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextWrapped = true
    Corner(b, radius or 14)
    Stroke(b, Colors.border, 2)
    return b
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "MultiUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game.CoreGui

-- PANEL PRINCIPAL COMPACTO

local Panel = Instance.new("Frame")
Panel.Name = "BatmanPanel"
Panel.Parent = Gui
Panel.Size = UDim2.fromOffset(286, 405)
Panel.Position = UDim2.new(0, Settings.Panel.X, 0, Settings.Panel.Y)
Panel.BackgroundColor3 = Colors.panel
Panel.BorderSizePixel = 0
Panel.ClipsDescendants = true
Corner(Panel, 25)
Stroke(Panel, Color3.fromRGB(75, 125, 180), 2)

local Header = Instance.new("Frame")
Header.Parent = Panel
Header.BackgroundTransparency = 1
Header.Position = UDim2.fromOffset(10, 6)
Header.Size = UDim2.new(1, -20, 0, 54)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(5, 0)
Title.Size = UDim2.new(1, -55, 0, 30)
Title.Text = "BATMAN HUB"
Title.TextColor3 = Colors.white
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 21

local Byline = Instance.new("TextLabel")
Byline.Parent = Header
Byline.BackgroundTransparency = 1
Byline.Position = UDim2.fromOffset(6, 29)
Byline.Size = UDim2.new(1, -55, 0, 19)
Byline.Text = "EXTRA GEARS"
Byline.TextColor3 = Colors.green
Byline.TextXAlignment = Enum.TextXAlignment.Left
Byline.Font = Enum.Font.Gotham
Byline.TextSize = 13

local Close = Button(Header, "−", UDim2.fromOffset(39, 39), UDim2.new(1, -42, 0, 1), Colors.panel2, 18)

local Lock = Button(Panel, "Lock: OFF", UDim2.new(0.48, -10, 0, 35), UDim2.fromOffset(12, 66), Colors.button, 16)
local Shape = Button(Panel, "Shape: Circle", UDim2.new(0.52, -10, 0, 35), UDim2.new(0.48, 4, 0, 66), Colors.button, 16)

local Display = Button(Panel, "Display Mode: Name", UDim2.new(1, -24, 0, 38), UDim2.fromOffset(12, 109), Colors.blue, 16)

local GearList = Instance.new("ScrollingFrame")
GearList.Parent = Panel
GearList.Position = UDim2.fromOffset(10, 155)
GearList.Size = UDim2.new(1, -20, 1, -165)
GearList.BackgroundTransparency = 1
GearList.BorderSizePixel = 0
GearList.ScrollBarThickness = 3
GearList.ScrollBarImageColor3 = Colors.blue
GearList.CanvasSize = UDim2.new()

local Layout = Instance.new("UIListLayout")
Layout.Parent = GearList
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    GearList.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 8)
end)

-- BOTÓN REDONDO PARA VOLVER A ABRIR EL PANEL

local Mini = Button(Gui, "EXTRA\nGEARS", UDim2.fromOffset(65, 65), UDim2.fromOffset(25, 100), Colors.panel2, 33)
Mini.Visible = false
Mini.TextSize = 12
Stroke(Mini, Color3.fromRGB(75, 125, 180), 2)

-- PANEL DE TAMAÑO

local SizeFrame = Instance.new("Frame")
SizeFrame.Parent = Gui
SizeFrame.Size = UDim2.fromOffset(174, 39)
SizeFrame.Position = UDim2.new(0.5, -87, 0.5, 150)
SizeFrame.BackgroundColor3 = Colors.panel
SizeFrame.BorderSizePixel = 0
Corner(SizeFrame, 10)
Stroke(SizeFrame, Colors.border, 2)

local Reset = Button(SizeFrame, "R", UDim2.fromOffset(28, 39), UDim2.fromOffset(0, 0), Colors.button, 8)
local Minus = Button(SizeFrame, "−", UDim2.fromOffset(28, 39), UDim2.fromOffset(29, 0), Colors.button, 8)
local SizeLabel = Instance.new("TextLabel")
SizeLabel.Parent = SizeFrame
SizeLabel.BackgroundTransparency = 1
SizeLabel.Position = UDim2.fromOffset(57, 0)
SizeLabel.Size = UDim2.fromOffset(38, 39)
SizeLabel.Text = "--"
SizeLabel.TextColor3 = Colors.white
SizeLabel.Font = Enum.Font.GothamBold
SizeLabel.TextSize = 17
local Plus = Button(SizeFrame, "+", UDim2.fromOffset(28, 39), UDim2.fromOffset(96, 0), Colors.button, 8)
local SizeCaption = Instance.new("TextLabel")
SizeCaption.Parent = SizeFrame
SizeCaption.BackgroundTransparency = 1
SizeCaption.Position = UDim2.fromOffset(126, 0)
SizeCaption.Size = UDim2.fromOffset(45, 39)
SizeCaption.Text = "SIZE"
SizeCaption.TextColor3 = Colors.green
SizeCaption.Font = Enum.Font.GothamBold
SizeCaption.TextSize = 10

-- ESTADO DE LOS BOTONES FLOTANTES

local Floating = {}
local SelectedKey = nil
local IsLocked = false
local IsCircle = Settings.Shape ~= "Rounded"
local ShowNames = true
local DragConnections = {}
local MakeDraggable

local function FindTool(key)
    local info
    for _, item in ipairs(GearInfo) do
        if item.key == key then info = item break end
    end
    if not info then return nil end

    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local n = string.lower(tool.Name)
                for _, word in ipairs(info.keywords) do
                    if string.find(n, word, 1, true) then return tool end
                end
            end
        end
    end

    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            for _, word in ipairs(info.keywords) do
                if string.find(n, word, 1, true) then return tool end
            end
        end
    end
    return nil
end

local function UseGear(key)
    local info
    for _, item in ipairs(GearInfo) do
        if item.key == key then info = item break end
    end
    if not info then return false end

    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local tool = FindTool(key)
    if not tool then return false end

    if humanoid then humanoid:UnequipTools() end
    task.wait(0.1)

    if tool.Parent == player.Backpack then
        tool.Parent = char
    end
    task.wait(0.15)
    pcall(function() tool:Activate() end)
    return true
end

local function SetShape(button)
    local corner = button:FindFirstChildOfClass("UICorner")
    if corner then corner.CornerRadius = UDim.new(0, IsCircle and 100 or 13) end
end

local function UpdateSizeLabel()
    if SelectedKey then
        SizeLabel.Text = tostring(Settings[SelectedKey].Size or 50)
    else
        SizeLabel.Text = "--"
    end
end

local function RemoveFloating(key)
    local data = Floating[key]
    if not data then return end

    if data.active then
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:UnequipTools() end
    end

    if data.button then data.button:Destroy() end
    Floating[key] = nil
end

local function ToggleFloating(key)
    if Floating[key] then
        RemoveFloating(key)
        if SelectedKey == key then
            SelectedKey = nil
            UpdateSizeLabel()
        end
        return
    end

    local info
    for _, item in ipairs(GearInfo) do
        if item.key == key then info = item break end
    end
    if not info then return end

    local setting = Settings[key]
    local button = Button(
        Gui,
        info.name .. " OFF",
        UDim2.fromOffset(setting.Size or 50, setting.Size or 50),
        UDim2.new(0.5, setting.X or info.x, 0.5, setting.Y or info.y),
        Colors.button,
        100
    )
    button.Name = key .. "_Floating"
    SetShape(button)

    local data = {button=button, active=false}
    Floating[key] = data
    if MakeDraggable then MakeDraggable(button, button, false) end

    button.MouseButton1Click:Connect(function()
        if IsLocked then return end

        if not data.active then
            local success = UseGear(key)
            if success then
                data.active = true
                button.BackgroundColor3 = Colors.blue
                button.Text = info.name .. " ON"
            else
                button.Text = info.name .. " NOT FOUND"
                task.delay(1.2, function()
                    if Floating[key] == data then
                        button.Text = info.name .. " OFF"
                    end
                end)
            end
        else
            data.active = false
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:UnequipTools() end
            RemoveFloating(key)
        end
    end)

    button.InputBegan:Connect(function(input)
        if IsLocked then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            SelectedKey = key
            UpdateSizeLabel()
        end
    end)
end

-- CADA FILA DEL PANEL SOLO MUESTRA / OCULTA SU BOTÓN CORRESPONDIENTE

for index, info in ipairs(GearInfo) do
    local row = Instance.new("Frame")
    row.Parent = GearList
    row.Size = UDim2.new(1, -2, 0, 34)
    row.BackgroundTransparency = 1
    row.LayoutOrder = index

    local showButton = Button(row, info.name, UDim2.new(1, -53, 1, 0), UDim2.fromOffset(0, 0), Colors.button, 13)
    local sizeButton = Button(row, tostring(Settings[info.key].Size or 50), UDim2.fromOffset(47, 34), UDim2.new(1, -47, 0, 0), Colors.panel2, 12)

    local function RefreshRow()
        if Floating[info.key] then
            showButton.BackgroundColor3 = Colors.blue
            showButton.Text = info.name .. "  •  SHOWN"
        else
            showButton.BackgroundColor3 = Colors.button
            showButton.Text = info.name
        end
        sizeButton.Text = tostring(Settings[info.key].Size or 50)
    end

    showButton.MouseButton1Click:Connect(function()
        ToggleFloating(info.key)
        RefreshRow()
    end)

    sizeButton.MouseButton1Click:Connect(function()
        SelectedKey = info.key
        UpdateSizeLabel()
        for _, child in ipairs(GearList:GetChildren()) do
            if child:IsA("Frame") then
                for _, button in ipairs(child:GetChildren()) do
                    if button:IsA("TextButton") and button.Text:find("SHOWN") then
                        button.BackgroundColor3 = Colors.blue
                    end
                end
            end
        end
        sizeButton.BackgroundColor3 = Colors.blueDark
    end)
end

local function ChangeSize(delta)
    if IsLocked or not SelectedKey then return end
    local key = SelectedKey
    local newSize = math.clamp((Settings[key].Size or 50) + delta, 25, 110)
    Settings[key].Size = newSize

    local data = Floating[key]
    if data and data.button then
        data.button.Size = UDim2.fromOffset(newSize, newSize)
    end

    SizeLabel.Text = tostring(newSize)
    Save()
    for _, row in ipairs(GearList:GetChildren()) do
        if row:IsA("Frame") then
            local sizeButton = row:FindFirstChildWhichIsA("TextButton")
            local info
            for _, item in ipairs(GearInfo) do
                if item.key == key then info = item break end
            end
            if info and row.LayoutOrder then
                local buttons = {}
                for _, child in ipairs(row:GetChildren()) do
                    if child:IsA("TextButton") then table.insert(buttons, child) end
                end
                if buttons[2] then buttons[2].Text = tostring(newSize) end
            end
        end
    end
end

Plus.MouseButton1Click:Connect(function() ChangeSize(5) end)
Minus.MouseButton1Click:Connect(function() ChangeSize(-5) end)

Reset.MouseButton1Click:Connect(function()
    if IsLocked or not SelectedKey then return end
    Settings[SelectedKey].Size = 50
    local data = Floating[SelectedKey]
    if data and data.button then data.button.Size = UDim2.fromOffset(50, 50) end
    UpdateSizeLabel()
    Save()
end)

-- LOCK / FORMA / CIERRE

Lock.MouseButton1Click:Connect(function()
    IsLocked = not IsLocked
    Lock.Text = IsLocked and "Lock: ON" or "Lock: OFF"
    Lock.BackgroundColor3 = IsLocked and Colors.blueDark or Colors.button
end)

Shape.MouseButton1Click:Connect(function()
    if IsLocked then return end
    IsCircle = not IsCircle
    Shape.Text = IsCircle and "Shape: Circle" or "Shape: Rounded"
    Settings.Shape = IsCircle and "Circle" or "Rounded"
    for _, data in pairs(Floating) do SetShape(data.button) end
    Save()
end)

Display.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    Display.Text = ShowNames and "Display Mode: Name" or "Display Mode: Icon"
    for key, data in pairs(Floating) do
        local info
        for _, item in ipairs(GearInfo) do
            if item.key == key then info = item break end
        end
        if info and not data.active then
            data.button.Text = ShowNames and (info.name .. " OFF") or info.name:sub(1, 2):upper()
        end
    end
end)

Close.MouseButton1Click:Connect(function()
    Panel.Visible = false
    SizeFrame.Visible = false
    Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
    Mini.Visible = false
    Panel.Visible = true
    SizeFrame.Visible = true
end)

-- ARRASTRAR PANEL / CÍRCULO / BOTONES FLOTANTES

MakeDraggable = function(target, handle, savePosition)
    local dragging = false
    local startInput, startPosition

    handle.InputBegan:Connect(function(input)
        if IsLocked then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input.Position
            startPosition = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging or IsLocked then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            target.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
            if savePosition then
                Settings.Panel.X = target.Position.X.Offset
                Settings.Panel.Y = target.Position.Y.Offset
                Save()
            end
        end
    end)
end

MakeDraggable(Panel, Header, true)
MakeDraggable(Mini, Mini, false)
MakeDraggable(SizeFrame, SizeFrame, false)

-- Al seleccionar un botón flotante, también se puede arrastrar cuando Lock está OFF.
for _, info in ipairs(GearInfo) do
    -- Se conecta al crear cada botón en ToggleFloating.
end

Save()
