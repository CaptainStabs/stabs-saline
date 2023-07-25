local QBCore = exports['qb-core']:GetCoreObject()

local function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNetEvent('saline:client:UseSaline', function()
    local hasItem = QBCore.Functions.HasItem('saline')
    if hasItem then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 5.0 then
            local playerId = GetPlayerServerId(player)
            QBCore.Functions.Progressbar("hospital_healwounds", "Injecting saline....", 5000, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = healAnimDict,
                anim = healAnim,
                flags = 33,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                QBCore.Functions.Notify("You healed someone!", 'success')
                TriggerServerEvent("stabs:server:HealPlayer", playerId)
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                QBCore.Functions.Notify('Canceled...', "error")
            end)
        else
            QBCore.Functions.Notify('No Player Nearby', "error")
        end
    else
        QBCore.Functions.Notify('You need saline', "error")
    end
end)

RegisterNetEvent('stabs:client:HealInjuries', function(playerId)
    -- ResetPartial()
    local player =  PlayerPedId()
    TriggerServerEvent("hospital:server:RestoreWeaponDamage")
    
    local currentHealth = GetEntityHealth(player)
    SetEntityHealth(player, currentHealth + 30) -- Heal the local player

    QBCore.Functions.Notify(Lang:t('success.wounds_healed'), 'success')
end)


-- RegisterCommand("givesaline", function()
--     TriggerServerEvent('giveItem')
-- end)
