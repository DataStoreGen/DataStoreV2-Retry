local Folder = script.Parent
local Module = Folder:FindFirstChild('ServiceModule')
local ServiceModule = require(Module)
local Players = ServiceModule.Players()
local DataStore = require(Folder:FindFirstChild('DataStore'))

local PlayersDataStore = DataStore.new('DataStore', DataStore.TemplateData)
-- u can add ur own Session Value to track players session in game

Players:PlayerAdded(function(player)
	local oldData = PlayersDataStore:LoadData(player.UserId)
	
	local ls = Instance.new('Folder')
	ls.Name = 'leaderstats'
	ls.Parent = player
	local PlusData = Instance.new('Folder')
	PlusData.Name = 'PlusData'
	PlusData.Parent = player
	local OtherData = Instance.new('Folder')
	OtherData.Name = 'OtherData'
	OtherData.Parent = player
	
	local Clicks = Instance.new('NumberValue')
	Clicks.Name = 'Clicks'
	local ClickPlus = Instance.new('NumberValue')
	ClickPlus.Name = 'ClickPlus'
	if oldData then
		Clicks.Value = oldData.Clicks
		ClickPlus.Value = oldData.ClickPlus
	else
		Clicks.Value = 0
		ClickPlus.Value = 1
	end
	
	Clicks.Parent = ls
	ClickPlus.Parent = PlusData
end)

Players:PlayerRemoving(function(player)
	PlayersDataStore:OnLeaveUpdate(player.UserId)
end)

PlayersDataStore:AutoSaveOnUpdate(Players.Players)
PlayersDataStore:BindOnUpdate(true)