local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

-- // Performance Constants
local TICK_RATE = 1/60 -- Target 60Hz update for visuals
local lastUpdate = 0
local HIGHLIGHT_LIMIT = 25 -- Roblox limit is 31

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
        Box = false, Name = false, Health = false, Lines = false, Chams = false, 
        RGB_ESP = false, RGB_Chams = false, SelfRGB = false, SelfChams = false,
        LowEndMode = false, -- FPS Saver
        Colors = { Main = Color3.fromRGB(130, 100, 255), Enemy = Color3.fromRGB(255, 50, 50) }
    },
    Movement = { Speed = 16, Jump = 50, Fly = false, FlySpeed = 50, Noclip = false, InfiniteJump = false },
    World = { FullBright = false, NightMode = false, RGB_Sky = false, FogRemove = false },
    ActiveState = { MenuOpen = true, RGB = Color3.new(1, 1, 1), Target = nil, Tick = 0 }
}

-- // Optimized RGB Loop (Single loop for all visuals)
task.spawn(function()
    while task.wait(0.01) do
        local hue = tick() % 4 / 4
        SAC.ActiveState.RGB = Color3.fromHSV(hue, 0.7, 1)
        SAC.ActiveState.Tick = tick()
    end
end)

-- // UI Library (Optimized)
local Library = {}
do
    function Library:Create(name, props, children)
        local obj = Instance.new(name)
        for i, v in pairs(props or {}) do obj[i] = v end
        for i, v in pairs(children or {}) do v.Parent = obj end
        return obj
    end

    function Library:Tween(obj, info, props)
        local t = TweenService:Create(obj, TweenInfo.new(table.unpack(info)), props)
        t:Play()
        return t
    end

    function Library.New(title)
        local Screen = Instance.new("ScreenGui", GetGui())
        Screen.Name = RandomString(12)
        Screen.ResetOnSpawn = false

        local Main = Library:Create("Frame", {
            Name = "Main", Parent = Screen, Size = UDim2.new(0, 520, 0, 360),
            Position = UDim2.new(0.5, -260, 0.5, -180), BackgroundColor3 = Color3.fromRGB(12, 12, 16),
            BorderSizePixel = 0, ClipsDescendants = true
        }, {
            Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Library:Create("UIStroke", {Name = "Glow", Color = SAC.ActiveState.RGB, Thickness = 2, ApplyStrokeMode = "Border"})
        })

        -- Optimized UI Color Update
        RunService.Heartbeat:Connect(function()
            if not Main.Visible then return end
            Main.Glow.Color = SAC.ActiveState.RGB
        end)

        local Sidebar = Library:Create("Frame", {
            Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 140, 1, 0),
            BackgroundColor3 = Color3.fromRGB(18, 18, 24), BorderSizePixel = 0
        }, { Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}) })

        local Title = Library:Create("TextLabel", {
            Parent = Sidebar, Size = UDim2.new(1, 0, 0, 50), Text = title,
            Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1,1,1), BackgroundTransparency = 1
        })
        
        RunService.Heartbeat:Connect(function() if Main.Visible then Title.TextColor3 = SAC.ActiveState.RGB end end)

        local TabContainer = Library:Create("ScrollingFrame", {
            Parent = Sidebar, Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -60),
            BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)
        }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center}) })

        local Pages = Library:Create("Frame", {
            Parent = Main, Position = UDim2.new(0, 150, 0, 10), Size = UDim2.new(1, -160, 1, -20), BackgroundTransparency = 1
        })

        local Tabs = {}
        local First = true

        function Tabs:CreateTab(name)
            local Page = Library:Create("ScrollingFrame", {
                Parent = Pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Visible = First, ScrollBarThickness = 1, CanvasSize = UDim2.new(0, 0, 0, 0)
            }, { Library:Create("UIListLayout", {Padding = UDim.new(0, 8)}) })

            local Button = Library:Create("TextButton", {
                Parent = TabContainer, Size = UDim2.new(0.85, 0, 0, 32),
                BackgroundColor3 = First and Color3.fromRGB(30, 30, 45) or Color3.fromRGB(22, 22, 30),
                Text = name, TextColor3 = First and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 160),
                Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false
            }, { 
                Library:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Library:Create("UIStroke", {Name = "BtnGlow", Color = SAC.ActiveState.RGB, Thickness = 0.8, Enabled = First})
            })

            RunService.Heartbeat:Connect(function() if Main.Visible and Button.BtnGlow.Enabled then Button.BtnGlow.Color = SAC.ActiveState.RGB end end)

            Button.MouseButton1Click:Connect(function()
                for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
                for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(22, 22, 30); b.TextColor3 = Color3.fromRGB(150, 150, 160); b.BtnGlow.Enabled = false end end
                Page.Visible = true; Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45); Button.TextColor3 = Color3.new(1,1,1); Button.BtnGlow.Enabled = true
            end)

            First = false
            local Elements = {}

            function Elements:AddToggle(text, callback)
                local Tgl = Library:Create("Frame", {
                    Parent = Page, Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(20, 20, 28),
                    BorderSizePixel = 0
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Library:Create("TextLabel", {
                        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text = text,
                        TextColor3 = Color3.fromRGB(200, 200, 210), Font = Enum.Font.Gotham, TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                })
                local Box = Library:Create("Frame", {
                    Parent = Tgl, Position = UDim2.new(1, -40, 0.5, -10), Size = UDim2.new(0, 30, 0, 20),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                    Library:Create("Frame", {
                        Name = "Indicator", Position = UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
                        BackgroundColor3 = Color3.fromRGB(150, 150, 160)
                    }, {Library:Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })

                local s = false
                Tgl.InputBegan:Connect(function(i) 
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                        s = not s
                        Library:Tween(Box.Indicator, {0.2}, {Position = s and UDim2.new(0, 12, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                        callback(s)
                    end 
                end)
                
                RunService.Heartbeat:Connect(function()
                    if s then Box.Indicator.BackgroundColor3 = SAC.ActiveState.RGB end
                end)
            end

            function Elements:AddSlider(text, min, max, default, callback)
                local Sld = Library:Create("Frame", {
                    Parent = Page, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(20, 20, 28),
                    BorderSizePixel = 0
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Library:Create("TextLabel", {
                        Name = "Title", Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 12, 0, 4),
                        Text = text .. ": " .. default, TextColor3 = Color3.fromRGB(200, 200, 210),
                        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1
                    })
                })
                local Bg = Library:Create("Frame", {
                    Parent = Sld, Position = UDim2.new(0, 12, 0.75, -4), Size = UDim2.new(1, -24, 0, 4),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                }, {
                    Library:Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
                    Library:Create("Frame", {
                        Name = "Fill", Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
                        BackgroundColor3 = SAC.ActiveState.RGB
                    }, {Library:Create("UICorner", {CornerRadius = UDim.new(0, 2)})})
                })
                
                RunService.Heartbeat:Connect(function() Bg.Fill.BackgroundColor3 = SAC.ActiveState.RGB end)

                local dragging = false
                local function update()
                    local pos = math.clamp((UserInputService:GetMouseLocation().X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                    Bg.Fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max-min)*pos)
                    Sld.Title.Text = text .. ": " .. val
                    callback(val)
                end

                Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            end

            return Elements
        end

        local d, s, sp
        Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; s = i.Position; sp = Main.Position end end)
        UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then 
            local delta = i.Position - s; Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) 
        end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

        UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then SAC.ActiveState.MenuOpen = not SAC.ActiveState.MenuOpen; Main.Visible = SAC.ActiveState.MenuOpen end end)
        return Tabs
    end
end

-- // Feature Initialization
local Window = Library.New("SHIELD PREMIUM V3.1")
local Combat = Window:CreateTab("Combat"); local Visuals = Window:CreateTab("Visuals")
local Movement = Window:CreateTab("Movement"); local World = Window:CreateTab("World")

Combat:AddToggle("Master Aimbot", function(v) SAC.Combat.Aimbot = v end)
Combat:AddToggle("Silent Aim", function(v) SAC.Combat.SilentAim = v end)
Combat:AddSlider("FOV radius", 30, 800, 150, function(v) SAC.Combat.FOV = v end)
Combat:AddSlider("Smoothing", 1, 100, 5, function(v) SAC.Combat.Smoothing = v/100 end)

Visuals:AddToggle("Box ESP", function(v) SAC.Visuals.Box = v end)
Visuals:AddToggle("Names", function(v) SAC.Visuals.Name = v end)
Visuals:AddToggle("Chams (Wall Hack)", function(v) SAC.Visuals.Chams = v end)
Visuals:AddToggle("Self RGB (Character)", function(v) SAC.Visuals.SelfRGB = v end)
Visuals:AddToggle("RGB ESP Mode", function(v) SAC.Visuals.RGB_ESP = v end)
Visuals:AddToggle("FPS Saver Mode", function(v) SAC.Visuals.LowEndMode = v end)

Movement:AddSlider("Walk Speed", 16, 300, 16, function(v) SAC.Movement.Speed = v end)
Movement:AddToggle("Fly Mode", function(v) SAC.Movement.Fly = v end)
Movement:AddToggle("Infinite Jump", function(v) SAC.Movement.InfiniteJump = v end)

World:AddToggle("Full Bright", function(v) SAC.World.FullBright = v end)
World:AddToggle("RGB Sky (Party)", function(v) SAC.World.RGB_Sky = v end)

-- // FPS Optimized Visuals
local Cache = {}
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 64; FOV_Circle.Visible = false

local function GetDrawings(p)
    if Cache[p] then return Cache[p] end
    local highlight = Instance.new("Highlight", GetGui())
    highlight.Adornee = p.Character
    highlight.Enabled = false
    local d = { Box = Drawing.new("Square"), Name = Drawing.new("Text"), Highlight = highlight }
    for _, v in pairs(d) do if v.Thickness then v.Thickness = 1; v.Visible = false end end
    d.Name.Center = true; d.Name.Outline = true; d.Name.Size = 13
    Cache[p] = d; return d
end

local selfHighlight = Instance.new("Highlight", GetGui())
selfHighlight.Enabled = false

RunService.RenderStepped:Connect(function()
    local now = tick()
    local isLowEnd = SAC.Visuals.LowEndMode
    
    -- Self RGB Update
    if SAC.Visuals.SelfRGB then
        selfHighlight.Enabled = true
        selfHighlight.Adornee = LocalPlayer.Character
        selfHighlight.FillColor = SAC.ActiveState.RGB
        selfHighlight.OutlineColor = Color3.new(1, 1, 1)
    else selfHighlight.Enabled = false end

    -- FOV Update
    FOV_Circle.Visible = (SAC.Combat.Aimbot and SAC.Combat.FOVVisible)
    FOV_Circle.Radius = SAC.Combat.FOV; FOV_Circle.Position = UserInputService:GetMouseLocation()
    FOV_Circle.Color = SAC.ActiveState.RGB

    local mouseLoc = UserInputService:GetMouseLocation()
    local target2D, bestTarg, minDist = nil, nil, SAC.Combat.FOV
    local activeHighlights = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
            local esp = GetDrawings(p)
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                -- Throttle Visual Updates if Low End Mode is on
                if not isLowEnd or (now - lastUpdate) > 0.02 then
                    local col = SAC.Visuals.RGB_ESP and SAC.ActiveState.RGB or Color3.new(1,1,1)
                    local h = math.abs(Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y)
                    local w = h * 0.6

                    esp.Box.Visible = SAC.Visuals.Box; esp.Box.Size = Vector2.new(w, h); esp.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2); esp.Box.Color = col
                    esp.Name.Visible = SAC.Visuals.Name; esp.Name.Text = p.Name; esp.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15); esp.Name.Color = col
                    
                    if SAC.Visuals.Chams and activeHighlights < HIGHLIGHT_LIMIT then
                        activeHighlights = activeHighlights + 1
                        esp.Highlight.Enabled = true
                        esp.Highlight.FillColor = SAC.Visuals.RGB_Chams and SAC.ActiveState.RGB or Color3.fromRGB(130, 100, 255)
                    else esp.Highlight.Enabled = false end
                end

                if (not SAC.ActiveState.MenuOpen) and SAC.Combat.Aimbot then
                    local sPos, sVis = Camera:WorldToViewportPoint(char.Head.Position)
                    local mag = (Vector2.new(sPos.X, sPos.Y) - mouseLoc).Magnitude
                    if mag < minDist then target2D = Vector2.new(sPos.X, sPos.Y); bestTarg = char.Head; minDist = mag end
                end
            else 
                esp.Box.Visible = false; esp.Name.Visible = false; esp.Highlight.Enabled = false 
            end
        elseif Cache[p] then
            Cache[p].Box.Visible = false; Cache[p].Name.Visible = false; Cache[p].Highlight.Enabled = false
        end
    end
    
    if (now - lastUpdate) > 0.02 then lastUpdate = now end

    if bestTarg and not SAC.ActiveState.MenuOpen then
        local moveX = (target2D.X - mouseLoc.X) * SAC.Combat.Smoothing
        local moveY = (target2D.Y - mouseLoc.Y) * SAC.Combat.Smoothing
        if mousemoverel then mousemoverel(moveX, moveY) end
    end
end)

-- // World & Movement
RunService.Heartbeat:Connect(function()
    if SAC.World.FullBright then Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1) end
    if SAC.World.RGB_Sky then Lighting.OutdoorAmbient = SAC.ActiveState.RGB end

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = SAC.Movement.Speed
        if SAC.Movement.InfiniteJump then char.Humanoid:ChangeState("Jumping") end
        if SAC.Movement.Fly then
            local root = char.HumanoidRootPart; char.Humanoid.PlatformStand = true; root.Velocity = Vector3.new(0,0,0)
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if moveDir.Magnitude > 0 then root.Velocity = moveDir.Unit * SAC.Movement.FlySpeed end
        else char.Humanoid.PlatformStand = false end
    end
end)
