extends Ability

@export var ability_uptime : float = 3.0
@export var base_damage : float = 2.0
@onready var particle = $GPUParticles3D

var coin_projectile : PackedScene = preload("res://scenes/weapons/projectiles/coin_projectile.tscn")

func _ready() -> void:
	faith_cost = 5

func use_ability(last_mouse_world_pos: Vector3) -> void:
	if not player:
		player = get_parent()

	print("C-Ability Used!")
	particle.emitting = true
	_do_projectile_attack(last_mouse_world_pos)

func _do_projectile_attack(last_mouse_world_pos: Vector3) -> void:
	var target_dir = (last_mouse_world_pos - player.global_position)
	target_dir.y = 0.0

	if target_dir.length() == 0.0:
		target_dir = -player.global_transform.basis.z
	else:
		target_dir = target_dir.normalized()

	var proj_instance = coin_projectile.instantiate()
	get_tree().root.add_child(proj_instance)

	proj_instance.global_position = player.global_position + Vector3.UP
	proj_instance.direction = target_dir
	proj_instance.damage = base_damage
	proj_instance.shooter = player
