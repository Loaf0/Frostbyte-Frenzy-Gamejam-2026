extends Interactable
class_name ItemPickup

@export var item : ItemResource

@onready var model_root : Node3D = $ModelRoot
@onready var cursed_particles : GPUParticles3D = $CursedParticles
@export var spin_speed := 90.0
var consumed := false

@export var item_name : String = "TEST"
@export var item_desc : String = "TEST"

const ITEM_RESOURCES := [
	"res://scenes/item/ItemResources/blue_bottle.tres",
	"res://scenes/item/ItemResources/burger.tres",
	"res://scenes/item/ItemResources/carrot_stew.tres",
	"res://scenes/item/ItemResources/closed_spellbook.tres",
	"res://scenes/item/ItemResources/cursed_shield.tres",
	"res://scenes/item/ItemResources/cursed_staff.tres",
	"res://scenes/item/ItemResources/dinner.tres",
	"res://scenes/item/ItemResources/green_bottle.tres",
	"res://scenes/item/ItemResources/quiver.tres",
	"res://scenes/item/ItemResources/shield.tres",
	"res://scenes/item/ItemResources/skeleton_quiver.tres",
	"res://scenes/item/ItemResources/smoke_bomb.tres",
	"res://scenes/item/ItemResources/spiked_shield.tres"
]

func _ready() -> void:
	add_to_group("item")

	if item == null:
		var path = ITEM_RESOURCES[randi() % ITEM_RESOURCES.size()]
		item = load(path)

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
	print("picked up item : " + item.item_name)
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
	for mod in item.stat_modifiers:
		var stat_name := str(mod.stat)
		var amount := mod.amount
		print("Applied " + stat_name + " : " + str(amount))
	# play pickup sound here
