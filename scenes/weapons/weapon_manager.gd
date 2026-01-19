class_name WeaponManager
extends Node

@export var equipped_weapon : WeaponResource
var weapon_quality : float
var weapon_mesh_container : BoneAttachment3D
var weapon_instance: Node3D
@onready var animator : Node3D = $"../Mesh"
var animations: Array[String] = []
var attack_anim_index: int = 0 

#func _ready() -> void:
	#weapon_mesh_container = get_parent().weapon_mesh_container

func _physics_process(_delta: float):
	if Input.is_action_just_pressed("debug_equip_sword"):
		equip(load("res://scenes/weapons/weapon_resources/sword.tres"), Global.WeaponQuality.POOR)

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

func attack() -> void:
	if not _has_weapon():
		return

	_play_attack_animation()

	match equipped_weapon.weapon_type:
		Global.WeaponType.LONG_SWORD, Global.WeaponType.BATTLE_AXE:
			_do_melee_attack()
		Global.WeaponType.BOW, Global.WeaponType.CROSSBOW, Global.WeaponType.STAFF, Global.WeaponType.SPELL_BOOK:
			_do_projectile_attack()

func _do_melee_attack() -> void:
	# This is where you would:
	# enable a hitbox
	# query overlapping bodies
	# apply damage
	pass

func _do_projectile_attack() -> void:
	if equipped_weapon.projectile == null:
		return

	var projectile := equipped_weapon.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_transform = weapon_mesh_container.global_transform
	projectile.damage = get_ranged_damage()

func _play_attack_animation() -> void:
	if animator == null or animations.is_empty():
		return

	var anim_name := animations[attack_anim_index]
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
		
	return equipped_weapon.base_damage * weapon_quality * (1.0 + _stat(Global.Stat.STRENGTH) * 0.04)

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
