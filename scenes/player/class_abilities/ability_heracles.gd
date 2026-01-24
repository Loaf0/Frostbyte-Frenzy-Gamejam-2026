extends Ability

@onready var bullet_manager: BossBulletManager = $BulletManager

func _ready() -> void:
	faith_cost = 110

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	print("Ability Used!")
	bullet_manager.pattern_targeted_shot_position(_last_mouse_world_pos, 0.18, 7, 10.0, 4.0, get_damage())

func get_damage() -> float:
	var strength = player._stat(Global.Stat.STRENGTH)
	return 0.1 + strength * 3
