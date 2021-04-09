extends Spatial

export var bridge_obstacle_node_path : NodePath
export var speed : float = 6
export var upper_bound : float = 18
export var lower_bound : float = 0

var _bridge_movement_direction : Vector3 = Vector3.ZERO
var _registered_players : Array
var _players_on_bridge : Array
var _bridge_node : StaticBody
var _bridge_end_collider : CollisionShape
var _bridge_opposite_collider : CollisionShape
var _game_manager : Node

onready var _button_sprite_3d : Sprite3D = $ButtonSprite3D as Sprite3D


func _enter_tree() -> void:
	_game_manager = $"/root/Main/GameManager"


func _ready() -> void:
	var actual_bridge_path : String = ""
	for i in range(bridge_obstacle_node_path.get_name_count()):
		actual_bridge_path += bridge_obstacle_node_path.get_name(i) + "/"
	actual_bridge_path += "Bridge"
	
	_bridge_node = get_node(actual_bridge_path) as StaticBody
	_bridge_end_collider = _bridge_node.get_node("EndCollider") as CollisionShape
	_bridge_opposite_collider = _bridge_node.get_node("../InvisibleWalls/OppositeCollider") as CollisionShape
	
	# warning-ignore:return_value_discarded
	_game_manager.connect("game_over", self, "on_game_over")
	
	var bridge_area : Area = _bridge_node.get_node("../OnBridgeArea") as Area
	# warning-ignore:return_value_discarded
	bridge_area.connect("body_entered", self, "on_player_entered_bridge")
	# warning-ignore:return_value_discarded
	bridge_area.connect("body_exited", self, "on_player_exited_bridge")


func _physics_process(delta : float) -> void:
	_handle_bridge_movement(delta)
	_handle_toggling_bridge_colliders()
	
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			_handle_player_input(player_string_prefix)
	
	if not _players_on_bridge.empty():
		_handle_bridge_player_movement(delta)


func _handle_player_input(prefix : String) -> void:
	if Input.is_action_pressed(prefix + "interact_A"):
		if _bridge_node.translation.y < upper_bound:
			_bridge_movement_direction.y = 1
		else:
			_bridge_movement_direction.y = 0
	else:
		if _bridge_node.translation.y > lower_bound:
			_bridge_movement_direction.y = -1
		else:
			_bridge_movement_direction.y = 0


func _handle_bridge_movement(delta : float) -> void:
	if _bridge_movement_direction.y != 0:
		if _bridge_movement_direction.y == 1 and _bridge_node.translation.y > upper_bound:
			_bridge_node.translation.y = upper_bound
		elif _bridge_movement_direction.y == -1 and _bridge_node.translation.y < lower_bound:
			_bridge_node.translation.y = lower_bound
		else:
			_bridge_node.translation += _bridge_movement_direction * (speed * delta)


func _handle_toggling_bridge_colliders() -> void:
	var distance : float = upper_bound - _bridge_node.translation.y
	if distance <= 0.1 and not _bridge_end_collider.disabled:
		_bridge_end_collider.disabled = true
		_bridge_opposite_collider.disabled = true
	elif distance > 0.1 and _bridge_end_collider.disabled:
		_bridge_end_collider.disabled = false
		_bridge_opposite_collider.disabled = false


func _handle_bridge_player_movement(delta : float):
	var player : Player
	for i in range(_players_on_bridge.size()):
		player = _players_on_bridge[i]
		player.move_on_bridge(_bridge_movement_direction * (speed * delta))


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)
		_button_sprite_3d.visible = true
		


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")
	if _bridge_node.translation.y > lower_bound:
		_bridge_movement_direction.y = -1
	
	if _registered_players.size() == 0:
		_button_sprite_3d.visible = false


func on_player_entered_bridge(body : Node) -> void:
	if not _players_on_bridge.has(body):
		_players_on_bridge.append(body)


func on_player_exited_bridge(body : Node) -> void:
	_players_on_bridge.erase(body)


func on_game_over() -> void:
	# TODO: finish function
	
	$InteractionArea.disconnect("body_entered", self, "on_player_registered")
	$InteractionArea.disconnect("body_exited", self, "on_player_unregistered")
	
	# Stop script
	set_script(null)

