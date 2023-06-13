config = {}

-- self explanatory
config.commandName = 'takso'

-- the vehicle model
config.Vehicle = 'taxi'

-- the driver aka ped model
config.pedmodel = 's_m_y_clown_01'

-- how fast does the vehicle drive
config.carspeed = 25.0

-- Makes the player leave the vehicle if they've arrived at the destination.
config.automaticallyLeaveVehicle = true

-- Draws a marker on top of the taxi vehicle
config.display_marker = true

-- Timer until the vehicle will be deleted after ariving at the destination
config.deleteTimer = 10000

-- default/normal: 786603
config.drivestyle = 786603 -- gtaforums.com/topic/822314-guide-driving-styles
config.spawnCoords = {
    downtowncab = {x = 909.479248, y = -176.718689, z = 74.217491, h = 238.659}
}