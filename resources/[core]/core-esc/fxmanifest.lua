fx_version 'cerulean'
game 'gta5'

author 'core-esc'
description 'Menu ESC (core-esc) - baseado no europa_esc'
version '1.0.0'
lua54 'yes'

-- UI (build do web-side)
ui_page 'web/dist/index.html'

shared_scripts {
    '@vrp/lib/utils.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua',
    'client/ranking.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/**/*'
}
