shader_type canvas_item;

uniform float wave_speed : hint_range(0.0, 10.0) = 3.0;
uniform float wave_frequency : hint_range(1.0, 50.0) = 15.0;
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.2;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_intensity : hint_range(0.0, 2.0) = 0.4;
uniform float brightness_boost : hint_range(0.0, 2.0) = 0.3;
uniform bool is_playing = false;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	if (is_playing) {
		// Centrar UV
		vec2 uv = UV - vec2(0.5);
		
		// Distancia radial desde el centro
		float dist = length(uv) * 2.0;
		
		// Ondas circulares expandiéndose
		float wave = sin(dist * wave_frequency - TIME * wave_speed) * wave_amplitude;
		wave += sin(dist * wave_frequency * 1.5 - TIME * wave_speed * 1.3) * wave_amplitude * 0.5;
		
		// Pulso desde el centro
		float pulse = sin(TIME * wave_speed * 0.5) * pulse_intensity;
		float center_glow = (1.0 - smoothstep(0.0, 0.5, dist)) * pulse;
		
		// Intensidad de las ondas
		float intensity = smoothstep(0.4, 0.0, abs(wave)) + center_glow;
		intensity = clamp(intensity, 0.0, 1.0);
		
		// Usar el color original de la textura y aumentar su brillo con las ondas
		vec3 original_color = tex.rgb;
		vec3 brightened_color = original_color * (1.0 + brightness_boost);
		
		// Mezclar entre color original y color iluminado según la intensidad de la onda
		vec3 final_color = mix(original_color, brightened_color, intensity * glow_intensity);
		
		COLOR = vec4(final_color, tex.a);
	} else {
		COLOR = tex;
	}
}