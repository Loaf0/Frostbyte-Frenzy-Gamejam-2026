extends Control

enum MenuState {
	PAUSE,
	STATS,
	OPTIONS
}

var menu_state: MenuState = MenuState.PAUSE

@onready var pause_menu: Control = $MenuContainer/PauseMenu
@onready var stats_menu: Control = $MenuContainer/StatsMenu
@onready var options_menu: Control = $MenuContainer/OptionsMenu

# pause
@onready var resume: Button = $MenuContainer/PauseMenu/Resume
@onready var stats: Button = $MenuContainer/PauseMenu/Stats
@onready var options: Button = $MenuContainer/PauseMenu/Options
@onready var quit: Button = $MenuContainer/PauseMenu/Quit

#stats
@onready var stats_back: Button = $MenuContainer/StatsMenu/Back
@onready var character_label: Label = $MenuContainer/StatsMenu/Character
@onready var god_label: Label = $MenuContainer/StatsMenu/God
@onready var stats_label: Label = $MenuContainer/StatsMenu/Stats


#options
@onready var sfx_volume: HSlider = $MenuContainer/OptionsMenu/sfx_volume
@onready var msfx_volume: HSlider = $MenuContainer/OptionsMenu/msfx_volume
@onready var options_back: Button = $MenuContainer/OptionsMenu/Back

var on_start_clicked : bool = false

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_volume.value = Global.sfx_volume
	msfx_volume.value = Global.music_volume

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu_button"):
		set_paused(not self.visible)

		if self.visible:
			pause_menu.visible = true
			stats_menu.visible = false
			options_menu.visible = false

func _on_exit_pressed() -> void:
	Save.save_all()
	SceneChanger.change_to("res://scenes/Maps/MainMenuMap.tscn")
	set_paused(false)

func set_menu_state(state: MenuState) -> void:
	menu_state = state

	match state:
		MenuState.PAUSE:
			_set_menu_state(true, false, false)
		MenuState.STATS:
			_set_menu_state(false, true, false)
		MenuState.OPTIONS:
			_set_menu_state(false, false, true)


func _set_menu_state(pause_state: bool, stats_state: bool, options_state: bool) -> void:
	pause_menu.visible = pause_state
	stats_menu.visible = stats_state
	options_menu.visible = options_state

func _on_stats_pressed() -> void:
	set_menu_state(MenuState.STATS)
	
	var players := get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		character_label.text = "No player found"
		stats_label.text = ""
		god_label.text = ""
		return

	var player := players[0] as CharacterBody3D

	var char_name := "Unknown"
	var god_name_text := ""
	if "character_type" in player:
		char_name = str(player.char_name)
		god_name_text = str(player.god_name_text)

	character_label.text = char_name
	god_label.text = god_name_text

	var weapon_name_text := "None"
	if player.weapon_manager and player.weapon_manager.equipped_weapon:
		weapon_name_text = player.weapon_manager.equipped_weapon.weapon_name

	stats_label.text = (
		"Weapon : %s\n\n" % weapon_name_text +
		"Vigor : %s\n" % str(player.stats.get(Global.Stat.VIGOR, 0.0)) +
		"Strength : %s\n" % str(player.stats.get(Global.Stat.STRENGTH, 0.0)) +
		"Dexterity : %s\n" % str(player.stats.get(Global.Stat.DEXTERITY, 0.0)) +
		"Knowledge : %s\n" % str(player.stats.get(Global.Stat.KNOWLEDGE, 0.0)) +
		"Faith : %s\n" % str(player.stats.get(Global.Stat.FAITH, 0.0)) +
		"Mana Regen : %s\n" % str(player.stats.get(Global.Stat.MANA_REGEN, 0.0)) +
		"Stamina Regen : %s" % str(player.stats.get(Global.Stat.STAMINA_REGEN, 0.0))
	)

func _on_options_pressed() -> void:
	set_menu_state(MenuState.OPTIONS)

func _get_parent_subviewport() -> SubViewport:
	var node := self as Node
	while node:
		if node is SubViewport:
			return node
		node = node.get_parent()
	return null

func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	self.visible = paused
	var sv := _get_parent_subviewport()
	if sv:
		sv.process_mode = (
			Node.PROCESS_MODE_DISABLED
			if paused
			else Node.PROCESS_MODE_PAUSABLE
		)

	self.visible = paused

func _on_resume_pressed() -> void:
	set_paused(false)

func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var v := sfx_volume.value
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("SFX"),
			linear_to_db(v)
		)
		Global.sfx_volume = v
		Save.save_settings()

func _on_msfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		var v := msfx_volume.value
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"),
			linear_to_db(v)
		)
		Global.music_volume = v
		Save.save_settings()

func _on_back_pressed() -> void:
	set_menu_state(MenuState.PAUSE)
	
