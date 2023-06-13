<h1 align="center">
	  CALL A TAXI
</h1>

<h3 align="center">
	  DESCRIPTION
</h3>

Will call a taxi by using a command (default `/takso`). The taxi will drive to the player from the nearest coordinate in config.spawnCoords. When it has arrived, It will wait for the player to sit into the vehicle. When player has selected a waypoint, it will start driving to that location. If it arrives at the location it waits for player to get out of the vehicle (you can change config to make the player automatically get out of the vehicle) and then drive away. After a certain amount of time (configurable in the config) it will delete the ped and the vehicle.

The script is client-side and averages about 0.10ms to 0.20ms on the resource monitor.
<h3 align="center">
	  PROBLEMS/ERRORS
</h3>

I made this just for fun. If you need any help with the resource you can contact me in discord, but before doing so make sure you've tried everything to fix the issue you're dealing with. Only contact me if you really need help, like something doesn't work. Don't contact me if you just want to ask 'how can i use this resource'. There are tutorials everywhere on how to install resources to your server.

<h3 align="center">
	  POSSIBLE UPDATES
</h3>

* Add a button to make the driver drive recklessly (run over red lights, take over vehicles etc)
* Add a button to Stop or pause the vehicle while driving
* Some sort of payment system (needs esx or qbcore)
