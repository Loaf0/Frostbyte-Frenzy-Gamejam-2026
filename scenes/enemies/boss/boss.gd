extends CharacterBody3D

@onready var anim = $Skeleton_Mage/Rig_Medium/AnimationPlayer
@onready var bullet_manager: BossBulletManager = $BulletManager
@onready var melee_hitbox: Area3D = $Skeleton_Mage/Rig_Medium/GeneralSkeleton/RightHand/Skeleton_Blade/MeleeHitbox
@export var boss_max_stamina : float = 100.0
@export var max_health = 50
var next_phase_thres = max_health * 0.4

var attacking := false
var attack_index := 0
var attack_delay_timer : float
@export var attack_delay := 1.25

var current_health = max_health
var started_death_sequence = false
var dissolve_materials: Array[ShaderMaterial] = []

var boss_stamina = 100
var boss_stamina_deplete_timeout : float = 2.5
var boss_timeout : float = 0

func _ready() -> void:
	anim.play("special/Spawn_Ground")
	await anim.animation_finished
	add_to_group("enemy")
	_setup_dissolve_materials()
	_start_ai()

func _start_ai() -> void:
	await get_tree().process_frame

	while is_inside_tree() and not started_death_sequence:
		if boss_timeout > 0.0 or attack_delay_timer > 0.0:
			await get_tree().process_frame
			continue

		var player := get_tree().get_first_node_in_group("player") as Node3D
		if player:
			do_attack(player)

		attack_delay_timer = attack_delay

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
	$CollisionShape3D.disabled = true
	started_death_sequence = true
	anim.play("actions/Death_A")
	await anim.animation_finished
	
	var tween = create_tween()
	tween.tween_method(
		func(val: float): 
			for mat in dissolve_materials:
				mat.set_shader_parameter("dissolve_value", val), 0.0, 1.0, 5.0
				)
	
	await tween.finished
	await get_tree().create_timer(5.0).timeout
	queue_free()

func take_damage(amount : float):
	current_health -= amount
	if current_health <= 0 and not started_death_sequence:
		_on_death()

func _process(delta: float) -> void:
	$Label3D.text = "HEALTH: " + str(current_health) + "/" + str(max_health)
	
	if attack_delay_timer > 0.0:
		attack_delay_timer -= delta
		if boss_timeout > 0.0: # boss timeout should add time so wait to continue timer
			boss_timeout -= delta

func _get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var found_meshes: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found_meshes.append(node)
	for child in node.get_children():
		found_meshes.append_array(_get_all_mesh_instances(child))
	return found_meshes

func do_attack(player: Node3D) -> void:
	if attacking or started_death_sequence:
		return

	attacking = true

	match attack_index:
		0:
			ranged_wave_attack(player)
		1:
			ranged_circle_attack()
		2:
			ranged_spin_attack()
		3:
			melee_attack()

	attack_index = (attack_index + 1) % 4
	attacking = false

func melee_attack() -> void:
	use_stamina(35)
	
	anim.speed_scale = 0.5
	anim.play("melee_combat/Melee_1H_Attack_Slice_Diagonal")
	await get_tree().create_timer(0.25).timeout
	
	anim.speed_scale = 1.0
	melee_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout

	melee_hitbox.monitoring = false

func ranged_spin_attack() -> void:
	#Melee_2H_Attack_Spin
	#attack and shoot proj #spin and shoot projectiles in direction facing
	use_stamina(20, 2.5)
	anim.play("melee_combat/Melee_2H_Attack_Spin")

	await bullet_manager.pattern_spiral(60, 0.04, 12.0, 3.5)

func ranged_wave_attack(player: Node3D) -> void:
	use_stamina(7.5, 2.0)

	anim.play("actions/Hit_B")
	bullet_manager.pattern_targeted_shot(player, 0.18, 7, 10.0, 4.0)

func ranged_circle_attack() -> void:
	#movement/Jump_Full_Short_Attack
	#shoot full circle of projectiles
	use_stamina(25, 4.0)
	anim.play("movement/Jump_Full_Short_Attack")
	await get_tree().create_timer(0.15).timeout
	
	bullet_manager.pattern_radial_ring(32, 8.0, 5.0)

func summon_attack() -> void:
	use_stamina(30, 2.5)
	#summon two enemies
	#simulation/cheering
	#must wait need enemies to be added
	pass

func use_stamina(cost: float, delay: float = 1.0) -> void:
	boss_stamina -= cost
	attack_delay_timer += delay

	if boss_stamina <= 0:
		boss_timeout = boss_stamina_deplete_timeout
		boss_stamina = boss_max_stamina


func _on_melee_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(15)
