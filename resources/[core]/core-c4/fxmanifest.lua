fx_version "cerulean"
game "gta5"
lua54 "yes"
ui_page "web-side/index.html"

shared_scripts {
    "@vrp/config/Native.lua",
    "@vrp/lib/Utils.lua",
    "@vrp/lib/Proxy.lua",
    "@vrp/lib/Tunnel.lua",
    "shared/config.lua",
}
client_script {
    "client-side/*",
    "@vrp/config/Native.lua"
}
server_script {
    "@vrp/config/Global.lua",
	"@vrp/config/Item.lua",
	"@vrp/lib/Utils.lua",
    "server-side/*"
}

files {
    "web-side/*"
}