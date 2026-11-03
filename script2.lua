--[[
    VOID.LAZY  |  SLAYERS 2
    Mobile Delta / Fluxus hardened
    Password: leyzepidao
    Fixed load path — GUI opens even if later features fail
]]

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

-- safe helpers
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

local function protect(gui)
    safe(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
        if gethui then gui.Parent = gethui() return end
        if CoreGui then gui.Parent = CoreGui return end
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
end

local function notify(title, text)
    safe(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "VOID.LAZY",
            Text = text or "",
            Duration = 4
        })
    end)
end

-- ===================== PASSWORD GATE (must never fail) =====================
local PASS = "leyzepidao"
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VOIDLAZY_" .. tostring(math.random(100000,999999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
protect(ScreenGui)

local Intro = Instance.new("Frame")
Intro.Size = UDim2.new(1,0,1,0)
Intro.BackgroundColor3 = Color3.fromRGB(8,8,12)
Intro.BorderSizePixel = 0
Intro.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.Position = UDim2.new(0,0,0.38,0)
Title.BackgroundTransparency = 1
Title.Text = "VOID.LAZY"
Title.TextColor3 = Color3.fromRGB(180,60,255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 28
Title.Parent = Intro

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1,0,0,24)
Sub.Position = UDim2.new(0,0,0.46,0)
Sub.BackgroundTransparency = 1
Sub.Text = "Slayers 2  •  Mobile"
Sub.TextColor3 = Color3.fromRGB(190,190,210)
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 14
Sub.Parent = Intro

local PassBox = Instance.new("TextBox")
PassBox.Size = UDim2.new(0,200,0,34)
PassBox.Position = UDim2.new(0.5,-100,0.55,0)
PassBox.BackgroundColor3 = Color3.fromRGB(22,22,30)
PassBox.BorderSizePixel = 0
PassBox.Text = ""
PassBox.PlaceholderText = "senha"
PassBox.TextColor3 = Color3.fromRGB(230,230,255)
PassBox.Font = Enum.Font.Gotham
PassBox.TextSize = 14
PassBox.ClearTextOnFocus = false
PassBox.Parent = Intro
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0,8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,20)
Status.Position = UDim2.new(0,0,0.63,0)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(255,100,120)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.Parent = Intro

local function openMain()
    Intro:Destroy()
    buildUI()
end

PassBox.FocusLost:Connect(function(enter)
    if not enter then return end
    if PassBox.Text:lower():gsub("%s","") == PASS then
        Status.TextColor3 = Color3.fromRGB(100,255,140)
        Status.Text = "ok"
        task.wait(0.25)
        openMain()
    else
        Status.Text = "senha errada"
        PassBox.Text = ""
    end
end)

-- also allow Enter on mobile keyboards
PassBox:GetPropertyChangedSignal("Text"):Connect(function()
    if PassBox.Text:lower():gsub("%s","") == PASS then
        -- auto unlock if they paste the full password
        task.defer(function()
            if PassBox and PassBox.Parent then
                Status.TextColor3 = Color3.fromRGB(100,255,140)
                Status.Text = "ok"
                task.wait(0.2)
                openMain()
            end
        end)
    end
end)

notify("VOID.LAZY", "Digite a senha")

-- ===================== MAIN UI =====================
function buildUI()
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 320, 0, 400)
    Main.Position = UDim2.new(0.5, -160, 0.5, -200)
    Main.BackgroundColor3 = Color3.fromRGB(14,14,20)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(130,40,220)
    stroke.Thickness = 1.4
    stroke.Parent = Main

    -- Top bar + drag
    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1,0,0,36)
    Top.BackgroundColor3 = Color3.fromRGB(20,18,28)
    Top.BorderSizePixel = 0
    Top.Parent = Main
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,12)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1,-40,1,0)
    TitleLbl.Position = UDim2.new(0,10,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "VOID.LAZY  •  SLAYERS 2"
    TitleLbl.TextColor3 = Color3.fromRGB(185,80,255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Top

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0,26,0,26)
    Close.Position = UDim2.new(1,-32,0.5,-13)
    Close.BackgroundColor3 = Color3.fromRGB(45,25,55)
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(255,110,140)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 16
    Close.Parent = Top
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local dragging, dragStart, startPos
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Top.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- Tabs
    local tabNames = {"Farm","Quest","TP","ESP","Misc"}
    local pages = {}
    local tabBtns = {}

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1,-12,0,28)
    TabBar.Position = UDim2.new(0,6,0,40)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Main

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-12,1,-78)
    Content.Position = UDim2.new(0,6,0,72)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = Main

    local function switch(name)
        for n,p in pairs(pages) do p.Visible = false end
        for n,b in pairs(tabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(24,24,32)
            b.TextColor3 = Color3.fromRGB(150,150,170)
        end
        pages[name].Visible = true
        tabBtns[name].BackgroundColor3 = Color3.fromRGB(55,30,85)
        tabBtns[name].TextColor3 = Color3.fromRGB(220,170,255)
    end

    for i,name in ipairs(tabNames) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1/#tabNames, -3, 1, 0)
        b.Position = UDim2.new((i-1)/#tabNames, 1, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(24,24,32)
        b.Text = name
        b.TextColor3 = Color3.fromRGB(150,150,170)
        b.Font = Enum.Font.Gotham
        b.TextSize = 11
        b.Parent = TabBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        tabBtns[name] = b

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(120,50,200)
        page.CanvasSize = UDim2.new(0,0,0,520)
        page.Visible = false
        page.Parent = Content
        pages[name] = page

        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0,5)
        lay.Parent = page

        b.MouseButton1Click:Connect(function() switch(name) end)
    end
    switch("Farm")

    -- UI helpers
    local function addToggle(parent, text, default, cb)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0,26)
        f.BackgroundTransparency = 1
        f.Parent = parent

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-48,1,0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(210,210,230)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,40,0,20)
        btn.Position = UDim2.new(1,-40,0.5,-10)
        btn.BackgroundColor3 = default and Color3.fromRGB(110,40,190) or Color3.fromRGB(40,40,50)
        btn.Text = ""
        btn.Parent = f
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(110,40,190) or Color3.fromRGB(40,40,50)
            }):Play()
            if cb then cb(state) end
        end)
        return function() return state end
    end

    local function addBtn(parent, text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,28)
        b.BackgroundColor3 = Color3.fromRGB(30,22,42)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(200,160,255)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 12
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(90,40,160)
        s.Thickness = 1
        s.Parent = b
        b.MouseButton1Click:Connect(function()
            if cb then cb() end
        end)
        return b
    end

    local function addDrop(parent, label, options, cb)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0,26)
        f.BackgroundTransparency = 1
        f.Parent = parent

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.42,0,1,0)
        l.BackgroundTransparency = 1
        l.Text = label
        l.TextColor3 = Color3.fromRGB(210,210,230)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.56,0,0,22)
        btn.Position = UDim2.new(0.44,0,0.5,-11)
        btn.BackgroundColor3 = Color3.fromRGB(28,28,38)
        btn.Text = options[1]
        btn.TextColor3 = Color3.fromRGB(200,180,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = f
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)

        local idx = 1
        btn.MouseButton1Click:Connect(function()
            idx = idx % #options + 1
            btn.Text = options[idx]
            if cb then cb(options[idx]) end
        end)
        return function() return options[idx] end
    end

    -- state
    local farmOn, autoEquip, gather, autoQuest = false, true, true, false
    local heightMode = "Under"
    local weaponType = "Any"
    local espOn, espMobs, espPlr = false, true, true

    -- FARM PAGE
    local Farm = pages["Farm"]
    addToggle(Farm, "Auto Farm", false, function(v) farmOn = v end)
    addToggle(Farm, "Auto Equip Weapon", true, function(v) autoEquip = v end)
    addToggle(Farm, "Gather Mobs", true, function(v) gather = v end)
    addDrop(Farm, "Hit Height", {"Under Floor","Above Head","Side Safe"}, function(v)
        if v:find("Under") then heightMode = "Under"
        elseif v:find("Above") then heightMode = "Above"
        else heightMode = "Side" end
    end)
    addDrop(Farm, "Weapon", {"Any","Sword","Katana","Fist"}, function(v) weaponType = v end)

    addBtn(Farm, "Kill Aura Pulse", function()
        local char = LocalPlayer.Character
        if not char then return end
        local myPos = char:GetPivot().Position
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and m \~= char then
                if m.Humanoid.Health > 0 and (m.HumanoidRootPart.Position - myPos).Magnitude < 70 then
                    safe(function()
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end)
                end
            end
        end
    end)

    -- QUEST PAGE
    local Quest = pages["Quest"]
    addToggle(Quest, "Auto Quest", false, function(v) autoQuest = v end)
    addBtn(Quest, "Force Accept Nearest", function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                safe(function() fireproximityprompt(v) end)
            end
        end
    end)

    -- TP PAGE
    local TP = pages["TP"]
    local places = {
        {"Spawn", CFrame.new(0,10,0)},
        {"Training", CFrame.new(120,10,-40)},
        {"Forest", CFrame.new(-200,15,150)},
        {"Mountain", CFrame.new(300,80,-100)},
        {"Village", CFrame.new(-80,12,220)},
        {"Demon Cave", CFrame.new(450,5,-300)},
        {"Boss Arena", CFrame.new(0,20,400)},
    }
    for _,p in ipairs(places) do
        addBtn(TP, "TP → "..p[1], function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = p[2] + Vector3.new(0,3,0)
            end
        end)
    end
    addBtn(TP, "TP Nearest Mob", function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local closest, dist = nil, 9999
        local my = char.HumanoidRootPart.Position
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and m \~= char then
                if m.Humanoid.Health > 0 then
                    local d = (m.HumanoidRootPart.Position - my).Magnitude
                    if d < dist then dist = d closest = m end
                end
            end
        end
        if closest then
            char.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0,0,5)
        end
    end)

    -- ESP PAGE (safe – only if Drawing exists)
    local ESP = pages["ESP"]
    local hasDrawing = (typeof(Drawing) == "table" or typeof(Drawing) == "userdata")
    addToggle(ESP, "ESP Master", false, function(v) espOn = v end)
    addToggle(ESP, "Mobs", true, function(v) espMobs = v end)
    addToggle(ESP, "Players", true, function(v) espPlr = v end)
    if not hasDrawing then
        local warn = Instance.new("TextLabel")
        warn.Size = UDim2.new(1,0,0,20)
        warn.BackgroundTransparency = 1
        warn.Text = "Drawing API não disponível neste executor"
        warn.TextColor3 = Color3.fromRGB(255,160,80)
        warn.Font = Enum.Font.Gotham
        warn.TextSize = 11
        warn.Parent = ESP
    end

    local drawings = {}
    local function clearDraw()
        for _,d in pairs(drawings) do safe(function() d:Remove() end) end
        drawings = {}
    end

    if hasDrawing then
        RunService.RenderStepped:Connect(function()
            if not espOn then clearDraw() return end
            clearDraw()
            local function box(model, col)
                local root = model:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if not vis then return end
                local sq = Drawing.new("Square")
                sq.Size = Vector2.new(28,38)
                sq.Position = Vector2.new(pos.X-14, pos.Y-19)
                sq.Color = col
                sq.Thickness = 1
                sq.Filled = false
                sq.Visible = true
                table.insert(drawings, sq)
                local t = Drawing.new("Text")
                t.Text = model.Name
                t.Size = 12
                t.Position = Vector2.new(pos.X, pos.Y-28)
                t.Color = col
                t.Center = true
                t.Outline = true
                t.Visible = true
                table.insert(drawings, t)
            end
            if espMobs then
                for _,m in ipairs(workspace:GetDescendants()) do
                    if m:IsA("Model") and m:FindFirstChild("Humanoid") and m \~= LocalPlayer.Character then
                        box(m, Color3.fromRGB(255,80,120))
                    end
                end
            end
            if espPlr then
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr \~= LocalPlayer and plr.Character then
                        box(plr.Character, Color3.fromRGB(80,200,255))
                    end
                end
            end
        end)
    end

    -- MISC
    local Misc = pages["Misc"]
    addToggle(Misc, "FPS Unlock", false, function(v)
        safe(function() if setfpscap then setfpscap(v and 0 or 60) end end)
    end)
    addToggle(Misc, "Bright / No Fog", false, function(v)
        if v then
            game.Lighting.FogEnd = 9e9
            game.Lighting.Brightness = 2.2
        end
    end)
    addBtn(Misc, "Rejoin", function()
        safe(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end)

    -- ===================== FARM LOOP =====================
    local function getChar()
        return LocalPlayer.Character
    end

    local function equip()
        if not autoEquip then return end
        local char = getChar()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not char or not bp then return end
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if weaponType == "Any"
                or (weaponType == "Sword" and (n:find("sword") or n:find("blade")))
                or (weaponType == "Katana" and n:find("katana"))
                or (weaponType == "Fist" and (n:find("fist") or n:find("hand"))) then
                    safe(function() char.Humanoid:EquipTool(t) end)
                    break
                end
            end
        end
    end

    local function offset()
        if heightMode == "Under" then return Vector3.new(0,-7,0)
        elseif heightMode == "Above" then return Vector3.new(0,11,0)
        else return Vector3.new(5,2,0) end
    end

    task.spawn(function()
        while true do
            task.wait(0.16)
            if not farmOn then continue end
            local char = getChar()
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            equip()

            local target, dist = nil, 100
            for _,m in ipairs(workspace:GetDescendants()) do
                if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and m \~= char then
                    if m.Humanoid.Health > 0 then
                        local d = (m.HumanoidRootPart.Position - root.Position).Magnitude
                        if d < dist then dist = d target = m end
                    end
                end
            end

            if target then
                local tRoot = target.HumanoidRootPart
                root.CFrame = CFrame.new(tRoot.Position + offset())

                if gather then
                    for _,m in ipairs(workspace:GetDescendants()) do
                        if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and m \~= char and m \~= target then
                            if m.Humanoid and m.Humanoid.Health > 0 then
                                local d = (m.HumanoidRootPart.Position - tRoot.Position).Magnitude
                                if d < 30 then
                                    safe(function()
                                        m.HumanoidRootPart.CFrame = tRoot.CFrame * CFrame.new(math.random(-2,2),0,math.random(-2,2))
                                    end)
                                end
                            end
                        end
                    end
                end

                safe(function()
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end)
            end
        end
    end)

    -- auto quest loop
    task.spawn(function()
        while true do
            task.wait(2.2)
            if not autoQuest then continue end
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = (v.Parent and v.Parent.Name or ""):lower()
                    if n:find("quest") or n:find("npc") or n:find("mission") or n:find("board") then
                        safe(function() fireproximityprompt(v) end)
                    end
                end
            end
        end
    end)

    notify("VOID.LAZY", "Carregado")
end
