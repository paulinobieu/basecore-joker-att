-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-- Slot do armamento que cada passaporte esta segurando. Sacar a arma nao tira o
-- item do inventario, entao o slot serve de ancora para devolver o pente e os
-- acessorios ao proprio item quando o jogador guarda, recarrega ou morre.
-----------------------------------------------------------------------------------------------------------------------------------------
Equipped = {}
local Settings = Inventory.Weapons
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONSLOT
-- Descobre em qual slot esta o armamento. Prefere o slot marcado como equipado;
-- so varre o inventario quando ele nao serve mais, evitando escrever a municao
-- em outra copia da mesma arma.
-----------------------------------------------------------------------------------------------------------------------------------------
function FindWeaponSlot(Passport,Item)
    local Inventory = Framework.Inventory(Passport)
    if not Inventory then
        return nil
    end

    local Tracked = Equipped[Passport]
    if Tracked and Inventory[Tracked] and Inventory[Tracked].item == Item then
        return Tracked
    end

    for Slot,Data in pairs(Inventory) do
        if Data.item == Item then
            return Slot
        end
    end

    return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONMETA
-----------------------------------------------------------------------------------------------------------------------------------------
function WeaponMeta(Passport,Slot)
    return Framework.GetItemMeta(Passport,Slot) or {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WRITEAMMO
-----------------------------------------------------------------------------------------------------------------------------------------
function WriteAmmo(Passport,Item,Ammo,Slot)
    local Slot = Slot or Equipped[Passport] or FindWeaponSlot(Passport,Item)
    if not Slot then
        return false
    end

    Ammo = Framework.parseInt(Ammo)

    return Framework.SetItemMeta(Passport,Slot,"ammo",Ammo > 0 and Ammo or nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATTACHLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function AttachList(Meta)
    local List = {}

    if Meta and type(Meta.attachs) == "table" then
        for Component in pairs(Meta.attachs) do
            List[Component] = true
        end
    end

    return List
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RELOADWEAPON
-- Chamada quando a interface arrasta municao sobre o armamento. O pente vive no
-- meta do item, entao a arma nao precisa estar na mao para ser carregada.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ReloadWeapon(AmmoSlot,WeaponSlot,Amount)
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    AmmoSlot = tostring(AmmoSlot)
    WeaponSlot = tostring(WeaponSlot)
    Amount = Framework.parseInt(Amount)

    if Amount <= 0 or AmmoSlot == WeaponSlot then
        return false
    end

    local Inventory = Framework.Inventory(Passport)
    local AmmoData = Inventory[AmmoSlot]
    local WeaponData = Inventory[WeaponSlot]

    if not AmmoData or not WeaponData then
        return false
    end

    if not Framework.ItemTypeCheck(WeaponData.item,"Armamento") then
        return false
    end

    local Ammunation = Framework.WeaponAmmo(WeaponData.item)
    if not Ammunation or Ammunation ~= AmmoData.item then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.ammoMismatch,"vermelho")
        return false
    end

    local Meta = WeaponMeta(Passport,WeaponSlot)
    local Loaded = Framework.parseInt(Meta.ammo)
    local Ceiling = (WeaponData.item == Settings.FuelWeapon) and Settings.FuelCapacity or Settings.AmmoCapacity

    if Loaded >= Ceiling then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.ammoFull,"amarelo")
        return false
    end

    Amount = math.min(Amount,AmmoData.amount,Ceiling - Loaded)
    if Amount <= 0 then
        return false
    end

    if not Framework.TakeItem(Passport,AmmoData.item,Amount,false,AmmoSlot) then
        return false
    end

    local Total = Loaded + Amount
    Framework.SetItemMeta(Passport,WeaponSlot,"ammo",Total)

    if Equipped[Passport] == WeaponSlot then
        Framework.InventoryClient.SyncWeaponAmmo(source,Total)
    end
    TriggerClientEvent("inventory:Update",source)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATTACHWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.AttachWeapon(AttachSlot,WeaponSlot)
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    AttachSlot = tostring(AttachSlot)
    WeaponSlot = tostring(WeaponSlot)

    if AttachSlot == WeaponSlot then
        return false
    end

    local Inventory = Framework.Inventory(Passport)
    local AttachData = Inventory[AttachSlot]
    local WeaponData = Inventory[WeaponSlot]

    if not AttachData or not WeaponData then
        return false
    end

    if not Framework.ItemTypeCheck(AttachData.item,"Attachs") or not Framework.ItemTypeCheck(WeaponData.item,"Armamento") then
        return false
    end

    if Framework.ItemPolice(AttachData.item) and not Framework.HasService(Passport,Settings.PolicePermission) then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.attachPolice,"vermelho")
        return false
    end

    local Component = Framework.WeaponAttach(AttachData.item,WeaponData.item)
    if not Component then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.attachUnsupported,"vermelho")
        return false
    end

    local Meta = WeaponMeta(Passport,WeaponSlot)
    local Attachs = AttachList(Meta)

    if Attachs[AttachData.item] then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.attachDuplicated,"vermelho")
        return false
    end

    for Component2 in pairs(Attachs) do
        if Framework.WeaponAttach(Component2,WeaponData.item) == Component then
            TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.attachDuplicated,"vermelho")
            return false
        end
    end

    if not Framework.TakeItem(Passport,AttachData.item,1,false,AttachSlot) then
        return false
    end

    Attachs[AttachData.item] = true
    Framework.SetItemMeta(Passport,WeaponSlot,"attachs",Attachs)

    if Equipped[Passport] == WeaponSlot then
        Framework.InventoryClient.SyncWeaponAttach(source,Component,true)
    end
    TriggerClientEvent("inventory:Update",source)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DETACHWEAPON
-- Botao DESMONTAR do tooltip: devolve todos os acessorios do armamento.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.DetachWeapon(WeaponSlot)
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    WeaponSlot = tostring(WeaponSlot)

    local Inventory = Framework.Inventory(Passport)
    local WeaponData = Inventory[WeaponSlot]

    if not WeaponData or not Framework.ItemTypeCheck(WeaponData.item,"Armamento") then
        return false
    end

    local Meta = WeaponData.meta
    local List = AttachList(Meta)

    if not next(List) then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.attachEmpty,"amarelo")
        return false
    end

    for Component in pairs(List) do
        local Native = Framework.WeaponAttach(Component,WeaponData.item)

        Framework.GenerateItem(Passport,Component,1,true)

        if Native and Equipped[Passport] == WeaponSlot then
            Framework.InventoryClient.SyncWeaponAttach(source,Native,false)
        end
    end

    Framework.SetItemMeta(Passport,WeaponSlot,"attachs",nil)

    TriggerClientEvent("inventory:Update",source)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNLOADWEAPON
-- Botao DESCARREGAR: o pente volta como item de municao.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.UnloadWeapon(WeaponSlot)
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    WeaponSlot = tostring(WeaponSlot)

    local Inventory = Framework.Inventory(Passport)
    local WeaponData = Inventory[WeaponSlot]

    if not WeaponData or not Framework.ItemTypeCheck(WeaponData.item,"Armamento") then
        return false
    end

    local Meta = WeaponData.meta
    local Loaded = Framework.parseInt(Meta and Meta.ammo)
    if Loaded <= 0 then
        return false
    end

    local Ammunation = Framework.WeaponAmmo(WeaponData.item)
    if not Ammunation then
        return false
    end

    if not Framework.CheckWeight(Passport,Ammunation,Loaded) then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.overweight,"amarelo")
        return false
    end

    Framework.SetItemMeta(Passport,WeaponSlot,"ammo",nil)

    Framework.GenerateItem(Passport,Ammunation,Loaded,true)

    if Equipped[Passport] == WeaponSlot then
        Framework.InventoryClient.SyncWeaponAmmo(source,0)
    end

    TriggerClientEvent("inventory:Update",source)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MIGRATEWEAPONPOOLS
-- Ate a versao anterior a municao e os acessorios viviam em dois pools por
-- passaporte no playerdata ("Ammos" e "Attachs"), soltos do item. Na primeira
-- conexao o que estava guardado volta como item na mochila e as duas linhas sao
-- apagadas, entao a conversao roda uma vez so por personagem.
-----------------------------------------------------------------------------------------------------------------------------------------
function MigrateWeaponPools(Passport)
    local Ammos = Framework.UserData(Passport,"Ammos")
    local Attachs = Framework.UserData(Passport,"Attachs")

    if type(Ammos) == "table" then
        for Ammunation,Amount in pairs(Ammos) do
            local Total = Framework.parseInt(Amount)
            if Total > 0 and Framework.ItemExist(Ammunation) then
                Framework.GenerateItem(Passport,Ammunation,Total,false)
            end
        end
    end

    if type(Attachs) == "table" then
        for _,Components in pairs(Attachs) do
            if type(Components) == "table" then
                for Component in pairs(Components) do
                    local Name = Framework.SplitOne(Component)
                    if Framework.ItemExist(Name) then
                        Framework.GenerateItem(Passport,Name,1,false)
                    end
                end
            end
        end
    end

    if (type(Ammos) == "table" and next(Ammos)) or (type(Attachs) == "table" and next(Attachs)) then
        Framework.Query("playerdata/RemoveData",{ Passport = Passport, Name = "Ammos" })
        Framework.Query("playerdata/RemoveData",{ Passport = Passport, Name = "Attachs" })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
    Equipped[Passport] = nil
end)
