-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Block = false
local Opened = false
local Animation = false

CoreInventoryChest = {
	Mount = function() return Framework.Server.ChestMount() end,
	Store = function(...) return Framework.Server.ChestStore(...) end,
	Take = function(...) return Framework.Server.ChestTake(...) end,
	Update = function(...) return Framework.Server.ChestUpdate(...) end,
	CanUpgrade = function() return Framework.Server.ChestCanUpgrade() end,
	QuoteUpgrade = function() return Framework.Server.ChestQuoteUpgrade() end,
	ConfirmUpgrade = function() return Framework.Server.ChestConfirmUpgrade() end
}

local function ChestMountData()
	local Primary,Secondary,PrimaryWeight,SecondaryWeight,PrimarySlots,SecondarySlots = Framework.Server.ChestMount()
	if type(Primary) ~= "table" then return false end

	return {
		Primary = Primary,
		Secondary = type(Secondary) == "table" and Secondary or {},
		PrimaryWeight = PrimaryWeight,
		SecondaryWeight = SecondaryWeight,
		PrimarySlots = PrimarySlots,
		SecondarySlots = SecondarySlots
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTS
-----------------------------------------------------------------------------------------------------------------------------------------
local Chests = Inventory.Chest.Locations
-----------------------------------------------------------------------------------------------------------------------------------------
-- LABELS
-----------------------------------------------------------------------------------------------------------------------------------------
local Labels = Inventory.Chest.Modes
local Target = Inventory.Chest.Target
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTOPTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function ChestOptions(Mode,Shop,ZoneName,Distance)
	local List = {}
	for Number,Opt in ipairs(Labels[Mode] or {}) do
		local Event = Opt.event
		local Tun = Opt.tunnel
		local Service = Opt.service
		List[#List + 1] = {
			name = ZoneName..":"..Number,
			label = Opt.label,
			icon = "fa-solid fa-box-open",
			distance = Distance,
			onSelect = function()
				if Tun == "server" then
					TriggerServerEvent(Event,Shop,Service)
				elseif Tun == "client" then
					TriggerEvent(Event,Shop,Service)
				elseif Tun == "products" then
					TriggerEvent(Event,Service)
				end
			end
		}
	end

	return List
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
local StaticZones = {}

CreateThread(function()
	if not Inventory.General.Features.Chests then return end
	while GetResourceState("sleepless_interact") ~= "started" do Wait(500) end
	for Name,v in pairs(Chests) do
		local id = Framework.AddChestZone(v.Coords,ChestOptions(v.Mode,v.Name,"Chest:"..Name,v.Distance or Target.Distance))
		StaticZones[#StaticZones + 1] = id
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DYNAMIC CHESTS (core-admin)
-----------------------------------------------------------------------------------------------------------------------------------------
local DynamicZones = {}

local function AddDynamicChest(chest)
	if not Inventory.General.Features.Chests then return end
	if not chest or not chest.name or not chest.coords then return end
	if GetResourceState("sleepless_interact") ~= "started" then return end
	local mode = tostring(chest.mode or "2")
	if not Labels[mode] then mode = "2" end

	local zoneName = "ChestDyn:"..chest.name
	local coords = vec3(chest.coords.x + 0.0, chest.coords.y + 0.0, chest.coords.z + 0.0)
	local distance = tonumber(chest.distance) or Target.Distance
	if distance < Target.MinimumDistance then distance = Target.MinimumDistance end
	if distance > Target.MaximumDistance then distance = Target.MaximumDistance end

	local id = Framework.AddChestZone(coords,ChestOptions(mode,chest.name,zoneName,distance))
	DynamicZones[zoneName] = id
end

local function ClearDynamicChests()
	for _,id in pairs(DynamicZones) do
		Framework.RemoveChestZone(id)
	end
	DynamicZones = {}
end

local function ApplyChestList(list)
	ClearDynamicChests()
	if type(list) ~= "table" then return end
	for _,chest in pairs(list) do
		AddDynamicChest(chest)
	end
end

-- StateBag global replica automaticamente p/ late-join e mudanças em runtime
AddStateBagChangeHandler("coreAdminChests","global",function(_,_,value)
	ApplyChestList(value)
end)

-- Carga inicial: o statebag pode já estar setado quando o resource sobe
CreateThread(function()
	while GetResourceState("sleepless_interact") ~= "started" do Wait(500) end
	local current = GlobalState.coreAdminChests
	if current then
		ApplyChestList(current)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chest:Open")
AddEventHandler("chest:Open",function(Name,Mode,Item,Blocked,Force)
	if Framework.Server.ChestPermissions(Name,Mode,Item) and GetEntityHealth(PlayerPedId()) > 100 then
		if Blocked or Framework.SplitBoolean(Name,"Helicrash",":") or Framework.SplitBoolean(Name,"Halloween",":") then
			Block = true
		end

		Opened = Name

		if Mode ~= "Item" then
			Animation = true
			Framework.playAnim(false,{"amb@prop_human_bum_bin@base","base"},true)
		end

		local MountData = ChestMountData()
		if not MountData then return end

		TriggerEvent("inventory:Open",{
			Type = "Chest",
			Resource = "chest",
			MountData = MountData,
			Force = Force,
			ReadOnly = Block,
			Right = "Baú"
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:ITEM
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("chest:Item",function(Name)
	local FullName = Framework.splitString(Name)
	if Framework.Server.ChestPermissions(FullName[1]..":"..FullName[3],"Item") and GetEntityHealth(PlayerPedId()) > 100 then
		Opened = true
		local MountData = ChestMountData()
		if not MountData then return end
		TriggerEvent("inventory:Open",{
			Type = "Chest",
			Resource = "chest",
			MountData = MountData,
			Right = "Baú"
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:RECYCLE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("chest:Recycle",function()
	if Framework.Server.ChestPermissions("Recycle","Tray") and GetEntityHealth(PlayerPedId()) > 100 then
		Opened = true
		local MountData = ChestMountData()
		if not MountData then return end
		TriggerEvent("inventory:Open",{
			Type = "Chest",
			Resource = "chest",
			MountData = MountData,
			Right = "Baú"
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Close")
AddEventHandler("inventory:Close",function(Force)
	if (not Force and Opened) or (Force and Opened and Opened == Force) then
		if Animation then
			Animation = false
			Framework.Destroy()
		end

		Opened = false
		Block = false
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLOSED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:Closed",function(Name)
	if Opened and Opened == Name then
		if Animation then
			Animation = false
			Framework.Destroy()
		end

		Block = false
		Opened = false
		TriggerEvent("inventory:Close")
	end
end)
