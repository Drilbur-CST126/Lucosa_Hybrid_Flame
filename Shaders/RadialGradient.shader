shader_type canvas_item;
render_mode unshaded;

uniform vec2 center = vec2(0.5, 0.5);
uniform vec4 color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float strength = 1.0;

float rand(vec2 co, float lower, float upper){
    return mix(lower, upper, fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453));
}

void fragment()
{
	COLOR = texture(TEXTURE, UV);
	float dist = distance(UV, center);
	COLOR.rgb = color.rgb;
	COLOR.a = COLOR.a * rand(UV, 0.95, 1.0) * (0.5 - dist) * strength;
}