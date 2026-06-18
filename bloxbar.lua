-- Bloxburg Pizza Auto Farm v2 (Mobile + Fix Stuck)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local AUTO_FARM = false

-- === МЕНЮ (то же самое, удобное для телефона) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Icon = Instance.new("ImageButton")
Icon.Size = UDim2.new(0, 65, 0, 65)
Icon.Position = UDim2.new(0, 15, 0, 15)
Icon.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
Icon.Image = "rbxassetid://3926305904"
Icon.Parent = ScreenGui

Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 200)
Frame.Position = UDim2.new(0.5, -120, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Visible = false
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Auto Farm v2"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.9,0,0,55)
Toggle.Position = UDim2.new(0.05,0,0.3,0)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
Toggle.Text = "ВКЛ Auto Farm"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextSize = 17
Toggle.Parent = Frame
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,12)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,35,0,35)
Close.Position = UDim2.new(1,-40,0,5)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.new(1,0,0)
Close.TextSize = 22
Close.Parent = Frame

Icon.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)
Close.MouseButton1Click:Connect(function() Frame.Visible = false end)

Toggle.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        Toggle.Text = "ВЫКЛ Auto Farm"
        Toggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    else
        Toggle.Text = "ВКЛ Auto Farm"
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end
end)

-- === УЛУЧШЕННЫЕ ФУНКЦИИ ===
local function findMopedSeat()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and (v.Name:lower():find("moped") or v.Name:lower():find("delivery")) then
            if (v.Position - root.Position).Magnitude < 150 then
                return v
            end
        end
    end
    return nil
end

local function sitOnMoped()
    local seat = findMopedSeat()
    if seat then
        humanoid:MoveTo(seat.Position)
        wait(1.2)
        root.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
        wait(0.5)
        humanoid.Sit = true
        print("✅ Сел на мопед")
        return true
    end
    return false
end

local function getPizza()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("pizza") and obj:IsA("BasePart") and obj.Transparency < 1 then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < 60 then
                root.CFrame = obj.CFrame + Vector3.new(0,4,0)
                firetouchinterest(obj, root, 0)
                wait(0.3)
                firetouchinterest(obj, root, 1)
                return true
            end
        end
    end
    return false
end

local function findCustomerPos()
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("arrow") or v.Name:lower():find("customer") or v.Name:lower():find("target")) and v:IsA("BasePart") then
            return v.Position + Vector3.new(0, 5, 0)
        end
    end
    return nil
end

local function moveTo(targetPos)
    if not targetPos then return false end
    
    local distance = (root.Position - targetPos).Magnitude
    if distance < 15 then return true end
    
    -- Простой телепорт на средние расстояния
    if distance < 80 then
        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        wait(0.4)
        return true
    end
    
    -- Pathfinding
    local path = PathfindingService:CreatePath({
        AgentRadius = 4,
        AgentHeight = 6,
        AgentCanJump = true,
        WaypointSpacing = 8,
        Costs = {Water = math.huge}
    })
    
    path:ComputeAsync(root.Position, targetPos)
    
    if path.Status == Enum.PathStatus.Success then
        for _, wp in pairs(path:GetWaypoints()) do
            if not AUTO_FARM then break end
            humanoid:MoveTo(wp.Position)
            if not humanoid.MoveToFinished:Wait(3) then
                -- Застрял — лёгкий прыжок
                humanoid.Jump = true
                wait(0.6)
            end
        end
        return true
    end
    return false
end

-- Основной цикл
spawn(function()
    while wait(1) do
        if AUTO_FARM and character and character:FindFirstChild("Humanoid") then
            sitOnMoped()
            wait(0.8)
            
            if not getPizza() then
                -- Возврат к Pizza Planet если нет пиццы
                root.CFrame = CFrame.new(-800, 30, -900) -- пример координат Pizza Planet (может меняться)
                wait(2)
            end
            
            local customerPos = findCustomerPos()
            if customerPos then
                moveTo(customerPos)
                wait(1.5)
                -- Попытка отдать пиццу
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("pizza") and (obj.Position - root.Position).Magnitude < 20 then
                        firetouchinterest(obj, root, 0) -- или к клиенту
                        break
                    end
                end
                wait(2)
            end
        end
    end
end)

print("🍕 v2 Загружен! Нажми на иконку пиццы и включи.")
