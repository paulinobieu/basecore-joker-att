-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-- Lancheira aberta por passaporte. A chave do armazenamento vem do `hash` do
-- meta, entao cada lancheira tem o proprio conteudo mesmo com varias no jogo.
-----------------------------------------------------------------------------------------------------------------------------------------
local Opened = {}
local Settings = Inventory.Chest.Lunchbag
-----------------------------------------------------------------------------------------------------------------------------------------
-- LUNCHBAGKEY
-----------------------------------------------------------------------------------------------------------------------------------------
local function LunchbagKey(Meta)
    local Hash = Meta and Meta.hash

    return Hash and ("Lunchbag:"..Hash) or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHILLEDELAPSED
--
-- Quanto tempo de estrago o alimento realmente acumulou. O que passou fora da
-- lancheira conta inteiro; o periodo dentro conta dividido pelo multiplicador.
-- `chilled` guarda o instante em que o item entrou.
-----------------------------------------------------------------------------------------------------------------------------------------
local function ChilledElapsed(Meta)
    if not Meta or not Meta.created then
        return 0
    end

    local Now = os.time()

    if not Meta.chilled then
        return Now - Meta.created
    end

    local Outside = Meta.chilled - Meta.created
    local Inside = math.max(0,Now - Meta.chilled)

    return Outside + math.floor(Inside / Settings.Multiplier)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BAKECREATED
--
-- Ao sair da lancheira o desconto vira definitivo: `created` e empurrado para
-- frente para que o item volte a envelhecer no ritmo normal ja creditado.
-----------------------------------------------------------------------------------------------------------------------------------------
local function BakeCreated(Meta)
    if not Meta or not Meta.created then
        return Meta
    end

    Meta.created = os.time() - ChilledElapsed(Meta)
    Meta.chilled = nil

    return Meta
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDCONTENT
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildContent(Key)
    local Content = Framework.GetSrvData(Key,true)
    local List = {}

    for Slot,v in pairs(Content) do
        if v.amount > 0 and Framework.ItemExist(v.item) then
            local Meta = v.meta or {}
            local Entry = {
                key = v.item,
                item = v.item,
                amount = v.amount,
                type = Framework.ItemType(v.item),
                name = Framework.ItemName(v.item),
                peso = Framework.ItemWeight(v.item),
                description = Framework.ItemDescription(v.item) or ""
            }

            local Durability = Framework.ItemDurability(v.item)
            if Durability and Meta.created then
                Entry.durability = ChilledElapsed(Meta)
                Entry.days = Durability
            end

            local Loaded = Framework.ItemLoads(v.item)
            if Loaded and Meta.charges then
                Entry.charges = Framework.parseInt(Meta.charges * (100 / Loaded))
            end

            List[Slot] = Entry
        end
    end

    return List
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDCONTENT
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendContent(source,Key)
    TriggerClientEvent("inventory:Lunchbag",source,{
        title = Settings.Title,
        description = Settings.Description,
        slots = Settings.Slots,
        items = BuildContent(Key)
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENLUNCHBAG
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenLunchbag(source,Passport,Slot)
    local Meta = Framework.GetItemMeta(Passport,Slot)
    local Hash = Meta and Meta.hash

    -- Lancheira criada por caminho que nao passa pelo SortMetaItem (GiveItem,
    -- loot antigo) chega sem hash e ficaria sem compartimento. Aqui ela ganha
    -- o dela na primeira abertura, em vez de nao abrir.
    if not Hash then
        Hash = Framework.GenerateHash(Settings.Item)
        Framework.SetItemMeta(Passport,Slot,"hash",Hash)
    end

    local Key = LunchbagKey({ hash = Hash })
    if not Key then
        return false
    end

    Opened[Passport] = Key

    SendContent(source,Key)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSELUNCHBAG
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CloseLunchbag()
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    Opened[Passport] = nil

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORELUNCHBAG
-----------------------------------------------------------------------------------------------------------------------------------------
local function StoreLunchbag(source,Passport,Key,Slot,Target,Amount)
    local Inv = Framework.Inventory(Passport)
    local Data = Inv[Slot]
    if not Data or Data.amount < Amount then
        return false
    end

    if not Framework.ItemFood(Data.item) then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.lunchbagFood,"vermelho")
        return false
    end

    if Framework.StoreChest(Passport,Key,Amount,Settings.Weight,Slot,Target,true,true) ~= false then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.lunchbagFull,"amarelo")
        return false
    end

    if Data.meta and Data.meta.created then
        Framework.SetChestMeta(Key,Target,"chilled",os.time(),true)
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKELUNCHBAG
-----------------------------------------------------------------------------------------------------------------------------------------
local function TakeLunchbag(source,Passport,Key,Slot,Target,Amount)
    local Content = Framework.GetSrvData(Key,true)
    local Data = Content[Slot]
    if not Data or Data.amount < Amount then
        return false
    end

    -- Lido antes de sair: o desconto do frio precisa do `chilled` que ainda
    -- esta na entrada da lancheira.
    local Baked = BakeCreated(Framework.ItemMetaClone(Data.meta))

    if Framework.TakeChest(Passport,Key,Amount,Slot,Target,true) ~= false then
        return false
    end

    -- O TakeChest copia o meta como estava dentro da lancheira; aqui ele volta
    -- a envelhecer no ritmo normal, com o tempo refrigerado ja creditado.
    if Baked and Baked.created then
        Framework.SetItemMeta(Passport,Target,"created",Baked.created)
        Framework.SetItemMeta(Passport,Target,"chilled",nil)
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FREESLOT
-----------------------------------------------------------------------------------------------------------------------------------------
function FreeSlot(Passport,Item,Meta)
    local Inventory = Framework.Inventory(Passport)
    local Slots = Framework.InventorySlots(Passport)
    local Empty = nil

    for Number = 0,Slots - 1 do
        local Slot = tostring(Number)
        local Data = Inventory[Slot]

        if not Data then
            Empty = Empty or Slot
        elseif Framework.ItemMetaStackable(Data.item,Data.meta,Item,Meta) then
            return Slot
        end
    end

    return Empty
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMPTYLUNCHBAG
-- Botao REMOVER TODOS. Devolve o que couber e para no primeiro que nao couber,
-- em vez de dropar no chao sem o jogador pedir.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.EmptyLunchbag()
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    local Key = Opened[Passport]
    if not Key then
        return false
    end

    local Content = Framework.GetSrvData(Key,true)
    local Slots = {}

    for Slot in pairs(Content) do
        Slots[#Slots + 1] = Slot
    end

    table.sort(Slots)

    local Moved = 0
    local Blocked = false

    for _,Slot in ipairs(Slots) do
        local Entry = Content[Slot]
        if Entry and Entry.amount > 0 then
            local Free = FreeSlot(Passport,Entry.item,Entry.meta)

            if not Free or not Framework.CheckWeight(Passport,Entry.item,Entry.amount) then
                Blocked = true
                break
            end

            if TakeLunchbag(source,Passport,Key,Slot,Free,Entry.amount) then
                Moved = Moved + 1
            else
                Blocked = true
                break
            end
        end
    end

    if Blocked then
        TriggerClientEvent("inventory:Notify",source,"Atenção",InventoryLocale.overweight,"amarelo")
    end

    if Moved > 0 then
        SendContent(source,Key)
        TriggerClientEvent("inventory:Update",source)
    end

    return Moved > 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOVELUNCHBAG
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.MoveLunchbag(From,Slot,To,Target,Amount)
    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    local Key = Opened[Passport]
    if not Key then
        return false
    end

    Slot = tostring(Slot)
    Target = tostring(Target)
    Amount = Framework.parseInt(Amount,true)

    if (tonumber(Target) or -1) < 0 then
        return false
    end

    local Moved = false

    if From == "inventory" and To == "container" then
        if (tonumber(Target) or 0) >= Settings.Slots then
            return false
        end

        Moved = StoreLunchbag(source,Passport,Key,Slot,Target,Amount)
    elseif From == "container" and To == "inventory" then
        if (tonumber(Target) or 0) >= Framework.InventorySlots(Passport) then
            return false
        end

        Moved = TakeLunchbag(source,Passport,Key,Slot,Target,Amount)
    elseif From == "container" and To == "container" then
        if (tonumber(Target) or 0) >= Settings.Slots then
            return false
        end

        Moved = Framework.UpdateChest(Passport,Key,Slot,Target,Amount,true) == false
    end

    if Moved then
        SendContent(source,Key)
        TriggerClientEvent("inventory:Update",source)
    end

    return Moved
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
    Opened[Passport] = nil
end)
