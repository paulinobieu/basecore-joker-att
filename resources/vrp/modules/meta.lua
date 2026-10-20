-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
ItemMeta = {}

local HandMade = {
	["vehiclekey"] = { "created", "hash" },
	["propertys"] = { "hash" }
}

local Renamed = {
	["backpackp"] = "backpackm",
	["backpackg"] = "backpackm",
	["teddypack"] = "backpackm",
	["illegalbackpack"] = "backpackm"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMPTY
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Empty(Meta)
	if type(Meta) ~= "table" then
		return true
	end

	return next(Meta) == nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLONE
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Clone(Meta)
	if type(Meta) ~= "table" then
		return nil
	end

	local Copy = {}
	for Key,Value in pairs(Meta) do
		if type(Value) == "table" then
			local Inner = {}
			for InnerKey,InnerValue in pairs(Value) do
				Inner[InnerKey] = InnerValue
			end

			Copy[Key] = Inner
		else
			Copy[Key] = Value
		end
	end

	return next(Copy) ~= nil and Copy or nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EQUAL
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Equal(First,Second)
	if First == Second then
		return true
	end

	if type(First) ~= "table" or type(Second) ~= "table" then
		return false
	end

	for Key,Value in pairs(First) do
		if not ItemMeta.Equal(Value,Second[Key]) then
			return false
		end
	end

	for Key in pairs(Second) do
		if First[Key] == nil then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STACKABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Stackable(Item,Meta,OtherItem,OtherMeta)
	if Item ~= OtherItem then
		return false
	end

	return ItemMeta.Empty(Meta) and ItemMeta.Empty(OtherMeta)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARSE
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Parse(Item)
	if type(Item) ~= "string" or Item == "" then
		return Item,nil
	end

	local Split = splitString(Item)
	local Name = Split[1]

	if not Split[2] then
		return Name,nil
	end

	local Meta = {}
	local Shape = HandMade[Name]

	if Shape then
		for Index,Field in ipairs(Shape) do
			local Value = Split[Index + 1]
			if Value then
				Meta[Field] = tonumber(Value) or Value
			end
		end
	elseif exports.vrp:ItemUnique(Name) then
		Meta.created = tonumber(Split[2])
		Meta.hash = Split[3]
	elseif exports.vrp:ItemDurability(Name) then
		Meta.created = tonumber(Split[2])

		if exports.vrp:ItemTypeCheck(Name,"Armamento") then
			Meta.repair = tonumber(Split[3])
			Meta.owner = tonumber(Split[4])
		end
	elseif exports.vrp:ItemLoads(Name) then
		Meta.charges = tonumber(Split[2])
	elseif exports.vrp:ItemNamed(Name) then
		Meta.owner = tonumber(Split[2]) or Split[2]
	else
		Meta.legacy = Item:sub(#Name + 2)
	end

	return Name,(next(Meta) ~= nil and Meta or nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOLVE
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Resolve(Item,Meta)
	if Meta ~= nil then
		return SplitOne(Item),Meta
	end

	return ItemMeta.Parse(Item)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LEGACY
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Legacy(Item,Meta)
	if ItemMeta.Empty(Meta) then
		return Item
	end

	if Meta.legacy then
		return Item.."-"..Meta.legacy
	end

	local Shape = HandMade[Item]
	if Shape then
		local Parts = { Item }

		for _,Field in ipairs(Shape) do
			if Meta[Field] == nil then
				break
			end

			Parts[#Parts + 1] = tostring(Meta[Field])
		end

		return table.concat(Parts,"-")
	end

	if Meta.created and Meta.hash then
		return Item.."-"..Meta.created.."-"..Meta.hash
	end

	if Meta.created and Meta.repair then
		return Item.."-"..Meta.created.."-"..Meta.repair..(Meta.owner and "-"..Meta.owner or "")
	end

	if Meta.created then
		return Item.."-"..Meta.created
	end

	if Meta.charges then
		return Item.."-"..Meta.charges
	end

	if Meta.owner then
		return Item.."-"..Meta.owner
	end

	return Item
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NORMALIZE
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.Normalize(Entry)
	if type(Entry) ~= "table" or type(Entry.item) ~= "string" then
		return Entry
	end

	if Entry.meta == nil and Entry.item:find("-",1,true) then
		local Name,Meta = ItemMeta.Parse(Entry.item)

		Entry.item = Name
		Entry.meta = Meta
	end

	local Rename = Renamed[Entry.item]
	if Rename then
		Entry.item = Rename
		Entry.meta = nil
	end

	return Entry
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NORMALIZEINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function ItemMeta.NormalizeInventory(Inventory)
	if type(Inventory) ~= "table" then
		return Inventory
	end

	for _,Entry in pairs(Inventory) do
		ItemMeta.Normalize(Entry)
	end

	return Inventory
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("ItemMetaParse",ItemMeta.Parse)
exports("ItemMetaLegacy",ItemMeta.Legacy)
exports("ItemMetaStackable",ItemMeta.Stackable)
exports("ItemMetaClone",ItemMeta.Clone)
