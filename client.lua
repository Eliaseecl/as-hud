local QBCore = nil
local ESX = nil
local idDead = false
if Config.FrameWork == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.FrameWork == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
end
print("FIX BY ELIASEECL")
local Loaded = false

if Config.FrameWork == "ESX" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded',function()
        lib.print.info("Hud Loaded")
        lib.notify({
            title = 'Bienvenido',
            description = 'Bienvenido a ELIASEECL SHOP',
            type = 'success'
        })
    Loaded = true
    end)

    AddEventHandler('esx:onPlayerSpawn', function(spawn)
        isDead = false
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        Loaded = false
    end)

    AddEventHandler('esx:onPlayerDeath', function(data)
        isDead = true
    end)
    

elseif Config.FrameWork == "QBCore" then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        lib.print.info("Hud Loaded")
        lib.notify({
            title = 'as-hud',
            description = 'Hud loaded',
            type = 'success'
        })
        Loaded = true
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        Loaded = false
    end)
end
RegisterCommand("tst", function()
    print("ok")
if Config.FrameWork == "QBCore" then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        lib.print.info("Hud Loaded")
        lib.notify({
            title = 'as-hud',
            description = 'Hud loaded',
            type = 'success'
        })
        Loaded = true
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        Loaded = false
    end)
else 
    Loaded = true
end
end)

 CreateThread(function()
    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)
end)

CreateThread(function()
    local time = 1000
    while true do 
        local vehicle = IsPedInAnyVehicle(PlayerPedId(), false)
        if not vehicle then
            DisplayRadar(false)
            SetRadarZoom(1100)
        else
            DisplayRadar(true)
        end
        Wait(time)
    end
end)


CreateThread(function()
    while true do
        if Loaded then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
           
            if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                local speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
                local  fuel = GetVehicleFuelLevel(vehicle)

                SendNUIMessage({
                    action = 'updateSpeedometer',
                    speed = speed,
                    fuel = fuel
                })
            else 
                SendNUIMessage({
                    action = 'hidespeed'
                })
            end

           
            local playerId = PlayerId()
            local isTalking = NetworkIsPlayerTalking(playerId)

            SendNUIMessage({
                action = 'updateTalkingStatus',
                isTalking = isTalking
            })

            local thirst = nil
            local hunger = nil
            if Config.FrameWork == "ESX" then
                TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                    if status then thirst = status.val / 10000 end
                end)
                TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                    if status then hunger = status.val / 10000 end
                end)
            elseif Config.FrameWork == "QBCore" then
                thirst = QBCore.Functions.GetPlayerData().metadata['thirst']
                hunger = QBCore.Functions.GetPlayerData().metadata['hunger']
            end
            
            local armor = GetPedArmour(cache.ped)
            local health = GetEntityHealth(cache.ped) - 100
            
            if isDead then
                armor = 0
                health = 0
            end
            
            
            SendNUIMessage({
                action = 'updateArmor',
                armor = armor
            })
            SendNUIMessage({
                action = "setBoxes",
                thirst = thirst,
                health = health,
                hunger = hunger,
                armor = armor
            })
        end
    Wait(200)
    end
end)
