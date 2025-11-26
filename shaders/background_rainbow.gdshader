shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float frequency : hint_range(0.1, 10.0) = 3.0;

void fragment() {
    // Базовые координаты
    vec2 uv = UV;
    
    // Добавляем движение с течением времени
    float time = TIME * speed;
    
    // Создаем несколько волновых паттернов
    float wave1 = sin(uv.x * frequency * 3.0 + time) * cos(uv.y * frequency * 2.0 + time * 0.7);
    float wave2 = cos(uv.x * frequency * 2.5 + time * 1.3) * sin(uv.y * frequency * 3.5 + time * 0.9);
    float wave3 = sin(uv.x * frequency * 4.0 + time * 1.7) * cos(uv.y * frequency * 1.5 + time * 1.1);
    
    // Комбинируем волны
    float combined = (wave1 + wave2 + wave3) * 0.33 * intensity;
    
    // Создаем RGB цвета на основе волн и времени
    float r = sin(combined * 6.28318 + time * 2.0) * 0.4 + 0.4;
    float g = sin(combined * 6.28318 + time * 2.0 + 2.094) * 0.4 + 0.4; // + 120°
    float b = sin(combined * 6.28318 + time * 2.0 + 4.188) * 0.4 + 0.4; // + 240°
    
    // Устанавливаем цвет пикселя
    COLOR = vec4(r, g, b, 1.0);
}