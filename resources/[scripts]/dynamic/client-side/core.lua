-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("dynamic")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Dynamic = false
local Staging = {}
local Registry = {}
local IdCounter = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function NextId()
	IdCounter = IdCounter + 1
	return "dyn:"..IdCounter
end

local function ResetState()
	Staging = {}
	Registry = {}
end

local function ResolveColor()
	if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
		return Theme.main
	end

	return "#dc1553"
end

local function HasParent(ParentId)
	return ParentId ~= nil and ParentId ~= false and ParentId ~= ""
end

local function BuildTree()
	local nodes = {}
	local roots = {}

	for _,Item in ipairs(Staging) do
		local Node = {
			id = Item.Id,
			title = Item.Title,
			icon = Item.Icon or (Item.Kind == "menu" and "fas fa-folder" or "fas fa-circle")
		}

		if Item.Image then
			Node.image = Item.Image
		end

		if Item.Kind == "menu" then
			Node.items = {}
			nodes[Item.MenuKey] = Node
		else
			if Item.Trigger and Item.Trigger ~= "" then
				Registry[Item.Id] = {
					Trigger = Item.Trigger,
					Param = Item.Param,
					Server = Item.Server == true
				}
			end
		end

		if HasParent(Item.ParentId) and nodes[Item.ParentId] then
			local Parent = nodes[Item.ParentId]
			Parent.items[#Parent.items + 1] = Node
		else
			roots[#roots + 1] = Node
		end
	end

	return roots
end

local function PushTree()
	SendNUIMessage({ action = "setMenuItems", payload = BuildTree() })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STAGING
-----------------------------------------------------------------------------------------------------------------------------------------
local function StageMenu(Title,Description,Id,ParentId,Icon)
	Staging[#Staging + 1] = {
		Kind = "menu",
		Id = NextId(),
		MenuKey = Id,
		Title = Title,
		ParentId = ParentId,
		Icon = Icon
	}
end

local function StageButton(Title,Description,Trigger,Param,ParentId,Server,Back,Icon,Image)
	Staging[#Staging + 1] = {
		Kind = "button",
		Id = NextId(),
		Title = Title,
		Trigger = Trigger,
		Param = Param,
		ParentId = ParentId,
		Server = Server,
		Icon = Icon,
		Image = Image
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDMENU / ADDBUTTON
-----------------------------------------------------------------------------------------------------------------------------------------
exports("AddMenu",StageMenu)
exports("AddButton",StageButton)

RegisterNetEvent("dynamic:AddMenu")
AddEventHandler("dynamic:AddMenu",function(Title,Description,Id,ParentId,Icon)
	StageMenu(Title,Description,Id,ParentId,Icon)

	if Dynamic then
		PushTree()
	end
end)

RegisterNetEvent("dynamic:AddButton")
AddEventHandler("dynamic:AddButton",function(Title,Description,Trigger,Param,ParentId,Server,Back,Icon,Image)
	StageButton(Title,Description,Trigger,Param,ParentId,Server,Back,Icon,Image)

	if Dynamic then
		PushTree()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN / CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function OpenUI()
	PushTree()
	SendNUIMessage({ action = "setVisible", payload = true })
	SetNuiFocus(true,true)
	Dynamic = true
end

local function CloseUI()
	if Dynamic then
		SendNUIMessage({ action = "setVisible", payload = false })
		SetNuiFocus(false,false)
		Dynamic = false
		ResetState()
	end
end

exports("Open",OpenUI)
exports("Close",CloseUI)

RegisterNetEvent("dynamic:Close")
AddEventHandler("dynamic:Close",CloseUI)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:closeUi",function(_,cb)
	CloseUI()
	cb(1)
end)

RegisterNUICallback("get:colors",function(_,cb)
	local Color = ResolveColor()
	cb({
		primaryColor = Color,
		secondaryColor = Color,
		thirdyColor = Color
	})
end)

RegisterNUICallback("triggerAction",function(Data,cb)
	local Entry = Data and Data.id and Registry[Data.id]
	if not Entry then
		cb(false)

		return
	end

	CloseUI()

	if Entry.Server then
		TriggerServerEvent(Entry.Trigger,Entry.Param)
	else
		TriggerEvent(Entry.Trigger,Entry.Param)
	end

	cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERFUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("PlayerFunctions",function()
	local Ped = PlayerPedId()
	if not Dynamic and not IsPauseMenuActive() and not LocalPlayer.state.Banned and not LocalPlayer.state.Commands and not LocalPlayer.state.Handcuff and not LocalPlayer.state.Prison and GetEntityHealth(Ped) > 100 then
		ResetState()

		StageButton("Armário","Abrir lista com todas as vestimentas.","core-wardrobe:open","",false,false,false,"fas fa-shirt")

		StageMenu("Roupas","Colocar/Retirar roupas.","clothes",false,"fas fa-vest")
		StageButton("Chapéu","Colocar/Retirar o chapéu.","core-customization:togglePart","hat","clothes",false,false,"fas fa-hat-cowboy")
		StageButton("Máscara","Colocar/Retirar a máscara.","core-customization:togglePart","mask","clothes",false,false,"fas fa-mask")
		StageButton("Óculos","Colocar/Retirar o óculos.","core-customization:togglePart","glass","clothes",false,false,"fas fa-glasses")
		StageButton("Camisa","Colocar/Retirar a camisa.","core-customization:togglePart","tshirt","clothes",false,false,"fas fa-shirt")
		StageButton("Jaqueta","Colocar/Retirar a jaqueta.","core-customization:togglePart","torso","clothes",false,false,"fas fa-vest")
		StageButton("Luvas","Colocar/Retirar as luvas.","core-customization:togglePart","arms","clothes",false,false,"fas fa-mitten")
		StageButton("Colete","Colocar/Retirar o colete.","core-customization:togglePart","vest","clothes",false,false,"fas fa-shield-halved")
		StageButton("Calça","Colocar/Retirar a calça.","core-customization:togglePart","pants","clothes",false,false,"fas fa-person-walking")
		StageButton("Sapatos","Colocar/Retirar o sapato.","core-customization:togglePart","shoes","clothes",false,false,"fas fa-shoe-prints")

		if vRP.ClosestVehicle(7) then
			if not IsPedInAnyVehicle(Ped) then
				local Vehicle = GetLastDrivenVehicle()
				if Vehicle and IsThisModelABoat(GetEntityModel(Vehicle)) then
					StageButton("Ancorar","Prender/Desprender a embarcação.","player:Anchor",Vehicle,false,false,false,"fas fa-anchor")
				end

				if vRP.ClosestPed(3) then
					StageMenu("Jogador","Pessoa mais próxima de você.","closestpeds",false,"fas fa-user")
					StageButton("Colocar no Veículo","Colocar no veículo mais próximo.","player:cvFunctions","cv","closestpeds",true,false,"fas fa-car-side")
					StageButton("Remover do Veículo","Remover do veículo mais próximo.","player:cvFunctions","rv","closestpeds",true,false,"fas fa-car-side")
				end
			else
				StageMenu("Veículo","Funções do veículo.","vehicle",false,"fas fa-car")
				StageButton("Sentar no Motorista","Sentar no banco do motorista.","player:seatPlayer","0","vehicle",false,false,"fas fa-chair")
				StageButton("Sentar no Passageiro","Sentar no banco do passageiro.","player:seatPlayer","1","vehicle",false,false,"fas fa-chair")
				StageButton("Sentar em Outros","Sentar no banco do passageiro.","player:seatPlayer","2","vehicle",false,false,"fas fa-chair")
				StageButton("Mexer nos Vidros","Levantar/Abaixar os vidros.","player:Windows","","vehicle",false,false,"fas fa-window-maximize")
			end

			StageMenu("Portas","Portas do veículo.","doors",false,"fas fa-door-open")
			StageButton("Porta do Motorista","Abrir porta do motorista.","player:Doors","1","doors",true,false,"fas fa-door-open")
			StageButton("Porta do Passageiro","Abrir porta do passageiro.","player:Doors","2","doors",true,false,"fas fa-door-open")
			StageButton("Porta Traseira Esquerda","Abrir porta traseira esquerda.","player:Doors","3","doors",true,false,"fas fa-door-open")
			StageButton("Porta Traseira Direita","Abrir porta traseira direita.","player:Doors","4","doors",true,false,"fas fa-door-open")
			StageButton("Porta-Malas","Abrir porta-malas.","player:Doors","5","doors",true,false,"fas fa-door-closed")
			StageButton("Capô","Abrir capô.","player:Doors","6","doors",true,false,"fas fa-car-burst")
		end

		StageMenu("Outros","Todas as funções do personagem.","others",false,"fas fa-ellipsis")
		StageButton("Propriedades","Marcar/Desmarcar propriedades no mapa.","propertys:Blips","","others",false,false,"fas fa-house")
		StageButton("Ferimentos","Verificar ferimentos no corpo.","paramedic:Injuries","","others",false,false,"fas fa-heart-pulse")
		StageButton("Desbugar","Recarregar o personagem.","player:Debug","","others",true,false,"fas fa-rotate")

		TriggerEvent("animals:Dynamic")

		OpenUI()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMERGENCYFUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("EmergencyFunctions",function()
	if not Dynamic and not IsPauseMenuActive() and not LocalPlayer.state.Banned and not LocalPlayer.state.Commands and not LocalPlayer.state.Handcuff and not LocalPlayer.state.Prison then
		local Ped = PlayerPedId()
		local Health = GetEntityHealth(Ped)

		if CheckPolice() then
			ResetState()

			if GetResourceState("perimeter") == "started" then
				TriggerEvent("perimeter:Dynamic")
			end

			StageButton("Placa","Verificar emplacamento.","prison:Plate",false,false,true,false,"fas fa-id-card")

			StageMenu("Emergência","Avisos emergenciais.","tencode",false,"fas fa-triangle-exclamation")
			StageButton("10-13","Oficial desmaiado/ferido.","dynamic:Tencode","13","tencode",true,false,"fas fa-user-injured")
			StageButton("10-20","Localização.","dynamic:Tencode","20","tencode",true,false,"fas fa-location-dot")
			StageButton("10-38","Abordagem de trânsito.","dynamic:Tencode","38","tencode",true,false,"fas fa-traffic-light")
			StageButton("10-78","Apoio com prioridade.","dynamic:Tencode","78","tencode",true,false,"fas fa-bullhorn")

			if Health > 100 and not IsPedInAnyVehicle(Ped) then
				StageMenu("Jogador","Pessoa mais próxima de você.","player",false,"fas fa-user")
				StageButton("Colocar no Veículo","Colocar no veículo mais próximo.","player:cvFunctions","cv","player",true,false,"fas fa-car-side")
				StageButton("Remover do Veículo","Remover do veículo mais próximo.","player:cvFunctions","rv","player",true,false,"fas fa-car-side")
				StageButton("Remover Chapéu","Remover da pessoa mais próxima.","core-customization:removeProps","hat","player",true,false,"fas fa-hat-cowboy")
				StageButton("Remover Máscara","Remover da pessoa mais próxima.","core-customization:removeProps","mask","player",true,false,"fas fa-mask")
				StageButton("Remover Óculos","Remover da pessoa mais próxima.","core-customization:removeProps","glass","player",true,false,"fas fa-glasses")

				StageMenu("Fardamentos","Todos os fardamentos policiais.","prePolice",false,"fas fa-shield")
				StageButton("Principal","Fardamento de oficial.","player:Preset","1","prePolice",true,false,"fas fa-user-shield")
			end

			OpenUI()
		elseif CheckMedical() and Health > 100 and not IsPedInAnyVehicle(Ped) then
			ResetState()

			StageMenu("Jogador","Pessoa mais próxima de você.","player",false,"fas fa-user")
			StageButton("Colocar no Veículo","Colocar no veículo mais próximo.","player:cvFunctions","cv","player",true,false,"fas fa-car-side")
			StageButton("Remover do Veículo","Remover do veículo mais próximo.","player:cvFunctions","rv","player",true,false,"fas fa-car-side")
			StageButton("Remover Chapéu","Remover da pessoa mais próxima.","core-customization:removeProps","hat","player",true,false,"fas fa-hat-cowboy")
			StageButton("Remover Máscara","Remover da pessoa mais próxima.","core-customization:removeProps","mask","player",true,false,"fas fa-mask")
			StageButton("Remover Óculos","Remover da pessoa mais próxima.","core-customization:removeProps","glass","player",true,false,"fas fa-glasses")

			StageMenu("Fardamentos","Todos os fardamentos médicos.","preMedic",false,"fas fa-staff-snake")
			StageButton("Principal","Fardamento de oficial.","player:Preset","2","preMedic",true,false,"fas fa-user-doctor")

			OpenUI()
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("PlayerFunctions","Abrir menu principal.","keyboard","F9")
RegisterKeyMapping("EmergencyFunctions","Abrir menu de emergencial.","keyboard","F10")
-----------------------------------------------------------------------------------------------------------------------------------------
-- GRABPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("GrabPlayer",function()
	if IsPauseMenuActive() or LocalPlayer.state.Banned or LocalPlayer.state.Commands or LocalPlayer.state.Handcuff or LocalPlayer.state.Prison then
		return
	end

	if not CheckPolice() and not CheckMedical() then
		return
	end

	local Ped = PlayerPedId()
	if not LocalPlayer.state.Carry and (GetEntityHealth(Ped) <= 100 or IsPedInAnyVehicle(Ped)) then
		return
	end

	TriggerServerEvent("inventory:Carry")
end)
RegisterKeyMapping("GrabPlayer","Agarrar a pessoa mais próxima.","keyboard","H")
