-- Bloxburg Pizza Auto Farm v3 (Safe Version - Mobile)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local PathfindingService = game:GetService("PathfindingService")

local AUTO_FARM = false
local stuckCounter = 0

-- === МЕНЮ ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Icon = Instance.new("ImageButton")
Icon.Size = UDim2.new(0, 70, 0, 70)
Icon.Position = UDim2.new(0, 20, 0, 20)
Icon.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
Icon.Image = "rbxassetid://3926305904"
Icon.Parent = ScreenGui
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1,0)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 180)
Frame.Position = UDim2.new(0.5, -125, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Visible = false
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "🍕 Pizza Farm v3 (Safe)"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9,0,0,60)
ToggleBtn.Position = UDim2.new(0.05,0,0.3,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleBtn.Text = "ВКЛ Auto Farm"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,12)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,0,0)
CloseBtn.TextSize = 22
CloseBtn.Parent = Frame

Icon.MouseButton1Click:Connect(function() Frame.Visible = not Frame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)

ToggleBtn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    if AUTO_FARM then
        ToggleBtn.Text = "ВЫКЛ Auto Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    else
        ToggleBtn.Text = "ВКЛ Auto Farm"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)

-- === БЕЗОПАСНЫЕ ФУНКЦИИ ===
local function findMopedSeat()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Name:lower():find("moped") or v.Name:lower():find("delivery") then
            if (v.Position - root.Position).Magnitude < 200 then
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
        wait(1)
        root.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
        wait(0.6)
        humanoid.Sit = true
        return true
    end
    return false
end

local function getPizza()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("pizza") and obj:IsA("BasePart") and obj.Transparency < 0.9 then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < 50 then
                root.CFrame = obj.CFrame + Vector3.new(0, 4, 0)
                firetouchinterest(obj, root, 0)
                wait(0.4)
                firetouchinterest(obj, root, 1)
                return true
            end
        end
    end
    return false
end

local function findCustomerPos()
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name:lower():find("arrow") or v.Name:lower():find("customer") or v.Name:lower():find("target")) and v:IsA("BasePart") and v.Transparency < 1 then
            return v.Position + Vector3.new(0, 6, 0)
        end
    end
    return nil
end

local function moveTo(target)
    if not target then return end
    local dist = (root.Position - target).Magnitude
    if dist < 12 then return end

    -- Только pathfinding, без телепорта
    local path = PathfindingService:CreatePath({
        AgentRadius = 3.5,
        AgentHeight = 5,
        AgentCanJump = true,
        WaypointSpacing = 6
    })
    
    path:ComputeAsync(root.Position, target)
    
    if path.Status == Enum.PathStatus.Success then
        for _, wp in pairs(path:GetWaypoints()) do
            if not AUTO_FARM then break end
            humanoid:MoveTo(wp.Position)
            local reached = humanoid.MoveToFinished:Wait(3)
            if not reached then
                stuckCounter = stuckCounter + 1
                humanoid.Jump = true
                wait(0.8)
                if stuckCounter > 5 then
                    -- Возврат к мопеду если сильно застрял
                    local seat = findMopedSeat()
                    if seat then humanoid:MoveTo(seat.Position) end
                    stuckCounter = 0
                end
            end
        end
    end
end

-- Основной цикл
spawn(function()
    while wait(1.2) do
        if AUTO_FARM then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            root = character:WaitForChild("HumanoidRootPart")

            sitOnMoped()
            wait(0.8)

            if not getPizza() then
                wait(2)
            end

            local customerPos = findCustomerPos()
            if customerPos then
                moveTo(customerPos)
                wait(1.8)
            end
        end
    end
end)

print("🍕 v3 Safe версия загружена! Начни смену и включи в меню.")
