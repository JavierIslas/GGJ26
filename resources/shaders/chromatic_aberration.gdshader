shader_type canvas_item;

// Chromatic Aberration Shader
// Separa los canales RGB para crear un efecto de distorsión/glitch

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	// Calcular offset basado en la distancia del centro
	vec2 direction = UV - center;
	float dist = length(direction);
	vec2 offset_dir = normalize(direction);

	// Offsets para cada canal RGB
	float offset = intensity * 0.01;

	vec2 uv_r = UV + offset_dir * offset * dist;
	vec2 uv_g = UV;
	vec2 uv_b = UV - offset_dir * offset * dist;

	// Samplear cada canal separado
	float r = texture(TEXTURE, uv_r).r;
	float g = texture(TEXTURE, uv_g).g;
	float b = texture(TEXTURE, uv_b).b;
	float a = texture(TEXTURE, UV).a;

	COLOR = vec4(r, g, b, a);
}
