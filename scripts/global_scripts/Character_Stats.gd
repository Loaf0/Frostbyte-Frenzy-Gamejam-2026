extends Node

const DEFAULT_CHARACTER : String = "res://scenes/rigged_models/players/ranger.tscn"
var CHARACTER_SCENES : Dictionary = {
	Global.CharacterClass.RANGER : "res://scenes/rigged_models/players/ranger.tscn",
	Global.CharacterClass.MAGE : "res://scenes/rigged_models/players/mage.tscn",
	Global.CharacterClass.KNIGHT : "res://scenes/rigged_models/players/knight.tscn",
	Global.CharacterClass.BARBARIAN : "res://scenes/rigged_models/players/barbarian.tscn",
	Global.CharacterClass.ROGUE : "res://scenes/rigged_models/players/rogue.tscn",
	Global.CharacterClass.SKELETON : "res://scenes/rigged_models/players/skeleton.tscn"
}
const CHARACTER_STATS : Dictionary[Global.CharacterClass, String] = {
	Global.CharacterClass.RANGER : "res://scenes/player/class_stats/ranger_class.tres",
	Global.CharacterClass.MAGE : "res://scenes/player/class_stats/mage_class.tres",
	Global.CharacterClass.KNIGHT : "res://scenes/player/class_stats/knight_class.tres",
	Global.CharacterClass.BARBARIAN : "res://scenes/player/class_stats/barbarian_class.tres",
	Global.CharacterClass.ROGUE : "res://scenes/player/class_stats/rogue_class.tres",
	Global.CharacterClass.SKELETON : "res://scenes/player/class_stats/skeleton_class.tres"
}
enum WeaponType {BOW, CROSSBOW, SPELL_BOOK, STAFF, BATTLE_AXE, LONG_SWORD}
enum CharacterClass {RANGER, BARBARIAN, MAGE, KNIGHT, ROGUE, SKELETON}
enum Stat {VIGOR, AGILITY, DEXTERITY, STRENGTH, KNOWLEDGE, STAMINA_REGEN, MANA_REGEN, ATTACK_SIZE, FAITH, NONE}
enum WeaponQuality {POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

var stats: Dictionary = {}
var selected_character : Global.CharacterClass = Global.CharacterClass.RANGER
var char_name : String = ""
var god_name_text : String = ""

var max_health = 100
var current_health = 100
var max_stamina = 100
var current_stamina = 100
var max_mana = 100
var current_mana = 100
var max_faith = 100
var current_faith = 0

var move_speed := 6.0
var dodge_cooldown := 2.5
var base_move_speed := 6.0
var agility_move_speed_bonus := 0.4
var base_dodge_cooldown := 2.5
var agility_dodge_cooldown_reduction := 0.15
var min_dodge_cooldown := 0.35
var vigor_health_multiplier := 10.0

func _ready():
	for s in Global.Stat.values():
		stats[s] = 0.0

func _stat(stat_type: int) -> float:
	return stats.get(stat_type, 0.0)

func reset_resources():
	current_health = max_health
	current_stamina = max_stamina
	current_mana = max_mana
	current_faith = 0
