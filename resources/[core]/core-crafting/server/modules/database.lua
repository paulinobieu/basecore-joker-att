-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local QueueTable = "core_crafting"

-- Nenhuma leitura ou gravação acontece antes da tabela existir.
local SchemaReady = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- SCHEMA
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.DatabaseReady(function()
    Framework.Query(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `passport`   INT NOT NULL,
            `queue`      LONGTEXT NOT NULL,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`passport`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]]):format(QueueTable))

    SchemaReady = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SCHEMAREADY
-----------------------------------------------------------------------------------------------------------------------------------------
function DatabaseReady()
    return SchemaReady
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINDQUEUE
-- Devolve sempre uma lista: linha ausente, JSON quebrado ou entrada malformada
-- viram fila vazia em vez de derrubar o fluxo.
-----------------------------------------------------------------------------------------------------------------------------------------
function FindQueue(Passport)
    if not SchemaReady then
        return {}
    end

    local Rows = Framework.Query("SELECT `queue` FROM `" .. QueueTable .. "` WHERE `passport` = ? LIMIT 1", { Passport })
    local Raw  = Rows and Rows[1] and Rows[1].queue

    if not Raw then
        return {}
    end

    local Decoded, Stored = pcall(json.decode, Raw)
    if not Decoded or type(Stored) ~= "table" then
        print("^3[CORE-CRAFTING]^7 fila ilegível do passaporte " .. tostring(Passport) .. ": mantida vazia.")
        return {}
    end

    local Entries = {}

    for _, Entry in ipairs(Stored) do
        if type(Entry) == "table" and type(Entry.Recipe) == "string" then
            Entries[#Entries + 1] = {
                Id       = parseInt(Entry.Id),
                Recipe   = Entry.Recipe,
                Times    = parseInt(Entry.Times),
                Amount   = parseInt(Entry.Amount),
                Duration = parseInt(Entry.Duration),
                EndsAt   = parseInt(Entry.EndsAt),
            }
        end
    end

    return Entries
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVEQUEUE
-- Gravação sem espera: a memória já é a fonte de verdade da sessão.
-----------------------------------------------------------------------------------------------------------------------------------------
function SaveQueue(Passport, Entries)
    if not SchemaReady then
        return
    end

    Framework.Execute(([[
        INSERT INTO `%s` (`passport`, `queue`)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE `queue` = VALUES(`queue`)
    ]]):format(QueueTable), { Passport, json.encode(Entries) })
end
