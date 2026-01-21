extends Ability

@export var ability_uptime : float = 5.0

@export var base_damage : float = 5.0
@export var weapon_quality : float = 5.0
var mug_projectile : PackedScene = preload("res://scenes/weapons/projectiles/mug_empty.tscn")

func _ready() -> void:
	faith_cost = 60

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	print("D-Ability Used!")
	
	#drink anim
	#save current stats
	#increase stats
	
	#player.dodge_cooldown = 0.25
	_do_projectile_attack(_last_mouse_world_pos)
	
	#return stats to save state (uh oh if player gets item during stat buff)
	
	var timer = get_tree().create_timer(ability_uptime)
	timer.timeout.connect(_on_timer_timeout)
	
func _on_timer_timeout() -> void:
	#player.dodge_cooldown = player.get_dodge_cooldown()
	return

func _stat(stat: int) -> float:
	return get_parent().stats.get(stat, 0.0)

func _do_projectile_attack(last_mouse_world_pos: Vector3) -> void:
	var target_dir = (last_mouse_world_pos - self.global_position).normalized()
	target_dir.y = 0
	target_dir = target_dir.normalized()
	
	
	var proj_instance = mug_projectile.instantiate()
	get_tree().root.add_child(proj_instance)
	
	proj_instance.global_transform = get_parent().global_transform
	proj_instance.global_transform.origin.y +=1
	
	if target_dir != Vector3.ZERO:
		proj_instance.direction = target_dir.normalized()
	else:
		proj_instance.direction = -get_parent().global_transform.basis.z.normalized()
	
	proj_instance.damage = base_damage * weapon_quality * (1.0 + _stat(Global.Stat.DEXTERITY) * 0.05)
	proj_instance.shooter = get_parent()
