--want new features just dm @bela_dimitrescu1940 on Discord
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Folder = script.Parent
local Service = require(script.Parent:FindFirstChild('ServiceModule'))
local RemoteEvents = Service.Remotes()
local Number = require(ReplicatedStorage:FindFirstChild('Number'))
local DataStore = require(Folder:FindFirstChild('DataStore'))

RemoteEvents:OnServerEvent('ClickEvent', function(player)
	local ls = player:FindFirstChild('leaderstats')
	local Clicks = ls:FindFirstChild('Clicks')
	local data = DataStore.GetData(player.UserId)
	data.Clicks = Number.add(data.Clicks, data.ClickPlus)
	Clicks.Value = data.Clicks
end)

RemoteEvents:OnServerEvent('SessionTime', function(player)
	local OtherData = player:FindFirstChild('OtherData')
	local SessionTime = OtherData:FindFirstChild('Session')
	local data = DataStore.GetData(player.UserId)
	data.SessionTime = Service.Number().add(data.SessionTime, 1)
	SessionTime.Value = data.SessionTime
end)