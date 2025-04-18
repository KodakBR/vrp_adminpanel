local isAdmin = false
local adminPanelOpen = false
local adminLevel = nil

-- Constantes para comandos
local COMMANDS = {
    OPEN_PANEL = {"tx", "txadmin", "adminpanel"},
    NOCLIP = "noclip",
    GODMODE = "godmode",
    SPECTATE = "spectate"
}

-- Local cache para os jogadores
local playersCache = {}
local resourcesCache = {}
local serverMetrics = {
    cpu = {},
    ram = {},
    players = {},
    timestamp = {}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- VERIFICAÇÃO DE ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_adminpanel:setIsAdmin")
AddEventHandler("vrp_adminpanel:setIsAdmin", function(status, level)
    isAdmin = status
    adminLevel = level
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- INICIALIZAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    -- Verificar a cada 10 segundos se o jogador é admin
    while true do
        TriggerServerEvent("vrp_adminpanel:checkIsAdmin")
        Wait(10000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD PARA COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    for _, cmd in ipairs(COMMANDS.OPEN_PANEL) do
        RegisterCommand(cmd, function()
            if isAdmin then
                ToggleAdminPanel()
            else
                TriggerEvent("Notify", "negado", "Você não tem permissão para acessar o painel administrativo.")
            end
        end, false)
    end

    -- Registrar atalho de teclado (F3)
    RegisterKeyMapping(COMMANDS.OPEN_PANEL[1], "Abrir Painel Admin", "keyboard", "F3")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE ADMIN PANEL
-----------------------------------------------------------------------------------------------------------------------------------------
function ToggleAdminPanel()
    adminPanelOpen = not adminPanelOpen
    
    if adminPanelOpen then
        -- Solicitar dados atualizados do servidor
        TriggerServerEvent("vrp_adminpanel:getPlayers")
        TriggerServerEvent("vrp_adminpanel:getResources")
        TriggerServerEvent("vrp_adminpanel:getServerMetrics")
        
        -- Abrir a NUI
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            adminLevel = adminLevel
        })
    else
        -- Fechar a NUI
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "close"
        })
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS DE RECEBIMENTO DE DADOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_adminpanel:receivePlayersData")
AddEventHandler("vrp_adminpanel:receivePlayersData", function(players)
    playersCache = players
    
    if adminPanelOpen then
        SendNUIMessage({
            action = "updatePlayers",
            players = players
        })
    end
end)

RegisterNetEvent("vrp_adminpanel:receiveResourcesData")
AddEventHandler("vrp_adminpanel:receiveResourcesData", function(resources)
    resourcesCache = resources
    
    if adminPanelOpen then
        SendNUIMessage({
            action = "updateResources",
            resources = resources
        })
    end
end)

RegisterNetEvent("vrp_adminpanel:receiveServerMetrics")
AddEventHandler("vrp_adminpanel:receiveServerMetrics", function(metrics)
    serverMetrics = metrics
    
    if adminPanelOpen then
        SendNUIMessage({
            action = "updateMetrics",
            metrics = metrics
        })
    end
end)

RegisterNetEvent("vrp_adminpanel:receiveServerLog")
AddEventHandler("vrp_adminpanel:receiveServerLog", function(logData)
    if adminPanelOpen then
        SendNUIMessage({
            action = "addLogEntry",
            log = logData
        })
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES AUXILIARES
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 215)
    
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0150, 0.030 + factor, 0.030, 41, 11, 41, 100)
end