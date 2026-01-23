shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always, blend_add;

uniform vec3 rarity_color : source_color = vec3(1.0);
uniform float intensity : hint_range(0.0, 10.0) = 10.0;
uniform float pulse : hint_range(0.0, 1.0) = 0.0;
uniform float outline_width : hint_range(0.0, 0.05) = 0.01;

void vertex() {
	VERTEX += NORMAL * outline_width * 0.05;
}

void fragment() {
	float glow = intensity + pulse * 0.5;

	ALBEDO = rarity_color * glow;
	ALPHA = glow;
}
