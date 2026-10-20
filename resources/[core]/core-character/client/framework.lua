-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, skin, roupas, animações). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cores do Notify da base. A chave da esquerda é o que o resource usa; a da
-- direita é o que a sua hud entende.
local NotifyColors = {
    success = "verde",
    error   = "vermelho",
    warning = "amarelo",
    info    = "azul",
}

-- Pose do personagem enquanto uma tela está aberta. São dicionários do GTA
-- base, sem depender de nenhum resource de animação.
local Poses = {
    idle = { "mp_character_creation@customise@male_a", "loop" },
    t    = { "missfam5_yoga", "a2_pose" },
}

Framework = {
    -- Alguma tela do core-character ABRIU. Os três estados são os que a base
    -- consulta para não deixar abrir menu, comando ou inventário por cima.
    Open = function()
        TriggerEvent("hud:Active", false)

        LocalPlayer.state:set("Commands", true, true)
        LocalPlayer.state:set("Buttons", true, true)
        LocalPlayer.state:set("Cancel", true, true)
    end,

    -- Todas as telas FECHARAM.
    Close = function()
        TriggerEvent("hud:Active", true)

        LocalPlayer.state:set("Cancel", false, true)
        LocalPlayer.state:set("Buttons", false, true)
        LocalPlayer.state:set("Commands", false, true)
    end,

    Notify = function(message, severity)
        TriggerEvent("Notify", "Personagem", tostring(message or ""), NotifyColors[severity] or "azul", 5000)
    end,

    -- Troca o modelo do jogador. Precisa ser síncrono: o visual é aplicado
    -- logo em seguida e um ped antigo receberia os traços errados.
    ApplySkin = function(model)
        local hash = type(model) == "number" and model or GetHashKey(model)

        if IsModelInCdimage(hash) and IsModelValid(hash) then
            RequestModel(hash)

            local timeout = GetGameTimer() + 10000

            while not HasModelLoaded(hash) and GetGameTimer() < timeout do
                Wait(0)
            end

            if HasModelLoaded(hash) then
                SetPlayerModel(PlayerId(), hash)
                SetModelAsNoLongerNeeded(hash)
            end
        end

        exports.vrp:ReloadCharacter()
    end,

    -- Roupa e tatuagens vêm de outros resources; aqui só repassamos.
    ApplyClothes = function(clothes)
        TriggerEvent("core-customization:wearClothes", clothes)
    end,

    ResetClothes = function()
        TriggerEvent("core-customization:reloadClothes")
    end,

    ApplyTattoos = function(tattoos)
        TriggerEvent("core-customization:wearTattoos", tattoos)
    end,

    -- Só é chamada com Character.Features.Clothing ligado. A loja precisa
    -- devolver o jogador disparando "core-character:finishedClothing".
    OpenClothing = function()
        TriggerEvent("core-customization:openCreator")
    end,

    -- Pose do personagem no criador: "idle" em pé, "t" em T-pose.
    -- Idempotente de propósito: quem vigia a pose chama isto de segundo em
    -- segundo, e reenviar o TaskPlayAnim reiniciaria a animação na cara do
    -- jogador.
    PlayPose = function(pose)
        local entry = Poses[pose] or Poses.idle
        local ped = PlayerPedId()

        if IsEntityPlayingAnim(ped, entry[1], entry[2], 3) then return end

        RequestAnimDict(entry[1])

        local timeout = GetGameTimer() + 5000

        while not HasAnimDictLoaded(entry[1]) and GetGameTimer() < timeout do
            Wait(0)
        end

        if not HasAnimDictLoaded(entry[1]) then return end

        TaskPlayAnim(ped, entry[1], entry[2], 4.0, 4.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(entry[1])
    end,

    StopAnim = function()
        ClearPedTasks(PlayerPedId())
    end,

    -- Chamado quando o jogador entra no mundo, no fim de todo o fluxo.
    OnSpawned = function()
        TriggerEvent("core-character:loginReady")
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PONTO DE INTERAÇÃO DA BARBEARIA
    -- Chamado uma vez por ponto de config.lua. O corpo abaixo é autossuficiente
    -- (marcador + E), sem depender de nenhum resource de interação: troque pelo
    -- seu se tiver um.
    -------------------------------------------------------------------------------------------------------------------------------------
    CreateBarberPoint = function(coords, label, onSelect)
        CreateThread(function()
            while true do
                local sleep = 1000
                local distance = #(GetEntityCoords(PlayerPedId()) - coords)

                if distance <= Character.BarberDistance + 8.0 then
                    sleep = 0

                    DrawMarker(27, coords.x, coords.y, coords.z - 0.95, 0, 0, 0, 0, 0, 0,
                        1.0, 1.0, 1.0, 255, 255, 255, 150, false, false, 0, true)

                    if distance <= Character.BarberDistance then
                        BeginTextCommandDisplayHelp("STRING")
                        AddTextComponentSubstringPlayerName("~INPUT_CONTEXT~ " .. label)
                        EndTextCommandDisplayHelp(0, false, true, -1)

                        if IsControlJustReleased(0, 38) then
                            onSelect()
                        end
                    end
                end

                Wait(sleep)
            end
        end)
    end,
}
