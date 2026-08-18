-- KZM v3.1 — Premium reskin on proven v1.7 structure
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RS                = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

-- ── COLOURS ──────────────────────────────────────────────────
local C = {
    bg        = Color3.fromRGB(8,   5,  18),
    panel     = Color3.fromRGB(13,  9,  26),
    row       = Color3.fromRGB(22,  16, 40),
    rowHover  = Color3.fromRGB(32,  24, 56),
    accent    = Color3.fromRGB(100, 55, 240),
    accent2   = Color3.fromRGB(65,  35, 180),
    accentHi  = Color3.fromRGB(150, 100,255),
    stroke    = Color3.fromRGB(70,  45, 150),
    tabActive = Color3.fromRGB(100, 55, 240),
    tabIdle   = Color3.fromRGB(18,  13, 35),
    text      = Color3.fromRGB(220, 215,245),
    textDim   = Color3.fromRGB(120, 105,160),
    section   = Color3.fromRGB(30,  20, 55),
    toggleOn  = Color3.fromRGB(100, 55, 240),
    toggleOff = Color3.fromRGB(25,  18, 50),
    white     = Color3.fromRGB(255, 255,255),
    red       = Color3.fromRGB(220, 50,  80),
    redLo     = Color3.fromRGB(140, 20,  45),
}

-- ── SCREEN GUI ───────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "KZM"
screenGui.ResetOnSpawn    = false
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder    = 200
screenGui.Parent          = LocalPlayer.PlayerGui

-- ── HELPERS ──────────────────────────────────────────────────
local function makeCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local function makeStroke(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.stroke
    s.Thickness = th or 1.5
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

-- ── WINDOW SIZES ─────────────────────────────────────────────
local WIN_W  = 700
local WIN_H  = 420
local TITLE_H = 42
local TAB_H   = 32
local HEADER_H = TITLE_H + TAB_H + 2

-- ── TOGGLE BUTTON ────────────────────────────────────────────
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size              = UDim2.new(0, 80, 0, 30)
toggleBtn.Position          = UDim2.new(0, 10, 0, 60)
toggleBtn.BackgroundColor3  = C.accent2
toggleBtn.Text              = "KZM"
toggleBtn.TextColor3        = C.white
toggleBtn.Font              = Enum.Font.GothamBold
toggleBtn.TextSize          = 13
toggleBtn.BorderSizePixel   = 0
toggleBtn.ZIndex            = 200
toggleBtn.Parent            = screenGui
makeCorner(toggleBtn, 15)
makeStroke(toggleBtn, C.accentHi, 1.5)

task.spawn(function()
    while true do
        TweenService:Create(toggleBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundColor3 = C.accent}):Play()
        task.wait(1.4)
        TweenService:Create(toggleBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundColor3 = C.accent2}):Play()
        task.wait(1.4)
    end
end)

-- ── MAIN WINDOW ──────────────────────────────────────────────
local window = Instance.new("Frame")
window.Name             = "KZMWindow"
window.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
window.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 30)
window.BackgroundColor3 = C.bg
window.BorderSizePixel  = 0
window.Active           = true
window.Visible          = false
window.ZIndex           = 100
window.Parent           = screenGui
makeCorner(window, 14)

-- animated glow border
local glowBorder = Instance.new("Frame")
glowBorder.Size                  = UDim2.new(1, 6, 1, 6)
glowBorder.Position              = UDim2.new(0, -3, 0, -3)
glowBorder.BackgroundTransparency = 1
glowBorder.BorderSizePixel       = 0
glowBorder.ZIndex                = 99
glowBorder.Parent                = window
makeCorner(glowBorder, 17)
local glowStroke = makeStroke(glowBorder, C.accent, 2.5, 0.3)

task.spawn(function()
    while window.Parent do
        TweenService:Create(glowStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Color = C.accentHi, Transparency = 0.05}):Play()
        task.wait(2)
        TweenService:Create(glowStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Color = C.accent, Transparency = 0.45}):Play()
        task.wait(2)
    end
end)

-- background gradient
local winGrad = Instance.new("UIGradient")
winGrad.Rotation = 135
winGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(12, 7, 24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,  5, 16)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 6, 20)),
})
winGrad.Parent = window

-- ── OPEN/CLOSE ANIMATION ─────────────────────────────────────
local isOpen = false
local OPEN_POS  = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 30)
local START_POS = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 80)

local function openGUI()
    isOpen = true
    window.Visible = true
    window.Position = START_POS
    window.BackgroundTransparency = 0.8
    -- slide up + fade in
    TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = OPEN_POS,
        BackgroundTransparency = 0,
    }):Play()
    -- border glow burst on open
    glowStroke.Transparency = 0
    glowStroke.Color = C.accentHi
    task.delay(0.35, function()
        TweenService:Create(glowStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Transparency = 0.3, Color = C.accent}):Play()
    end)
end

local function closeGUI()
    isOpen = false
    TweenService:Create(window, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = START_POS,
        BackgroundTransparency = 0.9,
    }):Play()
    task.delay(0.22, function()
        if not isOpen then window.Visible = false end
    end)
end

toggleBtn.MouseButton1Click:Connect(function()
    if isOpen then closeGUI() else openGUI() end
end)

-- ── TITLE BAR ────────────────────────────────────────────────
local titleBar = Instance.new("Frame")
titleBar.Name             = "TitleBar"
titleBar.Size             = UDim2.new(1, 0, 0, TITLE_H)
titleBar.BackgroundColor3 = C.panel
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 110
titleBar.Parent           = window
makeCorner(titleBar, 14)

-- fill bottom corners of titlebar
local tbFill = Instance.new("Frame")
tbFill.Size             = UDim2.new(1, 0, 0, 14)
tbFill.Position         = UDim2.new(0, 0, 1, -14)
tbFill.BackgroundColor3 = C.panel
tbFill.BorderSizePixel  = 0
tbFill.ZIndex           = 110
tbFill.Parent           = titleBar

-- accent underline
local accentLine = Instance.new("Frame")
accentLine.Size             = UDim2.new(0, 100, 0, 2)
accentLine.Position         = UDim2.new(0, 12, 1, -2)
accentLine.BackgroundColor3 = C.accent
accentLine.BorderSizePixel  = 0
accentLine.ZIndex           = 111
accentLine.Parent           = titleBar
makeCorner(accentLine, 1)

task.spawn(function()
    while window.Parent do
        TweenService:Create(accentLine, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Size = UDim2.new(0, 200, 0, 2), BackgroundColor3 = C.accentHi}):Play()
        task.wait(1.8)
        TweenService:Create(accentLine, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Size = UDim2.new(0, 100, 0, 2), BackgroundColor3 = C.accent}):Play()
        task.wait(1.8)
    end
end)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(0, 180, 1, 0)
titleLbl.Position           = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "KZM  v3.1"
titleLbl.TextColor3         = C.white
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize           = 16
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 111
titleLbl.Parent             = titleBar

-- status dot
local sDot = Instance.new("Frame")
sDot.Size             = UDim2.new(0, 8, 0, 8)
sDot.Position         = UDim2.new(1, -90, 0.5, -4)
sDot.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
sDot.BorderSizePixel  = 0
sDot.ZIndex           = 111
sDot.Parent           = titleBar
makeCorner(sDot, 4)
task.spawn(function()
    while true do
        TweenService:Create(sDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundTransparency = 0.6}):Play()
        task.wait(1)
        TweenService:Create(sDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundTransparency = 0}):Play()
        task.wait(1)
    end
end)

local sLbl = Instance.new("TextLabel")
sLbl.Size               = UDim2.new(0, 50, 1, 0)
sLbl.Position           = UDim2.new(1, -80, 0, 0)
sLbl.BackgroundTransparency = 1
sLbl.Text               = "Active"
sLbl.TextColor3         = C.textDim
sLbl.Font               = Enum.Font.Gotham
sLbl.TextSize           = 10
sLbl.TextXAlignment     = Enum.TextXAlignment.Left
sLbl.ZIndex             = 111
sLbl.Parent             = titleBar

-- close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 26, 0, 26)
closeBtn.Position         = UDim2.new(1, -34, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 55)
closeBtn.Text             = "x"
closeBtn.TextColor3       = Color3.fromRGB(200, 140, 210)
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 12
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 112
closeBtn.Parent           = titleBar
makeCorner(closeBtn, 13)
closeBtn.MouseButton1Click:Connect(closeGUI)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.red, TextColor3 = C.white}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50,20,55), TextColor3 = Color3.fromRGB(200,140,210)}):Play()
end)

-- drag
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = window.Position
    end
end)
titleBar.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
titleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- ── TAB BAR ──────────────────────────────────────────────────
local tabBar = Instance.new("Frame")
tabBar.Name             = "TabBar"
tabBar.Size             = UDim2.new(1, 0, 0, TAB_H)
tabBar.Position         = UDim2.new(0, 0, 0, TITLE_H)
tabBar.BackgroundColor3 = Color3.fromRGB(12, 8, 24)
tabBar.BorderSizePixel  = 0
tabBar.ZIndex           = 109
tabBar.Parent           = window

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection      = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment  = Enum.VerticalAlignment.Center
tabLayout.Padding            = UDim.new(0, 3)
tabLayout.Parent             = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft   = UDim.new(0, 6)
tabPad.PaddingTop    = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 4)
tabPad.Parent        = tabBar

-- separator
local tabSep = Instance.new("Frame")
tabSep.Size             = UDim2.new(1, 0, 0, 1)
tabSep.Position         = UDim2.new(0, 0, 0, TITLE_H + TAB_H)
tabSep.BackgroundColor3 = C.stroke
tabSep.BackgroundTransparency = 0.6
tabSep.BorderSizePixel  = 0
tabSep.ZIndex           = 108
tabSep.Parent           = window

-- ── CONTENT AREA ─────────────────────────────────────────────
local contentFrame = Instance.new("Frame")
contentFrame.Name             = "Content"
contentFrame.Size             = UDim2.new(1, 0, 1, -HEADER_H)
contentFrame.Position         = UDim2.new(0, 0, 0, HEADER_H)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel  = 0
contentFrame.ZIndex           = 100
contentFrame.Parent           = window

-- ── UI HELPERS ─────────────────────────────────────────────────────
local function makeScrollList(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Size                    = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency  = 1
    sf.BorderSizePixel         = 0
    sf.ScrollBarThickness      = 4
    sf.ScrollBarImageColor3    = C.accent
    sf.ScrollingDirection      = Enum.ScrollingDirection.Y
    sf.CanvasSize              = UDim2.new(0, 0, 0, 0)
    sf.ZIndex                  = 100
    sf.Parent                  = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding             = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Parent              = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft   = UDim.new(0, 6)
    pad.PaddingRight  = UDim.new(0, 6)
    pad.Parent        = sf

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)
    return sf
end

local function makeToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -8, 0, 36)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel  = 0
    row.ZIndex           = 100
    row.Parent           = parent
    makeCorner(row, 8)
    makeStroke(row, C.stroke, 1, 0.5)

    -- left accent bar
    local bar = Instance.new("Frame")
    bar.Size                    = UDim2.new(0, 3, 0.6, 0)
    bar.Position                = UDim2.new(0, 0, 0.2, 0)
    bar.BackgroundColor3        = C.accent
    bar.BackgroundTransparency  = default and 0 or 1
    bar.BorderSizePixel         = 0
    bar.ZIndex                  = 101
    bar.Parent                  = row
    makeCorner(bar, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.7, 0, 1, 0)
    lbl.Position           = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = labelText
    lbl.TextColor3         = default and C.white or C.text
    lbl.Font               = Enum.Font.GothamMedium
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 101
    lbl.Parent             = row

    local tBG = Instance.new("Frame")
    tBG.Size             = UDim2.new(0, 44, 0, 22)
    tBG.Position         = UDim2.new(1, -52, 0.5, -11)
    tBG.BackgroundColor3 = default and C.toggleOn or C.toggleOff
    tBG.BorderSizePixel  = 0
    tBG.ZIndex           = 101
    tBG.Parent           = row
    makeCorner(tBG, 11)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 16, 0, 16)
    knob.Position         = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 102
    knob.Parent           = tBG
    makeCorner(knob, 8)

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 103
    btn.Parent             = row

    local isOn = default or false
    local function setState(v)
        isOn = v
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
            Position = isOn and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        }):Play()
        TweenService:Create(tBG,  TweenInfo.new(0.15), {BackgroundColor3 = isOn and C.toggleOn or C.toggleOff}):Play()
        TweenService:Create(bar,  TweenInfo.new(0.15), {BackgroundTransparency = isOn and 0 or 1}):Play()
        TweenService:Create(lbl,  TweenInfo.new(0.15), {TextColor3 = isOn and C.white or C.text}):Play()
    end

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn; setState(isOn)
        if callback then callback(isOn) end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C.rowHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C.row}):Play()
    end)
    return row, setState, function() return isOn end
end

local function makeButton(parent, labelText, callback)
    local row = Instance.new("TextButton")
    row.Size             = UDim2.new(1, -8, 0, 34)
    row.BackgroundColor3 = C.accent2
    row.BorderSizePixel  = 0
    row.Text             = labelText
    row.TextColor3       = C.white
    row.Font             = Enum.Font.GothamBold
    row.TextSize         = 12
    row.ZIndex           = 100
    row.Parent           = parent
    makeCorner(row, 8)

    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 65, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 28, 160)),
    })
    g.Parent = row
    local gs = makeStroke(row, C.accent, 1.5, 0.4)

    row.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = C.accentHi}):Play()
        task.delay(0.15, function()
            TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.accent2}):Play()
        end)
        if callback then callback() end
    end)
    row.MouseEnter:Connect(function()
        TweenService:Create(gs, TweenInfo.new(0.1), {Transparency = 0}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(gs, TweenInfo.new(0.1), {Transparency = 0.4}):Play()
    end)
    return row
end

local function makeSlider(parent, labelText, minV, maxV, default, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -8, 0, 50)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel  = 0
    row.ZIndex           = 100
    row.Parent           = parent
    makeCorner(row, 8)
    makeStroke(row, C.stroke, 1, 0.5)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.65, 0, 0, 20)
    lbl.Position           = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text               = labelText
    lbl.TextColor3         = C.text
    lbl.Font               = Enum.Font.GothamMedium
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 101
    lbl.Parent             = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size               = UDim2.new(0.3, 0, 0, 20)
    valLbl.Position           = UDim2.new(0.68, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text               = tostring(default)
    valLbl.TextColor3         = C.accentHi
    valLbl.Font               = Enum.Font.GothamBold
    valLbl.TextSize           = 12
    valLbl.TextXAlignment     = Enum.TextXAlignment.Right
    valLbl.ZIndex             = 101
    valLbl.Parent             = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, -24, 0, 5)
    track.Position         = UDim2.new(0, 12, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(20, 14, 40)
    track.BorderSizePixel  = 0
    track.ZIndex           = 100
    track.Parent           = row
    makeCorner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((default-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 101
    fill.Parent           = track
    makeCorner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 15, 0, 15)
    knob.AnchorPoint      = Vector2.new(0.5, 0.5)
    knob.Position         = UDim2.new((default-minV)/(maxV-minV), 0, 0.5, 0)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 102
    knob.Parent           = track
    makeCorner(knob, 8)
    makeStroke(knob, C.accent, 1.5, 0.3)

    local dragSl = false
    local function upd(inp)
        local rx = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV-minV)*rx)
        valLbl.Text = tostring(v)
        fill.Size = UDim2.new(rx, 0, 1, 0)
        knob.Position = UDim2.new(rx, 0, 0.5, 0)
        if callback then callback(v) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragSl = true; upd(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragSl and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragSl = false end
    end)
    return row
end

local function makeSectionRow(parent, text)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1, -8, 0, 24)
    f.BackgroundColor3 = C.section
    f.BorderSizePixel  = 0
    f.ZIndex           = 100
    f.Parent           = parent
    makeCorner(f, 6)

    local pip = Instance.new("Frame")
    pip.Size             = UDim2.new(0, 3, 0.6, 0)
    pip.Position         = UDim2.new(0, 0, 0.2, 0)
    pip.BackgroundColor3 = C.accent
    pip.BorderSizePixel  = 0
    pip.ZIndex           = 101
    pip.Parent           = f
    makeCorner(pip, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, -10, 1, 0)
    lbl.Position           = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = "— " .. text .. " —"
    lbl.TextColor3         = C.accentHi
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 10
    lbl.ZIndex             = 101
    lbl.Parent             = f
    return f
end

local function makeDropdown(parent, labelText, items, default, callback)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -8, 0, 38)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel  = 0
    row.ClipsDescendants = false
    row.ZIndex           = 100
    row.Parent           = parent
    makeCorner(row, 8)
    makeStroke(row, C.stroke, 1, 0.5)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0.5, 0, 0, 18)
    lbl.Position           = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text               = labelText
    lbl.TextColor3         = C.text
    lbl.Font               = Enum.Font.GothamMedium
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 101
    lbl.Parent             = row

    local selLbl = Instance.new("TextLabel")
    selLbl.Size               = UDim2.new(0.42, 0, 0, 18)
    selLbl.Position           = UDim2.new(0.52, 0, 0, 4)
    selLbl.BackgroundTransparency = 1
    selLbl.Text               = default or "Select"
    selLbl.TextColor3         = C.accentHi
    selLbl.Font               = Enum.Font.GothamBold
    selLbl.TextSize           = 11
    selLbl.TextXAlignment     = Enum.TextXAlignment.Right
    selLbl.ZIndex             = 101
    selLbl.Parent             = row

    local chevron = Instance.new("TextLabel")
    chevron.Size               = UDim2.new(0, 14, 0, 18)
    chevron.Position           = UDim2.new(1, -18, 0, 4)
    chevron.BackgroundTransparency = 1
    chevron.Text               = "v"
    chevron.TextColor3         = C.textDim
    chevron.Font               = Enum.Font.GothamBold
    chevron.TextSize           = 10
    chevron.ZIndex             = 101
    chevron.Parent             = row

    local listFrame = Instance.new("Frame")
    listFrame.Size             = UDim2.new(1, -4, 0, 0)
    listFrame.Position         = UDim2.new(0, 2, 0, 24)
    listFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 25)
    listFrame.BorderSizePixel  = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible          = false
    listFrame.ZIndex           = 120
    listFrame.Parent           = row
    makeCorner(listFrame, 6)
    makeStroke(listFrame, C.stroke, 1, 0.3)

    local listScroller = Instance.new("ScrollingFrame")
    listScroller.Size              = UDim2.new(1, 0, 1, 0)
    listScroller.BackgroundTransparency = 1
    listScroller.BorderSizePixel   = 0
    listScroller.CanvasSize        = UDim2.new(0, 0, 0, 0)
    listScroller.ScrollBarThickness = 3
    listScroller.ScrollBarImageColor3 = C.accent
    listScroller.ZIndex            = 121
    listScroller.Parent            = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding             = UDim.new(0, 2)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent              = listScroller

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size               = UDim2.new(1, 0, 0, 22)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text               = ""
    clickBtn.ZIndex             = 101
    clickBtn.Parent             = row

    local selectedItem = default
    local ddOpen = false

    local function setOpen(open)
        ddOpen = open
        listFrame.Visible = open
        chevron.Text = open and "^" or "v"
        if open then
            row.Size = UDim2.new(1, -8, 0, 38 + listFrame.Size.Y.Offset + 4)
        else
            row.Size = UDim2.new(1, -8, 0, 38)
        end
    end

    local function updateList(newItems, keepSel)
        for _, child in ipairs(listScroller:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local selExists = false
        for _, itemName in ipairs(newItems) do
            local ib = Instance.new("TextButton")
            ib.Size             = UDim2.new(1, -4, 0, 22)
            ib.BackgroundColor3 = C.row
            ib.BorderSizePixel  = 0
            ib.Text             = itemName
            ib.TextColor3       = C.text
            ib.Font             = Enum.Font.Gotham
            ib.TextSize         = 11
            ib.ZIndex           = 122
            ib.Parent           = listScroller
            makeCorner(ib, 5)
            if itemName == selectedItem then selExists = true end
            ib.MouseEnter:Connect(function()
                TweenService:Create(ib, TweenInfo.new(0.1), {BackgroundColor3 = C.rowHover, TextColor3 = C.white}):Play()
            end)
            ib.MouseLeave:Connect(function()
                TweenService:Create(ib, TweenInfo.new(0.1), {BackgroundColor3 = C.row, TextColor3 = C.text}):Play()
            end)
            ib.MouseButton1Click:Connect(function()
                selectedItem = itemName; selLbl.Text = itemName
                setOpen(false)
                if callback then callback(itemName) end
            end)
        end
        if keepSel and selExists then selLbl.Text = selectedItem
        elseif keepSel and not selExists then selectedItem = newItems[1]; selLbl.Text = selectedItem or "Select" end
        task.wait()
        listScroller.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
        local ch = listLayout.AbsoluteContentSize.Y + 4
        listFrame.Size = UDim2.new(1, -4, 0, math.min(140, ch))
        if callback and selectedItem then callback(selectedItem) end
    end

    clickBtn.MouseButton1Click:Connect(function() setOpen(not ddOpen) end)
    updateList(items, true)
    row.Size = UDim2.new(1, -8, 0, 38)
    return row, updateList, function() return selectedItem end
end

-- ── TABS ─────────────────────────────────────────────────────
local tabs = {}
local tabFrames = {}
local tabNames = {"Main", "Combat", "Auto", "Target", "Extra", "Configs"}

local function switchTab(name)
    for _, tData in pairs(tabs) do
        local isActive = tData.name == name
        TweenService:Create(tData.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isActive and C.tabActive or C.tabIdle
        }):Play()
        tData.btn.TextColor3 = isActive and C.white or C.textDim
        tData.btn.Font = isActive and Enum.Font.GothamBold or Enum.Font.Gotham
        if tabFrames[tData.name] then
            tabFrames[tData.name].Visible = isActive
        end
    end
end

for _, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 88, 0, TAB_H - 6)
    btn.BackgroundColor3 = C.tabIdle
    btn.Text             = name
    btn.TextColor3       = C.textDim
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 110
    btn.Parent           = tabBar
    makeCorner(btn, 7)

    local tabFrame = Instance.new("Frame")
    tabFrame.Size                   = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible                = false
    tabFrame.ZIndex                 = 100
    tabFrame.Parent                 = contentFrame

    tabFrames[name] = tabFrame
    tabs[name] = {name = name, btn = btn, frame = tabFrame}

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

local scrolls = {}
for _, name in ipairs(tabNames) do
    scrolls[name] = makeScrollList(tabFrames[name])
end

-- ── PREMIUM LOCK-ON BUTTON (SMOOTH animations) ─────────────
local LOFrame = Instance.new("Frame")
LOFrame.Name                  = "LockOnBtn"
LOFrame.Size                  = UDim2.new(0, 88, 0, 88)
LOFrame.Position              = UDim2.new(0.5, -44, 0.45, 0)
LOFrame.BackgroundColor3      = Color3.fromRGB(6, 4, 15)
LOFrame.BackgroundTransparency = 0.15
LOFrame.BorderSizePixel       = 0
LOFrame.Visible               = false
LOFrame.ZIndex                = 201
LOFrame.Active                = true
LOFrame.Parent                = screenGui
makeCorner(LOFrame, 44)

-- outer glow ring (rotating)
local outerRing = Instance.new("Frame")
outerRing.Size                   = UDim2.new(1, 20, 1, 20)
outerRing.Position               = UDim2.new(0, -10, 0, -10)
outerRing.BackgroundTransparency = 1
outerRing.BorderSizePixel        = 0
outerRing.ZIndex                 = 199
outerRing.Parent                 = LOFrame
makeCorner(outerRing, 54)
local outerStroke = makeStroke(outerRing, C.accent, 2.5, 0.4)

-- rotating ring (spins continuously)
local spinRing = Instance.new("Frame")
spinRing.Size = UDim2.new(1.3, 0, 1.3, 0)
spinRing.Position = UDim2.new(-0.15, 0, -0.15, 0)
spinRing.BackgroundTransparency = 1
spinRing.BorderSizePixel = 0
spinRing.ZIndex = 198
spinRing.Parent = LOFrame
makeCorner(spinRing, 58)
local spinStroke = makeStroke(spinRing, Color3.fromRGB(150, 100, 255), 1.8, 0.6)

-- secondary ring (pulsing)
local pulseRing = Instance.new("Frame")
pulseRing.Size = UDim2.new(1, 0, 1, 0)
pulseRing.Position = UDim2.new(0, 0, 0, 0)
pulseRing.BackgroundTransparency = 1
pulseRing.BorderSizePixel = 0
pulseRing.ZIndex = 197
pulseRing.Parent = LOFrame
makeCorner(pulseRing, 44)
local pulseStroke = makeStroke(pulseRing, Color3.fromRGB(200, 150, 255), 2, 0.8)

-- inner glow
local innerGlow = Instance.new("Frame")
innerGlow.Size                   = UDim2.new(0.7, 0, 0.7, 0)
innerGlow.Position               = UDim2.new(0.15, 0, 0.15, 0)
innerGlow.BackgroundColor3       = C.accent
innerGlow.BackgroundTransparency = 0.85
innerGlow.BorderSizePixel        = 0
innerGlow.ZIndex                 = 202
innerGlow.Parent                 = LOFrame
makeCorner(innerGlow, 30)

-- center dot (pulsing scale)
local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 10, 0, 10)
centerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
centerDot.BackgroundColor3 = C.accent
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 205
centerDot.Parent = LOFrame
makeCorner(centerDot, 5)

-- corner brackets (now with glow)
local function mkBracket(ax, ay, rx, ry)
    local bh = Instance.new("Frame")
    bh.Size             = UDim2.new(0, 14, 0, 2)
    bh.AnchorPoint      = Vector2.new(ax, ay)
    bh.Position         = UDim2.new(rx, rx==0 and 12 or -12, ry, ry==0 and 12 or -12)
    bh.BackgroundColor3 = Color3.fromRGB(200, 160, 255)
    bh.BorderSizePixel  = 0; bh.ZIndex = 204; bh.Parent = LOFrame
    makeCorner(bh, 1)
    local bv = Instance.new("Frame")
    bv.Size             = UDim2.new(0, 2, 0, 14)
    bv.AnchorPoint      = Vector2.new(ax, ay)
    bv.Position         = UDim2.new(rx, rx==0 and 12 or -12, ry, ry==0 and 12 or -12)
    bv.BackgroundColor3 = Color3.fromRGB(200, 160, 255)
    bv.BorderSizePixel  = 0; bv.ZIndex = 204; bv.Parent = LOFrame
    makeCorner(bv, 1)
end
mkBracket(0,0, 0,0); mkBracket(1,0, 1,0)
mkBracket(0,1, 0,1); mkBracket(1,1, 1,1)

-- label + status
local lockLabel = Instance.new("TextLabel")
lockLabel.Size = UDim2.new(0,80,0,16); lockLabel.Position = UDim2.new(0,0,1,8)
lockLabel.BackgroundTransparency = 1; lockLabel.Text = "LOCK"
lockLabel.TextColor3 = Color3.fromRGB(180,140,255)
lockLabel.Font = Enum.Font.GothamBold; lockLabel.TextSize = 11
lockLabel.ZIndex = 201; lockLabel.Parent = LOFrame

local lockStatusFrame = Instance.new("Frame")
lockStatusFrame.Size = UDim2.new(0,55,0,16); lockStatusFrame.Position = UDim2.new(0.5,-27,1,28)
lockStatusFrame.BackgroundColor3 = C.accent2; lockStatusFrame.BorderSizePixel = 0
lockStatusFrame.ZIndex = 201; lockStatusFrame.Parent = LOFrame
makeCorner(lockStatusFrame, 8)
local lockStatusLbl = Instance.new("TextLabel")
lockStatusLbl.Size = UDim2.new(1,0,1,0); lockStatusLbl.BackgroundTransparency = 1
lockStatusLbl.Text = "IDLE"; lockStatusLbl.TextColor3 = C.textDim
lockStatusLbl.Font = Enum.Font.GothamBold; lockStatusLbl.TextSize = 9
lockStatusLbl.ZIndex = 202; lockStatusLbl.Parent = lockStatusFrame

-- clickable overlay (will also handle drag)
local lockOnBtn = Instance.new("TextButton")
lockOnBtn.Size = UDim2.new(1,0,1,0); lockOnBtn.BackgroundTransparency = 1
lockOnBtn.Text = ""; lockOnBtn.ZIndex = 206; lockOnBtn.Parent = LOFrame

-- ── ANIMATION LOOPS ─────────────────────────────────────────
local spinAngle = 0
local ringRotating = RunService.Heartbeat:Connect(function(dt)
    if not LOFrame.Visible then return end
    spinAngle = spinAngle + dt * 40
    spinRing.Rotation = spinAngle
end)

-- pulse ring expand/contract
local pulseLoop = task.spawn(function()
    while LOFrame.Parent do
        if LOFrame.Visible then
            TweenService:Create(pulseRing, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Size = UDim2.new(1.6, 0, 1.6, 0), Position = UDim2.new(-0.3, 0, -0.3, 0)}):Play()
            TweenService:Create(pulseStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Transparency = 0.2, Thickness = 3}):Play()
            task.wait(1.8)
            TweenService:Create(pulseRing, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
            TweenService:Create(pulseStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Transparency = 0.8, Thickness = 1.5}):Play()
            task.wait(1.8)
        else task.wait(0.5) end
    end
end)

-- center dot breathing
local dotLoop = task.spawn(function()
    while LOFrame.Parent do
        if LOFrame.Visible then
            TweenService:Create(centerDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0.5, -7, 0.5, -7)}):Play()
            task.wait(1.2)
            TweenService:Create(centerDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0.5, -4, 0.5, -4)}):Play()
            task.wait(1.2)
        else task.wait(0.5) end
    end
end)

-- outer glow breathing
local outerLoop = task.spawn(function()
    while LOFrame.Parent do
        if LOFrame.Visible then
            TweenService:Create(outerStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Transparency = 0.7, Thickness = 4}):Play()
            task.wait(1.5)
            TweenService:Create(outerStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Transparency = 0.2, Thickness = 2}):Play()
            task.wait(1.5)
        else task.wait(0.5) end
    end
end)

-- ── DRAG ─────────────────────────────────────────────────────
local loDrag, loDS, loSP
lockOnBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        loDrag = true; loDS = i.Position; loSP = LOFrame.Position
    end
end)
lockOnBtn.InputChanged:Connect(function(i)
    if loDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - loDS
        LOFrame.Position = UDim2.new(loSP.X.Scale, loSP.X.Offset + d.X, loSP.Y.Scale, loSP.Y.Offset + d.Y)
    end
end)
lockOnBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        loDrag = false
    end
end)

-- ── STATE CHANGE FUNCTIONS (theme switching) ──────────────
local lockRingStroke = innerGlow

local function setLockedTheme()
    TweenService:Create(lockRingStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = C.red, BackgroundTransparency = 0.70}):Play()
    TweenService:Create(centerDot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundColor3 = C.red, Size = UDim2.new(0, 12, 0, 12)}):Play()
    TweenService:Create(LOFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(18, 4, 8), BackgroundTransparency = 0.05}):Play()
    TweenService:Create(outerStroke, TweenInfo.new(0.3), {Color = C.red})  :Play()
    TweenService:Create(spinStroke, TweenInfo.new(0.3), {Color = C.red})    :Play()
    TweenService:Create(pulseStroke, TweenInfo.new(0.3), {Color = C.red})   :Play()
    lockLabel.Text = "LOCKED"; lockLabel.TextColor3 = Color3.fromRGB(255, 100, 120)
    lockStatusLbl.Text = "ON"; lockStatusFrame.BackgroundColor3 = C.redLo
end

local function setIdleTheme()
    TweenService:Create(lockRingStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = C.accent, BackgroundTransparency = 0.85}):Play()
    TweenService:Create(centerDot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundColor3 = C.accent, Size = UDim2.new(0, 10, 0, 10)}):Play()
    TweenService:Create(LOFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(6, 4, 15), BackgroundTransparency = 0.15}):Play()
    TweenService:Create(outerStroke, TweenInfo.new(0.3), {Color = C.accent})  :Play()
    TweenService:Create(spinStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(150, 100, 255)}):Play()
    TweenService:Create(pulseStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(200, 150, 255)}):Play()
    lockLabel.Text = "LOCK"; lockLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
    lockStatusLbl.Text = "IDLE"; lockStatusFrame.BackgroundColor3 = C.accent2
end

switchTab("Main")
openGUI()

-- ==========================================
-- TARGETING: Crosshair-based (Players + Dummy NPC only)
-- ==========================================
local function getNearestTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local bestResult = nil
    local bestDot    = -math.huge

    local function score(char)
        if char == myChar then return end
        local tHRP = char:FindFirstChild("HumanoidRootPart")
        local tHum = char:FindFirstChildOfClass("Humanoid")
        if not tHRP or not tHum or tHum.Health <= 0 then return end
        local toTarget = (tHRP.Position - cam.CFrame.Position)
        if toTarget.Magnitude == 0 then return end
        local dot = cam.CFrame.LookVector:Dot(toTarget.Unit)
        if dot > bestDot and dot > 0 then
            bestDot    = dot
            bestResult = { character = char, root = tHRP, humanoid = tHum }
        end
    end

    -- 1) Score all player characters
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            score(p.Character)
        end
    end

    -- 2) Score ONLY Models named exactly "Dummy"
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Dummy" and obj ~= myChar then
            score(obj)
        end
    end

    return bestResult
end

-- ==========================================
-- RESPAWN SYSTEM (Instant Respawn + Health Check Loop)
-- ==========================================
-- Variables
local respawnEnabled = false
local isRespawning = false
local respawnConnections = {}
local healthCheckConnection = nil

-- Core respawn function: aggressive Heartbeat teleport spam (FIXED)
local function autoRespawn()
    if isRespawning then return end
    isRespawning = true
    local char = LocalPlayer.Character
    if not char then
        isRespawning = false
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        isRespawning = false
        return
    end

    print("[Respawn] Starting aggressive teleport spam (Heartbeat).")

    -- Noclip all parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- Destroy all joints
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("Motor6D") or child:IsA("Weld") or child:IsA("WeldConstraint") then
            pcall(child.Destroy, child)
        end
    end

    -- Force physics
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    -- Spam teleport every frame for 2 seconds
    local startTime = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not char or not char.Parent or not hrp or not hrp.Parent then
            conn:Disconnect()
            isRespawning = false
            return
        end
        -- Teleport to extreme Y (alternate high/low for better kill)
        if (tick() % 0.1) < 0.05 then
            hrp.CFrame = CFrame.new(0, 10000, 0)
        else
            hrp.CFrame = CFrame.new(0, -1000, 0)
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        -- Damage every frame
        hum.Health = 0
        hum:TakeDamage(math.huge)

        if tick() - startTime > 2 then
            conn:Disconnect()
            pcall(function() LocalPlayer:LoadCharacter() end)
            isRespawning = false
        end
    end)

    -- Also try remote respawn methods as a fallback
    task.spawn(function()
        local function tryRemotes(container)
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local n = obj.Name:lower()
                    if n:find("reset") or n:find("respawn") or n:find("die") or n:find("death") then
                        pcall(function() obj:FireServer() end)
                        pcall(function() obj:FireServer(LocalPlayer) end)
                    end
                end
            end
        end
        tryRemotes(game)
        tryRemotes(LocalPlayer)
        task.wait(0.5)
        if not isRespawning then return
        pcall(function() LocalPlayer:LoadCharacter() end)
    end)
end

-- Manual respawn
local function manualRespawn()
    print("[Respawn] Manual respawn.")
    local function tryRemotes(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local n = obj.Name:lower()
                if n:find("reset") or n:find("respawn") or n:find("die") or n:find("death") then
                    pcall(function() obj:FireServer() end)
                    pcall(function() obj:FireServer(LocalPlayer) end)
                end
            end
        end
    end
    tryRemotes(game)
    tryRemotes(LocalPlayer)
    task.wait(0.2)
    pcall(function() LocalPlayer:LoadCharacter() end)
    print("[Respawn] Manual complete.")
end

-- Setup hooks for death detection
local function setupHooks()
    for _, conn in ipairs(respawnConnections) do
        conn:Disconnect()
    end
    respawnConnections = {}

    local function attachToChar(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        print("[Respawn] Attaching hooks to", char.Name)

        local healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if not respawnEnabled then return end
            if hum.Health <= 0 and hum.Health < 1 then
                print("[Respawn] Health hit 0")
                autoRespawn()
            end
        end)
        table.insert(respawnConnections, healthConn)

        local diedConn = hum.Died:Connect(function()
            if not respawnEnabled then return end
            print("[Respawn] Died event")
            autoRespawn()
        end)
        table.insert(respawnConnections, diedConn)

        local stateConn = hum.StateChanged:Connect(function(old, new)
            if not respawnEnabled then return end
            if new == Enum.HumanoidStateType.Dead then
                print("[Respawn] State Dead")
                autoRespawn()
            end
            if new == Enum.HumanoidStateType.Physics and hum.Health <= 0 then
                print("[Respawn] Physics + health<=0")
                autoRespawn()
            end
        end)
        table.insert(respawnConnections, stateConn)

        local removeConn = LocalPlayer.CharacterRemoving:Connect(function(charRemoved)
            if charRemoved == char and respawnEnabled then
                print("[Respawn] CharacterRemoving")
                autoRespawn()
            end
        end)
        table.insert(respawnConnections, removeConn)
    end

    if LocalPlayer.Character then
        attachToChar(LocalPlayer.Character)
    end

    local addedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        attachToChar(newChar)
    end)
    table.insert(respawnConnections, addedConn)

    print("[Respawn] Hooks active.")
end

-- Turn on respawn
local function turnOnRespawn()
    if respawnEnabled then return end
    respawnEnabled = true
    print("[Respawn] Enabled.")

    setupHooks()

    -- Start rapid health check loop
    if healthCheckConnection then healthCheckConnection:Disconnect() end
    healthCheckConnection = RunService.Heartbeat:Connect(function()
        if not respawnEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if hum.Health <= 0 and hum.Health < 1 then
            print("[Respawn] Health check loop triggered")
            autoRespawn()
        end
    end)
end

-- Turn off respawn
local function turnOffRespawn()
    if not respawnEnabled then return end
    respawnEnabled = false
    print("[Respawn] Disabled.")

    if healthCheckConnection then
        healthCheckConnection:Disconnect()
        healthCheckConnection = nil
    end

    for _, conn in ipairs(respawnConnections) do
        conn:Disconnect()
    end
    respawnConnections = {}
end

-- ==========================================
-- MAIN TAB
-- ==========================================
local mainS = scrolls["Main"]

makeSectionRow(mainS, "Movement")

-- No Parkour Cooldown — enabled by default
makeToggle(mainS, "No Parkour Cooldown", true, function(state)
    if state then
        local ok, MC = pcall(function()
            return require(LocalPlayer.PlayerScripts.Controllers.Character.MovementController)
        end)
        if ok and MC then
            RunService:BindToRenderStep("Parkour-Inf", 0, function()
                debug.setupvalue(MC.Parkour, 2, 0)
            end)
        end
    else
        RunService:UnbindFromRenderStep("Parkour-Inf")
    end
end)

-- ==========================================
-- FLY FEATURE
-- ==========================================
local FLY_SPEED   = 50
local flyActive   = false
local flyConn     = nil
local flyAnimTrack = nil

local FLY_ANIM_ID = "rbxassetid://616006778"

local function startFly()
    if flyActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    flyActive = true

    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed,   false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,  false)
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    pcall(function()
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            local anim = Instance.new("Animation")
            anim.AnimationId = FLY_ANIM_ID
            flyAnimTrack = animator:LoadAnimation(anim)
            flyAnimTrack.Priority = Enum.AnimationPriority.Action4
            flyAnimTrack:Play()
        end
    end)

    local bv = Instance.new("BodyVelocity")
    bv.Name      = "FlyBV"
    bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity  = Vector3.zero
    bv.Parent    = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name      = "FlyBG"
    bg.MaxTorque = Vector3.new(0, 1e5, 0)
    bg.P         = 1e4
    bg.D         = 400
    bg.CFrame    = hrp.CFrame
    bg.Parent    = hrp

    flyConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local fbv = root:FindFirstChild("FlyBV")
        local fbg = root:FindFirstChild("FlyBG")
        if not fbv or not fbg then return end

        local cam     = workspace.CurrentCamera
        local camCF   = cam.CFrame
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)
        or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            fbv.Velocity = moveDir.Unit * FLY_SPEED
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flatDir.Magnitude > 0.1 then
                fbg.CFrame = CFrame.new(root.Position, root.Position + flatDir)
            end
        else
            fbv.Velocity = Vector3.zero
        end
    end)
end

local function stopFly()
    if not flyActive then return end
    flyActive = false

    if flyConn then flyConn:Disconnect(); flyConn = nil end

    if flyAnimTrack then
        pcall(function() flyAnimTrack:Stop() end)
        flyAnimTrack = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local fbv = hrp:FindFirstChild("FlyBV")
            local fbg = hrp:FindFirstChild("FlyBG")
            if fbv then fbv:Destroy() end
            if fbg then fbg:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed,   true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,  true)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    flyActive    = false
    flyConn      = nil
    flyAnimTrack = nil
end)

makeToggle(mainS, "Fly", false, function(state)
    if state then startFly() else stopFly() end
end)

makeSlider(mainS, "Fly Speed", 10, 300, 50, function(v)
    FLY_SPEED = v
end)

makeToggle(mainS, "Fullbright", false, function(state)
    game:GetService("Lighting").Brightness = state and 5 or 1
end)

makeSectionRow(mainS, "Prediction Lock")

-- ===== PREDICTION SETTINGS =====
local PREDICTION_FACTOR = 0.22
local LERP_ALPHA = 0.3
local targetData = {}

local lockOnActive = false
local lockedTarget = nil
local lockMethod = {}

local function doUnlockOn()
    lockOnActive = false
    lockedTarget = nil
    targetData   = {}
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
    RunService:UnbindFromRenderStep("LockOnCam")
    setIdleTheme()
end

local function doLockOn()
    local targetInfo = getNearestTarget()
    if not targetInfo then return end
    lockedTarget = targetInfo.character
    lockOnActive = true

    setLockedTheme()

    RunService:BindToRenderStep("LockOnCam", Enum.RenderPriority.Camera.Value + 1, function(delta)
        if not lockedTarget or not lockedTarget.Parent or
           not lockedTarget:FindFirstChild("HumanoidRootPart") or
           lockedTarget:GetAttribute("Dead") then
            doUnlockOn()
            return
        end
        local hum = lockedTarget:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then
            doUnlockOn()
            return
        end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local tHRP = lockedTarget:FindFirstChild("HumanoidRootPart")
        if not tHRP then return end

        -- Predict and move character
        if table.find(lockMethod, "Camera") then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Track
            local camPos = workspace.CurrentCamera.CFrame.Position
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(
                CFrame.new(camPos, tHRP.Position + workspace.CurrentCamera.CFrame.RightVector * 1.75), 0.9
            ) - workspace.CurrentCamera.CFrame.Position + camPos
        end

        if table.find(lockMethod, "Character") then
            local hrp = myChar:FindFirstChild("HumanoidRootPart")
            local myHum = myChar:FindFirstChildOfClass("Humanoid")
            if hrp and myHum then
                myHum.AutoRotate = false

                local currentPos = tHRP.Position
                local data = targetData[tHRP] or {}
                local lastPos = data.lastPos
                local predictedPos = currentPos

                if lastPos and delta > 0.001 then
                    local velocity = (currentPos - lastPos) / delta
                    predictedPos = currentPos + velocity * PREDICTION_FACTOR
                end

                if data.smoothed then
                    predictedPos = data.smoothed:Lerp(predictedPos, LERP_ALPHA)
                end

                data.lastPos = currentPos
                data.smoothed = predictedPos
                targetData[tHRP] = data

                local offset = Vector3.new(
                    predictedPos.X - hrp.Position.X,
                    0,
                    predictedPos.Z - hrp.Position.Z
                )
                if offset.Magnitude > 0.001 then
                    hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + offset.Unit)
                end
            end
        end
    end)
end

lockOnBtn.MouseButton1Click:Connect(function()
    if lockOnActive then doUnlockOn() else doLockOn() end
end)

local lockToggleRow, setLockToggle, getLockToggle = makeToggle(mainS, "Prediction Lock", false, function(state)
    LOFrame.Visible = state
    if state then doLockOn() else doUnlockOn() end
end)

makeSlider(mainS, "Prediction Factor", 1, 100, 22, function(v)
    PREDICTION_FACTOR = v / 100
end)

makeSlider(mainS, "Prediction Smoothing", 0, 100, 30, function(v)
    LERP_ALPHA = v / 100
end)

makeToggle(mainS, "Lock Mode: Camera", false, function(state)
    if state then table.insert(lockMethod, "Camera")
    else local i = table.find(lockMethod, "Camera"); if i then table.remove(lockMethod, i) end end
end)

makeToggle(mainS, "Lock Mode: Character", false, function(state)
    if state then table.insert(lockMethod, "Character")
    else local i = table.find(lockMethod, "Character"); if i then table.remove(lockMethod, i) end end
end)

makeSectionRow(mainS, "Hitbox")

makeSlider(mainS, "Hitbox Size", 1, 20, 4, function(v)
    _G.HitboxSize = v
end)

makeToggle(mainS, "Expand Hitbox", false, function(state)
    _G.ExpandHitbox = state
    if state then
        RunService:BindToRenderStep("HitboxExpand", 0, function()
            if not _G.ExpandHitbox then
                RunService:UnbindFromRenderStep("HitboxExpand")
                return
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(_G.HitboxSize or 4, _G.HitboxSize or 4, _G.HitboxSize or 4)
                    end
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("HitboxExpand")
    end
end)

-- ==========================================
-- COMBAT TAB
-- ==========================================
local combatS = scrolls["Combat"]

makeSectionRow(combatS, "Blackflash")

local bfConn = nil
makeToggle(combatS, "Yuji 100% Blackflash", true, function(state)
    if state then
        if bfConn then bfConn:Disconnect(); bfConn = nil end
        local service = RS.Knit.Knit.Services:WaitForChild("DivergentFistService")
        if service and service.RE and service.RE.Effects then
            bfConn = service.RE.Effects.OnClientEvent:Connect(function(...)
                local args = {...}
                local eventType = args[#args - 1]
                local eventChar = args[#args]
                if eventType == "CurseBuild" and eventChar == LocalPlayer.Character then
                    task.wait(0.07)
                    pcall(function()
                        service.RE.Activated:FireServer(
                            LocalPlayer.Character.Moveset:FindFirstChild("Divergent Fist")
                        )
                    end)
                end
            end)
        end
    else
        if bfConn then
            bfConn:Disconnect()
            bfConn = nil
        end
    end
end)

-- ── RESPAWN SECTION ──
makeSectionRow(combatS, "Respawn")

-- Toggle for auto respawn
makeToggle(combatS, "Auto Respawn", false, function(state)
    if state then
        turnOnRespawn()
    else
        turnOffRespawn()
    end
end)

-- Manual respawn button
makeButton(combatS, "Manual Respawn", function()
    manualRespawn()
end)

-- ==========================================
-- TARGET TAB (Teleports + Spectate)
-- ==========================================
local targetTab = scrolls["Target"]

-- Shared TP functions
local function resetChar()
    workspace.FallenPartsDestroyHeight = -150
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function isAlive(player)
    if not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local function breakJoints(char)
    if not char then return end
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("Motor6D") or child:IsA("Weld") or child:IsA("WeldConstraint") then
            pcall(child.Destroy, child)
        end
    end
end

-- TP Bypass
local bodyVelocity, bodyGyro, antistuffConn = nil, nil, nil
local tpBypassOn = false

local function antistuff()
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if antistuffConn then antistuffConn:Disconnect() end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 0, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 0
    bodyGyro.D = 50
    bodyGyro.Parent = hrp
    antistuffConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and bodyVelocity then
            local md = hum.MoveDirection
            bodyVelocity.Velocity = md.Magnitude > 0
                and Vector3.new(md.X, 0, md.Z) * 22
                or Vector3.new(0, 0, 0)
        end
    end)
end

local function unantistuff()
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if antistuffConn then antistuffConn:Disconnect(); antistuffConn = nil end
end

-- FAST TELEPORT
local function tpToSpam(hrp, tHRP, tHum)
    local predicted = tHRP.Position + (tHum.MoveDirection * 0.8 * tHum.WalkSpeed)
    local dest = CFrame.new(predicted - tHRP.CFrame.LookVector * 2, predicted)
    local char = LocalPlayer.Character

    if tpBypassOn then unantistuff() end
    breakJoints(char)

    for i = 1, 3 do
        hrp.CFrame = dest * CFrame.new(
            math.random(-1, 1) * 0.05,
            math.random(-1, 1) * 0.05,
            math.random(-1, 1) * 0.05
        )
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    hrp.CFrame = dest

    if tpBypassOn then antistuff() end
    workspace.FallenPartsDestroyHeight = -150
end

-- TP Bypass toggle
makeToggle(targetTab, "TP Bypass", false, function(state)
    tpBypassOn = state
    if state then antistuff() else unantistuff() end
end)

-- TP Selected
local tpSelOn = false
local tpSelConn = nil
local selectedPlayer = nil

local function stopSelLoop()
    tpSelOn = false
    if tpSelConn then tpSelConn:Disconnect(); tpSelConn = nil end
    selectedPlayer = nil
    if not tpBypassOn then unantistuff() end
    workspace.FallenPartsDestroyHeight = -150
    resetChar()
end

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
end
local tpSelDropdown, updateTpSelList, getTpSelPlayer = makeDropdown(targetTab, "TP Selected Target", playerNames, playerNames[1], function(value)
    selectedPlayer = Players:FindFirstChild(value)
end)

makeToggle(targetTab, "TP Selected", false, function(state)
    if state then
        if not selectedPlayer then
            local first = Players:GetPlayers()[1]
            if first and first ~= LocalPlayer then selectedPlayer = first end
        end
        if not selectedPlayer then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "TP Selected",
                Text = "No valid player found.",
                Duration = 2
            })
            return
        end
        tpSelOn = true
        if not tpBypassOn then antistuff() end
        setTeleportStatus("TP -> " .. selectedPlayer.Name, Color3.fromRGB(255, 180, 80))
        if tpSelConn then tpSelConn:Disconnect(); tpSelConn = nil end
        tpSelConn = RunService.Heartbeat:Connect(function()
            if not tpSelOn then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local tChar = selectedPlayer and selectedPlayer.Character
            if not tChar then return end
            local tHRP = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChildOfClass("Humanoid")
            if not tHRP or not tHum then return end
            tpToSpam(hrp, tHRP, tHum)
        end)
    else
        stopSelLoop()
    end
end)

-- TP All Loop
local tpLoopOn = false
local tpLoopConn = nil

makeToggle(targetTab, "TP All Loop", false, function(state)
    tpLoopOn = state
    if state then
        if not tpBypassOn then antistuff() end
        if tpLoopConn then tpLoopConn:Disconnect(); tpLoopConn = nil end

        tpLoopConn = RunService.Heartbeat:Connect(function()
            if not tpLoopOn then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local alive = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isAlive(p) then
                    table.insert(alive, p)
                end
            end

            local target
            if #alive > 0 then
                target = alive[math.random(1, #alive)]
            else
                local dead = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and not isAlive(p) then
                        table.insert(dead, p)
                    end
                end
                if #dead > 0 then
                    target = dead[math.random(1, #dead)]
                end
            end

            if target then
                local tChar = target.Character
                if tChar then
                    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar:FindFirstChildOfClass("Humanoid")
                    if tHRP and tHum then
                        tpToSpam(hrp, tHRP, tHum)
                        local tag = isAlive(target) and "A" or "D"
                        setTeleportStatus("🔁 " .. tag .. " " .. target.Name, Color3.fromRGB(255, 180, 100))
                    end
                end
            else
                setTeleportStatus("🔁 No targets", Color3.fromRGB(200, 200, 200))
            end
        end)
    else
        if tpLoopConn then tpLoopConn:Disconnect(); tpLoopConn = nil end
        if not tpBypassOn then unantistuff() end
        workspace.FallenPartsDestroyHeight = -150
        resetChar()
        setTeleportStatus("TP Loop OFF", Color3.fromRGB(150, 150, 150))
    end
end)

-- Status label for Teleport tab
local function setTeleportStatus(msg, color)
    local statusRow = targetTab:FindFirstChild("StatusRow")
    if statusRow then
        local lbl = statusRow:FindFirstChild("StatusLabel")
        if lbl then
            lbl.Text = msg
            lbl.TextColor3 = color or C.textDim
        end
    end
end

local statusRowTp = Instance.new("Frame")
statusRowTp.Name = "StatusRow"
statusRowTp.Size = UDim2.new(1, -4, 0, 20)
statusRowTp.BackgroundColor3 = C.row
statusRowTp.BorderSizePixel = 0
statusRowTp.ZIndex = 100
statusRowTp.Parent = targetTab
makeCorner(statusRowTp, 5)
makeStroke(statusRowTp, C.stroke, 1, 0.5)
local statusLblTp = Instance.new("TextLabel")
statusLblTp.Name = "StatusLabel"
statusLblTp.Size = UDim2.new(1, 0, 1, 0)
statusLblTp.BackgroundTransparency = 1
statusLblTp.Text = "Ready"
statusLblTp.TextColor3 = C.textDim
statusLblTp.Font = Enum.Font.Gotham
statusLblTp.TextSize = 10
statusLblTp.TextXAlignment = Enum.TextXAlignment.Center
statusLblTp.ZIndex = 101
statusLblTp.Parent = statusRowTp

-- ── SPECTATE FEATURE (Dropdown + Free Camera) ──────────────
makeSectionRow(targetTab, "Spectate")

local spectatePlayer = nil
local spectateActive = false
local spectateConnection = nil

-- Dropdown to select target player
local spectateDropdown, updateSpectateDropdown, getSpectatePlayer = makeDropdown(targetTab, "Spectate Target", playerNames, playerNames[1], function(value)
    spectatePlayer = Players:FindFirstChild(value)
end)

-- Toggle to start/stop spectating
local spectateToggleRow, setSpectateToggle, getSpectateToggle = makeToggle(targetTab, "Spectate", false, function(state)
    spectateActive = state
    if state then
        if not spectatePlayer then
            Notify({Title="Spectate", Description="No player selected", Duration=2})
            spectateActive = false
            setSpectateToggle(false)
            return
        end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        local char = spectatePlayer.Character
        if char then
            workspace.CurrentCamera.CameraSubject = char
        else
            Notify({Title="Spectate", Description="Target character not found", Duration=2})
            spectateActive = false
            setSpectateToggle(false)
            return
        end
        if spectateConnection then spectateConnection:Disconnect() end
        spectateConnection = RunService.RenderStepped:Connect(function()
            if not spectateActive then
                spectateConnection:Disconnect()
                spectateConnection = nil
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character or workspace
                return
            end
            local char = spectatePlayer and spectatePlayer.Character
            if char then
                workspace.CurrentCamera.CameraSubject = char
            end
        end)
    else
        if spectateConnection then
            spectateConnection:Disconnect()
            spectateConnection = nil
        end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character or workspace
        spectatePlayer = nil
    end
end)

-- ==========================================
-- AUTO TAB
-- ==========================================
local autoS = scrolls["Auto"]

makeSectionRow(autoS, "M1 Assist")

local M1Method = "UpperCut"
local autoM1Active = false
local autoM1Hook   = nil
local autoM1Connections = {}
local comboCount = 0
local lastHitTime = 0

local function startM1Assist()
    if autoM1Active then return end
    autoM1Active = true
    comboCount = 0
    lastHitTime = 0

    if not autoM1Hook then
        autoM1Hook = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            local a = {...}
            if autoM1Active and m == "FireServer" and self.Name == "Activated" then
                if a[1] == false then
                    a[1] = (M1Method == "UpperCut") and "Up" or "Down"
                end
                return autoM1Hook(self, unpack(a))
            end
            return autoM1Hook(self, ...)
        end)
    end

    local function onSwing2(...)
        local args = {...}
        if args[1] == "Swing2" and args[2] == LocalPlayer.Character and args[3] == 3 then
            local now = tick()
            if now - lastHitTime > 2 then comboCount = 0 end
            lastHitTime = now
            comboCount = comboCount + 1
            if comboCount >= 4 then
                comboCount = 0
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:Move(Vector3.new(0,0,0), false) end
                end
            end
        end
    end

    for _, service in ipairs(RS.Knit.Knit.Services:GetChildren()) do
        if service:FindFirstChild("RE") and service.RE:FindFirstChild("Effects") then
            local conn = service.RE.Effects.OnClientEvent:Connect(onSwing2)
            table.insert(autoM1Connections, conn)
        end
    end
end

local function stopM1Assist()
    autoM1Active = false
    for _, conn in ipairs(autoM1Connections) do
        pcall(conn.Disconnect, conn)
    end
    table.clear(autoM1Connections)
    comboCount = 0
end

local m1MethodItems = {"UpperCut", "DownSlam"}
local m1Dropdown, updateM1Dropdown, getM1Method = makeDropdown(autoS, "M1 Method", m1MethodItems, "UpperCut", function(value)
    M1Method = value
    if autoM1Active then
        stopM1Assist()
        startM1Assist()
    end
end)

makeToggle(autoS, "M1 Assist", true, function(state)
    if state then startM1Assist() else stopM1Assist() end
end)

makeSectionRow(autoS, "Auto Burst")

local autoBurstActive = false
local autoBurstRenderStep = nil

local function startAutoBurst()
    if autoBurstActive then return end
    autoBurstActive = true
    autoBurstRenderStep = RunService:BindToRenderStep("Auto-Burst", 0, function()
        if not autoBurstActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local burstFound = false
        for _, child in ipairs(hrp:GetChildren()) do
            if child.Name == "BurstIcon" or child.Name == "Evade" then
                burstFound = true
                break
            end
        end
        if not burstFound then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local dir = "Left"
            if math.abs(moveDir.X) > math.abs(moveDir.Z) then
                dir = moveDir.X > 0 and "Right" or "Left"
            else
                dir = moveDir.Z < 0 and "Back" or "Left"
            end
            local movementService = RS.Knit.Knit.Services.MovementService
            if movementService and movementService.RE and movementService.RE.Dash then
                pcall(function()
                    movementService.RE.Dash:FireServer(dir, true)
                end)
            end
        end
    end)
end

local function stopAutoBurst()
    autoBurstActive = false
    if autoBurstRenderStep then
        RunService:UnbindFromRenderStep("Auto-Burst")
        autoBurstRenderStep = nil
    end
end

makeToggle(autoS, "Auto Burst", true, function(state)
    if state then startAutoBurst() else stopAutoBurst() end
end)

-- AUTO RATIO (Nanami)
makeSectionRow(autoS, "Nanami")

local autoRatioConn = nil
local autoRatioTable = {}

makeToggle(autoS, "Auto Ratio", false, function(state)
    if state then
        if autoRatioConn then autoRatioConn:Disconnect(); autoRatioConn = nil end
        local nanamiService = game.ReplicatedStorage.Knit.Knit.Services:FindFirstChild("NanamiService")
        if nanamiService and nanamiService.RE and nanamiService.RE.Effects then
            autoRatioConn = nanamiService.RE.Effects.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] == "SpawnRatio" and args[2] == LocalPlayer then
                    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                    local delay = args[6] * math.clamp(0.56 - (math.floor(ping) - 100) / 1000 * 0.9, 0.25, 0.85)
                    task.wait(delay)
                    if nanamiService and nanamiService.RE and nanamiService.RE.RightActivated then
                        pcall(function()
                            nanamiService.RE.RightActivated:FireServer()
                        end)
                    end
                end
            end)
            autoRatioTable.AutoRatio1 = autoRatioConn
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Ratio",
                Text = "NanamiService not found!",
                Duration = 2
            })
        end
    else
        if autoRatioConn then
            autoRatioConn:Disconnect()
            autoRatioConn = nil
            autoRatioTable.AutoRatio1 = nil
        end
    end
end)

-- PERFECT SWAP (Todo)
makeSectionRow(autoS, "Todo")

local perfectSwapActive = false
local perfectSwapConn = nil
local perfectSwapCharConn = nil
local perfectSwapEventConn = nil
local perfectSwapConnections = {}

local function setupPerfectSwap(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    local animConn = animator.AnimationPlayed:Connect(function(track)
        if not perfectSwapActive then return end
        if track.Animation then
            local id = track.Animation.AnimationId
            if id == "rbxassetid://91074768993486" or
               id == "rbxassetid://131358603583212" or
               id == "rbxassetid://116040503139675" then
                if not perfectSwapEventConn then
                    local todoService = RS.Knit.Knit.Services:FindFirstChild("TodoService")
                    if todoService and todoService.RE and todoService.RE.Effects then
                        perfectSwapEventConn = todoService.RE.Effects.OnClientEvent:Connect(function(...)
                            if not perfectSwapActive then return end
                            local args = {...}
                            if args[1] == "Swap" or args[1] == "Swap2" or args[1] == "Fakeout" then
                                local todoSvc = RS.Knit.Knit.Services:FindFirstChild("TodoService")
                                if todoSvc and todoSvc.RE and todoSvc.RE.Activated then
                                    pcall(function()
                                        todoSvc.RE.Activated:FireServer(false)
                                    end)
                                    if perfectSwapEventConn then
                                        perfectSwapEventConn:Disconnect()
                                        perfectSwapEventConn = nil
                                    end
                                end
                            end
                        end)
                        table.insert(perfectSwapConnections, perfectSwapEventConn)
                    end
                end
            end
        end
    end)
    table.insert(perfectSwapConnections, animConn)
end

makeToggle(autoS, "Perfect Swap", true, function(state)
    if state then
        if perfectSwapActive then return end
        perfectSwapActive = true
        perfectSwapConnections = {}
        perfectSwapEventConn = nil

        local char = LocalPlayer.Character
        if char then
            setupPerfectSwap(char)
        end

        perfectSwapCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            if perfectSwapActive then
                setupPerfectSwap(newChar)
            end
        end)
        table.insert(perfectSwapConnections, perfectSwapCharConn)
    else
        perfectSwapActive = false
        for _, conn in ipairs(perfectSwapConnections) do
            pcall(conn.Disconnect, conn)
        end
        table.clear(perfectSwapConnections)
        perfectSwapEventConn = nil
        perfectSwapCharConn = nil
    end
end)

-- AUTO GARUDA REBOUND
makeSectionRow(autoS, "Garuda")

local autoGarudaConn = nil
local autoGarudaTable = {}

makeToggle(autoS, "Auto Garuda Rebound", false, function(state)
    if state then
        if autoGarudaConn then autoGarudaConn:Disconnect(); autoGarudaConn = nil end
        local garudaService = game.ReplicatedStorage.Knit.Knit.Services:FindFirstChild("GarudaReboundService")
        if garudaService and garudaService.RE and garudaService.RE.Effects then
            autoGarudaConn = garudaService.RE.Effects.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] == "Recall" and args[2] == LocalPlayer.Character then
                    if args[5] == 0.1 then return end
                    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                    local delay = math.max(args[5] - math.clamp(0.1 + math.floor(ping) / 1000 * 0.6, 0.12, 0.35), 0)
                    task.wait(delay)
                    if garudaService and garudaService.RE and garudaService.RE.Activated then
                        pcall(function()
                            garudaService.RE.Activated:FireServer(LocalPlayer.Character.Moveset:FindFirstChild("Garuda Rebound"))
                        end)
                    end
                end
            end)
            autoGarudaTable.AutoGarudaRebound = autoGarudaConn
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Garuda Rebound",
                Text = "GarudaReboundService not found!",
                Duration = 2
            })
        end
    else
        if autoGarudaConn then
            autoGarudaConn:Disconnect()
            autoGarudaConn = nil
            autoGarudaTable.AutoGarudaRebound = nil
        end
    end
end)

-- ==========================================
-- EXTRA TAB
-- ==========================================
local extraS = scrolls["Extra"]

makeSectionRow(extraS, "Emotes")

makeButton(extraS, "Emote Unlocker", function()
    local gp = game:GetService("Players").LocalPlayer:WaitForChild("Gamepasses")
    gp:SetAttribute("742180133", true)
    gp:SetAttribute("1151174294", true)

    pcall(function()
        local Menus = LocalPlayer.PlayerGui:WaitForChild("Menus")
        for _, obj in ipairs(Menus:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("ImageButton") or obj:IsA("TextButton") then
                local n = tonumber(obj.Name)
                if n and n >= 5 and n <= 9 then obj.Visible = true end
                if obj.Name == "Switch" then obj.Visible = true end
            end
        end
        local ok, Equipped = pcall(function()
            return Menus:WaitForChild("Group", 3).Inventory.Items.Emotes.Equipped
        end)
        if ok and Equipped then
            for _, v in ipairs(Equipped:GetChildren()) do
                local n = tonumber(v.Name)
                if n and n >= 5 then v.Visible = true end
            end
            local sw = Equipped:FindFirstChild("Switch")
            if sw then sw.Visible = true end
        end
    end)

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Emote Unlocker",
        Text = "Extra emote slots unlocked!",
        Duration = 3
    })
end)

makeSectionRow(extraS, "Item Grabber")

local KNOWN_ITEMS = {
    "Soda", "Coin", "Jet Black", "Gun", "Playful Cloud", "Transfigured Flesh",
    "Voice Recorder", "Hazenoki's Eye", "Sniper", "Transfigured Human",
    "Tinted Glasses", "TNT", "Banana Peel", "Naginata", "Bowling Ball",
    "Crowbar", "Broom", "Flashlight", "Snowball", "Tiantui Star's Blade",
    "Arayashiki", "Nepcard", "Pen"
}

local MIN_Y = -50
local MAX_Y = 1000

local function scanItems()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
        if not prompt then
            for _, child in ipairs(obj:GetChildren()) do
                prompt = child:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then break end
            end
        end
        if prompt and prompt.Enabled then
            local container = prompt.Parent
            local name = container.Name
            if table.find(KNOWN_ITEMS, name) then
                local valid = true
                if container:IsA("BasePart") then
                    local pos = container.Position
                    if pos.Y < MIN_Y or pos.Y > MAX_Y then valid = false end
                else
                    local part = container:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local pos = part.Position
                        if pos.Y < MIN_Y or pos.Y > MAX_Y then valid = false end
                    else
                        valid = false
                    end
                end
                if valid and not table.find(found, name) then
                    table.insert(found, name)
                end
            end
        end
    end
    return found
end

local function findItem(itemName)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == itemName then
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt and prompt.Enabled then
                local targetPart = nil
                if prompt.Parent:IsA("BasePart") then
                    targetPart = prompt.Parent
                else
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            targetPart = part
                            break
                        end
                    end
                end
                if targetPart then
                    local pos = targetPart.Position
                    if pos.Y >= MIN_Y and pos.Y <= MAX_Y then
                        return obj, prompt, targetPart
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

local function instantGrab(targetPart, prompt)
    if not targetPart or not targetPart:IsA("BasePart") then return false end
    if not prompt or not prompt.Enabled then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return false end
    local originalCF = rootPart.CFrame
    local originalCamOffset = humanoid.CameraOffset
    local targetCF = targetPart.CFrame + Vector3.new(0, 0.2, 0)
    local success = false
    local startTime = tick()
    local maxTime = 1.5
    while tick() - startTime < maxTime do
        if not targetPart.Parent or not prompt.Enabled then
            success = true; break
        end
        humanoid.CameraOffset = targetCF:ToObjectSpace(CFrame.new(originalCF.Position)).Position
        rootPart.CFrame = targetCF
        RunService.RenderStepped:Wait()
        fireproximityprompt(prompt)
        task.wait()
    end
    rootPart.CFrame = originalCF
    humanoid.CameraOffset = originalCamOffset
    return success
end

local itemList = scanItems()
local selectedItemName = itemList[1] or ""
local dropdownRow, updateDropdown, getSelected = makeDropdown(extraS, "Select Item", itemList, selectedItemName, function(value)
    selectedItemName = value
end)

makeButton(extraS, "⟳ Refresh Item List", function()
    local newList = scanItems()
    updateDropdown(newList, true)
    selectedItemName = #newList > 0 and newList[1] or ""
end)

local statusRowExtra = Instance.new("Frame")
statusRowExtra.Size = UDim2.new(1, -4, 0, 20)
statusRowExtra.BackgroundColor3 = C.row
statusRowExtra.BorderSizePixel = 0
statusRowExtra.ZIndex = 100
statusRowExtra.Parent = extraS
makeCorner(statusRowExtra, 5)
makeStroke(statusRowExtra, C.stroke, 1, 0.5)

local statusLblExtra = Instance.new("TextLabel")
statusLblExtra.Size = UDim2.new(1, 0, 1, 0)
statusLblExtra.BackgroundTransparency = 1
statusLblExtra.Text = "Ready"
statusLblExtra.TextColor3 = C.textDim
statusLblExtra.Font = Enum.Font.Gotham
statusLblExtra.TextSize = 10
statusLblExtra.TextXAlignment = Enum.TextXAlignment.Center
statusLblExtra.ZIndex = 101
statusLblExtra.Parent = statusRowExtra

makeButton(extraS, "⬆ Pick Up Selected Item", function()
    if selectedItemName == "" then
        statusLblExtra.Text = "No item selected"
        statusLblExtra.TextColor3 = Color3.fromRGB(255, 200, 100)
        return
    end
    local container, prompt, targetPart = findItem(selectedItemName)
    if not targetPart or not prompt then
        statusLblExtra.Text = "Item not available"
        statusLblExtra.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    statusLblExtra.Text = "Grabbing..."
    statusLblExtra.TextColor3 = Color3.fromRGB(255, 200, 50)
    local success = instantGrab(targetPart, prompt)
    if success then
        statusLblExtra.Text = "✓ Picked up!"
        statusLblExtra.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(0.5, function()
            local newList = scanItems()
            updateDropdown(newList, true)
            selectedItemName = #newList > 0 and newList[1] or ""
            statusLblExtra.Text = "Ready"
            statusLblExtra.TextColor3 = C.textDim
        end)
    else
        statusLblExtra.Text = "✗ Failed"
        statusLblExtra.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.delay(1.5, function()
            statusLblExtra.Text = "Ready"
            statusLblExtra.TextColor3 = C.textDim
        end)
    end
end)

-- Walk into Domains
makeSectionRow(extraS, "Domain")

makeToggle(extraS, "Walk into Domains", false, function(state)
    if state then
        RunService:BindToRenderStep("Walk-Domain", 0, function()
            local domains = workspace:FindFirstChild("Domains")
            if domains then
                local domain = domains:FindFirstChild("Domain")
                if domain and domain:IsA("BasePart") then
                    domain.CanCollide = false
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("Walk-Domain")
    end
end)

makeSectionRow(extraS, "Misc")

makeToggle(extraS, "Anti AFK", false, function(state)
    _G.AntiAFK = state
    if state then
        local vrs = game:GetService("VirtualInputManager")
        task.spawn(function()
            while _G.AntiAFK do
                vrs:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                vrs:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                task.wait(15)
            end
        end)
    end
end)

makeButton(extraS, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

makeButton(extraS, "Copy Server ID", function()
    setclipboard(game.JobId)
end)

-- ==========================================
-- CONFIGS TAB
-- ==========================================
local configS = scrolls["Configs"]

makeSectionRow(configS, "UI Settings")

makeSlider(configS, "UI Transparency", 0, 90, 0, function(v)
    window.BackgroundTransparency = v / 100
end)

makeButton(configS, "Reset Position", function()
    window.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
end)

makeSectionRow(configS, "Credits")

local credLbl = Instance.new("Frame")
credLbl.Size = UDim2.new(1, -4, 0, 36)
credLbl.BackgroundColor3 = C.row
credLbl.BorderSizePixel = 0
credLbl.ZIndex = 100
credLbl.Parent = configS
makeCorner(credLbl, 6)

local credText = Instance.new("TextLabel")
credText.Size = UDim2.new(1, 0, 1, 0)
credText.BackgroundTransparency = 1
credText.Text = "｢KZM」 • Made for JJS\nBuilt by KZM"
credText.TextColor3 = C.textDim
credText.Font = Enum.Font.Gotham
credText.TextSize = 10
credText.TextXAlignment = Enum.TextXAlignment.Center
credText.ZIndex = 101
credText.Parent = credLbl

-- ==========================================
-- RESET ON RESPAWN
-- ==========================================
LocalPlayer.CharacterAdded:Connect(function()
    tpBypassOn = false
    unantistuff()
    tpSelOn = false
    if tpSelConn then tpSelConn:Disconnect(); tpSelConn = nil end
    tpLoopOn = false
    if tpLoopConn then tpLoopConn:Disconnect(); tpLoopConn = nil end
    workspace.FallenPartsDestroyHeight = -150
    selectedPlayer = nil
    setTeleportStatus("Respawned", Color3.fromRGB(100, 200, 100))
    -- reset spectate
    if spectateConnection then spectateConnection:Disconnect(); spectateConnection = nil end
    spectateActive = false
    setSpectateToggle(false)
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = LocalPlayer.Character or workspace
end)

-- Auto-start always-on features
task.defer(function()
    startM1Assist()
    startAutoBurst()
    perfectSwapActive = true
    local char = LocalPlayer.Character
    if char then setupPerfectSwap(char) end
    perfectSwapCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        if perfectSwapActive then setupPerfectSwap(newChar) end
    end)
end)

print("KZM v3.1 loaded — Respawn fixed (Heartbeat spam), Side Dash Assist removed")
