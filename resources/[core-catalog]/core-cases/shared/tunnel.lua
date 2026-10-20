if IsDuplicityVersion() then
    Tunnel = module("vrp", "lib/Tunnel")
    Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPC = Tunnel.getInterface("vRP")

    core = {}

    Tunnel.bindInterface(GetCurrentResourceName(), core)
    clientAPI = Tunnel.getInterface(GetCurrentResourceName())
else
    Tunnel = module("vrp", "lib/Tunnel")
    Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPC = Tunnel.getInterface("vRP")

    core = {}

    Tunnel.bindInterface(GetCurrentResourceName(), core)
    serverAPI = Tunnel.getInterface(GetCurrentResourceName())
end
