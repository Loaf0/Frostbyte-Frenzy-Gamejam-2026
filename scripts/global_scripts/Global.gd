extends Node

## This script acts as a global area to handle game state and settings
## across the project.

# Constants
const QUALITY_NAMES := {WeaponQuality.POOR: "Poor", WeaponQuality.COMMON: "Common", WeaponQuality.UNCOMMON: "Uncommon", WeaponQuality.RARE: "Rare", WeaponQuality.EPIC: "Epic", WeaponQuality.LEGENDARY: "Legendary"}
var RARITY_COLORS := {Global.WeaponQuality.POOR:Color(0.6, 0.6, 0.6), Global.WeaponQuality.COMMON:Color(1.0, 1.0, 1.0), Global.WeaponQuality.UNCOMMON:Color(0.3, 1.0, 0.3), Global.WeaponQuality.RARE:Color(0.2, 0.4, 1.0), Global.WeaponQuality.EPIC:Color(0.7, 0.3, 1.0), Global.WeaponQuality.LEGENDARY:Color(1.0, 0.7, 0.2)}
enum WeaponType {BOW, CROSSBOW, SPELL_BOOK, STAFF, BATTLE_AXE, LONG_SWORD}
enum CharacterClass {RANGER, BARBARIAN, MAGE, KNIGHT, ROGUE, SKELETON}
enum Stat {VIGOR, AGILITY, DEXTERITY, STRENGTH, KNOWLEDGE, STAMINA_REGEN, MANA_REGEN, ATTACK_SIZE, FAITH, NONE}
enum WeaponQuality {POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const QUALITY_MULTIPLIERS := {WeaponQuality.POOR: 0.8, WeaponQuality.COMMON: 1.0, WeaponQuality.UNCOMMON: 1.1, WeaponQuality.RARE: 1.2, WeaponQuality.EPIC: 1.3, WeaponQuality.LEGENDARY: 1.4,}

#character cont
var stats: Dictionary = {}
var current_faith : float = 0.0
#weapon manager
@export var weapon_pickup_scene: PackedScene
@export var equipped_weapon : WeaponResource
@export var pickup_location : Vector3

var weapon_quality : Global.WeaponQuality
@export var selected_character : CharacterClass = CharacterClass.KNIGHT
@onready var player : CharacterBody3D
@onready var aggro : Array[CharacterBody3D] = []

const dungeon_floors = [
	"res://scenes/Maps/polished_dungeons/d1f1.tscn",
	"res://scenes/Maps/polished_dungeons/d1f2.tscn",
	"res://scenes/Maps/polished_dungeons/d2f1.tscn",
]
const boss_floor = "res://scenes/Maps/polished_dungeons/boss_stage.tscn"
var generated_dungeon: Array[String] = []

var unlocked_characters : Dictionary = {
	CharacterClass.RANGER : true,
	CharacterClass.MAGE : false,
	CharacterClass.KNIGHT : false,
	CharacterClass.BARBARIAN : false,
	CharacterClass.ROGUE : false,
	CharacterClass.SKELETON : false
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

func unlock_next_character_from_selected() -> CharacterClass:
	var current_index := int(selected_character)
	var values := CharacterClass.values()
	
	if current_index + 1 < values.size():
		var next_class = values[current_index + 1]
		if not unlocked_characters[next_class]:
			unlocked_characters[next_class] = true
			Save.save_player()
			print(next_class)
			return next_class

	return Global.CharacterClass.RANGER

func generate_dungeon(floors: int) -> void:
	generated_dungeon.clear()
	
	var available_floors := dungeon_floors.duplicate()
	
	if floors > available_floors.size():
		floors = available_floors.size()
	
	available_floors.shuffle()
	
	for i in range(floors):
		generated_dungeon.append(available_floors[i])
	
	generated_dungeon.append(boss_floor)
	print("Generated dungeon : ", generated_dungeon)


func go_to_next_floor():
	if generated_dungeon.is_empty():
		print("No more floors left!")
		return
	
	var next_floor : String = generated_dungeon.pop_front()
	print("Going to next floor: ", next_floor)
	SceneChanger.change_to(next_floor)

func play_one_shot_sfx(
	sfx: AudioStream,
	pitch_range: float = 0.05,
	start_time: float = 0.0,
	volume_db: float = 0.0,
	bus_name: String = "SFX"
) -> void:
	var music_player := AudioStreamPlayer.new()
	add_child(music_player)
	music_player.stream = sfx
	music_player.bus = bus_name

	pitch_range = clamp(pitch_range, 0.0, 0.08)
	music_player.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)

	music_player.volume_db = volume_db

	music_player.finished.connect(music_player.queue_free)

	music_player.play(start_time)

func reset_run_state() -> void:
	# stats
	stats.clear()

	# weapon
	equipped_weapon = null
	weapon_quality = WeaponQuality.COMMON
	current_faith = 0.0
