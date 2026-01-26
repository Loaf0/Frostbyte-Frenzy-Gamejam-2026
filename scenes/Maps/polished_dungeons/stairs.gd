class_name Stairs
extends Interactable

var activated = false
var open_sfx = preload("res://assets/audio/sfx/Stairs.mp3")
@onready var mesh_root: Node3D = $Mesh
@onready var collision: CollisionShape3D = $AnimatableBody3D/CollisionShape3D
var original_y : float = 0

func _ready() -> void:
	collision.disabled = false
	original_y = mesh_root.position.y

func interact(_interactor: Node = null):
	if activated:
		Global.go_to_next_floor()

func activate():
	if not activated:
		Global.play_one_shot_sfx(open_sfx, 0.05, 0.0, -15)
		activated = true
		_start_wall_fade(0.0)

func deactivate():
	if activated:
		Global.play_one_shot_sfx(open_sfx, 0.05, 0.0, -15)
		activated = false
		_start_wall_fade(1.0)

func _start_wall_fade(target_alpha: float):
	collision.disabled = target_alpha == 0.0
	if target_alpha == 0.0:
		mesh_root.position.y = 10000
	else:
		mesh_root.position.y = original_y
