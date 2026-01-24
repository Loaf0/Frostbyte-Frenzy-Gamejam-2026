extends Enemy

func _ready():
	speed = 3.0
	attack_damage = 5.0
	attack_range = 5.0
	attack_windup = 0.35
	attack_hit_time = 0.55
	max_health = 50
	anim_tree = $Skeleton_Rogue/Rig_Medium/AnimationTree
	melee_collision = $Skeleton_Rogue/Rig_Medium/GeneralSkeleton/WeaponSlot/Skeleton_Crossbow/MeleeHitbox/MeleeCollision
	state_machine = anim_tree.get("parameters/StateMachine/playback")
	origin = global_position
	_setup_dissolve_materials()
	_set_random_target()

func _physics_process(_delta):
	#print(state_machine.get_current_node())
	match state_machine.get_current_node():
		"actions_Idle_B":
			anim_tree.set("parameters/StateMachine/conditions/Wander", true)
		"movement_Walking_B":
			velocity = Vector3.ZERO
			
			var next_pos := nav_agent.get_next_path_position()
			var direction := (next_pos - global_position)
			
			if direction.length() < repath_distance:
				return
			
			direction = direction.normalized()
			velocity = direction * (speed/2)
			
			velocity.y = 0 if is_on_floor() else -4
			look_at(Vector3(next_pos.x, global_position.y, next_pos.z), Vector3.UP)
			anim_tree.set("parameters/StateMachine/conditions/Run", _is_player_reachable()) 
			move_and_slide()
		"movement_Running_B":
			velocity = Vector3.ZERO
			
			var next_pos := nav_agent.get_next_path_position()
			var direction := (next_pos - global_position)
			
			if direction.length() < repath_distance:
				return
			
			direction = direction.normalized()
			velocity = direction * speed
			
			velocity.y = 0 if is_on_floor() else -4
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			attacked = false
			anim_tree.set("parameters/StateMachine/conditions/Attack", _player_in_range()) 
			move_and_slide()
		"tools_Sawing":
			if !attacked:
				_attack()
				attacked = true
			anim_tree.set("parameters/StateMachine/conditions/Run", !_player_in_range())
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"actions_Death_A":
			_death()
