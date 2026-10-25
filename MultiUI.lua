--[[
    MultiUI - Script de botones flotantes para Roblox (SAB)
    Incluye botón Trap para la trampa de Steal a Brainrot
    Requiere ejecutor (usa writefile, readfile, isfile)
]]

repeat task.wait() until game:IsLoaded()

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local SaveFile = "MultiUI_Settings.json"

-- ============================================================
-- CONFIGURACIÓN
-- ============================================================

local DefaultData = {
    ButtonT         = { X = -80, Y = -120, Size = 50 },
    ButtonPaintball = { X =  20, Y = -120, Size = 50 },
    ButtonCandy     = { X = -80, Y =  -50, Size = 50 },
    ButtonSubspace  = { X =  20, Y =  -50, Size = 50 },
    ButtonBlackBomb = { X = -80, Y =   20, Size = 50 },
    ButtonSentry    = { X =  20, Y =   20, Size = 50 },
    ButtonTrap      = { X = -80, Y =   90, Size = 50 },
}

local Keywords = {
    ButtonT         = {"giant", "khổng", "huge"},
    ButtonPaintball = {"paintball"},
    ButtonCandy     = {"candy"},
    ButtonSubspace  = {"subspace"},
    ButtonBlackBomb = {"blackhole bomb", "black hole bomb", "blackholebomb"},
    ButtonSentry    = {"all seeing", "allseeing"},
    ButtonTrap      = {"trap"},
}

-- ============================================================
-- ESTADO
-- ============================================================

local Settings = {}
for k, v in pairs(DefaultData) do
    Settings[k] = { X = v.X, Y = v.Y, Size = v.Size }
end

local MoveEnabled    = false
local SelectedButton = nil
local SelectedStroke = nil
local SelectedKey    = nil
local Label          = nil

-- ============================================================
-- PERSISTENCIA
-- ============================================================

local function SaveSettings()
    pcall(function()
        writefile(SaveFile, HttpService:JSONEncode(Settings))
    end)
end

pcall(function()
    if isfile(SaveFile) then
        local Data = HttpService:JSONDecode(readfile(SaveFile))
        for k, v in pairs(Data) do
            if type(v) == "table" then
                Settings[k] = Settings[k] or {}
                for k2, v2 in pairs(v) do
                    Settings[k][k2] = v2
                end
            else
                Settings[k] = v
            end
        end
    end
end)

-- ============================================================
-- GUI
-- ============================================================

pcall(function()
    local old = game.CoreGui:FindFirstChild("MultiUI")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- ============================================================
-- FÁBRICA DE BOTONES
-- ============================================================

local function CreateCircle(text, pos, size)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, size, 0, size)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextScaled = true
    Btn.TextWrapped = false
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = true

    local Corner = Instance.new("UICorner")
    Corner.Parent = Btn
    Corner.CornerRadius = UDim.new(1, 0)

    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Btn
    Stroke.Color = Color3.fromRGB(0, 191, 255)
    Stroke.Thickness = 0
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TextStroke = Instance.new("UIStroke")
    TextStroke.Parent = Btn
    TextStroke.Color = Color3.fromRGB(0, 0, 0)
    TextStroke.Thickness = 1.5

    return Btn, Stroke
end

-- ============================================================
-- CREACIÓN DE BOTONES
-- ============================================================

local ButtonT,         StrokeT         = CreateCircle("potion",     UDim2.new(0.5, Settings.ButtonT.X,         0.5, Settings.ButtonT.Y),         Settings.ButtonT.Size)
local ButtonPaintball, StrokePaintball = CreateCircle("Paintball",  UDim2.new(0.5, Settings.ButtonPaintball.X, 0.5, Settings.ButtonPaintball.Y), Settings.ButtonPaintball.Size)
local ButtonCandy,     StrokeCandy     = CreateCircle("Candy",      UDim2.new(0.5, Settings.ButtonCandy.X,     0.5, Settings.ButtonCandy.Y),     Settings.ButtonCandy.Size)
local ButtonSubspace,  StrokeSubspace  = CreateCircle("Subspace",   UDim2.new(0.5, Settings.ButtonSubspace.X,  0.5, Settings.ButtonSubspace.Y),  Settings.ButtonSubspace.Size)
local ButtonBlackBomb, StrokeBlackBomb = CreateCircle("Black Bomb", UDim2.new(0.5, Settings.ButtonBlackBomb.X, 0.5, Settings.ButtonBlackBomb.Y), Settings.ButtonBlackBomb.Size)
local ButtonSentry,    StrokeSentry    = CreateCircle("Sentry",     UDim2.new(0.5, Settings.ButtonSentry.X,    0.5, Settings.ButtonSentry.Y),    Settings.ButtonSentry.Size)
local ButtonTrap,      StrokeTrap      = CreateCircle("Trap",       UDim2.new(0.5, Settings.ButtonTrap.X,      0.5, Settings.ButtonTrap.Y),      Settings.ButtonTrap.Size)

local ButtonList = {
    { btn = ButtonT,         stroke = StrokeT,         key = "ButtonT" },
    { btn = ButtonPaintball, stroke = StrokePaintball, key = "ButtonPaintball" },
    { btn = ButtonCandy,     stroke = StrokeCandy,     key = "ButtonCandy" },
    { btn = ButtonSubspace,  stroke = StrokeSubspace,  key = "ButtonSubspace" },
    { btn = ButtonBlackBomb, stroke = StrokeBlackBomb, key = "ButtonBlackBomb" },
    { btn = ButtonSentry,    stroke = StrokeSentry,    key = "ButtonSentry" },
    { btn = ButtonTrap,      stroke = StrokeTrap,      key = "ButtonTrap" },
}

-- ============================================================
-- SELECCIÓN
-- ============================================================

local function Deselect()
    if SelectedStroke then
        SelectedStroke.Thickness = 0
    end
    SelectedButton = nil
    SelectedStroke = nil
    SelectedKey    = nil
    if Label then Label.Text = "--" end
end

local function SelectButton(btn, stroke, key)
    if SelectedStroke then
        SelectedStroke.Thickness = 0
    end
    SelectedButton = btn
    SelectedStroke = stroke
    SelectedKey    = key
    stroke.Thickness = 3
    if Label then
        Label.Text = tostring(Settings[key].Size or 50)
    end
end

-- ============================================================
-- AUTO-DESELECT AL QUITAR TOOL
-- ============================================================

local function SetupCharacter(char)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and SelectedKey then
            local n = string.lower(child.Name)
            local kws = Keywords[SelectedKey]
            if kws then
                for _, word in ipairs(kws) do
                    if string.find(n, word) then
                        Deselect()
                        break
                    end
                end
            end
        end
    end)
end

if player.Character then SetupCharacter(player.Character) end
player.CharacterAdded:Connect(SetupCharacter)

-- ============================================================
-- DRAG
-- ============================================================

local function EnableDrag(button, settingName)
    local dragging, dragInput, dragStart, startPos

    button.InputBegan:Connect(function(input)
        if MoveEnabled and input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = button.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            Settings[settingName].X = button.Position.X.Offset
            Settings[settingName].Y = button.Position.Y.Offset
            SaveSettings()
        end
    end)
end

for _, data in ipairs(ButtonList) do
    EnableDrag(data.btn, data.key)
end

-- ============================================================
-- PANEL DE TAMAÑO
-- ============================================================

local SizeFrame = Instance.new("Frame")
SizeFrame.Parent           = ScreenGui
SizeFrame.Size             = UDim2.new(0, 180, 0, 42)
SizeFrame.Position         = UDim2.new(0.5, -90, 0.5, 100)
SizeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SizeFrame.BorderSizePixel  = 0
SizeFrame.Active           = true
SizeFrame.Draggable        = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.Parent = SizeFrame
FrameCorner.CornerRadius = UDim.new(0, 10)

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Parent    = SizeFrame
FrameStroke.Color     = Color3.fromRGB(80, 80, 80)
FrameStroke.Thickness = 2

local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = SizeFrame
ResetBtn.Size = UDim2.new(0, 30, 1, 0)
ResetBtn.BackgroundTransparency = 1
ResetBtn.Text = "R"
ResetBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 20

local Minus = Instance.new("TextButton")
Minus.Parent = SizeFrame
Minus.Size = UDim2.new(0, 30, 1, 0)
Minus.Position = UDim2.new(0, 30, 0, 0)
Minus.BackgroundTransparency = 1
Minus.Text = "-"
Minus.TextColor3 = Color3.new(1, 1, 1)
Minus.Font = Enum.Font.GothamBold
Minus.TextSize = 24

Label = Instance.new("TextLabel")
Label.Parent = SizeFrame
Label.Size = UDim2.new(0, 40, 1, 0)
Label.Position = UDim2.new(0, 60, 0, 0)
Label.BackgroundTransparency = 1
Label.Text = "--"
Label.TextColor3 = Color3.new(1, 1, 1)
Label.Font = Enum.Font.GothamBold
Label.TextSize = 18

local Plus = Instance.new("TextButton")
Plus.Parent = SizeFrame
Plus.Size = UDim2.new(0, 30, 1, 0)
Plus.Position = UDim2.new(0, 100, 0, 0)
Plus.BackgroundTransparency = 1
Plus.Text = "+"
Plus.TextColor3 = Color3.new(1, 1, 1)
Plus.Font = Enum.Font.GothamBold
Plus.TextSize = 24

local MoveBtn = Instance.new("TextButton")
MoveBtn.Parent = SizeFrame
MoveBtn.Size = UDim2.new(0, 40, 0, 28)
MoveBtn.Position = UDim2.new(1, -45, 0.5, -14)
MoveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MoveBtn.Text = "OFF"
MoveBtn.TextColor3 = Color3.new(1, 1, 1)
MoveBtn.Font = Enum.Font.GothamBold
MoveBtn.TextSize = 14
MoveBtn.BorderSizePixel = 0

local MoveCorner = Instance.new("UICorner")
MoveCorner.Parent = MoveBtn
MoveCorner.CornerRadius = UDim.new(0, 8)

-- ============================================================
-- ACCIONES DEL PANEL
-- ============================================================

local function ResetAll()
    for _, data in ipairs(ButtonList) do
        local key = data.key
        local def = DefaultData[key]
        data.btn.Position = UDim2.new(0.5, def.X, 0.5, def.Y)
        data.btn.Size     = UDim2.new(0, def.Size, 0, def.Size)
        Settings[key].X   = def.X
        Settings[key].Y   = def.Y
        Settings[key].Size= def.Size
    end
    SaveSettings()
    Deselect()
end

ResetBtn.MouseButton1Click:Connect(ResetAll)

local function UpdateSelectedSize(delta)
    if not SelectedButton or not SelectedKey then return end
    local current = Settings[SelectedKey].Size or 50
    local newSize = math.clamp(current + delta, 30, 100)
    Settings[SelectedKey].Size = newSize
    SelectedButton.Size = UDim2.new(0, newSize, 0, newSize)
    Label.Text = tostring(newSize)
    SaveSettings()
end

Plus.MouseButton1Click:Connect(function() UpdateSelectedSize(5) end)
Minus.MouseButton1Click:Connect(function() UpdateSelectedSize(-5) end)

MoveBtn.MouseButton1Click:Connect(function()
    MoveEnabled = not MoveEnabled
    if MoveEnabled then
        MoveBtn.Text = "ON"
        MoveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        MoveBtn.Text = "OFF"
        MoveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

-- ============================================================
-- USO DE TOOL
-- ============================================================

local function UseTool(keywordTable)
    local char = player.Character or player.CharacterAdded:Wait()
    local backpack = player:WaitForChild("Backpack")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if humanoid then humanoid:UnequipTools() end
    task.wait(0.1)

    for _, v in pairs(backpack:GetChildren()) do
        if v:IsA("Tool") then
            local n = string.lower(v.Name)
            for _, word in pairs(keywordTable) do
                if string.find(n, word) then
                    v.Parent = char
                    task.wait(0.2)
                    pcall(function() v:Activate() end)
                    return
                end
            end
        end
    end
end

-- ============================================================
-- CLICK DE BOTONES
-- ============================================================

for _, data in ipairs(ButtonList) do
    data.btn.MouseButton1Click:Connect(function()
        if MoveEnabled then return end
        SelectButton(data.btn, data.stroke, data.key)
        UseTool(Keywords[data.key])
    end)
end
