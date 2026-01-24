extends CharacterBody3D
class_name Enemy

@export var wander_radius: float = 20.0
@export var speed: float = 4.0
@export var repath_distance: float = 0.5
@export var attack_damage: float = 3.5
@export var attack_range: float = 2.0
@export var attack_windup: float = 0.4
@export var attack_hit_time: float = 0.25
@export var max_health = 50
var current_health = max_health
var attacked: bool = false
var damaged: bool = true

var player: CharacterBody3D
var state_machine

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var nav_tester: NavigationAgent3D = $NavTester
@onready var anim_tree: AnimationTree = $Skeleton_Minion/Rig_Medium/AnimationTree
@onready var collisionshape: CollisionShape3D = $CollisionShape3D
@onready var melee_collision: CollisionShape3D = $Skeleton_Minion/Rig_Medium/GeneralSkeleton/WeaponSlot/Skeleton_Blade/MeleeHitbox/MeleeCollision

var origin: Vector3

func _ready():
	state_machine = anim_tree.get("parameters/playback")
	origin = global_position
	_set_random_target()

func _physics_process(_delta):
	#print(state_machine.get_current_node())
	match state_machine.get_current_node():
		"actions_Idle_B":
			anim_tree.set("parameters/conditions/Wander", true)
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
			anim_tree.set("parameters/conditions/Run", _is_player_reachable()) 
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
			anim_tree.set("parameters/conditions/Attack", _player_in_range()) 
			move_and_slide()
		"melee_combat_Melee_1H_Attack_Stab":
			if !attacked:
				_attack()
				attacked = true
			anim_tree.set("parameters/conditions/Run", !_player_in_range())
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"actions_Death_A":
			pass
		"actions_Hit_B":
			pass

func _is_player_reachable() -> bool:
	nav_tester.target_position = player.global_transform.origin
	if nav_tester.is_target_reachable():
		anim_tree.set("parameters/conditions/Wander", false)
		return true
	anim_tree.set("parameters/conditions/Wander", true)
	return false

func _player_in_range():
	return global_position.distance_to(player.global_position) < attack_range

func _attack():
	print("attack")
	await get_tree().create_timer(attack_windup).timeout
	damaged = false
	melee_collision.disabled = false
	await get_tree().create_timer(attack_hit_time).timeout
	damaged = true
	melee_collision.disabled = true
	return

func _on_melee_hitbox_body_entered(body: Node) -> void:
	if damaged:
		return
	if body.is_in_group("enemy"):
		return
	
	if body.is_in_group("player"):
		if body.is_dodging:
			return
		elif body.has_method("take_damage"):
			damaged = true
			body.take_damage(attack_damage)
			return

func _set_player_target(target: CharacterBody3D):
	if player == null:
		player = target
	if _is_player_reachable():
		#print("player")
		nav_agent.target_position = target.global_transform.origin
	elif nav_agent.is_navigation_finished():
		print("wander")
		_set_random_target()
	return

func _set_random_target():
	var random_offset := Vector3(
		randf_range(-wander_radius, wander_radius),
		0.0,
		randf_range(-wander_radius, wander_radius)
	)

	var target := origin + random_offset
	nav_agent.target_position = target
