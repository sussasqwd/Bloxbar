-- Bloxburg Pizza Auto Farm v7 (Очень Быстрый)
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
Icon.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Icon.Image = "rbxassetid://3926305904"
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 270, 0, 200)
Frame.Position = UDim2.new(0.5, -135, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Visible = false
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Farm v7 (Очень быстрый)"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9,0,0,60)
ToggleBtn.Position = UDim2.new(0.05,0,0.32,0)
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

-- === СИЛЬНОЕ УСКОРЕНИЕ МОПЕДА ===
local function superBoostMoped()
    if humanoid.Sit then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Velocity then
                local vel = part.Velocity
                part.Velocity = vel * 4.5   -- очень сильный буст
            end
        end
        
        -- Дополнительный импульс в направлении движения
        local seat = character:FindFirstChildWhichIsA("VehicleSeat")
        if seat and seat.Occupant then
            local direction = root.CFrame.LookVector
            root.AssemblyLinearVelocity = direction * 120  -- мощный толчок вперёд
        end
    end
end

local function isOnMoped()
    return humanoid.Sit and character:FindFirstChildWhichIsA("VehicleSeat") ~= nil
end

local function getPizza()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("pizza") and obj:IsA("BasePart") and obj.Transparency < 0.9 then
            if (obj.Position - root.Position).Magnitude < 70 then
                root.CFrame = obj.CFrame + Vector3.new(0, 4, 0)
                firetouchinterest(obj, root, 0)
                wait(0.2)
                firetouchinterest(obj, root, 1)
                return true
            end
        end
    end
    return false
end

local function findCustomerPos()
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("arrow") or v.Name:lower():find("customer") or v.Name:lower():find("target")) 
           and v:IsA("BasePart") and v.Transparency < 1 then
            return v.Position + Vector3.new(0, 7, 0)
        end
    end
    return nil
end

local function moveTo(target)
    if not target then return end
    local dist = (root.Position - target).Magnitude
    if dist < 18 then return end

    -- Телепорт только когда очень далеко
    if dist > 90 then
        root.CFrame = CFrame.new(target + Vector3.new(0, 6, 0))
        wait(0.35)
    else
        -- Нормальное движение + сильный буст
        local path = PathfindingService:CreatePath({
            AgentRadius = 3,
            AgentHeight = 5,
            AgentCanJump = true,
            WaypointSpacing = 8
        })
        path:ComputeAsync(root.Position, target)
        
        if path.Status == Enum.PathStatus.Success then
            for _, wp in pairs(path:GetWaypoints()) do
                if not AUTO_FARM then break end
                humanoid:MoveTo(wp.Position)
                humanoid.MoveToFinished:Wait(1.2)
                superBoostMoped()
            end
        end
    end
    superBoostMoped()
end

-- Главный цикл + постоянный буст
spawn(function()
    while wait(0.5) do
        if AUTO_FARM then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            root = character:WaitForChild("HumanoidRootPart")

            if not isOnMoped() then
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and (seat.Name:lower():find("moped") or seat.Name:lower():find("delivery")) then
                        if (seat.Position - root.Position).Magnitude < 300 then
                            root.CFrame = seat.CFrame * CFrame.new(0, 4, 0)
                            wait(0.4)
                            humanoid.Sit = true
                            break
                        end
                    end
                end
            end

            superBoostMoped()
            getPizza()
            wait(0.3)

            local customerPos = findCustomerPos()
            if customerPos then
                moveTo(customerPos)
                wait(0.8)
            end
        end
    end
end)

-- Постоянный буст каждые 0.2 секунды (очень важно!)
spawn(function()
    while wait(0.2) do
        if AUTO_FARM then
            superBoostMoped()
        end
    end
end)

print("🍕 v7 Очень быстрый загружен! Сядь на мопед с пиццей и включи.")
