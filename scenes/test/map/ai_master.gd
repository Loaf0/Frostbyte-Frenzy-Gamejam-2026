extends Node3D

@export var aggro_radius: float = 10.0
@export var aggro_interval: float = 1.5

var player: CharacterBody3D
var aggro_timer: Timer

func _ready() -> void:
	aggro_timer = Timer.new()
	aggro_timer.wait_time = aggro_interval
	aggro_timer.autostart = true
	aggro_timer.one_shot = false
	add_child(aggro_timer)
	aggro_timer.timeout.connect(_check_enemy_aggro)

func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	Global.player = player

func _check_enemy_aggro() -> void:
	if not is_instance_valid(Global.player):
		return
	var enemies := get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.is_in_group("boss"):
			continue
		if not is_instance_valid(enemy):
			continue
		if enemy.is_aggroed:
			continue
		if enemy.global_position.distance_to(Global.player.global_position) <= aggro_radius:
			enemy.aggro(Global.player)
