-- Bloxburg Pizza Auto Farm v23 (Упрощённая + Отладка)
wait(2)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 130, 0, 130)
ToggleButton.Position = UDim2.new(0, 20, 1, -220)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 28
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", ToggleButton).Thickness = 6

local AUTO_FARM = false

ToggleButton.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ToggleButton.Text = "🍕\nON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = "🍕\nOFF"
    end
end)

print("v23 Загружена")

local function fullNoClip()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function findPizza()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("pizza") and v:IsA("BasePart") and v.Transparency < 0.9 then
            return v
        end
    end
    return nil
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                return v
            end
        end
    end
    return nil
end

local function flyTo(targetPos)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    fullNoClip()
    
    for i = 1, 80 do   -- максимум 2.4 секунды полёта
        if not AUTO_FARM then break end
        local dist = (root.Position - targetPos).Magnitude
        if dist < 20 then break end
        
        root.CFrame = CFrame.new(root.Position, targetPos) * CFrame.new(0, 7, 0)
        root.Velocity = (targetPos - root.Position).Unit * 160
        wait(0.03)
    end
end

spawn(function()
    while wait(0.8) do
        if AUTO_FARM then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")

            fullNoClip()

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

            if not hasPizza() then
                print("Ищем пиццу...")
                local pizza = findPizza()
                if pizza then
                    flyTo(pizza.Position)
                    root.CFrame = pizza.CFrame + Vector3.new(0,5,0)
                    firetouchinterest(pizza, root, 0)
                    wait(0.4)
                    firetouchinterest(pizza, root, 1)
                    print("Пицца взята")
                end
            else
                print("Ищем заказчика...")
                local customer = findCustomer()
                if customer then
                    flyTo(customer.Position + Vector3.new(0,8,0))
                    wait(0.6)
                    for _, pizza in pairs(char:GetDescendants()) do
                        if pizza.Name:lower():find("pizza") then
                            firetouchinterest(pizza, customer, 0)
                            wait(0.4)
                            firetouchinterest(pizza, customer, 1)
                            print("Пицца сдана!")
                            break
                        end
                    end
                    wait(1.5)
                end
            end
        end
    end
end)

local function hasPizza()
    local char = player.Character
    if not char then return false end
    for _, v in pairs(char:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
    return false
end
