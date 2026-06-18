-- Bloxburg Pizza Auto Farm v17 (Сильный Поворот)
wait(2)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 100, 0, 100)
ToggleButton.Position = UDim2.new(0, 25, 1, -170)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", ToggleButton).Thickness = 5

local AUTO_FARM = false

ToggleButton.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 190, 0)
        ToggleButton.Text = "🍕\nON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = "🍕\nOFF"
    end
end)

local PathfindingService = game:GetService("PathfindingService")

local function hasPizza()
    local char = player.Character
    if not char then return false end
    for _, v in pairs(char:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
    return false
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                local dist = (v.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist > 45 and dist < 900 then
                    return v
                end
            end
        end
    end
    return nil
end

local function forceTurnTo(targetPos)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local direction = (targetPos - root.Position).Unit
    root.CFrame = CFrame.lookAt(root.Position, root.Position + direction)
end

local function gentleBoost()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or not char.Humanoid.Sit then return end
    local root = char.HumanoidRootPart
    local dir = root.CFrame.LookVector
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = dir * 58 + Vector3.new(0, 15, 0)
        end
    end
end

-- Постоянный буст + поворот
spawn(function()
    while wait(0.1) do
        if AUTO_FARM then
            gentleBoost()
            local customer = findCustomer()
            if customer then
                forceTurnTo(customer.Position)
            end
        end
    end
end)

local function moveToCustomer()
    local customer = findCustomer()
    if not customer then return end

    local targetPos = customer.Position + Vector3.new(0, 8, 0)
    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 6,
        WaypointSpacing = 6
    })

    path:ComputeAsync(player.Character.HumanoidRootPart.Position, targetPos)

    if path.Status == Enum.PathStatus.Success then
        for _, wp in pairs(path:GetWaypoints()) do
            if not AUTO_FARM then break end
            
            forceTurnTo(wp.Position)        -- сильный поворот
            player.Character.Humanoid:MoveTo(wp.Position)
            gentleBoost()
            
            wait(0.8)  -- чуть быстрее
        end
        
        -- Сдача пиццы
        wait(0.5)
        forceTurnTo(customer.Position)
        for _, pizza in pairs(player.Character:GetDescendants()) do
            if pizza.Name:lower():find("pizza") then
                firetouchinterest(pizza, customer, 0)
                wait(0.3)
                firetouchinterest(pizza, customer, 1)
                break
            end
        end
    end
end

-- Главный цикл
spawn(function()
    while wait(0.7) do
        if AUTO_FARM then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")

            if not hum.Sit then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                        hum:MoveTo(seat.Position)
                        wait(1)
                        root.CFrame = seat.CFrame * CFrame.new(0,4,0)
                        hum.Sit = true
                        wait(0.6)
                        break
                    end
                end
            end

            if hasPizza() then
                moveToCustomer()
            else
                -- Берём пиццу
                for _, p in pairs(workspace:GetDescendants()) do
                    if p.Name:lower():find("pizza") and (p.Position - root.Position).Magnitude < 70 then
                        root.CFrame = p.CFrame + Vector3.new(0,4,0)
                        firetouchinterest(p, root, 0)
                        wait(0.3)
                        firetouchinterest(p, root, 1)
                        break
                    end
                end
            end
        end
    end
end)

print("🎉 v17 Загружен! Сильный поворот активирован.")
