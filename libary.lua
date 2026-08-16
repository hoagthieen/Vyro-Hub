-- ===================================================== --
--                    NYX LIBRARY v2.0                    --
--            Đẹp, gọn, mượt, giữ cấu trúc redz          --
-- ===================================================== --

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ===== THEMES =====
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 22),
        Foreground = Color3.fromRGB(28, 28, 34),
        Accent = Color3.fromRGB(255, 140, 0),
        Accent2 = Color3.fromRGB(200, 100, 0),
        Text = Color3.fromRGB(235, 235, 245),
        TextDim = Color3.fromRGB(160, 160, 175),
        Border = Color3.fromRGB(50, 50, 60),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Blue = {
        Background = Color3.fromRGB(12, 18, 30),
        Foreground = Color3.fromRGB(22, 30, 48),
        Accent = Color3.fromRGB(0, 150, 255),
        Accent2 = Color3.fromRGB(0, 100, 200),
        Text = Color3.fromRGB(220, 230, 255),
        TextDim = Color3.fromRGB(150, 170, 210),
        Border = Color3.fromRGB(40, 60, 90),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Purple = {
        Background = Color3.fromRGB(20, 12, 30),
        Foreground = Color3.fromRGB(34, 22, 48),
        Accent = Color3.fromRGB(180, 80, 255),
        Accent2 = Color3.fromRGB(130, 40, 200),
        Text = Color3.fromRGB(240, 220, 255),
        TextDim = Color3.fromRGB(180, 160, 210),
        Border = Color3.fromRGB(60, 40, 80),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
}

local CurrentTheme = "Dark"

-- ===== HELPER FUNCTIONS =====
local function Tween(obj, prop, val, time, style)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle[style or "Quad"])
    local t = TweenService:Create(obj, info, {[prop] = val})
    t:Play()
    return t
end

local function MakeDraggable(frame)
    local drag, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = input.Position
            startPos = frame.Position
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                task.wait()
                local delta = Mouse.X - drag.X
                local deltaY = Mouse.Y - drag.Y
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta, startPos.Y.Scale, startPos.Y.Offset + deltaY)
            end
        end
    end)
end

local function NewInstance(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
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
        -- Có thể thêm logic cập nhật toàn bộ GUI ở đây nếu cần
    end
end

-- ===== CREATE WINDOW =====
function Nyx:NewWindow(title)
    local win = {}
    local theme = self.Themes[self.CurrentTheme]

    -- ScreenGui
    local gui = NewInstance("ScreenGui", CoreGui, { Name = "NyxUI" })
    local main = NewInstance("Frame", gui, {
        Size = UDim2.new(0, 480, 0, 400),
        Position = UDim2.new(0.5, -240, 0.5, -200),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    NewInstance("UICorner", main, { CornerRadius = UDim.new(0, 10) })
    NewInstance("UIStroke", main, { Color = theme.Border, Thickness = 1 })

    -- Shadow (đổ bóng mềm)
    local shadow = NewInstance("ImageLabel", main, {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://13135751763",
        ImageColor3 = theme.Shadow,
        ImageTransparency = 0.6,
        ZIndex = 0,
    })

    MakeDraggable(main)

    -- Title bar
    local titleBar = NewInstance("Frame", main, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
    })

    local titleLabel = NewInstance("TextLabel", titleBar, {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Nyx",
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
    })

    -- Nút Close
    local closeBtn = NewInstance("TextButton", titleBar, {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -34, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    NewInstance("UICorner", closeBtn, { CornerRadius = UDim.new(0, 5) })
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Tab sidebar
    local sidebar = NewInstance("Frame", main, {
        Size = UDim2.new(0, 140, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
    })
    local sideList = NewInstance("UIListLayout", sidebar, {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- Content area
    local content = NewInstance("ScrollingFrame", main, {
        Size = UDim2.new(1, -150, 1, -46),
        Position = UDim2.new(0, 145, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        BorderSizePixel = 0,
    })
    local contentList = NewInstance("UIListLayout", content, {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    win.Tabs = {}
    win.CurrentTab = nil

    -- ===== ADD TAB =====
    function win:AddTab(name)
        local tab = {}

        -- Tab button
        local btn = NewInstance("TextButton", sidebar, {
            Size = UDim2.new(1, -12, 0, 30),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundColor3 = theme.Foreground,
            Text = name,
            TextColor3 = theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        })
        NewInstance("UICorner", btn, { CornerRadius = UDim.new(0, 6) })

        -- Tab content container
        local tabContent = NewInstance("Frame", content, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        })
        local tabContentList = NewInstance("UIListLayout", tabContent, {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        local function setVisible(vis)
            tabContent.Visible = vis
            btn.BackgroundColor3 = vis and theme.Accent or theme.Foreground
            btn.TextColor3 = vis and theme.Text or theme.TextDim
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
            local frame = NewInstance("Frame", tabContent, {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
            })

            local label = NewInstance("TextLabel", frame, {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Text = title or "Section",
                TextColor3 = theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            -- ===== ADD BUTTON =====
            function section:AddButton(text, callback)
                local btn = NewInstance("TextButton", frame, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = theme.Foreground,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                NewInstance("UICorner", btn, { CornerRadius = UDim.new(0, 6) })

                btn.MouseEnter:Connect(function()
                    Tween(btn, "BackgroundColor3", theme.Accent, 0.15)
                    Tween(btn, "TextColor3", Color3.fromRGB(255, 255, 255), 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, "BackgroundColor3", theme.Foreground, 0.15)
                    Tween(btn, "TextColor3", theme.Text, 0.15)
                end)

                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            -- ===== ADD TOGGLE =====
            function section:AddToggle(text, default, callback)
                local btn = NewInstance("TextButton", frame, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = theme.Foreground,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                NewInstance("UICorner", btn, { CornerRadius = UDim.new(0, 6) })

                -- Toggle switch
                local sw = NewInstance("Frame", btn, {
                    Size = UDim2.new(0, 34, 0, 18),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                })
                NewInstance("UICorner", sw, { CornerRadius = UDim.new(1, 0) })

                local knob = NewInstance("Frame", sw, {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 2, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                })
                NewInstance("UICorner", knob, { CornerRadius = UDim.new(1, 0) })

                local state = default or false

                local function update()
                    if state then
                        Tween(knob, "Position", UDim2.new(1, -2, 0.5, 0), 0.2)
                        Tween(sw, "BackgroundColor3", theme.Accent, 0.2)
                    else
                        Tween(knob, "Position", UDim2.new(0, 2, 0.5, 0), 0.2)
                        Tween(sw, "BackgroundColor3", theme.Border, 0.2)
                    end
                end
                update()

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    update()
                    if callback then callback(state) end
                end)

                return {
                    Set = function(v)
                        state = v
                        update()
                    end,
                    Get = function() return state end,
                }
            end

            -- ===== ADD SLIDER =====
            function section:AddSlider(text, min, max, default, callback)
                local frame = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                })

                local label = NewInstance("TextLabel", frame, {
                    Size = UDim2.new(0.7, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local valueLabel = NewInstance("TextLabel", frame, {
                    Size = UDim2.new(0.3, 0, 0, 20),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default or min),
                    TextColor3 = theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local bar = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = theme.Border,
                    BorderSizePixel = 0,
                })
                NewInstance("UICorner", bar, { CornerRadius = UDim.new(1, 0) })

                local fill = NewInstance("Frame", bar, {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                })
                NewInstance("UICorner", fill, { CornerRadius = UDim.new(1, 0) })

                local value = default or min
                local function updateSlider()
                    local percent = (value - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    valueLabel.Text = tostring(math.floor(value))
                    if callback then callback(value) end
                end
                updateSlider()

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            task.wait()
                            local x = math.clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                            value = min + (max - min) * x
                            updateSlider()
                        end
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
                -- options: table { "Option1", "Option2", ... } hoặc { key = "value" }
                local frame = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                })

                local btn = NewInstance("TextButton", frame, {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = theme.Foreground,
                    Text = text .. " : " .. (default or "Select"),
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                NewInstance("UICorner", btn, { CornerRadius = UDim.new(0, 6) })

                -- Dropdown menu (ẩn)
                local menu = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = theme.Foreground,
                    ClipsDescendants = true,
                    Visible = false,
                })
                NewInstance("UICorner", menu, { CornerRadius = UDim.new(0, 6) })
                local menuList = NewInstance("UIListLayout", menu, {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local selected = default or options[1]
                local isOpen = false

                local function buildOptions()
                    for _, opt in pairs(options) do
                        local optBtn = NewInstance("TextButton", menu, {
                            Size = UDim2.new(1, -8, 0, 26),
                            Position = UDim2.new(0, 4, 0, 0),
                            BackgroundColor3 = theme.Foreground,
                            Text = tostring(opt),
                            TextColor3 = theme.TextDim,
                            TextSize = 11,
                            Font = Enum.Font.GothamBold,
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                        })
                        NewInstance("UICorner", optBtn, { CornerRadius = UDim.new(0, 4) })

                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            btn.Text = text .. " : " .. tostring(selected)
                            if callback then callback(selected) end
                            -- Đóng menu
                            Tween(menu, "Size", UDim2.new(1, 0, 0, 0), 0.2)
                            menu.Visible = false
                            isOpen = false
                        end)

                        optBtn.MouseEnter:Connect(function()
                            Tween(optBtn, "BackgroundColor3", theme.Accent, 0.1)
                            Tween(optBtn, "TextColor3", Color3.fromRGB(255, 255, 255), 0.1)
                        end)
                        optBtn.MouseLeave:Connect(function()
                            Tween(optBtn, "BackgroundColor3", theme.Foreground, 0.1)
                            Tween(optBtn, "TextColor3", theme.TextDim, 0.1)
                        end)
                    end
                end
                buildOptions()

                btn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    menu.Visible = true
                    local height = #options * 28 + 8
                    Tween(menu, "Size", UDim2.new(1, 0, 0, isOpen and height or 0), 0.25)
                    if not isOpen then
                        Tween(menu, "Size", UDim2.new(1, 0, 0, 0), 0.2)
                        wait(0.2)
                        menu.Visible = false
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
                local frame = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                })

                local label = NewInstance("TextLabel", frame, {
                    Size = UDim2.new(0.4, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local box = NewInstance("TextBox", frame, {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.new(0.4, 0, 0, 0),
                    BackgroundColor3 = theme.Foreground,
                    Text = default or "",
                    PlaceholderText = placeholder or "Type...",
                    TextColor3 = theme.Text,
                    PlaceholderColor3 = theme.TextDim,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    ClearTextOnFocus = false,
                })
                NewInstance("UICorner", box, { CornerRadius = UDim.new(0, 6) })

                box.FocusLost:Connect(function()
                    if callback then callback(box.Text) end
                end)

                return {
                    Get = function() return box.Text end,
                    Set = function(txt) box.Text = txt end,
                }
            end

            -- ===== ADD DISCORD INVITE =====
            function section:AddDiscordInvite(config)
                local frame = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1,
                })

                local container = NewInstance("Frame", frame, {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = theme.Foreground,
                })
                NewInstance("UICorner", container, { CornerRadius = UDim.new(0, 6) })

                local logo = NewInstance("ImageLabel", container, {
                    Size = UDim2.new(0, 36, 0, 36),
                    Position = UDim2.new(0, 10, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Image = config.Logo or "rbxassetid://1234567890",
                })
                NewInstance("UICorner", logo, { CornerRadius = UDim.new(0, 6) })

                local titleLabel = NewInstance("TextLabel", container, {
                    Size = UDim2.new(1, -120, 0, 20),
                    Position = UDim2.new(0, 56, 0, 8),
                    BackgroundTransparency = 1,
                    Text = config.Title or "Discord",
                    TextColor3 = theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local descLabel = NewInstance("TextLabel", container, {
                    Size = UDim2.new(1, -120, 0, 16),
                    Position = UDim2.new(0, 56, 0, 30),
                    BackgroundTransparency = 1,
                    Text = config.Desc or "Join our community!",
                    TextColor3 = theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local joinBtn = NewInstance("TextButton", container, {
                    Size = UDim2.new(0, 80, 0, 26),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = theme.Accent,
                    Text = "Copy",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                })
                NewInstance("UICorner", joinBtn, { CornerRadius = UDim.new(0, 6) })

                local inviteCode = config.Invite or "discord.gg/xxx"

                joinBtn.MouseButton1Click:Connect(function()
                    setclipboard(inviteCode)
                    joinBtn.Text = "Copied!"
                    Tween(joinBtn, "BackgroundColor3", Color3.fromRGB(50, 200, 50), 0.2)
                    task.wait(1.5)
                    joinBtn.Text = "Copy"
                    Tween(joinBtn, "BackgroundColor3", theme.Accent, 0.2)
                end)
            end

            return section
        end

        -- Mặc định mở tab đầu tiên
        if #win.Tabs == 1 then setVisible(true) end

        return tab
    end

    table.insert(self.Windows, win)
    return win
end

return Nyx
