local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Tối giản Library
local Library = {
    Flags = {},
    Windows = {},
    Themes = {
        Default = {
            Background = Color3.fromRGB(25, 25, 25),
            Foreground = Color3.fromRGB(35, 35, 35),
            Accent = Color3.fromRGB(255, 140, 0),
            Text = Color3.fromRGB(220, 220, 220),
            TextDim = Color3.fromRGB(150, 150, 150),
            Border = Color3.fromRGB(45, 45, 45),
        }
    }
}

-- Helper Functions
local function CreateTween(obj, prop, val, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad), {[prop] = val})
    tween:Play()
    return tween
end

local function MakeDraggable(frame)
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                task.wait()
                local delta = Mouse.X - dragStart.X
                local deltaY = Mouse.Y - dragStart.Y
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta, startPos.Y.Scale, startPos.Y.Offset + deltaY)
            end
        end
    end)
end

-- Main Functions
function Library:NewWindow(title)
    local win = {}
    
    -- Tạo ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleUI"
    gui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.5, -200, 0.5, -175)
    main.BackgroundColor3 = Library.Themes.Default.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    -- Border
    local border = Instance.new("UIStroke", main)
    border.Color = Library.Themes.Default.Border
    border.Thickness = 1
    
    MakeDraggable(main)
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Library"
    titleLabel.TextColor3 = Library.Themes.Default.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Tab Container
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(0, 130, 1, -30)
    tabs.Position = UDim2.new(0, 0, 0, 30)
    tabs.BackgroundTransparency = 1
    tabs.Parent = main
    
    local tabList = Instance.new("UIListLayout", tabs)
    tabList.Padding = UDim.new(0, 3)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Content Container
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -140, 1, -40)
    content.Position = UDim2.new(0, 135, 0, 35)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.BorderSizePixel = 0
    content.Parent = main
    
    local contentList = Instance.new("UIListLayout", content)
    contentList.Padding = UDim.new(0, 4)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    
    win.Tabs = {}
    win.CurrentTab = nil
    
    function win:AddTab(name)
        local tab = {}
        
        -- Tab Button
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.Position = UDim2.new(0, 5, 0, 0)
        btn.BackgroundColor3 = Library.Themes.Default.Foreground
        btn.Text = name
        btn.TextColor3 = Library.Themes.Default.TextDim
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = tabs
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        
        -- Tab Content Holder
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = content
        
        local tabContentList = Instance.new("UIListLayout", tabContent)
        tabContentList.Padding = UDim.new(0, 4)
        tabContentList.SortOrder = Enum.SortOrder.LayoutOrder
        
        -- Tab Selection
        local selected = false
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(win.Tabs) do
                t:SetVisible(false)
            end
            tab:SetVisible(true)
        end)
        
        function tab:SetVisible(vis)
            tabContent.Visible = vis
            selected = vis
            btn.BackgroundColor3 = vis and Library.Themes.Default.Accent or Library.Themes.Default.Foreground
            btn.TextColor3 = vis and Library.Themes.Default.Text or Library.Themes.Default.TextDim
        end
        
        table.insert(win.Tabs, tab)
        
        function tab:AddSection(name)
            local section = {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = name or "Section"
            label.TextColor3 = Library.Themes.Default.Text
            label.TextSize = 14
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            section.Frame = frame
            
            function section:AddButton(text, callback)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 28)
                btn.BackgroundColor3 = Library.Themes.Default.Foreground
                btn.Text = text
                btn.TextColor3 = Library.Themes.Default.Text
                btn.TextSize = 12
                btn.Font = Enum.Font.GothamBold
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.Parent = frame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end
            
            function section:AddToggle(text, default, callback)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 28)
                btn.BackgroundColor3 = Library.Themes.Default.Foreground
                btn.Text = text
                btn.TextColor3 = Library.Themes.Default.Text
                btn.TextSize = 12
                btn.Font = Enum.Font.GothamBold
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.Parent = frame
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(0, 30, 0, 16)
                toggleFrame.Position = UDim2.new(1, -40, 0.5, 0)
                toggleFrame.AnchorPoint = Vector2.new(0, 0.5)
                toggleFrame.BackgroundColor3 = Library.Themes.Default.Border
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Parent = btn
                Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1, 0)
                
                local toggleCircle = Instance.new("Frame")
                toggleCircle.Size = UDim2.new(0, 12, 0, 12)
                toggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
                toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
                toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleCircle.BorderSizePixel = 0
                toggleCircle.Parent = toggleFrame
                Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)
                
                local state = default or false
                
                local function updateToggle()
                    if state then
                        CreateTween(toggleCircle, "Position", UDim2.new(1, -2, 0.5, 0), 0.2)
                        CreateTween(toggleFrame, "BackgroundColor3", Library.Themes.Default.Accent, 0.2)
                    else
                        CreateTween(toggleCircle, "Position", UDim2.new(0, 2, 0.5, 0), 0.2)
                        CreateTween(toggleFrame, "BackgroundColor3", Library.Themes.Default.Border, 0.2)
                    end
                end
                updateToggle()
                
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    updateToggle()
                    if callback then callback(state) end
                end)
                
                return {
                    Set = function(v)
                        state = v
                        updateToggle()
                    end,
                    Get = function() return state end
                }
            end
            
            function section:AddSlider(text, min, max, default, callback)
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 40)
                frame.BackgroundTransparency = 1
                frame.Parent = section.Frame
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.7, 0, 0, 20)
                label.BackgroundTransparency = 1
                label.Text = text
                label.TextColor3 = Library.Themes.Default.Text
                label.TextSize = 12
                label.Font = Enum.Font.GothamBold
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
                valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(default or min)
                valueLabel.TextColor3 = Library.Themes.Default.Accent
                valueLabel.TextSize = 12
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = frame
                
                local sliderBar = Instance.new("Frame")
                sliderBar.Size = UDim2.new(1, 0, 0, 6)
                sliderBar.Position = UDim2.new(0, 0, 0, 26)
                sliderBar.BackgroundColor3 = Library.Themes.Default.Border
                sliderBar.BorderSizePixel = 0
                sliderBar.Parent = frame
                Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
                
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = Library.Themes.Default.Accent
                fill.BorderSizePixel = 0
                fill.Parent = sliderBar
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
                
                local value = default or min
                local function updateSlider()
                    local percent = (value - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    valueLabel.Text = tostring(math.floor(value))
                    if callback then callback(value) end
                end
                updateSlider()
                
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local start = input.Position
                        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            task.wait()
                            local x = math.clamp((Mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
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
                    Get = function() return value end
                }
            end
            
            return section
        end
        
        return tab
    end
    
    table.insert(Library.Windows, win)
    return win
end

return Library
