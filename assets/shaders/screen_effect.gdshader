shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 0.85;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float shadow_softness : hint_range(0.0, 2.0) = 1.2;
uniform vec3 shadow_color : source_color = vec3(0.01, 0.01, 0.02);
uniform float time : hint_range(0.0, 100.0);
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.03;
uniform float brightness : hint_range(0.0, 1.0) = 0.0; // Controla a transparência

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;

    // Efeito de pulso suave
    float pulse = sin(time * 1.5) * 0.5 + 0.5;
    pulse = pulse * pulse_intensity;

    // Distância do centro com suavização
    vec2 center_dist = UV - vec2(0.5);
    float dist = length(center_dist);
    float radial_darkness = smoothstep(0.2, shadow_softness, dist);

    // Ruído dinâmico sutil
    float noise = random(uv + vec2(time * 0.1)) * noise_intensity;

    // Obtém a cor original
    vec4 original = texture(TEXTURE, uv);

    // Aplica escuridão base
    float darkness_factor = darkness + pulse + (noise * 0.5);
    darkness_factor = clamp(darkness_factor, 0.0, 1.0);

    // Mistura com a cor da sombra
    vec3 darkened = mix(original.rgb, shadow_color, darkness_factor);

    // Adiciona escuridão radial
    darkened = mix(darkened, shadow_color, radial_darkness * 0.7);

    // Efeito de ondulação sutil
    float wave = sin((uv.y * 10.0) + time) * 0.002;
    darkened += vec3(wave);

    // Transparência dinâmica ajustada pelo brilho
    float alpha = mix(0.4, 0.85, darkness_factor);
    alpha *= (1.0 - brightness); // O brilho controla quanto do efeito é visível

    // Cor final
    COLOR = vec4(darkened, alpha);
}