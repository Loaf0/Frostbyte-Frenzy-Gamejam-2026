extends CharacterBody3D

enum AttackType { NONE, MELEE, RANGED_SPIN, RANGED_WAVE, RANGED_CIRCLE, SUMMON}
var current_attack: int = AttackType.NONE
@onready var anim = $Skeleton_Mage/Rig_Medium/AnimationPlayer
@onready var bullet_manager: BossBulletManager = $BulletManager
@onready var melee_hitbox: Area3D = $Skeleton_Mage/Rig_Medium/GeneralSkeleton/RightHand/Skeleton_Blade/MeleeHitbox
@export var boss_max_stamina : float = 100.0
@export var max_health : float = 500
@onready var mesh = $Skeleton_Mage
var player_in_melee_range := false
var melee_active = false
var bone_sfx = preload("res://assets/audio/sfx/bone-break-sound-269658.mp3")
var attack_sfx1 = preload("res://assets/audio/sfx/earth-spell-393923.mp3")
var attack_sfx2 = preload("res://assets/audio/sfx/light-woosh-7119.mp3")
var attack_sfx3 = preload("res://assets/audio/sfx/metal-door-slam-172172.mp3")
@onready var boss_spawn: Node3D = $boss_spawn

var enemy_scenes := [
		preload("res://scenes/enemies/base_enemy.tscn"),
		preload("res://scenes/enemies/jump_enemy.tscn"),
		preload("res://scenes/enemies/ranged_enemy.tscn")
	]

@export var stamina_deplete_timeout: float = 8.5
var boss_stamina = boss_max_stamina
var boss_stamina_timeout: float = 0.0
var out_of_stamina: bool = false
var stamina_recovering: bool = false

@export var turn_speed := 6.0
var attack_target: Node3D = null

var next_phase_thres = max_health * 0.4
var hit_player = false
var attacking := false
var attack_index := 0
var attack_delay_timer : float
@export var attack_delay := 1.25

var current_health : float = max_health
var started_death_sequence = false
var dissolve_materials: Array[ShaderMaterial] = []

var boss_timeout : float = 0

func _ready() -> void:
	anim.speed_scale = 0.5
	anim.play("special/Spawn_Ground", 0.2)
	await anim.animation_finished
	anim.speed_scale = 1.0
	add_to_group("enemy")
	_setup_dissolve_materials()
	_start_ai()

func _start_ai() -> void:
	await get_tree().process_frame

	while is_inside_tree() and not started_death_sequence:
		if attack_delay_timer > 0.0:
			attack_delay_timer -= get_process_delta_time()
			await get_tree().process_frame
			continue
		
		if out_of_stamina:
			_handle_out_of_stamina()
			await get_tree().process_frame
			continue

		var player := get_tree().get_first_node_in_group("player") as Node3D
		if player:
			await do_attack(player)

		attack_delay_timer = attack_delay


func _handle_out_of_stamina() -> void:
	if boss_stamina_timeout == stamina_deplete_timeout:
		anim.play("simulation/Sit_Floor_Down", 0.2)
		hit_player = false
		attacking = false
		current_attack = AttackType.NONE

	boss_stamina_timeout -= get_process_delta_time()
	if boss_stamina_timeout <= 0.0:
		boss_stamina = boss_max_stamina
		out_of_stamina = false
		boss_stamina_timeout = 0.0
		anim.play("simulation/Sit_Floor_StandUp", 0.2)

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

func _on_death():
	$CollisionShape3D.set_deferred("disabled", true)
	started_death_sequence = true
	bullet_manager.queue_free()
	anim.play("actions/Death_A", 0.4)
	await anim.animation_finished
	
	var tween = create_tween()
	tween.tween_method(
		func(val: float): 
			for mat in dissolve_materials:
				mat.set_shader_parameter("dissolve_value", val), 0.0, 1.0, 5.0
				)
	
	await tween.finished
	SignalBus.boss_defeated.emit()
	await get_tree().create_timer(5.0).timeout
	queue_free()

func take_damage(amount : float):
	current_health -= amount
	if current_health <= 0 and not started_death_sequence:
		_on_death()

func _process(delta: float) -> void:
	$Label3D.text = "HEALTH: " + str(current_health) + "/" + str(max_health)

	if started_death_sequence:
		if anim.current_animation != "actions/Death_A":
			anim.play("actions/Death_A_Pose", 0.4)
		return

	if attack_delay_timer > 0.0:
		attack_delay_timer -= delta

	if out_of_stamina:
		if not stamina_recovering:
			anim.play("simulation/Sit_Floor_Down", 0.2)
			stamina_recovering = true
			boss_stamina_timeout = stamina_deplete_timeout

		boss_stamina_timeout -= delta
		if boss_stamina_timeout <= 0.0:
			boss_stamina = boss_max_stamina
			out_of_stamina = false
			stamina_recovering = false
			current_attack = AttackType.NONE
			anim.play("actions/Idle_A", 0.5)
		
	if attacking and current_attack != AttackType.NONE and attack_target and is_instance_valid(attack_target):
		_face_target(delta)


func _face_target(delta: float) -> void:
	var to_target := attack_target.global_position - global_position
	to_target.y = 0.0

	if to_target.length_squared() < 0.001:
		return

	var desired_basis := Basis.looking_at(to_target.normalized(), Vector3.UP)

	var current_q := global_transform.basis.get_rotation_quaternion()
	var target_q := desired_basis.get_rotation_quaternion()

	var t = clamp(turn_speed * delta, 0.0, 1.0)
	var new_q := current_q.slerp(target_q, t)

	global_transform.basis = Basis(new_q)

func _get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var found_meshes: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found_meshes.append(node)
	for child in node.get_children():
		found_meshes.append_array(_get_all_mesh_instances(child))
	return found_meshes

func do_attack(player: Node3D) -> void:
	if attacking or started_death_sequence or out_of_stamina:
		return

	hit_player = false
	attacking = true
	attack_target = player

	var attack_options := []

	if player_in_melee_range:
		if randf() <= 0.8:
			attack_options.append(AttackType.MELEE)

	if attack_options.is_empty():
		attack_options.append(AttackType.RANGED_SPIN)
		attack_options.append(AttackType.RANGED_WAVE)
		attack_options.append(AttackType.RANGED_CIRCLE)
		if current_health <= max_health * 0.5 and randf() <= 0.5:
			attack_options.append(AttackType.SUMMON)

	var chosen_attack = attack_options[randi() % attack_options.size()]

	match chosen_attack:
		AttackType.MELEE:
			current_attack = AttackType.MELEE
			await melee_attack()
		AttackType.RANGED_SPIN:
			current_attack = AttackType.RANGED_SPIN
			await ranged_spin_attack()
		AttackType.RANGED_WAVE:
			current_attack = AttackType.RANGED_WAVE
			await ranged_wave_attack(player)
		AttackType.RANGED_CIRCLE:
			current_attack = AttackType.RANGED_CIRCLE
			await ranged_circle_attack()
		AttackType.SUMMON:
			current_attack = AttackType.SUMMON
			await summon_attack()

	attacking = false
	current_attack = AttackType.NONE
	attack_target = null

func melee_attack() -> void:
	use_stamina(35, 5)
	if out_of_stamina:
		return

	anim.speed_scale = 0.5
	anim.play("melee_combat/Melee_1H_Attack_Slice_Diagonal")

	await get_tree().create_timer(0.65).timeout
	melee_active = true
	hit_player = false

	var active_time := 0.4
	var elapsed := 0.0

	while elapsed < active_time:
		_check_melee_hit()
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	melee_active = false
	anim.speed_scale = 1.0

	await get_tree().create_timer(0.15).timeout

func ranged_spin_attack() -> void:
	#Melee_2H_Attack_Spin
	#attack and shoot proj #spin and shoot projectiles in direction facing
	use_stamina(20, 10)
	if out_of_stamina:
		return
	anim.play("melee_combat/Melee_2H_Attack_Spin", 0.2)
	await get_tree().create_timer(0.5).timeout
	anim.play("melee_combat/Melee_2H_Attack_Spinning", 0.2)
	
	Global.play_one_shot_sfx(attack_sfx2, 0.05, 2.75, -20)
	if bullet_manager:
		bullet_manager.pattern_spiral(40, 0.04, 12.0, 3.5, 5)
	await get_tree().create_timer(1.5).timeout
	anim.play("actions/Idle_B", 0.5)

func ranged_wave_attack(player: Node3D) -> void:
	use_stamina(7.5, 8)
	if out_of_stamina:
		return
	anim.play("melee_combat/Melee_Dualwield_Attack_Stab",)
	anim.speed_scale = 1.0
	await get_tree().create_timer(0.5).timeout
	Global.play_one_shot_sfx(attack_sfx1, 0.05, 0.6, -20)
	if bullet_manager:
		bullet_manager.pattern_targeted_shot(player, 0.18, 7, 10.0, 4.0, 5)

func ranged_circle_attack() -> void:
	#movement/Jump_Full_Short_Attack
	#shoot full circle of projectiles
	use_stamina(25, 10)
	if out_of_stamina:
		return
	anim.speed_scale = 0.5
	anim.play("movement/Jump_Full_Short_Attack", 0.5)
	await get_tree().create_timer(1.5).timeout
	Global.play_one_shot_sfx(attack_sfx3, 0.05, 0.0, -20)
	if bullet_manager:
		bullet_manager.pattern_radial_ring(18, 8.0, 5.0, 5)
	await anim.animation_finished
	anim.speed_scale = 1.0

func summon_attack() -> void:
	use_stamina(30, 12.0)
	if out_of_stamina:
		return

	anim.play("simulation/Cheering", 0.2)
	await get_tree().create_timer(0.5).timeout

	var player := get_tree().get_first_node_in_group("player") as CharacterBody3D
	if not player:
		return

	for i in range(1):
		var scene_to_spawn = enemy_scenes[randi() % enemy_scenes.size()]
		var enemy_instance := scene_to_spawn.instantiate() as CharacterBody3D

		get_parent().add_child(enemy_instance)
		enemy_instance.global_position = boss_spawn.global_position
		
		if enemy_instance.has_method("_set_player_target"):
			enemy_instance._set_player_target(player)

	Global.play_one_shot_sfx(bone_sfx, 0.05, 0.0, -15)

	await get_tree().create_timer(1.0).timeout
	anim.play("actions/Idle_B", 0.5)

func use_stamina(cost: float, delay: float = 1.0) -> void:
	boss_stamina -= cost
	attack_delay_timer += delay

	if boss_stamina <= 0 and not out_of_stamina:
		boss_stamina = 0
		out_of_stamina = true
		boss_stamina_timeout = stamina_deplete_timeout
	
func _on_melee_hit(target: Node3D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(10)

func _check_melee_hit() -> void:
	if hit_player:
		return

	var bodies := melee_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			hit_player = true
			_on_melee_hit(body)
			return


func _on_melee_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_melee_range = true


func _on_melee_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_melee_range = false
