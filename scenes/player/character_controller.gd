extends CharacterBody3D

const DEFAULT_CHARACTER : String = "res://scenes/rigged_models/players/ranger.tscn"
const CHARACTER_SCENES : Dictionary[Global.CharacterClass, String] = {
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

var character_type : Global.CharacterClass = Global.CharacterClass.RANGER

var _isMnK : bool
var last_mouse_world_pos : Vector3 = Vector3.ZERO

@export var selected_character : Global.CharacterClass = Global.CharacterClass.RANGER 
var model_skeleton : Skeleton3D
var weapon_mesh_container : BoneAttachment3D
var ability : Node3D
@onready var weapon_manager : WeaponManager = $WeaponManager
@onready var animator : Node3D = $Mesh

@export var rotation_fps: float = 12.0
var rotation_timer: float = 0.0
var visual_rotation_y: float = 0.0

@export var mouse_idle_threshold := 2.0
var mouse_idle_timer := 0.0
var last_mouse_pos := Vector2.ZERO

@export var move_speed := 6.0
@export var acceleration := 18.0
@export var friction := 48.0

@export var dodge_speed := 14.0
@export var dodge_duration := 0.25
@export var dodge_cooldown := 1.0

var stats: Dictionary = {}

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
	animator.weapon_manager = weapon_manager
	_apply_class()

func _spawn_character_model():
	for child in mesh_animator.get_children():
		if not child is AnimationTree:
			child.free()
	
	weapon_manager.weapon_mesh_container = null
	
	var scene_path : String = CHARACTER_SCENES.get(selected_character, DEFAULT_CHARACTER)
	if scene_path == null:
		push_error("Invalid character type: %s" % selected_character)
		return

	var scene := load(scene_path)
	model_instance = scene.instantiate()
	mesh_animator.add_child(model_instance)
	
	anim_player = _find_animation_player(model_instance)
	if mesh_animator.animation_tree:
		var tree = mesh_animator.animation_tree
		tree.active = false
		tree.anim_player = tree.get_path_to(anim_player) 
		animator.animation_player = anim_player 
		tree.active = true
	
	model_skeleton = find_skeleton_in_tree(self)
	
	if model_skeleton:
		weapon_mesh_container = create_weapon_attachment(model_skeleton)
		weapon_manager.weapon_mesh_container = weapon_mesh_container

func find_skeleton_in_tree(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node

	for child in node.get_children():
		var found := find_skeleton_in_tree(child)
		if found != null:
			return found

	return null

func _apply_class():
	#load model
	_spawn_character_model()
	await get_tree().process_frame

	# apply stat sheet
	var character_stats_path : String = CHARACTER_STATS.get(selected_character, DEFAULT_CHARACTER)
	var stat_sheet : ClassResource = load(character_stats_path)
	for stat in stat_sheet.stat_modifiers:
		stats[stat.stat] = stat.amount
	
	# instanciate ability
	ability = stat_sheet.special_ability.instantiate()
	add_child(ability)
	if ability:
		ability.player = self
	
	#load weapon
	weapon_manager.equip(stat_sheet.starting_weapon, Global.WeaponQuality.POOR)
	weapon_manager.animator = animator

func create_weapon_attachment(skeleton: Skeleton3D) -> BoneAttachment3D:
	var attachment := BoneAttachment3D.new()
	attachment.name = "WeaponAttachment"
	attachment.bone_name = "handslot.r"
	skeleton.add_child(attachment)
	attachment.owner = skeleton.owner
	return attachment

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result := _find_animation_player(child)
		if result:
			return result
	return null

func _physics_process(delta):
	_handle_animations(delta)
	_handle_timers(delta)
	_handle_input()
	_handle_movement(delta)
	_apply_stepped_rotation(delta)
	move_and_slide()

func _handle_animations(delta : float):
	var walk_vec = Vector3.ZERO
	if move_input != Vector3.ZERO:
		walk_vec = global_transform.basis.inverse() * move_input
	#print(walk_vec)
	animator.update_walk_vector(walk_vec, delta)

func _apply_stepped_rotation(delta: float):
	rotation_timer += delta
	var step_time = 1.0 / rotation_fps
	
	if rotation_timer >= step_time:
		visual_rotation_y = self.rotation.y
		rotation_timer -= step_time
	
	if animator:
		animator.global_rotation.y = visual_rotation_y + PI

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
	if Input.is_action_pressed("attack"):
		_try_attack()
	if Input.is_action_just_pressed("faith_power"):
		_try_faith_ability()

func _handle_movement(delta):
	if is_dodging:
		velocity = dodge_dir * dodge_speed
		return
	if mouse_idle_timer > 0.0:
		if _isMnK:
			_mouse_look()
		else:
			_controller_look()
	elif move_input.length() > 0.1:
		var target_angle = atan2(move_input.x, move_input.z)
		rotation.y = lerp_angle(rotation.y, target_angle + PI, 10.0 * delta)
	
	if move_input != Vector3.ZERO:
		velocity = velocity.move_toward(move_input * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	
	velocity.y = 0 if is_on_floor() else -4

func _input(event: InputEvent):
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
		if move_input.length() > 0.001:
			var look_target := global_position + move_input.normalized()
			last_mouse_world_pos = look_target
			look_at(look_target, Vector3.UP)

func _mouse_look():
	var cam = get_viewport().get_camera_3d()
	if not cam: 
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	var screen_center = screen_size / 2.0
	
	var dist_from_center = mouse_pos.distance_to(screen_center)
	var max_dist = (screen_size.y / 2.0) * 0.8 
	cam.look_distance = clamp(dist_from_center / max_dist, 0.0, 1.0)
	
	var plane := Plane(Vector3.UP, global_position.y)
	var world_pos = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
	
	if world_pos:
		world_pos.y = global_position.y
		last_mouse_world_pos = world_pos
		if world_pos.distance_to(global_position) > 0.1:
			look_at(world_pos, Vector3.UP)

func _try_attack():
	# compare stamina
	_mouse_look()
	weapon_manager.attack(last_mouse_world_pos)

func _try_faith_ability():
	#ability.faith_cost
	_mouse_look()
	ability.use_ability(last_mouse_world_pos)

func _try_dodge():
	if is_dodging or dodge_cd_timer > 0.0:
		return

	is_dodging = true
	dodge_timer = dodge_duration
	dodge_cd_timer = dodge_cooldown

	dodge_dir = move_input if move_input != Vector3.ZERO else -transform.basis.z
	
	if animator.has_method("start_roll"):
		animator.start_roll(dodge_dir)

func _handle_timers(delta):
	if Input.is_action_just_pressed("attack"):
		mouse_idle_timer = mouse_idle_threshold
	
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0.0:
			is_dodging = false
			velocity = velocity * 0.5
			if animator.has_method("stop_roll"):
				animator.stop_roll()

	if dodge_cd_timer > 0.0:
		dodge_cd_timer -= delta
	
	if velocity.length() > 0.1 and mouse_idle_timer > 0.0:
		mouse_idle_timer -= delta

func _interact(hit_object):
	if hit_object is Interactable:
		hit_object.interact(self)

func _stat(stat: int) -> float:
	return stats.get(stat, 0.0)

func get_dodge_cooldown() -> float:
	return max(0.35, 2.5 - (_stat(Global.Stat.AGILITY) * .5))

func get_super_cooldown() -> float:
	return max(1.0, 10.0 - (_stat(Global.Stat.FAITH) * 0.25))
