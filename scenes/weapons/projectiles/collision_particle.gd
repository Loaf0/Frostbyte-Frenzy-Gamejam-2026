extends GPUParticles3D

func _ready() -> void:
	emitting = true

func _on_finished() -> void:
	await get_tree().create_timer(2.0).timeout
	queue_free()
