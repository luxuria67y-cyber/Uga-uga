-- ============================================================
--  VOID.LAZY v3.1 | Slayers 2 | MOBILE FIX EDITION
--  Delta Executor Compatible | Crash-proof | Anti-ban
--  Senha: leyzepidao
-- ============================================================

-- Aguarda o jogo carregar completamente antes de qualquer coisa
task.wait(2)

-- ============================================================
-- [1] WRAPPER GERAL — qualquer erro vira uma notificação
-- ============================================================
local OK, ERR = pcall(function()

-- ============================================================
-- [2] SERVICES — todos com pcall individual
-- ============================================================
local function gs(name)
    local ok, svc = pcall(game.GetService, game, name)
    return ok and svc or nil
end

local Players       = gs("Players")
local RunService    = gs("RunService")
local TweenService  = gs("TweenService")
local UIS           = gs("UserInputService")
local RS            = gs("ReplicatedStorage")
local TS            = gs("TeleportService")
local WS            = workspace

local LP = Players and Players.LocalPlayer
if not LP then return end  -- sem player, aborta silencioso

-- Camera com acesso lazy (evita nil no load)
local function getCam()
    return workspace.CurrentCamera
end

-- ============================================================
-- [3] UTILIDADES
-- ============================================================
local function rnd(a, b) return a + math.random() * (b - a) end

local function tw(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    local ok, t = pcall(TweenService.Create, TweenService, obj,
        TweenInfo.new(dur or 0.25,
            style or Enum.EasingStyle.Quad,
            dir   or Enum.EasingDirection.Out),
        props)
    if ok and t then t:Play() end
    return t
end

local function getChar()
    return LP and (LP.Character or LP.CharacterAdded:Wait())
end

local function getHRP()
    local c = LP and LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP and LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ============================================================
-- [4] ESTADO GLOBAL
-- ============================================================
local ST = {
    AutoFarm     = false, AutoBoss     = false,
    AutoMastery  = false, AutoQuest    = false,
    AutoDungeon  = false, AutoFishing  = false,
    AutoClanSpin = false, AutoSkills   = true,
    FreezeTarget = true,  AntiIdle     = true,
    ESP_Mob      = false, ESP_Boss     = false, ESP_Player = false,
    Fly          = false, Speed        = false,
    NoClip       = false, InfiniteJump = false,
    AntiDetect   = true,

    TargetMob    = "Greater Demon",
    TargetBoss   = "Zuko",
    MaxLevel     = 400,
    SpeedVal     = 60,
    FlySpeedVal  = 90,

    Connections  = {},
    ESPCache     = {},
    FlyGyro      = nil,
    FlyBody      = nil,
    Notify       = nil,   -- função injetada depois
}

-- ============================================================
-- [5] ANTI-DETECÇÃO
-- ============================================================
local AD = { on = true }

function AD:wait(base)
    if self.on then
        task.wait(base + (math.random() * 2 - 1) * (base * 0.2))
    else
        task.wait(base)
    end
end

function AD:drift()
    if not self.on then return end
    local hrp = getHRP()
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame * CFrame.new(
                (math.random()-.5)*.5, 0, (math.random()-.5)*.5)
        end)
    end
end

function AD:safeTP(pos)
    local hrp = getHRP()
    if not hrp then return end
    if self.on then
        local o = hrp.Position
        for i = 1, math.random(4,6) do
            pcall(function()
                hrp.CFrame = CFrame.new(o:Lerp(pos + Vector3.new(0,4,0), i/6))
            end)
            task.wait(0.04)
        end
    else
        pcall(function() hrp.CFrame = CFrame.new(pos + Vector3.new(0,4,0)) end)
    end
end

-- ============================================================
-- [6] DATABASE — SLAYERS 2
-- ============================================================
local MOBS = {
    "Bandit","Greater Demon","Bear","Mother Bear",
    "Demon","Mushroom Demon","Spider Demon","Zagan Demon",
    "Frozen Demon","Wind Demon","Stone Golem","Blood Demon",
    "Dungeon Demon",
}

local BOSSES = {
    {N="Zuko",       Lv=7,  Zone="Starter Village", Drop="Cutlass 20%"},
    {N="Mother Bear",Lv=18, Zone="Bear Area",        Drop="Bear Pelt"},
    {N="Rengu",      Lv=30, Zone="Mistfall Village", Drop="Flame Katana 5%"},
    {N="Zentaro",    Lv=28, Zone="Thunder Cliffs",   Drop="Thunder Katana 5%"},
    {N="Giyen",      Lv=32, Zone="Bamboo Grove",     Drop="Water Katana 5%"},
    {N="Saneri",     Lv=35, Zone="Iceveil Valley",   Drop="Wind Katana 5%"},
    {N="Shinora",    Lv=38, Zone="Butterfly Estate", Drop="Insect Katana 5%"},
    {N="Obari",      Lv=36, Zone="Starter Cliffs",   Drop="Serpent Katana 5%"},
    {N="Gyorei",     Lv=40, Zone="Stone Sanctuary",  Drop="Stone Katana 5%"},
    {N="Tengai",     Lv=42, Zone="Iceveil Valley",   Drop="Sound Katana 5%"},
}

local ZONES = {
    "Starter Village","Bear Area","Bamboo Grove","Spider Forest",
    "Mistfall Village","Butterfly Estate","Stone Sanctuary",
    "Iceveil Valley","Thunder Cliffs","Ouwigahara Dungeon",
}

-- ============================================================
-- [7] COMBAT HELPERS
-- ============================================================
local function findMob(name)
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bd = nil, math.huge

    local function check(v)
        if not v:IsA("Model") then return end
        if not v.Name:lower():find(name:lower()) then return end
        local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
        local hum  = v:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local d = (hrp.Position - root.Position).Magnitude
            if d < bd then best, bd = v, d end
        end
    end

    for _, v in ipairs(WS:GetDescendants()) do
        pcall(check, v)
    end
    return best
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
        local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not root then return end

        local cd = target:FindFirstChildOfClass("ClickDetector")
        if cd then pcall(fireclickdetector, cd) end

        for _, pp in ipairs(target:GetDescendants()) do
            if pp:IsA("ProximityPrompt") then
                pcall(fireproximityprompt, pp)
            end
        end

        local char = LP and LP.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            local act = tool:FindFirstChild("Activate")
            if act then pcall(function() act:Fire() end) end
        end

        if RS then
            for _, rfn in ipairs({"Events","Remotes","RE","RF"}) do
                local rf = RS:FindFirstChild(rfn)
                if rf then
                    for _, ch in ipairs(rf:GetDescendants()) do
                        if ch:IsA("RemoteEvent") then
                            local n = ch.Name:lower()
                            if n:find("attack") or n:find("hit") or n:find("damage") then
                                pcall(function() ch:FireServer(target, root.Position) end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function randPos(target, v)
    v = v or 1.5
    local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not root then return Vector3.zero end
    return root.Position + Vector3.new(
        (math.random()-.5)*v*2, 4 + math.random()*.5, (math.random()-.5)*v*2)
end

-- ============================================================
-- [8] LOOPS DE FARM
-- ============================================================
local function loopFarm()
    task.spawn(function()
        while ST.AutoFarm do
            pcall(function()
                local hum = getHum()
                if not hum or hum.Health <= 0 then task.wait(3); return end

                local t = findMob(ST.TargetMob)
                if not t then task.wait(1); return end

                local th = t:FindFirstChildOfClass("Humanoid")
                if not th or th.Health <= 0 then return end

                local hrp = getHRP()
                if hrp then hrp.CFrame = CFrame.new(randPos(t)) end
                freezeModel(t)

                local hits = 0
                while ST.AutoFarm and th and th.Health > 0 do
                    freezeModel(t)
                    fireAttack(t)
                    hits = hits + 1
                    if hits % math.random(5,10) == 0 then
                        local h2 = getHRP()
                        if h2 and t.Parent then
                            h2.CFrame = CFrame.new(randPos(t, 2))
                        end
                    end
                    AD:wait(rnd(0.08, 0.18))
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
                local t = findMob(ST.TargetBoss)
                if not t then task.wait(rnd(2,4)); return end

                local th = t:FindFirstChildOfClass("Humanoid")
                if not th or th.Health <= 0 then task.wait(1); return end

                local hrp = getHRP()
                if hrp then hrp.CFrame = CFrame.new(randPos(t, 2.5)) end
                freezeModel(t)

                while ST.AutoBoss and th and th.Health > 0 do
                    fireAttack(t)
                    freezeModel(t)
                    local h2 = getHRP()
                    if h2 and t.Parent then
                        h2.CFrame = CFrame.new(randPos(t, 2))
                    end
                    AD:wait(rnd(0.1, 0.2))
                end
                task.wait(rnd(4, 7))
            end)
            task.wait(0.1)
        end
    end)
end

local function loopMastery()
    task.spawn(function()
        while ST.AutoMastery do
            pcall(function()
                local t = findMob(ST.TargetMob)
                if not t then task.wait(1); return end
                local th = t:FindFirstChildOfClass("Humanoid")
                if not th or th.Health <= 0 then return end
                local hrp = getHRP()
                if hrp then hrp.CFrame = CFrame.new(randPos(t)) end
                freezeModel(t)
                while ST.AutoMastery and th and th.Health > 0 do
                    fireAttack(t)
                    freezeModel(t)
                    AD:wait(rnd(0.08, 0.15))
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function loopSkills()
    task.spawn(function()
        while ST.AutoSkills and (ST.AutoFarm or ST.AutoBoss or ST.AutoMastery) do
            pcall(function()
                if RS then
                    for _, rfn in ipairs({"Events","Remotes","RE"}) do
                        local rf = RS:FindFirstChild(rfn)
                        if rf then
                            for _, ch in ipairs(rf:GetDescendants()) do
                                if ch:IsA("RemoteEvent") then
                                    local n = ch.Name:lower()
                                    if n:find("skill") or n:find("ability") or n:find("breath") then
                                        pcall(function() ch:FireServer() end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(rnd(0.5, 1.5))
        end
    end)
end

local function loopQuest()
    task.spawn(function()
        while ST.AutoQuest do
            pcall(function()
                for _, nname in ipairs({"Krue","Tom","Quest","Crow","Muzan"}) do
                    local npc = findMob(nname)
                    if npc then
                        local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                        if root then
                            local hrp = getHRP()
                            if hrp then hrp.CFrame = root.CFrame + Vector3.new(0,2,3) end
                            local cd = npc:FindFirstChildOfClass("ClickDetector")
                            if cd then pcall(fireclickdetector, cd) end
                            for _, pp in ipairs(npc:GetDescendants()) do
                                if pp:IsA("ProximityPrompt") then
                                    pcall(fireproximityprompt, pp)
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(rnd(2, 4))
        end
    end)
end

local function loopFishing()
    task.spawn(function()
        while ST.AutoFishing do
            pcall(function()
                if RS then
                    for _, rfn in ipairs({"Events","Remotes","RE"}) do
                        local rf = RS:FindFirstChild(rfn)
                        if rf then
                            for _, ch in ipairs(rf:GetDescendants()) do
                                if ch:IsA("RemoteEvent") and ch.Name:lower():find("fish") then
                                    pcall(function() ch:FireServer() end)
                                end
                            end
                        end
                    end
                end
                local char = LP and LP.Character
                local rod  = char and char:FindFirstChild("Fishing Rod")
                if rod then
                    local act = rod:FindFirstChild("Activate")
                    if act then pcall(function() act:Fire() end) end
                end
            end)
            task.wait(rnd(3, 6))
        end
    end)
end

local function loopClan()
    task.spawn(function()
        while ST.AutoClanSpin do
            pcall(function()
                if RS then
                    for _, rfn in ipairs({"Events","Remotes","RE"}) do
                        local rf = RS:FindFirstChild(rfn)
                        if rf then
                            for _, ch in ipairs(rf:GetDescendants()) do
                                if ch:IsA("RemoteEvent") then
                                    local n = ch.Name:lower()
                                    if n:find("clan") or n:find("spin") or n:find("roll") then
                                        pcall(function() ch:FireServer() end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(rnd(1, 2))
        end
    end)
end

-- ============================================================
-- [9] MOVIMENTO
-- ============================================================
local function enableFly()
    pcall(function()
        local hrp = getHRP()
        if not hrp then return end

        if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end) end
        if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end) end

        local g = Instance.new("BodyGyro", hrp)
        g.MaxTorque = Vector3.new(1e9,1e9,1e9); g.P = 1e6; g.D = 50

        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.Velocity = Vector3.zero

        ST.FlyGyro = g; ST.FlyBody = bv

        local conn = RunService.Heartbeat:Connect(function()
            if not ST.Fly then
                pcall(function() g:Destroy() end)
                pcall(function() bv:Destroy() end)
                ST.FlyGyro = nil; ST.FlyBody = nil
                return
            end
            local cam = getCam()
            if not cam or not hrp or not hrp.Parent then return end
            pcall(function()
                g.CFrame = cam.CFrame
                local rv = hrp.AssemblyLinearVelocity
                local fwd = cam.CFrame.LookVector
                local rgt = cam.CFrame.RightVector
                local hz  = Vector3.new(rv.X, 0, rv.Z)
                if hz.Magnitude > 1 then
                    local dir = (fwd * -rv.Z + rgt * rv.X).Unit
                    if dir == dir then bv.Velocity = dir * ST.FlySpeedVal end
                else
                    bv.Velocity = bv.Velocity * 0.82
                end
            end)
        end)
        table.insert(ST.Connections, conn)
    end)
end

local function disableFly()
    ST.Fly = false
    if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end); ST.FlyGyro = nil end
    if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end); ST.FlyBody = nil end
end

-- NoClip
local ncConn = RunService.Stepped:Connect(function()
    if not ST.NoClip then return end
    pcall(function()
        local char = LP and LP.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)
table.insert(ST.Connections, ncConn)

-- Infinite Jump
local ijConn = UIS.JumpRequest:Connect(function()
    if not ST.InfiniteJump then return end
    pcall(function()
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)
table.insert(ST.Connections, ijConn)

local function setSpeed(v)
    pcall(function()
        local hum = getHum()
        if hum then hum.WalkSpeed = v end
    end)
end

-- Re-apply on death
LP.CharacterAdded:Connect(function()
    task.wait(1.2)
    if ST.Speed then setSpeed(ST.SpeedVal) end
    if ST.Fly   then task.wait(0.5); enableFly() end
end)

-- Anti-idle simples (sem VirtualUser)
task.spawn(function()
    while true do
        task.wait(60)
        if ST.AntiIdle then
            pcall(function()
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.new(0.1, 0, 0)
                    task.wait(0.1)
                    hrp.CFrame = hrp.CFrame * CFrame.new(-0.1, 0, 0)
                end
            end)
        end
    end
end)

-- ============================================================
-- [10] ESP
-- ============================================================
local function clearESP()
    for _, v in ipairs(ST.ESPCache) do
        pcall(function()
            if typeof(v) == "RBXScriptConnection" then v:Disconnect()
            elseif v and v.Parent then v:Destroy() end
        end)
    end
    ST.ESPCache = {}
end

local function makeESPTag(model, color)
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    local hum  = model:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local bb = Instance.new("BillboardGui", root)
    bb.AlwaysOnTop  = true
    bb.Size         = UDim2.new(0,6,0,6)
    bb.StudsOffset  = Vector3.new(0,2.5,0)
    bb.MaxDistance  = 250

    local bg = Instance.new("Frame", bb)
    bg.Size                   = UDim2.new(1,0,1,0)
    bg.BackgroundColor3       = color
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel        = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,2)

    local nl = Instance.new("TextLabel", bb)
    nl.Size                   = UDim2.new(3,0,0.5,0)
    nl.Position               = UDim2.new(-1,0,-0.8,0)
    nl.BackgroundTransparency = 1
    nl.Font                   = Enum.Font.GothamBold
    nl.TextColor3             = color
    nl.TextScaled             = true
    nl.TextStrokeTransparency = 0.2
    nl.Text                   = model.Name

    local hl = Instance.new("TextLabel", bb)
    hl.Size                   = UDim2.new(3,0,0.45,0)
    hl.Position               = UDim2.new(-1,0,-0.3,0)
    hl.BackgroundTransparency = 1
    hl.Font                   = Enum.Font.Gotham
    hl.TextColor3             = Color3.fromRGB(60,220,110)
    hl.TextScaled             = true
    hl.Text                   = "HP: "..math.floor(hum.Health)

    local uc = RunService.Heartbeat:Connect(function()
        if not bb or not bb.Parent or not hum.Parent then return end
        hl.Text = "HP: "..math.floor(hum.Health)
    end)
    table.insert(ST.ESPCache, uc)
    table.insert(ST.ESPCache, bb)
end

local function refreshESP()
    clearESP()
    if not ST.ESP_Mob and not ST.ESP_Boss and not ST.ESP_Player then return end

    local bossSet = {}
    for _, b in ipairs(BOSSES) do bossSet[b.N:lower()] = true end

    for _, v in ipairs(WS:GetDescendants()) do
        pcall(function()
            if not v:IsA("Model") or v == LP.Character then return end
            local hum = v:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local isBoss = bossSet[v.Name:lower()]
            local isPC   = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character == v then isPC = true; break end
            end
            if isBoss and ST.ESP_Boss then
                makeESPTag(v, Color3.fromRGB(255,100,20))
            elseif not isBoss and not isPC and ST.ESP_Mob then
                makeESPTag(v, Color3.fromRGB(155,40,255))
            elseif isPC and ST.ESP_Player then
                makeESPTag(v, Color3.fromRGB(255,50,50))
            end
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        if ST.ESP_Mob or ST.ESP_Boss or ST.ESP_Player then
            pcall(refreshESP)
        end
    end
end)

-- ============================================================
-- [11] SCREEN GUI — parenting robusto para mobile
-- ============================================================
local SG
pcall(function() SG = game:GetService("CoreGui"):FindFirstChild("VOID_LAZY") end)
if SG then SG:Destroy() end

SG = Instance.new("ScreenGui")
SG.Name           = "VOID_LAZY"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder   = 999
SG.IgnoreGuiInset = true

-- tenta CoreGui, cai pro PlayerGui
local parentOk = false
pcall(function()
    SG.Parent = game:GetService("CoreGui")
    parentOk = true
end)
if not parentOk then
    pcall(function()
        SG.Parent = LP.PlayerGui
        parentOk = true
    end)
end
if not parentOk then return end  -- sem GUI, aborta

-- ============================================================
-- [12] TEMA
-- ============================================================
local T = {
    BG       = Color3.fromRGB(9,  8,  20),
    Panel    = Color3.fromRGB(17, 13, 37),
    PanelDk  = Color3.fromRGB(11,  8, 24),
    Acc      = Color3.fromRGB(105,  0,205),
    AccBrt   = Color3.fromRGB(170, 55,255),
    AccDim   = Color3.fromRGB(52,   0,108),
    Txt      = Color3.fromRGB(235,228,255),
    TxtDim   = Color3.fromRGB(138,128,172),
    On       = Color3.fromRGB(85,   0,185),
    Off      = Color3.fromRGB(32,  25, 58),
    Btn      = Color3.fromRGB(72,   0,170),
    BtnHot   = Color3.fromRGB(115,  18,225),
    Border   = Color3.fromRGB(72,   0,152),
    Danger   = Color3.fromRGB(210,  42, 42),
    Success  = Color3.fromRGB(42,  195, 85),
    Warn     = Color3.fromRGB(210,172,  0),
}

-- ============================================================
-- [13] INTRO FRAME
-- ============================================================
local Intro = Instance.new("Frame", SG)
Intro.Size            = UDim2.new(1,0,1,0)
Intro.BackgroundColor3 = Color3.fromRGB(5,3,14)
Intro.BorderSizePixel  = 0
Intro.ZIndex           = 200

local iGrad = Instance.new("UIGradient", Intro)
iGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(4,0,12)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,0,28)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(4,0,12)),
})
iGrad.Rotation = 135

-- Partículas simples e seguras
for i = 1, 18 do
    local p  = Instance.new("Frame", Intro)
    local sz = math.random(2,6)
    p.Size                   = UDim2.new(0,sz,0,sz)
    p.BackgroundColor3       = Color3.fromRGB(math.random(55,150), 0, math.random(175,255))
    p.BackgroundTransparency = math.random() * 0.45 + 0.1
    p.BorderSizePixel        = 0
    p.ZIndex                 = 201
    Instance.new("UICorner", p).CornerRadius = UDim.new(1,0)

    local startX = math.random() -- guarda fora do spawn
    local startY = math.random()
    local speed  = rnd(0.00008, 0.00022)
    local phase  = math.random() * math.pi * 2

    task.spawn(function()
        local y = startY
        while p and p.Parent do
            y = (y - speed) % 1
            pcall(function()
                p.Position = UDim2.new(
                    startX + math.sin(tick()*0.4 + phase)*0.012, 0,
                    y, 0)
                p.BackgroundTransparency = 0.25 + math.abs(math.sin(tick()*0.25 + phase))*0.5
            end)
            task.wait(0.03)
        end
    end)
end

-- Labels de boas-vindas
local WFrame = Instance.new("Frame", Intro)
WFrame.Size                  = UDim2.new(0.88,0,0.28,0)
WFrame.Position              = UDim2.new(0.06,0,0.14,0)
WFrame.BackgroundTransparency = 1
WFrame.ZIndex                = 202

local L1 = Instance.new("TextLabel", WFrame)
L1.Size                   = UDim2.new(1,0,0.38,0)
L1.BackgroundTransparency = 1
L1.Font                   = Enum.Font.GothamMedium
L1.TextScaled             = true
L1.TextColor3             = Color3.fromRGB(195,188,255)
L1.TextStrokeTransparency = 0.5
L1.TextStrokeColor3       = T.Acc
L1.Text                   = ""
L1.ZIndex                 = 203

local L2 = Instance.new("TextLabel", WFrame)
L2.Size                   = UDim2.new(1,0,0.62,0)
L2.Position               = UDim2.new(0,0,0.38,0)
L2.BackgroundTransparency = 1
L2.Font                   = Enum.Font.GothamBlack
L2.TextScaled             = true
L2.TextColor3             = T.AccBrt
L2.TextStrokeTransparency = 0.25
L2.TextStrokeColor3       = T.AccDim
L2.Text                   = ""
L2.ZIndex                 = 203

-- Barra de loading
local LBG = Instance.new("Frame", Intro)
LBG.Size             = UDim2.new(0.65,0,0,5)
LBG.Position         = UDim2.new(0.175,0,0.5,0)
LBG.BackgroundColor3 = Color3.fromRGB(22,0,50)
LBG.BorderSizePixel  = 0
LBG.Visible          = false
LBG.ZIndex           = 202
Instance.new("UICorner", LBG).CornerRadius = UDim.new(1,0)

local LFill = Instance.new("Frame", LBG)
LFill.Size             = UDim2.new(0,0,1,0)
LFill.BackgroundColor3 = T.AccBrt
LFill.BorderSizePixel  = 0
LFill.ZIndex           = 203
Instance.new("UICorner", LFill).CornerRadius = UDim.new(1,0)

local LStat = Instance.new("TextLabel", Intro)
LStat.Size                   = UDim2.new(0.65,0,0.045,0)
LStat.Position               = UDim2.new(0.175,0,0.515,0)
LStat.BackgroundTransparency = 1
LStat.TextColor3             = T.TxtDim
LStat.Font                   = Enum.Font.Gotham
LStat.TextScaled             = true
LStat.Text                   = ""
LStat.ZIndex                 = 202

-- Frame de senha
local PF = Instance.new("Frame", Intro)
PF.Size                  = UDim2.new(0.82,0,0.34,0)
PF.Position              = UDim2.new(0.09,0,0.59,0)
PF.BackgroundColor3      = T.PanelDk
PF.BackgroundTransparency = 1
PF.BorderSizePixel       = 0
PF.ZIndex                = 202
Instance.new("UICorner", PF).CornerRadius = UDim.new(0,14)
local PFStroke = Instance.new("UIStroke", PF)
PFStroke.Color = T.Acc; PFStroke.Thickness = 1.5; PFStroke.Transparency = 1

local PFTit = Instance.new("TextLabel", PF)
PFTit.Size               = UDim2.new(1,0,0.27,0)
PFTit.BackgroundTransparency = 1
PFTit.TextColor3         = T.Txt
PFTit.Font               = Enum.Font.GothamBold
PFTit.TextScaled         = true
PFTit.Text               = "🔐  VERIFICAÇÃO DE ACESSO"
PFTit.TextTransparency   = 1
PFTit.ZIndex             = 203

local PFInp = Instance.new("TextBox", PF)
PFInp.Size               = UDim2.new(0.82,0,0.25,0)
PFInp.Position           = UDim2.new(0.09,0,0.3,0)
PFInp.BackgroundColor3   = Color3.fromRGB(7,4,18)
PFInp.BorderSizePixel    = 0
PFInp.Font               = Enum.Font.GothamBold
PFInp.TextColor3         = T.AccBrt
PFInp.PlaceholderColor3  = T.TxtDim
PFInp.TextScaled         = true
PFInp.PlaceholderText    = "Digite a senha..."
PFInp.Text               = ""
PFInp.TextTransparency   = 1
PFInp.ClearTextOnFocus   = false
PFInp.ZIndex             = 203
Instance.new("UICorner", PFInp).CornerRadius = UDim.new(0,8)
local PFInpS = Instance.new("UIStroke", PFInp)
PFInpS.Color = T.AccDim; PFInpS.Thickness = 1; PFInpS.Transparency = 1

local PFBtn = Instance.new("TextButton", PF)
PFBtn.Size               = UDim2.new(0.52,0,0.23,0)
PFBtn.Position           = UDim2.new(0.24,0,0.63,0)
PFBtn.BackgroundColor3   = T.Acc
PFBtn.BackgroundTransparency = 1
PFBtn.BorderSizePixel    = 0
PFBtn.Font               = Enum.Font.GothamBold
PFBtn.TextColor3         = Color3.fromRGB(255,255,255)
PFBtn.TextScaled         = true
PFBtn.Text               = "✦  ENTRAR  ✦"
PFBtn.TextTransparency   = 1
PFBtn.ZIndex             = 203
Instance.new("UICorner", PFBtn).CornerRadius = UDim.new(0,9)

local PFErr = Instance.new("TextLabel", PF)
PFErr.Size               = UDim2.new(1,0,0.14,0)
PFErr.Position           = UDim2.new(0,0,0.9,0)
PFErr.BackgroundTransparency = 1
PFErr.TextColor3         = T.Danger
PFErr.Font               = Enum.Font.Gotham
PFErr.TextScaled         = true
PFErr.Text               = ""
PFErr.ZIndex             = 203

-- ============================================================
-- [14] SEQUÊNCIA DE INTRO
-- ============================================================
local function typeWrite(lbl, txt, spd)
    spd = spd or 0.065
    for i = 1, #txt do
        lbl.Text = txt:sub(1, i)
        task.wait(spd)
    end
end

local function fillBar(pct, dur)
    tw(LFill, {Size = UDim2.new(pct,0,1,0)}, dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    task.wait(dur + 0.05)
end

local function fadeIntro()
    tw(Intro, {BackgroundTransparency = 1}, 0.65, Enum.EasingStyle.Quad)
    for _, ch in ipairs(Intro:GetDescendants()) do
        pcall(function()
            if ch:IsA("GuiObject") then
                local p = {}
                if ch.BackgroundTransparency < 1 then p.BackgroundTransparency = 1 end
                if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
                    p.TextTransparency = 1
                end
                if next(p) then tw(ch, p, 0.38) end
            end
        end)
    end
    task.wait(0.75)
    pcall(function() Intro:Destroy() end)
end

-- ============================================================
-- [15] FORWARD DECLARATION (evita nil call na senha)
-- ============================================================
local buildMainUI  -- declarado aqui, definido abaixo

-- ============================================================
-- [16] VALIDAÇÃO DE SENHA
-- ============================================================
local PW      = "leyzepidao"
local pwTries = 0

local function validatePW()
    local inp = PFInp.Text:lower():gsub("%s","")
    if inp == PW then
        PFBtn.BackgroundColor3 = T.Success
        PFErr.TextColor3       = T.Success
        PFErr.Text             = "✓  Acesso concedido!"
        task.wait(0.9)
        fadeIntro()
        task.wait(0.1)
        buildMainUI()
    else
        pwTries = pwTries + 1
        PFErr.Text = "✗  Senha incorreta! ("..pwTries.."/3)"

        -- shake
        local orig = PF.Position
        for i = 1,7 do
            local off = (i%2==0) and 10 or -10
            tw(PF,{Position=UDim2.new(orig.X.Scale,off,orig.Y.Scale,0)},0.04,Enum.EasingStyle.Sine)
            task.wait(0.045)
        end
        tw(PF,{Position=orig},0.1,Enum.EasingStyle.Bounce)

        tw(PFBtn,{BackgroundColor3=T.Danger},0.1)
        task.wait(0.6)
        tw(PFBtn,{BackgroundColor3=T.Acc},0.3)

        if pwTries >= 3 then
            PFBtn.Active = false
            PFErr.Text   = "⏳ Muitas tentativas. Aguarde 10s..."
            task.wait(10)
            pwTries  = 0
            PFBtn.Active = true
        end
        PFInp.Text = ""
    end
end

PFBtn.MouseButton1Click:Connect(validatePW)
PFInp.FocusLost:Connect(function(enter) if enter then validatePW() end end)

-- ============================================================
-- [17] ANIMAÇÃO DE INTRO (roda em background)
-- ============================================================
task.spawn(function()
    task.wait(0.3)
    typeWrite(L1, "✦  Bem-vindo a  ✦", 0.055)
    task.wait(0.2)

    local full = "VOID.LAZY"
    L2.Text = ""
    for i = 1, #full do
        L2.Text = full:sub(1,i)
        tw(L2,{TextColor3=Color3.fromRGB(255,255,255)},0.08)
        task.wait(0.13)
        tw(L2,{TextColor3=T.AccBrt},0.2)
        task.wait(0.02)
    end

    task.wait(0.35)
    LBG.Visible = true

    local steps = {
        {0.2,  0.32, "Carregando módulos..."},
        {0.45, 0.28, "Anti-detecção ativado..."},
        {0.72, 0.30, "Conectando ao servidor..."},
        {0.92, 0.22, "Preparando interface..."},
        {1.0,  0.15, "Pronto. ✓"},
    }
    for _, s in ipairs(steps) do
        LStat.Text = s[3]
        fillBar(s[1], s[2])
    end

    task.wait(0.3)
    LBG:Destroy(); LStat:Destroy()

    -- Revela frame de senha
    PF.BackgroundTransparency = 0
    PFStroke.Transparency     = 0

    local fi = {
        {PFTit, "TextTransparency",        0},
        {PFInp, "TextTransparency",        0},
        {PFInp, "BackgroundTransparency",  0},
        {PFInpS,"Transparency",            0},
        {PFBtn, "BackgroundTransparency",  0},
        {PFBtn, "TextTransparency",        0},
    }
    for _, x in ipairs(fi) do tw(x[1],{[x[2]]=x[3]},0.5) end

    -- Borda pulsante no input
    task.spawn(function()
        while PFInp and PFInp.Parent do
            tw(PFInpS,{Color=T.AccBrt},0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(0.9)
            tw(PFInpS,{Color=T.AccDim},0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(0.9)
        end
    end)
end)

-- ============================================================
-- [18] MAIN UI — DEFINIÇÃO
-- ============================================================
buildMainUI = function()
    local VP       = getCam() and getCam().ViewportSize or Vector2.new(800,600)
    local mobile   = VP.X < 860

    -- Frame principal
    local MF = Instance.new("Frame", SG)
    MF.Name             = "VoidMain"
    MF.BorderSizePixel  = 0
    MF.ClipsDescendants = true
    MF.BackgroundColor3 = T.BG

    local FW = mobile and math.min(VP.X * 0.93, 400) or 355
    local FH = 575
    MF.Size     = UDim2.new(0, FW, 0, FH)
    MF.Position = UDim2.new(0.5, -FW/2, -1, 0)

    Instance.new("UICorner", MF).CornerRadius = UDim.new(0,15)
    local MFS = Instance.new("UIStroke", MF)
    MFS.Color = T.Border; MFS.Thickness = 1.5

    local tgtPos = UDim2.new(0.5, -FW/2, 0.04, 0)
    tw(MF,{Position=tgtPos},0.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    -- glow border pulse
    task.spawn(function()
        while MF and MF.Parent do
            tw(MFS,{Color=T.AccBrt},1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(1.5)
            tw(MFS,{Color=T.Border},1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
            task.wait(1.5)
        end
    end)

    -- ── Header ──────────────────────────────────────────────
    local HDR = Instance.new("Frame", MF)
    HDR.Size             = UDim2.new(1,0,0,50)
    HDR.BackgroundColor3 = T.AccDim
    HDR.BorderSizePixel  = 0
    Instance.new("UICorner", HDR).CornerRadius = UDim.new(0,15)
    Instance.new("UIGradient", HDR).Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(40,0,90)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(78,0,162)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(40,0,90)),
    })
    -- correção cantos inferiores
    local hfix = Instance.new("Frame", HDR)
    hfix.Size = UDim2.new(1,0,0.5,0); hfix.Position = UDim2.new(0,0,0.5,0)
    hfix.BackgroundColor3 = T.AccDim; hfix.BorderSizePixel = 0

    local htl = Instance.new("TextLabel", HDR)
    htl.Size = UDim2.new(0.62,0,1,0); htl.Position = UDim2.new(0,12,0,0)
    htl.BackgroundTransparency = 1; htl.Font = Enum.Font.GothamBlack
    htl.TextScaled = true; htl.TextXAlignment = Enum.TextXAlignment.Left
    htl.TextColor3 = Color3.fromRGB(255,255,255)
    htl.TextStrokeTransparency = 0.35; htl.TextStrokeColor3 = T.AccBrt
    htl.Text = "⬡ VOID.LAZY"

    local hsub = Instance.new("TextLabel", HDR)
    hsub.Size = UDim2.new(0.28,0,0.42,0); hsub.Position = UDim2.new(0.7,0,0.3,0)
    hsub.BackgroundTransparency = 1; hsub.Font = Enum.Font.GothamBold
    hsub.TextScaled = true; hsub.TextXAlignment = Enum.TextXAlignment.Right
    hsub.TextColor3 = T.TxtDim; hsub.Text = "SLAYERS 2"

    local function hBtn(icon, xoff, bg)
        local b = Instance.new("TextButton", HDR)
        b.Size = UDim2.new(0,27,0,27); b.Position = UDim2.new(1,xoff,0.5,-13)
        b.BackgroundColor3 = bg; b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold; b.TextScaled = true
        b.TextColor3 = Color3.fromRGB(255,255,255); b.Text = icon
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end
    local CloseBtn = hBtn("✕", -34, Color3.fromRGB(170,28,28))
    local MinBtn   = hBtn("─", -67, Color3.fromRGB(68,68,0))

    -- ── Tab bar ─────────────────────────────────────────────
    local TBar = Instance.new("Frame", MF)
    TBar.Size = UDim2.new(1,0,0,35); TBar.Position = UDim2.new(0,0,0,50)
    TBar.BackgroundColor3 = T.PanelDk; TBar.BorderSizePixel = 0
    local tbL = Instance.new("UIListLayout", TBar)
    tbL.FillDirection = Enum.FillDirection.Horizontal
    tbL.SortOrder     = Enum.SortOrder.LayoutOrder
    tbL.Padding       = UDim.new(0,3)
    local tbP = Instance.new("UIPadding", TBar)
    tbP.PaddingLeft=UDim.new(0,4); tbP.PaddingRight=UDim.new(0,4)
    tbP.PaddingTop=UDim.new(0,4);  tbP.PaddingBottom=UDim.new(0,4)

    -- Content area
    local CA = Instance.new("Frame", MF)
    CA.Size = UDim2.new(1,0,1,-85); CA.Position = UDim2.new(0,0,0,85)
    CA.BackgroundTransparency = 1; CA.ClipsDescendants = true

    -- ── Tab criação ─────────────────────────────────────────
    local TABS = {
        {N="Farm",   I="⚔"},
        {N="Boss",   I="💀"},
        {N="Player", I="⚡"},
        {N="ESP",    I="👁"},
        {N="TP",     I="🌀"},
        {N="Misc",   I="⚙"},
    }

    local frames  = {}
    local tBtns   = {}
    local curTab  = nil
    local tabW    = (1 - 0.012) / #TABS

    local function switchTab(name)
        if curTab == name then return end
        curTab = name
        for n,f in pairs(frames) do f.Visible = (n==name) end
        for n,b in pairs(tBtns) do
            if n==name then
                tw(b,{BackgroundColor3=T.Acc,TextColor3=Color3.fromRGB(255,255,255)},0.17)
            else
                tw(b,{BackgroundColor3=Color3.fromRGB(17,12,36),TextColor3=T.TxtDim},0.17)
            end
        end
    end

    for i,td in ipairs(TABS) do
        local b = Instance.new("TextButton", TBar)
        b.Size = UDim2.new(tabW,0,1,0)
        b.BackgroundColor3 = (i==1) and T.Acc or Color3.fromRGB(17,12,36)
        b.BorderSizePixel = 0; b.LayoutOrder = i
        b.Font = Enum.Font.GothamBold; b.TextScaled = true
        b.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or T.TxtDim
        b.Text = td.I.." "..td.N
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
        tBtns[td.N] = b

        local sf = Instance.new("ScrollingFrame", CA)
        sf.Size = UDim2.new(1,0,1,0); sf.BackgroundTransparency = 1
        sf.ScrollBarThickness = 3; sf.ScrollBarImageColor3 = T.AccDim
        sf.CanvasSize = UDim2.new(0,0,0,0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Visible = (i==1); sf.BorderSizePixel = 0
        local sfl = Instance.new("UIListLayout", sf)
        sfl.SortOrder = Enum.SortOrder.LayoutOrder; sfl.Padding = UDim.new(0,4)
        local sfp = Instance.new("UIPadding", sf)
        sfp.PaddingLeft=UDim.new(0,8); sfp.PaddingRight=UDim.new(0,8); sfp.PaddingTop=UDim.new(0,6)
        frames[td.N] = sf
        b.MouseButton1Click:Connect(function() switchTab(td.N) end)
    end
    curTab = "Farm"

    -- ── HELPERS ─────────────────────────────────────────────
    local function mkSec(p, txt, ord)
        local f = Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,22)
        f.BackgroundColor3=Color3.fromRGB(20,7,45); f.BorderSizePixel=0; f.LayoutOrder=ord or 0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
        local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-12,1,0); l.Position=UDim2.new(0,12,0,0)
        l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextScaled=true
        l.TextColor3=T.AccBrt; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=txt
        return f
    end

    local function mkToggle(p, lbl, key, ord, cb)
        local row=Instance.new("Frame",p); row.Size=UDim2.new(1,0,0,36)
        row.BackgroundColor3=T.Panel; row.BorderSizePixel=0; row.LayoutOrder=ord or 0
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
        local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(0.7,0,1,0); tl.Position=UDim2.new(0,10,0,0)
        tl.BackgroundTransparency=1; tl.Font=Enum.Font.Gotham; tl.TextScaled=true
        tl.TextColor3=T.Txt; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=lbl
        local tbg=Instance.new("Frame",row); tbg.Size=UDim2.new(0,44,0,22); tbg.Position=UDim2.new(1,-52,0.5,-11)
        tbg.BackgroundColor3=ST[key] and T.On or T.Off; tbg.BorderSizePixel=0
        Instance.new("UICorner",tbg).CornerRadius=UDim.new(1,0)
        local tk=Instance.new("Frame",tbg); tk.Size=UDim2.new(0,18,0,18)
        tk.Position=ST[key] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        tk.BackgroundColor3=Color3.fromRGB(255,255,255); tk.BorderSizePixel=0
        Instance.new("UICorner",tk).CornerRadius=UDim.new(1,0)
        local hit=Instance.new("TextButton",row); hit.Size=UDim2.new(1,0,1,0)
        hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=row.ZIndex+2
        local function upd()
            tw(tbg,{BackgroundColor3=ST[key] and T.On or T.Off},0.2)
            tw(tk,{Position=ST[key] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)},0.2)
        end
        hit.MouseButton1Click:Connect(function()
            ST[key]=not ST[key]; upd(); if cb then cb(ST[key]) end
        end)
        return row
    end

    local function mkSlider(p, lbl, vmin, vmax, key, ord, cb)
        local row=Instance.new("Frame",p); row.Size=UDim2.new(1,0,0,52)
        row.BackgroundColor3=T.Panel; row.BorderSizePixel=0; row.LayoutOrder=ord or 0
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
        local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(0.6,0,0.46,0); tl.Position=UDim2.new(0,10,0,0)
        tl.BackgroundTransparency=1; tl.Font=Enum.Font.Gotham; tl.TextScaled=true
        tl.TextColor3=T.Txt; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=lbl
        local vl=Instance.new("TextLabel",row); vl.Size=UDim2.new(0.3,0,0.4,0); vl.Position=UDim2.new(0.68,0,0.04,0)
        vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold; vl.TextScaled=true
        vl.TextColor3=T.AccBrt; vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Text=tostring(ST[key])
        local sbg=Instance.new("Frame",row); sbg.Size=UDim2.new(0.88,0,0,5); sbg.Position=UDim2.new(0.06,0,0.77,0)
        sbg.BackgroundColor3=Color3.fromRGB(26,17,50); sbg.BorderSizePixel=0
        Instance.new("UICorner",sbg).CornerRadius=UDim.new(1,0)
        local pct=(ST[key]-vmin)/(vmax-vmin)
        local sf=Instance.new("Frame",sbg); sf.Size=UDim2.new(pct,0,1,0)
        sf.BackgroundColor3=T.AccBrt; sf.BorderSizePixel=0
        Instance.new("UICorner",sf).CornerRadius=UDim.new(1,0)
        local sk=Instance.new("Frame",sbg); sk.Size=UDim2.new(0,14,0,14); sk.Position=UDim2.new(pct,-7,0.5,-7)
        sk.BackgroundColor3=Color3.fromRGB(255,255,255); sk.BorderSizePixel=0
        Instance.new("UICorner",sk).CornerRadius=UDim.new(1,0)
        local dragging=false
        local function apply(pos)
            local abs=sbg.AbsolutePosition; local sz=sbg.AbsoluteSize
            local rel=math.clamp((pos.X-abs.X)/sz.X,0,1)
            local val=math.floor(vmin+(vmax-vmin)*rel)
            ST[key]=val; vl.Text=tostring(val)
            tw(sf,{Size=UDim2.new(rel,0,1,0)},0.05,Enum.EasingStyle.Linear)
            tw(sk,{Position=UDim2.new(rel,-7,0.5,-7)},0.05,Enum.EasingStyle.Linear)
            if cb then cb(val) end
        end
        sbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=true; apply(i.Position) end end)
        sbg.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
                apply(i.Position) end end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragging=false end end)
        return row
    end

    local function mkDrop(p, lbl, opts, key, ord, cb)
        local wrap=Instance.new("Frame",p); wrap.Size=UDim2.new(1,0,0,36)
        wrap.BackgroundColor3=T.Panel; wrap.BorderSizePixel=0; wrap.LayoutOrder=ord or 0
        wrap.ClipsDescendants=false
        Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,9)
        local tl=Instance.new("TextLabel",wrap); tl.Size=UDim2.new(0.43,0,1,0); tl.Position=UDim2.new(0,10,0,0)
        tl.BackgroundTransparency=1; tl.Font=Enum.Font.Gotham; tl.TextScaled=true
        tl.TextColor3=T.Txt; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=lbl
        local db=Instance.new("TextButton",wrap); db.Size=UDim2.new(0.5,0,0.72,0); db.Position=UDim2.new(0.48,0,0.14,0)
        db.BackgroundColor3=Color3.fromRGB(20,13,45); db.BorderSizePixel=0
        db.Font=Enum.Font.GothamBold; db.TextScaled=true; db.TextColor3=T.AccBrt
        db.Text=ST[key] or opts[1]; db.ClipsDescendants=true
        Instance.new("UICorner",db).CornerRadius=UDim.new(0,7)
        local ds=Instance.new("UIStroke",db); ds.Color=T.AccDim; ds.Thickness=1
        local DL=Instance.new("Frame",SG); DL.BackgroundColor3=Color3.fromRGB(12,7,30)
        DL.BorderSizePixel=0; DL.Visible=false; DL.ZIndex=500
        Instance.new("UICorner",DL).CornerRadius=UDim.new(0,9)
        local dls=Instance.new("UIStroke",DL); dls.Color=T.Acc; dls.Thickness=1
        local dll=Instance.new("UIListLayout",DL); dll.SortOrder=Enum.SortOrder.LayoutOrder
        local IH=26
        for j,opt in ipairs(opts) do
            local ob=Instance.new("TextButton",DL); ob.Size=UDim2.new(1,0,0,IH)
            ob.BackgroundColor3=Color3.fromRGB(12,7,30); ob.BorderSizePixel=0
            ob.Font=Enum.Font.Gotham; ob.TextScaled=true; ob.TextColor3=T.Txt
            ob.Text=opt; ob.ZIndex=501; ob.LayoutOrder=j
            ob.MouseButton1Click:Connect(function() ST[key]=opt; db.Text=opt; DL.Visible=false; if cb then cb(opt) end end)
            ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(32,16,62)},0.1) end)
            ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(12,7,30)},0.1) end)
        end
        DL.Size=UDim2.new(0,175,0,IH*#opts)
        local open=false
        db.MouseButton1Click:Connect(function()
            open=not open
            if open then
                local ap=db.AbsolutePosition; local as=db.AbsoluteSize
                DL.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+3); DL.Visible=true
            else DL.Visible=false end
        end)
        return wrap
    end

    local function mkBtn(p, txt, ord, cb)
        local b=Instance.new("TextButton",p); b.Size=UDim2.new(1,0,0,33)
        b.BackgroundColor3=T.Btn; b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold
        b.TextScaled=true; b.TextColor3=Color3.fromRGB(255,255,255); b.Text=txt; b.LayoutOrder=ord or 0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
        b.MouseButton1Click:Connect(function()
            tw(b,{BackgroundColor3=T.AccBrt},0.08); task.wait(0.08); tw(b,{BackgroundColor3=T.Btn},0.22)
            if cb then pcall(cb) end
        end)
        b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=T.BtnHot},0.14) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=T.Btn},0.14) end)
        return b
    end

    local function mkSp(p,h,ord)
        local s=Instance.new("Frame",p); s.Size=UDim2.new(1,0,0,h or 3)
        s.BackgroundTransparency=1; s.LayoutOrder=ord or 0; return s
    end

    -- ── NOTIFICAÇÃO ─────────────────────────────────────────
    local function notify(msg, color, dur)
        color=color or T.AccBrt; dur=dur or 2.5
        task.spawn(function()
            local nf=Instance.new("Frame",SG); nf.Size=UDim2.new(0,265,0,44)
            nf.Position=UDim2.new(0.5,-132,1,5)
            nf.BackgroundColor3=T.PanelDk; nf.BorderSizePixel=0; nf.ZIndex=1000
            Instance.new("UICorner",nf).CornerRadius=UDim.new(0,11)
            local ns=Instance.new("UIStroke",nf); ns.Color=color; ns.Thickness=1.5
            local nl=Instance.new("TextLabel",nf); nl.Size=UDim2.new(1,-10,1,0); nl.Position=UDim2.new(0,5,0,0)
            nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold; nl.TextScaled=true
            nl.TextColor3=color; nl.TextStrokeTransparency=0.3; nl.ZIndex=1001; nl.Text=msg
            tw(nf,{Position=UDim2.new(0.5,-132,1,-54)},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            task.wait(dur)
            tw(nf,{Position=UDim2.new(0.5,-132,1,5)},0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
            task.wait(0.38); pcall(function() nf:Destroy() end)
        end)
    end
    ST.Notify = notify

    -- ================================================================
    -- CONTEÚDO DAS ABAS
    -- ================================================================

    -- ── FARM ────────────────────────────────────────────────
    local FT=frames["Farm"]
    mkSec(FT,"⚔  AUTO FARM",1)
    mkDrop(FT,"Mob Alvo",MOBS,"TargetMob",2)
    mkToggle(FT,"Auto Farm",        "AutoFarm",    3, function(on) if on then loopFarm(); loopSkills() end end)
    mkToggle(FT,"Congelar Alvo",    "FreezeTarget",4)
    mkSec(FT,"✦  AUTO MASTERY",5)
    mkToggle(FT,"Auto Mastery Farm","AutoMastery",6,function(on) if on then loopMastery() end end)
    mkSec(FT,"📋  AUTO QUEST",7)
    mkToggle(FT,"Auto Quest NPCs",  "AutoQuest",   8, function(on) if on then loopQuest() end end)
    mkSec(FT,"⚙  CONFIG",9)
    mkSlider(FT,"Nível Máximo",1,1000,"MaxLevel",10)
    mkToggle(FT,"Auto Skills/Breathing","AutoSkills",11)
    mkToggle(FT,"Anti-Idle (anti-kick)","AntiIdle",  12)
    mkSp(FT,3,13)

    -- ── BOSS ────────────────────────────────────────────────
    local BT=frames["Boss"]
    mkSec(BT,"💀  AUTO BOSS",1)
    local bnames={}; for _,b in ipairs(BOSSES) do table.insert(bnames,b.N) end
    mkDrop(BT,"Boss Alvo",bnames,"TargetBoss",2)
    mkToggle(BT,"Auto Boss Farm","AutoBoss",3,function(on) if on then loopBoss() end end)
    mkToggle(BT,"Congelar Boss","FreezeTarget",4)

    local biF=Instance.new("Frame",BT); biF.Size=UDim2.new(1,0,0,82); biF.BackgroundColor3=Color3.fromRGB(17,9,36)
    biF.BorderSizePixel=0; biF.LayoutOrder=5; Instance.new("UICorner",biF).CornerRadius=UDim.new(0,9)
    local biL=Instance.new("TextLabel",biF); biL.Size=UDim2.new(1,-12,1,0); biL.Position=UDim2.new(0,6,0,0)
    biL.BackgroundTransparency=1; biL.Font=Enum.Font.Gotham; biL.TextScaled=true; biL.TextWrapped=true
    biL.RichText=true; biL.TextColor3=T.TxtDim; biL.TextXAlignment=Enum.TextXAlignment.Left; biL.TextYAlignment=Enum.TextYAlignment.Center

    local function refreshBI()
        for _,b in ipairs(BOSSES) do
            if b.N==ST.TargetBoss then
                biL.Text=('<font color="#aa55ff"><b>%s</b></font>  Lv.%d\n<font color="#8844bb">Zona:</font> <font color="#ccaaff">%s</font>\n<font color="#8844bb">Drop:</font> <font color="#55cc77">%s</font>'):format(b.N,b.Lv,b.Zone,b.Drop)
                break
            end
        end
    end
    refreshBI()

    mkSec(BT,"🏰  DUNGEON OUWIGAHARA",6)
    mkToggle(BT,"Auto Dungeon (Lv.65+)","AutoDungeon",7,function(on)
        if on then
            task.spawn(function()
                while ST.AutoDungeon do
                    pcall(function()
                        if RS then
                            for _,rfn in ipairs({"Events","Remotes","RE"}) do
                                local rf=RS:FindFirstChild(rfn)
                                if rf then
                                    for _,ch in ipairs(rf:GetDescendants()) do
                                        if ch:IsA("RemoteEvent") then
                                            local n=ch.Name:lower()
                                            if n:find("dungeon") or n:find("ouw") then
                                                pcall(function() ch:FireServer() end)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(rnd(5,10))
                end
            end)
        end
    end)
    mkBtn(BT,"📍 TP para o Boss",8,function()
        local t=findMob(ST.TargetBoss)
        if t then
            local r=t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
            if r then
                local hrp=getHRP()
                if hrp then hrp.CFrame=r.CFrame+Vector3.new(0,10,0) end
                notify("💀 TP → "..ST.TargetBoss,T.Warn)
            end
        else notify("Boss não encontrado no servidor",T.Danger) end
    end)

    -- ── PLAYER ──────────────────────────────────────────────
    local PT=frames["Player"]
    mkSec(PT,"🚀  MOVIMENTO",1)
    mkToggle(PT,"✈ Voar (Fly)","Fly",2,function(on)
        if on then enableFly() else disableFly() end
    end)
    mkSlider(PT,"Velocidade Fly",10,350,"FlySpeedVal",3)
    mkToggle(PT,"⚡ Speed Hack","Speed",4,function(on) setSpeed(on and ST.SpeedVal or 16) end)
    mkSlider(PT,"Velocidade Walk",16,500,"SpeedVal",5,function(v) if ST.Speed then setSpeed(v) end end)
    mkToggle(PT,"🦘 Pulo Infinito","InfiniteJump",6)
    mkToggle(PT,"🔮 No Clip","NoClip",7)
    mkSec(PT,"🎣  PESCA & CLAN",8)
    mkToggle(PT,"Auto Pesca","AutoFishing",9,function(on) if on then loopFishing() end end)
    mkToggle(PT,"Auto Clan Spin","AutoClanSpin",10,function(on) if on then loopClan() end end)
    mkSec(PT,"🛡  ANTI-DETECÇÃO",11)
    mkToggle(PT,"Humanizar Ações","AntiDetect",12,function(on)
        AD.on=on
    end)
    mkBtn(PT,"♻ Recarregar Personagem",13,function() LP:LoadCharacter() end)
    mkBtn(PT,"🌐 Rejoin Servidor",14,function()
        pcall(function() TS:Teleport(game.PlaceId,LP) end)
    end)

    -- ── ESP ─────────────────────────────────────────────────
    local ET=frames["ESP"]
    mkSec(ET,"👁  ESP",1)
    mkToggle(ET,"ESP Mobs (roxo)","ESP_Mob",2,function() pcall(refreshESP) end)
    mkToggle(ET,"ESP Bosses (laranja)","ESP_Boss",3,function() pcall(refreshESP) end)
    mkToggle(ET,"ESP Jogadores (vermelho)","ESP_Player",4,function() pcall(refreshESP) end)
    mkBtn(ET,"🔄 Atualizar ESP",5,function() clearESP(); task.wait(0.1); pcall(refreshESP) end)
    mkBtn(ET,"🗑 Limpar ESP",6,function()
        clearESP(); ST.ESP_Mob=false; ST.ESP_Boss=false; ST.ESP_Player=false
        notify("✓ ESP limpo",T.Success)
    end)

    -- ── TP ──────────────────────────────────────────────────
    local TT=frames["TP"]
    mkSec(TT,"🌀  ZONAS",1)
    for i,z in ipairs(ZONES) do
        local zc=z
        mkBtn(TT,"📍 "..z,i+1,function()
            local found=false
            for _,obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
                    if obj.Name:lower():find(zc:sub(1,5):lower()) then
                        local hrp=getHRP()
                        if hrp then hrp.CFrame=obj.CFrame+Vector3.new(0,12,0) end
                        found=true; break
                    end
                end
            end
            notify(found and ("🌀 TP → "..zc) or ("Zona não mapeada ainda: "..zc),
                   found and T.AccBrt or T.Warn)
        end)
    end
    mkSec(TT,"💀  BOSSES",#ZONES+3)
    for i,b in ipairs(BOSSES) do
        local bc=b
        mkBtn(TT,("💀 %s  Lv.%d"):format(b.N,b.Lv),#ZONES+3+i,function()
            local t=findMob(bc.N)
            if t then
                local r=t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                if r then
                    local hrp=getHRP()
                    if hrp then hrp.CFrame=r.CFrame+Vector3.new(0,10,0) end
                    notify("💀 TP → "..bc.N,T.Warn)
                end
            else notify("Boss não encontrado no mapa",T.Danger) end
        end)
    end

    -- ── MISC ────────────────────────────────────────────────
    local MT=frames["Misc"]
    mkSec(MT,"⚙  UTILITÁRIOS",1)
    mkBtn(MT,"📋 Copiar UserID",2,function()
        pcall(function() setclipboard(tostring(LP.UserId)) end)
        notify("✓ UserID copiado!",T.Success)
    end)
    mkBtn(MT,"🌄 FPS Boost",3,function()
        pcall(function()
            local LC=game:GetService("Lighting")
            LC.GlobalShadows=false; LC.FogEnd=10000
            for _,v in ipairs(WS:GetDescendants()) do
                if v:IsA("BasePart") then v.CastShadow=false end
            end
        end)
        notify("✓ FPS Boost aplicado",T.Success)
    end)
    mkBtn(MT,"🔕 Remover Efeitos",4,function()
        pcall(function()
            for _,v in ipairs(WS:GetDescendants()) do
                if v:IsA("Atmosphere") or v:IsA("Sky") then v.Parent=nil end
            end
        end)
        notify("✓ Efeitos removidos",T.Success)
    end)
    mkSec(MT,"📊  DEBUG AO VIVO",5)
    local dbF=Instance.new("Frame",MT); dbF.Size=UDim2.new(1,0,0,88); dbF.BackgroundColor3=T.PanelDk
    dbF.BorderSizePixel=0; dbF.LayoutOrder=6; Instance.new("UICorner",dbF).CornerRadius=UDim.new(0,9)
    local dbL=Instance.new("TextLabel",dbF); dbL.Size=UDim2.new(1,-10,1,0); dbL.Position=UDim2.new(0,5,0,0)
    dbL.BackgroundTransparency=1; dbL.Font=Enum.Font.Code; dbL.TextScaled=true; dbL.TextWrapped=true
    dbL.TextColor3=T.TxtDim; dbL.TextXAlignment=Enum.TextXAlignment.Left; dbL.RichText=true

    RunService.Heartbeat:Connect(function()
        if not MF or not MF.Parent then return end
        pcall(function()
            local hum=getHum(); local hrp=getHRP()
            if hum and hrp then
                dbL.Text=('<font color="#7755aa">Player:</font> <font color="#bb88ff">%s</font>  <font color="#7755aa">HP:</font> <font color="#55cc77">%.0f</font>\n<font color="#7755aa">Pos:</font> <font color="#bb88ff">%.0f %.0f %.0f</font>\n<font color="#7755aa">Farm:</font> <font color="#cc99ff">%s</font>  <font color="#7755aa">Boss:</font> <font color="#cc99ff">%s</font>'):format(
                    LP.DisplayName, hum.Health, hrp.Position.X, hrp.Position.Y, hrp.Position.Z,
                    ST.TargetMob, ST.TargetBoss)
            end
        end)
    end)

    mkSec(MT,"ℹ  SOBRE",7)
    local aF=Instance.new("Frame",MT); aF.Size=UDim2.new(1,0,0,55); aF.BackgroundColor3=T.PanelDk
    aF.BorderSizePixel=0; aF.LayoutOrder=8; Instance.new("UICorner",aF).CornerRadius=UDim.new(0,9)
    local aL=Instance.new("TextLabel",aF); aL.Size=UDim2.new(1,-10,1,0); aL.Position=UDim2.new(0,5,0,0)
    aL.BackgroundTransparency=1; aL.Font=Enum.Font.Gotham; aL.TextScaled=true; aL.TextWrapped=true
    aL.RichText=true; aL.TextColor3=T.TxtDim
    aL.Text='<font color="#9933ee"><b>VOID.LAZY v3.1</b></font>  Mobile Fix Edition\nSlayers 2 | Anti-Detect | Delta Ready'

    -- ── DRAGGABLE ───────────────────────────────────────────
    local drag,dStart,dOrig=false,nil,nil
    HDR.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; dStart=i.Position; dOrig=MF.Position end end)
    HDR.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local d=i.Position-dStart
            MF.Position=UDim2.new(dOrig.X.Scale,dOrig.X.Offset+d.X,dOrig.Y.Scale,dOrig.Y.Offset+d.Y)
        end end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false end end)

    -- ── MINIMIZAR ───────────────────────────────────────────
    local minned=false
    MinBtn.MouseButton1Click:Connect(function()
        minned=not minned
        tw(MF,{Size=UDim2.new(0,FW,0,minned and 50 or FH)},0.3,
            Enum.EasingStyle.Quad,
            minned and Enum.EasingDirection.In or Enum.EasingDirection.Out)
    end)

    -- ── FECHAR ──────────────────────────────────────────────
    CloseBtn.MouseButton1Click:Connect(function()
        tw(MF,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.38,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.wait(0.45)
        ST.AutoFarm=false; ST.AutoBoss=false; ST.AutoMastery=false
        ST.AutoQuest=false; ST.AutoFishing=false; ST.AutoClanSpin=false
        ST.Fly=false; ST.NoClip=false; ST.InfiniteJump=false
        for _,c in ipairs(ST.Connections) do pcall(function() c:Disconnect() end) end
        clearESP()
        pcall(function() SG:Destroy() end)
    end)

    -- ── INIT ────────────────────────────────────────────────
    switchTab("Farm")
    task.wait(0.6)
    notify("✦ VOID.LAZY v3.1 carregado!",T.AccBrt,3)
    task.wait(1.1)
    notify("🛡 Anti-Detecção ATIVO",T.Success,2.5)
    task.wait(1.2)
    notify("⚔ Slayers 2 | Mobile Ready",T.Warn,2.5)
end -- fim buildMainUI

-- ============================================================
-- FIM DO PCALL PRINCIPAL
-- ============================================================
end) -- fim pcall

-- Se o script crashou, mostra o erro num ScreenGui mínimo
if not OK then
    task.spawn(function()
        local sg2 = Instance.new("ScreenGui")
        sg2.Name = "VOID_ERR"; sg2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg2.DisplayOrder = 9999
        sg2.ResetOnSpawn = false
        pcall(function() sg2.Parent = game:GetService("CoreGui") end)
        if not sg2.Parent then
            pcall(function() sg2.Parent = game:GetService("Players").LocalPlayer.PlayerGui end)
        end
        local f = Instance.new("Frame",sg2); f.Size=UDim2.new(0.9,0,0,80); f.Position=UDim2.new(0.05,0,0.4,0)
        f.BackgroundColor3=Color3.fromRGB(30,5,5); f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
        local l = Instance.new("TextLabel",f); l.Size=UDim2.new(1,-10,1,0); l.Position=UDim2.new(0,5,0,0)
        l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextScaled=true
        l.TextWrapped=true; l.TextColor3=Color3.fromRGB(255,80,80)
        l.Text = "VOID.LAZY ERRO:\n"..tostring(ERR)
    end)
end

print("[VOID.LAZY v3.1] Executado. Aguardando intro...")
