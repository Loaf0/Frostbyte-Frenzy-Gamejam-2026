extends Interactable
class_name WeaponPickup

@export var weapon_resource : WeaponResource
@export var use_override_quality := false
@export var override_quality: Global.WeaponQuality = Global.WeaponQuality.COMMON
@onready var model_root: Node3D = $WeaponModelRoot
var shader := preload("res://assets/shaders/itemOverlay.gdshader")
var color
var overlay_materials: Array[ShaderMaterial] = []
var pulse_timer := 0.0
var base_y := 0.0
var resolved_quality: Global.WeaponQuality

func _ready() -> void:
	if not weapon_resource:
		return

	add_to_group("item")
	base_y = position.y
	_spawn_pickup_model()
	
	await get_tree().process_frame
	if overlay_materials.is_empty(): 
		_setup_overlay()

func _process(delta: float) -> void:
	#print("Quality:", resolved_quality, " color:", color)
	if not weapon_resource:
		return

	rotation.y += weapon_resource.rotate_speed * delta
	pulse_timer += delta * weapon_resource.pulse_speed
	var pulse := (sin(pulse_timer) * 0.5 + 0.5) * 0.4
	#position.y +=sin(pulse_timer) * weapon_resource.bob_height

	for mat in overlay_materials:
		mat.set_shader_parameter("pulse", pulse/5)

func interact(interactor: Node = null) -> void:
	if not weapon_resource or not interactor:
		return

	if interactor.is_in_group("player") and interactor.has_node("WeaponManager"):
		interactor.weapon_manager.equip(
			weapon_resource,
			resolved_quality
		)
		queue_free()

func _spawn_pickup_model() -> void:
	if not weapon_resource or not weapon_resource.pickup_model:
		return

	var model := weapon_resource.pickup_model.instantiate()
	model_root.add_child(model)

func _setup_overlay() -> void:
	overlay_materials.clear()
	color = Global.RARITY_COLORS.get(resolved_quality)
	for mesh in _get_all_mesh_instances(self):
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("rarity_color", color)
		mat.set_shader_parameter("intensity", 10.0)
		mat.set_shader_parameter("pulse", 0.0)
		mat.set_shader_parameter("outline_width", 0.015)
		mesh.material_overlay = mat
		mesh.material_overlay.render_priority = 10
		overlay_materials.append(mat)

func _get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []

	if node is MeshInstance3D:
		result.append(node)

	for child in node.get_children():
		result.append_array(_get_all_mesh_instances(child))

	return result

func update_rarity_overlay() -> void:
	resolved_quality = override_quality if use_override_quality else weapon_resource.pickup_quality
	var rarity_color = Global.RARITY_COLORS.get(resolved_quality, Color.WHITE)
	
	overlay_materials.clear()
	
	var meshes = _get_all_mesh_instances(model_root)
	
	for mesh in meshes:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		
		mat.set_shader_parameter("rarity_color", rarity_color)
		mat.set_shader_parameter("outline_width", 0.015)
		mesh.material_overlay = mat
		overlay_materials.append(mat)
