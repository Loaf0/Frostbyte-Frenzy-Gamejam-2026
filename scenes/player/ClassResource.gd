class_name ClassResource
extends Resource

@export_category("Class")
@export var name : String = ""
@export var god_subtitle : String = ""
@export var model_path : PackedScene
@export var special_ability : PackedScene
@export var starting_weapon : WeaponResource

@export_category("Class Stats")
@export var stat_modifiers: Array[StatModifier]
