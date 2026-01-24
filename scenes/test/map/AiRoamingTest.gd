extends CharacterBody3D

@export var wander_radius: float = 20.0
@export var speed: float = 3.0
@export var repath_distance: float = 0.5

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var origin: Vector3

func _ready():
	origin = global_position
	_set_random_target()

func _physics_process(_delta):
	if nav_agent.is_navigation_finished():
		_set_random_target()
		return

	var next_pos := nav_agent.get_next_path_position()
	var direction := (next_pos - global_position)

	if direction.length() < repath_distance:
		return

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

func _set_random_target():
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)

	var target := origin + random_offset
	nav_agent.target_position = target
