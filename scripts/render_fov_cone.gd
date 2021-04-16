extends ImmediateGeometry

const FAR_VERTICES : Array = [
	Vector3(29.3444, 6.23735, 0),
	Vector3(29.708, 4.17519, 0),
	Vector3(29.9269, 2.09269, 0),
	Vector3(30, 0, 0),
	Vector3(29.9269, -2.09269, 0),
	Vector3(29.708, -4.17519, 0),
	Vector3(29.3444, -6.23735, 0)
]

const SHARED_VERTEX : Vector3 = Vector3.ZERO
const NORMAL : Vector3 = Vector3(0, 0, 1)
const PLAYER_AND_HIDABLE_ENV_LAYERS : int = 0b1010

var current_pass_vertices : Array = [
	Vector3(29.3444, 6.23735, 0),
	Vector3(29.708, 4.17519, 0),
	Vector3(29.9269, 2.09269, 0),
	Vector3(30, 0, 0),
	Vector3(29.9269, -2.09269, 0),
	Vector3(29.708, -4.17519, 0),
	Vector3(29.3444, -6.23735, 0)
]


func _process(_delta : float) -> void:
	clear()
	
	# Draw cone
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN)

	set_normal(NORMAL)
	add_vertex(SHARED_VERTEX)

	for i in range(7):
		set_normal(NORMAL)
		add_vertex(current_pass_vertices[i])
	
	end()


func _physics_process(_delta : float) -> void:
	var raycast_hit : Dictionary
	var space_state : PhysicsDirectSpaceState = get_world().direct_space_state
	
	for i in range(7):
		raycast_hit = space_state.intersect_ray(to_global(translation), to_global(FAR_VERTICES[i]), [], PLAYER_AND_HIDABLE_ENV_LAYERS)
		if raycast_hit.size() != 0:
			current_pass_vertices[i] = to_local(raycast_hit.position)
		else:
			current_pass_vertices[i] = FAR_VERTICES[i]
