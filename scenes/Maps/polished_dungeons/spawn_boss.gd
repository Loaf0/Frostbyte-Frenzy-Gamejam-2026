extends Area3D

@onready var body: AnimatableBody3D = $Body
@onready var boss_scene: PackedScene = preload("res://scenes/enemies/boss/boss.tscn")
@onready var boss_spawn_loc: Node3D = $boss_spawn_loc

var original_y := 0.0
var boss_spawned := false

func _ready() -> void:
	original_y = body.position.y
	body.position.y = 10000

func _on_body_entered(other: Node3D) -> void:
	print(other)
	if boss_spawned:
		return

	if not other.is_in_group("player"):
		return

	spawn_boss(other)

func spawn_boss(other: Node3D) -> void:
	body.position.y = original_y
	boss_spawned = true
	var boss_instance := boss_scene.instantiate()
	boss_instance.global_transform = boss_spawn_loc.global_transform
	other.get_parent().add_child(boss_instance)
