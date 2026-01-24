extends CharacterBody3D
class_name Enemy

var player : CharacterBody3D = null
@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

func _ready():
	player = get_node(player_path)

func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity = Vector3.ZERO
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		move_and_slide()
