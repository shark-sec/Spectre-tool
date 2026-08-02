--[[
    Plugin Name: Spectre - API Leak Detector
    Author: shark7_7 | roblox: faraojosep
    LinkedIn: https://www.linkedin.com/in/kalebesouza/
    
    Description: Advanced static analysis utility designed to parse LuaSourceContainers
    and identify hardcoded sensitive data such as webhooks, tokens, and API keys.
    Built with modern UI/UX principles for enterprise-grade security auditing.
]]

local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

if not RunService:IsEdit() then return end

local SPECTRE_ICON_ID = "rbxassetid://135016579240616"
local THEME = {
    Background = Color3.fromRGB(15, 15, 18),
    Surface = Color3.fromRGB(25, 25, 30),
    SurfaceHighlight = Color3.fromRGB(35, 35, 42),
    Primary = Color3.fromRGB(0, 195, 255),
    PrimaryHover = Color3.fromRGB(50, 210, 255),
    Danger = Color3.fromRGB(255, 65, 85),
    Success = Color3.fromRGB(45, 215, 115),
    Text = Color3.fromRGB(245, 245, 250),
    SubText = Color3.fromRGB(140, 140, 155),
    ProgressBg = Color3.fromRGB(20, 20, 25)
}

local SUSPECT_PATTERNS = {
    { pattern = "discord%.com/api/webhooks/%d+/[%w%-_]+", type = "Discord Webhook" },
    { pattern = "api_key%s*=%s*['\"][%w%-_]+['\"]", type = "API Key" },
    { pattern = "token%s*=%s*['\"][%w%-_]+['\"]", type = "Access Token" },
    { pattern = "secret%s*=%s*['\"][%w%-_]+['\"]", type = "Client Secret" }
}

local SCAN_SERVICES = {
    game:GetService("Workspace"),
    game:GetService("ReplicatedFirst"),
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerScriptService"),
    game:GetService("ServerStorage"),
    game:GetService("StarterGui"),
    game:GetService("StarterPack"),
    game:GetService("StarterPlayer")
}

local toolbar = plugin:CreateToolbar("Spectre Security Suite")
local toggleButton = toolbar:CreateButton(
    "Spectre Scanner",
    "Open Spectre API Leak Detector",
    SPECTRE_ICON_ID
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    false,
    450,
    600,
    350,
    350
)

local widget = plugin:CreateDockWidgetPluginGui("Spectre_API_Scanner", widgetInfo)
widget.Title = "Spectre | Credential Scanner"
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function create(className, properties, children)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = element
        end
    end
    return element
end

local function bindHoverTween(guiObject, defaultColor, hoverColor)
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local hoverIn = TweenService:Create(guiObject, info, {BackgroundColor3 = hoverColor})
    local hoverOut = TweenService:Create(guiObject, info, {BackgroundColor3 = defaultColor})

    guiObject.MouseEnter:Connect(function() hoverIn:Play() end)
    guiObject.MouseLeave:Connect(function() hoverOut:Play() end)
end

-- UI Hierarchy
local mainContainer = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = THEME.Background,
    Parent = widget
})

create("UIPadding", {
    PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20),
    PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20),
    Parent = mainContainer
})

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    TextColor3 = THEME.Text,
    Text = "SPECTRE SECURE AUDIT",
    Font = Enum.Font.GothamBlack,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainContainer
})

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 30),
    BackgroundTransparency = 1,
    TextColor3 = THEME.SubText,
    Text = "Engineered by shark7_7",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainContainer
})

local scanButton = create("TextButton", {
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 70),
    BackgroundColor3 = THEME.Primary,
    TextColor3 = Color3.fromRGB(10, 10, 15),
    Text = "INITIATE SYSTEM SCAN",
    Font = Enum.Font.GothamBlack,
    TextSize = 13,
    AutoButtonColor = false,
    Parent = mainContainer
}, {
    create("UICorner", { CornerRadius = UDim.new(0, 4) })
})
bindHoverTween(scanButton, THEME.Primary, THEME.PrimaryHover)

local statusLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 130),
    BackgroundTransparency = 1,
    TextColor3 = THEME.SubText,
    Text = "System Idle. Awaiting command.",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = mainContainer
})

local progressBarBg = create("Frame", {
    Size = UDim2.new(1, 0, 0, 4),
    Position = UDim2.new(0, 0, 0, 155),
    BackgroundColor3 = THEME.ProgressBg,
    BorderSizePixel = 0,
    Parent = mainContainer
}, {
    create("UICorner", { CornerRadius = UDim.new(1, 0) })
})

local progressBarFill = create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = THEME.Primary,
    BorderSizePixel = 0,
    Parent = progressBarBg
}, {
    create("UICorner", { CornerRadius = UDim.new(1, 0) })
})

local resultsScroll = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -180),
    Position = UDim2.new(0, 0, 0, 180),
    BackgroundTransparency = 1,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.SurfaceHighlight,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = mainContainer
}, {
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })
})

-- Core Logic
local function clearResults()
    for _, child in ipairs(resultsScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    progressBarFill.Size = UDim2.new(0, 0, 1, 0)
end

local function createResultCard(scriptInstance, violationType)
    local card = create("Frame", {
        Size = UDim2.new(1, -10, 0, 80),
        BackgroundColor3 = THEME.Surface,
        Parent = resultsScroll
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        create("UIStroke", { Color = THEME.Danger, Transparency = 0.5, Thickness = 1 }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)
        })
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        TextColor3 = THEME.Danger,
        Text = "THREAT DETECTED: " .. string.upper(violationType),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card
    })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = THEME.Text,
        Text = scriptInstance:GetFullName(),
        Font = Enum.Font.Code,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card
    })

    local jumpButton = create("TextButton", {
        Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = THEME.SurfaceHighlight,
        TextColor3 = THEME.Text,
        Text = "Inspect Source",
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = card
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) })
    })
    
    bindHoverTween(jumpButton, THEME.SurfaceHighlight, Color3.fromRGB(65, 65, 75))
    
    jumpButton.MouseButton1Click:Connect(function()
        Selection:Set({scriptInstance})
        plugin:OpenScript(scriptInstance)
    end)
    
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, resultsScroll.UIListLayout.AbsoluteContentSize.Y)
end

local function getScriptsSafe()
    local scripts = {}
    for _, service in ipairs(SCAN_SERVICES) do
        local success, result = pcall(function() return service:GetDescendants() end)
        if success then
            for _, instance in ipairs(result) do
                if instance:IsA("LuaSourceContainer") then
                    table.insert(scripts, instance)
                end
            end
        end
    end
    return scripts
end

local function performScan()
    clearResults()
    scanButton.Text = "SCANNING ENVIRONMENT..."
    scanButton.BackgroundColor3 = THEME.SurfaceHighlight
    statusLabel.Text = "Aggregating DataModel nodes..."
    statusLabel.TextColor3 = THEME.Primary
    
    task.wait(0.1) 
    
    local targetScripts = getScriptsSafe()
    local threatCount = 0
    local totalScripts = #targetScripts
    
    for i, instance in ipairs(targetScripts) do
        local success, sourceCode = pcall(function() return instance.Source end)
        
        if success and type(sourceCode) == "string" then
            for _, suspect in ipairs(SUSPECT_PATTERNS) do
                if string.match(sourceCode, suspect.pattern) then
                    threatCount = threatCount + 1
                    createResultCard(instance, suspect.type)
                end
            end
        end
        
        if i % 25 == 0 then
            statusLabel.Text = string.format("Analyzing script %d of %d...", i, totalScripts)
            progressBarFill.Size = UDim2.new(i / totalScripts, 0, 1, 0)
            task.wait() 
        end
    end
    
    progressBarFill.Size = UDim2.new(1, 0, 1, 0)
    
    if threatCount == 0 then
        statusLabel.Text = string.format("Scan complete. %d scripts verified secure.", totalScripts)
        statusLabel.TextColor3 = THEME.Success
        progressBarFill.BackgroundColor3 = THEME.Success
        
        create("TextLabel", {
            Size = UDim2.new(1, -10, 0, 45),
            BackgroundColor3 = THEME.Surface,
            TextColor3 = THEME.Success,
            Text = "✓ Zero vulnerabilities found.",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = resultsScroll
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            create("UIStroke", { Color = THEME.Success, Transparency = 0.5, Thickness = 1 })
        })
    else
        statusLabel.Text = string.format("Scan finished. Found %d critical threats.", threatCount)
        statusLabel.TextColor3 = THEME.Danger
        progressBarFill.BackgroundColor3 = THEME.Danger
    end
    
    scanButton.Text = "RUN NEW AUDIT"
    scanButton.BackgroundColor3 = THEME.Primary
end

toggleButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

scanButton.MouseButton1Click:Connect(function()
    if scanButton.Text == "SCANNING ENVIRONMENT..." then return end
    progressBarFill.BackgroundColor3 = THEME.Primary
    task.spawn(performScan)
end)
