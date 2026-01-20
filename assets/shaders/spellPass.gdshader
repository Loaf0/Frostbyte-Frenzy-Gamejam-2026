shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_always;

void fragment() {
    ALPHA = 0.0;
    ROUGHNESS = 0.0;
}