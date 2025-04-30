local QBCore = exports['qb-core']:GetCoreObject()

-- Admin command
QBCore.Commands.Add("ataqueg", "Inicia ataque de gangue em um player", {{name="id", help="Player ID"},{name="gang", help="Nome da gang (opcional)"}}, true, function(source, args)
    local src = source
    local target = tonumber(args[1]) or src
    local gang = args[2] and args[2]:lower()

    -- permissões QBox/QBCore
    if exports.qbx_core:HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'admin') then
        -- escolhe gang aleatória se não informar ou inválida
        if not Config.Gangs[gang] then
            local keys = {}
            for k,_ in pairs(Config.Gangs) do table.insert(keys,k) end
            gang = keys[math.random(#keys)]
        end
        TriggerClientEvent('gangAttack:start', target, gang)
        if Config.Debug then
            print(("[gangAttack] Admin %d iniciou ataque %s em %d"):format(src, gang, target))
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = 'Sem permissão.'})
    end
end)

-- Expor evento público
RegisterNetEvent('gangAttack:start', function(gang)
    local src = source
    TriggerClientEvent('gangAttack:start', src, gang)
end)
