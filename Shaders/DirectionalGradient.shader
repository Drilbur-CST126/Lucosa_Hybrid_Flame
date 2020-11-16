shader_type canvas_item;
render_mode unshaded;

uniform vec4 col : hint_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment()
{
	COLOR.rgb = col.rgb;
	COLOR.a = UV.x * UV.x;
}