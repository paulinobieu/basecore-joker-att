-- # garages_types: tipos de garagens (quais categorias de veículos irão aparecer em cada tipo de garagem)

garages_types = {
    ['NORMAL'] = {
        ['car'] = true,
        ['motorcycle'] = true,
        ['truck'] = true,
        ['vip'] = true,
        ['suv'] = true,
        ['other'] = true,
        ['service'] = true
    },
    ['PROPERTY'] = {
        ['car'] = true,
        ['motorcycle'] = true,
        ['truck'] = true,
        ['vip'] = true,
        ['suv'] = true,
        ['other'] = true,
        ['service'] = true
    },
    ['AIR'] = {
        ['air'] = true,
        ['vip_air'] = true
    },
    ['WATER'] = {
        ['water'] = true,
        ['vip_water'] = true
    }
}


-- # garages: cadastro de garagens
--[[

    -- # Formato de uma garagem comum.
    -- # A permission pode ser uma string (uma permissão), ex: 'permissao.permissao',
    -- # ou uma tabela (várias permissões), ex: {'perm1','perm2'},
    {
        name = 'Garagem', 
        permission = nil,
        payment = 500, -- Se é necessário pagar para retirar veículos nesta garagem, insira o valor, caso contrário deixe 0 ou remova esta linha.
        freePaymentPermission = {'teste'}, -- Caso a opção esteja acima, é possível definir permissões que não precisam pagar a taxa (ex: benefício vip)
        type = 'NORMAL',
        open = {101.04,-1073.62,29.38,261.67},
        spawns = {
            {105.07,-1077.14,29.2,339.59},
            {108.4,-1078.92,29.2,341.71},
            {111.73,-1080.23,29.2,332.29}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    -- # Formato de uma garagem de aluguel/serviço:
    -- # vehicles = tabela dos veículos disponíveis nesta garagem, formato: ['index'] = preço, (0 se for de graça)
    {
        name = 'Aluguel de Barcos',
        permission = nil,
        type = 'SERVICE',
        open = {1297.75,-3344.01,5.91,284.28},
        spawns = {
            {1302.76,-3344.64,-0.49,169.81}
        },
        blip = { 
            enabled = true,
            icon = 410, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 35,
            color = {255,255,255,255},
            size = 0.8
        },
        vehicles = {
            ['dinghy'] = 1000
        }
    },


--]]

garages = {

    -- FAVELA FALLET (pública)
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1394.36,1558.04,132.46,85.04},
        spawns = {
            {-1397.84,1554.4,132.46,172.92},
            {-1404.83,1554.93,132.44,172.92}
        },
        blip = {
            enabled = true,
            icon = 357,
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }
    },

    -- HOSPITAL NORTE
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {1732.55,3585.16,35.18,303.31},
        spawns = {
            {1737.06,3583.9,34.74,28.35}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Hospital Norte',
        permission = 'HospitalNorte',
        type = 'SERVICE',
        open = {1718.77,3619.77,34.58,308.98},
        spawns = {
            {1723.79,3623.11,34.81,209.77}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['UPnorte1'] = 0,
            ['UPnorte2'] = 0,
            ['UPnorte3'] = 0
        }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {1784.6,3660.1,39.85,215.44},
        spawns = {
            {1783.5,3653.29,40.52,212.6}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea Hospital Norte',
        permission = 'HospitalNorte',
        type = 'SERVICE',
        open = {1777.3,3655.48,39.85,300.48},
        spawns = {
            {1783.5,3653.29,40.52,212.6}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['UPnorte4'] = 0
        }
    },

    -- HOSPITAL SUL
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1042.94,-392.26,37.78,34.02},
        spawns = {
            {-1049.02,-391.81,37.12,291.97}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Hospital Sul',
        permission = 'HospitalSul',
        type = 'SERVICE',
        open = {-1019.07,-415.63,33.31,28.35},
        spawns = {
            {-1018.08,-412.0,32.84,113.39}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['UPsul1'] = 0,
            ['UPsul2'] = 0,
            ['UPsul3'] = 0
        }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {-1005.29,-426.54,78.28,204.1},
        spawns = {
            {-1007.51,-416.61,80.81,25.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea Hospital Sul',
        permission = 'HospitalSul',
        type = 'SERVICE',
        open = {-1000.78,-424.49,78.28,209.77},
        spawns = {
            {-1007.51,-416.61,80.81,25.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['UPsul4'] = 0
        }
    },

    -- POLÍCIA MILITAR
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {2562.2,-339.57,93.11,5.67},
        spawns = {
            {2564.67,-336.1,92.56,0.0}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Polícia Militar',
        permission = 'Militar',
        type = 'SERVICE',
        open = {2563.47,-318.98,92.99,277.8},
        spawns = {
            {2565.31,-316.21,92.57,0.0}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['vapidtactical'] = 0,
            ['ubermachtm3'] = 0,
            ['ubermachtm2'] = 0,
            ['shitzuadv'] = 0,
            ['dinkatyper'] = 0,
            ['benefactor850'] = 0
        }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {2464.11,-391.25,95.0,170.08},
        spawns = {
            {2456.77,-399.4,95.66,90.71}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea Polícia Militar',
        permission = 'Militar',
        type = 'SERVICE',
        open = {2467.63,-390.89,95.0,170.08},
        spawns = {
            {2456.77,-399.4,95.66,90.71}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['buckingham350'] = 0
        }
    },

    -- POLÍCIA CIVIL
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1075.96,-1983.36,13.16,235.28},
        spawns = {
            {-1071.96,-1982.82,12.74,226.78}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Polícia Civil',
        permission = 'Civil',
        type = 'SERVICE',
        open = {-1008.0,-2052.97,13.31,42.52},
        spawns = {
            {-1011.42,-2049.41,12.74,42.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['westerncliff'] = 0,
            ['ubermachtrebla'] = 0,
            ['karinsultanpol'] = 0,
            ['karinrebel'] = 0,
            ['karinfuto'] = 0
        }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {-989.6,-1999.42,44.7,42.52},
        spawns = {
            {-981.19,-2003.88,46.3,226.78}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea Polícia Civil',
        permission = 'Civil',
        type = 'SERVICE',
        open = {-985.96,-1996.07,44.7,45.36},
        spawns = {
            {-981.19,-2003.88,46.3,226.78}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['buckingswift'] = 0
        }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {-1018.37,-1963.23,44.7,226.78},
        spawns = {
            {-1025.31,-1960.03,46.3,42.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea Polícia Civil',
        permission = 'Civil',
        type = 'SERVICE',
        open = {-1021.54,-1966.62,44.7,45.36},
        spawns = {
            {-1025.31,-1960.03,46.3,42.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['buckingswift'] = 0
        }
    },

    -- BOPE
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1618.18,165.45,60.36,297.64},
        spawns = {
            {-1615.64,171.72,59.72,297.64}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {-1582.95,206.55,76.31,291.97},
        spawns = {
            {-1574.94,207.43,76.87,297.64}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    -- Garagem Exclusiva BOPE: exige permissão. Sem veículos definidos, habilitar quando informados.
    -- {
    --     name = 'Garagem Exclusiva BOPE',
    --     permission = 'BOPE',
    --     type = 'SERVICE',
    --     open = {-1636.41,204.4,60.64,294.81},
    --     spawns = {
    --         {-1631.52,205.79,60.09,297.64},
    --         {-1629.29,201.24,60.02,297.64},
    --         {-1627.3,197.41,59.97,297.64}
    --     },
    --     blip = { enabled = false },
    --     marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
    --     vehicles = {
    --     }
    -- },
    -- Garagem Aérea Exclusiva BOPE: gated AIR (helis próprios do membro). Passe um modelo p/ virar SERVICE fixo.
    -- {
    --     name = 'Garagem Aérea Exclusiva BOPE',
    --     permission = 'BOPE',
    --     type = 'AIR',
    --     open = {-1580.94,201.47,76.41,303.31},
    --     spawns = {
    --         {-1574.94,207.43,76.87,297.64}
    --     },
    --     blip = { enabled = false },
    --     marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    -- },

    -- PRF / CORE: pendente

    -- MALDIVAS PERFORMANCE (MECÂNICA)
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {848.72,-904.4,25.24,272.13},
        spawns = {
            {852.69,-902.55,24.87,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem 2º Andar',
        permission = nil,
        type = 'NORMAL',
        open = {818.99,-918.67,43.15,0.0},
        spawns = {
            {821.77,-924.15,42.73,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Aérea',
        permission = nil,
        type = 'AIR',
        open = {825.12,-900.92,52.42,0.0},
        spawns = {
            {833.83,-901.39,53.09,0.0}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- PADRÕES

    -- Garagem Pública Aeroporto
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1022.9,-2735.68,13.75,328.82},
        spawns = {
            {-1018.79,-2731.74,13.24,240.95},
            {-1010.67,-2736.19,13.24,240.95},
            {-1004.04,-2740.21,13.23,243.78}
        },
        blip = {
            enabled = true,
            icon = 357,
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }
    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {101.04,-1073.62,29.38,261.67},
        spawns = {
            {105.07,-1077.14,29.2,339.59},
            {108.4,-1078.92,29.2,341.71},
            {111.73,-1080.23,29.2,332.29}
        },
        hasInterior = true,
        interiorExit = vector4(108.67, -1071.33, 29.2, 64.82),
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {412.74,-633.93,28.51,1.67},
        spawns = {
            {408.49,-633.2,28.51,87.45},
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {55.84,-876.32,30.67,76.38},
        spawns = {
            {50.49,-873.24,30.44,163.97},
            {47.09,-872.23,30.45,161.23}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {597.09,91.18,93.13,68.77},
        spawns = {
            {599.19,98.21,92.91,252.57},
            {600.64,101.88,92.91,248.85}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-73.43,-2004.1,18.28,225.46},
        spawns = {
            {-82.2,-2010.87,18.02,168.38},
            {-78.57,-2011.33,18.02,172.71}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-2030.59,-465.42,11.61,138.78},
        spawns = {
            {-2024.51,-472.38,11.4,143.61},
            {-2022.09,-474.4,11.4,136.26}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-340.77,266.61,85.68,187.69},
        spawns = {
            {-328.85,274.44,86.35,93.96},
            {-328.91,277.77,86.35,89.08}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {1036.2,-763.2,58.0,231.01},
        spawns = {
            {1046.02,-774.62,58.02,93.32},
            {1046.34,-778.25,58.01,95.25}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {1036.2,-763.2,58.0,231.01},
        spawns = {
            {1046.02,-774.62,58.02,93.32},
            {1046.34,-778.25,58.01,95.25}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {317.12,2622.99,44.46,307.34},
        spawns = {
            {336.43,2620.25,44.5,6.93},
            {341.91,2623.05,44.51,17.89}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-773.18,5597.72,33.61,174.52},
        spawns = {
            {-772.36,5578.47,33.49,92.87},
            {-772.39,5575.43,33.49,87.05}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-389.15,1186.8,325.65,174.36},
        spawns = {
            {-389.02,1194.02,325.65,97.4},
            {-388.05,1198.24,325.65,93.9}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-317.25,-1512.75,27.75,174.53},
        spawns = {
            {-319.71,-1517.05,27.56,179.59},
            {-323.0,-1517.26,27.55,181.67}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {2560.0,-370.5,93.08,181.67},
        spawns = {
            {2556.9,-372.32,93.0,346.03},
            {2553.32,-371.58,93.0,345.56}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1184.63,-1509.94,4.65,302.06},
        spawns = {
            {-1183.48,-1495.57,4.38,121.93},
            {-1185.75,-1493.31,4.38,127.34}
        },
        blip = { 
            enabled = true,
            icon = 357, 
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    {

        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-577.09,-1095.51,22.18,103.07},
        spawns = {
            {-582.29,-1100.83,22.18,89.7},
            {-583.45,-1104.56,22.18,78.44}
        },
        blip = {
            enabled = true,
            icon = 357,
            color = 0,
            size = 0.5
        },
        marker = {
            icon = 36,
            color = {255,255,255,255},
            size = 0.8
        }

    },

    -- ============================================================
    -- FACCOES (blip = false)
    -- ============================================================

    -- Triade (Municao1)
    {
        name = 'Garagem Triade',
        permission = nil,
        type = 'NORMAL',
        open = {379.63,-9.73,82.99,34.02},
        spawns = {
            {379.28,-5.77,82.56,127.56},
            {377.07,-2.32,82.55,127.56}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Fazenda (Municao2)
    {
        name = 'Garagem Fazenda',
        permission = nil,
        type = 'NORMAL',
        open = {1403.33,1122.76,114.83,184.26},
        spawns = {
            {1409.29,1119.9,114.41,87.88},
            {1401.99,1119.95,114.41,90.71}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Jetsam (Municao3)
    {
        name = 'Garagem Jetsam',
        permission = nil,
        type = 'NORMAL',
        open = {819.38,-2967.3,1.79,175.75},
        spawns = {
            {816.41,-2968.83,1.35,272.13},
            {815.98,-2971.99,1.35,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Sinaloa (Municao4)
    {
        name = 'Garagem Sinaloa',
        permission = nil,
        type = 'NORMAL',
        open = {-1807.26,410.89,113.64,238.12},
        spawns = {
            {-1804.2,410.95,113.01,201.26},
            {-1801.97,403.8,112.54,201.26}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Globo (Arma1)
    {
        name = 'Garagem Globo',
        permission = nil,
        type = 'NORMAL',
        open = {-3673.31,3817.52,14.76,243.78},
        spawns = {
            {-3667.48,3822.28,14.34,136.07},
            {-3671.47,3815.46,14.34,153.08}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Vinhedo (Arma2)
    {
        name = 'Garagem Vinhedo',
        permission = nil,
        type = 'NORMAL',
        open = {-1902.87,2018.47,140.88,269.3},
        spawns = {
            {-1904.46,2015.83,140.68,269.3},
            {-1905.59,2012.6,140.9,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Playboy (Arma3)
    {
        name = 'Garagem Playboy',
        permission = nil,
        type = 'NORMAL',
        open = {-1534.49,88.53,56.77,269.3},
        spawns = {
            {-1530.8,92.29,56.24,226.78},
            {-1528.69,95.0,56.21,223.94}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Casablanca (Arma4)
    {
        name = 'Garagem Casablanca',
        permission = nil,
        type = 'NORMAL',
        open = {-1541.56,841.34,184.39,351.5},
        spawns = {
            {-1543.06,844.69,183.95,269.3},
            {-1551.61,846.76,183.95,252.29}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Yakuza (Arma5)
    {
        name = 'Garagem Yakuza',
        permission = nil,
        type = 'NORMAL',
        open = {-2333.51,-596.7,13.58,226.78},
        spawns = {
            {-2333.98,-600.01,13.82,223.94},
            {-2337.82,-603.89,13.82,226.78}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Distrito 14 (Contrabando1)
    {
        name = 'Garagem Distrito 14',
        permission = nil,
        type = 'NORMAL',
        open = {-678.25,2699.2,50.09,314.65},
        spawns = {
            {-675.36,2700.99,49.35,226.78},
            {-670.97,2696.88,49.34,229.61}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Resort (Contrabando2)
    {
        name = 'Garagem Resort',
        permission = nil,
        type = 'NORMAL',
        open = {-3022.47,89.46,11.61,320.32},
        spawns = {
            {-3023.12,93.37,11.19,320.32},
            {-3025.33,96.35,11.19,320.32}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Posto (Contrabando3)
    {
        name = 'Garagem Posto',
        permission = nil,
        type = 'NORMAL',
        open = {-2074.2,-322.4,13.31,79.38},
        spawns = {
            {-2078.21,-320.17,12.7,85.04},
            {-2077.25,-316.5,12.7,85.04}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Igreja (Contrabando4)
    {
        name = 'Garagem Igreja',
        permission = nil,
        type = 'NORMAL',
        open = {-328.78,6145.9,31.49,138.9},
        spawns = {
            {-333.99,6147.18,31.05,45.36},
            {-328.29,6141.49,31.05,42.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Jack Of Hearts (Lavagem1)
    {
        name = 'Garagem Jack Of Hearts',
        permission = nil,
        type = 'NORMAL',
        open = {362.3,298.34,103.68,340.16},
        spawns = {
            {361.07,293.73,103.09,249.45},
            {358.58,286.26,103.05,252.29}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Haute (Lavagem2)
    {
        name = 'Garagem Haute',
        permission = nil,
        type = 'NORMAL',
        open = {-61.93,220.69,106.56,274.97},
        spawns = {
            {-58.99,218.85,106.12,343.0},
            {-55.91,217.96,106.12,343.0}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Vanilla Sul (Lavagem3)
    {
        name = 'Garagem Vanilla Sul',
        permission = nil,
        type = 'NORMAL',
        open = {-670.32,-709.09,24.67,36.86},
        spawns = {
            {-673.75,-703.35,24.25,110.56},
            {-673.84,-696.52,24.25,113.39}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Vanilla Norte (Lavagem4)
    {
        name = 'Garagem Vanilla Norte',
        permission = nil,
        type = 'NORMAL',
        open = {-292.99,6253.51,31.44,229.61},
        spawns = {
            {-288.3,6252.57,30.94,133.23},
            {-293.49,6247.38,30.94,133.23}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Yellow Jack (Desmanche1)
    {
        name = 'Garagem Yellow Jack',
        permission = nil,
        type = 'NORMAL',
        open = {1986.23,3058.66,47.21,331.66},
        spawns = {
            {1989.09,3062.3,46.62,334.49},
            {1991.79,3059.69,46.62,328.82}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Racha Cranios (Desmanche2)
    {
        name = 'Garagem Racha Cranios',
        permission = nil,
        type = 'NORMAL',
        open = {1226.09,-3227.89,6.03,8.51},
        spawns = {
            {1223.0,-3225.73,5.43,272.13},
            {1229.39,-3225.53,5.43,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Mansao Black (Desmanche3)
    {
        name = 'Garagem Mansao Black',
        permission = nil,
        type = 'NORMAL',
        open = {-2784.65,1414.92,100.96,56.7},
        spawns = {
            {-2786.54,1417.3,100.54,325.99},
            {-2790.36,1419.88,100.54,325.99}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Rising Sun (Desmanche4)
    {
        name = 'Garagem Rising Sun',
        permission = nil,
        type = 'NORMAL',
        open = {-376.99,-149.23,38.7,300.48},
        spawns = {
            {-375.57,-145.88,38.28,300.48},
            {-378.76,-139.43,38.28,300.48}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Barragem (Metafetamina1)
    {
        name = 'Garagem Favela Barragem',
        permission = nil,
        type = 'NORMAL',
        open = {1235.98,-4.94,77.68,82.21},
        spawns = {
            {1239.12,5.93,76.9,138.9},
            {1245.72,13.75,76.9,138.9}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Demonike (Metafetamina2)
    {
        name = 'Garagem Favela Demonike',
        permission = nil,
        type = 'NORMAL',
        open = {-414.38,1595.95,360.59,311.82},
        spawns = {
            {-413.2,1599.17,360.16,223.94},
            {-410.62,1601.54,360.16,221.11}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Helipa (Skunk1)
    {
        name = 'Garagem Favela Helipa',
        permission = nil,
        type = 'NORMAL',
        open = {1329.84,-770.0,79.01,283.47},
        spawns = {
            {1340.05,-763.55,78.59,155.91},
            {1336.87,-762.35,78.59,153.08}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Juramento (Skunk2)
    {
        name = 'Garagem Favela Juramento',
        permission = nil,
        type = 'NORMAL',
        open = {-2094.17,931.09,204.41,331.66},
        spawns = {
            {-2087.8,932.15,203.97,323.15},
            {-2085.12,929.89,203.97,323.15}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Sinaloa (Cocaina1)
    {
        name = 'Garagem Favela Sinaloa',
        permission = nil,
        type = 'NORMAL',
        open = {1571.6,-1379.48,84.79,110.56},
        spawns = {
            {1564.7,-1374.55,85.53,158.75},
            {1560.32,-1372.58,86.47,161.58}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Mare (Cocaina2)
    {
        name = 'Garagem Favela Mare',
        permission = nil,
        type = 'NORMAL',
        open = {-2496.19,-172.0,45.21,320.32},
        spawns = {
            {-2489.68,-166.58,44.55,328.82},
            {-2486.84,-168.54,44.55,328.82}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela MMDG (Ecstasy1)
    {
        name = 'Garagem Favela MMDG',
        permission = nil,
        type = 'NORMAL',
        open = {-837.73,968.18,250.81,8.51},
        spawns = {
            {-837.77,974.88,250.14,8.51},
            {-834.34,975.22,250.14,8.51}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Vaticano (Ecstasy2)
    {
        name = 'Garagem Favela Vaticano',
        permission = nil,
        type = 'NORMAL',
        open = {2629.34,1829.97,36.97,192.76},
        spawns = {
            {2625.82,1825.07,36.55,181.42},
            {2622.84,1825.35,36.55,178.59}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- Favela Santo Amaro (Heroina1)
    {
        name = 'Garagem Favela Santo Amaro',
        permission = nil,
        type = 'NORMAL',
        open = {-1160.96,2520.26,41.5,201.26},
        spawns = {
            {-1156.83,2518.73,41.5,289.14},
            {-1168.21,2518.16,41.5,260.79}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },

    -- SODA POP
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-1396.18,-1385.2,3.64,59.53},
        spawns = {
            {-1398.68,-1384.03,3.79,343.0}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Soda Pop',
        permission = 'SodaPop',
        type = 'SERVICE',
        open = {-1398.92,-1396.24,3.56,96.38},
        spawns = {
            {-1400.28,-1400.74,3.89,5.67}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['PCXSODAP'] = 0,
            ['FOODTRUCKSODAP'] = 0
        }
    },

    -- MOO MOO
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-577.64,-1101.11,22.38,266.46},
        spawns = {
            {-572.59,-1104.39,22.41,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Moo Moo',
        permission = 'MooMoo',
        type = 'SERVICE',
        open = {-614.16,-1053.81,21.79,116.23},
        spawns = {
            {-618.42,-1058.74,22.02,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['PCXMOOMOO'] = 0,
            ['FOODTRUCKMOOMOO'] = 0
        }
    },

    -- OSAKA SUSHI
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {-768.65,-142.37,37.73,294.81},
        spawns = {
            {-763.95,-146.33,37.64,212.6}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    -- Garagem de serviço do Osaka Sushi: sem veículos ainda — reativar quando adicionarem
    --[[
    {
        name = 'Garagem Osaka Sushi',
        permission = 'OsakaSushi',
        type = 'SERVICE',
        open = {-799.68,-155.48,37.57,119.06},
        spawns = {
            {-802.15,-156.9,37.81,28.35}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
        }
    },
    --]]

    -- MARIANA LOUNGE
    {
        name = 'Garagem',
        permission = nil,
        type = 'NORMAL',
        open = {1521.43,3770.71,34.19,226.78},
        spawns = {
            {1524.76,3766.17,34.29,39.69}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 }
    },
    {
        name = 'Garagem Marina Lounge',
        permission = 'MarinaLounge',
        type = 'SERVICE',
        open = {1555.32,3792.19,34.26,204.1},
        spawns = {
            {1557.72,3787.26,34.37,25.52}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
            ['PCXMARINA'] = 0,
            ['FOODTRUCKMARINA'] = 0
        }
    },

    -- KITTY CAFÉ (pública já existe ao lado, não precisa)
    -- Garagem de serviço do Kitty Café: sem veículos ainda — reativar quando adicionarem
    --[[
    {
        name = 'Garagem Kitty Café',
        permission = 'KittyCafe',
        type = 'SERVICE',
        open = {1136.89,-770.42,57.69,0.0},
        spawns = {
            {1143.21,-768.84,57.81,272.13}
        },
        blip = { enabled = false },
        marker = { icon = 36, color = {255,255,255,255}, size = 0.8 },
        vehicles = {
        }
    },
    --]]

}
