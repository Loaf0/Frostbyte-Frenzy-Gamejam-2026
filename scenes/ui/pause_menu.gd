extends Control

@onready var start_button : Button = $CanvasLayer/MainMenu/VBoxContainer/Options/VBoxContainer/Resume
@onready var options_button : Button = $CanvasLayer/MainMenu/VBoxContainer/Options/VBoxContainer/Options
@onready var exit_button : Button = $CanvasLayer/MainMenu/VBoxContainer/Options/VBoxContainer/Quit

@onready var on_resume_sound : AudioStream = load("res://Assets/Audio/SFX/magic_ring_sfx.mp3")

@onready var main_menu : Control = $CanvasLayer/MainMenu
@onready var stats_menu : Control = $CanvasLayer/StatsMenu
@onready var options_menu : Control = $CanvasLayer/OptionsMenu
@onready var options_controls_menu : Control = $CanvasLayer/OptionsMenu/HBoxContainer/Controls
@onready var options_audio_menu : Control = $CanvasLayer/OptionsMenu/HBoxContainer/Audio

@onready var sens_slider : Slider = $CanvasLayer/OptionsMenu/HBoxContainer/Controls/VBoxContainer/Control/Sens
@onready var mfx_slider : Slider = $CanvasLayer/OptionsMenu/HBoxContainer/Audio/VBoxContainer/MFX/MFX_volume
@onready var sfx_slider : Slider = $CanvasLayer/OptionsMenu/HBoxContainer/Audio/VBoxContainer/SFX/SFX_volume
@onready var ufx_slider : Slider = $CanvasLayer/OptionsMenu/HBoxContainer/Audio/VBoxContainer/UFX/UFX_volume
@onready var ui : Control = $CanvasLayer
@onready var back := $TextureRect

var on_start_clicked : bool = false

func _ready() -> void:
	#load saved data
	sens_slider.value = Global.mouse_sensitivity / Global.default_mouse_sensitivity
	mfx_slider.value = Global.music_volume
	sfx_slider.value = Global.sfx_volume
	ufx_slider.value = Global.ufx_volume
	
	main_menu.visible = true
	back.visible = false
	stats_menu.visible = false
	options_menu.visible = false
	options_controls_menu.visible = false
	options_audio_menu.visible = false
	ui.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu_button"):
		if ui.visible:
			back.visible = false
			ui.visible = false
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			back.visible = true
			ui.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			main_menu.visible = true
			stats_menu.visible = false
			options_menu.visible = false
			options_controls_menu.visible = false
			options_audio_menu.visible = false

func _on_start_pressed() -> void:
	back.visible = false
	ui.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_open_options_pressed() -> void:
	main_menu.visible = false
	options_menu.visible = true
	options_controls_menu.visible = false
	options_audio_menu.visible = true
	pass

func _on_exit_pressed() -> void:
	Save.save_all()
	get_tree().quit()

func _on_open_options_controls_pressed() -> void:
	options_menu.visible = true
	options_controls_menu.visible = true
	options_audio_menu.visible = false
	pass

func _on_open_options_audio_pressed() -> void:
	options_menu.visible = true
	options_controls_menu.visible = false
	options_audio_menu.visible = true

func _on_return_to_main_menu_pressed() -> void:
	main_menu.visible = true
	stats_menu.visible = false
	options_menu.visible = false
	options_controls_menu.visible = false
	options_audio_menu.visible = false
	Global.update_volumes()

func _on_mfx_volume_value_changed(value: float) -> void:
	if options_audio_menu.visible and mfx_slider.drag_ended:
		Global.music_volume = value

func _on_ufx_volume_value_changed(value: float) -> void:
	#play some test sound
	if options_audio_menu.visible and ufx_slider.drag_ended:
		Global.ufx_volume = value

func _on_sfx_volume_value_changed(value: float) -> void:
	#play some test sound
	if options_audio_menu.visible and sfx_slider.drag_ended:
		Global.sfx_volume = value

func _on_sens_value_changed(value: float) -> void:
	if options_controls_menu.visible and sens_slider.drag_ended:
		Global.update_mouse_sens(value)

func _on_stats_pressed() -> void:
	#stats_menu.update_images()
	main_menu.visible = false
	stats_menu.visible = true
	#add return button
	pass
