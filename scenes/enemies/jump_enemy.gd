extends Enemy

var jump_dir: Vector3
var jumped: bool
var attack_sfx = preload("res://assets/audio/sfx/bone-break-sound-269658.mp3")

func _ready():
	add_to_group("enemy")
	floor_max_angle = deg_to_rad(80) 
	floor_snap_length = 0.5 
	speed = 2.0
	attack_damage = 5.0
	attack_range = 5.0
	attack_windup = 0.35
	attack_hit_time = 0.55
	max_health = 50
	anim_tree = $Skeleton_Warrior/Rig_Medium/AnimationTree
	melee_collision = $Skeleton_Warrior/Rig_Medium/GeneralSkeleton/MeleeHitbox/MeleeCollision
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
		"melee_combat_Melee_1H_Attack_Jump_Chop":
			if !attacked:
				_attack()
				Global.play_one_shot_sfx(attack_sfx, 0.05, 0.0, -15)
				var next_pos := nav_agent.get_next_path_position()
				var direction := (next_pos - global_position)
				jump_dir = direction.normalized()
				attacked = true
			velocity = Vector3.ZERO
			velocity = jump_dir * (speed+1.2)*2
			
			velocity.y = 0 if is_on_floor() else -4
			move_and_slide()
			anim_tree.set("parameters/StateMachine/conditions/Run", !_player_in_range())
		"actions_Death_A":
			_death()
