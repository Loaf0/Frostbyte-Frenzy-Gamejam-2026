extends Node

## This script acts as a global area to handle game state and settings
## across the project.

# Constants
enum WeaponType {BOW, CROSSBOW, SPELL_BOOK, STAFF, BATTLE_AXE, LONG_SWORD}
enum CharacterClass {RANGER, MAGE, KNIGHT, BARBARIAN, ROGUE, SKELETON}
enum Stat {VIGOR, AGILITY, DEXTERITY, STRENGTH, KNOWLEDGE, STAMINA_REGEN, MANA_REGEN, ATTACK_SIZE, FAITH, NONE}
enum WeaponQuality {POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const QUALITY_MULTIPLIERS := {WeaponQuality.POOR: 0.8, WeaponQuality.COMMON: 1.0, WeaponQuality.UNCOMMON: 1.1, WeaponQuality.RARE: 1.25, WeaponQuality.EPIC: 1.4, WeaponQuality.LEGENDARY: 1.6,}

# Global Settings
var default_mouse_sensitivity : float = 0.003
var mouse_sensitivity : float = 0.003

var sfx_volume : float = 0.75
var music_volume : float = 0.75
var ufx_volume : float = 0.75

func _ready() -> void:
	Save.load_settings()

# Global Util Functions

func update_volumes(new_sfx_volume : float = sfx_volume, new_ufx_volume : float = ufx_volume, new_mfx_volume : float = music_volume):
	sfx_volume = new_sfx_volume
	ufx_volume = new_ufx_volume
	music_volume = new_mfx_volume

	#AudioManager.set_sfx_volume(sfx_volume)
	#AudioManager.set_ufx_volume(ufx_volume)
	#AudioManager.set_music_volume(music_volume)
	Save.save_settings()

func update_mouse_sens(value : float = 1):
	mouse_sensitivity = default_mouse_sensitivity * value
	Save.save_settings()
