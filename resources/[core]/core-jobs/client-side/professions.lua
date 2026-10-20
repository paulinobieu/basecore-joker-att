local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local Vdist = Vdist
local DrawMarker = DrawMarker
local IsControlJustPressed = IsControlJustPressed
local IsControlJustReleased = IsControlJustReleased
local GetGameTimer = GetGameTimer
local GetEntityModel = GetEntityModel
local IsPedInAnyVehicle = IsPedInAnyVehicle
local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetLastDrivenVehicle = GetLastDrivenVehicle
local DoesEntityExist = DoesEntityExist
local GetDisplayNameFromVehicleModel = GetDisplayNameFromVehicleModel
local GetGamePool = GetGamePool
local SetEntityDrawOutline = SetEntityDrawOutline

-- # KeyMapping: controle para encerrar os empregos.
function setJobTip(msg) SetJobTip(msg) end
function endCurrentJob() EndCurrentJob() end
function jobCollectAction(Data) return ServerCall("core-jobs:requestCollectAction", Data) == true end
function lockPlayerActions(state) LocalPlayer.state.BlockTasks = state end
function createProgressBar(time) TriggerEvent("Progress", "", time) end
function loadModel(model) if type(model) == "string" then model = GetHashKey(model) end RequestModel(model) while not HasModelLoaded(model) do Wait(10) end return model end
function loadAnimDictionary(dict) RequestAnimDict(dict) while not HasAnimDictLoaded(dict) do Wait(10) end return true end
function cloneTable(t) local copy = {} for k,v in pairs(t) do copy[k] = v end return copy end
function loadNetwork(Network)
    while not NetworkDoesEntityExistWithNetworkId(Network) do Wait(0) end
    local Entitys = NetToEnt(Network)
    if not DoesEntityExist(Entitys) then return false end
    local Timeout = GetGameTimer() + 10000
    NetworkRequestControlOfEntity(Entitys)
    while not NetworkHasControlOfEntity(Entitys) do if GetGameTimer() > Timeout then return false end Wait(0) end
    Timeout = GetGameTimer() + 10000
    SetEntityAsMissionEntity(Entitys,true,true)
    while not IsEntityAMissionEntity(Entitys) do if GetGameTimer() > Timeout then return false end Wait(0) end
    return Entitys, NetworkGetNetworkIdFromEntity(Entitys)
end

isPedNearToModel = function(model,dist)
    if type(model) == "table" then
        for ind,_model in pairs(model) do
            local _isNear,_object = isPedNearToModel(_model,dist)
            if _isNear then return true,_object end
        end
        return false
    elseif type(model) == "number" then
        local object = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()),3.0,model,false)
        if object and DoesEntityExist(object) then
            local _distance = #(GetEntityCoords(object)-GetEntityCoords(PlayerPedId()))
            if _distance <= dist then return true,object end
        end
        return false
    elseif type(model) == "string" then
        local object = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()),3.0,GetHashKey(model),false)
        if object and DoesEntityExist(object) then
            local _distance = #(GetEntityCoords(object)-GetEntityCoords(PlayerPedId()))
            if _distance <= dist then return true,object end
        end
        return false
    end
    return false
end

local function hexToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

local function ResolveMarkerHex()
    if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
        return Theme.main
    end
    return Config.markerColor or Config.ThemeColor or "#ca27f4"
end

local MarkerR, MarkerG, MarkerB = hexToRGB(ResolveMarkerHex())

-- # generalThread = thread para gerar blips : markers.

CreateThread(function()

    local blip = Config.jobsAgencies.blip
    for k,v in pairs(Config.jobsAgencies.coords) do
        local x,y,z,h = table.unpack(v)
        if blip.show then
            local _blip = AddBlipForCoord(x,y,z)
            SetBlipSprite(_blip,blip.id)
            SetBlipColour(_blip,blip.color)
            SetBlipScale(_blip,blip.size)
            SetBlipAsShortRange(_blip,true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blip.name)
            EndTextCommandSetBlipName(_blip)
        end

        exports.sleepless_interact:addCoords(vec3(x, y, z), {
            {
                name = ('core_jobs:openAgency:%s'):format(k),
                icon = 'fa-solid fa-briefcase',
                label = 'Abrir Agência de Empregos',
                distance = 2.0,
                onSelect = function()
                    TriggerEvent("core_jobs:openAgency", Config.professions)
                end
            }
        })
    end

end)

-- # jobThread = lógica dos empregos.

--[[
    ## EMPREGOS EXCLUSIVOS ##
    Em jobThread, é possível criar qualquer emprego que você imaginar e adicioná-lô à agência de empregos através da config (cfg.lua)
    Não daremos suporte para bugs ou erros ocasionados por má programação/desenvolvimento neste arquivo.
    Portanto: certifique-se de que sabe o que está fazendo ou contrate quem saiba.
--]]

local fishingAreaTimer = false

local carryingMoneyBag = false

local drawedEntities = {}

jobThread = function(jobId)


    local ped = PlayerPedId()
    local playerId = PlayerId()

    local jobStep = 0
    local jobData = {}
    local jobActionCd = false

    _jobRouteName = nil

    if jobId == "minerador" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.requiredVehicle = GetHashKey(route.requiredVehicle)
        jobData.minerPoints = route.minerPoints
        jobData.centralCoords = route.centralCoords
        jobData.mineradoraCoords = route.mineradoraCoords

        jobData.currentMinerPointIndex = 1
        jobData.currentMinerPoint = jobData.minerPoints[jobData.currentMinerPointIndex]

        local nearpoint = false

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                local sleep = 500

                if jobStep == 0 then

                    sleep = 1500
                    createJobRoute("[EMPREGO] Central",351,43,jobData.centralCoords)
                    setJobTip("Vá até a <b>Central de Mineradores</b> para conseguir um caminhão.")
                    if IsPedInAnyVehicle(ped,true) then
                        local vehicle = GetVehiclePedIsIn(ped,true)
                        if GetEntityModel(vehicle) == jobData.requiredVehicle then
                            jobStep = 1
                        end
                    end

                elseif jobStep == 1 then

                    sleep = 500
                    createJobRoute("[EMPREGO] Mineradora",351,43,jobData.mineradoraCoords)
                    setJobTip("Vá até a <b>Mineradora</b> para iniciar a mineração.")
                    Wait(5000)
                    if IsPedInAnyVehicle(ped,true) then
                        local vehicle = GetVehiclePedIsIn(ped,true)
                        if GetEntityModel(vehicle) ~= jobData.requiredVehicle then
                            endCurrentJob()
                            TriggerEvent("Notify","Emprego","Você não pode utilizar um veículo próprio neste emprego.","vermelho",5000)
                        end
                    end
                    if getDistanceFrom(jobData.mineradoraCoords) <= 25 then
                        jobStep = 2
                    end

                elseif jobStep == 2 then

                    sleep = 500
                    createJobRoute(nil)
                    setJobTip("Inicie a <b>mineração</b>, seguindo os locais designados.")
                    Wait(5000)
                    jobStep = 3

                elseif jobStep == 3 then

                    if not nearpoint then
                        setJobTip("Localize o <b>ponto de mineração</b>.")
                    end
                    sleep = 500
                    local minerPointDistance = getDistanceFrom(jobData.currentMinerPoint)
                    if minerPointDistance <= 200 then
                        sleep = 3
                        DrawMarker(21,jobData.currentMinerPoint[1],jobData.currentMinerPoint[2],jobData.currentMinerPoint[3],0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,250,1,0,0,1)
                        if minerPointDistance <= 1.5 then
                            nearpoint = true
                            setJobTip("Pressione <b>[E]</b> para minerar.")
                            if IsControlJustReleased(0,38) then
                                if not jobActionCd then
                                    jobData.currentMinerPointIndex = jobData.currentMinerPointIndex % #jobData.minerPoints + 1
                                    jobData.currentMinerPoint = jobData.minerPoints[jobData.currentMinerPointIndex]
                                    jobActionCd = true
                                    local tool = loadModel("prop_tool_jackham")
                                    if loadAnimDictionary("amb@world_human_const_drill@male@drill@base") and tool then
                                        ClearPedTasks(ped)
                                        ClearPedSecondaryTask(ped)
                                        TriggerEvent("snt/animations/setBlocked",true)
                                        TriggerEvent("snt/inventory/setBlocked",true)
                                        SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNNARMED"),true)
                                        Wait(50)
                                        TaskPlayAnim(ped,"amb@world_human_const_drill@male@drill@base","base",2.0,2.0,1.0,15,1,0,0,0)
                                        local toolCoords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
                                        tool = CreateObject(tool,toolCoords.x,toolCoords.y,toolCoords.z,true,true,true)
                                        SetEntityCollision(tool,false,false)
                                        AttachEntityToEntity(tool,ped,GetPedBoneIndex(ped,28422),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
                                    end
                                    Wait(8000)
                                    ClearPedTasks(ped)
                                    if tool and DoesEntityExist(tool) then
                                        DetachEntity(tool)
                                        DeleteObject(tool)
                                    end
                                    jobCollectAction({ vehicle = VehToNet(GetLastDrivenVehicle()) })
                                    SetTimeout(2000,function()
                                        TriggerEvent("snt/animations/setBlocked",false)
                                        TriggerEvent("snt/inventory/setBlocked",false)
                                        jobActionCd = false
                                    end)
                                end
                            end
                        else
                            nearpoint = false
                        end
                    end

                end

                Wait(sleep)

            end

        end)

    elseif jobId == "motorista" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.requiredVehicle = GetHashKey(route.requiredVehicle)
        jobData.routePoints = route.routePoints
        jobData.centralCoords = route.centralCoords
        jobData.currentRoutePoint = 1

        local nearpoint = false

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                local sleep = 500

                if jobStep == 0 then

                    sleep = 1500
                    createJobRoute("[EMPREGO] Central",351,43,jobData.centralCoords)
                    setJobTip("Vá até a <b>Central de Motoristas</b> para conseguir um caminhão.")
                    if IsPedInAnyVehicle(ped,true) then
                        local vehicle = GetVehiclePedIsIn(ped,true)
                        if GetEntityModel(vehicle) == jobData.requiredVehicle then
                            jobStep = 1
                        end
                    end

                elseif jobStep == 1 then

                    sleep = 500
                    setJobTip("Agora, basta seguir a rota de <b>Pontos de Parada</b>.")
                    createJobRoute("[EMPREGO] Parada #"..jobData.currentRoutePoint,126,43,jobData.routePoints[jobData.currentRoutePoint])
                    Wait(10000)
                    jobStep = 2

                elseif jobStep == 2 then

                    sleep = 500
                    if not nearpoint then
                        setJobTip("Siga para o próximo <b>Ponto de Parada</b>.")
                    end
                    if IsPedInAnyVehicle(ped) then
                        local distanceFromPoint = getDistanceFrom(jobData.routePoints[jobData.currentRoutePoint])
                        local currentVehicle = GetVehiclePedIsIn(ped)
                        if GetEntityModel(currentVehicle) ~= jobData.requiredVehicle then
                            endCurrentJob()
                            TriggerEvent("Notify","Emprego","Você não pode utilizar um veículo próprio neste emprego.","vermelho",5000)
                        end
                        nearpoint = false
                        if distanceFromPoint <= 50 then
                            sleep = 3
                            DrawMarker(20,jobData.routePoints[jobData.currentRoutePoint][1],jobData.routePoints[jobData.currentRoutePoint][2],jobData.routePoints[jobData.currentRoutePoint][3],0,0,0,180.0,0,0,2.6,2.6,2.6,MarkerR,MarkerG,MarkerB,100,1,0,0,1)
                            if distanceFromPoint <= 7 and not jobActionCd then
                                nearpoint = true
                                setJobTip("Pressione <b>[E]</b> parar concluir a parada.")
                                if IsControlJustPressed(0,38) then
                                    jobActionCd = true
                                    jobData.currentRoutePoint = jobData.currentRoutePoint + 1
                                    if jobData.currentRoutePoint > #jobData.routePoints then
                                        jobData.currentRoutePoint = 1
                                    end
                                    jobCollectAction({ vehicle = VehToNet(currentVehicle) })
                                    SetTimeout(2000,function()
                                        createJobRoute("[EMPREGO] Parada #"..jobData.currentRoutePoint,126,43,jobData.routePoints[jobData.currentRoutePoint])
                                        jobActionCd = false
                                    end)
                                end
                            else
                                nearpoint = false
                            end
                        end
                    end

                end

                Wait(sleep)

            end

        end)

    elseif jobId == "pescador" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.requiredVehicle = GetHashKey(route.requiredVehicle)
        jobData.fishingAreas = route.fishingAreas
        jobData.portCoords = route.portCoords
        jobData.supplyMarket = route.supplyMarket
        jobData.currentFishingArea = jobData.fishingAreas[math.random(#jobData.fishingAreas)]

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                local sleep = 500

                if jobStep == 0 then

                    sleep = 500
                    createJobRoute("[EMPREGO] Mercado Central",50,43,jobData.supplyMarket)
                    setJobTip("Vá ao <b>Mercado Central</b> e compre uma <b>vara de pescar</b> e <b>iscas</b> antes de seguir ao porto.")
                    local marketDistance = getDistanceFrom(jobData.supplyMarket)
                    if marketDistance <= 25.0 then
                        sleep = 3
                        DrawMarker(21,jobData.supplyMarket[1],jobData.supplyMarket[2],jobData.supplyMarket[3],0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,250,1,0,0,1)
                        if marketDistance <= 15.0 then
                            jobStep = 1
                            TriggerEvent("Notify","Emprego","Compre uma vara de pescar e iscas. Agora siga para o Porto da Pescaria.","amarelo",6000)
                        end
                    end

                elseif jobStep == 1 then

                    sleep = 1500
                    createJobRoute("[EMPREGO] Porto",351,43,jobData.portCoords)
                    setJobTip("Com a <b>vara de pescar</b> e as <b>iscas</b>, vá até o <b>Porto da Pescaria</b> para conseguir um barco.")

                    if IsPedInAnyVehicle(ped,true) then
                        local vehicle = GetVehiclePedIsIn(ped,true)
                        if GetEntityModel(vehicle) == jobData.requiredVehicle then
                            jobStep = 2
                        end
                    end

                elseif jobStep == 2 then

                    sleep = 500
                    setJobTip("A <b>Zona de Pesca</b> foi marcada em seu GPS. Navegue até lá para iniciar a pescaria. <b>Lembre-se</b> de levar vara & isca.")
                    createJobRoute("[EMPREGO] Zona #"..GetGameTimer(),161,43,jobData.currentFishingArea)
                    Wait(10000)
                    jobStep = 3

                elseif jobStep == 3 then

                    sleep = 500

                    if not fishingAreaTimer then
                        fishingAreaTimer = GetGameTimer() + 120000
                    elseif fishingAreaTimer <= GetGameTimer() then
                        jobData.currentFishingArea =  jobData.fishingAreas[math.random(#jobData.fishingAreas)]
                        createJobRoute("[EMPREGO] Zona #"..GetGameTimer(),161,43,jobData.currentFishingArea)
                        fishingAreaTimer = false
                        TriggerEvent("Notify","Emprego","A zona de pesca mudou.","amarelo",5000)
                    end

                    local distanceFromPoint = getDistanceFrom(jobData.currentFishingArea)
                    if IsPedInAnyVehicle(ped) then
                        local currentVehicle = GetVehiclePedIsIn(ped)
                        if GetEntityModel(currentVehicle) ~= jobData.requiredVehicle then
                            endCurrentJob()
                            TriggerEvent("Notify","Emprego","Você não pode utilizar um veículo próprio neste emprego.","vermelho",5000)
                        end
                    end
                    if distanceFromPoint <= 100 then
                        setJobTip("Pressione <b>[E]</b> para pescar.")
                        sleep = 3
                        if IsControlJustPressed(0,38) and not IsPedSittingInAnyVehicle(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) then
                            if not jobActionCd and not LocalPlayer.state.animBlocked then
                                jobActionCd = true
                                jobCollectAction()
                                SetTimeout(4000,function()
                                    jobActionCd = false
                                end)
                            end
                        end
                    else
                        setJobTip("A <b>Zona de Pesca</b> foi marcada em seu GPS. Navegue até lá para iniciar a pescaria. <b>Lembre-se</b> de levar vara & isca.")
                        Wait(3000)
                    end

                end

                Wait(sleep)

            end

        end)

    elseif jobId == "lixeiro" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.requiredVehicle = GetHashKey(route.requiredVehicle)
        jobData.dumpstersModels = route.dumpstersModels
        jobData.centralCoords = route.centralCoords
        jobData.nearDumpsters = {}
        jobData.dumpstersCollected = {}
        jobData.currentDumpster = nil

        SetEntityDrawOutlineColor(MarkerR,MarkerG,MarkerB,255)

        local neardump = false

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                
                if jobStep == 1 then
                    
                    local gameTimer = GetGameTimer()
                    
                    if IsPedInAnyVehicle(ped) then
                        local vehicle = GetVehiclePedIsIn(ped)
                        if vehicle and GetEntityModel(vehicle) ~= jobData.requiredVehicle then
                            endCurrentJob()
                            TriggerEvent("Notify","Emprego","Você não pode utilizar um veículo próprio neste emprego.","vermelho",5000)
                            return
                        end
                    end

                    local pool = GetGamePool("CObject")
                    for i = 1, #pool do
                        local object = pool[i]
                        if jobData.dumpstersModels[GetEntityModel(object)] ~= nil and jobData.nearDumpsters[object] == nil then
                            jobData.nearDumpsters[object] = true
                        end
                    end
    
                    for object,data in pairs(jobData.nearDumpsters) do
                        if object and DoesEntityExist(object) and jobData.dumpstersModels[GetEntityModel(object)] ~= nil then
                            local dist = #(GetEntityCoords(object) - GetEntityCoords(ped))
                            FreezeEntityPosition(object,true)
                            if dist <= 100 and not jobData.dumpstersCollected[object] then
                                SetEntityDrawOutline(object,true)
                                drawedEntities[object] = true
                            else
                                SetEntityDrawOutline(object,false)
                                drawedEntities[object] = nil
                            end
                        else
                            jobData.nearDumpsters[object] = nil
                        end
                    end

                    for coords,timer in pairs(jobData.dumpstersCollected) do
                        if timer <= GetGameTimer() then
                            jobData.dumpstersCollected[coords] = nil
                        end
                    end

                end

                Wait(3000)

            end

        end)

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                local sleep = 500
    
                if jobStep == 0 then
    
                    sleep = 1500
                    createJobRoute("[EMPREGO] Central",351,61,jobData.centralCoords)
                    setJobTip("Vá até a <b>Central de Reciclagem</b> para conseguir um caminhão.")
                    if IsPedInAnyVehicle(ped,true) then
                        local vehicle = GetVehiclePedIsIn(ped,true)
                        if GetEntityModel(vehicle) == jobData.requiredVehicle and getDistanceFrom(jobData.centralCoords) <= 40 then
                            jobStep = 1
                        end
                    end
    
                elseif jobStep == 1 then
    
                    createJobRoute()
                    sleep = 500
                    if not neardump then
                        setJobTip("Realize a limpeza da cidade, <b>procurando lixeiras</b> e coletando seu conteúdo.")
                    end
                    if not IsPedInAnyVehicle(ped) then

                        sleep = 3

                        neardump = false

                        for object,data in pairs(jobData.nearDumpsters) do
                            if object and DoesEntityExist(object) and jobData.dumpstersModels[GetEntityModel(object)] ~= nil then
                                neardump = true
                                setJobTip("Pressione <b>[E]</b> para coletar o lixo.")
                                local dist = #(GetEntityCoords(object) - GetEntityCoords(ped))
                                if jobData.dumpstersCollected[object] == nil and dist <= 1.8 then
                                    if IsControlJustPressed(0,38) and not trashBag and not jobActionCd then
                                        jobData.currentDumpster = object
                                        jobData.currentDumpsterCoords = GetEntityCoords(object)
                                        jobData.currentDumpsterModel = GetEntityModel(object)
                                        jobData.currentDumpsterNetwork = NetworkGetEntityIsNetworked(object) and ObjToNet(object) or 0
                                        TriggerServerEvent("core-jobs:beginDynamicAction", jobId, {
                                            coords = jobData.currentDumpsterCoords,
                                            model = jobData.currentDumpsterModel,
                                            network = jobData.currentDumpsterNetwork
                                        })
                                        carryTrashBag(object)
                                    end
                                end
                            end
                        end

                        if IsControlJustPressed(0,38) and trashBag then
                            local lastVehicle = GetVehiclePedIsIn(ped,true)
                            if lastVehicle and GetEntityModel(lastVehicle) == jobData.requiredVehicle and DoesEntityExist(lastVehicle) then
                                local vehicleDeposit = GetWorldPositionOfEntityBone(lastVehicle,GetEntityBoneIndexByName(lastVehicle,"platelight"));
                                local dist = #(GetEntityCoords(ped)-vehicleDeposit)
                                if dist <= 2.5 and not jobActionCd then
                                    neardump = true
                                    setJobTip("Pressione <b>[E]</b> para depositar o lixo.")
                                    jobActionCd = true
                                    if jobData.currentDumpster ~= nil then
                                        local rewarded = jobCollectAction({
                                            coords = jobData.currentDumpsterCoords,
                                            model = jobData.currentDumpsterModel,
                                            network = jobData.currentDumpsterNetwork,
                                            vehicle = VehToNet(lastVehicle)
                                        })
                                        if rewarded then
                                            jobData.dumpstersCollected[jobData.currentDumpster] = GetGameTimer() + 180000
                                            jobData.currentDumpster = nil
                                            jobData.currentDumpsterCoords = nil
                                            jobData.currentDumpsterModel = nil
                                            jobData.currentDumpsterNetwork = nil
                                            carryTrashBag()
                                        else
                                            TriggerEvent("Notify", "Emprego", "O depósito não foi confirmado. Use o caminhão Trash de serviço e tente novamente.", "vermelho", 5000)
                                        end
                                    end
                                    SetTimeout(2000,function()
                                        jobActionCd = false
                                    end)
                                else
                                    TriggerEvent("Notify","Emprego","Longe demais do depósito do caminhão.","vermelho",5000)
                                end

                            else
                                endCurrentJob()
                                TriggerEvent("Notify","Emprego","Caminhão não encontrado.","vermelho",5000)
                            end
                        end

                    end
                    
                end
    
                Wait(sleep)
    
            end

        end)
        
        while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

            local sleep = 500

            if jobStep == 0 then

                sleep = 1500
                
                if IsPedInAnyVehicle(ped,true) then
                    local vehicle = GetVehiclePedIsIn(ped,true)
                    if GetEntityModel(vehicle) == jobData.requiredVehicle then
                        jobStep = 1
                    end
                end

            elseif jobStep == 1 then

                createJobRoute()
                sleep = 500
                local model,dumpster = isPedNearToModel(jobData.dumpModels,2) 
                if not IsPedInAnyVehicle(ped) and (model or trashBag) then
                    sleep = 3
                    
                end
                
            end

            Wait(sleep)

        end

    elseif jobId == "agricultor-trigo" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.requiredVehicle = GetHashKey(route.requiredVehicle)
        jobData.crops = route.crops
        jobData.farmCoords = route.farmCoords

        jobData.currentCrop = 1
       
        local nearcrop = false
        
        while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

            local sleep = 500

            if jobStep == 0 then

                sleep = 1500
                createJobRoute("[EMPREGO] Fazenda",351,43,jobData.farmCoords)
                setJobTip("Vá até a <b>Fazenda</b> e consiga um <b>trator</b> para trabalhar.")
                if IsPedInAnyVehicle(ped,true) then
                    local vehicle = GetVehiclePedIsIn(ped,true)
                    if GetEntityModel(vehicle) == jobData.requiredVehicle and getDistanceFrom(jobData.farmCoords) <= 15 then
                        createJobRoute()
                        jobStep = 1
                        setJobTip("Agora, basta seguir a rota de <b>colheta</b> para coletar os <b>trigos</b>.")
                        Wait(10000)
                        createJobRoute("[EMPREGO] Área #"..jobData.currentCrop,68,43,jobData.crops[jobData.currentCrop])
                    end
                end

            elseif jobStep == 1 then

                sleep = 500
                if not nearcrop then
                    setJobTip("Siga a rota de coleta para obter os <b>trigos</b>. Você pode vende-lôs a qualquer momento na <b>Cabana do Agricultor</b>!")
                end
                if IsPedInAnyVehicle(ped) then
                    local distanceFromPoint = getDistanceFrom(jobData.crops[jobData.currentCrop])
                    local currentVehicle = GetVehiclePedIsIn(ped)
                    if GetEntityModel(currentVehicle) ~= jobData.requiredVehicle then
                        endCurrentJob()
                        TriggerEvent("Notify","Emprego","Você não pode utilizar um veículo próprio neste emprego.","vermelho",5000)
                        return
                    end
                    if distanceFromPoint <= 50 then
                        sleep = 3
                        DrawMarker(20,jobData.crops[jobData.currentCrop][1],jobData.crops[jobData.currentCrop][2],jobData.crops[jobData.currentCrop][3],0,0,0,180.0,0,0,1.6,1.6,1.6,MarkerR,MarkerG,MarkerB,100,1,0,0,1)
                        if distanceFromPoint <= 4 and not jobActionCd then
                            nearcrop = true
                            setJobTip("Pressione <b>[E]</b> para lavrar a área.")
                            if IsControlJustPressed(0,38) then
                                SetPlayerControl(playerId,false)
                                jobActionCd = true
                                jobData.currentCrop = jobData.currentCrop + 1
                                if jobData.currentCrop > #jobData.crops then
                                    jobData.currentCrop = 1
                                end
                                createProgressBar(5000)
                                SetTimeout(5000,function()
                                    SetPlayerControl(playerId,true)
                                    TriggerEvent("Notify","Emprego","Área lavrada. Prossiga!","verde",3000)
                                    jobCollectAction({ vehicle = VehToNet(currentVehicle) })
                                    SetTimeout(500,function()
                                        createJobRoute("[EMPREGO] Área #"..jobData.currentCrop,68,43,jobData.crops[jobData.currentCrop])
                                        jobActionCd = false
                                    end)
                                end)
                            end
                        else
                            nearcrop = false
                        end
                    end
                end

            end

            Wait(sleep)

        end

    elseif jobId == "lenhador" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.hatchets = {}
        for weaponName, duration in pairs(route.hatchets) do
            jobData.hatchets[GetHashKey(weaponName)] = duration
        end
        jobData.trees = route.trees
        jobData.forestCoords = route.forestCoords
        jobData.supplyMarket = route.supplyMarket

        local neartree = false

        while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

            local sleep = 500

            if jobStep == 0 then

                sleep = 500
                createJobRoute("[EMPREGO] Mercado Central",50,43,jobData.supplyMarket)
                setJobTip("Vá ao <b>Mercado Central</b> e compre um <b>Machado</b> antes de seguir para a floresta.")
                local marketDistance = getDistanceFrom(jobData.supplyMarket)
                if marketDistance <= 25.0 then
                    sleep = 3
                    DrawMarker(21,jobData.supplyMarket[1],jobData.supplyMarket[2],jobData.supplyMarket[3],0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,250,1,0,0,1)
                    if marketDistance <= 15.0 then
                        jobStep = 1
                        TriggerEvent("Notify","Emprego","Compre e equipe um Machado. Agora siga para a Floresta.","amarelo",6000)
                    end
                end

            elseif jobStep == 1 then

                sleep = 1500
                createJobRoute("[EMPREGO] Floresta",351,43,jobData.forestCoords)
                setJobTip("Com o <b>Machado</b>, vá até a <b>Floresta</b> para iniciar o trabalho.")
                if getDistanceFrom(jobData.forestCoords) <= 40 then
                    createJobRoute()
                    jobStep = 2
                    Wait(2000)
                end
                 
            elseif jobStep == 2 then
                 
                if getDistanceFrom(jobData.forestCoords) > 100 then
                    jobStep = 1
                    Wait(500)
                end

                if not neartree then
                    setJobTip("Realize a coleta de <b>madeira</b> cortando as <b>árvores indicadas</b>.")
                end
                
                local pX,pY,pZ = table.unpack(GetEntityCoords(ped))

                sleep = 3
                
                local gameTimer = GetGameTimer()

                neartree = false 

                for id,tree in pairs(jobData.trees) do
                    local dist = Vdist(tree.point[1],tree.point[2],tree.point[3],pX,pY,pZ)
                    if dist <= 50 and not tree.timer or (tree.timer and tree.timer <= gameTimer) then
                        DrawMarker(20,tree.point[1],tree.point[2],tree.point[3]-0.5,0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,100,1,0,0,1) 
                        if dist <= 2 then
                            setJobTip("Pressione <b>[E]</b> para cortar a árvore.")
                            neartree = true 
                            if IsControlJustPressed(0,38) and not jobActionCd then
                                jobActionCd = true
                                local hatchetTimer = jobData.hatchets[GetSelectedPedWeapon(ped)] or false
                                if hatchetTimer then
                                    lockPlayerActions(true)
                                    SetEntityHeading(ped,tree.point[4])
                                    FreezeEntityPosition(PlayerPedId(),true)
                                    if loadAnimDictionary("melee@hatchet@streamed_core") then
                                        ClearPedTasks(ped)
                                        ClearPedSecondaryTask(ped)
                                        Wait(50)
                                        TaskPlayAnim(ped,"melee@hatchet@streamed_core","plyr_front_takedown_b",2.0,2.0,1.0,15,1,0,0,0)
                                    end
                                    createProgressBar(hatchetTimer)
                                    SetTimeout(hatchetTimer,function()
                                        jobData.trees[id].timer = GetGameTimer() + 60000
                                        ClearPedTasks(ped)
                                        lockPlayerActions(false)
                                        jobCollectAction()
                                        FreezeEntityPosition(PlayerPedId(),false)
                                        SetTimeout(2000,function()
                                            jobActionCd = false
                                        end)
                                    end)
                                else
                                    TriggerEvent("Notify","Emprego","Você deve possuir um <b>Machado</b> em mãos para cortar a árvore!","vermelho",5000)
                                    SetTimeout(2000,function()
                                        jobActionCd = false
                                    end)
                                end
                            end
                        end
                    end
                end

            end

            Wait(sleep)

        end

    elseif jobId == "agricultor-laranjas" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.trees = route.trees
        jobData.farmCoords = route.farmCoords

        local neartree = false

        while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

            local sleep = 500

            if jobStep == 0 then

                sleep = 1500
                createJobRoute("[EMPREGO] Fazenda",351,43,jobData.farmCoords)
                setJobTip("Vá até a <b>Fazenda</b> para iniciar o trabalho.")
                if getDistanceFrom(jobData.farmCoords) <= 40 then
                    createJobRoute()
                    jobStep = 1
                    Wait(2000)
                end
                
            elseif jobStep == 1 then
                
                if getDistanceFrom(jobData.farmCoords) > 100 then
                    jobStep = 0
                    Wait(500)
                end
                
                if not neartree then
                    setJobTip("Realize a coleta dos frutos nas árvores indicadas, você poderá vendê-las no Vendedor.")
                end
                
                local pX,pY,pZ = table.unpack(GetEntityCoords(ped))

                sleep = 3
                
                local gameTimer = GetGameTimer()

                neartree = false

                for id,tree in pairs(jobData.trees) do
                    local dist = Vdist(tree.point[1],tree.point[2],tree.point[3],pX,pY,pZ)
                    if dist <= 50 and not tree.timer or (tree.timer and tree.timer <= gameTimer) then
                        DrawMarker(20,tree.point[1],tree.point[2],tree.point[3]-0.5,0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,100,1,0,0,1) 
                        if dist <= 2 then
                            neartree = true
                            setJobTip("Pressione <b>[E]</b> para colher os frutos.")
                            if IsControlJustPressed(0,38) and not jobActionCd then
                                jobActionCd = true
                                lockPlayerActions(true)
                                if loadAnimDictionary("amb@prop_human_movie_bulb@base") then
                                    ClearPedTasks(ped)
                                    ClearPedSecondaryTask(ped)
                                    Wait(50)
                                    TaskPlayAnim(ped,"amb@prop_human_movie_bulb@base","base",2.0,2.0,1.0,15,1,0,0,0)
                                end
                                createProgressBar(10000)
                                SetTimeout(10000,function()
                                    jobData.trees[id].timer = GetGameTimer() + 60000
                                    ClearPedTasks(ped)
                                    lockPlayerActions(false)
                                    jobCollectAction()
                                    SetTimeout(2000,function()
                                        jobActionCd = false
                                    end)
                                end)
                            end
                        end
                    end
                end

            end

            Wait(sleep)

        end

    elseif jobId == "eletricista" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.requiredVehicle = GetHashKey(route.requiredVehicle)
        jobData.eBoxesModels = route.eBoxesModels
        jobData.centralCoords = route.centralCoords
        jobData.nearBoxes = {}
        jobData.eBoxesCollected = {}

        SetEntityDrawOutlineColor(MarkerR,MarkerG,MarkerB,255)

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                
                if jobStep == 1 then
                    
                    local gameTimer = GetGameTimer()

                    if IsPedInAnyVehicle(ped) then
                        local vehicle = GetVehiclePedIsIn(ped)
                        if vehicle and GetEntityModel(vehicle) ~= jobData.requiredVehicle then
                            endCurrentJob()
                            TriggerEvent("Notify","Emprego","Você não pode utilizar um veículo próprio neste emprego.","vermelho",5000)
                            return
                        end
                    end
                    
                    local pool = GetGamePool("CObject")
                    for i = 1, #pool do
                        local object = pool[i]
                        if jobData.eBoxesModels[GetEntityModel(object)] ~= nil and jobData.nearBoxes[object] == nil then
                            jobData.nearBoxes[object] = true
                        end
                    end
    
                    for object,data in pairs(jobData.nearBoxes) do
                        if object and DoesEntityExist(object) and jobData.eBoxesModels[GetEntityModel(object)] ~= nil then
                            local dist = #(GetEntityCoords(object) - GetEntityCoords(ped))
                            FreezeEntityPosition(object,true)
                            if dist <= 100 and not jobData.eBoxesCollected[object] then
                                SetEntityDrawOutline(object,true)
                                drawedEntities[object] = true
                            else
                                SetEntityDrawOutline(object,false)
                                drawedEntities[object] = nil
                            end
                        else
                            jobData.nearBoxes[object] = nil
                        end
                    end

                    for coords,timer in pairs(jobData.eBoxesCollected) do
                        if timer <= GetGameTimer() then
                            jobData.eBoxesCollected[coords] = nil
                        end
                    end

                end

                Wait(3000)

            end

        end)

        CreateThread(function()

            local nearbox = false

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                local sleep = 500
    
                if jobStep == 0 then
    
                    sleep = 1500
                    createJobRoute("[EMPREGO] Central",351,61,jobData.centralCoords)
                    setJobTip("Vá até a <b>Central de Eleticistas</b> para conseguir um carro.")
                    if IsPedInAnyVehicle(ped,true) then
                        local vehicle = GetVehiclePedIsIn(ped,true)
                        if GetEntityModel(vehicle) == jobData.requiredVehicle and getDistanceFrom(jobData.centralCoords) <= 40 then
                            jobStep = 1
                        end
                    end
    
                elseif jobStep == 1 then
    
                    createJobRoute()
                    sleep = 500
                    if not nearbox then
                        setJobTip("Realize a manutenção da <b>eletricidade</b> da cidade, <b>procurando caixas elétricas</b> e trocando seus fuzis.")
                    end
                    if not IsPedInAnyVehicle(ped) then

                        sleep = 3
                        nearbox = false

                        for object,data in pairs(jobData.nearBoxes) do
                            if object and DoesEntityExist(object) and jobData.eBoxesModels[GetEntityModel(object)] ~= nil then
                                local dist = #(GetEntityCoords(object) - GetEntityCoords(ped))
                                if jobData.eBoxesCollected[object] == nil and dist <= 1.8 and not jobActionCd then
                                    nearbox = true
                                    setJobTip("Pressione <b>[E]</b> para realizar a manutenção.")
                                    if IsControlJustPressed(0,38) then
                                        if dist <= 2.5 and not jobActionCd then
                                            jobActionCd = true
                                            local boxCoords = GetEntityCoords(object)
                                            local boxModel = GetEntityModel(object)
                                            local boxNetwork = NetworkGetEntityIsNetworked(object) and ObjToNet(object) or 0
                                            TriggerServerEvent("core-jobs:beginDynamicAction", jobId, {
                                                coords = boxCoords,
                                                model = boxModel,
                                                network = boxNetwork,
                                                vehicle = VehToNet(GetLastDrivenVehicle())
                                            })
                                            lockPlayerActions(true)
                                            TaskTurnPedToFaceEntity(ped,object,1000)
                                            SetTimeout(1000,function()
                                                if loadAnimDictionary("amb@prop_human_parking_meter@female@idle_a") then
                                                    ClearPedTasks(ped)
                                                    ClearPedSecondaryTask(ped)
                                                    Wait(50)
                                                    TaskPlayAnim(ped,"amb@prop_human_parking_meter@female@idle_a","idle_a_female",2.0,2.0,1.0,15,1,0,0,0)
                                                end
                                                createProgressBar(10000)
                                                SetTimeout(10000,function()
                                                    ClearPedTasks(ped)
                                                    lockPlayerActions(false)
                                                    if jobCollectAction({ coords = boxCoords, model = boxModel, network = boxNetwork }) then
                                                        jobData.eBoxesCollected[object] = GetGameTimer() + 180000
                                                    else
                                                        TriggerEvent("Notify", "Emprego", "A manutenção não foi confirmada. Use o veículo Futo de serviço e tente novamente.", "vermelho", 5000)
                                                    end
                                                    SetTimeout(2000,function()
                                                        jobActionCd = false
                                                    end)
                                                end)
                                            end)
    
                                        end
                                    end
                                end
                            end
                        end

                    end
                    
                end
    
                Wait(sleep)
    
            end

        end)

    elseif jobId == "entregador" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.restaurants = route.restaurants
        jobData.deliveryPoints = route.deliveryPoints

        jobData.totalFoods = 0
        jobData.currentFoods = 0

        local function pickDifferentIndex(list, currentIndex)
            if #list <= 1 then return 1 end
            local index
            repeat
                index = math.random(#list)
            until index ~= currentIndex
            return index
        end

        jobData.currentRestaurantIndex = math.random(#jobData.restaurants)
        jobData.currentRestaurant = jobData.restaurants[jobData.currentRestaurantIndex]
        jobData.currentDeliveryPointIndex = nil
        jobData.currentDeliveryPoint = nil

        CreateThread(function()

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do

                local sleep = 500
    
                if jobStep == 0 then
    
                    setJobTip("Você começará a receber <b>pedidos</b> em breve. <b>colete-os</b> e <b>entregue-os</b>.")
                    Wait(10000)
                    jobStep = 1

                elseif jobStep == 1 then
    
                    local dist = getDistanceFrom({jobData.currentRestaurant.point[1],jobData.currentRestaurant.point[2],jobData.currentRestaurant.point[3]})

                    createJobRoute("[EMPREGO] (Restaurante) "..jobData.currentRestaurant.name,351,43,{jobData.currentRestaurant.point[1],jobData.currentRestaurant.point[2],jobData.currentRestaurant.point[3]})
                    if dist > 2 then
                        setJobTip("Existem pedidos pendentes no estabelecimento <b>"..jobData.currentRestaurant.name.."</b>, colete-os e faça a <b>entrega</b>.")
                    end
                    sleep = 500
                    
                    
                    if dist <= 30 then
                        sleep = 3 
                        DrawMarker(21,jobData.currentRestaurant.point[1],jobData.currentRestaurant.point[2],jobData.currentRestaurant.point[3],0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,250,1,0,0,1)

                        if dist <= 2.0 then
                            if not IsPedInAnyVehicle(ped) then
                                setJobTip("Pressione <b>[E]</b> para coletar o(s) pedido(s).")
                                if IsControlJustPressed(0,38) and not carryingDelivery and not jobActionCd then
                                    jobActionCd = true
                                    local gFoods = math.random(1,5)
                                    jobData.totalFoods = gFoods
                                    jobData.currentFoods = gFoods
                                    deliveryCollect(true)
                                    setJobTip("Você coletou <b>"..jobData.currentFoods.." pedido(s)</b>, o <b>local da entrega</b> será marcado em breve em seu gps.")
                                    createJobRoute()
                                    jobData.currentDeliveryPointIndex = math.random(#jobData.deliveryPoints)
                                    jobData.currentDeliveryPoint = jobData.deliveryPoints[jobData.currentDeliveryPointIndex]
                                    Wait(10000)
                                    jobStep = 2
                                    SetTimeout(2000,function()
                                        jobActionCd = false
                                    end)
                                end
                            end
                        end
                    end

                elseif jobStep == 2 then

                    local dist = getDistanceFrom({jobData.currentDeliveryPoint[1],jobData.currentDeliveryPoint[2],jobData.currentDeliveryPoint[3]})
                    
                    createJobRoute("[EMPREGO] (Entrega) "..jobData.currentRestaurant.name.." #"..jobData.currentFoods,351,43,{jobData.currentDeliveryPoint[1],jobData.currentDeliveryPoint[2],jobData.currentDeliveryPoint[3]})
                    if dist > 2 then
                        setJobTip("Prossiga com a entrega do(s) pedido(s). Entregas restantes <b>"..jobData.currentFoods.."/"..jobData.totalFoods.."</b>.")
                    end
                    sleep = 500
                    
                    
                    if dist <= 30 then
                        sleep = 3 
                        DrawMarker(21,jobData.currentDeliveryPoint[1],jobData.currentDeliveryPoint[2],jobData.currentDeliveryPoint[3],0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,250,1,0,0,1)

                        if dist <= 2.0 then
                            if not IsPedInAnyVehicle(ped) then
                                setJobTip("Pressione <b>[E]</b> para entregar o pedido.")
                                if IsControlJustPressed(0,38) and carryingDelivery and not jobActionCd then
                                    jobActionCd = true
                                    if jobCollectAction() then
                                        deliveryCollect()
                                        setJobTip("Você entregou o <b>pedido.</b>")
                                        Wait(5000)
                                        jobData.currentFoods = jobData.currentFoods - 1
                                        if jobData.currentFoods > 0 then
                                            deliveryCollect(true)
                                            jobData.currentDeliveryPointIndex = pickDifferentIndex(jobData.deliveryPoints, jobData.currentDeliveryPointIndex)
                                            jobData.currentDeliveryPoint = jobData.deliveryPoints[jobData.currentDeliveryPointIndex]
                                            setJobTip("O endereço da <b>próxima entrega</b> será marcado em breve em seu <b>GPS</b>.")
                                        else
                                            jobData.currentRestaurantIndex = pickDifferentIndex(jobData.restaurants, jobData.currentRestaurantIndex)
                                            jobData.currentRestaurant = jobData.restaurants[jobData.currentRestaurantIndex]
                                            jobStep = 1
                                            setJobTip("Acabaram as entregas dos <b>pedidos coletados</b>, buscando novas demandas..")
                                        end
                                        Wait(10000)
                                    else
                                        TriggerEvent("Notify", "Emprego", "A entrega não foi confirmada. Aproxime-se do endereço e tente novamente.", "vermelho", 5000)
                                    end
                                    SetTimeout(2000,function()
                                        jobActionCd = false
                                    end)
                                end
                            end
                        end
                    end
                    
                end
    
                Wait(sleep)
    
            end

        end)
    
    elseif jobId == "entregador-jornais" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.vehicleSpawn = route.vehicleSpawn
        jobData.market = route.market
        jobData.vehicleList = route.vehicleList
        jobData.locations = {}
        for i, loc in ipairs(route.locations) do
            jobData.locations[i] = vec3(loc[1], loc[2], loc[3])
        end
        
        jobData.remaining = #jobData.locations
        jobData.blips = {}
        jobData.deliveryAttemptAt = {}

        CreateThread(function()
            local activeLocations = cloneTable(jobData.locations)

            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do
                local sleep = 1000
                local ped = PlayerPedId()

                if jobStep == 0 then
                    createJobRoute("Bicicletário", 376, 43, jobData.vehicleSpawn)
                    setJobTip("Vá até o <b>Bicicletário</b> indicado no GPS e retire uma <b>Bicicleta</b> na garagem.")
                    
                    if IsPedInAnyVehicle(ped, false) then
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        local modelName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                        if jobData.vehicleList[modelName] or GetEntityClass(vehicle) == 13 then
                            jobStep = 1
                        end
                    end
                elseif jobStep == 1 then
                    createJobRoute("Mercado Central", 50, 43, jobData.market)
                    setJobTip("Vá até o <b>Mercado Central</b> comprar os seus Jornais.")
                    if getDistanceFrom(jobData.market) <= 3.0 then
                        sleep = 3
                        DrawMarker(21,jobData.market[1],jobData.market[2],jobData.market[3],0,0,0,180.0,0,0,0.6,0.6,0.6,MarkerR,MarkerG,MarkerB,250,1,0,0,1)
                        setJobTip("Compre seus Jornais no balcão e saia de perto para iniciar as entregas.")
                    end
                    if getDistanceFrom(jobData.market) > 15.0 and getDistanceFrom(jobData.market) < 150.0 then
                        jobStep = 2
                        TriggerEvent("Notify", "Emprego", "Rotas marcadas em seu GPS. Inicie as entregas!", "amarelo", 5000)
                        for k,v in pairs(activeLocations) do
                            jobData.blips[k] = AddBlipForCoord(v.x, v.y, v.z)
                            SetBlipSprite(jobData.blips[k], 40)
                            SetBlipDisplay(jobData.blips[k], 4)
                            SetBlipAsShortRange(jobData.blips[k], true)
                            SetBlipColour(jobData.blips[k], Config.jobsAgencies.blip.color)
                            SetBlipScale(jobData.blips[k], 0.6)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Entrega de Jornal")
                            EndTextCommandSetBlipName(jobData.blips[k])
                            Wait(10)
                        end
                    end
                elseif jobStep == 2 then
                    createJobRoute(nil)
                    setJobTip("Atire <b>Jornais</b> nos locais demarcados pelo GPS!")
                    if IsPedInAnyVehicle(ped) then
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        local modelName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                        if jobData.vehicleList[modelName] or GetEntityClass(vehicle) == 13 then
                            local coords = GetEntityCoords(ped)
                            for line, v in pairs(activeLocations) do
                                local deliveryDistance = #(coords - v)
                                if deliveryDistance <= 100.0 then
                                    sleep = 1
                                    DrawMarker(1,v.x,v.y,v.z - 1.5,0,0,0,0,0,0,4.0,4.0,2.0,MarkerR,MarkerG,MarkerB,165,0,0,0,0)
                                    if deliveryDistance <= 35.0
                                        and IsProjectileTypeWithinDistance(v.x,v.y,v.z,-135142818,3.0,true)
                                        and (jobData.deliveryAttemptAt[line] or 0) <= GetGameTimer() then
                                        jobData.deliveryAttemptAt[line] = GetGameTimer() + 5000
                                        if jobCollectAction({ point = line }) then
                                            if DoesBlipExist(jobData.blips[line]) then
                                                RemoveBlip(jobData.blips[line])
                                            end
                                            jobData.blips[line] = nil
                                            activeLocations[line] = nil
                                            jobData.remaining = jobData.remaining - 1
                                            if jobData.remaining <= 0 then
                                                jobStep = 0
                                                TriggerEvent("Notify", "Emprego", "Você concluiu todas as rotas! Volte caso queira recomeçar.", "verde", 5000)
                                                activeLocations = cloneTable(jobData.locations)
                                                jobData.remaining = #activeLocations
                                            end
                                        else
                                            TriggerEvent("Notify", "Emprego", "A entrega não foi confirmada. Aproxime-se do endereço e jogue outro jornal.", "vermelho", 5000)
                                        end
                                    end
                                end
                            end
                        end
                    else
                        setJobTip("Suba em uma <b>Bicicleta</b> para realizar as entregas!")
                    end
                end
                Wait(sleep)
            end
            
            for k,v in pairs(jobData.blips) do
                if DoesBlipExist(v) then RemoveBlip(v) end
            end
        end)
    
    elseif jobId == "reboque" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.vehicleSpawn = route.vehicleSpawn
        jobData.dropOff = vec3(route.dropOff[1], route.dropOff[2], route.dropOff[3])
        jobData.locations = {}
        for i, loc in ipairs(route.locations) do
            jobData.locations[i] = vec4(loc[1], loc[2], loc[3], loc[4])
        end
        jobData.models = route.models
        jobData.requiredVehicle = route.requiredVehicle

        jobData.targetVehicle = nil
        jobData.targetPlate = nil
        jobData.currentDeliveryPoint = nil
        jobData.currentModel = nil
        jobData.isTowed = false

        local function SelectNewCar()
            jobData.currentDeliveryPoint = jobData.locations[math.random(#jobData.locations)]
            jobData.currentModel = jobData.models[math.random(#jobData.models)]
            jobData.targetVehicle = nil
            jobData.targetPlate = nil
            jobData.isTowed = false
            createJobRoute("Veículo Quebrado", 1, 77, jobData.currentDeliveryPoint)
            setJobTip("Vá até o local marcado no mapa e resgate o <b>Veículo Quebrado</b>.")
            jobStep = 2
        end

        CreateThread(function()
            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do
                local sleep = 1000
                local ped = PlayerPedId()

                if jobStep == 0 then
                    createJobRoute("Garagem de Reboque", 365, 43, jobData.vehicleSpawn)
                    setJobTip("Vá até a <b>Garagem de Reboque</b> buscar o caminhão Prancha de Serviço.")
                    if getDistanceFrom(jobData.vehicleSpawn) <= 50.0 then
                        sleep = 500
                        if IsPedInAnyVehicle(ped, false) then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            local modelName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                            if modelName == "flatbed" then
                                jobStep = 1
                            end
                        end
                    end
                elseif jobStep == 1 then
                    SelectNewCar()

                elseif jobStep == 2 then
                    sleep = 500
                    local flatbed = GetLastDrivenVehicle()

                    if not jobData.targetVehicle then
                        local dist = getDistanceFrom(jobData.currentDeliveryPoint)
                        if dist <= 50.0 then
                            local result = ServerCall("core-jobs:reboqueSpawn", jobData.currentModel, jobData.currentDeliveryPoint)
                            if result and result.netId then
                                local EntityObj = loadNetwork(result.netId)
                                while not DoesEntityExist(EntityObj) do Wait(100) end
                                jobData.targetVehicle = EntityObj
                                jobData.targetPlate = result.plate
                                SetVehicleHasBeenOwnedByPlayer(jobData.targetVehicle,true)
                                SetVehicleNeedsToBeHotwired(jobData.targetVehicle,false)
                                SetVehicleEngineHealth(jobData.targetVehicle,10.0)
                                SetVehicleOnGroundProperly(jobData.targetVehicle)
                                SetVehRadioStation(jobData.targetVehicle,"OFF")
                            end
                        end
                    else
                        if DoesEntityExist(jobData.targetVehicle) then
                            if not jobData.isTowed then
                                local carCoords = GetEntityCoords(jobData.targetVehicle)
                                local dist = getDistanceFrom(carCoords)
                                if dist <= 150.0 then
                                    sleep = 5
                                    DrawMarker(22,carCoords.x,carCoords.y,carCoords.z + 2.5,0.0,0.0,0.0,0.0,180.0,0.0,2.5,2.5,1.5,MarkerR,MarkerG,MarkerB,175,false,false,0,true)

                                    if dist <= 10.0 and not IsPedInAnyVehicle(ped) and IsEntityAVehicle(flatbed) and string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(flatbed))) == "flatbed" then
                                        setJobTip("Pressione <b>[E]</b> para rebocar o veículo na prancha.")
                                        if IsControlJustPressed(1,38) then
                                            LocalPlayer["state"]["Cancel"] = true
                                            LocalPlayer["state"]["Commands"] = true
                                            TriggerEvent("sounds:Private","tow",0.5)
                                            loadAnimDictionary("mini@repair")
                                            TaskPlayAnim(PlayerPedId(),"mini@repair","fixing_a_player",8.0,-8.0,-1,1,0,false,false,false)

                                            SetTimeout(5000,function()
                                                ClearPedTasks(PlayerPedId())
                                                LocalPlayer["state"]["Cancel"] = false
                                                LocalPlayer["state"]["Commands"] = false

                                                if DoesEntityExist(jobData.targetVehicle) and DoesEntityExist(flatbed) then
                                                    local Model = GetEntityModel(jobData.targetVehicle)
                                                    local Dimensions = GetModelDimensions(Model)
                                                    AttachEntityToEntity(jobData.targetVehicle,flatbed,GetEntityBoneIndexByName(flatbed,"bodyshell"),0,-2.2,0.4 - Dimensions.z,0,0,0,true,true,true,true,2,true)
                                                    Entity(flatbed)["state"]:set("Tow",true,true)
                                                    Entity(jobData.targetVehicle)["state"]:set("Tow",true,true)
                                                    jobData.isTowed = true
                                                end
                                            end)
                                        end
                                    else
                                        setJobTip("Desça do veículo e pressione <b>[E]</b> perto do carro quebrado para rebocá-lo.")
                                    end
                                end
                            else
                                local dropDist = getDistanceFrom(jobData.dropOff)
                                if dropDist <= 150.0 then
                                    sleep = 5
                                    DrawMarker(1,jobData.dropOff.x,jobData.dropOff.y,jobData.dropOff.z - 3,0,0,0,0,0,0,12.0,12.0,8.0,255,255,255,25,0,0,0,0)
                                    DrawMarker(21,jobData.dropOff.x,jobData.dropOff.y,jobData.dropOff.z + 1,0,0,0,0,180.0,130.0,3.0,3.0,2.0,MarkerR,MarkerG,MarkerB,175,0,0,0,1)

                                    if dropDist <= 10.0 and not IsPedInAnyVehicle(ped) then
                                        setJobTip("Pressione <b>[E]</b> para entregar o veículo rebocado.")
                                        if IsControlJustPressed(1,38) then
                                            if DoesEntityExist(jobData.targetVehicle) then
                                                DetachEntity(jobData.targetVehicle,false,false)
                                                if DoesEntityExist(flatbed) then
                                                    Entity(flatbed)["state"]:set("Tow",nil,true)
                                                end
                                                Entity(jobData.targetVehicle)["state"]:set("Tow",nil,true)
                                            end
                                            jobCollectAction({ plate = jobData.targetPlate })
                                        end
                                    else
                                        setJobTip("Desça do caminhão e pressione <b>[E]</b> no pátio para entregar.")
                                    end
                                else
                                    createJobRoute("Pátio", 68, 43, {jobData.dropOff.x, jobData.dropOff.y, jobData.dropOff.z})
                                    setJobTip("Leve o veículo rebocado até o <b>Pátio Central</b> (indicado no GPS).")
                                end
                            end
                        else
                            SelectNewCar()
                        end
                    end
                end
                Wait(sleep)
            end
        end)
    
    elseif jobId == "cegonha" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.vehicleSpawn = route.vehicleSpawn
        jobData.locations = {}
        for i, loc in ipairs(route.locations) do
            jobData.locations[i] = vec3(loc[1], loc[2], loc[3])
        end
        jobData.currentDeliveryPointIndex = 1

        local function EndCegonha()
            if _jobRouteBlip and DoesBlipExist(_jobRouteBlip) then
                RemoveBlip(_jobRouteBlip)
            end
            jobStep = 0
            jobData.currentDeliveryPointIndex = 1
            jobData.trailerNetwork = nil
            jobData.trailerEntity = nil
        end

        local function SpawnCegonhaTrailer(vehicle)
            local result = ServerCall("core-jobs:cegonhaSpawn", VehToNet(vehicle))
            if result and result.netId then
                jobData.trailerNetwork = result.netId
                local EntityObj = loadNetwork(result.netId)
                while not DoesEntityExist(EntityObj) do Wait(100) end
                jobData.trailerEntity = EntityObj
                SetVehicleOnGroundProperly(EntityObj)
                jobData.currentDeliveryPointIndex = jobData.currentDeliveryPointIndex + 1
                local nextPoint = jobData.locations[jobData.currentDeliveryPointIndex]
                createJobRoute("Concessionária", 12, 77, {nextPoint.x, nextPoint.y, nextPoint.z})
                TriggerEvent("Notify","Emprego","Carga liberada. Engate a cegonha e leve-a até a concessionária marcada no GPS.","amarelo",6000)
            else
                TriggerEvent("Notify","Emprego","Não foi possível liberar a carga. Posicione o Packer dentro do pátio e tente novamente.","vermelho",5000)
            end
        end

        CreateThread(function()
            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do
                local sleep = 1000
                local ped = PlayerPedId()

                if jobStep == 0 then
                    createJobRoute("Garagem de Cegonha", 318, 43, jobData.vehicleSpawn)
                    setJobTip("Vá até a <b>Garagem de Cegonha</b> marcada no mapa e pegue um caminhão Packer.")
                    if getDistanceFrom(jobData.vehicleSpawn) <= 50.0 then
                        sleep = 500
                        if IsPedInAnyVehicle(ped, false) then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            local modelName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                            if modelName == "packer" then
                                jobStep = 1
                                local nextPoint = jobData.locations[jobData.currentDeliveryPointIndex]
                                createJobRoute("Pátio de Carregamento", 12, 77, {nextPoint.x, nextPoint.y, nextPoint.z})
                            end
                        end
                    end
                elseif jobStep == 1 then
                    local vehicle = GetLastDrivenVehicle()
                    if IsEntityAVehicle(vehicle) and string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))) == "packer" then
                        local currentPoint = jobData.locations[jobData.currentDeliveryPointIndex]
                        local dist = getDistanceFrom(currentPoint)
                        if dist <= 200.0 then
                            sleep = 1
                            DrawMarker(1,currentPoint.x,currentPoint.y,currentPoint.z - 3,0,0,0,0,0,0,12.0,12.0,8.0,255,255,255,25,0,0,0,0)
                            DrawMarker(21,currentPoint.x,currentPoint.y,currentPoint.z + 1,0,0,0,0,180.0,130.0,3.0,3.0,2.0,MarkerR,MarkerG,MarkerB,175,0,0,0,1)

                            local interactionDistance = jobData.currentDeliveryPointIndex == 2 and 25.0 or 10.0
                            if dist <= interactionDistance then
                                if jobData.currentDeliveryPointIndex >= #jobData.locations then
                                    if not IsPedInVehicle(ped, vehicle, false) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
                                        setJobTip("Entre no <b>Packer</b>, sente no banco do motorista e pare dentro do ponto final.")
                                    else
                                        setJobTip("Pressione <b>[E]</b> para finalizar a rota e receber o pagamento.")
                                        if IsControlJustPressed(1,38) and not jobActionCd then
                                            jobActionCd = true
                                            if jobCollectAction() then
                                                EndCegonha()
                                                TriggerEvent("Notify","Emprego","Você concluiu toda a rota e recebeu seu pagamento! Volte às docas para iniciar novamente.","verde",6000)
                                            else
                                                TriggerEvent("Notify","Emprego","O pagamento não foi confirmado. Mantenha o Packer dentro do ponto final e tente novamente.","vermelho",5000)
                                            end
                                            SetTimeout(2000,function()
                                                jobActionCd = false
                                            end)
                                        end
                                    end
                                else
                                    if jobData.currentDeliveryPointIndex == 1 then
                                        setJobTip("Pressione <b>[E]</b> para receber e engatar a carga cegonheira.")
                                        if IsControlJustPressed(1,38) then
                                            SpawnCegonhaTrailer(vehicle)
                                        end
                                    else
                                        if jobData.currentDeliveryPointIndex == 2 then
                                            local TrailerEntity = jobData.trailerEntity
                                            if (not TrailerEntity or not DoesEntityExist(TrailerEntity)) and jobData.trailerNetwork
                                                and NetworkDoesEntityExistWithNetworkId(jobData.trailerNetwork) then
                                                TrailerEntity = NetToVeh(jobData.trailerNetwork)
                                                jobData.trailerEntity = TrailerEntity
                                            end

                                            if IsPedInAnyVehicle(ped) then
                                                setJobTip("Estacione o <b>caminhão</b>, desça e aproxime-se da <b>carga</b> para entregá-la.")
                                            elseif TrailerEntity and DoesEntityExist(TrailerEntity) then
                                                local TrailerDist = #(GetEntityCoords(ped) - GetEntityCoords(TrailerEntity))
                                                if TrailerDist <= 25.0 then
                                                    setJobTip("Pressione <b>[E]</b> ao lado da <b>carga</b> para confirmar a entrega.")
                                                else
                                                    setJobTip("Aproxime-se da <b>carga cegonheira</b> para confirmar a entrega.")
                                                end

                                                if TrailerDist <= 25.0 and IsControlJustPressed(1,38) then
                                                    local confirmed = ServerCall("core-jobs:cegonhaCheckpoint", 2, jobData.trailerNetwork)
                                                    if confirmed then
                                                        jobData.trailerNetwork = nil
                                                        jobData.trailerEntity = nil
                                                        jobData.currentDeliveryPointIndex = jobData.currentDeliveryPointIndex + 1
                                                        local nextPoint = jobData.locations[jobData.currentDeliveryPointIndex]
                                                        createJobRoute("Concessionária", 12, 77, {nextPoint.x, nextPoint.y, nextPoint.z})
                                                        TriggerEvent("Notify","Emprego","Carga entregue. Entre no Packer e siga para o próximo ponto marcado no GPS.","verde",6000)
                                                    else
                                                        TriggerEvent("Notify","Emprego","A carga não foi confirmada. Posicione o caminhão e a carga dentro do ponto e tente novamente.","vermelho",5000)
                                                    end
                                                end
                                            else
                                                setJobTip("A <b>carga cegonheira</b> não foi encontrada. Volte ao caminhão e tente novamente.")
                                            end
                                        else
                                            if not IsPedInVehicle(ped, vehicle, false) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
                                                setJobTip("Entre no <b>Packer</b> e passe pelo checkpoint como motorista.")
                                            elseif not jobActionCd then
                                                setJobTip("Passe com o <b>Packer</b> pelo checkpoint para confirmar a etapa.")
                                                jobActionCd = true
                                                local confirmed = ServerCall("core-jobs:cegonhaCheckpoint", jobData.currentDeliveryPointIndex)
                                                if confirmed then
                                                    jobData.currentDeliveryPointIndex = jobData.currentDeliveryPointIndex + 1
                                                    local nextPoint = jobData.locations[jobData.currentDeliveryPointIndex]
                                                    createJobRoute("Concessionária", 12, 77, {nextPoint.x, nextPoint.y, nextPoint.z})
                                                    if jobData.currentDeliveryPointIndex >= #jobData.locations then
                                                        TriggerEvent("Notify","Emprego","Última etapa: retorne às docas marcadas no GPS para finalizar e receber.","amarelo",6000)
                                                    else
                                                        TriggerEvent("Notify","Emprego","Checkpoint confirmado. Siga para o próximo ponto marcado no GPS.","verde",4000)
                                                    end
                                                end
                                                SetTimeout(1500,function()
                                                    jobActionCd = false
                                                end)
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            setJobTip("Siga a rota demarcada no GPS até as docas/concessionárias.")
                        end
                    else
                        setJobTip("Você precisa estar no caminhão <b>Packer</b> para continuar o serviço.")
                    end
                end

                Wait(sleep)
            end
            EndCegonha()
        end)
    elseif jobId == "taxista" then

        local route = Config.routes[jobId]
        if not route then return end

        jobData.vehicleSpawn = route.vehicleSpawn
        jobData.locations = {}
        for i, loc in ipairs(route.locations) do
            jobData.locations[i] = {
                Ped = vec3(loc.Ped[1], loc.Ped[2], loc.Ped[3]),
                Vehicle = vec3(loc.Vehicle[1], loc.Vehicle[2], loc.Vehicle[3])
            }
        end
        jobData.models = route.models
        jobData.currentDeliveryPoint = nil
        jobData.targetPed = nil

        local function DeletePassenger(passenger)
            if passenger and DoesEntityExist(passenger) then
                SetPedKeepTask(passenger, false)
                SetEntityAsMissionEntity(passenger, true, true)
                DeleteEntity(passenger)
            end
        end

        local function EndTaxista()
            if _jobRouteBlip and DoesBlipExist(_jobRouteBlip) then
                RemoveBlip(_jobRouteBlip)
            end
            DeletePassenger(jobData.targetPed)
            jobData.targetPed = nil
            jobData.currentDeliveryPoint = nil
            jobStep = 0
        end

        local function SelectNewPassenger()
            DeletePassenger(jobData.targetPed)
            jobData.targetPed = nil
            jobData.currentDeliveryPoint = jobData.locations[math.random(#jobData.locations)]
            createJobRoute("Passageiro(a)", 1, 77, {jobData.currentDeliveryPoint.Vehicle.x, jobData.currentDeliveryPoint.Vehicle.y, jobData.currentDeliveryPoint.Vehicle.z})
            jobStep = 1
        end

        local walking = false

        CreateThread(function()
            while LocalPlayer.state.currentJob and LocalPlayer.state.currentJob == jobId do
                local sleep = 1000
                local ped = PlayerPedId()

                if jobStep == 0 then
                    createJobRoute("Garagem de Taxi", 1, 77, jobData.vehicleSpawn)
                    setJobTip("Vá até a <b>Garagem de Taxi</b> marcada no mapa e pegue o seu táxi.")
                    if getDistanceFrom(jobData.vehicleSpawn) <= 50.0 then
                        sleep = 500
                        if IsPedInAnyVehicle(ped, false) then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            local modelName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                            if modelName == "taxi" then
                                SelectNewPassenger()
                            end
                        end
                    end
                elseif jobStep == 1 or jobStep == 2 then
                    local vehicle = GetLastDrivenVehicle()
                    if IsEntityAVehicle(vehicle) and string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))) == "taxi" then
                        local currentPoint = jobData.currentDeliveryPoint.Vehicle
                        local dist = getDistanceFrom(currentPoint)

                        if jobStep == 1 then
                            if dist <= 100.0 and not walking then
                                sleep = 1
                                DrawMarker(21,currentPoint.x,currentPoint.y,currentPoint.z,0.0,0.0,0.0,0.0,180.0,130.0,1.5,1.5,1.0,MarkerR,MarkerG,MarkerB,175,false,true,0,true)

                                if dist <= 2.5 then
                                    setJobTip("Pressione <b>[E]</b> para chamar o passageiro.")
                                    if IsControlJustPressed(1,38) then
                                        local RandModel = jobData.models[math.random(#jobData.models)]
                                        local pedModel = loadModel(RandModel)
                                        if pedModel then
                                            -- Ped local (isNetwork = false): handle estável, sem migração de
                                            -- entidade do OneSync nem deleção por limpadores de NPC.
                                            jobData.targetPed = CreatePed(26,pedModel,jobData.currentDeliveryPoint.Ped.x,jobData.currentDeliveryPoint.Ped.y,jobData.currentDeliveryPoint.Ped.z,0.0,false,false)
                                            
                                            SetEntityCoordsNoOffset(jobData.targetPed,jobData.currentDeliveryPoint.Ped.x,jobData.currentDeliveryPoint.Ped.y,jobData.currentDeliveryPoint.Ped.z)
                                            LocalPlayer["state"]:set("BlockLocked",true,false)
                                            SetBlockingOfNonTemporaryEvents(jobData.targetPed,true)
                                            SetEntityAsMissionEntity(jobData.targetPed,true,true)
                                            DecorSetBool(jobData.targetPed,"CREATIVE_PED",true)
                                            FreezeEntityPosition(vehicle,true)
                                            SetEntityInvincible(jobData.targetPed,true)
                                            SetVehicleDoorsLocked(vehicle,1)
                                            SetPedKeepTask(jobData.targetPed,true)
                                            walking = true

                                            TaskGoToEntity(jobData.targetPed,vehicle,-1,3.0,1.0,1073741824,0)

                                            local boarded = true
                                            local boardingTimeout = GetGameTimer() + 15000

                                            while not IsPedSittingInVehicle(jobData.targetPed,vehicle) do
                                                if not DoesEntityExist(jobData.targetPed) then
                                                    boarded = false
                                                    break
                                                end

                                                if GetGameTimer() >= boardingTimeout then
                                                    SetPedIntoVehicle(jobData.targetPed,vehicle,2)
                                                    break
                                                end

                                                TaskEnterVehicle(jobData.targetPed,vehicle,-1,2,1.0,1,0)
                                                Wait(1000)
                                            end

                                            LocalPlayer["state"]:set("BlockLocked",false,false)
                                            FreezeEntityPosition(vehicle,false)

                                            local lasted = jobData.currentDeliveryPoint
                                            repeat
                                                jobData.currentDeliveryPoint = jobData.locations[math.random(#jobData.locations)]
                                            until jobData.currentDeliveryPoint ~= lasted

                                            walking = false

                                            if boarded then
                                                jobStep = 2
                                                createJobRoute("Destino", 1, 77, {jobData.currentDeliveryPoint.Vehicle.x, jobData.currentDeliveryPoint.Vehicle.y, jobData.currentDeliveryPoint.Vehicle.z})
                                            else
                                                jobData.targetPed = nil
                                                createJobRoute("Passageiro(a)", 1, 77, {jobData.currentDeliveryPoint.Vehicle.x, jobData.currentDeliveryPoint.Vehicle.y, jobData.currentDeliveryPoint.Vehicle.z})
                                                setJobTip("O passageiro desistiu. Vá até o próximo <b>Passageiro(a)</b> indicado no GPS.")
                                            end
                                        end
                                    end
                                else
                                    setJobTip("Vá até o <b>Passageiro(a)</b> indicado no seu GPS.")
                                end
                            else
                                setJobTip("Vá até o <b>Passageiro(a)</b> indicado no seu GPS.")
                            end
                        elseif jobStep == 2 then
                            if dist <= 100.0 then
                                sleep = 1
                                DrawMarker(21,currentPoint.x,currentPoint.y,currentPoint.z,0.0,0.0,0.0,0.0,180.0,130.0,1.5,1.5,1.0,MarkerR,MarkerG,MarkerB,175,false,true,0,true)

                                if dist <= 2.5 then
                                    setJobTip("Pressione <b>[E]</b> para cobrar e desembarcar o passageiro.")
                                    if IsControlJustPressed(1,38) then
                                        FreezeEntityPosition(vehicle,true)

                                        if jobData.targetPed and DoesEntityExist(jobData.targetPed) then
                                            local passenger = jobData.targetPed
                                            TaskLeaveVehicle(passenger,vehicle,1)
                                            TaskWanderStandard(passenger,10.0,10)
                                            jobCollectAction()

                                            SetTimeout(10000,function()
                                                DeletePassenger(passenger)
                                            end)
                                        end

                                        FreezeEntityPosition(vehicle,false)
                                        jobData.targetPed = nil

                                        local lasted = jobData.currentDeliveryPoint
                                        repeat
                                            jobData.currentDeliveryPoint = jobData.locations[math.random(#jobData.locations)]
                                        until jobData.currentDeliveryPoint ~= lasted

                                        jobStep = 1
                                        createJobRoute("Passageiro(a)", 1, 77, {jobData.currentDeliveryPoint.Vehicle.x, jobData.currentDeliveryPoint.Vehicle.y, jobData.currentDeliveryPoint.Vehicle.z})
                                    end
                                else
                                    setJobTip("Leve o passageiro até o <b>Destino</b> indicado no seu GPS.")
                                end
                            else
                                setJobTip("Leve o passageiro até o <b>Destino</b> indicado no seu GPS.")
                            end
                        end
                    else
                        setJobTip("Você precisa estar no veículo <b>Taxi</b> para continuar.")
                    end
                end

                Wait(sleep)
            end
            EndTaxista()
        end)
    end

end

carryingDelivery = nil
deliveryCollect = function(collecting)
    if collecting then
        carryingDelivery = true
    else
        carryingDelivery = nil
    end 

end

-- # UTILS

getDistanceFrom = function(coords)
    local p = GetEntityCoords(PlayerPedId())
    return Vdist(p.x, p.y, p.z, coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
end

_jobRouteBlip = nil
_jobRouteName = nil
_jobRouteCoords = nil
createJobRoute = function(name,blipId,blipColor,blipCoords)
    if not name then
        if DoesBlipExist(_jobRouteBlip) then 
            RemoveBlip(_jobRouteBlip) 
        end
        _jobRouteName = nil
        _jobRouteCoords = nil
        return
    end

    local x,y,z = table.unpack(blipCoords)
    if _jobRouteName == name and _jobRouteCoords
        and math.abs(_jobRouteCoords.x - x) < 0.01
        and math.abs(_jobRouteCoords.y - y) < 0.01
        and math.abs(_jobRouteCoords.z - z) < 0.01 then
        return 
    end 
    _jobRouteName = name
	_jobRouteCoords = { x = x, y = y, z = z }
	if DoesBlipExist(_jobRouteBlip) then 
        RemoveBlip(_jobRouteBlip) 
    end
	_jobRouteBlip = AddBlipForCoord(x,y,z)
	SetBlipSprite(_jobRouteBlip,blipId)
	SetBlipColour(_jobRouteBlip,blipColor)
	SetBlipScale(_jobRouteBlip,1.0)
	SetBlipRoute(_jobRouteBlip,true)
	SetBlipAsShortRange(_jobRouteBlip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_jobRouteName)
	EndTextCommandSetBlipName(_jobRouteBlip)
    TriggerEvent("Notify","Emprego","Localização marcada em seu GPS!","amarelo",3000)
end

trashBag = nil
carryTrashBag = function(dumpster)
    if trashBag and DoesEntityExist(trashBag) then
        DetachEntity(trashBag)
        DeleteEntity(trashBag)
        trashBag = nil
    else
        lockPlayerActions(true)
        local bagModel = loadModel("prop_cs_rub_binbag_01")
        if bagModel then
            TaskTurnPedToFaceEntity(PlayerPedId(),dumpster,1000)
            Wait(1000)
            if loadAnimDictionary("amb@prop_human_parking_meter@female@idle_a") then
                ClearPedTasks(PlayerPedId())
                ClearPedSecondaryTask(PlayerPedId())
                Wait(50)
                TaskPlayAnim(PlayerPedId(),"amb@prop_human_parking_meter@female@idle_a","idle_a_female",2.0,2.0,1.0,15,1,0,0,0)
            end
            Wait(2000)
            local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0.0,0.0,-5.0)
            trashBag = CreateObject(bagModel,coords.x,coords.y,coords.z,true,true,true)
            AttachEntityToEntity(trashBag,PlayerPedId(),GetPedBoneIndex(PlayerPedId(),60309),0.0,0.0,0.0,-60.0,-100.0,-60.0,false,false,false,false,2,true)
            SetEntityAsMissionEntity(trashBag,true,true)
            SetModelAsNoLongerNeeded(bagModel)
            TriggerEvent("Notify","Emprego","Lixo coletado. Leve-o até o caminhão!","amarelo",5000)
            ClearPedTasks(PlayerPedId())
            lockPlayerActions(false)
        end
    end
end

-- # API para quando encerrar um emprego.
onEndJob = function()
    createJobRoute()
    if trashBag then
        DetachEntity(trashBag)
        DeleteEntity(trashBag)
        trashBag = nil
    end
    if carryingDelivery then
        deliveryCollect()
    end
    for entity,_ in pairs(drawedEntities) do
        if entity and DoesEntityExist(entity) then
            SetEntityDrawOutline(entity,false)
        end
    end
end

AddEventHandler("onResourceStop", function(resource) 
    if tostring(resource) == tostring(GetCurrentResourceName()) then   
        if LocalPlayer.state.currentJob then
            FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(),true),false)
            FreezeEntityPosition(PlayerPedId(),false)
            LocalPlayer.state.currentJob = nil
        end
        if trashBag and DoesEntityExist(trashBag) then
            DetachEntity(trashBag)
            DeleteEntity(trashBag)
            trashBag = nil
        end
        if carryingDelivery then
            deliveryCollect()
        end
        for entity,_ in pairs(drawedEntities) do
            if entity and DoesEntityExist(entity) then
                SetEntityDrawOutline(entity,false)
            end
        end
        if LocalPlayer.state.jobWardrobe then
            setClothes(LocalPlayer.state.jobWardrobe)
            LocalPlayer.state.jobWardrobe = nil
        end
    end
end) 
