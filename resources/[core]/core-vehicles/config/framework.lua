CreateThreadNow = Citizen.CreateThreadNow
Trace = Citizen.Trace
InvokeNative = Citizen.InvokeNative

CreateThreadNow(function()
    local moduleReturns = {}
    _G["lib-utils"] = function()
        SERVER = IsDuplicityVersion()
        CLIENT = not SERVER

        function table.maxn(t)
            local max = 0
            for k,v in pairs(t) do
                local n = tonumber(k)
                if n and n > max then max = n end
            end
            return max
        end

        function parseInt(v)
            local n = tonumber(v)
            if n == nil then
                return 0
            else
                return math.floor(n)
            end
        end

        local modules = {}
        function require(rsc, path)
            if path == nil then
                path = rsc
                rsc = GetCurrentResourceName()
            end
            local key = rsc..path
            local module = modules[key]
            if module then
                return module
            else
                local code = LoadResourceFile(rsc, path..".lua")
                if code then
                    local f,err = load(code, rsc.."/"..path..".lua")
                    if f then
                        local ok, res = xpcall(f, debug.traceback)
                        if ok then
                            modules[key] = res
                            return res
                        else
                            error("error loading module "..rsc.."/"..path..":"..res)
                        end
                    else
                        error("error parsing module "..rsc.."/"..path..":"..debug.traceback(err))
                    end
                else
                    error("resource file "..rsc.."/"..path..".lua not found")
                end
            end
        end

        local function wait(self)
            local rets = Citizen.Await(self.p)
            if not rets then
                rets = self.r
            end
            return table.unpack(rets,1,table.maxn(rets))
        end

        local function areturn(self, ...)
            self.r = {...}
            self.p:resolve(self.r)
        end

        function async(func)
            if func then
                Citizen.CreateThreadNow(func)
            else
                return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
            end
        end

        module = require
    end
    _G["lib-utils"]()

    _G["lib-tools"] = function()
        if not moduleReturns["lib-tools"] then
            local function module()
                local Tools = {}
                local IDGenerator = {}

                function Tools.newIDGenerator()
                    local r = setmetatable({}, { __index = IDGenerator })
                    r:construct()
                    return r
                end

                function IDGenerator:construct()
                    self:clear()
                end

                function IDGenerator:clear()
                    self.max = 0
                    self.ids = {}
                end

                function IDGenerator:gen()
                    if #self.ids > 0 then
                        return table.remove(self.ids)
                    else
                        local r = self.max
                        self.max = self.max+1
                        return r
                    end
                end

                function IDGenerator:free(id)
                    table.insert(self.ids,id)
                end

                return Tools
            end
            moduleReturns["lib/tools.lua"] = { module() }
        end
        return table.unpack(moduleReturns["lib/tools.lua"])
    end

    _G["lib-tunnel"] = function()
        if not moduleReturns["lib-tunnel"] then
            local function module()
                local Tools = _G["lib-tools"]()

                local TriggerRemoteEvent = nil
                local RegisterLocalEvent = nil
                if SERVER then
                    TriggerRemoteEvent = TriggerClientEvent
                    RegisterLocalEvent = RegisterServerEvent
                else
                    TriggerRemoteEvent = TriggerServerEvent
                    RegisterLocalEvent = RegisterNetEvent
                end

                local tunnel = {}
                tunnel.delays = {}

                function tunnel.setDestDelay(dest,delay)
                    tunnel.delays[dest] = { delay,0 }
                end

                local function tunnel_resolve(itable,key)
                    local mtable = getmetatable(itable)
                    local iname = mtable.name
                    local ids = mtable.tunnel_ids
                    local callbacks = mtable.tunnel_callbacks
                    local identifier = mtable.identifier
                    local fname = key
                    local no_wait = false
                    if string.sub(key,1,1) == "_" then
                        fname = string.sub(key,2)
                        no_wait = true
                    end

                    local fcall = function(...)
                        local r = nil
                        local args = {...}
                        local dest = nil
                        if SERVER then
                            dest = args[1]
                            args = {table.unpack(args,2,table.maxn(args))}
                            if dest >= 0 and not no_wait then
                                r = async()
                            end
                        elseif not no_wait then
                            r = async()
                        end

                        local delay_data = nil
                        if dest then delay_data = tunnel.delays[dest] end
                        if delay_data == nil then
                            delay_data = {0,0}
                        end

                        local add_delay = delay_data[1]
                        delay_data[2] = delay_data[2]+add_delay

                        if delay_data[2] > 0 then
                            SetTimeout(delay_data[2], function()
                                delay_data[2] = delay_data[2]-add_delay
                                local rid = -1
                                if r then
                                    rid = ids:gen()
                                    callbacks[rid] = r
                                end
                                if SERVER then
                                    TriggerRemoteEvent(iname..":tunnel_req",dest,fname,args,identifier,rid)
                                else
                                    TriggerRemoteEvent(iname..":tunnel_req",fname,args,identifier,rid)
                                end
                            end)
                        else
                            local rid = -1
                            if r then
                                rid = ids:gen()
                                callbacks[rid] = r
                            end
                            if SERVER then
                                TriggerRemoteEvent(iname..":tunnel_req",dest,fname,args,identifier,rid)
                            else
                                TriggerRemoteEvent(iname..":tunnel_req",fname,args,identifier,rid)
                            end
                        end

                        if r then
                            return r:wait()
                        end
                    end

                    itable[key] = fcall
                    return fcall
                end

                function tunnel.bindInterface(name,interface)
                    RegisterLocalEvent(name..":tunnel_req")
                    AddEventHandler(name..":tunnel_req",function(member,args,identifier,rid)
                        local source = source
                        local f = interface[member]
                        local rets = {}
                        if type(f) == "function" then
                            rets = { f(table.unpack(args,1,table.maxn(args))) }
                        end
                        if rid >= 0 then
                            if SERVER then
                                TriggerRemoteEvent(name..":"..identifier..":tunnel_res",source,rid,rets)
                            else
                                TriggerRemoteEvent(name..":"..identifier..":tunnel_res",rid,rets)
                            end
                        end
                    end)
                end

                function tunnel.getInterface(name,identifier)
                    if not identifier then identifier = GetCurrentResourceName() end
                    local ids = Tools.newIDGenerator()
                    local callbacks = {}
                    local r = setmetatable({},{ __index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier })
                    RegisterLocalEvent(name..":"..identifier..":tunnel_res")
                    AddEventHandler(name..":"..identifier..":tunnel_res",function(rid,args)
                        local callback = callbacks[rid]
                        if callback then
                            ids:free(rid)
                            callbacks[rid] = nil
                            callback(table.unpack(args,1,table.maxn(args)))
                        end
                    end)
                    return r
                end

                return tunnel
            end
            moduleReturns["lib-tunnel"] = { module() }
        end
        return table.unpack(moduleReturns["lib-tunnel"])
    end
end)

------------------------------------------------------------------------------------------------------------------------
-- # Shared Utilities
------------------------------------------------------------------------------------------------------------------------

tD = function(n)
    n = math.ceil(n * 100) / 100
    return n
end

parseInt = function(v)
    local n = tonumber(v)
    if n == nil then
        return 0
    else
        return math.floor(n)
    end
end

formatCurrency = function(f)
    while true do
        f,n = string.gsub(f,"^(-?%d+)(%d%d%d)",'%1.%2')
        if n == 0 then break end
    end
    return f
end

isEmptyTable = function(t)
    if not t then return true end
    if type(t) ~= "table" then return true end
    for k,v in pairs(t) do
        return false
    end
    return true
end

isEqualTables = function(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return a == b end
    for k, v in pairs(a) do
        if b[k] ~= v then return false end
    end
    for k, v in pairs(b) do
        if a[k] ~= v then return false end
    end
    return true
end

cloneTable = function(t)
    local copy = {}
    if not t or type(t) ~= "table" then return copy end
    for k,v in pairs(t) do
        copy[k] = v
    end
    return copy
end

splitStr = function(value,separator)
    local values = {}
    separator = separator or ","
    if type(value) ~= "string" or value == "" then
        return values
    end
    for piece in string.gmatch(value,"[^"..separator.."]+") do
        table.insert(values,piece)
    end
    return values
end

drawMrkr = function(m,x,y,z,c,s)
    local sz = 0.3
    local r,g,b,a = table.unpack({255,255,255,255})
    if c and type(c) == "table" then r,g,b,a = table.unpack(c) end
    if s then sz = s end
    DrawMarker(m,x,y,z,0,0,0,0,0.0,0.0,sz,sz,sz,r,g,b,a,0,0,0,1)
end

if CLIENT then
    getNearestVehicle = function(radius)
        radius = parseInt(radius)
        if radius <= 0 then
            radius = 3
        end

        local nearestVehicle = nil
        local nearestDistance = radius + 0.0001

        for vehicle,distance in pairs(getNearestVehicles(radius)) do
            if distance < nearestDistance then
                nearestDistance = distance
                nearestVehicle = vehicle
            end
        end

        if nearestVehicle then
            return GetEntityModel(nearestVehicle),GetVehicleNumberPlateText(nearestVehicle):gsub(" ",""),GetVehicleDoorLockStatus(nearestVehicle),VehToNet(nearestVehicle)
        end

        return nil
    end

    getNearestVehicles = function(radius)
        radius = parseInt(radius)
        if radius <= 0 then
            radius = 3
        end

        local result = {}
        local playerCoords = GetEntityCoords(PlayerPedId())
        local iterator,vehicle = FindFirstVehicle()
        local success = vehicle ~= nil and vehicle ~= 0

        if success then
            repeat
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(playerCoords - vehicleCoords)
                if distance <= radius then
                    result[vehicle] = distance
                end

                success,vehicle = FindNextVehicle(iterator)
            until not success
        end

        EndFindVehicle(iterator)
        return result
    end

    -- Tipos de população gerados pelo jogo (tráfego, estacionados, cenários).
    -- Veículos criados por script - client ou server - entram como POPTYPE_PERMANENT
    -- ou POPTYPE_MISSION e nunca podem ser tratados como veículo de NPC.
    local ambientPopulationTypes = {
        [1] = true, -- POPTYPE_RANDOM_PERMANENT
        [2] = true, -- POPTYPE_RANDOM_PARKED
        [3] = true, -- POPTYPE_RANDOM_PATROL
        [4] = true, -- POPTYPE_RANDOM_SCENARIO
        [5] = true  -- POPTYPE_RANDOM_AMBIENT
    }

    isAmbientVehicle = function(vehicle)
        if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            return ambientPopulationTypes[GetEntityPopulationType(vehicle)] == true
        end
        return false
    end
end

-- `veh-mods` entra aqui porque a State Bag pode chegar depois do player já ter
-- entrado no veículo: sem isto o bloqueio iniciado pela corrida nunca encerrava.
-- `Lockpick` foi retirado de propósito - arrombar a porta não liga o motor, isso
-- agora depende do minigame de fios (ver aiVehicleHotwire).
isAIVehicleUnlocked = function(vehicle)
    if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        local state = Entity(vehicle).state
        return state['veh-mods'] ~= nil or state['unlocked'] ~= nil or state['Hotwire'] ~= nil
    end
    return false
end

------------------------------------------------------------------------------------------------------------------------
-- # getVehicleInfo: retorna os dados completos de um veículo pelo hash ou index
------------------------------------------------------------------------------------------------------------------------

getVehicleInfo = function(hashOrIndex)
    if type(hashOrIndex) == 'string' then
        return vehlist[hashOrIndex]
    end
    for index, info in pairs(vehlist) do
        if GetHashKey(index) == hashOrIndex then
            return info
        end
    end
    return nil
end

exports('getVehicleInfo', getVehicleInfo)
exports('getVehicleList', function() return vehlist end)

------------------------------------------------------------------------------------------------------------------------
-- # getVehicleIndex: retorna o index (string) de um veículo pelo hash
------------------------------------------------------------------------------------------------------------------------

getVehicleIndex = function(hash)
    if type(hash) == 'string' then
        return hash
    end
    for index, _ in pairs(vehlist) do
        if GetHashKey(index) == hash then
            return index
        end
    end
    return nil
end

------------------------------------------------------------------------------------------------------------------------
-- # vehlist init: adiciona .index e .hash a cada entrada do vehlist
------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    for index,data in pairs(vehlist) do
        data.index = index
        data.hash = GetHashKey(index)
    end
end)
