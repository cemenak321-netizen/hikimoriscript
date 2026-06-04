-- =====================================================================
-- FILE: menu.lua (Simpan seluruh kode ini di GitHub kamu)
-- =====================================================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local TweenService = game:GetService("TweenService")
local LocalPlayer = game.Players.LocalPlayer

-- 1. MEMBUAT WINDOW UTAMA YTTAxHIKIMORI
local JendelaUtama = OrionLib:MakeWindow({
    Name = "💜 YTTAxHIKIMORI Premium Hub 💛", 
    HidePremium = true, 
    SaveConfig = false,
    IntroText = "YTTAxHIKIMORI LOADING..."
})

-- =====================================================================
-- ANIMASI RUNNING EFFECT (UNGU <-> EMAS GLOWING)
-- =====================================================================
task.spawn(function()
    while task.wait(0.1) do
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if gui:FindFirstChild("Orion") or gui.Name == "Orion" then
                local MainFrame = gui:FindFirstChild("Main")
                if MainFrame then
                    local t = tick() * 2
                    local r = math.sin(t) * 0.5 + 0.5
                    
                    local Ungu = Color3.fromRGB(138, 43, 226)
                    local Emas = Color3.fromRGB(255, 215, 0)
                    local WarnaRunning = Ungu:Lerp(Emas, r)
                    
                    if MainFrame:FindFirstChild("Topbar") then
                        MainFrame.Topbar.BackgroundColor3 = WarnaRunning
                    end
                    if MainFrame:FindFirstChild("Navigation") then
                        MainFrame.Navigation.BackgroundColor3 = WarnaRunning:Darken(0.3)
                    end
                end
            end
        end
    end
end)

-- =====================================================================
-- TAB 1: MODUL SCRIPT REWIND & TIMELINE (FLASHBACK PRO)
-- =====================================================================
local TabFlashback = JendelaUtama:MakeTab({Name = "Flashback Pro", Icon = "rbxassetid://4483345998"})

TabFlashback:AddButton({
    Name = "⚡ Load Flashback GUI & System",
    Callback = function()
        OrionLib:MakeNotification({Name = "YTTAxHIKIMORI", Content = "Mengaktifkan Flashback Adaptation Pro...", Time = 3})
        
        local flashbacklength = 300
        local flashbackspeed = 600
        local name = game:GetService("RbxAnalyticsService"):GetSessionId()
        local frames, LP, RS = {}, game:GetService("Players").LocalPlayer, game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local SoundService = game:GetService("SoundService")

        local IMAGE_ID = "rbxassetid://106402256086666"
        local SFX_URL = "https://github.com/AlrecTofficial67/ItsAlrecT67/raw/refs/heads/main/VID-20260119-WA0242.mp3"
        local ROTATE_DURATION = 0.7 

        local getAsset = getcustomasset or getsynasset
        local fileName = SFX_URL:match("([^/]+)$")

        if getAsset then
            if not pcall(function() readfile(fileName) end) then
                local ok, data = pcall(function() return game:HttpGet(SFX_URL) end)
                if ok and data then writefile(fileName, data) end
            end
        end

        pcall(RS.UnbindFromRenderStep, RS, name)

        local function getchar()
           return LP.Character or LP.CharacterAdded:Wait()
        end

        local function gethrp(c)
            return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")
        end

        local flashback = {lastinput=false, canrevert=true, active=false}

        local function PlayCleanAdaptationEffect()
            local guiEffect = Instance.new("ScreenGui")
            guiEffect.Name = "AdaptationCleanFX"
            guiEffect.IgnoreGuiInset = true
            guiEffect.Parent = game.CoreGui

            local img = Instance.new("ImageLabel")
            img.Parent = guiEffect
            img.Size = UDim2.fromOffset(180, 180)
            img.Position = UDim2.fromScale(0.5, 0.5)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.BackgroundTransparency = 1
            img.Image = IMAGE_ID
            img.ImageTransparency = 1
            img.Rotation = 0

            local sound = Instance.new("Sound")
            sound.SoundId = getAsset and getAsset(fileName) or SFX_URL
            sound.Volume = 1
            sound.Parent = SoundService
            
            if not sound.IsLoaded then sound.Loaded:Wait() end
            
            sound:Play()
            img.ImageTransparency = 0

            local rotateTween = TweenService:Create(img, TweenInfo.new(ROTATE_DURATION, Enum.EasingStyle.Linear), {Rotation = 360})
            local fadeImg = TweenService:Create(img, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, ROTATE_DURATION), {ImageTransparency = 1})

            rotateTween:Play()
            fadeImg:Play()
            
            task.spawn(function()
                sound.Ended:Wait() 
                sound:Destroy()
                guiEffect:Destroy()
            end)
        end

        local function GetActiveAnimations(hum)
            local activeAnims = {}
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    table.insert(activeAnims, {Track = track, Time = track.TimePosition, AnimId = track.Animation.AnimationId})
                end
            end
            return activeAnims
        end

        function flashback:Advance(char, hrp, hum, allowinput)
           if #frames > flashbacklength * 60 then table.remove(frames, 1) end
           if allowinput and not self.canrevert then self.canrevert = true end
           
           if self.lastinput then
               hrp.Anchored = false
               hum.PlatformStand = false
               self.lastinput = false
           end

           table.insert(frames, {
               hrp.CFrame,
               hrp.AssemblyLinearVelocity,
               hrp.AssemblyAngularVelocity,
               hum:GetState(),
               hum.PlatformStand,
               GetActiveAnimations(hum)
           })
        end

        function flashback:Revert(char, hrp, hum)
           if #frames <= 1 or not self.canrevert then
               self.active = false
               return
           end

           for i=1, flashbackspeed do
               if #frames > 1 then table.remove(frames, #frames) end
           end

           local lastframe = frames[#frames]
           table.remove(frames, #frames)
           self.lastinput = true
           
           hrp.CFrame = lastframe[1]
           hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
           hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
           
           hum:ChangeState(lastframe[4] == Enum.HumanoidStateType.Dead and Enum.HumanoidStateType.Running or lastframe[4])
           hum.PlatformStand = true

           local animData = lastframe[6]
           if animData then
               for _, data in pairs(animData) do
                   if data.Track and data.Track.IsPlaying then
                       data.Track.TimePosition = data.Time
                       data.Track:AdjustSpeed(0)
                   end
               end
           end
        end

        local function step()
           local char = getchar()
           local hrp = gethrp(char)
           local hum = char:FindFirstChildWhichIsA("Humanoid")
           if not hrp or not hum then return end

           if hum.Health <= 0 then return end

           if flashback.active then
               flashback:Revert(char, hrp, hum)
           else
               flashback:Advance(char, hrp, hum, true)
           end
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FlashbackGui"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = LP:WaitForChild("PlayerGui")

        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 180, 0, 60)
        mainFrame.Position = UDim2.new(0.5, -90, 0.85, 0)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mainFrame.BorderSizePixel = 0
        mainFrame.Active = true
        mainFrame.Draggable = true 
        mainFrame.Parent = screenGui
        Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
        
        local hiasan = Instance.new("Frame")
        hiasan.Size = UDim2.new(1, 0, 0, 3)
        hiasan.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        hiasan.BorderSizePixel = 0
        hiasan.Parent = mainFrame

        local textButtonFlashback = Instance.new("TextButton")
        textButtonFlashback.Text = "ADAPTATION"
        textButtonFlashback.Size = UDim2.new(0, 80, 0, 35)
        textButtonFlashback.Position = UDim2.new(0, 7, 0.5, -15)
        textButtonFlashback.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        textButtonFlashback.TextColor3 = Color3.fromRGB(255, 255, 255)
        textButtonFlashback.Font = Enum.Font.SourceSansBold
        textButtonFlashback.TextSize = 12
        textButtonFlashback.Parent = mainFrame
        Instance.new("UICorner", textButtonFlashback).CornerRadius = UDim.new(0, 6)

        local textButtonReset = Instance.new("TextButton")
        textButtonReset.Text = "RESET"
        textButtonReset.Size = UDim2.new(0, 80, 0, 35)
        textButtonReset.Position = UDim2.new(1, -87, 0.5, -15)
        textButtonReset.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        textButtonReset.TextColor3 = Color3.fromRGB(255, 255, 255)
        textButtonReset.Font = Enum.Font.SourceSansBold
        textButtonReset.TextSize = 12
        textButtonReset.Parent = mainFrame
        Instance.new("UICorner", textButtonReset).CornerRadius = UDim.new(0, 6)

        local dragging, dragStart, startPos
        mainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        textButtonFlashback.MouseButton1Click:Connect(function()
            flashback.active = not flashback.active
            local char = getchar()
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            local hrp = gethrp(char)

            if flashback.active then
                textButtonFlashback.Text = "STOP"
                textButtonFlashback.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                task.spawn(PlayCleanAdaptationEffect)
            else
                textButtonFlashback.Text = "ADAPTATION"
                textButtonFlashback.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                
                if hum then
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                            track:Stop(0.1)
                        end
                    end
                    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                if hrp then hrp.Anchored = false end
            end
        end)

        textButtonReset.MouseButton1Click:Connect(function()
            frames = {}
            flashback.active = false
            textButtonFlashback.Text = "ADAPTATION"
            textButtonFlashback.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)

        RS:BindToRenderStep(name, 1, step)
    end
})

-- =====================================================================
-- TAB 2: EKSTERNAL EXPLOITS MENU (JSY & CLON SCRIPT)
-- =====================================================================
local TabEksternal = JendelaUtama:MakeTab({Name = "External Mod", Icon = "rbxassetid://4483345998"})

TabEksternal:AddButton({
    Name = "🔥 Load JSY Menu V2",
    Callback = function()
        OrionLib:MakeNotification({Name = "YTTAxHIKIMORI", Content = "Menjalankan JSY Menu V2...", Time = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jsymenu/JSY/refs/heads/main/guiv2.txt"))()
    end
})

TabEksternal:AddButton({
    Name = "👥 Load Clon Script (Creaciones)",
    Callback = function()
        OrionLib:MakeNotification({Name = "YTTAxHIKIMORI", Content = "Menjalankan Clon Script...", Time = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/creator-26/-creaciones/refs/heads/main/clon.lua"))()
    end
})

-- =====================================================================
-- TAB 3: OPIXX LUA & RADAR HIKIMORI
-- =====================================================================
local TabTambahan = JendelaUtama:MakeTab({Name = "More Scripts", Icon = "rbxassetid://4483345998"})

TabTambahan:AddButton({
    Name = "🌐 Load Roblox Bikin Roblox (Opixx)",
    Callback = function()
        OrionLib:MakeNotification({Name = "YTTAxHIKIMORI", Content = "Menjalankan Opixx Lua...", Time = 3})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/OpixxLua/Opixx.my.id./main/ROBLOXBIKINGOBLOX.lua.txt"))()
    end
})

TabTambahan:AddButton({
    Name = "👁️ Aktifkan Radar 1 Teman Anonim",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local PlaceId = game.PlaceId
        local JobId = game.JobId
        OrionLib:MakeNotification({Name = "YTTAxHIKIMORI", Content = "Radar Aktif! Tekan /console di chat.", Time = 4})
        
        task.spawn(function()
            local apiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=100"
            local successApi, response = pcall(function() return game:HttpGet(apiUrl) end)
            if successApi and response then
                local serverData = HttpService:JSONDecode(response)
                if serverData and serverData.data then
                    for _, server in ipairs(serverData.data) do
                        if server.id ~= JobId and server.hasFriends == true then
                            print("🚨 [YTTAxHIKIMORI RADAR] Teman terdeteksi di server: " .. server.id)
                        end
                    end
                end
            end
        end)
    end
})

local TabInfo = JendelaUtama:MakeTab({Name = "License", Icon = "rbxassetid://4483345998"})
TabInfo:AddLabel("Script Name: YTTAxHIKIMORI")
TabInfo:AddLabel("Theme: Running Purple-Gold Neon")

OrionLib:Init()
