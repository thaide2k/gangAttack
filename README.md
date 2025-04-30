# gangAttack

**Versão:** 1.0.0  
**Autor:** ThaiDe  thaide_

## Descrição  
Evento dinâmico de ataque de gangues para FiveM (GTA V), usando QBCore/QBox e ox_lib, que:

- **Substitui veículos** próximos ao jogador por modelos temáticos de gangue  
- **Spawna 2 NPCs** (motorista + passageiro armado) dentro do veículo  
- **Inicia perseguição** usando `TaskVehicleChase`, mesmo se o player trocar de veículo  
- **Personaliza performance** dos veículos (engine power, torque, freios, grip)  
- **Notifica** início e fim da ação com estilo Neumorphism no ox_lib  
- **Monitora condições de término** (distância, indoor/água, morte)  
- **Admin command** `/ataqueg [id] [gang]` para disparo manual (permissões QBox/QBCore)  
- **Debug logs** completos e cleanup automático em crash ou restart  

## Instalação

1. Copie a pasta `gangAttack` para `resources/[local]/gangAttack`  
2. No `server.cfg`, adicione:  

ensure gangAttack

3. Ajuste o `config.lua` conforme suas preferências e reinicie o recurso.

## Configurações em `config.lua`

- **Config.Debug**: `true` para ver logs detalhados  
- **Config.Cooldown**: tempo (s) de cooldown por player  
- **Config.VehicleSearch**  
- `radius`: raio de busca (m)  
- `tries`: tentativas de substituir veículo  
- `retryInterval`: intervalo (ms) entre tentativas  
- **Config.Terminate**  
- `maxDistance`: distância máxima (m) antes de “perseguição perdida”  
- `distanceTimeout` / `indoorTimeout`: tempos (ms) para encerrar  
- **Config.NotifyStyle**: estilo Neumorphism para notifications  
- **Config.Gangs**: defina cada gangue com `models`, `vehicles`, `color`, `audio`

## Uso

### Comando admin

/ataqueg [playerID] [gang]

- `playerID`: ID do jogador alvo  
- `gang`: chave de gang (ex.: `ballas`, `families`, `vagos`, `lost`, `marabunta`)  
- Caso não informado ou inválido, escolhe aleatoriamente

### Evento público
```lua
TriggerEvent('gangAttack:start', 'ballas')

Estrutura de arquivos


gangAttack/
├─ fxmanifest.lua
├─ config.lua
├─ client/
│  └─ main.lua
└─ server/
   └─ main.lua

