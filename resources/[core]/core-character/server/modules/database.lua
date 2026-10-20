-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreateThread = CreateThread
local json_decode = json.decode
local json_encode = json.encode
local pcall = pcall
local tonumber = tonumber
local tostring = tostring
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
TableCharacters = "core_characters"

DatabaseReady = false

MaxSlots = math.max(math.floor(tonumber(Character.Slots.Max) or 8), 1)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVERSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
ServerState = {
    Slots = {},
    Creating = {},
    Backup = {},
    Buckets = {},
    Characters = {},
    EntryRequested = {},
    SpawnSessions = {},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATETABLESIFNOTEXIST
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateTablesIfNotExist()
    Framework.Query(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `id`         INT(11) NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(255) NOT NULL,
            `citizenid`  VARCHAR(255) NOT NULL,
            `model`      VARCHAR(50) NOT NULL DEFAULT 'mp_m_freemode_01',
            `chardata`   TEXT NOT NULL,
            `clothes`    TEXT NOT NULL,
            `tattoos`    TEXT NOT NULL,
            `reset`      TINYINT(1) NOT NULL DEFAULT 1,
            `deleted`    TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`) USING BTREE,
            UNIQUE KEY `unique_citizenid` (`citizenid`) USING BTREE,
            INDEX `idx_identifier` (`identifier`) USING BTREE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]]):format(TableCharacters))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DECODE
-----------------------------------------------------------------------------------------------------------------------------------------
local function Decode(raw, fallback)
    if type(raw) ~= "string" or raw == "" then return fallback end

    local ok, parsed = pcall(json_decode, raw)
    if not ok or type(parsed) ~= "table" then return fallback end

    return parsed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INFLATEROW
-----------------------------------------------------------------------------------------------------------------------------------------
local function InflateRow(row)
    if not row then return nil end

    return {
        identifier = row.identifier,
        citizenid = tostring(row.citizenid),
        model     = row.model,
        chardata  = Decode(row.chardata, nil),
        clothes   = Decode(row.clothes, nil),
        tattoos   = Decode(row.tattoos, nil),
        reset     = (tonumber(row.reset) or 0) == 1,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DB_LOADCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function DB_LoadCharacter(citizenid)
    citizenid = tostring(citizenid)

    local cached = ServerState.Characters[citizenid]
    if cached ~= nil then return cached or nil end

    local row = Framework.Single(
        ("SELECT `identifier`, `citizenid`, `model`, `chardata`, `clothes`, `tattoos`, `reset` FROM `%s` WHERE `citizenid` = ? AND `deleted` = 0")
            :format(TableCharacters),
        { citizenid }
    )

    local character = InflateRow(row)
    ServerState.Characters[citizenid] = character or false

    return character
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVALIDATECHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function InvalidateCharacter(citizenid)
    ServerState.Characters[tostring(citizenid)] = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DB_CREATECHARACTERROW
-----------------------------------------------------------------------------------------------------------------------------------------
function DB_CreateCharacterRow(identifier, citizenid, model)
    Framework.Update(([[
        INSERT INTO `%s` (`identifier`,`citizenid`,`model`,`chardata`,`clothes`,`tattoos`,`reset`,`deleted`)
        VALUES (?,?,?,?,'{}','[]',1,0)
        ON DUPLICATE KEY UPDATE `identifier` = VALUES(`identifier`), `deleted` = 0
    ]]):format(TableCharacters), {
        tostring(identifier), tostring(citizenid),
        model or "mp_m_freemode_01",
        json_encode(Appearance.Default),
    })

    InvalidateCharacter(citizenid)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DB_SAVEAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function DB_SaveAppearance(citizenid, appearance, model, identifier)
    local current = DB_LoadCharacter(citizenid)

    identifier = identifier or (current and current.identifier) or ""
    model = model or (current and current.model) or "mp_m_freemode_01"

    Framework.Update(([[
        INSERT INTO `%s` (`identifier`,`citizenid`,`model`,`chardata`,`clothes`,`tattoos`,`reset`,`deleted`)
        VALUES (?,?,?,?,'{}','[]',0,0)
        ON DUPLICATE KEY UPDATE `chardata` = VALUES(`chardata`), `model` = VALUES(`model`), `reset` = 0
    ]]):format(TableCharacters), {
        tostring(identifier), tostring(citizenid),
        model,
        json_encode(appearance),
    })

    InvalidateCharacter(citizenid)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DB_SAVEOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
function DB_SaveOutfit(citizenid, clothes, tattoos)
    if clothes == nil and tattoos == nil then return false end

    local current = DB_LoadCharacter(citizenid)

    Framework.Update(([[
        INSERT INTO `%s` (`identifier`,`citizenid`,`model`,`chardata`,`clothes`,`tattoos`,`reset`,`deleted`)
        VALUES (?,?,?,?,?,?,1,0)
        ON DUPLICATE KEY UPDATE `clothes` = VALUES(`clothes`), `tattoos` = VALUES(`tattoos`)
    ]]):format(TableCharacters), {
        tostring((current and current.identifier) or ""),
        tostring(citizenid),
        (current and current.model) or "mp_m_freemode_01",
        json_encode((current and current.chardata) or Appearance.Default),
        json_encode(clothes ~= nil and clothes or (current and current.clothes) or {}),
        json_encode(tattoos ~= nil and tattoos or (current and current.tattoos) or {}),
    })

    InvalidateCharacter(citizenid)
    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DB_DELETECHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function DB_DeleteCharacter(citizenid)
    Framework.Update(
        ("UPDATE `%s` SET `deleted` = 1 WHERE `citizenid` = ?"):format(TableCharacters),
        { tostring(citizenid) }
    )

    InvalidateCharacter(citizenid)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCOUNTSLOTS
-----------------------------------------------------------------------------------------------------------------------------------------
function AccountSlots(license)
    local slots = tonumber(Framework.AccountSlots(license)) or 1

    if slots > MaxSlots then return MaxSlots end
    if slots < 1 then return 1 end

    return slots
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LASTPOSITION
-----------------------------------------------------------------------------------------------------------------------------------------
function LastPosition(userId)
    local position = Framework.LastPosition(userId)

    if type(position) == "table" and position.x then return position end

    local fallback = Character.SpawnCoords
    return { x = fallback[1], y = fallback[2], z = fallback[3] }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORGETUSER
-----------------------------------------------------------------------------------------------------------------------------------------
function ForgetUser(src)
    ServerState.Slots[src] = nil
    ServerState.Creating[src] = nil
    ServerState.Backup[src] = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    CreateTablesIfNotExist()
    DatabaseReady = true
end)
