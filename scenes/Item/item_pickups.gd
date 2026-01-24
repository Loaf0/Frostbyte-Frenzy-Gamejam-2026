extends Interactable
class_name ItemPickup

@export var item : ItemResource

@onready var model_root : Node3D = $ModelRoot
@onready var cursed_particles : GPUParticles3D = $CursedParticles
@export var spin_speed := 90.0
var consumed := false

func _ready() -> void:
	add_to_group("item")
	_spawn_item_model()
	_apply_curse_visuals()

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(spin_speed * delta))

func _spawn_item_model() -> void:
	if item == null:
		return
	if item.item_model == null:
		return

	var model := item.item_model.instantiate()
	model_root.add_child(model)

func _apply_curse_visuals() -> void:
	if cursed_particles:
		cursed_particles.emitting = item != null and item.cursed

func interact(_interactor : Node = null):
	if consumed:
		return
	consumed = true
	_apply_item(_interactor)
	queue_free() 

func _apply_item(target: Node) -> void:
	if not target.has_method("add_item_stats"):
		push_warning("Target cannot receive item stats")
		return

	target.add_item_stats(item.stat_modifiers)
	# play pickup sound here
