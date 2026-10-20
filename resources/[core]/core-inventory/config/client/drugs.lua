Inventory.Drugs = Inventory.Drugs or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Drugs.Interaction = {
    PedRadius = 2.0,
    CancelDistance = 2.0,
    RetryDelay = 5000,
    AnimationDelay = 1000,
    ExchangeDelay = 3000,
    StartAnimation = {Dict = "jh_1_ig_3-2", Name = "cs_jewelass_dual-2"},
    Exchange = {
        CustomerAnimation = {
            Dict = "mp_safehouselost@",
            Name = "package_dropoff"
        },
        Money = {
            Model = "prop_anim_cash_note",
            Bone = 28422,
            Offset = {0.0, 0.0, 0.0},
            Rotation = {90.0, 0.0, 0.0}
        },
        Player = {
            Dict = "mp_safehouselost@",
            Name = "package_dropoff",
            Model = "prop_paper_bag_small",
            Flag = 16,
            Bone = 28422,
            Offset = {0.0, -0.05, 0.05},
            Rotation = {180.0, 0.0, 0.0}
        }
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Drugs.Effects = {
    Cocaine = {Effect = "MinigameTransitionIn", Duration = 30},
    Methamphetamine = {Effect = "Dont_tazeme_bro", Duration = 30},
    Metadone = {
        Effect = "DeathFailMPDark",
        EffectDuration = 90000,
        Duration = 600,
        PlayerMeleeDamage = 1.1,
        PlayerWeaponDamage = 1.1,
        AiMeleeDamage = 7.5,
        AiWeaponDamage = 0.75,
        DefaultAiMeleeDamage = 5.0,
        DefaultAiWeaponDamage = 0.5
    },
    Heroin = {
        Effect = "DrugsMichaelAliensFight",
        EffectDuration = 90000,
        Duration = 900,
        Health = 250,
        DefaultHealth = 200
    },
    Crack = {
        Effect = "HeistCelebPassBW",
        EffectDuration = 300000,
        Duration = 600,
        InitialNeeds = 90000,
        FinalNeeds = 180000
    },
    Joint = {Effect = "DeathFailMPIn", Duration = 30},
    Oxycontin = {Effect = "DrugsMichaelAliensFight", Duration = 30},
    Energetic = {Effect = "HeistTripSkipFade"}
}
