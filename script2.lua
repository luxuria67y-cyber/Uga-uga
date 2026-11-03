-- ============================================================
--  VOID.LAZY v5.0 | Slayers 2 | ULTIMATE REHEDGED EDITION
--  Delta Executor Optimized | Fully Packed Mobile Script
--  Senha Oculta e Blindada
-- ============================================================

task.wait(0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TeleportService")
local WS = workspace

local LP = Players.LocalPlayer
if not LP then return end

-- Limpeza profunda de instâncias anteriores
pcall(function()
    if LP.PlayerGui:FindFirstChild("VOID_LAZY") then LP.PlayerGui.VOID_LAZY:Destroy() end
    if game:GetService("CoreGui"):FindFirstChild("VOID_LAZY") then game:GetService("CoreGui").VOID_LAZY:Destroy() end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "VOID_LAZY"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 99999
SG.IgnoreGuiInset = true

pcall(function() SG.Parent = LP:WaitForChild("PlayerGui") end)
if not SG.Parent then pcall(function() SG.Parent = game:GetService("CoreGui") end) end

local T = {
    BG       = Color3.fromRGB(8, 7, 18),
    Panel    = Color3.fromRGB(15, 12, 32),
    PanelDk  = Color3.fromRGB(10, 8, 22),
    Acc      = Color3.fromRGB(115, 0, 220),
    AccBrt   = Color3.fromRGB(180, 60, 255),
    AccDim   = Color3.fromRGB(55, 0, 115),
    Txt      = Color3.fromRGB(240, 235, 255),
    TxtDim   = Color3.fromRGB(145, 135, 180),
    On       = Color3.fromRGB(90, 0, 200),
    Off      = Color3.fromRGB(30, 22, 52),
    Btn      = Color3.fromRGB(80, 0, 185),
    BtnHot   = Color3.fromRGB(125, 20, 240),
    Border   = Color3.fromRGB(80, 0, 165),
    Danger   = Color3.fromRGB(220, 40, 40),
    Success  = Color3.fromRGB(40, 210, 90),
    Warn     = Color3.fromRGB(220, 180, 0),
}

local ST = {
    AutoFarm     = false,
    AutoBoss     = false,
    AutoMastery  = false,
    AutoQuest    = false,
    AutoFishing  = false,
    AutoClanSpin = false,
    AutoSkills   = true,
    FreezeTarget = true,
    AntiIdle     = true,
    ESP_Mob      = false,
    ESP_Boss     = false,
    ESP_Player   = false,
    Fly          = false,
    Speed        = false,
    NoClip       = false,
    InfiniteJump = false,
    AntiDetect   = true,
    
    MobStack     = true,
    HeightMode   = "Por Cima (Seguro)",
    HitboxExp    = true,
    EquipWeapon  = true,

    TargetMob    = "Greater Demon",
    TargetBoss   = "Zuko",
    MaxLevel     = 400,
    SpeedVal     = 60,
    FlySpeedVal  = 90,
    HeightOffset = 12,

    Connections  = {},
    ESPCache     = {},
}

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function tw(obj, props, dur)
    if not obj or not obj.Parent then return end
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end

-- ============================================================
-- TELA DE LOGIN COM SENHA OCULTA (SEM EXIBIR NA PLACEHOLDER)
-- ============================================================
local Intro = Instance.new("Frame", SG)
Intro.Size = UDim2.new(1, 0, 1, 0)
Intro.BackgroundColor3 = Color3.fromRGB(4, 3, 10)
Intro.BorderSizePixel = 0

local PF = Instance.new("Frame", Intro)
PF.Size = UDim2.new(0, 310, 0, 210)
PF.Position = UDim2.new(0.5, -155, 0.5, -105)
PF.BackgroundColor3 = T.PanelDk
PF.BorderSizePixel = 0
Instance.new("UICorner", PF).CornerRadius = UDim.new(0, 14)
local PFStroke = Instance.new("UIStroke", PF)
PFStroke.Color = T.Acc; PFStroke.Thickness = 1.5

local PFTit = Instance.new("TextLabel", PF)
PFTit.Size = UDim2.new(1, 0, 0, 40)
PFTit.Position = UDim2.new(0, 0, 0, 15)
PFTit.BackgroundTransparency = 1
PFTit.TextColor3 = T.Txt
PFTit.Font = Enum.Font.GothamBold
PFTit.TextSize = 15
PFTit.Text = "🔐 VOID.LAZY // SLAYERS 2"

local SubKey = Instance.new("TextLabel", PF)
SubKey.Size = UDim2.new(1, 0, 0, 20)
SubKey.Position = UDim2.new(0, 0, 0, 50)
SubKey.BackgroundTransparency = 1
SubKey.TextColor3 = T.TxtDim
SubKey.Font = Enum.Font.Gotham
SubKey.TextSize = 12
SubKey.Text = "Insira a senha de acesso"

local PFInp = Instance.new("TextBox", PF)
PFInp.Size = UDim2.new(0, 260, 0, 40)
PFInp.Position = UDim2.new(0.5, -130, 0, 80)
PFInp.BackgroundColor3 = Color3.fromRGB(6, 4, 15)
PFInp.BorderSizePixel = 0
PFInp.Font = Enum.Font.GothamBold
PFInp.TextColor3 = T.AccBrt
PFInp.PlaceholderColor3 = T.TxtDim
PFInp.TextSize = 14
PFInp.PlaceholderText = "Digite a senha..."
PFInp.Text = ""
PFInp.TextWrapped = true
Instance.new("UICorner", PFInp).CornerRadius = UDim.new(0, 8)

local PFBtn = Instance.new("TextButton", PF)
PFBtn.Size = UDim2.new(0, 260, 0, 40)
PFBtn.Position = UDim2.new(0.5, -130, 0, 135)
PFBtn.BackgroundColor3 = T.Acc
PFBtn.BorderSizePixel = 0
PFBtn.Font = Enum.Font.GothamBold
PFBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PFBtn.TextSize = 14
PFBtn.Text = "ENTRAR"
Instance.new("UICorner", PFBtn).CornerRadius = UDim.new(0, 8)

local PFErr = Instance.new("TextLabel", PF)
PFErr.Size = UDim2.new(1, 0, 0, 20)
PFErr.Position = UDim2.new(0, 0, 0, 180)
PFErr.BackgroundTransparency = 1
PFErr.TextColor3 = T.Danger
PFErr.Font = Enum.Font.Gotham
PFErr.TextSize = 12
PFErr.Text = ""

local buildMainUI

local function validatePW()
    local val = PFInp.Text:gsub("%s+", ""):lower()
    if val == "leyzepidao" then
        PFErr.TextColor3 = T.Success
        PFErr.Text = "✓ Acesso Autorizado!"
        task.wait(0.5)
        Intro:Destroy()
        pcall(buildMainUI)
    else
        PFErr.Text = "✗ Senha incorreta!"
        tw(PFBtn, {BackgroundColor3 = T.Danger}, 0.1)
        task.wait(0.4)
        tw(PFBtn, {BackgroundColor3 = T.Acc}, 0.3)
    end
end

PFBtn.MouseButton1Click:Connect(validatePW)
PFInp.FocusLost:Connect(function(enter) if enter then validatePW() end end)

-- ============================================================
-- INTERFACE PRINCIPAL RECHEADA E COMPLETA (SLAYERS 2)
-- ============================================================
buildMainUI = function()
    local MF = Instance.new("Frame", SG)
    MF.Name = "VoidMain"
    MF.BackgroundColor3 = T.BG
    MF.BorderSizePixel = 0
    MF.ClipsDescendants = true

    local FW = math.min(workspace.CurrentCamera.ViewportSize.X * 0.95, 450)
    local FH = 590
    MF.Size = UDim2.new(0, FW, 0, FH)
    MF.Position = UDim2.new(0.5, -FW / 2, 0.5, -FH / 2)

    Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 16)
    local MFS = Instance.new("UIStroke", MF)
    MFS.Color = T.Border; MFS.Thickness = 1.5

    -- Topbar Mobile
    local HDR = Instance.new("Frame", MF)
    HDR.Size = UDim2.new(1, 0, 0, 45)
    HDR.BackgroundColor3 = T.AccDim
    HDR.BorderSizePixel = 0
    Instance.new("UICorner", HDR).CornerRadius = UDim.new(0, 16)

    local htl = Instance.new("TextLabel", HDR)
    htl.Size = UDim2.new(0.65, 0, 1, 0)
    htl.Position = UDim2.new(0, 12, 0, 0)
    htl.BackgroundTransparency = 1
    htl.Font = Enum.Font.GothamBlack
    htl.TextSize = 13
    htl.TextColor3 = Color3.fromRGB(255, 255, 255)
    htl.TextXAlignment = Enum.TextXAlignment.Left
    htl.Text = "VOID.LAZY // SLAYERS 2"

    local function hBtn(icon, xoff, bg)
        local b = Instance.new("TextButton", HDR)
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(1, xoff, 0.5, -13)
        b.BackgroundColor3 = bg
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = icon
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end
    
    local CloseBtn = hBtn("✕", -34, Color3.fromRGB(180, 30, 30))
    local MinBtn   = hBtn("─", -66, Color3.fromRGB(70, 70, 0))

    -- Sistema de Arrastar para Celular
    local dragging, dragInput, dragStart, startPos
    HDR.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MF.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local minned = false
    MinBtn.MouseButton1Click:Connect(function()
        minned = not minned
        tw(MF, {Size = UDim2.new(0, FW, 0, minned and 45 | FH)}, 0.3)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        pcall(function() SG:Destroy() end)
    end)

    -- Abas
    local TBar = Instance.new("Frame", MF)
    TBar.Size = UDim2.new(1, 0, 0, 38)
    TBar.Position = UDim2.new(0, 0, 0, 45)
    TBar.BackgroundColor3 = T.PanelDk
    TBar.BorderSizePixel = 0
    local tbL = Instance.new("UIListLayout", TBar)
    tbL.FillDirection = Enum.FillDirection.Horizontal
    tbL.SortOrder = Enum.SortOrder.LayoutOrder
    tbL.Padding = UDim.new(0, 3)

    local CA = Instance.new("Frame", MF)
    CA.Size = UDim2.new(1, 0, 1, -83)
    CA.Position = UDim2.new(0, 0, 0, 83)
    CA.BackgroundTransparency = 1
    CA.ClipsDescendants = true

    local TABS = {
        {N="Farm",   I="⚔"},
        {N="Combat", I="🛡"},
        {N="Player", I="⚡"},
        {N="ESP",    I="👁"},
        {N="TP",     I="🌀"},
        {N="Misc",   I="⚙"},
    }

    local frames = {}
    local tBtns = {}
    local curTab = nil
    local tabW = 1 / #TABS

    local function switchTab(name)
        if curTab == name then return end
        curTab = name
        for n, f in pairs(frames) do f.Visible = (n == name) end
        for n, b in pairs(tBtns) do
            if n == name then
                tw(b, {BackgroundColor3 = T.Acc, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            else
                tw(b, {BackgroundColor3 = Color3.fromRGB(15, 12, 32), TextColor3 = T.TxtDim}, 0.2)
            end
        end
    end

    for i, td in ipairs(TABS) do
        local b = Instance.new("TextButton", TBar)
        b.Size = UDim2.new(tabW, 0, 1, 0)
        b.BackgroundColor3 = (i == 1) and T.Acc or Color3.fromRGB(15, 12, 32)
        b.BorderSizePixel = 0
        b.LayoutOrder = i
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or T.TxtDim
        b.Text = td.I .. " " .. td.N
        tBtns[td.N] = b

        local sf = Instance.new("ScrollingFrame", CA)
        sf.Size = UDim2.new(1, 0, 1, 0)
        sf.BackgroundTransparency = 1
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = T.AccDim
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Visible = (i == 1)
        sf.BorderSizePixel = 0
        
        local sfl = Instance.new("UIListLayout", sf)
        sfl.SortOrder = Enum.SortOrder.LayoutOrder
        sfl.Padding = UDim.new(0, 6)
        
        local sfp = Instance.new("UIPadding", sf)
        sfp.PaddingLeft = UDim.new(0, 10)
        sfp.PaddingRight = UDim.new(0, 10)
        sfp.PaddingTop = UDim.new(0, 8)
        
        frames[td.N] = sf
        b.MouseButton1Click:Connect(function() switchTab(td.N) end)
    end
    curTab = "Farm"

    local function mkSec(p, txt, ord)
        local f = Instance.new("Frame", p)
        f.Size = UDim2.new(1, 0, 0, 24)
        f.BackgroundColor3 = Color3.fromRGB(22, 10, 48)
        f.BorderSizePixel = 0
        f.LayoutOrder = ord or 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -12, 1, 0)
        l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = T.AccBrt
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = txt
        return f
    end

    local function mkToggle(p, lbl, key, ord, cb)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = T.Panel
        row.BorderSizePixel = 0
        row.LayoutOrder = ord or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        
        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(0.7, 0, 1, 0)
        tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Font = Enum.Font.Gotham
        tl.TextSize = 12
        tl.TextColor3 = T.Txt
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Text = lbl
        
        local tbg = Instance.new("Frame", row)
        tbg.Size = UDim2.new(0, 40, 0, 20)
        tbg.Position = UDim2.new(1, -48, 0.5, -10)
        tbg.BackgroundColor3 = ST[key] and T.On or T.Off
        tbg.BorderSizePixel = 0
        Instance.new("UICorner", tbg).CornerRadius = UDim.new(1, 0)
        
        local tk = Instance.new("Frame", tbg)
        tk.Size = UDim2.new(0, 16, 0, 16)
        tk.Position = ST[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        tk.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tk.BorderSizePixel = 0
        Instance.new("UICorner", tk).CornerRadius = UDim.new(1, 0)
        
        local hit = Instance.new("TextButton", row)
        hit.Size = UDim2.new(1, 0, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""

        hit.MouseButton1Click:Connect(function()
            ST[key] = not ST[key]
            tw(tbg, {BackgroundColor3 = ST[key] and T.On or T.Off}, 0.2)
            tw(tk, {Position = ST[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
            if cb then cb(ST[key]) end
        end)
        return row
    end

    local function mkSlider(p, lbl, vmin, vmax, key, ord, cb)
        local row = Instance.new("Frame", p)
        row.Size = UDim2.new(1, 0, 0, 50)
        row.BackgroundColor3 = T.Panel
        row.BorderSizePixel = 0
        row.LayoutOrder = ord or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        
        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(0.6, 0, 0.45, 0)
        tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Font = Enum.Font.Gotham
        tl.TextSize = 12
        tl.TextColor3 = T.Txt
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Text = lbl
        
        local vl = Instance.new("TextLabel", row)
        vl.Size = UDim2.new(0.3, 0, 0.45, 0)
        vl.Position = UDim2.new(0.68, 0, 0, 0)
        vl.BackgroundTransparency = 1
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 12
        vl.TextColor3 = T.AccBrt
        vl.TextXAlignment = Enum.TextXAlignment.Right
        vl.Text = tostring(ST[key])

        local sbg = Instance.new("Frame", row)
        sbg.Size = UDim2.new(0.88, 0, 0, 5)
        sbg.Position = UDim2.new(0.06, 0, 0.72, 0)
        sbg.BackgroundColor3 = Color3.fromRGB(25, 16, 50)
        sbg.BorderSizePixel = 0
        Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
        
        local pct = (ST[key] - vmin) / (vmax - vmin)
        local sf = Instance.new("Frame", sbg)
        sf.Size = UDim2.new(pct, 0, 1, 0)
        sf.BackgroundColor3 = T.AccBrt
        sf.BorderSizePixel = 0
        Instance.new("UICorner", sf).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function apply(pos)
            local abs = sbg.AbsolutePosition; local sz = sbg.AbsoluteSize
            local rel = math.clamp((pos.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(vmin + (vmax - vmin) * rel)
            ST[key] = val; vl.Text = tostring(val)
            tw(sf, {Size = UDim2.new(rel, 0, 1, 0)}, 0.05)
            if cb then cb(val) end
        end
        sbg.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; apply(i.Position) end end)
        sbg.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
                apply(i.Position) end end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false end end)
        return row
    end

    local function mkDrop(p, lbl, opts, key, ord, cb)
        local wrap = Instance.new("Frame", p)
        wrap.Size = UDim2.new(1, 0, 0, 36)
        wrap.BackgroundColor3 = T.Panel
        wrap.BorderSizePixel = 0
        wrap.LayoutOrder = ord or 0
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)
        
        local tl = Instance.new("TextLabel", wrap)
        tl.Size = UDim2.new(0.42, 0, 1, 0)
        tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Font = Enum.Font.Gotham
        tl.TextSize = 12
        tl.TextColor3 = T.Txt
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Text = lbl

        local db = Instance.new("TextButton", wrap)
        db.Size = UDim2.new(0.52, 0, 0.72, 0)
        db.Position = UDim2.new(0.45, 0, 0.14, 0)
        db.BackgroundColor3 = Color3.fromRGB(22, 14, 48)
        db.BorderSizePixel = 0
        db.Font = Enum.Font.GothamBold
        db.TextSize = 11
        db.TextColor3 = T.AccBrt
        db.Text = ST[key] or opts[1]
        Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)

        local DL = Instance.new("Frame", SG)
        DL.BackgroundColor3 = Color3.fromRGB(12, 8, 30)
        DL.BorderSizePixel = 0
        DL.Visible = false
        DL.ZIndex = 6000
        Instance.new("UICorner", DL).CornerRadius = UDim.new(0, 8)
        
        local dll = Instance.new("UIListLayout", DL)
        dll.SortOrder = Enum.SortOrder.LayoutOrder
        local IH = 26
        for j, opt in ipairs(opts) do
            local ob = Instance.new("TextButton", DL)
            ob.Size = UDim2.new(1, 0, 0, IH)
            ob.BackgroundColor3 = Color3.fromRGB(12, 8, 30)
            ob.BorderSizePixel = 0
            ob.Font = Enum.Font.Gotham
            ob.TextSize = 11
            ob.TextColor3 = T.Txt
            ob.Text = opt
            ob.ZIndex = 6001
            ob.LayoutOrder = j
            ob.MouseButton1Click:Connect(function()
                ST[key] = opt; db.Text = opt; DL.Visible = false
                if cb then cb(opt) end
            end)
        end
        DL.Size = UDim2.new(0, 185, 0, IH * #opts)
        local open = false
        db.MouseButton1Click:Connect(function()
            open = not open
            if open then
                local ap = db.AbsolutePosition; local as = db.AbsoluteSize
                DL.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 4); DL.Visible = true
            else DL.Visible = false end
        end)
        return wrap
    end

    local function mkBtn(p, txt, ord, cb)
        local b = Instance.new("TextButton", p)
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = T.Btn
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = txt
        b.LayoutOrder = ord or 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(function()
            tw(b, {BackgroundColor3 = T.AccBrt}, 0.08)
            task.wait(0.08)
            tw(b, {BackgroundColor3 = T.Btn}, 0.2)
            if cb then pcall(cb) end
        end)
        return b
    end

    local function notify(msg, color, dur)
        color = color or T.AccBrt; dur = dur or 2.5
        task.spawn(function()
            local nf = Instance.new("Frame", SG)
            nf.Size = UDim2.new(0, 275, 0, 40)
            nf.Position = UDim2.new(0.5, -137, 1, 10)
            nf.BackgroundColor3 = T.PanelDk
            nf.BorderSizePixel = 0
            nf.ZIndex = 9000
            Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 10)
            
            local ns = Instance.new("UIStroke", nf)
            ns.Color = color; ns.Thickness = 1.5
            
            local nl = Instance.new("TextLabel", nf)
            nl.Size = UDim2.new(1, -10, 1, 0)
            nl.Position = UDim2.new(0, 5, 0, 0)
            nl.BackgroundTransparency = 1
            nl.Font = Enum.Font.GothamBold
            nl.TextSize = 12
            nl.TextColor3 = color
            nl.ZIndex = 9001
            nl.Text = msg
            
            tw(nf, {Position = UDim2.new(0.5, -137, 1, -55)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(dur)
            tw(nf, {Position = UDim2.new(0.5, -137, 1, 10)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.35); pcall(function() nf:Destroy() end)
        end)
    end
    ST.Notify = notify

    -- ============================================================
    -- LÓGICA COMPLETA DE SLAYERS 2 (EQUIPAR ARMA, STACK DE MOBS, ETC)
    -- ============================================================
    local function equipWeapon()
        pcall(function()
            if not ST.EquipWeapon then return end
            local char = getChar()
            if not char then return end
            if char:FindFirstChildOfClass("Tool") then return end
            local bp = LP:FindFirstChildOfClass("Backpack")
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") then
                        local n = item.Name:lower()
                        if n:find("sword") or n:find("katana") or n:find("blade") or n:find("breath") or n:find("combat") or n:find("soco") then
                            char.Humanoid:EquipTool(item)
                            return
                        end
                    end
                end
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") then
                        char.Humanoid:EquipTool(item)
                        return
                    end
                end
            end
        end)
    end

    local function getTargetModel(name)
        local hrp = getHRP()
        if not hrp then return nil end
        local best, bd = nil, math.huge
        for _, v in ipairs(WS:GetDescendants()) do
            pcall(function()
                if v:IsA("Model") and v.Name:lower():find(name:lower()) then
                    local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d < bd then best, bd = v, d end
                    end
                end
            end)
        end
        return best
    end

    local function getAllTargets(name)
        local list = {}
        for _, v in ipairs(WS:GetDescendants()) do
            pcall(function()
                if v:IsA("Model") and v.Name:lower():find(name:lower()) then
                    local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 then
                        table.insert(list, v)
                    end
                end
            end)
        end
        return list
    end

    local function freezeModel(m)
        if not m or not ST.FreezeTarget then return end
        pcall(function()
            local h = m:FindFirstChildOfClass("Humanoid")
            local r = m:FindFirstChild("HumanoidRootPart")
            if h then h.WalkSpeed = 0; h.JumpPower = 0 end
            if r then r.AssemblyLinearVelocity = Vector3.zero end
        end)
    end

    local function fireAttack(target)
        if not target then return end
        pcall(function()
            equipWeapon()
            local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            if not root then return end

            if ST.HitboxExp then
                root.Size = Vector3.new(14, 14, 14)
                root.Transparency = 0.85
                root.CanCollide = false
            end

            local cd = target:FindFirstChildOfClass("ClickDetector")
            if cd then pcall(fireclickdetector, cd) end

            for _, pp in ipairs(target:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp) end
            end

            local char = getChar()
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end

            if RS then
                for _, rfn in ipairs({"Events", "Remotes", "RE", "RF", "CombatSystem"}) do
                    local rf = RS:FindFirstChild(rfn)
                    if rf then
                        for _, ch in ipairs(rf:GetDescendants()) do
                            if ch:IsA("RemoteEvent") then
                                local n = ch.Name:lower()
                                if n:find("attack") or n:find("hit") or n:find("damage") or n:find("sword") then
                                    pcall(function() ch:FireServer(target, root.Position) end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    local function getSafePosition(targetRoot)
        if not targetRoot then return CFrame.new(0,0,0) end
        local pos = targetRoot.Position
        local mode = ST.HeightMode
        if mode == "Abaixo do Chão" then
            return CFrame.new(pos.X, pos.Y - 12, pos.Z)
        elseif mode == "Por Cima (Seguro)" then
            return CFrame.new(pos.X, pos.Y + ST.HeightOffset, pos.Z) * CFrame.Angles(math.rad(90), 0, 0)
        else
            return CFrame.new(pos + Vector3.new(0, 4, 6))
        end
    end

    -- Loops de Execução dos Recursos
    local function loopFarm()
        task.spawn(function()
            while ST.AutoFarm do
                pcall(function()
                    local hum = getHum()
                    if not hum or hum.Health <= 0 then task.wait(3); return end

                    if ST.MobStack then
                        local mobs = getAllTargets(ST.TargetMob)
                        if #mobs > 0 then
                            local pMob = mobs[1]
                            local pRoot = pMob:FindFirstChild("HumanoidRootPart") or pMob.PrimaryPart
                            if pRoot and getHRP() then
                                getHRP().CFrame = getSafePosition(pRoot)
                            end
                            for _, mob in ipairs(mobs) do
                                if not ST.AutoFarm then break end
                                freezeModel(mob)
                                local mRoot = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                                if mRoot and pRoot then
                                    pcall(function()
                                        mRoot.CFrame = pRoot.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                                    end)
                                end
                                fireAttack(mob)
                            end
                        else
                            task.wait(1)
                        end
                    else
                        local t = getTargetModel(ST.TargetMob)
                        if not t then task.wait(1); return end
                        local th = t:FindFirstChildOfClass("Humanoid")
                        if not th or th.Health <= 0 then return end

                        local root = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                        if getHRP() and root then getHRP().CFrame = getSafePosition(root) end
                        freezeModel(t)

                        while ST.AutoFarm and th and th.Health > 0 do
                            freezeModel(t)
                            fireAttack(t)
                            task.wait(0.08)
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end

    local function loopMastery()
        task.spawn(function()
            while ST.AutoMastery do
                pcall(function()
                    local t = getTargetModel(ST.TargetMob)
                    if not t then task.wait(1); return end
                    local th = t:FindFirstChildOfClass("Humanoid")
                    if not th or th.Health <= 0 then return end
                    local root = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                    if getHRP() and root then getHRP().CFrame = getSafePosition(root) end
                    freezeModel(t)
                    while ST.AutoMastery and th and th.Health > 0 do
                        fireAttack(t)
                        freezeModel(t)
                        task.wait(0.06)
                    end
                end)
                task.wait(0.05)
            end
        end)
    end

    local function loopBoss()
        task.spawn(function()
            while ST.AutoBoss do
                pcall(function()
                    local t = getTargetModel(ST.TargetBoss)
                    if not t then task.wait(2); return end
                    local th = t:FindFirstChildOfClass("Humanoid")
                    if not th or th.Health <= 0 then task.wait(1); return end
                    local root = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                    if getHRP() and root then getHRP().CFrame = getSafePosition(root) end
                    freezeModel(t)
                    while ST.AutoBoss and th and th.Health > 0 do
                        fireAttack(t)
                        freezeModel(t)
                        task.wait(0.1)
                    end
                    task.wait(3)
                end)
                task.wait(0.1)
            end
        end)
    end

    local function loopQuest()
        task.spawn(function()
            while ST.AutoQuest do
                pcall(function()
                    for _, obj in ipairs(WS:GetDescendants()) do
                        pcall(function()
                            if obj:IsA("ProximityPrompt") then
                                local name = obj.Parent and obj.Parent.Name:lower() or ""
                                if name:find("quest") or name:find("npc") or name:find("mission") or name:find("giver") then
                                    local hrp = getHRP()
                                    local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChild("HumanoidRootPart")
                                    if hrp and part then
                                        hrp.CFrame = part.CFrame + Vector3.new(0, 3, 3)
                                        task.wait(0.25)
                                        fireproximityprompt(obj)
                                    end
                                end
                            end
                        end)
                    end
                end)
                task.wait(4)
            end
        end)
    end

    local function loopSkills()
        task.spawn(function()
            while ST.AutoSkills and (ST.AutoFarm or ST.AutoBoss or ST.AutoMastery) do
                pcall(function()
                    local vim = game:GetService("VirtualInputManager")
                    for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}) do
                        vim:SendKeyEvent(true, key, false, game)
                        task.wait(0.04)
                        vim:SendKeyEvent(false, key, false, game)
                        task.wait(0.15)
                    end
                end)
                task.wait(1.2)
            end
        end)
    end

    -- Abas da Interface (Recheada)
    local FT = frames["Farm"]
    mkSec(FT, "⚔ AUTO FARM COMPLETO", 1)
    local mobNames = {"Bandit", "Greater Demon", "Bear", "Mother Bear", "Demon", "Mushroom Demon", "Spider Demon"}
    mkDrop(FT, "Mob Alvo", mobNames, "TargetMob", 2)
    mkToggle(FT, "Auto Farm Ativo", "AutoFarm", 3, function(on) if on then loopFarm(); loopSkills() end end)
    mkToggle(FT, "Mob Stack (Junta todos os Mobs)", "MobStack", 4)
    mkToggle(FT, "Auto Equipar Arma / Soco", "EquipWeapon", 5)

    mkSec(FT, "🛡 SEGURANÇA & POSIÇÃO", 6)
    mkDrop(FT, "Modo de Altura", {"Abaixo do Chão", "Por Cima (Seguro)", "Atrás/Lado"}, "HeightMode", 7)
    mkSlider(FT, "Altura do Voo / Posição", 5, 30, "HeightOffset", 8)
    mkToggle(FT, "Hitbox Expandida (Longo Alcance)", "HitboxExp", 9)

    mkSec(FT, "✦ MASTERY & MISSÕES", 10)
    mkToggle(FT, "Auto Mastery (Farpar Maestria)", "AutoMastery", 11, function(on) if on then loopMastery() end end)
    mkToggle(FT, "Auto Quest (Aceitar Missões)", "AutoQuest", 12, function(on) if on then loopQuest() end end)
    mkToggle(FT, "Auto Habilidades de Respiração", "AutoSkills", 13)

    local CT = frames["Combat"]
    mkSec(CT, "💀 AUTO BOSS & DUNGEONS", 1)
    local bossNames = {"Zuko", "Mother Bear", "Rengu", "Zentaro", "Giyen", "Saneri"}
    mkDrop(CT, "Boss Alvo", bossNames, "TargetBoss", 2)
    mkToggle(CT, "Auto Boss Farm", "AutoBoss", 3, function(on) if on then loopBoss() end end)
    mkBtn(CT, "📍 Teleportar para o Boss", 4, function()
        local t = getTargetModel(ST.TargetBoss)
        if t and getHRP() and (t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart) then
            getHRP().CFrame = (t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart).CFrame + Vector3.new(0, 10, 0)
            notify("💀 TP → " .. ST.TargetBoss, T.Warn)
        else notify("Boss não encontrado", T.Danger) end
    end)

    local PT = frames["Player"]
    mkSec(PT, "⚡ MOVIMENTO", 1)
    mkToggle(PT, "✈ Voar (Fly Mobile)", "Fly", 2, function(on)
        if on then
            pcall(function()
                local hrp = getHRP()
                if not hrp then return end
                local g = Instance.new("BodyGyro", hrp); g.MaxTorque = Vector3.new(1e9,1e9,1e9)
                local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.Velocity = Vector3.zero
                ST.FlyGyro = g; ST.FlyBody = bv
                table.insert(ST.Connections, RunService.Heartbeat:Connect(function()
                    if not ST.Fly then pcall(function() g:Destroy(); bv:Destroy() end); return end
                    local cam = workspace.CurrentCamera
                    if cam and hrp then
                        g.CFrame = cam.CFrame
                        bv.Velocity = cam.CFrame.LookVector * (ST.FlySpeedVal * 1.5)
                    end
                end))
            end)
        else
            ST.Fly = false
            if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end) end
            if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end) end
        end
    end)
    mkSlider(PT, "Velocidade do Fly", 20, 200, "FlySpeedVal", 3)
    mkToggle(PT, "🦘 Pulo Infinito", "InfiniteJump", 4, nil)
    table.insert(ST.Connections, UIS.JumpRequest:Connect(function()
        if ST.InfiniteJump and getHum() then getHum():ChangeState(Enum.HumanoidStateType.Jumping) end
    end))
    mkToggle(PT, "🔮 No Clip (Atravessar Paredes)", "NoClip", 5, nil)
    table.insert(ST.Connections, RunService.Stepped:Connect(function()
        if ST.NoClip and getChar() then
            for _, p in ipairs(getChar():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end))

    local ET = frames["ESP"]
    mkSec(ET, "👁 VISUAL ESP", 1)
    mkToggle(ET, "ESP Mobs", "ESP_Mob", 2, function()
        pcall(function()
            for _, v in ipairs(WS:GetDescendants()) do
                if v:IsA("Model") and v ~= LP.Character and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
                    if ST.ESP_Mob and not v:FindFirstChild("VoidESP") then
                        local bb = Instance.new("BillboardGui", v.HumanoidRootPart)
                        bb.Name = "VoidESP"; bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 5, 0, 5)
                        local fr = Instance.new("Frame", bb); fr.Size = UDim2.new(1,0,1,0); fr.BackgroundColor3 = Color3.fromRGB(160,50,255)
                    elseif not ST.ESP_Mob and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart:FindFirstChild("VoidESP") then
                        v.HumanoidRootPart.VoidESP:Destroy()
                    end
                end
            end
        end)
    end)

    local TT = frames["TP"]
    mkSec(TT, "🌀 ZONAS DO MAPA", 1)
    local zones = {"Starter Village", "Bear Area", "Bamboo Grove", "Spider Forest", "Mistfall Village"}
    for i, z in ipairs(zones) do
        local zc = z
        mkBtn(TT, "📍 " .. z, i + 1, function()
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find(zc:sub(1,4):lower()) then
                    if getHRP() then getHRP().CFrame = obj.CFrame + Vector3.new(0, 8, 0) end
                    notify("🌀 TP → " .. zc, T.AccBrt)
                    return
                end
            end
            notify("Local não encontrado", T.Warn)
        end)
    end

    local MT = frames["Misc"]
    mkSec(MT, "⚙ CONFIGURAÇÕES", 1)
    mkToggle(MT, "Modo Anti-Detecção Máximo", "AntiDetect", 2, function(on) ST.AntiDetect = on end)
    mkBtn(MT, "♻ Recarregar Personagem", 3, function() LP:LoadCharacter() end)
    mkBtn(MT, "🌐 Rejoin Servidor", 4, function() pcall(function() TS:Teleport(game.PlaceId, LP) end) end)

    switchTab("Farm")
    notify("✦ VOID.LAZY v5.0 Carregado com Sucesso!", T.AccBrt, 4)
end
