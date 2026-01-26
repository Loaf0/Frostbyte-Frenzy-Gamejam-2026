extends Area3D

var player: CharacterBody3D
var enemies_in_room: Array = []
@export var stairs : Node3D
@export var check_interval: float = 0.5

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	await get_tree().create_timer(1.0).timeout
	_collect_enemies_in_room()
	_start_enemy_check_timer()

func _on_body_entered(body: Node) -> void:
	await get_tree().create_timer(0.5).timeout
	if body.is_in_group("player"):
		player = body
		for enemy in enemies_in_room:
			if is_instance_valid(enemy):
				enemy.aggro(player)
	if body.is_in_group("enemy"):
		enemies_in_room.append(body)
	await get_tree().create_timer(1.0).timeout
	_collect_enemies_in_room()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_room.erase(body)
	if body.is_in_group("player"):
		player = null

func _collect_enemies_in_room() -> void:
	enemies_in_room.clear()
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body not in enemies_in_room:
			enemies_in_room.append(body)
		if body.is_in_group("player"):
			player = body

func _start_enemy_check_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = check_interval + randf_range(0.1, 0.5)
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_check_enemies_cleared)

func _check_enemies_cleared() -> void:
	enemies_in_room = enemies_in_room.filter(is_instance_valid)

	if stairs:
		if enemies_in_room.is_empty():
			stairs.activate()
		else:
			stairs.deactivate()
