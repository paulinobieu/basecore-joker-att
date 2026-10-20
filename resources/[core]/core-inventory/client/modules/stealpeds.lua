-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Timer = GetGameTimer()
local Settings = Inventory.ClientItems.StealPeds
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Pid = PlayerId()
		local TimeDistance = 999
		local Ped = PlayerPedId()

		if not IsPedInAnyVehicle(Ped) and IsPedArmed(Ped,6) and IsPlayerFreeAiming(Pid) then
			local Progress = Settings.Progress
			local Entitys = ClosestPed(Settings.Distance)
			if Entitys and GetGameTimer() >= Timer and GetVehiclePedIsIn(Entitys,true) == 0 and not Entity(Entitys)["state"]["Steal"] then
				Timer = GetGameTimer() + Settings.RetryDelay

				NetworkRequestControlOfEntity(Entitys)
				while not NetworkHasControlOfEntity(Entitys) do
					Wait(0)
				end

				ClearPedTasks(Entitys)
				ClearPedSecondaryTask(Entitys)
				ClearPedTasksImmediately(Entitys)

				TaskSetBlockingOfNonTemporaryEvents(Entitys,true)
				SetBlockingOfNonTemporaryEvents(Entitys,true)
				SetEntityAsMissionEntity(Entitys,true,true)
				SetPedDropsWeaponsWhenDead(Entitys,false)
				SetPedSuffersCriticalHits(Entitys,false)
				TaskTurnPedToFaceEntity(Entitys,Ped,0.0)

				LocalPlayer["state"]:set("Buttons",true,true)
				LocalPlayer["state"]:set("Commands",true,true)
				Entity(Entitys)["state"]:set("Steal",true,true)

				SetTimeout(Settings.StartDelay,function()
					if Framework.LoadAnim(Settings.HandsUp.Dict) then
						TaskPlayAnim(Entitys,Settings.HandsUp.Dict,Settings.HandsUp.Name,8.0,8.0,-1,16,1,0,0,0)
					end
				end)

				while true do
					local Pid = PlayerId()
					local Ped = PlayerPedId()
					local Coords = GetEntityCoords(Ped)
					local EntityCoords = GetEntityCoords(Entitys)

					if #(Coords - EntityCoords) <= Settings.Distance and IsPlayerFreeAiming(Pid) then
						Progress = Progress - 1

						if not IsEntityPlayingAnim(Entitys,Settings.HandsUp.Dict,Settings.HandsUp.Name,3) then
							TaskPlayAnim(Entitys,Settings.HandsUp.Dict,Settings.HandsUp.Name,8.0,8.0,-1,16,1,0,0,0)
						end

						if Progress <= 0 and Framework.LoadModel(Settings.Bag.Model) then
							local Object = CreateObjectNoOffset(Settings.Bag.Model,Coords["x"],Coords["y"],Coords["z"],false,false,false)
							AttachEntityToEntity(Object,Entitys,GetPedBoneIndex(Entitys,Settings.Bag.Bone),Settings.Bag.Offset[1],Settings.Bag.Offset[2],Settings.Bag.Offset[3],Settings.Bag.Rotation[1],Settings.Bag.Rotation[2],Settings.Bag.Rotation[3],true,true,false,true,2,true)

							if Framework.LoadAnim(Settings.Delivery.Dict) then
								TaskPlayAnim(Entitys,Settings.Delivery.Dict,Settings.Delivery.Name,8.0,8.0,-1,16,1,0,0,0)
							end

							Wait(Settings.DeliveryDelay)

							if DoesEntityExist(Object) then
								DeleteEntity(Object)
							end

							LocalPlayer["state"]:set("Buttons",false,true)
							LocalPlayer["state"]:set("Commands",false,true)
							TaskWanderStandard(Entitys,10.0,10)
							SetPedAsNoLongerNeeded(Entitys)
							Framework.Server.StealPeds()
							Framework.Destroy()

							break
						end
					else
						LocalPlayer["state"]:set("Buttons",false,true)
						LocalPlayer["state"]:set("Commands",false,true)
						TaskWanderStandard(Entitys,10.0,10)
						SetPedAsNoLongerNeeded(Entitys)

						break
					end

					Wait(1)
				end
			end
		end

		Wait(TimeDistance)
	end
end)
