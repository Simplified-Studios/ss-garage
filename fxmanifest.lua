fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Simplified Studios Garage'
version '1.2.0'

ui_page 'html/index.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/cl_functions.lua',
    'client/cl_main.lua',
}

server_scripts {
    'config.lua',
    'server/sv_main.lua',
    'server/sv_functions.lua',
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