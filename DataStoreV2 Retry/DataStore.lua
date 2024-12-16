local Folder = script.Parent
local ServiceModule = Folder:FindFirstChild('ServiceModule')
local DataStore1 = require(ServiceModule)
local DataStore = {}

DataStore.TemplateData = {
	-- example data
	Clicks = 1,
	ClickPlus = 1,
}

export type PlayersData = typeof(DataStore.TemplateData)

DataStore.__index = DataStore

function DataStore.new(dataName, Template)
	local self = {
		dataStore = DataStore1.DataStore(dataName),
		PlayersData = Template,
		Session = DataStore1.Session,
	}
	self.CloneTemplate = function(original)
		local clone = {}
		for keys, values in pairs(original) do
			if type(values) == 'table' then
				clone[keys] = self.CloneTemplate(values)
			else
				clone[keys] = values
			end
		end
		return clone
	end
	setmetatable(self, DataStore)
	return self
end

function DataStore:MergeToCurrent(data)
	for key, value in pairs(self.PlayersData) do
		if type(value) == 'table' then
			data[key] = data[key] or {}
			for k, v in pairs(value) do
				data[key][k] = data[key][k] or v
			end
		else
			data[key] = data[key] or value
		end
	end
	return data
end

function CleanData(self, Data)
	for info, data in pairs(Data) do
		if type(data) == 'table' then
			for k, _ in pairs(data) do
				if not (self.PlayersData[info] and self.PlayersData[info][k]) then
					data[k] = nil
				end
			end
		elseif not self.PlayersData[info] then
			Data[info] = nil
		end
	end
end

function DataStore:GetfromLastSession(player: Player)
	local success, data = pcall(function()
		return self.dataStore:GetAsync(player)
	end)
	return data or self.CloneTemplate(self.PlayersData)
end

function DataStore:LoadData(player: Player): PlayersData?
	local data = self:GetfromLastSession(player)
	data = self:MergeToCurrent(data)
	CleanData(self, data)
	self.Session[player] = data
	local newData = self.Session[player]
	return newData
end

function DataStore:GetDatafromSession(player: Player)
	local Session = self.Session[player]
	if not Session then return end
	return Session
end

function DataStore:SetAsync(player: Player, canBind: boolean?, userIds: {any}?, options: DataStoreSetOptions?)
	local data = self:GetDatafromSession(player)
	return self.dataStore:SetAsync(player, data, canBind, userIds, options)
end

function DataStore:UpdateAsync(player: Player, canBind: boolean?)
	local data = self:GetDatafromSession(player)
	return self.dataStore:UpdateAsync(player, function(oldData)
		return data
	end, canBind)
end

function DataStore:OnLeaveUpdate(player, canBind: boolean?)
	self:UpdateAsync(player, canBind)
	self.Session[player] = nil
end

function DataStore:OnLeaveSet(player: Player, canBind: boolean?, userIds: {any}?, options: DataStoreSetOptions?)
	self:SetAsync(player, canBind, userIds, options)
	self.Session[player] = nil
end

function DataStore:BindOnUpdate(canBind: boolean?)
	return self.dataStore:BindDataOnUpdate(canBind)
end

function DataStore:BindOnSet(canBind: boolean?)
	return self.dataStore:BindDataOnSet(canBind)
end

function DataStore:AutoSaveOnUpdate(Players, waitTime: number?)
	waitTime = waitTime or 180
	waitTime = DataStore1.Number().clamp(waitTime, 0, 180)
	task.spawn(function()
		while task.wait(waitTime) do
			for _, player in pairs(Players:GetPlayers()) do
				local success, err = pcall(function()
					return self:UpdateAsync(player.UserId)
				end)
				if not success then
					warn('Failed to auto save to:', player.Name)
				else
					warn('Successfully AutoSaved')
				end
			end
		end
	end)
end

function DataStore:AutoSaveOnSet(Players, waitTime)
	waitTime = DataStore1.Number().clamp(waitTime, 0, 180)
	task.spawn(function()
		while task.wait(waitTime) do
			for _, player in pairs(Players:GetPlayers()) do
				local success, err = pcall(function()
					return self:SetAsync(player.UserId)
				end)
				if not success then
					warn('Failed to auto save to:', player.Name)
				else
					warn('Successfully AutoSaved')
				end
			end
		end
	end)
end

return DataStore