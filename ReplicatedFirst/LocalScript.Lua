local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local loadingScreen = script:WaitForChild("loadingScreen"):Clone()
loadingScreen.Parent = playerGui

local frame = loadingScreen:WaitForChild("Frame")
local loadingText = frame:WaitForChild("TextLabel")
local bar = frame:WaitForChild("loadingBar"):WaitForChild("Bar")
local tipLabel = frame:WaitForChild("TipLabel")

local tips = {
	"Tip: The seed shop refreshes every 5 mins!",
	"Tip: Collect coins to buy new upgrades.",
	"Tip: Harvest fruit with mutations for more coins!",
	"Tip: Pets earn xp offline!",
	"Tip: Invite friends for bonus rewards!"
}

local assets = game:GetChildren()

-- Tip changing coroutine
local tipRunning = true
coroutine.wrap(function()
	while tipRunning do
		tipLabel.Text = tips[math.random(1, #tips)]
		task.wait(2) -- Change tip every 2 seconds (adjust as you like)
	end
end)()

for index, asset in pairs(assets) do
	ContentProvider:PreloadAsync({asset})
	bar.Size = UDim2.new(index/#assets,0,1,0)
	loadingText.Text = "Loading: " .. asset.Name .. " " .. math.floor(index/#assets * 100) .. "%"
end

tipRunning = false -- Stop tips changing

loadingText.Text = "Click anywhere to play!"
bar.Size = UDim2.new(1,0,1,0)

-- Start flashing the "Click anywhere to play!" text
local flashing = true
coroutine.wrap(function()
	while flashing do
		-- Fade out
		local tweenOut = TweenService:Create(
			loadingText,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextTransparency = 1}
		)
		tweenOut:Play()
		tweenOut.Completed:Wait()
		-- Fade in
		local tweenIn = TweenService:Create(
			loadingText,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextTransparency = 0}
		)
		tweenIn:Play()
		tweenIn.Completed:Wait()
	end
end)()

-- Fade out on click/tap
local inputConnection
inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		flashing = false -- Stop the flashing loop
		-- Fade out the Frame and its UI
		for _, v in ipairs(frame:GetDescendants()) do
			if v:IsA("TextLabel") or v:IsA("TextButton") then
				TweenService:Create(
					v,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{BackgroundTransparency = 1, TextTransparency = 1}
				):Play()
			elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
				TweenService:Create(
					v,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{BackgroundTransparency = 1, ImageTransparency = 1}
				):Play()
			elseif v:IsA("Frame") then
				TweenService:Create(
					v,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{BackgroundTransparency = 1}
				):Play()
			end
		end
		TweenService:Create(
			frame,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{BackgroundTransparency = 1}
		):Play()
		task.wait(0.5)
		loadingScreen:Destroy()
		if inputConnection then
			inputConnection:Disconnect()
		end
	end
end)
