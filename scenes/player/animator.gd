extends Node3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation : AnimationNodeAnimation
@onready var weapon_manager : Node3D

var weapon_blend_target : float = 0.0
@export var blend_speed : float = 5.0

var current_weapon : Global.WeaponType
var walk_vector := Vector2.ZERO
var sub_path : String = ""

func _ready() -> void:
	pass
	#walk_blend_tree = 
	#animation = 

func _process(delta: float) -> void:
	var current_blend = animation_tree.get("parameters/Blend2/blend_amount")
	var new_blend = move_toward(current_blend, weapon_blend_target, blend_speed * delta)
	animation_tree.set("parameters/Blend2/blend_amount", new_blend)

func start_roll(direction: Vector3):
	if not animation_tree:
		return

	var local_dir = global_transform.basis.inverse() * direction
	var roll_blend = Vector2(local_dir.x, local_dir.z).normalized()
	var state_machine_playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/RollMachine/playback")
	animation_tree.set("parameters/RollBlend/blend_amount", 0.8)

	if roll_blend.y > 0.7:
		state_machine_playback.travel("movement_advanced_Dodge_Forward")
	elif roll_blend.x > 0.5:
		state_machine_playback.travel("movement_advanced_Dodge_Left")
	elif roll_blend.x < -0.5:
		state_machine_playback.travel("movement_advanced_Dodge_Right")
	else:
		state_machine_playback.travel("movement_advanced_Dodge_Backward")

func stop_roll():
	if not animation_tree:
		return
	animation_tree.set("parameters/RollBlend/blend_amount", 0.0)

func update_walk_vector(target_move_vec: Vector3, delta: float) -> void:
	if not animation_tree: 
		return
		
	var target_blend = Vector2(target_move_vec.x, target_move_vec.z)
	walk_vector = walk_vector.lerp(target_blend, 10.0 * delta)
	var path = "parameters/RunningBlendSpace2D/blend_position"
	animation_tree.set(path, walk_vector)

func update_weapon_hold_animations():
	if current_weapon:
		weapon_blend_target = 0.85
		_update_state_machine_path()
	else:
		weapon_blend_target = 0.5

func _update_state_machine_path():
	var state_machine_playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
	if [Global.WeaponType.LONG_SWORD, Global.WeaponType.BATTLE_AXE].has(current_weapon):
		state_machine_playback.travel("2HandedMelee")
		sub_path = "2HandedMelee"
	elif [Global.WeaponType.BOW].has(current_weapon):
		state_machine_playback.travel("Bow")
		sub_path = "Bow"
	elif [Global.WeaponType.CROSSBOW].has(current_weapon):
		state_machine_playback.travel("Crossbow")
		sub_path = "Crossbow"
	elif [Global.WeaponType.SPELL_BOOK, Global.WeaponType.STAFF].has(current_weapon):
		state_machine_playback.travel("Spellbook")
		sub_path = "Spellbook"

func attack_animation(attack_name: String, speed: float = 1.0):
	if not animation_tree: 
		return
	
	update_weapon_hold_animations()

	var speed_path = "parameters/StateMachine/" + sub_path + "/TimeScale/scale"
	animation_tree.set(speed_path, speed)

	var playback_path = "parameters/StateMachine/" + sub_path + "/playback"
	var cur_playback: AnimationNodeStateMachinePlayback = animation_tree.get(playback_path)
	#animation_tree.get("parameters/StateMachine/2HandedMelee/playback")
	if cur_playback:
		cur_playback.start(attack_name)
