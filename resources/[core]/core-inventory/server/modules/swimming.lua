-----------------------------------------------------------------------------------------------------------------------------------------
-- SWIMMING
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Swimming()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport then
		local Inventory = Framework.Inventory(Passport)
		for Slot,v in pairs(Inventory) do
			local Name = Framework.ItemLostWater(v["item"])
			if Name and Framework.TakeItem(Passport,v["item"],v["amount"],false,Slot) and type(Name) == "string" then
				Framework.GenerateItem(Passport,Name,v["amount"])
			end
		end
	end
end
