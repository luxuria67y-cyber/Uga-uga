--[[
    Script: Slayers 2 (VOID.LAZY Hub - Delta Mobile Fix)
    Platform: Roblox Mobile (Delta Executor)
    Author: HOLLOW
]]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cleanup prior instances safely using pcall
pcall(function()
    if CoreGui:FindFirstChild("VoidLazySlayers2") then
        CoreGui.VoidLazySlayers2:Destroy()
    end
end)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidLazySlayers2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Fallback parent strategy for mobile executors (Delta compatibility)
local parentSuccess = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not parentSuccess then
    ScreenGui.Parent = PlayerGui
end

-- Notification System
local function notify(title, text, duration)
    pcall(function()
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 260, 0, 60)
        notif.Position = UDim2.new(1, -280, 0, 20)
        notif.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        notif.BorderSizePixel = 0
        notif.Parent = ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = notif

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(138, 43, 226)
        stroke.Transparency = 0.5
        stroke.Parent = notif

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -15, 0, 20)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 14
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Text = title
        titleLabel.Parent = notif

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -15, 0, 25)
        textLabel.Position = UDim2.new(0, 10, 0, 25)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        textLabel.TextSize = 12
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextWrapped = true
        textLabel.Text = text
        textLabel.Parent = notif

        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 0, 20)}):Play()
        
        task.delay(duration or 3, function()
            pcall(function()
                local tw = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, 20)})
                tw:Play()
                tw.Completed:Connect(function()
                    notif:Destroy()
                end)
            end)
        end)
    end)
end

-- Key System GUI
local KeyGui = Instance.new("Frame")
KeyGui.Size = UDim2.new(0, 320, 0, 210)
KeyGui.Position = UDim2.new(0.5, -160, 0.5, -105)
KeyGui.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
KeyGui.BorderSizePixel = 0
KeyGui.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 12)
KeyCorner.Parent = KeyGui

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(138, 43, 226)
KeyStroke.Transparency = 0.3
KeyStroke.Parent = KeyGui

local TitleKey = Instance.new("TextLabel")
TitleKey.Size = UDim2.new(1, 0, 0, 40)
TitleKey.Position = UDim2.new(0, 0, 0, 15)
TitleKey.BackgroundTransparency = 1
TitleKey.Text = "VOID.LAZY // SLAYERS 2"
TitleKey.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleKey.TextSize = 16
TitleKey.Font = Enum.Font.GothamBold
TitleKey.Parent = KeyGui

local SubKey = Instance.new("TextLabel")
SubKey.Size = UDim2.new(1, 0, 0, 20)
SubKey.Position = UDim2.new(0, 0, 0, 45)
SubKey.BackgroundTransparency = 1
SubKey.Text = "Insira a senha de acesso"
SubKey.TextColor3 = Color3.fromRGB(140, 140, 160)
SubKey.TextSize = 12
SubKey.Font = Enum.Font.Gotham
SubKey.Parent = KeyGui

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0, 260, 0, 40)
TextBox.Position = UDim2.new(0.5, -130, 0, 80)
TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TextBox.BorderSizePixel = 0
TextBox.PlaceholderText = "Senha..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
TextBox.TextSize = 14
TextBox.Font = Enum.Font.Gotham
TextBox.Parent = KeyGui

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = TextBox

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0, 260, 0, 40)
SubmitBtn.Position = UDim2.new(0.5, -130, 0, 135)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(110, 30, 190)
SubmitBtn.BorderSizePixel = 0
SubmitBtn.Text = "ENTRAR"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = KeyGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SubmitBtn

-- Main Hub UI Creation (Hidden initially)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 300)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Topbar for dragging (Mobile touch support)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(0, 200, 1, 0)
HubTitle.Position = UDim2.new(0, 15, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "VOID.LAZY // Slayers 2"
HubTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
HubTitle.TextSize = 13
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Parent = TopBar

-- Tab Navigation Container
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(0, 115, 1, -45)
TabContainer.Position = UDim2.new(0, 10, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 200)
TabContainer.ScrollBarThickness = 2
TabContainer.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabContainer

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -45)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local tabs = {}

local function createTab(name, index)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 35)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.LayoutOrder = index
    tabBtn.Parent = TabContainer

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 6)
    tc.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 350)
    page.ScrollBarThickness = 3
    page.Visible = (index == 1)
    page.Parent = ContentContainer

    local pl = Instance.new("UIListLayout")
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 8)
    pl.Parent = page

    if index == 1 then
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 75)
    end

    table.insert(tabs, {Button = tabBtn, Page = page})

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 28), TextColor3 = Color3.fromRGB(150, 150, 170)}):Play()
        end
        page.Visible = true
        TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 20, 75), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    return page
end

-- UI Helpers for Elements
local function addToggle(page, text, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 36)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = page

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 6)
    tc.Parent = toggleFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -45, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 230)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = toggleFrame

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 22, 0, 22)
    box.Position = UDim2.new(1, -28, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    box.BorderSizePixel = 0
    box.Parent = toggleFrame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = box

    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(0, 14, 0, 14)
    inner.Position = UDim2.new(0.5, -7, 0.5, -7)
    inner.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel = 0
    inner.Parent = box

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 3)
    ic.Parent = inner

    local enabled = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggleFrame

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetTrans = enabled and 0 or 1
        local targetColor = enabled and Color3.fromRGB(45, 20, 75) or Color3.fromRGB(30, 30, 40)
        TweenService:Create(inner, TweenInfo.new(0.2), {BackgroundTransparency = targetTrans}):Play()
        TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        pcall(callback, enabled)
    end)
end

-- Create Pages
local farmPage = createTab("Farm", 1)
local combatPage = createTab("Combate", 2)
local settingsPage = createTab("Ajustes", 3)

-- Slayers 2 Mechanics Core & Feature Logic
local autoFarmMobs = false
local autoQuest = false
local autoBreathe = false
local antiDetection = true
local killAura = false

-- Anti-Detection Loop
task.spawn(function()
    while true do
        task.wait(25)
        if antiDetection then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    if hum.WalkSpeed > 0 and hum.WalkSpeed < 30 then
                        hum.WalkSpeed = 16 + (math.random(-1, 1) * 0.05)
                    end
                end
            end)
        end
    end
end)

-- Feature Implementations
addToggle(farmPage, "Auto Farm Mobs", function(state)
    autoFarmMobs = state
    notify("Auto Farm", state ? "Ativado!" : "Desativado.", 2)
    task.spawn(function()
        while autoFarmMobs do
            task.wait(0.4)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                for _, folderName in ipairs({"Mobs", "Enemies", "Entities", "NPCs"}) do
                    local folder = workspace:FindFirstChild(folderName)
                    if folder then
                        for _, enemy in ipairs(folder:GetChildren()) do
                            if not autoFarmMobs then break end
                            local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
                            local hum = enemy:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                repeat
                                    task.wait(0.1)
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
                                    end
                                until not autoFarmMobs or not enemy.Parent or hum.Health <= 0
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

addToggle(farmPage, "Auto Quest (Missões)", function(state)
    autoQuest = state
    notify("Auto Quest", state ? "Ativo." : "Desativado.", 2)
    task.spawn(function()
        while autoQuest do
            task.wait(3)
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        fireproximityprompt(obj)
                    end
                end
            end)
        end
    end)
end)

addToggle(combatPage, "Kill Aura", function(state)
    killAura = state
    task.spawn(function()
        while killAura do
            task.wait(0.2)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v ~= char and v:FindFirstChildOfClass("Humanoid") then
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        local hum = v:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            if (char.HumanoidRootPart.Position - hrp.Position).Magnitude < 15 then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

addToggle(combatPage, "Auto Skills (Respiração)", function(state)
    autoBreathe = state
    task.spawn(function()
        while autoBreathe do
            task.wait(1)
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            end)
        end
    end)
end)

addToggle(settingsPage, "Modo Anti-Detecção Máximo", function(state)
    antiDetection = state
    notify("Anti-Ban", state ? "Ligado." : "Desligado.", 2)
end)

-- Mobile Dragging Support for Main Frame
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Authentication Event Handler
SubmitBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == "leyzepidao" then
        KeyGui:TweenPosition(UDim2.new(0.5, -160, 1.5, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.5, true, function()
            KeyGui.Visible = false
            MainFrame.Visible = true
            MainFrame.Position = UDim2.new(0.5, -240, 1.5, 0)
            MainFrame:TweenPosition(UDim2.new(0.5, -240, 0.5, -150), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)
            notify("VOID.LAZY", "Slayers 2 carregado com sucesso!", 4)
        end)
    else
        TextBox.Text = ""
        TextBox.PlaceholderText = "Senha incorreta!"
        task.delay(1.5, function()
            TextBox.PlaceholderText = "Senha..."
        end)
    end
end)
