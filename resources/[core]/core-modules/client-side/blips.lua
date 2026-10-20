local blipsOnMap = {
	-----------------------------------------------------------------------------------------------------------------------------------------
	-- GERAL (todos os blips públicos)
	-----------------------------------------------------------------------------------------------------------------------------------------
	['GERAL'] = {
		perm = nil,
		markerUnico = false,
		marker = {
			Sprite = 1,
			Colour = 0,
			Scale = 0.5
		},
		Blip = {
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ MECÂNICAS ]=---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = "Benny's Motorworks", coord = vec3(-236.80, -1339.78, 31.94), Sprite = 402, Colour = 64, Scale = 0.7, cat = 16 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ POLÍCIA ]=-----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Polícia Militar', coord = vec3(2545.69, -284.57, 93.32), Sprite = 60, Colour = 18, Scale = 0.6, cat = 15 },
			{ Name = 'Polícia Civil', coord = vec3(-995.16, -2007.55, 13.54), Sprite = 60, Colour = 18, Scale = 0.6, cat = 15 },
			{ Name = 'BOPE', coord = vec3(-1663.63, 171.04, 61.95), Sprite = 60, Colour = 18, Scale = 0.6, cat = 15 },
			-- CORE / PRF: sem blip por enquanto

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ SAÚDE ]=-------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Hospital Norte', coord = vec3(1763.99, 3619.4, 34.71), Sprite = 80, Colour = 1, Scale = 0.6 },
			{ Name = 'Hospital Sul', coord = vec3(-1040.86, -403.78, 38.7), Sprite = 80, Colour = 1, Scale = 0.6 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ RESTAURANTES / COMÉRCIOS ]=----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Soda POP', coord = vec3(-1380.88, -1394.78, 5.64), Sprite = 607, Colour = 5, Scale = 0.6, cat = 18 },
			{ Name = 'Moo Moo Cafe', coord = vec3(-578.76, -1074.13, 22.33), Sprite = 607, Colour = 5, Scale = 0.6, cat = 18 },
			{ Name = 'Sushi Osaka', coord = vec3(-775.62, -138.11, 37.79), Sprite = 607, Colour = 5, Scale = 0.6, cat = 18 },
			{ Name = 'Marina Lounge', coord = vec3(1535.66, 3770.79, 34.05), Sprite = 607, Colour = 5, Scale = 0.6, cat = 18 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ SERVIÇOS ]=----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Concessionária', coord = vec3(-803.96, -224.58, 37.22), Sprite = 225, Colour = 46, Scale = 0.6 },
			{ Name = 'Imobiliaria', coord = vec3(-869.76, -198.3, 37.83), Sprite = 492, Colour = 3, Scale = 0.6 },
			{ Name = 'Hotel', coord = vec3(-772.73, 312.74, 85.7), Sprite = 475, Colour = 26, Scale = 0.6 },
			{ Name = 'Mercado Central', coord = vec3(456.39, -2059.37, 23.93), Sprite = 78, Colour = 62, Scale = 0.5 },
			{ Name = 'Aviação', coord = vec3(-1896.42, -3032.01, 13.93), Sprite = 43, Colour = 62, Scale = 0.7 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ TATUAGENS ]=---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Loja de Tatuagem', coord = vec3(1327.98, -1654.78, 52.03), Sprite = 75, Colour = 13, Scale = 0.5 },
			{ Name = 'Loja de Tatuagem', coord = vec3(-1149.04, -1428.64, 4.71), Sprite = 75, Colour = 13, Scale = 0.5 },
			{ Name = 'Loja de Tatuagem', coord = vec3(322.01, 186.24, 103.34), Sprite = 75, Colour = 13, Scale = 0.5 },
			{ Name = 'Loja de Tatuagem', coord = vec3(-3175.64, 1075.54, 20.58), Sprite = 75, Colour = 13, Scale = 0.5 },
			{ Name = 'Loja de Tatuagem', coord = vec3(1866.01, 3748.07, 32.79), Sprite = 75, Colour = 13, Scale = 0.5 },
			{ Name = 'Loja de Tatuagem', coord = vec3(-295.51, 6199.21, 31.24), Sprite = 75, Colour = 13, Scale = 0.5 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ LOJA DE DEPARTAMENTO ]=----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Loja de Departamento', coord = vec3(29.2, -1351.89, 29.34), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(2561.74, 385.22, 108.61), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1160.21, -329.4, 69.03), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-711.99, -919.96, 19.01), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-54.56, -1758.56, 29.05), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(375.87, 320.04, 103.42), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-3237.48, 1004.72, 12.45), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1730.64, 6409.67, 35.0), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(543.51, 2676.85, 42.14), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1966.53, 3737.95, 32.18), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(2684.73, 3281.2, 55.23), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1696.12, 4931.56, 42.07), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-1820.18, 785.69, 137.98), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1395.35, 3596.6, 34.86), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-2977.14, 391.22, 15.03), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-3034.99, 590.77, 7.8), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1144.46, -980.74, 46.19), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(1166.06, 2698.17, 37.95), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-1493.12, -385.55, 39.87), Sprite = 52, Colour = 36, Scale = 0.5 },
			{ Name = 'Loja de Departamento', coord = vec3(-1228.6, -899.7, 12.27), Sprite = 52, Colour = 36, Scale = 0.5 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ LOJA DE ARMAS ]=-----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Loja de Armas', coord = vec3(1692.27, 3760.91, 34.69), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(253.8, -50.47, 69.94), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(842.54, -1035.25, 28.19), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(-331.67, 6084.86, 31.46), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(-662.37, -933.58, 21.82), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(-1304.12, -394.56, 36.7), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(-1118.98, 2699.73, 18.55), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(2567.98, 292.62, 108.73), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(-3173.51, 1088.35, 20.84), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(22.53, -1105.52, 29.79), Sprite = 76, Colour = 6, Scale = 0.4 },
			{ Name = 'Loja de Armas', coord = vec3(810.22, -2158.99, 29.62), Sprite = 76, Colour = 6, Scale = 0.4 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ BANCOS ]=------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Banco', coord = vec3(149.64, -1041.36, 29.59), Sprite = 108, Colour = 25, Scale = 0.7 },
			{ Name = 'Banco', coord = vec3(313.95, -279.74, 54.39), Sprite = 108, Colour = 25, Scale = 0.7 },
			{ Name = 'Banco', coord = vec3(-351.2, -50.57, 49.26), Sprite = 108, Colour = 25, Scale = 0.7 },
			{ Name = 'Banco', coord = vec3(-2961.85, 482.87, 15.92), Sprite = 108, Colour = 25, Scale = 0.7 },
			{ Name = 'Banco', coord = vec3(1175.09, 2707.53, 38.31), Sprite = 108, Colour = 25, Scale = 0.7 },
			{ Name = 'Banco', coord = vec3(-1212.37, -331.37, 38.0), Sprite = 108, Colour = 25, Scale = 0.7 },
			{ Name = 'Banco', coord = vec3(-112.86, 6470.46, 31.85), Sprite = 108, Colour = 25, Scale = 0.7 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ LOJAS DE ROUPAS ]=---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Loja de Roupas', coord = vec3(86.06, -1391.64, 29.23), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-719.94, -158.18, 37.0), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-152.79, -306.79, 38.67), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-816.39, -1081.22, 11.12), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-1206.51, -781.5, 17.12), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-1458.26, -229.79, 49.2), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-2.41, 6518.29, 31.48), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(1682.59, 4819.98, 42.04), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(129.46, -205.18, 54.51), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(618.49, 2745.54, 42.01), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(1197.93, 2698.21, 37.96), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-3165.74, 1061.29, 20.84), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(-1093.76, 2703.99, 19.04), Sprite = 366, Colour = 62, Scale = 0.5 },
			{ Name = 'Loja de Roupas', coord = vec3(414.86, -807.57, 29.34), Sprite = 366, Colour = 62, Scale = 0.5 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ BARBEARIAS ]=--------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Barbearia', coord = vec3(-815.12, -184.15, 37.57), Sprite = 71, Colour = 62, Scale = 0.5 },
			{ Name = 'Barbearia', coord = vec3(139.56, -1704.12, 29.05), Sprite = 71, Colour = 62, Scale = 0.5 },
			{ Name = 'Barbearia', coord = vec3(-1278.11, -1116.66, 6.75), Sprite = 71, Colour = 62, Scale = 0.5 },
			{ Name = 'Barbearia', coord = vec3(1928.89, 3734.04, 32.6), Sprite = 71, Colour = 62, Scale = 0.5 },
			{ Name = 'Barbearia', coord = vec3(1217.05, -473.45, 65.96), Sprite = 71, Colour = 62, Scale = 0.5 },
			{ Name = 'Barbearia', coord = vec3(-34.08, -157.01, 56.83), Sprite = 71, Colour = 62, Scale = 0.5 },
			{ Name = 'Barbearia', coord = vec3(-274.5, 6225.27, 31.45), Sprite = 71, Colour = 62, Scale = 0.5 },

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------=[ PONTOS TURÍSTICOS ]=-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			{ Name = 'Luma Beach Club', coord = vec3(-1261.04, -1698.25, 4.47), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Oasis Bungallows', coord = vec3(-3093.17, 551.87, 2.36), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Cavo Beach Club', coord = vec3(-3225.65, 1208.42, 3.42), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Riverside Serenity', coord = vec3(-654.02, 4379.21, 34.27), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Casamento Paleto', coord = vec3(35.93, 6983.1, 8.63), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Cine Beach', coord = vec3(1526.75, 6597.53, 3.34), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Casas na Árvore', coord = vec3(2552.11, 6170.62, 164.12), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Macumba', coord = vec3(3922.73, 4390.34, 16.45), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Cabanas', coord = vec3(3843.97, 3243.57, 2.53), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Festa na Gruta', coord = vec3(3085.18, 2129.58, 2.04), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Luau Aloha', coord = vec3(2898.53, 333.21, 2.59), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Chá Revelação', coord = vec3(-332.25, 212.29, 87.91), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Acampamento', coord = vec3(968.79, 4415.15, 47.15), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Aqua Paradise', coord = vec3(-2651.77, -765.98, 5.05), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
			{ Name = 'Chalets', coord = vec3(-1577.72, 2101.94, 68.11), Sprite = 304, Colour = 0, Scale = 0.6, cat = 17 },
		}
	},
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CATEGORIAS DO MAPA
-----------------------------------------------------------------------------------------------------------------------------------------
AddTextEntry("BLIP_CAT_14", "Mansões")
AddTextEntry("BLIP_CAT_15", "Polícia")
AddTextEntry("BLIP_CAT_16", "Mecânicas")
AddTextEntry("BLIP_CAT_17", "Turistico")
AddTextEntry("BLIP_CAT_18", "Restaurantes")
AddTextEntry("BLIP_CAT_20", "Boates")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CRIAÇÃO DOS BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Wait(5000)
	for _, k in pairs(blipsOnMap) do
		for _, blipData in ipairs(k.Blip) do
			local blip = AddBlipForCoord(blipData.coord.x, blipData.coord.y, blipData.coord.z)
			if k.markerUnico then
				SetBlipSprite(blip, k.marker.Sprite)
				SetBlipScale(blip, k.marker.Scale)
				SetBlipColour(blip, k.marker.Colour)
			else
				SetBlipSprite(blip, blipData.Sprite)
				SetBlipScale(blip, blipData.Scale)
				SetBlipColour(blip, blipData.Colour)
			end
			SetBlipAlpha(blip, blipData.Alpha or (k.marker.Alpha or 255))
			SetBlipDisplay(blip, 4)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(blipData.Name)
			EndTextCommandSetBlipName(blip)
			if blipData.cat then
				SetBlipCategory(blip, blipData.cat)
			end
			Wait(2)
		end
	end
end)
