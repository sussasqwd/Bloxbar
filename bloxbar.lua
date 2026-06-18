-- Bloxburg Pizza Auto Farm v21 (Улучшенный NoClip + Полёт)
wait(2)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 120)
ToggleButton.Position = UDim2.new(0, 25, 1, -190)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 26
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

print("v21 Загружена! Нажми кнопку.")

-- === УЛУЧШЕННЫЙ NOCLIP ===
local function fullNoClip()
    local char = player.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Velocity = Vector3.new(0,0,0)
            part.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
    
    -- Отключаем физику мопеда
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("moped") or obj.Name:lower():find("vehicle") or obj.Name:lower():find("seat")) then
            obj.CanCollide = false
            obj.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                if (v.Position - player.Character.HumanoidRootPart.Position).Magnitude > 35 then
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
    local root = player.Character.HumanoidRootPart
    fullNoClip()
    
    while AUTO_FARM do
        local dist = (root.Position - targetPos).Magnitude
        if dist < 20 then break end
        
        root.CFrame = CFrame.new(root.Position, targetPos) * CFrame.new(0, 6, 0)
        root.Velocity = (targetPos - root.Position).Unit * 140
        root.AssemblyLinearVelocity = (targetPos - root.Position).Unit * 140
        wait(0.025)
    end
end

-- Главный цикл
spawn(function()
    while wait(0.5) do
        if AUTO_FARM then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")

            fullNoClip()

            -- Садимся на мопед
            if not hum.Sit then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                        root.CFrame = seat.CFrame * CFrame.new(0, 6, 0)
                        hum.Sit = true
                        wait(0.8)
                        break
                    end
                end
            end

            if hasPizza() then
                local customer = findCustomer()
                if customer then
                    flyTo(customer.Position + Vector3.new(0, 8, 0))
                    wait(0.5)
                    -- Сдача пиццы
                    for _, pizza in pairs(char:GetDescendants()) do
                        if pizza.Name:lower():find("pizza") then
                            firetouchinterest(pizza, customer, 0)
                            wait(0.3)
                            firetouchinterest(pizza, customer, 1)
                            break
                        end
                    end
                    wait(1.2)
                end
            else
                -- Берём пиццу
                for _, p in pairs(workspace:GetDescendants()) do
                    if p.Name:lower():find("pizza") and p.Transparency < 0.9 and (p.Position - root.Position).Magnitude < 80 then
                        flyTo(p.Position)
                        root.CFrame = p.CFrame + Vector3.new(0, 5, 0)
                        firetouchinterest(p, root, 0)
                        wait(0.3)
                        firetouchinterest(p, root, 1)
                        wait(0.8)
                        break
                    end
                end
            end
        end
    end
end)

print("🎉 v21 Готово. Попробуй включить.")
