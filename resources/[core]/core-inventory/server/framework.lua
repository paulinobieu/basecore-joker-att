-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
vKEYBOARD = Tunnel.getInterface("keyboard")
vCLIENT = Tunnel.getInterface("core-inventory")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = Core or {}
Tunnel.bindInterface("core-inventory",Core)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
	-------------------------------------------------------------------------------------------------------------------------------------
	-- IDENTITY
	-------------------------------------------------------------------------------------------------------------------------------------
    Passport = function(source)
        return vRP.Passport(source)
    end,
    Source = function(passport)
        return vRP.Source(passport)
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- INTEGRATIONS
	-------------------------------------------------------------------------------------------------------------------------------------
    Log = function(category,data)
        if GetResourceState("core_logs") == "started" then
            exports["core_logs"]:AddLog(category,data)
        end
    end,
    Discord = function(category,message)
        exports.discord:Embed(category,message)
    end,
    DatabaseSingle = function(query,parameters)
        return exports.oxmysql:single_async(query,parameters)
    end,
    DatabaseUpdate = function(query,parameters)
        return exports.oxmysql:update_async(query,parameters)
    end,
    IsInCoreGameMatch = function(source)
        return GetResourceState("core-game") == "started" and Player(source).state.inCoreGameMatch
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- ITEMS
	-------------------------------------------------------------------------------------------------------------------------------------
    BlockDelete = function(...)
        return exports.vrp:BlockDelete(...)
    end,
    CallPolice = function(...)
        return exports.vrp:CallPolice(...)
    end,
    ItemDurability = function(...)
        return exports.vrp:ItemDurability(...)
    end,
    ItemExist = function(...)
        return exports.vrp:ItemExist(...)
    end,
    ItemLoads = function(...)
        return exports.vrp:ItemLoads(...)
    end,
    ItemLocked = function(...)
        return exports.vrp:ItemLocked(...)
    end,
    ItemMetaClone = function(...)
        return exports.vrp:ItemMetaClone(...)
    end,
    ItemMetaLegacy = function(...)
        return exports.vrp:ItemMetaLegacy(...)
    end,
    ItemMetaParse = function(...)
        return exports.vrp:ItemMetaParse(...)
    end,
    ItemMetaStackable = function(...)
        return exports.vrp:ItemMetaStackable(...)
    end,
    ItemName = function(...)
        return exports.vrp:ItemName(...)
    end,
    ItemNamed = function(...)
        return exports.vrp:ItemNamed(...)
    end,
    ItemType = function(...)
        return exports.vrp:ItemType(...)
    end,
    ItemUnique = function(...)
        return exports.vrp:ItemUnique(...)
    end,
    ItemWeight = function(...)
        return ItemWeight(...)
    end,
    VehicleExist = function(...)
        return exports.vrp:VehicleExist(...)
    end,
    VehicleName = function(...)
        return exports.vrp:VehicleName(...)
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- UTILS
	-------------------------------------------------------------------------------------------------------------------------------------
    parseInt = function(...)
        return parseInt(...)
    end,
    Dotted = function(...)
        return Dotted(...)
    end,
    CompleteTimers = function(...)
        return CompleteTimers(...)
    end,
    GenerateString = function(...)
        return GenerateString(...)
    end,
    RandPercentage = function(...)
        return RandPercentage(...)
    end,
    SplitBoolean = function(...)
        return SplitBoolean(...)
    end,
    SplitOne = function(...)
        return SplitOne(...)
    end,
    splitString = function(...)
        return splitString(...)
    end,
    ItemDescription = function(...)
        return ItemDescription(...)
    end,
    ItemFood = function(...)
        return ItemFood(...)
    end,
    ItemLostWater = function(...)
        return ItemLostWater(...)
    end,
    ItemPolice = function(...)
        return ItemPolice(...)
    end,
    ItemRecycle = function(...)
        return ItemRecycle(...)
    end,
    ItemTypeCheck = function(...)
        return ItemTypeCheck(...)
    end,
    ItemVehicle = function(...)
        return ItemVehicle(...)
    end,
    ItemWater = function(...)
        return ItemWater(...)
    end,
    VehicleList = function(...)
        return VehicleList(...)
    end,
    VehicleMode = function(...)
        return VehicleMode(...)
    end,
    VehiclePrice = function(...)
        return VehiclePrice(...)
    end,
    VehicleStock = function(...)
        return VehicleStock(...)
    end,
    async = function(...)
        return async(...)
    end,
    TableLevel = function(...)
        return TableLevel(...)
    end,
    WeaponAmmo = function(...)
        return WeaponAmmo(...)
    end,
    WeaponAttach = function(...)
        return WeaponAttach(...)
    end,
    WeaponBase = function(...)
        return WeaponBase(...)
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- VRP
	-------------------------------------------------------------------------------------------------------------------------------------
    AmountService = function(...)
        return vRP.AmountService(...)
    end,
    Archive = function(...)
        return vRP.Archive(...)
    end,
    Armour = function(...)
        return vRP.Armour(...)
    end,
    CheckDamaged = function(...)
        return vRP.CheckDamaged(...)
    end,
    CheckWeight = function(...)
        return vRP.CheckWeight(...)
    end,
    CleanSlot = function(...)
        return vRP.CleanSlot(...)
    end,
    CleanSlotChest = function(...)
        return vRP.CleanSlotChest(...)
    end,
    ConsultItem = function(...)
        return vRP.ConsultItem(...)
    end,
    DoesEntityExist = function(...)
        return vRP.DoesEntityExist(...)
    end,
    FullName = function(...)
        return vRP.FullName(...)
    end,
    GenerateHash = function(...)
        return vRP.GenerateHash(...)
    end,
    GenerateItem = function(...)
        return vRP.GenerateItem(...)
    end,
    GeneratePlate = function(...)
        return vRP.GeneratePlate(...)
    end,
    GetEntityCoords = function(...)
        return vRP.GetEntityCoords(...)
    end,
    GetExperience = function(...)
        return vRP.GetExperience(...)
    end,
    GetHealth = function(...)
        return vRP.GetHealth(...)
    end,
    GetItemMeta = function(...)
        return vRP.GetItemMeta(...)
    end,
    GetSrvData = function(...)
        return vRP.GetSrvData(...)
    end,
    GetWeight = function(...)
        return vRP.GetWeight(...)
    end,
    GiveItem = function(...)
        return vRP.GiveItem(...)
    end,
    HasGroup = function(...)
        return vRP.HasGroup(...)
    end,
    HasService = function(...)
        return vRP.HasService(...)
    end,
    Identity = function(...)
        return vRP.Identity(...)
    end,
    InsideVehicle = function(...)
        return vRP.InsideVehicle(...)
    end,
    Inventory = function(...)
        return vRP.Inventory(...)
    end,
    InventoryItemAmount = function(...)
        return vRP.InventoryItemAmount(...)
    end,
    InventorySlots = function(...)
        return vRP.InventorySlots(...)
    end,
    IsEntityVisible = function(...)
        return vRP.IsEntityVisible(...)
    end,
    MaxItens = function(...)
        return vRP.MaxItens(...)
    end,
    MountContainer = function(...)
        return vRP.MountContainer(...)
    end,
    NumPermission = function(...)
        return vRP.NumPermission(...)
    end,
    PassportPlate = function(...)
        return vRP.PassportPlate(...)
    end,
    Permissions = function(...)
        return vRP.Permissions(...)
    end,
    Phone = function(...)
        return vRP.Phone(...)
    end,
    Players = function(...)
        return vRP.Players(...)
    end,
    PutExperience = function(...)
        return vRP.PutExperience(...)
    end,
    Query = function(...)
        return vRP.Query(...)
    end,
    RemoveCharges = function(...)
        return vRP.RemoveCharges(...)
    end,
    RemoveItem = function(...)
        return vRP.RemoveItem(...)
    end,
    RemSrvData = function(...)
        return vRP.RemSrvData(...)
    end,
    Request = function(...)
        return vRP.Request(...)
    end,
    Scalar = function(...)
        return vRP.Scalar(...)
    end,
    SelectVehicle = function(...)
        return vRP.SelectVehicle(...)
    end,
    SetChestMeta = function(...)
        return vRP.SetChestMeta(...)
    end,
    SetItemMeta = function(...)
        return vRP.SetItemMeta(...)
    end,
    SetSrvData = function(...)
        return vRP.SetSrvData(...)
    end,
    SimpleData = function(...)
        return vRP.SimpleData(...)
    end,
    SingleQuery = function(...)
        return vRP.SingleQuery(...)
    end,
    SortMetaItem = function(...)
        return vRP.SortMetaItem(...)
    end,
    StoreChest = function(...)
        return vRP.StoreChest(...)
    end,
    TakeChest = function(...)
        return vRP.TakeChest(...)
    end,
    TakeItem = function(...)
        return vRP.TakeItem(...)
    end,
    Task = function(...)
        return vRP.Task(...)
    end,
    Update = function(...)
        return vRP.Update(...)
    end,
    UpdateChest = function(...)
        return vRP.UpdateChest(...)
    end,
    UpgradeStress = function(...)
        return vRP.UpgradeStress(...)
    end,
    UpgradeThirst = function(...)
        return vRP.UpgradeThirst(...)
    end,
    UserData = function(...)
        return vRP.UserData(...)
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- RESOURCES
	-------------------------------------------------------------------------------------------------------------------------------------
    Wanted = function(...)
        return exports.hud:Wanted(...)
    end,
    PartyExists = function(...)
        return exports.party:DoesExist(...)
    end,
    VehicleData = function(...)
        return exports["core-vehicles"]:getVehicleData(...)
    end,
    GiveVehicle = function(...)
        return exports["core-vehicles"]:giveVehicle(...)
    end,
    SpawnVehicle = function(...)
        return exports["core-vehicles"]:Spawn(...)
    end,
    UpdateVehicleStatus = function(...)
        return exports["core-vehicles"]:updateVehicleStatus(...)
    end,
    RemoveBoosting = function(...)
        return exports.boosting:Remove(...)
    end,
    CreatePlant = function(...)
        return exports.plants:Plants(...)
    end,
    InventoryDrops = function(...)
        return exports["core-inventory"]:Drops(...)
    end,
    InventoryBuff = function(...)
        return exports["core-inventory"]:Buffs(...)
    end,
    InventoryPlate = function(...)
        return exports["core-inventory"]:GeneratePlate(...)
    end,
    ResolveBaseWeapon = function(item)
        if not item or item == "" or GetResourceState("core-skins") ~= "started" then return item end

        local success,result = pcall(function()
            return exports["core-skins"]:GetBaseWeapon(item)
        end)

        return success and type(result) == "string" and result ~= "" and result or item
    end,
    ResolveWeaponSkin = function(passport,item)
        if not passport or not item or item == "" or GetResourceState("core-skins") ~= "started" then return item end

        local success,result = pcall(function()
            return exports["core-skins"]:GetWeaponSkin(passport,item)
        end)

        return success and type(result) == "string" and result ~= "" and result or item
    end,
    ReloadWeapons = function(source)
        TriggerEvent("vRP:ReloadWeapons",source)
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- CLIENT
	-------------------------------------------------------------------------------------------------------------------------------------
    Client = {
        AnimActive = function(...)
            return vRPC.AnimActive(...)
        end,
        ClosestPed = function(...)
            return vRPC.ClosestPed(...)
        end,
        CreateObjects = function(...)
            return vRPC.CreateObjects(...)
        end,
        Destroy = function(...)
            return vRPC.Destroy(...)
        end,
        DowngradeHealth = function(...)
            return vRPC.DowngradeHealth(...)
        end,
        IsEntityInWater = function(...)
            return vRPC.IsEntityInWater(...)
        end,
        ObjectControlling = function(...)
            return vRPC.ObjectControlling(...)
        end,
        playAnim = function(...)
            return vRPC.playAnim(...)
        end,
        Players = function(...)
            return vRPC.Players(...)
        end,
        PlayingAnim = function(...)
            return vRPC.PlayingAnim(...)
        end,
        PlaySound = function(...)
            return vRPC.PlaySound(...)
        end,
        SprayExist = function(...)
            return vRPC.SprayExist(...)
        end,
    },
	-------------------------------------------------------------------------------------------------------------------------------------
	-- INVENTORY CLIENT
	-------------------------------------------------------------------------------------------------------------------------------------
    InventoryClient = {
        Animals = function(...)
            return vCLIENT.Animals(...)
        end,
        CheckInterior = function(...)
            return vCLIENT.CheckInterior(...)
        end,
        CheckWeapon = function(...)
            return vCLIENT.CheckWeapon(...)
        end,
        ObjectExists = function(...)
            return vCLIENT.ObjectExists(...)
        end,
        ReturnWeapon = function(...)
            return vCLIENT.ReturnWeapon(...)
        end,
        SprayControlling = function(...)
            return vCLIENT.SprayControlling(...)
        end,
        StoreWeapon = function(...)
            return vCLIENT.StoreWeapon(...)
        end,
        SyncWeaponAmmo = function(...)
            return vCLIENT.SyncWeaponAmmo(...)
        end,
        SyncWeaponAttach = function(...)
            return vCLIENT.SyncWeaponAttach(...)
        end,
        TakeWeapon = function(...)
            return vCLIENT.TakeWeapon(...)
        end,
        tyreHealth = function(...)
            return vCLIENT.tyreHealth(...)
        end,
    },
	-------------------------------------------------------------------------------------------------------------------------------------
	-- KEYBOARD
	-------------------------------------------------------------------------------------------------------------------------------------
    Keyboard = {
        Password = function(...)
            return vKEYBOARD.Password(...)
        end,
    },
	-------------------------------------------------------------------------------------------------------------------------------------
	-- CONFIG
	-------------------------------------------------------------------------------------------------------------------------------------
    ListItem = ListItem,
    IlegalItens = IlegalItens,
    Loot = Loot,
    Clones = Clones,
    Puritys = Puritys,
}
