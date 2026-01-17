class_name ItemResource
extends Resource

@export_category("Item")
@export var item_name : String = ""
@export var item_desc : String = ""

@export var item_model : PackedScene
@export var cursed : bool = false

@export_category("Stats")
@export var stat_mod1 : String = ""
@export var stat_mod2 : String = ""
@export var stat_mod3 : String = ""

@export var stat_amt1 : float = 0.0
@export var stat_amt2 : float = 0.0
@export var stat_amt3 : float = 0.0
