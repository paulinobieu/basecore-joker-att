-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Target = Inventory.Robbery.Target
	for Number,v in pairs(Inventory.Robbery.Points) do
		local Mode = v.Mode
		Framework.TargetAddSphere({
			coords = v.Coords,
			radius = Target.Radius,
			name = "Robbery:"..Number,
			options = {
				{
					name = "inventory:robbery:"..Number,
					label = Target.Label,
					icon = Target.Icon,
					distance = Target.Distance,
					onSelect = function()
						TriggerServerEvent("inventory:Robbery",Number,Mode)
					end
				}
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:EXPLOSION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Explosion")
AddEventHandler("inventory:Explosion",function(Coords)
	AddExplosion(Coords.x,Coords.y,Coords.z,4,1.0,true,false,true)
end)
