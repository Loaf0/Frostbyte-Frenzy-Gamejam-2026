extends Control

@export var player : CharacterBody3D
@export var offset: Vector3 = Vector3(2.0, 1.0, 0)
@export var smoothing: float = 8.0

@onready var roll_radial: Sprite2D = $Sprite2D
@onready var health_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/HealthMeter
@onready var stamina_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/StaminaMeter
@onready var mana_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/ManaMeter

var roll_target_screen_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player") as Node3D

func _process(delta: float) -> void:
	if player:
		update_values()
		update_roll_position(delta)
		update_roll_frame()

func update_values():
	health_meter.value = player.current_health / player.max_health * 100
	stamina_meter.value = player.current_stamina / player.max_stamina * 100
	mana_meter.value = player.current_mana / player.max_mana * 100

func update_roll_position(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	roll_target_screen_pos = camera.unproject_position(player.global_position + offset)

	var target_pos := roll_target_screen_pos
	roll_radial.position = roll_radial.position.lerp(target_pos, smoothing * delta)

func update_roll_frame():
	if not player:
		return

	var cd : float = player.dodge_cd_timer
	var max_cd : float = player.dodge_cooldown
	var frame: int = 0

	if cd <= 0.0:
		frame = 8
	else:
		var perc = clamp(cd / max_cd, 0.0, 1.0)
		frame = 7 - int(round(perc * 7.0))

	roll_radial.frame = frame
