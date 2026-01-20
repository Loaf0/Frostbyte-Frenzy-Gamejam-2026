class_name Projectile
extends Node3D

@export var speed: float = 20.0
@export var lifetime: float = 5.0
@export var impact_effect: PackedScene

var damage: float = 0.0
var direction: Vector3 = Vector3.ZERO
var shooter: Node3D = null

@onready var area_3d: Area3D = $Area3D
@onready var ray_cast: RayCast3D = $RayCast3D

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	area_3d.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	direction.y = 0
	var velocity = direction * speed * delta
	global_position += velocity
	
	if direction != Vector3.ZERO:
		look_at(global_position + direction, Vector3.UP)
	
	if ray_cast.is_colliding():
		_handle_impact(ray_cast.get_collider())

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	_handle_impact(body)

func _handle_impact(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
	
	if impact_effect:
		var effect = impact_effect.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position
	
	queue_free()
