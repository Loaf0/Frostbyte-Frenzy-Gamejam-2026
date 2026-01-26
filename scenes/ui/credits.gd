extends Node3D

var credits_string = "Boss defeated whaterver \n you unlocked"
@onready var label = $SubViewportContainer/SubViewport/Options/Label

var character_name_map := {
	Global.CharacterClass.RANGER: "Theseus The Ranger",
	Global.CharacterClass.BARBARIAN: "Faldor The Barbarian",
	Global.CharacterClass.KNIGHT: "Leonidas The Knight",
	Global.CharacterClass.MAGE: "Phoebe The Mage",
	Global.CharacterClass.ROGUE: "Kaelen The Rogue",
	Global.CharacterClass.SKELETON: "FEMORE The Skeleton"
}

func _ready() -> void:
	var unlocked_class = Global.unlock_next_character_from_selected()
	label.text = _build_credits_text(unlocked_class)
	await get_tree().create_timer(7.0).timeout
	SceneChanger.change_to("res://scenes/Maps/MainMenuMap.tscn")

func _build_credits_text(unlocked_class: Global.CharacterClass) -> String:
	var lines: Array[String] = []

	lines.append("BOSS DEFEATED")
	lines.append("")

	if unlocked_class != Global.CharacterClass.RANGER:
		lines.append("UNLOCKED:")
		lines.append(character_name_map.get(unlocked_class, "Unknown"))
	else:
		lines.append("")

	lines.append("")
	lines.append("THANK YOU FOR PLAYING")

	return "\n".join(lines)
