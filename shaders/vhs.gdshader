shader_type canvas_item;
render_mode blend_premul_alpha;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float scanline_speed = 1.0;
uniform float scanline_intensity = 0.1;

uniform float color_bleed_intensity = 0.3;
uniform vec2 red_offset = vec2(0.008, 0.90);
uniform vec2 green_offset = vec2(-0.006, 0.003);
uniform vec2 blue_offset = vec2(-0.006, 0.003);


void fragment() {
    vec2 centered_uv = SCREEN_UV - 0.5;
    vec2 uv = centered_uv + 0.5;


    uv = clamp(uv, 0.0, 1.0);


    vec2 uv_r = uv + red_offset * color_bleed_intensity;
	vec2 uv_g = uv + green_offset * color_bleed_intensity;
    vec2 uv_b = uv + blue_offset * color_bleed_intensity;

    vec3 color = vec3(
        texture(screen_texture, uv_r).r,
        texture(screen_texture, uv_g).g,
        texture(screen_texture, uv_b).b
    );

    color *= 1.05 + 0.05 * sin(TIME * 0.5);
    color -= (sin(uv.y * 1000.0 + TIME * scanline_speed * 2.0) * 0.5 + 0.5) * scanline_intensity;

    COLOR = vec4(color, 1.0);
}