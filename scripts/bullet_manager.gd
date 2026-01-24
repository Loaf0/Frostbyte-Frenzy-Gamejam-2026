class_name BossBulletManager
extends Node3D

@export var bullet_scene: PackedScene
@export var bullet_speed: float = 12.0
@export var bullet_lifetime: float = 6.0
@export var spawn_loc: Node3D

func fire_bullet(dir: Vector3, speed: float = 10.0, lifetime: float = 5.0, damage: float = 0.0) -> void:
	if bullet_scene == null:
		push_error("Bullet scene missing!")
		return

	var b := bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)
	
	dir.y = 0
	
	b.global_position = spawn_loc.global_position if spawn_loc else global_position
	b.look_at(b.global_position + dir, Vector3.UP)
	b.direction = dir.normalized()

	b.speed = bullet_speed if speed < 0.0 else speed
	b.life_time = bullet_lifetime if lifetime < 0.0 else lifetime

	# Set bullet damage if the bullet has a property called "damage"
	if "damage" in b:
		b.damage = damage

func pattern_radial_ring(count: int = 24, speed: float = 10.0, lifetime: float = 5.0, damage: float = 0.0) -> void:
	for i in range(count):
		var angle := (TAU * float(i)) / float(count)
		var dir := Vector3(cos(angle), 0.0, sin(angle))
		fire_bullet(dir, speed, lifetime, damage)

func pattern_targeted_shot(target: Node3D, spread: float = 0.25, count: int = 5, speed: float = 10.0, lifetime: float = 5.0, damage: float = 0.0) -> void:
	if target == null:
		return

	var origin := spawn_loc.global_position if spawn_loc else global_position
	var base_dir := (target.global_position - origin).normalized()

	for i in range(count):
		var offset := (float(i) - float(count - 1) * 0.5) * spread
		var dir := base_dir.rotated(Vector3.UP, offset)
		fire_bullet(dir, speed, lifetime, damage)

func pattern_targeted_shot_position(target_position : Vector3, spread: float = 0.25, count: int = 5, speed: float = 10.0, lifetime: float = 5.0, damage: float = 0.0) -> void:
	var origin := spawn_loc.global_position if spawn_loc else global_position
	var base_dir := (target_position - origin).normalized()

	for i in range(count):
		var offset := (float(i) - float(count - 1) * 0.5) * spread
		var dir := base_dir.rotated(Vector3.UP, offset)
		fire_bullet(dir, speed, lifetime, damage)

func pattern_spiral(turns: int = 40, step: float = 0.25, speed: float = 10.0, lifetime: float = 5.0, damage: float = 0.0) -> void:
	await _spiral_coroutine(turns, step, speed, lifetime, damage)

func _spiral_coroutine(turns: int, step: float, speed: float, lifetime: float, damage: float) -> void:
	for i in range(turns):
		var angle := float(i) * 0.35
		var dir := Vector3(cos(angle), 0.0, sin(angle))
		fire_bullet(dir, speed, lifetime, damage)
		await get_tree().create_timer(step).timeout
