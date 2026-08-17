-- ==========================================
-- KZM v3.0 — Premium GUI
-- ==========================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RS                = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

-- ── PALETTE ─────────────────────────────────────────────────
local C = {
    bg         = Color3.fromRGB(6,   4,  14),
    bgCard     = Color3.fromRGB(11,  8,  22),
    panel      = Color3.fromRGB(15, 11,  28),
    row        = Color3.fromRGB(28, 22,  50),
    rowHover   = Color3.fromRGB(38, 30,  68),
    accent     = Color3.fromRGB(108, 60, 255),
    accentMid  = Color3.fromRGB(80,  42, 200),
    accentLo   = Color3.fromRGB(55,  28, 145),
    accentHi   = Color3.fromRGB(150, 100, 255),
    accentGlow = Color3.fromRGB(130, 80, 255),
    purple2    = Color3.fromRGB(180, 80, 255),
    red        = Color3.fromRGB(220,  50,  80),
    redLo      = Color3.fromRGB(140,  20,  45),
    stroke     = Color3.fromRGB(80,   50, 160),
    strokeDim  = Color3.fromRGB(40,   28,  85),
    text       = Color3.fromRGB(225, 218, 245),
    textDim    = Color3.fromRGB(120, 105, 160),
    textMuted  = Color3.fromRGB(75,   60, 110),
    toggleOn   = Color3.fromRGB(108, 60, 255),
    toggleOff  = Color3.fromRGB(22,  16,  45),
    white      = Color3.fromRGB(255, 255, 255),
    tabActive  = Color3.fromRGB(108, 60, 255),
    tabIdle    = Color3.fromRGB(15,  11,  28),
}

-- ── HELPERS ──────────────────────────────────────────────────
local function mkC(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function mkS(p, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or C.stroke
    s.Thickness = th or 1.5
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function mkGrad(p, rot, c0, c1)
    local g = Instance.new("UIGradient")
    g.Rotation = rot
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0),
        ColorSequenceKeypoint.new(1, c1),
    })
    g.Parent = p
    return g
end

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function tweenSine(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), props):Play()
end

-- ── SCREEN GUI ───────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KZM"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 200
screenGui.IgnoreGuiInset = false
screenGui.Parent = LocalPlayer.PlayerGui

-- ── WINDOW DIMENSIONS ────────────────────────────────────────
local WIN_W   = 720
local WIN_H   = 400
local TITLE_H = 48
local TAB_H   = 38

-- ════════════════════════════════════════════════════════════
-- TOGGLE PILL BUTTON
-- ════════════════════════════════════════════════════════════
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 88, 0, 32)
toggleBtn.Position = UDim2.new(0, 12, 0, 58)
toggleBtn.BackgroundColor3 = C.accentLo
toggleBtn.Text = "KZM"
toggleBtn.TextColor3 = C.white
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 200
toggleBtn.Parent = screenGui
mkC(toggleBtn, 16)
mkS(toggleBtn, C.accent, 1.5)
mkGrad(toggleBtn, 90, Color3.fromRGB(90,50,220), Color3.fromRGB(55,28,145))

-- glow behind toggle
local toggleGlow = Instance.new("Frame")
toggleGlow.Size = UDim2.new(1, 20, 1, 20)
toggleGlow.Position = UDim2.new(0, -10, 0, -10)
toggleGlow.BackgroundColor3 = C.accent
toggleGlow.BackgroundTransparency = 0.75
toggleGlow.BorderSizePixel = 0
toggleGlow.ZIndex = 199
toggleGlow.Parent = toggleBtn
mkC(toggleGlow, 22)

task.spawn(function()
    while true do
        tweenSine(toggleGlow, 1.2, {BackgroundTransparency = 0.88})
        task.wait(1.2)
        tweenSine(toggleGlow, 1.2, {BackgroundTransparency = 0.70})
        task.wait(1.2)
    end
end)

-- ════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ════════════════════════════════════════════════════════════
local window = Instance.new("Frame")
window.Name = "KZMWindow"
window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
window.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 20)
window.BackgroundColor3 = C.bg
window.BorderSizePixel = 0
window.Active = true
window.Visible = false
window.ZIndex = 100
window.ClipsDescendants = false
window.Parent = screenGui
mkC(window, 16)

-- layered background gradient
local winBg = Instance.new("Frame")
winBg.Size = UDim2.new(1,0,1,0)
winBg.BackgroundColor3 = C.bg
winBg.BorderSizePixel = 0
winBg.ZIndex = 100
winBg.Parent = window
mkC(winBg, 16)
mkGrad(winBg, 135,
    Color3.fromRGB(10, 6, 22),
    Color3.fromRGB(6,  4, 14))

-- animated outer glow border
local glowFrame = Instance.new("Frame")
glowFrame.Size = UDim2.new(1, 8, 1, 8)
glowFrame.Position = UDim2.new(0, -4, 0, -4)
glowFrame.BackgroundTransparency = 1
glowFrame.BorderSizePixel = 0
glowFrame.ZIndex = 99
glowFrame.Parent = window
mkC(glowFrame, 20)
local glowStroke = mkS(glowFrame, C.accent, 3, 0.4)

-- sharp inner border
local innerBorder = Instance.new("Frame")
innerBorder.Size = UDim2.new(1,0,1,0)
innerBorder.BackgroundTransparency = 1
innerBorder.BorderSizePixel = 0
innerBorder.ZIndex = 101
innerBorder.Parent = window
mkC(innerBorder, 16)
mkS(innerBorder, C.strokeDim, 1, 0.1)

-- animated border glow
task.spawn(function()
    while window and window.Parent do
        tweenSine(glowStroke, 2.5, {Color = C.accentHi, Transparency = 0.15})
        task.wait(2.5)
        tweenSine(glowStroke, 2.5, {Color = C.accentLo, Transparency = 0.55})
        task.wait(2.5)
    end
end)

-- ── OPEN / CLOSE ANIMATION ───────────────────────────────────
local isOpen = false

local OPEN_POS  = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 20)
local CLOSE_POS = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2 + 60)

local function openGUI()
    isOpen = true
    window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    window.Position = OPEN_POS
    window.BackgroundTransparency = 0
    winBg.BackgroundTransparency = 0
    window.Visible = true
end

local function closeGUI()
    isOpen = false
    window.Visible = false
end

toggleBtn.MouseButton1Click:Connect(function()
    if isOpen then closeGUI() else openGUI() end
end)

-- ════════════════════════════════════════════════════════════
-- TITLE BAR
-- ════════════════════════════════════════════════════════════
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
titleBar.BackgroundColor3 = C.panel
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 110
titleBar.Parent = winBg
mkC(titleBar, 16)
mkGrad(titleBar, 90,
    Color3.fromRGB(22, 14, 42),
    Color3.fromRGB(15, 10, 28))

-- fill bottom rounded corners
local tbFill = Instance.new("Frame")
tbFill.Size = UDim2.new(1, 0, 0.5, 0)
tbFill.Position = UDim2.new(0, 0, 0.5, 0)
tbFill.BackgroundColor3 = C.panel
tbFill.BorderSizePixel = 0
tbFill.ZIndex = 110
tbFill.Parent = titleBar
mkGrad(tbFill, 90,
    Color3.fromRGB(20, 13, 38),
    Color3.fromRGB(15, 10, 28))

-- accent line below title
local titleAccent = Instance.new("Frame")
titleAccent.Size = UDim2.new(1, 0, 0, 1)
titleAccent.Position = UDim2.new(0, 0, 1, -1)
titleAccent.BackgroundColor3 = C.accent
titleAccent.BorderSizePixel = 0
titleAccent.ZIndex = 111
titleAccent.Parent = titleBar
mkGrad(titleAccent, 0,
    Color3.fromRGB(55, 28, 145),
    Color3.fromRGB(180, 80, 255))

-- animated shimmer on accent line
task.spawn(function()
    while true do
        tweenSine(titleAccent, 2, {
            BackgroundColor3 = C.accentHi,
        })
        task.wait(2)
        tweenSine(titleAccent, 2, {
            BackgroundColor3 = C.accent,
        })
        task.wait(2)
    end
end)

-- Logo / title
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 36, 0, 36)
logoFrame.Position = UDim2.new(0, 8, 0.5, -18)
logoFrame.BackgroundColor3 = C.accentLo
logoFrame.BorderSizePixel = 0
logoFrame.ZIndex = 112
logoFrame.Parent = titleBar
mkC(logoFrame, 8)
mkGrad(logoFrame, 135, C.accent, C.accentLo)
mkS(logoFrame, C.accentHi, 1, 0.3)

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "K"
logoText.TextColor3 = C.white
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 18
logoText.ZIndex = 113
logoText.Parent = logoFrame

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 120, 1, 0)
titleLbl.Position = UDim2.new(0, 50, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "KZM"
titleLbl.TextColor3 = C.white
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 18
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 112
titleLbl.Parent = titleBar

local verLbl = Instance.new("TextLabel")
verLbl.Size = UDim2.new(0, 60, 1, 0)
verLbl.Position = UDim2.new(0, 106, 0, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "v3.0"
verLbl.TextColor3 = C.textMuted
verLbl.Font = Enum.Font.Gotham
verLbl.TextSize = 11
verLbl.TextXAlignment = Enum.TextXAlignment.Left
verLbl.ZIndex = 112
verLbl.Parent = titleBar

-- Status dot (shows script is running)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -80, 0.5, -4)
statusDot.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 112
statusDot.Parent = titleBar
mkC(statusDot, 4)
task.spawn(function()
    while true do
        tweenSine(statusDot, 1, {BackgroundTransparency = 0.5})
        task.wait(1)
        tweenSine(statusDot, 1, {BackgroundTransparency = 0})
        task.wait(1)
    end
end)

local statusLbl2 = Instance.new("TextLabel")
statusLbl2.Size = UDim2.new(0, 50, 1, 0)
statusLbl2.Position = UDim2.new(1, -70, 0, 0)
statusLbl2.BackgroundTransparency = 1
statusLbl2.Text = "Active"
statusLbl2.TextColor3 = C.textMuted
statusLbl2.Font = Enum.Font.Gotham
statusLbl2.TextSize = 10
statusLbl2.TextXAlignment = Enum.TextXAlignment.Left
statusLbl2.ZIndex = 112
statusLbl2.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(55, 20, 60)
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(220, 150, 220)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 113
closeBtn.Parent = titleBar
mkC(closeBtn, 14)
mkS(closeBtn, Color3.fromRGB(100, 30, 100), 1, 0.3)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.12, {BackgroundColor3 = Color3.fromRGB(180, 30, 60), TextColor3 = C.white})
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.12, {BackgroundColor3 = Color3.fromRGB(55, 20, 60), TextColor3 = Color3.fromRGB(220,150,220)})
end)
closeBtn.MouseButton1Click:Connect(function() closeGUI() end)

-- ── DRAG ─────────────────────────────────────────────────────
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = window.Position
    end
end)
titleBar.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
titleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- ════════════════════════════════════════════════════════════
-- TAB BAR (horizontal, pill style)
-- ════════════════════════════════════════════════════════════
local tabBarBg = Instance.new("Frame")
tabBarBg.Size = UDim2.new(1, -16, 0, TAB_H)
tabBarBg.Position = UDim2.new(0, 8, 0, TITLE_H + 6)
tabBarBg.BackgroundColor3 = Color3.fromRGB(12, 8, 24)
tabBarBg.BorderSizePixel = 0
tabBarBg.ZIndex = 109
tabBarBg.Parent = winBg
mkC(tabBarBg, 12)
mkS(tabBarBg, C.strokeDim, 1, 0.2)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabBarBg

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 6)
tabPad.PaddingRight = UDim.new(0, 6)
tabPad.PaddingTop = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 4)
tabPad.Parent = tabBarBg

-- ── CONTENT AREA ─────────────────────────────────────────────
local HEADER_H = TITLE_H + TAB_H + 20  -- title(48) + tabbar(38) + gap(20) = 106

local CF_H = WIN_H - HEADER_H - 8
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -16, 0, CF_H)
contentFrame.Position = UDim2.new(0, 8, 0, HEADER_H)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = false
contentFrame.ZIndex = 100
contentFrame.Parent = winBg

-- ════════════════════════════════════════════════════════════
-- UI COMPONENT BUILDERS
-- ════════════════════════════════════════════════════════════
local function makeCorner(parent, radius) mkC(parent, radius) end

local function makeStroke(parent, col, th, tr)
    return mkS(parent, col, th, tr or 0)
end

local function makeScrollList(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = C.accent
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.ScrollBarImageTransparency = 0
    sf.ZIndex = 100
    sf.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = sf

    -- Use a large initial canvas and update every frame until content loads
    sf.CanvasSize = UDim2.new(0, 0, 0, 2000)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local h = layout.AbsoluteContentSize.Y
        if h > 0 then
            sf.CanvasSize = UDim2.new(0, 0, 0, h + 20)
        end
    end)
    return sf
end

local function makeToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.ZIndex = 100
    row.Parent = parent
    mkC(row, 10)
    mkS(row, C.strokeDim, 1, 0.3)
    mkGrad(row, 90,
        Color3.fromRGB(22, 16, 40),
        Color3.fromRGB(18, 13, 33))

    -- left glow bar (active state)
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Position = UDim2.new(0, 0, 0.2, 0)
    bar.BackgroundColor3 = C.accent
    bar.BackgroundTransparency = default and 0 or 1
    bar.BorderSizePixel = 0
    bar.ZIndex = 101
    bar.Parent = row
    mkC(bar, 2)

    -- subtle glow behind bar
    local barGlow = Instance.new("Frame")
    barGlow.Size = UDim2.new(0, 20, 1, 0)
    barGlow.BackgroundColor3 = C.accent
    barGlow.BackgroundTransparency = default and 0.85 or 1
    barGlow.BorderSizePixel = 0
    barGlow.ZIndex = 100
    barGlow.Parent = row
    mkC(barGlow, 4)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.68, 0, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = default and C.text or C.textDim
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = row

    -- toggle track
    local tTrack = Instance.new("Frame")
    tTrack.Size = UDim2.new(0, 50, 0, 26)
    tTrack.Position = UDim2.new(1, -58, 0.5, -13)
    tTrack.BackgroundColor3 = default and C.toggleOn or C.toggleOff
    tTrack.BorderSizePixel = 0
    tTrack.ZIndex = 101
    tTrack.Parent = row
    mkC(tTrack, 13)

    -- track gradient when on
    local tGrad = mkGrad(tTrack, 90, C.accent, C.accentMid)
    tGrad.Transparency = NumberSequence.new(default and 0 or 1)

    -- knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 102
    knob.Parent = tTrack
    mkC(knob, 10)
    mkS(knob, Color3.fromRGB(200, 190, 230), 1, 0.5)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 103
    clickBtn.Parent = row

    local isOn = default or false
    local function setState(v)
        isOn = v
        tween(knob, 0.2, {Position = isOn and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)})
        tween(tTrack, 0.2, {BackgroundColor3 = isOn and C.toggleOn or C.toggleOff})
        tween(bar, 0.2, {BackgroundTransparency = isOn and 0 or 1})
        tween(barGlow, 0.2, {BackgroundTransparency = isOn and 0.85 or 1})
        tween(lbl, 0.15, {TextColor3 = isOn and C.text or C.textDim})
        tGrad.Transparency = NumberSequence.new(isOn and 0 or 1)
    end

    clickBtn.MouseButton1Click:Connect(function()
        isOn = not isOn; setState(isOn)
        if callback then callback(isOn) end
    end)
    clickBtn.MouseEnter:Connect(function()
        tween(row, 0.12, {BackgroundColor3 = C.rowHover})
    end)
    clickBtn.MouseLeave:Connect(function()
        tween(row, 0.12, {BackgroundColor3 = C.row})
    end)
    return row, setState, function() return isOn end
end

local function makeButton(parent, labelText, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -4, 0, 38)
    row.BackgroundColor3 = C.accentLo
    row.BorderSizePixel = 0
    row.Text = ""
    row.ZIndex = 100
    row.Parent = parent
    mkC(row, 10)
    local gs = mkS(row, C.accent, 1.5, 0.35)
    mkGrad(row, 90,
        Color3.fromRGB(90, 50, 210),
        Color3.fromRGB(50, 25, 130))

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.white
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.ZIndex = 101
    lbl.Parent = row

    row.MouseButton1Click:Connect(function()
        tween(row, 0.08, {BackgroundColor3 = C.accentHi})
        tween(gs, 0.08, {Transparency = 0})
        task.delay(0.18, function()
            tween(row, 0.15, {BackgroundColor3 = C.accentLo})
            tween(gs, 0.15, {Transparency = 0.35})
        end)
        if callback then callback() end
    end)
    row.MouseEnter:Connect(function()
        tween(row, 0.12, {BackgroundColor3 = C.accentMid})
        tween(gs, 0.12, {Transparency = 0.1})
    end)
    row.MouseLeave:Connect(function()
        tween(row, 0.12, {BackgroundColor3 = C.accentLo})
        tween(gs, 0.12, {Transparency = 0.35})
    end)
    return row
end

local function makeSlider(parent, labelText, minV, maxV, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 52)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.ZIndex = 100
    row.Parent = parent
    mkC(row, 10)
    mkS(row, C.strokeDim, 1, 0.3)
    mkGrad(row, 90,
        Color3.fromRGB(22, 16, 40),
        Color3.fromRGB(18, 13, 33))

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.62, 0, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = row

    local valBadge = Instance.new("Frame")
    valBadge.Size = UDim2.new(0, 52, 0, 22)
    valBadge.Position = UDim2.new(1, -62, 0, 5)
    valBadge.BackgroundColor3 = C.accentLo
    valBadge.BorderSizePixel = 0
    valBadge.ZIndex = 101
    valBadge.Parent = row
    mkC(valBadge, 6)
    mkS(valBadge, C.accent, 1, 0.4)

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(1, 0, 1, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = C.accentHi
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.ZIndex = 102
    valLbl.Parent = valBadge

    -- track
    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -28, 0, 6)
    trackBg.Position = UDim2.new(0, 14, 0, 38)
    trackBg.BackgroundColor3 = Color3.fromRGB(18, 12, 36)
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = 100
    trackBg.Parent = row
    mkC(trackBg, 3)
    mkS(trackBg, C.strokeDim, 1, 0.4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 101
    fill.Parent = trackBg
    mkC(fill, 3)
    mkGrad(fill, 0, C.accentMid, C.accentHi)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default-minV)/(maxV-minV), 0, 0.5, 0)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 102
    knob.Parent = trackBg
    mkC(knob, 9)
    mkS(knob, C.accent, 2, 0.2)

    local draggingSl = false
    local function upd(inp)
        local rx = math.clamp((inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV-minV)*rx)
        valLbl.Text = tostring(v)
        fill.Size = UDim2.new(rx, 0, 1, 0)
        knob.Position = UDim2.new(rx, 0, 0.5, 0)
        if callback then callback(v) end
    end

    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingSl = true; upd(i)
            tween(knob, 0.1, {Size = UDim2.new(0, 22, 0, 22)})
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if draggingSl and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            draggingSl = false
            tween(knob, 0.1, {Size = UDim2.new(0, 18, 0, 18)})
        end
    end)
    return row
end

local function makeSectionRow(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(14, 10, 28)
    f.BorderSizePixel = 0
    f.ZIndex = 100
    f.Parent = parent
    mkC(f, 8)
    mkS(f, C.strokeDim, 1, 0.4)

    -- left pip with gradient
    local pip = Instance.new("Frame")
    pip.Size = UDim2.new(0, 3, 0.65, 0)
    pip.Position = UDim2.new(0, 0, 0.175, 0)
    pip.BackgroundColor3 = C.accent
    pip.BorderSizePixel = 0
    pip.ZIndex = 101
    pip.Parent = f
    mkC(pip, 2)
    mkGrad(pip, 90, C.accentHi, C.accent)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text:upper()
    lbl.TextColor3 = C.accentHi
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LetterSpacing = 1
    lbl.ZIndex = 101
    lbl.Parent = f
    return f
end

local function makeDropdown(parent, labelText, items, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 46)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.ClipsDescendants = false
    row.ZIndex = 100
    row.Parent = parent
    mkC(row, 10)
    mkS(row, C.strokeDim, 1, 0.3)
    mkGrad(row, 90, Color3.fromRGB(22,16,40), Color3.fromRGB(18,13,33))

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.48, 0, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = row

    local selBadge = Instance.new("Frame")
    selBadge.Size = UDim2.new(0, 120, 0, 24)
    selBadge.Position = UDim2.new(1, -148, 0.5, -12)
    selBadge.BackgroundColor3 = C.accentLo
    selBadge.BorderSizePixel = 0
    selBadge.ZIndex = 101
    selBadge.Parent = row
    mkC(selBadge, 7)
    mkS(selBadge, C.accent, 1, 0.4)

    local selLbl = Instance.new("TextLabel")
    selLbl.Size = UDim2.new(1, -6, 1, 0)
    selLbl.Position = UDim2.new(0, 3, 0, 0)
    selLbl.BackgroundTransparency = 1
    selLbl.Text = default or "Select"
    selLbl.TextColor3 = C.accentHi
    selLbl.Font = Enum.Font.GothamBold
    selLbl.TextSize = 11
    selLbl.ZIndex = 102
    selLbl.Parent = selBadge

    local chevron = Instance.new("TextLabel")
    chevron.Size = UDim2.new(0, 22, 1, 0)
    chevron.Position = UDim2.new(1, -26, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text = "v"
    chevron.TextColor3 = C.textDim
    chevron.Font = Enum.Font.GothamBold
    chevron.TextSize = 11
    chevron.ZIndex = 101
    chevron.Parent = row

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, 32)
    listFrame.BackgroundColor3 = Color3.fromRGB(10, 7, 22)
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible = false
    listFrame.ZIndex = 130
    listFrame.Parent = row
    mkC(listFrame, 8)
    mkS(listFrame, C.strokeDim, 1, 0.15)

    local listScroller = Instance.new("ScrollingFrame")
    listScroller.Size = UDim2.new(1, 0, 1, 0)
    listScroller.BackgroundTransparency = 1
    listScroller.BorderSizePixel = 0
    listScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    listScroller.ScrollBarThickness = 3
    listScroller.ScrollBarImageColor3 = C.accent
    listScroller.ZIndex = 131
    listScroller.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = listScroller

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 4)
    listPad.Parent = listScroller

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 0, 32)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 101
    clickBtn.Parent = row

    local selectedItem = default
    local ddOpen = false

    local function setOpen(open)
        ddOpen = open
        listFrame.Visible = open
        chevron.Text = open and "^" or "v"
        if open then
            row.Size = UDim2.new(1,-2, 0, 46 + listFrame.Size.Y.Offset + 4)
        else
            row.Size = UDim2.new(1,-2, 0, 46)
        end
    end

    local function updateList(newItems, keepSel)
        for _, child in ipairs(listScroller:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local selExists = false
        for _, itemName in ipairs(newItems) do
            local ib = Instance.new("TextButton")
            ib.Size = UDim2.new(1, 0, 0, 28)
            ib.BackgroundColor3 = C.row
            ib.BorderSizePixel = 0
            ib.Text = itemName
            ib.TextColor3 = C.textDim
            ib.Font = Enum.Font.GothamMedium
            ib.TextSize = 12
            ib.ZIndex = 132
            ib.Parent = listScroller
            mkC(ib, 6)
            if itemName == selectedItem then selExists = true end
            ib.MouseEnter:Connect(function()
                tween(ib, 0.1, {BackgroundColor3 = C.rowHover, TextColor3 = C.white})
            end)
            ib.MouseLeave:Connect(function()
                tween(ib, 0.1, {BackgroundColor3 = C.row, TextColor3 = C.textDim})
            end)
            ib.MouseButton1Click:Connect(function()
                selectedItem = itemName; selLbl.Text = itemName
                setOpen(false)
                if callback then callback(itemName) end
            end)
        end
        if keepSel and selExists then selLbl.Text = selectedItem
        elseif keepSel and not selExists then selectedItem=newItems[1]; selLbl.Text=selectedItem or "Select" end
        task.wait()
        listScroller.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 8)
        listFrame.Size = UDim2.new(1,0,0, math.min(160, listLayout.AbsoluteContentSize.Y + 8))
        if callback and selectedItem then callback(selectedItem) end
    end

    clickBtn.MouseButton1Click:Connect(function() setOpen(not ddOpen) end)
    updateList(items, true)
    row.Size = UDim2.new(1,-2,0,46)
    return row, updateList, function() return selectedItem end
end

-- ════════════════════════════════════════════════════════════
-- TABS
-- ════════════════════════════════════════════════════════════
local tabs = {}
local tabFrames = {}
local tabNames = {"Main", "Combat", "Auto", "Teleport", "Extra", "Configs"}

local function switchTab(name)
    -- First pass: hide all, show active (instant for reliability)
    for _, tabName in ipairs(tabNames) do
        if tabFrames[tabName] then
            tabFrames[tabName].Visible = (tabName == name)
        end
    end
    -- Second pass: animate buttons
    for _, td in pairs(tabs) do
        local active = td.name == name
        td.btn.BackgroundColor3 = active and C.tabActive or Color3.fromRGB(16, 11, 30)
        td.lbl.Font = active and Enum.Font.GothamBold or Enum.Font.Gotham
        td.lbl.TextColor3 = active and C.white or C.textDim
        if td.topGlow then
            td.topGlow.BackgroundTransparency = active and 0.5 or 1
        end
    end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 96, 0, TAB_H - 8)
    btn.BackgroundColor3 = Color3.fromRGB(16, 11, 30)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 110
    btn.Parent = tabBarBg
    mkC(btn, 8)

    -- top accent glow (shows on active)
    local topGlow = Instance.new("Frame")
    topGlow.Size = UDim2.new(0.7, 0, 0, 2)
    topGlow.Position = UDim2.new(0.15, 0, 0, 0)
    topGlow.BackgroundColor3 = C.accent
    topGlow.BackgroundTransparency = 1
    topGlow.BorderSizePixel = 0
    topGlow.ZIndex = 111
    topGlow.Parent = btn
    mkC(topGlow, 1)
    mkGrad(topGlow, 0, C.accent, C.accentHi)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.textDim
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.ZIndex = 111
    lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        if tabs[name] and tabs[name].lbl.TextColor3 ~= C.white then
            tween(btn, 0.1, {BackgroundColor3 = Color3.fromRGB(22, 16, 42)})
        end
    end)
    btn.MouseLeave:Connect(function()
        if tabs[name] and tabs[name].lbl.TextColor3 ~= C.white then
            tween(btn, 0.1, {BackgroundColor3 = Color3.fromRGB(16, 11, 30)})
        end
    end)

    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, 0, 1, 0)
    tf.BackgroundTransparency = 1
    tf.Visible = false
    tf.ZIndex = 100
    tf.ClipsDescendants = false
    tf.Parent = contentFrame

    tabFrames[name] = tf
    tabs[name] = {name=name, btn=btn, lbl=lbl, topGlow=topGlow}

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

local scrolls = {}
for _, name in ipairs(tabNames) do
    scrolls[name] = makeScrollList(tabFrames[name])
end

-- ════════════════════════════════════════════════════════════
-- LOCK-ON BUTTON — floating, premium design
-- ════════════════════════════════════════════════════════════
local LOBtn = Instance.new("Frame")
LOBtn.Name = "LockOnBtn"
LOBtn.Size = UDim2.new(0, 96, 0, 96)
LOBtn.Position = UDim2.new(0.5, -48, 0.45, 0)
LOBtn.BackgroundColor3 = Color3.fromRGB(8, 5, 18)
LOBtn.BorderSizePixel = 0
LOBtn.Visible = false
LOBtn.ZIndex = 201
LOBtn.Active = true
LOBtn.Parent = screenGui
mkC(LOBtn, 48)
mkS(LOBtn, C.strokeDim, 1.5, 0.2)

-- outer pulse ring 1
local ring1 = Instance.new("Frame")
ring1.Size = UDim2.new(1, 16, 1, 16)
ring1.Position = UDim2.new(0, -8, 0, -8)
ring1.BackgroundTransparency = 1
ring1.BorderSizePixel = 0
ring1.ZIndex = 200
ring1.Parent = LOBtn
mkC(ring1, 56)
local ring1Stroke = mkS(ring1, C.accent, 2, 0.5)

-- outer pulse ring 2
local ring2 = Instance.new("Frame")
ring2.Size = UDim2.new(1, 30, 1, 30)
ring2.Position = UDim2.new(0, -15, 0, -15)
ring2.BackgroundTransparency = 1
ring2.BorderSizePixel = 0
ring2.ZIndex = 199
ring2.Parent = LOBtn
mkC(ring2, 63)
local ring2Stroke = mkS(ring2, C.accent, 1.5, 0.75)

-- inner glow fill
local innerGlow = Instance.new("Frame")
innerGlow.Size = UDim2.new(0.85, 0, 0.85, 0)
innerGlow.Position = UDim2.new(0.075, 0, 0.075, 0)
innerGlow.BackgroundColor3 = C.accent
innerGlow.BackgroundTransparency = 0.88
innerGlow.BorderSizePixel = 0
innerGlow.ZIndex = 202
innerGlow.Parent = LOBtn
mkC(innerGlow, 42)

-- crosshair lines
local function makeCrossLine(size, pos)
    local l = Instance.new("Frame")
    l.Size = size
    l.Position = pos
    l.BackgroundColor3 = Color3.fromRGB(190, 160, 255)
    l.BorderSizePixel = 0
    l.ZIndex = 204
    l.Parent = LOBtn
    mkC(l, 1)
    return l
end
-- 4 corner brackets instead of full lines (looks better)
-- Top-left
makeCrossLine(UDim2.new(0,16,0,2), UDim2.new(0.5,-30, 0.5,-18))
makeCrossLine(UDim2.new(0,2,0,16), UDim2.new(0.5,-30, 0.5,-18))
-- Top-right
makeCrossLine(UDim2.new(0,16,0,2), UDim2.new(0.5, 14, 0.5,-18))
makeCrossLine(UDim2.new(0,2,0,16), UDim2.new(0.5, 26, 0.5,-18))
-- Bottom-left
makeCrossLine(UDim2.new(0,16,0,2), UDim2.new(0.5,-30, 0.5, 16))
makeCrossLine(UDim2.new(0,2,0,16), UDim2.new(0.5,-30, 0.5,  2))
-- Bottom-right
makeCrossLine(UDim2.new(0,16,0,2), UDim2.new(0.5, 14, 0.5, 16))
makeCrossLine(UDim2.new(0,2,0,16), UDim2.new(0.5, 26, 0.5,  2))

-- small crosshair dot center
local crossH = Instance.new("Frame")
crossH.Size = UDim2.new(0, 20, 0, 2)
crossH.Position = UDim2.new(0.5, -10, 0.5, -1)
crossH.BackgroundColor3 = Color3.fromRGB(190, 160, 255)
crossH.BackgroundTransparency = 0.4
crossH.BorderSizePixel = 0
crossH.ZIndex = 203
crossH.Parent = LOBtn
mkC(crossH, 1)

local crossV = Instance.new("Frame")
crossV.Size = UDim2.new(0, 2, 0, 20)
crossV.Position = UDim2.new(0.5, -1, 0.5, -10)
crossV.BackgroundColor3 = Color3.fromRGB(190, 160, 255)
crossV.BackgroundTransparency = 0.4
crossV.BorderSizePixel = 0
crossV.ZIndex = 203
crossV.Parent = LOBtn
mkC(crossV, 1)

local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 10, 0, 10)
centerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
centerDot.BackgroundColor3 = C.accent
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 205
centerDot.Parent = LOBtn
mkC(centerDot, 5)

-- label below
local lockLabel = Instance.new("TextLabel")
lockLabel.Size = UDim2.new(0, 96, 0, 20)
lockLabel.Position = UDim2.new(0, 0, 1, 8)
lockLabel.BackgroundTransparency = 1
lockLabel.Text = "LOCK"
lockLabel.TextColor3 = Color3.fromRGB(150, 120, 255)
lockLabel.Font = Enum.Font.GothamBold
lockLabel.TextSize = 12
lockLabel.ZIndex = 201
lockLabel.Parent = LOBtn

-- Status pill
local lockStatus = Instance.new("Frame")
lockStatus.Size = UDim2.new(0, 60, 0, 16)
lockStatus.Position = UDim2.new(0.5, -30, 1, 30)
lockStatus.BackgroundColor3 = C.accentLo
lockStatus.BorderSizePixel = 0
lockStatus.ZIndex = 201
lockStatus.Parent = LOBtn
mkC(lockStatus, 8)
local lockStatusLbl = Instance.new("TextLabel")
lockStatusLbl.Size = UDim2.new(1, 0, 1, 0)
lockStatusLbl.BackgroundTransparency = 1
lockStatusLbl.Text = "IDLE"
lockStatusLbl.TextColor3 = C.textDim
lockStatusLbl.Font = Enum.Font.GothamBold
lockStatusLbl.TextSize = 9
lockStatusLbl.ZIndex = 202
lockStatusLbl.Parent = lockStatus

-- Drag
local loDrag, loDS, loSP
LOBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        loDrag = true; loDS = i.Position; loSP = LOBtn.Position
    end
end)
LOBtn.InputChanged:Connect(function(i)
    if loDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - loDS
        LOBtn.Position = UDim2.new(loSP.X.Scale, loSP.X.Offset+d.X, loSP.Y.Scale, loSP.Y.Offset+d.Y)
    end
end)
LOBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then loDrag = false end
end)

-- idle pulse animation
task.spawn(function()
    while LOBtn and LOBtn.Parent do
        if LOBtn.Visible then
            tweenSine(ring1Stroke, 1.2, {Transparency = 0.75})
            tweenSine(ring2Stroke, 1.2, {Transparency = 0.9})
            task.wait(1.2)
            tweenSine(ring1Stroke, 1.2, {Transparency = 0.4})
            tweenSine(ring2Stroke, 1.2, {Transparency = 0.65})
            task.wait(1.2)
        else task.wait(0.5) end
    end
end)

-- Make LOBtn act as a button (click on TextButton overlay)
local lockOnBtn = Instance.new("TextButton")
lockOnBtn.Size = UDim2.new(1, 0, 1, 0)
lockOnBtn.BackgroundTransparency = 1
lockOnBtn.Text = ""
lockOnBtn.ZIndex = 206
lockOnBtn.Parent = LOBtn

local lockRingStroke = ring1Stroke  -- alias for feature code compatibility

switchTab("Main")
openGUI()
-- force layout refresh
task.wait(0.1)
switchTab("Main")
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
-- MAIN TAB
-- ==========================================
local mainS = scrolls["Main"]

makeSectionRow(mainS, "Movement")

makeToggle(mainS, "No Parkour Cooldown", false, function(state)
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

-- FLY FEATURE (Mobile + PC)
local FLY_SPEED    = 50
local flyActive    = false
local flyConn      = nil
local flyAnimTrack = nil
local FLY_ANIM_ID  = "rbxassetid://616006778"

local function startFly()
    if flyActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    flyActive = true
    hum.AutoRotate = false
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
    bv.Name = "FlyBV"; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.zero; bv.Parent = hrp
    flyConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character; if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not root or not h then return end
        local fbv = root:FindFirstChild("FlyBV"); if not fbv then return end
        local cam = workspace.CurrentCamera
        local camYaw = CFrame.Angles(0, math.atan2(-cam.CFrame.LookVector.X,-cam.CFrame.LookVector.Z), 0)
        local md = h.MoveDirection
        local moveDir = Vector3.zero
        if md.Magnitude > 0.1 then
            moveDir = camYaw * Vector3.new(md.X,0,md.Z)
            moveDir = Vector3.new(moveDir.X,0,moveDir.Z)
        end
        local vertDir = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then vertDir=1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.E) then vertDir=-1 end
        if h:GetState()==Enum.HumanoidStateType.Jumping then vertDir=1 end
        local finalDir = moveDir + Vector3.new(0,vertDir,0)
        if finalDir.Magnitude > 0 then
            fbv.Velocity = finalDir.Unit * FLY_SPEED
            if moveDir.Magnitude > 0.1 then root.CFrame = CFrame.new(root.Position, root.Position+moveDir) end
        else fbv.Velocity = Vector3.zero end
    end)
end

local function stopFly()
    if not flyActive then return end
    flyActive = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyAnimTrack then pcall(function() flyAnimTrack:Stop() end); flyAnimTrack = nil end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then local fbv=hrp:FindFirstChild("FlyBV"); if fbv then fbv:Destroy() end end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

LocalPlayer.CharacterAdded:Connect(function() flyActive=false; flyConn=nil; flyAnimTrack=nil end)

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

-- lockOnBtn, LOBtn, lockRingStroke, centerDot, lockLabel etc defined in GUI

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
    -- restore idle purple theme
    tween(lockRingStroke, 0.25, {Color = C.accent, Transparency = 0.5})
    tween(centerDot, 0.25, {BackgroundColor3 = C.accent})
    tween(LOBtn, 0.25, {BackgroundColor3 = Color3.fromRGB(8,5,18)})
    tween(innerGlow, 0.25, {BackgroundColor3 = C.accent, BackgroundTransparency = 0.88})
    lockLabel.Text = "LOCK"; lockLabel.TextColor3 = Color3.fromRGB(150,120,255)
    lockStatusLbl.Text = "IDLE"; lockStatus.BackgroundColor3 = C.accentLo
end

local function doLockOn()
    local targetInfo = getNearestTarget()
    if not targetInfo then return end
    lockedTarget = targetInfo.character
    lockOnActive = true
    -- locked red theme
    tween(lockRingStroke, 0.25, {Color = C.red, Transparency = 0.1})
    tween(centerDot, 0.25, {BackgroundColor3 = C.red})
    tween(LOBtn, 0.25, {BackgroundColor3 = Color3.fromRGB(18,4,8)})
    tween(innerGlow, 0.25, {BackgroundColor3 = C.red, BackgroundTransparency = 0.80})
    lockLabel.Text = "LOCKED"; lockLabel.TextColor3 = Color3.fromRGB(255,100,120)
    lockStatusLbl.Text = "ON"; lockStatus.BackgroundColor3 = C.redLo
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
    LOBtn.Visible = state
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
        bfConn = RS.Knit.Knit.Services.DivergentFistService.RE.Effects.OnClientEvent:Connect(function(...)
            local args = {...}
            local eventType = args[#args - 1]
            local eventChar = args[#args]
            if eventType == "CurseBuild" and eventChar == LocalPlayer.Character then
                task.wait(0.07)
                pcall(function()
                    RS.Knit.Knit.Services.DivergentFistService.RE.Activated:FireServer(
                        LocalPlayer.Character.Moveset:FindFirstChild("Divergent Fist")
                    )
                end)
            end
        end)
    else
        if bfConn then bfConn:Disconnect(); bfConn = nil end
    end
end)

makeSectionRow(combatS, "Dash Assist")

local dashConn = nil
makeToggle(combatS, "Side Dash Assist", false, function(state)
    _G.DashAssist = state
    if state and not dashConn then
        dashConn = RunService.Heartbeat:Connect(function()
            if not _G.DashAssist then return end
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end
                local target, minDist = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if tHRP and tHum and tHum.Health > 0 then
                            local dist = (tHRP.Position - hrp.Position).Magnitude
                            if dist < minDist then minDist = dist; target = tHRP end
                        end
                    end
                end
                if not target then return end
                local animator = hum:FindFirstChildOfClass("Animator")
                if not animator then return end
                local dashDir = nil
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Animation then
                        local id = track.Animation.AnimationId
                        if id:find("Dash") or track.Name:lower():find("dash") then
                            if track.Name:lower():find("right") then dashDir = "Right"
                            elseif track.Name:lower():find("left") then dashDir = "Left" end
                        end
                    end
                end
                if dashDir and minDist <= 20 then
                    local angle = dashDir == "Right" and 75 or -75
                    local targetDir = CFrame.lookAt(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
                    hrp.CFrame = hrp.CFrame:Lerp(targetDir * CFrame.Angles(0, math.rad(angle), 0), 0.2)
                end
            end)
        end)
    elseif not state and dashConn then
        dashConn:Disconnect(); dashConn = nil
    end
end)

-- ==========================================
-- TELEPORT TAB (FASTER TP)
-- ==========================================
local teleportS = scrolls["Teleport"]

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
makeToggle(teleportS, "TP Bypass", false, function(state)
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
local tpSelDropdown, updateTpSelList, getTpSelPlayer = makeDropdown(teleportS, "TP Selected Target", playerNames, playerNames[1], function(value)
    selectedPlayer = Players:FindFirstChild(value)
end)

makeToggle(teleportS, "TP Selected", false, function(state)
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

makeToggle(teleportS, "TP All Loop", false, function(state)
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
    local statusRow = teleportS:FindFirstChild("StatusRow")
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
statusRowTp.Parent = teleportS
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

-- ==========================================
-- AUTO TAB
-- ==========================================
local autoS = scrolls["Auto"]

makeSectionRow(autoS, "M1 Assist")

-- M1Method: "UpperCut" uses hookmetamethod to send "Up" on every Activated FireServer
--           "DownSlam" uses the original BodyVelocity side-push approach
local M1Method = "UpperCut"
local autoM1Active = false
local autoM1Hook   = nil   -- hookmetamethod handle for UpperCut
local autoM1Connections = {}
local comboCount = 0
local lastHitTime = 0

-- ── Both UpperCut and DownSlam use hookmetamethod.
-- UpperCut replaces false with "Up", DownSlam replaces false with "Down".
-- One shared hook; M1Method decides the arg at call time.
local autoM1RenderStep = nil  -- kept for safety, unused

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

    -- Track combo resets (shared for both modes)
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
    autoM1Active = false   -- gates the hook replacement off
    if autoM1RenderStep then
        RunService:UnbindFromRenderStep("M1-Farm")
        autoM1RenderStep = nil
    end
    for _, conn in ipairs(autoM1Connections) do
        pcall(conn.Disconnect, conn)
    end
    table.clear(autoM1Connections)
    comboCount = 0
end

local m1MethodItems = {"UpperCut", "DownSlam"}
local m1Dropdown, updateM1Dropdown, getM1Method = makeDropdown(autoS, "M1 Method", m1MethodItems, "UpperCut", function(value)
    M1Method = value
    -- If assist is running, restart with new method
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

print("KZM v3.0 loaded")
