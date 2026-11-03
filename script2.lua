-- ============================================================
--  ██╗   ██╗ ██████╗ ██╗██████╗    ██╗      █████╗ ███████╗██╗   ██╗
--  ██║   ██║██╔═══██╗██║██╔══██╗   ██║     ██╔══██╗╚════██║╚██╗ ██╔╝
--  ██║   ██║██║   ██║██║██║  ██║   ██║     ███████║    ██╔╝ ╚████╔╝
--  ╚██╗ ██╔╝██║   ██║██║██║  ██║   ██║     ██╔══██║   ██╔╝   ╚██╔╝
--   ╚████╔╝ ╚██████╔╝██║██████╔╝   ███████╗██║  ██║   ██║     ██║
--    ╚═══╝   ╚═════╝ ╚═╝╚═════╝    ╚══════╝╚═╝  ╚═╝   ╚═╝     ╚═╝
--
--  VOID.LAZY | Slayers 2 Script | v3.0 MOBILE EDITION
--  Compatível com: Delta Executor (Mobile/Android/iOS)
--  Jogo: Slayers 2 (Project Slayers 2) — Ouw Productions
--  Senha: leyzepidao
-- ============================================================

-- ============================================================
-- [1] SERVICES & CORE REFERENCES
-- ============================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UIS            = game:GetService("UserInputService")
local RS             = game:GetService("ReplicatedStorage")
local VU             = game:GetService("VirtualUser")
local TS             = game:GetService("TeleportService")
local WS             = workspace

local LP             = Players.LocalPlayer
local Cam            = WS.CurrentCamera

-- ============================================================
-- [2] UTILITIES
-- ============================================================
local function rng(min, max)
    return min + math.random() * (max - min)
end

local function jitter(base, range)
    range = range or 0.05
    return base + (math.random() * 2 - 1) * range
end

local function safewait(t)
    task.wait(jitter(t, t * 0.15))
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpC3(c1, c2, t)
    return Color3.new(lerp(c1.R,c2.R,t), lerp(c1.G,c2.G,t), lerp(c1.B,c2.B,t))
end

local function tween(obj, props, dur, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, style, dir), props)
    t:Play()
    return t
end

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

-- ============================================================
-- [3] ANTI-DETECTION MODULE
-- ============================================================
local AD = {
    Active         = true,
    HumanizeTP     = true,
    MicroDrift     = true,
    RandomTiming   = true,
    MinDelay       = 0.08,
    MaxDelay       = 0.18,
}

function AD:Wait(base)
    if self.RandomTiming then
        task.wait(jitter(base or 0.12, 0.04))
    else
        task.wait(base or 0.1)
    end
end

function AD:Drift()
    if not self.MicroDrift then return end
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(
            (math.random()-0.5)*0.4,
            0,
            (math.random()-0.5)*0.4
        )
    end
end

function AD:SafeTP(target_pos)
    local hrp = getHRP()
    if not hrp then return end
    if self.HumanizeTP then
        local origin = hrp.Position
        local steps  = math.random(4, 7)
        for i = 1, steps do
            hrp.CFrame = CFrame.new(
                origin:Lerp(target_pos + Vector3.new(0, 3.5, 0), i / steps)
            )
            task.wait(0.04 + math.random() * 0.02)
        end
    else
        hrp.CFrame = CFrame.new(target_pos + Vector3.new(0, 3.5, 0))
    end
end

-- ============================================================
-- [4] GAME DATABASE — SLAYERS 2
-- ============================================================
local MOBS = {
    "Bandit",
    "Greater Demon",
    "Bear",
    "Mother Bear",
    "Demon",
    "Mushroom Demon",
    "Spider Demon",
    "Zagan Demon",
    "Frozen Demon",
    "Wind Demon",
    "Stone Golem",
    "Blood Demon",
    "Dungeon Demon",
}

local BOSSES = {
    {Name="Zuko",      Lvl=7,  Zone="Starter Village",  Drop="Cutlass (20%)"},
    {Name="Mother Bear",Lvl=18, Zone="Bear Area",        Drop="Bear Pelt"},
    {Name="Rengu",     Lvl=30, Zone="Mistfall Village",  Drop="Flame Katana (5%)"},
    {Name="Zentaro",   Lvl=28, Zone="Thunder Cliffs",    Drop="Thunder Katana (5%)"},
    {Name="Giyen",     Lvl=32, Zone="Bamboo Grove",      Drop="Water Katana (5%)"},
    {Name="Saneri",    Lvl=35, Zone="Iceveil Valley",    Drop="Wind Katana (5%)"},
    {Name="Shinora",   Lvl=38, Zone="Butterfly Estate",  Drop="Insect Katana (5%)"},
    {Name="Obari",     Lvl=36, Zone="Starter Cliffs",    Drop="Serpent Katana (5%)"},
    {Name="Gyorei",    Lvl=40, Zone="Stone Sanctuary",   Drop="Stone Katana (5%)"},
    {Name="Tengai",    Lvl=42, Zone="Iceveil Valley",    Drop="Sound Katana (5%)"},
}

local ZONES = {
    "Starter Village",
    "Bear Area",
    "Bamboo Grove",
    "Spider Forest",
    "Mistfall Village",
    "Butterfly Estate",
    "Stone Sanctuary",
    "Iceveil Valley",
    "Thunder Cliffs",
    "Ouwigahara Dungeon",
}

local BREATHING_STYLES = {
    "Thunder (S) — Zentaro",
    "Sound   (S) — Tengai",
    "Flame   (A) — Rengu",
    "Serpent (A) — Obari",
    "Insect  (A) — Shinora",
    "Stone   (A) — Gyorei",
    "Water   (A) — Urokodaki",
    "Wind    (B) — Saneri",
}

-- ============================================================
-- [5] STATE
-- ============================================================
local ST = {
    -- toggles
    AutoFarm        = false,
    AutoBoss        = false,
    AutoMastery     = false,
    AutoQuest       = false,
    AutoDungeon     = false,
    AutoFishing     = false,
    AutoClanSpin    = false,
    AutoSkills      = true,
    FreezeTarget    = true,
    AutoRespawn     = true,
    AntiIdle        = true,
    ESP_Mob         = false,
    ESP_Boss        = false,
    ESP_Player      = false,
    Fly             = false,
    Speed           = false,
    NoClip          = false,
    InfiniteJump    = false,
    AntiDetect      = true,

    -- config
    TargetMob       = "Greater Demon",
    TargetBoss      = "Zuko",
    MaxLevel        = 400,
    SpeedVal        = 60,
    FlySpeedVal     = 90,
    FarmStand       = "Acima",

    -- internal
    Connections     = {},
    ESPCache        = {},
    FlyGyro         = nil,
    FlyBody         = nil,
    NotifFn         = nil,
}

-- ============================================================
-- [6] CORE COMBAT / FARM HELPERS
-- ============================================================
local function findMob(name)
    local hrp = getHRP()
    if not hrp then return nil end

    local best, bestDist = nil, math.huge

    local function scan(parent)
        if not parent then return end
        for _, v in ipairs(parent:GetChildren()) do
            if v:IsA("Model") and v.Name:lower():find(name:lower()) then
                local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                local hum  = v:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < bestDist then
                        best, bestDist = v, d
                    end
                end
            end
            -- recurse one level
            for _, child in ipairs(v:GetChildren()) do
                if child:IsA("Model") and child.Name:lower():find(name:lower()) then
                    local root = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
                    local hum  = child:FindFirstChildOfClass("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local d = (hrp.Position - root.Position).Magnitude
                        if d < bestDist then
                            best, bestDist = child, d
                        end
                    end
                end
            end
        end
    end

    scan(WS)
    for _, folder in ipairs({"NPCFolder","Mobs","Enemies","NPCs","Entities","Map"}) do
        scan(WS:FindFirstChild(folder))
    end

    return best
end

local function freezeModel(model)
    if not model or not ST.FreezeTarget then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if hum  then hum.WalkSpeed = 0; hum.JumpPower = 0 end
    if root then root.AssemblyLinearVelocity = Vector3.zero end
end

local function fireAttack(target)
    if not target then return end
    local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not root then return end

    -- click detector
    local cd = target:FindFirstChildOfClass("ClickDetector")
    if cd then pcall(fireclickdetector, cd) end

    -- proximity prompts
    for _, pp in ipairs(target:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            pcall(fireproximityprompt, pp)
        end
    end

    -- equipped tool activate
    local char = getChar()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local act = tool:FindFirstChild("Activate")
            if act then pcall(function() act:Fire() end) end
        end
    end

    -- scan remotes
    for _, remoteFolderName in ipairs({"Events","Remotes","Functions","RE","RF"}) do
        local rf = RS:FindFirstChild(remoteFolderName)
        if rf then
            for _, child in ipairs(rf:GetDescendants()) do
                if child:IsA("RemoteEvent") then
                    local n = child.Name:lower()
                    if n:find("attack") or n:find("hit") or n:find("damage") or n:find("combat") then
                        pcall(function() child:FireServer(target, root.Position) end)
                    end
                end
            end
        end
    end
end

local function posNearTarget(target, variance)
    variance = variance or 1.5
    local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not root then return Vector3.zero end
    return root.Position + Vector3.new(
        (math.random()-0.5)*variance*2,
        3.5 + math.random()*0.5,
        (math.random()-0.5)*variance*2
    )
end

-- ============================================================
-- [7] AUTO FARM LOOPS
-- ============================================================
local function loopAutoFarm()
    task.spawn(function()
        while ST.AutoFarm do
            local char = getChar()
            local hum  = getHum()
            if not hum or hum.Health <= 0 then
                task.wait(3); goto continue
            end

            local target = findMob(ST.TargetMob)
            if not target then
                AD:Wait(1.5)
                goto continue
            end

            local tHum = target:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then goto continue end

            -- move to target
            local hrp = getHRP()
            if hrp then
                hrp.CFrame = CFrame.new(posNearTarget(target))
            end

            freezeModel(target)

            -- kill loop
            local iters = 0
            while ST.AutoFarm and tHum and tHum.Health > 0 do
                freezeModel(target)
                fireAttack(target)

                -- randomize position each N hits to avoid static detection
                iters = iters + 1
                if iters % math.random(4,8) == 0 then
                    local hrp2 = getHRP()
                    if hrp2 and target.Parent then
                        hrp2.CFrame = CFrame.new(posNearTarget(target, 2))
                    end
                end

                AD:Wait(rng(AD.MinDelay, AD.MaxDelay))
            end

            AD:Drift()
            ::continue::
            task.wait(0.05)
        end
    end)
end

local function loopAutoBoss()
    task.spawn(function()
        while ST.AutoBoss do
            local target = findMob(ST.TargetBoss)
            if not target then
                AD:Wait(rng(2, 4))
            else
                local tHum = target:FindFirstChildOfClass("Humanoid")
                if tHum and tHum.Health > 0 then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(posNearTarget(target, 2.5))
                    end
                    freezeModel(target)

                    while ST.AutoBoss and tHum and tHum.Health > 0 do
                        fireAttack(target)
                        freezeModel(target)

                        local hrp2 = getHRP()
                        if hrp2 and target.Parent then
                            hrp2.CFrame = CFrame.new(posNearTarget(target, 2))
                        end

                        AD:Wait(rng(0.1, 0.2))
                    end

                    -- wait boss respawn
                    task.wait(rng(4, 7))
                end
            end
            task.wait(0.1)
        end
    end)
end

local function loopAutoMastery()
    task.spawn(function()
        while ST.AutoMastery do
            local target = findMob(ST.TargetMob)
            if not target then AD:Wait(1) else
                local tHum = target:FindFirstChildOfClass("Humanoid")
                if tHum and tHum.Health > 0 then
                    local hrp = getHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(posNearTarget(target))
                    end
                    freezeModel(target)
                    while ST.AutoMastery and tHum and tHum.Health > 0 do
                        fireAttack(target)
                        freezeModel(target)
                        AD:Wait(rng(0.08, 0.15))
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function loopAutoSkills()
    task.spawn(function()
        while ST.AutoSkills and (ST.AutoFarm or ST.AutoBoss or ST.AutoMastery) do
            for _, rfName in ipairs({"Events","Remotes","RE"}) do
                local rf = RS:FindFirstChild(rfName)
                if rf then
                    for _, child in ipairs(rf:GetDescendants()) do
                        if child:IsA("RemoteEvent") then
                            local n = child.Name:lower()
                            if n:find("skill") or n:find("ability") or n:find("breath") or n:find("art") then
                                pcall(function() child:FireServer() end)
                            end
                        end
                    end
                end
            end
            task.wait(rng(0.4, 1.2))
        end
    end)
end

local function loopAutoQuest()
    task.spawn(function()
        local questNPCs = {"Krue","Tom","Quest","Crow","Muzan","Hunter"}
        while ST.AutoQuest do
            for _, nName in ipairs(questNPCs) do
                local npc = findMob(nName)
                if npc then
                    local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                    if root then
                        local hrp = getHRP()
                        if hrp then
                            hrp.CFrame = root.CFrame + Vector3.new(0,2,3)
                        end
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
            task.wait(rng(2, 4))
        end
    end)
end

local function loopAutoFishing()
    task.spawn(function()
        while ST.AutoFishing do
            for _, rfName in ipairs({"Events","Remotes","RE"}) do
                local rf = RS:FindFirstChild(rfName)
                if rf then
                    for _, child in ipairs(rf:GetDescendants()) do
                        if child:IsA("RemoteEvent") and child.Name:lower():find("fish") then
                            pcall(function() child:FireServer() end)
                        end
                    end
                end
            end
            local char = getChar()
            local rod = char and char:FindFirstChild("Fishing Rod")
            if rod then
                local act = rod:FindFirstChild("Activate")
                if act then pcall(function() act:Fire() end) end
            end
            task.wait(rng(3, 6))
        end
    end)
end

local function loopClanSpin()
    task.spawn(function()
        while ST.AutoClanSpin do
            for _, rfName in ipairs({"Events","Remotes","RE"}) do
                local rf = RS:FindFirstChild(rfName)
                if rf then
                    for _, child in ipairs(rf:GetDescendants()) do
                        if child:IsA("RemoteEvent") then
                            local n = child.Name:lower()
                            if n:find("clan") or n:find("spin") or n:find("roll") then
                                pcall(function() child:FireServer() end)
                            end
                        end
                    end
                end
            end
            task.wait(rng(0.8, 1.8))
        end
    end)
end

local function loopAutoDungeon()
    task.spawn(function()
        while ST.AutoDungeon do
            -- Ouwigahara entry
            for _, rfName in ipairs({"Events","Remotes","RE"}) do
                local rf = RS:FindFirstChild(rfName)
                if rf then
                    for _, child in ipairs(rf:GetDescendants()) do
                        if child:IsA("RemoteEvent") then
                            local n = child.Name:lower()
                            if n:find("dungeon") or n:find("ouw") or n:find("join") then
                                pcall(function() child:FireServer() end)
                            end
                        end
                    end
                end
            end
            -- farm dungeon mobs while inside
            if ST.AutoDungeon then
                loopAutoFarm()
            end
            task.wait(rng(5,10))
        end
    end)
end

-- ============================================================
-- [8] MOVEMENT SYSTEMS
-- ============================================================

-- FLY
local function enableFly()
    local char = getChar()
    local hrp  = getHRP()
    if not char or not hrp then return end

    if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end) end
    if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end) end

    local gyro    = Instance.new("BodyGyro", hrp)
    gyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    gyro.P         = 1e6
    gyro.D         = 50

    local vel      = Instance.new("BodyVelocity", hrp)
    vel.MaxForce   = Vector3.new(1e9,1e9,1e9)
    vel.Velocity   = Vector3.zero

    ST.FlyGyro = gyro
    ST.FlyBody = vel

    local conn = RunService.Heartbeat:Connect(function()
        if not ST.Fly or not hrp or not hrp.Parent then
            pcall(function() gyro:Destroy() end)
            pcall(function() vel:Destroy() end)
            ST.FlyGyro = nil
            ST.FlyBody = nil
            return
        end

        gyro.CFrame = Cam.CFrame

        -- derive move intent from character velocity on ground (mobile joystick)
        local rawVel = hrp.AssemblyLinearVelocity
        local fwd    = Cam.CFrame.LookVector
        local rgt    = Cam.CFrame.RightVector
        local up     = Vector3.new(0,1,0)

        -- Blend camera direction with raw XZ intent
        local hVel = Vector3.new(rawVel.X, 0, rawVel.Z)
        local speed = ST.FlySpeedVal

        if hVel.Magnitude > 1 then
            local dir = (fwd * -hVel.Z + rgt * hVel.X).Unit
            vel.Velocity = dir * speed
        else
            -- Slow drift stop
            vel.Velocity = vel.Velocity * 0.85
        end

        -- Up/Down via jump & crouch (mobile button simulation)
        -- Delta mobile exposes these
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            vel.Velocity = vel.Velocity + Vector3.new(0, speed * 0.5, 0)
        end
    end)
    table.insert(ST.Connections, conn)
end

local function disableFly()
    ST.Fly = false
    if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end); ST.FlyGyro = nil end
    if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end); ST.FlyBody = nil end
end

-- NO CLIP
local ncConn
local function setupNoClip()
    ncConn = RunService.Stepped:Connect(function()
        if not ST.NoClip then return end
        local char = LP.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
    table.insert(ST.Connections, ncConn)
end

-- INFINITE JUMP
local ijConn
local function setupInfJump()
    ijConn = UIS.JumpRequest:Connect(function()
        if ST.InfiniteJump then
            local hum = getHum()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    table.insert(ST.Connections, ijConn)
end

-- SET SPEED
local function setSpeed(v)
    local hum = getHum()
    if hum then hum.WalkSpeed = v end
end

-- ============================================================
-- [9] ESP MODULE
-- ============================================================
local ESP_UPDATE_RATE = 3  -- seconds

local function clearESP()
    for _, v in ipairs(ST.ESPCache) do
        pcall(function() v:Destroy() end)
    end
    ST.ESPCache = {}
end

local function createESPTag(model, color, isPlayer)
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    local hum  = model:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop    = true
    bb.Size           = UDim2.new(0, 6, 0, 6)
    bb.StudsOffset    = Vector3.new(0, 2.5, 0)
    bb.MaxDistance    = 300
    bb.Parent         = root

    local bg = Instance.new("Frame", bb)
    bg.Size                    = UDim2.new(1,0,1,0)
    bg.BackgroundColor3        = color
    bg.BackgroundTransparency  = 0.4
    bg.BorderSizePixel         = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,2)

    local nameL = Instance.new("TextLabel", bb)
    nameL.Size               = UDim2.new(3,0,0.5,0)
    nameL.Position           = UDim2.new(-1,0,-0.8,0)
    nameL.BackgroundTransparency = 1
    nameL.TextColor3         = color
    nameL.Font               = Enum.Font.GothamBold
    nameL.TextScaled         = true
    nameL.TextStrokeTransparency = 0.2
    nameL.Text               = isPlayer and ("👤 "..model.Name) or model.Name

    local hpL = Instance.new("TextLabel", bb)
    hpL.Size               = UDim2.new(3,0,0.45,0)
    hpL.Position           = UDim2.new(-1,0,-0.3,0)
    hpL.BackgroundTransparency = 1
    hpL.TextColor3         = Color3.fromRGB(80,255,120)
    hpL.Font               = Enum.Font.Gotham
    hpL.TextScaled         = true
    hpL.TextStrokeTransparency = 0.3
    hpL.Text               = "❤ "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)

    -- live HP update
    local updConn
    updConn = RunService.Heartbeat:Connect(function()
        if not bb or not bb.Parent then updConn:Disconnect(); return end
        if hum and hum.Parent then
            hpL.Text = "❤ "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
        end
    end)

    table.insert(ST.ESPCache, bb)
    table.insert(ST.ESPCache, updConn)
end

local function refreshESP()
    clearESP()

    if not ST.ESP_Mob and not ST.ESP_Boss and not ST.ESP_Player then return end

    local bossNames = {}
    for _, b in ipairs(BOSSES) do bossNames[b.Name:lower()] = true end

    for _, v in ipairs(WS:GetDescendants()) do
        if v:IsA("Model") and v ~= LP.Character then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local nameL = v.Name:lower()
                local isBoss = bossNames[nameL]

                if isBoss and ST.ESP_Boss then
                    createESPTag(v, Color3.fromRGB(255,100,30), false)
                elseif not isBoss and ST.ESP_Mob then
                    -- skip player chars
                    local isPlayer = false
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character == v then isPlayer = true; break end
                    end
                    if not isPlayer then
                        createESPTag(v, Color3.fromRGB(160,50,255), false)
                    end
                end
            end
        end
    end

    if ST.ESP_Player then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character then
                local hum = pl.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    createESPTag(pl.Character, Color3.fromRGB(255,60,60), true)
                end
            end
        end
    end
end

-- ESP periodic refresh
task.spawn(function()
    while true do
        if ST.ESP_Mob or ST.ESP_Boss or ST.ESP_Player then
            refreshESP()
        end
        task.wait(ESP_UPDATE_RATE)
    end
end)

-- ============================================================
-- [10] ANTI-IDLE
-- ============================================================
LP.Idled:Connect(function()
    if ST.AntiIdle then
        pcall(function()
            VU:Button2Down(Vector2.zero, Cam.CFrame)
            task.wait(0.5)
            VU:Button2Up(Vector2.zero, Cam.CFrame)
        end)
    end
end)

-- ============================================================
-- [11] CHARACTER REAPPLY ON DEATH
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if ST.Speed   then setSpeed(ST.SpeedVal) end
    if ST.Fly     then task.wait(0.5); enableFly() end
end)

-- ============================================================
-- [12] UI — THEME
-- ============================================================
local T = {
    BG         = Color3.fromRGB(9,   8,  20),
    Panel      = Color3.fromRGB(17,  14, 38),
    PanelDark  = Color3.fromRGB(12,  9,  26),
    Accent     = Color3.fromRGB(110,  0, 210),
    AccentBrt  = Color3.fromRGB(175,  60,255),
    AccentDim  = Color3.fromRGB(55,   0, 110),
    Text       = Color3.fromRGB(235, 230,255),
    TextDim    = Color3.fromRGB(140, 130,175),
    On         = Color3.fromRGB(90,   0, 190),
    Off        = Color3.fromRGB(35,  28, 60),
    Btn        = Color3.fromRGB(75,   0, 175),
    BtnHot     = Color3.fromRGB(120,  20,230),
    Border     = Color3.fromRGB(75,   0, 155),
    Danger     = Color3.fromRGB(215,  45, 45),
    Success    = Color3.fromRGB(45,  200, 90),
    Warning    = Color3.fromRGB(215, 175,  0),
}

-- ============================================================
-- [13] SCREEN GUI ROOT
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name            = "VOID_LAZY"
SG.ResetOnSpawn    = false
SG.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder    = 999
SG.IgnoreGuiInset  = true
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

-- ============================================================
-- [14] INTRO SCREEN
-- ============================================================
local Intro = Instance.new("Frame", SG)
Intro.Size                   = UDim2.new(1,0,1,0)
Intro.BackgroundColor3       = Color3.fromRGB(5,3,14)
Intro.BorderSizePixel        = 0
Intro.ZIndex                 = 200

local iGrad = Instance.new("UIGradient", Intro)
iGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(4, 0,12)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12,0,30)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(4, 0,12)),
})
iGrad.Rotation = 135

-- Floating particles
for i = 1, 25 do
    task.spawn(function()
        local p = Instance.new("Frame", Intro)
        local sz = math.random(2, 6)
        p.Size                   = UDim2.new(0,sz,0,sz)
        p.BackgroundColor3       = Color3.fromRGB(math.random(60,160), 0, math.random(180,255))
        p.BackgroundTransparency = math.random() * 0.4 + 0.1
        p.BorderSizePixel        = 0
        p.ZIndex                 = 201
        local pc = Instance.new("UICorner", p); pc.CornerRadius = UDim.new(1,0)

        local x  = math.random()
        local y  = math.random()
        local dy = rng(0.00008, 0.00025)
        local ph = math.random() * math.pi * 2

        while p and p.Parent and Intro and Intro.Parent do
            y = (y - dy) % 1
            p.Position = UDim2.new(x + math.sin(tick()*0.4 + ph)*0.015, 0, y, 0)
            p.BackgroundTransparency = 0.2 + math.abs(math.sin(tick()*0.25 + ph))*0.5
            task.wait(0.016)
        end
    end)
end

-- Welcome label container
local WCont = Instance.new("Frame", Intro)
WCont.Size                  = UDim2.new(0.85,0,0.28,0)
WCont.Position              = UDim2.new(0.075,0,0.15,0)
WCont.BackgroundTransparency = 1
WCont.ZIndex                = 202

local L1 = Instance.new("TextLabel", WCont)
L1.Size                     = UDim2.new(1,0,0.38,0)
L1.BackgroundTransparency   = 1
L1.Font                     = Enum.Font.GothamMedium
L1.TextScaled               = true
L1.TextColor3               = Color3.fromRGB(195,190,255)
L1.TextStrokeTransparency   = 0.5
L1.TextStrokeColor3         = T.Accent
L1.Text                     = ""
L1.ZIndex                   = 203

local L2 = Instance.new("TextLabel", WCont)
L2.Size                     = UDim2.new(1,0,0.62,0)
L2.Position                 = UDim2.new(0,0,0.38,0)
L2.BackgroundTransparency   = 1
L2.Font                     = Enum.Font.GothamBlack
L2.TextScaled               = true
L2.TextColor3               = T.AccentBrt
L2.TextStrokeTransparency   = 0.25
L2.TextStrokeColor3         = T.AccentDim
L2.Text                     = ""
L2.ZIndex                   = 203

-- Loading bar
local LBG = Instance.new("Frame", Intro)
LBG.Size                    = UDim2.new(0.65,0,0,5)
LBG.Position                = UDim2.new(0.175,0,0.5,0)
LBG.BackgroundColor3        = Color3.fromRGB(25,0,55)
LBG.BorderSizePixel         = 0
LBG.ZIndex                  = 202
LBG.Visible                 = false
Instance.new("UICorner", LBG).CornerRadius = UDim.new(1,0)

local LBar = Instance.new("Frame", LBG)
LBar.Size                   = UDim2.new(0,0,1,0)
LBar.BackgroundColor3       = T.AccentBrt
LBar.BorderSizePixel        = 0
LBar.ZIndex                 = 203
Instance.new("UICorner", LBar).CornerRadius = UDim.new(1,0)

local LStat = Instance.new("TextLabel", Intro)
LStat.Size                  = UDim2.new(0.65,0,0.045,0)
LStat.Position              = UDim2.new(0.175,0,0.52,0)
LStat.BackgroundTransparency = 1
LStat.TextColor3            = T.TextDim
LStat.Font                  = Enum.Font.Gotham
LStat.TextScaled            = true
LStat.ZIndex                = 202
LStat.Text                  = ""

-- Password Frame
local PF = Instance.new("Frame", Intro)
PF.Size                     = UDim2.new(0.78,0,0.38,0)
PF.Position                 = UDim2.new(0.11,0,0.56,0)
PF.BackgroundColor3         = T.PanelDark
PF.BackgroundTransparency   = 1
PF.BorderSizePixel          = 0
PF.ZIndex                   = 202
Instance.new("UICorner", PF).CornerRadius = UDim.new(0,14)
local PFStroke = Instance.new("UIStroke", PF)
PFStroke.Color       = T.Accent
PFStroke.Thickness   = 1.5
PFStroke.Transparency = 1

local PFTitle = Instance.new("TextLabel", PF)
PFTitle.Size               = UDim2.new(1,0,0.27,0)
PFTitle.BackgroundTransparency = 1
PFTitle.TextColor3         = T.Text
PFTitle.Font               = Enum.Font.GothamBold
PFTitle.TextScaled         = true
PFTitle.Text               = "🔐  VERIFICAÇÃO DE ACESSO"
PFTitle.TextTransparency   = 1
PFTitle.ZIndex             = 203

local PFInput = Instance.new("TextBox", PF)
PFInput.Size               = UDim2.new(0.82,0,0.26,0)
PFInput.Position           = UDim2.new(0.09,0,0.3,0)
PFInput.BackgroundColor3   = Color3.fromRGB(7,4,18)
PFInput.BorderSizePixel    = 0
PFInput.Font               = Enum.Font.GothamBold
PFInput.TextColor3         = T.AccentBrt
PFInput.PlaceholderColor3  = T.TextDim
PFInput.TextScaled         = true
PFInput.PlaceholderText    = "Digite a senha..."
PFInput.Text               = ""
PFInput.TextTransparency   = 1
PFInput.ClearTextOnFocus   = false
PFInput.ZIndex             = 203
Instance.new("UICorner", PFInput).CornerRadius = UDim.new(0,8)
local PFInpStroke = Instance.new("UIStroke", PFInput)
PFInpStroke.Color       = T.AccentDim
PFInpStroke.Thickness   = 1
PFInpStroke.Transparency = 1

local PFBtn = Instance.new("TextButton", PF)
PFBtn.Size               = UDim2.new(0.5,0,0.24,0)
PFBtn.Position           = UDim2.new(0.25,0,0.64,0)
PFBtn.BackgroundColor3   = T.Accent
PFBtn.BackgroundTransparency = 1
PFBtn.BorderSizePixel    = 0
PFBtn.Font               = Enum.Font.GothamBold
PFBtn.TextColor3         = Color3.fromRGB(255,255,255)
PFBtn.TextScaled         = true
PFBtn.Text               = "✦ ENTRAR ✦"
PFBtn.TextTransparency   = 1
PFBtn.ZIndex             = 203
Instance.new("UICorner", PFBtn).CornerRadius = UDim.new(0,9)

local PFErr = Instance.new("TextLabel", PF)
PFErr.Size               = UDim2.new(1,0,0.15,0)
PFErr.Position           = UDim2.new(0,0,0.9,0)
PFErr.BackgroundTransparency = 1
PFErr.TextColor3         = T.Danger
PFErr.Font               = Enum.Font.Gotham
PFErr.TextScaled         = true
PFErr.Text               = ""
PFErr.ZIndex             = 203

-- ============================================================
-- [15] INTRO ANIMATION SEQUENCE
-- ============================================================
local function typeWrite(lbl, txt, spd)
    spd = spd or 0.065
    lbl.Text = ""
    for i = 1, #txt do
        lbl.Text = txt:sub(1, i)
        task.wait(spd)
    end
end

local function fillBar(pct, dur)
    tween(LBar, {Size = UDim2.new(pct, 0, 1, 0)}, dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    task.wait(dur + 0.05)
end

task.spawn(function()
    task.wait(0.4)

    -- Line 1: "✦  Bem-vindo a  ✦"
    typeWrite(L1, "✦  Bem-vindo a  ✦", 0.055)
    task.wait(0.2)

    -- Line 2: "VOID.LAZY" character by character with flash
    local full = "VOID.LAZY"
    L2.Text = ""
    for i = 1, #full do
        L2.Text = full:sub(1, i)
        tween(L2, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.08)
        task.wait(0.12)
        tween(L2, {TextColor3 = T.AccentBrt}, 0.18)
        task.wait(0.02)
    end

    task.wait(0.35)

    -- Loading bar phase
    LBG.Visible  = true
    local steps = {
        {0.2,  0.35, "Carregando módulos..."},
        {0.45, 0.3,  "Inicializando anti-detecção..."},
        {0.7,  0.35, "Conectando ao servidor..."},
        {0.9,  0.25, "Preparando interface..."},
        {1.0,  0.2,  "Pronto. ✓"},
    }
    for _, s in ipairs(steps) do
        LStat.Text = s[3]
        fillBar(s[1], s[2])
        task.wait(0.05)
    end

    task.wait(0.3)
    LBG:Destroy()
    LStat:Destroy()

    -- Reveal password frame
    PF.BackgroundTransparency = 0
    PFStroke.Transparency     = 0

    local fadeIn_targets = {
        {PFTitle,     "TextTransparency",        0},
        {PFInput,     "TextTransparency",        0},
        {PFInput,     "BackgroundTransparency",  0},
        {PFInpStroke, "Transparency",            0},
        {PFBtn,       "BackgroundTransparency",  0},
        {PFBtn,       "TextTransparency",        0},
    }
    for _, ft in ipairs(fadeIn_targets) do
        tween(ft[1], {[ft[2]] = ft[3]}, 0.5)
    end

    -- Pulsing border
    task.spawn(function()
        while PF and PF.Parent do
            tween(PFInpStroke, {Color = T.AccentBrt}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.9)
            tween(PFInpStroke, {Color = T.AccentDim}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.9)
        end
    end)
end)

-- ============================================================
-- [16] PASSWORD VALIDATION
-- ============================================================
local CORRECT_PW = "leyzepidao"
local attempts   = 0

local function doFadeOutIntro()
    tween(Intro, {BackgroundTransparency = 1}, 0.7, Enum.EasingStyle.Quad)
    for _, child in ipairs(Intro:GetDescendants()) do
        if child:IsA("GuiObject") then
            local props = {}
            if child.BackgroundTransparency < 1 then props.BackgroundTransparency = 1 end
            pcall(function()
                if child.TextTransparency ~= nil then props.TextTransparency = 1 end
            end)
            if next(props) then tween(child, props, 0.4) end
        end
    end
    task.wait(0.8)
    Intro:Destroy()
end

local function validatePW()
    local inp = PFInput.Text:lower():gsub("%s","")
    if inp == CORRECT_PW then
        PFBtn.BackgroundColor3 = T.Success
        PFErr.TextColor3       = T.Success
        PFErr.Text             = "✓  Acesso concedido!"

        -- button bounce
        tween(PFBtn, {Size = UDim2.new(0.55,0,0.26,0), Position = UDim2.new(0.225,0,0.63,0)}, 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.wait(0.12)
        tween(PFBtn, {Size = UDim2.new(0.5,0,0.24,0), Position = UDim2.new(0.25,0,0.64,0)}, 0.15)
        task.wait(0.8)

        doFadeOutIntro()
        task.wait(0.1)
        buildMainUI()
    else
        attempts = attempts + 1
        PFErr.Text       = "✗  Senha incorreta! ("..attempts.."/3)"
        PFErr.TextColor3 = T.Danger

        -- shake
        local orig = PF.Position
        for i = 1, 7 do
            local off = (i%2==0) and 9 or -9
            tween(PF, {Position = UDim2.new(orig.X.Scale, off, orig.Y.Scale, 0)}, 0.04, Enum.EasingStyle.Sine)
            task.wait(0.045)
        end
        tween(PF, {Position = orig}, 0.1, Enum.EasingStyle.Bounce)

        tween(PFBtn, {BackgroundColor3 = T.Danger}, 0.1)
        task.wait(0.6)
        tween(PFBtn, {BackgroundColor3 = T.Accent}, 0.3)

        if attempts >= 3 then
            PFBtn.Active = false
            PFErr.Text   = "⏳  Muitas tentativas. Aguarde 10s..."
            task.wait(10)
            attempts     = 0
            PFBtn.Active = true
        end

        PFInput.Text = ""
    end
end

PFBtn.MouseButton1Click:Connect(validatePW)
PFInput.FocusLost:Connect(function(enter) if enter then validatePW() end end)

-- ============================================================
-- [17] MAIN UI
-- ============================================================
function buildMainUI()
    -- ── Main frame ──────────────────────────────────────────
    local VP  = Cam.ViewportSize
    local isMobile = VP.X < 860

    local MF = Instance.new("Frame", SG)
    MF.Name              = "VOID_Main"
    MF.BorderSizePixel   = 0
    MF.ClipsDescendants  = true

    if isMobile then
        MF.Size     = UDim2.new(0.93,0,0,590)
        MF.Position = UDim2.new(0.035,0,-1,0)
    else
        MF.Size     = UDim2.new(0,355,0,560)
        MF.Position = UDim2.new(0.5,-177,-1,0)
    end

    MF.BackgroundColor3  = T.BG
    Instance.new("UICorner", MF).CornerRadius = UDim.new(0,15)

    local MFStroke = Instance.new("UIStroke", MF)
    MFStroke.Color     = T.Border
    MFStroke.Thickness = 1.5

    -- slide in from top
    local targetPos = isMobile and UDim2.new(0.035,0,0.05,0) or UDim2.new(0.5,-177,0.06,0)
    tween(MF, {Position = targetPos}, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- border glow pulse
    task.spawn(function()
        while MF and MF.Parent do
            tween(MFStroke, {Color = T.AccentBrt}, 1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.6)
            tween(MFStroke, {Color = T.Border}, 1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.6)
        end
    end)

    -- ── Header ───────────────────────────────────────────────
    local HDR = Instance.new("Frame", MF)
    HDR.Size            = UDim2.new(1,0,0,50)
    HDR.BackgroundColor3 = T.AccentDim
    HDR.BorderSizePixel = 0
    local hdrC = Instance.new("UICorner", HDR); hdrC.CornerRadius = UDim.new(0,15)

    local hdrGrad = Instance.new("UIGradient", HDR)
    hdrGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(42,0, 95)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80,0,170)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(42,0, 95)),
    })

    -- fix round bottom corners on header
    local hdrFix = Instance.new("Frame", HDR)
    hdrFix.Size             = UDim2.new(1,0,0.55,0)
    hdrFix.Position         = UDim2.new(0,0,0.45,0)
    hdrFix.BackgroundColor3 = T.AccentDim
    hdrFix.BorderSizePixel  = 0

    local hdrTitle = Instance.new("TextLabel", HDR)
    hdrTitle.Size                  = UDim2.new(0.65,0,1,0)
    hdrTitle.Position              = UDim2.new(0,12,0,0)
    hdrTitle.BackgroundTransparency = 1
    hdrTitle.Font                  = Enum.Font.GothamBlack
    hdrTitle.TextScaled            = true
    hdrTitle.TextColor3            = Color3.fromRGB(255,255,255)
    hdrTitle.TextXAlignment        = Enum.TextXAlignment.Left
    hdrTitle.TextStrokeTransparency = 0.35
    hdrTitle.TextStrokeColor3      = T.AccentBrt
    hdrTitle.Text                  = "⬡ VOID.LAZY"

    local hdrSub = Instance.new("TextLabel", HDR)
    hdrSub.Size                   = UDim2.new(0.28,0,0.45,0)
    hdrSub.Position               = UDim2.new(0.69,0,0.3,0)
    hdrSub.BackgroundTransparency = 1
    hdrSub.Font                   = Enum.Font.GothamBold
    hdrSub.TextScaled             = true
    hdrSub.TextColor3             = T.TextDim
    hdrSub.TextXAlignment         = Enum.TextXAlignment.Right
    hdrSub.Text                   = "SLAYERS 2"

    -- Close & Min buttons
    local function mkHdrBtn(icon, xOff, bg)
        local b = Instance.new("TextButton", HDR)
        b.Size               = UDim2.new(0,27,0,27)
        b.Position           = UDim2.new(1,xOff,0.5,-13)
        b.BackgroundColor3   = bg
        b.BorderSizePixel    = 0
        b.Font               = Enum.Font.GothamBold
        b.TextScaled         = true
        b.TextColor3         = Color3.fromRGB(255,255,255)
        b.Text               = icon
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end

    local CloseBtn = mkHdrBtn("✕", -34, Color3.fromRGB(175,30,30))
    local MinBtn   = mkHdrBtn("─", -67, Color3.fromRGB(70,70,0))

    -- ── Tab bar ─────────────────────────────────────────────
    local TBar = Instance.new("Frame", MF)
    TBar.Size            = UDim2.new(1,0,0,36)
    TBar.Position        = UDim2.new(0,0,0,50)
    TBar.BackgroundColor3 = T.PanelDark
    TBar.BorderSizePixel = 0

    local TLayout = Instance.new("UIListLayout", TBar)
    TLayout.FillDirection = Enum.FillDirection.Horizontal
    TLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    TLayout.Padding       = UDim.new(0,3)

    local TBarPad = Instance.new("UIPadding", TBar)
    TBarPad.PaddingLeft   = UDim.new(0,4)
    TBarPad.PaddingRight  = UDim.new(0,4)
    TBarPad.PaddingTop    = UDim.new(0,4)
    TBarPad.PaddingBottom = UDim.new(0,4)

    -- ── Content area ────────────────────────────────────────
    local CA = Instance.new("Frame", MF)
    CA.Size               = UDim2.new(1,0,1,-86)
    CA.Position           = UDim2.new(0,0,0,86)
    CA.BackgroundTransparency = 1
    CA.ClipsDescendants   = true

    -- ── Tab system ──────────────────────────────────────────
    local TabDefs = {
        {N="Farm",   I="⚔"},
        {N="Boss",   I="💀"},
        {N="Player", I="⚡"},
        {N="ESP",    I="👁"},
        {N="TP",     I="🌀"},
        {N="Misc",   I="⚙"},
    }

    local frames  = {}
    local tabBtns = {}
    local curTab  = nil

    local function switchTab(name)
        if curTab == name then return end
        curTab = name
        for n, f in pairs(frames) do
            f.Visible = (n == name)
        end
        for n, b in pairs(tabBtns) do
            if n == name then
                tween(b, {BackgroundColor3 = T.Accent, TextColor3 = Color3.fromRGB(255,255,255)}, 0.18)
            else
                tween(b, {BackgroundColor3 = Color3.fromRGB(18,13,38), TextColor3 = T.TextDim}, 0.18)
            end
        end
    end

    local tabW = (1 - 0.015) / #TabDefs

    for i, td in ipairs(TabDefs) do
        -- button
        local b = Instance.new("TextButton", TBar)
        b.Size             = UDim2.new(tabW, 0, 1, 0)
        b.BackgroundColor3 = (i==1) and T.Accent or Color3.fromRGB(18,13,38)
        b.BorderSizePixel  = 0
        b.Font             = Enum.Font.GothamBold
        b.TextScaled       = true
        b.TextColor3       = (i==1) and Color3.fromRGB(255,255,255) or T.TextDim
        b.Text             = td.I.." "..td.N
        b.LayoutOrder      = i
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        tabBtns[td.N] = b

        -- content scroll frame
        local sf = Instance.new("ScrollingFrame", CA)
        sf.Size                 = UDim2.new(1,0,1,0)
        sf.BackgroundTransparency = 1
        sf.ScrollBarThickness   = 3
        sf.ScrollBarImageColor3 = T.AccentDim
        sf.CanvasSize           = UDim2.new(0,0,0,0)
        sf.AutomaticCanvasSize  = Enum.AutomaticSize.Y
        sf.Visible              = (i==1)
        sf.BorderSizePixel      = 0
        local sfLayout = Instance.new("UIListLayout", sf)
        sfLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        sfLayout.Padding    = UDim.new(0,4)
        local sfPad = Instance.new("UIPadding", sf)
        sfPad.PaddingLeft   = UDim.new(0,8)
        sfPad.PaddingRight  = UDim.new(0,8)
        sfPad.PaddingTop    = UDim.new(0,6)
        frames[td.N] = sf

        b.MouseButton1Click:Connect(function() switchTab(td.N) end)
    end
    curTab = "Farm"

    -- ── UI COMPONENT HELPERS ─────────────────────────────────

    local function mkSection(parent, text, order)
        local f = Instance.new("Frame", parent)
        f.Size             = UDim2.new(1,0,0,22)
        f.BackgroundColor3 = Color3.fromRGB(22,8,48)
        f.BorderSizePixel  = 0
        f.LayoutOrder      = order or 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
        local lbl = Instance.new("TextLabel", f)
        lbl.Size                   = UDim2.new(1,-12,1,0)
        lbl.Position               = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextScaled             = true
        lbl.TextColor3             = T.AccentBrt
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text                   = text
        return f
    end

    local function mkToggle(parent, label, key, order, cb)
        local row = Instance.new("Frame", parent)
        row.Size             = UDim2.new(1,0,0,36)
        row.BackgroundColor3 = T.Panel
        row.BorderSizePixel  = 0
        row.LayoutOrder      = order or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size                   = UDim2.new(0.7,0,1,0)
        lbl.Position               = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.Gotham
        lbl.TextScaled             = true
        lbl.TextColor3             = T.Text
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text                   = label

        local tBG = Instance.new("Frame", row)
        tBG.Size             = UDim2.new(0,44,0,22)
        tBG.Position         = UDim2.new(1,-52,0.5,-11)
        tBG.BackgroundColor3 = ST[key] and T.On or T.Off
        tBG.BorderSizePixel  = 0
        Instance.new("UICorner", tBG).CornerRadius = UDim.new(1,0)

        local tKnob = Instance.new("Frame", tBG)
        tKnob.Size             = UDim2.new(0,18,0,18)
        tKnob.Position         = ST[key] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        tKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        tKnob.BorderSizePixel  = 0
        Instance.new("UICorner", tKnob).CornerRadius = UDim.new(1,0)

        local hitbox = Instance.new("TextButton", row)
        hitbox.Size                 = UDim2.new(1,0,1,0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text                 = ""
        hitbox.ZIndex               = row.ZIndex + 2

        local function updateViz()
            tween(tBG,    {BackgroundColor3 = ST[key] and T.On or T.Off}, 0.2)
            tween(tKnob,  {Position = ST[key] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.2)
        end

        hitbox.MouseButton1Click:Connect(function()
            ST[key] = not ST[key]
            updateViz()
            if cb then cb(ST[key]) end
        end)

        return row
    end

    local function mkSlider(parent, label, vmin, vmax, key, order, cb)
        local row = Instance.new("Frame", parent)
        row.Size             = UDim2.new(1,0,0,52)
        row.BackgroundColor3 = T.Panel
        row.BorderSizePixel  = 0
        row.LayoutOrder      = order or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size                   = UDim2.new(0.62,0,0.46,0)
        lbl.Position               = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.Gotham
        lbl.TextScaled             = true
        lbl.TextColor3             = T.Text
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text                   = label

        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size                   = UDim2.new(0.3,0,0.4,0)
        valLbl.Position               = UDim2.new(0.68,0,0.05,0)
        valLbl.BackgroundTransparency = 1
        valLbl.Font                   = Enum.Font.GothamBold
        valLbl.TextScaled             = true
        valLbl.TextColor3             = T.AccentBrt
        valLbl.TextXAlignment         = Enum.TextXAlignment.Right
        valLbl.Text                   = tostring(ST[key])

        local sBG = Instance.new("Frame", row)
        sBG.Size             = UDim2.new(0.88,0,0,5)
        sBG.Position         = UDim2.new(0.06,0,0.76,0)
        sBG.BackgroundColor3 = Color3.fromRGB(28,18,52)
        sBG.BorderSizePixel  = 0
        Instance.new("UICorner", sBG).CornerRadius = UDim.new(1,0)

        local pct = (ST[key] - vmin) / (vmax - vmin)
        local sFill = Instance.new("Frame", sBG)
        sFill.Size             = UDim2.new(pct,0,1,0)
        sFill.BackgroundColor3 = T.AccentBrt
        sFill.BorderSizePixel  = 0
        Instance.new("UICorner", sFill).CornerRadius = UDim.new(1,0)

        local sKnob = Instance.new("Frame", sBG)
        sKnob.Size             = UDim2.new(0,14,0,14)
        sKnob.Position         = UDim2.new(pct,-7,0.5,-7)
        sKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        sKnob.BorderSizePixel  = 0
        Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1,0)

        local dragging = false

        local function applySlider(inputPos)
            local abs = sBG.AbsolutePosition
            local sz  = sBG.AbsoluteSize
            local rel = math.clamp((inputPos.X - abs.X) / sz.X, 0, 1)
            local val = math.floor(vmin + (vmax - vmin) * rel)
            ST[key]       = val
            valLbl.Text   = tostring(val)
            tween(sFill,  {Size     = UDim2.new(rel,0,1,0)},   0.05, Enum.EasingStyle.Linear)
            tween(sKnob,  {Position = UDim2.new(rel,-7,0.5,-7)}, 0.05, Enum.EasingStyle.Linear)
            if cb then cb(val) end
        end

        sBG.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or
               inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                applySlider(inp.Position)
            end
        end)
        sBG.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.Touch or
                             inp.UserInputType == Enum.UserInputType.MouseMovement) then
                applySlider(inp.Position)
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch or
               inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        return row
    end

    local function mkDropdown(parent, label, options, key, order, cb)
        local wrap = Instance.new("Frame", parent)
        wrap.Size             = UDim2.new(1,0,0,36)
        wrap.BackgroundColor3 = T.Panel
        wrap.BorderSizePixel  = 0
        wrap.LayoutOrder      = order or 0
        wrap.ClipsDescendants = false
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0,9)

        local lbl = Instance.new("TextLabel", wrap)
        lbl.Size                   = UDim2.new(0.44,0,1,0)
        lbl.Position               = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.Gotham
        lbl.TextScaled             = true
        lbl.TextColor3             = T.Text
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text                   = label

        local dBtn = Instance.new("TextButton", wrap)
        dBtn.Size             = UDim2.new(0.5,0,0.74,0)
        dBtn.Position         = UDim2.new(0.48,0,0.13,0)
        dBtn.BackgroundColor3 = Color3.fromRGB(22,14,48)
        dBtn.BorderSizePixel  = 0
        dBtn.Font             = Enum.Font.GothamBold
        dBtn.TextScaled       = true
        dBtn.TextColor3       = T.AccentBrt
        dBtn.Text             = ST[key] or options[1]
        Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0,7)
        local dStroke = Instance.new("UIStroke", dBtn)
        dStroke.Color     = T.AccentDim
        dStroke.Thickness = 1

        -- dropdown list (parented to SG to avoid clipping)
        local DL = Instance.new("Frame", SG)
        DL.BackgroundColor3 = Color3.fromRGB(14,8,32)
        DL.BorderSizePixel  = 0
        DL.Visible          = false
        DL.ZIndex           = 500
        Instance.new("UICorner", DL).CornerRadius = UDim.new(0,9)
        local dlStroke = Instance.new("UIStroke", DL)
        dlStroke.Color = T.Accent; dlStroke.Thickness = 1
        local dlLayout = Instance.new("UIListLayout", DL)
        dlLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local itemH = 26
        for j, opt in ipairs(options) do
            local ob = Instance.new("TextButton", DL)
            ob.Size             = UDim2.new(1,0,0,itemH)
            ob.BackgroundColor3 = Color3.fromRGB(14,8,32)
            ob.BorderSizePixel  = 0
            ob.Font             = Enum.Font.Gotham
            ob.TextScaled       = true
            ob.TextColor3       = T.Text
            ob.Text             = opt
            ob.ZIndex           = 501
            ob.LayoutOrder      = j
            ob.MouseButton1Click:Connect(function()
                ST[key] = opt
                dBtn.Text = opt
                DL.Visible = false
                if cb then cb(opt) end
            end)
            ob.MouseEnter:Connect(function() tween(ob,{BackgroundColor3=Color3.fromRGB(35,18,65)},0.1) end)
            ob.MouseLeave:Connect(function() tween(ob,{BackgroundColor3=Color3.fromRGB(14,8,32)},0.1) end)
        end

        DL.Size = UDim2.new(0,170,0,itemH*#options)

        local open = false
        dBtn.MouseButton1Click:Connect(function()
            open = not open
            if open then
                local ap = dBtn.AbsolutePosition
                local as = dBtn.AbsoluteSize
                DL.Position = UDim2.new(0,ap.X,0,ap.Y+as.Y+3)
                DL.Visible  = true
            else
                DL.Visible = false
            end
        end)

        return wrap
    end

    local function mkButton(parent, text, order, cb)
        local b = Instance.new("TextButton", parent)
        b.Size             = UDim2.new(1,0,0,33)
        b.BackgroundColor3 = T.Btn
        b.BorderSizePixel  = 0
        b.Font             = Enum.Font.GothamBold
        b.TextScaled       = true
        b.TextColor3       = Color3.fromRGB(255,255,255)
        b.Text             = text
        b.LayoutOrder      = order or 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)
        b.MouseButton1Click:Connect(function()
            tween(b,{BackgroundColor3=T.AccentBrt},0.08)
            task.wait(0.08)
            tween(b,{BackgroundColor3=T.Btn},0.2)
            if cb then cb() end
        end)
        b.MouseEnter:Connect(function() tween(b,{BackgroundColor3=T.BtnHot},0.15) end)
        b.MouseLeave:Connect(function() tween(b,{BackgroundColor3=T.Btn},0.15) end)
        return b
    end

    local function mkSpacer(parent, h, order)
        local s = Instance.new("Frame", parent)
        s.Size             = UDim2.new(1,0,0,h or 4)
        s.BackgroundTransparency = 1
        s.LayoutOrder      = order or 0
        return s
    end

    -- ── FARM TAB ─────────────────────────────────────────────
    local FT = frames["Farm"]
    mkSection(FT, "⚔  AUTO FARM", 1)
    mkDropdown(FT, "Mob Alvo", MOBS, "TargetMob", 2)
    mkToggle(FT, "Auto Farm Mobs", "AutoFarm", 3, function(on)
        if on then loopAutoFarm() end
        if on and ST.AutoSkills then loopAutoSkills() end
    end)
    mkToggle(FT, "Congelar Alvo", "FreezeTarget", 4)
    mkSpacer(FT, 2, 5)
    mkSection(FT, "✦  AUTO MASTERY", 6)
    mkToggle(FT, "Auto Mastery Farm", "AutoMastery", 7, function(on)
        if on then loopAutoMastery() end
    end)
    mkSection(FT, "📋  AUTO QUEST", 8)
    mkToggle(FT, "Auto Quest (NPCs)", "AutoQuest", 9, function(on)
        if on then loopAutoQuest() end
    end)
    mkSection(FT, "⚙  CONFIGURAÇÃO", 10)
    mkSlider(FT, "Nível Máximo", 1, 1000, "MaxLevel", 11)
    mkToggle(FT, "Auto Skills/Breathing", "AutoSkills", 12)
    mkToggle(FT, "Auto Respawn", "AutoRespawn", 13)
    mkToggle(FT, "Anti-Idle (anti-kick)", "AntiIdle", 14)

    -- ── BOSS TAB ─────────────────────────────────────────────
    local BT = frames["Boss"]
    mkSection(BT, "💀  AUTO BOSS FARM", 1)

    local bossNameList = {}
    for _, b in ipairs(BOSSES) do table.insert(bossNameList, b.Name) end
    mkDropdown(BT, "Boss Alvo", bossNameList, "TargetBoss", 2)

    mkToggle(BT, "Auto Boss Farm", "AutoBoss", 3, function(on)
        if on then loopAutoBoss() end
    end)
    mkToggle(BT, "Congelar Boss", "FreezeTarget", 4)

    -- Boss info card
    local bInfoF = Instance.new("Frame", BT)
    bInfoF.Size             = UDim2.new(1,0,0,85)
    bInfoF.BackgroundColor3 = Color3.fromRGB(18,10,38)
    bInfoF.BorderSizePixel  = 0
    bInfoF.LayoutOrder      = 5
    Instance.new("UICorner", bInfoF).CornerRadius = UDim.new(0,9)

    local bInfoLbl = Instance.new("TextLabel", bInfoF)
    bInfoLbl.Size                   = UDim2.new(1,-12,1,0)
    bInfoLbl.Position               = UDim2.new(0,6,0,0)
    bInfoLbl.BackgroundTransparency = 1
    bInfoLbl.Font                   = Enum.Font.Gotham
    bInfoLbl.TextScaled             = true
    bInfoLbl.TextWrapped            = true
    bInfoLbl.RichText               = true
    bInfoLbl.TextColor3             = T.TextDim
    bInfoLbl.TextXAlignment         = Enum.TextXAlignment.Left
    bInfoLbl.TextYAlignment         = Enum.TextYAlignment.Center

    local function refreshBossInfo()
        for _, b in ipairs(BOSSES) do
            if b.Name == ST.TargetBoss then
                bInfoLbl.Text = string.format(
                    '<font color="#aa55ff"><b>%s</b></font>  <font color="#666699">Lv.%d</font>\n<font color="#8855cc">Zona:</font> <font color="#ccaaff">%s</font>\n<font color="#8855cc">Drop:</font> <font color="#55cc77">%s</font>',
                    b.Name, b.Lvl, b.Zone, b.Drop
                )
                break
            end
        end
    end
    refreshBossInfo()

    mkSection(BT, "🏰  DUNGEON OUWIGAHARA", 6)
    mkToggle(BT, "Auto Dungeon (Lv.65+)", "AutoDungeon", 7, function(on)
        if on then loopAutoDungeon() end
    end)
    mkButton(BT, "📍 TP para Zona do Boss", 8, function()
        for _, b in ipairs(BOSSES) do
            if b.Name == ST.TargetBoss then
                if ST.NotifFn then ST.NotifFn("🌀 Teleportando para "..b.Zone, T.AccentBrt) end
                break
            end
        end
    end)

    -- ── PLAYER TAB ───────────────────────────────────────────
    local PT = frames["Player"]
    mkSection(PT, "🚀  MOVIMENTO", 1)
    mkToggle(PT, "✈ Voar (Fly)", "Fly", 2, function(on)
        if on then enableFly() else disableFly() end
    end)
    mkSlider(PT, "Velocidade Fly", 10, 350, "FlySpeedVal", 3)
    mkToggle(PT, "⚡ Speed Hack", "Speed", 4, function(on)
        setSpeed(on and ST.SpeedVal or 16)
    end)
    mkSlider(PT, "Velocidade Walk", 16, 500, "SpeedVal", 5, function(v)
        if ST.Speed then setSpeed(v) end
    end)
    mkToggle(PT, "🦘 Pulo Infinito", "InfiniteJump", 6)
    mkToggle(PT, "🔮 No Clip", "NoClip", 7)
    mkSection(PT, "🎣  PESCA & CLAN", 8)
    mkToggle(PT, "Auto Pesca", "AutoFishing", 9, function(on)
        if on then loopAutoFishing() end
    end)
    mkToggle(PT, "Auto Clan Spin", "AutoClanSpin", 10, function(on)
        if on then loopClanSpin() end
    end)
    mkSection(PT, "🛡  ANTI-DETECÇÃO", 11)
    mkToggle(PT, "Humanizar Movimento", "AntiDetect", 12, function(on)
        AD.HumanizeTP   = on
        AD.MicroDrift   = on
        AD.RandomTiming = on
    end)
    mkButton(PT, "♻ Recarregar Personagem", 13, function()
        LP:LoadCharacter()
    end)
    mkButton(PT, "🌐 Rejoin Server", 14, function()
        pcall(function() TS:Teleport(game.PlaceId, LP) end)
    end)

    -- ── ESP TAB ──────────────────────────────────────────────
    local ET = frames["ESP"]
    mkSection(ET, "👁  ESP", 1)
    mkToggle(ET, "ESP — Mobs (roxo)", "ESP_Mob", 2, function(on)
        refreshESP()
    end)
    mkToggle(ET, "ESP — Bosses (laranja)", "ESP_Boss", 3, function(on)
        refreshESP()
    end)
    mkToggle(ET, "ESP — Jogadores (vermelho)", "ESP_Player", 4, function(on)
        if not on then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character then
                    local r = pl.Character:FindFirstChild("HumanoidRootPart")
                    if r then for _, v in ipairs(r:GetChildren()) do
                        if v:IsA("BillboardGui") then v:Destroy() end
                    end end
                end
            end
        else
            refreshESP()
        end
    end)
    mkButton(ET, "🔄 Atualizar ESP Agora", 5, function()
        clearESP()
        task.wait(0.1)
        refreshESP()
    end)
    mkButton(ET, "🗑 Limpar ESP", 6, function()
        clearESP()
        ST.ESP_Mob    = false
        ST.ESP_Boss   = false
        ST.ESP_Player = false
    end)

    -- ── TELEPORT TAB ─────────────────────────────────────────
    local TT = frames["TP"]
    mkSection(TT, "🌀  ZONAS", 1)
    for i, z in ipairs(ZONES) do
        mkButton(TT, "📍 "..z, i+1, function()
            if ST.NotifFn then ST.NotifFn("🌀 TP → "..z, T.AccentBrt) end
            -- attempt workspace landmark search for zone
            local nameLow = z:lower()
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
                    if obj.Name:lower():find(nameLow:sub(1,5)) then
                        local hrp = getHRP()
                        if hrp then
                            hrp.CFrame = obj.CFrame + Vector3.new(0,10,0)
                        end
                        return
                    end
                end
            end
        end)
    end

    mkSection(TT, "💀  BOSSES", #ZONES + 3)
    for i, b in ipairs(BOSSES) do
        local bc = b
        mkButton(TT, string.format("💀 %s  (Lv.%d)", b.Name, b.Lvl), #ZONES + 3 + i, function()
            if ST.NotifFn then ST.NotifFn("💀 TP → "..bc.Name, T.Warning) end
            local target = findMob(bc.Name)
            if target then
                local r = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
                if r then
                    local hrp = getHRP()
                    if hrp then hrp.CFrame = r.CFrame + Vector3.new(0,10,0) end
                end
            end
        end)
    end

    -- ── MISC TAB ─────────────────────────────────────────────
    local MT = frames["Misc"]
    mkSection(MT, "⚙  UTILITÁRIOS", 1)
    mkButton(MT, "📋 Copiar UserID", 2, function()
        pcall(function() setclipboard(tostring(LP.UserId)) end)
        if ST.NotifFn then ST.NotifFn("✓ UserID copiado!", T.Success) end
    end)
    mkButton(MT, "🔕 Remover Efeitos Gráficos", 3, function()
        for _, v in ipairs(WS:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("Sky") then
                v.Parent = nil
            end
        end
        if ST.NotifFn then ST.NotifFn("✓ Efeitos removidos", T.Success) end
    end)
    mkButton(MT, "🌄 FPS Boost (sem texturas)", 4, function()
        local LC = game:GetService("Lighting")
        LC.GlobalShadows = false
        LC.FogEnd        = 10000
        for _, v in ipairs(WS:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
            end
        end
        if ST.NotifFn then ST.NotifFn("✓ FPS Boost aplicado", T.Success) end
    end)

    mkSection(MT, "📊  DEBUG", 5)

    local dbgFrame = Instance.new("Frame", MT)
    dbgFrame.Size             = UDim2.new(1,0,0,90)
    dbgFrame.BackgroundColor3 = T.PanelDark
    dbgFrame.BorderSizePixel  = 0
    dbgFrame.LayoutOrder      = 6
    Instance.new("UICorner", dbgFrame).CornerRadius = UDim.new(0,9)

    local dbgLbl = Instance.new("TextLabel", dbgFrame)
    dbgLbl.Size                   = UDim2.new(1,-10,1,0)
    dbgLbl.Position               = UDim2.new(0,5,0,0)
    dbgLbl.BackgroundTransparency = 1
    dbgLbl.Font                   = Enum.Font.Code
    dbgLbl.TextScaled             = true
    dbgLbl.TextWrapped            = true
    dbgLbl.TextColor3             = T.TextDim
    dbgLbl.TextXAlignment         = Enum.TextXAlignment.Left
    dbgLbl.RichText               = true

    RunService.Heartbeat:Connect(function()
        if not MF or not MF.Parent then return end
        local hum = getHum()
        local hrp = getHRP()
        if hum and hrp then
            dbgLbl.Text = string.format(
                '<font color="#7755aa">Player:</font> <font color="#bb88ff">%s</font>\n<font color="#7755aa">HP:</font> <font color="#55cc77">%.0f/%.0f</font>\n<font color="#7755aa">Pos:</font> <font color="#bb88ff">%.0f, %.0f, %.0f</font>\n<font color="#7755aa">Farm:</font> <font color="#cc99ff">%s</font>  <font color="#7755aa">Boss:</font> <font color="#cc99ff">%s</font>',
                LP.DisplayName,
                hum.Health, hum.MaxHealth,
                hrp.Position.X, hrp.Position.Y, hrp.Position.Z,
                ST.TargetMob, ST.TargetBoss
            )
        end
    end)

    mkSection(MT, "ℹ  SOBRE", 7)
    local aboutF = Instance.new("Frame", MT)
    aboutF.Size             = UDim2.new(1,0,0,58)
    aboutF.BackgroundColor3 = T.PanelDark
    aboutF.BorderSizePixel  = 0
    aboutF.LayoutOrder      = 8
    Instance.new("UICorner", aboutF).CornerRadius = UDim.new(0,9)
    local aboutLbl = Instance.new("TextLabel", aboutF)
    aboutLbl.Size                   = UDim2.new(1,-10,1,0)
    aboutLbl.Position               = UDim2.new(0,5,0,0)
    aboutLbl.BackgroundTransparency = 1
    aboutLbl.Font                   = Enum.Font.Gotham
    aboutLbl.TextScaled             = true
    aboutLbl.TextWrapped            = true
    aboutLbl.RichText               = true
    aboutLbl.TextColor3             = T.TextDim
    aboutLbl.Text                   = '<font color="#9933ee"><b>VOID.LAZY v3.0</b></font>  Mobile Edition\nSlayers 2 — Anti-Detect Ativo\n<font color="#554477">Delta Compatible | by VOID Team</font>'

    -- ── DRAGGABLE ────────────────────────────────────────────
    local dragActive, dragStart, dragOrigPos = false, nil, nil

    HDR.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive  = true
            dragStart   = inp.Position
            dragOrigPos = MF.Position
        end
    end)
    HDR.InputChanged:Connect(function(inp)
        if dragActive and (inp.UserInputType == Enum.UserInputType.Touch or
                           inp.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = inp.Position - dragStart
            MF.Position = UDim2.new(
                dragOrigPos.X.Scale, dragOrigPos.X.Offset + delta.X,
                dragOrigPos.Y.Scale, dragOrigPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or
           inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = false
        end
    end)

    -- ── MINIMIZE ─────────────────────────────────────────────
    local minimized = false
    local fullHeight = isMobile and 590 or 560

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(MF, {Size = minimized
            and UDim2.new(MF.Size.X.Scale, MF.Size.X.Offset, 0, 50)
            or  UDim2.new(MF.Size.X.Scale, MF.Size.X.Offset, 0, fullHeight)
        }, 0.3, Enum.EasingStyle.Quad, minimized and Enum.EasingDirection.In or Enum.EasingDirection.Out)
    end)

    -- ── CLOSE ────────────────────────────────────────────────
    CloseBtn.MouseButton1Click:Connect(function()
        tween(MF, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.5)
        ST.AutoFarm = false; ST.AutoBoss = false; ST.AutoMastery = false
        ST.AutoQuest = false; ST.AutoFishing = false; ST.AutoClanSpin = false
        ST.Fly = false; ST.NoClip = false; ST.InfiniteJump = false
        for _, c in ipairs(ST.Connections) do pcall(function() c:Disconnect() end) end
        clearESP()
        SG:Destroy()
    end)

    -- ── NOTIFICATION SYSTEM ──────────────────────────────────
    local function showNotif(msg, color, dur)
        color = color or T.AccentBrt
        dur   = dur   or 2.5
        task.spawn(function()
            local nf = Instance.new("Frame", SG)
            nf.Size             = UDim2.new(0,260,0,44)
            nf.Position         = UDim2.new(0.5,-130,1,5)
            nf.BackgroundColor3 = T.PanelDark
            nf.BorderSizePixel  = 0
            nf.ZIndex           = 1000
            Instance.new("UICorner", nf).CornerRadius = UDim.new(0,11)
            local nStroke = Instance.new("UIStroke", nf)
            nStroke.Color = color; nStroke.Thickness = 1.5

            local nl = Instance.new("TextLabel", nf)
            nl.Size                   = UDim2.new(1,-10,1,0)
            nl.Position               = UDim2.new(0,5,0,0)
            nl.BackgroundTransparency = 1
            nl.Font                   = Enum.Font.GothamBold
            nl.TextScaled             = true
            nl.TextWrapped            = true
            nl.TextColor3             = color
            nl.TextStrokeTransparency = 0.3
            nl.ZIndex                 = 1001
            nl.Text                   = msg

            tween(nf, {Position = UDim2.new(0.5,-130,1,-54)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(dur)
            tween(nf, {Position = UDim2.new(0.5,-130,1,5)},   0.3,  Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.35)
            nf:Destroy()
        end)
    end

    ST.NotifFn = showNotif

    -- Init tab
    switchTab("Farm")

    -- Welcome notifications
    task.wait(0.6)
    showNotif("✦ VOID.LAZY v3.0 carregado!", T.AccentBrt, 3)
    task.wait(1.1)
    showNotif("🛡 Anti-Detecção ATIVO", T.Success, 2.5)
    task.wait(1.2)
    showNotif("⚔ Slayers 2 | Mobile Ready", T.Warning, 2.5)
end

-- ============================================================
-- [18] GLOBAL SYSTEMS INIT
-- ============================================================
setupNoClip()
setupInfiniteJump()

print("[VOID.LAZY] v3.0 | Inicializado. Aguardando autenticação...")
