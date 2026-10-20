-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Last: Utilizado apenas em roubos globais e exclusivos para indicar a última ocorrência.
--        Valor padrão: 1

-- Delay: Tempo de espera antes de permitir um novo roubo, usado apenas se diferente do padrão.
--        Valor padrão: 3600 segundos

-- Timer: Duração total do roubo, utilizado somente quando o tempo for diferente do padrão.
--        Valor padrão: 30 segundos

-- Wanted: Duração do estado de procurado após o roubo, aplicado somente se for diferente do padrão.
--        Valor padrão: 60 segundos

-- Cooldown: Define o tipo de cooldown do roubo.
--           Se for uma tabela, o roubo terá múltiplos cooldowns (multiplicador).
--           Se for um timestamp (os.time()), o cooldown será único.

-- Percentage: Probabilidade, em milésimos, de chamar a polícia durante o roubo.

-- Police: Quantidade mínima de policiais em serviço necessária para iniciar o roubo.
--         Utilizado somente quando essa restrição for necessária.

-- Explosion: Flag que indica se o roubo envolve explosões.
--            Utilizado somente quando aplicável.

-- Residual: Tipo de resíduo deixado após o roubo, usado apenas se diferente do padrão.
--           Valor padrão: "Resquício de Línter"

-- Need: Item(s) obrigatório(s) que o jogador deve possuir para iniciar o roubo.
--       Utilizado apenas quando houver essa exigência.
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
local Config = Inventory.Robbery.Modes
local Settings = Inventory.Robbery.Settings
local Points = Inventory.Robbery.Points
local Target = Inventory.Robbery.Target
local Cooldowns = {}
local Last = {}

local function Cooldown(Mode,Number)
	local Configuration = Config[Mode]
	if Configuration.Scope == "global" then
		return Cooldowns[Mode] or 0
	end

	Cooldowns[Mode] = Cooldowns[Mode] or {}
	return Cooldowns[Mode][Number] or 0
end

local function SetCooldown(Mode,Number,Timestamp)
	local Configuration = Config[Mode]
	if Configuration.Scope == "global" then
		Last[Mode] = Number
		Cooldowns[Mode] = Timestamp
		return
	end

	Cooldowns[Mode] = Cooldowns[Mode] or {}
	Cooldowns[Mode][Number] = Timestamp
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:ROBBERYACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:RobberyActive",function(Mode,Number)
	local Configuration = Config[Mode]
	if Configuration then
		if Configuration.Scope ~= "global" or Last[Mode] == Number then
			SetCooldown(Mode,Number,os.time())
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:ROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Robbery")
AddEventHandler("inventory:Robbery",function(Number,Mode)
	local source = source
	Number = Framework.parseInt(Number,true)
	local Configuration = Config[Mode]
	local Point = Points[Number]
	local Passport = Framework.Passport(source)

	if not Passport or Active[Passport] or not Configuration or not Point or Point.Mode ~= Mode then
		return false
	end

	local Coords = Framework.GetEntityCoords(source)
	if not Coords or #(Coords - Point.Coords) > Target.ServerDistance then
		return false
	end

	if Configuration.Police and Framework.AmountService(Settings.Police.Permission) < Configuration.Police then
		TriggerClientEvent("Notify",source,"Atenção","Contingente indisponível.","amarelo",5000)
		return false
	end

	local RequiredItem = true
	if Configuration.Need then
		RequiredItem = Framework.ConsultItem(Passport,Configuration.Need.Item,Configuration.Need.Amount)
		if not RequiredItem then
			TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>"..Configuration.Need.Amount.."x "..Framework.ItemName(Configuration.Need.Item).."</b>.","amarelo",5000)
			return false
		end
	end

	local CurrentTimer = os.time()
	local CurrentCooldown = Cooldown(Mode,Number)
	if CurrentTimer < CurrentCooldown then
		local Remaining = CurrentCooldown - CurrentTimer
		if not Configuration.Explosion and Remaining >= ((Configuration.Delay or Settings.DefaultDelay) - Settings.ReuseWindow) and (Configuration.Scope ~= "global" or (Last[Mode] or 1) == Number) then
			TriggerClientEvent("chest:Open",source,Mode..":"..Number,"Custom",false,true)
		else
			TriggerClientEvent("Notify",source,"Atenção","Aguarde "..Framework.CompleteTimers(Remaining)..".","amarelo",5000)
		end

		return false
	else
		SetCooldown(Mode,Number,os.time() + (Configuration.Delay or Settings.DefaultDelay))
	end

	Player(source).state.Buttons = true
	Robberys[Passport] = { Mode = Mode, Number = Number }
	Active[Passport] = CurrentTimer + (Configuration.Timer or Settings.DefaultTimer)
	TriggerClientEvent("Progress",source,"Roubando",(Configuration.Timer or Settings.DefaultTimer) * 1000)
	TriggerClientEvent("player:Residual",source,Configuration.Residual or Settings.DefaultResidual)

	if Configuration.Explosion then
		Framework.Client.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

		SetTimeout(5000,function()
			Framework.Client.Destroy(source)
		end)
	elseif Configuration.Animation then
		Framework.Client.playAnim(source,false,{Configuration.Animation.Dict,Configuration.Animation.Name},true)
	end

	Framework.CallPolice({
		Source = source,
		Passport = Passport,
		Permission = Settings.Police.Permission,
		Name = Configuration.Name,
		Percentage = Configuration.Percentage,
		Wanted = Configuration.Wanted or Settings.DefaultWanted,
		Code = Settings.Police.Code,
		Color = Settings.Police.Color
	})

	CreateThread(function()
		while Active[Passport] and os.time() < Active[Passport] do
			Wait(100)
		end

		Framework.Client.Destroy(source)
		Robberys[Passport] = nil
		Player(source).state.Buttons = false

		if Active[Passport] then
			Active[Passport] = nil

			if (not Configuration.Need) or (RequiredItem and (not Configuration.Need.Consume or Framework.TakeItem(Passport,RequiredItem.Item,Configuration.Need.Amount))) then
				local Valuation = math.random(Configuration.Payment.Money.Min,Configuration.Payment.Money.Max)

				if Framework.PartyExists(Passport,Settings.PartySize) then
					Valuation = Valuation * Settings.PartyMultiplier
				end

				if Framework.InventoryBuff(Settings.Buff,Passport) then
					Valuation = Valuation * Settings.BuffMultiplier
				end

				for Permission,Multiplier in pairs(Settings.Membership) do
					if Framework.HasService(Passport,Permission) then
						Valuation = Valuation * (1 + Multiplier)
					end
				end

				if Configuration.Explosion then
					for _,v in pairs(Framework.Client.Players(source)) do
						Framework.async(function()
							TriggerClientEvent("inventory:Explosion",v,Point.Coords)
						end)
					end

					Framework.InventoryDrops(Passport,source,Configuration.Payment.Money.Item,Valuation,false,Point.Coords)
				else
					local Multiplier = math.random(Configuration.Payment.Multiplier.Min,Configuration.Payment.Multiplier.Max)
					if Framework.MountContainer(Passport,Mode..":"..Number,Configuration.Payment.List,Multiplier,false,false,{ Item = Configuration.Payment.Money.Item, Amount = Valuation }) then
						TriggerClientEvent("chest:Open",source,Mode..":"..Number,"Custom",false,true)
					end
				end
			end
		end
	end)
end)
