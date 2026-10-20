-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-influencers",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Groups = {}
local PlayerGroup = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckPermission()
	local source = source
	return Functions.HasPermission(Functions.Passport(source),Influencers.Permission)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP STATE
-----------------------------------------------------------------------------------------------------------------------------------------
local function GroupPayload(OwnerSid,TargetSid)
	local Group = Groups[OwnerSid]
	if not Group then return nil end

	local Members = {}
	for _,Sid in ipairs(Group.members) do
		local Passport = Functions.Passport(Sid)
		if Passport then
			Members[#Members+1] = {
				sid = Sid,
				name = Functions.FullName(Passport),
				isOwner = tonumber(Sid) == tonumber(OwnerSid),
			}
		end
	end

	return {
		owner = OwnerSid,
		members = Members,
		enabled = Group.enabled == true,
		isOwner = tonumber(TargetSid) == tonumber(OwnerSid),
	}
end

local function BroadcastGroup(OwnerSid)
	local Group = Groups[OwnerSid]
	if not Group then return end

	for _,Sid in ipairs(Group.members) do
		if Functions.Passport(Sid) then
			TriggerClientEvent("core-influencers:GroupState",tonumber(Sid),GroupPayload(OwnerSid,Sid))
		end
	end
end

local function RemoveMember(OwnerSid,MemberSid)
	local Group = Groups[OwnerSid]
	if not Group then return end

	local Members = {}
	for _,Sid in ipairs(Group.members) do
		if tonumber(Sid) ~= tonumber(MemberSid) then
			Members[#Members+1] = Sid
		end
	end
	Group.members = Members
	PlayerGroup[MemberSid] = nil

	if Functions.Passport(MemberSid) then
		TriggerClientEvent("core-influencers:GroupRemoved",tonumber(MemberSid))
		TriggerClientEvent("core-influencers:ForceCancel",tonumber(MemberSid))
	end
end

local function DissolveGroup(OwnerSid)
	local Group = Groups[OwnerSid]
	if not Group then return end

	for _,Sid in ipairs(Group.members) do
		if tonumber(Sid) ~= tonumber(OwnerSid) then
			PlayerGroup[Sid] = nil
			if Functions.Passport(Sid) then
				TriggerClientEvent("core-influencers:GroupClosed",tonumber(Sid))
				TriggerClientEvent("core-influencers:ForceCancel",tonumber(Sid))
			end
		end
	end

	PlayerGroup[OwnerSid] = nil
	Groups[OwnerSid] = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP:INVITE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:GroupInvite")
AddEventHandler("core-influencers:GroupInvite",function(TargetSid)
	local OwnerSid = source
	local OwnerPassport = Functions.Passport(OwnerSid)
	TargetSid = tonumber(TargetSid)

	if not OwnerPassport or not Functions.HasPermission(OwnerPassport,Influencers.Permission) then
		Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupNoPermission,"negado",5000)
		return
	end

	if not TargetSid or TargetSid <= 0 then return end

	if TargetSid == OwnerSid then
		Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupSelfInvite,"aviso",5000)
		return
	end

	if not Functions.Passport(TargetSid) then
		Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupPlayerNotFound,"aviso",5000)
		return
	end

	if PlayerGroup[TargetSid] then
		Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupAlreadyInGroup,"aviso",5000)
		return
	end

	if not Groups[OwnerSid] then
		Groups[OwnerSid] = { members = { OwnerSid }, enabled = false }
		PlayerGroup[OwnerSid] = OwnerSid
	end

	local Group = Groups[OwnerSid]
	for _,Sid in ipairs(Group.members) do
		if tonumber(Sid) == TargetSid then
			Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupAlreadyMember,"aviso",5000)
			return
		end
	end

	Group.members[#Group.members+1] = TargetSid
	PlayerGroup[TargetSid] = OwnerSid

	TriggerClientEvent("core-influencers:GroupJoined",TargetSid,Functions.FullName(OwnerPassport))
	Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupMemberAdded,"verde",5000)
	BroadcastGroup(OwnerSid)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP:REMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:GroupRemove")
AddEventHandler("core-influencers:GroupRemove",function(TargetSid)
	local OwnerSid = source
	TargetSid = tonumber(TargetSid)

	if not Functions.Passport(OwnerSid) then return end

	local Group = Groups[OwnerSid]
	if not Group then return end

	if tonumber(PlayerGroup[OwnerSid]) ~= tonumber(OwnerSid) then
		Functions.Notify(OwnerSid,"Influencers",Influencers.Language.GroupOnlyLeaderRemove,"aviso",5000)
		return
	end

	RemoveMember(OwnerSid,TargetSid)
	BroadcastGroup(OwnerSid)

	if #Group.members <= 1 then
		DissolveGroup(OwnerSid)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP:LEAVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:GroupLeave")
AddEventHandler("core-influencers:GroupLeave",function()
	local MemberSid = source
	local OwnerSid = PlayerGroup[MemberSid]
	if not OwnerSid then return end

	if tonumber(OwnerSid) == tonumber(MemberSid) then
		DissolveGroup(OwnerSid)
		return
	end

	RemoveMember(OwnerSid,MemberSid)

	local Group = Groups[OwnerSid]
	if Group then
		BroadcastGroup(OwnerSid)
		if #Group.members <= 1 then
			DissolveGroup(OwnerSid)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP:PLAY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:GroupPlay")
AddEventHandler("core-influencers:GroupPlay",function(Command,NetStart,SyncId)
	local OwnerSid = source
	local Group = Groups[OwnerSid]

	if not Group or not Group.enabled then return end
	if not Command or Command == "" then return end

	for _,Sid in ipairs(Group.members) do
		if tonumber(Sid) ~= tonumber(OwnerSid) and Functions.Passport(Sid) then
			TriggerClientEvent("core-influencers:GroupPlay",tonumber(Sid),Command,NetStart,SyncId)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP:TOGGLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:GroupToggle")
AddEventHandler("core-influencers:GroupToggle",function(Enabled)
	local OwnerSid = source
	local Group = Groups[OwnerSid]
	if not Group then return end
	if tonumber(PlayerGroup[OwnerSid]) ~= tonumber(OwnerSid) then return end

	Group.enabled = Enabled == true
	BroadcastGroup(OwnerSid)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:SyncRequest")
AddEventHandler("core-influencers:SyncRequest",function(TargetSid,Command)
	local FromSid = source
	local FromPassport = Functions.Passport(FromSid)
	TargetSid = tonumber(TargetSid)

	if not FromPassport or not Functions.HasPermission(FromPassport,Influencers.Permission) then return end
	if not TargetSid or not Functions.Passport(TargetSid) then
		Functions.Notify(FromSid,"Influencers",Influencers.Language.SyncTargetNotFound,"negado",5000)
		return
	end

	TriggerClientEvent("core-influencers:SyncRequest",TargetSid,FromSid,Command)
end)

RegisterNetEvent("core-influencers:SyncAccept")
AddEventHandler("core-influencers:SyncAccept",function(SenderSid)
	local TargetSid = source
	SenderSid = tonumber(SenderSid)

	if not Functions.Passport(TargetSid) or not Functions.Passport(SenderSid) then return end
	TriggerClientEvent("core-influencers:SyncAccepted",SenderSid,TargetSid)
end)

RegisterNetEvent("core-influencers:SyncDeny")
AddEventHandler("core-influencers:SyncDeny",function(SenderSid)
	local TargetSid = source
	SenderSid = tonumber(SenderSid)

	if not Functions.Passport(TargetSid) or not Functions.Passport(SenderSid) then return end
	TriggerClientEvent("core-influencers:SyncDenied",SenderSid,TargetSid)
end)

RegisterNetEvent("core-influencers:SyncToTarget")
AddEventHandler("core-influencers:SyncToTarget",function(TargetSid,FromSid,OtherCommand,AttachFlag,NetStart,SyncId)
	local SenderSid = source
	local SenderPassport = Functions.Passport(SenderSid)
	TargetSid = tonumber(TargetSid)

	if not SenderPassport or not Functions.HasPermission(SenderPassport,Influencers.Permission) then return end
	if not TargetSid or not Functions.Passport(TargetSid) then return end

	TriggerClientEvent("core-influencers:PlayOther",TargetSid,FromSid,OtherCommand,AttachFlag,NetStart,SyncId)
end)

RegisterNetEvent("core-influencers:SyncCancel")
AddEventHandler("core-influencers:SyncCancel",function(PartnerSid)
	local FromSid = source
	PartnerSid = tonumber(PartnerSid)

	if not Functions.Passport(FromSid) or not Functions.Passport(PartnerSid) then return end
	TriggerClientEvent("core-influencers:ForceCancel",PartnerSid)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SOUND RELAY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:PlaySoundNear")
AddEventHandler("core-influencers:PlaySoundNear",function(File,Volume,Radius)
	local source = source
	if not Functions.Passport(source) or not File or File == "" then return end

	Volume = tonumber(Volume) or Influencers.Sound.Volume
	Radius = tonumber(Radius) or Influencers.Sound.Radius
	TriggerClientEvent("core-influencers:PlaySound",-1,source,File,Volume,Radius)
end)

RegisterNetEvent("core-influencers:StopSoundNear")
AddEventHandler("core-influencers:StopSoundNear",function()
	local source = source
	if not Functions.Passport(source) then return end
	TriggerClientEvent("core-influencers:StopSound",-1,source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPS (PL_PROTECT)
-----------------------------------------------------------------------------------------------------------------------------------------
local PropsByCommand = {}

local function IndexProps(Command,Options)
	if not Command or not Options or not Options.Props then return end

	local Names = {}
	for _,Prop in ipairs(Options.Props) do
		if Prop and Prop.Name and Prop.Name ~= "" then
			Names[#Names+1] = Prop.Name
		end
	end

	if #Names > 0 then
		PropsByCommand[Command] = Names
	end
end

CreateThread(function()
	local Pack = Influencers.EmotePack or {}

	for _,Emote in ipairs(Pack.options or {}) do
		if Emote then
			IndexProps(Emote.Command,Emote.Options)
		end
	end

	for _,CategoryData in pairs(Pack.categories or {}) do
		for _,Entry in ipairs(CategoryData.emoteList or {}) do
			IndexProps(Entry.command or Entry.Command,Entry.Options)
		end
	end
end)

RegisterNetEvent("core-influencers:AddPropToPlayer")
AddEventHandler("core-influencers:AddPropToPlayer",function(Command)
	local source = source
	if GetResourceState("PL_PROTECT") ~= "started" then return end

	local Names = PropsByCommand[Command]
	if not Names then return end

	for _,Name in ipairs(Names) do
		if GetResourceState("PL_PROTECT") == "started" then exports["PL_PROTECT"]:setSpawnClient(source,Name) end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DROP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function()
	local Sid = source

	if Groups[Sid] then
		DissolveGroup(Sid)
	end

	local OwnerSid = PlayerGroup[Sid]
	if OwnerSid and Groups[OwnerSid] then
		RemoveMember(OwnerSid,Sid)
		local Group = Groups[OwnerSid]
		if Group then
			if #Group.members <= 1 then
				DissolveGroup(OwnerSid)
			else
				BroadcastGroup(OwnerSid)
			end
		end
	end

	PlayerGroup[Sid] = nil
end)
