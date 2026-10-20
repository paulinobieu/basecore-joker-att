Config = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- IMAGENS (CDN)
-----------------------------------------------------------------------------------------------------------------------------------------
Config.ImagesProvider = {
    Items    = ItemsURL,
    Vehicles = "https://cdn.corenetwork.dev/corevehicles/",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Permission = "Admin"

-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-- Cores de destaque da NUI.
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Colors = {
    primaryColor   = "#df1553",
    secondaryColor = "#9e0f3c",
    thirdyColor    = "#670a27"
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CACHE
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Cache = {
    Organizations = {
        Duration = 30000,
        Enabled  = true,
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- HIERARQUIA STAFF
-----------------------------------------------------------------------------------------------------------------------------------------
Config.StaffGroups = {
    ["C-Level"] = {
        Level      = 6,
        Color      = "#c9159c",
        BgColor    = "#34014d20",
        CanPromote = true,
        CanDemote  = true,
        CanManage  = true,
    },
    ["Diretor"] = {
        Level      = 5,
        Color      = "#f8dc3e",
        BgColor    = "#FFD70020",
        CanPromote = false,
        CanDemote  = false,
        CanManage  = false,
    },
    ["Supervisor"] = {
        Level      = 4,
        Color      = "#1bfaa4",
        BgColor    = "#48ffd120",
        CanPromote = false,
        CanDemote  = false,
        CanManage  = false,
    },
    ["Administrador"] = {
        Level      = 3,
        Color      = "#FF4444",
        BgColor    = "#FF444420",
        CanPromote = false,
        CanDemote  = false,
        CanManage  = false,
    },
    ["Moderador"] = {
        Level      = 2,
        Color      = "#3C8EDC",
        BgColor    = "#3C8EDC20",
        CanPromote = false,
        CanDemote  = false,
        CanManage  = false,
    },
    ["Suporte"] = {
        Level      = 1,
        Color      = "#10B981",
        BgColor    = "#10B98120",
        CanPromote = false,
        CanDemote  = false,
        CanManage  = false,
    },
}

Config.StaffHierarchy = {
    "Suporte",
    "Moderador",
    "Administrador",
    "Supervisor",
    "Diretor",
    "C-Level",
}
