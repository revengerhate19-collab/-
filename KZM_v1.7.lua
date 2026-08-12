-- ==========================================
-- ｢KZM」 v1.3 (Wide + Short + Scrollable + Fixed Item Grabber)
-- with Prediction Lock-On (Players + NPCs)
-- + Correct M1 Assist (Uppercut / Downslam) + Auto Burst
-- + Emote Unlocker (replaces Extra Emote Slots toggle)
-- + Integrated Teleport Tools (Bypass, Selected, All Loop)
-- + Walk into Domains (Extra)
-- + Auto Ratio (Nanami) – FIXED
-- + Perfect Swap (Todo)
-- + Auto Garuda Rebound
-- + GUI always on top (above game UI) + Lock button mid-screen
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local C = {
    bg        = Color3.fromRGB(10, 5, 15),
    panel     = Color3.fromRGB(18, 8, 25),
    row       = Color3.fromRGB(25, 10, 35),
    rowHover  = Color3.fromRGB(35, 15, 50),
    accent    = Color3.fromRGB(180, 20, 60),
    accent2   = Color3.fromRGB(120, 20, 160),
    stroke    = Color3.fromRGB(140, 20, 80),
    tabActive = Color3.fromRGB(160, 20, 60),
    tabIdle   = Color3.fromRGB(35, 10, 50),
    text      = Color3.fromRGB(255, 220, 230),
    textDim   = Color3.fromRGB(160, 120, 140),
    section   = Color3.fromRGB(100, 20, 60),
    toggleOn  = Color3.fromRGB(180, 20, 60),
    toggleOff = Color3.fromRGB(45, 15, 55),
    white     = Color3.fromRGB(255, 255, 255),
}

-- ==========================================
-- SCREEN GUI — HIGHEST DISPLAYORDER TO OVERLAY GAME UI
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KZM"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 100          -- on top of everything
screenGui.Parent = LocalPlayer.PlayerGui

-- ==========================================
-- TOGGLE BUTTON (always visible, on top)
-- ==========================================
local toggleWindowBtn = Instance.new("TextButton")
toggleWindowBtn.Size = UDim2.new(0, 72, 0, 24)
toggleWindowBtn.Position = UDim2.new(0, 10, 0, 10)
toggleWindowBtn.BackgroundColor3 = Color3.fromRGB(100, 10, 50)
toggleWindowBtn.Text = "Toggle"
toggleWindowBtn.TextColor3 = C.white
toggleWindowBtn.Font = Enum.Font.GothamBold
toggleWindowBtn.TextSize = 11
toggleWindowBtn.BorderSizePixel = 0
toggleWindowBtn.ZIndex = 100
toggleWindowBtn.Parent = screenGui
local twCorner = Instance.new("UICorner")
twCorner.CornerRadius = UDim.new(0, 6)
twCorner.Parent = toggleWindowBtn
local twStroke = Instance.new("UIStroke")
twStroke.Color = C.stroke
twStroke.Thickness = 1.5
twStroke.Parent = toggleWindowBtn

-- ==========================================
-- MAIN WINDOW — slightly bigger (540 x 340) with ZIndex 100
-- ==========================================
local WIN_W = 540
local WIN_H = 340

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
window.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
window.BackgroundColor3 = C.bg
window.BorderSizePixel = 0
window.Active = true
window.Visible = true
window.ZIndex = 100
window.Parent = screenGui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 10)

local winStroke = Instance.new("UIStroke")
winStroke.Color = C.stroke
winStroke.Thickness = 2
winStroke.Parent = window

local winGrad = Instance.new("UIGradient")
winGrad.Rotation = 135
winGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 5, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 3, 20)),
})
winGrad.Parent = window
TweenService:Create(winGrad, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Rotation = 315}):Play()

toggleWindowBtn.MouseButton1Click:Connect(function()
    window.Visible = not window.Visible
end)

-- ==========================================
-- TITLE BAR (height 34)
-- ==========================================
local TITLE_H = 34

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
titleBar.BackgroundColor3 = C.panel
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 101
titleBar.Parent = window
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleFill = Instance.new("Frame")
titleFill.Size = UDim2.new(1, 0, 0, 10)
titleFill.Position = UDim2.new(0, 0, 1, -10)
titleFill.BackgroundColor3 = C.panel
titleFill.BorderSizePixel = 0
titleFill.Parent = titleBar

local titleGrad = Instance.new("UIGradient")
titleGrad.Rotation = 90
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 20, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 10, 120)),
})
titleGrad.Parent = titleBar

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, -80, 1, 0)
hubTitle.Position = UDim2.new(0, 12, 0, 0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "｢KZM」"
hubTitle.TextColor3 = C.white
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 14
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.Parent = titleBar

local hubVer = Instance.new("TextLabel")
hubVer.Size = UDim2.new(0, 50, 1, 0)
hubVer.Position = UDim2.new(0, 120, 0, 0)
hubVer.BackgroundTransparency = 1
hubVer.Text = "v1.5"
hubVer.TextColor3 = C.textDim
hubVer.Font = Enum.Font.Gotham
hubVer.TextSize = 10
hubVer.TextXAlignment = Enum.TextXAlignment.Left
hubVer.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -28, 0.5, -11)
minBtn.BackgroundColor3 = Color3.fromRGB(100, 10, 120)
minBtn.Text = "–"
minBtn.TextColor3 = C.white
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 102
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

-- Drag
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
    end
end)
titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(window, TweenInfo.new(0.2), {
        Size = minimized and UDim2.new(0, WIN_W, 0, TITLE_H + TAB_H) or UDim2.new(0, WIN_W, 0, WIN_H)
    }):Play()
end)

-- ==========================================
-- TAB BAR (height 28, sits below title)
-- TAB WIDTH REDUCED TO 70 TO FIT ALL 6 TABS
-- ==========================================
local TAB_H = 28

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, TAB_H)
tabBar.Position = UDim2.new(0, 0, 0, TITLE_H)
tabBar.BackgroundColor3 = Color3.fromRGB(14, 5, 20)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 101
tabBar.Parent = window

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 5)
tabPad.PaddingTop = UDim.new(0, 3)
tabPad.PaddingBottom = UDim.new(0, 3)
tabPad.Parent = tabBar

-- ==========================================
-- CONTENT AREA (fills the rest, clips properly)
-- ==========================================
local HEADER_H = TITLE_H + TAB_H  -- 62

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -HEADER_H)
contentFrame.Position = UDim2.new(0, 0, 0, HEADER_H)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.ZIndex = 100
contentFrame.Parent = window

-- ==========================================
-- UI HELPERS
-- ==========================================
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 7)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.stroke
    s.Thickness = thickness or 1.2
    s.Transparency = transparency or 0.3
    s.Parent = parent
    return s
end

local function makeScrollList(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.Position = UDim2.new(0, 0, 0, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = C.accent
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.ZIndex = 100
    sf.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = sf

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = sf

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)

    return sf
end

local function makeToggle(parent, labelText, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 28)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.ZIndex = 100
    row.Parent = parent
    makeCorner(row, 6)
    makeStroke(row, C.stroke, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.72, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = row

    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 36, 0, 18)
    toggleBG.Position = UDim2.new(1, -42, 0.5, -9)
    toggleBG.BackgroundColor3 = default and C.toggleOn or C.toggleOff
    toggleBG.BorderSizePixel = 0
    toggleBG.ZIndex = 101
    toggleBG.Parent = row
    makeCorner(toggleBG, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 102
    knob.Parent = toggleBG
    makeCorner(knob, 6)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 101
    btn.Parent = row

    local isOn = default or false
    local function setState(state)
        isOn = state
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = isOn and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        }):Play()
        TweenService:Create(toggleBG, TweenInfo.new(0.15), {
            BackgroundColor3 = isOn and C.toggleOn or C.toggleOff
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        setState(isOn)
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
    row.Size = UDim2.new(1, -4, 0, 28)
    row.BackgroundColor3 = C.accent2
    row.BorderSizePixel = 0
    row.Text = labelText
    row.TextColor3 = C.white
    row.Font = Enum.Font.GothamBold
    row.TextSize = 11
    row.ZIndex = 100
    row.Parent = parent
    makeCorner(row, 6)
    makeStroke(row, C.stroke, 1, 0.4)

    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 20, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 10, 120)),
    })
    grad.Parent = row

    row.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C.accent}):Play()
        task.delay(0.15, function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C.accent2}):Play()
        end)
        if callback then callback() end
    end)
    return row
end

local function makeSlider(parent, labelText, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 42)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.ZIndex = 100
    row.Parent = parent
    makeCorner(row, 6)
    makeStroke(row, C.stroke, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.28, 0, 0, 16)
    valLbl.Position = UDim2.new(0.72, -6, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = C.accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 101
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 5)
    track.Position = UDim2.new(0, 8, 0, 27)
    track.BackgroundColor3 = C.toggleOff
    track.BorderSizePixel = 0
    track.ZIndex = 100
    track.Parent = row
    makeCorner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 101
    fill.Parent = track
    makeCorner(fill, 3)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Rotation = 90
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 30, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 20, 160)),
    })
    fillGrad.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.ZIndex = 102
    knob.Parent = track
    makeCorner(knob, 6)

    local value = default
    local draggingSlider = false

    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relX)
        valLbl.Text = tostring(value)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, 0, 0.5, 0)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    return row
end

local function makeSectionRow(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 20)
    f.BackgroundColor3 = Color3.fromRGB(30, 8, 45)
    f.BorderSizePixel = 0
    f.ZIndex = 100
    f.Parent = parent
    makeCorner(f, 5)

    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 15, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 8, 90)),
    })
    grad.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "— " .. text .. " —"
    lbl.TextColor3 = Color3.fromRGB(255, 160, 180)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.ZIndex = 101
    lbl.Parent = f

    return f
end

-- ==========================================
-- IMPROVED DROPDOWN (scrollable, expands)
-- ==========================================
local function makeDropdown(parent, labelText, items, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 40)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.ClipsDescendants = false
    row.ZIndex = 100
    row.Parent = parent
    makeCorner(row, 6)
    makeStroke(row, C.stroke, 1, 0.6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101
    lbl.Parent = row

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(0.45, 0, 0, 16)
    selectedLbl.Position = UDim2.new(0.5, 0, 0, 2)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = default or "Select"
    selectedLbl.TextColor3 = C.accent
    selectedLbl.Font = Enum.Font.GothamBold
    selectedLbl.TextSize = 10
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Right
    selectedLbl.ZIndex = 101
    selectedLbl.Parent = row

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, -4, 0, 0)
    listFrame.Position = UDim2.new(0, 2, 0, 22)
    listFrame.BackgroundColor3 = C.panel
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.Visible = false
    listFrame.ZIndex = 102
    listFrame.Parent = row
    makeCorner(listFrame, 5)

    local listScroller = Instance.new("ScrollingFrame")
    listScroller.Size = UDim2.new(1, 0, 1, 0)
    listScroller.BackgroundTransparency = 1
    listScroller.BorderSizePixel = 0
    listScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    listScroller.ScrollBarThickness = 3
    listScroller.ScrollBarImageColor3 = C.accent
    listScroller.ZIndex = 102
    listScroller.Parent = listFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = listScroller

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 101
    btn.Parent = row

    local selectedItem = default
    local isOpen = false

    local function setOpen(open)
        isOpen = open
        listFrame.Visible = open
        if open then
            local listHeight = listFrame.Size.Y.Offset
            row.Size = UDim2.new(1, -4, 0, 40 + listHeight + 4)
        else
            row.Size = UDim2.new(1, -4, 0, 40)
        end
    end

    local function updateList(newItems, keepSelection)
        for _, child in ipairs(listScroller:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local selectedExists = false
        for _, itemName in ipairs(newItems) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, -4, 0, 19)
            itemBtn.BackgroundColor3 = C.row
            itemBtn.BorderSizePixel = 0
            itemBtn.Text = itemName
            itemBtn.TextColor3 = C.text
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextSize = 10
            itemBtn.ZIndex = 103
            itemBtn.Parent = listScroller
            makeCorner(itemBtn, 4)
            if itemName == selectedItem then selectedExists = true end
            itemBtn.MouseButton1Click:Connect(function()
                selectedItem = itemName
                selectedLbl.Text = itemName
                setOpen(false)
                if callback then callback(itemName) end
            end)
        end
        if keepSelection and selectedExists then
            selectedLbl.Text = selectedItem
        elseif keepSelection and not selectedExists then
            selectedItem = newItems[1]
            selectedLbl.Text = selectedItem or "Select"
        end
        task.wait()
        listScroller.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
        local contentHeight = listLayout.AbsoluteContentSize.Y + 4
        listFrame.Size = UDim2.new(1, -4, 0, math.min(140, contentHeight))
        if callback and selectedItem then callback(selectedItem) end
    end

    btn.MouseButton1Click:Connect(function()
        setOpen(not isOpen)
    end)

    updateList(items, true)
    row.Size = UDim2.new(1, -4, 0, 40)

    return row, updateList, function() return selectedItem end
end

-- ==========================================
-- TABS (6 tabs, width 70 each to fit)
-- ==========================================
local tabs = {}
local tabFrames = {}
local tabNames = {"Main", "Combat", "Auto", "Teleport", "Extra", "Configs"}

local function switchTab(name)
    for _, tData in pairs(tabs) do
        local isActive = tData.name == name
        TweenService:Create(tData.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = isActive and C.tabActive or C.tabIdle
        }):Play()
        tData.btn.TextColor3 = isActive and C.white or C.textDim
        if tabFrames[tData.name] then
            tabFrames[tData.name].Visible = isActive
        end
    end
end

for _, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 21)  -- reduced width to fit all
    btn.BackgroundColor3 = C.tabIdle
    btn.Text = name
    btn.TextColor3 = C.textDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.ZIndex = 101
    btn.Parent = tabBar
    makeCorner(btn, 5)

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.ZIndex = 100
    tabFrame.Parent = contentFrame

    tabFrames[name] = tabFrame
    tabs[name] = {name = name, btn = btn, frame = tabFrame}

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

local scrolls = {}
for _, name in ipairs(tabNames) do
    scrolls[name] = makeScrollList(tabFrames[name])
end

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

-- ==========================================
-- FLY FEATURE
-- ==========================================
local FLY_SPEED   = 50
local flyActive   = false
local flyConn     = nil
local flyAnimTrack = nil

-- Animation IDs for flying pose (standard Roblox float anims)
local FLY_ANIM_ID = "rbxassetid://616006778"   -- hover/float animation

local function startFly()
    if flyActive then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    flyActive = true

    -- Disable humanoid state so the game stops fighting us with gravity
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Landed,   false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,  false)
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    -- Play fly/hover animation through Animator (correct modern API)
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

    -- BodyVelocity keeps us airborne and moving
    local bv = Instance.new("BodyVelocity")
    bv.Name      = "FlyBV"
    bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity  = Vector3.zero
    bv.Parent    = hrp

    -- BodyGyro keeps character upright / facing direction
    local bg = Instance.new("BodyGyro")
    bg.Name      = "FlyBG"
    bg.MaxTorque = Vector3.new(0, 1e5, 0)  -- yaw only, no pitch roll
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
            -- Hover: kill velocity so gravity can't pull us down
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
            -- Re-enable all states we disabled
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Landed,   true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,  true)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- Clean up fly on respawn
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

-- Lock button (floating) – mid-screen with ZIndex 101
local lockOnBtn = Instance.new("ImageButton")
lockOnBtn.Name = "LockOnBtn"
lockOnBtn.Size = UDim2.new(0, 70, 0, 70)
lockOnBtn.Position = UDim2.new(0.5, -35, 0.45, 0)
lockOnBtn.BackgroundTransparency = 1
lockOnBtn.Image = "rbxassetid://11738355467"
lockOnBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
lockOnBtn.ImageTransparency = 0.1
lockOnBtn.Visible = false
lockOnBtn.ZIndex = 101
lockOnBtn.Parent = screenGui

local loDragging, loDragStart, loStartPos
lockOnBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        loDragging = true
        loDragStart = input.Position
        loStartPos = lockOnBtn.Position
    end
end)
lockOnBtn.InputChanged:Connect(function(input)
    if loDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - loDragStart
        lockOnBtn.Position = UDim2.new(
            loStartPos.X.Scale, loStartPos.X.Offset + delta.X,
            loStartPos.Y.Scale, loStartPos.Y.Offset + delta.Y
        )
    end
end)
lockOnBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        loDragging = false
    end
end)

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
    TweenService:Create(lockOnBtn, TweenInfo.new(0.15), {
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end

local function doLockOn()
    local targetInfo = getNearestTarget()
    if not targetInfo then return end
    lockedTarget = targetInfo.character
    lockOnActive = true
    TweenService:Create(lockOnBtn, TweenInfo.new(0.15), {
        ImageColor3 = Color3.fromRGB(255, 60, 60)
    }):Play()
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
    lockOnBtn.Visible = state
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
makeToggle(combatS, "Yuji 100% Blackflash", false, function(state)
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

makeToggle(autoS, "M1 Assist", false, function(state)
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

makeToggle(autoS, "Auto Burst", false, function(state)
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

makeToggle(autoS, "Perfect Swap", false, function(state)
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

-- ==========================================
-- START ON MAIN TAB
-- ==========================================
switchTab("Main")

print("✅ ｢KZM」 v1.7 – Fly rewritten, hookmetamethod M1")
