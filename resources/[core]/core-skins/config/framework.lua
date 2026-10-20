-------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-------------------------------------------------------------------------------------------------------------------------------------
-- Carrega o Tunnel e o Proxy do vRP e pega acesso ao objeto vRP. Se seu framework usa outro
-- nome de resource (não "vrp") ou outro sistema de comunicação, troque essas 3 linhas aqui.
Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK
-------------------------------------------------------------------------------------------------------------------------------------
-- Camada de adaptação. É o ÚNICO arquivo que fala com o vRP direto. O client/core.lua e o
-- server/core.lua só chamam framework.xxx(), nunca vRP.xxx(). Pra adaptar o core-skins a
-- outro framework, basta reescrever o corpo das funções abaixo mantendo o mesmo nome, os
-- mesmos parâmetros e o mesmo tipo de retorno.
framework = {}
-------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORT
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o source do jogador e devolve o identificador único do personagem (user_id,
-- character id, etc). Quase todas as outras funções do server usam esse retorno.
function framework.passport(source)
	return vRP.Passport(source)
end
-------------------------------------------------------------------------------------------------------------------------------------
-- SOURCE
-------------------------------------------------------------------------------------------------------------------------------------
-- O inverso do passport: recebe o passport e devolve o source (id de rede) do jogador,
-- se ele estiver online. Usado pra enviar eventos/notificações pro jogador certo.
function framework.source(passport)
	return vRP.Source(passport)
end
-------------------------------------------------------------------------------------------------------------------------------------
-- IDENTITY
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o passport e devolve a identidade (dados civis) do personagem, ou false. Usado
-- pra montar o nome do jogador no ranking e nas trocas. Os campos Name, Lastname e License
-- vêm do vRP; se seu framework nomeia diferente, ajuste quem lê esses campos.
function framework.identity(passport)
	return vRP.Identity(passport) or false
end
-------------------------------------------------------------------------------------------------------------------------------------
-- HASPERMISSION
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o passport e uma permissão, e devolve true se o jogador tem. A permissão pode ser:
-- uma lista (basta ter uma delas), um texto no formato "grupo@nível" (ex: "Admin@1"), ou
-- só o nome de uma permissão/grupo. Usado pra liberar o comando e as ações de admin.
function framework.hasPermission(passport,permission)
	if not passport then
		return false
	end

	if not permission then
		return true
	end

	if type(permission) == "table" then
		return vRP.HasTable(passport,permission) and true or false
	end

	local group,level = permission:match("^(.+)@(%d+)$")
	if group then
		return vRP.HasGroup(passport,group,tonumber(level)) and true or false
	end

	return (vRP.HasPermission(passport,permission) or vRP.HasGroup(passport,permission,1)) and true or false
end
-------------------------------------------------------------------------------------------------------------------------------------
-- AVATAR
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o passport e devolve a URL do avatar do jogador (foto do Instagram in-game), ou ""
-- se não tiver. É uma integração opcional com a tabela smartphone_instagram; se seu servidor
-- não tem esse sistema, pode simplesmente retornar "" aqui.
function framework.avatar(passport)
	passport = tonumber(passport)
	if not passport or not IsDuplicityVersion() then return "" end

	local ok,rows = pcall(function()
		if MySQL and MySQL.query and MySQL.query.await then
			return MySQL.query.await("SELECT avatarURL FROM smartphone_instagram WHERE user_id = ? LIMIT 1",{ passport })
		end
		return exports.oxmysql:query_async("SELECT avatarURL FROM smartphone_instagram WHERE user_id = ? LIMIT 1",{ passport })
	end)

	if ok and type(rows) == "table" and rows[1] and type(rows[1].avatarURL) == "string" then
		return rows[1].avatarURL
	end

	return ""
end
-------------------------------------------------------------------------------------------------------------------------------------
-- DATABASEREADY
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe uma função e a executa assim que o banco de dados estiver pronto. Usado no boot do
-- server pra criar as tabelas do core-skins só depois que o MySQL subiu.
function framework.databaseReady(callback)
	if MySQL and MySQL.ready then
		return MySQL.ready(callback)
	end
	CreateThread(callback)
end
-------------------------------------------------------------------------------------------------------------------------------------
-- QUERY
-------------------------------------------------------------------------------------------------------------------------------------
-- Executa uma query SQL (com parâmetros opcionais) e devolve o resultado. É a ponte com o
-- oxmysql; usada em todo acesso ao banco (skins possuídas, histórico de trocas, ranking...).
function framework.query(sql,params)
	params = params or {}

	if MySQL and MySQL.query and MySQL.query.await then
		return MySQL.query.await(sql,params)
	end

	return exports.oxmysql:query_async(sql,params)
end
-------------------------------------------------------------------------------------------------------------------------------------
-- USERDATA
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o passport e uma chave, e devolve o dado persistente salvo nela. Usado pra ler
-- saldo de SkinsCoins, vouchers e o controle de caixas diárias do jogador.
function framework.userData(passport,key)
	return vRP.UserData(passport,key)
end
-------------------------------------------------------------------------------------------------------------------------------------
-- SETUSERDATA
-------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o passport, uma chave e um valor, e grava esse dado de forma persistente. Par do
-- userData acima (grava o que aquele lê). O valor é serializado em JSON antes de salvar.
function framework.setUserData(passport,key,value)
	vRP.Query("playerdata/SetData",{
		Passport = passport,
		Name = key,
		Information = json.encode(value),
	})
end
-------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORKCOINS
-------------------------------------------------------------------------------------------------------------------------------------
-- Integração opcional com a "moeda premium" do framework (gemstone do vRP). Só é usada se
-- globalConfig.useFrameworkCoins estiver true; nesse caso o core-skins usa essa moeda no
-- lugar do SkinsCoins interno. Adapte as 4 funções abaixo pra moeda premium do seu servidor.
framework.frameworkCoins = {}

-- Devolve quantas moedas o jogador (passport) tem.
function framework.frameworkCoins.get(passport)
	local identity = vRP.Identity(passport)
	if not identity then return 0 end
	return tonumber(vRP.UserGemstone(identity.License)) or 0
end

-- Adiciona amount moedas ao jogador. Devolve true se deu certo.
function framework.frameworkCoins.give(passport,amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	vRP.UpgradeGemstone(passport,amount)
	return true
end

-- Remove amount moedas do jogador. Devolve true se o jogador tinha saldo e o débito ocorreu.
function framework.frameworkCoins.remove(passport,amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	return vRP.PaymentGems(passport,amount) and true or false
end

-- Ajusta o saldo do jogador pra exatamente amount (dá ou tira a diferença conforme o saldo atual).
function framework.frameworkCoins.set(passport,amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount < 0 then return false end

	local current = framework.frameworkCoins.get(passport)
	if amount > current then
		return framework.frameworkCoins.give(passport,amount - current)
	elseif amount < current then
		return framework.frameworkCoins.remove(passport,current - amount)
	end

	return true
end
