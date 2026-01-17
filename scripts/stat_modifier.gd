extends Resource
class_name StatModifier

@export var stat : Global.Stat
@export var amount : float

func _init(new_stat : Global.Stat = Global.Stat.VIGOR, new_amount : float = 0.0) -> void:
	stat = new_stat
	amount = new_amount
