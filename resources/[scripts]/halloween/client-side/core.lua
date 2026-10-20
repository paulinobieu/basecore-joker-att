-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Alpha = {}
local Objects = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	LoadModel("tfx-summer_abroba")

	if GlobalState.Halloween then
		for Index in pairs(Locations) do
			if GlobalState["Halloween:"..Index] then
				Alpha[Index] = AddBlipForRadius(Locations[Index].xyz,25.0)
				SetBlipAlpha(Alpha[Index],255)
				SetBlipColour(Alpha[Index],81)
			end
		end
	end

	while true do
		if GlobalState.Halloween then
			local Ped = PlayerPedId()
			local Coords = GetEntityCoords(Ped)

			for Index,OtherCoords in pairs(Locations) do
				local Name = "Halloween:"..Index
				local Distance = #(Coords - OtherCoords.xyz)

				if Distance <= 100 and GlobalState[Name] then
					if not Objects[Index] then
						Objects[Index] = CreateObjectNoOffset("tfx-summer_abroba",OtherCoords.xyz,false,false,false)
						SetEntityLodDist(Objects[Index],0xFFFF)
						FreezeEntityPosition(Objects[Index],true)
						PlaceObjectOnGroundProperly(Objects[Index])
						SetEntityHeading(Objects[Index],OtherCoords.w)

						exports.ox_target:addBoxZone({
							coords = vec3(OtherCoords.x,OtherCoords.y,OtherCoords.z + 0.25),
							size = vec3(0.75,0.75,2.0),
							rotation = OtherCoords.w,
							name = Name,
							options = {
								{
									name = Name..":open",
									label = "Abrir",
									icon = "fa-solid fa-ghost",
									distance = 2.0,
									onSelect = function()
										TriggerEvent("chest:Open",Name,"Custom")
									end
								}
							}
						})
					end
				elseif Objects[Index] then
					exports.ox_target:removeZone(Name)

					if DoesEntityExist(Objects[Index]) then
						DeleteEntity(Objects[Index])
					end

					Objects[Index] = nil
				end
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
for Index in pairs(Locations) do
	local Name = "Halloween:"..Index
	AddStateBagChangeHandler(Name,nil,function(_,_,Value)
		if not Value then
			TriggerEvent("inventory:Closed",Name)

			if Objects[Index] then
				exports.ox_target:removeZone(Name)

				if DoesEntityExist(Objects[Index]) then
					DeleteEntity(Objects[Index])
				end

				Objects[Index] = nil
			end

			if Alpha[Index] then
				if DoesBlipExist(Alpha[Index]) then
					RemoveBlip(Alpha[Index])
				end

				Alpha[Index] = nil
			end
		else
			Alpha[Index] = AddBlipForRadius(Locations[Index].xyz,25.0)
			SetBlipAlpha(Alpha[Index],255)
			SetBlipColour(Alpha[Index],81)
		end
	end)
end