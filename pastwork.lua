--OUR ALL GUI MATERIALS IN StarterGui and ReplicatedStorage WITH ALL DETAILS
local replicatedStorage = game:GetService("ReplicatedStorage")
local testEvent = replicatedStorage:WaitForChild("TestEvent")
local plyr = game:GetService("Players")
local dataStoreServices = game:GetService("DataStoreService")
--That is important.
-- We are using dataStore, dataStore1 when we have dataStorePlyr you will ask why ?
--Answer is simple. We are storing custom value in  dataStorePlyr like frkn and gold and when user press tab scoretable showing but for here
--we need more spesific requirments. For example we are listing top 5 players in a gameobject. so we are using OrderedDataStore not
--regular DataStore. there are technical reasons for this usage. For example roblox understanting leaderstats folder and under this datastorage 
--architecture we are true but we want to show a few player on gameobject so we are using it.
local dataStore = dataStoreServices:GetOrderedDataStore("st")
local dataStore1 = dataStoreServices:GetOrderedDataStore("st1")
local dataStorePlyr = dataStoreServices:GetDataStore("Player")
local loaded = {}
local ServerStorage = game:GetService("ServerStorage")
local InventoryTemplate = ServerStorage:WaitForChild("InventoryTemplate")
local Items = replicatedStorage:WaitForChild("Items")
local TweenService = game:GetService("TweenService")
local PickupItem = replicatedStorage:WaitForChild("PickupItem")
local DropItem = replicatedStorage:WaitForChild("RemoteFunctionDropItem")
local pickupTweenInfo = TweenInfo.new(
	0.3,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.In,
	0,
	false,
	0
)
local UIS = game:GetService("UserInputService")
local pickupKey = "F"
local player = game.Players:GetPlayerFromCharacter(script.Parent)
local mouse = player:GetMouse()
local PlayerGui = player:WaitForChild("PlayerGui")
local PickUpInfoGui = PlayerGui:WaitForChild("PickUpInfoGui")
local Inventory = player.Inventory
local MainGui = script.Parent
local InventoryGui = MainGui.InventoryGui
local InventoryAcKapaButton = MainGui.TextButton
local part = game.Workspace:WaitForChild("Part")

wait(3)
-- Getting best 5 players in order and show them in gameobject
local success, errorMessage = pcall(function()
    -- we are getting first richest 5 players
	local data = dataStore:GetSortedAsync(false,5)
	local winsPage = data:GetCurrentPage()
	-- we are assigning their values to show step by step
	for rank, data in ipairs(winsPage) do
		local name = data.key
		local Gold = data.value
		--Checking. Is it a real player ? if yes continue
		local successs, val = pcall(plyr.GetNameFromUserIdAsync, plyr, data.key)
		if successs == true then
		    -- Now we are getting Frkn value from winsPage players in a order. So their gold and frkn values will shown true
			local b = dataStore1:GetAsync(data.key)
			-- Show players on leaderboard object in a order (leaderboard template created and this code only cloning and changin values and placing --it)
			local newLbFrame = game.ReplicatedStorage:WaitForChild("LeaderBoardFrame"):Clone()
			newLbFrame.Player.Text = val
			newLbFrame.Rank.Text = rank
			newLbFrame.Gold.Text = Gold
			newLbFrame.Frkn.Text = b
			newLbFrame.Position = UDim2.new(0,0,newLbFrame.Position.Y.Scale + (0.8 * #game.Workspace.GlobalLeaderBoard.LeaderBoardGUI.Holder:GetChildren()),0)
			--We must assign a parent if you want to show it for all players
			newLbFrame.Parent = game.Workspace.GlobalLeaderBoard.LeaderBoardGUI.Holder
		end
	end
end)

--Setup Inventory to player. This function called from line 96
local function SetupInventory(player)
    --get templates from player, because we will use them. (Inventory template,PlayerGui,MainGui,InventoryGui)
	local Inventory = player:WaitForChild("Inventory")
	local PlayerGui = player:WaitForChild("PlayerGui")
	local MainGui = PlayerGui:WaitForChild("MainGui")
	local InventoryGui = MainGui:WaitForChild("InventoryGui")
	
	--for loop.  For inventory items (Note inventory is a template and we assign it from StarterGui in roblox studio)
	--we are assign saved items with values to player inventory
	for i,item in pairs(Inventory:GetChildren()) do
		local itemGui = InventoryGui.Templates.Item:Clone()
		itemGui.Name = item.Name
		itemGui.ItemName.Text = item.Name
		itemGui.ItemQuantity.Text = item.Value
		--Check if item value is equal 1 or more bigger than 1 set item visible in inventory. And assign it to player inventory
		if item.Value > 0 then
			itemGui.Visible = true
			itemGui.Parent = InventoryGui.ItemList
		else
			itemGui.Visible = false
			itemGui.Parent = InventoryGui.ItemList
		end
	end
end

--When player join the game this function (event subscribe) will work
game.Players.PlayerAdded:Connect(function(player)
	--pcall is preventing any failure and waiting results
    --Get player's stored data	
	local success, value = pcall(dataStorePlyr.GetAsync,dataStorePlyr,player.UserId)
	--create data in player with files
	if success == false then player:Kick("DataStore failed to load") return end
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
	print("Loaded:", value)
	--Get players data and assign it to player
	for i, folder in game.ServerStorage.PlayerData:GetChildren() do
		local subData = data[folder.Name] or {} --data[folder.Name] is exist assign it. If not exist assign null
		local clone = folder:Clone()
		for i , child in clone:GetChildren()do
			child.Value = subData[child.Name] or child.Value
			if clone.Name == "leaderstats" then
				if child.Name == "Gold" then
					gold.Value = child.Value
				elseif child.Name == "Frkn" then
					Frkn.Value = child.Value
				end
			end
		end
		clone.Parent = player
	end
	--save data to orderedDataStorage to be used later for custom transactions(to show Leaderboard on Gameobject)
	local success, value = pcall(dataStore.SetAsync, dataStore, player.UserId,gold.Value)
	local success, value = pcall(dataStore1.SetAsync, dataStore1, player.UserId,Frkn.Value)
	loaded[player] = true
	
	--add +1 point to user data when player join the game (LoginCounter + 1),(Gold + 1),(Frkn + 1)
	local data2 = player:WaitForChild("Data2",10)
	if data2 == nil then return end
	data2.LoginCounter.Value += 1
	
	local data3 = player:WaitForChild("leaderstats",10)
	if data3 == nil then return end 
	data3.Gold.Value += 1
	
	local data4 = player:WaitForChild("leaderstats",10)
	if data4 == nil then return end
	data4.Frkn.Value += 1
	
	--Create inventorytemplate on player. When player open inventory it will see existing items if item value is equal 1 or more higher than 1
	local GameData = InventoryTemplate:Clone()
	GameData.Name = "Inventory"
	GameData.Parent = player	
	SetupInventory(player)
end)

--Save data when player left game. That is auto save when user left game automatcly saving player's data
game.Players.PlayerRemoving:Connect(function(player)
    --Check loaded has player
	if loaded[player] == nil then return end
	local data = {}
	--Start to save user data before left game. Save Gold and Frkn
	for i, folder in game.ServerStorage.PlayerData:GetChildren() do
		local subData = {}
		for i, child in player[folder.Name]:GetChildren() do
			subData[child.Name] = child.Value
			if child.Name == "Gold" then
				local success, value = pcall(dataStore.SetAsync, dataStore, child.Value)
			elseif child.Name == "Frkn" then
				local success, value = pcall(dataStore1.SetAsync, dataStore1, child.Value)
			end
		end
		data[folder.Name] = subData
		player[folder.Name]:Destroy()
	end
	local success, value = pcall(dataStorePlyr.SetAsync, dataStorePlyr, player.UserId,data)
	print("Saved:",data)
	loaded[player] = nil
end)

--Check every itemValues changing. if 0 set visible false else visible true.
for i , itemValue in pairs(Inventory:GetChildren()) do
    --Assign a listener for woods and leaves values. If they changed this block will be fired
	itemValue.Changed:Connect(function()
		local itemGui = InventoryGui.ItemList:FindFirstChild(itemValue.Name)
		if itemGui then
			itemGui.ItemQuantity.Text = itemValue.Value
			--if item value is equal 1 or more higher than 1 user can see this item on inventory else player can't see item on inventory
			if itemValue.Value <= 0 then
				itemGui.Visible = false
			else
				itemGui.Visible = true
			end
		end
	end)
end

--assign events to inventory item buttons to drop them
for i , itemButton in pairs(InventoryGui.ItemList:GetDescendants()) do	
    -- if it is a ImageButton assign a event right and left mouse click on image. We are using it to detect player clicked item image
	if itemButton:IsA("ImageButton") then
		itemButton.MouseButton2Up:Connect(function()
			local itemFrame = itemButton.Parent
			local itemValue = Inventory:FindFirstChild(itemFrame.Name)
			if itemValue.Value > 0 then
			    --If item value(count) is equal 1 or more higher than 1 dropıtem events turn back true value and we assign new value to item in --inventory
				local DropItemm = DropItem:InvokeServer(itemFrame.Name)
				if DropItemm == true then
					if itemValue.Value > 0 then
						itemFrame.ItemQuantity.Text = itemValue.Value
					else
						itemFrame.Visible = false
					end
				end
			end
		end)
		itemButton.MouseButton1Up:Connect(function()
			local itemFrame = itemButton.Parent
			local itemValue = Inventory:FindFirstChild(itemFrame.Name)
			if itemValue.Value > 0 then
			    -- if user has this item DropItemm will be true and we will show (itemCount - 1) to player and if still user has item it will shown --in inventory
				local DropItemm = DropItem:InvokeServer(itemFrame.Name)
				if DropItemm == true then
					if itemValue.Value > 0 then
						itemFrame.ItemQuantity.Text = itemValue.Value
					else
						itemFrame.Visible = false
					end
				end
			end
		end)
	end
end

-- when pickupitem fired here will work
PickupItem.OnServerEvent:Connect(function(player, item)
	local char = player.Character
	local inventory = player.Inventory
	local itemValue = inventory:FindFirstChild(item.Name)
	--if item is exist continue
	if itemValue then
		itemValue.Value = itemValue.Value + 1
		local finishingLocation = char.HumanoidRootPart.CFrame
		item.CanCollide = false
		item.Anchored = true
		local tween = TweenService:Create(item, pickupTweenInfo, {Transparency = 1,Size = Vector3.new(0,0,0), CFrame = finishingLocation})
		--rotate and move towards character under tween conditions
		tween:Play()
	end
end)

-- when dropitem event fired here will work
DropItem.OnServerInvoke = function(player,itemName)
    --Get player inventory item to check item count and name
	local Inventory = player.Inventory
	local item = Inventory:FindFirstChild(itemName)
	if item then
	    -- if item count bigger than 1 or equal 1 this block will work
		if item.Value > 0 then
		    -- minus 1 from item value because it losing one count
			item.Value = item.Value - 1
			-- put item into workspace. Now everyone can see item . Because user drop it
			local itemClone = Items:FindFirstChild(itemName):Clone()
			itemClone.CFrame = player.Character.HumanoidRootPart.CFrame + player.Character.HumanoidRootPart.CFrame.LookVector * 6
			itemClone.Parent = game.Workspace
			return true
		else
			return false
		end
	end
end

--show player to item name and that "f to pickup" text under true conditions (conditions = mouse must be over item object)
UIS.InputChanged:Connect(function(input)
	if mouse.Target then
	    --Out items has boolen value and calling it Pickable. If it is a item it must has Pickable boolean value. This line checking it
		if mouse.Target:FindFirstChild("Pickable") then
		    --after if conditions it is showing item name and we are assinging gui's adornee. For show gui over item 
			local item = mouse.Target
			PickUpInfoGui.Adornee = item
			PickUpInfoGui.ObjectName.Text = item.Name
			PlayerGui.PickUpInfoGui.Enabled = true
		else
		    --if that is not a item (has no pickable boolean value) we not assign adornee because we must not show item name and "F-to pickup" text
			PickUpInfoGui.Adornee = nil
			PlayerGui.PickUpInfoGui.Enabled = false
		end
	end	
end)

--fire pickupitem event under true conditions
UIS.InputEnded:Connect(function(input)
    -- if user pressed "f"(pickupKey), this block working
	if input.KeyCode == Enum.KeyCode[pickupKey] then
	    --if mouse is over a object, this block working
		if mouse.Target then
		     -- if mouse's targeted object has pickable boolen value and this pickable value is true this block working
			if mouse.Target:FindFirstChild("Pickable") then
			    -- we are assigning mouse's targeted object to item
				local item = mouse.Target
				--if item valid(not null)
				if item then
				    -- Get distinces between player and item. That is mathematical function we are subtracting two vectors
					local distanceFromItem = player:DistanceFromCharacter(item.Position)
					--true if the distance is less than 30 then this code will work
					if distanceFromItem < 30 then
						--to take item we are firing PickupItem event and we are sending item features with event
						--pickupitem event is in replicatedStorage. it is a brigde between user and server
						PickupItem:FireServer(item)
					end
				end
			end
		end
	end
end)

UIS.InputBegan:Connect(function(input)
	-- if user pressed delete key spesific part 
	if input.KeyCode == Enum.KeyCode.Delete then
	    --this event only deleting spesific part object
		testEvent:FireServer(part)
	end	
end)

--OpenCloseInventory is a button. when you click it. It is showing or hiding inventory. InventoryGui.Visible = true or false
--Inventory and other player's gui items loading to user at the begining so you are only changing their values
--MouseButton2Up is mouse right click. MouseButton1Up is mouse right click
--Appear and Dissappear inventory
OpenCloseInventory.MouseButton2Up:Connect(function()
	if InventoryGui.Visible == true then
		InventoryGui.Visible = false
	else
		InventoryGui.Visible = true
	end
end)

OpenCloseInventory.MouseButton1Up:Connect(function()
	if InventoryGui.Visible == true then
		InventoryGui.Visible = false
	else
		InventoryGui.Visible = true
	end
end)

testEvent.OnServerEvent:Connect(function(player,part)
    --delete object from server(from all users)
	part:Destroy()
end)

--That is important part BindToClose is preventing lose data. For example if player left game or server has unexpected issues. This code waiting
--untill game data saving. So BindToClose is too important
game:BindToClose(function()
    -- we created a loaded value in script. this line checking is there any waiting operation if there is a waiting operation
	--task.wait working and providing time to accomplish all tasks
	while next(loaded) ~= nil do
		task.wait()
	end
end)
