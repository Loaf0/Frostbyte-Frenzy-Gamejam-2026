class_name ClassResource
extends Resource

@export_category("Class")
@export var name: String = ""
@export var selected_class: Global.CharacterClass

@export_category("Class Stats")
@export var stat_modifiers: Array[StatModifier] = [
	StatModifier.new(Global.Stat.VIGOR, 0.0),
	StatModifier.new(Global.Stat.AGILITY, 0.0),
	StatModifier.new(Global.Stat.DEXTERITY, 0.0),
	StatModifier.new(Global.Stat.STRENGTH, 0.0),
	StatModifier.new(Global.Stat.KNOWLEDGE, 0.0),
	StatModifier.new(Global.Stat.STAMINA_REGEN, 0.0),
	StatModifier.new(Global.Stat.MANA_REGEN, 0.0),
	StatModifier.new(Global.Stat.ATTACK_SIZE, 0.0),
	StatModifier.new(Global.Stat.FAITH, 0.0)
	]

var model_path: String:
	get:
		match selected_class:
			Global.CharacterClass.RANGER:
				return "res://scenes/rigged_models/players/ranger.tscn"
			Global.CharacterClass.MAGE:
				return "res://scenes/rigged_models/players/mage.tscn"
			Global.CharacterClass.KNIGHT:
				return "res://scenes/rigged_models/players/knight.tscn"
			Global.CharacterClass.BARBARIAN:
				return "res://scenes/rigged_models/players/barbarian.tscn"
			Global.CharacterClass.ROGUE:
				return "res://scenes/rigged_models/players/rogue.tscn"
			Global.CharacterClass.SKELETON:
				return "res://scenes/rigged_models/players/skeleton.tscn"
			_:
				return "res://scenes/rigged_models/players/ranger.tscn"
