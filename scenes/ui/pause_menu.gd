extends CanvasLayer

@onready var resume: Button = $MenuContainer/PauseMenu/VBoxContainer/Buttons/VBoxContainer/Resume
@onready var stats: Button = $MenuContainer/PauseMenu/VBoxContainer/Buttons/VBoxContainer/Stats
@onready var options: Button = $MenuContainer/PauseMenu/VBoxContainer/Buttons/VBoxContainer/Options
@onready var quit: Button = $MenuContainer/PauseMenu/VBoxContainer/Buttons/VBoxContainer/Quit

@onready var pause_menu: Control = $MenuContainer/PauseMenu
@onready var stats_menu: Control = $MenuContainer/StatsMenu
@onready var options_menu: Control = $MenuContainer/OptionsMenu

var on_start_clicked : bool = false

func _ready() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu_button"):
		if self.visible:
			self.visible = false
			get_tree().paused = false
		else:
			self.visible = true
			get_tree().paused = true
			pause_menu.visible = true
			stats_menu.visible = false
			options_menu.visible = false

func _on_exit_pressed() -> void:
	Save.save_all()
	get_tree().quit()


func _on_stats_pressed() -> void:
	pause_menu.visible = false
	stats_menu.visible = true
	pass # Replace with function body.


func _on_options_pressed() -> void:
	pause_menu.visible = false
	options_menu.visible = true
	pass # Replace with function body.
