extends Enemy

@export var jump_cd: float = 6
var cd

func _physics_process(_delta):
	_target_check()
	
	var next_pos := nav_agent.get_next_path_position()
	var direction := (next_pos - global_position)
	
	if direction.length() < repath_distance:
		return
	
	direction = direction.normalized()
	velocity = direction * speed
	
	velocity.y = 0 if is_on_floor() else -4
	move_and_slide()

func _target_check():
	#edit this is different enemies to have different behaviors based on distance remaining
	if nav_agent.distance_to_target() <= 2:
		if lock:
			lock = false
		elif cd == jump_cd:
			#jump at player with a cleaving strike
			return
		elif nav_agent.is_navigation_finished():
			_attack()
			return
		return
