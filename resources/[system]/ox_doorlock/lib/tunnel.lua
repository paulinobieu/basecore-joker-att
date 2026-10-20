Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
Resource = GetCurrentResourceName()
IsServerSide = IsDuplicityVersion()

if IsServerSide then
  vRP = Proxy.getInterface("vRP")
  vRPclient = Tunnel.getInterface("vRP")

  RegisterTunnel = {}
  Tunnel.bindInterface(Resource, RegisterTunnel)

  vCLIENT = Tunnel.getInterface(Resource)
else
  vRP = Proxy.getInterface("vRP")

  RegisterTunnel = {}
  Tunnel.bindInterface(Resource, RegisterTunnel)

  vSERVER = Tunnel.getInterface(Resource)
end