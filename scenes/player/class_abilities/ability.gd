extends Node3D
class_name Ability

var faith_cost : int = 100
var player : CharacterBody3D

func _ready() -> void:
	pass

func use_ability(_last_mouse_world_pos: Vector3):
	if !player:
		player = get_parent()
	pass
	
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
