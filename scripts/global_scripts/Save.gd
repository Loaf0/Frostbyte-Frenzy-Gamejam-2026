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
	
	save_file.save(SAVE_PATH)

func load_settings():
	var err = save_file.load(SAVE_PATH)
	if err != OK:
		return
	

func save_player():
	save_file.set_value("Player", "UNLOCKED_CHARACTERS", Global.unlocked_characters)
	save_file.save(SAVE_PATH)

func load_player():
	var err = save_file.load(SAVE_PATH)
	if err != OK:
		return
	
	var loaded_chars = save_file.get_value("Player", "UNLOCKED_CHARACTERS", {})
	
	for char_key in loaded_chars:
		Global.unlocked_characters[int(char_key)] = loaded_chars[char_key]
