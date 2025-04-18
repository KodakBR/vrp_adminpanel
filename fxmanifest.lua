fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vRP Admin Panel'
author 'KodakBR'
description 'Painel administrativo in-game inspirado no txAdmin para framework vRP'
version '1.0.0'

ui_page 'web/build/index.html'

client_scripts {
    '@vrp/lib/Utils.lua',
    'client/main.lua',
    'client/nui.lua',
    'client/commands.lua'
}

server_scripts {
    '@vrp/lib/Utils.lua',
    'server/main.lua',
    'server/commands.lua',
    'server/players.lua',
    'server/resources.lua',
    'server/metrics.lua',
    'server/logs.lua',
    'server/permissions.lua'
}

files {
    'web/build/index.html',
    'web/build/**/*'
}

dependencies {
    'vrp'
}