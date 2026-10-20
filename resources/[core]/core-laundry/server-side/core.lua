-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local MachineCache    = {}
local ActiveWashes    = {}
local MachineWatchers = {}
local SourceMachine   = {}
local DatabaseReady   = false
local TableName       = "core_laundry_machines"
local LaundryTable    = "core_laundry_laundries"
local SettingsTable   = "core_laundry_settings"
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEFAULTS (sobrescritos in-game pelo painel admin e persistidos em core_laundry_settings)
-----------------------------------------------------------------------------------------------------------------------------------------
Laundry.Items = {
    DirtyMoney = "dirtydollar",
    CleanMoney = "dollar",
    Cleaner = "water",
}

Laundry.Mathematics = {
    BaseValue = 10000,
    WashTime = 5,
    CleanerCost = 1,
    TaxPercent = 10,
    MinimumWashTime = 5,
}

Laundry.Cancel = {
    RefundPercent = 100,
    RefundCleaners = false,
}

Laundry.Upgrades = {
    Efficiency = {
        Enabled = true,
        DefaultLimit = 1000000,
        Levels = {
            [1] = { Limit = 2000000,  Price = 100000 },
            [2] = { Limit = 3000000,  Price = 100000 },
            [3] = { Limit = 5000000,  Price = 100000 },
            [4] = { Limit = 7500000,  Price = 100000 },
            [5] = { Limit = 10000000, Price = 100000 },
        },
    },

    Potency = {
        Enabled = true,
        Levels = {
            [1] = { TimeReducePercent = 10, Price = 100000 },
            [2] = { TimeReducePercent = 15, Price = 100000 },
            [3] = { TimeReducePercent = 20, Price = 100000 },
            [4] = { TimeReducePercent = 25, Price = 100000 },
            [5] = { TimeReducePercent = 30, Price = 100000 },
        },
    },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------

local function DatabaseQuery(query, parameters)
    parameters = parameters or {}

    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, parameters)
    end

    return exports.oxmysql:query_async(query, parameters)
end

local function CreateTableIfNotExists()
    DatabaseQuery(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `machine_id`       VARCHAR(64) NOT NULL,
            `cleaners_owned`   INT         NOT NULL DEFAULT 0,
            `efficiency_level` INT         NOT NULL DEFAULT 0,
            `power_level`      INT         NOT NULL DEFAULT 0,
            `is_washing`       TINYINT(1)  NOT NULL DEFAULT 0,
            `is_done`          TINYINT(1)  NOT NULL DEFAULT 0,
            `wash_amount`      BIGINT      NOT NULL DEFAULT 0,
            `wash_result`      BIGINT      NOT NULL DEFAULT 0,
            `wash_cleaners`    INT         NOT NULL DEFAULT 0,
            `wash_duration`    INT         NOT NULL DEFAULT 0,
            `wash_started_at`  BIGINT      NOT NULL DEFAULT 0,
            `wash_ends_at`     BIGINT      NOT NULL DEFAULT 0,
            `updated_at`       BIGINT      NOT NULL DEFAULT 0,
            PRIMARY KEY (`machine_id`)
        )
    ]]):format(TableName))

    DatabaseQuery(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `machine_id`   VARCHAR(64)  NOT NULL,
            `name`         VARCHAR(128) NOT NULL DEFAULT '',
            `permission`   VARCHAR(128) NOT NULL DEFAULT '',
            `theme_color`  VARCHAR(16)  NOT NULL DEFAULT '#dc1553',
            `spawn_object` TINYINT(1)   NOT NULL DEFAULT 1,
            `x`            FLOAT        NOT NULL DEFAULT 0,
            `y`            FLOAT        NOT NULL DEFAULT 0,
            `z`            FLOAT        NOT NULL DEFAULT 0,
            `h`            FLOAT        NOT NULL DEFAULT 0,
            `created_at`   BIGINT       NOT NULL DEFAULT 0,
            PRIMARY KEY (`machine_id`)
        )
    ]]):format(LaundryTable))

    DatabaseQuery(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `id`   TINYINT  NOT NULL,
            `data` LONGTEXT DEFAULT NULL,
            PRIMARY KEY (`id`)
        )
    ]]):format(SettingsTable))
end

local function LoadAllMachines()
    return DatabaseQuery(("SELECT * FROM `%s`"):format(TableName)) or {}
end

local function LoadMachine(machineId)
    local rows = DatabaseQuery(
        ("SELECT * FROM `%s` WHERE `machine_id` = ? LIMIT 1"):format(TableName),
        { machineId }
    ) or {}
    return rows[1]
end

local function SaveMachine(machine)
    machine.updated_at = os.time()

    DatabaseQuery(([[
        INSERT INTO `%s` (
            `machine_id`,       `cleaners_owned`,   `efficiency_level`,
            `power_level`,      `is_washing`,       `is_done`,
            `wash_amount`,      `wash_result`,      `wash_cleaners`,
            `wash_duration`,    `wash_started_at`,  `wash_ends_at`,
            `updated_at`
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            `cleaners_owned`   = VALUES(`cleaners_owned`),
            `efficiency_level` = VALUES(`efficiency_level`),
            `power_level`      = VALUES(`power_level`),
            `is_washing`       = VALUES(`is_washing`),
            `is_done`          = VALUES(`is_done`),
            `wash_amount`      = VALUES(`wash_amount`),
            `wash_result`      = VALUES(`wash_result`),
            `wash_cleaners`    = VALUES(`wash_cleaners`),
            `wash_duration`    = VALUES(`wash_duration`),
            `wash_started_at`  = VALUES(`wash_started_at`),
            `wash_ends_at`     = VALUES(`wash_ends_at`),
            `updated_at`       = VALUES(`updated_at`)
    ]]):format(TableName), {
        machine.machine_id,            machine.cleaners_owned,       machine.efficiency_level,
        machine.power_level,           machine.is_washing and 1 or 0,
        machine.is_done and 1 or 0,    machine.wash_amount,          machine.wash_result,
        machine.wash_cleaners,         machine.wash_duration,        machine.wash_started_at,
        machine.wash_ends_at,          machine.updated_at,
    })
end

local function InsertMachineIfNotExists(machineId)
    DatabaseQuery(
        ("INSERT IGNORE INTO `%s` (`machine_id`, `updated_at`) VALUES (?, ?)"):format(TableName),
        { tostring(machineId), os.time() }
    )
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- LAUNDRY DATABASE (dynamic machines)
-----------------------------------------------------------------------------------------------------------------------------------------

local function LoadAllLaundries()
    return DatabaseQuery(("SELECT * FROM `%s`"):format(LaundryTable)) or {}
end

local function SaveLaundry(laundry)
    DatabaseQuery(([[
        INSERT INTO `%s` (`machine_id`, `name`, `permission`, `theme_color`, `spawn_object`, `x`, `y`, `z`, `h`, `created_at`)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            `name` = VALUES(`name`), `permission` = VALUES(`permission`),
            `theme_color` = VALUES(`theme_color`),
            `spawn_object` = VALUES(`spawn_object`),
            `x` = VALUES(`x`), `y` = VALUES(`y`), `z` = VALUES(`z`), `h` = VALUES(`h`)
    ]]):format(LaundryTable), {
        laundry.machine_id, laundry.name, laundry.permission,
        laundry.theme_color, laundry.spawn_object and 1 or 0,
        laundry.x, laundry.y, laundry.z, laundry.h, laundry.created_at or os.time()
    })
end

local function DeleteLaundry(machineId)
    DatabaseQuery(("DELETE FROM `%s` WHERE `machine_id` = ?"):format(LaundryTable), { machineId })
    DatabaseQuery(("DELETE FROM `%s` WHERE `machine_id` = ?"):format(TableName), { machineId })
end

local function BuildLaundriesFromDB()
    local rows = LoadAllLaundries()
    Laundry.Laundries = {}

    for _, row in ipairs(rows) do
        local id = tostring(row.machine_id)
        Laundry.Laundries[id] = {
            ThemeColor = row.theme_color or Laundry.DefaultThemeColor,
            Machine = {
                Object = (tonumber(row.spawn_object) or 1) == 1,
                Coords = vec4(
                    tonumber(row.x) or 0,
                    tonumber(row.y) or 0,
                    tonumber(row.z) or 0,
                    tonumber(row.h) or 0
                ),
            },
            Permission = (row.permission and row.permission ~= "") and { row.permission } or false,
            _name = row.name or id,
        }
    end
end

local function GetLaundryListForNUI()
    local list = {}
    for machineId, laundry in pairs(Laundry.Laundries) do
        local coords = laundry.Machine.Coords
        list[#list + 1] = {
            id = machineId,
            name = laundry._name or machineId,
            permission = (laundry.Permission and laundry.Permission[1]) or "",
            spawnObject = laundry.Machine.Object and true or false,
            x = math.ceil((coords.x or 0) * 10) / 10,
            y = math.ceil((coords.y or 0) * 10) / 10,
            z = math.ceil((coords.z or 0) * 10) / 10,
            h = math.ceil((coords.w or 0) * 10) / 10,
        }
    end
    return list
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS (overrides persistidos do painel admin)
-----------------------------------------------------------------------------------------------------------------------------------------

local function SanitizeLevels(levels, key, maxPercent)
    local out = {}
    if type(levels) ~= "table" then return out end

    for index = 1, math.min(#levels, 10) do
        local level = levels[index]
        if type(level) == "table" then
            local price = math.max(0, math.floor(tonumber(level.price) or 0))

            if key == "limit" then
                local limit = math.max(1, math.floor(tonumber(level.limit) or 0))
                out[#out + 1] = { Limit = limit, Price = price }
            else
                local percent = math.floor(tonumber(level.percent) or 0)
                out[#out + 1] = { TimeReducePercent = math.max(0, math.min(maxPercent or 90, percent)), Price = price }
            end
        end
    end

    return out
end

local function SanitizeSettings(raw)
    if type(raw) ~= "table" then return nil end

    local clean = {}

    if type(raw.items) == "table" then
        clean.items = {
            dirty = tostring(raw.items.dirty or ""):sub(1, 64),
            clean = tostring(raw.items.clean or ""):sub(1, 64),
            cleaner = tostring(raw.items.cleaner or ""):sub(1, 64),
        }
    end

    if type(raw.mathematics) == "table" then
        clean.mathematics = {
            baseValue = math.max(1, math.floor(tonumber(raw.mathematics.baseValue) or 0)),
            washTime = math.max(0, math.floor(tonumber(raw.mathematics.washTime) or 0)),
            cleanerCost = math.max(0, math.floor(tonumber(raw.mathematics.cleanerCost) or 0)),
            taxPercent = math.max(0, math.min(100, math.floor(tonumber(raw.mathematics.taxPercent) or 0))),
            minimumWashTime = math.max(1, math.floor(tonumber(raw.mathematics.minimumWashTime) or 0)),
        }
    end

    if type(raw.cancel) == "table" then
        clean.cancel = {
            refundPercent = math.max(0, math.min(100, math.floor(tonumber(raw.cancel.refundPercent) or 0))),
            refundCleaners = raw.cancel.refundCleaners and true or false,
        }
    end

    if type(raw.upgrades) == "table" then
        clean.upgrades = {}

        if type(raw.upgrades.efficiency) == "table" then
            local levels = SanitizeLevels(raw.upgrades.efficiency.levels, "limit")
            if #levels > 0 then
                clean.upgrades.efficiency = {
                    enabled = raw.upgrades.efficiency.enabled and true or false,
                    defaultLimit = math.max(1, math.floor(tonumber(raw.upgrades.efficiency.defaultLimit) or 0)),
                    levels = levels,
                }
            end
        end

        if type(raw.upgrades.potency) == "table" then
            local levels = SanitizeLevels(raw.upgrades.potency.levels, "percent", 90)
            if #levels > 0 then
                clean.upgrades.potency = {
                    enabled = raw.upgrades.potency.enabled and true or false,
                    levels = levels,
                }
            end
        end
    end

    return clean
end

local function ApplySettings(s)
    if type(s) ~= "table" then return end

    if type(s.items) == "table" then
        if (s.items.dirty or "") ~= "" then Laundry.Items.DirtyMoney = s.items.dirty end
        if (s.items.clean or "") ~= "" then Laundry.Items.CleanMoney = s.items.clean end
        if (s.items.cleaner or "") ~= "" then Laundry.Items.Cleaner = s.items.cleaner end
    end

    if type(s.mathematics) == "table" then
        Laundry.Mathematics.BaseValue = s.mathematics.baseValue or Laundry.Mathematics.BaseValue
        Laundry.Mathematics.WashTime = s.mathematics.washTime or Laundry.Mathematics.WashTime
        Laundry.Mathematics.CleanerCost = s.mathematics.cleanerCost or Laundry.Mathematics.CleanerCost
        Laundry.Mathematics.TaxPercent = s.mathematics.taxPercent or Laundry.Mathematics.TaxPercent
        Laundry.Mathematics.MinimumWashTime = s.mathematics.minimumWashTime or Laundry.Mathematics.MinimumWashTime
    end

    if type(s.cancel) == "table" then
        Laundry.Cancel.RefundPercent = s.cancel.refundPercent or Laundry.Cancel.RefundPercent
        if s.cancel.refundCleaners ~= nil then Laundry.Cancel.RefundCleaners = s.cancel.refundCleaners end
    end

    if type(s.upgrades) == "table" then
        if type(s.upgrades.efficiency) == "table" and type(s.upgrades.efficiency.levels) == "table" and #s.upgrades.efficiency.levels > 0 then
            Laundry.Upgrades.Efficiency.Enabled = s.upgrades.efficiency.enabled and true or false
            Laundry.Upgrades.Efficiency.DefaultLimit = s.upgrades.efficiency.defaultLimit or Laundry.Upgrades.Efficiency.DefaultLimit
            Laundry.Upgrades.Efficiency.Levels = s.upgrades.efficiency.levels
        end

        if type(s.upgrades.potency) == "table" and type(s.upgrades.potency.levels) == "table" and #s.upgrades.potency.levels > 0 then
            Laundry.Upgrades.Potency.Enabled = s.upgrades.potency.enabled and true or false
            Laundry.Upgrades.Potency.Levels = s.upgrades.potency.levels
        end
    end
end

local function LoadSettings()
    local rows = DatabaseQuery(("SELECT `data` FROM `%s` WHERE `id` = 1 LIMIT 1"):format(SettingsTable)) or {}

    if rows[1] and rows[1].data then
        local ok, decoded = pcall(json.decode, rows[1].data)
        if ok and type(decoded) == "table" then
            ApplySettings(decoded)
        end
    end
end

local function SaveSettingsToDB(s)
    local ok, encoded = pcall(json.encode, s)
    if not ok then return end

    DatabaseQuery(([[
        INSERT INTO `%s` (`id`, `data`) VALUES (1, ?)
        ON DUPLICATE KEY UPDATE `data` = VALUES(`data`)
    ]]):format(SettingsTable), { encoded })
end

local function BuildSettingsForNUI()
    local efficiency = Laundry.Upgrades.Efficiency
    local potency = Laundry.Upgrades.Potency

    local efficiencyLevels = {}
    for index, level in ipairs(efficiency.Levels) do
        efficiencyLevels[index] = { limit = level.Limit, price = level.Price }
    end

    local potencyLevels = {}
    for index, level in ipairs(potency.Levels) do
        potencyLevels[index] = { percent = level.TimeReducePercent, price = level.Price }
    end

    return {
        items = {
            dirty = Laundry.Items.DirtyMoney,
            clean = Laundry.Items.CleanMoney,
            cleaner = Laundry.Items.Cleaner,
        },
        mathematics = {
            baseValue = Laundry.Mathematics.BaseValue,
            washTime = Laundry.Mathematics.WashTime,
            cleanerCost = Laundry.Mathematics.CleanerCost,
            taxPercent = Laundry.Mathematics.TaxPercent,
            minimumWashTime = Laundry.Mathematics.MinimumWashTime,
        },
        cancel = {
            refundPercent = Laundry.Cancel.RefundPercent,
            refundCleaners = Laundry.Cancel.RefundCleaners and true or false,
        },
        upgrades = {
            efficiency = {
                enabled = efficiency.Enabled and true or false,
                defaultLimit = efficiency.DefaultLimit,
                levels = efficiencyLevels,
            },
            potency = {
                enabled = potency.Enabled and true or false,
                levels = potencyLevels,
            },
        },
    }
end

local StartingSeconds = 4

local function GetMachinePropState(machine)
    if machine.starting_until and os.time() < machine.starting_until then
        return "starting"
    elseif machine.is_washing then
        return "on"
    end
    return "off"
end

local function BroadcastMachineProp(machineId, target)
    local machine = MachineCache[machineId]
    if not machine then return end

    local state = GetMachinePropState(machine)

    if not target then
        if machine._propState == state then return end
        machine._propState = state
    end

    TriggerClientEvent("core-laundry:machineProp", target or -1, machineId, state)
end

local function SyncMachineProps(target)
    for machineId in pairs(MachineCache) do
        BroadcastMachineProp(machineId, target)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function FormatThousands(value)
    local sep = (Laundry.Currency and Laundry.Currency.Separator) or "."
    local formatted = tostring(math.floor(tonumber(value) or 0))

    while true do
        local updated, matches = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1" .. sep .. "%2")
        formatted = updated
        if matches == 0 then break end
    end

    return formatted
end

local function FormatCurrency(value)
    local cfg = Laundry.Currency or {}
    return (cfg.Prefix or "R$ ") .. FormatThousands(value) .. (cfg.Suffix or "")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local function GetLaundry(machineId)
    return Laundry.Laundries[tostring(machineId)]
end

local function GetMachineName(machineId)
    return tostring(machineId)
end

local function HasMachineAccess(user_id, machineId)
    local laundry = GetLaundry(machineId)

    if not laundry then
        return false
    end

    return Functions.HasPermission(user_id, laundry.Permission)
end

local function BuildDefaultMachine(machineId)
    return {
        machine_id = tostring(machineId),
        cleaners_owned = 0,
        efficiency_level = 0,
        power_level = 0,
        is_washing = false,
        is_done = false,
        wash_amount = 0,
        wash_result = 0,
        wash_cleaners = 0,
        wash_duration = 0,
        wash_started_at = 0,
        wash_ends_at = 0,
        updated_at = os.time()
    }
end

local function NormalizeMachine(machineId, row)
    local machine = BuildDefaultMachine(machineId)

    if not row then
        return machine
    end

    machine.cleaners_owned = tonumber(row.cleaners_owned) or 0
    machine.efficiency_level = tonumber(row.efficiency_level) or 0
    machine.power_level = tonumber(row.power_level) or 0
    machine.is_washing = (tonumber(row.is_washing) or 0) == 1
    machine.is_done = (tonumber(row.is_done) or 0) == 1
    machine.wash_amount = tonumber(row.wash_amount) or 0
    machine.wash_result = tonumber(row.wash_result) or 0
    machine.wash_cleaners = tonumber(row.wash_cleaners) or 0
    machine.wash_duration = tonumber(row.wash_duration) or 0
    machine.wash_started_at = tonumber(row.wash_started_at) or 0
    machine.wash_ends_at = tonumber(row.wash_ends_at) or 0
    machine.updated_at = tonumber(row.updated_at) or os.time()

    return machine
end

local function ResetWashState(machine)
    machine.is_washing = false
    machine.is_done = false
    machine.wash_amount = 0
    machine.wash_result = 0
    machine.wash_cleaners = 0
    machine.wash_duration = 0
    machine.wash_started_at = 0
    machine.wash_ends_at = 0
end

local function GetEfficiencyState(machine)
    local upgrade = Laundry.Upgrades.Efficiency
    local currentLevel = Clamp(machine.efficiency_level, 0, #upgrade.Levels)
    local currentLimit = upgrade.DefaultLimit

    if currentLevel > 0 and upgrade.Levels[currentLevel] then
        currentLimit = upgrade.Levels[currentLevel].Limit
    end

    return {
        Level = currentLevel,
        Max = #upgrade.Levels,
        Limit = currentLimit,
        Cost = upgrade.Levels[currentLevel + 1] and upgrade.Levels[currentLevel + 1].Price or 0
    }
end

local function GetPowerState(machine)
    local upgrade = Laundry.Upgrades.Potency
    local currentLevel = Clamp(machine.power_level, 0, #upgrade.Levels)
    local currentBonus = 0

    if currentLevel > 0 and upgrade.Levels[currentLevel] then
        currentBonus = upgrade.Levels[currentLevel].TimeReducePercent or 0
    end

    return {
        Level = currentLevel,
        Max = #upgrade.Levels,
        Bonus = currentBonus,
        Description = currentBonus > 0 and (tostring(currentBonus) .. "% menos tempo") or "0% menos tempo",
        Cost = upgrade.Levels[currentLevel + 1] and upgrade.Levels[currentLevel + 1].Price or 0
    }
end

local function CalculateRequiredCleaners(amount)
    local baseValue = Laundry.Mathematics.BaseValue
    local cleanerCost = Laundry.Mathematics.CleanerCost

    return math.max(1, math.ceil((amount / baseValue) * cleanerCost))
end

local function CalculateWashResult(amount)
    local taxPercent = Laundry.Mathematics.TaxPercent
    return math.floor(amount * ((100 - taxPercent) / 100))
end

local function CalculateWashDuration(amount, machine)
    local baseSeconds = math.ceil((amount / Laundry.Mathematics.BaseValue) * Laundry.Mathematics.WashTime)
    local powerState = GetPowerState(machine)
    local duration = math.ceil(baseSeconds * ((100 - powerState.Bonus) / 100))

    return math.max(Laundry.Mathematics.MinimumWashTime or 5, duration)
end

local function GetMachineStatus(machine)
    if machine.is_washing then
        local timeRemaining = math.max(machine.wash_ends_at - os.time(), 0)
        local elapsed = math.max(os.time() - machine.wash_started_at, 0)
        local progress = 0

        if machine.wash_duration > 0 then
            progress = math.floor((elapsed / machine.wash_duration) * 100)
        end

        return {
            isWashing = true,
            isDone = false,
            amount = machine.wash_amount,
            result = machine.wash_result,
            time = timeRemaining,
            cleaners = machine.wash_cleaners,
            progress = Clamp(progress, 0, 99)
        }
    end

    if machine.is_done then
        return {
            isWashing = false,
            isDone = true,
            amount = machine.wash_amount,
            result = machine.wash_result,
            time = 0,
            cleaners = machine.wash_cleaners,
            progress = 100
        }
    end

    return {
        isWashing = false,
        isDone = false,
        amount = 0,
        result = 0,
        time = 0,
        cleaners = 0,
        progress = 0
    }
end

local function BuildOpenPayload(machineId)
    local machine = MachineCache[machineId]
    local efficiencyState = GetEfficiencyState(machine)
    local powerState = GetPowerState(machine)
    local laundry = GetLaundry(machineId) or {}

    return {
        machineId = GetMachineName(machineId),
        machineName = laundry._name or GetMachineName(machineId),
        taxRate = Laundry.Mathematics.TaxPercent,
        cleanersOwned = machine.cleaners_owned,
        efficiencyLevel = efficiencyState.Level,
        efficiencyMax = efficiencyState.Max,
        efficiencyLimit = FormatCurrency(efficiencyState.Limit),
        efficiencyCost = efficiencyState.Cost,
        powerLevel = powerState.Level,
        powerMax = powerState.Max,
        powerLimit = powerState.Description,
        powerCost = powerState.Cost,
        themeColor = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or laundry.ThemeColor or Laundry.DefaultThemeColor,
        currencyPrefix = (Laundry.Currency and Laundry.Currency.Prefix) or "R$ ",
        currencySuffix = (Laundry.Currency and Laundry.Currency.Suffix) or "",
        currencySeparator = (Laundry.Currency and Laundry.Currency.Separator) or ".",
    }
end

local function RemoveWatcher(source)
    local machineId = SourceMachine[source]

    if not machineId then
        return
    end

    if MachineWatchers[machineId] then
        MachineWatchers[machineId][source] = nil

        if not next(MachineWatchers[machineId]) then
            MachineWatchers[machineId] = nil
        end
    end

    SourceMachine[source] = nil
end

local function AddWatcher(source, machineId)
    RemoveWatcher(source)

    MachineWatchers[machineId] = MachineWatchers[machineId] or {}
    MachineWatchers[machineId][source] = true
    SourceMachine[source] = machineId
end

local function SendWatcherMessage(machineId, action, data)
    local watchers = MachineWatchers[machineId]

    if not watchers then
        return
    end

    for src in pairs(watchers) do
        if GetPlayerPing(src) <= 0 then
            RemoveWatcher(src)
        else
            TriggerClientEvent("core-laundry:nuiMessage", src, action, data)
        end
    end
end

local function BroadcastMachineConfig(machineId)
    SendWatcherMessage(machineId, "updateConfig", BuildOpenPayload(machineId))
end

local function BroadcastMachineStatus(machineId)
    local machine = MachineCache[machineId]
    local status = GetMachineStatus(machine)

    SendWatcherMessage(machineId, "updateWashStatus", status)

    if machine.is_done then
        SendWatcherMessage(machineId, "washDone")
    end
end

local function EnsureMachineLoaded(machineId)
    machineId = tostring(machineId)

    if MachineCache[machineId] then
        return MachineCache[machineId]
    end

    InsertMachineIfNotExists(machineId)

    local row = LoadMachine(machineId)
    MachineCache[machineId] = NormalizeMachine(machineId, row)

    return MachineCache[machineId]
end

local function OpenMachine(source, machineId)
    local machine = EnsureMachineLoaded(machineId)

    AddWatcher(source, machineId)
    TriggerClientEvent("core-laundry:openPanel", source, machineId, BuildOpenPayload(machineId), GetMachineStatus(machine))
end

local function FinishMachineWash(machineId)
    local machine = MachineCache[machineId]

    if not machine or not machine.is_washing then
        return
    end

    machine.is_washing = false
    machine.is_done = true
    machine.wash_ends_at = os.time()
    machine.starting_until = nil
    SaveMachine(machine)
    BroadcastMachineStatus(machineId)
    BroadcastMachineProp(machineId)
end

local function ValidateMachineAction(source)
    local user_id = Functions.Passport(source)
    local machineId = SourceMachine[source]

    if not user_id or not machineId then
        return nil, nil
    end

    if not HasMachineAccess(user_id, machineId) then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "Você não possui acesso a esta máquina.")
        return nil, nil
    end

    return user_id, EnsureMachineLoaded(machineId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTUP
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    CreateTableIfNotExists()

    LoadSettings()

    -- Load laundries from database (dynamic)
    BuildLaundriesFromDB()

    for machineId in pairs(Laundry.Laundries) do
        InsertMachineIfNotExists(machineId)
    end

    local rows = LoadAllMachines() or {}

    for _, row in ipairs(rows) do
        local id = tostring(row.machine_id)

        if Laundry.Laundries[id] then
            MachineCache[id] = NormalizeMachine(id, row)

            if MachineCache[id].is_washing and MachineCache[id].wash_ends_at <= os.time() then
                MachineCache[id].is_washing = false
                MachineCache[id].is_done = true
                MachineCache[id].wash_ends_at = os.time()
                SaveMachine(MachineCache[id])
            elseif MachineCache[id].is_washing then
                ActiveWashes[id] = true
            end
        end
    end

    DatabaseReady = true

    -- Tell all clients to spawn the machines
    TriggerClientEvent("core-laundry:syncLaundries", -1, Laundry.Laundries)
    SyncMachineProps()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local sleep = 1000

        local now = os.time()

        for machineId in pairs(ActiveWashes) do
            local machine = MachineCache[machineId]

            if not machine or not machine.is_washing then
                ActiveWashes[machineId] = nil
            elseif now >= machine.wash_ends_at then
                FinishMachineWash(machineId)
                ActiveWashes[machineId] = nil
            else
                BroadcastMachineStatus(machineId)
                BroadcastMachineProp(machineId)
            end
        end

        Wait(sleep)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-laundry:requestLaundries", function()
    local source = source
    if DatabaseReady then
        TriggerClientEvent("core-laundry:syncLaundries", source, Laundry.Laundries)
        SyncMachineProps(source)
    end
end)

RegisterNetEvent("core-laundry:requestOpen", function(machineId)
    local source = source
    local user_id = Functions.Passport(source)
    local laundry = GetLaundry(machineId)

    if not DatabaseReady then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "O sistema ainda está inicializando.")
        return
    end

    if not user_id then
        return
    end

    if not laundry then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "Máquina de lavagem inválida.")
        return
    end

    if not HasMachineAccess(user_id, machineId) then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "Você não possui acesso a esta máquina.")
        return
    end

    OpenMachine(source, machineId)
end)

RegisterNetEvent("core-laundry:closeMachine", function()
    RemoveWatcher(source)
end)

RegisterNetEvent("core-laundry:handleAction", function(action, data)
    local source = source
    local user_id, machine = ValidateMachineAction(source)

    if not user_id or not machine then
        return
    end

    local machineId   = SourceMachine[source]
    local machineName = GetMachineName(machineId)

    if action == "startWash" then
        local amount = math.floor(tonumber(data.amount) or 0)
        local dirtyItem = Laundry.Items.DirtyMoney
        local dirtyAmount, dirtySlot = Functions.InventoryItemAmount(user_id, dirtyItem)
        local efficiencyState = GetEfficiencyState(machine)
        local requiredCleaners = CalculateRequiredCleaners(amount)

        if machine.is_washing then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Esta máquina já está lavando dinheiro.")
            return
        end

        if machine.is_done then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Colete o dinheiro finalizado antes de iniciar outra lavagem.")
            return
        end

        if amount <= 0 then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Informe um valor válido para lavagem.")
            return
        end

        if amount > efficiencyState.Limit then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "O valor excede o limite atual da máquina.")
            return
        end

        if dirtyAmount < amount then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Você não possui dinheiro sujo suficiente.")
            return
        end

        if machine.cleaners_owned < requiredCleaners then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "A máquina não possui limpadores suficientes.")
            return
        end

        if not Functions.TakeItem(user_id, dirtySlot or dirtyItem, amount) then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Não foi possível remover o dinheiro sujo do inventário.")
            return
        end

        machine.cleaners_owned = machine.cleaners_owned - requiredCleaners
        machine.is_washing = true
        machine.is_done = false
        machine.wash_amount = amount
        machine.wash_result = CalculateWashResult(amount)
        machine.wash_cleaners = requiredCleaners
        machine.wash_duration = CalculateWashDuration(amount, machine)
        machine.wash_started_at = os.time()
        machine.wash_ends_at = machine.wash_started_at + machine.wash_duration
        machine.starting_until = os.time() + StartingSeconds
        ActiveWashes[machineId] = true
        SaveMachine(machine)
        BroadcastMachineConfig(machineId)
        BroadcastMachineStatus(machineId)
        BroadcastMachineProp(machineId)
        TriggerClientEvent("core-laundry:playWashAnim", source, StartingSeconds * 1000)
        Functions.Notify(source, Functions.NotifyTypes.Success, "Lavagem iniciada com sucesso.")

        Functions.Log("LAVAGEM-INICIOU", {
            message    = Functions.FullName(user_id) .. " #" .. user_id .. " iniciou a lavagem de R$ " .. amount .. " na máquina " .. machineName,
            playerName = Functions.FullName(user_id),
            playerId   = user_id,
            Maquina    = machineName,
            Valor      = amount,
            Resultado  = machine.wash_result,
            Duracao    = machine.wash_duration .. "s",
        })

        return
    end

    if action == "cancelWash" then
        if not machine.is_washing then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Não existe lavagem em andamento nesta máquina.")
            return
        end

        local refundAmount = math.floor(machine.wash_amount * ((Laundry.Cancel.RefundPercent or 100) / 100))

        if refundAmount > 0 then
            Functions.GiveItem(user_id, Laundry.Items.DirtyMoney, refundAmount)
        end

        if Laundry.Cancel.RefundCleaners then
            machine.cleaners_owned = machine.cleaners_owned + machine.wash_cleaners
        end

        ResetWashState(machine)
        machine.starting_until = nil
        SaveMachine(machine)
        BroadcastMachineConfig(machineId)
        BroadcastMachineStatus(machineId)
        BroadcastMachineProp(machineId)
        Functions.Notify(source, Functions.NotifyTypes.Warning, "Lavagem cancelada.")

        Functions.Log("LAVAGEM-CANCELOU", {
            message    = Functions.FullName(user_id) .. " #" .. user_id .. " cancelou a lavagem na máquina " .. machineName,
            playerName = Functions.FullName(user_id),
            playerId   = user_id,
            Maquina    = machineName,
            Reembolso  = refundAmount,
        })

        return
    end

    if action == "collectWash" then
        if not machine.is_done then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Não existe lavagem pronta para coleta.")
            return
        end

        local collected = machine.wash_result
        Functions.GiveItem(user_id, Laundry.Items.CleanMoney, collected)
        ResetWashState(machine)
        machine.starting_until = nil
        SaveMachine(machine)
        BroadcastMachineStatus(machineId)
        BroadcastMachineProp(machineId)
        Functions.Notify(source, Functions.NotifyTypes.Success, "Dinheiro limpo coletado com sucesso.")

        Functions.Log("LAVAGEM-COLETOU", {
            message    = Functions.FullName(user_id) .. " #" .. user_id .. " coletou R$ " .. collected .. " lavados da máquina " .. machineName,
            playerName = Functions.FullName(user_id),
            playerId   = user_id,
            Maquina    = machineName,
            Valor      = collected,
        })

        return
    end

    if action == "upgradeEfficiency" then
        local upgrade = Laundry.Upgrades.Efficiency
        local state = GetEfficiencyState(machine)

        if not upgrade.Enabled then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Este upgrade está desabilitado.")
            return
        end

        if state.Level >= state.Max then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "A eficiência desta máquina já está no nível máximo.")
            return
        end

        if not Functions.Payment(user_id, state.Cost) then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Dinheiro insuficiente para realizar este upgrade.")
            return
        end

        machine.efficiency_level = machine.efficiency_level + 1
        SaveMachine(machine)
        BroadcastMachineConfig(machineId)
        Functions.Notify(source, Functions.NotifyTypes.Success, "Upgrade de eficiência aplicado com sucesso.")

        Functions.Log("LAVAGEM-UPGRADE", {
            message    = Functions.FullName(user_id) .. " #" .. user_id .. " aplicou upgrade de Eficiência (nível " .. machine.efficiency_level .. ") na máquina " .. machineName,
            playerName = Functions.FullName(user_id),
            playerId   = user_id,
            Maquina    = machineName,
            Upgrade    = "Eficiência",
            Nivel      = machine.efficiency_level,
            Custo      = state.Cost,
        })

        return
    end

    if action == "upgradePower" then
        local upgrade = Laundry.Upgrades.Potency
        local state = GetPowerState(machine)

        if not upgrade.Enabled then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Este upgrade está desabilitado.")
            return
        end

        if state.Level >= state.Max then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "A potência desta máquina já está no nível máximo.")
            return
        end

        if not Functions.Payment(user_id, state.Cost) then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Dinheiro insuficiente para realizar este upgrade.")
            return
        end

        machine.power_level = machine.power_level + 1
        SaveMachine(machine)
        BroadcastMachineConfig(machineId)
        Functions.Notify(source, Functions.NotifyTypes.Success, "Upgrade de potência aplicado com sucesso.")

        Functions.Log("LAVAGEM-UPGRADE", {
            message    = Functions.FullName(user_id) .. " #" .. user_id .. " aplicou upgrade de Potência (nível " .. machine.power_level .. ") na máquina " .. machineName,
            playerName = Functions.FullName(user_id),
            playerId   = user_id,
            Maquina    = machineName,
            Upgrade    = "Potência",
            Nivel      = machine.power_level,
            Custo      = state.Cost,
        })

        return
    end

    if action == "addCleaners" then
        local amount = math.floor(tonumber(data.amount) or 0)
        local cleanerItem = Laundry.Items.Cleaner
        local cleanerAmount, cleanerSlot = Functions.InventoryItemAmount(user_id, cleanerItem)

        if amount <= 0 then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Informe uma quantidade válida de limpadores.")
            return
        end

        if cleanerAmount < amount then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Você não possui limpadores suficientes.")
            return
        end

        if not Functions.TakeItem(user_id, cleanerSlot or cleanerItem, amount) then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Não foi possível remover os limpadores do inventário.")
            return
        end

        machine.cleaners_owned = machine.cleaners_owned + amount
        SaveMachine(machine)
        BroadcastMachineConfig(machineId)
        Functions.Notify(source, Functions.NotifyTypes.Success, "Limpadores adicionados com sucesso.")

        Functions.Log("LAVAGEM-LIMPADORES", {
            message    = Functions.FullName(user_id) .. " #" .. user_id .. " adicionou " .. amount .. " limpadores na máquina " .. machineName,
            playerName = Functions.FullName(user_id),
            playerId   = user_id,
            Maquina    = machineName,
            Quantidade = amount,
        })

        return
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
local AdminPermission = Laundry.Admin.Permission or "Admin"

RegisterNetEvent("core-laundry:handleAdminAction", function(action, data)
    local source = source
    local user_id = Functions.Passport(source)

    if not user_id then return end
    if not Functions.HasGroup(user_id, AdminPermission, 1) then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    if action == "getLocation" then
        local spawnObject = data.spawnObject == nil and true or (data.spawnObject and true or false)
        TriggerClientEvent("core-laundry:startPlacement", source, spawnObject)
        return
    end

    if action == "createMachine" then
        local name = tostring(data.name or ""):sub(1, 128)
        local perm = tostring(data.permission or ""):sub(1, 128)
        local spawnObject = data.spawnObject == nil and true or (data.spawnObject and true or false)
        local px = tonumber(data.x) or 0
        local py = tonumber(data.y) or 0
        local pz = tonumber(data.z) or 0
        local ph = tonumber(data.h) or 0

        if name == "" then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Informe um nome para a máquina.")
            return
        end

        if px == 0 and py == 0 and pz == 0 then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Informe as coordenadas da máquina.")
            return
        end

        local machineId = name:lower():gsub("%s+", "_"):gsub("[^%w_]", "") .. "_" .. os.time()

        local laundry = {
            machine_id = machineId,
            name = name,
            permission = perm,
            theme_color = Laundry.DefaultThemeColor,
            spawn_object = spawnObject,
            x = px, y = py, z = pz, h = ph,
            created_at = os.time(),
        }

        SaveLaundry(laundry)
        InsertMachineIfNotExists(machineId)

        Laundry.Laundries[machineId] = {
            ThemeColor = laundry.theme_color,
            Machine = {
                Object = spawnObject,
                Coords = vec4(px, py, pz, ph),
            },
            Permission = (perm ~= "") and { perm } or false,
            _name = name,
        }

        MachineCache[machineId] = NormalizeMachine(machineId, nil)

        TriggerClientEvent("core-laundry:syncLaundries", -1, Laundry.Laundries)
        TriggerClientEvent("core-laundry:nuiMessage", source, "updateMachines", { machines = GetLaundryListForNUI() })
        Functions.Notify(source, Functions.NotifyTypes.Success, "Máquina criada com sucesso.")

        Functions.Log("CRIOU-LAVAGEM", {
            message       = Functions.FullName(user_id) .. " #" .. user_id .. " criou a máquina de lavagem " .. name,
            adminName     = Functions.FullName(user_id),
            adminId       = user_id,
            Maquina       = name,
            Permissao     = perm ~= "" and perm or "Pública",
            CoordsMaquina = ("%.1f, %.1f, %.1f"):format(px, py, pz),
        })

        return
    end

    if action == "editMachine" then
        local targetId = tostring(data.id or "")
        local existing = Laundry.Laundries[targetId]

        if targetId == "" or not existing then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Máquina não encontrada.")
            return
        end

        local coords = existing.Machine.Coords
        local name = tostring(data.name or ""):sub(1, 128)
        local perm = tostring(data.permission or ""):sub(1, 128)
        local spawnObject = data.spawnObject == nil and (existing.Machine.Object and true or false) or (data.spawnObject and true or false)
        local px = tonumber(data.x) or coords.x
        local py = tonumber(data.y) or coords.y
        local pz = tonumber(data.z) or coords.z
        local ph = tonumber(data.h) or coords.w

        if name == "" then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Informe um nome para a máquina.")
            return
        end

        local laundry = {
            machine_id = targetId,
            name = name,
            permission = perm,
            theme_color = existing.ThemeColor or Laundry.DefaultThemeColor,
            spawn_object = spawnObject,
            x = px, y = py, z = pz, h = ph,
        }

        SaveLaundry(laundry)

        Laundry.Laundries[targetId] = {
            ThemeColor = laundry.theme_color,
            Machine = {
                Object = spawnObject,
                Coords = vec4(px, py, pz, ph),
            },
            Permission = (perm ~= "") and { perm } or false,
            _name = name,
        }

        TriggerClientEvent("core-laundry:syncLaundries", -1, Laundry.Laundries)
        TriggerClientEvent("core-laundry:nuiMessage", source, "updateMachines", { machines = GetLaundryListForNUI() })
        Functions.Notify(source, Functions.NotifyTypes.Success, "Máquina atualizada com sucesso.")

        Functions.Log("EDITOU-LAVAGEM", {
            message       = Functions.FullName(user_id) .. " #" .. user_id .. " editou a máquina de lavagem " .. name,
            adminName     = Functions.FullName(user_id),
            adminId       = user_id,
            Maquina       = name,
            Permissao     = perm ~= "" and perm or "Pública",
            CoordsMaquina = ("%.1f, %.1f, %.1f"):format(px, py, pz),
        })

        return
    end

    if action == "saveSettings" then
        local clean = SanitizeSettings(data.settings)

        if not clean then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Configurações inválidas.")
            return
        end

        ApplySettings(clean)
        SaveSettingsToDB(BuildSettingsForNUI())

        for machineId in pairs(MachineCache) do
            BroadcastMachineConfig(machineId)
        end

        TriggerClientEvent("core-laundry:nuiMessage", source, "setAdminSettings", BuildSettingsForNUI())
        TriggerClientEvent("core-laundry:nuiMessage", source, "updateMachines", { machines = GetLaundryListForNUI() })
        Functions.Notify(source, Functions.NotifyTypes.Success, "Configurações salvas com sucesso.")

        Functions.Log("LAVAGEM-CONFIG", {
            message   = Functions.FullName(user_id) .. " #" .. user_id .. " atualizou as configurações da lavagem pelo painel admin",
            adminName = Functions.FullName(user_id),
            adminId   = user_id,
        })

        return
    end

    if action == "deleteMachine" then
        local targetId = tostring(data.id or "")

        if targetId == "" or not Laundry.Laundries[targetId] then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Máquina não encontrada.")
            return
        end

        DeleteLaundry(targetId)
        Laundry.Laundries[targetId] = nil
        MachineCache[targetId] = nil

        TriggerClientEvent("core-laundry:syncLaundries", -1, Laundry.Laundries)
        TriggerClientEvent("core-laundry:nuiMessage", source, "updateMachines", { machines = GetLaundryListForNUI() })
        Functions.Notify(source, Functions.NotifyTypes.Success, "Máquina removida com sucesso.")

        Functions.Log("REMOVEU-LAVAGEM", {
            message   = Functions.FullName(user_id) .. " #" .. user_id .. " removeu a máquina de lavagem " .. targetId,
            adminName = Functions.FullName(user_id),
            adminId   = user_id,
            Maquina   = targetId,
        })

        return
    end

    if action == "teleportToMachine" then
        local targetId = tostring(data.id or "")
        local laundry = Laundry.Laundries[targetId]

        if not laundry then
            Functions.Notify(source, Functions.NotifyTypes.Denied, "Máquina não encontrada.")
            return
        end

        local coords = laundry.Machine.Coords
        TriggerClientEvent("core-laundry:teleport", source, coords.x, coords.y, coords.z, coords.w)
        return
    end

    if action == "refreshMachines" then
        TriggerClientEvent("core-laundry:nuiMessage", source, "updateMachines", { machines = GetLaundryListForNUI() })
        return
    end

    if action == "openAdmin" then
        TriggerClientEvent("core-laundry:nuiMessage", source, "openAdmin", { machines = GetLaundryListForNUI(), settings = BuildSettingsForNUI() })
        return
    end
end)

RegisterNetEvent("core-laundry:requestAdmin", function()
    local source = source
    local user_id = Functions.Passport(source)

    if not user_id then return end
    if not Functions.HasGroup(user_id, AdminPermission, 1) then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    TriggerClientEvent("core-laundry:openAdminPanel", source, GetLaundryListForNUI(), BuildSettingsForNUI())
end)

RegisterCommand(Laundry.Admin.Command or "laundryadmin", function(source)
    if source == 0 then return end
    local user_id = Functions.Passport(source)

    if not user_id then return end
    if not Functions.HasGroup(user_id, AdminPermission, 1) then
        Functions.Notify(source, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    TriggerClientEvent("core-laundry:openAdminPanel", source, GetLaundryListForNUI(), BuildSettingsForNUI())
end, false)

RegisterNetEvent("core-laundry:placementResult", function(confirmed, coords)
    local source = source

    if confirmed and coords then
        TriggerClientEvent("core-laundry:nuiMessage", source, "setPlacementCoords", {
            x = coords[1],
            y = coords[2],
            z = coords[3],
            h = coords[4],
        })
    end

    TriggerClientEvent("core-laundry:openAdminRestore", source)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for _, machine in pairs(MachineCache) do
        machine.updated_at = os.time()

        local query = ([[
            UPDATE `%s` SET
                `cleaners_owned` = ?, `efficiency_level` = ?, `power_level` = ?,
                `is_washing` = ?, `is_done` = ?,
                `wash_amount` = ?, `wash_result` = ?, `wash_cleaners` = ?,
                `wash_duration` = ?, `wash_started_at` = ?, `wash_ends_at` = ?,
                `updated_at` = ?
            WHERE `machine_id` = ?
        ]]):format(TableName)

        local params = {
            machine.cleaners_owned, machine.efficiency_level, machine.power_level,
            machine.is_washing and 1 or 0, machine.is_done and 1 or 0,
            machine.wash_amount, machine.wash_result, machine.wash_cleaners,
            machine.wash_duration, machine.wash_started_at, machine.wash_ends_at,
            machine.updated_at, machine.machine_id
        }

        MySQL.update(query, params, function() end)
    end
end)

AddEventHandler("playerDropped", function()
    RemoveWatcher(source)
end)
