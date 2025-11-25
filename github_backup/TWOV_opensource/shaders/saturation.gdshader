shader_type canvas_item;

uniform float saturation = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 saturated = mix(vec3(gray), color.rgb, saturation);
    COLOR = vec4(saturated, color.a);
}