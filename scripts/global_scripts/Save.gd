extends Node

## TODO -- more in depth Implementation of this needs further breakdown to 
##         decide how to implment this

var save_file : ConfigFile = ConfigFile.new()
const SAVE_PATH : String = "user://save.cfg"

func save_all():
	save_player()
	save_settings()

func save_settings():
	print(ProjectSettings.globalize_path("user://save.cfg"))
	#save_file.set_value("Settings", "MOUSE_SENS", Global.mouse_sensitivity)
	#save_file.set_value("Settings", "UFX_VOL", Global.ufx_volume)
	#save_file.set_value("Settings", "SFX_VOL", Global.sfx_volume)
	#save_file.set_value("Settings", "MFX_VOL", Global.music_volume)
	
	save_file.save(SAVE_PATH)

func load_settings():
	var err = save_file.load(SAVE_PATH)
	if err != OK:
		return
	
	#Global.mouse_sensitivity = save_file.get_value("Settings", "MOUSE_SENS", 1) # default to 1 if none were saved
	#Global.ufx_volume = save_file.get_value("Settings", "UFX_VOL", .75)
	#Global.sfx_volume = save_file.get_value("Settings", "SFX_VOL", .75)
	#Global.music_volume = save_file.get_value("Settings", "MFX_VOL", .75)

func save_player():
	save_file.set_value("Player", "ABILITY_1_UNLOCKED", false)
	save_file.save(SAVE_PATH)

# would pass in player reference and apply all stored values
func load_player():
	var err = save_file.load(SAVE_PATH)
	if err != OK:
		return
	
	# load player data
	pass
