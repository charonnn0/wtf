local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- // Performance Constants (V4 Optimized Powerhouse)
local SMART_TICK = 1/35 -- Balances visuals and FPS
local lastSmartTick = 0
local MAIN_COLOR = Color3.fromRGB(150, 100, 255)
local HIGHLIGHT_POOL = 15 -- Only 15 chams at a time for MAX FPS

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

-- // Settings Management
local SAC = {
    Combat = {
        Aimbot = false, SilentAim = false, FOV = 150, Smoothing = 0.05, FOVVisible = true, WallCheck = true,
        TargetPart = "Head", MaxDistance = 1000
    },
    Visuals = {
        Box = false, Name = false, Health = false, Chams = false, 
        SelfColor = "Normal", -- Red, Blue, Green, RGB, Normal
        SelfChams = false, EnemyColor = Color3.new(1, 1, 1),
        PerformanceMode = true
    },
    Movement = { Speed = 16, Jump = 50, Fly = false, FlySpeed = 50, Noclip = false, InfiniteJump = false },
    World = { FullBright = false, RGB_Sky = false, NightMode = false },
    ActiveState = { MenuOpen = true, RGB = MAIN_COLOR, Target = nil }
}

-- // One Central RGB Loop (Smart RGB)
task.spawn(function()
    while task.wait(0.08) do -- Slower update cycle saves CPU
        local hue = tick() % 12 / 12
        SAC.ActiveState.RGB = Color3.fromHSV(hue, 0.8, 1)
    end
end)

-- // UI Library (V4 Expanded)
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
            Name = "Main", Parent = Screen, Size = UDim2.new(0, 580, 0, 420),
            Position = UDim2.new(0.5, -290, 0.5, -210), BackgroundColor3 = Color3.fromRGB(10, 10, 14),
            BorderSizePixel = 0, ClipsDescendants = true
        }, {
            Library:Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
            Library:Create("UIStroke", {Color = MAIN_COLOR, Thickness = 2, ApplyStrokeMode = "Border"})
        })

        local Sidebar = Library:Create("Frame", {
            Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 160, 1, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20), BorderSizePixel = 0
        }, { Library:Create("UICorner", {CornerRadius = UDim.new(0, 14)}) })

        local Title = Library:Create("TextLabel", {
            Parent = Sidebar, Size = UDim2.new(1, 0, 0, 80), Text = title,
            Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = MAIN_COLOR, BackgroundTransparency = 1
        })
        
        task.spawn(function() while task.wait(0.1) do if Main.Visible then Title.TextColor3 = SAC.ActiveState.RGB end end end)

        local TabContainer = Library:Create("ScrollingFrame", {
            Parent = Sidebar, Position = UDim2.new(0, 0, 0, 80), Size = UDim2.new(1, -10, 1, -100),
            BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
        }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center}) })

        local Pages = Library:Create("Frame", {
            Parent = Main, Position = UDim2.new(0, 175, 0, 20), Size = UDim2.new(1, -195, 1, -40), BackgroundTransparency = 1
        })

        local Tabs = {}
        local First = true

        function Tabs:CreateTab(name)
            local Page = Library:Create("ScrollingFrame", {
                Parent = Pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Visible = First, ScrollBarThickness = 2, CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarImageColor3 = MAIN_COLOR
            }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 10)}) })

            local Button = Library:Create("TextButton", {
                Parent = TabContainer, Size = UDim2.new(0.9, 0, 0, 38),
                BackgroundColor3 = First and Color3.fromRGB(30, 30, 45) or Color3.fromRGB(22, 22, 28),
                Text = name, TextColor3 = First and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 160),
                Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false
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
                local Tgl = Library:Create("Frame", {
                    Parent = Page, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Color3.fromRGB(20, 20, 28),
                    BorderSizePixel = 0
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                    Library:Create("TextLabel", {
                        Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), Text = text,
                        TextColor3 = Color3.fromRGB(220, 220, 230), Font = Enum.Font.Gotham, TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                })
                local Box = Library:Create("Frame", {
                    Parent = Tgl, Position = UDim2.new(1, -50, 0.5, -11), Size = UDim2.new(0, 36, 0, 22),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 11)}),
                    Library:Create("Frame", { Name = "I", Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.fromRGB(140, 140, 150) }, {Library:Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })
                local s = false
                Tgl.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    s = not s
                    TweenService:Create(Box.I, TweenInfo.new(0.2), {Position = s and UDim2.new(0, 17, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = s and MAIN_COLOR or Color3.fromRGB(140, 140, 150)}):Play()
                    callback(s)
                end end)
                Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
            end

            function Elements:AddSlider(text, min, max, default, callback)
                local Sld = Library:Create("Frame", {
                    Parent = Page, Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Color3.fromRGB(20, 20, 28),
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                    Library:Create("TextLabel", { Name = "T", Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 15, 0, 6), Text = text .. ": " .. default, TextColor3 = Color3.fromRGB(220, 220, 230), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 })
                })
                local Bg = Library:Create("Frame", { Parent = Sld, Position = UDim2.new(0, 15, 0.78, -5), Size = UDim2.new(1, -30, 0, 5), BackgroundColor3 = Color3.fromRGB(35, 35, 45) }, { Library:Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Library:Create("Frame", { Name = "F", Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = MAIN_COLOR }, {Library:Create("UICorner", {CornerRadius = UDim.new(0, 3)})}) })
                local dragging = false
                local function update()
                    local pos = math.clamp((UserInputService:GetMouseLocation().X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                    Bg.F.Size = UDim2.new(pos, 0, 1, 0); local val = math.floor(min + (max-min)*pos)
                    Sld.T.Text = text .. ": " .. val; callback(val)
                end
                Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            end

            function Elements:AddDropdown(text, list, callback)
                local Drp = Library:Create("Frame", { Parent = Page, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Color3.fromRGB(20, 20, 28) }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                    Library:Create("TextLabel", { Name = "Title", Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), Text = text .. ": " .. list[1], TextColor3 = Color3.fromRGB(220, 220, 230), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 })
                })
                Drp.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    local cur = table.find(list, callback()) or 1
                    local nxt = cur % #list + 1
                    Drp.Title.Text = text .. ": " .. list[nxt]
                    callback(list[nxt])
                end end)
            end
            return Elements
        end

        local d, s, sp
        Sidebar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; s = i.Position; sp = Main.Position end end)
        UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - s; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
        UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then SAC.ActiveState.MenuOpen = not SAC.ActiveState.MenuOpen; Main.Visible = SAC.ActiveState.MenuOpen end end)
        return Tabs
    end
end

-- // Feature Initialization (V4 Optimized)
local Window = Library.New("SHIELD PREMIUM V4")
local Combat = Window:CreateTab("Combat"); local Visuals = Window:CreateTab("Visuals")
local Mov = Window:CreateTab("Movement"); local World = Window:CreateTab("World")

Combat:AddToggle("Master Aimbot", function(v) SAC.Combat.Aimbot = v end)
Combat:AddToggle("Wall Check", function(v) SAC.Combat.WallCheck = v end)
Combat:AddDropdown("Target Bone", {"Head", "HumanoidRootPart"}, function(v) if v then SAC.Combat.TargetPart = v end return SAC.Combat.TargetPart end)
Combat:AddSlider("FOV radius", 30, 1000, 150, function(v) SAC.Combat.FOV = v end)
Combat:AddSlider("Smoothing", 1, 100, 5, function(v) SAC.Combat.Smoothing = v/100 end)

Visuals:AddToggle("Box ESP", function(v) SAC.Visuals.Box = v end)
Visuals:AddToggle("Name ESP", function(v) SAC.Visuals.Name = v end)
Visuals:AddToggle("Highlight Chams", function(v) SAC.Visuals.Chams = v end)
Visuals:AddDropdown("Self Visual", {"Normal", "Red", "Blue", "Green", "RGB"}, function(v) if v then SAC.Visuals.SelfColor = v end return SAC.Visuals.SelfColor end)
Visuals:AddToggle("Enemy RGB Mode", function(v) SAC.Visuals.RGB_ESP = v end)

Mov:AddSlider("Speed Boost", 16, 300, 16, function(v) SAC.Movement.Speed = v end)
Mov:AddToggle("Fly Mode", function(v) SAC.Movement.Fly = v end)
Mov:AddToggle("Noclip", function(v) SAC.Movement.Noclip = v end)
Mov:AddToggle("Infinite Jump", function(v) SAC.Movement.InfiniteJump = v end)

World:AddToggle("Full Bright", function(v) SAC.World.FullBright = v end)
World:AddToggle("Night Mode", function(v) SAC.World.NightMode = v end)
World:AddToggle("RGB Party Sky", function(v) SAC.World.RGB_Sky = v end)

-- // V4 POWER CORE VISUALS
local Cache = {}
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 24; FOV_Circle.Visible = false; FOV_Circle.Color = MAIN_COLOR

local function GetDrawings(p)
    if Cache[p] then return Cache[p] end
    local h = Instance.new("Highlight", GetGui()); h.Adornee = p.Character; h.Enabled = false
    local d = { B = Drawing.new("Square"), N = Drawing.new("Text"), H = h }
    d.N.Center = true; d.N.Outline = true; d.N.Size = 12; d.N.Color = Color3.new(1,1,1); d.B.Color = Color3.new(1,1,1)
    Cache[p] = d; return d
end

local sHighlight = Instance.new("Highlight", GetGui()); sHighlight.Enabled = false

RunService.Heartbeat:Connect(function()
    local now = tick()
    if (now - lastSmartTick) < SMART_TICK then return end
    lastSmartTick = now

    -- Self Color Logic
    local sCol = SAC.Visuals.SelfColor
    if sCol ~= "Normal" then
        sHighlight.Enabled = true; sHighlight.Adornee = LocalPlayer.Character
        if sCol == "Red" then sHighlight.FillColor = Color3.new(1,0,0)
        elseif sCol == "Blue" then sHighlight.FillColor = Color3.new(0,0,1)
        elseif sCol == "Green" then sHighlight.FillColor = Color3.new(0,1,0)
        elseif sCol == "RGB" then sHighlight.FillColor = SAC.ActiveState.RGB end
    else sHighlight.Enabled = false end

    FOV_Circle.Visible = (SAC.Combat.Aimbot and SAC.Combat.FOVVisible); FOV_Circle.Radius = SAC.Combat.FOV; FOV_Circle.Position = UserInputService:GetMouseLocation()

    local mouse = UserInputService:GetMouseLocation()
    local target2D, bestTarg, minDist = nil, nil, SAC.Combat.FOV
    local activeH = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            local esp = GetDrawings(p); local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                if dist < 800 then
                    local h = math.abs(Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                    local w = h * 0.6
                    local col = SAC.Visuals.RGB_ESP and SAC.ActiveState.RGB or Color3.new(1,1,1)

                    if SAC.Visuals.Box then esp.B.Visible = true; esp.B.Size = Vector2.new(w, h); esp.B.Position = Vector2.new(pos.X - w/2, pos.Y - h/2); esp.B.Color = col else esp.B.Visible = false end
                    if SAC.Visuals.Name then esp.N.Visible = true; esp.N.Text = p.Name; esp.N.Position = Vector2.new(pos.X, pos.Y - h/2 - 14); esp.N.Color = col else esp.N.Visible = false end
                    
                    if SAC.Visuals.Chams and activeH < HIGHLIGHT_POOL then
                        activeH += 1; esp.H.Enabled = true; esp.H.FillColor = col; esp.H.OutlineColor = Color3.new(1,1,1)
                    else esp.H.Enabled = false end
                else esp.B.Visible = false; esp.N.Visible = false; esp.H.Enabled = false end

                if (not SAC.ActiveState.MenuOpen) and SAC.Combat.Aimbot then
                    local sPos = Camera:WorldToViewportPoint(char.Head.Position)
                    local mag = (Vector2.new(sPos.X, sPos.Y) - mouse).Magnitude
                    if mag < minDist then target2D = Vector2.new(sPos.X, sPos.Y); bestTarg = char.Head; minDist = mag end
                end
            else esp.B.Visible = false; esp.N.Visible = false; esp.H.Enabled = false end
        elseif Cache[p] then Cache[p].B.Visible = false; Cache[p].N.Visible = false; Cache[p].H.Enabled = false end
    end
    
    if bestTarg and not SAC.ActiveState.MenuOpen then
        local moveX = (target2D.X - mouse.X) * SAC.Combat.Smoothing
        local moveY = (target2D.Y - mouse.Y) * SAC.Combat.Smoothing
        if mousemoverel then mousemoverel(moveX, moveY) end
    end
end)

RunService.Heartbeat:Connect(function()
    if SAC.World.FullBright then Lighting.Ambient = Color3.new(1,1,1) end
    if SAC.World.NightMode then Lighting.ClockTime = 0 end
    if SAC.World.RGB_Sky then Lighting.OutdoorAmbient = SAC.ActiveState.RGB end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = SAC.Movement.Speed
        if SAC.Movement.Noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if SAC.Movement.Fly then
            local root = char.HumanoidRootPart; char.Humanoid.PlatformStand = true; root.Velocity = Vector3.new(0,0,0)
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if moveDir.Magnitude > 0 then root.Velocity = moveDir.Unit * SAC.Movement.FlySpeed end
        else char.Humanoid.PlatformStand = false end
    end
end)

UserInputService.JumpRequest:Connect(function() if SAC.Movement.InfiniteJump then LocalPlayer.Character.Humanoid:ChangeState("Jumping") end end)
