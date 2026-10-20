-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
vSERVER = Tunnel.getInterface("core-inventory")

local vPROPERTY = Tunnel.getInterface("propertys")
local vTRUNK = Tunnel.getInterface("trunkchest")

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
	-- INTERFACE
	-------------------------------------------------------------------------------------------------------------------------------------
    Open = function()
        TriggerEvent("hud:Active",false)
    end,
    Close = function()
        TriggerEvent("hud:Active",true)
    end,
    AddChestZone = function(coords,options)
        if GetResourceState("sleepless_interact") ~= "started" then return nil end

        return exports.sleepless_interact:addCoords(coords,options)
    end,
    RemoveChestZone = function(id)
        if id and GetResourceState("sleepless_interact") == "started" then
            exports.sleepless_interact:removeCoords(id)
        end
    end,
    IsInCoreGameMatch = function()
        return GetResourceState("core-game") == "started" and LocalPlayer.state.inCoreGameMatch
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- TARGET
	-------------------------------------------------------------------------------------------------------------------------------------
    TargetAddBox = function(...)
        return exports.ox_target:addBoxZone(...)
    end,
    TargetAddSphere = function(...)
        return exports.ox_target:addSphereZone(...)
    end,
    TargetRemove = function(...)
        return exports.ox_target:removeZone(...)
    end,
    ResolveBaseWeapon = function(item)
        if not item or item == "" or GetResourceState("core-skins") ~= "started" then return item end

        local success,result = pcall(function()
            return exports["core-skins"]:GetBaseWeapon(item)
        end)

        return success and type(result) == "string" and result ~= "" and result or item
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
    CountTable = function(...)
        return CountTable(...)
    end,
    LoadAnim = function(...)
        return LoadAnim(...)
    end,
    LoadModel = function(...)
        return LoadModel(...)
    end,
    Optimize = function(...)
        return Optimize(...)
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
	-------------------------------------------------------------------------------------------------------------------------------------
	-- ITEMS
	-------------------------------------------------------------------------------------------------------------------------------------
    ItemDescription = function(...)
        return ItemDescription(...)
    end,
    ItemIndex = function(...)
        return ItemIndex(...)
    end,
    ItemMaxAmount = function(...)
        return ItemMaxAmount(...)
    end,
    ItemName = function(...)
        return ItemName(...)
    end,
    ItemType = function(...)
        return ItemType(...)
    end,
    ItemVehicle = function(...)
        return ItemVehicle(...)
    end,
    ItemWeight = function(...)
        return ItemWeight(...)
    end,
    ClassCategory = function(...)
        return ClassCategory(...)
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
    ClosestVehicle = function(...)
        return vRP.ClosestVehicle(...)
    end,
    CreateObjects = function(...)
        return vRP.CreateObjects(...)
    end,
    Destroy = function(...)
        return vRP.Destroy(...)
    end,
    playAnim = function(...)
        return vRP.playAnim(...)
    end,
	-------------------------------------------------------------------------------------------------------------------------------------
	-- SERVER
	-------------------------------------------------------------------------------------------------------------------------------------
    Server = {
        AttachWeapon = function(...)
            return vSERVER.AttachWeapon(...)
        end,
        CheckDrugs = function(...)
            return vSERVER.CheckDrugs(...)
        end,
        CheckExistWeapons = function(...)
            return vSERVER.CheckExistWeapons(...)
        end,
        ChestCanUpgrade = function(...)
            return vSERVER.ChestCanUpgrade(...)
        end,
        ChestConfirmUpgrade = function(...)
            return vSERVER.ChestConfirmUpgrade(...)
        end,
        ChestMount = function(...)
            return vSERVER.ChestMount(...)
        end,
        ChestPermissions = function(...)
            return vSERVER.ChestPermissions(...)
        end,
        ChestQuoteUpgrade = function(...)
            return vSERVER.ChestQuoteUpgrade(...)
        end,
        ChestStore = function(...)
            return vSERVER.ChestStore(...)
        end,
        ChestTake = function(...)
            return vSERVER.ChestTake(...)
        end,
        ChestUpdate = function(...)
            return vSERVER.ChestUpdate(...)
        end,
        CloseLunchbag = function(...)
            return vSERVER.CloseLunchbag(...)
        end,
        CreateVehicle = function(...)
            return vSERVER.CreateVehicle(...)
        end,
        DetachWeapon = function(...)
            return vSERVER.DetachWeapon(...)
        end,
        Drops = function(...)
            return vSERVER.Drops(...)
        end,
        EmptyLunchbag = function(...)
            return vSERVER.EmptyLunchbag(...)
        end,
        Experience = function(...)
            return vSERVER.Experience(...)
        end,
        InspectMount = function(...)
            return vSERVER.InspectMount(...)
        end,
        InspectReset = function(...)
            return vSERVER.InspectReset(...)
        end,
        InspectStore = function(...)
            return vSERVER.InspectStore(...)
        end,
        InspectTake = function(...)
            return vSERVER.InspectTake(...)
        end,
        Mount = function(...)
            return vSERVER.Mount(...)
        end,
        MoveLunchbag = function(...)
            return vSERVER.MoveLunchbag(...)
        end,
        PaymentDrugs = function(...)
            return vSERVER.PaymentDrugs(...)
        end,
        Pickup = function(...)
            return vSERVER.Pickup(...)
        end,
        PreventWeapons = function(...)
            return vSERVER.PreventWeapons(...)
        end,
        ReloadWeapon = function(...)
            return vSERVER.ReloadWeapon(...)
        end,
        RemoveThrowing = function(...)
            return vSERVER.RemoveThrowing(...)
        end,
        Send = function(...)
            return vSERVER.Send(...)
        end,
        ShotsFired = function(...)
            return vSERVER.ShotsFired(...)
        end,
        StealPeds = function(...)
            return vSERVER.StealPeds(...)
        end,
        Swimming = function(...)
            return vSERVER.Swimming(...)
        end,
        UnloadWeapon = function(...)
            return vSERVER.UnloadWeapon(...)
        end,
        Use = function(...)
            return vSERVER.Use(...)
        end,
        VerifyWeapon = function(...)
            return vSERVER.VerifyWeapon(...)
        end,
        Washers = function(...)
            return vSERVER.Washers(...)
        end,
    },
    VRPServer = {
        CreateObject = function(...)
            return vRPS.CreateObject(...)
        end,
        invUpdate = function(...)
            return vRPS.invUpdate(...)
        end,
    },
	-------------------------------------------------------------------------------------------------------------------------------------
	-- PROPERTY
	-------------------------------------------------------------------------------------------------------------------------------------
    Property = {
        Mount = function(...)
            return vPROPERTY.Mount(...)
        end,
        Store = function(...)
            return vPROPERTY.Store(...)
        end,
        Take = function(...)
            return vPROPERTY.Take(...)
        end,
        Update = function(...)
            return vPROPERTY.Update(...)
        end,
    },
	-------------------------------------------------------------------------------------------------------------------------------------
	-- TRUNK
	-------------------------------------------------------------------------------------------------------------------------------------
    Trunk = {
        Mount = function(...)
            return vTRUNK.Mount(...)
        end,
        Store = function(...)
            return vTRUNK.Store(...)
        end,
        Take = function(...)
            return vTRUNK.Take(...)
        end,
        Update = function(...)
            return vTRUNK.Update(...)
        end,
    },
	-------------------------------------------------------------------------------------------------------------------------------------
	-- CONFIG
	-------------------------------------------------------------------------------------------------------------------------------------
    Currency = Currency,
    NameDefault = NameDefault,
    Theme = Theme,
    WeaponBack = WeaponBack,
}
