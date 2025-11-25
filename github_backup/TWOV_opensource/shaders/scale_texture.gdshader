shader_type canvas_item;


uniform float texture_scale = 1.0;
uniform float brightness : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = UV * texture_scale;
	vec4 tex = texture(TEXTURE, fract(uv));
	COLOR = tex;
	COLOR.rgb *= brightness;
}
