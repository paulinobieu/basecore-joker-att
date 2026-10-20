local isSearching = false
local rightPosition = { x = 1430, y = 200 }
local leftPosition = { x = 0, y = 200 }
local menuPosition = { x = 0, y = 200 }
local menuHeader = "shopui_title_sm_hangar"

if GetAspectRatio() > 2.0 then
    rightPosition = { x = 1200, y = 100 }
    leftPosition = { x = -250, y = 100 }
end

if Config.MenuPosition then
    if Config.MenuPosition == "left" then
        menuPosition = leftPosition
    elseif Config.MenuPosition == "right" then
        menuPosition = rightPosition
    end
end

if Config.CustomMenuEnabled then
    local txd = CreateRuntimeTxd('Custom_Menu_Head')
    CreateRuntimeTextureFromImage(txd, 'Custom_Menu_Head', 'header.png')
    menuHeader = "Custom_Menu_Head"
end

local function NormalizeEmote(Emote)
    local Prefix, Num = string.match(Emote, "^(%a+)(%d+)$")
    if Prefix and Num and tonumber(Num) < 10 then
        return Prefix .. tonumber(Num)
    end
    return Emote
end

local _menuPool = NativeUI.CreatePool()
local mainMenu = NativeUI.CreateMenu(Config.MenuTitle or "", "", menuPosition["x"], menuPosition["y"], menuHeader, menuHeader)
_menuPool:Add(mainMenu)

local sharemenu, shareddancemenu, favmenu, infomenu

local CoredanceTable = {}
local FuzilTable = {}
local EmoteTable = {}
local FavEmoteTable = {}
local DanceTable = {}
local AnimalTable = {}
local PropETable = {}

local WhiteTable3ro = {}
local WhiteTable2do = {}
local WhiteTable5to = {}
local WhiteTable6to = {}
local WhiteTable7mo = {}

local WalkTable = {}
local FaceTable = {}
local ShareTable = {}
local FavoriteEmote = ""

if Config.FavKeybindEnabled then
    RegisterCommand('emotefav', function() FavKeybind() end, false)
    RegisterKeyMapping("emotefav", Translate("register_fav_anim"), "keyboard", Config.FavKeybind)

    local doingFavoriteEmote = false

    function FavKeybind()
        if doingFavoriteEmote == false then
            doingFavoriteEmote = true
            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                if FavoriteEmote ~= "" and (not CanUseFavKeyBind or CanUseFavKeyBind()) then
                    EmoteCommandStart(nil, { FavoriteEmote, 0 })
                    Wait(500)
                end
            end
        else
            EmoteCancel()
            doingFavoriteEmote = false
        end
    end
end

function AddEmoteMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Translate('emotes'), "", true, true)
    if Config.Search then
        submenu:AddItem(NativeUI.CreateItem(Translate('searchemotes'), ""))
        table.insert(EmoteTable, Translate('searchemotes'))
    end
    local seattledancemenu = _menuPool:AddSubMenu(submenu, "~q~🎶 Trends do TikTok", "", true, true)
    local fuzilmenu = _menuPool:AddSubMenu(submenu, "~o~🔫  Fuzil Core", "", true, true)
    local dancemenu = _menuPool:AddSubMenu(submenu, Translate('danceemotes'), "", true, true)
    local animalmenu
    if Config.AnimalEmotesEnabled then
        animalmenu = _menuPool:AddSubMenu(submenu, Translate('animalemotes'), "", true, true)
        table.insert(EmoteTable, Translate('animalemotes'))
    end
    local propmenu = _menuPool:AddSubMenu(submenu, Translate('propemotes'), "", true, true)
    table.insert(EmoteTable, Translate('danceemotes'))
    table.insert(EmoteTable, Translate('danceemotes'))

    local whitemenu3ero = _menuPool:AddSubMenu(submenu, Translate('whitecustom'), "", true, true)
    table.insert(EmoteTable, Translate('whitecustom'))

    local whitemenu2do = _menuPool:AddSubMenu(submenu, Translate('whitecustom2do'), "", true, true)
    table.insert(EmoteTable, Translate('whitecustom2do'))

    local whitemenu5to = _menuPool:AddSubMenu(submenu, Translate('whitecustom5to'), "", true, true)
    table.insert(EmoteTable, Translate('whitecustom5to'))

    local whitemenu6to = _menuPool:AddSubMenu(submenu, Translate('whitecustom6to'), "", true, true)
    table.insert(EmoteTable, Translate('whitecustom6to'))

    local whitemenu7mo = _menuPool:AddSubMenu(submenu, Translate('whitecustom7mo'), "", true, true)
    table.insert(EmoteTable, Translate('whitecustom7mo'))

    



    if Config.SharedEmotesEnabled then
        sharemenu = _menuPool:AddSubMenu(submenu, Translate('shareemotes'),
            Translate('shareemotesinfo'), true, true)
        shareddancemenu = _menuPool:AddSubMenu(sharemenu, Translate('sharedanceemotes'), "", true, true)
        table.insert(ShareTable, 'none')
        table.insert(EmoteTable, Translate('shareemotes'))
    end

    -- Temp var to be able to sort every emotes in the fav list
    local favEmotes = {}
    if not Config.Keybinding then
        favmenu = _menuPool:AddSubMenu(submenu, Translate('favoriteemotes'), Translate('favoriteinfo'), true, true)
        favmenu:AddItem(NativeUI.CreateItem(Translate('prop2info'), ""))
        favmenu:AddItem(NativeUI.CreateItem(Translate('rfavorite'), Translate('rfavorite')))
        -- Add two elements as offset
        table.insert(FavEmoteTable, Translate('rfavorite'))
        table.insert(FavEmoteTable, Translate('rfavorite'))
        table.insert(EmoteTable, Translate('favoriteemotes'))
    else
        table.insert(EmoteTable, "keybinds")
        submenu:AddItem(NativeUI.CreateItem(Translate('keybinds'), Translate('keybindsinfo') .. " /emotebind [~y~num4-9~w~] [~g~emotename~w~]"))
    end

    for a, b in PairsByKeys(RP.Emotes) do
        local x, y, z = table.unpack(b)
        submenu:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        table.insert(EmoteTable, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.Coredances) do
        local x, y, z = table.unpack(b)
        seattledancemenu:AddItem(NativeUI.CreateItem(z, "/" .. NormalizeEmote(a) .. ""))
        table.insert(CoredanceTable, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.FuzilEmotes) do
        local x, y, z = table.unpack(b)
        fuzilmenu:AddItem(NativeUI.CreateItem(z, "/" .. NormalizeEmote(a) .. ""))
        table.insert(FuzilTable, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.White3ro) do
        local x, y, z = table.unpack(b)
        whitemenu3ero:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        table.insert(WhiteTable3ro, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.White2do) do
        local x, y, z = table.unpack(b)
        whitemenu2do:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        table.insert(WhiteTable2do, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.White5to) do
        local x, y, z = table.unpack(b)
        whitemenu5to:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        table.insert(WhiteTable5to, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end
    
    for a, b in PairsByKeys(RP.White6to) do
        local x, y, z = table.unpack(b)
        whitemenu6to:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        table.insert(WhiteTable6to, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.White7mo) do
        local x, y, z = table.unpack(b)
        whitemenu7mo:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        table.insert(WhiteTable7mo, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    for a, b in PairsByKeys(RP.Dances) do
        local x, y, z = table.unpack(b)
        dancemenu:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
        if Config.SharedEmotesEnabled then
            shareddancemenu:AddItem(NativeUI.CreateItem(z, "/nearby (" .. a .. ")"))
        end
        table.insert(DanceTable, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    if Config.AnimalEmotesEnabled then
        for a, b in PairsByKeys(RP.AnimalEmotes) do
            local x, y, z = table.unpack(b)
            animalmenu:AddItem(NativeUI.CreateItem(z, "/emote (" .. a .. ")"))
            table.insert(AnimalTable, a)
            if not Config.Keybinding then
                favEmotes[a] = z
            end
        end
    end

    if Config.SharedEmotesEnabled then
        for a, b in PairsByKeys(RP.Shared) do
            local x, y, z, otheremotename = table.unpack(b)
            local shareitem = NativeUI.CreateItem(z, "/nearby (~g~" .. a .. "~w~)" .. (otheremotename and " " .. Translate('makenearby') .. " (~y~" .. otheremotename .. "~w~)" or ""))
            sharemenu:AddItem(shareitem)
            table.insert(ShareTable, a)
        end
    end

    for a, b in PairsByKeys(RP.PropEmotes) do
        local x, y, z = table.unpack(b)
        local propitem = b.AnimationOptions.PropTextureVariations and
            NativeUI.CreateListItem(z, b.AnimationOptions.PropTextureVariations, 1, "/emote (" .. a .. ")") or
            NativeUI.CreateItem(z, "/emote (" .. a .. ")")

        propmenu:AddItem(propitem)

        table.insert(PropETable, a)
        if not Config.Keybinding then
            favEmotes[a] = z
        end
    end

    if not Config.Keybinding then
        -- Add the emotes to the fav menu
        for emoteName, emoteLabel in PairsByKeys(favEmotes) do
            favmenu:AddItem(NativeUI.CreateItem(emoteLabel, Translate('set') .. emoteLabel .. Translate('setboundemote')))
            table.insert(FavEmoteTable, emoteName)
        end

        favmenu.OnItemSelect = function(sender, item, index)
            if FavEmoteTable[index] == Translate('rfavorite') then
                FavoriteEmote = ""
                SimpleNotify(Translate('rfavorite'))
                return
            end
            if Config.FavKeybindEnabled then
                FavoriteEmote = FavEmoteTable[index]
                SimpleNotify("~o~" .. FirstToUpper(FavoriteEmote) .. Translate('newsetemote'))
            end
        end
    end
    favEmotes = nil

    -- Ped Emote on Change Index

    dancemenu.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(DanceTable[newindex], "dances")
    end

    seattledancemenu.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(CoredanceTable[newindex], "seattledances")
    end

    fuzilmenu.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(FuzilTable[newindex], "fuzil")
    end

    propmenu.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(PropETable[newindex], "props")
    end

    whitemenu3ero.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(WhiteTable3ro[newindex], "whitecustom")
    end
    whitemenu2do.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(WhiteTable2do[newindex], "whitecustom2do")
    end
    whitemenu5to.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(WhiteTable5to[newindex], "whitecustom5to")
    end
    whitemenu6to.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(WhiteTable6to[newindex], "whitecustom6to")
    end
    whitemenu7mo.OnIndexChange = function(menu, newindex)
        ClearPedTaskPreview()
        EmoteMenuStartClone(WhiteTable7mo[newindex], "whitecustom7mo")
    end



    submenu.OnIndexChange = function(menu, newindex)
        if newindex > 6 then
            ClearPedTaskPreview()
            EmoteMenuStartClone(EmoteTable[newindex], "emotes")
        end
    end

    dancemenu.OnMenuClosed = function(menu)
        ClearPedTaskPreview()
    end

    seattledancemenu.OnMenuClosed = function(menu)
        ClearPedTaskPreview()
    end

    fuzilmenu.OnMenuClosed = function(menu)
        ClearPedTaskPreview()
    end

    --------


    dancemenu.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(DanceTable[index], "dances")
    end

    whitemenu3ero.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(WhiteTable3ro[index], "whitecustom")
    end

    whitemenu2do.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(WhiteTable2do[index], "whitecustom2do")
    end

    whitemenu5to.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(WhiteTable5to[index], "whitecustom5to")
    end
    
    whitemenu6to.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(WhiteTable6to[index], "whitecustom6to")
    end

    whitemenu7mo.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(WhiteTable7mo[index], "whitecustom7mo")
    end



    if Config.AnimalEmotesEnabled then
        animalmenu.OnItemSelect = function(sender, item, index)
            EmoteMenuStart(AnimalTable[index], "animals")
        end
    end

    if Config.SharedEmotesEnabled then
        sharemenu.OnItemSelect = function(sender, item, index)
            if ShareTable[index] ~= 'none' then
                local target, distance = GetClosestPlayer()
                if (distance ~= -1 and distance < 3) then
                    TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), ShareTable[index])
                    SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                else
                    SimpleNotify(Translate('nobodyclose'))
                end
            end
        end

        shareddancemenu.OnItemSelect = function(sender, item, index)
            local target, distance = GetClosestPlayer()
            if (distance ~= -1 and distance < 3) then
                TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), DanceTable[index], 'Dances')
                SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
            else
                SimpleNotify(Translate('nobodyclose'))
            end
        end
    end

    seattledancemenu.OnItemSelect = function(sender, item, index)
        if CoredanceTable[index] ~= 'none' then
            local currentEmote = RP.Coredances[CoredanceTable[index]]
            if currentEmote["AnimationOptions"] and currentEmote["AnimationOptions"]["Shared"] then
                local target, distance = GetClosestPlayer()
                if (distance and type(distance) == "number" and distance ~= -1 and distance < 3) then
                    TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), CoredanceTable[index], 'Coredances')
                    SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                else
                    SimpleNotify(Translate('nobodyclose'))
                end
            else
                EmoteMenuStart(CoredanceTable[index], "seattledances")
            end
        end
    end

    fuzilmenu.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(FuzilTable[index], "fuzil")
    end

    propmenu.OnItemSelect = function(sender, item, index)
        EmoteMenuStart(PropETable[index], "props")
    end

   propmenu.OnListSelect = function(menu, item, itemIndex, listIndex)
        EmoteMenuStart(PropETable[itemIndex], "props", item:IndexToItem(listIndex).Value)
    end

    submenu.OnItemSelect = function(sender, item, index)
        if Config.Search and EmoteTable[index] == Translate('searchemotes') then
            EmoteMenuSearch(submenu)
        elseif EmoteTable[index] ~= Translate('favoriteemotes') then
            EmoteMenuStart(EmoteTable[index], "emotes")
        end
    end

    submenu.OnMenuClosed = function(menu)
        if not isSearching then
            ClosePedMenu()
        end
    end

end

if Config.Search then
    local ignoredCategories = {
        ["Walks"] = true,
        ["Expressions"] = true,
        ["Shared"] = not Config.SharedEmotesEnabled
    }

    function EmoteMenuSearch(lastMenu)
        ClosePedMenu()
        local favEnabled = not Config.Keybinding and Config.FavKeybindEnabled
        AddTextEntry("PM_NAME_CHALL", Translate('searchinputtitle'))
        DisplayOnscreenKeyboard(1, "PM_NAME_CHALL", "", "", "", "", "", 30)
        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Wait(100)
        end
        local input = GetOnscreenKeyboardResult()
        if input ~= nil then
            local results = {}
            for k, v in pairs(RP) do
                if not ignoredCategories[k] then
                    for a, b in pairs(v) do
                        if string.find(string.lower(a), string.lower(input)) or (b[3] ~= nil and string.find(string.lower(b[3]), string.lower(input))) then
                            table.insert(results, {table = k, name = a, data = b})
                        end
                    end
                end
            end

            if #results > 0 then
                isSearching = true

                local searchMenu = _menuPool:AddSubMenu(lastMenu, string.format('%s '..Translate('searchmenudesc')..' ~r~%s~w~', #results, input), "", true, true)
                local sharedDanceMenu
                if favEnabled then
                    searchMenu:AddItem(NativeUI.CreateItem(Translate('rfavorite'), Translate('rfavorite')))
                end

                if Config.SharedEmotesEnabled then
                    sharedDanceMenu = _menuPool:AddSubMenu(searchMenu, Translate('sharedanceemotes'), "", true, true)
                end

                table.sort(results, function(a, b) return a.name < b.name end)
                for k, v in pairs(results) do
                    local desc = ""
                    if v.table == "Shared" then
                        local otheremotename = v.data[4]
                        if otheremotename == nil then
                           desc = "/nearby (~g~" .. v.name .. "~w~)"
                        else
                           desc = "/nearby (~g~" .. v.name .. "~w~) " .. Translate('makenearby') .. " (~y~" .. otheremotename .. "~w~)"
                        end
                    else
                        desc = "/emote (" .. v.name .. ")" .. (favEnabled and "\n" .. Translate('searchshifttofav') or "")
                    end

                    if v.data.AnimationOptions and v.data.AnimationOptions.PropTextureVariations then
                        searchMenu:AddItem(NativeUI.CreateListItem(v.data[3], v.data.AnimationOptions.PropTextureVariations, 1, desc))
                    else
                        searchMenu:AddItem(NativeUI.CreateItem(v.data[3], desc))
                    end

                    if v.table == "Dances" and Config.SharedEmotesEnabled then
                        sharedDanceMenu:AddItem(NativeUI.CreateItem(v.data[3], ""))
                    end
                end

                if favEnabled then
                    table.insert(results, 1, Translate('rfavorite'))
                end


                searchMenu.OnMenuChanged = function(menu, newmenu, forward)
                    isSearching = false
                    ShowPedMenu()
                end


                searchMenu.OnIndexChange = function(menu, newindex)
                    local data = results[newindex]

                    ClearPedTaskPreview()
                    if data.table == "Emotes" or data.table == "Dances" then
                        EmoteMenuStartClone(data.name, string.lower(data.table))
                    elseif data.table == "PropEmotes" then
                        EmoteMenuStartClone(data.name, "props")
                    elseif data.table == "White2do" then
                        EmoteMenuStartClone(data.name, "whitecustom2do")
                    elseif data.table == "White5to" then
                        EmoteMenuStartClone(data.name, "whitecustom5to")
                    elseif data.table == "White6to" then
                        EmoteMenuStartClone(data.name, "whitecustom6to")
                    elseif data.table == "White7mo" then
                        EmoteMenuStartClone(data.name, "whitecustom7mo")
                    elseif data.table == "White3ro" then
                        EmoteMenuStartClone(data.name, "whitecustom")


                    elseif data.table == "AnimalEmotes" then
                        EmoteMenuStartClone(data.name, "animals")
                    end
                end


                searchMenu.OnItemSelect = function(sender, item, index)
                    local data = results[index]

                    if data == Translate('sharedanceemotes') then return end
                    if data == Translate('rfavorite') then
                        FavoriteEmote = ""
                        SimpleNotify(Translate('rfavorite'))
                        return
                    end

                    if favEnabled and IsControlPressed(0, 21) then
                        if data.table ~= "Shared" then
                            FavoriteEmote = data.name
                            SimpleNotify("~o~" .. FirstToUpper(data.name) .. Translate('newsetemote'))
                        else
                            SimpleNotify(Translate('searchcantsetfav'))
                        end
                    elseif data.table == "Emotes" or data.table == "Dances" then
                        EmoteMenuStart(data.name, string.lower(data.table))
                    elseif data.table == "PropEmotes" then
                        EmoteMenuStart(data.name, "props")


                    elseif data.table == "White2do" then
                        EmoteMenuStart(data.name, "whitecustom2do")
                    elseif data.table == "White5to" then
                        EmoteMenuStart(data.name, "whitecustom5to")
                    elseif data.table == "White6to" then
                        EmoteMenuStart(data.name, "whitecustom6to")
                    elseif data.table == "White7mo" then
                        EmoteMenuStart(data.name, "whitecustom7mo")
                    elseif data.table == "White3ro" then
                        EmoteMenuStart(data.name, "whitecustom")



                    elseif data.table == "AnimalEmotes" then
                        EmoteMenuStart(data.name, "animals")
                    elseif data.table == "Shared" then
                        local target, distance = GetClosestPlayer()
                        if (distance ~= -1 and distance < 3) then
                            TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), data.name)
                            SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                        else
                            SimpleNotify(Translate('nobodyclose'))
                        end
                    end
                end

                searchMenu.OnListSelect = function(menu, item, itemIndex, listIndex)
                    EmoteMenuStart(results[itemIndex].name, "props", item:IndexToItem(listIndex).Value)
                end

                if Config.SharedEmotesEnabled then
                    if #sharedDanceMenu.Items > 0 then
                        table.insert(results, (favEnabled and 2 or 1), Translate('sharedanceemotes'))
                        sharedDanceMenu.OnItemSelect = function(sender, item, index)
                            if not LocalPlayer.state.canEmote then return end

                            local data = results[index]
                            local target, distance = GetClosestPlayer()
                            if (distance ~= -1 and distance < 3) then
                                TriggerServerEvent("ServerEmoteRequest", GetPlayerServerId(target), data.name, 'Dances')
                                SimpleNotify(Translate('sentrequestto') .. GetPlayerName(target))
                            else
                                SimpleNotify(Translate('nobodyclose'))
                            end
                        end
                    else
                        sharedDanceMenu:Clear()
                        searchMenu:RemoveItemAt((favEnabled and 2 or 1))
                    end
                end

                searchMenu.OnMenuClosed = function()
                    searchMenu:Clear()
                    lastMenu:RemoveItemAt(#lastMenu.Items)
                    _menuPool:RefreshIndex()
                    results = {}
                end

                _menuPool:RefreshIndex()
                _menuPool:CloseAllMenus()
                searchMenu:Visible(true)
                ShowPedMenu()
            else
                SimpleNotify(string.format(Translate('searchnoresult')..' ~r~%s~w~', input))
            end
        end
    end
end

function AddCancelEmote(menu)
    local newitem = NativeUI.CreateItem(Translate('cancelemote'), Translate('cancelemoteinfo'))
    menu:AddItem(newitem)
    newitem.Activated = function()
        EmoteCancel()
        DestroyAllProps()
    end
end

ShowPedPreview = function(menu)
    menu.OnItemSelect = function(sender, item, index)
        if (index == 1) then
            isSearching = false
            ShowPedMenu()
        elseif index == 4 then
            ShowPedMenu(true)
        end
    end
end

function AddWalkMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Translate('walkingstyles'), "", true, true)

    local walkreset = NativeUI.CreateItem(Translate('normalreset'), Translate('resetdef'))
    submenu:AddItem(walkreset)
    table.insert(WalkTable, Translate('resetdef'))

    local sortedWalks = {}
    for a, b in PairsByKeys(RP.Walks) do
        local x, label = table.unpack(b)
        if x == "move_m@injured" then
            table.insert(sortedWalks, 1, {label = label or a, anim = x})
        else
            table.insert(sortedWalks, {label = label or a, anim = x})
        end
    end

    for _, walk in ipairs(sortedWalks) do
        submenu:AddItem(NativeUI.CreateItem(walk.label, "/walk (" .. string.lower(walk.label) .. ")"))
        table.insert(WalkTable, walk.anim)
    end

    submenu.OnItemSelect = function(sender, item, index)
        if item == walkreset then
            ResetWalk()
            DeleteResourceKvp("walkstyle")
        else
            WalkMenuStart(WalkTable[index])
        end
    end
end

function AddFaceMenu(menu)
    local submenu = _menuPool:AddSubMenu(menu, Translate('moods'), "", true, true)

    local facereset = NativeUI.CreateItem(Translate('normalreset'), Translate('resetdef'))
    submenu:AddItem(facereset)
    table.insert(FaceTable, "")

    for name, data in PairsByKeys(RP.Expressions) do
        local faceitem = NativeUI.CreateItem(data[2] or name, "")
        submenu:AddItem(faceitem)
        table.insert(FaceTable, name)
    end


    submenu.OnMenuClosed = function(menu)
        ClosePedMenu()
    end

    submenu.OnIndexChange = function(menu, newindex)
        EmoteMenuStartClone(FaceTable[newindex], "expression")
    end

    submenu.OnItemSelect = function(sender, item, index)
        if item ~= facereset then
            EmoteMenuStart(FaceTable[index], "expression")
        else
            DeleteResourceKvp("expression")
            ClearFacialIdleAnimOverride(PlayerPedId())
        end
    end
end

function AddInfoMenu(menu)
    infomenu = _menuPool:AddSubMenu(menu, Translate('infoupdate'), "~h~~y~WHITE CUSTOM~h~~y~", true, true)

    for _,v in ipairs(Config.Credits) do
        local item = NativeUI.CreateItem(v.title,v.subtitle or "")
        infomenu:AddItem(item)
    end
end

function OpenEmoteMenu()
    local ped = PlayerPedId()
    if GetEntityHealth(ped) <= 101 then
        -- TriggerEvent('Notify', 'amarelo', Translate('dead'), 5000)
        return
    end
    if IsEntityDead(PlayerPedId()) then
        SimpleNotify(Translate('dead'))
        return
    end
    if (IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId())) and not Config.AllowInWater then
        SimpleNotify(Translate('swimming'))
        return
    end
    if _menuPool:IsAnyMenuOpen() then
        _menuPool:CloseAllMenus()
    else
        mainMenu:Visible(true)
        ProcessMenu()
    end
end

LoadAddonEmotes()
AddEmoteMenu(mainMenu)
AddCancelEmote(mainMenu)
if Config.PreviewPed then
    ShowPedPreview(mainMenu)
end
if Config.WalkingStylesEnabled then
    AddWalkMenu(mainMenu)
end
if Config.ExpressionsEnabled then
    AddFaceMenu(mainMenu)
end
-- AddInfoMenu(mainMenu)

_menuPool:RefreshIndex()

local isMenuProcessing = false
function ProcessMenu()
    if isMenuProcessing then return end
    isMenuProcessing = true
    
    -- Desativar controles enquanto o menu está aberto
    local originalControls = {
        attack = GetControlNormal(0, 24),
        aim = GetControlNormal(0, 25),
        look = GetDisabledControlNormal(0, 1),
        move = GetDisabledControlNormal(0, 2)
    }
    
    while _menuPool:IsAnyMenuOpen() do
        _menuPool:ProcessMenus()
        DisablePlayerFiring(PlayerId(), true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        
        Wait(0)
    end
    
    SetControlNormal(0, 24, originalControls.attack)
    SetControlNormal(0, 25, originalControls.aim)
    SetControlNormal(0, 1, originalControls.look)
    SetControlNormal(0, 2, originalControls.move)
    
    isMenuProcessing = false
end

RegisterNetEvent("rp:Update", function(state)
    UpdateAvailable = state
    -- AddInfoMenu(mainMenu)
    _menuPool:RefreshIndex()
end)

RegisterNetEvent("rp:RecieveMenu", function()
    OpenEmoteMenu()
end)


-- While ped is dead, don't show menus
CreateThread(function()
    while true do
        Wait(500)
        if IsEntityDead(PlayerPedId()) then
            _menuPool:CloseAllMenus()
        end
        if (IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId())) and not Config.AllowInWater then
            -- cancel emote, destroy props and close menu
            if IsInAnimation then
                EmoteCancel()
            end
            _menuPool:CloseAllMenus()
        end
    end
end)
