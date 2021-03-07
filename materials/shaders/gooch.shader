shader_type spatial;
render_mode blend_mix, depth_draw_opaque, shadows_disabled,
		ambient_light_disabled, skip_vertex_transform, unshaded;

uniform vec4 cool_color : hint_color = vec4(0.0, 0.0, 0.6, 1.0);
uniform vec4 warm_color : hint_color = vec4(0.35, 0.0, 0.15, 1.0);
uniform vec4 base_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.3;
uniform float beta : hint_range(0.0, 1.0) = 0.3;

const float specular_power = 64.0;
const vec3 light_direction = vec3(0.492914, -0.355124, -0.794307);

varying vec3 view_space_light_dir;

vec3 gooch_shading(vec3 dir_towards_camera, vec3 normal) {
	vec3 dir_towards_light = normalize(-view_space_light_dir);
	vec3 h = normalize(dir_towards_light + dir_towards_camera);
	
	vec3 kcool = min(cool_color.rgb + alpha * base_color.rgb, 1.0);
	vec3 kwarm = min(warm_color.rgb + beta * base_color.rgb, 1.0);
	
	// Fragment is facing towards light -> warm color.
	// Fragment is facing away from light -> cool color.
	vec3 diffuse = mix(kcool, kwarm, max(0.0, dot(normal, dir_towards_light)));
	float specular = pow(max(0.0, dot(normal, h)), specular_power);

	return diffuse + specular;
}

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	// Directional light vector to view space.
	view_space_light_dir = (MODELVIEW_MATRIX * vec4(light_direction, 0.0)).xyz;
}
// View space to clip space is done automatically after the vertex() function is run.

vec3 simple_blinn_shading(vec3 dir_towards_camera, vec3 normal) {
	vec3 dir_towards_light = normalize(-view_space_light_dir);
	vec3 h = normalize(dir_towards_light + dir_towards_camera);

	float diffuse = max(0.0, dot(normal, dir_towards_light));
	float specular = pow(max(0.0, dot(normal, h)), specular_power);
	
	return base_color.rgb * (0.1 + diffuse) + specular;
}

void fragment() {
	ALBEDO = gooch_shading(VIEW, NORMAL);
}
