extends Ability

@export var ability_uptime : float = 5.0
@onready var particle = $GPUParticles3D
func _ready() -> void:
	faith_cost = 60

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	print("Ability Used!")
	player.dodge_cooldown = 0.25
	var timer = get_tree().create_timer(ability_uptime)
	timer.timeout.connect(_on_timer_timeout)
	particle.emitting = true
	
func _on_timer_timeout() -> void:
	particle.emitting = false
	player.dodge_cooldown = player.get_dodge_cooldown()
