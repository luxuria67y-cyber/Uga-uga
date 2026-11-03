--[[
    VOID.LAZY  |  SLAYERS 2  (Assassin / Demon Slayer)
    Mobile Delta / Fluxus / Codex ready
    Password: leyzepidao
    Soft anti-detection layer + smooth lerp UI
]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Anti-detection soft layer
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui = syn.protect_gui end
    if getgenv then getgenv().VOID_LAZY = true end
    setfpscap = setfpscap or function() end
end)

local function safeFire(remote, ...)
    if not remote then return end
    task.spawn(function()
        task.wait(math.random(4,12)/100)
        pcall(remote.FireServer, remote, ...)
    end)
end

-- // Password Gate + Intro
local PASS = "leyzepidao"
local unlocked = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VOID_LAZY_" .. HttpService:GenerateGUID(false)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end
end)

local Intro = Instance.new("Frame")
Intro.Size = UDim2.new(1,0,1,0)
Intro.BackgroundColor3 = Color3.fromRGB(8,8,12)
Intro.BorderSizePixel = 0
Intro.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,60)
Title.Position = UDim2.new(0,0,0.42,0)
Title.BackgroundTransparency = 1
Title.Text = ""
Title.TextColor3 = Color3.fromRGB(180,60,255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 32
Title.Parent = Intro

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1,0,0,30)
Sub.Position = UDim2.new(0,0,0.52,0)
Sub.BackgroundTransparency = 1
Sub.Text = ""
Sub.TextColor3 = Color3.fromRGB(200,200,220)
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 16
Sub.Parent = Intro

local PassBox = Instance.new("TextBox")
PassBox.Size = UDim2.new(0,220,0,36)
PassBox.Position = UDim2.new(0.5,-110,0.62,0)
PassBox.BackgroundColor3 = Color3.fromRGB(20,20,28)
PassBox.BorderSizePixel = 0
PassBox.Text = ""
PassBox.PlaceholderText = "senha"
PassBox.TextColor3 = Color3.fromRGB(220,220,255)
PassBox.Font = Enum.Font.Gotham
PassBox.TextSize = 15
PassBox.Visible = false
PassBox.Parent = Intro
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0,8)

local function typeText(label, text, speed)
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text,1,i)
        task.wait(speed or 0.035)
    end
end

task.spawn(function()
    typeText(Title, "Bem-vindo a VOID.LAZY", 0.04)
    task.wait(0.3)
    typeText(Sub, "Slayers 2  •  Mobile Edition", 0.03)
    task.wait(0.4)
    PassBox.Visible = true
    PassBox:CaptureFocus()
end)

PassBox.FocusLost:Connect(function(enter)
    if enter and PassBox.Text:lower() == PASS then
        unlocked = true
        TweenService:Create(Intro, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        Title.TextTransparency = 1
        Sub.TextTransparency = 1
        PassBox.Visible = false
        task.wait(0.65)
        Intro:Destroy()
        loadMain()
    else
        PassBox.Text = ""
        PassBox.PlaceholderText = "errada"
    end
end)

-- // Main UI
function loadMain()
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 340, 0, 420)
    Main.Position = UDim2.new(0.5, -170, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(12,12,18)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(140,40,255)
    Stroke.Thickness = 1.5
    Stroke.Parent = Main

    -- Drag (mobile friendly)
    local dragging, dragStart, startPos
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1,0,0,38)
    TopBar.BackgroundColor3 = Color3.fromRGB(18,18,26)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0,12)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1,-40,1,0)
    TitleLbl.Position = UDim2.new(0,12,0,0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = "VOID.LAZY  •  SLAYERS 2"
    TitleLbl.TextColor3 = Color3.fromRGB(190,80,255)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0,28,0,28)
    Close.Position = UDim2.new(1,-34,0.5,-14)
    Close.BackgroundColor3 = Color3.fromRGB(40,20,50)
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(255,100,140)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 18
    Close.Parent = TopBar
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)
    Close.MouseButton1Click:Connect(function()
        Main:Destroy()
    end)

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tabs
    local Tabs = {"Farm","Quest","TP","ESP","Misc","Settings"}
    local TabButtons = {}
    local Pages = {}
    local CurrentPage = nil

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1,-16,0,32)
    TabFrame.Position = UDim2.new(0,8,0,44)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = Main

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1,-16,1,-90)
    Content.Position = UDim2.new(0,8,0,82)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = Main

    local function makeToggle(parent, name, default, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1,0,0,28)
        holder.BackgroundTransparency = 1
        holder.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,-50,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.fromRGB(210,210,230)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = holder

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,42,0,22)
        btn.Position = UDim2.new(1,-42,0.5,-11)
        btn.BackgroundColor3 = default and Color3.fromRGB(120,40,200) or Color3.fromRGB(35,35,45)
        btn.Text = ""
        btn.Parent = holder
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                BackgroundColor3 = state and Color3.fromRGB(120,40,200) or Color3.fromRGB(35,35,45)
            }):Play()
            if callback then callback(state) end
        end)
        return function() return state end
    end

    local function makeButton(parent, text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,30)
        b.BackgroundColor3 = Color3.fromRGB(28,20,40)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(200,160,255)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 13
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(100,40,180)
        s.Thickness = 1
        s.Parent = b
        b.MouseButton1Click:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(60,30,90)}):Play()
            task.wait(0.12)
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28,20,40)}):Play()
            if callback then callback() end
        end)
        return b
    end

    local function makeDropdown(parent, name, options, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1,0,0,28)
        holder.BackgroundTransparency = 1
        holder.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.fromRGB(210,210,230)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = holder

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.58,0,0,24)
        btn.Position = UDim2.new(0.42,0,0.5,-12)
        btn.BackgroundColor3 = Color3.fromRGB(25,25,35)
        btn.Text = options[1] or "..."
        btn.TextColor3 = Color3.fromRGB(200,180,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = holder
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)

        local idx = 1
        btn.MouseButton1Click:Connect(function()
            idx = idx % #options + 1
            btn.Text = options[idx]
            if callback then callback(options[idx], idx) end
        end)
        return function() return options[idx] end
    end

    -- Create pages
    for i, name in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1/#Tabs, -4, 1, 0)
        btn.Position = UDim2.new((i-1)/#Tabs, 2, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(22,22,30)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(160,160,180)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = TabFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        TabButtons[name] = btn

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(120,40,200)
        page.CanvasSize = UDim2.new(0,0,0,600)
        page.Visible = false
        page.Parent = Content
        Pages[name] = page

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0,6)
        list.Parent = page
        list.SortOrder = Enum.SortOrder.LayoutOrder
    end

    local function switch(name)
        for n,p in pairs(Pages) do p.Visible = false end
        for n,b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(22,22,30)
            b.TextColor3 = Color3.fromRGB(160,160,180)
        end
        Pages[name].Visible = true
        TabButtons[name].BackgroundColor3 = Color3.fromRGB(50,25,80)
        TabButtons[name].TextColor3 = Color3.fromRGB(220,160,255)
        CurrentPage = name
    end

    for name,btn in pairs(TabButtons) do
        btn.MouseButton1Click:Connect(function() switch(name) end)
    end
    switch("Farm")

    -- ===================== FARM =====================
    local FarmPage = Pages["Farm"]
    local farmEnabled = false
    local heightMode = "Under" -- Under / Above / Side
    local selectedWeapon = "Sword"
    local autoEquip = true
    local gatherMobs = true
    local attackSpeed = 0.18

    makeToggle(FarmPage, "Auto Farm (Quest Sync)", false, function(v) farmEnabled = v end)
    makeToggle(FarmPage, "Auto Equip Weapon", true, function(v) autoEquip = v end)
    makeToggle(FarmPage, "Gather Mobs (bring to you)", true, function(v) gatherMobs = v end)

    local getHeight = makeDropdown(FarmPage, "Hit Height", {"Under Floor","Above Head","Side Safe"}, function(val)
        if val:find("Under") then heightMode = "Under"
        elseif val:find("Above") then heightMode = "Above"
        else heightMode = "Side" end
    end)

    local getWeapon = makeDropdown(FarmPage, "Weapon Type", {"Sword","Fist","Katana","Any"}, function(val)
        selectedWeapon = val
    end)

    makeButton(FarmPage, "Kill Aura Pulse", function()
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m \~= LocalPlayer.Character then
                local hum = m:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 and (m:GetPivot().Position - LocalPlayer.Character:GetPivot().Position).Magnitude < 80 then
                    pcall(function()
                        local root = m:FindFirstChild("HumanoidRootPart")
                        if root then
                            -- soft damage attempt via common remotes
                            local rem = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
                            for _,r in ipairs(rem:GetDescendants()) do
                                if r:IsA("RemoteEvent") and (r.Name:lower():find("damage") or r.Name:lower():find("hit") or r.Name:lower():find("attack")) then
                                    safeFire(r, m, 999)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)

    -- ===================== QUEST =====================
    local QuestPage = Pages["Quest"]
    local autoQuest = false
    makeToggle(QuestPage, "Auto Quest (accept + complete)", false, function(v) autoQuest = v end)
    makeToggle(QuestPage, "Auto Turn-in", true, function() end)

    makeButton(QuestPage, "Force Accept Nearest Quest", function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") or (v:IsA("ClickDetector") and v.Parent and v.Parent.Name:lower():find("quest")) then
                pcall(function()
                    fireproximityprompt(v)
                end)
            end
        end
    end)

    -- ===================== TELEPORT =====================
    local TPPage = Pages["TP"]
    local maps = {
        ["Spawn"] = CFrame.new(0,10,0),
        ["Training Ground"] = CFrame.new(120,10,-40),
        ["Forest"] = CFrame.new(-200,15,150),
        ["Mountain"] = CFrame.new(300,80,-100),
        ["Village"] = CFrame.new(-80,12,220),
        ["Demon Cave"] = CFrame.new(450,5,-300),
        ["Boss Arena"] = CFrame.new(0,20,400),
    }

    for name,cf in pairs(maps) do
        makeButton(TPPage, "TP → "..name, function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = cf + Vector3.new(0,3,0)
            end
        end)
    end

    makeButton(TPPage, "TP to Nearest Mob", function()
        local closest, dist = nil, 9999
        local myPos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position
        if not myPos then return end
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and m \~= LocalPlayer.Character then
                local d = (m.HumanoidRootPart.Position - myPos).Magnitude
                if d < dist and m.Humanoid.Health > 0 then
                    dist = d
                    closest = m
                end
            end
        end
        if closest then
            LocalPlayer.Character.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0,0,4)
        end
    end)

    -- ===================== ESP =====================
    local ESPPage = Pages["ESP"]
    local espEnabled = false
    local espMobs = true
    local espPlayers = true
    local drawings = {}

    makeToggle(ESPPage, "ESP Master", false, function(v) espEnabled = v end)
    makeToggle(ESPPage, "Show Mobs", true, function(v) espMobs = v end)
    makeToggle(ESPPage, "Show Players", true, function(v) espPlayers = v end)

    local function clearESP()
        for _,d in pairs(drawings) do
            if d and d.Remove then pcall(d.Remove, d) end
        end
        drawings = {}
    end

    RunService.RenderStepped:Connect(function()
        if not espEnabled then
            clearESP()
            return
        end
        clearESP()
        local function addBox(model, color)
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            if not root then return end
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local box = Drawing.new("Square")
                box.Size = Vector2.new(30,40)
                box.Position = Vector2.new(pos.X-15, pos.Y-20)
                box.Color = color
                box.Thickness = 1
                box.Filled = false
                box.Visible = true
                table.insert(drawings, box)

                local txt = Drawing.new("Text")
                txt.Text = model.Name
                txt.Size = 13
                txt.Position = Vector2.new(pos.X, pos.Y-30)
                txt.Color = color
                txt.Center = true
                txt.Outline = true
                txt.Visible = true
                table.insert(drawings, txt)
            end
        end
        if espMobs then
            for _,m in ipairs(workspace:GetDescendants()) do
                if m:IsA("Model") and m:FindFirstChild("Humanoid") and m \~= LocalPlayer.Character then
                    addBox(m, Color3.fromRGB(255,80,120))
                end
            end
        end
        if espPlayers then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr \~= LocalPlayer and plr.Character then
                    addBox(plr.Character, Color3.fromRGB(80,200,255))
                end
            end
        end
    end)

    -- ===================== MISC =====================
    local MiscPage = Pages["Misc"]
    makeToggle(MiscPage, "FPS Unlock (mobile)", false, function(v)
        if v then pcall(setfpscap, 0) else pcall(setfpscap, 60) end
    end)
    makeToggle(MiscPage, "No Fog / Bright", false, function(v)
        if v then
            game.Lighting.FogEnd = 1e6
            game.Lighting.Brightness = 2
        end
    end)
    makeToggle(MiscPage, "Inf Jump", false, function(v)
        if v then
            LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    makeButton(MiscPage, "Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)

    makeButton(MiscPage, "Server Hop", function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        for _,s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id \~= game.JobId then
                table.insert(servers, s.id)
            end
        end
        if #servers > 0 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)])
        end
    end)

    -- ===================== SETTINGS =====================
    local SettingsPage = Pages["Settings"]
    makeToggle(SettingsPage, "Soft Anti-Detect (delay fires)", true, function() end)
    makeButton(SettingsPage, "Destroy UI", function()
        ScreenGui:Destroy()
    end)

    -- ===================== CORE FARM LOOP =====================
    local function getChar()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end

    local function equipWeapon()
        if not autoEquip then return end
        local char = getChar()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end
        for _,tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if selectedWeapon == "Any" or
                   (selectedWeapon == "Sword" and (n:find("sword") or n:find("katana") or n:find("blade"))) or
                   (selectedWeapon == "Fist" and (n:find("fist") or n:find("hand") or n:find("punch"))) or
                   (selectedWeapon == "Katana" and n:find("katana")) then
                    char.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end

    local function getOffset()
        if heightMode == "Under" then return Vector3.new(0,-8,0)
        elseif heightMode == "Above" then return Vector3.new(0,12,0)
        else return Vector3.new(6,2,0) end
    end

    task.spawn(function()
        while task.wait(attackSpeed) do
            if not farmEnabled then continue end
            local char = getChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            equipWeapon()

            -- find closest alive mob
            local target, dist = nil, 120
            for _,m in ipairs(workspace:GetDescendants()) do
                if m:IsA("Model") and m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") and m \~= char then
                    local hum = m.Humanoid
                    if hum.Health > 0 then
                        local d = (m.HumanoidRootPart.Position - root.Position).Magnitude
                        if d < dist then
                            dist = d
                            target = m
                        end
                    end
                end
            end

            if target then
                local tRoot = target.HumanoidRootPart
                local offset = getOffset()
                -- position under / above / side
                root.CFrame = CFrame.new(tRoot.Position + offset)

                if gatherMobs then
                    -- soft pull nearby
                    for _,m in ipairs(workspace:GetDescendants()) do
                        if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and m \~= char and m \~= target then
                            local d = (m.HumanoidRootPart.Position - tRoot.Position).Magnitude
                            if d < 35 and m.Humanoid.Health > 0 then
                                pcall(function()
                                    m.HumanoidRootPart.CFrame = tRoot.CFrame * CFrame.new(math.random(-3,3),0,math.random(-3,3))
                                end)
                            end
                        end
                    end
                end

                -- attack attempt
                pcall(function()
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    -- try common damage remotes
                    local remFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage
                    for _,r in ipairs(remFolder:GetDescendants()) do
                        if r:IsA("RemoteEvent") then
                            local n = r.Name:lower()
                            if n:find("damage") or n:find("hit") or n:find("attack") or n:find("swing") or n:find("combat") then
                                safeFire(r, target, math.random(50,120))
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- Auto Quest soft loop
    task.spawn(function()
        while task.wait(2.5) do
            if not autoQuest then continue end
            pcall(function()
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        local n = (v.Parent and v.Parent.Name or ""):lower()
                        if n:find("quest") or n:find("npc") or n:find("mission") then
                            fireproximityprompt(v)
                        end
                    end
                end
            end)
        end
    end)

    -- Mobile notification
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "VOID.LAZY",
            Text = "Slayers 2 loaded • mobile ready",
            Duration = 4
        })
    end)
end
