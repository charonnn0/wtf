local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- // Performance Constants
local TICK_RATE = 1/30 -- Update visuals at 30 FPS instead of 60+
local lastTick = 0
local HIGHLIGHT_LIMIT = 20 -- Reduced to ensure stability

-- // Registry for Centralized RGB Updates (Saves CPU)
local RGB_REGISTRY = {
    Controls = {}, -- { {Obj, Prop, ActiveCheck} }
    ESP = {}       -- { {Player, Drawings} }
}

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
        Aimbot = false, SilentAim = false, FOV = 150, Smoothing = 0.05, FOVVisible = true, WallCheck = true, TargetPart = "Head"
    },
    Visuals = {
        Box = false, Name = false, Health = false, Chams = false, 
        RGB_ESP = false, RGB_Chams = false, SelfRGB = false, 
        PerformanceMode = true, -- Default to TRUE for "FPS Dostu"
        Colors = { Main = Color3.fromRGB(130, 100, 255), Enemy = Color3.fromRGB(255, 50, 50) }
    },
    Movement = { Speed = 16, Jump = 50, Fly = false, FlySpeed = 50, Noclip = false, InfiniteJump = false },
    World = { FullBright = false, RGB_Sky = false },
    ActiveState = { MenuOpen = true, RGB = Color3.new(1, 1, 1), Target = nil }
}

-- // ONE CENTRAL LOOP FOR ALL RGB CALCULATIONS
task.spawn(function()
    while task.wait(TICK_RATE) do
        local hue = tick() % 6 / 6
        SAC.ActiveState.RGB = Color3.fromHSV(hue, 0.7, 1)

        -- Update Menu Colors ONLY if Menu is Open
        if SAC.ActiveState.MenuOpen then
            for _, entry in pairs(RGB_REGISTRY.Controls) do
                local obj, prop, check = entry[1], entry[2], entry[3]
                if not check or check() then
                    obj[prop] = SAC.ActiveState.RGB
                end
            end
        end

        -- Update Skybox if Active
        if SAC.World.RGB_Sky then
            Lighting.OutdoorAmbient = SAC.ActiveState.RGB
        end
    end
end)

-- // UI Library (Optimized for performance)
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
            Name = "Main", Parent = Screen, Size = UDim2.new(0, 500, 0, 340),
            Position = UDim2.new(0.5, -250, 0.5, -170), BackgroundColor3 = Color3.fromRGB(10, 10, 12),
            BorderSizePixel = 0, ClipsDescendants = true
        }, {
            Library:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Library:Create("UIStroke", {Name = "Glow", Color = SAC.ActiveState.RGB, Thickness = 2, ApplyStrokeMode = "Border"})
        })
        
        table.insert(RGB_REGISTRY.Controls, {Main.Glow, "Color"})

        local Sidebar = Library:Create("Frame", {
            Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 130, 1, 0),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20), BorderSizePixel = 0
        }, { Library:Create("UICorner", {CornerRadius = UDim.new(0, 8)}) })

        local Title = Library:Create("TextLabel", {
            Parent = Sidebar, Size = UDim2.new(1, 0, 0, 50), Text = title,
            Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Color3.new(1,1,1), BackgroundTransparency = 1
        })
        table.insert(RGB_REGISTRY.Controls, {Title, "TextColor3"})

        local TabContainer = Library:Create("ScrollingFrame", {
            Parent = Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -60),
            BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
        }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center}) })

        local Pages = Library:Create("Frame", {
            Parent = Main, Position = UDim2.new(0, 140, 0, 10), Size = UDim2.new(1, -150, 1, -20), BackgroundTransparency = 1
        })

        local Tabs = {}
        local First = true

        function Tabs:CreateTab(name)
            local Page = Library:Create("ScrollingFrame", {
                Parent = Pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Visible = First, ScrollBarThickness = 1, CanvasSize = UDim2.new(0, 0, 0, 0)
            }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 6)}) })

            local Button = Library:Create("TextButton", {
                Parent = TabContainer, Size = UDim2.new(0.9, 0, 0, 32),
                BackgroundColor3 = First and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 20, 25),
                Text = name, TextColor3 = First and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 160),
                Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false
            }, { 
                Library:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Library:Create("UIStroke", {Name = "B", Color = SAC.ActiveState.RGB, Thickness = 0.8, Enabled = First})
            })
            
            table.insert(RGB_REGISTRY.Controls, {Button.B, "Color", function() return Button.B.Enabled end})

            Button.MouseButton1Click:Connect(function()
                for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
                for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(20, 20, 25); b.TextColor3 = Color3.fromRGB(150, 150, 160); b.B.Enabled = false end end
                Page.Visible = true; Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40); Button.TextColor3 = Color3.new(1,1,1); Button.B.Enabled = true
            end)

            First = false
            local Elements = {}

            function Elements:AddToggle(text, callback)
                local Tgl = Library:Create("Frame", {
                    Parent = Page, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(18, 18, 24),
                    BorderSizePixel = 0
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Library:Create("TextLabel", {
                        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = text,
                        TextColor3 = Color3.fromRGB(200, 200, 210), Font = Enum.Font.Gotham, TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                })
                local Box = Library:Create("Frame", {
                    Parent = Tgl, Position = UDim2.new(1, -38, 0.5, -9), Size = UDim2.new(0, 28, 0, 18),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 9)}),
                    Library:Create("Frame", {
                        Name = "I", Position = UDim2.new(0, 2, 0.5, -7), Size = UDim2.new(0, 14, 0, 14),
                        BackgroundColor3 = Color3.fromRGB(140, 140, 150)
                    }, {Library:Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })

                local s = false
                table.insert(RGB_REGISTRY.Controls, {Box.I, "BackgroundColor3", function() return s end})

                Tgl.InputBegan:Connect(function(i) 
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                        s = not s
                        TweenService:Create(Box.I, TweenInfo.new(0.2), {Position = s and UDim2.new(0, 12, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                        if not s then Box.I.BackgroundColor3 = Color3.fromRGB(140, 140, 150) end
                        callback(s)
                    end 
                end)
                Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 10)
            end

            function Elements:AddSlider(text, min, max, default, callback)
                local Sld = Library:Create("Frame", {
                    Parent = Page, Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = Color3.fromRGB(18, 18, 24),
                    BorderSizePixel = 0
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Library:Create("TextLabel", {
                        Name = "T", Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 12, 0, 2),
                        Text = text .. ": " .. default, TextColor3 = Color3.fromRGB(200, 200, 210),
                        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                })
                local Bg = Library:Create("Frame", {
                    Parent = Sld, Position = UDim2.new(0, 12, 0.75, -4), Size = UDim2.new(1, -24, 0, 4),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
                    Library:Create("Frame", { Name = "F", Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = SAC.ActiveState.RGB }, {Library:Create("UICorner", {CornerRadius = UDim.new(0, 2)})})
                })
                
                table.insert(RGB_REGISTRY.Controls, {Bg.F, "BackgroundColor3"})

                local dragging = false
                local function update()
                    local pos = math.clamp((UserInputService:GetMouseLocation().X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                    Bg.F.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max-min)*pos)
                    Sld.T.Text = text .. ": " .. val; callback(val)
                end
                Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            end
            return Elements
        end

        local d, s, sp
        Sidebar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; s = i.Position; sp = Main.Position end end)
        UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then 
            local delta = i.Position - s; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) 
        end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
        UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then SAC.ActiveState.MenuOpen = not SAC.ActiveState.MenuOpen; Main.Visible = SAC.ActiveState.MenuOpen end end)
        return Tabs
    end
end

-- // Feature Initialization
local Window = Library.New("SHIELD PREMIUM LITE")
local Combat = Window:CreateTab("Combat"); local Visuals = Window:CreateTab("Visuals")
local Movement = Window:CreateTab("Movement"); local World = Window:CreateTab("World")

Combat:AddToggle("Master Aimbot", function(v) SAC.Combat.Aimbot = v end)
Combat:AddSlider("FOV radius", 30, 800, 150, function(v) SAC.Combat.FOV = v end)
Combat:AddSlider("Smoothing", 1, 100, 5, function(v) SAC.Combat.Smoothing = v/100 end)

Visuals:AddToggle("Box ESP", function(v) SAC.Visuals.Box = v end)
Visuals:AddToggle("Names", function(v) SAC.Visuals.Name = v end)
Visuals:AddToggle("Chams (Highlight)", function(v) SAC.Visuals.Chams = v end)
Visuals:AddToggle("Self RGB", function(v) SAC.Visuals.SelfRGB = v end)
Visuals:AddToggle("RGB ESP Mode", function(v) SAC.Visuals.RGB_ESP = v end)
Visuals:AddToggle("High Performance Mode", function(v) SAC.Visuals.PerformanceMode = v end)

Movement:AddSlider("Walk Speed", 16, 250, 16, function(v) SAC.Movement.Speed = v end)
Movement:AddToggle("Fly Mode", function(v) SAC.Movement.Fly = v end)

World:AddToggle("Full Bright", function(v) SAC.World.FullBright = v end)
World:AddToggle("RGB Sky (Party)", function(v) SAC.World.RGB_Sky = v end)

-- // ULTRA LIGHTWEIGHT ESP & VISUALS
local Cache = {}
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 32; FOV_Circle.Visible = false

local function GetDrawings(p)
    if Cache[p] then return Cache[p] end
    local highlight = Instance.new("Highlight", GetGui())
    highlight.Adornee = p.Character; highlight.Enabled = false
    local drawings = { B = Drawing.new("Square"), N = Drawing.new("Text"), H = highlight }
    drawings.N.Center = true; drawings.N.Outline = true; drawings.N.Size = 13
    Cache[p] = drawings; return drawings
end

local selfHigh = Instance.new("Highlight", GetGui()); selfHigh.Enabled = false

-- THROTTLED MAIN LOOP (Saves CPU)
RunService.Heartbeat:Connect(function()
    local now = tick()
    if (now - lastTick) < (SAC.Visuals.PerformanceMode and 0.05 or 0.01) then return end
    lastTick = now

    -- Self RGB
    if SAC.Visuals.SelfRGB then
        selfHigh.Enabled = true; selfHigh.Adornee = LocalPlayer.Character
        selfHigh.FillColor = SAC.ActiveState.RGB
    else selfHigh.Enabled = false end

    -- FOV
    FOV_Circle.Visible = (SAC.Combat.Aimbot and SAC.Combat.FOVVisible)
    FOV_Circle.Radius = SAC.Combat.FOV; FOV_Circle.Position = UserInputService:GetMouseLocation()
    FOV_Circle.Color = SAC.ActiveState.RGB

    local mouse = UserInputService:GetMouseLocation()
    local target2D, bestTarg, minDist = nil, nil, SAC.Combat.FOV
    local activeHigh = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            local esp = GetDrawings(p)
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                if dist < 600 then -- Distant cull
                    local col = SAC.Visuals.RGB_ESP and SAC.ActiveState.RGB or Color3.new(1,1,1)
                    local h = math.abs(Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                    local w = h * 0.6

                    if SAC.Visuals.Box then esp.B.Visible = true; esp.B.Size = Vector2.new(w, h); esp.B.Position = Vector2.new(pos.X - w/2, pos.Y - h/2); esp.B.Color = col else esp.B.Visible = false end
                    if SAC.Visuals.Name then esp.N.Visible = true; esp.N.Text = p.Name; esp.N.Position = Vector2.new(pos.X, pos.Y - h/2 - 15); esp.N.Color = col else esp.N.Visible = false end
                    
                    if SAC.Visuals.Chams and activeHigh < HIGHLIGHT_LIMIT then
                        activeHigh += 1; esp.H.Enabled = true; esp.H.FillColor = SAC.ActiveState.RGB
                    else esp.H.Enabled = false end
                else 
                    esp.B.Visible = false; esp.N.Visible = false; esp.H.Enabled = false 
                end

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

-- WORLD LOOP
RunService.Heartbeat:Connect(function()
    if SAC.World.FullBright then Lighting.Ambient = Color3.new(1,1,1) end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = SAC.Movement.Speed
        if SAC.Movement.Fly then
            local root = char.HumanoidRootPart; char.Humanoid.PlatformStand = true; root.Velocity = Vector3.new(0,0,0)
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if moveDir.Magnitude > 0 then root.Velocity = moveDir.Unit * SAC.Movement.FlySpeed end
        else char.Humanoid.PlatformStand = false end
    end
end)
