extends Control

@export var player : CharacterBody3D
@export var offset: Vector3 = Vector3(2.0, 1.0, 0)
@export var smoothing: float = 8.0

@onready var roll_radial: Sprite2D = $Sprite2D
@onready var health_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/HealthMeter
@onready var stamina_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/StaminaMeter
@onready var mana_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/ManaMeter
@onready var ability_spot: TextureProgressBar = $PlayerMeters/HBoxContainer/AbilitySpot
@onready var item_description: Label = $"Item Description"
@onready var boss_bar: ProgressBar = $BossBar
var boss_ref: Node = null

var roll_target_screen_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player_ui")
	if not player:
		player = get_tree().get_first_node_in_group("player") as Node3D

func _process(delta: float) -> void:
	if player:
		update_values()
		update_roll_position(delta)
		update_roll_frame()
		update_ability_spot()
	
	update_boss_bar()

func update_values():
	if not player:
		return
	if player.max_health <= 0 or player.max_stamina <= 0 or player.max_mana <= 0:
		return
	
	health_meter.value = player.current_health / player.max_health * 100
	stamina_meter.value = player.current_stamina / player.max_stamina * 100
	mana_meter.value = player.current_mana / player.max_mana * 100

func update_roll_position(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	roll_target_screen_pos = camera.unproject_position(player.global_position + offset)
	roll_radial.position = roll_radial.position.lerp(roll_target_screen_pos, smoothing * delta)

func update_roll_frame():
	var cd : float = player.dodge_cd_timer
	var max_cd : float = player.dodge_cooldown
	var frame: int = 0

	if cd <= 0.0:
		frame = 8
	else:
		var perc = clamp(cd / max_cd, 0.0, 1.0)
		frame = 7 - int(round(perc * 7.0))

	roll_radial.frame = frame

func update_ability_spot():
	if not player:
		return

	var perc = clamp(player.current_faith / player.max_faith, 0.0, 1.0)
	ability_spot.value = perc * 100.0

	var min_modulate := Color(0.5, 0.5, 0.5, 1.0)
	var full_modulate := Color(1, 1, 1, 1)
	ability_spot.modulate = min_modulate.lerp(full_modulate, perc)

func update_item_description(item_or_weapon: Object) -> void:
	if item_or_weapon == null:
		item_description.text = ""
		return
	
	if item_or_weapon is WeaponResource:
		if item_or_weapon is WeaponResource:
			var quality_name = Global.QUALITY_NAMES.get(item_or_weapon.pickup_quality, "Unknown")
			item_description.text = (
				str(item_or_weapon.weapon_name) + " (" + quality_name + ")")
	elif item_or_weapon is ItemResource:
		item_description.text = str(item_or_weapon.item_name) + "\n" + str(item_or_weapon.item_desc)
	elif item_or_weapon is Chest:
		if !item_or_weapon.looted:
			item_description.text = "Open Chest"
		else:
			item_description.text = "Looted Chest"
	elif item_or_weapon is Interactable:
		item_description.text = "Descend Stairs"

func update_boss_bar() -> void:
	if boss_ref == null or not is_instance_valid(boss_ref):
		var bosses = get_tree().get_nodes_in_group("boss")
		if bosses.is_empty():
			boss_bar.visible = false
			boss_ref = null
			return
		else:
			boss_ref = bosses[0]
			boss_bar.visible = true

	if not boss_ref:
		boss_bar.visible = false
		return

	if boss_ref.max_health <= 0:
		boss_bar.visible = false
		return

	var perc = clamp(
		boss_ref.current_health / boss_ref.max_health,0.0,1.0)

	boss_bar.value = perc * 100.0
