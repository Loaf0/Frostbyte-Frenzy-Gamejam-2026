class_name Projectile
extends Node3D

@export var speed: float = 20.0
@export var lifetime: float = 5.0
@export var impact_effect: PackedScene
@export var damage: float = 0.0

var direction: Vector3 = Vector3.ZERO
var shooter: Node3D = null
var is_spent := false
var impact_position: Vector3

@onready var area_3d: Area3D = $Area3D
@onready var visuals: Node3D = $Visuals

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	area_3d.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if is_spent:
		return

	direction.y = 0.0
	global_position += direction * speed * delta

	if direction != Vector3.ZERO:
		look_at(global_position + direction, Vector3.UP)

func _on_body_entered(body: Node) -> void:
	if is_spent or body == shooter:
		return

	impact_position = global_position
	_handle_impact(body)

func _handle_impact(body: Node) -> void:
	if is_spent:
		return

	is_spent = true

	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)

	if impact_effect:
		var effect := impact_effect.instantiate()
		add_sibling(effect)
		effect.global_position = global_position

	visuals.hide()
	area_3d.set_deferred("monitoring", false)
	area_3d.set_deferred("monitorable", false)

	for child in get_children():
		if child is GPUParticles3D or child is CPUParticles3D:
			child.emitting = false

	await get_tree().create_timer(2.0).timeout
	queue_free()
