--want new features just dm @bela_dimitrescu1940 on Discord
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Folder = script.Parent
local Service = require(script.Parent:FindFirstChild('ServiceModule'))
local RemoteEvents = Service.Remotes()
local Number = require(ReplicatedStorage:FindFirstChild('Number'))
local GetData = Service.GetData()

RemoteEvents:OnServerEvent('ClickEvent', function(player)
	local ls = player:FindFirstChild('leaderstats')
	local Clicks = ls:FindFirstChild('Clicks')
	local data = GetData.data(player.UserId)
	data.Clicks = Number.add(data.Clicks, data.ClickPlus)
	Clicks.Value = data.Clicks
end)