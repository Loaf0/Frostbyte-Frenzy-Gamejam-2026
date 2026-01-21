extends Node3D
class_name Ability

var faith_cost : int = 100
var player : CharacterBody3D

func _ready() -> void:
	pass

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	pass
	
