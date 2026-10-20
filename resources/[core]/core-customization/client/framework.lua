-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, animações, interação). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cores do Notify da base. A chave da esquerda é o que o resource usa; a da
-- direita é o que a sua hud entende.
local NotifyColors = {
    success = "verde",
    error   = "vermelho",
    warning = "amarelo",
    info    = "azul",
}

-- A pose normal fica sem animação para o ped usar o idle natural do jogo.
-- Somente a T-pose precisa de um dicionário de animação.
local Poses = {
    t    = { "missfam5_yoga", "a2_pose" },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIMDICT
-----------------------------------------------------------------------------------------------------------------------------------------
local function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end

    RequestAnimDict(dict)

    local timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(0)
    end

    return HasAnimDictLoaded(dict)
end

Framework = {
    -- Uma loja do core-customization ABRIU. Os três estados são os que a base
    -- consulta para não deixar abrir menu, comando ou inventário por cima.
    Open = function()
        TriggerEvent("hud:Active", false)

        LocalPlayer.state:set("Commands", true, true)
        LocalPlayer.state:set("Buttons", true, true)
        LocalPlayer.state:set("Cancel", true, true)
    end,

    -- A loja FECHOU.
    Close = function()
        TriggerEvent("hud:Active", true)

        LocalPlayer.state:set("Cancel", false, true)
        LocalPlayer.state:set("Buttons", false, true)
        LocalPlayer.state:set("Commands", false, true)
    end,

    Notify = function(message, severity)
        TriggerEvent("Notify", "Aparência", tostring(message or ""), NotifyColors[severity] or "azul", 5000)
    end,

    -- "idle" limpa qualquer pose herdada do criador e deixa o ped parado de
    -- forma natural. "t" ativa a pose usada para inspecionar as roupas.
    PlayPose = function(pose)
        local ped = PlayerPedId()

        if pose ~= "t" then
            ClearPedTasks(ped)
            return
        end

        local entry = Poses.t

        if IsEntityPlayingAnim(ped, entry[1], entry[2], 3) then return end
        if not LoadAnimDict(entry[1]) then return end

        TaskPlayAnim(ped, entry[1], entry[2], 4.0, 4.0, -1, 1, 0, false, false, false)
        RemoveAnimDict(entry[1])
    end,

    -- Animação de vestir/tirar uma peça: { dicionário, animação }.
    PlayAnim = function(anim)
        if not LoadAnimDict(anim[1]) then return end

        TaskPlayAnim(PlayerPedId(), anim[1], anim[2], 4.0, 4.0, -1, 48, 0, false, false, false)
        RemoveAnimDict(anim[1])
    end,

    StopAnim = function()
        ClearPedTasks(PlayerPedId())
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PONTOS DE INTERAÇÃO
    -- Chamado uma vez por ponto de config.lua e sempre que outro resource
    -- acrescentar um em runtime. O corpo abaixo é autossuficiente (marcador +
    -- E), sem depender de nenhum resource de interação: troque pelo seu se
    -- tiver um.
    -------------------------------------------------------------------------------------------------------------------------------------
    CreateShopPoint = function(coords, label, onSelect)
        local position = vector3(coords[1], coords[2], coords[3])

        CreateThread(function()
            while true do
                local sleep = 1000
                local distance = #(GetEntityCoords(PlayerPedId()) - position)

                if distance <= Customization.ShopDistance + 8.0 then
                    sleep = 0

                    DrawMarker(27, position.x, position.y, position.z - 0.95, 0, 0, 0, 0, 0, 0,
                        1.0, 1.0, 1.0, 255, 255, 255, 150, false, false, 0, true)

                    if distance <= Customization.ShopDistance then
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
