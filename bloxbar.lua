-- Bloxburg Pizza Auto Farm v19 (NoClip + Прямой Полёт)
wait(2)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 110, 0, 110)
ToggleButton.Position = UDim2.new(0, 20, 1, -180)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", ToggleButton).Thickness = 6

local AUTO_FARM = false
local NOCLIP_ENABLED = false

ToggleButton.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 190, 0)
        ToggleButton.Text = "🍕\nON"
        NOCLIP_ENABLED = true
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = "🍕\nOFF"
        NOCLIP_ENABLED = false
    end
end)

-- === NOCLIP (отключение коллизии) ===
local function enableNoClip()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    -- Отключаем коллизию у мопеда
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("moped") or obj.Name:lower():find("vehicle") then
            obj.CanCollide = false
        end
    end
end

-- === ОСНОВНЫЕ ФУНКЦИИ ===
local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                if (v.Position - player.Character.HumanoidRootPart.Position).Magnitude > 30 then
                    return v
                end
            end
        end
    end
    return nil
end

local function hasPizza()
    local char = player.Character
    if not char then return false end
    for _, v in pairs(char:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
