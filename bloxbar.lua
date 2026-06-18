-- Bloxburg Pizza Auto Farm v13 (Фикс направления к заказчику)
local player = game.Players.LocalPlayer
wait(2)

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")

local AUTO_FARM = false

print("🍕 v13 Загружается...")

-- === КНОПКА ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 90, 0, 90)
ToggleButton.Position = UDim2.new(0, 30, 1, -130)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 4
stroke.Color = Color3.new(1,1,1)
stroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 180, 20)
        ToggleButton.Text = "🍕\nON"
        print("✅ Auto Farm ВКЛ")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        ToggleButton.Text = "🍕\nOFF"
        print("⛔ Auto Farm ВЫКЛ")
    end
end)

-- === ЛОГИКА ===
local function hasPizza()
    for _, v in pairs(character:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
    return false
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3.5 then
            local n = v.Name:lower()
