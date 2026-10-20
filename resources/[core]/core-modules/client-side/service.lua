-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local OnDuty = {}
local Services = {
	{
		Permission = "Policia",
		Coords = vec3(2534.49,-313.66,92.96),
		Distance = 1.5
	},{
		Permission = "Policia",
		Coords = vec3(-992.72,-2009.87,12.31),
		Distance = 1.5
	},{
		Permission = "HospitalNorte",
		Coords = vec3(1759.77,3629.63,34.31),
		Distance = 1.5
	},{
		Permission = "HospitalSul",
		Coords = vec3(-1026.92,-424.59,39.64),
		Distance = 1.5
	},{
		Permission = "Bennys",
		Coords = vec3(-236.80,-1339.78,31.94),
		Distance = 1.5
	},{
		Permission = "SodaPop",
		Coords = vec3(-1393.54,-1399.33,4.73),
		Distance = 1.5
	},{
		Permission = "MooMoo",
		Coords = vec3(-584.76,-1063.62,22.37),
		Distance = 1.5
	},{
		Permission = "OsakaSushi",
		Coords = vec3(-799.50,-145.13,37.94),
		Distance = 1.5
	},{
		Permission = "MarinaLounge",
		Coords = vec3(1533.54,3785.70,34.42),
		Distance = 1.5
	},{
		Permission = "KittyCafe",
		Coords = vec3(1146.32,-799.16,58.11),
		Distance = 1.5
	},{
		Permission = "Policia",
		Coords = vec3(-1642.53,177.80,61.93),
		Distance = 1.5
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIANTS
-----------------------------------------------------------------------------------------------------------------------------------------
local Variants = {
	Militar = "Policia",
	Civil = "Policia",
	CORE = "Policia",
	BOPE = "Policia",
	PRF = "Policia"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while GetResourceState("sleepless_interact") ~= "started" do
		Wait(500)
	end

	for Index,v in pairs(Services) do
		exports.sleepless_interact:addCoords(v.Coords,{
			{
				name = "Service:"..Index..":start",
				label = "Iniciar Expediente",
				icon = "briefcase",
				distance = v.Distance,
				canInteract = function()
					return not OnDuty[v.Permission]
				end,
				onSelect = function()
					TriggerServerEvent("target:Service",v.Permission)
				end
			},{
				name = "Service:"..Index..":stop",
				label = "Finalizar Expediente",
				icon = "briefcase",
				distance = v.Distance,
				canInteract = function()
					return OnDuty[v.Permission]
				end,
				onSelect = function()
					TriggerServerEvent("target:Service",v.Permission)
				end
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE:CLIENT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("service:Client")
AddEventHandler("service:Client",function(Permission,Status)
	OnDuty[Variants[Permission] or Permission] = Status
end)
