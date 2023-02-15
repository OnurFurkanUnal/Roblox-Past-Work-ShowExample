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
---------------------------------------------------------------------



-- Tool script to use it and subscribe-------------------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Model = Tool:WaitForChild("Model")
local SwordAnim = Tool:WaitForChild("SwordAttack")
local Debounce = false
local PlayerHit = {}
local Sword = Tool:WaitForChild("Model"):WaitForChild("Kilicucu")

-- When tool activated this function works
Tool.Activated:Connect(function()	
	if Debounce == false then
		Debounce = true
		
		local Humanoid = Tool.Parent:WaitForChild("Humanoid")
		local AnimTrack = Humanoid:LoadAnimation(SwordAnim)
		
		AnimTrack:Play()
		wait(1)
		Debounce = false
	end
end)

-- When tool's part touched to any object this code will work
Sword.Touched:Connect(function(hit)
    -- if touched object is not tool owner and if it is a character it will work
	if hit.Parent:FindFirstChild("Humanoid") and hit.Parent ~= Tool.Parent then
	    -- Debounce checking is tool active or deactive
		if Debounce == true and PlayerHit[hit.Parent] == nil then
		    hit.Parent:FindFirstChild("Humanoid"):TakeDamage(25)
			PlayerHit[hit.Parent] = true
			wait(1)
			PlayerHit[hit.Parent] = nil
			-- if character die this code will destroy it
			if hit.Parent:FindFirstChild("Humanoid").died == true  then
				hit.Parent:FindFirstChild("Humanoid"):Kill()
			end
		end
	end
end)
local dum = game.Workspace.Dummy:WaitForChild("Humanoid")
dum.Died:Connect(function()
	-- Do stuff when dummy is die. When dummy is die this code will work
end)
----------------------------------------------------------------------


-- AddAccessory script to add accessory for character at the begining-
local char = script.Parent
local hum = char:WaitForChild("Humanoid")
local replicatedStorage = game:GetService("ReplicatedStorage")
local hat = replicatedStorage:WaitForChild("Accessory")
local cloneHat = hat:Clone()
cloneHat.Parent = game.Workspace
hum:AddAccessory(cloneHat)
-----------------------------------------------------------------------


-- Get user input script to detect user pressed keys and delete parts--
local replicatedStorage = game:GetService("ReplicatedStorage")
local testEvent = replicatedStorage:WaitForChild("TestEvent")
local UIS = game:GetService("UserInputService")
local part = game.Workspace:WaitForChild("Part")

-- if user press any key it will work
UIS.InputBegan:Connect(function(input)
	--if user preseed delete key it will work
	if input.KeyCode == Enum.KeyCode.Delete then
        -- Fire remoteevent for serverside to delete it
		testEvent:FireServer(part)
	end
	
end)
-----------------------------------------------------------------------




--Event controller script to destroy objects and inventory checking----
local replicatedStorage = game:GetService("ReplicatedStorage")
local testEvent = replicatedStorage:WaitForChild("TestEvent")
local plyr = game:GetService("Players")

-- if testevent fired it will work and remove object from server and from all users
testEvent.OnServerEvent:Connect(function(player,part)
	part:Destroy()
end)

-- to show LeaderBoard in a order
local dataStoreServices = game:GetService("DataStoreService")
local dataStore = dataStoreServices:GetOrderedDataStore("st")
local dataStore1 = dataStoreServices:GetOrderedDataStore("st1")

-- wait 3 seconds. Because server is working more faster than players so it is missing important data
wait(3)
-- Show leaderboard over game object
local success, errorMessage = pcall(function()
	local data = dataStore:GetSortedAsync(false,5)
	local winsPage = data:GetCurrentPage()

	for rank, data in ipairs(winsPage) do
		local name = data.key
		local Gold = data.value
		local successs, val = pcall(plyr.GetNameFromUserIdAsync, plyr, data.key)
		if successs == true then
			local b = dataStore1:GetAsync(data.key)
			local newLbFrame = game.ReplicatedStorage:WaitForChild("LeaderBoardFrame"):Clone()
			newLbFrame.Player.Text = val
			newLbFrame.Rank.Text = rank
			newLbFrame.Gold.Text = Gold
			newLbFrame.Frkn.Text = b
			newLbFrame.Position = UDim2.new(0,0,newLbFrame.Position.Y.Scale + (0.8 * #game.Workspace.GlobalLeaderBoard.LeaderBoardGUI.Holder:GetChildren()),0)
			newLbFrame.Parent = game.Workspace.GlobalLeaderBoard.LeaderBoardGUI.Holder
		end
	end
end)
-----------------------------------------------------------------------


--DataStore script to create and manipulate data-----------------------
local dataStoreServices = game:GetService("DataStoreService")
local dataStore = dataStoreServices:GetDataStore("Player")
local dt = dataStoreServices:GetOrderedDataStore("st")
local dt1 = dataStoreServices:GetOrderedDataStore("st1")
local loaded = {}

game.Players.PlayerAdded:Connect(function(player)
    --pcall is preventing any failure
	local success, value = pcall(dataStore.GetAsync,dataStore,player.UserId)
	if success == false then player:Kick("DataStore failed to load") return end
	--Create file for datastorage
	local data = value or {}
	local st = Instance.new("Folder")
	st.Name = "st"
	st.Parent = player
	
	local gold = Instance.new("IntValue")
	gold.Name = "Gold"
	gold.Value = 0
	gold.Parent = st
	
	local Frkn = Instance.new("IntValue")
	Frkn.Name = "Frkn"
	Frkn.Value = 0
	Frkn.Parent = st
    --load data
	print("Loaded:", value)
	for i, folder in game.ServerStorage.PlayerData:GetChildren() do
		local subData = data[folder.Name] or {}
		local clone = folder:Clone()
		for i , child in clone:GetChildren()do
			child.Value = subData[child.Name] or child.Value
			if clone.Name == "leaderstats" then
				if child.Name == "Gold" then
					gold.Value = child.Value
				end
				if child.Name == "Frkn" then
					Frkn.Value = child.Value
				end

			end
			
		end
		clone.Parent = player
	end
	local success, value = pcall(dt.SetAsync, dt, player.UserId,gold.Value)
	local success, value = pcall(dt1.SetAsync, dt1, player.UserId,Frkn.Value)
	loaded[player] = true
end)
-- Save data when player left
game.Players.PlayerRemoving:Connect(function(player)
	if loaded[player] == nil then return end
	local data = {}
	for i, folder in game.ServerStorage.PlayerData:GetChildren() do
		local subData = {}
		for i, child in player[folder.Name]:GetChildren() do
			subData[child.Name] = child.Value
			--bu 2 ıfıde ozel ordered datamızı cıkısda kaydetsın dıye koyduk
			if child.Name == "Gold" then
				local success, value = pcall(dt.SetAsync, dt, child.Value)
			end
			if child.Name == "Frkn" then
				local success, value = pcall(dt1.SetAsync, dt1, child.Value)
			end
		end
		data[folder.Name] = subData
		player[folder.Name]:Destroy()
	end
	local success, value = pcall(dataStore.SetAsync, dataStore, player.UserId,data)
	print("Saved:",data)
	loaded[player] = nil
end)

--that is very important, if server breaks it waits until the last player. So you can save your data without any lose
game:BindToClose(function()
	while next(loaded) ~= nil do
		task.wait()
	end
end)
-----------------------------------------------------------------------


--AddData script to players when they join game-----------------------
game.Players.PlayerAdded:Connect(function(player)
	local data2 = player:WaitForChild("Data2",10)
	if data2 == nil then return end
	data2.LoginCounter.Value += 1
	
	local data3 = player:WaitForChild("leaderstats",10)
	if data3 == nil then return end
	data3.Gold.Value += 1
	
	local data4 = player:WaitForChild("leaderstats",10)
	if data4 == nil then return end
	data4.Frkn.Value += 1
end)
-----------------------------------------------------------------------


--PickUpMenager script to pick up objects -----------------------------
local UIS = game:GetService("UserInputService")
local pickupKey = "F"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupItem = ReplicatedStorage:WaitForChild("PickupItem")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local PlayerGui = player:WaitForChild("PlayerGui")
local PickUpInfoGui = PlayerGui:WaitForChild("PickUpInfoGui")

--Check user mouse raycast
UIS.InputChanged:Connect(function(input)
	if mouse.Target then
		if mouse.Target:FindFirstChild("Pickable") then
			local item = mouse.Target
			PickUpInfoGui.Adornee = item
			PickUpInfoGui.ObjectName.Text = item.Name
			PlayerGui.PickUpInfoGui.Enabled = true
		else
			PickUpInfoGui.Adornee = nil
			PlayerGui.PickUpInfoGui.Enabled = false
		end
	end
	
end)

--Check user mouse raycast ended
UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode[pickupKey] then
		if mouse.Target then
			if mouse.Target:FindFirstChild("Pickable") then
				local item = mouse.Target
				if item then
					local distanceFromItem = player:DistanceFromCharacter(item.Position)
					if distanceFromItem < 30 then
						--if the user meets the needs, fire event to get item 
						PickupItem:FireServer(item)
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------

