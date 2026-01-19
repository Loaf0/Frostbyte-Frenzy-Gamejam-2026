extends Node3D
class_name Ability

var faith_cost : int = 100
var player : CharacterBody3D

func _ready() -> void:
	if(get_parent().is_in_group("player")):
		player = get_parent()
	else:
		push_error("No player found")

func use_ability():
	return
