-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP por padrão). É o ÚNICO arquivo do
-- server que fala com o vRP direto: os módulos só chamam Framework.xxx().
-- Pra adaptar o core-skins a outro framework, reescreva só o CORPO das funções
-- abaixo, mantendo os mesmos nomes, parâmetros e tipos de retorno.
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Source do jogador → identificador único do personagem (passport/user_id).
    -- O core-skins trata esse valor como OPACO: nunca converte, só repassa e usa
    -- como chave. Devolva sempre a mesma representação que a sua base usa (pode
    -- ser número, texto, citizenid...) e tudo continua batendo — inclusive um
    -- passaporte digitado num comando, que o core resolve juntando Source e
    -- Passport (ResolvePassport, em server/modules/common.lua).
    Passport = function(source)
        return source and vRP.Passport(source) or nil
    end,

    -- O inverso: passport → source, se o jogador estiver online.
    Source = function(passport)
        return vRP.Source(passport)
    end,

    -- Identidade civil do personagem, ou false. Os campos lidos pelo core-skins
    -- são Name, Lastname e License.
    Identity = function(passport)
        return vRP.Identity(passport) or false
    end,

    -- URL do avatar do jogador (foto do Instagram in-game), ou "". Integração
    -- opcional: retorne "" se o seu servidor não tem esse sistema.
    Avatar = function(passport)
        if not passport then return "" end

        local ok, rows = pcall(function()
            return Framework.Query("SELECT avatarURL FROM smartphone_instagram WHERE user_id = ? LIMIT 1", { passport })
        end)

        if ok and type(rows) == "table" and rows[1] and type(rows[1].avatarURL) == "string" then
            return rows[1].avatarURL
        end

        return ""
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERMISSÕES
    -- A permissão pode ser uma lista (basta ter uma delas), "grupo@nível"
    -- (ex: "Admin@1") ou só o nome de uma permissão/grupo.
    -------------------------------------------------------------------------------------------------------------------------------------
    HasPermission = function(passport, permission)
        if not passport then return false end
        if not permission then return true end

        if type(permission) == "table" then
            return vRP.HasTable(passport, permission) and true or false
        end

        local group, level = permission:match("^(.+)@(%d+)$")
        if group then
            return vRP.HasGroup(passport, group, tonumber(level)) and true or false
        end

        return (vRP.HasPermission(passport, permission) or vRP.HasGroup(passport, permission, 1)) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA
    -- A base avisa quando o personagem entra e sai da cidade. O core-skins usa
    -- a entrada pra devolver as skins equipadas e a saída pra limpar os caches.
    -- Assinaturas da base: Connect(passport, source, first) e
    -- Disconnect(passport, source, license).
    -------------------------------------------------------------------------------------------------------------------------------------
    OnConnect = function(handler)
        AddEventHandler("Connect", handler)
    end,

    OnDisconnect = function(handler)
        AddEventHandler("Disconnect", handler)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -- kind: "verde" (sucesso), "vermelho" (erro), "amarelo" (aviso).
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(source, message, kind)
        if not source or source <= 0 then return end
        TriggerClientEvent("Notify", source, "Skins", tostring(message or ""), kind or "amarelo", 5000)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Executa a função assim que o banco estiver pronto.
    DatabaseReady = function(callback)
        if MySQL and MySQL.ready then
            return MySQL.ready(callback)
        end
        CreateThread(callback)
    end,

    Query = function(query, params)
        params = params or {}

        if MySQL and MySQL.query and MySQL.query.await then
            return MySQL.query.await(query, params)
        end

        return exports.oxmysql:query_async(query, params)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PLAYERDATA
    -- Dados persistentes por personagem: SkinsCoins, vouchers e caixas diárias.
    -------------------------------------------------------------------------------------------------------------------------------------
    GetUserData = function(passport, key)
        return vRP.UserData(passport, key)
    end,

    SetUserData = function(passport, key, value)
        vRP.Query("playerdata/SetData", {
            Passport = passport,
            Name = key,
            Information = json.encode(value),
        })
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- MOEDA PREMIUM (Gemstone do vRP)
    -- Usada quando Skins.Economy.UseFrameworkCoins = true, no lugar do
    -- SkinsCoins interno. Já pronta pro Gemstone do vRP.
    -------------------------------------------------------------------------------------------------------------------------------------
    Coins = {
        Get = function(passport)
            local identity = vRP.Identity(passport)
            if not identity then return 0 end
            return tonumber(vRP.UserGemstone(identity.License)) or 0
        end,

        Give = function(passport, amount)
            amount = math.floor(tonumber(amount) or 0)
            if amount <= 0 then return false end

            vRP.UpgradeGemstone(passport, amount)
            return true
        end,

        Remove = function(passport, amount)
            amount = math.floor(tonumber(amount) or 0)
            if amount <= 0 then return false end

            return vRP.PaymentGems(passport, amount) and true or false
        end,

        -- Ajusta o saldo pra exatamente amount (dá ou tira a diferença).
        Set = function(passport, amount)
            amount = math.floor(tonumber(amount) or 0)
            if amount < 0 then return false end

            local current = Framework.Coins.Get(passport)
            if amount > current then
                return Framework.Coins.Give(passport, amount - current)
            elseif amount < current then
                return Framework.Coins.Remove(passport, current - amount)
            end

            return true
        end,
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ARMAS (TESTE DE SKIN)
    -- Ganchos com o seu sistema de armas/anticheat. Por padrão, PL_PROTECT.
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Entrega a arma da skin pro jogador que entrou no teste.
    GiveTestWeapon = function(source, weapon, ammo)
        if GetResourceState("PL_PROTECT") ~= "started" then return end
        exports["PL_PROTECT"]:giveWeapons(source, {
            [weapon] = { ammo = ammo, isHidden = false, bForceInHand = true },
        })
    end,

    -- Repõe munição durante o teste.
    AddTestAmmo = function(source, weapon, ammo)
        if GetResourceState("PL_PROTECT") ~= "started" then return end
        exports["PL_PROTECT"]:addAmmo(source, "SetPedAmmo", weapon, ammo)
    end,

    -- Tira a arma de teste ao encerrar.
    RemoveTestWeapons = function(source)
        if GetResourceState("PL_PROTECT") ~= "started" then return end
        exports["PL_PROTECT"]:removeWeapons(source)
    end,

    -- Devolve ao jogador as armas reais do inventário depois do teste.
    ReloadWeapons = function(source)
        TriggerEvent("vRP:ReloadWeapons", source)
    end,
}
