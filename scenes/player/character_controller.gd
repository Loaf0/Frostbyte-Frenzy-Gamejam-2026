extends CharacterBody3D

const ANIM_PLAYER_SCRIPT := preload("res://scripts/fps_locked_animation.gd")
const DEFAULT_CHARACTER = "res://scenes/rigged_models/rogue.tscn"
const CHARACTER_SCENES : Dictionary[Global.CharacterClass, String] = {
	Global.CharacterClass.RANGER : "res://scenes/rigged_models/players/ranger.tscn",
	Global.CharacterClass.MAGE : "res://scenes/rigged_models/players/mage.tscn",
	Global.CharacterClass.KNIGHT : "res://scenes/rigged_models/players/knight.tscn",
	Global.CharacterClass.BARBARIAN : "res://scenes/rigged_models/players/barbarian.tscn",
	Global.CharacterClass.ROGUE : "res://scenes/rigged_models/players/rogue.tscn",
	Global.CharacterClass.SKELETON : "res://scenes/rigged_models/players/skeleton.tscn"
}

var character_type : Global.CharacterClass = Global.CharacterClass.RANGER

var _isMnK : bool

@export var move_speed := 6.0
@export var acceleration := 18.0
@export var friction := 48.0

@export var dodge_speed := 14.0
@export var dodge_duration := 0.25
@export var dodge_cooldown := 0.5

var move_input := Vector3.ZERO
var dodge_timer := 0.0
var dodge_cd_timer := 0.0
var is_dodging := false
var dodge_dir := Vector3.ZERO

@onready var mesh_animator: Node3D = $Mesh

var model_instance: Node3D
var anim_player: AnimationPlayer

func _ready() -> void:
	add_to_group("player")
	_spawn_character_model()

func _spawn_character_model():
	for child in mesh_animator.get_children():
		child.queue_free()

	var scene_path : String = CHARACTER_SCENES.get(character_type, DEFAULT_CHARACTER)
	if scene_path == null:
		push_error("Invalid character type: %s" % character_type)
		return

	var scene := load(scene_path)
	model_instance = scene.instantiate()
	mesh_animator.add_child(model_instance)

	anim_player = _find_animation_player(model_instance)
	if anim_player == null:
		push_error("Model has no AnimationPlayer: %s" % character_type)
		return
	
	anim_player.set_script(ANIM_PLAYER_SCRIPT)
	
	if mesh_animator.animation_tree:
		mesh_animator.animation_tree.anim_player = anim_player.get_path()
	else:
		push_error("Mesh has no AnimationTree")


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node

	for child in node.get_children():
		var result := _find_animation_player(child)
		if result:
			return result

	return null


func _physics_process(delta):
	_handle_timers(delta)
	_handle_input()
	_handle_movement(delta)
	move_and_slide()

func _handle_input():
	move_input = Vector3.ZERO

	if Input.is_action_pressed("move_up"):
		move_input.z += .5
		move_input.x += .5
	if Input.is_action_pressed("move_down"):
		move_input.z -= .5
		move_input.x -= .5
	if Input.is_action_pressed("move_left"):
		move_input.z -= .5
		move_input.x += .5
	if Input.is_action_pressed("move_right"):
		move_input.z += .5
		move_input.x -= .5

	move_input = move_input.normalized()

	if Input.is_action_just_pressed("dodge"):
		_try_dodge()

	if Input.is_action_just_pressed("attack"):
		_attack()

func _handle_movement(delta):
	if is_dodging:
		velocity = dodge_dir * dodge_speed
		return
	
	if _isMnK:
		_mouse_look()
	else:
		_controller_look()
	
	if move_input != Vector3.ZERO:
		velocity = velocity.move_toward(
			move_input * move_speed,
			acceleration * delta
		)
		_play_move_anim()
	else:
		velocity = velocity.move_toward(
			Vector3.ZERO,
			friction * delta
		)
		_play_idle_anim()

func _input(event: InputEvent):
	#this just checks to see if they are using mnk or controller
	if event is InputEventKey or event is InputEventMouse:
		_isMnK = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_isMnK = false

func _controller_look():
	var stick_rotation: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y), Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
	stick_rotation *= -1.0
	if stick_rotation.length() > 0.2:
		#idk why this needs - 2.4 on the y but it was improperly rotating so i brute force fixed it
		self.rotation = Basis(Vector3(0.0, 1.0, 0.0), stick_rotation.angle()).get_euler() - Vector3(0.0, 2.4, 0.0)
	else:
		look_at(global_position + move_input, Vector3.UP)
	return

func _mouse_look():
	var mouse_pos = get_viewport().get_mouse_position()
	var cam = get_node("../Camera3D")
	
	var plane : Plane = Plane(Vector3.UP, 1)
	var world_pos = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
	
	if world_pos != null:
		world_pos.y = global_position.y
		
		if world_pos == global_position:
			return
		look_at(world_pos, Vector3.UP)
	return

func _try_dodge():
	if is_dodging or dodge_cd_timer > 0.0:
		return

	is_dodging = true
	dodge_timer = dodge_duration
	dodge_cd_timer = dodge_cooldown

	dodge_dir = move_input if move_input != Vector3.ZERO else -transform.basis.z

	_play_dodge_anim()

func _handle_timers(delta):
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0.0:
			is_dodging = false
			velocity = velocity * 0.5

	if dodge_cd_timer > 0.0:
		dodge_cd_timer -= delta

func _attack():
	_play_attack_anim()

func _interact(hit_object):
	if hit_object is Interactable:
		hit_object.interact(self)


func _play_idle_anim():
	if anim_player:
		anim_player.play("actions/Idle_A")

func _play_move_anim():
	if anim_player:
		anim_player.play("movement/Running_A")

func _play_dodge_anim(): 
	return
	#if anim_player:
		#anim_player.play("Dodge")

func _play_attack_anim():
	if anim_player:
		return
		#anim_player.play("")

func _play_hit_anim():
	if anim_player:
		anim_player.play("Hit_A" if randi() % 2 == 0 else "Hit_b")
