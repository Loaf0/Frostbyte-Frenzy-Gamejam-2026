shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always, blend_add;

uniform float white_amount : hint_range(0.0, 1.0) = 0.0;
uniform float red_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec3 overlay = vec3(0.0);
	overlay += vec3(1.0) * white_amount * 0.1;
	overlay += vec3(1.0, 0.0, 0.0) * red_flash * 0.5;

	ALBEDO = overlay;
	ALPHA = max(white_amount, red_flash);
}
