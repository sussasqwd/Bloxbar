-- Bloxburg Taxi Auto Farm v1 (Для Телефона)
wait(3)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 160, 0, 160)
btn.Position = UDim2.new(0.5, -80, 0.75, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
btn.Text = "🚕\nOFF"
btn.TextColor3 = Color3.new(1,1,1)
btn.TextSize = 36
btn.Font = Enum.Font.GothamBold
btn.Parent = ScreenGui

Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", btn).Thickness = 8

local AUTO_FARM = false

btn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        btn.Text = "🚕\nON"
        print("✅ Taxi Farm ВКЛ")
    else
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
        btn.Text = "🚕\nOFF"
        print("⛔ Taxi Farm ВЫКЛ")
    end
end)

print("🚕 Taxi скрипт загружен. Нажми большую синюю кнопку.")

local function fullNoClip(char)
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
                return v
            end
        end
    end
    return nil
end

local function flyTo(targetPos)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    fullNoClip(player.Character)
    
    for i = 1, 100 do
        if not AUTO_FARM then break end
        local dist = (root.Position - targetPos).Magnitude
        if dist < 25 then break end
        
        root.CFrame = CFrame.new(root.Position, targetPos) * CFrame.new(0, 6, 0)
        root.Velocity = (targetPos - root.Position).Unit * 130
        wait(0.03)
    end
end

spawn(function()
    while wait(0.6) do
        if not AUTO_FARM then continue end
        
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")

        fullNoClip(char)

        -- Садимся в такси
        if not hum.Sit then
            for _, seat in pairs(workspace:GetDescendants()) do
                if seat:IsA("VehicleSeat") and (seat.Name:lower():find("taxi") or seat.Name:lower():find("car")) then
                    root.CFrame = seat.CFrame * CFrame.new(0, 5, 0)
                    hum.Sit = true
                    wait(1)
                    break
                end
            end
        end

        local customer = findCustomer()
        if customer then
            print("→ Едем к клиенту")
            flyTo(customer.Position + Vector3.new(0,8,0))
            wait(1.5)
            
            -- Ждём пока клиент сядет
            wait(3)
            
            -- Ищем место назначения (вторая стрелка)
            local destination = findCustomer()
            if destination then
                print("→ Везём клиента")
                flyTo(destination.Position + Vector3.new(0,8,0))
                wait(2)
                print("✅ Заказ выполнен!")
            end
        end
    end
end)
