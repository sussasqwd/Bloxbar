-- Bloxburg Pizza Auto Farm v20 (Максимально надёжная кнопка)
wait(3)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PizzaFarmV20"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 120)
ToggleButton.Position = UDim2.new(0, 30, 1, -200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 28
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleButton).Thickness = 6

local AUTO_FARM = false

ToggleButton.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 200, 30)
        ToggleButton.Text = "🍕\nON"
        print("✅ Auto Farm ВКЛ")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
        ToggleButton.Text = "🍕\nOFF"
        print("⛔ Auto Farm ВЫКЛ")
    end
end)

print("🔴 Кнопка должна появиться внизу слева. Если не видно — перезапусти executor полностью.")

-- ==================== NoClip + Полёт ====================

local function enableNoClip()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                if (v.Position - (player.Character and player.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude > 40 then
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
    return false
end

local function flyTo(targetPos)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    enableNoClip()
    
    while AUTO_FARM do
        local dist = (root.Position - targetPos).Magnitude
        if dist < 18 then break end
        
        root.CFrame = CFrame.new(root.Position, targetPos) * CFrame.new(0, 7, 0)
        root.Velocity = (targetPos - root.Position).Unit * 150
        wait(0.03)
    end
end

-- Главный цикл
spawn(function()
    while wait(0.7) do
        if AUTO_FARM then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")

            enableNoClip()

            if not hum.Sit then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                        root.CFrame = seat.CFrame * CFrame.new(0, 6, 0)
                        hum.Sit = true
                        wait(1)
                        break
                    end
                end
            end

            if hasPizza() then
                local customer = findCustomer()
                if customer then
                    flyTo(customer.Position + Vector3.new(0,8,0))
                    wait(0.6)
                    -- Сдача
                    for _, pizza in pairs(char:GetDescendants()) do
                        if pizza.Name:lower():find("pizza") then
                            firetouchinterest(pizza, customer, 0)
                            wait(0.4)
                            firetouchinterest(pizza, customer, 1)
                            break
                        end
                    end
                    wait(1.5)
                end
            else
                -- За пиццей
                for _, p in pairs(workspace:GetDescendants()) do
                    if p.Name:lower():find("pizza") and p.Transparency < 0.9 then
                        flyTo(p.Position)
                        root.CFrame = p.CFrame + Vector3.new(0,5,0)
                        firetouchinterest(p, root, 0)
                        wait(0.3)
                        firetouchinterest(p, root, 1)
                        wait(1)
                        break
                    end
                end
            end
        end
    end
end)

print("🎉 v20 NoClip загружен! Нажми кнопку для запуска.")
