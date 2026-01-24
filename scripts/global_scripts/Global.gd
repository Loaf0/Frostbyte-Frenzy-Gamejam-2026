extends Node

## This script acts as a global area to handle game state and settings
## across the project.

# Constants
var RARITY_COLORS := {Global.WeaponQuality.POOR:Color(0.6, 0.6, 0.6), Global.WeaponQuality.COMMON:Color(1.0, 1.0, 1.0), Global.WeaponQuality.UNCOMMON:Color(0.3, 1.0, 0.3), Global.WeaponQuality.RARE:Color(0.2, 0.4, 1.0), Global.WeaponQuality.EPIC:Color(0.7, 0.3, 1.0), Global.WeaponQuality.LEGENDARY:Color(1.0, 0.7, 0.2)}
enum WeaponType {BOW, CROSSBOW, SPELL_BOOK, STAFF, BATTLE_AXE, LONG_SWORD}
enum CharacterClass {RANGER, BARBARIAN, MAGE, KNIGHT, ROGUE, SKELETON}
enum Stat {VIGOR, AGILITY, DEXTERITY, STRENGTH, KNOWLEDGE, STAMINA_REGEN, MANA_REGEN, ATTACK_SIZE, FAITH, NONE}
enum WeaponQuality {POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const QUALITY_MULTIPLIERS := {WeaponQuality.POOR: 0.8, WeaponQuality.COMMON: 1.0, WeaponQuality.UNCOMMON: 1.1, WeaponQuality.RARE: 1.25, WeaponQuality.EPIC: 1.4, WeaponQuality.LEGENDARY: 1.6,}

@export var selected_character : CharacterClass = CharacterClass.MAGE

var unlocked_characters : Dictionary = {
	CharacterClass.RANGER : true,
	CharacterClass.MAGE : true,
	CharacterClass.KNIGHT : true,
	CharacterClass.BARBARIAN : true,
	CharacterClass.ROGUE : true,
	CharacterClass.SKELETON : true
}

var name_map : Dictionary = {
	Global.CharacterClass.RANGER: "RANGER",
	Global.CharacterClass.BARBARIAN: "BARBARIAN",
	Global.CharacterClass.KNIGHT: "KNIGHT",
	Global.CharacterClass.MAGE: "MAGE",
	Global.CharacterClass.ROGUE: "ROGUE",
	Global.CharacterClass.SKELETON: "SKELETON",
}

var sfx_volume : float = 1.0
var music_volume : float = 1.0

func _ready() -> void:
	Save.load_settings()

# Global Util Functions

func unlock_character(char_class: CharacterClass):
	if unlocked_characters.has(char_class):
		unlocked_characters[char_class] = true
		Save.save_player()
		print("Character Unlocked: ", CharacterClass.keys()[char_class])
