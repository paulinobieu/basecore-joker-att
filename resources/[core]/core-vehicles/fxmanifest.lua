fx_version 'cerulean'
lua54 'yes'
game 'gta5'
author 'core-vehicles'

files {
    'web-side/dist/*',
    'web-side/dist/**/*',
    'config/*.js'
}

shared_scripts {
    '@vrp/lib/utils.lua',
    '@vrp/config/Global.lua',
    'config/framework.lua',
    'config/general.lua',
    'config/commands.lua',
    'config/vehicles.lua',
    'config/dealership.lua',
    'config/garages.lua',
    'config/mechanics.lua',
    'config/notify.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server-side/framework.lua',
    'server-side/vehicles.lua',
    'server-side/core.lua',
    'server-side/dealership.lua',
    'server-side/garages.lua',
    'server-side/garage-manager.lua',
    'server-side/vehicle-register.lua',
    'server-side/mechanics.lua',
    'server-side/admin.lua',
    'server-side/compat.lua',
}

client_scripts {
    'client-side/framework.lua',
    'client-side/core.lua',
    'client-side/vehicles.lua',
    'client-side/dealership.lua',
    'client-side/garages.lua',
    'client-side/garage-manager.lua',
    'client-side/vehicle-register.lua',
    'client-side/mechanics.lua',
    'client-side/vehmenu.lua',
    'client-side/threads.lua',
}

ui_page 'web-side/dist/index.html'
