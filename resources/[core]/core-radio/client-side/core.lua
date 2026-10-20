-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local IsRadioOpen = false
local IsHudActive = false
local IsAnimationPlaying = false
local ConnectedRadios = {}
local CurrentRadio = nil
local CurrentRadioIndex = 1
local SelectedAnimation = 1
local RadioPropHandle = nil
local RemoteRadioProps = {}
local PendingCallbacks = {}
local NextCallbackId = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVER CALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
local function ServerCallback(eventName, data, cb)
	NextCallbackId = NextCallbackId + 1
	local id = NextCallbackId
	PendingCallbacks[id] = cb
	TriggerServerEvent(eventName, id, data)
end

RegisterNetEvent("core-radio:callback")
AddEventHandler("core-radio:callback", function(callbackId, result)
	local cb = PendingCallbacks[callbackId]
	if cb then
		PendingCallbacks[callbackId] = nil
		cb(result)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function LoadAnimationDict(dict)
	if HasAnimDictLoaded(dict) then
		return true
	end

	RequestAnimDict(dict)
	local timeout = GetGameTimer() + 5000

	while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
		Wait(10)
	end

	return HasAnimDictLoaded(dict)
end

local function CreateRadioProp(ped)
	local propHash = GetHashKey(Radio.RadioProp)
	RequestModel(propHash)

	local timeout = GetGameTimer() + 5000
	while not HasModelLoaded(propHash) and GetGameTimer() < timeout do
		Wait(10)
	end

	local prop = CreateObject(propHash, 0.0, 0.0, 0.0, true, true, true)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, Radio.BoneIndex), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(propHash)

	return prop
end

local function DeleteRadioProp()
	if RadioPropHandle and DoesEntityExist(RadioPropHandle) then
		DeleteObject(RadioPropHandle)
		RadioPropHandle = nil
	end
end

local function StartRadioAnimation()
	local ped = PlayerPedId()

	if IsPedInAnyVehicle(ped, false) then
		return
	end

	if LoadAnimationDict(Radio.AnimDict) then
		TaskPlayAnim(ped, Radio.AnimDict, "cellphone_text_in", 8.0, 8.0, -1, 50, 1, false, false, false)
		RadioPropHandle = CreateRadioProp(ped)
		IsAnimationPlaying = true
		Entity(ped).state:set("radioProp", true, true)
	end
end

local function StopRadioAnimation()
	if not IsAnimationPlaying then
		return
	end

	IsAnimationPlaying = false
	local ped = PlayerPedId()
	Entity(ped).state:set("radioProp", false, true)

	if IsPedInAnyVehicle(ped, false) then
		ClearPedTasks(ped)
		DeleteRadioProp()
		return
	end

	if LoadAnimationDict(Radio.AnimDict) then
		TaskPlayAnim(ped, Radio.AnimDict, "cellphone_text_out", 8.0, 8.0, -1, 50, 1, false, false, false)
	end

	CreateThread(function()
		Wait(1000)
		local p = PlayerPedId()
		ClearPedTasks(p)
		DeleteRadioProp()
	end)
end

local function PlaySound(soundName, volume)
	SendNUIMessage({
		sound = soundName,
		volume = volume or 0.5
	})
end

local function SendNui(action, data)
	SendNUIMessage({
		action = action,
		data = data or {}
	})
end

local function IsFrequencyPrivate(frequency)
	return Radio.RestrictedFrequencies[frequency] ~= nil
end

local function GetFrequencyPermissions(frequency)
	return Radio.RestrictedFrequencies[frequency]
end

local function FindRadioByFrequency(frequency)
	for index, radio in ipairs(ConnectedRadios) do
		if radio.frequency == frequency then
			return radio, index
		end
	end
	return nil, nil
end

local function FindRadioById(radioId)
	for index, radio in ipairs(ConnectedRadios) do
		if radio.id == radioId then
			return radio, index
		end
	end
	return nil, nil
end

local function SetVoiceRadioChannel(frequency, volume)
	exports["pma-voice"]:setRadioChannel(frequency)
	exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
	exports["pma-voice"]:setRadioVolume(volume)
	TriggerEvent("radio:Connect", frequency)
end

local function DisableVoiceRadio()
	exports["pma-voice"]:removePlayerFromRadio()
	exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
	TriggerEvent("radio:Disconnect")
end

local function BuildChannelList()
	local list = {}
	for _, radio in ipairs(ConnectedRadios) do
		list[#list + 1] = {
			id = "radio-" .. tostring(radio.frequency),
			label = "Rádio " .. tostring(radio.frequency),
			frequency = radio.frequency,
			type = IsFrequencyPrivate(radio.frequency) and "private" or "public",
			connected = true
		}
	end
	return list
end



local function BuildRestrictedFrequencyList()
	local list = {}
	for frequency, _ in pairs(Radio.RestrictedFrequencies) do
		list[#list + 1] = frequency
	end
	table.sort(list)
	return list
end

local function GetSelectedAnimationId()
	return "anim-" .. tostring(SelectedAnimation)
end

local function UpdateNuiRadioState()
	SendNui("radio:ui:channels", {
		publicChannels = BuildChannelList(),
		restrictedFrequencies = BuildRestrictedFrequencyList()
	})
	if CurrentRadio and CurrentRadio.volume then
		SendNui("radio:ui:volume", { volume = CurrentRadio.volume })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN RADIO
-----------------------------------------------------------------------------------------------------------------------------------------
local function RequestOpenRadio()
	if IsRadioOpen then
		return
	end

	local ped = PlayerPedId()
	if GetEntityHealth(ped) <= 101 then
		return
	end

	TriggerServerEvent("core-radio:requestOpen")
end

local function OpenRadio()
	IsRadioOpen = true
	StartRadioAnimation()
	SetNuiFocus(true, true)
	SetCursorLocation(0.5, 0.5)
	SendNui("radio:ui:config", {
		themeColor = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or Radio.ThemeColor or "#dc1553",
		radioAlign = Radio.RadioAlign,
		speakingAlign = Radio.SpeakingAlign
	})
	SendNui("radio:ui:visible", { visible = true })
	UpdateNuiRadioState()
	SendNui("radio:ui:animations", {
		selectedAnimationId = GetSelectedAnimationId()
	})
end

RegisterNetEvent("core-radio:open")
AddEventHandler("core-radio:open", function()
	OpenRadio()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE RADIO
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseRadio()
	if not IsRadioOpen then
		return
	end

	IsRadioOpen = false
	StopRadioAnimation()
	SetNuiFocus(false, false)
	SendNui("radio:ui:visible", { visible = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT TO FREQUENCY
-----------------------------------------------------------------------------------------------------------------------------------------
local function ConnectToFrequency(frequency)
	if frequency < Radio.MinFrequency or frequency > Radio.MaxFrequency then
		TriggerEvent("Notify", "Negado", "Frequência inválida.", "vermelho", 5000)
		return
	end

	local existingRadio = FindRadioByFrequency(frequency)
	if existingRadio then
		TriggerEvent("Notify", "Aviso", "Já está conectado nesta frequência.", "amarelo", 5000)
		return
	end

	TriggerServerEvent("core-radio:connect", frequency)
end

RegisterNetEvent("core-radio:frequencyJoined")
AddEventHandler("core-radio:frequencyJoined", function(frequency)
	local isPrivate = IsFrequencyPrivate(frequency)
	local newRadio = {
		id = GetGameTimer(),
		frequencia = frequency,
		frequency = frequency,
		nome = "Rádio " .. frequency,
		name = "Rádio " .. frequency,
		tipo = isPrivate and "privada" or "publica",
		type = isPrivate and "privada" or "publica",
		volume = Radio.DefaultVolume,
		mic = false,
		ligado = true,
		active = true
	}

	table.insert(ConnectedRadios, newRadio)
	CurrentRadio = newRadio
	CurrentRadioIndex = #ConnectedRadios

	SetVoiceRadioChannel(frequency, newRadio.volume)

	UpdateNuiRadioState()
	SendNui("radio:ui:connected", { frequency = frequency })
	PlaySound("audio_on", 0.6)
	TriggerEvent("Notify", "Sucesso", "Conectado à frequência: " .. frequency, "verde", 5000)
end)

RegisterNetEvent("core-radio:connectDenied")
AddEventHandler("core-radio:connectDenied", function(frequency)
	-- Server already sent notify, no action needed on client
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT FROM FREQUENCY
-----------------------------------------------------------------------------------------------------------------------------------------
local function DisconnectFromFrequency(radioId)
	local radio, index = FindRadioById(radioId)
	if not radio then
		return false
	end

	table.remove(ConnectedRadios, index)
	TriggerServerEvent("core-radio:disconnect", radio.frequency)

	if CurrentRadio and CurrentRadio.id == radioId then
		if #ConnectedRadios > 0 then
			local fallback = ConnectedRadios[math.min(index, #ConnectedRadios)] or ConnectedRadios[1]
			CurrentRadio = fallback
			CurrentRadioIndex = 1
			for i, r in ipairs(ConnectedRadios) do
				if r.id == fallback.id then
					CurrentRadioIndex = i
					break
				end
			end
			SetVoiceRadioChannel(fallback.frequency, fallback.volume)
		else
			CurrentRadio = nil
			CurrentRadioIndex = 1
			DisableVoiceRadio()
			PlaySound("audio_off", 0.05)
		end
	end

	UpdateNuiRadioState()
	TriggerEvent("Notify", "Sucesso", "Desconectado da frequência: " .. radio.frequency, "verde", 5000)

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT ALL
-----------------------------------------------------------------------------------------------------------------------------------------
local function DisconnectAll()
	for _, radio in ipairs(ConnectedRadios) do
		TriggerServerEvent("core-radio:disconnect", radio.frequency)
	end

	DisableVoiceRadio()
	ConnectedRadios = {}
	CurrentRadio = nil
	CurrentRadioIndex = 1

	UpdateNuiRadioState()
	PlaySound("audio_off", 0.05)
	TriggerEvent("Notify", "Sucesso", "Todos os rádios foram desligados.", "verde", 5000)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE VOLUME
-----------------------------------------------------------------------------------------------------------------------------------------
local function UpdateRadioVolume(radioId, volume)
	if volume < 0 or volume > 100 then
		return false
	end

	local radio = FindRadioById(radioId)
	if not radio then
		return false
	end

	radio.volume = volume

	if CurrentRadio and CurrentRadio.id == radioId then
		exports["pma-voice"]:setRadioVolume(volume)
	end

	SendNui("radio:ui:volume", { volume = volume })
	TriggerEvent("Notify", "Sucesso", "Volume do rádio: " .. volume .. "%", "verde", 3000)

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NAVIGATE RADIO
-----------------------------------------------------------------------------------------------------------------------------------------
local function NavigateRadio(direction)
	if #ConnectedRadios == 0 then
		TriggerEvent("Notify", "Aviso", "Nenhum rádio conectado.", "amarelo", 5000)
		return
	end

	if direction == "up" then
		CurrentRadioIndex = CurrentRadioIndex + 1
		if CurrentRadioIndex > #ConnectedRadios then
			CurrentRadioIndex = 1
		end
	elseif direction == "down" then
		CurrentRadioIndex = CurrentRadioIndex - 1
		if CurrentRadioIndex < 1 then
			CurrentRadioIndex = #ConnectedRadios
		end
	end

	local selectedRadio = ConnectedRadios[CurrentRadioIndex]
	CurrentRadio = selectedRadio

	SetVoiceRadioChannel(selectedRadio.frequency, selectedRadio.volume)

	UpdateNuiRadioState()
	SendNui("radio:ui:volume", { volume = selectedRadio.volume })

	local directionText = direction == "up" and "subiu" or "desceu"
	TriggerEvent("Notify", "Sucesso", "Você " .. directionText .. " para a rádio " .. selectedRadio.frequency, "verde", 3000)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE HUD
-----------------------------------------------------------------------------------------------------------------------------------------
local function ToggleHud()
	IsHudActive = not IsHudActive
	if IsHudActive then
		TriggerEvent("Notify", "Sucesso", "HUD do rádio ativado.", "verde", 3000)
	else
		TriggerEvent("Notify", "Aviso", "HUD do rádio desativado.", "amarelo", 3000)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Radio.Command, function()
	if Radio.EnableCommand then
		RequestOpenRadio()
	end
end, false)

RegisterCommand("radio_up", function()
	if #ConnectedRadios > 0 then
		NavigateRadio("up")
	end
end, false)

RegisterCommand("radio_down", function()
	if #ConnectedRadios > 0 then
		NavigateRadio("down")
	end
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEY MAPPINGS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("radio_up", "Rádio - Subir Frequência", "keyboard", "PAGEUP")
RegisterKeyMapping("radio_down", "Rádio - Descer Frequência", "keyboard", "PAGEDOWN")
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("radioGui")
AddEventHandler("radioGui", function()
	RequestOpenRadio()
end)

RegisterNetEvent("radio:Open")
AddEventHandler("radio:Open", function()
	RequestOpenRadio()
end)

RegisterNetEvent("radio:check")
AddEventHandler("radio:check", function()
	RequestOpenRadio()
end)

RegisterNetEvent("radio:outServers")
AddEventHandler("radio:outServers", function()
	if CurrentRadio then
		DisconnectAll()
	end
end)

RegisterNetEvent("core-radio:updateTalkingStatus")
AddEventHandler("core-radio:updateTalkingStatus", function(status, frequency, userId, playerName)
	if CurrentRadio and CurrentRadio.frequency == frequency then
		SendNui("radio:ui:speaking", {
			playerName = playerName,
			playerId = tostring(userId),
			talking = status == true
		})
	end
end)

RegisterNetEvent("client:pessoafalando")
AddEventHandler("client:pessoafalando", function(status, frequency, userId, playerName)
	if CurrentRadio and CurrentRadio.frequency == frequency then
		SendNui("radio:ui:speaking", {
			playerName = playerName,
			playerId = tostring(userId),
			talking = status == true
		})
	end
end)

RegisterNetEvent("core-radio:syncRadioState")
AddEventHandler("core-radio:syncRadioState", function()
	UpdateNuiRadioState()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("radio:ui:close", function(_, cb)
	CloseRadio()
	cb(true)
end)

RegisterNUICallback("radio:connect", function(data, cb)
	local frequency = tonumber(data.frequency)
	if frequency then
		ConnectToFrequency(frequency)
	end
	cb("ok")
end)

RegisterNUICallback("radio:disconnect", function(data, cb)
	local frequency = tonumber(data.frequency)
	if frequency then
		local radio, _ = FindRadioByFrequency(frequency)
		if radio then
			DisconnectFromFrequency(radio.id)
		end
	end
	cb("ok")
end)

RegisterNUICallback("radio:volume:set", function(data, cb)
	local volume = tonumber(data.volume)
	if volume and CurrentRadio then
		UpdateRadioVolume(CurrentRadio.id, volume)
	end
	cb("ok")
end)

RegisterNUICallback("radio:animation:set", function(data, cb)
	local animationId = tostring(data.animationId or "")
	local animId = tonumber(animationId:match("anim%-(%d+)"))
	if animId then
		SelectedAnimation = animId
		SetResourceKvp("core_radio_anim", tostring(animId))
		TriggerEvent("core-radio:setAnimation", animId)
		TriggerEvent("core-radio:setAnimacao", animId)
		TriggerEvent("Notify", "Sucesso", "Animação " .. animId .. " selecionada.", "verde", 3000)
		SendNui("radio:ui:animations", {
			selectedAnimationId = GetSelectedAnimationId()
		})
	end
	cb("ok")
end)

RegisterNUICallback("GetPlayers", function(_, cb)
	if CurrentRadio and CurrentRadio.frequency then
		ServerCallback("core-radio:getPlayers", CurrentRadio.frequency, function(result)
			cb(result)
		end)
	else
		cb({ players = {} })
	end
end)

RegisterNUICallback("radio:select", function(data, cb)
	local frequency = tonumber(data.frequency)
	if frequency then
		local radio, index = FindRadioByFrequency(frequency)
		if radio then
			CurrentRadio = radio
			CurrentRadioIndex = index
			SetVoiceRadioChannel(radio.frequency, radio.volume)
		end
	end
	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("getHudAtiva", function()
	return IsHudActive
end)

exports("pmaradioanim", function()
	return tostring(SelectedAnimation)
end)

exports("getRadioAnimData", function()
	local key = tostring(SelectedAnimation)
	local data = Radio.Animations[key]
	if data then
		return data
	end
	return Radio.Animations["1"]
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	SetNuiFocus(false, false)
	exports["pma-voice"]:setVoiceProperty("radioEnabled", false)

	local savedAnim = GetResourceKvpString("core_radio_anim")
	if savedAnim then
		SelectedAnimation = tonumber(savedAnim) or 1
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTROL DISABLE THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if IsRadioOpen then
			Wait(1)
			DisableControlAction(0, 1, true)
			DisableControlAction(0, 2, true)
			DisableControlAction(0, 14, true)
			DisableControlAction(0, 15, true)
			DisableControlAction(0, 16, true)
			DisableControlAction(0, 17, true)
			DisableControlAction(0, 99, true)
			DisableControlAction(0, 100, true)
			DisableControlAction(0, 115, true)
			DisableControlAction(0, 116, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 106, true)

			local ped = PlayerPedId()
			if IsAnimationPlaying then
				if IsPedInAnyVehicle(ped, false) then
					StopRadioAnimation()
				elseif not RadioPropHandle or not DoesEntityExist(RadioPropHandle) then
					RadioPropHandle = CreateRadioProp(ped)
				end
			end
		else
			Wait(100)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOTE PROP SYNC (third parties)
-----------------------------------------------------------------------------------------------------------------------------------------
local function CreateRemoteRadioProp(ped)
	local propHash = GetHashKey(Radio.RadioProp)
	RequestModel(propHash)

	local timeout = GetGameTimer() + 5000
	while not HasModelLoaded(propHash) and GetGameTimer() < timeout do
		Wait(10)
	end

	if not HasModelLoaded(propHash) then
		return nil
	end

	local prop = CreateObject(propHash, 0.0, 0.0, 0.0, false, false, false)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, Radio.BoneIndex), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(propHash)

	return prop
end

local function RemoveRemoteRadioProp(key)
	local handle = RemoteRadioProps[key]
	if handle and DoesEntityExist(handle) then
		DeleteEntity(handle)
	end
	RemoteRadioProps[key] = nil
end

AddStateBagChangeHandler("radioProp", nil, function(bagName, _key, value)
	local netId = tonumber(bagName:match("entity:(%d+)"))
	if not netId then return end

	if value then
		CreateThread(function()
			local timeout = GetGameTimer() + 5000
			while not NetworkDoesEntityExistWithNetworkId(netId) and GetGameTimer() < timeout do
				Wait(50)
			end
			if not NetworkDoesEntityExistWithNetworkId(netId) then return end

			local ped = NetworkGetEntityFromNetworkId(netId)
			if not DoesEntityExist(ped) then return end
			if ped == PlayerPedId() then return end

			RemoveRemoteRadioProp(netId)
			local prop = CreateRemoteRadioProp(ped)
			if prop then
				RemoteRadioProps[netId] = prop
			end
		end)
	else
		RemoveRemoteRadioProp(netId)
	end
end)

AddEventHandler("onResourceStop", function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
	for key in pairs(RemoteRadioProps) do
		RemoveRemoteRadioProp(key)
	end
end)

