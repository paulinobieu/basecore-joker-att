-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("core-arsenal")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local CurrentArsenal = nil
local NUIOpen = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResolveColor()
	local R,G,B = Functions.HexToRgb(Arsenal.ThemeColor or "#dc1553")
	return string.format("%d, %d, %d",R,G,B)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenArsenal(name)
	if NUIOpen then
		return
	end

	if not vSERVER.CheckPermission(name) then
		Functions.Notify(nil,"vermelho","Você não tem permissão para acessar este arsenal.")
		return
	end

	local data = vSERVER.GetArsenalData(name)
	if not data or #data == 0 then
		return
	end

	CurrentArsenal = name
	NUIOpen = true

	SetNuiFocus(true,true)
	SendNUIMessage({ action = "setColor", payload = ResolveColor() })
	SendNUIMessage({ action = "setArsenal", payload = data })
	SendNUIMessage({ action = "setVisible", payload = true })

	if Arsenal.OpenSound then
		TriggerEvent("sounds:Private","shop",0.5)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseArsenal()
	if not NUIOpen then
		return
	end

	NUIOpen = false
	CurrentArsenal = nil

	SetNuiFocus(false,false)
	SendNUIMessage({ action = "setVisible", payload = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:closeUi",function(_,Callback)
	CloseArsenal()
	Callback(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:BUY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("buyProducts",function(Data,Callback)
	if not CurrentArsenal then
		Callback(false)
		return
	end

	local Items = {}
	if Data and type(Data.items) == "table" then
		for _,Entry in ipairs(Data.items) do
			local Key = Entry.key or Entry.id or Entry.item
			local Amount = tonumber(Entry.quantity) or tonumber(Entry.amount) or 1
			if Key then
				Items[#Items + 1] = { item = Key, amount = Amount }
			end
		end
	end

	local Status,Message = vSERVER.ProcessPurchase(CurrentArsenal,Items)
	Functions.Notify(nil,Status and "verde" or "vermelho",Message or (Status and "Compra realizada com sucesso!" or "Não foi possível concluir a compra."))

	Callback(Status and true or false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	if not exports.sleepless_interact then
		return
	end

	for Name,Shop in pairs(Arsenal.Locations) do
		exports.sleepless_interact:addCoords(Shop.coords,{
			name = "core-arsenal:"..Name,
			label = Arsenal.InteractLabel or "Abrir Arsenal",
			icon = Arsenal.InteractIcon or "person-rifle",
			distance = Shop.distance or Arsenal.InteractDistance or 1.5,
			onSelect = function()
				OpenArsenal(Name)
			end
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(Resource)
	if Resource == GetCurrentResourceName() and NUIOpen then
		SetNuiFocus(false,false)
	end
end)
