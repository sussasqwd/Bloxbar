-- Bloxburg Pizza Auto Farm v10 (Фикс телепорта в пиццерию)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")

local AUTO_FARM = false

-- === МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Icon = Instance.new("ImageButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 20, 0, 20)
Icon.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
Icon.Image = "rbxassetid://3926305904"
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 210)
Frame.Position = UDim2.new(0.5, -140, 0.5, -105)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Visible = false
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Farm v10 (Исправлено)"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9,0,0,60)
ToggleBtn.Position = UDim2.new(0.05,0,0.3,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 190, 0)
ToggleBtn.Text = "ВКЛ Auto Farm"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 17
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,12)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,40,0,40)
CloseBtn.Position = UDim2.new(1,-45,0,5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,0,0)
CloseBtn.TextSize = 24
CloseBtn.Parent = Frame

Icon.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)

ToggleBtn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    ToggleBtn.Text = AUTO_FARM and "ВЫКЛ Auto Farm" or "ВКЛ Auto Farm"
    ToggleBtn.BackgroundColor3 = AUTO_FARM and Color3.fromRGB(190,0,0) or Color3.fromRGB(0,190,0)
end)

-- === ФУНКЦИИ ===
local function hasPizza()
    for _, obj in pairs(character:GetDescendants()) do
        if obj.Name:lower():find("pizza") then
            return true
        end
    end
    return false
end

local function isInPizzaPlanet(pos)
    -- Примерные координаты зоны пиццерии (можно подправить)
    return pos.Z > -950 and pos.X > -850 and pos.X < -700
end

local function findRealCustomerArrow()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 1 and v.Size.Y > 3 then -- типичная стрелка большая
            local name = v.Name:lower()
            if name:find("arrow") or name:find("target") or name:find("customer") then
                local pos = v.Position
                if not isInPizzaPlanet(pos) and (pos - root.Position).Magnitude > 30 then
                    return pos + Vector3.new(0, 8, 0)
                end
            end
        end
    end
    return nil
end

local function superBoost()
    if humanoid.Sit then
        local direction = root.CFrame.LookVector
        for _, part in pairs(character:GetDescendants())
