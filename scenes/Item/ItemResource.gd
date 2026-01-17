class_name ItemResource
extends Resource

@export_category("Item Quality")
@export var item_name : String = ""
@export var item_desc : String = ""

@export var item_model : PackedScene
@export var cursed : bool = false

@export_category("Stat Modifiers")
@export var stat_modifiers: Array[StatModifier] = []
