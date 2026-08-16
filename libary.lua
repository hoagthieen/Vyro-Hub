local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- ===== THEMES =====
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),
        Background2 = Color3.fromRGB(20, 20, 28),
        Foreground = Color3.fromRGB(30, 30, 40),
        Foreground2 = Color3.fromRGB(35, 35, 48),
        Accent = Color3.fromRGB(255, 120, 0),
        Accent2 = Color3.fromRGB(255, 160, 50),
        AccentGradient = Color3.fromRGB(255, 80, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 165),
        Border = Color3.fromRGB(45, 45, 58),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(255, 120, 0),
        ToggleOff = Color3.fromRGB(60, 60, 75),
        Success = Color3.fromRGB(50, 200, 100),
        Danger = Color3.fromRGB(255, 60, 60),
    },
    Blue = {
        Background = Color3.fromRGB(10, 15, 25),
        Background2 = Color3.fromRGB(15, 22, 35),
        Foreground = Color3.fromRGB(25, 35, 55),
        Foreground2 = Color3.fromRGB(30, 42, 65),
        Accent = Color3.fromRGB(0, 140, 255),
        Accent2 = Color3.fromRGB(60, 180, 255),
        AccentGradient = Color3.fromRGB(0, 80, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(140, 160, 200),
        Border = Color3.fromRGB(40, 55, 80),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(0, 140, 255),
        ToggleOff = Color3.fromRGB(50, 65, 90),
        Success = Color3.fromRGB(50, 200, 100),
        Danger = Color3.fromRGB(255, 60, 60),
    },
    Purple = {
        Background = Color3.fromRGB(18, 10, 28),
        Background2 = Color3.fromRGB(25, 15, 38),
        Foreground = Color3.fromRGB(38, 25, 55),
        Foreground2 = Color3.fromRGB(45, 30, 65),
        Accent = Color3.fromRGB(170, 80, 255),
        Accent2 = Color3.fromRGB(200, 120, 255),
        AccentGradient = Color3.fromRGB(120, 40, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(170, 150, 200),
        Border = Color3.fromRGB(55, 40, 75),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(170, 80, 255),
        ToggleOff = Color3.fromRGB(65, 50, 85),
        Success = Color3.fromRGB(50, 200, 100),
        Danger = Color3.fromRGB(255, 60, 60),
    },
}

local CurrentTheme = "Dark"

-- ===== HELPER FUNCTIONS =====
local function Tween(obj, prop, val, time, style, direction, callback)
    local info = TweenInfo.new(
        time or 0.25,
        Enum.EasingStyle[style or "Quad"],
        Enum.EasingDirection[direction or "Out"],
        0,
        false,
        0
    )
    local t = TweenService:Create(obj, info, {[prop] = val})
    if callback then
        t.Completed:Connect(callback)
    end
    t:Play()
    return t
end

local function MakeDraggable(frame, dragObject)
    local dragToggle = nil
    local dragSpeed = 0
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = Vector2.new(input.Position.X - dragStart.Position.X, input.Position.Y - dragStart.Position.Y)
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Tween(frame, "Position", newPosition, 0.05, "Linear")
    end
    
    (dragObject or frame).InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input
            startPos = frame.Position
        end
    end)
    
    (dragObject or frame).InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragSpeed = input
            if dragToggle then
                updateInput(input)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)
end

local function NewInstance(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function AddCorner(obj, radius)
    return NewInstance("UICorner", obj, { CornerRadius = UDim.new(0, radius or 8) })
end

local function AddStroke(obj, color, thickness)
    return NewInstance("UIStroke", obj, {
        Color = color,
        Thickness = thickness or 1,
        Transparency = 0.5,
    })
end

local function AddGradient(obj, color1, color2, rotation)
    local gradient = NewInstance("UIGradient", obj, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2),
        }),
        Rotation = rotation or 90,
    })
    return gradient
end

-- ===== MAIN LIBRARY =====
local Nyx = {
    Windows = {},
    Flags = {},
    Themes = Themes,
    CurrentTheme = "Dark",
}

-- ===== SET THEME =====
function Nyx:SetTheme(name)
    if self.Themes[name] then
        self.CurrentTheme = name
        CurrentTheme = name
    end
end

function Nyx:GetTheme()
    return self.Themes[self.CurrentTheme]
end

-- ===== CREATE WINDOW =====
function Nyx:NewWindow(title, subtitle)
    local win = {}
    local theme = self:GetTheme()

    -- ScreenGui
    local gui = NewInstance("ScreenGui", CoreGui, { 
        Name = "NyxUI",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- Main Container with shadow
    local mainContainer = NewInstance("Frame", gui, {
        Size = UDim2.new(0, 520, 0, 420),
        Position = UDim2.new(0.5, -260, 0.5, -210),
        BackgroundTransparency = 1,
    })

    -- Shadow effect
    local shadow = NewInstance("ImageLabel", mainContainer, {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = theme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(99, 99, 99, 99),
        ZIndex = 0,
    })

    -- Main frame
    local main = NewInstance("Frame", mainContainer, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    AddCorner(main, 12)
    AddStroke(main, theme.Border, 1.5)

    MakeDraggable(mainContainer, main)

    -- Title bar with gradient
    local titleBar = NewInstance("Frame", main, {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = theme.Background2,
        BorderSizePixel = 0,
    })
    AddCorner(titleBar, 12)

    -- Title bar gradient
    AddGradient(titleBar, theme.Foreground2, theme.Background2, 90)

    -- Accent line under title
    local accentLine = NewInstance("Frame", titleBar, {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
    })
    AddGradient(accentLine, theme.Accent, theme.AccentGradient, 0)

    -- Title
    local titleLabel = NewInstance("TextLabel", titleBar, {
        Size = UDim2.new(1, -90, 0, 25),
        Position = UDim2.new(0, 16, 0, 4),
        BackgroundTransparency = 1,
        Text = title or "Nyx",
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        ZIndex = 2,
    })

    -- Subtitle
    if subtitle then
        NewInstance("TextLabel", titleBar, {
            Size = UDim2.new(1, -90, 0, 14),
            Position = UDim2.new(0, 16, 0, 28),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            ZIndex = 2,
        })
    end

    -- Window controls
    local minimizeBtn = NewInstance("TextButton", titleBar, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -56, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 180, 50),
        Text = "—",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    AddCorner(minimizeBtn, 6)
    
    local isMinimized = false
    local originalSize = mainContainer.Size
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(mainContainer, "Size", UDim2.new(0, 520, 0, 45), 0.3, "Quart")
            titleBar.Size = UDim2.new(1, 0, 1, 0)
            titleBar.Position = UDim2.new(0, 0, 0, 0)
        else
            Tween(mainContainer, "Size", originalSize, 0.3, "Quart")
        end
    end)

    local closeBtn = NewInstance("TextButton", titleBar, {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -26, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.Danger,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    AddCorner(closeBtn, 6)
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, "BackgroundColor3", Color3.fromRGB(255, 80, 80), 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, "BackgroundColor3", theme.Danger, 0.2)
    end)
    closeBtn.MouseButton1Click:Connect(function() 
        gui:Destroy() 
    end)

    -- Tab sidebar
    local sidebar = NewInstance("Frame", main, {
        Size = UDim2.new(0, 150, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = theme.Background2,
        BorderSizePixel = 0,
    })
    
    local sidebarGradient = AddGradient(sidebar, theme.Background2, theme.Background, 90)

    local sideList = NewInstance("UIListLayout", sidebar, {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })
    
    NewInstance("UIPadding", sidebar, {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })

    -- Content area
    local content = NewInstance("ScrollingFrame", main, {
        Size = UDim2.new(1, -150, 1, -45),
        Position = UDim2.new(0, 150, 0, 45),
        BackgroundColor3 = theme.Background,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BorderSizePixel = 0,
        ScrollBarImageColor3 = theme.Accent,
    })
    
    local contentList = NewInstance("UIListLayout", content, {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    NewInstance("UIPadding", content, {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })

    win.Tabs = {}
    win.CurrentTab = nil

    -- ===== ADD TAB =====
    function win:AddTab(name, icon)
        local tab = {}

        -- Tab button
        local btn = NewInstance("TextButton", sidebar, {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.Foreground,
            Text = (icon and (icon .. "  ") or "") .. name,
            TextColor3 = theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        })
        AddCorner(btn, 8)
        
        -- Hover effect
        btn.MouseEnter:Connect(function()
            if not tab.IsActive then
                Tween(btn, "BackgroundColor3", theme.Foreground2, 0.2)
                Tween(btn, "TextColor3", theme.Text, 0.2)
            end
        end)
        btn.MouseLeave:Connect(function()
            if not tab.IsActive then
                Tween(btn, "BackgroundColor3", theme.Foreground, 0.2)
                Tween(btn, "TextColor3", theme.TextDim, 0.2)
            end
        end)

        -- Tab content container
        local tabContent = NewInstance("Frame", content, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })
        
        local tabContentList = NewInstance("UIListLayout", tabContent, {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        tab.IsActive = false

        local function setVisible(vis)
            tabContent.Visible = vis
            tab.IsActive = vis
            if vis then
                btn.BackgroundColor3 = theme.Accent
                btn.TextColor3 = theme.Text
                local accentGradient = btn:FindFirstChild("Gradient") or AddGradient(btn, theme.Accent, theme.AccentGradient, 90)
                accentGradient.Enabled = true
            else
                btn.BackgroundColor3 = theme.Foreground
                btn.TextColor3 = theme.TextDim
                local accentGradient = btn:FindFirstChild("Gradient")
                if accentGradient then accentGradient.Enabled = false end
            end
        end

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(win.Tabs) do
                t:SetVisible(false)
            end
            setVisible(true)
        end)

        tab.SetVisible = setVisible
        table.insert(win.Tabs, tab)

        -- ===== ADD SECTION =====
        function tab:AddSection(title)
            local section = {}
            
            local sectionContainer = NewInstance("Frame", tabContent, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
            })

            -- Section title with line
            local titleContainer = NewInstance("Frame", sectionContainer, {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
            })

            local accentBar = NewInstance("Frame", titleContainer, {
                Size = UDim2.new(0, 3, 0, 16),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0,
            })
            AddCorner(accentBar, 2)

            local label = NewInstance("TextLabel", titleContainer, {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = title or "Section",
                TextColor3 = theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local line = NewInstance("Frame", titleContainer, {
                Size = UDim2.new(1, -20, 0, 1),
                Position = UDim2.new(0, 12, 1, -1),
                BackgroundColor3 = theme.Border,
                BorderSizePixel = 0,
                BackgroundTransparency = 0.5,
            })

            -- ===== ADD BUTTON =====
            function section:AddButton(text, callback)
                local btn = NewInstance("TextButton", sectionContainer, {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Foreground,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                AddCorner(btn, 8)
                AddStroke(btn, theme.Border, 1)

                btn.MouseEnter:Connect(function()
                    Tween(btn, "BackgroundColor3", theme.Accent, 0.2)
                    Tween(btn, "TextColor3", Color3.fromRGB(255, 255, 255), 0.2)
                    local glow = btn:FindFirstChild("Glow") or NewInstance("UIStroke", btn, {
                        Color = theme.Glow,
                        Thickness = 2,
                        Transparency = 0,
                    })
                    glow.Name = "Glow"
                end)
                
                btn.MouseLeave:Connect(function()
                    Tween(btn, "BackgroundColor3", theme.Foreground, 0.2)
                    Tween(btn, "TextColor3", theme.Text, 0.2)
                    local glow = btn:FindFirstChild("Glow")
                    if glow then glow:Destroy() end
                end)

                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            -- ===== ADD TOGGLE =====
            function section:AddToggle(text, default, callback)
                local container = NewInstance("TextButton", sectionContainer, {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Foreground,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                AddCorner(container, 8)
                AddStroke(container, theme.Border, 1)

                local label = NewInstance("TextLabel", container, {
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                -- Toggle switch
                local sw = NewInstance("Frame", container, {
                    Size = UDim2.new(0, 42, 0, 22),
                    Position = UDim2.new(1, -14, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = theme.ToggleOff,
                    BorderSizePixel = 0,
                })
                AddCorner(sw, 11)

                local knob = NewInstance("Frame", sw, {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                })
                AddCorner(knob, 9)
                AddStroke(knob, Color3.fromRGB(200, 200, 200), 1)

                local state = default or false

                local function update(instant)
                    if state then
                        if instant then
                            knob.Position = UDim2.new(1, -2, 0.5, 0)
                            sw.BackgroundColor3 = theme.Accent
                        else
                            Tween(knob, "Position", UDim2.new(1, -2, 0.5, 0), 0.25, "Quart")
                            Tween(sw, "BackgroundColor3", theme.Accent, 0.25, "Quart")
                        end
                    else
                        if instant then
                            knob.Position = UDim2.new(0, 2, 0.5, 0)
                            sw.BackgroundColor3 = theme.ToggleOff
                        else
                            Tween(knob, "Position", UDim2.new(0, 2, 0.5, 0), 0.25, "Quart")
                            Tween(sw, "BackgroundColor3", theme.ToggleOff, 0.25, "Quart")
                        end
                    end
                end
                update(true)

                container.MouseButton1Click:Connect(function()
                    state = not state
                    update()
                    if callback then callback(state) end
                end)

                return {
                    Set = function(v)
                        state = v
                        update(true)
                    end,
                    Get = function() return state end,
                }
            end

            -- ===== ADD SLIDER =====
            function section:AddSlider(text, min, max, default, callback)
                local container = NewInstance("Frame", sectionContainer, {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundColor3 = theme.Foreground,
                    BorderSizePixel = 0,
                })
                AddCorner(container, 8)
                AddStroke(container, theme.Border, 1)

                local label = NewInstance("TextLabel", container, {
                    Size = UDim2.new(0.7, 0, 0, 20),
                    Position = UDim2.new(0, 12, 0, 6),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local valueLabel = NewInstance("TextLabel", container, {
                    Size = UDim2.new(0.3, -24, 0, 20),
                    Position = UDim2.new(0.7, 12, 0, 6),
                    BackgroundTransparency = 1,
                    Text = tostring(default or min),
                    TextColor3 = theme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local bar = NewInstance("Frame", container, {
                    Size = UDim2.new(1, -24, 0, 8),
                    Position = UDim2.new(0, 12, 0, 32),
                    BackgroundColor3 = theme.ToggleOff,
                    BorderSizePixel = 0,
                })
                AddCorner(bar, 4)

                local fill = NewInstance("Frame", bar, {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                })
                AddCorner(fill, 4)
                AddGradient(fill, theme.Accent, theme.AccentGradient, 0)

                local knob = NewInstance("Frame", bar, {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                })
                AddCorner(knob, 7)
                AddStroke(knob, theme.Accent, 2)

                local value = default or min
                local function updateSlider()
                    local percent = (value - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    valueLabel.Text = tostring(math.floor(value * 100) / 100)
                    if callback then callback(value) end
                end
                updateSlider()

                local function setValueFromMouse()
                    local x = math.clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * x
                    updateSlider()
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        setValueFromMouse()
                        local connection
                        connection = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                setValueFromMouse()
                            else
                                connection:Disconnect()
                            end
                        end)
                    end
                end)

                return {
                    Set = function(v)
                        value = math.clamp(v, min, max)
                        updateSlider()
                    end,
                    Get = function() return value end,
                }
            end

            -- ===== ADD DROPDOWN =====
            function section:AddDropdown(text, options, default, callback)
                local container = NewInstance("Frame", sectionContainer, {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                })

                local btn = NewInstance("TextButton", container, {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Foreground,
                    Text = text .. " : " .. (default or "Select"),
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                AddCorner(btn, 8)
                AddStroke(btn, theme.Border, 1)

                -- Dropdown arrow
                local arrow = NewInstance("TextLabel", btn, {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                })

                -- Dropdown menu
                local menu = NewInstance("Frame", container, {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 38),
                    BackgroundColor3 = theme.Foreground2,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                })
                AddCorner(menu, 8)
                AddStroke(menu, theme.Border, 1)

                local menuList = NewInstance("UIListLayout", menu, {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                
                NewInstance("UIPadding", menu, {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                })

                local selected = default or options[1]
                local isOpen = false

                local function buildOptions()
                    for _, opt in pairs(options) do
                        local optBtn = NewInstance("TextButton", menu, {
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = theme.Foreground2,
                            Text = tostring(opt),
                            TextColor3 = theme.TextDim,
                            TextSize = 11,
                            Font = Enum.Font.GothamBold,
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                        })
                        AddCorner(optBtn, 6)

                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            btn.Text = text .. " : " .. tostring(selected)
                            if callback then callback(selected) end
                            isOpen = false
                            Tween(menu, "Size", UDim2.new(1, 0, 0, 0), 0.2, "Quart")
                            Tween(arrow, "Rotation", 0, 0.2)
                            task.wait(0.2)
                            menu.Visible = false
                        end)

                        optBtn.MouseEnter:Connect(function()
                            Tween(optBtn, "BackgroundColor3", theme.Accent, 0.15)
                            Tween(optBtn, "TextColor3", Color3.fromRGB(255, 255, 255), 0.15)
                        end)
                        
                        optBtn.MouseLeave:Connect(function()
                            Tween(optBtn, "BackgroundColor3", theme.Foreground2, 0.15)
                            Tween(optBtn, "TextColor3", theme.TextDim, 0.15)
                        end)
                    end
                end
                buildOptions()

                btn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    menu.Visible = true
                    local height = #options * 30 + 8
                    if isOpen then
                        Tween(menu, "Size", UDim2.new(1, 0, 0, height), 0.25, "Quart")
                        Tween(arrow, "Rotation", 180, 0.25)
                        container.Size = UDim2.new(1, 0, 0, 36 + height)
                    else
                        Tween(menu, "Size", UDim2.new(1, 0, 0, 0), 0.25, "Quart")
                        Tween(arrow, "Rotation", 0, 0.25)
                        task.wait(0.25)
                        menu.Visible = false
                        container.Size = UDim2.new(1, 0, 0, 36)
                    end
                end)

                return {
                    Get = function() return selected end,
                    Set = function(opt)
                        for _, o in pairs(options) do
                            if o == opt then
                                selected = opt
                                btn.Text = text .. " : " .. tostring(selected)
                                if callback then callback(selected) end
                                break
                            end
                        end
                    end,
                }
            end

            -- ===== ADD TEXTBOX =====
            function section:AddTextbox(text, placeholder, default, callback)
                local container = NewInstance("Frame", sectionContainer, {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = theme.Foreground,
                    BorderSizePixel = 0,
                })
                AddCorner(container, 8)
                AddStroke(container, theme.Border, 1)

                local label = NewInstance("TextLabel", container, {
                    Size = UDim2.new(0.35, 0, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local box = NewInstance("TextBox", container, {
                    Size = UDim2.new(0.65, -24, 0, 26),
                    Position = UDim2.new(0.35, 12, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = theme.Background2,
                    Text = default or "",
                    PlaceholderText = placeholder or "Type...",
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                })
                AddCorner(box, 6)

                box.FocusLost:Connect(function(enterPressed)
                    if callback then callback(box.Text) end
                end)

                return {
                    Get = function() return box.Text end,
                    Set = function(txt) box.Text = txt end,
                }
            end

            -- ===== ADD DISCORD INVITE =====
            function section:AddDiscordInvite(config)
                local container = NewInstance("Frame", sectionContainer, {
                    Size = UDim2.new(1, 0, 0, 65),
                    BackgroundColor3 = theme.Foreground,
                    BorderSizePixel = 0,
                })
                AddCorner(container, 8)
                AddStroke(container, theme.Border, 1)

                -- Discord logo
                local logo = NewInstance("ImageLabel", container, {
                    Size = UDim2.new(0, 40, 0, 40),
                    Position = UDim2.new(0, 12, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Image = config.Logo or "rbxassetid://1234567890",
                    ImageColor3 = theme.Text,
                })
                AddCorner(logo, 8)

                local titleLabel = NewInstance("TextLabel", container, {
                    Size = UDim2.new(1, -130, 0, 22),
                    Position = UDim2.new(0, 64, 0, 10),
                    BackgroundTransparency = 1,
                    Text = config.Title or "Discord Server",
                    TextColor3 = theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local descLabel = NewInstance("TextLabel", container, {
                    Size = UDim2.new(1, -130, 0, 16),
                    Position = UDim2.new(0, 64, 0, 36),
                    BackgroundTransparency = 1,
                    Text = config.Desc or "Join our community!",
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local joinBtn = NewInstance("TextButton", container, {
                    Size = UDim2.new(0, 90, 0, 30),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = theme.Accent,
                    Text = "Copy Invite",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                AddCorner(joinBtn, 6)
                AddGradient(joinBtn, theme.Accent, theme.AccentGradient, 90)

                local inviteCode = config.Invite or "discord.gg/xxx"

                joinBtn.MouseEnter:Connect(function()
                    Tween(joinBtn, "BackgroundColor3", theme.Accent2, 0.2)
                end)
                joinBtn.MouseLeave:Connect(function()
                    Tween(joinBtn, "BackgroundColor3", theme.Accent, 0.2)
                end)

                joinBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        setclipboard(inviteCode)
                    end)
                    joinBtn.Text = "✓ Copied!"
                    Tween(joinBtn, "BackgroundColor3", theme.Success, 0.2)
                    task.wait(1.5)
                    joinBtn.Text = "Copy Invite"
                    Tween(joinBtn, "BackgroundColor3", theme.Accent, 0.2)
                end)
            end

            return section
        end

        -- Mặc định mở tab đầu tiên
        if #win.Tabs == 1 then setVisible(true) end

        return tab
    end

    -- Animation khi window xuất hiện
    mainContainer.Position = UDim2.new(0.5, -260, 0.5, -260)
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(mainContainer, "Size", UDim2.new(0, 520, 0, 420), 0.4, "Quart")

    table.insert(self.Windows, win)
    return win
end

return Nyx
