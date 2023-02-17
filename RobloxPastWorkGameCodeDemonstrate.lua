--Find Target and Fire script for weapon---------------------------------------
local replicatedStorage = game:GetService("ReplicatedStorage")
local bullet = replicatedStorage:WaitForChild("Bullet")
local turret = script.Parent
local fireRate = 0.5
local bulletDemage = 10
local bulletSpeed = 250
local aggroDist = 100
local tweenServices = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1)

-- Run this script every fireRate. You can use runServices if you dont want to use while loop
while wait(fireRate) do
	local target = nil
	for i,v in pairs(game.Workspace:GetChildren()) do
		local human = v:FindFirstChild("Humanoid")
		local torso = v:FindFirstChild("UpperTorso")
		if human and torso and human.Health > 0 then
			target = torso
		end
	end
	-- if target is true then rotate weapon
	if target then
		local tors = target
		local target ={
			CFrame = 	CFrame.new(turret.Position, tors.Position)
		} 
		local tween = tweenServices:Create(turret,tweenInfo,target)
		tween:Play()
	-- Generate bullet and give velocity, trail 
	local newBullet = bullet:Clone()
		newBullet.Position = turret.Position
		newBullet.Parent = game.Workspace
		-- Bullet Trail
		local Attachment = Instance.new("Attachment",newBullet)
		Attachment.Parent = newBullet
		Attachment.Position = turret.CFrame.LookVector * -1
		Attachment.Name = "Attachment1"
		local at = newBullet:WaitForChild("Trail")
		at.Attachment1 = Attachment
		--
		newBullet.Velocity = turret.CFrame.LookVector * bulletSpeed		
		newBullet.Touched:Connect(function(objectHit)
			newBullet:Destroy()
		end)
	end
end
