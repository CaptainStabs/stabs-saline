local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('stabs:server:HealPlayer', function(playerId)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Patient = QBCore.Functions.GetPlayer(playerId)
	if Patient then	
        Player.Functions.RemoveItem('saline', 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['saline'], "remove")
        TriggerClientEvent("stabs:client:HealInjuries", playerId)
	end
end)

-- Testing command
RegisterServerEvent('giveItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem('saline', 1)
end)

QBCore.Functions.CreateUseableItem("saline", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("saline:client:UseSaline", src)
	end
end)
