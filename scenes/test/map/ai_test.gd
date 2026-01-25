extends Node3D

@onready var target: CharacterBody3D = $SubViewportContainer/SubViewport/Player

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	get_tree().call_group("enemy", "_set_player_target", target)
