-- Bloxburg Pizza Auto Farm v12 (Простая кнопка)
local player = game.Players.LocalPlayer
wait(2)

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")

local AUTO_FARM = false

print("🍕 v12 Загружается...")

-- === ОЧЕНЬ ПРОСТАЯ КНОПКА ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 90, 0, 90)
ToggleButton.Position = UDim2.new(0, 30, 1, -130)  -- внизу слева
ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
ToggleButton.Text = "🍕\nOFF"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = ToggleButton

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

print("✅ Большая красная кнопка должна быть внизу слева!")

-- === ЛОГИКА ===
local function hasPizza()
    for _, v in pairs(character:GetDescendants()) do
        if v.Name:lower():find("pizza") then return true end
    end
    return false
end

local function findCustomer()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency < 0.8 and v.Size.Y > 3 then
            local n = v.Name:lower()
            if n:find("arrow") or n:find("target") or n:find("customer") then
                if (v.Position - root.Position).Magnitude > 35 then
                    return v.Position + Vector3.new(0, 8, 0)
                end
            end
        end
    end
    return nil
end

local function boost()
    if humanoid.Sit then
        local dir = root.CFrame.LookVector
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = dir * 90 + Vector3.new(0, 25, 0)
            end
        end
    end
end

-- Постоянный буст
spawn(function()
    while wait(0.15) do
        if AUTO_FARM and humanoid.Sit then
            boost()
        end
    end
end)

-- Главный цикл
spawn(function()
    while wait(0.9) do
        if AUTO_FARM then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            root = character:WaitForChild("HumanoidRootPart")

            -- Садимся на мопед
            if not humanoid.Sit then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                        if (seat.Position - root.Position).Magnitude < 250 then
                            humanoid:MoveTo(seat.Position)
                            wait(1)
                            root.CFrame = seat.CFrame * CFrame.new(0,4,0)
                            humanoid.Sit = true
                            wait(0.7)
                            break
                        end
                    end
                end
            end

            if hasPizza() then
                local pos = findCustomer()
                if pos then
                    local path = PathfindingService:CreatePath({AgentRadius = 4, AgentHeight = 6})
                    path:ComputeAsync(root.Position, pos)
                    if path.Status == Enum.PathStatus.Success then
                        for _, wp in pairs(path:GetWaypoints()) do
                            if not AUTO_FARM then break end
                            humanoid:MoveTo(wp.Position)
                            boost()
                            humanoid.MoveToFinished:Wait(1.5)
                        end
                    end
                end
            else
                -- Берём пиццу
                for _, p in pairs(workspace:GetDescendants()) do
                    if p.Name:lower():find("pizza") and (p.Position - root.Position).Magnitude < 55 then
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

print("🎉 Скрипт загружен! Ищи большую кнопку с 🍕 внизу экрана.")
