extends Node

## This class acts as a global area to connect signals between scripts
## across the project.
## Usage :
## - Define custom signals here, e.g., `signal player_died`
## - Emit from anywhere: `SignalBus.player_died.emit()`
## - Connect from anywhere: `SignalBus.player_died.connect(target_method)`
