-- Configurações gerais e definição de gangs
Config = {}
Config.Debug = true   -- true para logs e notificações extras
Config.Cooldown = 1   -- segundos de cooldown por player (ajuste em produção)

-- Parâmetros de busca de veículo
Config.VehicleSearch = {
    radius        = 30.0,  -- metros
    tries         = 5,
    retryInterval = 5000,  -- ms
}

-- Parâmetros de término do evento
Config.Terminate = {
    maxDistance     = 50.0,   -- m
    distanceTimeout = 25000,  -- ms em dist > maxDistance
    indoorTimeout   = 10000,  -- ms em prédio/água
}

-- ---------------------------------------------------------------------
-- Estilo de Notificações (ox_lib.notify) inspirado no seu exemplo:
-- fundo claro, borda arredondada “pill”, sombras externas suaves 
-- (Neumorphism light) e texto escuro para contraste.
-- ---------------------------------------------------------------------
Config.NotifyStyle = {
    backgroundColor  = '#F0F0F3',                                      -- fundo muito claro
    borderRadius     = '24px',                                         -- formato “pill”
    boxShadow        = '9px 9px 16px #D1D9E6, -9px -9px 16px #FFFFFF',  -- sombra dupla suave

    -- Título (opcional em bold)
    ['.title'] = {
      color    = '#333333',
      fontSize = '22px',
      fontWeight = '600'
    },

    -- Descrição (cor mais suave)
    ['.description'] = {
      color    = '#555555',
      fontSize = '18px'
    }
}

-- Definição das gangues
Config.Gangs = {
    ballas = {
        name     = "Ballas",
        models   = {'g_m_y_ballaeast_01'},
        vehicles = {'sultan','peyote','buccaneer'},
        color    = {r=108,g=30,b=140},
        audio    = {'BALLAS_OFFENSE','BALLAS_INSULT','GENERIC_INSULT_HIGH','GENERIC_FUCK_YOU'},
    },
    families = {
        name     = "Families",
        models   = {'g_m_y_famca_01'},
        vehicles = {'buccaneer','chino','manana'},
        color    = {r=45,g=143,b=58},
        audio    = {'FAMILY_1_INSULT','FAMILY_5_THREAT','GENERIC_SHOUT_ANGER'},
    },
    vagos = {
        name     = "Vagos",
        models   = {'g_m_y_mexgang_01'},
        vehicles = {'emperor','tornado','peyote'},
        color    = {r=255,g=215,b=0},
        audio    = {'VAGOS_TAUNT','VAGOS_THREAT','SPANISH_INSULTS'},
    },
    lost = {
        name     = "Lost MC",
        models   = {'g_m_y_lost_01'},
        vehicles = {'daemon','hexer','zombiechopper'},
        color    = {r=0,g=0,b=0},
        audio    = {'LOST_OFFENSE','LOST_INSULT','GENERIC_MOTO_THREAT'},
    },
    marabunta = {
        name     = "Marabunta Grande",
        models   = {'g_m_y_salvaboss_01'},
        vehicles = {'emperor','peyote'},
        color    = {r=139,g=0,b=0},
        audio    = {'MARA_TAUNT','SPANISH_SHOUTS'},
    },
}
