extends Node3D

@export var rotate_speed : Vector3 = Vector3(-300, 300, 0)

func _process(delta: float) -> void:
	rotation_degrees += rotate_speed * delta
	
