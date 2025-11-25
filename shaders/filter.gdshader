shader_type canvas_item;

uniform sampler2D screen_texture;

void fragment() {
    vec4 color = texture(screen_texture, FRAGCOORD.xy / SCREEN_PIXEL_SIZE);
    float gray = (color.r + color.g + color.b) / 5.0;
    COLOR = vec4(vec3(gray), color.a);
}
