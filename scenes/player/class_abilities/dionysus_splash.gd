extends Node3D

var damage = 3
@onready var bullet_manager = $BulletManager
@onready var sfx1 = preload("res://assets/audio/sfx/slime-splat-5-219251.mp3")
@onready var sfx2 = preload("res://assets/audio/sfx/wood-smash-1-170410.mp3")

func _ready() -> void:
	bullet_manager.pattern_radial_ring(12, 4, .4, damage)
	$GPUParticles3D.emitting = true
	_play_one_shot_sfx(sfx2, 0.05, 0.2, -10)
	await get_tree().create_timer(0.25).timeout
	_play_one_shot_sfx(sfx1, 0.05, 0.0, -25)
	await get_tree().create_timer(10.0).timeout
	queue_free()

func _play_one_shot_sfx(
	sfx: AudioStream,
	pitch_range: float = 0.05,
	start_time: float = 0.0,
	volume_db: float = 0.0,
	bus_name: String = "SFX"
) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = sfx
	player.bus = bus_name

	pitch_range = clamp(pitch_range, 0.0, 0.08)
	player.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)

	player.volume_db = volume_db

	player.finished.connect(player.queue_free)

	player.play(start_time)
