fx_version "bodacious"
game 'gta5'

author "Nagasakicode - @CORE NETWORK"
this_is_a_map 'yes'

dependency 'xsound'
dependency 'oxmysql'

--* UI PAGE *--
ui_page "web/index.html"

files {
    "web/**/*"
}

--* CLIENT-SIDE *--

client_scripts {
    "client/client.lua",
    "client/class/adapter.lua",
    "client/class/presentation.lua",
    "client/class/world.lua",
    "client/class/teamregistry.lua",
}

--* SERVER-SIDE *--

server_scripts {
    "@oxmysql/lib/MySQL.lua",

    "server/class/framework.lua",
    "server/class/adapter.lua",

    "server/class/round.lua",

    "server/class/duel.lua",
    "server/server.lua",

    "token.lua"
}

--* SHARED FILES *--

shared_scripts {
    "@vrp/lib/utils.lua",
    "shared/tunnel.lua",
    "shared/config.lua",
    "shared/util.lua",
}

--* SMOKE FILES *--

files {
	"data/*.meta"
}

data_file "WEAPON_METADATA_FILE" "data/weaponarchetypes.meta"
data_file "WEAPON_ANIMATIONS_FILE" "data/weaponanimations.meta"
data_file "LOADOUTS_FILE" "data/loadouts.meta"
data_file "WEAPONINFO_FILE" "data/weapons.meta"
data_file "PED_PERSONALITY_FILE" "data/pedpersonality.meta"
