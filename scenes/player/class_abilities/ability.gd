extends Node3D
class_name Ability

var faith_cost : int = 100
var player : CharacterBody3D

func _ready() -> void:
	pass

func use_ability():
	if !player:
		player = get_parent()
	pass
	
