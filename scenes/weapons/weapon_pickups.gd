extends Interactable

@export var weapon : WeaponResource
@export var quality : Global.WeaponQuality

func _ready() -> void:
	add_to_group("item")

func interact(_interactor : Node = null):
	if(_interactor.is_in_group("player") and _interactor.is_class("CharacterBody3D")):
		_interactor.weapon_manager.equip(weapon, quality)
