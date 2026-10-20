-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("core-calls")
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATA
-----------------------------------------------------------------------------------------------------------------------------------------
local Surface = {
	None     = "none",
	Prompt   = "prompt",
	Panel    = "panel",
	Feedback = "feedback",
	Staff    = "staff",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------------------------------------------------------------------------
local CurrentSurface = Surface.None
local IncomingData   = nil
local ActiveTicket   = nil
local ActiveBlip     = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
local function HexToRGB(Hex)
	if type(Hex) ~= "string" then return 1,67,187 end
	Hex = Hex:gsub("#","")
	if #Hex ~= 6 then return 1,67,187 end
	return tonumber(Hex:sub(1,2),16) or 1,tonumber(Hex:sub(3,4),16) or 67,tonumber(Hex:sub(5,6),16) or 187
end

local function ResolveTheme()
	local Color = (Theme and Theme.main) or Calls.ThemeColor or "#dc1553"
	local R,G,B = HexToRGB(Color)
	return { hex = Color, rgb = string.format("%d,%d,%d",R,G,B) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendNui(Action,Payload)
	SendNUIMessage({ action = Action, payload = Payload })
end

local function HasFocus()
	return CurrentSurface == Surface.Prompt or CurrentSurface == Surface.Panel
		or CurrentSurface == Surface.Feedback or CurrentSurface == Surface.Staff
end

local function ApplyFocus()
	if HasFocus() then
		SetNuiFocus(true,true)
	else
		SetNuiFocus(false,false)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
local function OpenPrompt()
	if CurrentSurface ~= Surface.None then return end
	CurrentSurface = Surface.Prompt
	ApplyFocus()
	SendNui("setConfig",{ theme = ResolveTheme(), keys = { accept = Calls.AcceptKey, decline = Calls.DeclineKey, staff = Calls.StaffMenuKey, finish = Calls.FinishKey } })
	SendNui("openPrompt",{})
	SendNui("setVisible",true)
end

local function OpenPanel(Initial)
	if CurrentSurface == Surface.Panel then return end
	CurrentSurface = Surface.Panel
	ApplyFocus()
	SendNui("setConfig",{ theme = ResolveTheme(), keys = { accept = Calls.AcceptKey, decline = Calls.DeclineKey, staff = Calls.StaffMenuKey, finish = Calls.FinishKey } })
	SendNui("openPanel",Initial)
	SendNui("setVisible",true)
end

local function OpenStaffMenu()
	if not ActiveTicket or CurrentSurface == Surface.Staff then return end
	CurrentSurface = Surface.Staff
	ApplyFocus()
	SendNui("openStaffMenu",{ id = ActiveTicket.id, name = ActiveTicket.name, text = ActiveTicket.text })
	SendNui("setVisible",true)
end

local function OpenFeedback(StaffInfo)
	CurrentSurface = Surface.Feedback
	ApplyFocus()
	SendNui("setConfig",{ theme = ResolveTheme() })
	SendNui("openFeedback",StaffInfo)
	SendNui("setVisible",true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseSurface(Silent)
	if CurrentSurface == Surface.None then return end

	local Previous = CurrentSurface
	CurrentSurface = Surface.None

	SendNui("setVisible",false)
	SendNui("closeSurface",{})
	ApplyFocus()

	if not Silent and Previous == Surface.Panel then
		vSERVER.ClosePanel()
	end
end

local function HideIncoming()
	IncomingData = nil
	SendNui("hideIncoming",{})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIP
-----------------------------------------------------------------------------------------------------------------------------------------
local function ClearBlip()
	if ActiveBlip then
		RemoveBlip(ActiveBlip)
		ActiveBlip = nil
	end
end

local function CreateAttendBlip(Coords)
	ClearBlip()
	ActiveBlip = AddBlipForCoord(Coords.x + 0.0,Coords.y + 0.0,Coords.z + 0.0)
	SetBlipSprite(ActiveBlip,Calls.Blip.Sprite)
	SetBlipColour(ActiveBlip,Calls.Blip.Color)
	SetBlipScale(ActiveBlip,Calls.Blip.Scale)
	SetBlipAsShortRange(ActiveBlip,Calls.Blip.ShortRange)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Calls.Blip.Name)
	EndTextCommandSetBlipName(ActiveBlip)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATTEND THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
local function DrawAttendText(Text,X,Y)
	SetTextFont(4)
	SetTextScale(0.5,0.5)
	SetTextColour(255,255,255,180)
	SetTextOutline()
	SetTextCentre(true)
	SetTextEntry("STRING")
	AddTextComponentString(Text)
	DrawText(X,Y)
end

local function RunAttendThread()
	CreateThread(function()
		while ActiveTicket do
			local Ticket = ActiveTicket
			local Origin = Ticket.coords
			local Ped    = PlayerPedId()
			local PCoord = GetEntityCoords(Ped)

			local Far = (#(PCoord - vector3(Origin.x,Origin.y,Origin.z))) > 50.0
			local TargetPed
			if not Far then
				local Idx = GetPlayerFromServerId(Ticket.target)
				if Idx and Idx ~= -1 then
					TargetPed = GetPlayerPed(Idx)
				end
			end

			if not Far and TargetPed and TargetPed ~= 0 and DoesEntityExist(TargetPed) then
				local TCoord = GetEntityCoords(TargetPed)
				DrawMarker(0,TCoord.x,TCoord.y,TCoord.z + 1.5,0.0,0.0,0.0,0.0,0.0,0.0,0.5,0.5,0.5,255,255,255,150,true,false,0,false,nil,nil,false)
				DrawAttendText("Para finalizar use /"..Calls.FinishCommand,0.5,0.85)
				DrawAttendText("ID: "..Ticket.id.."  •  "..(Ticket.text or ""),0.5,0.90)
			else
				DrawAttendText("Volte para o local do chamado (ID: "..Ticket.id..")",0.5,0.85)
				DrawAttendText("Ou finalize com /"..Calls.FinishCommand,0.5,0.90)
			end

			Wait(0)
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NET EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-calls:OpenPrompt",function()
	OpenPrompt()
end)

RegisterNetEvent("core-calls:OpenPanel",function()
	local Initial = vSERVER.GetInitial()
	if not Initial then
		CloseSurface(true)
		return
	end
	OpenPanel(Initial)
end)

RegisterNetEvent("core-calls:Incoming",function(Data)
	if ActiveTicket then return end
	IncomingData = { id = Data.id, expiresAt = GetGameTimer() + (Data.time * 1000) }
	SendNui("incoming",Data)
end)

RegisterNetEvent("core-calls:Update",function(Snapshot)
	SendNui("updateTickets",Snapshot)
end)

RegisterNetEvent("core-calls:Accepted",function(Data)
	ActiveTicket = Data
	CreateAttendBlip(Data.coords)
	HideIncoming()
	if CurrentSurface == Surface.Panel then CloseSurface(true) end
	SendNui("ticketActive",{ id = Data.id, name = Data.name })
	TriggerEvent("Notify","Chamados","Chamado de "..(Data.name or "?").." aceito. "..Calls.StaffMenuKey.." para acoes, "..Calls.FinishKey.." para finalizar.","verde",20000)
	RunAttendThread()
end)

RegisterNetEvent("core-calls:Finished",function()
	ActiveTicket = nil
	ClearBlip()
	if CurrentSurface == Surface.Staff then CloseSurface(true) end
	SendNui("ticketEnded",{})
end)

RegisterNetEvent("core-calls:Feedback",function(StaffInfo)
	OpenFeedback(StaffInfo)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:SUBMITTICKET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("submitTicket",function(Data,Callback)
	local Text = Data and Data.text or ""
	CloseSurface(true)
	local Result = vSERVER.OpenTicket(Text)
	Callback(Result or { ok = false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:ACCEPT / DECLINE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("acceptTicket",function(Data,Callback)
	local Id = Data and tonumber(Data.id)
	Callback(vSERVER.AcceptTicket(Id) or { ok = false })
end)

RegisterNUICallback("declineTicket",function(Data,Callback)
	local Id = Data and tonumber(Data.id)
	Callback(vSERVER.DeclineTicket(Id) or { ok = false })
end)

RegisterNUICallback("dismissIncoming",function(_,Callback)
	HideIncoming()
	Callback({ ok = true })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:FEEDBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("submitFeedback",function(Data,Callback)
	local Stars = Data and tonumber(Data.stars) or 5
	CloseSurface(true)
	Callback(vSERVER.SubmitFeedback(Stars) or { ok = false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:STAFF ACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("staffRevive",function(_,Callback)
	Callback(vSERVER.StaffRevive() or { ok = false })
end)

RegisterNUICallback("staffTpTo",function(_,Callback)
	if CurrentSurface == Surface.Staff then CloseSurface(true) end
	Callback(vSERVER.StaffTpTo() or { ok = false })
end)

RegisterNUICallback("staffPullPlayer",function(_,Callback)
	if CurrentSurface == Surface.Staff then CloseSurface(true) end
	Callback(vSERVER.StaffPullPlayer() or { ok = false })
end)

RegisterNUICallback("staffSendToGarage",function(_,Callback)
	Callback(vSERVER.StaffSendToGarage() or { ok = false })
end)

RegisterNUICallback("staffFinish",function(_,Callback)
	if CurrentSurface == Surface.Staff then CloseSurface(true) end
	Callback(vSERVER.StaffFinish() or { ok = false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close",function(_,Callback)
	CloseSurface()
	Callback({ ok = true })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEY MAPPINGS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+calls_accept",function()
	if not IncomingData then return end
	local Id = IncomingData.id
	HideIncoming()
	vSERVER.AcceptTicket(Id)
end)
RegisterCommand("-calls_accept",function() end)

RegisterCommand("+calls_decline",function()
	if not IncomingData then return end
	local Id = IncomingData.id
	HideIncoming()
	vSERVER.DeclineTicket(Id)
end)
RegisterCommand("-calls_decline",function() end)

RegisterCommand("+calls_staffmenu",function()
	if not ActiveTicket then return end
	if CurrentSurface == Surface.Staff then
		CloseSurface(true)
	else
		OpenStaffMenu()
	end
end)
RegisterCommand("-calls_staffmenu",function() end)

RegisterCommand("+calls_finish",function()
	if not ActiveTicket then return end
	vSERVER.StaffFinish()
end)
RegisterCommand("-calls_finish",function() end)

RegisterKeyMapping("+calls_accept",   "Aceitar chamado",       "KEYBOARD",Calls.AcceptKey)
RegisterKeyMapping("+calls_decline",  "Recusar chamado",       "KEYBOARD",Calls.DeclineKey)
RegisterKeyMapping("+calls_staffmenu","Menu staff (chamado)",  "KEYBOARD",Calls.StaffMenuKey)
RegisterKeyMapping("+calls_finish",   "Finalizar chamado",     "KEYBOARD",Calls.FinishKey)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WATCHDOGS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if IncomingData and GetGameTimer() > IncomingData.expiresAt then
			HideIncoming()
		end
		Wait(250)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(Resource)
	if Resource ~= GetCurrentResourceName() then return end
	ClearBlip()
	SetNuiFocus(false,false)
end)
