extends Node3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var animation : AnimationNodeAnimation
@onready var weapon_manager : Node3D

var current_weapon : Global.WeaponType
var walk_vector := Vector2.ZERO

func _ready() -> void:
	pass
	#walk_blend_tree = 
	#animation = 

func update_walk_vector(move_input: Vector3) -> void:
	if animation_tree == null:
		return
	
	var walk_dir = Vector2(move_input.x, move_input.z)
	if walk_dir.length() > 0.01:
		var local_dir = (global_transform.basis.inverse() * walk_dir).normalized()
		walk_vector = Vector2(local_dir.x, local_dir.z)
	else:
		walk_vector = Vector2.ZERO
	
	if animation_tree.get("parameters/RunningBlendSpace2D/blend_position") != null:
		animation_tree.set("parameters/RunningBlendSpace2D/blend_position", walk_vector)


func update_weapon_hold_animations():
	if current_weapon:
		animation_tree.set("parameters/Blend2/blend_amount", 1.0)
	else:
		animation_tree.set("parameters/Blend2/blend_amount", 0.0)
		return
	var state_machine_playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
	if [Global.WeaponType.LONG_SWORD, Global.WeaponType.BATTLE_AXE].has(current_weapon):
		state_machine_playback.travel("2HandedMelee")
	elif [Global.WeaponType.BOW].has(current_weapon):
		state_machine_playback.travel("Bow")
	elif [Global.WeaponType.CROSSBOW].has(current_weapon):
		state_machine_playback.travel("Crossbow")
	elif [Global.WeaponType.SPELL_BOOK, Global.WeaponType.STAFF].has(current_weapon):
		state_machine_playback.travel("Spellbook")

func attack_animation(attack_name : String):
	if not animation_tree: 
		return
	var cur_playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/2HandedMelee/playback")
	if cur_playback:
		cur_playback.start(attack_name)
