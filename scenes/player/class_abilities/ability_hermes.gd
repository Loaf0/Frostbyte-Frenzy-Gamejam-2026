extends Ability

func _ready() -> void:
	faith_cost = 60
	if(get_parent().is_in_group("player")):
		player = get_parent()
	else:
		push_error("No player found")

func use_ability():
	return
