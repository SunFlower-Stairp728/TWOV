shader_type canvas_item;

// Настройки ветра
uniform float wind_strength = 0.03; // Сила ветра
uniform float wind_speed = 2.0;     // Скорость ветра
uniform float wind_frequency = 10.0; // Частота (сколько "волн")

void fragment() {
    // Нормализованные координаты текстуры (0-1)
    vec2 uv = UV;

    // Вычисляем смещение только для верхней части спрайта
    float wind_effect = smoothstep(0.5, -0.2, uv.y); // Применяем только к верхней половине

    // Создаем волнообразное смещение по X
    float wave = sin(TIME * wind_speed + uv.y * wind_frequency) * wind_strength * wind_effect;

    // Смещаем текстуру
    COLOR = texture(TEXTURE, vec2(uv.x + wave, uv.y));
}