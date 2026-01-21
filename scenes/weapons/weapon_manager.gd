class_name WeaponManager
extends Node

@export var equipped_weapon : WeaponResource
var weapon_quality : float
var weapon_mesh_container : BoneAttachment3D
var weapon_instance: Node3D
@onready var animator : Node3D = $"../Mesh"
var animations: Array[String] = []
var attack_anim_index: int = 0 
var hit_targets: Array[Node3D] = []
var active_trail: Node = null
var trail_active := false
var attack_queued = false
var current_attack_multiplier: float = 1.0

func _physics_process(_delta: float):
	if Input.is_action_just_pressed("debug_equip_sword"):
		equip(load("res://scenes/weapons/weapon_resources/sword.tres"), Global.WeaponQuality.POOR)

func _process(_delta: float) -> void:
	if trail_active and active_trail:
		active_trail.add_point()

func equip(weapon: WeaponResource, quality: Global.WeaponQuality) -> void:
	if weapon == null:
		return
	animator.current_weapon = weapon.weapon_type
	equipped_weapon = weapon
	weapon_quality = Global.QUALITY_MULTIPLIERS.get(quality, 1.0)

	_build_attack_animation_list()
	_clear_weapon_model()
	_spawn_weapon_model()
	#create model as child of weapon_mesh_container and apply transforms scaled with size modifier

func _clear_weapon_model() -> void:
	if weapon_instance:
		weapon_instance.queue_free()
		weapon_instance = null

func _spawn_weapon_model() -> void:
	if not equipped_weapon or not equipped_weapon.world_model:
		return

	if not weapon_mesh_container:
		weapon_mesh_container = get_parent().weapon_mesh_container
		if not weapon_mesh_container:
			push_error("weapon_mesh_container is null")
			return

	weapon_instance = equipped_weapon.world_model.instantiate()
	weapon_mesh_container.add_child(weapon_instance)
	
	apply_world_model_transforms(weapon_instance)

func _build_attack_animation_list() -> void:
	animations.clear()
	attack_anim_index = 0

	if equipped_weapon.attack1_anim != "":
		animations.append(equipped_weapon.attack1_anim)
	if equipped_weapon.attack2_anim != "":
		animations.append(equipped_weapon.attack2_anim)
	if equipped_weapon.attack3_anim != "":
		animations.append(equipped_weapon.attack3_anim)

func attack(target_dir: Vector3 = Vector3.ZERO) -> void:
	if not _has_weapon():
		return
	
	if animator.is_attacking:
		attack_queued = true
		return
	
	_play_attack_animation()

	match equipped_weapon.weapon_type:
		Global.WeaponType.LONG_SWORD, Global.WeaponType.BATTLE_AXE:
			_do_melee_attack()
		Global.WeaponType.BOW, Global.WeaponType.CROSSBOW:
			await get_tree().create_timer(0.5).timeout
			_do_projectile_attack(target_dir)
		Global.WeaponType.STAFF, Global.WeaponType.SPELL_BOOK:
			await get_tree().create_timer(0.5).timeout
			_do_projectile_attack(target_dir)

func _do_melee_attack() -> void:
	if not weapon_instance:
		return

	active_trail = weapon_instance.get_node_or_null("TrailRoot")
	if active_trail:
		trail_active = true
		active_trail.visible = true
	# This is where you would:
	# enable a hitbox
	# query overlapping bodies
	# apply damage
	pass

func _stop_trail() -> void:
	if active_trail:
		active_trail.stop()
		active_trail.visible = false
	trail_active = false
	active_trail = null
	if attack_queued:
		attack_queued = false
		attack()

func _do_projectile_attack(last_mouse_world_pos: Vector3) -> void:
	if equipped_weapon.projectile == null:
		return
	
	var target_dir = (last_mouse_world_pos - self.global_position).normalized()
	target_dir.y = 0
	target_dir = target_dir.normalized()
	
	var proj_instance = equipped_weapon.projectile.instantiate()
	get_tree().root.add_child(proj_instance)
	
	proj_instance.global_transform = weapon_mesh_container.global_transform
	
	if target_dir != Vector3.ZERO:
		proj_instance.direction = target_dir.normalized()
	else:
		proj_instance.direction = -weapon_mesh_container.global_transform.basis.z.normalized()
	
	proj_instance.damage = get_ranged_damage()
	proj_instance.shooter = get_parent()
	
func _play_attack_animation() -> void:
	if animator == null or animations.is_empty():
		return
		
	var anim_name := animations[attack_anim_index]
	match attack_anim_index:
		0: current_attack_multiplier = equipped_weapon.damage_mult1
		1: current_attack_multiplier = equipped_weapon.damage_mult2
		2: current_attack_multiplier = equipped_weapon.damage_mult3
		_: current_attack_multiplier = 1.0
		
	attack_anim_index = (attack_anim_index + 1) % animations.size()
	var speed := get_attack_speed()
	if animator.has_method("attack_animation"):
		animator.attack_animation(anim_name, speed)

func _stat(stat: int) -> float:
	return get_parent().stats.get(stat, 0.0)

func _has_weapon() -> bool:
	return equipped_weapon != null

func get_melee_damage() -> float:
	if not _has_weapon():
		return 0.0
		
	var base_dmg = equipped_weapon.base_damage * weapon_quality * (1.0 + _stat(Global.Stat.STRENGTH) * 0.04)
	return base_dmg * current_attack_multiplier

func get_ranged_damage() -> float:
	if not _has_weapon():
		return 0.0
		
	return equipped_weapon.base_damage * weapon_quality * (1.0 + _stat(Global.Stat.DEXTERITY) * 0.05)

func get_magic_damage() -> float:
	if not _has_weapon():
		return 0.0
		
	return equipped_weapon.base_damage * weapon_quality * (1.0 + _stat(Global.Stat.KNOWLEDGE) * 0.05)

func get_attack_speed() -> float:
	if not _has_weapon():
		return 1.0
		
	if [Global.WeaponType.BOW, Global.WeaponType.CROSSBOW].has(equipped_weapon.weapon_type):
		return equipped_weapon.base_attack_speed * (1.0 + _stat(Global.Stat.DEXTERITY) * 0.035)
		
	return equipped_weapon.base_attack_speed * (1.0 + _stat(Global.Stat.DEXTERITY) * 0.05)

func get_move_speed_multiplier() -> float:
	return 1.0 + _stat(Global.Stat.AGILITY) * 0.05

func get_roll_cooldown() -> float:
	return max(0.2, 1.5 - _stat(Global.Stat.AGILITY) * 0.03)

func get_stamina_cost() -> float:
	if not _has_weapon():
		return 0.0

	return equipped_weapon.base_stamina_cost / (1.0 + _stat(Global.Stat.STAMINA_REGEN) * 0.05)

func get_mana_cost() -> float:
	if not _has_weapon():
		return 0.0

	return equipped_weapon.base_mana_cost / (1.0 + _stat(Global.Stat.MANA_REGEN) * 0.05)

func get_attack_size() -> float:
	if not _has_weapon():
		return 1.0

	return equipped_weapon.base_size * weapon_quality * (1.0 + _stat(Global.Stat.ATTACK_SIZE) * 0.06)

func apply_world_model_transforms(weapon_node: Node3D) -> void:
	weapon_node.position = equipped_weapon.world_model_pos
	weapon_node.rotation = equipped_weapon.world_model_rot
	weapon_node.scale = equipped_weapon.world_model_scale * get_attack_size()

func start_attack_state() -> void:
	hit_targets = []
	
	#cant get this to work ignore for now
	#active_trail = weapon_instance.get_node_or_null("TrailRoot")
	#if active_trail:
		#trail_active = true
		#active_trail.visible = true
	
	var hitbox = _get_weapon_hitbox()
	if hitbox:
		hitbox.monitoring = true
		if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
			hitbox.body_entered.connect(_on_hitbox_body_entered)
	pass

func stop_attack_state() -> void:
	var hitbox = _get_weapon_hitbox()
	if hitbox:
		hitbox.monitoring = false
	#if active_trail:
		#active_trail.stop()
		#active_trail.visible = false
	#trail_active = false
	#active_trail = null
	pass

func _get_weapon_hitbox() -> Area3D:
	if weapon_instance:
		return weapon_instance.get_node_or_null("Hitbox") as Area3D
	return null

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy") and not hit_targets.has(body):
		hit_targets.append(body)
		if body.has_method("take_damage"):
			var damage = get_melee_damage()
			body.take_damage(damage)
			print("Hit %s for %f damage" % [body.name, damage])
