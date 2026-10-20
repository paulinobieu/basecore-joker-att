-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-arsenal", Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResolveTemplate(Name)
	local Location = Arsenal.Locations[Name]
	if not Location then
		return nil
	end

	return Arsenal.Templates[Location.template or Name], Location
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckPermission(Name)
	local source = source
	local Passport = Functions.Passport(source)
	if not Passport then
		return false
	end

	local Location = Arsenal.Locations[Name]
	if not Location then
		return false
	end

	if not Location.permission then
		return true
	end

	return Functions.HasPermission(Passport, Location.permission)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETARSENALDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.GetArsenalData(Name)
	local Template = ResolveTemplate(Name)
	if not Template then
		return {}
	end

	local Result = {}
	local Processed = {}

	local function ProcessCategory(Category)
		if Processed[Category] then
			return
		end
		Processed[Category] = true

		local List = Template[Category]
		if not List then
			return
		end

		local Items = {}
		for _, Entry in ipairs(List) do
			if Entry.item then
				local Key = Entry.item
				local Display = ItemName(Key) or Key
				local Index = ItemIndex(Key) or Key
				local Price = Entry.price or 0

				Items[#Items + 1] = {
					id = Key,
					key = Key,
					item = Display,
					name = Display,
					label = Display,
					price = Price,
					value = Price,
					perms = Entry.permission,
					index = Index,
					icon = Index,
					image = (Arsenal.ImagesUrl or "") .. Index .. ".png",
				}
			end
		end

		if #Items > 0 then
			Result[#Result + 1] = {
				name = Category,
				label = Category,
				category = Category,
				items = Items,
			}
		end
	end

	for _, Category in ipairs(Arsenal.CategoryOrder or {}) do
		ProcessCategory(Category)
	end

	for Category in pairs(Template) do
		ProcessCategory(Category)
	end

	return Result
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSPURCHASE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ProcessPurchase(Name, Items)
	local source = source
	local Passport = Functions.Passport(source)
	if not Passport then
		return false, "Usuário não encontrado."
	end

	local Template, Location = ResolveTemplate(Name)
	if not Template then
		return false, "Arsenal não encontrado."
	end

	if Location.permission and not Functions.HasPermission(Passport, Location.permission) then
		return false, "Você não tem permissão para acessar este arsenal."
	end

	if type(Items) ~= "table" or #Items == 0 then
		return false, "Carrinho vazio."
	end

	local InfoMap = {}
	for _, List in pairs(Template) do
		for _, Entry in ipairs(List) do
			InfoMap[Entry.item] = Entry
		end
	end

	local Aggregated = {}
	local Total = 0

	for _, Entry in ipairs(Items) do
		local Key = Entry.item or Entry.key or Entry.id
		local Info = Key and InfoMap[Key]
		if not Info then
			return false, "Item não permitido neste arsenal."
		end

		if Info.permission and not Functions.HasPermission(Passport, Info.permission) then
			return false, "Você não tem permissão para o item: " .. (ItemName(Key) or Key)
		end

		local Amount = math.floor(tonumber(Entry.amount) or tonumber(Entry.quantity) or 1)
		if Amount <= 0 then
			return false, "Quantidade inválida."
		end

		Total = Total + ((Info.price or 0) * Amount)
		Aggregated[Key] = (Aggregated[Key] or 0) + Amount
	end

	if Total <= 0 then
		return false, "Valor inválido."
	end

	if not Functions.TryPayment(Passport, Total) then
		return false, "Dinheiro insuficiente."
	end

	for Key, Amount in pairs(Aggregated) do
		Functions.GenerateItem(Passport, Key, Amount)
	end

	TriggerClientEvent("sounds:Private", source, "cash", 0.1)

	return true, "Compra realizada com sucesso!"
end
