-- Bloxburg Pizza Auto Farm v28 (Финальная для телефона)
wait(3)
local player = game.Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 170, 0, 170)
btn.Position = UDim2.new(0.5, -85, 0.75, 0)
btn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
btn.Text = "🍕\nOFF"
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
        btn.Text = "🍕\nON"
    else
        btn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
        btn.Text = "🍕\nOFF"
    end
end)

-- Основная функция
local function fullNoClip(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

spawn(function()
    while wait(0.5) do
        if not AUTO_FARM then continue end
        
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum then continue end

        fullNoClip(char)

        -- Садимся на мопед
        if not hum.Sit then
            for _, seat in pairs(workspace:GetDescendants()) do
                if seat:IsA("VehicleSeat") and seat.Name:lower():find("moped") then
                    root.CFrame = seat.CFrame * CFrame.new(0,6,0)
                    hum.Sit = true
                    wait(1)
                    break
                end
            end
        end

        -- Логика доставки
        local hasPizza = false
        for _, v in pairs(char:GetDescendants()) do
            if v.Name:lower():find("pizza") then hasPizza = true break end
        end

        if not hasPizza then
            -- Берём пиццу
            for _, p in pairs(workspace:GetDescendants()) do
                if p.Name:lower():find("pizza") and p.Transparency < 0.9 then
                    root.CFrame = p.CFrame + Vector3.new(0,5,0)
                    firetouchinterest(p, root, 0)
                    wait(0.3)
                    firetouchinterest(p, root, 1)
                    break
                end
            end
        else
            -- Летим к заказчику
            for _, c in pairs(workspace:GetDescendants()) do
                if c:IsA("BasePart") and c.Transparency < 0.9 and c.Size.Y > 3 then
                    local n = c.Name:lower()
                    if n:find("arrow") or n:find("target") then
                        root.CFrame = CFrame.new(root.Position, c.Position) * CFrame.new(0,7,0)
                        root.Velocity = (c.Position - root.Position).Unit * 140
                        wait(0.8)
                        
                        -- Сдаём пиццу
                        for _, pizza in pairs(char:GetDescendants()) do
                            if pizza.Name:lower():find("pizza") then
                                firetouchinterest(pizza, c, 0)
                                wait(0.4)
                                firetouchinterest(pizza, c, 1)
                                break
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end)

print("v28 загружена. Нажми большую кнопку.")
