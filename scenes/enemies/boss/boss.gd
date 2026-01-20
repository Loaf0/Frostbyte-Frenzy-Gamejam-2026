extends CharacterBody3D

var max_health = 50
var current_health = max_health
@onready var anim = $Skeleton_Mage/Rig_Medium/AnimationPlayer
var started_death_sequence = false

var dissolve_materials: Array[ShaderMaterial] = []

func _ready() -> void:
	add_to_group("enemy")
	_setup_dissolve_materials()

func _setup_dissolve_materials():
	var meshes = _get_all_mesh_instances(self)
	var shader_res = load("res://assets/shaders/dissolve.gdshader")
	
	for m in meshes:
		if m.mesh: 
			for i in m.mesh.get_surface_count():
				var old_mat = m.get_active_material(i)
				var original_tex = null
				
				if old_mat is StandardMaterial3D:
					original_tex = old_mat.albedo_texture
				
				var new_mat = ShaderMaterial.new()
				new_mat.shader = shader_res
				
				if original_tex:
					new_mat.set_shader_parameter("albedo_texture", original_tex)
				
				new_mat.set_shader_parameter("dissolve_value", 0.0)
				
				m.set_surface_override_material(i, new_mat)
				dissolve_materials.append(new_mat)

func _on_death():
	$CollisionShape3D.disabled = true
	started_death_sequence = true
	anim.play("actions/Death_A")
	await anim.animation_finished
	
	var tween = create_tween()
	tween.tween_method(
		func(val: float): 
			for mat in dissolve_materials:
				mat.set_shader_parameter("dissolve_value", val),
		0.0, 1.0, 5.0
	)
	
	await tween.finished
	queue_free()

func take_damage(amount : float):
	current_health -= amount
	if current_health <= 0 and not started_death_sequence:
		_on_death()

func _process(_delta: float) -> void:
	$Label3D.text = "HEALTH: " + str(current_health) + "/" + str(max_health)

func _get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var found_meshes: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		found_meshes.append(node)
	for child in node.get_children():
		found_meshes.append_array(_get_all_mesh_instances(child))
	return found_meshes
