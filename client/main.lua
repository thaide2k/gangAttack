-- client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local isUnderAttack, lastAttack = false, 0
local spawnedPeds, spawnedVehs     = {}, {}

-- Estilo de notificação “pill” Neumorphism (definido em config.lua)
local NotifyStyle = Config.NotifyStyle

-- Função de log em debug
local function log(msg)
    if Config.Debug then
        print("[gangAttack] "..msg)
    end
end

-- Função unificada de notificação usando ox_lib.notify
local function sendNotify(type, title, desc)
    exports.ox_lib:notify({
        type        = type,
        title       = title,
        description = desc,
        position    = "topright",
        duration    = 5000,
        style       = NotifyStyle
    })
end

-- Indica quando o resource é carregado
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        log("Resource iniciado: "..resourceName)
    end
end)

-- Limpeza geral: deleta entidades criadas
local function cleanup()
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
            SetPedAsNoLongerNeeded(ped)
        end
    end
    for _, veh in ipairs(spawnedVehs) do
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
            SetVehicleAsNoLongerNeeded(veh)
        end
    end
    spawnedPeds, spawnedVehs = {}, {}
    isUnderAttack = false
    lastAttack = GetGameTimer()
    log("Limpeza finalizada.")
end

-- Monitoramento de término do evento
local function monitorTermination(targetPed, chaseVeh)
    local lostTimer, indoorTimer = 0, 0

    Citizen.CreateThread(function()
        while isUnderAttack do
            Citizen.Wait(1000)

            local px,py,pz = table.unpack(GetEntityCoords(targetPed))
            local cx,cy,cz = table.unpack(GetEntityCoords(chaseVeh))
            local dist = #(vector3(px,py,pz) - vector3(cx,cy,cz))

            -- Distância > limite?
            if dist > Config.Terminate.maxDistance then
                lostTimer = lostTimer + 1000
            else
                lostTimer = 0
            end

            -- Indoor ou água?
            local interiorId = GetInteriorFromEntity(targetPed)
            if IsEntityInWater(targetPed) or (interiorId and interiorId ~= 0) then
                indoorTimer = indoorTimer + 1000
            else
                indoorTimer = 0
            end

            -- Checa condições de fim
            if lostTimer >= Config.Terminate.distanceTimeout then
                log("Evento encerrado: perseguição perdida")
                sendNotify('warning', 'Perseguição perdida', 'Você despistou a gangue!')
                break
            end
            if indoorTimer >= Config.Terminate.indoorTimeout then
                log("Evento encerrado: player entrou em prédio/água")
                sendNotify('info', 'Você encontrou abrigo', 'Perseguição encerrada.')
                break
            end
            if IsEntityDead(targetPed) then
                log("Evento encerrado: player morreu")
                sendNotify('error', 'Você foi derrotado!', 'Perseguição encerrada.')
                break
            end

            -- Todos os NPCs mortos?
            local anyAlive = false
            for _, ped in ipairs(spawnedPeds) do
                if not IsEntityDead(ped) then
                    anyAlive = true
                    break
                end
            end
            if not anyAlive then
                log("Evento encerrado: NPCs derrotados")
                sendNotify('success', 'Inimigos derrotados', 'Parabéns! Você eliminou todos os inimigos.')
                break
            end
        end

        cleanup()
    end)
end

-- Busca e substitui veículo próximo (raio em Config.VehicleSearch)
local function replaceVehicle(coords, gangData)
    for i = 1, Config.VehicleSearch.tries do
        log(("Tentativa %d/%d de substituir veículo em raio %.1fm"):format(i, Config.VehicleSearch.tries, Config.VehicleSearch.radius))
        local veh = GetClosestVehicle(coords.x, coords.y, coords.z, Config.VehicleSearch.radius, 0, 70)
        if DoesEntityExist(veh) then
            log("Veículo encontrado, substituindo...")
            local vx,vy,vz   = table.unpack(GetEntityCoords(veh))
            local vHeading   = GetEntityHeading(veh)
            local modelHash  = GetHashKey(gangData.vehicles[math.random(#gangData.vehicles)])
            RequestModel(modelHash); while not HasModelLoaded(modelHash) do Wait(10) end

            local newVeh = CreateVehicle(modelHash, vx, vy, vz, vHeading, true, false)
            SetVehicleCustomPrimaryColour(newVeh, gangData.color.r, gangData.color.g, gangData.color.b)
            SetVehicleCustomSecondaryColour(newVeh, gangData.color.r, gangData.color.g, gangData.color.b)

            -- Performance: aceleração, torque, freio e grip
            SetVehicleEnginePowerMultiplier(newVeh, 50.0)
            SetVehicleEngineTorqueMultiplier(newVeh, 50.0)
            SetVehicleHandlingFloat(newVeh, "CHandlingData", "fBrakeForce",         1.0)
            SetVehicleHandlingFloat(newVeh, "CHandlingData", "fTractionCurveMax",    2.5)
            SetVehicleHandlingFloat(newVeh, "CHandlingData", "fTractionCurveMin",    2.0)
            SetVehicleHandlingFloat(newVeh, "CHandlingData", "fTractionCurveLateral", 25.0)

            table.insert(spawnedVehs, newVeh)
            DeleteEntity(veh)

            log(("Sucesso: veículo %s (netId %d) na tentativa %d"):format(gangData.name, VehToNet(newVeh), i))
            return newVeh
        else
            log("Nenhum veículo encontrado na tentativa "..i)
        end
        Citizen.Wait(Config.VehicleSearch.retryInterval)
    end

    log("Falha ao substituir veículo após todas as tentativas")
    sendNotify('error', 'Falha na substituição', 'Não foi possível encontrar veículo próximo.')
    return nil
end

-- Spawn de 2 NPCs e início da perseguição
local function spawnAndChase(targetPed, gangKey)
    log("Preparando NPCs para gangue: "..gangKey)
    local gangData = Config.Gangs[gangKey]
    local px,py,pz = table.unpack(GetEntityCoords(targetPed))

    local chaseVeh = replaceVehicle(vector3(px,py,pz), gangData)
    if not chaseVeh then return end

    for idx = 1, 2 do
        log("Spawnando NPC #"..idx)
        local mHash = GetHashKey(gangData.models[idx] or gangData.models[1])
        RequestModel(mHash); while not HasModelLoaded(mHash) do Wait(10) end

        local seat = (idx == 1) and -1 or 0
        local ped  = CreatePedInsideVehicle(chaseVeh, 4, mHash, seat, true, false)

        if idx == 1 then
            GiveWeaponToPed(ped, `WEAPON_UNARMED`, 255, true, true)
            SetDriverAggressiveness(ped, 100)
        else
            GiveWeaponToPed(ped, `WEAPON_PISTOL`,    255, true, true)
            Citizen.CreateThread(function()
                local shootRange = 30.0
                while DoesEntityExist(ped) and not IsEntityDead(ped) do
                    local d = #(GetEntityCoords(ped) - GetEntityCoords(targetPed))
                    if d <= shootRange then
                        TaskVehicleShootAtPed(ped, targetPed, 1000)
                        Wait(1000)
                    else
                        Wait(500)
                    end
                end
            end)
        end

        SetPedAsCop(ped, false)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAttributes(ped, 5, true)
        SetPedCombatAbility(ped, 2)
        SetPedCombatMovement(ped, 3)
        SetPedCombatRange(ped, 2)

        table.insert(spawnedPeds, ped)
    end

    log("Iniciando perseguição")
    TaskVehicleChase(spawnedPeds[1], targetPed)

    sendNotify('inform', 'Ação iniciada', ('A gangue %s está atrás de você!'):format(gangData.name))

    Citizen.CreateThread(function()
        for _, ped in ipairs(spawnedPeds) do
            local speech = gangData.audio[math.random(#gangData.audio)]
            PlayPedAmbientSpeechNative(ped, speech, "SPEECH_PARAMS_FORCE_SHOUTED")
            Wait(4000)
        end
    end)

    monitorTermination(targetPed, chaseVeh)
end

-- Evento público para iniciar o ataque
RegisterNetEvent('gangAttack:start', function(gangKey)
    log("Evento recebido: gangAttack:start -> "..gangKey)
    local ped, now = PlayerPedId(), GetGameTimer()
    if isUnderAttack then
        log("Já em ataque, ignorando")
        return
    end
    if (now - lastAttack) < (Config.Cooldown * 1000) then
        log("Em cooldown, ignorando")
        return
    end
    isUnderAttack = true
    spawnAndChase(ped, gangKey)
end)

-- Cleanup em crash/restart
AddEventHandler('onResourceStop', function(r)
    if r == GetCurrentResourceName() then
        cleanup()
    end
end)
