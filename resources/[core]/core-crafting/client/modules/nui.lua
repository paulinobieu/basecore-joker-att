-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYRESULT
-- Toda ação volta com o estado novo de materiais e fila: a interface recebe o
-- update antes da resposta do callback.
-----------------------------------------------------------------------------------------------------------------------------------------
local function ApplyResult(Result)
    if type(Result) ~= "table" then
        return { success = false, message = Crafting.Language.Failed }
    end

    if Result.update then
        SendNUIMessage({ action = "craft:update", payload = Result.update })
    end

    return { success = Result.success, message = Result.message }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFT:GETDATA
-- Responde com o painel já validado na abertura.
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("craft:getData", function(_, Callback)
    if not CraftOpen or not CraftData then
        Callback(false)
        return
    end

    Callback(CraftData)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFT:START
-- A interface manda só receita e quantidade; o servidor refaz materiais,
-- permissão e distância.
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("craft:start", function(Data, Callback)
    if not CraftOpen or type(Data) ~= "table" or type(Data.recipe) ~= "string" then
        Callback({ success = false, message = Crafting.Language.InvalidRecipe })
        return
    end

    Callback(ApplyResult(vSERVER.StartCraft(CraftOpen, Data.recipe, Data.amount)))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFT:COLLECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("craft:collect", function(Data, Callback)
    if not CraftOpen or type(Data) ~= "table" or not tonumber(Data.id) then
        Callback({ success = false, message = Crafting.Language.NotFound })
        return
    end

    Callback(ApplyResult(vSERVER.CollectCraft(CraftOpen, Data.id)))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFT:CANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("craft:cancel", function(Data, Callback)
    if not CraftOpen or type(Data) ~= "table" or not tonumber(Data.id) then
        Callback({ success = false, message = Crafting.Language.NotFound })
        return
    end

    Callback(ApplyResult(vSERVER.CancelCraft(CraftOpen, Data.id)))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFT:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("craft:close", function(_, Callback)
    CloseBench()
    Callback(true)
end)
