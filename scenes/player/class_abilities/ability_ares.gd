extends Ability

const healing_sfx = preload("res://assets/audio/sfx/healing-magic-4-378668.mp3")
@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	faith_cost = 80

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	_play_one_shot_sfx(healing_sfx, 0.05, 0.0, -20)
	particles.emitting = true
	player.current_health += player.max_health / 2
	player.max_health = clamp(player.max_health, 0, player.max_health)
