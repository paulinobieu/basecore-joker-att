openStockManager = function()
    if cooldown or interfaceOpen or not _intloaded or not dealerStock then
        return
    end
    if type(ensureVehicleCatalog) ~= 'function' or not ensureVehicleCatalog() then
        return
    end
    SendNUIMessage({ action = "openStockManager", data = { categories = categories, vehicles = getOrganizedVehicleList(), stock = dealerStock } })
    toggleHud(false)
    SetNuiFocus(true,true)
end
CL.openStockManager = openStockManager

getOrganizedVehicleList = function()

    local list = {}
    for id,_ in pairs(categories) do
        list[id] = {}
    end

    for index,data in pairs(vehlist) do
        if data and data.category and list[data.category] and not data.outDealership then
            table.insert(list[data.category],data)
        end
    end

    return list

end

openDealership = function(id)

    if cooldown or interfaceOpen or not _intloaded or not dealerStock then
        return
    end

    if type(ensureVehicleCatalog) ~= 'function' or not ensureVehicleCatalog() then
        return
    end

    currentDealer = id
    interfaceOpen = true
    toggleHud(false)
    SetNuiFocus(true,true)

    -- Sincroniza o flag "oculto da concessionaria" direto do servidor (banco),
    -- que e a mesma fonte de verdade usada pelo gerenciador. Assim a loja
    -- respeita o out_dealership mesmo que o StateBag da vehlist nao tenha
    -- replicado o campo. Aplicado de forma autoritativa: marca os ocultos e
    -- desmarca os que deixaram de ser ocultos.
    local hidden = SV.vrGetHiddenModels()
    if type(hidden) == "table" then
        for index,vdata in pairs(vehlist) do
            if type(vdata) == "table" then
                vdata.outDealership = hidden[index] or nil
            end
        end
    end

    local data = {
        categories = categories,
        vehicles = getOrganizedVehicleList(),
        myVehicles =  SV.getCharacterVehicles(),
        purchaseColorOptions = purchaseColorOptions,
        sellBackPercentFromPrice = ((sellBack and sellBack.percentFromPrice) and sellBack.percentFromPrice or 0.05),
        stock = dealerStock,
        testDrive = testDrive,
        infiniteStock = infiniteStock or false,
        balance = SV.getDealerBalance()
    }

    if currentDealer ~= -1 and dealerships[currentDealer] and dealerships[currentDealer].disabledCategories and type(dealerships[currentDealer].disabledCategories) == "table" then
        data.disabledCategories = dealerships[currentDealer].disabledCategories
    end

    for plate,vdata in pairs(data.myVehicles) do
        if vdata and vdata.index then
            local vehInfo = getVehicleInfo(vdata.index)
            if not vehInfo then
                vehInfo = {
                    index = vdata.index,
                    hash = GetHashKey(vdata.index),
                    name = '??',
                    category = 'car',
                    paymentType = 'primary',
                    weights = { trunk = 45, gloves = 5 },
                    price = 1000000
                }
            end
            for kInfo,vInfo in pairs(vehInfo) do
                data.myVehicles[plate][kInfo] = vInfo
            end
        end
    end

    if currentDealer ~= -1 and dealerships[currentDealer] and dealerships[currentDealer].modelViewer then
        SV.changeMyRoute()
        SetPlayerControl(PlayerId(),false)
        LocalPlayer.state.modelViwerLC = GetEntityCoords(PlayerPedId())
        local mv = dealerships[currentDealer].modelViewer
        DoScreenFadeOut(500)
        Wait(500)
        FreezeEntityPosition(PlayerPedId(),true)
        SetEntityCoords(PlayerPedId(),mv.ped[1],mv.ped[2],mv.ped[3])
        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            RequestCollisionAtCoord(mv.ped[1],mv.ped[2],mv.ped[3])
            Wait(0)
        end
        FreezeEntityPosition(PlayerPedId(),false)
        SetEntityHeading(PlayerPedId(),mv.ped[4])
        createModelViewerCamera(mv.ped[1]+0.5,mv.ped[2]+0.5,mv.ped[3],mv.vehicle[1],mv.vehicle[2],mv.vehicle[3])
        Wait(500)
        DoScreenFadeIn(500)
    end

    SendNUIMessage({ action = "openDealership", data = data })

end

------------------------------------------------------------------------------------------------------------------------
-- # Model Viewer Camera
------------------------------------------------------------------------------------------------------------------------

createModelViewerCamera = function(x,y,z,tX,tY,tZ)
    if modelViewerCamera then
        destroyModelViewerCamera()
    end
    modelViewerCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(modelViewerCamera,x,y,z+0.5) 
    PointCamAtCoord(modelViewerCamera,tX,tY,tZ) 
    SetCamRot(modelViewerCamera,0,0,-150.0,0)
    RenderScriptCams(true,false,0,true,false)
end

destroyModelViewerCamera = function()
    if modelViewerCamera then
        RenderScriptCams(false, false, 0, true, false)
        SetCamActive(GetRenderingCam(),true)
        DestroyCam(modelViewerCamera, false)
    end
end

------------------------------------------------------------------------------------------------------------------------
-- # Model Viewer Vehicle
------------------------------------------------------------------------------------------------------------------------

createDealerViewModel = function(modelName,plate)
    deleteDealerModel()
    local stats = nil
    if currentDealer ~= -1 and dealerships[currentDealer] and dealerships[currentDealer].modelViewer then
        local mv = dealerships[currentDealer].modelViewer
        if modelName and IsModelValid(GetHashKey(modelName)) then
            local model = loadModel(modelName)
            if model then
                currentModelViewer = CreateVehicle(model,mv.vehicle[1],mv.vehicle[2],mv.vehicle[3],mv.vehicle[4],false,false)
                while not DoesEntityExist(currentModelViewer) do
                    Wait(0)
                end
                FreezeEntityPosition(currentModelViewer,true)
                SetEntityCollision(currentModelViewer,false,false)
                SetEntityInvincible(currentModelViewer,true)
                SetVehicleOnGroundProperly(currentModelViewer)
                SetVehicleNumberPlateText(currentModelViewer,"PDMSPORT")
                SetVehicleDoorsLocked(currentModelViewer,true)
                SetVehicleFixed(currentModelViewer)
                SetVehicleDirtLevel(currentModelViewer,0.0)
                SetVehicleUndriveable(currentModelViewer,true)
                if plate then
                    local mods = SV.getVehicleModsByPlate(plate)
                    if mods then
                        setVehicleMods(currentModelViewer,mods)
                    end
                end
                local maxSpeed = GetVehicleHandlingFloat(currentModelViewer, "CHandlingData", "fInitialDriveMaxFlatVel")
                local accel = GetVehicleHandlingFloat(currentModelViewer, "CHandlingData", "fInitialDriveForce")
                local braking = GetVehicleHandlingFloat(currentModelViewer, "CHandlingData", "fBrakeForce")
                local traction = GetVehicleHandlingFloat(currentModelViewer, "CHandlingData", "fTractionCurveMax")
                stats = {
                    speed = math.floor(maxSpeed or 0),
                    acceleration = math.floor((accel or 0) * 100),
                    braking = math.floor((braking or 0) * 100),
                    traction = math.floor((traction or 0) * 100)
                }
            end
        end
    end
    return { success = true, stats = stats }
end

deleteDealerModel = function(resetPlayer,restart)
    if currentModelViewer and DoesEntityExist(currentModelViewer) then
        DeleteEntity(currentModelViewer)
    end
    if resetPlayer then
        if LocalPlayer.state.modelViwerLC then
            SV.resetMyRoute()
            if not restart then
                DoScreenFadeOut(500)
                Wait(500)
            end
            destroyModelViewerCamera()
            if not restart then
                FreezeEntityPosition(PlayerPedId(),true)
            end
            SetEntityCoords(PlayerPedId(),LocalPlayer.state.modelViwerLC)
            if not restart then
                while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
                    RequestCollisionAtCoord(LocalPlayer.state.modelViwerLC)
                    Wait(0)
                end
                FreezeEntityPosition(PlayerPedId(),false)
            end
            LocalPlayer.state.modelViwerLC = nil
            SetPlayerControl(PlayerId(),true)
            if not restart then
                DoScreenFadeIn(500)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-- # Test Drive
------------------------------------------------------------------------------------------------------------------------

tryTestDrive = function(modelName)

    if LocalPlayer.state.testDriveExit == nil then

        deleteDealerModel()
        LocalPlayer.state.modelViwerLC = nil

        local ped = PlayerPedId()
        local playerId = PlayerId()
    
        if currentDealer ~= -1 and dealerships[currentDealer] and dealerships[currentDealer].coords and type(dealerships[currentDealer].coords) == "table" and #dealerships[currentDealer].coords >= 3 then
            LocalPlayer.state.testDriveExit = vec3(dealerships[currentDealer].coords[1],dealerships[currentDealer].coords[2],dealerships[currentDealer].coords[3])
        else
            LocalPlayer.state.testDriveExit = GetEntityCoords(ped)
        end
        SV.changeMyRoute()

        DoScreenFadeOut(200)
        Wait(300)

        destroyModelViewerCamera()
        SetNuiFocus(false,false)
        SetPlayerControl(PlayerId(),true)
        Wait(500)

        FreezeEntityPosition(ped,true)
        SetEntityCoords(ped,testDrive.coords[1],testDrive.coords[2],testDrive.coords[3]+0.05)
        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(testDrive.coords[1],testDrive.coords[2],testDrive.coords[3]+0.05)
            Wait(0)
        end

        local model = loadModel(modelName)
        if model then
            testDriveVehicle = CreateVehicle(model,testDrive.coords[1],testDrive.coords[2],testDrive.coords[3]+0.05,testDrive.coords[4] or 0.0,false,false)
            while not DoesEntityExist(testDriveVehicle) do
                Wait(0)
            end
            SetVehicleNumberPlateText(testDriveVehicle,testDrive.plate)
            SetVehicleOnGroundProperly(testDriveVehicle)
            SetVehicleFixed(testDriveVehicle)
            SetVehicleDirtLevel(testDriveVehicle,0.0)
            SetVehicleUndriveable(testDriveVehicle,false)
            SetVehicleFuelLevel(testDriveVehicle,99.9)
            SetEntityInvincible(testDriveVehicle,true)
        end

        if testDriveVehicle and DoesEntityExist(testDriveVehicle) and IsEntityAVehicle(testDriveVehicle) then

            CreateThread(function()
                if API and type(API) == 'table' and API['onTestDriveVehicleCreation'] and type(API['onTestDriveVehicleCreation']) == 'function' then
                    API['onTestDriveVehicleCreation'](testDriveVehicle)
                end
            end)
            
            FreezeEntityPosition(ped,false)
            SetPedIntoVehicle(ped,testDriveVehicle,-1)

            Wait(200)
            DoScreenFadeIn(200)
            Wait(250)

            SendNUIMessage({ action = "toggleTestDriveTimer", model = modelName })

            testDriveThread()

            local time = testDrive.time + 1
            while time > 0 do
                time = time - 1 
                SendNUIMessage({ action = "updateTestDriveTimer", seconds = time })
                Wait(1000)
                if not LocalPlayer.state.testDriveExit then
                    break
                end
            end

            if not LocalPlayer.state.testDriveExit then
                return
            end
            
            SendNUIMessage({ action = "toggleTestDriveTimer" })
            DoScreenFadeOut(200)
            Wait(300)

            FreezeEntityPosition(ped,true)
            DeleteEntity(testDriveVehicle)
            
        end
        
        DoScreenFadeOut(200)
        Wait(300)

        FreezeEntityPosition(ped,true)
        SetEntityCoords(ped,LocalPlayer.state.testDriveExit)
        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(LocalPlayer.state.testDriveExit)
            Wait(0)
        end
        
        FreezeEntityPosition(ped,false)
        SV.resetMyRoute()
        Wait(100)
        DoScreenFadeIn(200)
        LocalPlayer.state.testDriveExit = nil
        interfaceOpen = false
        currentDealer = -1
        cooldown = false
        toggleHud(true)

    end

end

tryEndTestDrive = function()
    local ped = PlayerPedId()
    DoScreenFadeOut(200)
    Wait(300)
    SendNUIMessage({ action = "toggleTestDriveTimer" })
    DeleteEntity(testDriveVehicle)
    FreezeEntityPosition(ped,true)
    SetEntityCoords(ped,LocalPlayer.state.testDriveExit)
    while not HasCollisionLoadedAroundEntity(ped) do
        RequestCollisionAtCoord(LocalPlayer.state.testDriveExit)
        Wait(0)
    end
    FreezeEntityPosition(ped,false)
    SV.resetMyRoute()
    LocalPlayer.state.testDriveExit = nil
    interfaceOpen = false
    currentDealer = -1
    cooldown = false
    toggleHud(true)
    Wait(100)
    DoScreenFadeIn(200)
end
