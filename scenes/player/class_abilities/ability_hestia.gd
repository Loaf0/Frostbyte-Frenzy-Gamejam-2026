extends Ability

@onready var bullet_manager: BossBulletManager = $BulletManager

func _ready() -> void:
	faith_cost = 120

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	print("Ability Used!")
	bullet_manager.pattern_radial_ring(12, 4, 4, get_damage())

func get_damage() -> float:
	var knowledge = player._stat(Global.Stat.KNOWLEDGE)
	return 2 + knowledge * 2
