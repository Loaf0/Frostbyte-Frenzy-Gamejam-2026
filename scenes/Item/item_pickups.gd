extends Interactable

@export var item : ItemResource

func _ready() -> void:
	add_to_group("item")

func interact(_interactor : Node = null):
	if(_interactor.is_in_group("player") and _interactor.is_class("CharacterBody3D")):
		apply_stats(_interactor)

func apply_stats(target : CharacterBody3D):
	if not target.has_method("update_stats"):
		return
	
	for modifier in item.stat_modifiers:
		target.update_stats(modifier.stat, modifier.amount)
