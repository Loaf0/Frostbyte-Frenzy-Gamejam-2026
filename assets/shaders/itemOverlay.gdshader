shader_type spatial;
// cull_front is the secret to making it an outline rather than a solid blob
render_mode unshaded, cull_front, depth_draw_always; 

uniform vec3 rarity_color : source_color = vec3(1.0);
uniform float intensity : hint_range(0.0, 10.0) = 1.0; 
uniform float pulse : hint_range(0.0, 1.0) = 0.0;
uniform float outline_width : hint_range(0.0, 1.0) = 0.02; // Increased default

void vertex() {
    // We push the vertices out along their normals. 
    // If outline_width is 0, you won't see anything!
    float thickness = outline_width * 0.01 + (pulse * 0.01);
    VERTEX += NORMAL * thickness;
}

void fragment() {
    // Keep ALBEDO bright. If you want it to "glow" into the air, 
    // you can multiply rarity_color by intensity.
    ALBEDO = rarity_color * intensity;
}