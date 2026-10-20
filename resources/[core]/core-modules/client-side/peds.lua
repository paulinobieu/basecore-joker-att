-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Spawned = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIST
-----------------------------------------------------------------------------------------------------------------------------------------
local List = {
	{ -- Compra Pública Benny's Motorworks
		Distance = 25,
		Coords = vec4(-228.61,-1408.65,31.29,184.26),
		Model = "s_m_y_xmech_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Compra Privada Benny's Motorworks
		Distance = 25,
		Coords = vec4(-194.38,-1316.90,31.98,82.21),
		Model = "s_m_y_xmech_02",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Farmácia Pública Hospital Norte
		Distance = 25,
		Coords = vec4(1748.71,3622.87,34.58,303.31),
		Model = "u_m_y_baygor",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Farmácia Pública Hospital Sul
		Distance = 25,
		Coords = vec4(-1009.55,-428.99,39.61,28.35),
		Model = "u_m_y_baygor",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Lanchonete Hospital Norte
		Distance = 25,
		Coords = vec4(1732.44,3636.69,34.58,300.48),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Lanchonete Hospital Sul
		Distance = 25,
		Coords = vec4(-1028.09,-438.51,42.66,28.35),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Lanchonete Polícia Militar
		Distance = 25,
		Coords = vec4(2514.26,-307.84,97.85,2.84),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Lanchonete Polícia Civil
		Distance = 25,
		Coords = vec4(-974.26,-2005.95,13.31,127.56),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Lanchonete BOPE
		Distance = 25,
		Coords = vec4(-1583.34,200.25,59.31,22.68),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Jobs Agency
	Distance = 50,
	Coords = vec4(-268.97,-956.1,31.22,209.77),
	Model = "ig_bankman",
	Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Banned
		Distance = 100,
		Route = 9999998,
		Coords = vec4(-1674.58,-3174.77,13.99,331.66),
		Model = "a_m_m_bevhills_02",
		Collision = true
	},{ -- Essence
		Distance = 50,
		Coords = vec4(87.62,-1670.45,29.18,73.71),
		Model = "a_f_y_vinewood_01",
		Collision = true
	},{ -- Cow
		Distance = 50,
		Coords = vec4(957.99,-2207.26,30.6,266.46),
		Model = "a_c_cow",
		Collision = true
	},{ -- Cow
		Distance = 50,
		Coords = vec4(956.66,-2220.51,30.58,266.46),
		Model = "a_c_cow",
		Collision = true
	},{ -- Cow
		Distance = 50,
		Coords = vec4(955.6,-2233.52,30.58,266.46),
		Model = "a_c_cow",
		Collision = true
	},{ -- Cow
		Distance = 50,
		Coords = vec4(954.49,-2247.07,30.58,266.46),
		Model = "a_c_cow",
		Collision = true
	},{ -- Desmanche
		Distance = 100,
		Coords = vec4(778.49,-395.89,33.43,99.22),
		Model = "g_m_y_salvagoon_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Hotel
		Distance = 50,
		Coords = vec4(-772.76,312.81,85.7,181.42),
		Model = "s_m_y_doorman_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Megamall
		Distance = 50,
		Coords = vec4(456.39,-2059.37,23.93,277.8),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Clandestine
		Distance = 50,
		Coords = vec4(179.9,2779.98,45.7,189.93),
		Model = "csb_paige",
		Anim = { "amb@lo_res_idles@","world_human_lean_male_foot_up_lo_res_base" }
	},{ -- MoneyWash
		Distance = 50,
		Coords = vec4(68.93,-1569.81,29.59,48.19),
		Model = "a_m_m_soucent_03",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Helicopters
		Distance = 100,
		Coords = vec4(-1896.42,-3032.01,13.93,243.78),
		Model = "g_m_y_korlieut_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Cemitery
		Distance = 100,
		Coords = vec4(-1741.52,-219.85,56.14,255.12),
		Model = "g_m_m_armboss_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(24.51,-1346.75,29.49,272.13),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(2556.77,380.87,108.61,0.0),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1164.81,-323.61,69.2,99.22),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-706.16,-914.55,19.21,87.88),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-47.35,-1758.59,29.42,45.36),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(372.7,326.89,103.56,255.12),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-3242.7,1000.05,12.82,357.17),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1728.08,6415.6,35.03,243.78),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(549.09,2670.89,42.16,93.55),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1959.87,3740.44,32.33,300.48),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(2677.65,3279.66,55.23,331.66),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1697.32,4923.46,42.06,323.15),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-1819.52,793.48,138.08,130.4),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1391.62,3605.95,34.98,198.43),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-2966.41,391.52,15.05,82.21),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-3039.42,584.42,7.9,14.18),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1134.32,-983.09,46.4,277.8),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(1165.32,2710.79,38.15,175.75),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-1486.72,-377.61,40.15,130.4),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Departament Store
		Distance = 15,
		Coords = vec4(-1221.48,-907.93,12.32,31.19),
		Model = "mp_m_shopkeep_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(1692.27,3760.91,34.69,226.78),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(253.8,-50.47,69.94,65.2),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(842.54,-1035.25,28.19,0.0),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(-331.67,6084.86,31.46,223.94),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(-662.37,-933.58,21.82,181.42),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(-1304.12,-394.56,36.7,73.71),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(-1118.98,2699.73,18.55,221.11),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(2567.98,292.62,108.73,0.0),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(-3173.51,1088.35,20.84,246.62),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(22.53,-1105.52,29.79,155.91),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Ammu-Nation Store
		Distance = 15,
		Coords = vec4(810.22,-2158.99,29.62,0.0),
		Model = "ig_dale",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Jewelry
		Distance = 15,
		Coords = vec4(-628.79,-238.7,38.05,311.82),
		Model = "cs_gurk",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Lenhador
		Distance = 50,
		Coords = vec4(1961.61,5179.26,47.94,277.8),
		Model = "a_m_o_ktown_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Caçador
		Distance = 10,
		Coords = vec4(-679.14,5834.37,17.32,127.56),
		Model = "ig_hunter",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Caçador
		Distance = 50,
		Coords = vec4(-1593.08,5202.9,4.31,297.64),
		Model = "a_m_o_ktown_01",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Pescador
		Distance = 30,
		Coords = vec4(-1816.64,-1193.73,14.31,334.49),
		Model = "a_f_y_eastsa_03",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	},{ -- Dismantle
		Distance = 25,
		Coords = vec4(2340.7,3126.49,48.21,351.5),
		Model = "a_m_m_soucent_03",
		Anim = { "anim@heists@heist_corona@single_team","single_team_loop_boss" }
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADLIST
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		for Number = 1,#List do
			local Distance = #(Coords - List[Number].Coords.xyz)
			if Distance <= List[Number].Distance and (not List[Number].Route or List[Number].Route == LocalPlayer.state.Route) then
				if not Spawned[Number] and LoadModel(List[Number].Model) then
					Spawned[Number] = CreatePed(26,List[Number].Model,List[Number].Coords.x,List[Number].Coords.y,List[Number].Coords.z - 1,List[Number].Coords.w,false,false)

					SetEntityInvincible(Spawned[Number],true)
					FreezeEntityPosition(Spawned[Number],true)
					DecorSetBool(Spawned[Number],"CREATIVE_PED",true)
					SetEntityAsMissionEntity(Spawned[Number],true,true)
					SetBlockingOfNonTemporaryEvents(Spawned[Number],true)

					if not List[Number].Collision then
						SetEntityNoCollisionEntity(Spawned[Number],Ped,false)
					end

					if List[Number].Anim and LoadAnim(List[Number].Anim[1]) then
						TaskPlayAnim(Spawned[Number],List[Number].Anim[1],List[Number].Anim[2],8.0,8.0,-1,1,0,0,0,0)
					end
				end
			else
				if Spawned[Number] then
					if DoesEntityExist(Spawned[Number]) then
						DeleteEntity(Spawned[Number])
					end

					Spawned[Number] = nil
				end
			end
		end

		Wait(1000)
	end
end)