-----------------------------------------------------------------------------------------------------------------------------------------
-- RECEITAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cada categoria vira uma aba da interface e é liberada pelo campo Modes das
-- bancadas em stations.lua.
--   Label    → nome da aba na interface
--   List     → receitas da categoria, indexadas pelo item produzido
--     Amount   → unidades produzidas por fabricação
--     Time     → segundos gastos por fabricação
--     Required → materiais consumidos por fabricação { [item] = quantidade }
-----------------------------------------------------------------------------------------------------------------------------------------
-- A interface desenha 8 espaços de ingrediente: receitas com mais que isso são
-- avisadas no console quando o resource sobe.
-----------------------------------------------------------------------------------------------------------------------------------------

Crafting.Recipes = {
    Armas = {
        Label = "Armas",
        List = {
            BOX_WEAPON_PISTOL_MK2 = {
                Amount = 1,
                Time = 30,
                Required = { canopistola = 20, gatilhofarm = 40, molafarm = 40 }
            },
            BOX_WEAPON_SNSPISTOL_MK2 = {
                Amount = 1,
                Time = 30,
                Required = { canopistola = 15, gatilhofarm = 30, molafarm = 30 }
            },
            BOX_WEAPON_MACHINEPISTOL = {
                Amount = 1,
                Time = 30,
                Required = { canosub = 50, gatilhofarm = 100, molafarm = 100 }
            },
            BOX_WEAPON_SMG_MK2 = {
                Amount = 1,
                Time = 30,
                Required = { canosub = 75, gatilhofarm = 150, molafarm = 150 }
            },
            BOX_WEAPON_ASSAULTSMG = {
                Amount = 1,
                Time = 30,
                Required = { canosub = 100, gatilhofarm = 200, molafarm = 200 }
            },
            BOX_WEAPON_COMPACTRIFLE = {
                Amount = 1,
                Time = 30,
                Required = { canofuzil = 150, gatilhofarm = 250, molafarm = 250 }
            },
            BOX_WEAPON_SPECIALCARBINE = {
                Amount = 1,
                Time = 30,
                Required = { canofuzil = 200, gatilhofarm = 300, molafarm = 300 }
            },
            BOX_WEAPON_SPECIALCARBINE_MK2 = {
                Amount = 1,
                Time = 30,
                Required = { canofuzil = 250, gatilhofarm = 350, molafarm = 350 }
            },
        }
    },
    Parafal = {
        Label = "Equipamentos",
        List = {
            BOX_WEAPON_APPISTOL = {
                Amount = 1,
                Time = 5,
                Required = { canopistola = 250, gatilhofarm = 350, molafarm = 350 }
            },
            dollar = {
                Amount = 48000,
                Time = 5,
                Required = { dirtydollar = 50000, washbleach = 10, papelfarm = 10 }
            },
            hood = {
                Amount = 1,
                Time = 5,
                Required = { tarp = 5 }
            },
            rope = {
                Amount = 1,
                Time = 5,
                Required = { tarp = 5 }
            },
            handcuff = {
                Amount = 1,
                Time = 5,
                Required = { carbonofarm = 5, aluminiofarm = 5 }
            },
            blocksignal = {
                Amount = 1,
                Time = 5,
                Required = { carbonofarm = 25, cdfarm = 5, aluminiofarm = 20, techtrash = 5, copper = 10, rubber = 5, plastic = 20 }
            },
            lockpick = {
                Amount = 3,
                Time = 5,
                Required = { plastic = 1, aluminiofarm = 10 }
            },
            lockpickplus = {
                Amount = 3,
                Time = 5,
                Required = { plastic = 1, copper = 15 }
            },
            racestablet = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 30, aluminiofarm = 20, techtrash = 10, copper = 10 }
            },
            plate = {
                Amount = 1,
                Time = 5,
                Required = { aluminiofarm = 15, rubber = 5 }
            },
            nitro = {
                Amount = 1,
                Time = 5,
                Required = { carbonofarm = 50, aluminiofarm = 30, techtrash = 10, rubber = 20, plastic = 20 }
            },
            racesticket = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 5, cdfarm = 1, rubber = 2 }
            },
        }
    },
    Municao = {
        Label = "Munição",
        List = {
            caixapistolammo = {
                Amount = 1,
                Time = 1,
                Required = { polvorafarm = 50, capsula = 50 }
            },
            caixasubammo = {
                Amount = 1,
                Time = 1,
                Required = { polvorafarm = 100, capsulasub = 100 }
            },
            caixarifleammo = {
                Amount = 1,
                Time = 1,
                Required = { polvorafarm = 150, capsulafuzil = 150 }
            },
        }
    },
    LavagemPublica = {
        Label = "Lavagem",
        List = {
            dollar = {
                Amount = 5000,
                Time = 1,
                Required = { dirtydollar = 10000 }
            },
        }
    },
    Lavagem = {
        Label = "Lavagem",
        List = {
            dollar = {
                Amount = 48000,
                Time = 5,
                Required = { dirtydollar = 50000, washbleach = 10, papelfarm = 10 }
            },
            hood = {
                Amount = 1,
                Time = 5,
                Required = { tarp = 5 }
            },
            rope = {
                Amount = 1,
                Time = 5,
                Required = { tarp = 5 }
            },
            handcuff = {
                Amount = 1,
                Time = 5,
                Required = { carbonofarm = 5, aluminiofarm = 5 }
            },
        }
    },
    Ilegal = {
        Label = "Contrabando",
        List = {
            accesscard1 = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 20, microchipfarm = 5 }
            },
            accesscard2 = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 30, microchipfarm = 10, aluminiofarm = 10 }
            },
            accesscard3 = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 40, microchipfarm = 15, aluminiofarm = 20, techtrash = 5 }
            },
            accesscard4 = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 50, microchipfarm = 20, aluminiofarm = 30, techtrash = 10 }
            },
            accesscard5 = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 60, microchipfarm = 25, aluminiofarm = 40, techtrash = 15, carbonofarm = 10 }
            },
            c4 = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 10, microchipfarm = 3 }
            },
            pager = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 15, microchipfarm = 8, techtrash = 5 }
            },
            vest = {
                Amount = 1,
                Time = 5,
                Required = { tarp = 8 }
            },
            backpackm = {
                Amount = 1,
                Time = 5,
                Required = { tarp = 16 }
            },
            balaenergy = {
                Amount = 1,
                Time = 5,
                Required = { sugar = 5 }
            },
            caixabalaenergy = {
                Amount = 1,
                Time = 5,
                Required = { sugar = 50 }
            },
            safependrive = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 50, microchipfarm = 20, aluminiofarm = 30, techtrash = 10 }
            },
        }
    },
    Desmanche = {
        Label = "Desmanche",
        List = {
            blocksignal = {
                Amount = 1,
                Time = 5,
                Required = { carbonofarm = 25, cdfarm = 5, aluminiofarm = 20, techtrash = 5, copper = 10, rubber = 5, plastic = 20 }
            },
            lockpick = {
                Amount = 3,
                Time = 5,
                Required = { plastic = 1, aluminiofarm = 10 }
            },
            lockpickplus = {
                Amount = 3,
                Time = 5,
                Required = { plastic = 1, copper = 15 }
            },
            racestablet = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 30, aluminiofarm = 20, techtrash = 10, copper = 10 }
            },
            plate = {
                Amount = 1,
                Time = 5,
                Required = { aluminiofarm = 15, rubber = 5 }
            },
            nitro = {
                Amount = 1,
                Time = 5,
                Required = { carbonofarm = 50, aluminiofarm = 30, techtrash = 10, rubber = 20, plastic = 20 }
            },
            racesticket = {
                Amount = 1,
                Time = 5,
                Required = { plastic = 5, cdfarm = 1, rubber = 2 }
            },
        }
    },
    FavelaPistola = {
        Label = "Pistolas",
        List = {
            WEAPON_SNSPISTOL_MK2 = {
                Amount = 1,
                Time = 5,
                Required = { canopistola = 10, gatilhofarm = 20, molafarm = 20 }
            },
            WEAPON_PISTOL_MK2 = {
                Amount = 1,
                Time = 5,
                Required = { canopistola = 15, gatilhofarm = 30, molafarm = 30 }
            },
        }
    },
    FavelaMuni = {
        Label = "Munição",
        List = {
            WEAPON_PISTOL_AMMO = {
                Amount = 10,
                Time = 1,
                Required = { polvorafarm = 2, capsula = 2 }
            },
            kitattachs = {
                Amount = 1,
                Time = 5,
                Required = { aluminiofarm = 8 }
            },
        }
    },
    FavelaIlegal1 = {
        Label = "Equipamentos",
        List = {
            handcuff = {
                Amount = 1,
                Time = 0,
                Required = { aluminiofarm = 15, plastic = 1 }
            },
            hood = {
                Amount = 1,
                Time = 0,
                Required = { tarp = 5 }
            },
            pager = {
                Amount = 1,
                Time = 0,
                Required = { aluminiofarm = 30, techtrash = 5 }
            },
            vest = {
                Amount = 1,
                Time = 9,
                Required = { tarp = 8 }
            },
        }
    },
    FavelaIlegal2 = {
        Label = "Cartões",
        List = {
            accesscard1 = {
                Amount = 1,
                Time = 0,
                Required = { techtrash = 50, plastic = 50 }
            },
            accesscard2 = {
                Amount = 1,
                Time = 0,
                Required = { techtrash = 50, plastic = 50 }
            },
            accesscard3 = {
                Amount = 1,
                Time = 0,
                Required = { techtrash = 60, plastic = 60, aluminiofarm = 60 }
            },
            accesscard4 = {
                Amount = 1,
                Time = 0,
                Required = { techtrash = 70, plastic = 70, aluminiofarm = 70 }
            },
            accesscard5 = {
                Amount = 1,
                Time = 0,
                Required = { techtrash = 80, plastic = 80, aluminiofarm = 80 }
            },
        }
    },
    FavelaDesmanche = {
        Label = "Desmanche",
        List = {
            lockpick = {
                Amount = 3,
                Time = 0,
                Required = { plastic = 1, aluminiofarm = 10 }
            },
            lockpickplus = {
                Amount = 3,
                Time = 0,
                Required = { plastic = 1, aluminiofarm = 15 }
            },
        }
    },
    LSD = {
        Label = "LSD",
        List = {
            lsdsell = {
                Amount = 1,
                Time = 5,
                Required = { lsdfarm = 3 }
            },
            lsdeat = {
                Amount = 1,
                Time = 5,
                Required = { lsdfarm = 3 }
            },
            caixalsd = {
                Amount = 1,
                Time = 60,
                Required = { lsdfarm = 300 }
            },
        }
    },
    Cocaina = {
        Label = "Cocaína",
        List = {
            cocainasell = {
                Amount = 1,
                Time = 5,
                Required = { cocainafarm = 3 }
            },
            cocainaeat = {
                Amount = 1,
                Time = 5,
                Required = { cocainafarm = 3 }
            },
            caixacocaina = {
                Amount = 1,
                Time = 60,
                Required = { cocainafarm = 300 }
            },
        }
    },
    Ecstasy = {
        Label = "Ecstasy",
        List = {
            exatasysell = {
                Amount = 1,
                Time = 5,
                Required = { exatasyfarm = 3 }
            },
            exatasyeat = {
                Amount = 1,
                Time = 5,
                Required = { exatasyfarm = 3 }
            },
            caixaexatasy = {
                Amount = 1,
                Time = 60,
                Required = { exatasyfarm = 300 }
            },
        }
    },
    Skunk = {
        Label = "Skunk",
        List = {
            skunksell = {
                Amount = 1,
                Time = 5,
                Required = { skunkfarm = 3 }
            },
            skunkeat = {
                Amount = 1,
                Time = 5,
                Required = { skunkfarm = 3 }
            },
            caixaskunk = {
                Amount = 1,
                Time = 60,
                Required = { skunkfarm = 300 }
            },
        }
    },
    Ayahuasca = {
        Label = "Ayahuasca",
        List = {
            ayahuascasell = {
                Amount = 1,
                Time = 5,
                Required = { ayahuascafarm = 3 }
            },
            ayahuascaeat = {
                Amount = 1,
                Time = 5,
                Required = { ayahuascafarm = 3 }
            },
            caixaayahuasca = {
                Amount = 1,
                Time = 60,
                Required = { ayahuascafarm = 300 }
            },
        }
    },
    Ketamina = {
        Label = "Ketamina",
        List = {
            ketaminasell = {
                Amount = 1,
                Time = 5,
                Required = { ketaminafarm = 3 }
            },
            ketaminaeat = {
                Amount = 1,
                Time = 5,
                Required = { ketaminafarm = 3 }
            },
            caixaketamina = {
                Amount = 1,
                Time = 60,
                Required = { ketaminafarm = 300 }
            },
        }
    },
    Metanfetamina = {
        Label = "Metanfetamina",
        List = {
            metasell = {
                Amount = 1,
                Time = 5,
                Required = { metadone = 3 }
            },
            metaeat = {
                Amount = 1,
                Time = 5,
                Required = { metadone = 3 }
            },
            caixameta = {
                Amount = 1,
                Time = 60,
                Required = { metadone = 300 }
            },
        }
    },
    Heroina = {
        Label = "Heroína",
        List = {
            heroinasell = {
                Amount = 1,
                Time = 5,
                Required = { heroinafarm = 3 }
            },
            heroinaeat = {
                Amount = 1,
                Time = 5,
                Required = { heroinafarm = 3 }
            },
            caixaheroina = {
                Amount = 1,
                Time = 60,
                Required = { heroinafarm = 300 }
            },
        }
    },
    -----------------------------------------------------------------------------------------------------------------------------------------
    -- RESTAURANTES (receitas alinhadas aos combos COMBOSODAPOP / COMBOKITTY / COMBOMOOMOO / COMBOMARINA no inventário)
    -- Combos: no máximo 8 tipos em Required (M/G: chocolate inclui açúcar; coco inclui água do coco; Marina M/G: laranja inclui limão; tomate no salmão; morango no leite do waffle)
    -----------------------------------------------------------------------------------------------------------------------------------------
    SodaPOP = {
        Label = "Cardápio",
        List = {
            COMBOSODAPOP_P = { Amount = 1, Time = 0, Required = { leite = 2, cereja = 4, coco = 2, water = 2, farinha = 1, carne = 1, tomato = 3, strawberry = 1 } },
            COMBOSODAPOP_M = { Amount = 1, Time = 0, Required = { leite = 3, cereja = 4, coco = 4, farinha = 4, carne = 2, tomato = 6, strawberry = 4, chocolate = 2 } },
            COMBOSODAPOP_G = { Amount = 1, Time = 0, Required = { leite = 5, cereja = 6, coco = 6, farinha = 7, carne = 3, tomato = 9, strawberry = 7, chocolate = 4 } },
            milkcereja = { Amount = 1, Time = 0, Required = { leite = 1, cereja = 2 } },
            aguadecoco = { Amount = 1, Time = 0, Required = { coco = 1, water = 1 } },
            bibimbap = { Amount = 1, Time = 0, Required = { farinha = 1, carne = 1, tomato = 1 } },
            salada = { Amount = 1, Time = 0, Required = { tomato = 2, strawberry = 1 } },
            churros = { Amount = 1, Time = 0, Required = { farinha = 1, chocolate = 1, sugar = 1 } },
            bolodemorango = { Amount = 1, Time = 0, Required = { farinha = 1, strawberry = 2, leite = 1 } },
        }
    },
    MooMoo = {
        Label = "Cardápio",
        List = {
            COMBOMOOMOO_P = { Amount = 1, Time = 0, Required = { leite = 6, strawberry = 4, sugar = 3, farinha = 1, batata = 2 } },
            COMBOMOOMOO_M = { Amount = 1, Time = 0, Required = { leite = 9, strawberry = 4, sugar = 5, farinha = 4, batata = 4, coco = 2, amendoim = 2 } },
            COMBOMOOMOO_G = { Amount = 1, Time = 0, Required = { leite = 14, strawberry = 6, sugar = 8, farinha = 7, batata = 6, coco = 4, amendoim = 4 } },
            leitedemorango = { Amount = 1, Time = 0, Required = { leite = 1, strawberry = 2 } },
            leitecomcanela = { Amount = 1, Time = 0, Required = { leite = 1, sugar = 1 } },
            cereal = { Amount = 1, Time = 0, Required = { leite = 1, farinha = 1, sugar = 1 } },
            purebatata = { Amount = 1, Time = 0, Required = { batata = 2, leite = 1 } },
            bolococo = { Amount = 1, Time = 0, Required = { farinha = 1, coco = 2, leite = 1 } },
            tortadeamendoim = { Amount = 1, Time = 0, Required = { farinha = 1, amendoim = 2, sugar = 1 } },
        }
    },
    Marina = {
        Label = "Cardápio",
        List = {
            COMBOMARINA_P = { Amount = 1, Time = 0, Required = { grape = 4, orange = 2, limao = 2, water = 4, tilapia = 1, batata = 2, salmao = 1, tomato = 1 } },
            COMBOMARINA_M = { Amount = 1, Time = 0, Required = { grape = 4, orange = 6, water = 4, tilapia = 2, batata = 4, salmao = 4, farinha = 2, leite = 3 } },
            COMBOMARINA_G = { Amount = 1, Time = 0, Required = { grape = 6, orange = 10, water = 6, tilapia = 3, batata = 6, salmao = 6, farinha = 4, leite = 6 } },
            sucodeuva = { Amount = 1, Time = 0, Required = { grape = 2, water = 1 } },
            coquetellaranjaelimao = { Amount = 1, Time = 0, Required = { orange = 1, limao = 1, water = 1 } },
            peixebatata = { Amount = 1, Time = 0, Required = { tilapia = 1, batata = 2 } },
            salmaomolho = { Amount = 1, Time = 0, Required = { salmao = 1, tomato = 1 } },
            wafflesgelado = { Amount = 1, Time = 0, Required = { farinha = 1, strawberry = 2, leite = 1 } },
            cupcakedelaranja = { Amount = 1, Time = 0, Required = { farinha = 1, orange = 2 } },
        }
    },
}
