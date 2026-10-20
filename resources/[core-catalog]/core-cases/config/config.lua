-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CASES · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Cases = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA
-----------------------------------------------------------------------------------------------------------------------------------------
Cases.System = {
    Command = "cases",
    StateBag = "phoneCase",
    Currency = "Diamonds", -- "Diamonds" ou "Dollar"
    PurchaseCooldown = 1500,
    EquipCooldown = 500,
    MaxCartItems = 12,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- IDENTIDADE VISUAL
-----------------------------------------------------------------------------------------------------------------------------------------
Cases.Branding = {
    LogoUrl = "",
    LogoAlt = "Core Network",
    StoreName = "CORE",
    Title = "Cases",
    AccentColor = "#7c6cff",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOJA
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- IMAGENS
-- Image pode ser uma URL completa. Se estiver vazia, a NUI usa a miniatura CSS.
-----------------------------------------------------------------------------------------------------------------------------------------
Cases.Images = {
    BaseUrl = "",
    Extension = ".webp",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CELULAR
-----------------------------------------------------------------------------------------------------------------------------------------
Cases.Phone = {
    DefaultProps = {
        "prop_npc_phone_02",
        "prop_npc_phone",
        "prop_amb_phone",
        "prop_phone_ing",
        "prop_phone_ing_02",
        "prop_phone_ing_03",
        "prop_amb_vallphone",
    },

    Preview = {
        Animation = {
            Dict = "cellphone@",
            Name = "cellphone_text_read_base",
            Flag = 49,
        },
        Hand = {
            Bone = 28422,
            Position = { 0.0, 0.0, 0.0 },
            Rotation = { 0.0, 0.0, 0.0 },
        },
        Showcase = {
            Forward = 0.55,
            Right = 0.15,
            Down = 0.02,
            RotationSpeed = 0.4,
        },
    },

    PropAttach = {
        bunnywish = {
            Position = { 0.012, 0.003, -0.045 },
        },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CATÁLOGO
-----------------------------------------------------------------------------------------------------------------------------------------
Cases.Cases = {
    { Id = "ipbrown", Prop = "ipbrown", Name = "Bear Marrom", Collection = "Bear", Price = 500, Style = "sand", Image = "cases/ipbrown.png" },
    { Id = "bearx_or", Prop = "bearx_or", Name = "Bear X Laranja", Collection = "Bear X", Price = 500, Style = "ruby", Image = "cases/bearx_or.png" },
    { Id = "bearx_b", Prop = "bearx_b", Name = "Bear X Preta", Collection = "Bear X", Price = 500, Style = "onyx", Image = "cases/bearx_b.png" },
    { Id = "bearx_whiteor", Prop = "bearx_whiteor", Name = "Bear X Branca/Laranja", Collection = "Bear X", Price = 500, Style = "sand", Image = "cases/bearx_whiteor.png" },
    { Id = "bearx_w", Prop = "bearx_w", Name = "Bear X Branca", Collection = "Bear X", Price = 500, Style = "mint", Image = "cases/bearx_w.png" },
    { Id = "bowconque_phone", Prop = "bowconque_phone", Name = "Bow Conque", Collection = "Conque", Price = 500, Style = "violet", Image = "cases/bowconque_phone.png" },
    { Id = "bunnywish", Prop = "bunnywish", Name = "Coelho Sonhador", Collection = "Wish", Price = 500, Style = "violet", Image = "cases/bunnywish.png" },
    { Id = "careblue_phone", Prop = "careblue_phone", Name = "Care Azul", Collection = "Care", Price = 500, Style = "ocean", Image = "cases/careblue_phone.png" },
    { Id = "caregpink_phone", Prop = "caregpink_phone", Name = "Care Rosa", Collection = "Care", Price = 500, Style = "ruby", Image = "cases/caregpink_phone.png" },
    { Id = "caregreen_phone", Prop = "caregreen_phone", Name = "Care Verde", Collection = "Care", Price = 500, Style = "mint", Image = "cases/caregreen_phone.png" },
    { Id = "carepurple_phone", Prop = "carepurple_phone", Name = "Care Roxa", Collection = "Care", Price = 500, Style = "violet", Image = "cases/carepurple_phone.png" },
    { Id = "careyellow_phone", Prop = "careyellow_phone", Name = "Care Amarela", Collection = "Care", Price = 500, Style = "sand", Image = "cases/careyellow_phone.png" },
    { Id = "chin_phone", Prop = "chin_phone", Name = "Chin", Collection = "Essentials", Price = 500, Style = "onyx", Image = "cases/chin_phone.png" },
    { Id = "conque_phone", Prop = "conque_phone", Name = "Conque", Collection = "Conque", Price = 500, Style = "ocean", Image = "cases/conque_phone.png" },
    { Id = "nick1_ip", Prop = "nick1_ip", Name = "Couple Zoo Nick 1", Collection = "Couple Zoo", Price = 500, Style = "ocean", Image = "cases/nick1_ip.png" },
    { Id = "nick2_ip", Prop = "nick2_ip", Name = "Couple Zoo Nick 2", Collection = "Couple Zoo", Price = 500, Style = "ocean", Image = "cases/nick2_ip.png" },
    { Id = "judy1_ip", Prop = "judy1_ip", Name = "Couple Zoo Judy 1", Collection = "Couple Zoo", Price = 500, Style = "violet", Image = "cases/judy1_ip.png" },
    { Id = "judy2_ip", Prop = "judy2_ip", Name = "Couple Zoo Judy 2", Collection = "Couple Zoo", Price = 500, Style = "violet", Image = "cases/judy2_ip.png" },
    { Id = "powergreen", Prop = "powergreen", Name = "Powerpuff Verde", Collection = "Powerpuff", Price = 500, Style = "mint", Image = "cases/powergreen.png" },
    { Id = "powerpink", Prop = "powerpink", Name = "Powerpuff Rosa", Collection = "Powerpuff", Price = 500, Style = "ruby", Image = "cases/powerpink.png" },
    { Id = "powerblue", Prop = "powerblue", Name = "Powerpuff Azul", Collection = "Powerpuff", Price = 500, Style = "ocean", Image = "cases/powerblue.png" },
    { Id = "redpanda_phone", Prop = "redpanda_phone", Name = "Red Panda", Collection = "Animals", Price = 500, Style = "ruby", Image = "cases/redpanda_phone.png" },
    { Id = "shiro_phone", Prop = "shiro_phone", Name = "Shiro", Collection = "Essentials", Price = 500, Style = "onyx", Image = "cases/shiro_phone.png" },
    { Id = "y2k_phone", Prop = "y2k_phone", Name = "Y2K", Collection = "Y2K", Price = 500, Style = "sand", Image = "cases/y2k_phone.png" },
}
