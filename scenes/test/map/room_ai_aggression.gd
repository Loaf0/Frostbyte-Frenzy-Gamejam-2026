extends Area3D

var player: CharacterBody3D
var enemies_in_room: Array = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	await get_tree().create_timer(0.5).timeout
	_collect_enemies_in_room()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		for enemy in enemies_in_room:
			if is_instance_valid(enemy):
				enemy.aggro(player)
	
	if body.is_in_group("enemy"):
		enemies_in_room.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_room.erase(body)
	if body.is_in_group("player"):
		player = null

func _collect_enemies_in_room() -> void:
	enemies_in_room.clear()

	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy") and body not in enemies_in_room:
			enemies_in_room.append(body)

		if body.is_in_group("player"):
			player = body
