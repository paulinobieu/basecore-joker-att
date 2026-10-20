-- ══════════════════════════════════════════════
--              CORE NETWORK LTDA
-- ══════════════════════════════════════════════
-- Todos os direitos reservados © Core Network Ltda.
--
-- ATENÇÃO: arquivo de configuração aberto para adaptação. NÃO altere nada
-- aqui se você não tem conhecimento de programação, mudanças incorretas
-- podem quebrar o funcionamento do sistema.
-- ══════════════════════════════════════════════

-- =============================================================================
-- ADAPTER (server)
-- =============================================================================
-- Camada de integração com sistemas externos ao redor da partida: anticheat
-- (PL_PROTECT), sistema de skins de arma (core-skins) e snapshot/restore do
-- estado do jogador (vida, armadura, posição, inventário) antes/depois de
-- entrar numa partida. Ponto de adaptação pra quem quiser plugar outro
-- anticheat, outro sistema de skins, ou mudar o que é salvo/restaurado.

adapter = {}

local isPlaying = {}
local weaponSkinsBySource = {}

--- Detecta o anticheat PL_PROTECT em runtime. Quando ativo, toda arma é
--- registrada/entregue pelos exports dele antes do fluxo padrão rodar — assim
--- o give do client passa a ser de arma já registrada no anticheat. Sem o
--- PL_PROTECT no servidor, apenas o fluxo padrão roda. Não precisa configurar
--- nada; se você usa outro anticheat, troque essa checagem e os
--- `exports["PL_PROTECT"]` abaixo pelos equivalentes dele.
local function plProtectActive()
    return GetResourceState("PL_PROTECT") == "started"
end

--- Verifica se o jogador pode entrar em uma partida (não está em outra
--- instância/bucket, não está morto). Adapte aqui se quiser bloquear entrada
--- por outros motivos (ex.: estar algemado, em um veículo, etc.).
---@param source number Source do jogador
---@return boolean allowed Retorna true se o jogador puder entrar na partida
function adapter.canJoin(source)
    if GetPlayerRoutingBucket(source) > 0 then
        return false
    end

    local playerPed = GetPlayerPed(source)
    local health = GetEntityHealth(playerPed)

    return health > 101
end

--- Tira um snapshot do jogador (vida, armadura, coords, bucket) e do
--- inventário (via vRP.SaveTemporary) antes de entrar na partida, pra
--- restaurar tudo depois em `adapter.applyPlayerInfos`. Também liga as
--- statebags `inCoreGameMatch`/`inCoreGameMatchId`/`inCoreGameMatchEconomic`,
--- que o client usa pra saber que está numa partida, e desliga o HUD de
--- outro resource (evento `hud:Active`) — ajuste esse evento se seu HUD
--- externo usa outro nome.
---@param userSource number
function adapter.savePlayerInfos(userSource, matchId, bucketId, economic)
    if not userSource then return end

    local ped = GetPlayerPed(userSource)
    local passport = vRP.Passport(userSource)
    local route = tonumber(bucketId)

    if not ped or ped == 0 or not passport or not route then return end

    Player(userSource).state:set('inCoreGameMatch', true, true)
    Player(userSource).state:set('inCoreGameMatchId', matchId, true)
    Player(userSource).state:set('inCoreGameMatchEconomic', economic == true, true)

    local playerData = {
        health = GetEntityHealth(ped),
        armour = GetPedArmour(ped),
        coords = GetEntityCoords(ped),
        bucket = GetPlayerRoutingBucket(userSource)
    }

    Player(userSource).state:set('temporaryDataCoreGame', playerData, true)
    local arenaState = "Arena:" .. route
    GlobalState[arenaState] = GlobalState[arenaState] or 0

    vRP.SaveTemporary(passport, userSource, {
        Route = route,
        Itens = {},
        Attachs = {},
        Ammos = {}
    })
    TriggerClientEvent("hud:Active", userSource, false)
end

--- Restaura o snapshot salvo em `adapter.savePlayerInfos` quando o jogador
--- sai da partida (fim de round, desconexão, saída de espectador).
---@param userSource number
function adapter.applyPlayerInfos(userSource)
    if not userSource then return end

    local ped = GetPlayerPed(userSource)
    if not ped or ped == 0 then return end

    local playerData = Player(userSource).state.temporaryDataCoreGame
    if not playerData then return end

    if playerData.bucket then
        SetPlayerRoutingBucket(userSource, playerData.bucket)
    end

    if playerData.coords then
        SetEntityCoords(
            ped,
            playerData.coords.x,
            playerData.coords.y,
            playerData.coords.z,
            false,
            false,
            false,
            false
        )
    end

    if playerData.health then
        clientAPI.setEntityHealth(userSource, playerData.health)
    end

    if playerData.armour then
        SetPedArmour(ped, playerData.armour)
    end

    Player(userSource).state:set('inCoreGameMatch', false, true)
    Player(userSource).state:set('temporaryDataCoreGame', nil, true)
    Player(userSource).state:set('inCoreGameMatchId', nil, true)
    Player(userSource).state:set('inCoreGameMatchEconomic', false, true)

    if plProtectActive() then
        exports["PL_PROTECT"]:removeWeapons(userSource)
    end

    weaponSkinsBySource[userSource] = nil

    clientAPI.removeAllWeapons(userSource)
    vRP.ApplyTemporary(vRP.Passport(userSource), userSource)
    TriggerClientEvent("hud:Active", userSource, true)
end

--- Entrega o loadout completo do round pro jogador. `weaponSkins` mapeia arma
--- base -> modelo skinado (ex.: WEAPON_CARBINERIFLE -> arma addon da skin
--- equipada); o modelo skinado é o que é fisicamente entregue ao ped. Com
--- PL_PROTECT ativo, as armas são registradas/entregues pelos exports do
--- anticheat antes do fluxo padrão (que monta hotbar, skins etc. no client).
---@param userSource number
---@param weaponList string[] Lista de armas base (ex.: "WEAPON_KNIFE") já resolvida pelo servidor
---@param weaponSkins table<string, string>|nil Mapa arma base -> modelo skinado (via adapter.getWeaponSkin)
function adapter.givePlayerWeapons(userSource, weaponList, weaponSkins)
    if not userSource then return end

    if plProtectActive() and weaponList and #weaponList > 0 then
        weaponSkinsBySource[userSource] = weaponSkins or {}

        local weapons = {}
        local inHand  = nil

        for i = 1, #weaponList do
            local weaponName = weaponList[i]
            local giveModel  = (weaponSkins and weaponSkins[weaponName]) or weaponName
            local ammoCount  = globalConfig.weaponCategories[weaponName] == "grenades" and 1 or 250

            if not inHand and weaponName ~= "WEAPON_KNIFE" then
                inHand = giveModel
            end

            weapons[GetHashKey(giveModel)] = { ammo = ammoCount, isHidden = false, bForceInHand = false }
        end

        inHand = inHand or (weaponSkins and weaponSkins["WEAPON_KNIFE"]) or "WEAPON_KNIFE"

        if weapons[GetHashKey(inHand)] then
            weapons[GetHashKey(inHand)].bForceInHand = true
        end

        exports["PL_PROTECT"]:removeWeapons(userSource)
        exports["PL_PROTECT"]:giveWeapons(userSource, weapons)
    end

    clientAPI.giveWeapons(userSource, weaponList, weaponSkins)
end

--- Entrega uma única arma (compra na loja / pegar arma do chão) direto na
--- mão do jogador. Com PL_PROTECT ativo, a arma é registrada/entregue pelo
--- export do anticheat antes do fluxo padrão.
---@param userSource number
---@param weaponName string Nome da arma base (ex.: "WEAPON_CARBINERIFLE")
---@param ammo number|nil Munição entregue junto (padrão 250)
---@param forceInHand boolean|nil Se a arma já deve vir equipada na mão
---@param skinWeapon string|nil Modelo skinado a ser entregue no lugar da base (via adapter.getWeaponSkin)
function adapter.givePlayerWeapon(userSource, weaponName, ammo, forceInHand, skinWeapon)
    if not userSource or not weaponName then return end

    if plProtectActive() then
        local skins = weaponSkinsBySource[userSource]

        if not skins then
            skins = {}
            weaponSkinsBySource[userSource] = skins
        end

        skins[weaponName] = skinWeapon or nil

        exports["PL_PROTECT"]:giveWeapons(userSource, {
            [GetHashKey(skinWeapon or weaponName)] = {
                ammo         = tonumber(ammo) or 250,
                isHidden     = false,
                bForceInHand = forceInHand ~= false
            }
        })
    end

    clientAPI.giveWeapon(userSource, weaponName, ammo, forceInHand, skinWeapon)
end

--- Remove uma única arma do jogador (venda na loja / troca de arma pesada).
--- Com PL_PROTECT ativo, remove também do registro do anticheat, resolvendo
--- o modelo skinado que foi fisicamente entregue.
---@param userSource number
---@param weaponName string
function adapter.removePlayerWeapon(userSource, weaponName)
    if not userSource or not weaponName then return end

    if plProtectActive() then
        local skins = weaponSkinsBySource[userSource]

        exports["PL_PROTECT"]:removeWeapons(userSource, GetHashKey((skins and skins[weaponName]) or weaponName))

        if skins then
            skins[weaponName] = nil
        end
    end

    clientAPI.removeWeapon(userSource, weaponName)
end

--- Retorna a skin equipada do jogador pra arma dada (integração com sistema
--- de skins). Sem o resource "core-skins" rodando, retorna nil e o jogador
--- simplesmente recebe a arma base. Adapte pra outro sistema de skins aqui.
---@param passport number Identificador do jogador
---@param weaponName string Nome da arma (ex.: "WEAPON_CARBINERIFLE")
---@return table|string|nil skin Skin equipada ou nil se não houver sistema de skins/skin equipada
function adapter.getWeaponSkin(passport, weaponName)
    if not passport or not weaponName then return nil end

    if GetResourceState("core-skins") ~= "started" then return nil end

    return exports["core-skins"]:GetWeaponSkin(passport, weaponName)
end

-- Os props de drop de arma e da bomba são criados pelo client; com
-- PL_PROTECT ativo, o model é registrado via setSpawnClient antes do spawn
-- client-side (senão o anticheat acusa spawn de objeto não autorizado).
local bombPropModel         = "ch_prop_ch_ld_bomb_01a"
local baseCreateMatchObject = clientAPI.createMatchObject

clientAPI.createMatchObject = function(userSource, objectData)
    if plProtectActive() and objectData then
        exports["PL_PROTECT"]:setSpawnClient(userSource, GetHashKey(objectData.model or bombPropModel))
    end

    return baseCreateMatchObject(userSource, objectData)
end

AddEventHandler("playerDropped", function()
    weaponSkinsBySource[source] = nil
end)

-- Export público pra outros resources (ex.: seu HUD, seu anticheat)
-- consultarem se o jogador está numa partida do Core Game agora.
exports("isPlayingGame", function(source)
    if not source then
        return false
    end

    if isPlaying[tostring(source)] == true then
        return true
    end

    return Player(source).state.inCoreGameMatch == true
end)
