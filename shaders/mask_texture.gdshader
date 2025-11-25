shader_type canvas_item;

uniform sampler2D mask_texture;
uniform float speed = 1.0;
uniform float intensity = 0.1;
uniform float amplitude_x = 0.3;
uniform float amplitude_y = 0.3;


void fragment() {
    float noise_x = fract(sin(UV.y * 78.233 + TIME * 0.3) * 43758.5453) * intensity;
    float noise_y = fract(sin(UV.x * 78.233 + TIME * 0.3) * 43758.5453) * intensity;

    // Движение туда-сюда
    float time_offset_x = sin(TIME * speed) * amplitude_x;
    float time_offset_y = sin(TIME * speed + 1.57) * amplitude_y;

    // Комбинируем смещения
    vec2 mask_uv = fract(UV + vec2(time_offset_x + noise_x, time_offset_y + noise_y));

    // Используем texelFetch для точного чтения пикселей без фильтрации
    ivec2 tex_size = textureSize(mask_texture, 0);
    ivec2 tex_coord = ivec2(mask_uv * vec2(tex_size));
    vec4 mask_color = texelFetch(mask_texture, tex_coord, 0);

    vec4 sprite_color = texture(TEXTURE, UV);
	
    COLOR = sprite_color * COLOR * mask_color;
}