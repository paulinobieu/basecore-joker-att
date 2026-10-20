-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddPedDecorationFromHashesInCorona = AddPedDecorationFromHashesInCorona
local ClearPedDecorations = ClearPedDecorations
local ClearPedProp = ClearPedProp
local GetHashKey = GetHashKey
local PlayerPedId = PlayerPedId
local SetPedComponentVariation = SetPedComponentVariation
local SetPedEyeColor = SetPedEyeColor
local SetPedFaceFeature = SetPedFaceFeature
local SetPedHairColor = SetPedHairColor
local SetPedHeadBlendData = SetPedHeadBlendData
local SetPedHeadOverlay = SetPedHeadOverlay
local SetPedHeadOverlayColor = SetPedHeadOverlayColor
local floor = math.floor
local pairs = pairs
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- FACEFEATURES
-----------------------------------------------------------------------------------------------------------------------------------------
local FaceFeatures = {
    { 0, "noseWidth" }, { 1, "noseHeight" }, { 2, "noseLength" },
    { 3, "noseBridge" }, { 4, "noseTip" }, { 5, "noseShift" },
    { 6, "eyebrowsHeight" }, { 7, "eyebrowsWidth" },
    { 8, "cheekboneHeight" }, { 9, "cheekboneWidth" }, { 10, "cheeksWidth" },
    { 11, "eyesOpening" },
    { 12, "lips" }, { 13, "jawWidth" }, { 14, "jawHeight" },
    { 15, "chinLength" }, { 16, "chinPosition" }, { 17, "chinWidth" }, { 18, "chinShape" },
    { 19, "neckWidth" },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEADOVERLAYS
-----------------------------------------------------------------------------------------------------------------------------------------
local HeadOverlays = {
    { 0, "blemishesModel", nil, -1, nil },
    { 1, "beardModel", "beardIntensity", 1, "beardColor" },
    { 2, "eyebrowsModel", "eyebrowsIntensity", 1, "eyebrowsColor" },
    { 3, "ageingModel", nil, -1, nil },
    { 4, "makeupModel", "makeupIntensity", 1, "makeupColor" },
    { 5, "blushModel", "blushIntensity", 2, "blushColor" },
    { 6, "complexionModel", nil, -1, nil },
    { 7, "sundamageModel", nil, -1, nil },
    { 8, "lipstickModel", "lipstickIntensity", 2, "lipstickColor" },
    { 9, "frecklesModel", "frecklesIntensity", -1, nil },
    { 10, "chestModel", "chestOpacity", 1, "chestColor" },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEFAULTCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function DefaultClothes(ped)
    ped = ped or PlayerPedId()

    if IsMale(ped) then
        SetPedComponentVariation(ped, 3, 15, 0, 2)
        SetPedComponentVariation(ped, 4, 0, 0, 2)
        SetPedComponentVariation(ped, 6, 1, 0, 2)
        SetPedComponentVariation(ped, 8, 15, 0, 2)
        SetPedComponentVariation(ped, 11, 15, 0, 2)
    else
        SetPedComponentVariation(ped, 3, 15, 0, 2)
        SetPedComponentVariation(ped, 4, 0, 0, 2)
        SetPedComponentVariation(ped, 6, 0, 0, 2)
        SetPedComponentVariation(ped, 8, 7, 0, 2)
        SetPedComponentVariation(ped, 11, 15, 0, 2)
        SetPedComponentVariation(ped, 6, 34, 0, 2)
    end

    ClearPedProp(ped, 0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYSKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function ApplySkin(appearance, ped)
    ped = ped or PlayerPedId()
    appearance = appearance or CurrentAppearance

    SetPedHeadBlendData(ped,
        floor(ValidateNumber(appearance.fathersID, 0, nil, 0)),
        floor(ValidateNumber(appearance.mothersID, 0, nil, 21)),
        0,
        floor(ValidateNumber(appearance.skinFirstID, 0, nil, 0)),
        floor(ValidateNumber(appearance.skinSecondID, 0, nil, 0)),
        0,
        Float(appearance.shapeMix),
        Float(appearance.skinMix),
        0.0,
        false
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYFACE
-----------------------------------------------------------------------------------------------------------------------------------------
function ApplyFace(appearance, ped)
    ped = ped or PlayerPedId()
    appearance = appearance or CurrentAppearance

    SetPedEyeColor(ped, floor(ValidateNumber(appearance.eyesColor, 0, nil, 0)))

    for index = 1, #FaceFeatures do
        local feature = FaceFeatures[index]
        SetPedFaceFeature(ped, feature[1], Float(appearance[feature[2]]))
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYHEAD
-----------------------------------------------------------------------------------------------------------------------------------------
function ApplyHead(appearance, ped)
    ped = ped or PlayerPedId()
    appearance = appearance or CurrentAppearance

    SetPedComponentVariation(ped, 2, floor(ValidateNumber(appearance.hairModel, 0, nil, 0)), 0, 0)
    SetPedHairColor(ped,
        floor(ValidateNumber(appearance.firstHairColor, 0, nil, 0)),
        floor(ValidateNumber(appearance.secondHairColor, 0, nil, 0))
    )

    local overlay = Appearance.HairOverlays[GenderKey(ped)][appearance.hairOverlay]

    if overlay then
        ClearPedDecorations(ped)
        AddPedDecorationFromHashesInCorona(ped, GetHashKey(overlay.collection), GetHashKey(overlay.overlay))
    end

    for index = 1, #HeadOverlays do
        local entry = HeadOverlays[index]
        local slot, model, intensity, colorType, colorKey = entry[1], entry[2], entry[3], entry[4], entry[5]

        SetPedHeadOverlay(ped, slot,
            floor(ValidateNumber(appearance[model], -1, nil, -1)),
            intensity and Float(appearance[intensity]) or 0.99
        )

        if colorType >= 0 then
            local color = floor(ValidateNumber(appearance[colorKey], 0, nil, 0))
            SetPedHeadOverlayColor(ped, slot, colorType, color, color)
        else
            SetPedHeadOverlayColor(ped, slot, 0, 0, 0)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function ApplyAppearance(appearance, ped, keepClothes)
    ped = ped or PlayerPedId()

    if not keepClothes then DefaultClothes(ped) end

    ApplySkin(appearance, ped)
    ApplyFace(appearance, ped)
    ApplyHead(appearance, ped)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MERGEAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function MergeAppearance(config)
    if type(config) ~= "table" then return false end

    local changed = false

    for key, value in pairs(config) do
        if Appearance.Default[key] ~= nil then
            CurrentAppearance[key] = ValidateNumber(value, nil, nil, Appearance.Default[key])
            changed = true
        end
    end

    return changed
end
