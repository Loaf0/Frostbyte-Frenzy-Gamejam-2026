extends Node3D

const CLASS_SHEETS : Dictionary[Global.CharacterClass, String] = {
	Global.CharacterClass.RANGER : "res://scenes/player/class_stats/ranger_class.tres",
	Global.CharacterClass.MAGE : "res://scenes/player/class_stats/mage_class.tres",
	Global.CharacterClass.KNIGHT : "res://scenes/player/class_stats/knight_class.tres",
	Global.CharacterClass.BARBARIAN : "res://scenes/player/class_stats/barbarian_class.tres",
	Global.CharacterClass.ROGUE : "res://scenes/player/class_stats/rogue_class.tres",
	Global.CharacterClass.SKELETON : "res://scenes/player/class_stats/skeleton_class.tres"
}
var loaded_class_sheets: Dictionary[Global.CharacterClass, ClassResource] = {}
@onready var camera: Camera3D = $SubViewportContainer/SubViewport/POI/Camera3D

@onready var main_menu_music = preload("res://assets/audio/music/mystical-music-54294.mp3")
@onready var character_select_sfx = preload("res://assets/audio/sfx/characterselectedsound.mp3")
@onready var button_press = preload("res://assets/audio/sfx/select-button-ui-395763.mp3")

@onready var music = preload("res://assets/audio/music/mystical-music-54294.mp3")
@onready var music_player: AudioStreamPlayer3D = $SubViewportContainer/SubViewport/MusicPlayer

@onready var main_location : Node3D = $SubViewportContainer/SubViewport/POI/MAIN_LOCATION
@onready var options_location : Node3D = $SubViewportContainer/SubViewport/POI/OPTIONS
@onready var poi_folder: Node3D = $SubViewportContainer/SubViewport/POI

@onready var character_container : Node3D = $SubViewportContainer/SubViewport/World/Characters

@onready var character_pois: Array[Node3D] = [
	$SubViewportContainer/SubViewport/POI/CHARACTER_0,
	$SubViewportContainer/SubViewport/POI/CHARACTER_1,
	$SubViewportContainer/SubViewport/POI/CHARACTER_2,
	$SubViewportContainer/SubViewport/POI/CHARACTER_3,
	$SubViewportContainer/SubViewport/POI/CHARACTER_4,
	$SubViewportContainer/SubViewport/POI/CHARACTER_5
]

# menus
@onready var main_menu: Control = $SubViewportContainer/SubViewport/MainMenu
@onready var character_select: Control = $SubViewportContainer/SubViewport/CharacterSelect
@onready var options: Control = $SubViewportContainer/SubViewport/Options

# Character Select
@onready var character_name: Label = $SubViewportContainer/SubViewport/CharacterSelect/CharacterName
@onready var god_name: Label = $SubViewportContainer/SubViewport/CharacterSelect/GodName
@onready var stats: Label = $SubViewportContainer/SubViewport/CharacterSelect/Stats

# options
@onready var sfx_volume: HSlider = $SubViewportContainer/SubViewport/Options/sfx_volume
@onready var msfx_volume: HSlider = $SubViewportContainer/SubViewport/Options/msfx_volume
@onready var completion_percentage: Label = $"SubViewportContainer/SubViewport/Options/completion percentage"


@export var lerp_speed: float = 5.0
var target_poi: Node3D
var current_character_index: int = 0

@export var game_scene : String = "res://scenes/test/map/test_boss.tscn"

func _ready() -> void:
	Save.load_player()
	update_character_visibility()
	_load_all_class_sheets()
	target_poi = main_location
	_set_menu_state(true, false, false)
	sfx_volume.value = Global.sfx_volume
	msfx_volume.value = Global.music_volume

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Global.sfx_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Global.music_volume))

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			var index = event.keycode - KEY_1
			go_to_character(index)
		if event.keycode == KEY_0:
			go_to_main()

func update_character_visibility() -> void:
	for character_class in Global.name_map.keys():
		var node_name: String = Global.name_map[character_class]

		var model: Node3D = character_container.get_node_or_null(node_name)
		if model:
			model.visible = Global.unlocked_characters.get(character_class, false)

func _process(delta: float) -> void:
	if not target_poi or not camera:
		return
	
	var weight = lerp_speed * delta
	
	camera.global_position = camera.global_position.lerp(target_poi.global_position, weight)
	camera.quaternion = camera.quaternion.slerp(target_poi.quaternion, weight)

	if camera.projection == Camera3D.PROJECTION_ORTHOGONAL:
		var target_zoom = target_poi.get("camera_zoom") if "camera_zoom" in target_poi else 9.5
		camera.size = lerp(camera.size, target_zoom, weight)
	

func go_to_character(id: int):
	if id >= 0 and id < character_pois.size():
		if Global.unlocked_characters.get(id, false):
			target_poi = character_pois[id]
			update_character_ui(id)

func go_to_main():
	target_poi = main_location

func _get_class_sheet_for_index(index: int) -> ClassResource:
	var character_class: Global.CharacterClass = Global.CharacterClass.values()[index]
	return loaded_class_sheets.get(character_class, null)

func _get_stat(sheet: ClassResource, stat: Global.Stat) -> float:
	if sheet == null or sheet.stat_modifiers == null:
		return 0.0

	for mod in sheet.stat_modifiers:
		if mod != null and mod.stat == stat:
			return mod.amount

	return 0.0

func update_character_ui(index: int) -> void:
	var sheet := _get_class_sheet_for_index(index)
	if sheet == null:
		character_name.text = "Unknown"
		god_name.text = ""
		stats.text = ""
		return

	character_name.text = sheet.name
	god_name.text = sheet.god_subtitle

	var weapon_name_text := "None"
	if sheet.starting_weapon != null:
		weapon_name_text = sheet.starting_weapon.weapon_name

	stats.text = (
		"Weapon : %s\n\n" % weapon_name_text +
		"Vigor : %s\n" % str(_get_stat(sheet, Global.Stat.VIGOR)) +
		"Strength : %s\n" % str(_get_stat(sheet, Global.Stat.STRENGTH)) +
		"Agility : %s\n" % str(_get_stat(sheet, Global.Stat.AGILITY)) +
		"Dexterity : %s\n" % str(_get_stat(sheet, Global.Stat.DEXTERITY)) +
		"Knowledge : %s\n" % str(_get_stat(sheet, Global.Stat.KNOWLEDGE)) +
		"Faith : %s" % str(_get_stat(sheet, Global.Stat.FAITH))
	)

func _load_all_class_sheets() -> void:
	loaded_class_sheets.clear()

	for character_class in CLASS_SHEETS.keys():
		var path: String = CLASS_SHEETS[character_class]
		var sheet := load(path) as ClassResource
		if sheet == null:
			continue

		loaded_class_sheets[character_class] = sheet

func _on_character_confirm_selection_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	var selected_class: Global.CharacterClass = Global.CharacterClass.values()[current_character_index]
	Global.selected_character = selected_class
	Global.reset_run_state()
	_fade_out_music()

	Global.selected_character = selected_class

	Global.generate_dungeon(2)
	await get_tree().create_timer(1.5).timeout
	Global.go_to_next_floor()

func _on_prev_character_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	var tries := 0
	while tries < character_pois.size():
		current_character_index = (current_character_index - 1 + character_pois.size()) % character_pois.size()
		if Global.unlocked_characters.get(current_character_index, false):
			go_to_character(current_character_index)
			return
		tries += 1

func _on_next_character_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	var tries := 0
	while tries < character_pois.size():
		current_character_index = (current_character_index + 1) % character_pois.size()
		if Global.unlocked_characters.get(current_character_index, false):
			go_to_character(current_character_index)
			return
		tries += 1

func _on_go_to_character_select_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	_set_menu_state(false, true, false)
	go_to_character(current_character_index)

func _on_go_to_options_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	_set_menu_state(false, false, true)
	target_poi = options_location
	
	var total_chars := Global.CharacterClass.values().size() - 1
	var unlocked := -1
	for i in Global.CharacterClass.values():
		if Global.unlocked_characters.get(i, false):
			unlocked += 1

	var completion_percent := roundf(float(unlocked) / float(total_chars) * 100.0)
	completion_percentage.text = "Completion: " + str(completion_percent) + "%"

func _on_exit_game_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	get_tree().quit()

func _on_character_select_return_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	_set_menu_state(true, false, false)
	target_poi = main_location

func _set_menu_state(show_main: bool, show_char_select: bool, show_options: bool) -> void:
	main_menu.visible = show_main
	character_select.visible = show_char_select
	options.visible = show_options

func _on_msfx_volume_value_changed(_value: float) -> void:
	if int(_value) % 15 == 0:
		_play_one_shot_sfx(button_press, 0.05, 0.0, -50, "Music")
	var bus_index = AudioServer.get_bus_index("Music") 
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(_value))

func _on_sfx_volume_value_changed(_value: float) -> void:
	if int(_value) % 15 == 0:
		_play_one_shot_sfx(button_press, 0.05, 0.0)
	var bus_index = AudioServer.get_bus_index("Master") 
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(_value))

func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var bus_index = AudioServer.get_bus_index("Master") 
		var slider_value = sfx_volume.value 
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(slider_value))
		Global.sfx_volume = slider_value 

func _on_msfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var bus_index = AudioServer.get_bus_index("Music")
		var slider_value = msfx_volume.value
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(slider_value))
		Global.music_volume = slider_value 

func _on_back_pressed() -> void:
	_play_one_shot_sfx(button_press, 0.05, 0.0)
	Save.save_settings()
	go_to_main()
	_set_menu_state(true, false, false)
	
func _fade_out_music():
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, 2.0)
	await tween.finished
	music_player.stop()

func _play_one_shot_sfx(
	sfx: AudioStream,
	pitch_range: float = 0.05,
	start_time: float = 0.0,
	volume_db: float = 0.0,
	bus_name: String = "SFX"
) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = sfx
	player.bus = bus_name

	pitch_range = clamp(pitch_range, 0.0, 0.08)
	player.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)

	player.volume_db = volume_db

	player.finished.connect(player.queue_free)

	player.play(start_time)


func _on_reset_pressed() -> void:
	Save.reset_player_progress()
	SceneChanger.change_to("res://scenes/Maps/MainMenuMap.tscn")
