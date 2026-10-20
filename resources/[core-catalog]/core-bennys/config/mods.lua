-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLE MODS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Catálogo de tunagens. Cada categoria tem: name (rótulo), modType (customization|performance),
-- numMods (quantidade) e mods (id -> nome). As numéricas 0..49 são slots nativos do GTA;
-- as de chave string (bulletProofTyres, neon, chameleon, ...) são customizações especiais.
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESATIVAR UMA TUNAGEM GLOBALMENTE: adicione enabled = false na entrada da categoria.
-- Ela some do menu e o servidor recusa aplicá-la. Não precisa apagar linhas.
-- Ex.: bulletProofTyres abaixo tem enabled = true (troque p/ false para desligar os pneus à prova de balas).
-----------------------------------------------------------------------------------------------------------------------------------------
Bennys.Mods = {
    modTypes = {
        [0]  = { name = 'Aerofólio', modType = 'customization' },
        [1]  = { name = 'Parachoque Frontal', modType = 'customization' },
        [2]  = { name = 'Parachoque Traseiro', modType = 'customization' },
        [3]  = { name = 'Saia Lateral', modType = 'customization' },
        [4]  = { name = 'Escapamento', modType = 'performance' },
        [5]  = { name = 'Carroceria', modType = 'customization' },
        [6]  = { name = 'Grelha', modType = 'customization' },
        [7]  = { name = 'Capô', modType = 'customization' },
        [8]  = { name = 'Paralama', modType = 'customization' },
        [9]  = { name = 'Paralama Direita', modType = 'customization' },
        [10] = { name = 'Teto', modType = 'customization' },
        [11] = { name = 'Motor', modType = 'performance' },
        [12] = { name = 'Freio', modType = 'performance' },
        [13] = { name = 'Transmissão', modType = 'performance' },
        [14] = { name = 'Buzina', modType = 'customization' },
        [15] = { name = 'Suspensão', modType = 'performance' },
        [16] = { name = 'Blindagem', modType = 'performance' },
        [17] = { name = 'Nitro', modType = 'performance' },
        [18] = { name = 'Turbo', modType = 'performance' },
        [19] = { name = 'Som', modType = 'customization' },
        [20] = { name = 'Fumaça do pneu', modType = 'customization' },
        [21] = { name = 'Hidráulica', modType = 'performance' },
        [22] = { name = 'Faróis Xenon', modType = 'customization' },
        [23] = { name = 'Rodas', modType = 'customization' },
        [24] = { name = 'Inclinação das Rodas', modType = 'customization' },
        [25] = { name = 'Decoração de Placa', modType = 'customization' },
        [26] = { name = 'Placa Customizada', modType = 'customization' },
        [27] = { name = 'Interna', modType = 'customization' },
        [28] = { name = 'Bonecos', modType = 'customization' },
        [29] = { name = 'Dashboard', modType = 'customization' },
        [30] = { name = 'Velocímetro', modType = 'customization' },
        [31] = { name = 'Portas', modType = 'customization' },
        [32] = { name = 'Bancos', modType = 'customization' },
        [33] = { name = 'Volante', modType = 'customization' },
        [34] = { name = 'Marcha', modType = 'customization' },
        [35] = { name = 'Plaques', modType = 'customization' },
        [36] = { name = 'Caixa de som', modType = 'customization' },
        [37] = { name = 'Som na mala', modType = 'customization' },
        [38] = { name = 'Hidráulica', modType = 'performance' },
        [39] = { name = 'Bloco do motor', modType = 'performance' },
        [40] = { name = 'Filtro de ar', modType = 'performance' },
        [41] = { name = 'Customização de Motor 2', modType = 'performance' },
        [42] = { name = 'Arch cover', modType = 'customization' },
        [43] = { name = 'Antenas', modType = 'customization' },
        [44] = { name = 'Chassi 4', modType = 'customization' },
        [45] = { name = 'Armas', modType = 'customization' },
        [46] = { name = 'Porta Esquerda', modType = 'customization' },
        [47] = { name = 'Porta Direita', modType = 'customization' },
        [48] = { name = 'Decalque', modType = 'customization' },
        [49] = { name = 'Luz', modType = 'customization' },
    },
    [11] = {
        name = 'Motor',
        modType = 'performance',
        numMods = 4,
        mods = {
            ["0"] = "Nível 1",
            ["1"] = "Nível 2",
            ["2"] = "Nível 3",
            ["3"] = "Nível 4",
        }
    },

    [12] = {
        name = "Freio",
        modType = 'performance',
        numMods = 3,
        mods = {
            ["0"] = "Nível 1",
            ["1"] = "Nível 2",
            ["2"] = "Nível 3",
        }
    },

    [13] = {
        name = "Transmissão",
        modType = 'performance',
        numMods = 3,
        mods = {
            ["0"] = "Nível 1",
            ["1"] = "Nível 2",
            ["2"] = "Nível 3",
        }
    },

    [14] = {
        name = "Buzina",
        modType = 'customization',
        numMods = 58,
        mods = {
            ["0"] = "Buzina de Caminhão",
            ["1"] = "Buzina Policial",
            ["2"] = "Buzina de Palhaço",
            ["3"] = "Buzina Musical 1",
            ["4"] = "Buzina Musical 2",
            ["5"] = "Buzina Musical 3",
            ["6"] = "Buzina Musical 4",
            ["7"] = "Buzina Musical 5",
            ["8"] = "Trombone Triste",
            ["9"] = "Buzina Clássica 1",
            ["10"] = "Buzina Clássica 2",
            ["11"] = "Buzina Clássica 3",
            ["12"] = "Buzina Clássica 4",
            ["13"] = "Buzina Clássica 5",
            ["14"] = "Buzina Clássica 6",
            ["15"] = "Buzina Clássica 7",
            ["16"] = "Nota Musical Do",
            ["17"] = "Nota Musical Re",
            ["18"] = "Nota Musical Mi",
            ["19"] = "Nota Musical Fa",
            ["20"] = "Nota Musical Sol",
            ["21"] = "Nota Musical La",
            ["22"] = "Nota Musical Ti",
            ["23"] = "Nota Musical Do (Grave)",
            ["24"] = "Buzina de Jazz 1",
            ["25"] = "Buzina de Jazz 2",
            ["26"] = "Buzina de Jazz 3",
            ["27"] = "Buzina de Jazz Loop",
            ["28"] = "Star Spangled Banner",
            ["29"] = "Star Spangled Banner",
            ["30"] = "Star Spangled Banner",
            ["31"] = "Star Spangled Banner",
            ["32"] = "Buzina Clássica Loop",
            ["33"] = "Buzina Clássica 8",
            ["34"] = "Buzina Clássica Loop 2",
            ["35"] = "Halloween Loop 1",
            ["36"] = "Halloween Loop 2",
            ["37"] = "San Andreas Loop",
            ["38"] = "Liberty City Loop",
            ["39"] = "Loop Festival 1",
            ["40"] = "Loop Festival 2",
            ["41"] = "Loop Festival 3",
            ["42"] = "Street Transmission",
            ["43"] = "Buzina Musical Loop 6",
            ["44"] = "Buzina Musical Loop 7",
            ["45"] = "Buzina Musical Loop 8",
            ["46"] = "Buzina Natalina 1",
            ["47"] = "Buzina Natalina 2",
            ["48"] = "Buzina Natalina 3",
            ["49"] = "Buzina Natalina 4",
            ["50"] = "Buzina Natalina 5",
            ["51"] = "Buzina Natalina 6",
            ["52"] = "Buzina de Corneta Loop 1",
            ["53"] = "Buzina de Corneta 1",
            ["54"] = "Buzina de Corneta Loop 2",
            ["55"] = "Buzina de Corneta 2",
            ["56"] = "Buzina de Corneta Loop 3",
            ["57"] = "Buzina de Corneta 3",
        }
    },

    [15] = {
        name = "Suspensão",
        modType = 'performance',
        numMods = 4,
        mods = {
            ["0"] = "Nível 1",
            ["1"] = "Nível 2",
            ["2"] = "Nível 3",
            ["3"] = "Nível 4",
        }
    },

    [16] = {
        name = "Blindagem",
        modType = 'performance',
        numMods = 5,
        mods = {
            ["0"] = "Nível 1",
            ["1"] = "Nível 2",
            ["2"] = "Nível 3",
            ["3"] = "Nível 4",
            ["4"] = "Nível 5",
        }
    },


    [18] = {
        name = "Turbo",
        modType = 'performance',
        numMods = 1,
        mods = {
            ["1"] = "Ativado"
        }
    },
    [20] = {
        name = "Fumaça do pneu",
        modType = 'customization',
        numMods = 2,
        mods = {
            ["-1"] = "Desativado",
            ["1"] = "Ativado"
        }
    },

    [21] = {
        name = "Hidráulica",
        modType = 'performance',
        numMods = 1,
        mods = {
            ["1"] = "Ativado"
        }
    },

    ['wheelColour'] = {
        name = "Cor da Roda",
        modType = "customization",
        icon = "wheelColour",
        palette = "wheel",
    },
    ['primaryColour'] = {
        name = "Cores Primárias",
        modType = 'customization',
        icon = "primaryColour",
        numMods = 1,
        mods = {
            ["-3"] = "Selecione a cor",
        }
    },
    ['secondaryColour'] = {
        name = "Cores Secundárias",
        modType = 'customization',
        icon = "secondaryColour",
        numMods = 1,
        mods = {
            ["-3"] = "Selecione a cor",
        }
    },
    ['pearlescentColour'] = {
        name = "Perolado",
        modType = "customization",
        icon = "pearlescentColour",
        palette = "wheel",
    },
    ['windowTint'] = {
        name = "Vidros",
        modType = 'customization',
        icon = "windowTint",
        numMods = 7,
        mods = {
            ["0"] = "Normal",
            ["1"] = "Preto",
            ["2"] = "Cinza Escuro",
            ["3"] = "Cinza Claro",
            ["4"] = "Claro",
            ["5"] = "Limousine",
            ["6"] = "Verde",
        }
    },
    [22] = {
        name = "Xênon",
        modType = "customization",
        icon = "xenon",
        palette = "xenon",
    },
    ['neon'] = {
        name = "Neon",
        modType = 'customization',
        numMods = 5,
        icon = "neon",
        mods = {
            ["-1"] = "Desativado",
            ["0"] = "Esquerda",
            ["1"] = "Direita",
            ["2"] = "Frente",
            ["3"] = "Atrás",
        },
    },
    ['plate'] = {
        name = "Placa",
        modType = 'customization',
        icon = "plate",
        numMods = 13,
        mods = {
            ["0"] = "Azul (San Andreas)",
            ["1"] = "Amarela e Preta",
            ["2"] = "Amarela e Azul",
            ["3"] = "Branca Clássica",
            ["4"] = "Branca Simples",
            ["5"] = "North Yankton",
            ["6"] = "Personalizada 1",
            ["7"] = "Personalizada 2",
            ["8"] = "Personalizada 3",
            ["9"] = "Personalizada 4",
            ["10"] = "Personalizada 5",
            ["11"] = "Personalizada 6",
            ["12"] = "Personalizada 7",
        }
    },

    ['bulletProofTyres'] = {
        name = "Pneus à Prova de Balas",
        modType = 'customization',
        icon = "bulletProofTyres",
        enabled = true,
        numMods = 2,
        mods = {
            ["-1"] = "Desativado",
            ["1"] = "Ativado"
        }
    },

    ['driftTyres'] = {
        name = "Pneus de Drift",
        modType = 'customization',
        icon = "driftTyres",
        numMods = 2,
        mods = {
            ["-1"] = "Desativado",
            ["1"] = "Ativado"
        }
    },

}
Bennys.ExtraMods = {
    ['primaryPaintType'] = {
        name = 'Tipo de Pintura',
        modType = 'customization',
        icon = "primaryPaintType",
    },
    ['secondaryPaintType'] = {
        name = 'Tipo de Pintura Sec',
        modType = 'customization',
        icon = "secondaryPaintType",
    },
    ['xenonColour'] = {
        name = 'Xenon',
        modType = 'customization',
        icon = "xenonColour",
    },
    ['wheelType'] = {
        name = 'Tipo de Rodas',
        modType = 'customization',
        icon = "wheelType",
    },
    ['tyreSmokeColour'] = {
        name = 'Fumaça dos Pneus',
        modType = 'customization',
        icon = "tyreSmokeColour",
    },
    ['bulletProofTyres'] = {
        name = 'Pneus a prova de Balas',
        modType = 'customization',
        icon = "bulletProofTyres",
    },
    ['driftTyres'] = {
        name = 'Pneus de Drift',
        modType = 'customization',
        icon = "driftTyres",
    },
    ['vehicleExtras'] = {
        name = 'Extras do Veículo',
        modType = 'customization',
        icon = "vehicleExtras",
    },
}
