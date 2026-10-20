return {
    ---@type boolean Enable/Disable debug messages.
    Debug = false, -- Enable debug console messages for troubleshooting

    ---@type boolean Automatic creation of tables required for 0r-nailshop.
    AutoRunSQL = true, -- Automatically create database tables on resource start

    -- !NOTE!
    -- You can add the translation files you have created for the script to the script in the next updates by contacting the support requests/snippets channels or the authorized person named @vezironi (no.1).
    -- !NOTE!

    ---@type string Locale file name (without .json extension) located in the locales folder.
    Locale = 'pt', -- Language file to use (en.json, tr.json, etc.)

    ---@type TargetSystem
    ---Target system to use in the script. Set to 'auto' to automatically detect a supported target system. If you are not using target script set the false (Supported Target Scripts: qb-target, ox_target, sleepless_interact)
    Target = 'auto', -- Target system: 'auto', 'qb-target', 'ox_target', 'sleepless_interact', or false

    ---@type NotifySystem
    ---Notification system to use in the script. Set to 'auto' to automatically detect a supported notification system. (Supported Notification Scripts: brutal_notify, lation_ui, mythic_notify, okokNotify, ox_lib, pNotify, r_notify, t-notify, wasabi_notify)
    Notify = 'auto', -- Notification system: 'auto' or specific notify script name

    ---@type CommandsConfig
    Commands = { -- Custom commands configuration
        ['reload_nails'] = {
            name = 'reload_nails', -- Command name
            help = 'Reload your nail design from the database.', -- Command help text
        }
    },

    ---@type NailStudiosConfig
    NailStudios = { -- Nail salon locations and tables configuration
        {
            name = "Harem", -- Studio name
            coords = vec3(217.09, -1544.95, 28.29), -- Studio location coordinates
            job = false, -- Required job to access (false for public access)
            tables = { -- Work tables in this studio
                {
                    customer = { -- Customer chair position
                        coords = vec4(220.95503234863, -1545.1121826172, 28.290630340576, -53.0), -- Customer chair position and heading
                        cameraOffset = vec3(0.0, -0.45, 1.5), -- Camera offset from customer chair
                        chairOffset = vec3(0.0, -0.8, 0.2), -- Player position offset when sitting
                    },
                    employee = { -- Employee chair position
                        coords = vec4(219.01142883301, -1546.6011962891, 28.290410995483, 127.0), -- Employee chair position and heading
                        chairOffset = vec3(0.0, -0.4, -0.3), -- Employee position offset when sitting
                    },
                },
                {
                    customer = { -- Customer chair position
                        coords = vec4(215.93556213379, -1548.935546875, 28.290410995483, -127.0), -- Customer chair position and heading
                        cameraOffset = vec3(0.0, -0.45, 1.5), -- Camera offset from customer chairbir
                        chairOffset = vec3(0.0, -0.8, 0.2), -- Player position offset when sitting
                    },
                    employee = { -- Employee chair position
                        coords = vec4(217.88572692871, -1547.4417724609, 28.290630340576, -53.0), -- Employee chair position and heading
                        chairOffset = vec3(0.0, -0.4, -0.3), -- Employee position offset when sitting
                    },
                },
                {
                    customer = { -- Customer chair position
                        coords = vec4(213.08038330078, -1545.2966308594, 28.290410995483, -127.0), -- Customer chair position and heading
                        cameraOffset = vec3(0.0, -0.45, 1.5), -- Camera offset from customer chairbir
                        chairOffset = vec3(0.0, -0.8, 0.2), -- Player position offset when sitting
                    },
                    employee = { -- Employee chair position
                        coords = vec4(215.02543640137, -1543.806640625, 28.290630340576, -53.0), -- Employee chair position and heading
                        chairOffset = vec3(0.0, -0.4, -0.3), -- Employee position offset when sitting
                    },
                },
                {
                    customer = { -- Customer chair position
                        coords = vec4(217.96156311035, -1541.3356933594, 28.290508270264, -53.0), -- Customer chair position and heading
                        cameraOffset = vec3(0.0, -0.45, 1.5), -- Camera offset from customer chairbir
                        chairOffset = vec3(0.0, -0.8, 0.2), -- Player position offset when sitting
                    },
                    employee = { -- Employee chair position
                        coords = vec4(216.04086303711, -1542.8074951172, 28.290288925171, -127.0), -- Employee chair position and heading
                        chairOffset = vec3(0.0, -0.4, -0.3), -- Employee position offset when sitting
                    },
                }
            },
        },
        -- {
        --     name = "Harem", -- Studio name
        --     coords = vec3(217.09, -1544.95, 28.29), -- Studio location coordinates
        --     job = 'harem_nail', -- Required job to access (false for public access)
        --     tables = { -- Work tables in this studio
        --         {
        --             customer = { -- Customer chair position
        --                 coords = vec4(220.78144836426, -1545.3660888672, 28.274831771851, 65), -- Customer chair position and heading
        --                 cameraOffset = vec3(0.0, -0.2, 1.2), -- Camera offset from customer chair
        --                 chairOffset = vec3(-0.2, -0.7, -0.2), -- Player position offset when sitting
        --             },
        --             employee = { -- Employee chair position
        --                 coords = vec4(218.98052978516, -1546.8543701172, 28.274831771851, -155), -- Employee chair position and heading
        --                 chairOffset = vec3(0.0, -0.4, -0.3), -- Employee position offset when sitting
        --             },
        --         },
        --         {
        --             customer = { -- Customer chair position
        --                 coords = vec4(216.04916381836, -1549.0728759766, 28.274831771851, -135), -- Customer chair position and heading
        --                 cameraOffset = vec3(0.0, -0.2, 1.2), -- Camera offset from customer chair
        --                 chairOffset = vec3(-0.2, -0.7, -0.2), -- Player position offset when sitting
        --             },
        --             employee = { -- Employee chair position
        --                 coords = vec4(217.98722839355, -1547.5891113281, 28.274831771851, 70), -- Employee chair position and heading
        --                 chairOffset = vec3(0.0, -0.4, -0.3), -- Employee position offset when sitting
        --             },
        --         }
        --     },
        -- }
    },

    ---@type BlipSettingsConfig
    BlipSettings = { -- Map blip settings for nail studios
        sprite = 279, -- Blip sprite ID
        color = 8, -- Blip color ID
        scale = 0.7, -- Blip scale size
        name = "Estudio de Unhas" -- Blip name on map
    },

    ---@type FingerBonesConfig
    FingerBones = { -- Bone IDs for each finger (used for attaching nail objects)
        ['left_hand_1'] = 45, -- Left thumb bone ID
        ['left_hand_2'] = 50, -- Left index finger bone ID
        ['left_hand_3'] = 54, -- Left middle finger bone ID
        ['left_hand_4'] = 57, -- Left ring finger bone ID
        ['left_hand_5'] = 60, -- Left pinky finger bone ID
        ['right_hand_1'] = 74, -- Right thumb bone ID
        ['right_hand_2'] = 79, -- Right index finger bone ID
        ['right_hand_3'] = 83, -- Right middle finger bone ID
        ['right_hand_4'] = 86, -- Right ring finger bone ID
        ['right_hand_5'] = 89 -- Right pinky finger bone ID
    }
}