shader_type canvas_item;

uniform float speed = 0.5;
uniform float vertical_scroll_speed = 0.03;
uniform float horizontal_scroll_speed = 0.0;
uniform float random_direction_change = 0.0;
uniform float direction_change_cooldown = 5.0;
uniform float bulge_intensity = 0.0;
uniform float wave_distortion = 0.0;
uniform float glitch_duration = 0.0;
uniform float glitch_cooldown = 0.0;
uniform float glitch_power = 0.0;
uniform float hue_shift_speed = 0.0;
uniform float blood_intensity = 0.0;
uniform float texture_scale = 1.0;

// Новые параметры для контроля цвета
uniform vec3 color_tint = vec3(1.0); // Общий тон цвета (RGB)
uniform float color_saturation = 1.0; // Насыщенность цвета
uniform float color_brightness = 1.0; // Яркость

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453);
}

// Функция для корректировки насыщенности
vec3 applySaturation(vec3 color, float saturation) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, saturation);
}

void fragment() {
    vec2 uv = UV * texture_scale;
    float time = TIME * speed;

    // Логика изменения направления
    float current_horizontal_speed = horizontal_scroll_speed;
    float current_vertical_speed = vertical_scroll_speed;

    if (random_direction_change > 0.5) {
        float last_change_time = floor(time / direction_change_cooldown) * direction_change_cooldown;
        float random_dir_x = (rand(vec2(last_change_time, 0.123))) > 0.5 ? 1.0 : -1.0;
        float random_dir_y = (rand(vec2(last_change_time + 1.0, 0.456))) > 0.5 ? 1.0 : -1.0;
        current_horizontal_speed *= random_dir_x;
        current_vertical_speed *= random_dir_y;
    }

    // Движение фона
    uv.x -= time * current_horizontal_speed;
    uv.y -= time * current_vertical_speed;

    // Glitch effect
    float glitch_phase = mod(time, glitch_duration + glitch_cooldown);
    float glitch = smoothstep(0.0, 0.3, glitch_phase) * (1.0 - smoothstep(glitch_duration - 0.3, glitch_duration, glitch_phase));

    if (glitch > 0.0) {
        uv += vec2(
            rand(vec2(time, uv.y)) * glitch_power - glitch_power * 0.5,
            rand(vec2(time + 1.0, uv.x)) * glitch_power * 0.7
        ) * glitch;

        vec2 offset = vec2(glitch_power * 0.2 * glitch, 0.0);
        COLOR.rgb = vec3(
            texture(TEXTURE, fract(uv + offset)).r,
            texture(TEXTURE, fract(uv)).g,
            texture(TEXTURE, fract(uv - offset)).b
        );
        COLOR.a = 1.0;
    }

    // Bulge effect
    if (bulge_intensity > 0.0) {
        vec2 center = vec2(sin(time * 0.5) * 0.5 + 0.5, cos(time * 0.3) * 0.5 + 0.5);
        float d = length(uv - center);
        uv += normalize(uv - center) * ((1.0 - smoothstep(0.0, 0.4, d))) * sin(time * 2.0) * bulge_intensity;
    }

    // Wave distortion
    if (wave_distortion > 0.0) {
        uv += vec2(
            sin(uv.y * 8.0 + time * 2.0),
            cos(uv.x * 6.0 + time * 1.7)
        ) * wave_distortion * 0.1;
    }

    vec4 tex = texture(TEXTURE, fract(uv));

    // Color effects
    if (blood_intensity > 0.0) {
        tex.rgb = mix(tex.rgb, vec3(1.0, 0.1, 0.1), blood_intensity * (0.5 + 0.5 * sin(time * hue_shift_speed)));
    }

    // Применяем цветовые корректировки
    tex.rgb *= color_tint; // Применяем цветовой тон
    tex.rgb = applySaturation(tex.rgb, color_saturation); // Корректируем насыщенность
    tex.rgb *= color_brightness; // Корректируем яркость

    COLOR = tex;
}