fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Simplified Studios Garage'
version '0.05'

ui_page 'html/index.html'

dependencies {
    'PolyZone',
}

shared_scripts {
    'config.lua',
    'locales/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/qb.lua',
    'client/esx.lua',
    'client/cl_main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

files {
    'html/img/*.png',
    'html/img/*.jpg',
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

escrow_ignore {
    'client/*.lua',
    'server/*.lua',
    'locales/*.lua',
    'config.lua',
}
