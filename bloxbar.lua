-- Bloxburg Pizza Auto Farm v15 (Нормальная скорость + Поворот)
wait(2)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 95, 0, 95)
ToggleButton.Position = UDim2.new(0, 25, 1, -160)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 20
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", ToggleButton).Thickness = 4

local AUTO_FARM = false

ToggleButton.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        ToggleButton.Text = "🍕\nON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = "🍕\nOFF"
    end
end)

-- ==================== ЛОГИКА ====================
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
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3.5 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") then
                if (v.Position - player.Character.HumanoidRootPart.Position).Magnitude > 35 then
                    return v.Position + Vector3.new(0, 8, 0)
                end
            end
        end
    end
    return nil
end

local function gentleBoost()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local hum = char.Humanoid
    if hum.Sit then
        local root = char.HumanoidRootPart
        local dir = root.CFrame.LookVector
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = dir * 55 + Vector3.new(0, 15, 0)  -- слабее чем раньше
            end
        end
    end
end

-- Постоянный мягкий буст
spawn(function()
    while wait(0.2) do
        if AUTO_FARM then
            gentleBoost()
        end
    end
end)

local function moveToCustomer()
    local target = findCustomer()
    if not target then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 6,
        AgentCanJump = true,
        WaypointSpacing = 5
    })

    path:ComputeAsync(player.Character.HumanoidRootPart.Position, target)

    if path.Status == Enum.PathStatus.Success then
        for _, wp in pairs(path:GetWaypoints()) do
            if not AUTO_FARM then break end
            
            local root = player.Character.HumanoidRootPart
            -- Хороший поворот
            local direction = (wp.Position - root.Position).Unit
            root.CFrame = CFrame.lookAt(root.Position, root.Position + direction * 10)
            
            player.Character.Humanoid:MoveTo(wp.Position)
            gentleBoost()
            
            player.Character.Humanoid.MoveToFinished:Wait(1.3)
        end
    end
end

-- Главный цикл
spawn(function()
    while wait(0.9) do
        if AUTO_FARM then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")

            -- Садимся на мопед
            if not hum.Sit then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                        if (seat.Position - root.Position).Magnitude < 200 then
                            hum:MoveTo(seat.Position)
                            wait(1)
                            root.CFrame = seat.CFrame * CFrame.new(0,4,0)
                            hum.Sit = true
                            wait(0.7)
                            break
                        end
                    end
                end
            end

            if hasPizza() then
                moveToCustomer()
            else
                -- Берём пиццу
                for _, p in pairs(workspace:GetDescendants()) do
                    if p.Name:lower():find("pizza") and (p.Position - root.Position).Magnitude < 60 then
                        root.CFrame = p.CFrame + Vector3.new(0,4,0)
                        firetouchinterest(p, root, 0)
                        wait(0.25)
                        firetouchinterest(p, root, 1)
                        break
                    end
                end
            end
        end
    end
end)

print("🎉 v15 Загружен! Теперь должен нормально поворачивать и не летать как сумасшедший.")
