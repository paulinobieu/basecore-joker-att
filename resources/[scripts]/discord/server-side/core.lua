-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD
-----------------------------------------------------------------------------------------------------------------------------------------
local Discord = {
	Characters = "https://discord.com/api/webhooks/1513711984389001398/fdUumwooUg_OZv1IO9ACjabH8uHmnGlouoIo_9stkGoFsSWpV5uHsXyQbWFliu1Q47QC",
	Connect = "",
	Disconnect = "",
	Airport = "",
	Deaths = "",
	Gemstone = "",
	Rename = "",
	Roles = "",
	Weaponskins = "",
	Marketplace = "",
	Shopping = "",
	Boxes = "",
	Battlepass = "",
	Hackers = "",
	Skin = "",
	ClearInv = "",
	Dima = "",
	God = "",
	Item = "",
	Delete = "",
	Kick = "",
	Ban = "",
	Group = "",
	AddCar = "",
	Print = "",
	Permissions = "",
	Sprays = "",
	Daily = "",
	Premium = "",
	Chest = "",
	Propertys = "",
	Crons = "",
	Races = "",
	Pdm = "",
	Domination = "",
	Luckywheel = "",
	Send = "",
	Inspect = "",
	Money = ""
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMBED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Embed",function(Hook,Message,source)
	PerformHttpRequest(Discord[Hook],function() end,"POST",json.encode({
		username = ServerName,
		avatar_url = ServerAvatar,
		embeds = {
			{
				color = 6171009,
				description = Message,
				footer = {
					icon_url = ServerAvatar,
					text = os.date("%d/%m/%Y %H:%M:%S")
				}
			}
		}
	}),{ ["Content-Type"] = "application/json" })

	if source then
		TriggerClientEvent("megazord:Screenshot",source,Discord[Hook])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTENT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Content",function(Hook,Message)
	PerformHttpRequest(Discord[Hook],function() end,"POST",json.encode({
		username = ServerName,
		content = Message
	}),{ ["Content-Type"] = "application/json" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Webhook",function(Hook)
	return Discord[Hook] or ""
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("CharacterChosen",function(Passport,source,Creation)
	local Identity = vRP.Identity(Passport)
	if not Identity then return end

	local DiscordId = vRP.AccountInformation(Passport,"Discord") or "0"
	local Message = ("%s %s %s %s"):format(DiscordId,Identity.Name,Identity.Lastname,Passport)

	PerformHttpRequest(Discord.Characters,function() end,"POST",json.encode({ content = Message }),{ ["Content-Type"] = "application/json" })
end)