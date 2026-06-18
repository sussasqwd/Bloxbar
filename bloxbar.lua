-- [[ Bloxburg Teacher Auto-Farm Script ]] --
-- Инструкция: Запустите скрипт, находясь в классе 206 (Teacher) на втором этаже.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Флаг работы скрипта (поменяйте на false, чтобы остановить)
_G.AutoFarmTeacher = true

-- Функция для безопасного ожидания (имитация пинга и человеческой реакции)
local function humanDelay()
    task.wait(math.random(6, 12) / 10) -- Случайная пауза от 0.6 до 1.2 секунд
end

print("[Бот-Учитель]: Скрипт успешно активирован!")

-- Основной цикл автоматизации
task.spawn(function()
    while _G.AutoFarmTeacher do
        task.wait(0.5)
        
        -- Проверяем, существует ли персонаж игрока
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            
            -- Находим школьный класс в игре
            local schoolObjects = workspace:FindFirstChild("Environment") 
                and workspace.Environment:FindFirstChild("School")
            
            if schoolObjects then
                -- 1. Сбор и раздача пропусков, успокоение учеников
                for _, student in ipairs(schoolObjects:GetChildren()) do
                    if not _G.AutoFarmTeacher then break end
                    
                    -- Проверяем, хулиганит ли ученик (прыгает на парте)
                    if student:FindFirstChild("Disruptive") and student.Disruptive.Value == true then
                        -- Отправляем запрос серверу: "Утихомирить ученика"
                        ReplicatedStorage.Modules.JobService.Remote:FireServer("ScoldStudent", student)
                        print("[Бот-Учитель]: Ученик успокоен.")
                        humanDelay()
                    end
                    
                    -- Проверяем, просит ли ученик выйти в туалет
                    if student:FindFirstChild("NeedsPass") and student.NeedsPass.Value == true then
                        -- Отправляем запрос серверу: "Выдать пропуск"
                        ReplicatedStorage.Modules.JobService.Remote:FireServer("GiveRestroomPass", student)
                        print("[Бот-Учитель]: Пропуск в туалет выдан.")
                        humanDelay()
                    end
                end
                
                -- 2. Автоматическое решение головоломки на доске (Chalkboard Puzzle)
                local board = schoolObjects:FindFirstChild("Chalkboard")
                if board and board:FindFirstChild("ActivePuzzle") and board.ActivePuzzle.Value == true then
                    -- Имитируем правильный ответ в мини-игре с фигурами
                    local correctAnswer = board.ActivePuzzle:GetAttribute("CorrectAnswer") or 1
                    
                    ReplicatedStorage.Modules.JobService.Remote:FireServer("SolveBoardPuzzle", correctAnswer)
                    print("[Бот-Учитель]: Задача на доске решена!")
                    humanDelay()
                end
            end
            
        end
    end
    print("[Бот-Учитель]: Скрипт деактивирован.")
end)
