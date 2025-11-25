shader_type canvas_item;

// Параметры анимации
uniform float amplitude = 0.1;        // Амплитуда шатания
uniform float frequency = 1.0;        // Частота анимации
uniform float wave_speed = 2.0;       // Скорость волны
uniform float distortion = 0.02;      // Искажение формы

// Цветовые эффекты (опционально)
uniform vec4 tint_color : source_color = vec4(1.0);
uniform float color_variation = 0.1;

void fragment() {
    // Базовые UV координаты
    vec2 uv = UV;

    // Время для анимации
    float time = TIME * frequency;

    // Волнообразное искажение
    float wave = sin(uv.y * 10.0 + time * wave_speed) * amplitude;
    float wave2 = cos(uv.x * 8.0 + time * wave_speed * 0.7) * amplitude * 0.5;

    // Применяем искажение к UV
    uv.x += wave * distortion;
    uv.y += wave2 * distortion;

    // Получаем цвет текстуры с искаженными UV
    vec4 color = texture(TEXTURE, uv);

    // Сохраняем исходную альфу
    float original_alpha = color.a;

    // Легкое изменение цвета для эффекта "живости"
    float color_shift = sin(time * 2.0) * color_variation;
    color.rgb += color_shift * 0.1;

    // Применяем tint (если нужен)
    color *= tint_color;

    // Восстанавливаем исходную альфу
    color.a = original_alpha;

    COLOR = color;
}

void vertex() {
    // Анимация вершин для эффекта шатания
    float time = TIME * frequency;

    // Волнообразное движение
    float wave = sin(VERTEX.y * 0.01 + time * wave_speed) * amplitude;
    float wave2 = cos(VERTEX.x * 0.008 + time * wave_speed * 0.8) * amplitude * 0.7;

    // Применяем движение к вершинам
    VERTEX.x += wave * 10.0;
    VERTEX.y += wave2 * 8.0;
}