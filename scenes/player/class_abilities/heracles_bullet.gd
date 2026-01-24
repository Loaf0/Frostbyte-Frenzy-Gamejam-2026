extends Node3D

@onready var hitbox = $Area3D
@export var speed: float = 10.0
@export var life_time: float = 4.0
@export var damage: float = 5.0
@onready var mesh: Node3D = $axe_1handed

var direction: Vector3 = Vector3.ZERO
var _time_alive := 0.0

func _ready() -> void:
	add_to_group("player_bullet")
	hitbox.monitoring = true
	
	mesh.rotation.y = randf_range(0, TAU)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	mesh.rotate_y(10.0 * delta)
	_time_alive += delta
	if _time_alive >= life_time:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	if body.is_in_group("player") or body.is_in_group("player_bullet"):
		return
	
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()
		return
	
	queue_free()
