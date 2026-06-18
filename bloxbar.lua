-- Bloxburg Pizza Auto Farm v14 (Надёжная кнопка)
wait(3)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "PizzaFarmButton"
ToggleButton.Size = UDim2.new(0, 100, 0, 100)
ToggleButton.Position = UDim2.new(0, 25, 1, -160)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 20
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 5
stroke.Color = Color3.new(1,1,1)
stroke.Parent = ToggleButton

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

print("✅ Кнопка должна быть внизу слева! Если не видно — попробуй перезапустить executor")

-- ==================== ОСНОВНОЙ КОД ====================

local PathfindingService = game:GetService("PathfindingService")

local function hasPizza()
    for _, v in pairs(player.Character:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
    return false
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.9 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") then
                if (v.Position - player.Character.HumanoidRootPart.Position).Magnitude > 40 then
                    return v.Position + Vector3.new(0, 8, 0)
                end
            end
        end
    end
    return nil
end

local function boost()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local hum = char.Humanoid
    if hum.Sit then
        local root = char.HumanoidRootPart
        local dir = root.CFrame.LookVector
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = dir * 90 + Vector3.new(0, 25, 0)
            end
        end
    end
end

spawn(function()
    while wait(0.15) do
        if AUTO_FARM then
            boost()
        end
    end
end)

spawn(function()
    while wait(1) do
        if AUTO_FARM then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local root = char:WaitForChild("HumanoidRootPart")

            if not hum.Sit then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                        hum:MoveTo(seat.Position)
                        wait(1.2)
                        root.CFrame = seat.CFrame * CFrame.new(0,4,0)
                        hum.Sit = true
                        wait(0.8)
                        break
                    end
                end
            end

            if hasPizza() then
                local target = findCustomer()
                if target then
                    local path = PathfindingService:CreatePath({AgentRadius = 4, AgentHeight = 6})
                    path:ComputeAsync(root.Position, target)
                    if path.Status == Enum.PathStatus.Success then
                        for _, wp in pairs(path:GetWaypoints()) do
                            if not AUTO_FARM then break end
                            local dir = (wp.Position - root.Position).Unit
                            root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
                            hum:MoveTo(wp.Position)
                            boost()
                            hum.MoveToFinished:Wait(1.5)
                        end
                    end
                end
            else
                -- Берём пиццу
                for _, p in pairs(workspace:GetDescendants()) do
                    if p.Name:lower():find("pizza") and (p.Position - root.Position).Magnitude < 60 then
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

print("🎉 v14 Загружен! Ищи большую кнопку 🍕")
