shader_type canvas_item;

uniform vec4 neon_color : source_color = vec4(0.0, 0.8, 1.0, 1.0); 
uniform float pulse_intensity = 1.0; 
uniform float glow_radius = 0.5;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    vec4 final_color = texture_color * neon_color;
    final_color.rgb += neon_color.rgb * pulse_intensity * glow_radius;
    COLOR = final_color;
}