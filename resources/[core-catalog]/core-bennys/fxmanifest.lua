fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "config/language.lua",
    "config/colors.lua",
    "config/mods.lua",
    "config/prices.lua",
    "config/engines.lua",
    "shared/configuration.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/customization.lua",
    "client/modules/mechanic.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "token.lua",
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "server/modules/database.lua",
    "server/modules/service.lua",
    "server/modules/repair.lua",
    "server/server.lua",
}

files {
    "web/index.html",
    "web/**/*",
    "sounds/ui/*.ogg",
    "sounds/audioconfig/**",
    "sounds/sfx/**/**",
    "stream/**/*",
    "carcols_gen9.meta",
    "carmodcols_gen9.meta",
}

data_file "CARCOLS_GEN9_FILE" "carcols_gen9.meta"
data_file "CARMODCOLS_GEN9_FILE" "carmodcols_gen9.meta"

-- Bancos de áudio dos motores disponíveis no catálogo.
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/lambov10_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/lambov10_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_lambov10"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/tagt3flat6_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/tagt3flat6_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_tagt3flat6"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/ta176m177_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/ta176m177_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_ta176m177"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/ta488f154_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/ta488f154_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_ta488f154"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/ta023l539_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/ta023l539_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_ta023l539"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/kc42brz14_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/kc42brz14_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/kc42brz14_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_kc42brz14"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/s63b44_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/s63b44_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_s63b44"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/kc46nisr34ztune_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/kc46nisr34ztune_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_kc46nisr34ztune"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/kc41gt86na_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/kc41gt86na_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/kc41gt86na_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_kc41gt86na"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/ta4b11_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/ta4b11_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_ta4b11"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/kc31m3gtr_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/kc31m3gtr_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/kc31m3gtr_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_kc31m3gtr"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/chevroletlt4_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/chevroletlt4_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_chevroletlt4"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/tacumminsb_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/tacumminsb_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_tacumminsb"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/subaruej20_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/subaruej20_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_subaruej20"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/musv8_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/musv8_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_musv8"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/brabus850_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/brabus850_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_brabus850"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/shonen_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/shonen_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/shonen_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_shonen"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/toysupmk4_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/toysupmk4_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_toysupmk4"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/rb26dett_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/rb26dett_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/rb26dett_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_rb26dett"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/rotary7_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/rotary7_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_rotary7"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/m297zonda_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/m297zonda_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/m297zonda_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_m297zonda"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/avesv_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/avesv_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_avesv"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/diablov12_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/diablov12_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_diablov12"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/f40v8_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/f40v8_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_f40v8"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/f50v12_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/f50v12_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_f50v12"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/ferrarif12_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/ferrarif12_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_ferrarif12"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/murciev12_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/murciev12_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_murciev12"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/sestov10_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/sestov10_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_sestov10"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/m158huayra_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/m158huayra_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/m158huayra_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_m158huayra"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/k20a_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/k20a_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/k20a_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_k20a"

data_file "AUDIO_SYNTHDATA" "sounds/audioconfig/gt3flat6_amp.dat"
data_file "AUDIO_GAMEDATA" "sounds/audioconfig/gt3flat6_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/gt3flat6_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_gt3flat6"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/predatorv8_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/predatorv8_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_predatorv8"

data_file "AUDIO_GAMEDATA" "sounds/audioconfig/p60b40_game.dat"
data_file "AUDIO_SOUNDDATA" "sounds/audioconfig/p60b40_sounds.dat"
data_file "AUDIO_WAVEPACK" "sounds/sfx/dlc_p60b40"
