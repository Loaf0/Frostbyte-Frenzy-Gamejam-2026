extends Node3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation : AnimationNodeAnimation
@onready var weapon_manager : Node3D

var current_weapon : Global.WeaponType
var walk_vector := Vector2.ZERO
var sub_path : String = ""

func _ready() -> void:
	pass
	#walk_blend_tree = 
	#animation = 

#While roling set rollblend to 1 else zero and on roll set roll blendspace2d
# Mesh script (the one provided in the prompt)

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
		animation_tree.set("parameters/Blend2/blend_amount", 1.0)
	else:
		animation_tree.set("parameters/Blend2/blend_amount", 0.0)
		return
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
	
func attack_animation(attack_name : String):
	if not animation_tree: 
		return
	var cur_playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/" + sub_path + "/playback")
	if cur_playback:
		cur_playback.start(attack_name)
