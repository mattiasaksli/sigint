extends Spatial

export var wall_node_path : NodePath
export var speed : float = 6
export var upper_bound : float = 25
export var lower_bound : float = -25

var wall_node : Spatial
var can_move_wall_up : bool = false
var can_move_wall_down : bool = false

const registered_players : Array = []


func _ready() -> void:
	wall_node = get_node(wall_node_path)

func _physics_process(delta : float) -> void:
	if not registered_players.empty():
		for player_string_prefix in registered_players:
			handle_player_input(player_string_prefix)
	handle_wall_movement(delta)
	reset_wall()

func reset_wall() -> void:
	can_move_wall_up = false
	can_move_wall_down = false

func handle_player_input(prefix : String) -> void:
	if Input.is_action_pressed(prefix + "interact_up"):
		can_move_wall_up = true
	elif Input.is_action_pressed(prefix + "interact_down"):
		can_move_wall_down = true

func handle_wall_movement(delta : float):
	if can_move_wall_up:
		if not wall_node.translation.y > upper_bound:
			wall_node.translation += Vector3(0, 1, 0) * (speed * delta)
		else:
			wall_node.translation.y = upper_bound
	elif can_move_wall_down:
		if not wall_node.translation.y < lower_bound:
			wall_node.translation += Vector3(0, -1, 0) * (speed * delta)
		else:
			wall_node.translation.y = lower_bound

func on_player_registered(body : Node) -> void:
	registered_players.append(body.name.to_lower() + "_")

func on_player_unregistered(body : Node) -> void:
	registered_players.erase(body.name.to_lower() + "_")
