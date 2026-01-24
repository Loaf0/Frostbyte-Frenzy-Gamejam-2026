extends Node3D

@onready var target = $SubViewportContainer/SubViewport/Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_tree().call_group("enemy", "_set_player_target", target.global_transform.origin)
