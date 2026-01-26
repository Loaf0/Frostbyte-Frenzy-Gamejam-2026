extends Ability

@export var ability_uptime : float = 10.0
@export var base_damage : float = 5.0
@export var weapon_quality : float = 5.0
@export var buff_amount := 1.5
@onready var particle = $GPUParticles3D

var mug_projectile : PackedScene = preload("res://scenes/weapons/projectiles/mug_empty.tscn")

var active_buff := {}
var _buff_timer: SceneTreeTimer = null
var _buff_active := false

func _ready() -> void:
	faith_cost = 60

func use_ability(last_mouse_world_pos: Vector3) -> void:
	if not player:
		player = get_parent()

	print("D-Ability Used!")
	particle.emitting = true
	_do_projectile_attack(last_mouse_world_pos)

	if _buff_active:
		if _buff_timer:
			_buff_timer = get_tree().create_timer(ability_uptime)
			_buff_timer.timeout.connect(_remove_stat_buff)
	else:
		_apply_stat_buff()
		_buff_active = true
		_buff_timer = get_tree().create_timer(ability_uptime)
		_buff_timer.timeout.connect(_remove_stat_buff)

func _apply_stat_buff() -> void:
	active_buff.clear()

	for stat in Global.Stat.values():
		active_buff[stat] = buff_amount
		Global.stats[stat] = Global.stats.get(stat, 0.0) + buff_amount

	player._recalculate_derived_stats()

func _remove_stat_buff() -> void:
	if not player:
		return
	particle.emitting = false
	for stat in active_buff.keys():
		Global.stats[stat] -= active_buff[stat]

	active_buff.clear()
	player._recalculate_derived_stats()
	_buff_active = false
	_buff_timer = null

func _stat(stat: int) -> float:
	return Global.stats.get(stat, 0.0)

func _do_projectile_attack(last_mouse_world_pos: Vector3) -> void:
	var target_dir = (last_mouse_world_pos - player.global_position)
	target_dir.y = 0.0

	if target_dir.length() == 0.0:
		target_dir = -player.global_transform.basis.z
	else:
		target_dir = target_dir.normalized()

	var proj_instance = mug_projectile.instantiate()
	get_tree().root.add_child(proj_instance)

	proj_instance.global_position = player.global_position + Vector3.UP
	proj_instance.direction = target_dir
	proj_instance.damage = base_damage * weapon_quality * (1.0 + _stat(Global.Stat.DEXTERITY) * 0.05)
	proj_instance.shooter = player
