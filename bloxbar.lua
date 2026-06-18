-- Bloxburg Pizza Auto Farm v11 (Фикс меню + Стабильность)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")

local AUTO_FARM = false

print("🍕 v11 Загружается...")

-- === НАДЁЖНОЕ МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PizzaFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Иконка
local Icon = Instance.new("TextButton")
Icon.Size = UDim2.new(0, 80, 0, 80)
Icon.Position = UDim2.new(0, 30, 0, 30)
Icon.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
Icon.Text = "🍕"
Icon.TextSize = 40
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = Icon

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Color = Color3.new(1,1,1)
stroke.Parent = Icon

-- Главное меню
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 290, 0, 220)
Frame.Position = UDim2.new(0.5, -145, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Visible = false
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Auto Farm v11"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85,0,0,65)
ToggleBtn.Position = UDim2.new(0.075,0,0.35,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
ToggleBtn.Text = "ВКЛ Auto Farm"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 18
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,12)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,30)
Status.Position = UDim2.new(0,0,0.7,0)
Status.BackgroundTransparency = 1
Status.Text = "Статус: Выключен"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 16
Status.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.TextSize = 25
CloseBtn.Parent = Frame

-- Клик по иконке
Icon.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
    print("Меню открыто/закрыто")
end)

CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleBtn.Text = "ВЫКЛ Auto Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        Status.Text = "Статус: Работает"
    else
        ToggleBtn.Text = "ВКЛ Auto Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        Status.Text = "Статус: Выключен"
    end
    print("Auto Farm:", AUTO_FARM)
end)

print("✅ Меню должно появиться! Нажми на большую красную кнопку с 🍕")

-- === ОСНОВНАЯ ЛОГИКА (v10 улучшенная) ===
local function hasPizza()
    for _, v in pairs(character:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
    return false
end

local function findRealCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 4 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                if (v.Position - root.Position).Magnitude > 40 then
                    return v.Position + Vector3.new(0,8,0)
                end
            end
        end
    end
    return nil
end

local function superBoost()
    if humanoid.Sit then
        local dir = root.CFrame.LookVector
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity
