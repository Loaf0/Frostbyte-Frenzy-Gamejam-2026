extends CharacterBody3D
class_name Enemy

@export var wander_radius: float = 20.0
@export var speed: float = 3.0
@export var repath_distance: float = 0.5

var lock: bool = true

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var origin: Vector3

func _ready():
	origin = global_position
	_set_random_target()

func _physics_process(_delta):
	if _target_check():
		return
	
	
	var next_pos := nav_agent.get_next_path_position()
	var direction := (next_pos - global_position)
	
	if direction.length() < repath_distance:
		return
	
	direction = direction.normalized()
	velocity = direction * speed
	
	velocity.y = 0 if is_on_floor() else -4
	move_and_slide()

func _target_check() -> bool:
	#edit this is different enemies to have different behaviors based on distance remaining
	if nav_agent.distance_to_target() <= 2 or !nav_agent.is_target_reachable():
		if lock:
			_set_random_target()
			lock = false
		else:
			_attack()
			return true
		return true
	return false



func _attack():
	look_at(nav_agent.target_position)
	#play attack anim
	print("attack!")
	return


func _set_player_target(target):
	if !lock:
		print("check")
		nav_agent.target_position = target
		if !nav_agent.is_target_reachable():
			print("deep")
			_set_random_target()
			lock = true
	return

func _set_random_target():
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)

	var target := origin + random_offset
	nav_agent.target_position = target
	if !nav_agent.is_target_reachable():
		lock = false
