-- ============================================================
--  VOID.LAZY v4.0 | Slayers 2 | ULTIMATE MOBILE EDITION
--  Delta Executor Optimized | Anti-Ban Máximo | Full Features
--  Senha: leyzepidao
-- ============================================================

task.wait(1)

local OK, ERR = pcall(function()

-- Services com pcall e fallback seguro
local function gs(name)
    local ok, svc = pcall(game.GetService, game, name)
    return ok and svc or nil
end

local Players      = gs("Players")
local RunService   = gs("RunService")
local TweenService = gs("TweenService")
local UIS          = gs("UserInputService")
local RS           = gs("ReplicatedStorage")
local TS           = gs("TeleportService")
local WS           = workspace

local LP = Players and Players.LocalPlayer
if not LP then return end

local function getCam()
    return workspace.CurrentCamera
end

local function rnd(a, b) return a + math.random() * (b - a) end

local function tw(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    local ok, t = pcall(TweenService.Create, TweenService, obj,
        TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    if ok and t then t:Play() end
    return t
end

local function getChar()
    return LP and (LP.Character or LP.CharacterAdded:Wait())
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ============================================================
-- ESTADO GLOBAL E CONFIGURAÇÕES DE JOGO
-- ============================================================
local ST = {
    AutoFarm       = false,
    AutoBoss       = false,
    AutoMastery    = false,
    AutoQuest      = false,
    AutoDungeon    = false,
    AutoFishing    = false,
    AutoClanSpin   = false,
    AutoSkills     = true,
    FreezeTarget   = true,
    AntiIdle       = true,
    ESP_Mob        = false,
    ESP_Boss       = false,
    ESP_Player     = false,
    Fly            = false,
    Speed          = false,
    NoClip         = false,
    InfiniteJump   = false,
    AntiDetect     = true,
    
    -- Novas Opções Solicitadas
    MobStack       = true,  -- Junta todos os NPCs da missão para matar de uma vez
    HeightMode     = "Por Cima (Seguro)", -- Opções: "Abaixo do Chão", "Por Cima (Seguro)", "Atrás/Lado"
    HitboxExp      = true,  -- Aumenta hitbox para bater de longe sem tomar dano
    EquipItem      = "Qualquer Arma/Soco", -- Auto equipar ferramenta do inventário

    TargetMob      = "Greater Demon",
    TargetBoss     = "Zuko",
    MaxLevel       = 400,
    SpeedVal       = 60,
    FlySpeedVal    = 90,
    HeightOffset   = 12,    -- Altura customizável para segurança

    Connections    = {},
    ESPCache       = {},
    FlyGyro        = nil,
    FlyBody        = nil,
    Notify         = nil,
}

-- ============================================================
-- SISTEMA DE ANTI-DETECÇÃO MÁXIMO & HUMANIZAÇÃO
-- ============================================================
local AD = { on = true }

function AD:wait(base)
    if self.on then
        task.wait(base + (math.random() * 2 - 1) * (base * 0.25))
    else
        task.wait(base)
    end
end

function AD:drift()
    if not self.on then return end
    local hrp = getHRP()
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame * CFrame.new((math.random()-.5)*0.3, 0, (math.random()-.5)*0.3)
        end)
    end
end

-- ============================================================
-- DATABASE ATUALIZADA - SLAYERS 2
-- ============================================================
local MOBS = {
    "Bandit", "Greater Demon", "Bear", "Mother Bear",
    "Demon", "Mushroom Demon", "Spider Demon", "Zagan Demon",
    "Frozen Demon", "Wind Demon", "Stone Golem", "Blood Demon",
    "Dungeon Demon", "Lower Rank Demon", "Corrupted Slayer"
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
    "Starter Village", "Bear Area", "Bamboo Grove", "Spider Forest",
    "Mistfall Village", "Butterfly Estate", "Stone Sanctuary",
    "Iceveil Valley", "Thunder Cliffs", "Ouwigahara Dungeon",
}

-- ============================================================
-- GERENCIAMENTO DE ARMAS E INVENTÁRIO (Soco / Espada / Maestria)
-- ============================================================
local function equipBestWeapon()
    pcall(function()
        local char = getChar()
        if not char then return end
        
        -- Verifica se já tem alguma ferramenta na mão
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool then return end

        local backpack = LP:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("sword") or name:find("katana") or name:find("blade") or name:find("breath") or name:find("combat") or name:find("fist") or name:find("soco") then
                        LP.Character.Humanoid:EquipTool(item)
                        return
                    end
                end
            end
            -- Se não achou específica, equipa a primeira ferramenta disponível
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    LP.Character.Humanoid:EquipTool(item)
                    return
                end
            end
        end
    end)
end

-- ============================================================
-- COMBAT HELPERS & HITBOX / ALTURA DE SEGURANÇA
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

-- Coleta múltiplos NPCs para farm em massa (Junta todos)
local function getAllMobs(name)
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

-- Expansão de Hitbox para ataque à distância sem tomar dano
local function applyHitbox(target)
    if not ST.HitboxExp or not target then return end
    pcall(function()
        local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if root then
            root.Size = Vector3.new(12, 12, 12)
            root.Transparency = 0.8
            root.CanCollide = false
        end
    end)
end

local function fireAttack(target)
    if not target then return end
    pcall(function()
        equipBestWeapon()
        applyHitbox(target)
        
        local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not root then return end

        local cd = target:FindFirstChildOfClass("ClickDetector")
        if cd then pcall(fireclickdetector, cd) end

        for _, pp in ipairs(target:GetDescendants()) do
            if pp:IsA("ProximityPrompt") then
                pcall(fireproximityprompt, pp)
            end
        end

        local char = getChar()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            local act = tool:FindFirstChild("Activate")
            if act then pcall(function() act:Fire() end) end
            pcall(function() tool:Activate() end)
        end

        if RS then
            for _, rfn in ipairs({"Events", "Remotes", "RE", "RF", "CombatSystem", "DamageRemote"}) do
                local rf = RS:FindFirstChild(rfn)
                if rf then
                    for _, ch in ipairs(rf:GetDescendants()) do
                        if ch:IsA("RemoteEvent") then
                            local n = ch.Name:lower()
                            if n:find("attack") or n:find("hit") or n:find("damage") or n:find("sword") or n:find("combat") then
                                pcall(function() ch:FireServer(target, root.Position) end)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Cálculo de Posição Baseado no Modo de Altura Escolhido
local function getPositionByMode(targetRoot)
    if not targetRoot then return CFrame.new(0,0,0) end
    local pos = targetRoot.Position
    local mode = ST.HeightMode

    if mode == "Abaixo do Chão" then
        -- Fica embaixo do chão para ficar 100% seguro e invisível para players
        return CFrame.new(pos.X, pos.Y - 12, pos.Z)
    elseif mode == "Por Cima (Seguro)" then
        -- Fica flutuando bem acima fora do alcance melee do mob
        return CFrame.new(pos.X, pos.Y + ST.HeightOffset, pos.Z) * CFrame.Angles(math.rad(90), 0, 0)
    else -- Atrás / Lado
        return CFrame.new(pos + Vector3.new(0, 4, 5))
    end
end

-- ============================================================
-- LOOPS DE AUTOMAÇÃO (FARM, BOSS, QUEST, MASTERY)
-- ============================================================
local function loopFarm()
    task.spawn(function()
        while ST.AutoFarm do
            pcall(function()
                local hum = getHum()
                if not hum or hum.Health <= 0 then task.wait(3); return end

                equipBestWeapon()

                if ST.MobStack then
                    -- Junta todos os mobs da missão ao redor do player ou leva o player até o grupo
                    local mobs = getAllMobs(ST.TargetMob)
                    if #mobs > 0 then
                        local primaryMob = mobs[1]
                        local pRoot = primaryMob:FindFirstChild("HumanoidRootPart") or primaryMob.PrimaryPart
                        if pRoot then
                            local hrp = getHRP()
                            if hrp then hrp.CFrame = getPositionByMode(pRoot) end
                        end
                        
                        for _, mob in ipairs(mobs) do
                            if not ST.AutoFarm then break end
                            freezeModel(mob)
                            local mRoot = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                            if mRoot and pRoot then
                                -- Puxa os outros mobs para perto do principal para matar em área (AoE)
                                pcall(function()
                                    mRoot.CFrame = pRoot.CFrame * CFrame.new(math.random(-2,2), 0, math.random(-2,2))
                                end)
                            end
                            fireAttack(mob)
                        end
                    else
                        task.wait(1)
                    end
                else
                    local t = findMob(ST.TargetMob)
                    if not t then task.wait(1); return end
                    local th = t:FindFirstChildOfClass("Humanoid")
                    if not th or th.Health <= 0 then return end

                    local root = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                    local hrp = getHRP()
                    if hrp and root then hrp.CFrame = getPositionByMode(root) end
                    freezeModel(t)

                    while ST.AutoFarm and th and th.Health > 0 do
                        freezeModel(t)
                        fireAttack(t)
                        AD:wait(rnd(0.06, 0.12))
                    end
                end
            end)
            task.wait(0.04)
        end
    end)
end

local function loopBoss()
    task.spawn(function()
        while ST.AutoBoss do
            pcall(function()
                local t = findMob(ST.TargetBoss)
                if not t then task.wait(2); return end

                local th = t:FindFirstChildOfClass("Humanoid")
                if not th or th.Health <= 0 then task.wait(1); return end

                local root = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                local hrp = getHRP()
                if hrp and root then hrp.CFrame = getPositionByMode(root) end
                freezeModel(t)

                while ST.AutoBoss and th and th.Health > 0 do
                    fireAttack(t)
                    freezeModel(t)
                    AD:wait(rnd(0.08, 0.15))
                end
                task.wait(3)
            end)
            task.wait(0.1)
        end
    end)
end

local function loopMastery()
    task.spawn(function()
        while ST.AutoMastery do
            pcall(function()
                equipBestWeapon()
                local t = findMob(ST.TargetMob)
                if not t then task.wait(1); return end
                local th = t:FindFirstChildOfClass("Humanoid")
                if not th or th.Health <= 0 then return end
                local root = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
                local hrp = getHRP()
                if hrp and root then hrp.CFrame = getPositionByMode(root) end
                freezeModel(t)
                while ST.AutoMastery and th and th.Health > 0 do
                    fireAttack(t)
                    freezeModel(t)
                    AD:wait(rnd(0.05, 0.1))
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- Auto Quest funcional com varredura inteligente de NPCs de Missão e Diálogo
local function loopQuest()
    task.spawn(function()
        while ST.AutoQuest do
            pcall(function()
                for _, obj in ipairs(WS:GetDescendants()) do
                    pcall(function()
                        if obj:IsA("ProximityPrompt") then
                            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                            if parentName:find("quest") or parentName:find("npc") or parentName:find("mission") or parentName:find("krue") or parentName:find("giver") then
                                local hrp = getHRP()
                                local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChild("HumanoidRootPart")
                                if hrp and part then
                                    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 3)
                                    task.wait(0.3)
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
                -- Simula o uso das habilidades de respiração (teclas 1, 2, 3, 4)
                for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}) do
                    vim:SendKeyEvent(true, key, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, key, false, game)
                    task.wait(0.2)
                end
            end)
            task.wait(rnd(1, 2))
        end
    end)
end

local function loopFishing()
    task.spawn(function()
        while ST.AutoFishing do
            pcall(function()
                local char = getChar()
                local rod = char and char:FindFirstChild("Fishing Rod")
                if not rod then
                    local bp = LP:FindFirstChildOfClass("Backpack")
                    if bp then
                        for _, item in ipairs(bp:GetChildren()) do
                            if item.Name:lower():find("fish") or item.Name:lower():find("vara") then
                                LP.Character.Humanoid:EquipTool(item)
                            end
                        end
                    end
                end
                rod = getChar() and getChar():FindFirstChild("Fishing Rod")
                if rod then
                    rod:Activate()
                end
            end)
            task.wait(rnd(3, 5))
        end
    end)
end

local function loopClan()
    task.spawn(function()
        while ST.AutoClanSpin do
            pcall(function()
                if RS then
                    for _, rfn in ipairs({"Events", "Remotes", "RE"}) do
                        local rf = RS:FindFirstChild(rfn)
                        if rf then
                            for _, ch in ipairs(rf:GetDescendants()) do
                                if ch:IsA("RemoteEvent") and (ch.Name:lower():find("clan") or ch.Name:lower():find("spin")) then
                                    ch:FireServer()
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(1.5)
        end
    end)
end

-- ============================================================
-- SISTEMA DE MOVIMENTO (FLY, NOCLIP, SPEED)
-- ============================================================
local function enableFly()
    pcall(function()
        local hrp = getHRP()
        if not hrp then return end
        if ST.FlyGyro then ST.FlyGyro:Destroy() end
        if ST.FlyBody then ST.FlyBody:Destroy() end

        local g = Instance.new("BodyGyro", hrp)
        g.MaxTorque = Vector3.new(1e9, 1e9, 1e9); g.P = 1e6; g.D = 50
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.zero

        ST.FlyGyro = g; ST.FlyBody = bv

        local conn = RunService.Heartbeat:Connect(function()
            if not ST.Fly then
                pcall(function() g:Destroy(); bv:Destroy() end)
                ST.FlyGyro = nil; ST.FlyBody = nil
                return
            end
            local cam = getCam()
            if cam and hrp then
                g.CFrame = cam.CFrame
                local rv = hrp.AssemblyLinearVelocity
                local fwd = cam.CFrame.LookVector
                local rgt = cam.CFrame.RightVector
                local hz = Vector3.new(rv.X, 0, rv.Z)
                if hz.Magnitude > 1 then
                    local dir = (fwd * -rv.Z + rgt * rv.X).Unit
                    if dir == dir then bv.Velocity = dir * ST.FlySpeedVal end
                else
                    bv.Velocity = Vector3.zero
                end
            end
        end)
        table.insert(ST.Connections, conn)
    end)
end

local function disableFly()
    ST.Fly = false
    if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end); ST.FlyGyro = nil end
    if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end); ST.FlyBody = nil end
end

local ncConn = RunService.Stepped:Connect(function()
    if not ST.NoClip then return end
    pcall(function()
        local char = getChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)
table.insert(ST.Connections, ncConn)

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

-- ============================================================
-- ESP SYSTEM ROBUSTO
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
    bb.AlwaysOnTop = true; bb.Size = UDim2.new(0, 6, 0, 6)
    bb.StudsOffset = Vector3.new(0, 2.5, 0); bb.MaxDistance = 300

    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = color
    bg.BackgroundTransparency = 0.3; bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 2)

    local nl = Instance.new("TextLabel", bb)
    nl.Size = UDim2.new(3, 0, 0.5, 0); nl.Position = UDim2.new(-1, 0, -0.8, 0)
    nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamBold
    nl.TextColor3 = color; nl.TextScaled = true; nl.TextStrokeTransparency = 0.2
    nl.Text = model.Name

    local hl = Instance.new("TextLabel", bb)
    hl.Size = UDim2.new(3, 0, 0.45, 0); hl.Position = UDim2.new(-1, 0, -0.3, 0)
    hl.BackgroundTransparency = 1; hl.Font = Enum.Font.Gotham
    hl.TextColor3 = Color3.fromRGB(80, 255, 120); hl.TextScaled = true
    hl.Text = "HP: " .. math.floor(hum.Health)

    local uc = RunService.Heartbeat:Connect(function()
        if not bb or not bb.Parent or not hum.Parent then return end
        hl.Text = "HP: " .. math.floor(hum.Health)
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
            local isPC = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character == v then isPC = true; break end
            end
            if isBoss and ST.ESP_Boss then
                makeESPTag(v, Color3.fromRGB(255, 120, 0))
            elseif not isBoss and not isPC and ST.ESP_Mob then
                makeESPTag(v, Color3.fromRGB(160, 50, 255))
            elseif isPC and ST.ESP_Player then
                makeESPTag(v, Color3.fromRGB(255, 50, 50))
            end
        end)
    end
end

-- ============================================================
-- INTERFACE GRÁFICA (UI) - VOID.LAZY v4.0 (MOBILE SMOOTH & LERP)
-- ============================================================
local SG
pcall(function() SG = game:GetService("CoreGui"):FindFirstChild("VOID_LAZY") end)
if SG then SG:Destroy() end

SG = Instance.new("ScreenGui")
SG.Name = "VOID_LAZY"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 9999
SG.IgnoreGuiInset = true

local parentOk = false
pcall(function() SG.Parent = game:GetService("CoreGui"); parentOk = true end)
if not parentOk then
    pcall(function() SG.Parent = LP.PlayerGui; parentOk = true end)
end
if not parentOk then return end

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

-- INTRODUÇÃO VISUAL
local Intro = Instance.new("Frame", SG)
Intro.Size = UDim2.new(1, 0, 1, 0)
Intro.BackgroundColor3 = Color3.fromRGB(4, 3, 10)
Intro.BorderSizePixel = 0
Intro.ZIndex = 500

local WFrame = Instance.new("Frame", Intro)
WFrame.Size = UDim2.new(0.85, 0, 0.25, 0)
WFrame.Position = UDim2.new(0.075, 0, 0.2, 0)
WFrame.BackgroundTransparency = 1
WFrame.ZIndex = 501

local L1 = Instance.new("TextLabel", WFrame)
L1.Size = UDim2.new(1, 0, 0.4, 0)
L1.BackgroundTransparency = 1
L1.Font = Enum.Font.GothamMedium
L1.TextScaled = true
L1.TextColor3 = Color3.fromRGB(200, 190, 255)
L1.Text = ""
L1.ZIndex = 502

local L2 = Instance.new("TextLabel", WFrame)
L2.Size = UDim2.new(1, 0, 0.6, 0)
L2.Position = UDim2.new(0, 0, 0.4, 0)
L2.BackgroundTransparency = 1
L2.Font = Enum.Font.GothamBlack
L2.TextScaled = true
L2.TextColor3 = T.AccBrt
L2.Text = ""
L2.ZIndex = 502

-- FRAME DE SENHA COM LOGIN REQUISITADO ("leyzepidao")
local PF = Instance.new("Frame", Intro)
PF.Size = UDim2.new(0.82, 0, 0.32, 0)
PF.Position = UDim2.new(0.09, 0, 0.52, 0)
PF.BackgroundColor3 = T.PanelDk
PF.BackgroundTransparency = 1
PF.BorderSizePixel = 0
PF.ZIndex = 501
Instance.new("UICorner", PF).CornerRadius = UDim.new(0, 14)
local PFStroke = Instance.new("UIStroke", PF)
PFStroke.Color = T.Acc; PFStroke.Thickness = 1.5; PFStroke.Transparency = 1

local PFTit = Instance.new("TextLabel", PF)
PFTit.Size = UDim2.new(1, 0, 0.25, 0)
PFTit.BackgroundTransparency = 1
PFTit.TextColor3 = T.Txt
PFTit.Font = Enum.Font.GothamBold
PFTit.TextScaled = true
PFTit.Text = "🔐  INSIRA A SENHA DE ACESSO"
PFTit.TextTransparency = 1
PFTit.ZIndex = 502

local PFInp = Instance.new("TextBox", PF)
PFInp.Size = UDim2.new(0.82, 0, 0.25, 0)
PFInp.Position = UDim2.new(0.09, 0, 0.32, 0)
PFInp.BackgroundColor3 = Color3.fromRGB(6, 4, 15)
PFInp.BorderSizePixel = 0
PFInp.Font = Enum.Font.GothamBold
PFInp.TextColor3 = T.AccBrt
PFInp.PlaceholderColor3 = T.TxtDim
PFInp.TextScaled = true
PFInp.PlaceholderText = "Senha (leyzepidao)..."
PFInp.Text = ""
PFInp.TextTransparency = 1
PFInp.ZIndex = 502
Instance.new("UICorner", PFInp).CornerRadius = UDim.new(0, 8)

local PFBtn = Instance.new("TextButton", PF)
PFBtn.Size = UDim2.new(0.5, 0, 0.23, 0)
PFBtn.Position = UDim2.new(0.25, 0, 0.67, 0)
PFBtn.BackgroundColor3 = T.Acc
PFBtn.BackgroundTransparency = 1
PFBtn.BorderSizePixel = 0
PFBtn.Font = Enum.Font.GothamBold
PFBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PFBtn.TextScaled = true
PFBtn.Text = "✦ ENTRAR ✦"
PFBtn.TextTransparency = 1
PFBtn.ZIndex = 502
Instance.new("UICorner", PFBtn).CornerRadius = UDim.new(0, 8)

local PFErr = Instance.new("TextLabel", PF)
PFErr.Size = UDim2.new(1, 0, 0.15, 0)
PFErr.Position = UDim2.new(0, 0, 0.9, 0)
PFErr.BackgroundTransparency = 1
PFErr.TextColor3 = T.Danger
PFErr.Font = Enum.Font.Gotham
PFErr.TextScaled = true
PFErr.Text = ""
PFErr.ZIndex = 502

-- ANIMAÇÃO DE TEXTO DA INTRO
task.spawn(function()
    task.wait(0.2)
    local t1 = "Bem-vindo a"
    for i = 1, #t1 do
        L1.Text = t1:sub(1, i)
        task.wait(0.05)
    end
    task.wait(0.1)
    local t2 = "VOID.LAZY"
    for i = 1, #t2 do
        L2.Text = t2:sub(1, i)
        task.wait(0.08)
    end
    task.wait(0.3)
    
    PF.BackgroundTransparency = 0
    PFStroke.Transparency = 0
    tw(PFTit, {TextTransparency = 0}, 0.4)
    tw(PFInp, {TextTransparency = 0, BackgroundTransparency = 0}, 0.4)
    tw(PFBtn, {TextTransparency = 0, BackgroundTransparency = 0}, 0.4)
end)

local buildMainUI

local function validatePW()
    local val = PFInp.Text:gsub("%s+", ""):lower()
    if val == "leyzepidao" then
        PFErr.TextColor3 = T.Success
        PFErr.Text = "✓ Acesso Autorizado!"
        task.wait(0.6)
        tw(Intro, {BackgroundTransparency = 1}, 0.5)
        for _, ch in ipairs(Intro:GetDescendants()) do
            pcall(function()
                if ch:IsA("GuiObject") then tw(ch, {BackgroundTransparency = 1}, 0.3) end
                if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then tw(ch, {TextTransparency = 1}, 0.3) end
            end)
        end
        task.wait(0.6)
        pcall(function() Intro:Destroy() end)
        buildMainUI()
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
-- INTERFACE PRINCIPAL (UI MOBILE PROFISSIONAL COM LERP E SUAVIZAÇÃO)
-- ============================================================
buildMainUI = function()
    local VP = getCam() and getCam().ViewportSize or Vector2.new(800, 600)
    local MF = Instance.new("Frame", SG)
    MF.Name = "VoidMain"
    MF.BackgroundColor3 = T.BG
    MF.BorderSizePixel = 0
    MF.ClipsDescendants = true

    local FW = math.min(VP.X * 0.94, 420)
    local FH = 580
    MF.Size = UDim2.new(0, FW, 0, FH)
    MF.Position = UDim2.new(0.5, -FW / 2, -1, 0)

    Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 16)
    local MFS = Instance.new("UIStroke", MF)
    MFS.Color = T.Border; MFS.Thickness = 1.5

    tw(MF, {Position = UDim2.new(0.5, -FW / 2, 0.03, 0)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Header da UI
    local HDR = Instance.new("Frame", MF)
    HDR.Size = UDim2.new(1, 0, 0, 50)
    HDR.BackgroundColor3 = T.AccDim
    HDR.BorderSizePixel = 0
    Instance.new("UICorner", HDR).CornerRadius = UDim.new(0, 16)

    local htl = Instance.new("TextLabel", HDR)
    htl.Size = UDim2.new(0.65, 0, 1, 0); htl.Position = UDim2.new(0, 14, 0, 0)
    htl.BackgroundTransparency = 1; htl.Font = Enum.Font.GothamBlack
    htl.TextScaled = true; htl.TextXAlignment = Enum.TextXAlignment.Left
    htl.TextColor3 = Color3.fromRGB(255, 255, 255)
    htl.Text = "⬡ VOID.LAZY // SLAYERS 2"

    local function hBtn(icon, xoff, bg)
        local b = Instance.new("TextButton", HDR)
        b.Size = UDim2.new(0, 28, 0, 28); b.Position = UDim2.new(1, xoff, 0.5, -14)
        b.BackgroundColor3 = bg; b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold; b.TextScaled = true
        b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Text = icon
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end
    local CloseBtn = hBtn("✕", -36, Color3.fromRGB(180, 30, 30))
    local MinBtn   = hBtn("─", -70, Color3.fromRGB(70, 70, 0))

    -- Barra de Abas (Tabs)
    local TBar = Instance.new("Frame", MF)
    TBar.Size = UDim2.new(1, 0, 0, 38); TBar.Position = UDim2.new(0, 0, 0, 50)
    TBar.BackgroundColor3 = T.PanelDk; TBar.BorderSizePixel = 0
    local tbL = Instance.new("UIListLayout", TBar)
    tbL.FillDirection = Enum.FillDirection.Horizontal
    tbL.SortOrder = Enum.SortOrder.LayoutOrder
    tbL.Padding = UDim.new(0, 4)

    local CA = Instance.new("Frame", MF)
    CA.Size = UDim2.new(1, 0, 1, -88); CA.Position = UDim2.new(0, 0, 0, 88)
    CA.BackgroundTransparency = 1; CA.ClipsDescendants = true

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
        b.BorderSizePixel = 0; b.LayoutOrder = i
        b.Font = Enum.Font.GothamBold; b.TextScaled = true
        b.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or T.TxtDim
        b.Text = td.I .. " " .. td.N
        tBtns[td.N] = b

        local sf = Instance.new("ScrollingFrame", CA)
        sf.Size = UDim2.new(1, 0, 1, 0); sf.BackgroundTransparency = 1
        sf.ScrollBarThickness = 3; sf.ScrollBarImageColor3 = T.AccDim
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Visible = (i == 1); sf.BorderSizePixel = 0
        local sfl = Instance.new("UIListLayout", sf)
        sfl.SortOrder = Enum.SortOrder.LayoutOrder; sfl.Padding = UDim.new(0, 6)
        local sfp = Instance.new("UIPadding", sf)
        sfp.PaddingLeft = UDim.new(0, 10); sfp.PaddingRight = UDim.new(0, 10); sfp.PaddingTop = UDim.new(0, 8)
        frames[td.N] = sf

        b.MouseButton1Click:Connect(function() switchTab(td.N) end)
    end
    curTab = "Farm"

    -- HELPERS DE CRIAÇÃO DE ELEMENTOS UI
    local function mkSec(p, txt, ord)
        local f = Instance.new("Frame", p); f.Size = UDim2.new(1, 0, 0, 24)
        f.BackgroundColor3 = Color3.fromRGB(22, 10, 48); f.BorderSizePixel = 0; f.LayoutOrder = ord or 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -12, 1, 0); l.Position = UDim2.new(0, 12, 0, 0)
        l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamBold; l.TextScaled = true
        l.TextColor3 = T.AccBrt; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = txt
        return f
    end

    local function mkToggle(p, lbl, key, ord, cb)
        local row = Instance.new("Frame", p); row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = T.Panel; row.BorderSizePixel = 0; row.LayoutOrder = ord or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local tl = Instance.new("TextLabel", row); tl.Size = UDim2.new(0.7, 0, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1; tl.Font = Enum.Font.Gotham; tl.TextScaled = true
        tl.TextColor3 = T.Txt; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = lbl
        local tbg = Instance.new("Frame", row); tbg.Size = UDim2.new(0, 44, 0, 22); tbg.Position = UDim2.new(1, -52, 0.5, -11)
        tbg.BackgroundColor3 = ST[key] and T.On or T.Off; tbg.BorderSizePixel = 0
        Instance.new("UICorner", tbg).CornerRadius = UDim.new(1, 0)
        local tk = Instance.new("Frame", tbg); tk.Size = UDim2.new(0, 18, 0, 18)
        tk.Position = ST[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        tk.BackgroundColor3 = Color3.fromRGB(255, 255, 255); tk.BorderSizePixel = 0
        Instance.new("UICorner", tk).CornerRadius = UDim.new(1, 0)
        local hit = Instance.new("TextButton", row); hit.Size = UDim2.new(1, 0, 1, 0)
        hit.BackgroundTransparency = 1; hit.Text = ""

        hit.MouseButton1Click:Connect(function()
            ST[key] = not ST[key]
            tw(tbg, {BackgroundColor3 = ST[key] and T.On or T.Off}, 0.2)
            tw(tk, {Position = ST[key] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
            if cb then cb(ST[key]) end
        end)
        return row
    end

    local function mkSlider(p, lbl, vmin, vmax, key, ord, cb)
        local row = Instance.new("Frame", p); row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundColor3 = T.Panel; row.BorderSizePixel = 0; row.LayoutOrder = ord or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local tl = Instance.new("TextLabel", row); tl.Size = UDim2.new(0.6, 0, 0.45, 0); tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1; tl.Font = Enum.Font.Gotham; tl.TextScaled = true
        tl.TextColor3 = T.Txt; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = lbl
        local vl = Instance.new("TextLabel", row); vl.Size = Instance.new("TextLabel", row).Size
        vl.Size = UDim2.new(0.3, 0, 0.4, 0); vl.Position = UDim2.new(0.68, 0, 0.05, 0)
        vl.BackgroundTransparency = 1; vl.Font = Enum.Font.GothamBold; vl.TextScaled = true
        vl.TextColor3 = T.AccBrt; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Text = tostring(ST[key])

        local sbg = Instance.new("Frame", row); sbg.Size = UDim2.new(0.88, 0, 0, 5); sbg.Position = UDim2.new(0.06, 0, 0.75, 0)
        sbg.BackgroundColor3 = Color3.fromRGB(25, 16, 50); sbg.BorderSizePixel = 0
        Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
        local pct = (ST[key] - vmin) / (vmax - vmin)
        local sf = Instance.new("Frame", sbg); sf.Size = UDim2.new(pct, 0, 1, 0)
        sf.BackgroundColor3 = T.AccBrt; sf.BorderSizePixel = 0
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
        local wrap = Instance.new("Frame", p); wrap.Size = UDim2.new(1, 0, 0, 38)
        wrap.BackgroundColor3 = T.Panel; wrap.BorderSizePixel = 0; wrap.LayoutOrder = ord or 0
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)
        local tl = Instance.new("TextLabel", wrap); tl.Size = UDim2.new(0.42, 0, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0)
        tl.BackgroundTransparency = 1; tl.Font = Enum.Font.Gotham; tl.TextScaled = true
        tl.TextColor3 = T.Txt; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = lbl

        local db = Instance.new("TextButton", wrap); db.Size = UDim2.new(0.52, 0, 0.72, 0); db.Position = UDim2.new(0.45, 0, 0.14, 0)
        db.BackgroundColor3 = Color3.fromRGB(22, 14, 48); db.BorderSizePixel = 0
        db.Font = Enum.Font.GothamBold; db.TextScaled = true; db.TextColor3 = T.AccBrt
        db.Text = ST[key] or opts[1]
        Instance.new("UICorner", db).CornerRadius = UDim.new(0, 6)

        local DL = Instance.new("Frame", SG); DL.BackgroundColor3 = Color3.fromRGB(12, 8, 30)
        DL.BorderSizePixel = 0; DL.Visible = false; DL.ZIndex = 6000
        Instance.new("UICorner", DL).CornerRadius = UDim.new(0, 8)
        local dll = Instance.new("UIListLayout", DL); dll.SortOrder = Enum.SortOrder.LayoutOrder
        local IH = 26
        for j, opt in ipairs(opts) do
            local ob = Instance.new("TextButton", DL); ob.Size = UDim2.new(1, 0, 0, IH)
            ob.BackgroundColor3 = Color3.fromRGB(12, 8, 30); ob.BorderSizePixel = 0
            ob.Font = Enum.Font.Gotham; ob.TextScaled = true; ob.TextColor3 = T.Txt
            ob.Text = opt; ob.ZIndex = 6001; ob.LayoutOrder = j
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
        local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, 0, 0, 36)
        b.BackgroundColor3 = T.Btn; b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold
        b.TextScaled = true; b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Text = txt; b.LayoutOrder = ord or 0
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
            local nf = Instance.new("Frame", SG); nf.Size = UDim2.new(0, 275, 0, 44)
            nf.Position = UDim2.new(0.5, -137, 1, 10)
            nf.BackgroundColor3 = T.PanelDk; nf.BorderSizePixel = 0; nf.ZIndex = 9000
            Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 10)
            local ns = Instance.new("UIStroke", nf); ns.Color = color; ns.Thickness = 1.5
            local nl = Instance.new("TextLabel", nf); nl.Size = UDim2.new(1, -10, 1, 0); nl.Position = UDim2.new(0, 5, 0, 0)
            nl.BackgroundTransparency = 1; nl.Font = Enum.Font.GothamBold; nl.TextScaled = true
            nl.TextColor3 = color; nl.ZIndex = 9001; nl.Text = msg
            tw(nf, {Position = UDim2.new(0.5, -137, 1, -55)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(dur)
            tw(nf, {Position = UDim2.new(0.5, -137, 1, 10)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.35); pcall(function() nf:Destroy() end)
        end)
    end
    ST.Notify = notify

    -- ────────────────────────────────────────────────────────
    -- ABA 1: FARM
    -- ────────────────────────────────────────────────────────
    local FT = frames["Farm"]
    mkSec(FT, "⚔  AUTO FARM AVANÇADO", 1)
    mkDrop(FT, "Mob Alvo", MOBS, "TargetMob", 2)
    mkToggle(FT, "Auto Farm (Ativo)", "AutoFarm", 3, function(on) if on then loopFarm(); loopSkills() end end)
    mkToggle(FT, "Juntar Todos os Mobs (Mob Stack)", "MobStack", 4)
    mkToggle(FT, "Congelar Mob Alvo", "FreezeTarget", 5)
    
    mkSec(FT, "🛡  SEGURANÇA & POSICIONAMENTO", 6)
    mkDrop(FT, "Modo de Altura / Posição", {"Abaixo do Chão", "Por Cima (Seguro)", "Atrás/Lado"}, "HeightMode", 7)
    mkSlider(FT, "Altura do Voo / Posição", 5, 30, "HeightOffset", 8)
    mkToggle(FT, "Hitbox Expandida (Longo Alcance)", "HitboxExp", 9)

    mkSec(FT, "✦  MASTERY & MISSÕES", 10)
    mkToggle(FT, "Auto Mastery (Espada/Soco)", "AutoMastery", 11, function(on) if on then loopMastery() end end)
    mkToggle(FT, "Auto Quest (Missões Automáticas)", "AutoQuest", 12, function(on) if on then loopQuest() end end)
    mkToggle(FT, "Auto Habilidades / Respiração", "AutoSkills", 13)

    -- ────────────────────────────────────────────────────────
    -- ABA 2: COMBAT
    -- ────────────────────────────────────────────────────────
    local CT = frames["Combat"]
    mkSec(CT, "💀  AUTO BOSS & DUNGEONS", 1)
    local bnames = {}
    for _, b in ipairs(BOSSES) do table.insert(bnames, b.N) end
    mkDrop(CT, "Boss Alvo", bnames, "TargetBoss", 2)
    mkToggle(CT, "Auto Boss Farm", "AutoBoss", 3, function(on) if on then loopBoss() end end)
    mkToggle(CT, "Auto Dungeon (Ouwigahara)", "AutoDungeon", 4, function(on)
        if on then
            task.spawn(function()
                while ST.AutoDungeon do
                    pcall(function()
                        if RS then
                            for _, rfn in ipairs({"Events", "Remotes", "RE"}) do
                                local rf = RS:FindFirstChild(rfn)
                                if rf then
                                    for _, ch in ipairs(rf:GetDescendants()) do
                                        if ch:IsA("RemoteEvent") and (ch.Name:lower():find("dungeon") or ch.Name:lower():find("ouw")) then
                                            ch:FireServer()
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(6)
                end
            end)
        end
    end)
    mkBtn(CT, "📍 Teleportar para o Boss", 5, function()
        local t = findMob(ST.TargetBoss)
        if t then
            local r = t:FindFirstChild("HumanoidRootPart") or t.PrimaryPart
            if r and getHRP() then getHRP().CFrame = r.CFrame + Vector3.new(0, 10, 0) end
            notify("💀 TP → " .. ST.TargetBoss, T.Warn)
        else notify("Boss não encontrado", T.Danger) end
    end)

    -- ────────────────────────────────────────────────────────
    -- ABA 3: PLAYER
    -- ────────────────────────────────────────────────────────
    local PT = frames["Player"]
    mkSec(PT, "⚡  MOVIMENTO & UTILITÁRIOS", 1)
    mkToggle(PT, "✈ Voar (Fly Mobile)", "Fly", 2, function(on) if on then enableFly() else disableFly() end end)
    mkSlider(PT, "Velocidade do Fly", 20, 250, "FlySpeedVal", 3)
    mkToggle(PT, "⚡ Speed Hack", "Speed", 4, function(on) setSpeed(on and ST.SpeedVal or 16) end)
    mkSlider(PT, "Velocidade de Corrida", 16, 300, "SpeedVal", 5, function(v) if ST.Speed then setSpeed(v) end end)
    mkToggle(PT, "🦘 Pulo Infinito", "InfiniteJump", 6)
    mkToggle(PT, "🔮 No Clip (Atravessar Paredes)", "NoClip", 7)
    
    mkSec(PT, "🎣  PESCA E SORTE DE CLAN", 8)
    mkToggle(PT, "Auto Pesca Automática", "AutoFishing", 9, function(on) if on then loopFishing() end end)
    mkToggle(PT, "Auto Clan Spin (Rolar Clã)", "AutoClanSpin", 10, function(on) if on then loopClan() end end)
    mkToggle(PT, "Anti-Idle (Evita Kick por Inatividade)", "AntiIdle", 11)

    -- ────────────────────────────────────────────────────────
    -- ABA 4: ESP
    -- ────────────────────────────────────────────────────────
    local ET = frames["ESP"]
    mkSec(ET, "👁  VISUAL ESP", 1)
    mkToggle(ET, "ESP Mobs (Roxo)", "ESP_Mob", 2, function() pcall(refreshESP) end)
    mkToggle(ET, "ESP Bosses (Laranja)", "ESP_Boss", 3, function() pcall(refreshESP) end)
    mkToggle(ET, "ESP Jogadores (Vermelho)", "ESP_Player", 4, function() pcall(refreshESP) end)
    mkBtn(ET, "🔄 Atualizar ESP", 5, function() clearESP(); pcall(refreshESP) end)

    -- ────────────────────────────────────────────────────────
    -- ABA 5: TP
    -- ────────────────────────────────────────────────────────
    local TT = frames["TP"]
    mkSec(TT, "🌀  ZONAS DE SLAYERS 2", 1)
    for i, z in ipairs(ZONES) do
        local zc = z
        mkBtn(TT, "📍 " .. z, i + 1, function()
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find(zc:sub(1, 4):lower()) then
                    if getHRP() then getHRP().CFrame = obj.CFrame + Vector3.new(0, 10, 0) end
                    notify("🌀 TP → " .. zc, T.AccBrt)
                    return
                end
            end
            notify("Zona rápida não localizada", T.Warn)
        end)
    end

    -- ────────────────────────────────────────────────────────
    -- ABA 6: MISC
    -- ────────────────────────────────────────────────────────
    local MT = frames["Misc"]
    mkSec(MT, "⚙  OPÇÕES DO SISTEMA", 1)
    mkToggle(MT, "Modo Anti-Detecção Máximo", "AntiDetect", 2, function(on) AD.on = on end)
    mkBtn(MT, "♻ Recarregar Personagem", 3, function() LP:LoadCharacter() end)
    mkBtn(MT, "🌐 Rejoin Servidor", 4, function() pcall(function() TS:Teleport(game.PlaceId, LP) end) end)
    mkBtn(MT, "🌄 FPS Boost (Leveza no Jogo)", 5, function()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in ipairs(WS:GetDescendants()) do if v:IsA("BasePart") then v.CastShadow = false end end
        end)
        notify("✓ FPS Boost Aplicado", T.Success)
    end)

    -- Draggable para Mobile
    local drag, dStart, dOrig = false, nil, nil
    HDR.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dStart = i.Position; dOrig = MF.Position
        end
    end)
    HDR.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - dStart
            MF.Position = UDim2.new(dOrig.X.Scale, dOrig.X.Offset + d.X, dOrig.Y.Scale, dOrig.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)

    local minned = false
    MinBtn.MouseButton1Click:Connect(function()
        minned = not minned
        tw(MF, {Size = UDim2.new(0, FW, 0, minned and 50 or FH)}, 0.3)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        tw(MF, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.35)
        for _, c in ipairs(ST.Connections) do pcall(function() c:Disconnect() end) end
        clearESP()
        pcall(function() SG:Destroy() end)
    end)

    switchTab("Farm")
    notify("✦ VOID.LAZY v4.0 Carregado com Sucesso!", T.AccBrt, 4)
end

end)

if not OK then
    print("[VOID.LAZY Error]: " .. tostring(ERR))
end
