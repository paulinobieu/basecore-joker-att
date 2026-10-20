-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP por padrão). Adapte só o CORPO das funções.
--
-- Este resource não tem tabela nem SQL: roupa e tatuagem são do personagem, e
-- quem guarda o personagem é o core-character. LoadOutfit e SaveOutfit são a
-- porta — troque o corpo delas para apontar para outro resource de personagem.
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
local Tunnel = module("vrp", "lib/Tunnel")

vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")

local NotifyColors = {
    success = "verde",
    error   = "vermelho",
    warning = "amarelo",
    info    = "azul",
}

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    UserId = function(source)
        return source and vRP.Passport(source) or nil
    end,

    Source = function(userId)
        return vRP.Source(userId)
    end,

    UserName = function(userId)
        local id = vRP.Identity(userId)
        return id and (id.Name .. " " .. id.Lastname) or nil
    end,

    -- Modelo vestido pelo jogador ("mp_m_freemode_01"/"mp_f_freemode_01").
    -- Decide qual catálogo de roupa e de tatuagem vale para ele.
    Model = function(source)
        return vRP.ModelPlayer(source)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERMISSÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    HasGroup = function(userId, group, level)
        local r = vRP.HasGroup(userId, group, level or 1)
        return r == true or (type(r) == "number" and r >= 1)
    end,

    -- Está DE SERVIÇO na polícia ou no resgate? É o que libera tirar props de
    -- um jogador caído. Ter o grupo não basta: HasService exige o serviço
    -- aberto, ao contrário de HasPermission.
    HasService = function(userId)
        return vRP.HasService(userId, "Policia")
            or vRP.HasService(userId, "Paramedico")
            or vRP.HasService(userId, "Emergencia")
    end,

    -- O jogador pode mexer na aparência agora? Falso algemado, preso,
    -- procurado ou em coma.
    CanCustomize = function(source, userId)
        if Player(source).state.Handcuff then return false end
        if Player(source).state.Prison then return false end

        if GetResourceState("hud") == "started" and exports.hud:Wanted(userId) then
            return false
        end

        return Framework.Health(source) > 100
    end,

    -- Grupo que dispensa o item dos comandos de peça e libera o comando de
    -- loja de qualquer lugar. Vazio em config = ninguém passa por aqui.
    HasPremium = function(userId)
        local group = Customization.PremiumGroup

        if not group or group == "" then return false end

        return Framework.HasGroup(userId, group)
    end,

    -- Quantidade do item na mochila. Usado só pelos comandos de peça.
    ItemAmount = function(userId, item)
        return vRP.ItemAmount(userId, item) or 0
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -- O Notify da base recebe (Título, Mensagem, Cor, Tempo). A cor é uma
    -- chave de hudConfig.anuncios, não uma severidade: a tradução é logo
    -- abaixo, e é ela que você troca se a sua base falar outra língua.
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(source, message, severity)
        if not source then return end

        local color = NotifyColors[severity] or "azul"

        TriggerClientEvent("Notify", source, "Aparência", tostring(message or ""), color, 5000)
    end,

    -- Entrega um texto longo demais para caber num Notify. Vai para o chat,
    -- onde o admin consegue ler e copiar à mão.
    SendText = function(source, title, content)
        TriggerClientEvent("chat:ClientMessage", source, title, content)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -- Só usado com Customization.Storage.Mode = "table". No modo padrão o
    -- resource não toca em SQL nenhum.
    -------------------------------------------------------------------------------------------------------------------------------------
    Query = function(query, params)
        return MySQL.query.await(query, params or {})
    end,

    Update = function(query, params)
        return MySQL.update.await(query, params or {})
    end,

    Single = function(query, params)
        return MySQL.single.await(query, params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ROUPA E TATUAGEM DO PERSONAGEM
    -- As duas únicas portas de gravação. Qual delas vale vem do
    -- Customization.Storage.Mode:
    --
    --   "character" → o resource de personagem guarda (padrão)
    --   "table"     → a tabela deste resource, logo abaixo
    --
    -- Grava em outro lugar? Troque o corpo destas duas. Enquanto elas
    -- devolverem e aceitarem o mesmo formato, o resto do resource não muda.
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Devolve { clothes = {...}, tattoos = {...} }. Qualquer uma pode vir nil:
    -- quem chamou preenche com o padrão de config/clothes.lua.
    LoadOutfit = function(userId)
        if Customization.Storage.Mode == "table" then
            return StorageLoad(userId)
        end

        if GetResourceState("core-character") ~= "started" then return nil end

        return exports["core-character"]:GetOutfit(userId)
    end,

    -- `nil` numa das duas mantém o que já estava gravado.
    SaveOutfit = function(userId, clothes, tattoos)
        if Customization.Storage.Mode == "table" then
            return StorageSave(userId, clothes, tattoos)
        end

        if GetResourceState("core-character") ~= "started" then return false end

        return exports["core-character"]:SetOutfit(userId, clothes, tattoos)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- JOGADOR PRÓXIMO
    -- Usado para tirar props de quem está caído. Devolve o source do alvo, não
    -- o Passport: quem chama manda um evento de client direto para ele.
    -------------------------------------------------------------------------------------------------------------------------------------
    NearestPlayer = function(source, distance)
        local target = vRPC.ClosestPed(source, distance or 2)

        return target and target ~= false and target or nil
    end,

    Health = function(source)
        return vRP.GetHealth(source) or 0
    end,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TABELA PRÓPRIA
-- Só entra em cena com Customization.Storage.Mode = "table". Existe para quem
-- não usa o core-character: o resource passa a guardar sozinho, sem depender
-- de nenhum outro.
--
-- Os nomes de tabela e de coluna são os de Customization.Storage, então dá
-- para apontar para a tabela que o SEU criador de personagem já lê, desde que
-- as colunas de roupa e tatuagem guardem JSON no formato daqui.
-----------------------------------------------------------------------------------------------------------------------------------------
local Storage = Customization.Storage
local Columns = Storage.Columns
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORAGEDECODE
-----------------------------------------------------------------------------------------------------------------------------------------
-- A coluna é TEXT e pode chegar vazia ou corrompida por edição manual; um
-- decode que estoura tiraria a roupa do jogador ao entrar.
local function StorageDecode(raw)
    if type(raw) ~= "string" or raw == "" then return nil end

    local ok, parsed = pcall(json.decode, raw)
    if not ok or type(parsed) ~= "table" then return nil end

    return parsed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORAGELOAD
-----------------------------------------------------------------------------------------------------------------------------------------
function StorageLoad(userId)
    local row = Framework.Single(
        ("SELECT `%s`, `%s` FROM `%s` WHERE `%s` = ?")
            :format(Columns.Clothes, Columns.Tattoos, Storage.Table, Columns.Passport),
        { tostring(userId) }
    )

    if not row then return nil end

    return {
        clothes = StorageDecode(row[Columns.Clothes]),
        tattoos = StorageDecode(row[Columns.Tattoos]),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORAGESAVE
-----------------------------------------------------------------------------------------------------------------------------------------
-- Upsert: quem nunca passou por uma loja não tem linha, e a primeira gravação
-- precisa criá-la. `nil` numa das duas mantém o que já estava.
function StorageSave(userId, clothes, tattoos)
    if clothes == nil and tattoos == nil then return false end

    local current = StorageLoad(userId) or {}

    Framework.Update(([[
        INSERT INTO `%s` (`%s`,`%s`,`%s`) VALUES (?,?,?)
        ON DUPLICATE KEY UPDATE `%s` = VALUES(`%s`), `%s` = VALUES(`%s`)
    ]]):format(
        Storage.Table, Columns.Passport, Columns.Clothes, Columns.Tattoos,
        Columns.Clothes, Columns.Clothes, Columns.Tattoos, Columns.Tattoos
    ), {
        tostring(userId),
        json.encode(clothes ~= nil and clothes or current.clothes or {}),
        json.encode(tattoos ~= nil and tattoos or current.tattoos or {}),
    })

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORAGE
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cria a tabela no primeiro start. Aponte Customization.Storage para uma
-- tabela que já existe e o CREATE não faz nada.
CreateThread(function()
    if Storage.Mode ~= "table" then return end

    Framework.Query(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `%s` VARCHAR(255) NOT NULL,
            `%s` TEXT NOT NULL,
            `%s` TEXT NOT NULL,
            PRIMARY KEY (`id`) USING BTREE,
            UNIQUE KEY `unique_passport` (`%s`) USING BTREE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]]):format(
        Storage.Table, Columns.Passport, Columns.Clothes, Columns.Tattoos, Columns.Passport
    ))
end)
