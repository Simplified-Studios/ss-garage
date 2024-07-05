garageZones, comboZone, Locales = {}, nil, {}
Config = {
    Language = 'en', -- Which language should the garage use?
    Framework = 'qb', -- Which framework should the garage use? (qb, esx)
    WarpIntoVehicle = true, -- Should the player be teleported into the vehicle?
    RealisticGarage = true,
    CustomCategorys = false,
    TextUI = 'standard', -- Option for text UI: 'standard' or 'qb-drawtextui'
    
    QBCore = {
        FuelResource = 'LegacyFuel',
    },
    
    Swapping = {        
        PayForSwap = true, -- Should the player pay for swapping a vehicle to another garage?
        PayAmount = 500, -- How much should the player pay for swapping a vehicle to another garage?
    },
    
    Impound = {
        DefaultImpoundPrice = 500, -- How much should the player pay, to get a vehicle back from the impound?
    },
    
    VehicleClass = { -- DO NOT TOUCH THIS
        all = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22 },
        car = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 18, 22 },
        air = { 15, 16 },
        sea = { 14 },
        rig = { 10, 11, 17, 19, 20 }
    }
}

Config.Blips = {
    ["garage"] = {
        sprite = 357,
        color = 3,
    },
    ["depot"] = {
        sprite = 68,
        color = 3,
    },
    ["air"] = {
        sprite = 360,
        color = 3,
    },
    ["sea"] = {
        sprite = 356,
        color = 3,
    },
}

Config.Garages = {
    ["motelgarage"] = {
        label = "Motel Garage",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(285.4, -346.73, 44.94),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(283.99, -342.49, 44.92, 69.53),
            vector4(285.3, -339.29, 44.92, 72.09),
            vector4(286.57, -336.12, 44.92, 68.81),
            vector4(287.89, -332.93, 44.92, 67.15),
            vector4(289.2, -329.76, 44.92, 67.61),
            vector4(293.3, -345.87, 44.92, 252.0),
            vector4(294.52, -342.76, 44.92, 246.73),
            vector4(295.55, -339.41, 44.92, 251.73),
        },
    },
    ["casinogarage"] = {
        label = "Casino Garage",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(884.25, -3.92, 78.76),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(881.88, -15.23, 78.76, 237.01),
            vector4(880.08, -18.24, 78.76, 238.06),
            vector4(878.21, -20.97, 78.76, 243.91),
            vector4(876.47, -24.12, 78.76, 244.03),
            vector4(874.72, -26.9, 78.76, 236.26),
            vector4(890.36, -20.58, 78.76, 62.48),
            vector4(888.47, -23.47, 78.76, 58.66),
            vector4(886.57, -26.42, 78.76, 57.02),
            vector4(884.82, -29.32, 78.76, 55.08),
        },
    },
    ["sapcounsel"] = {
        label = "San Andreas Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(-331.07, -778.99, 33.96),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(-341.51, -767.35, 33.97, 91.59),
            vector4(-341.8, -764.63, 33.97, 93.64),
            vector4(-342.86, -756.77, 33.97, 270.87),
            vector4(-337.4, -751.69, 33.97, 0.37),
            vector4(-334.43, -751.73, 33.97, 4.3),
            vector4(-331.82, -751.75, 33.97, 2.74),
            vector4(-328.88, -751.72, 33.97, 2.87),
        },
    },
    ["spanishave"] = {
        label = "Spanish Ave Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(-110.0, -613.0, 35.67),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(-1146.82, -745.9, 19.61, 285.42),
            vector4(-1144.5, -749.03, 19.46, 290.16),
            vector4(-1142.12, -752.13, 19.3, 290.32),
            vector4(-1139.61, -754.96, 19.17, 290.12),
            vector4(-1137.15, -757.97, 19.01, 288.45),
            vector4(-1134.87, -760.83, 18.86, 285.08),
            vector4(-1131.98, -763.73, 18.7, 285.49),
        },
    },
    ["caears24"] = {
        label = "Caears 24 Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(68.84, 16.29, 69.14),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(64.25, 17.37, 69.23, 164.09),
            vector4(61.22, 18.51, 69.29, 160.25),
            vector4(58.17, 19.59, 69.39, 160.61),
            vector4(55.19, 20.83, 69.64, 151.07),
        },
    },
    ["caears242"] = {
        label = "Caears 24 Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(-453.61, -796.9, 30.55),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(-459.46, -806.76, 30.54, 89.32),
            vector4(-459.29, -803.54, 30.54, 93.59),
            vector4(-459.15, -800.3, 30.54, 95.22),
            vector4(-459.23, -797.29, 30.55, 91.25),
            vector4(-467.86, -797.27, 30.55, 270.24),
            vector4(-467.99, -800.44, 30.54, 268.92),
            vector4(-467.75, -803.56, 30.54, 269.2),
            vector4(-467.78, -806.71, 30.54, 270.85),
        },
    },
    ["lagunapi"] = {
        label = "Laguna Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(366.01, 295.98, 103.44),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(362.41, 293.31, 103.49, 70.38),
            vector4(361.07, 289.67, 103.48, 71.12),
            vector4(359.87, 285.86, 103.47, 73.93),
            vector4(358.42, 282.18, 103.38, 68.42),
            vector4(374.64, 293.39, 103.27, 350.49),
            vector4(378.55, 292.07, 103.19, 344.72),
            vector4(382.33, 291.1, 103.11, 341.45),
            vector4(386.32, 289.83, 103.05, 343.43),
            vector4(371.55, 285.94, 103.26, 160.28),
            vector4(375.29, 284.75, 103.19, 160.42),
            vector4(378.99, 283.13, 103.11, 160.02),
        },
    },
    ["airportp"] = {
        label = "Airport Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(-784.42, -2035.5, 8.87),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(-778.68, -2038.98, 8.88, 137.88),
            vector4(-776.35, -2041.41, 8.89, 141.1),
            vector4(-773.85, -2043.84, 8.89, 138.44),
            vector4(-771.43, -2046.31, 8.9, 135.15),
            vector4(-769.0, -2048.79, 8.9, 141.19),
            vector4(-766.59, -2051.23, 8.9, 130.35),
            vector4(-764.35, -2053.66, 8.9, 134.26),
            vector4(-762.0, -2056.31, 8.9, 135.78),
            vector4(-759.42, -2058.61, 8.91, 133.74),
            vector4(-757.1, -2060.93, 8.91, 135.77),
        },
    },
    ["beachp"] = {
        label = "Beach Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(-1186.39, -1505.35, 4.38),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(-1184.2, -1496.47, 4.38, 298.41),
            vector4(-1185.94, -1493.84, 4.38, 303.72),
            vector4(-1187.59, -1491.26, 4.38, 299.91),
            vector4(-1189.48, -1488.77, 4.38, 303.77),
            vector4(-1191.43, -1486.19, 4.38, 304.57),
            vector4(-1192.93, -1483.57, 4.38, 303.14),
            vector4(-1176.11, -1490.85, 4.38, 128.26),
            vector4(-1177.81, -1488.5, 4.38, 126.47),
            vector4(-1179.5, -1485.93, 4.38, 126.56),
        },
    },
    ["themotorhotel"] = {
        label = "The Motor Hotel Parking",
        blip = Config.Blips["garage"],
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(1137.67, 2664.16, 38.0),
        spawns = {
            vector4(1131.54, 2648.87, 38.0, 187.25),
            vector4(1127.51, 2648.94, 38.0, 181.55),
            vector4(1124.12, 2648.92, 38.0, 188.42),
            vector4(1120.38, 2648.97, 38.0, 180.07),
            vector4(1116.63, 2648.82, 38.0, 178.76),
            vector4(1113.23, 2654.2, 38.0, 88.38),
            vector4(1112.98, 2657.89, 38.0, 96.84),
        },
    },
    ["liqourparking"] = {
        label = 'Liqour Parking',
        coords = vector3(895.47, 3649.74, 32.79),
        type = "car",
        category = 'car',
        canTransfer = true,
        blip = Config.Blips["garage"],
        spawns = {
            vector4(898.76, 3646.06, 32.77, 269.45),
            vector4(898.66, 3649.52, 32.77, 268.03),
            vector4(898.72, 3652.98, 32.77, 268.18),
        },
    },
    ["shoreparking"] = {
        label = 'Shore Parking',
        coords = vector3(1739.39, 3717.33, 34.07),
        type = "car",
        category = 'car',
        canTransfer = true,
        blip = Config.Blips["garage"],
        spawns = {
            vector4(1737.82, 3716.85, 34.08, 291.42),
            vector4(1736.08, 3721.33, 34.02, 291.38),
        },
    },
    ["haanparking"] = {
        label = "Bell Farms Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(85.0, 6393.0, 31.38),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(80.1, 6395.31, 31.23, 312.1),
            vector4(77.54, 6397.75, 31.23, 317.14),
            vector4(74.48, 6400.48, 31.23, 311.71),
            vector4(71.73, 6403.13, 31.23, 320.09),
        },
    },
    ["dumbogarage"] = {
        label = 'Dumbo Private Parking',
        coords = vector3(163.44, -3213.1, 5.93),
        type = "car",
        category = 'car',
        canTransfer = true,
        blip = Config.Blips["garage"],
        spawns = {
            vector4(164.46, -3217.76, 5.91, 266.39),
        },
    },
    ["pillboxgarage"] = {
        label = "Pillbox Garage Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector3(213.35, -795.13, 30.86),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(221.54, -806.78, 30.67, 69.92),
            vector4(222.43, -804.28, 30.67, 75.82),
            vector4(223.26, -801.83, 30.66, 74.33),
            vector4(224.13, -799.34, 30.66, 67.34),
            vector4(225.42, -796.97, 30.65, 68.2),
            vector4(231.41, -807.54, 30.46, 246.18),
            vector4(232.58, -805.12, 30.46, 253.25),
            vector4(233.64, -802.61, 30.47, 254.7),
            vector4(234.41, -800.09, 30.49, 252.28),
            vector4(235.28, -797.45, 30.5, 265.21),
        },
    },
    ["grapeseedgarage"] = {
        label = "Grapeseed Parking",
        type = "car",
        category = 'car',
        canTransfer = true,
        coords = vector(2552.86, 4675.3, 33.92),
        blip = Config.Blips["garage"],
        spawns = {
            vector4(2552.86, 4675.3, 33.92, 19.2),
        },
    },
    ["depotLot"] = {
        label = "Depot Lot",
        type = 'depot',
        category = 'car',
        blip = Config.Blips["depot"],
        canTransfer = true,
        coords = vector3(409.65, -1623.39, 29.29),
        spawns = {
            vector4(419.72, -1635.86, 29.29, 271.06),
            vector4(419.75, -1638.83, 29.29, 265.56),
            vector4(419.68, -1641.92, 29.29, 271.07),
            vector4(417.57, -1645.68, 29.29, 231.22),
            vector4(418.78, -1630.38, 29.29, 321.42),
            vector4(416.61, -1628.38, 29.29, 318.89),
        },
    },
    ["ballas"] = {
        label = "Ballas Parking",
        type = "gang",
        category = 'car',
        canTransfer = false,
        coords = vector3(84.2, -1966.75, 20.94),
        spawns = {
            vector4(86.7, -1970.56, 20.75, 319.4),
            vector4(90.31, -1966.17, 20.75, 319.94),
            vector4(94.34, -1961.33, 20.75, 320.22),
        },
        gang = 'ballas',
    },
    ["families"] = {
        label = "Families Parking",
        type = "gang",
        category = 'car',
        canTransfer = false,
        coords = vector3(-23.89, -1436.03, 30.65),
        spawns = {
            vector4(-25.47, -1445.76, 30.24, 178.5)
        },
        gang = 'families',
    },
    ["lostmc"] = {
        label = "Lost MC Parking",
        type = "gang",
        category = 'car',
        canTransfer = false,
        coords = vector3(985.83, -138.14, 73.09),
        spawns = {
            vector4(977.65, -133.02, 73.34, 59.39)
        },
        gang = 'lostmc',
    },
    ["cartel"] = {
        label = 'Cartel',
        coords = vector3(1411.67, 1117.8, 114.84),
        type = "gang",
        category = 'car',
        canTransfer = false,
        spawns = {
            vector4(1403.01, 1118.25, 114.84, 88.69)
        },
        gang = 'cartel',
    },
    ["intairport"] = {
        label = 'Airport Hangar',
        coords = vector3(-979.06, -2995.48, 13.95),
        spawns = {
            vector4(-998.37, -2985.01, 13.95, 61.09)
        },
        type = "air",
        category = 'air',
        canTransfer = false,
        blip = Config.Blips["air"],
    },
    ["higginsheli"] = {
        label = 'Higgins Helitours',
        coords = vector3(-722.15, -1472.79, 5.0),
        spawns = {
            vector4(-745.22, -1468.72, 5.39, 319.84),
            vector4(-724.36, -1443.61, 5.39, 135.78)
        },
        type = "air",
        category = 'air',
        canTransfer = false,
        blip = Config.Blips["air"],
    },
    ["airsshores"] = {
        label = 'Sandy Shores Hangar',
        coords = vector3(1737.89, 3288.13, 41.14),
        spawns = {
            vector4(1742.83, 3266.83, 41.24, 102.64)
        },
        type = "air",
        category = 'air',
        canTransfer = false,
        blip = Config.Blips["air"],
    },
    ["airzancudo"] = {
        label = 'Fort Zancudo Hangar',
        coords = vector3(-1828.25, 2975.44, 32.81),
        spawns = {
            vector4(-1828.25, 2975.44, 32.81, 57.24)
        },
        type = "air",
        category = 'air',
        canTransfer = false,
        blip = Config.Blips["air"],
    },
    ["airdepot"] = {
        label = 'Air Depot',
        coords = vector3(-1270.01, -3377.53, 14.33),
        spawns = {
            vector4(-1270.01, -3377.53, 14.33, 329.25)
        },
        type = "air",
        category = 'air',
        canTransfer = false,
        blip = Config.Blips["depot"],
    },
    ["lsymc"] = {
        label = 'LSYMC Boathouse',
        coords = vector3(-785.95, -1497.84, -0.09),
        spawns = {
            vector4(-796.64, -1502.6, -0.09, 111.49)
        },
        type = "sea",
        category = 'sea',
        canTransfer = false,
        blip = Config.Blips["sea"],
    },
    ["paleto"] = {
        label = 'Paleto Boathouse',
        coords = vector3(-278.21, 6638.13, 7.55),
        spawns = {
            vector4(-289.2, 6637.96, 1.01, 45.5)
        },
        type = "sea",
        category = 'sea',
        canTransfer = false,
        blip = Config.Blips["sea"],
    },
    ["millars"] = {
        label = 'Millars Boathouse',
        coords = vector3(1298.56, 4212.42, 33.25),
        spawns = {
            vector4(1297.82, 4209.61, 30.12, 253.5)
        },
        type = "sea",
        category = 'sea',
        canTransfer = false,
        blip = Config.Blips["sea"],
    },
    ["seadepot"] = {
        label = 'LSYMC Depot',
        coords = vector3(-742.95, -1407.58, 5.5),
        spawns = {
            vector4(-729.77, -1355.49, 1.19, 142.5)
        },
        type = "depot",
        category = 'sea',
        canTransfer = false,
        blip = Config.Blips["depot"],
    },
    ["rigdepot"] = {
        label = 'Big Rig Depot',
        coords = vector3(2334.42, 3118.62, 48.2),
        spawns = {
            vector4(2324.57, 3117.79, 48.21, 4.05)
        },
        type = "depot",
        category = 'car',
        canTransfer = false,
        blip = Config.Blips["depot"],
    },
    ["dumborigparking"] = {
        label = 'Dumbo Big Rig Parking',
        coords = vector3(161.23, -3188.73, 5.97),
        spawns = {
            vector4(167.0, -3203.89, 5.94, 271.27)
        },
        type = "car",
        category = 'car',
        canTransfer = false,
        blip = Config.Blips["garage"],
    },
    ["popsrigparking"] = {
        label = 'Pop\'s Big Rig Parking',
        coords = vector3(137.67, 6632.99, 31.67),
        spawns = {
            vector4(127.69, 6605.84, 31.93, 223.67)
        },
        type = "car",
        category = 'car',
        canTransfer = false,
        blip = Config.Blips["garage"],
    },
    ["ronsrigparking"] = {
        label = 'Ron\'s Big Rig Parking',
        coords = vector3(-2529.37, 2342.67, 33.06),
        spawns = {
            vector4(-2521.61, 2326.45, 33.13, 88.7)
        },
        type = "car",
        category = 'car',
        canTransfer = false,
        blip = Config.Blips["garage"],
    },
    ["ronsrigparking2"] = {
        label = 'Ron\'s Big Rig Parking',
        coords = vector3(2561.67, 476.68, 108.49),
        spawns = {
            vector4(2561.67, 476.68, 108.49, 177.86)
        },
        type = "car",
        category = 'car',
        canTransfer = false,
        blip = Config.Blips["garage"],
    },
    ["ronsrigparking3"] = {
        label = 'Ron\'s Big Rig Parking',
        coords = vector3(-41.24, -2550.63, 6.01),
        spawns = {
            vector4(-39.39, -2527.81, 6.08, 326.18)
        },
        type = "car",
        category = 'car',
        canTransfer = false,
        blip = Config.Blips["garage"],
    }
}