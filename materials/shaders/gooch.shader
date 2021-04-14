shader_type spatial;
render_mode blend_mix, shadows_disabled, ambient_light_disabled;

uniform lowp vec4 cool_color : hint_color = vec4(0.0, 0.0, 0.6, 1.0);
uniform lowp vec4 warm_color : hint_color = vec4(0.35, 0.0, 0.15, 1.0);
uniform lowp vec4 base_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform lowp float alpha : hint_range(0.0, 1.0) = 0.3;
uniform lowp float beta : hint_range(0.0, 1.0) = 0.3;

const lowp float specular_power = 48.0;

vec3 gooch_shading(lowp vec3 light_dir, lowp vec3 dir_towards_camera, lowp vec3 normal) {
	// Input vectors are in view space.
	
	lowp vec3 dir_towards_light = normalize(light_dir);
	
	lowp vec3 kcool = min(cool_color.rgb + alpha * base_color.rgb, 1.0);
	lowp vec3 kwarm = min(warm_color.rgb + beta * base_color.rgb, 1.0);
	
	// Fragment is facing towards light -> warm color.
	// Fragment is facing away from light -> cool color.
	lowp vec3 diffuse = mix(kcool, kwarm, max(0.0, dot(normal, dir_towards_light)));

	return diffuse;
}

void light() {
	DIFFUSE_LIGHT = mix(gooch_shading(LIGHT, VIEW, NORMAL), LIGHT_COLOR, 0.05) * ATTENUATION;
	
	lowp vec3 h = normalize(LIGHT + VIEW);
	lowp float specular = pow(max(0.0, dot(NORMAL, h)), specular_power);
	
	SPECULAR_LIGHT += min(LIGHT_COLOR * specular, 1.0) * ATTENUATION;
}
