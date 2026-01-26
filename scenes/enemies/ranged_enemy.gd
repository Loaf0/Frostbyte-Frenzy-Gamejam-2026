extends Enemy

@onready var bullet_manager: BossBulletManager = $BulletManager
var attack_sfx = preload("res://assets/audio/sfx/bow-release-bow-and-arrow-4-101936.mp3")

func _ready():
	floor_max_angle = deg_to_rad(80) 
	floor_snap_length = 0.5 
	add_to_group("enemy")
	speed = 2.0
	attack_damage = 5.0
	attack_range = 10.0
	attack_windup = 0.35
	attack_hit_time = 0.55
	max_health = 20
	anim_tree = $Skeleton_Rogue/Rig_Medium/AnimationTree
	melee_collision = $Skeleton_Rogue/Rig_Medium/GeneralSkeleton/WeaponSlot/Skeleton_Crossbow/MeleeHitbox/MeleeCollision
	state_machine = anim_tree.get("parameters/StateMachine/playback")
	origin = global_position
	damaged = true
	melee_collision.disabled = true
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
			if !global_position.is_equal_approx(Vector3(next_pos.x, global_position.y, next_pos.z)):
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

func _attack():
	print("attack")
	await get_tree().create_timer(attack_windup).timeout
	Global.play_one_shot_sfx(attack_sfx, 0.05, 0.0, -15)
	bullet_manager.fire_bullet(player.global_position-global_position, 10.0, 5.0, attack_damage)
	await get_tree().create_timer(attack_hit_time).timeout
	return
