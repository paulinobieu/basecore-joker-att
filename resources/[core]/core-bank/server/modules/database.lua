-----------------------------------------------------------------------------------------------------------------------------------------
-- SCHEMA
-- Tabelas próprias do resource. Datas são unix timestamp inteiro: o servidor
-- grava número e a interface formata, sem depender de fuso ou de parser.
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.DatabaseReady(function()
    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_accounts` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `passport` INT NOT NULL,
            `name` VARCHAR(32) NOT NULL,
            `business` TINYINT(1) NOT NULL DEFAULT 0,
            `balance` BIGINT NOT NULL DEFAULT 0,
            `created_at` INT NOT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_passport` (`passport`, `business`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_members` (
            `account_id` BIGINT NOT NULL,
            `passport` INT NOT NULL,
            `created_at` INT NOT NULL,
            PRIMARY KEY (`account_id`, `passport`),
            KEY `idx_passport` (`passport`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_invites` (
            `account_id` BIGINT NOT NULL,
            `passport` INT NOT NULL,
            `created_at` INT NOT NULL,
            PRIMARY KEY (`account_id`, `passport`),
            KEY `idx_passport` (`passport`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_pix_keys` (
            `key` VARCHAR(32) NOT NULL,
            `account_id` BIGINT NOT NULL,
            `created_at` INT NOT NULL,
            PRIMARY KEY (`key`),
            KEY `idx_account` (`account_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_transactions` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `payer_id` BIGINT NOT NULL DEFAULT 0,
            `payee_id` BIGINT NOT NULL DEFAULT 0,
            `type` VARCHAR(24) NOT NULL,
            `amount` BIGINT NOT NULL,
            `description` VARCHAR(96) DEFAULT NULL,
            `author` VARCHAR(64) DEFAULT NULL,
            `created_at` INT NOT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_payer` (`payer_id`, `created_at`),
            KEY `idx_payee` (`payee_id`, `created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_invoices` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `issuer_id` BIGINT NOT NULL,
            `target_id` BIGINT NOT NULL,
            `amount` BIGINT NOT NULL,
            `reason` VARCHAR(64) NOT NULL,
            `status` ENUM('pending','paid','canceled') NOT NULL DEFAULT 'pending',
            `created_at` INT NOT NULL,
            `paid_at` INT DEFAULT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_target` (`target_id`, `status`),
            KEY `idx_issuer` (`issuer_id`, `status`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_fines` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `passport` INT NOT NULL,
            `officer` INT DEFAULT NULL,
            `amount` BIGINT NOT NULL,
            `description` TEXT DEFAULT NULL,
            `infractions` TEXT DEFAULT NULL,
            `arrest_id` BIGINT DEFAULT NULL,
            `created_at` INT NOT NULL,
            `paid_at` INT DEFAULT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_passport` (`passport`, `paid_at`),
            KEY `idx_arrest` (`arrest_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_investments` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `account_id` BIGINT NOT NULL,
            `code` VARCHAR(32) NOT NULL,
            `amount` BIGINT NOT NULL,
            `revenue` BIGINT NOT NULL DEFAULT 0,
            `yield_at` INT NOT NULL,
            `created_at` INT NOT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_account` (`account_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_cryptos` (
            `account_id` BIGINT NOT NULL,
            `asset` VARCHAR(16) NOT NULL,
            `amount` DECIMAL(24,8) NOT NULL DEFAULT 0,
            PRIMARY KEY (`account_id`, `asset`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])

    Framework.Query([[
        CREATE TABLE IF NOT EXISTS `core_bank_charts` (
            `day` INT NOT NULL,
            `account_id` BIGINT NOT NULL,
            `balance` BIGINT NOT NULL DEFAULT 0,
            PRIMARY KEY (`day`, `account_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAS
-----------------------------------------------------------------------------------------------------------------------------------------
function FindPersonalAccount(Passport)
    local Rows = Framework.Query(
        "SELECT * FROM `core_bank_accounts` WHERE `passport` = ? AND `business` = 0 LIMIT 1",
        { Passport }
    )

    return Rows and Rows[1] or false
end

function FindAccount(AccountId)
    local Rows = Framework.Query(
        "SELECT * FROM `core_bank_accounts` WHERE `id` = ? LIMIT 1",
        { AccountId }
    )

    return Rows and Rows[1] or false
end

--- Conta pessoal + empresas em que o passaporte é dono ou sócio.
function FindAccountsOf(Passport)
    return Framework.Query([[
        SELECT `accounts`.*
          FROM `core_bank_accounts` AS `accounts`
          LEFT JOIN `core_bank_members` AS `members`
            ON `members`.`account_id` = `accounts`.`id`
           AND `members`.`passport` = ?
         WHERE `accounts`.`passport` = ? OR `members`.`passport` IS NOT NULL
         ORDER BY `accounts`.`business` ASC, `accounts`.`id` ASC
    ]], { Passport, Passport }) or {}
end

function InsertAccount(Passport, Name, Business, Timestamp)
    return Framework.Insert(
        "INSERT INTO `core_bank_accounts` (`passport`, `name`, `business`, `created_at`) VALUES (?, ?, ?, ?)",
        { Passport, Name, Business, Timestamp }
    )
end

function CountBusiness(Passport)
    local Rows = Framework.Query(
        "SELECT COUNT(*) AS `total` FROM `core_bank_accounts` WHERE `passport` = ? AND `business` = 1",
        { Passport }
    )

    return Rows and Rows[1] and parseInt(Rows[1].total) or 0
end

function UpdateAccountBalance(AccountId, Balance)
    Framework.Execute(
        "UPDATE `core_bank_accounts` SET `balance` = ? WHERE `id` = ?",
        { Balance, AccountId }
    )
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SÓCIOS E CONVITES
-----------------------------------------------------------------------------------------------------------------------------------------
function FindMembers(AccountId)
    return Framework.Query(
        "SELECT `passport`, `created_at` FROM `core_bank_members` WHERE `account_id` = ? ORDER BY `created_at` ASC",
        { AccountId }
    ) or {}
end

function CountMembers(AccountId)
    local Rows = Framework.Query(
        "SELECT COUNT(*) AS `total` FROM `core_bank_members` WHERE `account_id` = ?",
        { AccountId }
    )

    return Rows and Rows[1] and parseInt(Rows[1].total) or 0
end

function IsMember(AccountId, Passport)
    local Rows = Framework.Query(
        "SELECT 1 FROM `core_bank_members` WHERE `account_id` = ? AND `passport` = ? LIMIT 1",
        { AccountId, Passport }
    )

    return Rows and Rows[1] and true or false
end

function InsertMember(AccountId, Passport, Timestamp)
    Framework.Execute(
        "INSERT IGNORE INTO `core_bank_members` (`account_id`, `passport`, `created_at`) VALUES (?, ?, ?)",
        { AccountId, Passport, Timestamp }
    )
end

function DeleteMember(AccountId, Passport)
    Framework.Execute(
        "DELETE FROM `core_bank_members` WHERE `account_id` = ? AND `passport` = ?",
        { AccountId, Passport }
    )
end

function FindInvites(Passport)
    return Framework.Query([[
        SELECT `invites`.`account_id`,
               `invites`.`created_at`,
               `accounts`.`name`,
               `accounts`.`passport` AS `owner`
          FROM `core_bank_invites` AS `invites`
          INNER JOIN `core_bank_accounts` AS `accounts`
            ON `accounts`.`id` = `invites`.`account_id`
         WHERE `invites`.`passport` = ?
         ORDER BY `invites`.`created_at` DESC
    ]], { Passport }) or {}
end

function HasInvite(AccountId, Passport)
    local Rows = Framework.Query(
        "SELECT 1 FROM `core_bank_invites` WHERE `account_id` = ? AND `passport` = ? LIMIT 1",
        { AccountId, Passport }
    )

    return Rows and Rows[1] and true or false
end

function InsertInvite(AccountId, Passport, Timestamp)
    Framework.Execute(
        "INSERT IGNORE INTO `core_bank_invites` (`account_id`, `passport`, `created_at`) VALUES (?, ?, ?)",
        { AccountId, Passport, Timestamp }
    )
end

function DeleteInvite(AccountId, Passport)
    Framework.Execute(
        "DELETE FROM `core_bank_invites` WHERE `account_id` = ? AND `passport` = ?",
        { AccountId, Passport }
    )
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAVES PIX
-----------------------------------------------------------------------------------------------------------------------------------------
function FindPixKeys(AccountId)
    return Framework.Query(
        "SELECT `key`, `created_at` FROM `core_bank_pix_keys` WHERE `account_id` = ? ORDER BY `created_at` ASC",
        { AccountId }
    ) or {}
end

function FindPixOwner(Key)
    local Rows = Framework.Query(
        "SELECT `account_id` FROM `core_bank_pix_keys` WHERE `key` = ? LIMIT 1",
        { Key }
    )

    return Rows and Rows[1] and parseInt(Rows[1].account_id) or false
end

--- Devolve false quando a chave já existe: a chave é primary key.
function InsertPixKey(AccountId, Key, Timestamp)
    local Affected = Framework.Execute(
        "INSERT IGNORE INTO `core_bank_pix_keys` (`key`, `account_id`, `created_at`) VALUES (?, ?, ?)",
        { Key, AccountId, Timestamp }
    )

    return parseInt(Affected) > 0
end

function DeletePixKey(AccountId, Key)
    Framework.Execute(
        "DELETE FROM `core_bank_pix_keys` WHERE `account_id` = ? AND `key` = ?",
        { AccountId, Key }
    )
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EXTRATO
-- Uma linha cobre os dois lados: quem pagou e quem recebeu. Conta 0 é o mundo
-- fora do banco (dinheiro em mãos, sistema, corretora).
-----------------------------------------------------------------------------------------------------------------------------------------
function InsertTransaction(PayerId, PayeeId, Type, Amount, Description, Author, Timestamp)
    Framework.Execute([[
        INSERT INTO `core_bank_transactions`
            (`payer_id`, `payee_id`, `type`, `amount`, `description`, `author`, `created_at`)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], { PayerId, PayeeId, Type, Amount, Description, Author, Timestamp })
end

function FindTransactions(AccountId, Limit)
    return Framework.Query([[
        SELECT `id`, `payer_id`, `payee_id`, `type`, `amount`, `description`, `author`, `created_at`
          FROM `core_bank_transactions`
         WHERE `payer_id` = ? OR `payee_id` = ?
         ORDER BY `created_at` DESC, `id` DESC
         LIMIT ?
    ]], { AccountId, AccountId, Limit }) or {}
end

function FindTransactionsByType(AccountId, Type, Limit)
    return Framework.Query([[
        SELECT `id`, `payer_id`, `payee_id`, `type`, `amount`, `description`, `author`, `created_at`
          FROM `core_bank_transactions`
         WHERE (`payer_id` = ? OR `payee_id` = ?) AND `type` = ?
         ORDER BY `created_at` DESC, `id` DESC
         LIMIT ?
    ]], { AccountId, AccountId, Type, Limit }) or {}
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GRÁFICO
-----------------------------------------------------------------------------------------------------------------------------------------
function SaveChartPoint(Day, AccountId, Balance)
    Framework.Execute([[
        INSERT INTO `core_bank_charts` (`day`, `account_id`, `balance`)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE `balance` = VALUES(`balance`)
    ]], { Day, AccountId, Balance })
end

function FindChart(AccountId, Days)
    return Framework.Query([[
        SELECT `day`, `balance`
          FROM `core_bank_charts`
         WHERE `account_id` = ?
         ORDER BY `day` DESC
         LIMIT ?
    ]], { AccountId, Days }) or {}
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FATURAS
-----------------------------------------------------------------------------------------------------------------------------------------
function FindInvoice(InvoiceId)
    local Rows = Framework.Query(
        "SELECT * FROM `core_bank_invoices` WHERE `id` = ? LIMIT 1",
        { InvoiceId }
    )

    return Rows and Rows[1] or false
end

function FindInvoicesFor(AccountId, Limit)
    return Framework.Query([[
        SELECT * FROM `core_bank_invoices`
         WHERE `target_id` = ?
         ORDER BY `status` = 'pending' DESC, `created_at` DESC
         LIMIT ?
    ]], { AccountId, Limit }) or {}
end

function FindInvoicesBy(AccountId, Limit)
    return Framework.Query([[
        SELECT * FROM `core_bank_invoices`
         WHERE `issuer_id` = ?
         ORDER BY `status` = 'pending' DESC, `created_at` DESC
         LIMIT ?
    ]], { AccountId, Limit }) or {}
end

--- Imposto vencido: fatura do sistema (emissor 0) fora da carência.
function HasOverdueTax(AccountId, Deadline)
    local Rows = Framework.Query([[
        SELECT 1 FROM `core_bank_invoices`
         WHERE `target_id` = ? AND `issuer_id` = 0 AND `status` = 'pending' AND `created_at` < ?
         LIMIT 1
    ]], { AccountId, Deadline })

    return Rows and Rows[1] and true or false
end

function CountPendingInvoices(AccountId)
    local Rows = Framework.Query(
        "SELECT COUNT(*) AS `total` FROM `core_bank_invoices` WHERE `issuer_id` = ? AND `status` = 'pending'",
        { AccountId }
    )

    return Rows and Rows[1] and parseInt(Rows[1].total) or 0
end

function InsertInvoice(IssuerId, TargetId, Amount, Reason, Timestamp)
    return Framework.Insert([[
        INSERT INTO `core_bank_invoices` (`issuer_id`, `target_id`, `amount`, `reason`, `created_at`)
        VALUES (?, ?, ?, ?, ?)
    ]], { IssuerId, TargetId, Amount, Reason, Timestamp })
end

--- Só fecha a fatura que ainda está pendente: evita pagamento duplicado.
function CloseInvoice(InvoiceId, Status, Timestamp)
    local Affected = Framework.Execute(
        "UPDATE `core_bank_invoices` SET `status` = ?, `paid_at` = ? WHERE `id` = ? AND `status` = 'pending'",
        { Status, Timestamp, InvoiceId }
    )

    return parseInt(Affected) > 0
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MULTAS
-----------------------------------------------------------------------------------------------------------------------------------------
function FindFine(FineId)
    local Rows = Framework.Query(
        "SELECT * FROM `core_bank_fines` WHERE `id` = ? LIMIT 1",
        { FineId }
    )

    return Rows and Rows[1] or false
end

function FindFineByArrest(ArrestId)
    local Rows = Framework.Query(
        "SELECT * FROM `core_bank_fines` WHERE `arrest_id` = ? ORDER BY `id` DESC LIMIT 1",
        { ArrestId }
    )

    return Rows and Rows[1] or false
end

function FindFinesOf(Passport, IncludePaid)
    if IncludePaid then
        return Framework.Query([[
            SELECT * FROM `core_bank_fines`
             WHERE `passport` = ?
             ORDER BY `paid_at` IS NOT NULL ASC, `created_at` DESC
        ]], { Passport }) or {}
    end

    return Framework.Query([[
        SELECT * FROM `core_bank_fines`
         WHERE `passport` = ? AND `paid_at` IS NULL
         ORDER BY `created_at` DESC
    ]], { Passport }) or {}
end

--- Débito vencido: só conta depois da carência configurada.
function HasOverdueFine(Passport, Deadline)
    local Rows = Framework.Query(
        "SELECT 1 FROM `core_bank_fines` WHERE `passport` = ? AND `paid_at` IS NULL AND `created_at` < ? LIMIT 1",
        { Passport, Deadline }
    )

    return Rows and Rows[1] and true or false
end

function InsertFine(Passport, Officer, Amount, Description, Infractions, ArrestId, Timestamp)
    return Framework.Insert([[
        INSERT INTO `core_bank_fines`
            (`passport`, `officer`, `amount`, `description`, `infractions`, `arrest_id`, `created_at`)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], { Passport, Officer, Amount, Description, Infractions, ArrestId, Timestamp })
end

function CloseFine(FineId, Timestamp)
    local Affected = Framework.Execute(
        "UPDATE `core_bank_fines` SET `paid_at` = ? WHERE `id` = ? AND `paid_at` IS NULL",
        { Timestamp, FineId }
    )

    return parseInt(Affected) > 0
end

function DeleteFine(FineId)
    local Affected = Framework.Execute(
        "DELETE FROM `core_bank_fines` WHERE `id` = ?",
        { FineId }
    )

    return parseInt(Affected) > 0
end

function DeleteFinesByArrest(ArrestId)
    Framework.Execute("DELETE FROM `core_bank_fines` WHERE `arrest_id` = ?", { ArrestId })
end

function DeleteFinesOf(Passport)
    Framework.Execute("DELETE FROM `core_bank_fines` WHERE `passport` = ?", { Passport })
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- INVESTIMENTOS
-----------------------------------------------------------------------------------------------------------------------------------------
function FindPosition(PositionId)
    local Rows = Framework.Query(
        "SELECT * FROM `core_bank_investments` WHERE `id` = ? LIMIT 1",
        { PositionId }
    )

    return Rows and Rows[1] or false
end

function FindPositions(AccountId)
    return Framework.Query(
        "SELECT * FROM `core_bank_investments` WHERE `account_id` = ? ORDER BY `created_at` ASC",
        { AccountId }
    ) or {}
end

function FindMaturedPositions(Timestamp)
    return Framework.Query(
        "SELECT * FROM `core_bank_investments` WHERE `yield_at` <= ?",
        { Timestamp }
    ) or {}
end

function InsertPosition(AccountId, Code, Amount, YieldAt, Timestamp)
    return Framework.Insert([[
        INSERT INTO `core_bank_investments` (`account_id`, `code`, `amount`, `yield_at`, `created_at`)
        VALUES (?, ?, ?, ?, ?)
    ]], { AccountId, Code, Amount, YieldAt, Timestamp })
end

function UpdatePositionYield(PositionId, Revenue, YieldAt)
    Framework.Execute(
        "UPDATE `core_bank_investments` SET `revenue` = ?, `yield_at` = ? WHERE `id` = ?",
        { Revenue, YieldAt, PositionId }
    )
end

--- Só apaga a aplicação que ainda existe: evita resgate duplicado.
function DeletePosition(PositionId)
    local Affected = Framework.Execute(
        "DELETE FROM `core_bank_investments` WHERE `id` = ?",
        { PositionId }
    )

    return parseInt(Affected) > 0
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CARTEIRA DE CRIPTOMOEDAS
-----------------------------------------------------------------------------------------------------------------------------------------
function FindWallet(AccountId)
    return Framework.Query(
        "SELECT `asset`, `amount` FROM `core_bank_cryptos` WHERE `account_id` = ? AND `amount` > 0",
        { AccountId }
    ) or {}
end

function FindWalletAsset(AccountId, Asset)
    local Rows = Framework.Query(
        "SELECT `amount` FROM `core_bank_cryptos` WHERE `account_id` = ? AND `asset` = ? LIMIT 1",
        { AccountId, Asset }
    )

    return Rows and Rows[1] and tonumber(Rows[1].amount) or 0.0
end

function SaveWalletAsset(AccountId, Asset, Amount)
    Framework.Execute([[
        INSERT INTO `core_bank_cryptos` (`account_id`, `asset`, `amount`)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE `amount` = VALUES(`amount`)
    ]], { AccountId, Asset, Amount })
end
