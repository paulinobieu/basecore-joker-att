-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
vCHAT = Tunnel.getInterface("chat")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Block = {
	"zap","macaco","preto","arrombado","viadinho","urugutango","gorila","gorilla",
	"mongoloide","bixa","bicha","traveco","veveco","boiola","pau","buceta","gay",
	"piranha","monkey","vagabunda","puta","escroto","pretinho","escurinho","negrinho",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSTART
-----------------------------------------------------------------------------------------------------------------------------------------
for Permission, v in pairs(Groups) do
	if v.Chat then
		Active[Permission] = true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT OPEN (T key)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("ChatEvent", function()
	local Ped   = PlayerPedId()
	local Local = LocalPlayer.state
	if not Local.Active or IsPauseMenuActive() or Local.Handcuff or Local.Carry or IsPedReloading(Ped) then
		return
	end

	local Police = false
	local Tags   = { "OOC" }
	for Permission in pairs(Active) do
		if Local[Permission] then
			Tags[#Tags + 1] = Permission
			if not Police and (Permission == "Militar" or Permission == "Civil" or Permission == "CORE" or Permission == "BOPE" or Permission == "PRF") then
				Tags[#Tags + 1] = "Policia"
				Police = true
			end
		end
	end

	SendNUIMessage({ action = "chat:inputfocus", payload = { open = true, categories = Tags } })
	SetNuiFocus(true, true)
end)
RegisterKeyMapping("ChatEvent", "Abrir o chat.", "keyboard", "T")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:CLIENTMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
local function hexToRGBA(hex, alpha)
	hex = (hex or "#ffffff"):gsub("#", "")
	local r = tonumber(hex:sub(1,2), 16) or 255
	local g = tonumber(hex:sub(3,4), 16) or 255
	local b = tonumber(hex:sub(5,6), 16) or 255
	return string.format("rgba(%d, %d, %d, %.2f)", r, g, b, alpha or 0.2)
end

RegisterNetEvent("chat:ClientMessage")
AddEventHandler("chat:ClientMessage", function(Author, Message, Mode, Html, Highlight)
	local group   = Groups and Groups[Mode]
	local payload = { context = Mode }

	if group and group.Chat and group.ChatIcon then
		local rgba = hexToRGBA(group.ChatBackground, 0.2)
		payload.typeIcon = {
			src       = group.ChatIcon,
			className = "text-xs mr-2.5",
			style     = { color = group.ChatBackground },
		}
		payload.author  = Author
		payload.content = Message
		payload.containerStyles = {
			backgroundBlendMode = "screen",
			border     = ".025rem solid #FFFFFF0A",
			background = "linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(90.59deg, " .. rgba .. " -7.28%, rgba(0,0,0,0) 51.21%)",
		}
	elseif Mode == "OOC" then
		payload.inlineMessage = true
		payload.typeIcon = {
			src       = "fa-regular fa-globe",
			className = "text-xs text-[#FFFFFF59] mr-2.5",
		}
		payload.author  = Author
		payload.content = Message
	else
		payload.author  = Author
		payload.content = Message
	end

	SendNUIMessage({ action = "chat:message", payload = payload })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI: GETCHATCATEGORIES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getChatCategories", function(_, cb)
	cb({})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI: SETCHATFOCUS (close)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("setChatFocus", function(_, cb)
	SetNuiFocus(false, false)
	cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI: SENDCHATMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("sendChatMessage", function(data, cb)
	local message = data.message or ""
	local context = data.context or ""
	if message ~= "" then
		if message:sub(1, 1) == "/" then
			ExecuteCommand(message:sub(2))
		else
			TriggerServerEvent("chat:ServerMessage", context, message)
		end
	end
	cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:ME_NEW
-----------------------------------------------------------------------------------------------------------------------------------------
local Me       = {}
local MeActive = {}

RegisterNetEvent("chat:me_new")
AddEventHandler("chat:me_new", function(source, Name, Message, Seconds)
	local Index = GetPlayerFromServerId(source)
	if Index ~= -1 then
		local Ped = GetPlayerPed(Index)
		Me[Ped] = { Message = Message, Name = Name, Timer = Seconds }
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:ME_REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chat:me_remove")
AddEventHandler("chat:me_remove", function(source)
	local Index = GetPlayerFromServerId(source)
	if Index ~= -1 then
		local Ped = GetPlayerPed(Index)
		if MeActive[Ped] then
			SendNUIMessage({ action = "chat:me:remove", payload = Ped })
			MeActive[Ped] = nil
			Me[Ped] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ME THREAD (world-space floating text)
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped    = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		for Index, v in pairs(Me) do
			local OtherCoords = GetEntityCoords(Index)
			if #(Coords - OtherCoords) <= 5 then
				TimeDistance = 1
				local _, x, y = GetScreenCoordFromWorldCoord(OtherCoords.x, OtherCoords.y, OtherCoords.z + 0.7)

				if not MeActive[Index] then
					SendNUIMessage({ action = "chat:me:show", payload = { id = Index, author = v.Name, message = v.Message, x = x, y = y } })
					MeActive[Index] = true
				end

				SendNUIMessage({ action = "chat:me:update", payload = { id = Index, message = v.Message, x = x, y = y } })
			elseif MeActive[Index] then
				SendNUIMessage({ action = "chat:me:remove", payload = Index })
				MeActive[Index] = nil
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ME TIMER THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		for Index, v in pairs(Me) do
			if v.Timer > 0 then
				v.Timer = v.Timer - 1
			else
				if MeActive[Index] then
					SendNUIMessage({ action = "chat:me:remove", payload = Index })
					MeActive[Index] = nil
				end
				Me[Index] = nil
			end
		end
		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POSTIT VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Posts   = {}
local Display = {}
local PostitPlacing = false

local function GetCoordsFromCam(Distance, Coords)
	local RadConv  = math.pi / 180
	local Rotation = GetGameplayCamRot()
	local Adjusted = vec3(Rotation.x * RadConv, Rotation.y * RadConv, Rotation.z * RadConv)
	local Direction = vec3(
		-math.sin(Adjusted.z) * math.abs(math.cos(Adjusted.x)),
		 math.cos(Adjusted.z) * math.abs(math.cos(Adjusted.x)),
		 math.sin(Adjusted.x)
	)
	return Coords + Direction * Distance
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:POSTIT_NEW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chat:postit_new")
AddEventHandler("chat:postit_new", function(Admin)
	if PostitPlacing then return end
	PostitPlacing = true

	CreateThread(function()
		while PostitPlacing do
			local Ped    = PlayerPedId()
			local Camera = GetGameplayCamCoord()
			local Handler = StartExpensiveSynchronousShapeTestLosProbe(Camera, GetCoordsFromCam(25.0, Camera), -1, Ped, 4)
			local _, _, Coords = GetShapeTestResult(Handler)

			DrawMarker(28, Coords.x, Coords.y, Coords.z, 0, 0, 0, 0, 0, 0, 0.05, 0.05, 0.05, 88, 101, 242, 175, false, false, false, false)

			if IsControlJustPressed(1, 38) then
				if Admin then
					exports["keyboard"]:Copy("Cordenadas", string.format("%.2f,%.2f,%.2f", Coords.x, Coords.y, Coords.z))
				else
					vCHAT.Add(Coords)
				end
				PostitPlacing = false
			end

			Wait(0)
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:POSTIT_REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chat:postit_remove")
AddEventHandler("chat:postit_remove", function(Route, Number)
	if Posts[Route] and Posts[Route][Number] then
		Posts[Route][Number] = nil
		if not next(Posts[Route]) then Posts[Route] = nil end
	end

	if Display[Route] and Display[Route][Number] then
		SendNUIMessage({ action = "chat:me:remove", payload = Number })
		Display[Route][Number] = nil
		if not next(Display[Route]) then Display[Route] = nil end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:POSTIT_ADD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chat:postit_add")
AddEventHandler("chat:postit_add", function(Route, Number, Content)
	Posts[Route] = Posts[Route] or {}
	Posts[Route][Number] = Content
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POSTIT PROXIMITY THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		if LocalPlayer.state.Active and Posts[LocalPlayer.state.Route] then
			local Ped    = PlayerPedId()
			local Coords = GetEntityCoords(Ped)
			local Route  = LocalPlayer.state.Route

			for Number, v in pairs(Posts[Route]) do
				local Distance = #(Coords - v.Coords)
				if Distance <= v.Distance then
					TimeDistance = 1
					local _, x, y = GetScreenCoordFromWorldCoord(v.Coords.x, v.Coords.y, v.Coords.z)
					Display[Route] = Display[Route] or {}
					if not Display[Route][Number] then
						SendNUIMessage({ action = "chat:me:show", payload = {
							id      = Number,
							author  = v.Author,
							message = v.Message,
							x = x, y = y,
							postit  = true,
						}})
						Display[Route][Number] = true
					else
						SendNUIMessage({ action = "chat:me:update", payload = {
							id = Number, message = v.Message, x = x, y = y,
						}})
					end

					if IsControlJustPressed(1, 47) and Distance <= 2 then
						vCHAT.Delete(Route, Number)
					end
				elseif Display[Route] and Display[Route][Number] then
					SendNUIMessage({ action = "chat:me:remove", payload = Number })
					Display[Route][Number] = nil
				end
			end
		end
		Wait(TimeDistance)
	end
end)
