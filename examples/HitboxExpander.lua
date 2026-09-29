-- Hitbox Expander · LuaInterface 1.0.0-beta
-- Execute somente em um cliente compatível que permita HTTP e loadstring.

local source, loadError = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, loadError)

local LuaInterface = source()
assert(type(LuaInterface) == "table" and type(LuaInterface.CreateWindow) == "function",
    "LuaInterface não inicializou; execute no cliente com LocalPlayer e PlayerGui disponíveis.")

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BALL_NAME = "Ball"
local DEFAULT_MULTIPLIER = 1
local MIN_MULTIPLIER = 0.5
local MAX_MULTIPLIER = 25
local DEFAULT_HITBOX_TRANSPARENCY = 0.6
local DEFAULT_PLATFORM_SIZE = 12
local DEFAULT_PLATFORM_COLOR = Color3.fromRGB(110, 150, 255)

local hitboxEnabled = false
local hitboxMultiplier = DEFAULT_MULTIPLIER
local hitboxTransparency = DEFAULT_HITBOX_TRANSPARENCY
local helperEnabled = false
local platformVisible = true
local platformSize = DEFAULT_PLATFORM_SIZE
local platformColor = DEFAULT_PLATFORM_COLOR
local boxEnabled = false
local boxIndicators = {}
local helperTarget = nil
local helperPlatform = nil
local helperWeld = nil
local unloaded = false

local trackedBalls = {}
local ballOrder = {}
local connections = {}
local partConnections = {}
local syncHelperTarget
local destroyHelperPlatform

local Window = LuaInterface:CreateWindow({
    Title = "Hitbox Expander",
    Footer = "LuaInterface 1.0.0-beta",
    Resizable = true,
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
})
Window:SetTheme("Obsidian")

local Reach = Window:AddTab("Reach", {
    Icon = "lucide:target",
    Description = "Tamanho e visual da hitbox",
})
local Helper = Window:AddTab("Helper", {
    Icon = "lucide:package",
    Description = "Plataforma presa à bola",
})

local ReachGroup = Reach:AddLeftGroupbox({
    Name = "Reach",
    Description = "Ajuste a hitbox da bola",
    IconName = "target",
})
local HelperGroup = Helper:AddLeftGroupbox({
    Name = "Helper ZZZ",
    Description = "Crie uma base que acompanha a bola",
    IconName = "package",
})

local function restoreAllBalls()
    for part, original in pairs(trackedBalls) do
        if part and part.Parent then
            part.Size = original.Size
            part.Transparency = original.Transparency
            part.CanCollide = original.CanCollide
            part.Material = original.Material
        end
    end
end

local function applyPlatformSettings()
    if not helperPlatform or not helperPlatform.Parent then
        return
    end

    helperPlatform.Size = Vector3.new(platformSize, 1, platformSize)
    helperPlatform.Color = platformColor
    helperPlatform.Transparency = platformVisible and 0 or 1
    helperPlatform.CastShadow = platformVisible
    -- Show afeta apenas o visual: a base continua sólida quando fica invisível.
    helperPlatform.CanCollide = true
    helperPlatform.CanTouch = true
    helperPlatform.CanQuery = true
end

destroyHelperPlatform = function()
    if helperPlatform and helperPlatform.Parent then
        helperPlatform:Destroy()
    end
    helperPlatform = nil
    helperWeld = nil
    helperTarget = nil
end

local function destroyBoxFor(part)
    local box = boxIndicators[part]
    if box then
        box:Destroy()
        boxIndicators[part] = nil
    end
end

local function createBoxFor(part)
    if not boxEnabled or not part or not part.Parent or boxIndicators[part] then
        return
    end

    local box = Instance.new("SelectionBox")
    box.Name = "HitboxExpanderBox"
    box.Adornee = part
    box.Color3 = Color3.fromRGB(167, 139, 250)
    box.SurfaceColor3 = box.Color3
    box.SurfaceTransparency = 1
    box.LineThickness = 0.04
    box.Parent = Workspace
    boxIndicators[part] = box
end

local function setBoxEnabled(value)
    boxEnabled = value == true
    if boxEnabled then
        for part in pairs(trackedBalls) do
            createBoxFor(part)
        end
    else
        for part in pairs(boxIndicators) do
            destroyBoxFor(part)
        end
    end
end

local function findBall()
    for _, part in ipairs(ballOrder) do
        if part and part.Parent and trackedBalls[part] then
            return part
        end
    end
    return nil
end

local function attachPlatform(part)
    if not part or not part.Parent then
        return false
    end

    local platform = Instance.new("Part")
    platform.Name = "HelperZZZPlatform"
    platform.Size = Vector3.new(platformSize, 1, platformSize)
    platform.Color = platformColor
    platform.Material = Enum.Material.SmoothPlastic
    platform.Transparency = platformVisible and 0 or 1
    platform.CastShadow = platformVisible
    platform.Anchored = false
    platform.Massless = true
    platform.CanCollide = true
    platform.CanTouch = true
    platform.CanQuery = true
    platform.TopSurface = Enum.SurfaceType.Smooth
    platform.BottomSurface = Enum.SurfaceType.Smooth
    -- O deslocamento solicitado é de 1 stud para baixo, relativo à orientação da bola.
    platform.CFrame = part.CFrame * CFrame.new(0, -1, 0)
    platform.Parent = Workspace

    helperPlatform = platform
    helperTarget = part
    applyPlatformSettings()

    local ok, weldOrError = pcall(function()
        local weld = Instance.new("WeldConstraint")
        weld.Name = "HelperZZZWeld"
        weld.Part0 = part
        weld.Part1 = platform
        weld.Parent = platform
        return weld
    end)

    if ok then
        helperWeld = weldOrError
    else
        -- Só usa atualização por frame se o ambiente não aceitar o WeldConstraint.
        platform.Anchored = true
        helperWeld = nil
        warn("Helper ZZZ: WeldConstraint indisponível; usando acompanhamento alternativo.", weldOrError)
    end

    return true
end

syncHelperTarget = function()
    if not helperEnabled then
        destroyHelperPlatform()
        return false
    end

    if helperPlatform and helperPlatform.Parent
        and helperTarget and helperTarget.Parent and trackedBalls[helperTarget] then
        applyPlatformSettings()
        return true
    end

    destroyHelperPlatform()
    local target = findBall()
    if not target then
        return false
    end

    return attachPlatform(target)
end

local function addBall(part)
    if not part:IsA("BasePart") or trackedBalls[part] then
        return
    end

    trackedBalls[part] = {
        Size = part.Size,
        Transparency = part.Transparency,
        CanCollide = part.CanCollide,
        Material = part.Material,
        Color = part.Color,
    }
    table.insert(ballOrder, part)
    if boxEnabled then
        createBoxFor(part)
    end

    local ancestryConnection
    ancestryConnection = part.AncestryChanged:Connect(function()
        if part.Parent ~= nil or not trackedBalls[part] then
            return
        end

        trackedBalls[part] = nil
        partConnections[part] = nil
        destroyBoxFor(part)
        for index = #ballOrder, 1, -1 do
            if ballOrder[index] == part then
                table.remove(ballOrder, index)
                break
            end
        end
        if ancestryConnection then
            ancestryConnection:Disconnect()
        end

        if helperTarget == part then
            destroyHelperPlatform()
            if helperEnabled then
                task.defer(function()
                    if syncHelperTarget then
                        syncHelperTarget()
                    end
                end)
            end
        end
    end)
    partConnections[part] = ancestryConnection

    if helperEnabled and not helperTarget then
        task.defer(function()
            if syncHelperTarget then
                syncHelperTarget()
            end
        end)
    end
end

connections.DescendantAdded = Workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name == BALL_NAME then
        addBall(descendant)
    end
end)

for _, descendant in ipairs(Workspace:GetDescendants()) do
    if descendant.Name == BALL_NAME then
        addBall(descendant)
    end
end

connections.Heartbeat = RunService.Heartbeat:Connect(function()
    if hitboxEnabled then
        for part, original in pairs(trackedBalls) do
            if part and part.Parent then
                local newSize = original.Size * hitboxMultiplier
                if part.Size ~= newSize then
                    part.Size = newSize
                end
                if part.Transparency ~= hitboxTransparency then
                    part.Transparency = hitboxTransparency
                end
                if part.CanCollide then
                    part.CanCollide = false
                end
                if part.Material ~= Enum.Material.Neon then
                    part.Material = Enum.Material.Neon
                end
            end
        end
    end

    -- Caminho normal: a plataforma acompanha a bola pela junta, sem loop de posição.
    -- Este bloco só roda quando a criação da junta falhou no ambiente atual.
    if helperEnabled and helperPlatform and helperPlatform.Parent
        and helperTarget and helperTarget.Parent and not (helperWeld and helperWeld.Parent) then
        helperPlatform.CFrame = helperTarget.CFrame * CFrame.new(0, -1, 0)
    end
end)

local hitboxToggle
hitboxToggle = ReachGroup:AddToggle("hitbox-enabled", {
    Name = "Ativar Hitbox Expander",
    Default = false,
    Callback = function(value)
        hitboxEnabled = value
        if hitboxEnabled then
            Window:Notify({
                Type = "Success",
                Title = "Reach ativado",
                Content = "A hitbox será atualizada conforme os controles.",
                Duration = 3,
            })
        else
            restoreAllBalls()
        end
    end,
})

ReachGroup:AddSlider("hitbox-multiplier", {
    Name = "Multiplicador da hitbox",
    Min = MIN_MULTIPLIER,
    Max = MAX_MULTIPLIER,
    Default = DEFAULT_MULTIPLIER,
    Rounding = 1,
    Callback = function(value)
        hitboxMultiplier = value
    end,
})

ReachGroup:AddSlider("hitbox-transparency", {
    Name = "Transparência da hitbox",
    Min = 0,
    Max = 1,
    Default = DEFAULT_HITBOX_TRANSPARENCY,
    Rounding = 2,
    Callback = function(value)
        hitboxTransparency = math.clamp(value, 0, 1)
    end,
})

ReachGroup:AddToggle("hitbox-box", {
    Name = "Box",
    Default = false,
    Callback = setBoxEnabled,
})

ReachGroup:AddButton({
    Text = "Restaurar bolas",
    Func = function()
        hitboxEnabled = false
        restoreAllBalls()
        if hitboxToggle then
            hitboxToggle:SetValue(false)
        end
    end,
})

HelperGroup:AddToggle("helper-zzz-enabled", {
    Name = "Helper ZZZ",
    Default = false,
    Callback = function(value)
        helperEnabled = value
        if helperEnabled then
            if not syncHelperTarget() then
                Window:Notify({
                    Type = "Warning",
                    Title = "Bola não encontrada",
                    Content = "A plataforma será criada quando uma peça chamada Ball aparecer.",
                    Duration = 4,
                })
            end
        else
            destroyHelperPlatform()
        end
    end,
})

HelperGroup:AddSlider("helper-platform-size", {
    Name = "Tamanho da plataforma",
    Min = 2,
    Max = 40,
    Default = DEFAULT_PLATFORM_SIZE,
    Rounding = 1,
    Callback = function(value)
        platformSize = value
        applyPlatformSettings()
    end,
})

HelperGroup:AddColorPicker("helper-platform-color", {
    Title = "Cor da plataforma",
    Default = DEFAULT_PLATFORM_COLOR,
    Callback = function(color)
        platformColor = color
        applyPlatformSettings()
    end,
})

HelperGroup:AddToggle("helper-platform-show", {
    Name = "Mostrar plataforma",
    Default = true,
    Callback = function(value)
        platformVisible = value
        applyPlatformSettings()
    end,
})

local function unloadScript()
    if unloaded then
        return
    end
    unloaded = true
    hitboxEnabled = false
    helperEnabled = false
    destroyHelperPlatform()

    for _, connection in pairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(connections)

    for _, connection in pairs(partConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(partConnections)
    for part in pairs(boxIndicators) do
        destroyBoxFor(part)
    end
    table.clear(ballOrder)

    restoreAllBalls()
    Window:Destroy()
end

HelperGroup:AddButton({
    Text = "Descarregar e restaurar",
    Func = unloadScript,
})

Window:SetPosition(UDim2.fromScale(0.5, 0.5))
Window:Open()
