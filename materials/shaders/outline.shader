shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_front, unshaded;

uniform lowp vec4 albedo : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform lowp float grow : hint_range(0.0, 1.0) = 0.25;


void vertex() {
	VERTEX += VERTEX * grow;
}

void fragment() {
	ALBEDO = albedo.rgb;
}
