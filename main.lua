local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

local GH_HUE = 0 -- Global Hue for RGB optimization
local SHIELD_ENABLED = true -- For uninjection

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "SHIELD_PREMIUM" or v.Name == "SHIELD_WATERMARK" then v:Destroy() end
end


local SAC = {
    Combat = {
        Aimbot = false, 
        FOV = 150, 
        Smoothing = 0.05, 
        FOVVisible = true, 
        FOVColorValue = Color3.fromRGB(255, 255, 255),
        AimbotKey = Enum.KeyCode.F,
        AimbotAlwaysActive = false,
        WallCheck = true,
        AutoShoot = false, 
        ShootDelay = 0.2,
        Triggerbot = false
    },
    Visuals = {
        Box = false, 
        Name = false, 
        Health = false, 
        Line = false,
        Skeleton = false,
        SelfColor = false,
        SelfRGB = false,
        SelfColorValue = Color3.fromRGB(220, 220, 220),
        EnemyColor = false,
        EnemyColorValue = Color3.fromRGB(255, 60, 60),
        FieldOfView = 70,
        Fullbright = false
    },


    Movement = {
        Spin = false, 
        SpinSpeed = 100, 
        Fly = false, 
        FlySpeed = 50, 
        Noclip = false,
        Speed = 16,
        JumpPower = 50,
        InfiniteJump = false
    },
    World = {
        DarkMode = false,
        RGBWorld = false
    },
    Friends = {}, -- Whitelist for Aimbot and ESP
    Settings = {ResetTimer = 30}
}





local Cache = {}
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 100; FOV_Circle.Color = Color3.new(1,1,1); FOV_Circle.Visible = false

local Watermark = Instance.new("ScreenGui", CoreGui); Watermark.Name = "SHIELD_WATERMARK"
local WLbl = Instance.new("TextLabel", Watermark)
WLbl.Size = UDim2.new(0, 120, 0, 30); WLbl.Position = UDim2.new(0, 50, 0, 50)
WLbl.BackgroundTransparency = 1; WLbl.Text = "shield.wtf"; WLbl.Font = "GothamBold"
WLbl.TextSize = 18; WLbl.TextColor3 = Color3.new(1,1,1); WLbl.TextTransparency = 0.4

local w_vel = Vector2.new(1, 1)
task.spawn(function()
    while task.wait() do
        if not SHIELD_ENABLED then break end
        GH_HUE = tick() % 5 / 5
        WLbl.TextColor3 = Color3.fromHSV(GH_HUE, 1, 1)
        
        local pos = WLbl.AbsolutePosition
        local size = WLbl.AbsoluteSize
        local screen = Watermark.AbsoluteSize
        
        if pos.X <= 0 or pos.X + size.X >= screen.X then w_vel = Vector2.new(-w_vel.X, w_vel.Y) end
        if pos.Y <= 0 or pos.Y + size.Y >= screen.Y then w_vel = Vector2.new(w_vel.X, -w_vel.Y) end
        
        WLbl.Position = UDim2.new(0, pos.X + w_vel.X, 0, pos.Y + w_vel.Y)
    end
end)


local function GetColor(type)
    if type == "Self" then
        return SAC.Visuals.SelfRGB and Color3.fromHSV(GH_HUE, 1, 1) or SAC.Visuals.SelfColorValue
    else
        return SAC.Visuals.EnemyColorValue
    end
end


RunService.Heartbeat:Connect(function()
    if not SHIELD_ENABLED then return end
    
    -- Self Coloring
    if SAC.Visuals.SelfColor then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.Color = GetColor("Self")
                elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
                    v.Handle.Color = GetColor("Self")
                end
            end
        end
    end

    -- Enemy Coloring
    if SAC.Visuals.EnemyColor then
        for _, p in pairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            if char then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.Color = GetColor("Enemy")
                    elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
                        v.Handle.Color = GetColor("Enemy")
                    end
                end
            end
        end
    end
end)

local function DestroyESP(drawings)
    for _, obj in pairs(drawings) do
        if type(obj) == "table" then
            for _, sub in pairs(obj) do pcall(function() sub:Destroy() end) end
        else
            pcall(function() obj:Destroy() end)
        end
    end
end

task.spawn(function()
    while task.wait(SAC.Settings.ResetTimer) do
        if not SHIELD_ENABLED then break end
        for p, drawings in pairs(Cache) do
            if not p or not p.Parent then
                DestroyESP(drawings)
                Cache[p] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if Cache[p] then
        DestroyESP(Cache[p])
        Cache[p] = nil
    end
end)




local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "SHIELD_PREMIUM"
local Main = Instance.new("Frame", Screen); Main.Size = UDim2.new(0, 580, 0, 420); Main.Position = UDim2.new(0.5, -290, 0.5, -210); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Color3.fromRGB(45, 45, 45); MainStroke.Thickness = 1.5

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 160, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
local SidebarLine = Instance.new("Frame", Sidebar); SidebarLine.Size = UDim2.new(0, 1, 1, 0); SidebarLine.Position = UDim2.new(1, 0, 0, 0); SidebarLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45); SidebarLine.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "SHIELD"; Title.Font = "GothamBold"; Title.TextSize = 16; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1

local TabButtons = Instance.new("Frame", Sidebar); TabButtons.Size = UDim2.new(1, 0, 1, -60); TabButtons.Position = UDim2.new(0, 0, 0, 60); TabButtons.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabButtons); TabList.Padding = UDim.new(0, 5); TabList.HorizontalAlignment = "Center"

local PageContainer = Instance.new("Frame", Main); PageContainer.Size = UDim2.new(1, -175, 1, -20); PageContainer.Position = UDim2.new(0, 170, 0, 10); PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", PageContainer); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.CanvasSize = UDim2.new(0,0,0,0); Page.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)
    
    local TabBtn = Instance.new("TextButton", TabButtons); TabBtn.Size = UDim2.new(0.9, 0, 0, 38); TabBtn.Text = name; TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180); TabBtn.Font = "GothamSemibold"; TabBtn.TextSize = 12; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    local TabBtnStroke = Instance.new("UIStroke", TabBtn); TabBtnStroke.Color = Color3.fromRGB(40, 40, 40); TabBtnStroke.Thickness = 1
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons:GetChildren()) do 
            if b:IsA("TextButton") then 
                TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
            end 
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45), TextColor3 = Color3.new(1, 1, 1)}):Play()
    end)
    Pages[name] = Page; return Page
end

local UI_Updates = {}

local function AddToggle(parent, text, default, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.98, 0, 0, 40); b.Text = "      " .. text; b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.TextColor3 = Color3.new(0.9, 0.9, 0.9); b.Font = "GothamSemibold"; b.TextSize = 13; b.TextXAlignment = "Left"; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local s = default; local str = Instance.new("UIStroke", b); str.Color = s and Color3.fromRGB(80, 80, 255) or Color3.fromRGB(40, 40, 40); str.Thickness = 1.2
    local Indicator = Instance.new("Frame", b); Indicator.Size = UDim2.new(0, 4, 0.6, 0); Indicator.Position = UDim2.new(0, 8, 0.2, 0); Indicator.BackgroundColor3 = s and Color3.fromRGB(80, 80, 255) or Color3.fromRGB(50, 50, 50); Instance.new("UICorner", Indicator)
    
    local function update_visual(val)
        s = val
        TweenService:Create(str, TweenInfo.new(0.3), {Color = s and Color3.fromRGB(80, 80, 255) or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = s and Color3.fromRGB(80, 80, 255) or Color3.fromRGB(50, 50, 50)}):Play()
    end
    
    UI_Updates[text] = update_visual
    b.MouseButton1Click:Connect(function() update_visual(not s); callback(s) end)
end


local function AddSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.98, 0, 0, 55); f.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(40, 40, 40)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -20, 0, 25); l.Position = UDim2.new(0, 10, 0, 5); l.Text = text .. ": " .. default; l.TextColor3 = Color3.new(0.9, 0.9, 0.9); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.Font = "GothamSemibold"; l.TextSize = 12
    local s_bg = Instance.new("TextButton", f); s_bg.Size = UDim2.new(1, -20, 0, 6); s_bg.Position = UDim2.new(0, 10, 0, 38); s_bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); s_bg.Text = ""; Instance.new("UICorner", s_bg)
    local bar = Instance.new("Frame", s_bg); bar.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); bar.BackgroundColor3 = Color3.fromRGB(80, 80, 255); Instance.new("UICorner", bar)
    
    local function update_visual(val)
        local rel = math.clamp((val - min) / (max - min), 0, 1)
        bar.Size = UDim2.new(rel, 0, 1, 0)
        l.Text = text .. ": " .. val
    end
    
    UI_Updates[text] = update_visual
    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - s_bg.AbsolutePosition.X) / s_bg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max-min)*rel)
        update_visual(val); callback(val)
    end
    s_bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
end


local function AddKeybind(parent, text, default, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.98, 0, 0, 40); b.Text = "      " .. text; b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.TextColor3 = Color3.new(0.9, 0.9, 0.9); b.Font = "GothamSemibold"; b.TextSize = 13; b.TextXAlignment = "Left"; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local kt = Instance.new("TextLabel", b); kt.Size = UDim2.new(0, 80, 0.6, 0); kt.Position = UDim2.new(1, -90, 0.2, 0); kt.BackgroundColor3 = Color3.fromRGB(30, 30, 30); kt.Text = default.Name; kt.TextColor3 = Color3.fromRGB(80, 80, 255); kt.Font = "GothamBold"; kt.TextSize = 11; Instance.new("UICorner", kt); Instance.new("UIStroke", kt).Color = Color3.fromRGB(50, 50, 255)
    
    local binding = false
    b.MouseButton1Click:Connect(function()
        binding = true; kt.Text = "..."; kt.TextColor3 = Color3.new(1, 1, 1)
    end)
    
    UserInputService.InputBegan:Connect(function(i)
        if binding then
            if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.MouseButton2 or i.UserInputType == Enum.UserInputType.MouseButton3 then
                binding = false
                local key = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType
                kt.Text = key.Name; kt.TextColor3 = Color3.fromRGB(80, 80, 255); callback(key)
            end
        end
    end)
end

local function AddButton(parent, text, callback)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.98, 0, 0, 38); b.Text = text; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamSemibold"; b.TextSize = 13; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(50, 50, 50)
    b.MouseButton1Click:Connect(callback)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() end)
end



local P_Combat = CreatePage("Combat")
local P_Visuals = CreatePage("Visuals")
local P_Move = CreatePage("Movement")
local P_World = CreatePage("World")
local P_Players = CreatePage("Players")
local P_Settings = CreatePage("Settings")

-- Scrollable Player List
local PlayerScroll = Instance.new("ScrollingFrame", P_Players)
PlayerScroll.Size = UDim2.new(1, 0, 1, 0); PlayerScroll.BackgroundTransparency = 1; PlayerScroll.ScrollBarThickness = 2
local PlayerListLayout = Instance.new("UIListLayout", PlayerScroll)
PlayerListLayout.Padding = UDim.new(0, 5); PlayerListLayout.HorizontalAlignment = "Center"

local function UpdatePlayerList()
    for _, v in pairs(PlayerScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local f = Instance.new("Frame", PlayerScroll); f.Size = UDim2.new(0.95, 0, 0, 80); f.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Instance.new("UICorner", f)
        Instance.new("UIStroke", f).Color = SAC.Friends[tostring(p.UserId)] and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(40, 40, 40)
        
        local n = Instance.new("TextLabel", f); n.Size = UDim2.new(0.6, 0, 0, 30); n.Position = UDim2.new(0, 10, 0, 5); n.Text = p.Name; n.Font = "GothamBold"; n.TextSize = 14; n.TextColor3 = Color3.new(1,1,1); n.TextXAlignment = "Left"; n.BackgroundTransparency = 1
        local det = Instance.new("TextLabel", f); det.Size = UDim2.new(0.6, 0, 0, 20); det.Position = UDim2.new(0, 10, 0, 30); det.Text = "Health: 100% | Dist: 0m"; det.Font = "GothamSemibold"; det.TextSize = 11; det.TextColor3 = Color3.fromRGB(150, 150, 150); det.TextXAlignment = "Left"; det.BackgroundTransparency = 1
        
        task.spawn(function()
            while f and f.Parent do
                local char = p.Character; local lpchar = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") and lpchar and lpchar:FindFirstChild("HumanoidRootPart") then
                    local hp = math.floor(char.Humanoid.Health)
                    local dist = math.floor((char.HumanoidRootPart.Position - lpchar.HumanoidRootPart.Position).Magnitude)
                    det.Text = "Health: "..hp.."% | Dist: "..dist.."m"
                end
                task.wait(1)
            end
        end)

        local btn_tp = Instance.new("TextButton", f); btn_tp.Size = UDim2.new(0, 60, 0, 25); btn_tp.Position = UDim2.new(1, -70, 0, 5); btn_tp.Text = "Goto"; btn_tp.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn_tp.TextColor3 = Color3.new(1,1,1); btn_tp.Font = "GothamBold"; btn_tp.TextSize = 11; Instance.new("UICorner", btn_tp)
        local btn_br = Instance.new("TextButton", f); btn_br.Size = UDim2.new(0, 60, 0, 25); btn_br.Position = UDim2.new(1, -70, 0, 32); btn_br.Text = "Bring"; btn_br.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn_br.TextColor3 = Color3.new(1,1,1); btn_br.Font = "GothamBold"; btn_br.TextSize = 11; Instance.new("UICorner", btn_br)
        local btn_fr = Instance.new("TextButton", f); btn_fr.Size = UDim2.new(0, 80, 0, 25); btn_fr.Position = UDim2.new(1, -90, 0, 59); btn_fr.Text = SAC.Friends[tostring(p.UserId)] and "Unfriend" or "Whitelist"; btn_fr.BackgroundColor3 = SAC.Friends[tostring(p.UserId)] and Color3.fromRGB(80, 50, 50) or Color3.fromRGB(50, 80, 50); btn_fr.TextColor3 = Color3.new(1,1,1); btn_fr.Font = "GothamBold"; btn_fr.TextSize = 11; Instance.new("UICorner", btn_fr)

        btn_tp.MouseButton1Click:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
            end
        end)
        btn_br.MouseButton1Click:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end)
        btn_fr.MouseButton1Click:Connect(function()
            local id = tostring(p.UserId)
            if SAC.Friends[id] then SAC.Friends[id] = nil else SAC.Friends[id] = true end
            UpdatePlayerList()
        end)
    end
end

UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList); Players.PlayerRemoving:Connect(UpdatePlayerList)


-- Initial Visibility
P_Combat.Visible = true
for _, b in pairs(TabButtons:GetChildren()) do
    if b:IsA("TextButton") and b.Text == "Combat" then
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        b.TextColor3 = Color3.new(1, 1, 1)
    end
end

AddToggle(P_Combat, "Aimbot Master", SAC.Combat.Aimbot, function(v) SAC.Combat.Aimbot = v end)
AddToggle(P_Combat, "Wall Check (Legit)", SAC.Combat.WallCheck, function(v) SAC.Combat.WallCheck = v end)
AddToggle(P_Combat, "Triggerbot", SAC.Combat.Triggerbot, function(v) SAC.Combat.Triggerbot = v end)
AddToggle(P_Combat, "Auto Shoot", SAC.Combat.AutoShoot, function(v) SAC.Combat.AutoShoot = v end)
AddToggle(P_Combat, "Always Active Mode", SAC.Combat.AimbotAlwaysActive, function(v) SAC.Combat.AimbotAlwaysActive = v end)
AddKeybind(P_Combat, "Aimbot Keybind", SAC.Combat.AimbotKey, function(v) SAC.Combat.AimbotKey = v end)
AddToggle(P_Combat, "Show FOV Circle", SAC.Combat.FOVVisible, function(v) SAC.Combat.FOVVisible = v end)
AddSlider(P_Combat, "Aimbot FOV", 30, 800, 150, function(v) SAC.Combat.FOV = v end)
AddSlider(P_Combat, "Smoothness", 1, 100, 5, function(v) SAC.Combat.Smoothing = v/100 end)
AddButton(P_Combat, "Cycle FOV Color", function()

    local colors = {Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1)}
    local current = 1
    for i, c in ipairs(colors) do if c == SAC.Combat.FOVColorValue then current = i break end end
    SAC.Combat.FOVColorValue = colors[(current % #colors) + 1]
end)


AddToggle(P_Visuals, "Box ESP", SAC.Visuals.Box, function(v) SAC.Visuals.Box = v end)
AddToggle(P_Visuals, "Player Names", SAC.Visuals.Name, function(v) SAC.Visuals.Name = v end)
AddToggle(P_Visuals, "Health Bar", SAC.Visuals.Health, function(v) SAC.Visuals.Health = v end)
AddToggle(P_Visuals, "Snaplines", SAC.Visuals.Line, function(v) SAC.Visuals.Line = v end)
AddToggle(P_Visuals, "Skeleton ESP", SAC.Visuals.Skeleton, function(v) SAC.Visuals.Skeleton = v end)

AddToggle(P_Visuals, "Fullbright", SAC.Visuals.Fullbright, function(v) SAC.Visuals.Fullbright = v end)
AddSlider(P_Visuals, "Field Of View", 70, 120, 70, function(v) SAC.Visuals.FieldOfView = v end)

local f_self = Instance.new("Frame", P_Visuals); f_self.Size = UDim2.new(0.98, 0, 0, 30); f_self.BackgroundTransparency = 1; local l_self = Instance.new("TextLabel", f_self); l_self.Size = UDim2.new(1, 0, 1, 0); l_self.Text = "  SELF SETTINGS"; l_self.Font = "GothamBold"; l_self.TextSize = 11; l_self.TextColor3 = Color3.fromRGB(150, 150, 150); l_self.TextXAlignment = "Left"; l_self.BackgroundTransparency = 1
AddToggle(P_Visuals, "Self Coloring", SAC.Visuals.SelfColor, function(v) SAC.Visuals.SelfColor = v end)
AddToggle(P_Visuals, "Self RGB Mode", SAC.Visuals.SelfRGB, function(v) SAC.Visuals.SelfRGB = v end)

local f_enemy = Instance.new("Frame", P_Visuals); f_enemy.Size = UDim2.new(0.98, 0, 0, 30); f_enemy.BackgroundTransparency = 1; local l_enemy = Instance.new("TextLabel", f_enemy); l_enemy.Size = UDim2.new(1, 0, 1, 0); l_enemy.Text = "  ENEMY SETTINGS"; l_enemy.Font = "GothamBold"; l_enemy.TextSize = 11; l_enemy.TextColor3 = Color3.fromRGB(150, 150, 150); l_enemy.TextXAlignment = "Left"; l_enemy.BackgroundTransparency = 1
AddToggle(P_Visuals, "Enemy Coloring", SAC.Visuals.EnemyColor, function(v) SAC.Visuals.EnemyColor = v end)


AddToggle(P_Move, "Spinbot (Mevlana)", SAC.Movement.Spin, function(v) SAC.Movement.Spin = v end)
AddSlider(P_Move, "Spin Speed", 10, 500, 100, function(v) SAC.Movement.SpinSpeed = v end)
AddToggle(P_Move, "Fly Mode", SAC.Movement.Fly, function(v) SAC.Movement.Fly = v end)
AddSlider(P_Move, "Fly Speed", 10, 300, 50, function(v) SAC.Movement.FlySpeed = v end)
AddToggle(P_Move, "Infinite Jump", SAC.Movement.InfiniteJump, function(v) SAC.Movement.InfiniteJump = v end)
AddToggle(P_Move, "Noclip", SAC.Movement.Noclip, function(v) SAC.Movement.Noclip = v end)
AddSlider(P_Move, "WalkSpeed", 16, 250, 16, function(v) SAC.Movement.Speed = v end)
AddSlider(P_Move, "JumpPower", 50, 500, 50, function(v) SAC.Movement.JumpPower = v end)

AddToggle(P_World, "Karanlık Mod (Dark)", SAC.World.DarkMode, function(v) SAC.World.DarkMode = v end)
AddToggle(P_World, "Dünya RGB (Optimize)", SAC.World.RGBWorld, function(v) SAC.World.RGBWorld = v end)

AddButton(P_Settings, "Önerilen Ayarları Kullan (Safe)", function()
    -- Logic Updates
    SAC.Combat.Smoothing = 0.1
    SAC.Combat.Triggerbot = false
    SAC.Movement.Speed = 20
    SAC.Movement.JumpPower = 65
    SAC.Movement.InfiniteJump = false
    SAC.Movement.Fly = false
    SAC.Movement.Noclip = false
    SAC.Movement.Spin = false
    
    -- UI Visual Updates
    if UI_Updates["Smoothness"] then UI_Updates["Smoothness"](10) end
    if UI_Updates["Triggerbot"] then UI_Updates["Triggerbot"](false) end
    if UI_Updates["WalkSpeed"] then UI_Updates["WalkSpeed"](20) end
    if UI_Updates["JumpPower"] then UI_Updates["JumpPower"](65) end
    if UI_Updates["Infinite Jump"] then UI_Updates["Infinite Jump"](false) end
    if UI_Updates["Fly Mode"] then UI_Updates["Fly Mode"](false) end
    if UI_Updates["Noclip"] then UI_Updates["Noclip"](false) end
    if UI_Updates["Spinbot (Mevlana)"] then UI_Updates["Spinbot (Mevlana)"](false) end
    
    -- Notify
    local old_text = Title.Text
    Title.Text = "SETTINGS APPLIED!"
    task.delay(1.5, function() Title.Text = old_text end)
end)

AddButton(P_Settings, "Uninject Script", function()


    SHIELD_ENABLED = false
    FOV_Circle:Destroy()
    Screen:Destroy()
    Watermark:Destroy()
    for _, drawings in pairs(Cache) do
        for _, obj in pairs(drawings) do obj:Destroy() end
    end
end)



local R15_K = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6_K = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}


local function GetESP(p)
    if Cache[p] then return Cache[p] end
    local d = {
        Box = Drawing.new("Square"), Name = Drawing.new("Text"), 
        HealthBG = Drawing.new("Square"), Health = Drawing.new("Square"), 
        Line = Drawing.new("Line"), Skeleton = {}
    }
    for _, v in pairs(d) do if type(v) ~= "table" then v.Thickness = 1; v.Color = Color3.new(1,1,1); v.Visible = false end end
    d.Name.Center = true; d.Name.Outline = true; d.Name.Size = 13
    
    for i=1, 15 do 
        local l = Drawing.new("Line"); l.Thickness = 1; l.Visible = false; l.Color = Color3.new(1,1,1)
        table.insert(d.Skeleton, l) 
    end
    
    Cache[p] = d; return d
end

local function IsVisible(part, char)
    local origin = Camera.CFrame.Position
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, part.Position - origin, ray)
    return result == nil or result.Instance:IsDescendantOf(char)
end


local lastShot = 0 

RunService.RenderStepped:Connect(function(dt)
    if not SHIELD_ENABLED then return end
    
    if Main.Visible then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end

    FOV_Circle.Visible = (SAC.Combat.Aimbot and SAC.Combat.FOVVisible and not Main.Visible)

    FOV_Circle.Radius = SAC.Combat.FOV; FOV_Circle.Position = UserInputService:GetMouseLocation()
    FOV_Circle.Color = SAC.Combat.FOVColorValue

    
    local mouseLoc = UserInputService:GetMouseLocation()
    local target2D = nil; local minDist = SAC.Combat.FOV

    -- Visuals (FOV & Fullbright & World)
    Camera.FieldOfView = SAC.Visuals.FieldOfView
    
    if SAC.World.RGBWorld then
        game:GetService("Lighting").Ambient = Color3.fromHSV(GH_HUE, 1, 1)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromHSV(GH_HUE, 1, 1)
    elseif SAC.Visuals.Fullbright then
        game:GetService("Lighting").Ambient = Color3.new(1,1,1)
        game:GetService("Lighting").OutdoorAmbient = Color3.new(1,1,1)
    elseif SAC.World.DarkMode then
        game:GetService("Lighting").Ambient = Color3.new(0,0,0)
        game:GetService("Lighting").OutdoorAmbient = Color3.new(0,0,0)
    else
        game:GetService("Lighting").Ambient = Color3.fromRGB(127, 127, 127)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end


    -- Trigger Key Check
    local aim_key_pressed = SAC.Combat.AimbotAlwaysActive
    if not aim_key_pressed then
        if SAC.Combat.AimbotKey.Name:find("MouseButton") then
            aim_key_pressed = UserInputService:IsMouseButtonPressed(SAC.Combat.AimbotKey)
        else
            aim_key_pressed = UserInputService:IsKeyDown(SAC.Combat.AimbotKey)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or SAC.Friends[tostring(p.UserId)] then 
            if Cache[p] then 
                for _, v in pairs(Cache[p]) do 
                    if type(v) == "table" then for _, l in pairs(v) do l.Visible = false end else v.Visible = false end 
                end 
            end
            continue 
        end
        local char = p.Character

        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
            local root = char.HumanoidRootPart; local head = char.Head
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local esp = GetESP(p)

            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.abs(headPos.Y - legPos.Y); local w = h * 0.6

                esp.Box.Visible = SAC.Visuals.Box; esp.Box.Size = Vector2.new(w, h); esp.Box.Position = Vector2.new(pos.X - w/2, headPos.Y)
                esp.Name.Visible = SAC.Visuals.Name; esp.Name.Text = p.Name; esp.Name.Position = Vector2.new(pos.X, headPos.Y - 15)
                
                esp.Line.Visible = SAC.Visuals.Line
                esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                esp.Line.To = Vector2.new(pos.X, pos.Y + (h/2)) 

                -- Skeleton ESP
                if SAC.Visuals.Skeleton then
                    local rig = char:FindFirstChild("UpperTorso") and R15_K or R6_K
                    for i, bone in pairs(rig) do
                        local b1, b2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                        local line = esp.Skeleton[i]
                        if b1 and b2 and line then
                            local p1, o1 = Camera:WorldToViewportPoint(b1.Position)
                            local p2, o2 = Camera:WorldToViewportPoint(b2.Position)
                            if o1 and o2 then
                                line.Visible = true
                                line.From = Vector2.new(p1.X, p1.Y)
                                line.To = Vector2.new(p2.X, p2.Y)
                                line.Color = SAC.Visuals.EnemyColorValue
                            else line.Visible = false end
                        elseif line then line.Visible = false end
                    end
                else
                    for _, l in pairs(esp.Skeleton) do l.Visible = false end
                end

                local hum = char:FindFirstChildOfClass("Humanoid")
                if SAC.Visuals.Health and hum then
                    esp.HealthBG.Visible = true; esp.Health.Visible = true
                    esp.HealthBG.Size = Vector2.new(2, h); esp.HealthBG.Position = Vector2.new(pos.X - w/2 - 5, headPos.Y)
                    local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                    esp.Health.Size = Vector2.new(2, hp*h); esp.Health.Position = Vector2.new(pos.X - w/2 - 5, headPos.Y + (h - (hp*h))); esp.Health.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hp)
                else esp.HealthBG.Visible = false; esp.Health.Visible = false end

                if SAC.Combat.Aimbot and not Main.Visible and aim_key_pressed then
                    local sPos, sVis = Camera:WorldToViewportPoint(head.Position)
                    local mag = (Vector2.new(sPos.X, sPos.Y) - mouseLoc).Magnitude
                    
                    if mag < minDist then
                        if SAC.Combat.WallCheck then
                            if IsVisible(head, char) then
                                target2D = Vector2.new(sPos.X, sPos.Y); minDist = mag
                            end
                        else
                            target2D = Vector2.new(sPos.X, sPos.Y); minDist = mag
                        end
                    end
                end
            else 
                for _, v in pairs(esp) do if type(v) == "table" then for _, l in pairs(v) do l.Visible = false end else v.Visible = false end end 
            end
        else 
            if Cache[p] then 
                for _, v in pairs(Cache[p]) do if type(v) == "table" then for _, l in pairs(v) do l.Visible = false end else v.Visible = false end end 
            end 
        end
    end

    if target2D and SAC.Combat.Aimbot and not Main.Visible and aim_key_pressed then

        local moveX = (target2D.X - mouseLoc.X) * SAC.Combat.Smoothing
        local moveY = (target2D.Y - mouseLoc.Y) * SAC.Combat.Smoothing
        
        if moveX == moveX and moveY == moveY then -- NaN check
            if mousemoverel then mousemoverel(moveX, moveY) end
        end
        
        if SAC.Combat.AutoShoot then

            local currentDistance = (target2D - mouseLoc).Magnitude
            if currentDistance < 15 and (tick() - lastShot) > SAC.Combat.ShootDelay then
                if mouse1click then mouse1click() end
                lastShot = tick()
            end
        end
    end

    -- Triggerbot
    if SAC.Combat.Triggerbot and not Main.Visible then
        local target = LocalPlayer:GetMouse().Target
        if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
            if Players:GetPlayerFromCharacter(target.Parent) ~= LocalPlayer then
                if (tick() - lastShot) > SAC.Combat.ShootDelay then
                    if mouse1click then mouse1click() end
                    lastShot = tick()
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not SHIELD_ENABLED then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if SAC.Movement.Spin then
        root.RotVelocity = Vector3.new(0, SAC.Movement.SpinSpeed, 0)
    end

    -- Speed & Jump
    hum.WalkSpeed = SAC.Movement.Speed
    hum.JumpPower = SAC.Movement.JumpPower

    if SAC.Movement.Fly then
        hum.PlatformStand = true
        root.Velocity = Vector3.new(0,0,0)
        
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        
        if moveDir.Magnitude > 0 then
            root.Velocity = moveDir.Unit * SAC.Movement.FlySpeed
        end
    else
        hum.PlatformStand = false
    end

    if SAC.Movement.Noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if SAC.Movement.InfiniteJump and SHIELD_ENABLED then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)



local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local guiObjects = Screen:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        local isOverButton = false
        for _, obj in pairs(guiObjects) do
            if obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
                if obj ~= Main and obj ~= Sidebar then
                    isOverButton = true; break
                end
            end
        end
        
        if not isOverButton then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.Insert then 
        Main.Visible = not Main.Visible 
        FOV_Circle.Visible = (Main.Visible and SAC.Combat.Aimbot and SAC.Combat.FOVVisible)
        
        if Main.Visible then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end 
end)


