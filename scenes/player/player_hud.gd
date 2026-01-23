extends Control

@export var player : CharacterBody3D

@onready var roll_meter: TextureProgressBar = $RollMeter
@onready var health_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/HealthMeter
@onready var stamina_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/StaminaMeter
@onready var mana_meter: TextureProgressBar = $PlayerMeters/HBoxContainer/Control/ManaMeter


func _ready() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player") as Node3D
 
func _process(_delta: float) -> void:
	if player:
		update_values()

func update_values():
	var health_perc = player.current_health / player.max_health * 100
	health_meter.value = health_perc
