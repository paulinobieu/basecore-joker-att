-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local OptionName = "admin:objecthash"
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function IsAdmin()
	return LocalPlayer.state.Admin and true or false
end

local function CopyObjectHash(Entity)
	if not IsAdmin() or not Entity or Entity <= 0 or not DoesEntityExist(Entity) or GetEntityType(Entity) ~= 3 then
		return false
	end

	local Hash = GetEntityModel(Entity)
	local Copied = pcall(function()
		exports.ox_lib:setClipboard(tostring(Hash))
	end)

	print(("[core-modules] Hash do objeto: %s"):format(Hash))

	if Copied then
		TriggerEvent("Notify","Administração",("Hash do objeto <b>%s</b> copiado."):format(Hash),"verde",5000)
	else
		TriggerEvent("Notify","Administração",("Hash do objeto: <b>%s</b>. Consulte também o console F8."):format(Hash),"amarelo",8000)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL OBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
exports.ox_target:addGlobalObject({
	{
		name = OptionName,
		label = "Pegar hash",
		icon = "fa-solid fa-hashtag",
		distance = 2.0,
		canInteract = function(Entity)
			return IsAdmin() and DoesEntityExist(Entity) and GetEntityType(Entity) == 3
		end,
		onSelect = function(Data)
			if type(Data) == "table" then
				CopyObjectHash(Data.entity)
			end
		end
	}
})
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOURCE STOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onClientResourceStop",function(Resource)
	if Resource == GetCurrentResourceName() then
		pcall(function()
			exports.ox_target:removeGlobalObject(OptionName)
		end)
	end
end)
