-----------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT ITEMS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.ClientItems = {
    Carry = {
        Bone = 11816,
        Handcuffed = {Offset = {0.0, 0.5, 0.0}, Rotation = {0.0, 0.0, 0.0}},
        Default = {Offset = {0.6, 0.0, 0.0}, Rotation = {0.0, 0.0, 0.0}}
    },
    Camera = {
        Fov = {Minimum = 10.0, Maximum = 70.0, Step = 10.0},
        RotationSpeed = 8.0,
        Pitch = {Minimum = -89.5, Maximum = 20.0},
        Smoothing = 0.05,
        Scaleform = "BINOCULARS"
    },
    Scuba = {
        DefaultUnderwaterTime = 10.0,
        MaximumUnderwaterTime = 10000.0,
        LodDistance = 0xFFFF,
        Tank = {
            Model = "p_s_scuba_tank_s",
            Bone = 24818,
            Offset = {-0.28, -0.24, 0.0},
            Rotation = {180.0, 90.0, 0.0}
        },
        Mask = {
            Model = "p_s_scuba_mask_s",
            Bone = 12844,
            Offset = {0.0, 0.0, 0.0},
            Rotation = {180.0, 90.0, 0.0}
        }
    },
    StealPeds = {
        Distance = 2.0,
        RetryDelay = 5000,
        Progress = 1000,
        StartDelay = 100,
        DeliveryDelay = 3000,
        HandsUp = {Dict = "random@mugging3", Name = "handsup_standing_base"},
        Delivery = {Dict = "mp_safehouselost@", Name = "package_dropoff"},
        Bag = {
            Model = "prop_paper_bag_small",
            Bone = 28422,
            Offset = {0.0, -0.05, 0.05},
            Rotation = {180.0, 0.0, 0.0}
        }
    },
    Tow = {
        TruckModel = "flatbed",
        MaximumDistance = 15.0,
        ActionDuration = 5000,
        Sound = {Name = "tow", Volume = 0.5},
        Animation = {Dict = "mini@repair", Name = "fixing_a_player"},
        Attachment = {Bone = "bodyshell", Offset = {0.0, -2.2, 0.4}},
        DetachOffset = {0.0, -10.0, 0.0}
    }
}
