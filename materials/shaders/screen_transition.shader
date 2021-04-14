shader_type canvas_item;
render_mode unshaded;

uniform float progress : hint_range(0.0, 1.0);
uniform float diamond_size = 40.0;
// Transition in: 1.0
// Transition out: -1.0
uniform float direction = 1.0;


void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamond_size);
	float yFraction = fract(FRAGCOORD.y / diamond_size);
	
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	
	if ((xDistance + yDistance + UV.y) * direction < (progress * 2.1) * direction) {
		discard;
	}
	COLOR = vec4(COLOR.rgb, 1.0);
}