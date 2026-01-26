extends Interactable
class_name Chest

var looted = false
var chest_close_sfx = preload("res://assets/audio/sfx/chest-slam-85122.mp3")
var chest_open_sfx = preload("res://assets/audio/sfx/coin-2-47744.mp3")

const CLASS_WEAPONS := {
	Global.CharacterClass.KNIGHT: [
		"res://scenes/weapons/weapon_resources/axe.tres",
		"res://scenes/weapons/weapon_resources/sword.tres",
		"res://scenes/weapons/weapon_resources/gold_sword.tres"
	],
	Global.CharacterClass.BARBARIAN: [
		"res://scenes/weapons/weapon_resources/axe.tres",
		"res://scenes/weapons/weapon_resources/sword.tres",
		"res://scenes/weapons/weapon_resources/gold_sword.tres"
	],
	Global.CharacterClass.RANGER: [
		"res://scenes/weapons/weapon_resources/bow.tres",
		"res://scenes/weapons/weapon_resources/crossbow.tres"
	],
	Global.CharacterClass.ROGUE: [
		"res://scenes/weapons/weapon_resources/bow.tres",
		"res://scenes/weapons/weapon_resources/crossbow.tres"
	],
	Global.CharacterClass.MAGE: [
		"res://scenes/weapons/weapon_resources/staff.tres",
		"res://scenes/weapons/weapon_resources/spellbook.tres"
	],
	Global.CharacterClass.SKELETON: [
		"res://scenes/weapons/weapon_resources/staff.tres",
		"res://scenes/weapons/weapon_resources/spellbook.tres"
	]
}

const ITEM_POOL := [
	"res://scenes/item/ItemResources/blue_bottle.tres",
	"res://scenes/item/ItemResources/burger.tres",
	"res://scenes/item/ItemResources/carrot_stew.tres",
	"res://scenes/item/ItemResources/closed_spellbook.tres",
	"res://scenes/item/ItemResources/cursed_shield.tres",
	"res://scenes/item/ItemResources/cursed_staff.tres",
	"res://scenes/item/ItemResources/dinner.tres",
	"res://scenes/item/ItemResources/green_bottle.tres",
	"res://scenes/item/ItemResources/quiver.tres",
	"res://scenes/item/ItemResources/shield.tres",
	"res://scenes/item/ItemResources/skeleton_quiver.tres",
	"res://scenes/item/ItemResources/smoke_bomb.tres",
	"res://scenes/item/ItemResources/spiked_shield.tres"
]

const WEAPON_QUALITIES := [
	Global.WeaponQuality.UNCOMMON,
	Global.WeaponQuality.RARE,
	Global.WeaponQuality.EPIC,
	Global.WeaponQuality.LEGENDARY
]

const ITEM_PICKUPS = preload("res://scenes/item/ItemPickups.tscn")
const WEAPON_PICKUPS = preload("res://scenes/weapons/WeaponPickups.tscn")

@onready var item_1: Node3D = $SpawnLocations/item1
@onready var item_2: Node3D = $SpawnLocations/item2
@onready var item_3: Node3D = $SpawnLocations/item3
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact(_interactor : Node = null):
	if looted:
		return
	spawn_loot()
	animation_player.play("open")
	Global.play_one_shot_sfx(chest_open_sfx, 0.05, 0.0, -15)
	await get_tree().create_timer(1.0).timeout
	Global.play_one_shot_sfx(chest_close_sfx, 0.05, 0.0, -25)
	
func spawn_loot() -> void:
	var char_class := Global.selected_character

	_spawn_weapon(char_class, item_1)
	_spawn_item(item_2)
	_spawn_item(item_3)
	looted = true

func _spawn_item(spawn_point: Node3D) -> void:
	var item_res := load(ITEM_POOL.pick_random())

	var pickup := ITEM_PICKUPS.instantiate()

	pickup.item = item_res
	spawn_point.add_child(pickup)

func _spawn_weapon(char_class: int, spawn_point: Node3D) -> void:
	var weapon_paths = CLASS_WEAPONS[char_class]
	var weapon_res: WeaponResource = load(weapon_paths.pick_random()).duplicate(true)
	
	weapon_res.pickup_quality = _roll_weapon_quality()

	var pickup := WEAPON_PICKUPS.instantiate()
	pickup.weapon_resource = weapon_res 
	
	spawn_point.add_child(pickup)
	
	await get_tree().process_frame 
	pickup.update_rarity_overlay()

func _roll_weapon_quality() -> Global.WeaponQuality:
	return [Global.WeaponQuality.UNCOMMON, Global.WeaponQuality.RARE, 
	Global.WeaponQuality.EPIC, Global.WeaponQuality.LEGENDARY].pick_random()
