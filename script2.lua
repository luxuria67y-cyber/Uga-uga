-- ============================================================
--  VOID.LAZY v4.2 | Slayers 2 | MOBILE ULTIMATE BLINDADO
--  Senha: leyzepidao
-- ============================================================

-- [1] PROTEÇÃO DE INICIALIZAÇÃO (Evita crash antes do jogo carregar)
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
while not LP do
    task.wait(0.1)
    LP = Players.LocalPlayer
end

-- [2] PROTEÇÃO DA INTERFACE (Evita bloqueio do Delta no CoreGui)
local parentGui
local ok, hui = pcall(function() return gethui() end)
if ok and hui then
    parentGui = hui
else
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then
        parentGui = core
    else
        parentGui = LP:WaitForChild("PlayerGui")
    end
end

-- [3] PCALL MESTRE (Se der erro, avisa na tela em vez de sumir)
local OK, ERR = pcall(function()

local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local RS            = game:GetService("ReplicatedStorage")
local WS            = workspace

local function getCam() return WS.CurrentCamera end
local function rnd(a, b) return a + math.random() * (b - a) end

local function tw(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    local ok, t = pcall(TweenService.Create, TweenService, obj, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    if ok and t then t:Play() end
end

local function getChar() return LP and (LP.Character or LP.CharacterAdded:Wait()) end
local function getHRP() local c = LP and LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = LP and LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end

local ST = {
    AutoFarm=false, AutoBoss=false, AutoMastery=false, AutoQuest=false, AutoDungeon=false, AutoFishing=false, AutoClanSpin=false, AutoSkills=true,
    FreezeTarget=true, AntiIdle=true, ESP_Mob=false, ESP_Boss=false, ESP_Player=false, ESP_NPC=false, Fly=false, Speed=false, NoClip=false, InfiniteJump=false, AntiDetect=true,
    TargetMob="Greater Demon", TargetBoss="Zuko", MaxLevel=400, SpeedVal=60, FlySpeedVal=90, FarmHeight=5, HitboxSize=15, AutoEquipBest=false, AutoLoot=false, AutoChest=false,
    Connections={}, ESPCache={}, FlyGyro=nil, FlyBody=nil
}

local AD = { on = true }
function AD:wait(base) task.wait(self.on and (base + (math.random()*2-1)*(base*0.2)) or base) end

local MOBS = {"Bandit","Greater Demon","Bear","Mother Bear","Demon","Mushroom Demon","Spider Demon","Zagan Demon","Frozen Demon","Wind Demon","Stone Golem","Blood Demon","Dungeon Demon"}
local BOSSES = {
    {N="Zuko",Lv=7,Zone="Starter Village",Drop="Cutlass 20%"},{N="Mother Bear",Lv=18,Zone="Bear Area",Drop="Bear Pelt"},
    {N="Rengu",Lv=30,Zone="Mistfall Village",Drop="Flame Katana 5%"},{N="Zentaro",Lv=28,Zone="Thunder Cliffs",Drop="Thunder Katana 5%"}
}
local QUEST_NPCS = {"Krue","Tom","Quest","Crow","Muzan","Hunter","Trainer","Master"}

local function findMob(name)
    local hrp = getHRP(); if not hrp then return nil end
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

local function freezeModel(m)
    if not m or not ST.FreezeTarget then return end
    pcall(function()
        local h = m:FindFirstChildOfClass("Humanoid"); local r = m:FindFirstChild("HumanoidRootPart")
        if h then h.WalkSpeed = 0; h.JumpPower = 0 end
        if r then r.AssemblyLinearVelocity = Vector3.zero end
    end)
end

local function fireAttack(target)
    if not target then return end
    pcall(function()
        local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not root then return end
        local hitbox = root:FindFirstChild("VOID_Hitbox")
        if not hitbox then
            hitbox = Instance.new("Part", root); hitbox.Name = "VOID_Hitbox"; hitbox.Transparency = 1; hitbox.CanCollide = false; hitbox.Massless = true
            local weld = Instance.new("WeldConstraint", hitbox); weld.Part0 = hitbox; weld.Part1 = root
        end
        hitbox.Size = Vector3.new(ST.HitboxSize, ST.HitboxSize, ST.HitboxSize)
        hitbox.CFrame = root.CFrame

        if ST.AutoEquipBest then
            local char = LP and LP.Character
            if char then
                local bestTool, bestDmg = nil, 0
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local dmg = tool:GetAttribute("Damage") or 10
                        if dmg > bestDmg then bestDmg = dmg; bestTool = tool end
                    end
                end
                if bestTool then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(bestTool) end end
            end
        end

        local cd = target:FindFirstChildOfClass("ClickDetector"); if cd then pcall(fireclickdetector, cd) end
        for _, pp in ipairs(target:GetDescendants()) do if pp:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp) end end
        local tool = LP and LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if tool then local act = tool:FindFirstChild("Activate"); if act then pcall(function() act:Fire() end) end end
        if RS then
            for _, rfn in ipairs({"Events","Remotes","RE","RF"}) do
                local rf = RS:FindFirstChild(rfn)
                if rf then
                    for _, ch in ipairs(rf:GetDescendants()) do
                        if ch:IsA("RemoteEvent") then
                            local n = ch.Name:lower()
                            if n:find("attack") or n:find("hit") or n:find("damage") then pcall(function() ch:FireServer(target, root.Position) end) end
                        end
                    end
                end
            end
        end
    end)
end

local function getFarmPosition(target)
    local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not root then return Vector3.zero end
    return root.Position + Vector3.new((math.random()-.5)*2, ST.FarmHeight + math.random()*.5, (math.random()-.5)*2)
end

local function loopFarm()
    task.spawn(function()
        while ST.AutoFarm do
            pcall(function()
                local hum = getHum(); if not hum or hum.Health <= 0 then task.wait(3); return end
                local t = findMob(ST.TargetMob); if not t then task.wait(1); return end
                local th = t:FindFirstChildOfClass("Humanoid"); if not th or th.Health <= 0 then return end
                local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(getFarmPosition(t)) end
                freezeModel(t)
                local hits = 0
                while ST.AutoFarm and th and th.Health > 0 do
                    freezeModel(t); fireAttack(t); hits = hits + 1
                    if hits % math.random(5,10) == 0 then local h2 = getHRP(); if h2 and t.Parent then h2.CFrame = CFrame.new(getFarmPosition(t)) end end
                    AD:wait(rnd(0.08, 0.18))
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function loopQuest()
    task.spawn(function()
        while ST.AutoQuest do
            pcall(function()
                for _, nname in ipairs(QUEST_NPCS) do
                    local npc = findMob(nname)
                    if npc then
                        local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                        if root then
                            local hrp = getHRP(); if hrp then hrp.CFrame = root.CFrame + Vector3.new(0,2,3) end
                            local cd = npc:FindFirstChildOfClass("ClickDetector"); if cd then pcall(fireclickdetector, cd) end
                            for _, pp in ipairs(npc:GetDescendants()) do if pp:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp) end end
                        end
                    end
                end
                local t = findMob(ST.TargetMob)
                if t then
                    local th = t:FindFirstChildOfClass("Humanoid")
                    if th and th.Health > 0 then
                        local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(getFarmPosition(t)) end
                        freezeModel(t)
                        while ST.AutoQuest and th and th.Health > 0 do freezeModel(t); fireAttack(t); AD:wait(rnd(0.1, 0.2)) end
                    end
                end
            end)
            task.wait(rnd(1.5, 3))
        end
    end)
end

local function loopChestLoot()
    task.spawn(function()
        while ST.AutoChest or ST.AutoLoot do
            pcall(function()
                for _, obj in ipairs(WS:GetDescendants()) do
                    local n = obj.Name:lower()
                    if n:find("chest") or n:find("cache") or n:find("loot") then
                        local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj
                        if root and root:IsA("BasePart") then
                            local hrp = getHRP(); if hrp then hrp.CFrame = root.CFrame + Vector3.new(0,3,0) end
                            for _, pp in ipairs(obj:GetDescendants()) do if pp:IsA("ProximityPrompt") then pcall(fireproximityprompt, pp) end end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

local function loopBoss()
    task.spawn(function()
        while ST.AutoBoss do
            pcall(function()
                local t = findMob(ST.TargetBoss); if not t then task.wait(rnd(2,4)); return end
                local th = t:FindFirstChildOfClass("Humanoid"); if not th or th.Health <= 0 then task.wait(1); return end
                local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(getFarmPosition(t)) end
                freezeModel(t)
                while ST.AutoBoss and th and th.Health > 0 do
                    fireAttack(t); freezeModel(t)
                    local h2 = getHRP(); if h2 and t.Parent then h2.CFrame = CFrame.new(getFarmPosition(t)) end
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
                local t = findMob(ST.TargetMob); if not t then task.wait(1); return end
                local th = t:FindFirstChildOfClass("Humanoid"); if not th or th.Health <= 0 then return end
                local hrp = getHRP(); if hrp then hrp.CFrame = CFrame.new(getFarmPosition(t)) end
                freezeModel(t)
                while ST.AutoMastery and th and th.Health > 0 do fireAttack(t); freezeModel(t); AD:wait(rnd(0.08, 0.15)) end
            end)
            task.wait(0.05)
        end
    end)
end

local function loopSkills()
    task.spawn(function()
        while ST.AutoSkills and (ST.AutoFarm or ST.AutoBoss or ST.AutoMastery or ST.AutoQuest) do
            pcall(function()
                if RS then
                    for _, rfn in ipairs({"Events","Remotes","RE"}) do
                        local rf = RS:FindFirstChild(rfn)
                        if rf then for _, ch in ipairs(rf:GetDescendants()) do if ch:IsA("RemoteEvent") and (ch.Name:lower():find("skill") or ch.Name:lower():find("ability") or ch.Name:lower():find("breath")) then pcall(function() ch:FireServer() end) end end end
                    end
                end
            end)
            task.wait(rnd(0.5, 1.5))
        end
    end)
end

local function enableFly()
    pcall(function()
        local hrp = getHRP(); if not hrp then return end
        if ST.FlyGyro then pcall(function() ST.FlyGyro:Destroy() end) end
        if ST.FlyBody then pcall(function() ST.FlyBody:Destroy() end) end
        local g = Instance.new("BodyGyro", hrp); g.MaxTorque = Vector3.new(1e9,1e9,1e9); g.P = 1e6; g.D = 50
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.Velocity = Vector3.zero
        ST.FlyGyro = g; ST.FlyBody = bv
        local conn = RunService.Heartbeat:Connect(function()
            if not ST.Fly then pcall(function() g:Destroy() end); pcall(function() bv:Destroy() end); ST.FlyGyro = nil; ST.FlyBody = nil; return end
            local cam = getCam(); if not cam or not hrp or not hrp.Parent then return end
            pcall(function()
                g.CFrame = cam.CFrame
                local rv = hrp.AssemblyLinearVelocity
                if Vector3.new(rv.X, 0, rv.Z).Magnitude > 1 then bv.Velocity = (cam.CFrame.LookVector * -rv.Z + cam.CFrame.RightVector * rv.X).Unit * ST.FlySpeedVal else bv.Velocity = bv.Velocity * 0.82 end
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

table.insert(ST.Connections, RunService.Stepped:Connect(function()
    if not ST.NoClip then return end
    pcall(function() local char = LP and LP.Character; if not char then return end; for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end)
end))

table.insert(ST.Connections, UIS.JumpRequest:Connect(function()
    if not ST.InfiniteJump then return end
    pcall(function() local hum = getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end)
end))

LP.CharacterAdded:Connect(function()
    task.wait(1.2)
    if ST.Speed then pcall(function() local hum = getHum(); if hum then hum.WalkSpeed = ST.SpeedVal end end) end
    if ST.Fly then task.wait(0.5); enableFly() end
end)

-- ============================================================
-- INTERFACE (Aqui usa o parentGui blindado)
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name = "VOID_LAZY"; SG.ResetOnSpawn = false; SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG.DisplayOrder = 999; SG.IgnoreGuiInset = true
SG.Parent = parentGui -- Usa a variável blindada que você validou!

local T = {BG=Color3.fromRGB(9,8,20), Panel=Color3.fromRGB(17,13,37), PanelDk=Color3.fromRGB(11,8,24), Acc=Color3.fromRGB(105,0,205), AccBrt=Color3.fromRGB(170,55,255), AccDim=Color3.fromRGB(52,0,108), Txt=Color3.fromRGB(235,228,255), TxtDim=Color3.fromRGB(138,128,172), On=Color3.fromRGB(85,0,185), Off=Color3.fromRGB(32,25,58), Btn=Color3.fromRGB(72,0,170), BtnHot=Color3.fromRGB(115,18,225), Border=Color3.fromRGB(72,0,152), Danger=Color3.fromRGB(210,42,42), Success=Color3.fromRGB(42,195,85), Warn=Color3.fromRGB(210,172,0)}

-- INTRO E SENHA
local Intro = Instance.new("Frame", SG); Intro.Size = UDim2.new(1,0,1,0); Intro.BackgroundColor3 = Color3.fromRGB(5,3,14); Intro.BorderSizePixel = 0; Intro.ZIndex = 200
local WFrame = Instance.new("Frame", Intro); WFrame.Size = UDim2.new(0.88,0,0.28,0); WFrame.Position = UDim2.new(0.06,0,0.14,0); WFrame.BackgroundTransparency = 1; WFrame.ZIndex = 202
local L2 = Instance.new("TextLabel", WFrame); L2.Size = UDim2.new(1,0,1,0); L2.BackgroundTransparency = 1; L2.Font = Enum.Font.GothamBlack; L2.TextScaled = true; L2.TextColor3 = T.AccBrt; L2.Text = "VOID.LAZY"; L2.ZIndex = 203
local PF = Instance.new("Frame", Intro); PF.Size = UDim2.new(0.82,0,0.34,0); PF.Position = UDim2.new(0.09,0,0.59,0); PF.BackgroundColor3 = T.PanelDk; PF.BackgroundTransparency = 1; PF.BorderSizePixel = 0; PF.ZIndex = 202
Instance.new("UICorner", PF).CornerRadius = UDim.new(0,14)
local PFStroke = Instance.new("UIStroke", PF); PFStroke.Color = T.Acc; PFStroke.Thickness = 1.5; PFStroke.Transparency = 1
local PFInp = Instance.new("TextBox", PF); PFInp.Size = UDim2.new(0.82,0,0.25,0); PFInp.Position = UDim2.new(0.09,0,0.3,0); PFInp.BackgroundColor3 = Color3.fromRGB(7,4,18); PFInp.BorderSizePixel = 0; PFInp.Font = Enum.Font.GothamBold; PFInp.TextColor3 = T.AccBrt; PFInp.PlaceholderText = "Senha..."; PFInp.TextScaled = true; PFInp.TextTransparency = 1; PFInp.ZIndex = 203
Instance.new("UICorner", PFInp).CornerRadius = UDim.new(0,8)
local PFBtn = Instance.new("TextButton", PF); PFBtn.Size = UDim2.new(0.52,0,0.23,0); PFBtn.Position = UDim2.new(0.24,0,0.63,0); PFBtn.BackgroundColor3 = T.Acc; PFBtn.BackgroundTransparency = 1; PFBtn.BorderSizePixel = 0; PFBtn.Font = Enum.Font.GothamBold; PFBtn.TextColor3 = Color3.fromRGB(255,255,255); PFBtn.TextScaled = true; PFBtn.Text = "✦ ENTRAR ✦"; PFBtn.TextTransparency = 1; PFBtn.ZIndex = 203
Instance.new("UICorner", PFBtn).CornerRadius = UDim.new(0,9)
local PFErr = Instance.new("TextLabel", PF); PFErr.Size = UDim2.new(1,0,0.14,0); PFErr.Position = UDim2.new(0,0,0.9,0); PFErr.BackgroundTransparency = 1; PFErr.TextColor3 = T.Danger; PFErr.Font = Enum.Font.Gotham; PFErr.TextScaled = true; PFErr.Text = ""; PFErr.ZIndex = 203

task.spawn(function()
    task.wait(0.4)
    tw(L2, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.5)
    task.wait(1)
    PF.BackgroundTransparency = 0; PFStroke.Transparency = 0
    tw(PFInp, {TextTransparency=0, BackgroundTransparency=0}, 0.5)
    tw(PFBtn, {BackgroundTransparency=0, TextTransparency=0}, 0.5)
end)

local buildMainUI
local function validatePW()
    if PFInp.Text:lower():gsub("%s","") == "leyzepidao" then
        PFErr.TextColor3 = T.Success; PFErr.Text = "✓ Acesso concedido!"
        task.wait(0.5); Intro:Destroy(); buildMainUI()
    else
        PFErr.Text = "✗ Senha incorreta!"; PFInp.Text = ""
    end
end
PFBtn.MouseButton1Click:Connect(validatePW)
PFInp.FocusLost:Connect(function(e) if e then validatePW() end end)

buildMainUI = function()
    local VP = getCam() and getCam().ViewportSize or Vector2.new(800,600)
    local MF = Instance.new("Frame", SG); MF.Name = "VoidMain"; MF.BorderSizePixel = 0; MF.ClipsDescendants = true; MF.BackgroundColor3 = T.BG
    local FW = math.min(VP.X * 0.93, 400); local FH = 500
    MF.Size = UDim2.new(0, FW, 0, FH); MF.Position = UDim2.new(0.5, -FW/2, -1, 0)
    Instance.new("UICorner", MF).CornerRadius = UDim.new(0,15)
    local MFS = Instance.new("UIStroke", MF); MFS.Color = T.Border; MFS.Thickness = 1.5
    tw(MF, {Position = UDim2.new(0.5, -FW/2, 0.04, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local HDR = Instance.new("Frame", MF); HDR.Size = UDim2.new(1,0,0,50); HDR.BackgroundColor3 = T.AccDim; HDR.BorderSizePixel = 0
    Instance.new("UICorner", HDR).CornerRadius = UDim.new(0,15)
    local htl = Instance.new("TextLabel", HDR); htl.Size = UDim2.new(0.62,0,1,0); htl.Position = UDim2.new(0,12,0,0); htl.BackgroundTransparency = 1; htl.Font = Enum.Font.GothamBlack; htl.TextScaled = true; htl.TextXAlignment = Enum.TextXAlignment.Left; htl.TextColor3 = Color3.fromRGB(255,255,255); htl.Text = "⬡ VOID.LAZY"
    local CloseBtn = Instance.new("TextButton", HDR); CloseBtn.Size = UDim2.new(0,27,0,27); CloseBtn.Position = UDim2.new(1,-34,0.5,-13); CloseBtn.BackgroundColor3 = Color3.fromRGB(170,28,28); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

    local TBar = Instance.new("Frame", MF); TBar.Size = UDim2.new(1,0,0,35); TBar.Position = UDim2.new(0,0,0,50); TBar.BackgroundColor3 = T.PanelDk; TBar.BorderSizePixel = 0
    local CA = Instance.new("Frame", MF); CA.Size = UDim2.new(1,0,1,-85); CA.Position = UDim2.new(0,0,0,85); CA.BackgroundTransparency = 1; CA.ClipsDescendants = true

    local TABS = {{N="Farm",I="⚔"},{N="Boss",I="💀"},{N="Player",I="⚡"},{N="ESP",I="👁"},{N="Misc",I="⚙"}}
    local frames, tBtns, curTab = {}, {}, nil
    local tabW = (1 - 0.012) / #TABS

    local function switchTab(name)
        if curTab == name then return end
        curTab = name
        for n,f in pairs(frames) do f.Visible = (n==name) end
        for n,b in pairs(tBtns) do
            if n==name then tw(b,{BackgroundColor3=T.Acc,TextColor3=Color3.fromRGB(255,255,255)},0.15) else tw(b,{BackgroundColor3=Color3.fromRGB(17,12,36),TextColor3=T.TxtDim},0.15) end
        end
    end

    for i,td in ipairs(TABS) do
        local b = Instance.new("TextButton", TBar); b.Size = UDim2.new(tabW,0,1,0); b.BackgroundColor3 = (i==1) and T.Acc or Color3.fromRGB(17,12,36); b.BorderSizePixel = 0; b.LayoutOrder = i; b.Font = Enum.Font.GothamBold; b.TextScaled = true; b.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or T.TxtDim; b.Text = td.I.." "..td.N
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,6); tBtns[td.N] = b
        local sf = Instance.new("ScrollingFrame", CA); sf.Size = UDim2.new(1,0,1,0); sf.BackgroundTransparency = 1; sf.ScrollBarThickness = 3; sf.CanvasSize = UDim2.new(0,0,0,0); sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.Visible = (i==1)
        local sfl = Instance.new("UIListLayout", sf); sfl.SortOrder = Enum.SortOrder.LayoutOrder; sfl.Padding = UDim.new(0,4)
        local sfp = Instance.new("UIPadding", sf); sfp.PaddingLeft=UDim.new(0,8); sfp.PaddingRight=UDim.new(0,8); sfp.PaddingTop=UDim.new(0,6)
        frames[td.N] = sf; b.MouseButton1Click:Connect(function() switchTab(td.N) end)
    end
    curTab = "Farm"

    local function mkSec(p, txt, ord) local f = Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,22); f.BackgroundColor3=Color3.fromRGB(20,7,45); f.BorderSizePixel=0; f.LayoutOrder=ord or 0; Instance.new("UICorner",f).CornerRadius=UDim.new(0,6); local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-12,1,0); l.Position=UDim2.new(0,12,0,0); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextScaled=true; l.TextColor3=T.AccBrt; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=txt end
    local function mkToggle(p, lbl, key, ord, cb) local row=Instance.new("Frame",p); row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=T.Panel; row.BorderSizePixel=0; row.LayoutOrder=ord or 0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,9); local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(0.7,0,1,0); tl.Position=UDim2.new(0,10,0,0); tl.BackgroundTransparency=1; tl.Font=Enum.Font.Gotham; tl.TextScaled=true; tl.TextColor3=T.Txt; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=lbl; local tbg=Instance.new("Frame",row); tbg.Size=UDim2.new(0,44,0,22); tbg.Position=UDim2.new(1,-52,0.5,-11); tbg.BackgroundColor3=ST[key] and T.On or T.Off; tbg.BorderSizePixel=0; Instance.new("UICorner",tbg).CornerRadius=UDim.new(1,0); local tk=Instance.new("Frame",tbg); tk.Size=UDim2.new(0,18,0,18); tk.Position=ST[key] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9); tk.BackgroundColor3=Color3.fromRGB(255,255,255); tk.BorderSizePixel=0; Instance.new("UICorner",tk).CornerRadius=UDim.new(1,0); local hit=Instance.new("TextButton",row); hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=row.ZIndex+2; hit.MouseButton1Click:Connect(function() ST[key]=not ST[key]; tw(tbg,{BackgroundColor3=ST[key] and T.On or T.Off},0.2); tw(tk,{Position=ST[key] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)},0.2); if cb then cb(ST[key]) end end) end
    local function mkSlider(p, lbl, vmin, vmax, key, ord) local row=Instance.new("Frame",p); row.Size=UDim2.new(1,0,0,52); row.BackgroundColor3=T.Panel; row.BorderSizePixel=0; row.LayoutOrder=ord or 0; Instance.new("UICorner",row).CornerRadius=UDim.new(0,9); local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(0.6,0,0.46,0); tl.Position=UDim2.new(0,10,0,0); tl.BackgroundTransparency=1; tl.Font=Enum.Font.Gotham; tl.TextScaled=true; tl.TextColor3=T.Txt; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=lbl; local vl=Instance.new("TextLabel",row); vl.Size=UDim2.new(0.3,0,0.4,0); vl.Position=UDim2.new(0.68,0,0.04,0); vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold; vl.TextScaled=true; vl.TextColor3=T.AccBrt; vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Text=tostring(ST[key]); local sbg=Instance.new("Frame",row); sbg.Size=UDim2.new(0.88,0,0,5); sbg.Position=UDim2.new(0.06,0,0.77,0); sbg.BackgroundColor3=Color3.fromRGB(26,17,50); sbg.BorderSizePixel=0; Instance.new("UICorner",sbg).CornerRadius=UDim.new(1,0); local pct=(ST[key]-vmin)/(vmax-vmin); local sf=Instance.new("Frame",sbg); sf.Size=UDim2.new(pct,0,1,0); sf.BackgroundColor3=T.AccBrt; sf.BorderSizePixel=0; Instance.new("UICorner",sf).CornerRadius=UDim.new(1,0); local sk=Instance.new("Frame",sbg); sk.Size=UDim2.new(0,14,0,14); sk.Position=UDim2.new(pct,-7,0.5,-7); sk.BackgroundColor3=Color3.fromRGB(255,255,255); sk.BorderSizePixel=0; Instance.new("UICorner",sk).CornerRadius=UDim.new(1,0); local dragging=false; local function apply(pos) local abs=sbg.AbsolutePosition; local sz=sbg.AbsoluteSize; local rel=math.clamp((pos.X-abs.X)/sz.X,0,1); local val=math.floor(vmin+(vmax-vmin)*rel); ST[key]=val; vl.Text=tostring(val); tw(sf,{Size=UDim2.new(rel,0,1,0)},0.05,Enum.EasingStyle.Linear); tw(sk,{Position=UDim2.new(rel,-7,0.5,-7)},0.05,Enum.EasingStyle.Linear) end; sbg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; apply(i.Position) end end); sbg.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then apply(i.Position) end end); UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end) end
    local function mkDrop(p, lbl, opts, key, ord) local wrap=Instance.new("Frame",p); wrap.Size=UDim2.new(1,0,0,36); wrap.BackgroundColor3=T.Panel; wrap.BorderSizePixel=0; wrap.LayoutOrder=ord or 0; wrap.ClipsDescendants=false; Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,9); local tl=Instance.new("TextLabel",wrap); tl.Size=UDim2.new(0.43,0,1,0); tl.Position=UDim2.new(0,10,0,0); tl.BackgroundTransparency=1; tl.Font=Enum.Font.Gotham; tl.TextScaled=true; tl.TextColor3=T.Txt; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Text=lbl; local db=Instance.new("TextButton",wrap); db.Size=UDim2.new(0.5,0,0.72,0); db.Position=UDim2.new(0.48,0,0.14,0); db.BackgroundColor3=Color3.fromRGB(20,13,45); db.BorderSizePixel=0; db.Font=Enum.Font.GothamBold; db.TextScaled=true; db.TextColor3=T.AccBrt; db.Text=ST[key] or opts[1]; Instance.new("UICorner",db).CornerRadius=UDim.new(0,7); local DL=Instance.new("Frame",SG); DL.BackgroundColor3=Color3.fromRGB(12,7,30); DL.BorderSizePixel=0; DL.Visible=false; DL.ZIndex=500; Instance.new("UICorner",DL).CornerRadius=UDim.new(0,9); local dll=Instance.new("UIListLayout",DL); dll.SortOrder=Enum.SortOrder.LayoutOrder; for j,opt in ipairs(opts) do local ob=Instance.new("TextButton",DL); ob.Size=UDim2.new(1,0,0,26); ob.BackgroundColor3=Color3.fromRGB(12,7,30); ob.BorderSizePixel=0; ob.Font=Enum.Font.Gotham; ob.TextScaled=true; ob.TextColor3=T.Txt; ob.Text=opt; ob.ZIndex=501; ob.LayoutOrder=j; ob.MouseButton1Click:Connect(function() ST[key]=opt; db.Text=opt; DL.Visible=false end) end; DL.Size=UDim2.new(0,175,0,26*#opts); local open=false; db.MouseButton1Click:Connect(function() open=not open; if open then DL.Position=UDim2.new(0,db.AbsolutePosition.X,0,db.AbsolutePosition.Y+db.AbsoluteSize.Y+3); DL.Visible=true else DL.Visible=false end end) end
    local function mkBtn(p, txt, ord, cb) local b=Instance.new("TextButton",p); b.Size=UDim2.new(1,0,0,33); b.BackgroundColor3=T.Btn; b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; b.TextScaled=true; b.TextColor3=Color3.fromRGB(255,255,255); b.Text=txt; b.LayoutOrder=ord or 0; Instance.new("UICorner",b).CornerRadius=UDim.new(0,9); b.MouseButton1Click:Connect(function() tw(b,{BackgroundColor3=T.AccBrt},0.08); task.wait(0.08); tw(b,{BackgroundColor3=T.Btn},0.22); if cb then pcall(cb) end end) end

    local FT=frames["Farm"]
    mkSec(FT,"⚔ AUTO FARM",1); mkDrop(FT,"Mob Alvo",MOBS,"TargetMob",2)
    mkToggle(FT,"Auto Farm","AutoFarm",3,function(on) if on then loopFarm(); loopSkills() end end)
    mkToggle(FT,"Auto Quest","AutoQuest",4,function(on) if on then loopQuest(); loopSkills() end end)
    mkToggle(FT,"Congelar Alvo","FreezeTarget",5)
    mkSec(FT,"⚙ POSIÇÃO",6); mkSlider(FT,"Altura Farm",0,30,"FarmHeight",7); mkSlider(FT,"Hitbox",5,50,"HitboxSize",8)
    mkSec(FT,"🎒 EQUIP & LOOT",9); mkToggle(FT,"Auto Equipar","AutoEquipBest",10); mkToggle(FT,"Auto Baús","AutoChest",11,function(on) if on then loopChestLoot() end end)
    mkSec(FT,"✦ MASTERY",12); mkToggle(FT,"Auto Mastery","AutoMastery",13,function(on) if on then loopMastery() end end)

    local BT=frames["Boss"]; mkSec(BT,"💀 BOSS",1)
    local bnames={}; for _,b in ipairs(BOSSES) do table.insert(bnames,b.N) end
    mkDrop(BT,"Boss Alvo",bnames,"TargetBoss",2); mkToggle(BT,"Auto Boss","AutoBoss",3,function(on) if on then loopBoss() end end)

    local PT=frames["Player"]; mkSec(PT,"🚀 MOVIMENTO",1)
    mkToggle(PT,"Voar (Fly)","Fly",2,function(on) if on then enableFly() else disableFly() end end)
    mkSlider(PT,"Vel. Fly",10,350,"FlySpeedVal",3)
    mkToggle(PT,"Speed Hack","Speed",4,function(on) if on then local h=getHum(); if h then h.WalkSpeed=ST.SpeedVal end else local h=getHum(); if h then h.WalkSpeed=16 end end end)
    mkSlider(PT,"Vel. Walk",16,500,"SpeedVal",5,function(v) if ST.Speed then local h=getHum(); if h then h.WalkSpeed=v end end end)
    mkToggle(PT,"Pulo Infinito","InfiniteJump",6); mkToggle(PT,"No Clip","NoClip",7)

    local ET=frames["ESP"]; mkSec(ET,"👁 ESP",1)
    mkToggle(ET,"Mobs","ESP_Mob",2); mkToggle(ET,"Bosses","ESP_Boss",3); mkToggle(ET,"Players","ESP_Player",4)

    local MT=frames["Misc"]; mkSec(MT,"⚙ UTILS",1)
    mkBtn(MT,"Copiar UserID",2,function() pcall(function() setclipboard(tostring(LP.UserId)) end) end)
    mkBtn(MT,"FPS Boost",3,function() pcall(function() game:GetService("Lighting").GlobalShadows=false end) end)

    local drag,dStart,dOrig=false,nil,nil
    HDR.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; dStart=i.Position; dOrig=MF.Position end end)
    HDR.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then local d=i.Position-dStart; MF.Position=UDim2.new(dOrig.X.Scale,dOrig.X.Offset+d.X,dOrig.Y.Scale,dOrig.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    CloseBtn.MouseButton1Click:Connect(function() tw(MF,{Size=UDim2.new(0,0,0,0)},0.3); task.wait(0.35); pcall(function() SG:Destroy() end) end)
    switchTab("Farm")
end

end)

if not OK then
    local sg2 = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local f = Instance.new("Frame",sg2); f.Size=UDim2.new(0.9,0,0,80); f.Position=UDim2.new(0.05,0,0.4,0); f.BackgroundColor3=Color3.fromRGB(30,5,5)
    local l = Instance.new("TextLabel",f); l.Size=UDim2.new(1,-10,1,0); l.Position=UDim2.new(0,5,0,0); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold; l.TextScaled=true; l.TextWrapped=true; l.TextColor3=Color3.fromRGB(255,80,80); l.Text = "ERRO NO SCRIPT:\n"..tostring(ERR)
end
