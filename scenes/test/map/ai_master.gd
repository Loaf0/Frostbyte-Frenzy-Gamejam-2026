extends Node3D

var target

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	if player:
		get_tree().call_group("enemy", "_set_player_target", player)
