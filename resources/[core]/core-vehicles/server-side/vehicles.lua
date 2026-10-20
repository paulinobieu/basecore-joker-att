-- ------------------------------------------------
-- # Vehicle Data (Cache + DB)
-- ------------------------------------------------

loadingData = true

local vehiclesDatas = {}
local vehiclesOwners = {}

local vehiclesBorrowed = {}
local vehiclesBorrowedByPlate = {}

-- ------------------------------------------------
-- # Change Plate In Real-Time
-- ------------------------------------------------

changeVehiclePlateIRT = function(oldPlate,newPlate)

    if oldPlate and newPlate and type(newPlate) == 'string' then
        newPlate = newPlate:gsub('[%p%c]','')
        newPlate = newPlate:gsub(' ','')
        newPlate = newPlate:upper()
        if newPlate:match('%W') ~= nil then
            return false,'INVALID_NEW_PLATE'
        end
        if newPlate:len() <= 0 or newPlate:len() > 8 then
            return false,'INVALID_NEW_PLATE'
        end
        local result = query('SELECT * FROM `core_characters_vehicles` WHERE `plate` = \''..newPlate..'\';')
        if result and type(result) == 'table' and result[1] and result[1].owner then
            return false,'PLATE_ALREADY_IN_USE'
        end
        if vehiclesDatas[oldPlate] then
            execute('UPDATE `core_characters_vehicles` SET `plate` = \''..newPlate..'\' WHERE `plate` = \''..oldPlate..'\';')
            local vehicleData = cloneTable(vehiclesDatas[oldPlate])
            vehiclesDatas[newPlate] = vehicleData
            vehiclesDatas[newPlate].plate = newPlate
            if vehicleData.owner and vehiclesOwners[vehicleData.owner] and vehiclesOwners[vehicleData.owner][oldPlate] then
                vehiclesOwners[vehicleData.owner][oldPlate] = nil
                vehiclesOwners[vehicleData.owner][newPlate] = 1
                if debugMode then
                    print('[DEBUG] : changeVeiclePlateIRT setVehicleOwner -> '..newPlate..' = '..vehicleData.owner..'\n'..json.encode(vehiclesOwners[vehicleData.owner]))
                end
            end
            local friendId = vehiclesBorrowedByPlate[oldPlate]
            if friendId then
                vehiclesBorrowedByPlate[newPlate] = friendId
                if vehiclesBorrowed[friendId] and vehiclesBorrowed[friendId][oldPlate] then
                    vehiclesBorrowed[friendId][oldPlate] = nil
                    vehiclesBorrowed[friendId][newPlate] = 1
                end
                vehiclesBorrowedByPlate[oldPlate] = nil
                if debugMode then
                    print('[DEBUG] : changeVeiclePlateIRT setVeicleFriend -> '..newPlate..' = '..friendId)
                end
            end
            local networkVehicle,entityCoords = getNetVehicle(oldPlate,vehicleData.index)
            if networkVehicle then
                local state = GlobalState['core-cVehicles']
                if not state then
                    state = {}
                end
                state[newPlate] = { id = networkVehicle, model = GetHashKey(vehicleData.index), owner = vehicleData.owner }
                if state[oldPlate] then
                    state[oldPlate] = nil
                end
                GlobalState:set('core-cVehicles',state,false)
                local entity = NetworkGetEntityFromNetworkId(networkVehicle)
                if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
                    SetVehicleNumberPlateText(entity,newPlate)
                end
            end
            vehiclesDatas[oldPlate] = nil
            return true,'PLATE_CHANGED_IRT'
        end
        return false,'OLD_PLATE_NOT_FOUND'
    end
    return false,'INVALID_PARAMS'
end
exports('changeVehiclePlateIRT',changeVehiclePlateIRT)

-- ------------------------------------------------
-- # Database Init + Load
-- ------------------------------------------------

CreateThread(function()

    query([[CREATE TABLE IF NOT EXISTS `core_characters_vehicles_srvc` (`plate` varchar(8) NOT NULL DEFAULT '',`owner` int(11) DEFAULT 0,`index` varchar(255) DEFAULT '0',`mods` longtext DEFAULT NULL,PRIMARY KEY (`plate`),UNIQUE KEY `plate` (`plate`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;]])
    query([[CREATE TABLE IF NOT EXISTS `core_characters_vehicles` (`plate` varchar(8) NOT NULL, `owner` int(11) NOT NULL, `index` varchar(100) NOT NULL, `status` varchar(50) DEFAULT '', `tax` bigint(20) DEFAULT NULL, `health` longtext DEFAULT '{"body":1000,"engine":1000,"fuel":99}', `mods` longtext DEFAULT '[]', `damages` longtext DEFAULT '[]', `expire_time` bigint(20) DEFAULT 0, `expired` int(11) DEFAULT 0, PRIMARY KEY (`plate`), UNIQUE KEY `plate` (`plate`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;]])
    query([[CREATE TABLE IF NOT EXISTS `core_vehicles_stock` (`index` varchar(50) NOT NULL, `stock` int(3) DEFAULT 0, PRIMARY KEY (`index`) USING BTREE, UNIQUE KEY `index` (`index`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;]])
    query([[CREATE TABLE IF NOT EXISTS `core_vehicles_borrowed` (`plate` varchar(8) NOT NULL, `target` int(11) NOT NULL DEFAULT 0, PRIMARY KEY (`plate`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;]])
    local favoriteColumn = query([[SHOW COLUMNS FROM `core_characters_vehicles` LIKE 'favorite';]])
    if not favoriteColumn or not favoriteColumn[1] then
        query([[ALTER TABLE `core_characters_vehicles` ADD COLUMN `favorite` tinyint(1) NOT NULL DEFAULT 0 AFTER `expired`;]])
    end
    execute('UPDATE `core_characters_vehicles` SET `expired` = 1 WHERE `expire_time` > 0 AND `expire_time` <= '..os.time()..';')

    Wait(2000)

    vehiclesDatas,vehiclesOwners,vehiclesBorrowed,vehiclesBorrowedByPlate = loadCharactersVehicles()
    loadingData = false

    while true do
        execute('UPDATE `core_characters_vehicles` SET `expired` = 1 WHERE `expire_time` > 0 AND `expire_time` <= '..os.time()..';')
        Wait(900000)
    end

end)

local function databaseFlagEnabled(value)
    return value == true or value == 1 or value == '1'
end

loadCharactersVehicles = function()

    local total = 0
    local listDatas = {}
    local listOwners = {}
    local result = query('SELECT * FROM `core_characters_vehicles` WHERE `expired` = 0;')
    if result and type(result) == 'table' and #result > 0 then
        for _,v in pairs(result) do
            total = total + 1
            if not v.owner and v.characterOwner then
                v.owner = v.characterOwner
            end
            v.plate = v.plate:gsub(' ','')
            v.plate = v.plate:upper()
            local vhash = GetHashKey(v.index)
            listDatas[v.plate] = {
                plate = v.plate,
                owner = v.owner,
                index = v.index,
                hash = vhash,
                name = getVehicleName(vhash),
                category = getVehicleCategory(v.index),
                status = v.status,
                tax = v.tax,
                taxEndTime = (v.tax+(86400*vehicleTaxes.durationInDays)),
                health = json.decode(v.health) or {},
                mods = json.decode(v.mods) or {},
                damages = json.decode(v.damages) or {},
                expire_time = v.expire_time,
                favorite = databaseFlagEnabled(v.favorite)
            }
            if not listOwners[v.owner] then
                listOwners[v.owner] = {}
            end
            listOwners[v.owner][v.plate] = 1
        end
    end

    local totalBorrowed = 0
    local listBorrow = {}
    local listBorrowPlates = {}
    local result = query('SELECT * FROM `core_vehicles_borrowed`;')
    if result and type(result) == 'table' and #result > 0 then
        for _,v in pairs(result) do
            totalBorrowed = totalBorrowed + 1
            v.plate = v.plate:gsub(' ','')
            v.plate = v.plate:upper()
            if listDatas[v.plate] then
                if not listBorrow[v.target] then
                    listBorrow[v.target] = {}
                end
                listBorrow[v.target][v.plate] = 1
                listBorrowPlates[v.plate] = v.target
            else
                execute('DELETE FROM `core_vehicles_borrowed` WHERE `plate` = \''..v.plate..'\' AND `target` = \''..v.target..'\';')
            end
        end
    end

    _vehiclesVPrint('^0Loaded ^5'..total..' character ^0vehicles. (^5'..totalBorrowed..'^0 borrowed).')

    return listDatas,listOwners,listBorrow,listBorrowPlates

end
exports('loadCharactersVehicles',loadCharactersVehicles)

-- ------------------------------------------------
-- # Get Character Vehicles
-- ------------------------------------------------

local borrowedToCache = {}
getCharacterVehicles = function(characterId,includeBorrowed)

    local list = {}
    local count = 0

    if characterId and vehiclesOwners[characterId] then
        for plate,_ in pairs(vehiclesOwners[characterId]) do
            if vehiclesDatas[plate] then
                count = count + 1
                local v = vehiclesDatas[plate]
                if v then
                    if type(v.health) ~= 'table' or (type(v.health) == 'table' and type(v.health[1]) ~= 'number' or type(v.health[2]) ~= 'number' or type(v.health[3]) ~= 'number') then
                        v.health = { 1000.0, 1000.0, 100.0 }
                        execute('UPDATE `core_characters_vehicles` SET `health` = \''..json.encode(v.health)..'\' WHERE `plate` = \''..v.plate..'\';')
                    end
                    local _borrowedTo = nil
                    if vehiclesBorrowedByPlate[plate] then
                        if borrowedToCache[vehiclesBorrowedByPlate[plate]] then
                            _borrowedTo = borrowedToCache[vehiclesBorrowedByPlate[plate]]
                        else
                            local name = getCharacterIdentity(vehiclesBorrowedByPlate[plate])['name'] or 'Desconhecido'
                            _borrowedTo = name..' #'..vehiclesBorrowedByPlate[plate]
                            borrowedToCache[vehiclesBorrowedByPlate[plate]] = _borrowedTo
                        end
                    end
                    list[v.plate] = { borrowedTo = _borrowedTo, plate = plate, index = v.index, name = v.name, owner = v.owner, status = v.status, tax = v.taxEndTime, health = v.health, category = v.category, expire_time = v.expire_time, favorite = v.favorite == true, trunk = (vehlist[v.index] and vehlist[v.index].weights and vehlist[v.index].weights.trunk) or 0 }
                end
            end
        end
    end

    if includeBorrowed then
        if vehiclesBorrowed[characterId] then
            for plate,_ in pairs(vehiclesBorrowed[characterId]) do
                if vehiclesDatas[plate] and (vehiclesBorrowedByPlate[plate] and vehiclesBorrowedByPlate[plate] == characterId) then
                    local v = vehiclesDatas[plate]
                    if v then
                        if type(v.health) ~= 'table' or (type(v.health) == 'table' and type(v.health[1]) ~= 'number' or type(v.health[2]) ~= 'number' or type(v.health[3]) ~= 'number') then
                            v.health = { 1000.0, 1000.0, 100.0 }
                            execute('UPDATE `core_characters_vehicles` SET `health` = \''..json.encode(v.health)..'\' WHERE `plate` = \''..v.plate..'\';')
                        end
                        list[v.plate] = { borrowedFrom = true, plate = plate, index = v.index, name = v.name, owner = v.owner, status = v.status, tax = v.taxEndTime, health = v.health, category = v.category, expire_time = v.expire_time, favorite = false, trunk = (vehlist[v.index] and vehlist[v.index].weights and vehlist[v.index].weights.trunk) or 0 }
                    end
                end
            end
        end
    end

    return list,count

end
exports('getCharacterVehicles',getCharacterVehicles)

updateVehicleFavorite = function(characterId, vehiclePlate, favorite)
    if not characterId or type(vehiclePlate) ~= 'string' or type(favorite) ~= 'boolean' then
        return false,'INVALID_PARAMS'
    end

    vehiclePlate = vehiclePlate:gsub(' ',''):upper()
    if vehiclePlate:len() <= 0 or vehiclePlate:len() > 8 or not vehiclePlate:match('^[%w]+$') then
        return false,'INVALID_PLATE'
    end

    local vehicleData = vehiclesDatas[vehiclePlate]
    if not vehicleData then
        return false,'VEHICLE_NOT_FOUND'
    end
    if vehicleData.owner ~= characterId then
        return false,'NOT_VEHICLE_OWNER'
    end

    local affectedRows = exports.oxmysql:update_async(
        'UPDATE `core_characters_vehicles` SET `favorite` = ? WHERE `plate` = ? AND `owner` = ?',
        { favorite and 1 or 0, vehiclePlate, characterId }
    )
    if not affectedRows or affectedRows < 1 then
        return false,'DATABASE_ERROR'
    end

    vehicleData.favorite = favorite
    return true,favorite
end
exports('updateVehicleFavorite',updateVehicleFavorite)

-- ------------------------------------------------
-- # Generate Vehicle
-- ------------------------------------------------

generateVehicle = function(characterId,vehicleModel,customColors,customPlate)

    if not characterId or not vehicleModel then
        return false,'MISSING_PARAMS'
    end

    local vhash = GetHashKey(vehicleModel)
    local vinfo = getVehicleInfo(vhash)
    if not vinfo then
        return false,'MODEL_NOT_REGISTERED'
    end

    local vehColorPrimary = (customColors and type(customColors) == 'table' and #customColors == 2 and customColors[1] and type(customColors[1]) == 'table' and #customColors[1] == 3) and customColors[1] or {0,0,0}
    local vehColorSecondary = (customColors and type(customColors) == 'table' and #customColors == 2 and customColors[2] and type(customColors[2]) == 'table' and #customColors[2] == 3) and customColors[2] or {0,0,0}
    local vehPlate = (customPlate and isValidPlate(customPlate)) and customPlate:gsub(' ','') or generateNewPlate()
    local vehTax = os.time()
    
    local vdata = {
        plate = vehPlate,
        owner = characterId,
        index = vinfo.index,
        hash = vhash,
        name = vinfo.name,
        category = vinfo.category,
        status = '',
        tax = vehTax,
        taxEndTime = (vehTax+(86400*vehicleTaxes.durationInDays)),
        health = { 1000,1000,100 },
        mods = { ['c'] = { p = vehColorPrimary, s = vehColorSecondary } },
        damages = {},
        expire_time = 0
    }
    vehiclesDatas[vehPlate] = vdata

    execute([[
        INSERT INTO 
            `core_characters_vehicles` 
            (
                `plate`,
                `owner`,
                `index`,
                `status`,
                `tax`,
                `health`,
                `mods`,
                `damages`
            )
        VALUES
            (
                ']]..vehPlate..[[',
                ]]..characterId..[[,
                ']]..vdata.index..[[',
                '',
                ]]..vehTax..[[,
                ']]..json.encode(vdata.health)..[[',
                ']]..json.encode(vdata.mods)..[[',
                '[]'
            );
    ]])

    if not vehiclesOwners[characterId] then
        vehiclesOwners[characterId] = {}
    end
    vehiclesOwners[characterId][vehPlate] = 1
    
    return true,vehPlate
    
end
exports('generateVehicle',generateVehicle)

-- ------------------------------------------------
-- # Give Vehicle (export limpo)
-- ------------------------------------------------
-- Wrapper de generateVehicle pensado pra ser chamado de outros resources.
-- Recebe apenas (passport, model); aplica validação de modelo e de limite de
-- garagem. Retorna SEMPRE uma tabela (single-return é confiável via exports):
--
--   { ok = true,  plate = "ABC1234" }
--   { ok = false, error = "MISSING_PARAMS" | "INVALID_PASSPORT" |
--                          "MODEL_NOT_REGISTERED" | "GARAGE_FULL" |
--                          "INSERT_FAILED" }
--
-- Uso:
--   local res = exports['core-vehicles']:giveVehicle(passport, "adder")
--   if res.ok then print("plate:", res.plate) else print("erro:", res.error) end

giveVehicle = function(characterId, vehicleModel)
    if not characterId or not vehicleModel then
        return { ok = false, error = "MISSING_PARAMS" }
    end

    characterId = tonumber(characterId)
    if not characterId or characterId <= 0 then
        return { ok = false, error = "INVALID_PASSPORT" }
    end

    if type(vehicleModel) ~= "string" or vehicleModel == "" then
        return { ok = false, error = "MISSING_PARAMS" }
    end

    local vinfo = getVehicleInfo(GetHashKey(vehicleModel))
    if not vinfo then
        return { ok = false, error = "MODEL_NOT_REGISTERED" }
    end

    local _list, count = getCharacterVehicles(characterId)
    if not canCharacterBuyVehicle(characterId, count) then
        return { ok = false, error = "GARAGE_FULL" }
    end

    local ok, plateOrErr = generateVehicle(characterId, vinfo.index)
    if not ok then
        return { ok = false, error = plateOrErr or "INSERT_FAILED" }
    end

    return { ok = true, plate = plateOrErr }
end
exports('giveVehicle', giveVehicle)

-- ------------------------------------------------
-- # Rental Vehicles
-- ------------------------------------------------

hasVehicleModelRented = function(characterId,vehicleModel)
    if characterId and parseInt(characterId) > 0 and vehicleModel and type(vehicleModel) == 'string' then
        local vehicleInfo = getVehicleInfo(vehicleModel)
        if vehicleInfo then
            local result = query('SELECT * FROM `core_characters_vehicles` WHERE `owner` = '..characterId..' AND `index` = \''..vehicleInfo.index..'\' AND `expire_time` > 0;')
            if result and type(result) == 'table' and result[1] then
                return true,result[1].plate,result[1].expire_time
            end
        end
    end
    return false,false,false
end
exports('hasVehicleModelRented',hasVehicleModelRented)

generateRentalVehicle = function(characterId,vehicleModel,rentalDays,customPlate)

    if not characterId or not vehicleModel then
        return false,'MISSING_PARAMS'
    end

    local vhash = GetHashKey(vehicleModel)
    local vinfo = getVehicleInfo(vhash)
    if not vinfo then
        return false,'MODEL_NOT_REGISTERED'
    end

    rentalDays = parseInt(rentalDays)
    if rentalDays <= 0 then
        return false,'INVALID_DAYS_AMOUNT'
    end

    local vehPlate = (customPlate and isValidPlate(customPlate)) and customPlate:gsub(' ','') or generateNewPlate()
    local vehTax = os.time()
    
    local vdata = {
        plate = vehPlate,
        owner = characterId,
        index = vinfo.index,
        hash = vhash,
        name = vinfo.name,
        category = vinfo.category,
        status = '',
        tax = vehTax,
        taxEndTime = vehTax,
        health = { 1000,1000,100 },
        mods = { ['colors'] = { primary = {0,0,0}, secondary = {255,255,255} } },
        damages = {},
        expire_time = (vehTax+(86400*rentalDays)),
    }
    vehiclesDatas[vehPlate] = vdata

    execute([[
        INSERT INTO 
            `core_characters_vehicles` 
            (
                `plate`,
                `owner`,
                `index`,
                `status`,
                `tax`,
                `health`,
                `mods`,
                `damages`,
                `expire_time`
            )
        VALUES
            (
                ']]..vehPlate..[[',
                ]]..characterId..[[,
                ']]..vdata.index..[[',
                '',
                ]]..vehTax..[[,
                ']]..json.encode(vdata.health)..[[',
                ']]..json.encode(vdata.mods)..[[',
                '[]',
                ]]..vdata.expire_time..[[
            );
    ]])

    if not vehiclesOwners[characterId] then
        vehiclesOwners[characterId] = {}
    end
    vehiclesOwners[characterId][vehPlate] = 1

    return true,vehPlate

end
exports('generateRentalVehicle',generateRentalVehicle)

updateRentalVehicleDays = function(vehiclePlate,rentalDays)
    if not vehiclePlate or type(vehiclePlate) ~= 'string' then
        return false,'MISSING_PARAMS'
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    rentalDays = parseInt(rentalDays)
    if rentalDays <= 0 then
        return false,'INVALID_DAYS_AMOUNT'
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    local vehicleData = vehiclesDatas[vehiclePlate] or false
    if vehicleData then
        local currentTime = os.time()
        local _currentTime = (vehicleData.expire_time and vehicleData.expire_time > 0 and vehicleData.expire_time > currentTime) and vehicleData.expire_time or currentTime
        local newTime = (_currentTime+(86400*rentalDays))
        execute('UPDATE `core_characters_vehicles` SET `expire_time` = '..newTime..', `expired` = 0 WHERE `plate` = \''..vehiclePlate..'\';')
        vehiclesDatas[vehiclePlate].expire_time = newTime
        return true,newTime
    end
    return false,'VEHICLE_NOT_FOUND'
end
exports('updateRentalVehicleDays',updateRentalVehicleDays)

-- ------------------------------------------------
-- # Vehicle Data Access
-- ------------------------------------------------

forceLoadVehicleByPlate = function(plate)
    if plate and type(plate) == 'string' then
        plate = plate:gsub(' ','')
        local v = query('SELECT * FROM `core_characters_vehicles` WHERE `plate` = \''..plate..'\';')
        if v and type(v) == 'table' and v[1] then
            v = v[1]
            if not v.owner and v.characterOwner then
                v.owner = v.characterOwner
            end
            v.plate = v.plate:gsub(' ','')
            local vhash = GetHashKey(v.index)
            vehiclesDatas[v.plate] = {
                plate = v.plate,
                owner = v.owner,
                index = v.index,
                hash = vhash,
                name = getVehicleName(vhash),
                category = getVehicleCategory(v.index),
                status = v.status,
                tax = v.tax,
                taxEndTime = (v.tax+(86400*vehicleTaxes.durationInDays)),
                health = json.decode(v.health) or {},
                mods = json.decode(v.mods) or {},
                damages = json.decode(v.damages) or {},
                expire_time = v.expire_time,
                favorite = databaseFlagEnabled(v.favorite)
            }
            if not vehiclesOwners[v.owner] then
                vehiclesOwners[v.owner] = {}
            end
            vehiclesOwners[v.owner][v.plate] = 1
        end
        return true
    end
    return nil
end
exports('forceLoadVehicleByPlate',forceLoadVehicleByPlate)

getVehicleData = function(plate)
    if plate and type(plate) == 'string' then
        plate = plate:gsub(' ','')
        if vehiclesDatas[plate] then
            return vehiclesDatas[plate]
        end
        local state = GlobalState['core-cVehicles']
        if state and type(state) == 'table' and state[plate] then
            return {
                isServiceRental = true,
                owner = state[plate].owner,
                index = getVehicleIndex(state[plate].model),
                name = getVehicleIndex(state[plate].model)
            }
        end
    end
    return nil
end
exports('getVehicleData',getVehicleData)

-- ------------------------------------------------
-- # Borrow / Transfer / Delete
-- ------------------------------------------------

getVehicleBorrowed = function(plate)
    if plate and type(plate) == 'string' then
        plate = plate:gsub(' ','')
        return vehiclesBorrowedByPlate[plate] or 0
    end
    return nil
end
exports('getVehicleBorrowed',getVehicleBorrowed)

toggleVehicleBorrow = function(vehiclePlate,target,setBorrowed)
    if vehiclePlate then
        vehiclePlate = vehiclePlate:gsub(' ','')
        if vehiclesDatas[vehiclePlate] then
            if not setBorrowed then
                if vehiclesBorrowedByPlate[vehiclePlate] then
                    local borrowedTo = vehiclesBorrowed[vehiclePlate]
                    if vehiclesBorrowed[borrowedTo] then
                        if vehiclesBorrowed[borrowedTo][vehiclePlate] then
                            vehiclesBorrowed[borrowedTo][vehiclePlate] = nil
                        end
                    end
                    vehiclesBorrowedByPlate[vehiclePlate] = nil
                    execute('DELETE FROM `core_vehicles_borrowed` WHERE `plate` = \''..vehiclePlate..'\';')
                    return true,'BORROW_REVOKED'
                end
                return false,'VEHICLE_NOT_BORROWED'
            end
            if setBorrowed then
                if vehiclesBorrowedByPlate[vehiclePlate] then
                    return false,'VEHICLE_ALREADY_BORROWED'
                end
                if target then
                    if not vehiclesBorrowed[target] then
                        vehiclesBorrowed[target] = {}
                    end
                    vehiclesBorrowedByPlate[vehiclePlate] = target
                    vehiclesBorrowed[target][vehiclePlate] = 1
                    execute([[
                        INSERT INTO `core_vehicles_borrowed`
                        (
                            `plate`,
                            `target`
                        )
                        VALUES
                        (
                            ']]..vehiclePlate..[[',
                            ]]..target..[[
                        );
                    ]])
                    return true,'BORROW_APPLIED'
                else
                    return false,'MISSING_TARGET'
                end
            end
        else
            return false,'VEHICLE_DATA_NOT_FOUND'
        end
    end
    return false,'MISSING_VEHICLE_PLATE'
end
exports('toggleVehicleBorrow',toggleVehicleBorrow)

transferVehicle = function(vehiclePlate,newOwner)
    if not vehiclePlate or not newOwner then
        return false,'MISSING_PARAMS'
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    if vehiclesDatas[vehiclePlate] then

        toggleVehicleBorrow(vehiclePlate)

        local vdata = vehiclesDatas[vehiclePlate]
        local oldOwner = vdata.owner

        if vehiclesOwners[oldOwner] then
            if vehiclesOwners[oldOwner][vehiclePlate] then
                vehiclesOwners[oldOwner][vehiclePlate] = nil
            end
        end

        if not vehiclesOwners[newOwner] then
            vehiclesOwners[newOwner] = {}
        end
        vehiclesOwners[newOwner][vehiclePlate] = 1

        execute('UPDATE `core_characters_vehicles` SET `owner` = '..newOwner..' WHERE `plate` = \''..vehiclePlate..'\' AND `owner` = '..oldOwner..';')
        vehiclesDatas[vehiclePlate].owner = newOwner

        return true,'VEHICLE_TRANSFERRED'
    end
    return false,'VEHICLE_NOT_FOUND'
end
exports('transferVehicle',transferVehicle)

isVehicleBorrowed = function(vehiclePlate)
    if not vehiclePlate then
        return false,'MISSING_PARAMS'
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    return (vehiclesBorrowedByPlate[vehiclePlate] ~= nil)
end
exports('isVehicleBorrowed',isVehicleBorrowed)

deleteVehicle = function(vehiclePlate)
    if not vehiclePlate then
        return false,'MISSING_PARAMS'
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    if vehiclesDatas[vehiclePlate] then
        toggleVehicleBorrow(vehiclePlate)
        local vdata = vehiclesDatas[vehiclePlate]
        if vehiclesOwners[vdata.owner] then
            if vehiclesOwners[vdata.owner][vehiclePlate] then
                vehiclesOwners[vdata.owner][vehiclePlate] = nil
            end
        end
        if vehiclesDatas[vehiclePlate].expire_time <= 0 then
            execute('DELETE FROM `core_characters_vehicles` WHERE `plate` = \''..vehiclePlate..'\';')
        else
            execute('UPDATE `core_characters_vehicles` SET `expired` = \'1\', `expire_time` = \''..os.time()..'\' WHERE `plate` = \''..vehiclePlate..'\';')
        end
        vehiclesDatas[vehiclePlate] = nil
        return true,'VEHICLE_DELETED'
    end
    return false,'VEHICLE_NOT_FOUND'
end
exports('deleteVehicle',deleteVehicle)

-- ------------------------------------------------
-- # Tax / Status
-- ------------------------------------------------

updateVehicleTax = function(vehiclePlate)
    if not vehiclePlate then
        return false,'MISSING_PARAMS'
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    if vehiclesDatas[vehiclePlate] then
        local newTax = os.time()
        vehiclesDatas[vehiclePlate].tax = newTax
        vehiclesDatas[vehiclePlate].taxEndTime = (newTax+(86400*vehicleTaxes.durationInDays)),
        execute('UPDATE `core_characters_vehicles` SET `tax` = \''..newTax..'\' WHERE `plate` = \''..vehiclePlate..'\';')
        return vehiclesDatas[vehiclePlate].taxEndTime,'TAX_UPDATED'
    end
    return false,'VEHICLE_NOT_FOUND'
end
exports('updateVehicleTax',updateVehicleTax)

updateVehicleStatus = function(vehiclePlate,status)
    if not vehiclePlate then
        return false,'MISSING_PARAMS'
    end
    if not status then
        status = ''
    end
    vehiclePlate = vehiclePlate:gsub(' ','')
    if vehiclesDatas[vehiclePlate] then
        vehiclesDatas[vehiclePlate].status = status
        execute('UPDATE `core_characters_vehicles` SET `status` = \''..status..'\' WHERE `plate` = \''..vehiclePlate..'\';')
        return true,'STATUS_UPDATED'
    end
    return false,'VEHICLE_NOT_FOUND'
end
exports('updateVehicleStatus',updateVehicleStatus)

-- ------------------------------------------------
-- # Plate Generation
-- ------------------------------------------------

local plateModels = {'DLDLDLDL','DLLDLLDD','LDDLDLDL','DDLLDDLD','LDDDLLDL','DLLLDDDL'}
local servicePlateModels = {'LLLDDDLD','LLDDDDLL','DLLLLLLD'}

generateNewPlate = function(isService)
    if isService then
        return generateValidServicePlate(servicePlateModels[math.random(#servicePlateModels)])
    end
    return generateValidPlate(plateModels[math.random(#plateModels)])
end
exports('generateNewPlate',generateNewPlate)

hashString = function(format)
	local abyte = string.byte('A')
	local zbyte = string.byte('0')
	local ft = ''
	for i=1,#format do
		local char = string.sub(format,i,i)
    	if char == 'D' then ft = ft..string.char(zbyte+math.random(0,9))
		elseif char == 'L' then ft = ft..string.char(abyte+math.random(0,25))
		else ft = ft..char end
	end
	return ft
end

generateValidPlate = function(m)
    local plate = ''
	repeat
		plate = hashString(m)
	until vehiclesDatas[plate] == nil
	return plate
end

generateValidServicePlate = function(m)
    local plate = hashString(m)
    local result = query('SELECT * FROM `core_characters_vehicles_srvc` WHERE `plate` = \''..plate..'\';')
	repeat
		plate = hashString(m)
        result = query('SELECT * FROM `core_characters_vehicles_srvc` WHERE `plate` = \''..plate..'\';')
	until (not result or (result and type(result) == 'table' and #result <= 0))
	return plate
end

isValidPlate = function(plate)
    if not plate then 
        return false
    end
    if type(plate) ~= 'string' then
        return false
    end
    if plate:len() > 8 then
        return false
    end
    if vehiclesDatas[plate:gsub(' ','')] then
        return false
    end
    return true
end

-- ------------------------------------------------
-- # Mods / Health (Server Cache)
-- ------------------------------------------------

updateVehicleMods = function(plate,mods)
    if plate and mods then
        plate = plate:gsub(' ','')
        if vehiclesDatas[plate] then
            vehiclesDatas[plate].mods = mods
        end
    end
end
exports('updateVehicleMods',updateVehicleMods)

getVehicleMods = function(plate)
    if plate then
        plate = plate:gsub(' ','')
        if vehiclesDatas[plate] then
            return vehiclesDatas[plate].mods or {}
        end
    end
    return {}
end
exports('getVehicleMods',getVehicleMods)

updateVehicleHealth = function(plate,health,damages)
    if plate and health and damages then
        plate = plate:gsub(' ','')
        if vehiclesDatas[plate] then
            vehiclesDatas[plate].health = health
            if type(health) ~= 'table' or (type(health) == 'table' and type(health[1]) ~= 'number' or type(health[2]) ~= 'number' or type(health[3]) ~= 'number') then
                health = { 1000.0, 1000.0, 100.0 }
            end
            vehiclesDatas[plate].damages = damages
            execute('UPDATE `core_characters_vehicles` SET `health` = \''..json.encode(health)..'\', `damages` = \''..json.encode(damages)..'\' WHERE `plate` = \''..plate..'\';')
        end
    end
end
exports('updateVehicleHealth',updateVehicleHealth)

getVehicleHealth = function(plate)
    if plate then
        plate = plate:gsub(' ','')
        if vehiclesDatas[plate] then
            return vehiclesDatas[plate].health or {1000,1000,100},vehiclesDatas[plate].damages or {}
        end
    end
    return {1000,1000,100},{}
end
exports('getVehicleHealth',getVehicleHealth)

-- ------------------------------------------------
-- # AI / Service Vehicles
-- ------------------------------------------------

unlockAIVehicle = function(networkVehicle)
    if networkVehicle then
        local entity = NetworkGetEntityFromNetworkId(networkVehicle)
        if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
            Entity(entity).state:set('unlocked',1,true)
        end
    end
end
exports('unlockAIVehicle',unlockAIVehicle)

unlockVehicle = function(networkVehicle)
    if networkVehicle then
        local entity = NetworkGetEntityFromNetworkId(networkVehicle)
        if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
            SetVehicleDoorsLocked(entity,1)
        end
    end
end
exports('unlockVehicle',unlockVehicle)

isAIVehicle = function(networkVehicle)
    if networkVehicle then
        local entity = NetworkGetEntityFromNetworkId(networkVehicle)
        if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
            return (Entity(entity).state['veh-mods'] == nil),(Entity(entity).state['unlocked'] ~= nil)
        end
    end
    return false,false
end
exports('isAIVehicle',isAIVehicle)

getServiceVehicleData = function(id,index)
    if id and index then
        local result = query('SELECT * FROM `core_characters_vehicles_srvc` WHERE `owner` = \''..id..'\' AND `index` = \''..index..'\';')
        if result and type(result) == 'table' and result[1] then
            return result[1].plate:upper(),(json.decode(result[1].mods or '[]') or {})
        end
        local plate = generateNewPlate(true)
        execute('INSERT INTO `core_characters_vehicles_srvc` (`plate`,`owner`,`index`,`mods`) VALUES (\''..plate..'\',\''..id..'\',\''..index..'\',\'[]\');')
        return plate,{}
    end
    return false,false
end
exports('getServiceVehicleData',getServiceVehicleData)

-- ------------------------------------------------
-- # Compatibility: old garages API
-- ------------------------------------------------

local signalPlates = {}
AddEventHandler('SignalRemove',function(plate)
    if plate then
        signalPlates[plate:gsub(' ','')] = true
    end
end)

exports('Signal',function(plate)
    if plate then
        return signalPlates[plate:gsub(' ','')] or false
    end
    return false
end)

exports('Spawn',function(plate)
    if plate then
        plate = plate:gsub(' ','')
        local state = GlobalState['core-cVehicles']
        if state and state[plate] then
            local vdata = vehiclesDatas[plate]
            local owner = vdata and vdata.owner or (state[plate].owner or 0)
            local model = vdata and vdata.index or getVehicleIndex(state[plate].model)
            return { owner, model, state[plate].id }
        end
    end
    return nil
end)
