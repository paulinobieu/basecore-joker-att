fx_version 'cerulean'
game {'gta5'}

version '1.0.2'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua',
}

client_scripts {
    "@vrp/lib/utils.lua",
    'modules/**/client.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "@vrp/lib/utils.lua",
    'modules/**/server.lua',
    'server/*.lua',
}

files {
    'web/build/*.*',
    'web/build/**/*.*',
    'locales/*.json',
    'stream/*.ytd',
    'stream/*.ydr',
    'stream/*.ybn',
    'stream/*.ycd'
}

ui_page 'web/build/index.html'

data_file 'DLC_ITYP_REQUEST' 'stream/qua_nails.ytyp'
data_file 'ANIM_DICT' 'stream/adezanim@anim.ycd'

lua54 'yes'
use_experimental_fxv2_oal 'yes'