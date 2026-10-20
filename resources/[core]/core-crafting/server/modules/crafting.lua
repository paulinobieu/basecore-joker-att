-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Parte estática do painel (identidade, abas e receitas) montada uma vez por
-- bancada. Só materiais e fila são refeitos a cada pedido.
local StationCache = {}

-- Uma fabricação por passaporte de cada vez.
local CraftLocks = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- RECIPEIMAGE
-----------------------------------------------------------------------------------------------------------------------------------------
local function RecipeImage(Item)
    return ItemsURL .. Framework.ItemIndex(Item) .. ".png"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDINGREDIENTS
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildIngredients(Required)
    local Ingredients = {}

    for Item, Amount in pairs(Required or {}) do
        if Framework.ItemExist(Item) then
            Ingredients[#Ingredients + 1] = {
                id     = Item,
                name   = Framework.ItemName(Item),
                image  = RecipeImage(Item),
                amount = parseInt(Amount, true),
            }
        end
    end

    table.sort(Ingredients, function(Left, Right)
        return Left.name < Right.name
    end)

    return Ingredients
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATIONCATALOG
-- Abas só aparecem quando a bancada libera mais de uma categoria.
-----------------------------------------------------------------------------------------------------------------------------------------
local function StationCatalog(StationId)
    if StationCache[StationId] then
        return StationCache[StationId]
    end

    local Station = Crafting.Stations[StationId]
    if not Station then
        return false
    end

    local Modes      = Station.Modes or {}
    local Categories = {}
    local Recipes    = {}
    local Materials  = {}
    local Seen       = {}

    if #Modes > 1 then
        Categories[#Categories + 1] = { id = "all", label = "Tudo" }
    end

    for _, Mode in ipairs(Modes) do
        local Group = Crafting.Recipes[Mode]

        if Group and Group.List then
            if #Modes > 1 then
                Categories[#Categories + 1] = { id = Mode, label = Group.Label or Mode }
            end

            for Item, Definition in pairs(Group.List) do
                if not Seen[Item] and Framework.ItemExist(Item) then
                    Seen[Item] = true

                    local Ingredients = BuildIngredients(Definition.Required)

                    for _, Ingredient in ipairs(Ingredients) do
                        Materials[Ingredient.id] = true
                    end

                    Recipes[#Recipes + 1] = {
                        id          = Item,
                        name        = Framework.ItemName(Item),
                        image       = RecipeImage(Item),
                        category    = Mode,
                        amount      = parseInt(Definition.Amount, true),
                        time        = parseInt(Definition.Time),
                        weight      = Framework.ItemWeight(Item),
                        ingredients = Ingredients,
                    }
                end
            end
        end
    end

    table.sort(Recipes, function(Left, Right)
        return Left.name < Right.name
    end)

    local Ingredients = {}
    for Item in pairs(Materials) do
        Ingredients[#Ingredients + 1] = Item
    end

    StationCache[StationId] = {
        Station = {
            label       = Station.Title,
            description = Station.Description,
        },
        Categories  = Categories,
        Recipes     = Recipes,
        Ingredients = Ingredients,
    }

    return StationCache[StationId]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINDSTATIONRECIPE
-- Fonte única da receita: a interface manda só o identificador.
-----------------------------------------------------------------------------------------------------------------------------------------
local function FindStationRecipe(StationId, RecipeId)
    local Station = Crafting.Stations[StationId]
    if not Station then
        return false
    end

    for _, Mode in ipairs(Station.Modes or {}) do
        local Group = Crafting.Recipes[Mode]

        if Group and Group.List and Group.List[RecipeId] then
            return Group.List[RecipeId]
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANUSESTATION
-- Revalidado na abertura e em toda ação seguinte.
-----------------------------------------------------------------------------------------------------------------------------------------
function CanUseStation(Passport, Source, StationId)
    local Station = Crafting.Stations[StationId]
    if not Station then
        return false, Crafting.Language.Failed
    end

    if Station.Permission and not Framework.HasGroup(Passport, Station.Permission, Station.Rank) then
        return false, Crafting.Language.NoPermission
    end

    if #(Framework.Coords(Source) - Station.Coords) > Crafting.MaxDistance then
        return false, Crafting.Language.TooFar
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDMATERIALS
-- Só os itens que as receitas da bancada usam: o inventário inteiro não vai
-- para a interface.
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildMaterials(Passport, Ingredients)
    local Materials = {}

    for _, Item in ipairs(Ingredients) do
        Materials[Item] = Framework.ItemAmount(Passport, Item)
    end

    return Materials
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDQUEUE
-- Remaining conta o tempo até a produção ficar pronta, incluindo as anteriores.
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildQueue(Passport)
    local Now   = os.time()
    local Lines = {}

    for _, Entry in ipairs(QueueEntries(Passport)) do
        Lines[#Lines + 1] = {
            id        = Entry.Id,
            name      = Framework.ItemName(Entry.Recipe),
            image     = RecipeImage(Entry.Recipe),
            amount    = Entry.Amount,
            duration  = Entry.Duration,
            remaining = math.max(0, Entry.EndsAt - Now),
        }
    end

    return Lines
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDUPDATE
-- Estado devolvido junto de cada ação para a interface não pedir de novo.
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildUpdate(Passport, StationId)
    local Catalog = StationCatalog(StationId)
    if not Catalog then
        return nil
    end

    return {
        materials = BuildMaterials(Passport, Catalog.Ingredients),
        queue     = BuildQueue(Passport),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDPANEL
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildPanel(Passport, StationId)
    local Catalog = StationCatalog(StationId)
    if not Catalog then
        return false
    end

    return {
        station    = Catalog.Station,
        categories = Catalog.Categories,
        recipes    = Catalog.Recipes,
        materials  = BuildMaterials(Passport, Catalog.Ingredients),
        queue      = BuildQueue(Passport),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSCRAFT
-- Os materiais saem do inventário na hora em que a produção entra na fila.
-----------------------------------------------------------------------------------------------------------------------------------------
function ProcessCraft(Passport, Source, StationId, RecipeId, Times)
    -- O lock fecha antes de qualquer checagem: validar e mutar acontecem sem
    -- brecha para um segundo pedido do mesmo passaporte.
    if CraftLocks[Passport] then
        return false, Crafting.Language.Failed
    end

    CraftLocks[Passport] = true

    local Executed, Result = xpcall(function()
        local Allowed, Denied = CanUseStation(Passport, Source, StationId)
        if not Allowed then
            return { false, Denied }
        end

        local Recipe = FindStationRecipe(StationId, RecipeId)
        if not Recipe then
            return { false, Crafting.Language.InvalidRecipe }
        end

        local Cached = EnsureQueue(Passport)
        if not Cached then
            return { false, Crafting.Language.Failed }
        end

        if #Cached.Entries >= Crafting.Queue.MaxEntries then
            return { false, Crafting.Language.QueueFull }
        end

        local Amount = math.min(parseInt(Times, true), Crafting.Queue.MaxAmount)

        for Item, Required in pairs(Recipe.Required or {}) do
            local Needed = parseInt(Required, true) * Amount

            if Framework.ItemAmount(Passport, Item) < Needed then
                return { false, string.format(Crafting.Language.NoMaterial, Needed, Framework.ItemName(Item)) }
            end
        end

        local Taken = {}

        local function Rollback()
            for Item, Given in pairs(Taken) do
                Framework.GiveItem(Passport, Item, Given)
            end
        end

        for Item, Required in pairs(Recipe.Required or {}) do
            local Needed = parseInt(Required, true) * Amount

            if not Framework.TakeItem(Passport, Item, Needed) then
                Rollback()

                return { false, string.format(Crafting.Language.NoMaterial, Needed, Framework.ItemName(Item)) }
            end

            Taken[Item] = Needed
        end

        local Produced = parseInt(Recipe.Amount, true) * Amount
        local Duration = parseInt(Recipe.Time) * Amount

        local Entry = PushEntry(Passport, RecipeId, Amount, Produced, Duration)
        if not Entry then
            Rollback()

            return { false, Crafting.Language.Failed }
        end

        Framework.Log("CRAFTOU", {
            message    = Framework.FullName(Passport) .. " #" .. Passport .. " iniciou " .. Produced .. "x " .. Framework.ItemName(RecipeId),
            playerName = Framework.FullName(Passport),
            playerId   = Passport,
            Item       = RecipeId,
            Quantidade = Produced,
        })

        return { true, string.format(Crafting.Language.Started, Produced .. "x " .. Framework.ItemName(RecipeId)) }
    end, debug.traceback)

    CraftLocks[Passport] = nil

    if not Executed then
        print("^1[CORE-CRAFTING]^7 " .. tostring(Result))
        return false, Crafting.Language.Failed
    end

    return Result[1], Result[2]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSCOLLECT
-- Capacidade é conferida aqui, na entrega, e não na hora de enfileirar.
-----------------------------------------------------------------------------------------------------------------------------------------
function ProcessCollect(Passport, Source, StationId, EntryId)
    if CraftLocks[Passport] then
        return false, Crafting.Language.Failed
    end

    CraftLocks[Passport] = true

    local Executed, Result = xpcall(function()
        local Allowed, Denied = CanUseStation(Passport, Source, StationId)
        if not Allowed then
            return { false, Denied }
        end

        local Entry = FindEntry(Passport, EntryId)
        if not Entry then
            return { false, Crafting.Language.NotFound }
        end

        if Entry.EndsAt > os.time() then
            return { false, Crafting.Language.NotReady }
        end

        if Framework.ReachedMax(Passport, Entry.Recipe, Entry.Amount) then
            return { false, string.format(Crafting.Language.MaxAmount, Framework.ItemName(Entry.Recipe)) }
        end

        local Weight = Framework.InventoryWeight(Passport) + (Framework.ItemWeight(Entry.Recipe) * Entry.Amount)
        if Weight > Framework.MaxWeight(Passport) then
            return { false, Crafting.Language.NoSpace }
        end

        if not Framework.GiveItem(Passport, Entry.Recipe, Entry.Amount) then
            return { false, Crafting.Language.NoSpace }
        end

        RemoveEntry(Passport, EntryId)

        Framework.Log("CRAFTOU", {
            message    = Framework.FullName(Passport) .. " #" .. Passport .. " coletou " .. Entry.Amount .. "x " .. Framework.ItemName(Entry.Recipe),
            playerName = Framework.FullName(Passport),
            playerId   = Passport,
            Item       = Entry.Recipe,
            Quantidade = Entry.Amount,
        })

        return { true, string.format(Crafting.Language.Collected, Entry.Amount .. "x " .. Framework.ItemName(Entry.Recipe)) }
    end, debug.traceback)

    CraftLocks[Passport] = nil

    if not Executed then
        print("^1[CORE-CRAFTING]^7 " .. tostring(Result))
        return false, Crafting.Language.Failed
    end

    return Result[1], Result[2]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSCANCEL
-- Produção pronta não é cancelada: nesse ponto só resta coletar.
-----------------------------------------------------------------------------------------------------------------------------------------
function ProcessCancel(Passport, Source, StationId, EntryId)
    if CraftLocks[Passport] then
        return false, Crafting.Language.Failed
    end

    CraftLocks[Passport] = true

    local Executed, Result = xpcall(function()
        local Allowed, Denied = CanUseStation(Passport, Source, StationId)
        if not Allowed then
            return { false, Denied }
        end

        local Entry = FindEntry(Passport, EntryId)
        if not Entry then
            return { false, Crafting.Language.NotFound }
        end

        if Entry.EndsAt <= os.time() then
            return { false, Crafting.Language.AlreadyDone }
        end

        local Recipe = FindStationRecipe(StationId, Entry.Recipe)
        local Refund = Crafting.Queue.Refund and Recipe and Recipe.Required or false

        if Refund then
            local Weight = Framework.InventoryWeight(Passport)

            for Item, Required in pairs(Refund) do
                Weight = Weight + (Framework.ItemWeight(Item) * parseInt(Required, true) * Entry.Times)
            end

            if Weight > Framework.MaxWeight(Passport) then
                return { false, Crafting.Language.NoSpace }
            end
        end

        RemoveEntry(Passport, EntryId)

        if not Refund then
            return { true, Crafting.Language.Canceled }
        end

        for Item, Required in pairs(Refund) do
            Framework.GiveItem(Passport, Item, parseInt(Required, true) * Entry.Times)
        end

        return { true, Crafting.Language.Refunded }
    end, debug.traceback)

    CraftLocks[Passport] = nil

    if not Executed then
        print("^1[CORE-CRAFTING]^7 " .. tostring(Result))
        return false, Crafting.Language.Failed
    end

    return Result[1], Result[2]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIFECYCLE
-- Um lock preso derrubaria as fabricações do jogador no próximo login.
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.OnPlayerDropped(function(Passport)
    CraftLocks[Passport] = nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATECONFIG
-- Avisa no console o que a interface não conseguiria mostrar.
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    for Index, Station in ipairs(Crafting.Stations) do
        for _, Mode in ipairs(Station.Modes or {}) do
            local Group = Crafting.Recipes[Mode]

            if not Group or not Group.List then
                print("^3[CORE-CRAFTING]^7 bancada " .. Index .. " (" .. Station.Title .. ") aponta para a categoria inexistente: " .. tostring(Mode))
            end
        end
    end

    for Mode, Group in pairs(Crafting.Recipes) do
        for Item, Definition in pairs(Group.List or {}) do
            if not Framework.ItemExist(Item) then
                print("^3[CORE-CRAFTING]^7 receita com item inexistente em " .. Mode .. ": " .. tostring(Item))
            end

            local Total = 0
            for Ingredient in pairs(Definition.Required or {}) do
                Total = Total + 1

                if not Framework.ItemExist(Ingredient) then
                    print("^3[CORE-CRAFTING]^7 ingrediente inexistente em " .. Mode .. "/" .. Item .. ": " .. tostring(Ingredient))
                end
            end

            if Total > Crafting.MaxIngredients then
                print("^3[CORE-CRAFTING]^7 receita " .. Mode .. "/" .. Item .. " tem " .. Total .. " ingredientes: a interface mostra " .. Crafting.MaxIngredients .. ".")
            end
        end
    end
end)
