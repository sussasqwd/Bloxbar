-- Bloxburg Pizza Auto Farm v4 (Быстрая версия)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local AUTO_FARM = false
local stuck = 0

-- === МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Icon = Instance.new("ImageButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 20, 0, 20)
Icon.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Icon.Image = "rbxassetid://3926305904"
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 190)
Frame.Position = UDim2.new(0.5, -130, 0.5, -95)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Visible = false
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Farm v4 (Быстрый)"
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

-- === СКОРОСТЬ МОПЕДА ===
local function boostMopedSpeed()
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant then
            local vehicle = v.Parent
            for _, part in pairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Velocity = part.Velocity * 2.2  -- сильно ускоряем
                end
            end
            return true
        end
    end
    return false
end

local function isOnMoped()
    return humanoid.Sit and character:FindFirstChildWhichIsA("VehicleSeat") ~= nil
end

local function getPizza()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("pizza") and obj:IsA("BasePart") and obj.Transparency < 0.9 then
            if (obj.Position - root.Position).Magnitude < 60 then
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
        if (v.Name:lower():find("arrow") or v.Name:lower():find("customer") or v.Name:lower():find("target")) 
           and v:IsA("BasePart") and v.Transparency < 1 then
            return v.Position + Vector3.new(0, 8, 0)
        end
    end
    return nil
end

local function moveTo(target)
    if not target then return end
    local dist = (root.Position - target).Magnitude
    if dist < 15 then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 3,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 5
    })

    path:ComputeAsync(root.Position, target)

    if path.Status == Enum.PathStatus.Success then
        for _, wp in pairs(path:GetWaypoints()) do
            if not AUTO_FARM then break end
            humanoid:MoveTo(wp.Position)
            if not humanoid.MoveToFinished:Wait(2.5) then
                stuck = stuck + 1
                humanoid.Jump = true
                wait(0.7)
                if stuck > 6 then
                    local seat = character:FindFirstChildWhichIsA("VehicleSeat")
                    if seat then seat.Parent:PivotTo(seat.CFrame + Vector3.new(0,5,0)) end
                    stuck = 0
                end
            end
            boostMopedSpeed() -- ускоряем каждый waypoint
        end
    end
end

-- Главный цикл
spawn(function()
    while wait(0.8) do
        if AUTO_FARM then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            root = character:WaitForChild("HumanoidRootPart")

            if not isOnMoped() then
                -- Пытаемся сесть на мопед
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and (seat.Name:lower():find("moped") or seat.Name:lower():find("delivery")) then
                        humanoid:MoveTo(seat.Position)
                        wait(1)
                        root.CFrame = seat.CFrame * CFrame.new(0,3,0)
                        humanoid.Sit = true
                        break
                    end
                end
            end

            wait(0.5)
            if not getPizza() and not isOnMoped() then
                wait(1)
            end

            boostMopedSpeed()

            local customerPos = findCustomerPos()
            if customerPos then
                moveTo(customerPos)
                wait(1.2)
            end
        end
    end
end)

print("🍕 v4 Быстрая версия загружена! Сядь на мопед, возьми пиццу и включи.")
