local replicatedStorage = game:GetService("ReplicatedStorage")
local testEvent = replicatedStorage:WaitForChild("TestEvent")
local UIS = game:GetService("UserInputService")
local part = game.Workspace:WaitForChild("Part")
local plyr = game:GetService("Players")
local dataStoreServices = game:GetService("DataStoreService")
local dataStore = dataStoreServices:GetOrderedDataStore("st")
local dataStore1 = dataStoreServices:GetOrderedDataStore("st1")
local dt = dataStoreServices:GetOrderedDataStore("st")
local dt1 = dataStoreServices:GetOrderedDataStore("st1")
local loaded = {}
local pickupKey = "F"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PickupItem = ReplicatedStorage:WaitForChild("PickupItem")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local PlayerGui = player:WaitForChild("PlayerGui")
local PickUpInfoGui = PlayerGui:WaitForChild("PickUpInfoGui")
local ServerStorage = game:GetService("ServerStorage")
local InventoryTemplate = ServerStorage:WaitForChild("InventoryTemplate")

UIS.InputBegan:Connect(function(input)
	--if user preseed delete key it will work
	if input.KeyCode == Enum.KeyCode.Delete then
        -- Fire remoteevent for serverside to delete it
		testEvent:FireServer(part)
	end
	
end)

testEvent.OnServerEvent:Connect(function(player,part)
	part:Destroy()
end)

wait(3)
--to show leaderboard on part
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

--Save data when player left game
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

game:BindToClose(function()
	while next(loaded) ~= nil do
		task.wait()
	end
end)

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

local function SetupInventory(player)
	local Inventory = player:WaitForChild("Inventory")
	local PlayerGui = player:WaitForChild("PlayerGui")
	local MainGui = PlayerGui:WaitForChild("MainGui")
	local InventoryGui = MainGui:WaitForChild("InventoryGui")
	
	for i,item in pairs(Inventory:GetChildren()) do
		local itemGui = InventoryGui.Templates.Item:Clone()
		itemGui.Name = item.Name
		itemGui.ItemName.Text = item.Name
		itemGui.ItemQuantity.Text = item.Value
		
		if item.Value > 0 then
			itemGui.Visible = true
			itemGui.Parent = InventoryGui.ItemList
		else
			itemGui.Visible = false
			itemGui.Parent = InventoryGui.ItemList
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	--create data on player
	local GameData = InventoryTemplate:Clone()
	GameData.Name = "Inventory"
	GameData.Parent = player
	
	SetupInventory(player)
end)
