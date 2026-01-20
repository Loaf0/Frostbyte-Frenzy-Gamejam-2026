extends Node3D

@export var target_path: NodePath
@export var offset := Vector3(-12, 20, -12)
@export var smooth_speed := 4.0
@export var lead_distance := 5.0
@export var lead_smooth_speed := 2.0
var look_distance : float = 0.0
var target: Node3D
var current_lead := Vector3.ZERO

func _ready() -> void:
	if target_path:
		target = get_node(target_path)

func _physics_process(delta: float) -> void:
	if not target:
		return

	var facing_dir = -target.global_transform.basis.z
	
	var target_lead = (facing_dir * lead_distance) * look_distance
	current_lead = current_lead.lerp(target_lead, lead_smooth_speed * delta)

	var target_pos = target.global_transform.origin + offset + current_lead
	
	var weight = 1.0 - exp(-smooth_speed * delta)
	global_transform.origin = global_transform.origin.lerp(target_pos, weight)
