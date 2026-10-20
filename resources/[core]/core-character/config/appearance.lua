-----------------------------------------------------------------------------------------------------------------------------------------
-- APARÊNCIA
-- Dados de visual usados pela criação e pela barbearia.
--
--   Appearance.HairOverlays → micropigmentação aplicada junto do cabelo,
--                             indexada pelo valor de hairOverlay
--   Appearance.HiddenHairs  → cabelos tirados da criação e da barbearia
--   Appearance.Clothes      → roupa dentro do criador e ao nascer
--   Appearance.SelectAnims  → poses sorteadas na tela de seleção
--   Appearance.Cutscene     → figurino dos figurantes da cutscene de chegada
-----------------------------------------------------------------------------------------------------------------------------------------

Appearance = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SOBREPOSIÇÕES DE CABELO
-----------------------------------------------------------------------------------------------------------------------------------------
Appearance.HairOverlays = {
    Male = {
        [0] = { collection = "mpbeach_overlays", overlay = "FM_Hair_Fuzz" },
        [1] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_001" },
        [2] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_002" },
        [3] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_003" },
        [4] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_004" },
        [5] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_005" },
        [6] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_006" },
        [7] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_007" },
        [8] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_008" },
        [9] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_009" },
        [10] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_013" },
        [11] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_002" },
        [12] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_011" },
        [13] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_012" },
        [14] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_014" },
        [15] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_015" },
        [16] = { collection = "multiplayer_overlays", overlay = "NGBea_M_Hair_000" },
        [17] = { collection = "multiplayer_overlays", overlay = "NGBea_M_Hair_001" },
        [18] = { collection = "multiplayer_overlays", overlay = "NGBus_M_Hair_000" },
        [19] = { collection = "multiplayer_overlays", overlay = "NGBus_M_Hair_001" },
        [20] = { collection = "multiplayer_overlays", overlay = "NGHip_M_Hair_000" },
        [21] = { collection = "multiplayer_overlays", overlay = "NGHip_M_Hair_001" },
        [22] = { collection = "multiplayer_overlays", overlay = "NGInd_M_Hair_000" },
        [24] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_000" },
        [25] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_001" },
        [26] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_002" },
        [27] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_003" },
        [28] = { collection = "mplowrider2_overlays", overlay = "LR_M_Hair_004" },
        [29] = { collection = "mplowrider2_overlays", overlay = "LR_M_Hair_005" },
        [30] = { collection = "mplowrider2_overlays", overlay = "LR_M_Hair_006" },
        [31] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_000_M" },
        [32] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_001_M" },
        [33] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_002_M" },
        [34] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_003_M" },
        [35] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_004_M" },
        [36] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_005_M" },
        [37] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_001" },
        [38] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_002" },
        [39] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_003" },
        [40] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_004" },
        [41] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_005" },
        [42] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_006" },
        [43] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_007" },
        [44] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_008" },
        [45] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_009" },
        [46] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_013" },
        [47] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_002" },
        [48] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_011" },
        [49] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_012" },
        [50] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_014" },
        [51] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_015" },
        [52] = { collection = "multiplayer_overlays", overlay = "NGBea_M_Hair_000" },
        [53] = { collection = "multiplayer_overlays", overlay = "NGBea_M_Hair_001" },
        [54] = { collection = "multiplayer_overlays", overlay = "NGBus_M_Hair_000" },
        [55] = { collection = "multiplayer_overlays", overlay = "NGBus_M_Hair_001" },
        [56] = { collection = "multiplayer_overlays", overlay = "NGHip_M_Hair_000" },
        [57] = { collection = "multiplayer_overlays", overlay = "NGHip_M_Hair_001" },
        [58] = { collection = "multiplayer_overlays", overlay = "NGInd_M_Hair_000" },
        [59] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_000" },
        [60] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_001" },
        [61] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_002" },
        [62] = { collection = "mplowrider_overlays", overlay = "LR_M_Hair_003" },
        [63] = { collection = "mplowrider2_overlays", overlay = "LR_M_Hair_004" },
        [64] = { collection = "mplowrider2_overlays", overlay = "LR_M_Hair_005" },
        [65] = { collection = "mplowrider2_overlays", overlay = "LR_M_Hair_006" },
        [66] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_000_M" },
        [67] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_001_M" },
        [68] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_002_M" },
        [69] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_003_M" },
        [70] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_004_M" },
        [71] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_005_M" },
        [72] = { collection = "mpgunrunning_overlays", overlay = "MP_Gunrunning_Hair_M_000_M" },
        [73] = { collection = "mpgunrunning_overlays", overlay = "MP_Gunrunning_Hair_M_001_M" },
    },

    Female = {
        [0] = { collection = "mpbeach_overlays", overlay = "FM_Hair_Fuzz" },
        [1] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_001" },
        [2] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_002" },
        [3] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_003" },
        [4] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_004" },
        [5] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_005" },
        [6] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_006" },
        [7] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_007" },
        [8] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_008" },
        [9] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_009" },
        [10] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_010" },
        [11] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_011" },
        [12] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_012" },
        [13] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_013" },
        [14] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_014" },
        [15] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_015" },
        [16] = { collection = "multiplayer_overlays", overlay = "NGBea_F_Hair_000" },
        [17] = { collection = "multiplayer_overlays", overlay = "NGBea_F_Hair_001" },
        [18] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_007" },
        [19] = { collection = "multiplayer_overlays", overlay = "NGBus_F_Hair_000" },
        [20] = { collection = "multiplayer_overlays", overlay = "NGBus_F_Hair_001" },
        [21] = { collection = "multiplayer_overlays", overlay = "NGBea_F_Hair_001" },
        [22] = { collection = "multiplayer_overlays", overlay = "NGHip_F_Hair_000" },
        [23] = { collection = "multiplayer_overlays", overlay = "NGInd_F_Hair_000" },
        [25] = { collection = "mplowrider_overlays", overlay = "LR_F_Hair_000" },
        [26] = { collection = "mplowrider_overlays", overlay = "LR_F_Hair_001" },
        [27] = { collection = "mplowrider_overlays", overlay = "LR_F_Hair_002" },
        [28] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_003" },
        [29] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_003" },
        [30] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_004" },
        [31] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_006" },
        [32] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_000_F" },
        [33] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_001_F" },
        [34] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_002_F" },
        [35] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_003_F" },
        [36] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_003" },
        [37] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_006_F" },
        [38] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_004_F" },
        [39] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_001" },
        [40] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_002" },
        [41] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_003" },
        [42] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_004" },
        [43] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_005" },
        [44] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_006" },
        [45] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_007" },
        [46] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_008" },
        [47] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_009" },
        [48] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_010" },
        [49] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_011" },
        [50] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_012" },
        [51] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_013" },
        [52] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_014" },
        [53] = { collection = "multiplayer_overlays", overlay = "NG_M_Hair_015" },
        [54] = { collection = "multiplayer_overlays", overlay = "NGBea_F_Hair_000" },
        [55] = { collection = "multiplayer_overlays", overlay = "NGBea_F_Hair_001" },
        [56] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_007" },
        [57] = { collection = "multiplayer_overlays", overlay = "NGBus_F_Hair_000" },
        [58] = { collection = "multiplayer_overlays", overlay = "NGBus_F_Hair_001" },
        [59] = { collection = "multiplayer_overlays", overlay = "NGBea_F_Hair_001" },
        [60] = { collection = "multiplayer_overlays", overlay = "NGHip_F_Hair_000" },
        [61] = { collection = "multiplayer_overlays", overlay = "NGInd_F_Hair_000" },
        [62] = { collection = "mplowrider_overlays", overlay = "LR_F_Hair_000" },
        [63] = { collection = "mplowrider_overlays", overlay = "LR_F_Hair_001" },
        [64] = { collection = "mplowrider_overlays", overlay = "LR_F_Hair_002" },
        [65] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_003" },
        [66] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_003" },
        [67] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_004" },
        [68] = { collection = "mplowrider2_overlays", overlay = "LR_F_Hair_006" },
        [69] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_000_F" },
        [70] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_001_F" },
        [71] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_002_F" },
        [72] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_003_F" },
        [73] = { collection = "multiplayer_overlays", overlay = "NG_F_Hair_003" },
        [74] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_006_F" },
        [75] = { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_004_F" },
        [76] = { collection = "mpgunrunning_overlays", overlay = "MP_Gunrunning_Hair_F_000_F" },
        [77] = { collection = "mpgunrunning_overlays", overlay = "MP_Gunrunning_Hair_F_001_F" },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CABELOS ESCONDIDOS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índices que não aparecem na criação nem na barbearia. Aceita índice solto
-- ("14") ou faixa fechada ("36-40"). Deixe vazio para oferecer todos.
--
-- É uma escolha do servidor, não um limite de conteúdo: um cabelo já gravado
-- num personagem continua vestido, só não dá para escolher de novo.
Appearance.HiddenHairs = {
    Male   = {},
    Female = {},
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUPAS INICIAIS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Creator → vestida enquanto a criação está aberta, para o corpo ficar
--           visível enquanto o jogador ajusta rosto e herança.
-- Spawn   → vestida quando o personagem novo entra no mundo.
Appearance.Clothes = {
    Creator = {
        Male = {
            ["arms"]      = { ["item"] = 15, ["texture"] = 0 },
            ["glass"]     = { ["item"] = -1, ["texture"] = -1 },
            ["mask"]      = { ["item"] = 0, ["texture"] = 0 },
            ["torso"]     = { ["item"] = 15, ["texture"] = 0 },
            ["pants"]     = { ["item"] = 61, ["texture"] = 0 },
            ["shoes"]     = { ["item"] = 34, ["texture"] = 0 },
            ["vest"]      = { ["item"] = 0, ["texture"] = 0 },
            ["watch"]     = { ["item"] = -1, ["texture"] = -1 },
            ["backpack"]  = { ["item"] = 0, ["texture"] = 0 },
            ["ear"]       = { ["item"] = -1, ["texture"] = -1 },
            ["bracelet"]  = { ["item"] = -1, ["texture"] = -1 },
            ["tshirt"]    = { ["item"] = 15, ["texture"] = 0 },
            ["hat"]       = { ["item"] = -1, ["texture"] = -1 },
            ["decals"]    = { ["item"] = 0, ["texture"] = 0 },
            ["accessory"] = { ["item"] = 0, ["texture"] = 0 },
        },

        Female = {
            ["arms"]      = { ["item"] = 15, ["texture"] = 0 },
            ["glass"]     = { ["item"] = -1, ["texture"] = -1 },
            ["mask"]      = { ["item"] = 0, ["texture"] = 0 },
            ["torso"]     = { ["item"] = 15, ["texture"] = 0 },
            ["pants"]     = { ["item"] = 15, ["texture"] = 0 },
            ["shoes"]     = { ["item"] = 35, ["texture"] = 0 },
            ["vest"]      = { ["item"] = 0, ["texture"] = 0 },
            ["watch"]     = { ["item"] = -1, ["texture"] = -1 },
            ["backpack"]  = { ["item"] = 0, ["texture"] = 0 },
            ["ear"]       = { ["item"] = -1, ["texture"] = -1 },
            ["bracelet"]  = { ["item"] = -1, ["texture"] = -1 },
            ["tshirt"]    = { ["item"] = 15, ["texture"] = 0 },
            ["hat"]       = { ["item"] = -1, ["texture"] = -1 },
            ["decals"]    = { ["item"] = 0, ["texture"] = 0 },
            ["accessory"] = { ["item"] = 0, ["texture"] = 0 },
        },
    },

    Spawn = {
        Male = {
            ["arms"]      = { ["item"] = 5, ["texture"] = 0 },
            ["glass"]     = { ["item"] = -1, ["texture"] = -1 },
            ["mask"]      = { ["item"] = 0, ["texture"] = 0 },
            ["torso"]     = { ["item"] = 5, ["texture"] = 0 },
            ["pants"]     = { ["item"] = 3, ["texture"] = 0 },
            ["shoes"]     = { ["item"] = 138, ["texture"] = 1 },
            ["vest"]      = { ["item"] = 0, ["texture"] = 0 },
            ["watch"]     = { ["item"] = -1, ["texture"] = -1 },
            ["backpack"]  = { ["item"] = 0, ["texture"] = 0 },
            ["ear"]       = { ["item"] = -1, ["texture"] = -1 },
            ["bracelet"]  = { ["item"] = -1, ["texture"] = -1 },
            ["tshirt"]    = { ["item"] = 15, ["texture"] = 0 },
            ["hat"]       = { ["item"] = -1, ["texture"] = -1 },
            ["decals"]    = { ["item"] = 0, ["texture"] = 0 },
            ["accessory"] = { ["item"] = 0, ["texture"] = 0 },
        },

        Female = {
            ["arms"]      = { ["item"] = 4, ["texture"] = 0 },
            ["glass"]     = { ["item"] = -1, ["texture"] = -1 },
            ["mask"]      = { ["item"] = 0, ["texture"] = 0 },
            ["torso"]     = { ["item"] = 13, ["texture"] = 0 },
            ["pants"]     = { ["item"] = 8, ["texture"] = 0 },
            ["shoes"]     = { ["item"] = 141, ["texture"] = 0 },
            ["vest"]      = { ["item"] = 0, ["texture"] = 0 },
            ["watch"]     = { ["item"] = -1, ["texture"] = -1 },
            ["backpack"]  = { ["item"] = 0, ["texture"] = 0 },
            ["ear"]       = { ["item"] = -1, ["texture"] = -1 },
            ["bracelet"]  = { ["item"] = -1, ["texture"] = -1 },
            ["tshirt"]    = { ["item"] = 15, ["texture"] = 0 },
            ["hat"]       = { ["item"] = -1, ["texture"] = -1 },
            ["decals"]    = { ["item"] = 0, ["texture"] = 0 },
            ["accessory"] = { ["item"] = 0, ["texture"] = 0 },
        },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PERSONAGEM PADRÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Estado de partida da criação e alvo do reset. Toda chave aqui precisa
-- existir no mapeamento da interface.
Appearance.Default = {
    fathersID = 0, mothersID = 21,
    skinFirstID = 0, skinSecondID = 0,
    shapeMix = 0.5, skinMix = 0.80,

    eyesColor = 0, eyesOpening = 0.0,
    eyebrowsHeight = 0, eyebrowsWidth = 0,

    noseWidth = 0, noseHeight = 0, noseLength = 0,
    noseBridge = 0, noseTip = 0, noseShift = 0,

    cheekboneHeight = 0, cheekboneWidth = 0, cheeksWidth = 0,
    jawWidth = 0, jawHeight = 0,
    chinLength = 0, chinPosition = 0, chinWidth = 0, chinShape = 0,
    neckWidth = 0,

    hairModel = 0, hairOverlay = 0,
    firstHairColor = 0, secondHairColor = 0,

    eyebrowsModel = 0, eyebrowsIntensity = 0.99, eyebrowsColor = 0,
    beardModel = -1, beardIntensity = 0.99, beardColor = 0,
    chestModel = -1, chestOpacity = 0.99, chestColor = 0,

    lips = 0,
    lipstickModel = -1, lipstickIntensity = 0.99, lipstickColor = 0,
    blushModel = -1, blushIntensity = 0.99, blushColor = 0,
    makeupModel = -1, makeupIntensity = 0.99, makeupColor = 0,

    blemishesModel = -1, ageingModel = -1, complexionModel = -1,
    sundamageModel = -1, frecklesModel = -1, frecklesIntensity = 0.99,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- POSES DA SELEÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Appearance.SelectAnims = {
    { "anim@amb@casino@out_of_money@ped_male@01b@base", "base" },
    { "rcmpaparazzo_3big_1", "_action_guard_a" },
    { "anim@miss@low@fin@lamar@", "idle" },
    { "clothingtie", "try_tie_positive_b" },
    { "clothingtie", "outro" },
    { "amb@world_human_muscle_flex@arms_at_side@idle_a", "idle_a" },
    { "oddjobs@assassinate@guard", "unarmed_fold_arms" },
    { "oddjobs@assassinate@vice@hooker", "argue_a" },
    { "timetable@gardener@smoking_joint", "idle_cough" },
    { "amb@code_human_police_investigate@idle_b", "idle_f" },
    { "amb@code_human_police_investigate@idle_b", "idle_e" },
    { "amb@world_human_guard_patrol@male@idle_b", "idle_e" },
    { "random@mugging5", "001445_01_gangintimidation_1_female_idle_b" },
    { "anim@mp_player_intcelebrationfemale@knuckle_crunch", "knuckle_crunch" },
    { "random@shop_tattoo", "_idle_a" },
    { "mp_deathmatch_intros@melee@2h", "intro_male_melee_2h_b" },
    { "mp_deathmatch_intros@melee@1h", "intro_male_melee_1h_c" },
    { "anim@deathmatch_intros@unarmed", "intro_male_unarmed_d" },
    { "anim@deathmatch_intros@unarmed", "intro_male_unarmed_a" },
    { "oddjobs@basejump@", "ped_d_loop" },
    { "friends@fra@ig_1", "base_idle" },
    { "misscarsteal4@aliens", "rehearsal_base_idle_director" },
    { "anim@mp_player_intcelebrationfemale@stinker", "stinker" },
    { "anim@mp_fm_event@intro", "beast_transform" },
    { "anim@amb@casino@valet_scenario@pose_d@", "base_a_m_y_vinewood_01" },
    { "anim@amb@casino@shop@ped_female@01a@base", "base" },
    { "anim@amb@casino@valet_scenario@pose_c@", "shuffle_feet_a_m_y_vinewood_01" },
    { "anim@amb@casino@hangout@ped_male@stand@03a@idles_convo", "idle_a" },
    { "amb@world_human_cop_idles@female@idle_b", "idle_e" },
    { "anim@amb@casino@hangout@ped_male@stand@02b@idles", "idle_a" },
    { "amb@world_human_hang_out_street@male_c@idle_a", "idle_b" },
    { "random@street_race", "_car_b_lookout" },
    { "random@shop_gunstore", "_idle" },
    { "anim@mp_player_intselfiedock", "idle_a" },
    { "anim@mp_player_intincaryou_locobodhi@ds@", "idle_a" },
    { "anim@mp_player_intcelebrationmale@finger_kiss", "finger_kiss" },
    { "rcmbarry", "base" },
    { "random@hitch_lift", "idle_f" },
    { "rcmcollect_paperleadinout@", "meditiate_idle" },
    { "timetable@amanda@ig_4", "ig_4_base" },
    { "mp_fm_intro_cut", "base_loop" },
    { "missminuteman_1ig_2", "tasered_2" },
    { "misscommon@response", "bring_it_on" },
    { "anim@deathmatch_intros@unarmed", "intro_male_unarmed_e" },
    { "mini@triathlon", "idle_e" },
    { "anim@deathmatch_intros@unarmed", "intro_male_unarmed_c" },
    { "mini@triathlon", "idle_f" },
    { "mini@triathlon", "idle_d" },
    { "rcmfanatic1maryann_stretchidle_b", "idle_e" },
    { "timetable@reunited@ig_2", "jimmy_getknocked" },
    { "mp_player_int_upperpeace_sign", "mp_player_int_peace_sign" },
    { "anim@mp_player_intupperpeace", "idle_a" },
    { "anim@mp_player_intupperslow_clap", "idle_a" },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CUTSCENE DE CHEGADA
-----------------------------------------------------------------------------------------------------------------------------------------
Appearance.Cutscene = {
    -- Nome de cada figurante dentro da cutscene MP_INTRO_CONCAT.
    Peds = {
        [0] = "MP_Plane_Passenger_1",
        [1] = "MP_Plane_Passenger_2",
        [2] = "MP_Plane_Passenger_3",
        [3] = "MP_Plane_Passenger_4",
        [4] = "MP_Plane_Passenger_5",
        [5] = "MP_Plane_Passenger_6",
        [6] = "MP_Plane_Passenger_7",
    },

    -- Índices dos figurantes que usam o modelo feminino.
    FemaleSlots = { [1] = true, [2] = true, [4] = true, [6] = true },

    -- Componentes por figurante: { componentId, drawable, texture }.
    Outfits = {
        [0] = { { 0, 21, 0 }, { 1, 0, 0 }, { 2, 9, 0 }, { 3, 1, 0 }, { 4, 9, 0 }, { 5, 0, 0 }, { 6, 4, 8 }, { 7, 0, 0 }, { 8, 15, 0 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 10, 0 } },
        [1] = { { 0, 13, 0 }, { 1, 0, 0 }, { 2, 5, 4 }, { 3, 1, 0 }, { 4, 10, 0 }, { 5, 0, 0 }, { 6, 10, 0 }, { 7, 11, 2 }, { 8, 13, 6 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 10, 0 } },
        [2] = { { 0, 15, 0 }, { 1, 0, 0 }, { 2, 1, 4 }, { 3, 1, 0 }, { 4, 0, 1 }, { 5, 0, 0 }, { 6, 1, 7 }, { 7, 0, 0 }, { 8, 2, 9 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 6, 0 } },
        [3] = { { 0, 14, 0 }, { 1, 0, 0 }, { 2, 5, 3 }, { 3, 3, 0 }, { 4, 1, 6 }, { 5, 0, 0 }, { 6, 11, 5 }, { 7, 0, 0 }, { 8, 2, 0 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 3, 12 } },
        [4] = { { 0, 18, 0 }, { 1, 0, 0 }, { 2, 15, 3 }, { 3, 15, 0 }, { 4, 2, 5 }, { 5, 0, 0 }, { 6, 4, 6 }, { 7, 4, 0 }, { 8, 3, 0 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 4, 0 } },
        [5] = { { 0, 27, 0 }, { 1, 0, 0 }, { 2, 7, 3 }, { 3, 11, 0 }, { 4, 4, 8 }, { 5, 0, 0 }, { 6, 13, 14 }, { 7, 5, 3 }, { 8, 3, 0 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 2, 7 } },
        [6] = { { 0, 16, 0 }, { 1, 0, 0 }, { 2, 15, 1 }, { 3, 3, 0 }, { 4, 5, 6 }, { 5, 0, 0 }, { 6, 2, 8 }, { 7, 0, 0 }, { 8, 2, 0 }, { 9, 0, 0 }, { 10, 0, 0 }, { 11, 3, 7 } },
    },
}
