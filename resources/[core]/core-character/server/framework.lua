-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP Core por padrão). Adapte só o CORPO das funções.
--
-- Tudo que toca as tabelas DA BASE (contas e personagens) está aqui. O que é
-- do resource — visual, roupas e tatuagens — vive na tabela própria
-- `core_characters` e não passa por este arquivo.
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

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

    -- Nome, sobrenome e modelo do personagem, separados. É o que preenche o
    -- criador quando um personagem antigo volta para lá: sem isso ele abriria
    -- com os campos em branco e no ped masculino.
    Identity = function(userId)
        local id = vRP.Identity(userId)
        if not id then return nil end

        return {
            name = id.Name,
            lastname = id.Lastname,
            model = id.Skin,
        }
    end,

    -- Identificador da CONTA, não do personagem: é ele que agrupa os slots.
    License = function(source)
        return vRP.Identities(source)
    end,

    -- Modelo atualmente vestido pelo jogador ("mp_m_freemode_01"/"mp_f_freemode_01").
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

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -- O Notify da base recebe (Título, Mensagem, Cor, Tempo). A cor é uma
    -- chave de hudConfig.anuncios, não uma severidade: a tradução é o
    -- NotifyColors lá em cima, e é ele que você troca se a sua base falar
    -- outra língua.
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(source, message, severity)
        if not source then return end

        local color = NotifyColors[severity] or "azul"

        TriggerClientEvent("Notify", source, "Personagem", tostring(message or ""), color, 5000)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -- oxmysql direto, sem passar pela camada de consultas do seu framework:
    -- é o que deixa o resource rodar em qualquer base. Serve tanto a tabela
    -- `core_characters` quanto as consultas da base logo abaixo.
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

    Insert = function(query, params)
        return MySQL.insert.await(query, params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERSONAGENS DA CONTA
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Quantos personagens vivos a conta tem.
    CountCharacters = function(license)
        local row = Framework.Single(
            "SELECT COUNT(*) AS total FROM `characters` WHERE `License` = ? AND `Deleted` = 0",
            { license }
        )

        return tonumber(row and row.total) or 0
    end,

    -- Lista da conta, em ordem de criação.
    -- Retorno: array de { id = number, name = string }.
    ListCharacters = function(license)
        local rows = Framework.Query(
            "SELECT `id`, `Name`, `Lastname` FROM `characters` WHERE `License` = ? AND `Deleted` = 0 ORDER BY `id` ASC",
            { license }
        ) or {}

        local list = {}

        for index = 1, #rows do
            local row = rows[index]

            list[index] = {
                id = tonumber(row.id),
                name = row.Name .. " " .. row.Lastname,
            }
        end

        return list
    end,

    -- Quantos slots a conta tem direito. O teto (MaxSlots) é aplicado fora.
    AccountSlots = function(license)
        local row = Framework.Single("SELECT `Characters` FROM `accounts` WHERE `License` = ?", { license })
        return tonumber(row and row.Characters) or 1
    end,

    AddAccountSlot = function(license)
        return Framework.Update("UPDATE `accounts` SET `Characters` = `Characters` + 1 WHERE `License` = ?", { license })
    end,

    -- Cria um personagem vazio na base e devolve o id dele.
    CreateCharacter = function(license, model)
        return Framework.Insert(
            "INSERT INTO `characters` (`License`,`Name`,`Lastname`,`Sex`,`Blood`,`Skin`) VALUES (?,?,?,?,?,?)",
            {
                license, "", "",
                model == "mp_f_freemode_01" and "F" or "M",
                math.random(1, 4),
                model or "mp_m_freemode_01",
            }
        )
    end,

    -- Grava a identidade escolhida no criador.
    SaveIdentity = function(userId, name, lastname, gender)
        local affected = Framework.Update(
            "UPDATE `characters` SET `Name` = ?, `Lastname` = ?, `Sex` = ?, `Skin` = ? WHERE `id` = ?",
            { name, lastname, gender == "mp_f_freemode_01" and "F" or "M", gender, userId }
        )

        vRP.UpgradeNames(userId, name, lastname)

        local source = vRP.Source(userId)
        local player = source and Player(source)
        if player then
            player.state:set("Name", name .. " " .. lastname, true)
        end

        return affected
    end,

    -- Onde o personagem estava ao desconectar. Alimenta o primeiro cartão da
    -- tela de spawn; devolva nil se a sua base não guardar isso.
    --
    -- Na base Core o Datatable do personagem mora em `playerdata`, na linha
    -- de `Name` = "Datatable".
    LastPosition = function(userId)
        local row = Framework.Single(
            "SELECT `Information` FROM `playerdata` WHERE `Passport` = ? AND `Name` = 'Datatable'",
            { userId }
        )

        local ok, datatable = pcall(json.decode, row and row.Information or "")

        if ok and type(datatable) == "table" and type(datatable.Pos) == "table" then
            return datatable.Pos
        end

        return nil
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA DO PERSONAGEM
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Coloca o jogador dentro do personagem escolhido. `model` só vem quando o
    -- personagem acabou de nascer: é ele que faz a base entregar os itens
    -- iniciais e criar as chaves de playerdata do personagem novo.
    CharacterChosen = function(source, characterId, model)
        vRP.CharacterChosen(source, characterId, model)
    end,

    -- Persiste o modelo (sexo) do personagem na base. O resource também
    -- guarda o modelo na tabela própria, para montar o preview da seleção.
    SkinCharacter = function(userId, model)
        vRP.SkinCharacter(userId, model)
    end,

    -- Isola o jogador enquanto ele está na seleção ou na criação. Passa pela
    -- base em vez de chamar o native direto porque é ela que guarda o
    -- state.Route que o resto do servidor consulta.
    SetRouting = function(source, bucket)
        if bucket and bucket > 0 then
            return exports.vrp:Bucket(source, "Enter", bucket)
        end

        exports.vrp:Bucket(source, "Exit")
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- MOEDA PREMIUM
    -- Usada apenas na compra de slot (Character.Slots.Buy). É da CONTA, não do
    -- personagem: a compra acontece na seleção, onde ainda não existe um.
    -------------------------------------------------------------------------------------------------------------------------------------
    Coins = {
        -- Debita e devolve se conseguiu. O `>= ?` no WHERE é o que impede
        -- saldo negativo se o jogador clicar duas vezes.
        Remove = function(license, amount)
            local affected = Framework.Update(
                "UPDATE `accounts` SET `Gemstone` = `Gemstone` - ? WHERE `License` = ? AND `Gemstone` >= ?",
                { amount, license, amount }
            )

            return (tonumber(affected) or 0) > 0
        end,
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- HOOKS DO FLUXO DE CRIAÇÃO
    -- Ninguém escuta os dois eventos abaixo: eles existem para VOCÊ pendurar
    -- alguma coisa. Os itens iniciais já saem da base, no CharacterChosen.
    --
    -- Created  → nome, sexo e visual acabaram de ser gravados.
    -- Spawned  → o jogador terminou o fluxo e voltou ao mundo.
    -------------------------------------------------------------------------------------------------------------------------------------
    OnCharacterCreated = function(source, userId)
        TriggerEvent("core-character:insertPlayer", userId, source)
    end,

    OnCharacterSpawned = function(source, userId)
        TriggerEvent("core-character:playerSpawned", userId, source)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PONTOS DE SPAWN DO JOGADOR
    -- Alimenta a tela de escolha de local com o que é do personagem: casas e
    -- bases de organização. Cada entrada é { nome = { x, y, z } }.
    -------------------------------------------------------------------------------------------------------------------------------------
    SpawnPoints = function(userId)
        return { homes = {}, groups = {} }
    end,
}
