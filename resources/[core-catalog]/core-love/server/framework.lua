-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Única camada que fala com a sua base. Pra rodar em outro framework, reescreva
-- só o corpo das funções abaixo.
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local AnnounceKeys = {
    dating  = "announceDating",
    engaged = "announceEngaged",
    married = "announceMarried",
    single  = "announceSingle",
}

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Source -> passaporte do personagem.
    Passport = function(source)
        return vRP.Passport(source)
    end,

    -- Passaporte -> source, se estiver online.
    Source = function(passport)
        return vRP.Source(passport)
    end,

    -- Nome exibido no painel, ou false se o passaporte não existir.
    Name = function(passport)
        local identity = vRP.Identity(passport)
        if not identity then return false end

        return identity.Name.." "..identity.Lastname
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Personagem entrou: handler(passport, source, first).
    OnConnect = function(handler)
        AddEventHandler("Connect", handler)
    end,

    -- Personagem saiu: handler(passport, source, license).
    OnDisconnect = function(handler)
        AddEventHandler("Disconnect", handler)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    -- kind: "verde", "vermelho" ou "amarelo".
    Notify = function(source, message, kind)
        TriggerClientEvent("Notify", source, Love.Brand.Title, message, kind, 5000)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- INTEGRAÇÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Roda quando o casal muda de etapa. Pendure aqui o que o seu servidor faz
    -- nessa hora: conquista, item, foto. Já vem com o anúncio global no chat.
    -- one/two = { Passport, Name } · status = dating, engaged, married ou single
    OnRelationshipChanged = function(one, two, status)
        if not Love.Announce[status] then return end

        local message = L(AnnounceKeys[status], { one = one.Name, two = two.Name })

        TriggerClientEvent("chat:ClientMessage", -1, Love.Brand.Title, message, "OOC")
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    Query = function(query, params)
        return MySQL.query.await(query, params)
    end,

    Insert = function(query, params)
        return MySQL.insert.await(query, params)
    end,
}
