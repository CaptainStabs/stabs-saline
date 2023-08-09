local QBCore = exports['qb-core']:GetCoreObject()

local function GetDistanceBetweenPlayers(player1, player2)
    local pos1 = GetEntityCoords(GetPlayerPed(player1))
    local pos2 = GetEntityCoords(GetPlayerPed(player2))
    return #(pos1 - pos2)
end

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

local function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        
        Citizen.Wait(1)
    end
end

RegisterNetEvent('saline:client:UseSaline', function()
    -- local ivBag = 'iv_bag'
    local ivBag = 'prop_ld_binbag_01'
    local bagHash = GetHashKey(ivBag)
    local hasItem = QBCore.Functions.HasItem('saline')
    local healAnimDict = "anim@amb@business@weed@weed_inspecting_high_dry@"
    local healAnim = "weed_inspecting_high_base_inspector"
    local playerPed = PlayerPedId()

    if hasItem then
        local player, distance = GetClosestPlayer()
        if player ~= -1 and distance < 5.0 then        
            LoadModel(ivBag)
            local bag = CreateObject(bagHash, 0.0, 0.0, 0.0, true, true, true)
            local boneIndex = GetPedBoneIndex(playerPed, 60309) -- 60309 is the bone index for the hand
            AttachEntityToEntity(bag, playerPed, boneIndex, 0.08, 0, 0.05, 90.0, 90.0, 180.0, true, true, false, true, 1, true)

            local playerId = GetPlayerServerId(player)

            healing = true
            Citizen.CreateThread(function()
                while healing do
                    Citizen.Wait(1000)
                    local currentDistance = GetDistanceBetweenPlayers(PlayerId(), player)
                    print(currentDistance, distance)
                    if currentDistance > distance + 2.0 then -- You can adjust this distance as needed
                        TriggerServerEvent('saline:server:causeBleed', playerId)
                        QBCore.Functions.Notify("The patient moved too far away!", "error")
                        TriggerEvent('progressbar:client:cancel')
                        Citizen.Wait(60000) -- Allows two bleedrate ticks to pass
                        TriggerServerEvent('saline:server:stopBleed', playerId)
                        break
                    end
                end
            end)
            
            QBCore.Functions.Progressbar("hospital_healwounds", "Injecting saline....", 15000, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = healAnimDict,
                anim = healAnim,
                flags = 49,
            }, {}, {}, function() -- Done
                StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                QBCore.Functions.Notify("You healed someone!", 'success')
                TriggerServerEvent("stabs:server:HealPlayer", playerId)
                DeleteEntity(bag)
                healing = false
            end, function() -- Cancel
                StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                QBCore.Functions.Notify('Canceled...', "error")
                healing = false
                DeleteEntity(bag)
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

RegisterCommand("givesaline", function()
    TriggerServerEvent('giveItem')
end)
