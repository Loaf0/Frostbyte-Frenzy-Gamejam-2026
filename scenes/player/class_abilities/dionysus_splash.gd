extends Node3D

var damage = 3
@onready var bullet_manager = $BulletManager

func _ready() -> void:
	bullet_manager.pattern_radial_ring(12, 4, .4, damage)
	$GPUParticles3D.emitting = true
	await get_tree().create_timer(10.0).timeout
	queue_free()
