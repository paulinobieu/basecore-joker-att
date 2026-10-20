--[[ ===========================================================================
    core-laundry · client-side/thread.lua

    Este arquivo cuida de COMO o jogador abre a lavagem ao chegar numa máquina.
    Ele foi feito para ser fácil de adaptar: basta mexer no bloco CONFIGURAÇÃO
    logo abaixo. Você NÃO precisa entender o resto do arquivo para trocar o modo.

    ┌─ COMO ADAPTAR (resumo) ──────────────────────────────────────────────────┐
    │ 1) Quer usar TARGET (olhar + tecla, via sleepless_interact)?             │
    │    → Config.Interaction = "target"   (é o padrão)                        │
    │                                                                          │
    │ 2) Prefere um MARCADOR no chão + tecla?                                  │
    │    → Config.Interaction = "marker"                                       │
    │                                                                          │
    │ 3) Usa outro target (ex: ox_target)?                                     │
    │    → mantenha "target" e troque as linhas dentro de CreateInteraction /  │
    │      DestroyInteraction (há um exemplo comentado logo abaixo delas).     │
    └──────────────────────────────────────────────────────────────────────────┘

    Não importa o modo escolhido, no final tudo chama LaundryBridge.Open(id)
    para abrir o painel — então você só troca a "porta de entrada", nunca o miolo.
=========================================================================== ]]

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÃO  ← mexa só aqui para adaptar a interação
-----------------------------------------------------------------------------------------------------------------------------------------
local Config = {

    -- Modo de interação com a máquina:
    --   "target" → usa sleepless_interact (mira na máquina e aperta a tecla). PADRÃO.
    --   "marker" → desenha um marcador no chão e abre ao apertar a tecla perto.
    Interaction = "target",

    -- Opções usadas SOMENTE quando Interaction = "target"
    Target = {
        label    = "Abrir Lavagem",   -- texto mostrado na interação
        icon     = "money-bill-wave", -- ícone (Font Awesome) mostrado na interação
        distance = 2.0,               -- distância máxima (metros) para poder interagir
    },

    -- Opções usadas SOMENTE quando Interaction = "marker"
    Marker = {
        drawDistance     = 15.0,      -- a partir de quantos metros o marcador aparece
        interactDistance = 1.5,       -- distância (metros) para poder apertar a tecla
        key              = 38,        -- tecla de interação (38 = E). Lista de teclas: docs.fivem.net/docs/game-references/controls
        markerType       = 27,        -- tipo do marcador (27 = anel no chão). Tipos: docs.fivem.net/docs/game-references/markers
        size             = { x = 1.2, y = 1.2, z = 0.5 }, -- tamanho do marcador
        color            = { r = 1, g = 67, b = 187, a = 150 }, -- cor do marcador (RGBA, 0-255)
        helpText         = "[E] Abrir Lavagem", -- texto flutuante mostrado quando está perto
    },

    -- Fecha o painel automaticamente se o jogador se afastar mais que isto (metros).
    -- Vale para qualquer modo de interação.
    AutoCloseDistance = 4.0,
}
-----------------------------------------------------------------------------------------------------------------------------------------

-- Prefixo usado para nomear cada ponto de interação (não precisa mexer)
local InteractionPrefix = "core_laundry_"

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEIS INTERNAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Guarda os pontos de target ativos por máquina, para conseguir removê-los depois.
-- (No modo "marker" isto fica vazio, pois o marcador é desenhado direto pela thread.)
local ActiveInteractions = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------

-- Ponto exato onde o TARGET fica. Se a máquina tem objeto (prop), sobe 1.0 no Z
-- para o ponto ficar na altura do corpo da máquina, não no chão.
local function MachineInteractPoint(laundry)
    local coords  = laundry.Machine.Coords
    local zOffset = laundry.Machine.Object and 1.0 or 0.0
    return vec3(coords.x + 0.0, coords.y + 0.0, coords.z + zOffset)
end

-- Coordenada da base da máquina (no chão). Usada pelo MARCADOR.
local function MachineBaseCoords(laundry)
    local coords = laundry.Machine.Coords
    return vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
end

-- Desenha um texto 3D flutuante no mundo (usado pelo modo "marker").
local function Draw3DText(x, y, z, text)
    SetDrawOrigin(x, y, z, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MODO "TARGET"  (sleepless_interact)
-----------------------------------------------------------------------------------------------------------------------------------------

-- Cria UM ponto de target na máquina. Retorna um "handle" para removê-lo depois.
local function CreateInteraction(machineId, name, coords, laundry, open, isOpen)
    return exports.sleepless_interact:addCoords(coords, {
        name        = name,
        label       = Config.Target.label,
        icon        = Config.Target.icon,
        distance    = Config.Target.distance,
        onSelect    = function() open() end,                 -- abre a lavagem ao selecionar
        canInteract = function(entity, distance) return not isOpen() end, -- não deixa interagir com o painel já aberto
    })

    --[[ EXEMPLO — usando ox_target no lugar do sleepless_interact:
        return exports.ox_target:addSphereZone({
            coords = coords,
            radius = Config.Target.distance,
            options = {
                {
                    name    = name,
                    label   = Config.Target.label,
                    icon    = "fas fa-money-bill-wave",
                    onSelect = function() open() end,
                    canInteract = function() return not isOpen() end,
                },
            },
        })
        -- (e no DestroyInteraction troque para: exports.ox_target:removeZone(handle))
    ]]
end

-- Remove um ponto de target criado pelo CreateInteraction.
local function DestroyInteraction(machineId, name, handle)
    exports.sleepless_interact:removeCoords(handle, name)
    -- ox_target: exports.ox_target:removeZone(handle)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTRO / REMOÇÃO  (chamados pelo core.lua sempre que a lista de máquinas muda)
-----------------------------------------------------------------------------------------------------------------------------------------

-- Remove todos os pontos de interação ativos.
function RemoveInteractions()
    for machineId, entry in pairs(ActiveInteractions) do
        pcall(DestroyInteraction, machineId, entry.name, entry.handle)
        ActiveInteractions[machineId] = nil
    end
end

-- Recria os pontos de interação de todas as máquinas.
function RegisterInteractions()
    RemoveInteractions() -- limpa os antigos antes de recriar

    -- No modo "marker" não há pontos de target para registrar: o marcador é
    -- desenhado direto pela thread mais abaixo, que lê Laundry.Laundries em tempo real.
    if Config.Interaction ~= "target" then return end

    for machineId, laundry in pairs(Laundry.Laundries) do
        local name   = InteractionPrefix .. tostring(machineId)
        local coords = MachineInteractPoint(laundry)

        -- pcall para uma máquina com dados inválidos não derrubar as outras
        local ok, handle = pcall(
            CreateInteraction,
            machineId,
            name,
            coords,
            laundry,
            function() LaundryBridge.Open(machineId) end,   -- o que fazer ao interagir
            function() return LaundryBridge.IsOpen() end     -- se o painel já está aberto
        )

        if ok then
            ActiveInteractions[machineId] = { name = name, handle = handle }
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MODO "MARKER"  (marcador no chão + tecla)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Esta thread só faz algo quando Config.Interaction == "marker".
-- Ela percorre as máquinas, desenha o marcador quando o jogador está perto e
-- abre a lavagem ao apertar a tecla configurada.
CreateThread(function()
    while true do
        local sleep = 1000 -- quando não há nada perto, dorme 1s para economizar CPU

        if Config.Interaction == "marker" and not LaundryBridge.IsOpen() then
            local playerCoords = GetEntityCoords(PlayerPedId())

            for machineId, laundry in pairs(Laundry.Laundries) do
                if laundry.Machine and laundry.Machine.Coords then
                    local point = MachineBaseCoords(laundry)
                    local dist  = #(playerCoords - point)

                    -- Só desenha (e roda a cada frame) se estiver dentro da distância de exibição
                    if dist < Config.Marker.drawDistance then
                        sleep = 0 -- perto de uma máquina → roda todo frame para o marcador ficar suave

                        local m = Config.Marker
                        DrawMarker(
                            m.markerType,
                            point.x, point.y, point.z,   -- posição
                            0.0, 0.0, 0.0,               -- direção
                            0.0, 0.0, 0.0,               -- rotação
                            m.size.x, m.size.y, m.size.z, -- tamanho
                            m.color.r, m.color.g, m.color.b, m.color.a, -- cor
                            false, false, 2, false, nil, nil, false
                        )

                        -- Dentro da distância de interação: mostra o texto e escuta a tecla
                        if dist <= Config.Marker.interactDistance then
                            Draw3DText(point.x, point.y, point.z + 1.0, Config.Marker.helpText)

                            if IsControlJustPressed(0, Config.Marker.key) then
                                LaundryBridge.Open(machineId)
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FECHAMENTO AUTOMÁTICO  (vale para qualquer modo)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Se o painel estiver aberto e o jogador se afastar da máquina, fecha sozinho.
CreateThread(function()
    while true do
        local sleep = 1000

        if LaundryBridge.IsOpen() and LaundryBridge.OpenedId() then
            local laundry = Laundry.Laundries[LaundryBridge.OpenedId()]

            if laundry and laundry.Machine and laundry.Machine.Coords then
                local coords   = laundry.Machine.Coords
                local distance = #(GetEntityCoords(PlayerPedId()) - vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0))

                -- Longe demais → fecha o painel (o "true" avisa o jogador)
                if distance > Config.AutoCloseDistance then
                    LaundryBridge.Close(true)
                end
            end
        end

        Wait(sleep)
    end
end)
