shader_type canvas_item;

uniform float wind_speed : hint_range(0.0, 2.0) = 0.5;
uniform float wind_strength : hint_range(0.0, 0.1) = 0.03;
uniform float time_scale : hint_range(0.0, 2.0) = 1.0;
uniform float height_scale : hint_range(16.0, 128.0) = 64.0;
uniform float wave_frequency : hint_range(0.1, 2.0) = 0.5;
uniform float secondary_wave : hint_range(0.0, 1.0) = 0.2;
uniform bool enable_vertical_movement = false;
uniform vec2 wind_direction = vec2(1.0, 0.0);

// Função de ruído simples
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
    // Posição original do vértice
    vec2 vertex = VERTEX;

    // Fator de altura normalizado com limite mais suave
    float height_factor = smoothstep(0.0, 1.0, vertex.y / height_scale);
    height_factor = pow(height_factor, 1.5); // Suaviza a transição

    // Tempo ajustado com suavização
    float adjusted_time = TIME * time_scale;

    // Movimento principal com amplitude reduzida nas bordas
    float primary_wave = sin(adjusted_time * wind_speed + vertex.y * wave_frequency);

    // Movimento secundário suavizado
    float secondary_movement = sin(adjusted_time * wind_speed * 1.5 + vertex.x * 0.05) * secondary_wave;

    // Combina os movimentos com mais controle
    float total_movement = (primary_wave + secondary_movement) * wind_strength;
    total_movement *= height_factor;

    // Limita o movimento máximo
    total_movement = clamp(total_movement, -wind_strength, wind_strength);

    // Aplica a direção do vento normalizada com mais controle
    vec2 normalized_direction = normalize(wind_direction);
    vertex += normalized_direction * total_movement * 20.0;

    // Movimento vertical opcional com mais suavização
    if (enable_vertical_movement) {
        float vertical_movement = cos(adjusted_time * wind_speed + vertex.x * 0.1) * wind_strength * 5.0;
        vertical_movement *= smoothstep(0.0, 1.0, height_factor);
        vertex.y += vertical_movement * height_factor;
    }

    // Ruído suavizado
    float noise = random(vertex * 0.01 + adjusted_time * 0.1) * wind_strength;
    noise *= smoothstep(0.0, 1.0, height_factor);
    vertex += noise * height_factor;

    VERTEX = vertex;
}

void fragment() {
    // Obtém a cor do pixel da textura com coordenadas ajustadas
    vec4 texture_color = texture(TEXTURE, UV);

    // Descarta pixels completamente transparentes
    if (texture_color.a < 0.01) {
        discard;
    }

    // Suaviza as bordas
    float alpha_smoothing = 0.1;
    texture_color.a *= smoothstep(0.0, alpha_smoothing, texture_color.a);

    // Aplica a cor final
    COLOR = texture_color;
}