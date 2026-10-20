-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Timer = 0
local Sale = Inventory.Drugs.Interaction
local Effects = Inventory.Drugs.Effects
-----------------------------------------------------------------------------------------------------------------------------------------
-- COCAINE
-----------------------------------------------------------------------------------------------------------------------------------------
local Cocaine = 0
local CocaineTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- METHAMPHETAMINE
-----------------------------------------------------------------------------------------------------------------------------------------
local Methamphetamine = 0
local MethamphetamineTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- METADONE
-----------------------------------------------------------------------------------------------------------------------------------------
local Metadone = 0
local MetadoneTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEROIN
-----------------------------------------------------------------------------------------------------------------------------------------
local Heroin = 0
local HeroinTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRACK
-----------------------------------------------------------------------------------------------------------------------------------------
local Crack = 0
local CrackTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- JOINT
-----------------------------------------------------------------------------------------------------------------------------------------
local Joint = 0
local JointTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- OXYCONTIN
-----------------------------------------------------------------------------------------------------------------------------------------
local Oxycontin = 0
local OxycontinTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENERGETIC
-----------------------------------------------------------------------------------------------------------------------------------------
local Energetic = 0
local EnergeticTimer = 0
local EnergeticRate = 0
LocalPlayer.state.Energetic = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()

		if not IsPedInAnyVehicle(Ped) then
			local Entitys = ClosestPed(Sale.PedRadius)
			local Progress = GetGameTimer()
			if Entitys and not Entity(Entitys)["state"]["Drugs"] then
				TimeDistance = 1

				if IsControlJustPressed(1,38) and GetGameTimer() >= Timer and GetVehiclePedIsIn(Entitys,true) == 0 then
					local TimeDrugs = Framework.Server.CheckDrugs()
					if TimeDrugs then
						TriggerEvent("Progress","Vendendo",TimeDrugs * 1000)
						Progress = GetGameTimer() + (TimeDrugs * 1000)
						Timer = GetGameTimer() + Sale.RetryDelay

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
						Entity(Entitys)["state"]:set("Drugs",true,true)

						SetTimeout(Sale.AnimationDelay,function()
							if Framework.LoadAnim(Sale.StartAnimation.Dict) then
								TaskPlayAnim(Entitys,Sale.StartAnimation.Dict,Sale.StartAnimation.Name,8.0,8.0,-1,49,0,0,0,0)
							end
						end)

						while true do
							local Ped = PlayerPedId()
							local Coords = GetEntityCoords(Ped)
							local EntityCoords = GetEntityCoords(Entitys)

							if #(Coords - EntityCoords) <= Sale.CancelDistance then
								if Progress <= GetGameTimer() and Framework.LoadModel(Sale.Exchange.Money.Model) then
									local Money = Sale.Exchange.Money
									local Player = Sale.Exchange.Player
									local Object = CreateObjectNoOffset(Money.Model,Coords["x"],Coords["y"],Coords["z"],false,false,false)
									AttachEntityToEntity(Object,Entitys,GetPedBoneIndex(Entitys,Money.Bone),Money.Offset[1],Money.Offset[2],Money.Offset[3],Money.Rotation[1],Money.Rotation[2],Money.Rotation[3],true,true,false,true,2,true)
									Framework.CreateObjects(Player.Dict,Player.Name,Player.Model,Player.Flag,Player.Bone,Player.Offset[1],Player.Offset[2],Player.Offset[3],Player.Rotation[1],Player.Rotation[2],Player.Rotation[3])
									ClearPedSecondaryTask(Entitys)
									ClearPedTasks(Entitys)

									local Customer = Sale.Exchange.CustomerAnimation
									if Framework.LoadAnim(Customer.Dict) then
										TaskPlayAnim(Entitys,Customer.Dict,Customer.Name,8.0,8.0,-1,16,0,0,0,0)
									end

									Wait(Sale.ExchangeDelay)

									if DoesEntityExist(Object) then
										DeleteEntity(Object)
									end

									LocalPlayer["state"]:set("Buttons",false,true)
									LocalPlayer["state"]:set("Commands",false,true)
									TaskWanderStandard(Entitys,10.0,10)
									SetEntityAsNoLongerNeeded(Entitys)
									Framework.Server.PaymentDrugs()
									Framework.Destroy()

									break
								end
							else
								LocalPlayer["state"]:set("Buttons",false,true)
								LocalPlayer["state"]:set("Commands",false,true)
								TriggerEvent("Progress","Cancelando",1000)
								TaskWanderStandard(Entitys,10.0,10)
								SetEntityAsNoLongerNeeded(Entitys)
								ClearPedSecondaryTask(Entitys)
								ClearPedTasks(Entitys)

								break
							end

							Wait(1)
						end
					end
				end
			end

		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESTPED
-----------------------------------------------------------------------------------------------------------------------------------------
function ClosestPed(Radius)
	local Selected = false
	local Ped = PlayerPedId()
	local Radius = Radius + 0.0001
	local Coords = GetEntityCoords(Ped)
	local GamePool = GetGamePool("CPed")

	for _,Entity in pairs(GamePool) do
		if Entity ~= PlayerPedId() and not IsPedAPlayer(Entity) and not IsEntityDead(Entity) and not IsPedDeadOrDying(Entity,true) and NetworkGetEntityIsNetworked(Entity) and not DecorGetBool(Entity,"CREATIVE_PED") and not IsPedInAnyVehicle(Entity) and GetPedType(Entity) ~= 28 then
			local EntityCoords = GetEntityCoords(Entity)
			local EntityDistance = #(Coords - EntityCoords)

			if EntityDistance < Radius then
				Radius = EntityDistance
				Selected = Entity
			end
		end
	end

	return Selected
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COCAINE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Cocaine")
AddEventHandler("Cocaine",function()
	local Effect = Effects.Cocaine
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,0,true)
	Cocaine = Cocaine + Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- METHAMPHETAMINE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Methamphetamine")
AddEventHandler("Methamphetamine",function()
	local Effect = Effects.Methamphetamine
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,0,true)
	Methamphetamine = Methamphetamine + Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- METADONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Metadone")
AddEventHandler("Metadone",function()
	local Effect = Effects.Metadone
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,Effect.EffectDuration,false)

	if not LocalPlayer["state"]["DamageModify"] then
		LocalPlayer["state"]:set("DamageModify",true,false)
	end

	SetPlayerMeleeWeaponDamageModifier(PlayerId(),Effect.PlayerMeleeDamage)
	SetPlayerWeaponDamageModifier(PlayerId(),Effect.PlayerWeaponDamage)
	SetAiMeleeWeaponDamageModifier(Effect.AiMeleeDamage)
	SetAiWeaponDamageModifier(Effect.AiWeaponDamage)
	Metadone = Metadone + Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEROIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Heroin")
AddEventHandler("Heroin",function()
	local Effect = Effects.Heroin
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	SetPedMaxHealth(PlayerPedId(),Effect.Health)
	SetEntityMaxHealth(PlayerPedId(),Effect.Health)
	AnimpostfxPlay(Effect.Effect,Effect.EffectDuration,false)

	Heroin = Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Crack")
AddEventHandler("Crack",function()
	local Effect = Effects.Crack
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,Effect.EffectDuration,false)
	TriggerEvent("Hunger",Effect.InitialNeeds)
	TriggerEvent("Thirst",Effect.InitialNeeds)
	Crack = Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- JOINT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Joint")
AddEventHandler("Joint",function()
	local Effect = Effects.Joint
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,0,true)
	Joint = Joint + Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OXYCONTIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Oxycontin")
AddEventHandler("Oxycontin",function()
	local Effect = Effects.Oxycontin
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,0,true)
	Oxycontin = Effect.Duration
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENERGETIC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Energetic")
AddEventHandler("Energetic",function(Time,Multiplier)
	local Effect = Effects.Energetic
	if AnimpostfxIsRunning(Effect.Effect) then
		AnimpostfxStop(Effect.Effect)
	end

	AnimpostfxPlay(Effect.Effect,0,true)
	SetRunSprintMultiplierForPlayer(PlayerId(),Multiplier)
	Energetic = Time
	EnergeticRate = 100 / Time
	LocalPlayer.state.Energetic = 100
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADMETH
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Pid = PlayerId()
		local Ped = PlayerPedId()
		local Health = GetEntityHealth(Ped)

		if Cocaine > 0 and GetGameTimer() >= CocaineTimer then
			Cocaine = Cocaine - 1
			CocaineTimer = GetGameTimer() + 1000

			if Cocaine <= 0 or Health <= 100 then
				if AnimpostfxIsRunning(Effects.Cocaine.Effect) then
					AnimpostfxStop(Effects.Cocaine.Effect)
				end

				Cocaine = 0
			end
		end

		if Methamphetamine > 0 and GetGameTimer() >= MethamphetamineTimer then
			Methamphetamine = Methamphetamine - 1
			MethamphetamineTimer = GetGameTimer() + 1000

			if Methamphetamine <= 0 or Health <= 100 then
				if AnimpostfxIsRunning(Effects.Methamphetamine.Effect) then
					AnimpostfxStop(Effects.Methamphetamine.Effect)
				end

				Methamphetamine = 0
			end
		end

		if Metadone > 0 and GetGameTimer() >= MetadoneTimer then
			Metadone = Metadone - 1
			MetadoneTimer = GetGameTimer() + 1000

			if Metadone <= 0 or GetEntityHealth(Ped) <= 100 then
				if AnimpostfxIsRunning(Effects.Metadone.Effect) then
					AnimpostfxStop(Effects.Metadone.Effect)
				end

				Metadone = 0
				SetAiWeaponDamageModifier(Effects.Metadone.DefaultAiWeaponDamage)
				SetAiMeleeWeaponDamageModifier(Effects.Metadone.DefaultAiMeleeDamage)
				SetPlayerWeaponDamageModifier(Pid,1.0)
				SetPlayerMeleeWeaponDamageModifier(Pid,1.0)
				LocalPlayer["state"]:set("DamageModify",false,false)
			end
		end

		if Heroin > 0 and GetGameTimer() >= HeroinTimer then
			Heroin = Heroin - 1
			HeroinTimer = GetGameTimer() + 1000

			if Heroin <= 0 or Health <= 100 then
				if AnimpostfxIsRunning(Effects.Heroin.Effect) then
					AnimpostfxStop(Effects.Heroin.Effect)
				end

				if GetEntityHealth(Ped) > Effects.Heroin.DefaultHealth then
					SetEntityHealth(Ped,Effects.Heroin.DefaultHealth)
				end

				SetEntityMaxHealth(Ped,Effects.Heroin.DefaultHealth)
				SetPedMaxHealth(Ped,Effects.Heroin.DefaultHealth)
				Heroin = 0
			end
		end

		if Crack > 0 and GetGameTimer() >= CrackTimer then
			Crack = Crack - 1
			CrackTimer = GetGameTimer() + 1000

			if Crack <= 0 or Health <= 100 then
				if AnimpostfxIsRunning(Effects.Crack.Effect) then
					AnimpostfxStop(Effects.Crack.Effect)
				end

				TriggerEvent("Hunger",Effects.Crack.FinalNeeds)
				TriggerEvent("Thirst",Effects.Crack.FinalNeeds)
				Crack = 0
			end
		end

		if Joint > 0 and GetGameTimer() >= JointTimer then
			Joint = Joint - 1
			JointTimer = GetGameTimer() + 1000

			if Joint <= 0 or GetEntityHealth(Ped) <= 100 then
				if AnimpostfxIsRunning(Effects.Joint.Effect) then
					AnimpostfxStop(Effects.Joint.Effect)
				end

				Joint = 0
			end
		end

		if Oxycontin > 0 and GetGameTimer() >= OxycontinTimer then
			Oxycontin = Oxycontin - 1
			OxycontinTimer = GetGameTimer() + 1000

			if Oxycontin <= 0 or Health <= 100 then
				if AnimpostfxIsRunning(Effects.Oxycontin.Effect) then
					AnimpostfxStop(Effects.Oxycontin.Effect)
				end

				Oxycontin = 0
			end
		end

		if Energetic > 0 and GetGameTimer() >= EnergeticTimer then
			Energetic = Energetic - 1
			EnergeticTimer = GetGameTimer() + 1000
			LocalPlayer.state.Energetic = math.max(LocalPlayer.state.Energetic - EnergeticRate,0)

			if Energetic <= 0 or Health <= 100 then
				if AnimpostfxIsRunning(Effects.Energetic.Effect) then
					AnimpostfxStop(Effects.Energetic.Effect)
				end

				SetRunSprintMultiplierForPlayer(Pid,1.0)
				LocalPlayer.state.Energetic = 0
				Energetic = 0
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENERGETIC STAMINA
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Energetic > 0 then
			RestorePlayerStamina(PlayerId(),1.0)
			Wait(0)
		else
			Wait(500)
		end
	end
end)
