fx_version 'cerulean'
game 'gta5'

author 'ThaiDe'
description 'Evento de ataque dinâmico de gangues com QBCore/QBox + ox_lib'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-core',
    'qbx_core',
    'ox_lib'
}
