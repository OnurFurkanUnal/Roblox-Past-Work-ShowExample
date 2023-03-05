--Important : MatchFind, RightSlotOne, Character, ToolController and LeftSlotOne scripts showing all details. 
--They are in The Model/L/1/LeftSlotOne , The Model/R/1/RightSlotOne , ServerScriptService/MatchFind, 
--StarterPlayer/StarterPlayerScripts/Character , ReplicatedStorage/Tool/ToolController
--others copy of them and we defined 4 copy of this arena so we have 4 copy of server events. Because every arena
--has own spesific process. That is preventing any confiuse
--Împortant : We are using dictionarys and in activeWarriorRight,activeWarriorLeft there is inner table
--Key is player value is a table with side and slot. true is right side. false is left side on arena
--This script controls arena1(The Model)
local replicatedStorage = game:GetService("ReplicatedStorage")
--we are storing arena 1 users and every arena scripts has these attiributes
local activeWarriorRight = {}
local activeWarriorLeft = {}
local activeWarriorsAccept = {}
--To check there is match to block or allow users to join match
local checkThereIsMatch = false
--Our client events(Sending messages to clients)
local remoteEventForFireClient = replicatedStorage:WaitForChild("RemoteEvent")
local AcceptMatch = replicatedStorage:WaitForChild("AcceptMatch")
local StartMatch = replicatedStorage:WaitForChild("StartMatch")
local CloseDuel = replicatedStorage:WaitForChild("CloseDuelWarn")
local tool = replicatedStorage:WaitForChild("Tool")
--send player info if match is 1v1
local UserInfo = replicatedStorage:WaitForChild("UserInfo")
--send match info if match is 1v1
local SendPoint = replicatedStorage:WaitForChild("SendPoint")
--Start positions for players. It is protecting position because these models are child of The Model
local startposexampleright1 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleright1")
local startposexampleright2 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleright2")
local startposexampleright3 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleright3")
local startposexampleright4 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleright4")
local startposexampleleft1 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleleft1")
local startposexampleleft2 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleleft2")
local startposexampleleft3 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleleft3")
local startposexampleleft4 = game.Workspace:WaitForChild("The Model"):WaitForChild("startposexampleleft4")
--to count match points
local leftPoint = 0
local rightPoint = 0
--To show match detail to everyone. These attiributes are UI
local leftPointShow = game.Workspace:WaitForChild("The Model"):WaitForChild("Monitor"):WaitForChild("Surface2"):WaitForChild("MainFrame"):WaitForChild("Main"):WaitForChild("score_t1")
local rightPointShow = game.Workspace:WaitForChild("The Model"):WaitForChild("Monitor"):WaitForChild("Surface2"):WaitForChild("MainFrame"):WaitForChild("Main"):WaitForChild("score_t2")
local timerShow = game.Workspace:WaitForChild("The Model"):WaitForChild("Monitor"):WaitForChild("Surface2"):WaitForChild("MainFrame"):WaitForChild("Main"):WaitForChild("timer")
local mainShow = game.Workspace:WaitForChild("The Model"):WaitForChild("Monitor"):WaitForChild("Surface"):WaitForChild("MainFrame"):WaitForChild("Main"):WaitForChild("timer")
--Count match time
local matchTime = 90
--This attiribute is reseting match time and checking
local stopTime = false
--To accept match. This attiribute is important if one player accept starting match
local isAccept = 0
--That is so important we set 5000 second respawntıme and we set true to characterautoloads
--when we load character it is losing script subsucribe and local values with this settings
--we are not losing we are only changing character easly
game:GetService("StarterGui").ResetPlayerGuiOnSpawn = false

--slots events(left and right slots using these events)
local leftSlotOne = replicatedStorage:WaitForChild("LeftSlotOne")
local rightSlotOne = replicatedStorage:WaitForChild("RightSlotOne")
--model slots(pads) asking is there match now in arena
local isThereMatch = replicatedStorage:WaitForChild("IsThereMatch")
local removeUser = replicatedStorage:WaitForChild("RemoveUser")
--Reseting pads UI
local resetSlotsUI = replicatedStorage:WaitForChild("Reset")
--getting request to respawnchecker script
local sendReSpawnCheck = replicatedStorage:WaitForChild("ReSpawnCheckSendToMultipleScripts")


--check user lefted slot(maybe he is in match)
local function CheckLeftSlotOne(player, slot)
	--get left and right slots active players counts
	local lengthRight = 0
	local lengthLeft = 0
	for _ in pairs(activeWarriorRight) do
		lengthRight = lengthRight + 1
	end
	for _ in pairs(activeWarriorLeft) do
		lengthLeft = lengthLeft + 1
	end
	-- if left and right not zero and they are equal they can match.
	if lengthLeft ~= 0 and lengthRight ~= 0 and lengthLeft == lengthRight then
		--do not anything
		return false
	else
		--add left side user to activeWarriorLeft
		activeWarriorLeft[player] = {false,slot}
		--Control if  they are eligible for match, start match
		ControlCanTheyMatch()
		return true
	end

end

--check user lefted slot(maybe he is in match)
local function CheckRightSlotOne(player, slot)
	--get left and right slots active players counts
	local lengthRight = 0
	local lengthLeft = 0
	for _ in pairs(activeWarriorRight) do
		lengthRight = lengthRight + 1
	end
	for _ in pairs(activeWarriorLeft) do
		lengthLeft = lengthLeft + 1
	end
	-- if left and right not zero and they are equal they can match.
	if lengthLeft ~= 0 and lengthRight ~= 0 and lengthLeft == lengthRight then
		--do not anything
		return false
	else
		--add right side user to activeWarriorRight
		activeWarriorRight[player] = {true, slot}
		--Control if  they are eligible for match, start match
		ControlCanTheyMatch()
		return true
	end

end

-- check there is match. Slots query this method and we feed back with respond. Arena slots waiting this
--respond to make anythink
local function MatchCheck()
	if checkThereIsMatch == true then
		return true
	else
		return false
	end
end

--remove user. ıf player left slot or for any unexpected situation slots query this event
--and we removing player. side is equal left or right. slot is equal whic pad. pl is equal player
local function rmv(side, slot , pl)
	if side == true then
		for key, value in pairs(activeWarriorRight) do
			if key == pl and value[2] == slot then
				-- if here works we deleted a player from right side
				activeWarriorRight[key] = nil
				return true
			end
		end
	else
		for key, value in pairs(activeWarriorLeft) do
			if key == pl and value[2] == slot then
				-- if here works we deleted a player from left side
				activeWarriorLeft[key] = nil
				return true
			end
		end
	end
end


-- Set the OnInvoke callback for leftslots queries event
leftSlotOne.OnInvoke = CheckLeftSlotOne
-- Set the OnInvoke callback for rightslot queries event
rightSlotOne.OnInvoke = CheckRightSlotOne
-- Set the OnInvoke callback to check there is match queries event
isThereMatch.OnInvoke = MatchCheck
-- Set the OnInvoke callback to remove user queries event
removeUser.OnInvoke = rmv

--Control can they make a match. If they can send accept message
function ControlCanTheyMatch()
	--get left and right slots active players counts
	local lengthRight = 0
	local lengthLeft = 0
	for _ in pairs(activeWarriorRight) do
		lengthRight = lengthRight + 1
	end
	for _ in pairs(activeWarriorLeft) do
		lengthLeft = lengthLeft + 1
	end

	-- If left and right slots has equal player send them query to start match
	if lengthLeft == lengthRight and checkThereIsMatch == false  then
		-- set true because now we sended a match query so we dont want to addional player
		checkThereIsMatch = true
		for key, value in pairs(activeWarriorLeft) do
			--send messages to players standing in left slots
			remoteEventForFireClient:FireClient(key , false)
		end
		for key, value in pairs(activeWarriorRight) do
			--send messages to players standing in right slots
			remoteEventForFireClient:FireClient(key, true)
		end
	end

end

--If this event fired by client. We start match.
AcceptMatch.OnServerEvent:Connect(function(player)
	--This control mechanism prevents confusion among the very important arena codes. If the user is registered on this map, the process continues
	if activeWarriorLeft[player] ~= nil or activeWarriorRight[player] ~= nil or activeWarriorsAccept[player] ~= nil then
		-- if one user accepted match we are starting match. so isAccept is a controller
		if isAccept == 0 then
			--isAccept = 2 now. Because we dont want to process other accept match queryes
			isAccept = isAccept + 1
			local right = 1
			local left = 1
			--left players process
			for key, value in pairs(activeWarriorLeft) do
				--Make red team for leftside players
				key.Team = game.Teams.Red
				--Give start position
				local cf1 = CFrame.new(alignPos(false,left).Position)
				--fire startmatch event
				StartMatch:FireClient(key, cf1)
				--we increase the left value by one so that we can give the next position
				left = left + 1
				--add tool to player
				addTool(key)
				--add player to activeWarriorsAccept. activeWarriorsAccept table keeps active players in match
				activeWarriorsAccept[key] = true
			end
			--right players process
			for key, value in pairs(activeWarriorRight) do
				--Make white team for rightside players
				key.Team = game.Teams.White
				--Give start position
				local cf = CFrame.new(alignPos(true,right).Position)
				--fire startmatch event
				StartMatch:FireClient(key, cf)
				--we increase the right value by one so that we can give the next position
				right = right + 1
				--add tool to player
				addTool(key)
				--add player to activeWarriorsAccept. activeWarriorsAccept table keeps active players in match
				activeWarriorsAccept[key] = true
			end
			--send enemy info to show on top of player screen if match is 1v1
			local total = 0
			for _ in pairs(activeWarriorsAccept) do
				total = total + 1
			end
			if total == 2 then
				local leftPly
				local rightPly
				for key, value in pairs(activeWarriorLeft) do
					leftPly = key
				end
				for key, value in pairs(activeWarriorRight) do
					rightPly = key
				end
				--first param is user. second is enemy. third is left right if true is right else left
				UserInfo:FireClient(rightPly,leftPly,true)
				UserInfo:FireClient(leftPly,rightPly,false)
			end

			--Show match score to world
			mainShow.Text = "0     -      0"
			--Start count down for match timer
			seconds()
			activeWarriorsAccept[player] = true
		end
	end
end)

--Add sword to user(When match start)
function addTool(key)
	local Clone = tool:Clone()
	Clone.Parent = key.Backpack
end

--count time if match not finish count players and give points 
function seconds()
	--stopTime is a controller to finis countin or continue
	stopTime = false
	matchTime = 90
	--every one seconds this block will be fired
	while wait(1) do
		--to show elapsing time on UI
		timerShow.Text = matchTime
		--count down from time
		matchTime = matchTime - 1
		--control if stopTime is true contniue to count down
		if stopTime == true then
			break
		end
		--if there is not match continue to count down
		if checkThereIsMatch == false then
			break
		end
		--if matchtime elapsed and time is 0 finish match
		if matchTime <= 0 then
			--count how many people there are in activeWarriorsAccept table
			local total = 0
			for _ in pairs(activeWarriorsAccept) do
				total = total + 1
			end
			--give points or win lose if match 1v1
			if total == 2 then	
				refresh()
				break
				--give points or win lose if match is not 1v1
			elseif total > 2 then
				reset()
				break	
			end	
			break
		end				
	end
end

--to finish match
function getOut()
	--reset all slots UI's because match is done
	resetSlotsUI:Fire("asd")
	--stopTime = true because timer must stop
	stopTime = true
	-- remove all users from left side slots
	for key, value in pairs(activeWarriorLeft) do
		--assing nill to team. there is not match so there is no team
		key.Team = nil
		--reset character load them(only reseting positions not their scripts)
		key:LoadCharacter()
		--close user gui
		CloseDuel:FireClient(key)
		--remove player from activeWarriorsAccept and activeWarriorLeft
		activeWarriorsAccept[key] = nil
		activeWarriorLeft[key] = nil
	end
	-- remove all users from right side slots
	for key, value in pairs(activeWarriorRight) do
		key.Team = nil
		key:LoadCharacter()
		--close user gui
		CloseDuel:FireClient(key)
		activeWarriorsAccept[key] = nil
		activeWarriorRight[key] = nil
	end
	--checkThereIsMatch = false because slots can get new users that attiribute is important for slots. slots query for this attiribute
	checkThereIsMatch = false
	--reset isaccept 
	isAccept = 0
	wait(3)
	stopTime = false
end
--to respawn players in match if match not 1v1
function reset()
	stopTime = true
	local right = 1
	local left = 1
	wait(2)
	-- itterate activeWarriorLeft table. they are left side players
	for key, value in pairs(activeWarriorLeft) do
		--get user position
		local cframe = key.character.HumanoidRootPart.CFrame
		--reload character(not their scripts only position heal etc)
		key:LoadCharacter()
		--get eligible position and give it to character. aligmPos is a function it is giving us player next position depends on params
		key.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(alignPos(false,left).Position)
		--give sword to player
		addTool(key)
		--we increase the left value by one so that we can give the next position
		left = left + 1
	end
	-- itterate activeWarriorRight table. they are right side players
	for key, value in pairs(activeWarriorRight) do
		--get user position
		local cframe = key.character.HumanoidRootPart.CFrame
		--reload character(not their scripts only position heal etc)
		key:LoadCharacter()
		--get eligible position and give it to character. aligmPos is a function it is giving us player next position depends on params
		key.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(alignPos(true,right).Position)
		--give sword to player
		addTool(key)
		--we increase the right value by one so that we can give the next position
		right = right + 1
	end
	--Show 90 secs for match timer because match reset
	timerShow.Text = 90
	--start count down timer
	seconds()
end
--to respawn players in match if match is 1v1
function refresh()
	--everyting same as reset() function
	stopTime = true
	local right = 1
	local left = 1
	wait(2)
	for key, value in pairs(activeWarriorLeft) do
		local cframe = key.character.HumanoidRootPart.CFrame
		key:LoadCharacter()
		key.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(alignPos(false,left).Position)
		addTool(key)
	end
	for key, value in pairs(activeWarriorRight) do
		local cframe = key.character.HumanoidRootPart.CFrame
		key:LoadCharacter()
		key.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(alignPos(true,right).Position)
		addTool(key)
	end
	timerShow.Text = 90
	seconds()
end

function sendMatchScore()
	local leftPly
	local rightPly
	for key, value in pairs(activeWarriorLeft) do
		leftPly = key
	end
	for key, value in pairs(activeWarriorRight) do
		rightPly = key
	end
	--first param is user. second is enemy. third is left right if true is right else left
	--first param is left score. second param is right score
	SendPoint:FireClient(rightPly,leftPoint,rightPoint)
	SendPoint:FireClient(leftPly,leftPoint,rightPoint)
end

--when player join the game operations here
game.Players.PlayerAdded:Connect(function(player)
	player.Team = nil

	--when character came here works (Character and player are diffrent in roblox)
	player.CharacterAdded:Connect(function()
		--when player die here works
		player.Character.Humanoid.Died:Connect(function()
			--This control mechanism prevents confusion among the very important arena codes. If the user is registered on this map, the process continues
			if activeWarriorLeft[player] ~= nil or activeWarriorRight[player] ~= nil or activeWarriorsAccept[player] ~= nil then
				--check player is in match
				if activeWarriorsAccept[player] ~= nil then
					--send message to respawnchecker. Is player in our area or not 
					--last param is scriptcode
					sendReSpawnCheck:Invoke(player, true , 1)
					-- check match is 1v1 or 2..vs2..
					--get count of table
					local lengthAccepted = 0
					for _ in pairs(activeWarriorsAccept) do
						lengthAccepted = lengthAccepted + 1
					end
					--if match 1v1
					if lengthAccepted == 2 then
						--check left is die and died player in left side
						if activeWarriorLeft[player] ~= nil then
							local resetMatchLeft = false					
							for key, value in pairs(activeWarriorLeft) do
								--if leftside player is die
								if key.Character:WaitForChild("Humanoid").Health > 0 then
									resetMatchLeft = false
									break
								else
									resetMatchLeft = true
								end
							end
							--if die left side player process
							if resetMatchLeft == true then
								--add +1 point to right side because he killed left side player
								rightPoint = rightPoint + 1
								--show point on board
								rightPointShow.Text = rightPoint
								sendMatchScore()
								--if right player killed left player 5 times. match is done and right player won
								if rightPoint == 5 then
									--add +1 point lose to left side players
									for key, value in pairs(activeWarriorLeft) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Lose.Value += 1
									end
									--add +1 point win to right side players
									for key, value in pairs(activeWarriorRight) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Win.Value += 1
									end
									--reset points UI's and timer
									wait(3)
									rightPoint = 0
									leftPoint = 0
									rightPointShow.Text = rightPoint
									leftPointShow.Text = leftPoint
									timerShow.Text = 90
									mainShow.Text = "Waiting"
									--match is done throw users to out of match area
									getOut()
									--if match not done add point to right side and respawn players inside arena
								else
									rightPointShow.Text = rightPoint
									--front face of board to show match score to everyone
									mainShow.Text = leftPoint.."     -      "..rightPoint
									--respawn to continue match
									refresh()
								end						
							end
						end
						--check right is die  and died player in right side
						if activeWarriorRight[player] ~= nil then
							local resetMatchRight = false					
							for key, value in pairs(activeWarriorRight) do
								--if rightside player is die
								if key.Character:WaitForChild("Humanoid").Health > 0 then
									resetMatchRight = false
									break
								else
									resetMatchRight = true
								end
							end
							--if die right side player process
							if resetMatchRight == true then
								--add +1 point to left side because he killed right side player
								leftPoint = leftPoint + 1
								--show point on board
								leftPointShow.Text = leftPoint
								sendMatchScore()
								--if left player killed right player 5 times. match is done and left player won
								if leftPoint == 5 then
									--add +1 point win to left side players
									for key, value in pairs(activeWarriorLeft) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Win.Value += 1
									end
									--add +1 point lose to right side players
									for key, value in pairs(activeWarriorRight) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Lose.Value += 1
									end
									--reset points UI's and timer
									wait(3)
									rightPoint = 0
									leftPoint = 0
									rightPointShow.Text = rightPoint
									leftPointShow.Text = leftPoint
									timerShow.Text = 90
									mainShow.Text = "Waiting"
									--match is done throw users to out of match area
									getOut()
									--if match not done add point to right side and respawn players inside arena
								else
									leftPointShow.Text = leftPoint
									--front face of board to show match score to everyone
									mainShow.Text = leftPoint.."     -      "..rightPoint
									--respawn to continue match
									refresh()
								end						
							end
						end

					else
						--if match not 1v1 wait death of theam
						--check user in leftside
						if activeWarriorLeft[player] ~= nil then
							--check all leftside teammates die
							local resetMatch = false
							for key, value in pairs(activeWarriorLeft) do
								--if everyone is death we will reset match
								if key.Character:WaitForChild("Humanoid").Health > 0 then
									resetMatch = false
									break
								else
									resetMatch = true
								end

							end
							--if resetmatch is true count points respawn them etc
							if resetMatch == true then
								--reset positions and check points give points stop timer etc
								rightPoint = rightPoint + 1
								rightPointShow.Text = rightPoint
								if rightPoint == 5 then
									--add +1 point lose to left side players
									for key, value in pairs(activeWarriorLeft) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Lose.Value += 1
									end
									--add +1 point win to right side players
									for key, value in pairs(activeWarriorRight) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Win.Value += 1
									end
									wait(3)
									rightPoint = 0
									leftPoint = 0
									rightPointShow.Text = rightPoint
									leftPointShow.Text = leftPoint
									timerShow.Text = 90
									mainShow.Text = "Waiting"
									--match is done throw users to out of match area
									getOut()
								else
									rightPointShow.Text = rightPoint
									mainShow.Text = leftPoint.."     -      "..rightPoint
									reset()
								end



							else 
								--wait until match finish

							end
							--if match not 1v1 wait death of theam
							--check user in rightside                     
						elseif activeWarriorRight[player] ~= nil then
							--check all rightside teammates die
							local resetMatch = false
							for key, value in pairs(activeWarriorRight) do
								--if everyone is death we will reset match
								if key.Character:WaitForChild("Humanoid").Health > 0 then
									resetMatch = false
									break
								else
									resetMatch = true
								end

							end
							--if resetmatch is true count points respawn them etc
							if resetMatch == true then
								--reset positions and check points give points stop timer etc
								leftPoint = leftPoint + 1
								leftPointShow.Text = leftPoint
								if leftPoint == 5 then
									--add +1 point win to left side players
									for key, value in pairs(activeWarriorLeft) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Win.Value += 1
									end
									--add +1 point lose to right side players
									for key, value in pairs(activeWarriorRight) do
										local data = key:WaitForChild("leaderstats",10)--10 sanıye bekle yoksa devam et
										if data == nil then return end -- data2 yoksa dur dedik oyun cokmesın dıye
										data.Lose.Value += 1
									end
									wait(3)
									rightPoint = 0
									leftPoint = 0
									rightPointShow.Text = rightPoint
									leftPointShow.Text = leftPoint
									timerShow.Text = 90
									mainShow.Text = "Waiting"
									--match is done throw users to out of match area
									getOut()
								else
									leftPointShow.Text = leftPoint
									mainShow.Text = leftPoint.."     -      "..rightPoint
									reset()
								end



							else 
								--wait until match finish(not do anything)

							end
						end
					end


				elseif activeWarriorRight[player] ~= nil then
					--send message to respawnchecker. Is player in our area or not 
					--last param is scriptcode
					sendReSpawnCheck:Invoke(player, false , 1)
					resetSlotsUI:Fire("asd")
					for key, value in pairs(activeWarriorLeft) do
						CloseDuel:FireClient(key)
						activeWarriorLeft[key] = nil
					end
					for key, value in pairs(activeWarriorRight) do
						CloseDuel:FireClient(key)
						activeWarriorRight[key] = nil
					end
					checkThereIsMatch = false
					isAccept = 0
					stopTime = true
					resetSlotsUI:Fire("asd")
					timerShow.Text = 90
					mainShow.Text = "Waiting"
				elseif activeWarriorLeft[player] ~= nil then
					--send message to respawnchecker. Is player in our area or not 
					--last param is scriptcode
					sendReSpawnCheck:Invoke(player, false , 1)
					resetSlotsUI:Fire("asd")
					for key, value in pairs(activeWarriorLeft) do
						CloseDuel:FireClient(key)
						activeWarriorLeft[key] = nil
					end
					for key, value in pairs(activeWarriorRight) do
						CloseDuel:FireClient(key)
						activeWarriorRight[key] = nil
					end
					checkThereIsMatch = false
					isAccept = 0
					stopTime = true
					resetSlotsUI:Fire("asd")
					timerShow.Text = 90
					mainShow.Text = "Waiting"
				end
			else
				--send message to respawnchecker. Is player in our area or not 
				--last param is scriptcode
				sendReSpawnCheck:Invoke(player, false , 1)
			end
		end)
	end)
end)

--if everyone leaved match make rdy duel area
function cleanArea()
	local leftC = 0
	local rightC = 0
	local totalC = 0
	for _ in pairs(activeWarriorLeft) do
		leftC = leftC + 1
	end
	for _ in pairs(activeWarriorRight) do
		rightC = rightC + 1
	end
	for _ in pairs(activeWarriorsAccept) do
		totalC = totalC + 1
	end

	if totalC == 0 then
		checkThereIsMatch = false
		isAccept = 0
		stopTime = true
	end
end

--remove user from lists if he is exist in any list for this duel area
game.Players.PlayerRemoving:Connect(function(player)
	--This control mechanism prevents confusion among the very important arena codes. If the user is registered on this map, the process continues
	if activeWarriorLeft[player] ~= nil or activeWarriorRight[player] ~= nil or activeWarriorsAccept[player] ~= nil then
		--Remove player
		--check user is in match
		if activeWarriorsAccept[player] ~= nil then
			for key, value in pairs(activeWarriorsAccept) do
				CloseDuel:FireClient(key)
				activeWarriorsAccept[key] = nil			
			end
			if activeWarriorLeft[player] ~= nil then
				activeWarriorLeft[player] = nil
			elseif activeWarriorRight[player] ~= nil then
				activeWarriorRight[player] = nil
			end
			checkThereIsMatch = false
			isAccept = 0
			stopTime = true
			resetSlotsUI:Fire("asd")
			timerShow.Text = 90
			mainShow.Text = "Waiting"
			getOut()
			--check user in leftside ? because user is not in match	
		elseif activeWarriorLeft[player] ~= nil then
			activeWarriorLeft[player] = nil
			resetSlotsUI:Fire("asd")
			for key, value in pairs(activeWarriorLeft) do
				CloseDuel:FireClient(key)
			end
			for key, value in pairs(activeWarriorRight) do
				CloseDuel:FireClient(key)
			end
			checkThereIsMatch = false
			isAccept = 0
			stopTime = true
			resetSlotsUI:Fire("asd")
			timerShow.Text = 90
			mainShow.Text = "Waiting"
			--check user in leftside ? because user is not in match and leftside
		elseif activeWarriorRight[player] ~= nil then
			activeWarriorRight[player] = nil
			resetSlotsUI:Fire("asd")
			for key, value in pairs(activeWarriorLeft) do
				CloseDuel:FireClient(key)
			end
			for key, value in pairs(activeWarriorRight) do
				CloseDuel:FireClient(key)
			end
			checkThereIsMatch = false
			isAccept = 0
			stopTime = true
			resetSlotsUI:Fire("asd")
			timerShow.Text = 90
			mainShow.Text = "Waiting"

		end
	end
end)

function alignPos(side, count)
	if side == true then
		if count == 1 then
			return startposexampleright1
		elseif count == 2 then
			return startposexampleright2
		elseif count == 3 then
			return	startposexampleright3
		elseif count == 4 then
			return startposexampleright4
		end
	elseif side == false then
		if count == 1 then
			return startposexampleleft1
		elseif count == 2 then
			return startposexampleleft2
		elseif count == 3 then
			return	startposexampleleft3
		elseif count == 4 then
			return startposexampleleft4
		end
	end
end
