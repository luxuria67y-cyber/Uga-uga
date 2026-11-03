-- ============================================================
--  VOID.LAZY v4.1 | Slayers 2 | MOBILE STABLE RELEASE
--  Delta Executor Optimized | Anti-Crash | Anti-Ban
--  Senha: leyzepidao
-- ============================================================

task.wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TeleportService")
local WS = workspace

local LP = Players.LocalPlayer
if not LP then return end

-- Remove instâncias antigas para evitar conflito de UI duplicada
pcall(function()
    if LP.PlayerGui:FindFirstChild("VOID_LAZY") then
        LP.PlayerGui.VOID_LAZY:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("VOID_LAZY") then
        game:GetService("CoreGui").VOID_LAZY:Destroy()
    end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "VOID_LAZY"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 99999
SG.IgnoreGuiInset = true

-- Força o parent na PlayerGui do Player para garantir compatibilidade total no Delta Mobile
local parentSuccess = pcall(function()
    SG.Parent = LP:WaitForChild("PlayerGui")
end)
if not parentSuccess then
    SG.Parent = game:GetService("CoreGui")
end

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
-- INTERFACE DE LOGIN / SENHA
-- ============================================================
local Intro = Instance.new("Frame", SG)
Intro.Size = UDim2.new(1, 0, 1, 0)
Intro.BackgroundColor3 = Color3.fromRGB(4, 3, 10)
Intro.BorderSizePixel = 0

local PF = Instance.new("Frame", Intro)
PF.Size = UDim2.new(0, 310, 0, 200)
PF.Position = UDim2.new(0.5, -155, 0.5, -100)
PF.BackgroundColor3 = T.PanelDk
PF.BorderSizePixel = 0
Instance.new("UICorner", PF).CornerRadius = UDim.new(0, 12)
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

local PFInp = Instance.new("TextBox", PF)
PFInp.Size = UDim2.new(0, 260, 0, 40)
PFInp.Position = UDim2.new(0.5, -130, 0, 70)
PFInp.BackgroundColor3 = Color3.fromRGB(6, 4, 15)
PFInp.BorderSizePixel = 0
PFInp.Font = Enum.Font.GothamBold
PFInp.TextColor3 = T.AccBrt
PFInp.PlaceholderColor3 = T.TxtDim
PFInp.TextSize = 14
PFInp.PlaceholderText = "Senha (leyzepidao)..."
PFInp.Text = ""
Instance.new("UICorner", PFInp).CornerRadius = UDim.new(0, 8)

local PFBtn = Instance.new("TextButton", PF)
PFBtn.Size = UDim2.new(0, 260, 0, 40)
PFBtn.Position = UDim2.new(0.5, -130, 0, 130)
PFBtn.BackgroundColor3 = T.Acc
PFBtn.BorderSizePixel = 0
PFBtn.Font = Enum.Font.GothamBold
PFBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PFBtn.TextSize = 14
PFBtn.Text = "ENTRAR"
Instance.new("UICorner", PFBtn).CornerRadius = UDim.new(0, 8)

local PFErr = Instance.new("TextLabel", PF)
PFErr.Size = UDim2.new(1, 0, 0, 20)
PFErr.Position = UDim2.new(0, 0, 0, 175)
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
        PFErr.Text = "✗ Senha incorreta! (Use: leyzepidao)"
        tw(PFBtn, {BackgroundColor3 = T.Danger}, 0.1)
        task.wait(0.4)
        tw(PFBtn, {BackgroundColor3 = T.Acc}, 0.3)
    end
end

PFBtn.MouseButton1Click:Connect(validatePW)
PFInp.FocusLost:Connect(function(enter) if enter then validatePW() end end)

-- ============================================================
-- INTERFACE PRINCIPAL (MOBILE READY)
-- ============================================================
buildMainUI = function()
    local MF = Instance.new("Frame", SG)
    MF.Name = "VoidMain"
    MF.BackgroundColor3 = T.BG
    MF.BorderSizePixel = 0
    MF.ClipsDescendants = true

    local FW = math.min(workspace.CurrentCamera.ViewportSize.X * 0.94, 420)
    local FH = 560
    MF.Size = UDim2.new(0, FW, 0, FH)
    MF.Position = UDim2.new(0.5, -FW / 2, 0.5, -FH / 2)

    Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 16)
    local MFS = Instance.new("UIStroke", MF)
    MFS.Color = T.Border; MFS.Thickness = 1.5

    local HDR = Instance.new("Frame", MF)
    HDR.Size = UDim2.new(1, 0, 0, 45)
    HDR.BackgroundColor3 = T.AccDim
    HDR.BorderSizePixel = 0
    Instance.new("UICorner", HDR).CornerRadius = UDim.new(0, 16)

    local htl = Instance.new("TextLabel", HDR)
    htl.Size = UDim2.new(0.7, 0, 1, 0)
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

    -- Arrastar no Mobile (Touch Support)
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
        tw(MF, {Size = UDim2.new(0, FW, 0, minned and 45 or FH)}, 0.3)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        pcall(function() SG:Destroy() end)
    end)

    -- Notificação interna simples
    local function notify(msg)
        pcall(function()
            local nf = Instance.new("TextLabel", SG)
            nf.Size = UDim2.new(0, 260, 0, 35)
            nf.Position = UDim2.new(0.5, -130, 0.85, 0)
            nf.BackgroundColor3 = T.PanelDk
            nf.TextColor3 = T.AccBrt
            nf.Font = Enum.Font.GothamBold
            nf.TextSize = 12
            nf.Text = msg
            Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 8)
            task.delay(2.5, function() pcall(function() nf:Destroy() end) end)
        end)
    end

    notify("✦ VOID.LAZY Carregado com Sucesso!")
end
