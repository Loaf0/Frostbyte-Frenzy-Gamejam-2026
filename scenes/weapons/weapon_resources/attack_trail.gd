extends MeshInstance3D

@export var max_points: int = 20
@export var trail_width: float = 0.8
@export var lifetime: float = 0.2

var points: Array = []
var msh: ImmediateMesh

func _ready():
	msh = ImmediateMesh.new()
	mesh = msh
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func add_point():
	var head_pos = global_position
	var tail_pos = global_position + (global_transform.basis.y * trail_width)
	
	if points.size() > 0:
		if points[0][0].distance_to(head_pos) < 0.01:
			return

	points.push_front([head_pos, tail_pos, lifetime])

func _process(delta):
	var i = points.size() - 1
	while i >= 0:
		points[i][2] -= delta
		if points[i][2] <= 0:
			points.remove_at(i)
		i -= 1
	
	_draw_trail()

func _draw_trail():
	msh.clear_surfaces()
	if points.size() < 2:
		return

	msh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for p in points:
		var u = p[2] / lifetime

		msh.surface_set_uv(Vector2(u, 0))
		msh.surface_add_vertex(to_local(p[0]))
		msh.surface_set_uv(Vector2(u, 1))
		msh.surface_add_vertex(to_local(p[1]))
	msh.surface_end()

func stop():
	points.clear()
