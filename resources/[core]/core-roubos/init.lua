--[[
    core-roubos :: init.lua
    Inicializa Tunnel/Proxy do vRP e expõe globais compartilhadas:
        vRP, vRPC, vCLIENT, vSERVER, lRoubos
--]]

Tunnel = module('vrp', 'lib/Tunnel')
Proxy  = module('vrp', 'lib/Proxy')
vRP    = Proxy.getInterface('vRP')

local RESOURCE = 'core-roubos'

lRoubos = {}
Tunnel.bindInterface(RESOURCE, lRoubos)

if IsDuplicityVersion() then
    vRPC    = Tunnel.getInterface('vRP')
    vCLIENT = Tunnel.getInterface(RESOURCE)
else
    vSERVER = Tunnel.getInterface(RESOURCE)
end
