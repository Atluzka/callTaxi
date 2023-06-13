local taxi_exists = false
local your_coords = nil
local nearestDistance = nil
local spawnVehicleCoords = nil


-- taxi vehicle and ped inside the vehicle
local ped = nil
local veh = nil

local vehicleDriveAway = false
local vehicleParked = false
local vehicleArrived = nil
local taxiDriving = false

local playerInTaxi = false

local pedcoords = nil

Citizen.CreateThread(function()
    RegisterCommand(config.commandName, function()
        TriggerEvent('callataxi:calltaxi')
    end)
end)

RegisterNetEvent('callataxi:calltaxi', function()
    -- check if taxi already exists
    if taxi_exists then
        print('[' .. string.upper(config.commandName) .. '] Taxi is already on the way!')
        return
    end
    
    -- get the required variables
    your_coords = GetEntityCoords(GetPlayerPed(-1))
    
    -- get the nearest spawn location to player
    for _,loc in pairs(config.spawnCoords) do
        heading = loc.h 
        loc = vector3(loc.x, loc.y, loc.z)
        local tempDis = GetDistanceBetweenCoords(loc, your_coords)
        if nearestDistance then
            if tempDis < nearestDistance then
                nearestDistance = tempDis
                spawnVehicleCoords = loc
            else
                nearestDistance = nearestDistance
            end
        else
            nearestDistance = tempDis
            spawnVehicleCoords = loc
        end
    end
    
    -- request the models needed
    while not HasModelLoaded(GetHashKey(config.Vehicle)) do
        RequestModel(GetHashKey(config.Vehicle))
        Wait(10)
    end
    while not HasModelLoaded(GetHashKey(config.pedmodel)) do
        RequestModel(GetHashKey(config.pedmodel))
        Wait(10)
    end
    
    -- spawn a vehicle & ped
    taxi_exists = true
    ped = CreatePed(0, GetHashKey(config.pedmodel), spawnVehicleCoords, heading, true)
    veh = CreateVehicle(GetHashKey(config.Vehicle), spawnVehicleCoords, heading, true)
    
    -- put ped into vehicle
    TaskWarpPedIntoVehicle(ped, veh, -1)

    -- other stuff
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetEntityAsMissionEntity(veh, true, true)

    -- start driving to player location
    driveToLocation(your_coords.x, your_coords.y, your_coords.z)
end)

-- make vehicle taxi to location
function driveToLocation(x, y, z)
    TaskVehicleDriveToCoordLongrange(ped, veh, x, y, z, config.carspeed, config.drivestyle, 5.0)
    if vehicleDriveAway then
        Citizen.Wait(config.deleteTimer)
        DeletePed(ped)
        DeleteVehicle(veh)
    end
end

function parkVehicle(x, y, z)
    local ret, coordsTemp, heading = GetClosestVehicleNodeWithHeading(x, y, z, 1, 3.0, 0)
    local retval, coordsSide = GetPointOnRoadSide(coordsTemp.x, coordsTemp.y, coordsTemp.z)
    driveToLocation(coordsSide.x, coordsSide.y, coordsSide.z)
    vehicleParked = true
end

-- the vehicle arrived at destination
function atDestination()
    while veh == GetVehiclePedIsIn(GetPlayerPed(-1), false) do
        Wait(1000)
        if
        TaskLeaveVehicle(GetPlayerPed(-1), veh, 1)
    end
    Wait(100)
    vehicleDriveAway = true
    driveToLocation(909.479248, -176.718689, 74.217491)
    Wait(10)
    ped = nil
    veh = nil
    vehicleDriveAway = false
    vehicleParked = false
    vehicleArrived = nil
    taxiDriving = false
    playerInTaxi = false
    your_coords = nil
    nearestDistance = nil
    spawnVehicleCoords = nil
    taxi_exists = false
    pedcoords = nil
end

-- park the vehicle

-- waits for player to sit into the vehicle
Citizen.CreateThread(function()
    while true do
        if taxi_exists and not playerInTaxi then
            if veh ~= nil then
                if vehicleParked and not playerInTaxi and not vehicleDriveAway then
                    if IsControlJustReleased(0, 23) and GetLastInputMethod(2) then
                        TaskEnterVehicle(GetPlayerPed(-1), veh, 1000, math.random(0,2), 2.0, 1, 0)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- get players current coordinate
Citizen.CreateThread(function()
    while taxi_exists do
        if taxi_exists then
            your_coords = GetEntityCoords(GetPlayerPed(-1))
        end
        Citizen.Wait(0)
    end
end)

-- draw a marker above the vehicle
Citizen.CreateThread(function()
	while true do
        if config.display_marker then
            vehicleCoords = GetEntityCoords(veh)
            if ped ~= nil and not vehicleDriveAway then
                if GetDistanceBetweenCoords(vehicleCoords, mycoords) > 2 then
                    DrawMarker(0, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z+3, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 2.0, 244, 123, 23, 100, true, true, 2, true, false, false, false)
                end
            end
        end
        Citizen.Wait(0)
	end
end)

-- check if the driver is alive
Citizen.CreateThread(function()
    while true do
        if taxi_exists then
            if ped ~= nil then
                if IsPedDeadOrDying(ped, 1) then
                    ped = nil
                    veh = nil
                    vehicleDriveAway = false
                    vehicleParked = false
                    vehicleArrived = nil
                    taxiDriving = false
                    playerInTaxi = false
                    your_coords = nil
                    nearestDistance = nil
                    spawnVehicleCoords = nil
                    taxi_exists = false
                    pedcoords = nil
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- wait for player to put a waypoint
Citizen.CreateThread(function()
    while true do
        if taxi_exists then
            if veh ~= nil then
                if veh == GetVehiclePedIsIn(GetPlayerPed(-1), false) then
                    playerInTaxi = true
                    local waypoint = GetFirstBlipInfoId(8)
                    pedcoords = GetEntityCoords(GetPlayerPed(-1))
                    if not DoesBlipExist(waypoint) and not taxiDriving then
                        Citizen.Wait(1000)
                    else
                        tx, ty, tz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, waypoint, Citizen.ResultAsVector()))
                        if not taxiDriving then
                            if not targetX then
                                targetX = tx
                                targetY = ty
                                targetZ = tz
                            end
                            driveToLocation(tx, ty, tz)
                            taxiDriving = true
                        end
                        local distancebetweencoord = GetDistanceBetweenCoords(pedcoords.x, pedcoords.y, pedcoords.z, targetX, targetY, targetZ, true)
                        --print(distancebetweencoord)
                        if distancebetweencoord <= 20 then
                            atDestination()
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- park vehicle
Citizen.CreateThread(function()
    while true do
        if taxi_exists and not vehicleParked then
            if veh ~= nil then
                vehCoords = GetEntityCoords(ped)
                local distanceBetweenTaxi = GetDistanceBetweenCoords(your_coords.x, your_coords.y, your_coords.z, vehCoords.x, vehCoords.y, vehCoords.z, true)
                if distanceBetweenTaxi <= 20 then
                    if not vehicleParked then
                        parkVehicle(your_coords.x, your_coords.y, your_coords.z)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)
