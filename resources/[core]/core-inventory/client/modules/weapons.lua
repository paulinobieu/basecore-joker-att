-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Weapon = ""
WeaponHash = ""
Ammos = false
local Skins = {}
local Objects = {}
TakeWeapon = false
StoreWeapon = false
local Reload = GetGameTimer()
local Cooldown = GetGameTimer()
-----------------------------------------------------------------------------------------------------------------------------------------
-- NATIVEWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
local function NativeWeapon(Item)
	return Framework.WeaponBase(Item) or Item
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:SKINS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Skins")
AddEventHandler("inventory:Skins",function(Table)
	Skins = Table
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Config = Inventory.Weapons.Carry
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REMOVEWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RemoveWeapon")
AddEventHandler("inventory:RemoveWeapon",function(Name)
	local Name = NativeWeapon(Framework.SplitOne(Name))

	if Objects[Name] then
		TriggerServerEvent("DeleteObject",0,Name)
		Objects[Name] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CREATEWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:CreateWeapon")
AddEventHandler("inventory:CreateWeapon",function(Name)
	if Framework.WeaponBack == false then
		return false
	end

	local WeaponName = NativeWeapon(Framework.SplitOne(Name))
	if not Config[WeaponName] or Objects[WeaponName] then
		return false
	end

	local WeaponModel = nil
	local Ped = PlayerPedId()
	local Data = Config[WeaponName]
	local Coords = GetEntityCoords(Ped)
	local Bone = GetPedBoneIndex(Ped,Data.Bone)

	if Skins[WeaponName] then
		local Hash = GetHashKey(Skins[WeaponName])
		WeaponModel = GetWeaponComponentTypeModel(Hash)
	end

	local Networked = Framework.VRPServer.CreateObject(Data.Model,Coords.x,Coords.y,Coords.z,WeaponName,WeaponModel)
	if not Networked then
		return false
	end

	Objects[WeaponName] = LoadNetwork(Networked)
	while not DoesEntityExist(Objects[WeaponName]) do
		Wait(100)
	end

	SetEntityCollision(Objects[WeaponName],false,false)
	SetEntityCompletelyDisableCollision(Objects[WeaponName],false,true)
	AttachEntityToEntity(Objects[WeaponName],Ped,Bone,Data.x,Data.y,Data.z,Data.RotX,Data.RotY,Data.RotZ,true,true,false,false,2,true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSTOREWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Framework.LoadAnim("rcmjosh4")
	Framework.LoadAnim("weapons@pistol@")

	while true do
		local TimeDistance = 999
		if Weapon ~= "" and Actived then
			TimeDistance = 1

			local Ped = PlayerPedId()
			local CurrentTimer = GetGameTimer()
			local Ammo = GetAmmoInPedWeapon(Ped,WeaponHash)

			if IsPedReloading(Ped) and CurrentTimer >= Reload then
				Framework.Server.PreventWeapons(Weapon,Ammo)
				Reload = CurrentTimer + 1000
			end

			if (Ammo <= 0 or (Weapon == "WEAPON_PETROLCAN" and Ammo <= 50 and IsPedShooting(Ped))) and CurrentTimer >= Cooldown then
				Cooldown = CurrentTimer + 1000
				TriggerEvent("inventory:CleanWeapons")

				if Types ~= "" then
					Framework.Server.RemoveThrowing(Types)
				else
					Framework.Server.PreventWeapons(Weapon,Ammo)
				end
			end

			if IsPedInAnyVehicle(Ped) then
				local Allowed = false
				local Pid = PlayerId()

				if IsPedInAnyHeli(Ped) then
					Allowed = (Ammos == "WEAPON_RIFLE_AMMO" or Ammos == "WEAPON_POLICE_AMMO")
				else
					Allowed = (Ammos == "WEAPON_PISTOL_AMMO" or Ammos == "WEAPON_POLICE_AMMO" or Weapon == "WEAPON_ACIDPACKAGE")
				end

				SetPlayerCanDoDriveBy(Pid,Allowed)
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:VERIFYWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:verifyWeapon")
AddEventHandler("inventory:verifyWeapon",function(Item)
	local Name = Framework.SplitOne(Item)

	if Weapon ~= "" then
		local Ped = PlayerPedId()
		local BaseWeapon = Framework.ResolveBaseWeapon(Weapon)
		local AmmoItem = Framework.WeaponAmmo(Item)
		local AmmoHand = Framework.WeaponAmmo(BaseWeapon)

		local UsingWeapong = (Weapon == Name) or (BaseWeapon == Name)
		local Ammo = GetAmmoInPedWeapon(Ped,UsingWeapong and WeaponHash or NativeWeapon(Name))

		if UsingWeapong then
			if not Framework.Server.VerifyWeapon(Weapon,Ammo) then
				return TriggerEvent("inventory:CleanWeapons")
			end
		elseif AmmoItem and AmmoHand and AmmoItem == AmmoHand then
			return TriggerEvent("inventory:RemoveWeapon",Item)
		elseif not Framework.Server.VerifyWeapon(Name,Ammo) then
			return TriggerEvent("inventory:CleanWeapons")
		end
	else
		Framework.Server.VerifyWeapon(Name)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLEANWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:CleanWeapons",function(Ignore)
	if Weapon == "" then
		return false
	end

	local Ped = PlayerPedId()
	local Parachute = HasPedGotWeapon(Ped,-72657034,false)

	if not Ignore then
		local Ammo = GetAmmoInPedWeapon(Ped,WeaponHash)
		if Framework.Server.PreventWeapons(Weapon,Ammo) then
			TriggerEvent("inventory:CreateWeapon",Weapon)
		end
	end

	TriggerEvent("Weapon","")
	RemoveAllPedWeapons(Ped,true)
	TriggerEvent("hud:Weapon",false)

	if Parachute then
		GiveWeaponToPed(Ped,"GADGET_PARACHUTE",1,false,true)
	end

	Actived = false
	Ammos = false
	Weapon = ""
	WeaponHash = ""
	Types = ""
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ReturnWeapon()
	return Weapon ~= "" and Weapon or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckWeapon(Hash)
	return Weapon == Hash and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVECOMPONENT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.GiveComponent(Component)
	GiveWeaponComponentToPed(PlayerPedId(),WeaponHash,Component)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKEWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.TakeWeapon(Name,Ammo,Components,Type,Skin,Display)
	if TakeWeapon then
		return false
	end

	Ammo = Ammo or 0
	if Ammo > 0 then
		Actived = true
	end

	TakeWeapon = true
	LocalPlayer.state:set("Cancel",true,true)

	local Ped = PlayerPedId()
	local function EquipWeapon()
		Weapon = Name
		WeaponHash = Display or NativeWeapon(Name)
		Ammos = Framework.WeaponAmmo(Framework.ResolveBaseWeapon(Weapon))
		TriggerEvent("Weapon",Weapon)
		TriggerEvent("inventory:RemoveWeapon",Weapon)
		GiveWeaponToPed(Ped,WeaponHash,Ammo,false,true)

		if Skin then
			GiveWeaponComponentToPed(Ped,WeaponHash,Skin)
		end

		if Components then
			for Item in pairs(Components) do
				local Component = Framework.WeaponAttach(Framework.SplitOne(Item),Weapon)
				GiveWeaponComponentToPed(Ped,WeaponHash,Component)
			end
		end

		TriggerServerEvent("core-skins:TryApplyComponent",NativeWeapon(Name))
	end

	if not IsPedInAnyVehicle(Ped) then
		TaskPlayAnim(Ped,"rcmjosh4","josh_leadout_cop2",8.0,8.0,-1,48,1,0,0,0)
		Wait(200)
		EquipWeapon()
		Wait(300)
		ClearPedTasks(Ped)

		SetTimeout(2500,function()
			if Weapon ~= "" and GetSelectedPedWeapon(Ped) ~= GetHashKey(WeaponHash) then
				TriggerEvent("inventory:CleanWeapons")
			end
		end)
	else
		EquipWeapon()
	end

	if Type then
		Types = Type
	end

	TakeWeapon = false
	LocalPlayer.state:set("Cancel",false,true)

	if Framework.WeaponAmmo(Framework.ResolveBaseWeapon(Weapon)) then
		TriggerEvent("hud:Weapon",true,WeaponHash)
	end

	if (IsPedInAnyVehicle(Ped) and not Framework.ItemVehicle(Weapon)) or Framework.Server.CheckExistWeapons(Weapon) then
		TriggerEvent("inventory:CleanWeapons")
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOREWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.StoreWeapon()
	if StoreWeapon or Weapon == "" then
		return false
	end

	StoreWeapon = true

	local Lasted = Weapon
	local Ped = PlayerPedId()
	local Ammo = GetAmmoInPedWeapon(Ped,WeaponHash)

	LocalPlayer.state:set("Cancel",true,true)

	if not IsPedInAnyVehicle(Ped) then
		TaskPlayAnim(Ped,"weapons@pistol@","aim_2_holster",8.0,8.0,-1,48,1,0,0,0)
		Wait(450)
		ClearPedTasks(Ped)
	end

	TriggerEvent("inventory:CleanWeapons")
	LocalPlayer.state:set("Cancel",false,true)

	StoreWeapon = false
	return true,Ammo,Lasted
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INFOWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.InfoWeapon(Type)
	local Ammo = 0

	if Weapon ~= "" then
		Ammo = GetAmmoInPedWeapon(PlayerPedId(),WeaponHash)
	end

	return Weapon,Ammo
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RELOADING
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Reloading(Hash,Ammo)
	AddAmmoToPed(PlayerPedId(),WeaponHash,Ammo)
	Actived = true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCWEAPONAMMO
-- Recarga feita pela interface. So mexe no ped quando o armamento recarregado e
-- justamente o que esta na mao; do contrario a municao ja ficou no meta do item.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.SyncWeaponAmmo(Ammo)
	if Weapon == "" or WeaponHash == "" then
		return false
	end

	SetPedAmmo(PlayerPedId(),WeaponHash,Framework.parseInt(Ammo))
	Actived = true

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCWEAPONATTACH
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.SyncWeaponAttach(Component,Install)
	if Weapon == "" or WeaponHash == "" then
		return false
	end

	local Ped = PlayerPedId()

	if Install then
		GiveWeaponComponentToPed(Ped,WeaponHash,Component)
	else
		RemoveWeaponComponentFromPed(Ped,WeaponHash,Component)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARACHUTE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Parachute()
	GiveWeaponToPed(PlayerPedId(),"GADGET_PARACHUTE",1,false,true)
end
