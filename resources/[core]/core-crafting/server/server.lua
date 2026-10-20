-----------------------------------------------------------------------------------------------------------------------------------------
-- NORMALIZESTATION
-- A interface manda só o índice da bancada: tudo mais é resolvido aqui.
-----------------------------------------------------------------------------------------------------------------------------------------
local function NormalizeStation(StationId)
    local Station = parseInt(StationId)

    return Crafting.Stations[Station] and Station or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NORMALIZEENTRY
-----------------------------------------------------------------------------------------------------------------------------------------
local function NormalizeEntry(EntryId)
    local Entry = parseInt(EntryId)

    return Entry > 0 and Entry or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSTATION
-- Entrada da interface: devolve o painel quando o acesso é liberado.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.GetStation(StationId)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    local Station = NormalizeStation(StationId)
    if not Station then
        return false
    end

    local Allowed, Denied = CanUseStation(Passport, source, Station)
    if not Allowed then
        if Denied then
            Framework.Notify(source, Denied, "vermelho")
        end

        return false
    end

    return BuildPanel(Passport, Station)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTCRAFT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.StartCraft(StationId, RecipeId, Amount)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return { success = false, message = Crafting.Language.Failed }
    end

    local Station = NormalizeStation(StationId)
    if not Station or type(RecipeId) ~= "string" or #RecipeId > 48 then
        return { success = false, message = Crafting.Language.InvalidRecipe }
    end

    local Success, Message = ProcessCraft(Passport, source, Station, RecipeId, Amount)

    return {
        success = Success,
        message = Message,
        update  = BuildUpdate(Passport, Station),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COLLECTCRAFT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CollectCraft(StationId, EntryId)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return { success = false, message = Crafting.Language.Failed }
    end

    local Station = NormalizeStation(StationId)
    local Entry   = NormalizeEntry(EntryId)
    if not Station or not Entry then
        return { success = false, message = Crafting.Language.NotFound }
    end

    local Success, Message = ProcessCollect(Passport, source, Station, Entry)

    return {
        success = Success,
        message = Message,
        update  = BuildUpdate(Passport, Station),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELCRAFT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CancelCraft(StationId, EntryId)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return { success = false, message = Crafting.Language.Failed }
    end

    local Station = NormalizeStation(StationId)
    local Entry   = NormalizeEntry(EntryId)
    if not Station or not Entry then
        return { success = false, message = Crafting.Language.NotFound }
    end

    local Success, Message = ProcessCancel(Passport, source, Station, Entry)

    return {
        success = Success,
        message = Message,
        update  = BuildUpdate(Passport, Station),
    }
end
