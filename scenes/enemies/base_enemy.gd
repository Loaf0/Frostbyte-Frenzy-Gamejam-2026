extends CharacterBody3D
class_name Enemy

var bone_sfx = preload("res://assets/audio/sfx/bone-break-sfx-393835.mp3")
var sfx = preload("res://assets/audio/sfx/swing-whoosh-5-198498.mp3")
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
var state_machine: AnimationNodeStateMachinePlayback

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var nav_tester: NavigationAgent3D = $NavTester
var anim_tree: AnimationTree
@onready var collisionshape: CollisionShape3D = $CollisionShape3D
var melee_collision: CollisionShape3D

var origin: Vector3
var dissolve_materials: Array[ShaderMaterial] = []

func _ready():
	anim_tree = $Skeleton_Minion/Rig_Medium/AnimationTree
	melee_collision = $Skeleton_Minion/Rig_Medium/GeneralSkeleton/WeaponSlot/Skeleton_Blade/MeleeHitbox/MeleeCollision
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
		"melee_combat_Melee_1H_Attack_Stab":
			if !attacked:
				_attack()
				attacked = true
			anim_tree.set("parameters/StateMachine/conditions/Run", !_player_in_range())
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"actions_Death_A":
			_death()

func _is_player_reachable() -> bool:
	nav_tester.target_position = player.global_transform.origin
	if nav_tester.is_target_reachable():
		anim_tree.set("parameters/StateMachine/conditions/Wander", false)
		return true
	anim_tree.set("parameters/StateMachine/conditions/Wander", true)
	return false

func _player_in_range():
	return global_position.distance_to(player.global_position) < attack_range

func _attack():
	print("attack")
	await get_tree().create_timer(attack_windup).timeout
	damaged = false
	Global.play_one_shot_sfx(sfx, 0.05, 0.0, -15)
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

func take_damage(amount : float):
	current_health -= amount
	Global.play_one_shot_sfx(bone_sfx, 0.05, 0.1, -15)
	if current_health <= 0:
		anim_tree.set("parameters/StateMachine/conditions/Death", true)
		anim_tree.set("parameters/StateMachine/conditions/Attack", false)
	else:
		anim_tree.set("parameters/HitBlend/blend_amount", 0.8)
		anim_tree.set("parameters/HitMachine/conditions/Hit", true)
		await get_tree().create_timer(0.3).timeout
		anim_tree.set("parameters/HitBlend/blend_amount", 0.0)
		anim_tree.set("parameters/HitMachine/conditions/Hit", false)
		return

func _get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var found_meshes: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found_meshes.append(node)
	for child in node.get_children():
		found_meshes.append_array(_get_all_mesh_instances(child))
	return found_meshes

func _setup_dissolve_materials():
	var meshes = _get_all_mesh_instances(self)
	var shader_res = load("res://assets/shaders/dissolve.gdshader")
	
	for m in meshes:
		if m.mesh: 
			for i in m.mesh.get_surface_count():
				var old_mat = m.get_active_material(i)
				var original_tex = null
				
				if old_mat is StandardMaterial3D:
					original_tex = old_mat.albedo_texture
				
				var new_mat = ShaderMaterial.new()
				new_mat.shader = shader_res
				
				if original_tex:
					new_mat.set_shader_parameter("albedo_texture", original_tex)
				
				new_mat.set_shader_parameter("dissolve_value", 0.0)
				
				m.set_surface_override_material(i, new_mat)
				dissolve_materials.append(new_mat)

func _death():
	collisionshape.disabled = true
	melee_collision.disabled = true
	await anim_tree.animation_finished
	
	var tween = create_tween()
	tween.tween_method(
		func(val: float): 
			for mat in dissolve_materials:
				mat.set_shader_parameter("dissolve_value", val), 0.0, 1.0, 5.0
				)
	
	await tween.finished
	queue_free()
