-- Bloxburg Pizza Auto Delivery (Mobile Friendly)
-- Запускай после того, как взял работу Delivery Person

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AUTO_FARM = false

-- === ПРОСТОЕ МЕНЮ ДЛЯ ТЕЛЕФОНА ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Иконка (маленькая кнопка)
local Icon = Instance.new("ImageButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 20, 0, 20)
Icon.BackgroundTransparency = 0.3
Icon.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
Icon.Image = "rbxassetid://3926305904" -- иконка пиццы (можно поменять)
Icon.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = Icon

-- Главное меню
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0.5, -110, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Auto Farm"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleBtn.Text = "ВКЛ Auto Farm"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = ToggleBtn

-- Закрыть меню
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,0,0)
CloseBtn.TextSize = 20
CloseBtn.Parent = Frame

-- Логика открытия/закрытия
Icon.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

ToggleBtn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleBtn.Text = "ВЫКЛ Auto Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    else
        ToggleBtn.Text = "ВКЛ Auto Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)

-- === ОСНОВНАЯ ЛОГИКА ===
local function findMoped()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("moped") or v.Name:lower():find("delivery") or v.Name == "VehicleSeat" then
            if v:IsA("VehicleSeat") and (v.Position - root.Position).Magnitude < 100 then
                return v
            end
        end
    end
    return nil
end

local function sitOnMoped()
    local seat = findMoped()
    if seat then
        humanoid:MoveTo(seat.Position)
        wait(1)
        humanoid.Sit = true
        wait(0.5)
        if seat.Occupant == nil then
            root.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
        end
        print("✅ Сел на мопед")
        return true
    end
    return false
end

local function getPizza()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("pizza") and obj:IsA("BasePart") and (obj.Position - root.Position).Magnitude < 40 then
            firetouchinterest(obj, root, 0)
            wait(0.2)
            firetouchinterest(obj, root, 1)
            return true
        end
    end
    return false
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("arrow") or v.Name:lower():find("customer") then
            if v:IsA("BasePart") then
                return v.Position
            end
        end
    end
    return nil
end

local function moveTo(pos)
    if not pos then return end
    humanoid:MoveTo(pos)
    humanoid.MoveToFinished:Wait(4)
end

spawn(function()
    while true do
        if AUTO_FARM then
            if not character:FindFirstChild("Humanoid") then
                character = player.Character or player.CharacterAdded:Wait()
                humanoid = character:WaitForChild("Humanoid")
                root = character:WaitForChild("HumanoidRootPart")
            end

            sitOnMoped()
            wait(1)
            getPizza()
            wait(1)

            local customerPos = findCustomer()
            if customerPos then
                moveTo(customerPos)
                wait(2)
            else
                wait(3)
            end
        end
        wait(1)
    end
end)

print("🍕 Pizza Auto Farm загружен! Нажми на иконку пиццы.")
