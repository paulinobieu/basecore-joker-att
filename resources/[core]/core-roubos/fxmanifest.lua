

fx_version 'bodacious'
game       'gta5'

author      'bkvini.ofc1'
description 'Sistema de roubos com painel administrativo, killfeed e histórico'
version     '2.0.0'

use_fxv2_oal 'yes'
lua54        'yes'

ui_page 'ui/index.html'

files {
    'ui/*',
    'ui/**/*',
}

shared_scripts {
    'shared/*.lua',
}

client_scripts {
    '@vrp/lib/utils.lua',
    'init.lua',
    'client/**/*.lua',
}

server_scripts {
    '@vrp/lib/utils.lua',
    'init.lua',
    'server/**/*.lua',
}
