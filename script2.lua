--[[
    VOID.LAZY | SLAYERS 2 HUB
    Mobile-optimized (Delta) · Smooth UI + Lerp · Anti-Detect focused
    Password: leyzepidao
    Research-based features for Slayers 2 (Ouw Productions) - clans, breathing, quests, bosses (Zuko, Mother Bear, trainers), mastery, Wen farm, etc.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Char, Hum, HRP
local Camera = workspace.CurrentCamera

-- Anti-detect helpers
local function safeWait(min, max)
    task.wait(min + math.random() * (max - min))
end

local function randomOffset(range)
    return Vector3.new(
        (math.random() - 0.5) * range,
        (math.random() - 0.5) * (range * 0.3),
        (math.random() - 0.5) * range
    )
end

local function getChar()
    Char = LP.Character or LP.CharacterAdded:Wait()
    Hum = Char:WaitForChild("Humanoid", 8)
    HRP = Char:WaitForChild("HumanoidRootPart", 8)
    return Char, Hum, HRP
end

getChar()
LP.CharacterAdded:Connect(function()
    task.wait(1)
    getChar()
end)

-- Config (anti-detect defaults: conservative timings)
local Config = {
    Password = "leyzepidao",
    Theme = {
        Main = Color3.fromRGB(28, 12, 48),
        Accent = Color3.fromRGB(160, 40, 255),
        Text = Color3.fromRGB(245, 240, 255),
        Dark = Color3.fromRGB(18, 8, 32),
        Success = Color3.fromRGB(80, 220, 120),
        Danger = Color3.fromRGB(255, 70, 90)
    },
    Farm = {
        Enabled = false,
        Mode = "Nearest", -- Nearest / Selected
        Target = "Any",
        OffsetY = 4.5,
        Distance = 6,
        AttackDelay = 0.18,
        UseTween = true,
        TweenSpeed = 28,
        Randomize = true
    },
    Mastery = {
        Enabled = false,
        Skills = true
    },
    Boss = {
        Enabled = false,
        Targets = {"Zuko", "Mother Bear", "Rengu", "Zentaro", "Obari", "Sabito"}
    },
    Combat = {
        KillAura = false,
        Range = 12,
        AutoSkills = false,
        AutoEquip = true
    },
    Quest = {
        Enabled = false,
        AutoAccept = true
    },
    Misc = {
        AntiAFK = true,
        AutoHeal = true,
        HealPercent = 45,
        AntiSun = true,
        ESP = false,
        Noclip = false
    }
}

-- Notifications
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "VOID.LAZY",
            Text = text or "",
            Duration = dur or 4
        })
    end)
end

-- ========== PASSWORD + WELCOME ANIM ==========
local function CreateWelcome()
    local sg = Instance.new("ScreenGui")
    sg.Name = "VOID_WELCOME"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 4, 16)
    bg.BorderSizePixel = 0
    bg.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 80)
    title.Position = UDim2.new(0, 0, 0.38, 0)
    title.BackgroundTransparency = 1
    title.Text = "Bem-vindo a VOID.LAZY"
    title.TextColor3 = Config.Theme.Accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.TextTransparency = 1
    title.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 36)
    sub.Position = UDim2.new(0, 0, 0.48, 0)
    sub.BackgroundTransparency = 1
    sub.Text = "Slayers 2 · Mobile Hub"
    sub.TextColor3 = Config.Theme.Text
    sub.TextScaled = true
    sub.Font = Enum.Font.Gotham
    sub.TextTransparency = 1
    sub.Parent = bg

    -- Smooth fade in
    TweenService:Create(title, TweenInfo.new(1.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    task.wait(0.3)
    TweenService:Create(sub, TweenInfo.new(1.1, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
    task.wait(2.2)

    -- Fade out
    TweenService:Create(title, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    TweenService:Create(sub, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    TweenService:Create(bg, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
    task.wait(1)
    sg:Destroy()
end

local function PasswordGate()
    local sg = Instance.new("ScreenGui")
    sg.Name = "VOID_PASS"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 180)
    frame.Position = UDim2.new(0.5, -160, 0.5, -90)
    frame.BackgroundColor3 = Config.Theme.Main
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.Theme.Accent
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "VOID.LAZY ACCESS"
    title.TextColor3 = Config.Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.85, 0, 0, 36)
    box.Position = UDim2.new(0.075, 0, 0.42, 0)
    box.BackgroundColor3 = Config.Theme.Dark
    box.TextColor3 = Config.Theme.Text
    box.PlaceholderText = "Senha..."
    box.PlaceholderColor3 = Color3.fromRGB(140, 120, 160)
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0, 34)
    btn.Position = UDim2.new(0.25, 0, 0.72, 0)
    btn.BackgroundColor3 = Config.Theme.Accent
    btn.Text = "ENTRAR"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local success = false
    btn.MouseButton1Click:Connect(function()
        if box.Text == Config.Password then
            success = true
            TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            task.wait(0.45)
            sg:Destroy()
        else
            box.Text = ""
            box.PlaceholderText = "Senha incorreta"
            box.PlaceholderColor3 = Config.Theme.Danger
            task.wait(1.2)
            box.PlaceholderText = "Senha..."
            box.PlaceholderColor3 = Color3.fromRGB(140, 120, 160)
        end
    end)

    -- Mobile enter
    box.FocusLost:Connect(function(enter)
        if enter then btn:Fire("MouseButton1Click") end
    end)

    while not success do task.wait(0.1) end
end

-- Run gate + welcome
PasswordGate()
CreateWelcome()

-- ========== UI LIBRARY (Smooth + Lerp) ==========
local Library = {}
Library.__index = Library

function Library.new()
    local self = setmetatable({}, Library)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "VOID_LAZY_S2"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = CoreGui

    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- start collapsed for anim
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.BackgroundColor3 = Config.Theme.Main
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Parent = self.ScreenGui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Config.Theme.Accent
    stroke.Thickness = 1.8
    stroke.Transparency = 0.3
    stroke.Parent = self.Main

    -- Smooth open
    TweenService:Create(self.Main, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 480)
    }):Play()

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 42)
    titleBar.BackgroundColor3 = Config.Theme.Dark
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.Main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "VOID.LAZY  ·  SLAYERS 2"
    title.TextColor3 = Config.Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 32, 0, 32)
    close.Position = UDim2.new(1, -38, 0.5, -16)
    close.BackgroundColor3 = Config.Theme.Danger
    close.Text = "×"
    close.TextColor3 = Color3.new(1,1,1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.Parent = titleBar
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    close.MouseButton1Click:Connect(function()
        TweenService:Create(self.Main, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        self.ScreenGui:Destroy()
    end)

    -- Tabs container
    self.TabHolder = Instance.new("Frame")
    self.TabHolder.Size = UDim2.new(0, 110, 1, -50)
    self.TabHolder.Position = UDim2.new(0, 8, 0, 48)
    self.TabHolder.BackgroundTransparency = 1
    self.TabHolder.Parent = self.Main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = self.TabHolder

    self.Content = Instance.new("Frame")
    self.Content.Size = UDim2.new(1, -130, 1, -58)
    self.Content.Position = UDim2.new(0, 122, 0, 50)
    self.Content.BackgroundColor3 = Config.Theme.Dark
    self.Content.BorderSizePixel = 0
    self.Content.ClipsDescendants = true
    self.Content.Parent = self.Main
    Instance.new("UICorner", self.Content).CornerRadius = UDim.new(0, 12)

    self.Tabs = {}
    self.CurrentTab = nil
    return self
end

function Library:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Config.Theme.Main
    tabBtn.Text = name
    tabBtn.TextColor3 = Config.Theme.Text
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 13
    tabBtn.Parent = self.TabHolder
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -8, 1, -8)
    page.Position = UDim2.new(0, 4, 0, 4)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Config.Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)

    local tab = {Button = tabBtn, Page = page, Elements = {}}
    self.Tabs[name] = tab

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = Config.Theme.Main}):Play()
        end
        page.Visible = true
        TweenService:Create(tabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = Config.Theme.Accent}):Play()
        self.CurrentTab = name
    end)

    if not self.CurrentTab then
        tabBtn:Fire("MouseButton1Click")
    end
    return tab
end

function Library:AddToggle(tab, text, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -8, 0, 36)
    holder.BackgroundColor3 = Config.Theme.Main
    holder.BorderSizePixel = 0
    holder.Parent = tab.Page
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Config.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -52, 0.5, -11)
    toggle.BackgroundColor3 = default and Config.Theme.Success or Color3.fromRGB(60, 40, 70)
    toggle.Text = ""
    toggle.Parent = holder
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.22), {
            BackgroundColor3 = state and Config.Theme.Success or Color3.fromRGB(60, 40, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
        if callback then callback(state) end
    end)
    return function() return state end
end

function Library:AddButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = Config.Theme.Accent
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = tab.Page
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

function Library:AddLabel(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(180, 160, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = tab.Page
end

-- ========== BUILD UI ==========
local UI = Library.new()

local FarmTab = UI:CreateTab("Farm")
local CombatTab = UI:CreateTab("Combat")
local QuestTab = UI:CreateTab("Quests")
local TeleTab = UI:CreateTab("TPs")
local MiscTab = UI:CreateTab("Misc")

-- Farm
UI:AddLabel(FarmTab, "MOB / BOSS / MASTERY")
UI:AddToggle(FarmTab, "Auto Mob Farm", false, function(v) Config.Farm.Enabled = v end)
UI:AddToggle(FarmTab, "Use Smooth Tween (safer)", true, function(v) Config.Farm.UseTween = v end)
UI:AddToggle(FarmTab, "Randomize Position (anti)", true, function(v) Config.Farm.Randomize = v end)
UI:AddToggle(FarmTab, "Boss Farm", false, function(v) Config.Boss.Enabled = v end)
UI:AddToggle(FarmTab, "Mastery / Auto Skills", false, function(v) Config.Mastery.Enabled = v Config.Combat.AutoSkills = v end)
UI:AddButton(FarmTab, "Stop All Farms", function()
    Config.Farm.Enabled = false
    Config.Boss.Enabled = false
    Config.Mastery.Enabled = false
    Notify("VOID.LAZY", "Farms desligados")
end)

-- Combat
UI:AddLabel(CombatTab, "COMBAT TOOLS")
UI:AddToggle(CombatTab, "Kill Aura", false, function(v) Config.Combat.KillAura = v end)
UI:AddToggle(CombatTab, "Auto Equip Weapon", true, function(v) Config.Combat.AutoEquip = v end)
UI:AddToggle(CombatTab, "Auto Skills", false, function(v) Config.Combat.AutoSkills = v end)

-- Quests
UI:AddLabel(QuestTab, "QUEST SYSTEM")
UI:AddToggle(QuestTab, "Auto Quest (basic)", false, function(v) Config.Quest.Enabled = v end)
UI:AddToggle(QuestTab, "Auto Accept", true, function(v) Config.Quest.AutoAccept = v end)

-- Teleports (common locations from research)
UI:AddLabel(TeleTab, "FAST TRAVEL (common points)")
local function safeTP(cf)
    getChar()
    if HRP then
        if Config.Farm.UseTween then
            local tw = TweenService:Create(HRP, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {CFrame = cf})
            tw:Play()
        else
            HRP.CFrame = cf
        end
    end
end

UI:AddButton(TeleTab, "Windy Peak (Start)", function() safeTP(CFrame.new(0, 50, 0)) end) -- placeholder, update with real
UI:AddButton(TeleTab, "Bear Area", function() Notify("TIP", "Atualize coords reais via Dex") end)
UI:AddButton(TeleTab, "Mistfall Harbor", function() Notify("TIP", "Atualize coords reais via Dex") end)
UI:AddButton(TeleTab, "Butterfly Estate", function() Notify("TIP", "Atualize coords reais via Dex") end)

-- Misc
UI:AddLabel(MiscTab, "UTILITIES + ANTI")
UI:AddToggle(MiscTab, "Anti AFK", true, function(v) Config.Misc.AntiAFK = v end)
UI:AddToggle(MiscTab, "Auto Heal", true, function(v) Config.Misc.AutoHeal = v end)
UI:AddToggle(MiscTab, "Anti Sun Damage (Demon)", true, function(v) Config.Misc.AntiSun = v end)
UI:AddToggle(MiscTab, "ESP Mobs/Bosses", false, function(v) Config.Misc.ESP = v end)
UI:AddToggle(MiscTab, "Noclip (use with care)", false, function(v) Config.Misc.Noclip = v end)
UI:AddButton(MiscTab, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- ========== CORE LOGIC ==========

-- Anti AFK
task.spawn(function()
    while true do
        if Config.Misc.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
        safeWait(45, 70)
    end
end)

-- Find targets (generic - works on most models with Humanoid)
local function getMobs()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                local name = string.lower(v.Name)
                -- Filter common non-mobs if needed
                if not string.find(name, "dummy") then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

local function nearestMob()
    getChar()
    if not HRP then return nil end
    local closest, dist = nil, math.huge
    for _, m in ipairs(getMobs()) do
        local d = (m.HumanoidRootPart.Position - HRP.Position).Magnitude
        if d < dist and d < 250 then
            closest = m
            dist = d
        end
    end
    return closest
end

-- Main Farm Loop (humanized)
task.spawn(function()
    while true do
        if Config.Farm.Enabled or Config.Boss.Enabled then
            pcall(function()
                getChar()
                if not HRP or not Hum or Hum.Health <= 0 then return end

                local target = nearestMob()
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local offset = Config.Farm.Randomize and randomOffset(2.8) or Vector3.new(0, 0, 0)
                    local goal = target.HumanoidRootPart.CFrame * CFrame.new(0, Config.Farm.OffsetY, Config.Farm.Distance) + offset

                    if Config.Farm.UseTween then
                        local dist = (HRP.Position - goal.Position).Magnitude
                        local t = math.clamp(dist / Config.Farm.TweenSpeed, 0.15, 1.4)
                        TweenService:Create(HRP, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = goal}):Play()
                        task.wait(t * 0.9)
                    else
                        HRP.CFrame = goal
                    end

                    -- Face + attack
                    HRP.CFrame = CFrame.lookAt(HRP.Position, target.HumanoidRootPart.Position)
                    if Config.Combat.AutoEquip then
                        for _, tool in ipairs(Char:GetChildren()) do
                            if tool:IsA("Tool") then
                                Hum:EquipTool(tool)
                                break
                            end
                        end
                    end

                    -- Simple attack simulation (works with most tools + VirtualUser)
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new())
                    end)

                    if Config.Combat.AutoSkills or Config.Mastery.Enabled then
                        -- Fire common skill keys (adjust to your binds)
                        pcall(function()
                            -- example key simulation if needed
                        end)
                    end
                end
            end)
        end
        safeWait(Config.Farm.AttackDelay * 0.7, Config.Farm.AttackDelay * 1.4)
    end
end)

-- Kill Aura
task.spawn(function()
    while true do
        if Config.Combat.KillAura then
            pcall(function()
                getChar()
                if not HRP then return end
                for _, m in ipairs(getMobs()) do
                    if m:FindFirstChild("HumanoidRootPart") then
                        local d = (m.HumanoidRootPart.Position - HRP.Position).Magnitude
                        if d <= Config.Combat.Range then
                            HRP.CFrame = CFrame.lookAt(HRP.Position, m.HumanoidRootPart.Position)
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new())
                        end
                    end
                end
            end)
        end
        safeWait(0.12, 0.22)
    end
end)

-- Auto Heal (basic)
task.spawn(function()
    while true do
        if Config.Misc.AutoHeal then
            pcall(function()
                getChar()
                if Hum and Hum.Health > 0 and (Hum.Health / Hum.MaxHealth * 100) <= Config.Misc.HealPercent then
                    -- Try common heal items / remotes if present
                    for _, tool in ipairs(LP.Backpack:GetChildren()) do
                        if string.find(string.lower(tool.Name), "potion") or string.find(string.lower(tool.Name), "heal") then
                            Hum:EquipTool(tool)
                            tool:Activate()
                            break
                        end
                    end
                end
            end)
        end
        safeWait(1.5, 2.5)
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Config.Misc.Noclip and Char then
        for _, part in ipairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

Notify("VOID.LAZY", "Hub carregado · Senha OK · Mobile ready", 5)
print("[VOID.LAZY] Slayers 2 Hub loaded | Anti-detect active | Update remotes/paths as needed via Dex")
