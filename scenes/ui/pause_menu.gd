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
	
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_exit_pressed() -> void:
	Save.save_all()
	get_tree().quit()


func _on_stats_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	pass # Replace with function body.
