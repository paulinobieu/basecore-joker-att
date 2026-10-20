CREATE TABLE IF NOT EXISTS `accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Whitelist` tinyint(1) NOT NULL DEFAULT 0,
  `Characters` int(10) NOT NULL DEFAULT 1,
  `Gemstone` bigint(20) NOT NULL DEFAULT 0,
  `Discord` varchar(50) NOT NULL DEFAULT '0',
  `License` varchar(50) NOT NULL DEFAULT '0',
  `Login` bigint(20) NOT NULL DEFAULT current_timestamp(),
  `Token` varchar(10) DEFAULT '0',
  `Banned` bigint(20) NOT NULL DEFAULT 0,
  `Reason` varchar(254) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `Discord` (`Discord`),
  KEY `License` (`License`),
  KEY `Token` (`Token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `avatars` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Image` text DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `characters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT 'Individuo',
  `Lastname` varchar(50) DEFAULT 'Indigente',
  `License` varchar(50) DEFAULT NULL,
  `Bank` bigint(20) NOT NULL DEFAULT 5000,
  `Blood` int(1) NOT NULL DEFAULT 1,
  `Prison` int(10) NOT NULL DEFAULT 0,
  `Killed` int(10) NOT NULL DEFAULT 0,
  `Death` int(10) NOT NULL DEFAULT 0,
  `Daily` varchar(20) NOT NULL DEFAULT '09-01-1990-0',
  `Created` bigint(20) NOT NULL DEFAULT current_timestamp(),
  `Login` bigint(20) NOT NULL DEFAULT current_timestamp(),
  `Skin` varchar(50) NOT NULL DEFAULT 'mp_m_freemode_01',
  `SkinMontly` bigint(20) NOT NULL DEFAULT 0,
  `Deleted` tinyint(1) NOT NULL DEFAULT 0,
  `Phone` varchar(50) DEFAULT NULL,
  `Sex` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Discord` (`License`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `chests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) NOT NULL,
  `Weight` bigint(20) NOT NULL DEFAULT 500,
  `Slots` int(10) NOT NULL DEFAULT 50,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `dependents` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Dependent` int(10) NOT NULL DEFAULT 0,
  `Name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Passport` (`Passport`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `ems_creative_consultations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Reason` varchar(255) NOT NULL DEFAULT '',
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Doctor` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Status` varchar(255) NOT NULL DEFAULT 'appointment',
  `Description` longtext DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `ems_creative_exams` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL DEFAULT '',
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Doctor` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Status` varchar(255) NOT NULL DEFAULT 'appointment',
  `Description` longtext DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `ems_creative_specialties` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Name` varchar(150) NOT NULL DEFAULT 'Médico',
  `Members` longtext NOT NULL DEFAULT '[]',
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `entitydata` (
  `Name` varchar(100) NOT NULL,
  `Information` longtext DEFAULT NULL,
  PRIMARY KEY (`Name`),
  UNIQUE KEY `unique_name` (`Name`),
  KEY `Information` (`Name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `fuelstations_creative` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  `Name` varchar(100) NOT NULL DEFAULT 'Posto de Combustível',
  `Color` int(3) NOT NULL DEFAULT 47,
  `Blip` int(3) NOT NULL DEFAULT 361,
  `Stock` int(9) NOT NULL DEFAULT 0,
  `FuelPrice` decimal(5,1) NOT NULL DEFAULT 5.0,
  `MoneyEarned` bigint(20) NOT NULL DEFAULT 0,
  `MoneySpent` bigint(20) NOT NULL DEFAULT 0,
  `FuelImported` bigint(20) NOT NULL DEFAULT 0,
  `Visits` bigint(20) NOT NULL DEFAULT 0,
  `Empty` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `hwid` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Account` bigint(20) NOT NULL DEFAULT 1,
  `Token` varchar(250) NOT NULL DEFAULT '0',
  `Banned` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_arrest` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Officer` bigint(20) NOT NULL DEFAULT 0,
  `Officers` longtext DEFAULT NULL,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Infractions` longtext DEFAULT NULL,
  `Arrest` bigint(20) NOT NULL DEFAULT 0,
  `Fine` bigint(20) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_board` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Title` varchar(100) NOT NULL,
  `Description` longtext DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_internalaffairs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Title` text DEFAULT NULL,
  `Suspect` bigint(20) NOT NULL DEFAULT 0,
  `Officer` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  `Archive` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_medals` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  `Image` text NOT NULL DEFAULT '',
  `Name` varchar(150) NOT NULL DEFAULT 'Honra ao Mérito',
  `Officers` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_penalcode_sections` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Type` varchar(10) NOT NULL,
  `Title` varchar(100) NOT NULL,
  `Description` longtext DEFAULT NULL,
  `Order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_penalcode_articles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Section` bigint(20) NOT NULL DEFAULT 0,
  `Article` varchar(250) NOT NULL,
  `Contravention` varchar(250) NOT NULL,
  `Fine` bigint(20) NOT NULL DEFAULT 0,
  `Arrest` bigint(20) NOT NULL DEFAULT 0,
  `Bail` bigint(20) NOT NULL DEFAULT 0,
  `Order` int(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `MDT_Section` (`Section`),
  CONSTRAINT `MDT_Section` FOREIGN KEY (`Section`) REFERENCES `mdt_creative_penalcode_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_reports` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Title` text DEFAULT NULL,
  `Suspects` longtext NOT NULL DEFAULT '[]',
  `Officer` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  `Archive` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_units` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Image` text NOT NULL DEFAULT '',
  `Name` varchar(150) NOT NULL DEFAULT 'Civil',
  `Permission` varchar(100) NOT NULL DEFAULT '',
  `Officers` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_vehicles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Officer` bigint(20) NOT NULL DEFAULT 0,
  `Image` text NOT NULL DEFAULT '',
  `Vehicle` varchar(100) DEFAULT NULL,
  `Plate` varchar(10) DEFAULT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_wanted` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Image` text DEFAULT NULL,
  `Accusations` longtext DEFAULT NULL,
  `Officer` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `HowLong` int(5) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `mdt_creative_warning` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Officer` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `painel_creative_announcements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Title` text DEFAULT NULL,
  `Description` longtext DEFAULT NULL,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Updated` bigint(20) DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `painel_creative_paramedic` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Doctor` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Description` longtext DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `painel_creative_tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Image` text NOT NULL DEFAULT '',
  `Name` varchar(150) NOT NULL DEFAULT 'Recruta',
  `Members` longtext NOT NULL DEFAULT '[]',
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `painel_creative_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Type` varchar(50) NOT NULL DEFAULT 'Deposit',
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Value` bigint(20) NOT NULL DEFAULT 0,
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  `Transfer` bigint(20) DEFAULT NULL,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Permission` varchar(100) NOT NULL DEFAULT '',
  `Members` int(10) NOT NULL DEFAULT 10,
  `Tags` int(10) NOT NULL DEFAULT 3,
  `Announces` int(10) NOT NULL DEFAULT 3,
  `Experience` bigint(20) NOT NULL DEFAULT 0,
  `Points` bigint(20) NOT NULL DEFAULT 0,
  `Bank` bigint(20) NOT NULL DEFAULT 0,
  `Premium` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `playerdata` (
  `Passport` bigint(20) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Information` longtext DEFAULT NULL,
  PRIMARY KEY (`Passport`,`Name`),
  KEY `Passport` (`Passport`),
  KEY `Information` (`Name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `propertys` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT 'Homes0001',
  `Interior` varchar(20) NOT NULL DEFAULT 'Middle',
  `Item` bigint(20) NOT NULL DEFAULT 3,
  `Tax` bigint(20) NOT NULL DEFAULT 0,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Serial` varchar(10) NOT NULL,
  `Vault` bigint(20) NOT NULL DEFAULT 1,
  `Fridge` bigint(20) NOT NULL DEFAULT 1,
  `Garage` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `Passport` (`Passport`),
  KEY `Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `races` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL DEFAULT 'Indivíduo Indigente',
  `Mode` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `Race` smallint(5) unsigned NOT NULL DEFAULT 0,
  `Passport` int(10) unsigned NOT NULL DEFAULT 0,
  `Vehicle` varchar(50) NOT NULL DEFAULT 'Sultan RS',
  `Points` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_race_player` (`Mode`,`Race`,`Passport`),
  KEY `Points` (`Points`),
  KEY `Name` (`Name`),
  KEY `Vehicle` (`Vehicle`),
  KEY `Passport` (`Passport`),
  KEY `Race` (`Race`),
  KEY `Mode` (`Mode`),
  KEY `idx_races_race_points` (`Race`,`Points`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `Vehicle` varchar(100) DEFAULT NULL,
  `Tax` bigint(20) NOT NULL DEFAULT 0,
  `Plate` varchar(10) DEFAULT NULL,
  `Weight` bigint(20) NOT NULL DEFAULT 0,
  `Save` varchar(50) NOT NULL DEFAULT '1',
  `Rental` bigint(20) NOT NULL DEFAULT 0,
  `Arrest` tinyint(1) NOT NULL DEFAULT 0,
  `Block` tinyint(1) NOT NULL DEFAULT 0,
  `Engine` int(4) NOT NULL DEFAULT 1000,
  `Body` int(4) NOT NULL DEFAULT 1000,
  `Health` int(4) NOT NULL DEFAULT 1000,
  `Fuel` int(3) NOT NULL DEFAULT 100,
  `Nitro` int(5) NOT NULL DEFAULT 0,
  `Work` tinyint(1) NOT NULL DEFAULT 0,
  `Doors` longtext DEFAULT NULL,
  `Windows` longtext DEFAULT NULL,
  `Tyres` longtext DEFAULT NULL,
  `Seatbelt` tinyint(1) NOT NULL DEFAULT 0,
  `Drift` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `Passport` (`Passport`),
  KEY `Vehicle` (`Vehicle`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tickets_creative` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Subject` varchar(255) NOT NULL DEFAULT '',
  `Category` varchar(100) NOT NULL DEFAULT '',
  `Assumed` bigint(20) DEFAULT NULL,
  `Status` tinyint(1) NOT NULL DEFAULT 1,
  `CreatedAt` bigint(20) DEFAULT NULL,
  `ClosedAt` bigint(20) DEFAULT NULL,
  `Author` bigint(20) NOT NULL DEFAULT 0,
  `Members` longtext DEFAULT NULL,
  `MessageAdmin` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tickets_creative_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Ticket` bigint(20) NOT NULL DEFAULT 0,
  `Type` varchar(100) NOT NULL DEFAULT 'User',
  `Author` bigint(20) DEFAULT NULL,
  `Staff` tinyint(1) NOT NULL DEFAULT 0,
  `Message` longtext DEFAULT NULL,
  `CreatedAt` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_tickets_creative_messages_tickets_creative` (`Ticket`),
  CONSTRAINT `FK_tickets_creative_messages_tickets_creative` FOREIGN KEY (`Ticket`) REFERENCES `tickets_creative` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `codes_creative` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Code` varchar(50) NOT NULL DEFAULT '',
  `Rewards` longtext DEFAULT NULL,
  `Max` int(9) NOT NULL DEFAULT 1,
  `Used` int(9) NOT NULL DEFAULT 0,
  `CreatedAt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `codes_creative_redeemd` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Code` varchar(50) NOT NULL DEFAULT '',
  `Passport` bigint(20) NOT NULL DEFAULT 0,
  `RedeemdAt` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `deaths_creative` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `Attacker` bigint(20) NOT NULL DEFAULT 0,
  `Victim` bigint(20) NOT NULL DEFAULT 0,
  `Weapon` varchar(50) NOT NULL DEFAULT 'WEAPON_PISTOL',
  `Timestamp` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `entitydata` (`Name`, `Information`) VALUES ('Permissions:Admin', '{\"1\":1}');

CREATE TABLE IF NOT EXISTS `bank_joint_invites` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_id` INT NOT NULL,
  `inviter_id` INT NOT NULL,
  `inviter_name` VARCHAR(100) NOT NULL,
  `invitee_id` INT NOT NULL,
  `account_name` VARCHAR(100) NOT NULL,
  `account_type` VARCHAR(50) NOT NULL,
  `status` ENUM('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_invitee_status` (`invitee_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `core_craft` (
  `StationKey` varchar(100) NOT NULL,
  `Data` longtext NOT NULL DEFAULT '{}',
  PRIMARY KEY (`StationKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
