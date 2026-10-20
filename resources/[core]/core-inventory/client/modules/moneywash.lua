-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
local Config = {
	Sends = {},
	Active = false,
	Cooldown = GetGameTimer()
}
local Settings = Inventory.MoneyWash
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Framework.TargetAddBox({
		coords = Settings.Init.xyz,
		size = vec3(0.75,0.75,2.0),
		rotation = Settings.Init.w,
		name = "MoneyWash",
		options = {
			{
				name = "moneywash:init:start",
				label = "Iniciar Expediente",
				icon = "fa-solid fa-briefcase",
				distance = Settings.TargetDistance,
				canInteract = function()
					return not Config.Active
				end,
				onSelect = function()
					TriggerEvent("moneywash:Init")
				end
			},{
				name = "moneywash:init:stop",
				label = "Finalizar Expediente",
				icon = "fa-solid fa-briefcase",
				distance = Settings.TargetDistance,
				canInteract = function()
					return Config.Active
				end,
				onSelect = function()
					TriggerEvent("moneywash:Init")
				end
			},{
				name = "moneywash:swap",
				label = "Trocar",
				icon = "fa-solid fa-rotate",
				distance = Settings.TargetDistance,
				onSelect = function()
					TriggerServerEvent("moneywash:Swap")
				end
			}
		}
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:INIT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("moneywash:Init",function()
	if Config.Active then
		TriggerEvent("Notify","Central de Empregos","Você acaba finalizar sua jornada de trabalho, esperamos que você tenha aprendido bastante hoje.","default",5000)
		Config.Active = false
		CleanBlips()
	else
		if Config.Cooldown <= GetGameTimer() then
			Config.Cooldown = GetGameTimer() + Settings.Cooldown
			TriggerEvent("Notify","Central de Empregos","Você acaba de dar inicio a sua jornada de trabalho, lembrando que a sua vida não se resume só a isso.","default",5000)
			Config.Active = true
			MakeBlips()
		else
			TriggerEvent("Notify","Aviso","Aguarde seu tempo de descanso.","amarelo",5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:SEND
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("moneywash:Send",function(Number,Value)
	if Config.Sends[Number] and Framework.Server.Washers(Value) then
		if DoesBlipExist(Config.Sends[Number]) then
			RemoveBlip(Config.Sends[Number])
		end

		Framework.TargetRemove("MoneyWash:"..Number)
		Config.Sends[Number] = nil

		if Framework.CountTable(Config.Sends) <= 0 then
			Config.Active = false
			CleanBlips()
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANBLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
function CleanBlips()
	for Selected,Blips in pairs(Config.Sends) do
		if DoesBlipExist(Blips) then
			RemoveBlip(Blips)
		end

		Framework.TargetRemove("MoneyWash:"..Selected)
		Config.Sends[Selected] = nil
	end

	Config.Sends = {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAKEBLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
function MakeBlips()
	for Index = 1,Settings.RouteCount do
		local Selected = math.random(#Settings.Locations)
		local Number = tostring(Selected)
		if Config.Sends[Number] then
			repeat
				Selected = math.random(#Settings.Locations)
				Number = tostring(Selected)
			until not Config.Sends[Number]
		end

		local Options = {}
		for Value,Amount in ipairs(Settings.Values) do
			Options[Value] = {
				name = "moneywash:send:"..Selected..":"..Value,
				label = "Entregar "..Framework.Currency..Framework.Dotted(Amount),
				icon = "fa-solid fa-money-bill",
				distance = Settings.DeliveryDistance,
				onSelect = function()
					TriggerEvent("moneywash:Send",Number,Amount)
				end
			}
		end

		Framework.TargetAddSphere({
			coords = Settings.Locations[Selected],
			radius = Settings.DeliveryDistance,
			name = "MoneyWash:"..Selected,
			options = Options
		})

		Config.Sends[Number] = AddBlipForCoord(Settings.Locations[Selected])
		SetBlipSprite(Config.Sends[Number],Settings.Blip.Sprite)
		SetBlipDisplay(Config.Sends[Number],Settings.Blip.Display)
		SetBlipAsShortRange(Config.Sends[Number],true)
		SetBlipColour(Config.Sends[Number],Settings.Blip.Color)
		SetBlipScale(Config.Sends[Number],Settings.Blip.Scale)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Settings.Blip.Name)
		EndTextCommandSetBlipName(Config.Sends[Number])
	end
end
