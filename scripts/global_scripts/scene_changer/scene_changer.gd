extends Control

## This script handles smooth scene transitions using a fade-in/out animation.
## Usage :
## - Call `change_to("res://path/to/scene.tscn")` to trigger a fade-out, load the new scene,
##   and then fade-in.

var new_scene_path : String
@onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim.play("fade_in")
	SignalBus.connect("boss_defeated", game_win_state)

func game_win_state():
	change_to("res://scenes/ui/credits.tscn")


func change_to(new_scene : String):
	if new_scene.is_empty():
		push_error("SceneTransitionManager: Cannot change to an empty scene path.")
		return
	
	new_scene_path = new_scene
	anim.play("fade_out")

func _on_animation_player_animation_finished(anim_name : StringName) -> void:
	if anim_name == "fade_out" and new_scene_path != "":
		get_tree().change_scene_to_file(new_scene_path)
		anim.play("fade_in")
