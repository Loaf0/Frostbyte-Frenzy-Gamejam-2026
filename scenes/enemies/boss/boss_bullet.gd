extends Node3D
class_name BossBullet

@onready var hitbox = $Area3D
@export var speed: float = 10.0
@export var life_time: float = 4.0
@export var damage: float = 5.0

var direction: Vector3 = Vector3.ZERO
var _time_alive := 0.0

func _ready() -> void:
	hitbox.monitoring = true

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	_time_alive += delta
	if _time_alive >= life_time:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		return
	
	if body.is_in_group("player"):
		if body.is_dodging:
			return
		elif body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
			return
	
	queue_free()
		
