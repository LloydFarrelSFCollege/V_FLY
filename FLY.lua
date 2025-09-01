local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local flying = false
local speed = 100

-- Ruta al hitbox del jugador
local Hitbox = workspace.placeFolders.entityManifestCollection[player.Name].hitbox
local hitboxVelocity = Hitbox:WaitForChild("hitboxVelocity")

-- Bypass oficial del sistema
local JoltFunction = ReplicatedStorage.network.BindableEvent_Client.applyJoltVelocityToCharacter

-- Variables para controles móviles
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local mobileDirection = Vector3.zero
local flyButton
local directionalButtons = {}

-- Crear interfaz móvil
local function createMobileUI()
    if not isMobile then return end
    
    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlightControls"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Botón de vuelo
    flyButton = Instance.new("TextButton")
    flyButton.Name = "FlyButton"
    flyButton.Size = UDim2.new(0, 80, 0, 80)
    flyButton.Position = UDim2.new(1, -100, 1, -100)
    flyButton.AnchorPoint = Vector2.new(0, 1)
    flyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    flyButton.BorderSizePixel = 0
    flyButton.Text = "FLY"
    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyButton.TextScaled = true
    flyButton.Font = Enum.Font.GothamBold
    flyButton.Parent = screenGui
    
    -- Esquinas redondeadas para el botón de vuelo
    local flyCorner = Instance.new("UICorner")
    flyCorner.CornerRadius = UDim.new(0, 12)
    flyCorner.Parent = flyButton
    
    -- Frame para controles direccionales
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "DirectionalControls"
    controlFrame.Size = UDim2.new(0, 200, 0, 200)
    controlFrame.Position = UDim2.new(0, 20, 1, -220)
    controlFrame.AnchorPoint = Vector2.new(0, 1)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Visible = false
    controlFrame.Parent = screenGui
    
    -- Crear botones direccionales
    local buttonData = {
        {name = "Forward", pos = UDim2.new(0.5, -25, 0, 0), text = "↑", direction = "forward"},
        {name = "Backward", pos = UDim2.new(0.5, -25, 1, -50), text = "↓", direction = "backward"},
        {name = "Left", pos = UDim2.new(0, 0, 0.5, -25), text = "←", direction = "left"},
        {name = "Right", pos = UDim2.new(1, -50, 0.5, -25), text = "→", direction = "right"},
        {name = "Up", pos = UDim2.new(0.5, 25, 0, 25), text = "▲", direction = "up"},
        {name = "Down", pos = UDim2.new(0.5, 25, 1, -75), text = "▼", direction = "down"}
    }
    
    for _, data in ipairs(buttonData) do
        local button = Instance.new("TextButton")
        button.Name = data.name
        button.Size = UDim2.new(0, 50, 0, 50)
        button.Position = data.pos
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        button.BorderSizePixel = 0
        button.Text = data.text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = controlFrame
        
        -- Esquinas redondeadas
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        directionalButtons[data.direction] = {button = button, pressed = false}
    end
    
    -- Mostrar/ocultar controles cuando se activa el vuelo
    local function updateControlsVisibility()
        controlFrame.Visible = flying
        if flying then
            flyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            flyButton.Text = "STOP"
        else
            flyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            flyButton.Text = "FLY"
        end
    end
    
    -- Conectar botón de vuelo
    flyButton.MouseButton1Click:Connect(function()
        flying = not flying
        if not flying then
            hitboxVelocity.Velocity = Vector3.zero
            JoltFunction:Fire(Vector3.zero)
            mobileDirection = Vector3.zero
        end
        updateControlsVisibility()
    end)
    
    -- Conectar botones direccionales
    for direction, data in pairs(directionalButtons) do
        local button = data.button
        
        -- Touch began
        button.MouseButton1Down:Connect(function()
            data.pressed = true
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end)
        
        -- Touch ended
        button.MouseButton1Up:Connect(function()
            data.pressed = false
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end)
        
        -- Touch leave
        button.MouseLeave:Connect(function()
            data.pressed = false
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end)
    end
end

-- Calcular dirección para móvil
local function calculateMobileDirection()
    if not flying then return Vector3.zero end
    
    local direction = Vector3.zero
    
    if directionalButtons.forward and directionalButtons.forward.pressed then
        direction += Camera.CFrame.LookVector
    end
    if directionalButtons.backward and directionalButtons.backward.pressed then
        direction -= Camera.CFrame.LookVector
    end
    if directionalButtons.left and directionalButtons.left.pressed then
        direction -= Camera.CFrame.RightVector
    end
    if directionalButtons.right and directionalButtons.right.pressed then
        direction += Camera.CFrame.RightVector
    end
    if directionalButtons.up and directionalButtons.up.pressed then
        direction += Camera.CFrame.UpVector
    end
    if directionalButtons.down and directionalButtons.down.pressed then
        direction -= Camera.CFrame.UpVector
    end
    
    return direction
end

-- Activar/desactivar vuelo
if not isMobile then
    -- Controles de PC (tecla F)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
            flying = not flying
            if not flying then
                hitboxVelocity.Velocity = Vector3.zero
                JoltFunction:Fire(Vector3.zero)
            end
        end
    end)
else
    -- Crear interfaz móvil
    createMobileUI()
end

-- Lógica del vuelo
RunService.RenderStepped:Connect(function()
    if flying then
        local direction = Vector3.zero
        
        if isMobile then
            -- Usar controles móviles
            direction = calculateMobileDirection()
        else
            -- Usar controles de PC
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                direction += Camera.CFrame.UpVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                direction -= Camera.CFrame.UpVector
            end
        end
        
        if direction.Magnitude > 0 then
            local velocity = direction.Unit * speed
            local cancelOut = hitboxVelocity.Velocity * -1
            JoltFunction:Fire(cancelOut)
            JoltFunction:Fire(velocity)
            hitboxVelocity.Velocity = velocity
        else
            hitboxVelocity.Velocity = Vector3.zero
            JoltFunction:Fire(Vector3.zero)
        end
    end
end)
