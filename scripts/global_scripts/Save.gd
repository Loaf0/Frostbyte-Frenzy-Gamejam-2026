extends Node

## TODO -- more in depth Implementation of this needs further breakdown to 
##         decide how to implment this

var save_file : ConfigFile = ConfigFile.new()
const SAVE_PATH : String = "user://save.cfg"

func save_all():
	save_player()
	save_settings()

func save_settings():
	var sfx_value := Global.sfx_volume
	var msfx_value := Global.music_volume
	
	save_file.set_value("Audio", "SFX_VOLUME", linear_to_db(sfx_value))
	save_file.set_value("Audio", "MSFX_VOLUME", linear_to_db(msfx_value))

	# Save the file
	save_file.save(SAVE_PATH)

func load_settings():
	var err = save_file.load(SAVE_PATH)
	if err != OK:
		return
	
	var sfx_value := float(save_file.get_value("Audio", "SFX_VOLUME", 1.0))
	var msfx_value := float(save_file.get_value("Audio", "MSFX_VOLUME", 1.0))

	Global.sfx_volume = sfx_value
	Global.music_volume = msfx_value

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(sfx_value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(msfx_value))

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

func reset_player_progress():
	Global.unlocked_characters.clear()

	for character in Global.CharacterClass.values():
		Global.unlocked_characters[character] = false

	Global.unlocked_characters[Global.CharacterClass.RANGER] = true

	save_file.set_value("Player", "UNLOCKED_CHARACTERS", Global.unlocked_characters)
	save_file.save(SAVE_PATH)
