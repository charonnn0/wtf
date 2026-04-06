local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- // Performance & Legacy Logic Constants
local SMART_TICK = 1/35 -- Balanced visuals
local lastSmartTick = 0
local MAIN_COLOR = Color3.fromRGB(150, 100, 255)
local HIGHLIGHT_POOL = 15

-- // Setup Helpers
local function GetGui()
    if gethui then return gethui() end
    return CoreGui
end

local function RandomString(l)
    local s = ""
    for i = 1, l do s = s .. string.char(math.random(65, 90)) end
    return s
end

-- // Settings Management (Legacy Sync)
local SAC = {
    Combat = {
        Aimbot = false, SilentAim = false, FOV = 150, Smoothing = 0.05, FOVVisible = true, WallCheck = true,
        TargetPart = "Head", MaxDistance = 1000, AutoShoot = false, ShootDelay = 0.2
    },
    Visuals = {
        Box = false, Name = false, Health = false, Lines = false, Chams = false, 
        SelfColor = "Normal", EnemyColor = Color3.new(1, 1, 1),
        PerformanceMode = true
    },
    Movement = { Speed = 16, Jump = 50, Fly = false, FlySpeed = 50, Noclip = false, InfiniteJump = false, Spin = false, SpinSpeed = 100 },
    World = { FullBright = false, RGB_Sky = false, NightMode = false, Gravity = 196.2 },
    ActiveState = { MenuOpen = true, RGB = MAIN_COLOR, Target = nil, LastShot = 0 }
}

-- // Original Watermark (shield.wtf)
local Watermark = Instance.new("ScreenGui", GetGui()); Watermark.Name = "SHIELD_WATERMARK"
local WLbl = Instance.new("TextLabel", Watermark)
WLbl.Size = UDim2.new(0, 200, 0, 30); WLbl.Position = UDim2.new(0, 10, 0, 10)
WLbl.BackgroundTransparency = 1; WLbl.Text = "shield.wtf"; WLbl.Font = Enum.Font.GothamBold
WLbl.TextSize = 20; WLbl.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while task.wait(0.05) do
        local hue = tick() % 6 / 6
        SAC.ActiveState.RGB = Color3.fromHSV(hue, 0.8, 1)
        WLbl.TextColor3 = SAC.ActiveState.RGB
    end
end)

-- // UI Library (Legacy Plus)
local Library = {}
do
    function Library:Create(name, props, children)
        local obj = Instance.new(name); for i, v in pairs(props or {}) do obj[i] = v end
        for i, v in pairs(children or {}) do v.Parent = obj end
        return obj
    end

    function Library.New(title)
        local Screen = Instance.new("ScreenGui", GetGui())
        Screen.Name = RandomString(12); Screen.ResetOnSpawn = false

        local Main = Library:Create("Frame", {
            Name = "Main", Parent = Screen, Size = UDim2.new(0, 560, 0, 420),
            Position = UDim2.new(0.5, -280, 0.5, -210), BackgroundColor3 = Color3.fromRGB(10, 10, 12),
            BorderSizePixel = 0, ClipsDescendants = true
        }, {
            Library:Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
            Library:Create("UIStroke", {Color = MAIN_COLOR, Thickness = 2, ApplyStrokeMode = "Border"})
        })

        local Sidebar = Library:Create("Frame", {
            Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 160, 1, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20), BorderSizePixel = 0
        }, { Library:Create("UICorner", {CornerRadius = UDim.new(0, 12)}) })

        local TitleText = Library:Create("TextLabel", {
            Parent = Sidebar, Size = UDim2.new(1, 0, 0, 70), Text = title,
            Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = MAIN_COLOR, BackgroundTransparency = 1
        })
        
        task.spawn(function() while task.wait(0.1) do if Main.Visible then TitleText.TextColor3 = SAC.ActiveState.RGB end end end)

        local TabContainer = Library:Create("ScrollingFrame", {
            Parent = Sidebar, Position = UDim2.new(0, 0, 0, 70), Size = UDim2.new(1, 0, 1, -80),
            BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
        }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center}) })

        local Pages = Library:Create("Frame", {
            Parent = Main, Position = UDim2.new(0, 175, 0, 15), Size = UDim2.new(1, -190, 1, -30), BackgroundTransparency = 1
        })

        local TabList = {}
        local First = true

        function TabList:CreateTab(name)
            local Page = Library:Create("ScrollingFrame", {
                Parent = Pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Visible = First, ScrollBarThickness = 1, CanvasSize = UDim2.new(0, 0, 0, 0)
            }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 8)}) })

            local Button = Library:Create("TextButton", {
                Parent = TabContainer, Size = UDim2.new(0.9, 0, 0, 36),
                BackgroundColor3 = First and Color3.fromRGB(30, 30, 45) or Color3.fromRGB(22, 22, 28),
                Text = name, TextColor3 = First and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 160),
                Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false
            }, { 
                Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                Library:Create("UIStroke", {Color = MAIN_COLOR, Thickness = 1.2, Enabled = First, Name = "B"})
            })

            Button.MouseButton1Click:Connect(function()
                for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
                for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(22, 22, 28); b.TextColor3 = Color3.fromRGB(150, 150, 160); b.B.Enabled = false end end
                Page.Visible = true; Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45); Button.TextColor3 = Color3.new(1,1,1); Button.B.Enabled = true
            end)

            First = false
            local Elements = {}

            function Elements:AddToggle(text, callback)
                local Tgl = Library:Create("Frame", { Parent = Page, Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(20, 20, 28) }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                    Library:Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), Text = text, TextColor3 = Color3.fromRGB(220, 220, 230), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 })
                })
                local Box = Library:Create("Frame", { Parent = Tgl, Position = UDim2.new(1, -50, 0.5, -11), Size = UDim2.new(0, 36, 0, 22), BackgroundColor3 = Color3.fromRGB(35, 35, 45) }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 11)}),
                    Library:Create("Frame", { Name = "I", Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.fromRGB(140, 140, 150) }, {Library:Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })
                local active = false
                Tgl.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    active = not active
                    TweenService:Create(Box.I, TweenInfo.new(0.2), {Position = active and UDim2.new(0, 17, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = active and MAIN_COLOR or Color3.fromRGB(140, 140, 150)}):Play()
                    callback(active)
                end end)
                Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
            end

            function Elements:AddSlider(text, min, max, default, callback)
                local Sld = Library:Create("Frame", { Parent = Page, Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Color3.fromRGB(20, 20, 28) }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                    Library:Create("TextLabel", { Name = "T", Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 15, 0, 6), Text = text .. ": " .. default, TextColor3 = Color3.fromRGB(220, 220, 230), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 })
                })
                local BgSlider = Library:Create("Frame", { Parent = Sld, Position = UDim2.new(0, 15, 0.78, -5), Size = UDim2.new(1, -30, 0, 5), BackgroundColor3 = Color3.fromRGB(35, 35, 45) }, { Library:Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Library:Create("Frame", { Name = "F", Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = MAIN_COLOR }, {Library:Create("UICorner", {CornerRadius = UDim.new(0, 3)})}) })
                local dragging = false
                local function updateSlider()
                    local pos = math.clamp((UserInputService:GetMouseLocation().X - BgSlider.AbsolutePosition.X) / BgSlider.AbsoluteSize.X, 0, 1)
                    BgSlider.F.Size = UDim2.new(pos, 0, 1, 0); local val = math.floor(min + (max-min)*pos); Sld.T.Text = text .. ": " .. val; callback(val)
                end
                Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateSlider() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then updateSlider() end end)
            end
            return Elements
        end

        local d, s, sp
        Sidebar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; s = i.Position; sp = Main.Position end end)
        UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - s; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
        UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then SAC.ActiveState.MenuOpen = not SAC.ActiveState.MenuOpen; Main.Visible = SAC.ActiveState.MenuOpen end end)
        return TabList
    end
end

-- // Feature Initialization (Legacy Plus)
local WindowMenu = Library.New("SHIELD LEGACY PLUS")
local Combat = WindowMenu:CreateTab("Combat"); local Visuals = WindowMenu:CreateTab("Visuals")
local Movment = WindowMenu:CreateTab("Movement"); local WorldTab = WindowMenu:CreateTab("World")

Combat:AddToggle("Aimbot Master", function(v) SAC.Combat.Aimbot = v end)
Combat:AddToggle("Wall Check (Legit)", function(v) SAC.Combat.WallCheck = v end)
Combat:AddToggle("Auto Shoot (mouse1click)", function(v) SAC.Combat.AutoShoot = v end)
Combat:AddSlider("Aimbot FOV", 30, 800, 150, function(v) SAC.Combat.FOV = v end)
Combat:AddSlider("Smoothing", 1, 100, 5, function(v) SAC.Combat.Smoothing = v/100 end)

Visuals:AddToggle("Box ESP (Legacy)", function(v) SAC.Visuals.Box = v end)
Visuals:AddToggle("Player Names", function(v) SAC.Visuals.Name = v end)
Visuals:AddToggle("Health Bar (Classic)", function(v) SAC.Visuals.Health = v end)
Visuals:AddToggle("Snaplines (Line)", function(v) SAC.Visuals.Lines = v end)
Visuals:AddToggle("Highlight Chams", function(v) SAC.Visuals.Chams = v end)

Movment:AddToggle("Spinbot (Mevlana)", function(v) SAC.Movement.Spin = v end)
Movment:AddSlider("Spin Speed", 10, 500, 100, function(v) SAC.Movement.SpinSpeed = v end)
Movment:AddToggle("Fly Mode", function(v) SAC.Movement.Fly = v end)
Movment:AddToggle("Noclip", function(v) SAC.Movement.Noclip = v end)

WorldTab:AddToggle("Full Bright", function(v) SAC.World.FullBright = v end)
WorldTab:AddSlider("Gravity Control", 0, 500, 196, function(v) SAC.World.Gravity = v end)

-- // LEGACY ESP & AIMBOT CORE (Restored from your snippet)
local function GetESP(p)
    if Cache[p] then return Cache[p] end
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBG = Drawing.new("Square"),
        Health = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        H = Instance.new("Highlight", GetGui())
    }
    for _, v in pairs(drawings) do if v.Thickness then v.Thickness = 1; v.Color = Color3.new(1,1,1); v.Visible = false end end
    drawings.HealthBG.Color = Color3.new(0,0,0); drawings.HealthBG.Filled = true; drawings.Health.Filled = true
    drawings.Name.Center = true; drawings.Name.Outline = true; drawings.Name.Size = 13; drawings.H.Enabled = false
    Cache[p] = drawings; return drawings
end

local function IsVisible(part, char)
    local origin = Camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, part.Position - origin, rayParams)
    return result == nil or result.Instance:IsDescendantOf(char)
end

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 100; FOV_Circle.Color = Color3.new(1,1,1); FOV_Circle.Visible = false

RunService.RenderStepped:Connect(function()
    local now = tick()
    if (now - lastSmartTick) < SMART_TICK then return end
    lastSmartTick = now

    FOV_Circle.Visible = (SAC.Combat.Aimbot and SAC.Combat.FOVVisible)
    FOV_Circle.Radius = SAC.Combat.FOV; FOV_Circle.Position = UserInputService:GetMouseLocation()
    
    local mouseLoc = UserInputService:GetMouseLocation()
    local target2D = nil; local minDist = SAC.Combat.FOV

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
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
                
                esp.Line.Visible = SAC.Visuals.Lines; esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); esp.Line.To = Vector2.new(pos.X, pos.Y + (h/2)) 

                local hum = char:FindFirstChildOfClass("Humanoid")
                if SAC.Visuals.Health and hum then
                    esp.HealthBG.Visible = true; esp.Health.Visible = true
                    esp.HealthBG.Size = Vector2.new(2, h); esp.HealthBG.Position = Vector2.new(pos.X - w/2 - 5, headPos.Y)
                    local hpPercent = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                    esp.Health.Size = Vector2.new(2, hpPercent*h); esp.Health.Position = Vector2.new(pos.X - w/2 - 5, headPos.Y + (h - (hpPercent*h))); esp.Health.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hpPercent)
                else esp.HealthBG.Visible = false; esp.Health.Visible = false end

                if SAC.Visuals.Chams and activeHigh < HIGHLIGHT_POOL then
                    esp.H.Enabled = true; esp.H.Adornee = char; esp.H.FillColor = SAC.ActiveState.RGB
                else esp.H.Enabled = false end

                if (not SAC.ActiveState.MenuOpen) and SAC.Combat.Aimbot then
                    local sPos, sVis = Camera:WorldToViewportPoint(head.Position)
                    local mag = (Vector2.new(sPos.X, sPos.Y) - mouseLoc).Magnitude
                    
                    if mag < minDist then
                        if not SAC.Combat.WallCheck or IsVisible(head, char) then
                            target2D = Vector2.new(sPos.X, sPos.Y); minDist = mag
                        end
                    end
                end
            else for _, v in pairs(esp) do if v.Visible ~= nil then v.Visible = false end end esp.H.Enabled = false end
        else if Cache[p] then for _, v in pairs(Cache[p]) do if v.Visible ~= nil then v.Visible = false end end end end
    end

    if target2D and SAC.Combat.Aimbot then
        local moveX = (target2D.X - mouseLoc.X) * SAC.Combat.Smoothing
        local moveY = (target2D.Y - mouseLoc.Y) * SAC.Combat.Smoothing
        if mousemoverel then mousemoverel(moveX, moveY) end
        
        if SAC.Combat.AutoShoot then
            local currentDistanceM = (target2D - mouseLoc).Magnitude
            if currentDistanceM < 15 and (tick() - SAC.ActiveState.LastShot) > SAC.Combat.ShootDelay then
                if mouse1click then mouse1click() end
                SAC.ActiveState.LastShot = tick()
            end
        end
    end
end)

-- // Legacy Movement & World Integration
RunService.Heartbeat:Connect(function()
    workspace.Gravity = SAC.World.Gravity
    if SAC.World.FullBright then Lighting.Ambient = Color3.new(1,1,1) end
    if SAC.World.RGB_Sky then Lighting.OutdoorAmbient = SAC.ActiveState.RGB end

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char.Humanoid
        if not root or not hum then return end

        if SAC.Movement.Spin then root.RotVelocity = Vector3.new(0, SAC.Movement.SpinSpeed, 0) end

        if SAC.Movement.Fly then
            hum.PlatformStand = true; root.Velocity = Vector3.new(0,0,0)
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if moveDir.Magnitude > 0 then root.Velocity = moveDir.Unit * SAC.Movement.FlySpeed end
        else hum.PlatformStand = false end

        if SAC.Movement.Noclip then
            for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end
end)

-- // Legacy Cache Reset logic
task.spawn(function()
    while task.wait(30) do
        for p, drawings in pairs(Cache) do
            for _, obj in pairs(drawings) do if obj.Destroy then obj:Destroy() end end
        end
        Cache = {}
    end
end)
