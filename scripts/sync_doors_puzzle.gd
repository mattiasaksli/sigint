extends Spatial

const LEFT_ROOM_PLAYER_INDEXES : Array = [1, 4]
const MIDDLE_ROOM_PLAYER_INDEXES : Array = [0, 3, 6]
const RIGHT_ROOM_PLAYER_INDEXES : Array = [2, 5]

var _interactable_nodes : Array = []
var _next_active_node_indices_stack : Array = []
var _max_interactable_nodes : int
var _are_doors_open : bool = false

onready var _game_manager : GameManager = $"/root/Main/GameManager" as GameManager


func _ready() -> void:
	# warning-ignore:return_value_discarded
	_game_manager.connect("add_player", self, "on_add_player")
	# warning-ignore:return_value_discarded
	_game_manager.connect("remove_player", self, "on_remove_player")
	
	
	
	# Initialize variables
	_max_interactable_nodes = $"/root/Main/Players".get_child_count()
	
	var nodes : Array = $Interactables.get_children()
	for node in nodes:
		_interactable_nodes.append(node)
	
	_next_active_node_indices_stack = _set_active_nodes_order()
	
	if _next_active_node_indices_stack.empty():
		return
	
	# Let the node know it is currently active
	var current_active_node_index = _next_active_node_indices_stack[0]
	_interactable_nodes[current_active_node_index].set_active()


func on_interacted(interacted_node : Node) -> void:
	if _next_active_node_indices_stack.size() == 0:
		# Doors are already opened
		return
	
	# Check if the interacted node was the currently active node
	var current_active_node_index = _next_active_node_indices_stack[0]
	var active_node : Node = _interactable_nodes[current_active_node_index]
	if active_node != interacted_node:
		_reset_progress()
		return
	
	_interactable_nodes[current_active_node_index].set_completed()
	
	_next_active_node_indices_stack.pop_front()
	
	if _next_active_node_indices_stack.size() == 0:
		# Finish puzzle
		_open_doors()
		return
	
	current_active_node_index = _next_active_node_indices_stack[0]
	_interactable_nodes[current_active_node_index].set_active()


func on_add_player(_player : Node) -> void:
	if _are_doors_open:
		return
	
	_max_interactable_nodes += 1
	_reset_progress()


func on_remove_player(_player : Node) -> void:
	if _are_doors_open:
		return
	
	_max_interactable_nodes -= 1
	_reset_progress()


func _reset_progress() -> void:
	# Reset all node states
	for node in _interactable_nodes:
		node.reset()
	
	if _max_interactable_nodes != 0:
		_next_active_node_indices_stack = _set_active_nodes_order()
		
		var current_active_node_index = _next_active_node_indices_stack[0]
		_interactable_nodes[current_active_node_index].set_active()


func _set_active_nodes_order() -> Array:
	_next_active_node_indices_stack.clear()
	
	# Randomize indices per room
	LEFT_ROOM_PLAYER_INDEXES.shuffle()
	MIDDLE_ROOM_PLAYER_INDEXES.shuffle()
	RIGHT_ROOM_PLAYER_INDEXES.shuffle()
	
	var players_in_left_room : bool = false
	var players_in_middle_room : bool = false
	var players_in_right_room : bool = false
	
	# Check if there are any players in the rooms
	for player_index in _game_manager.get_controller_indices():
		if not players_in_left_room and player_index in LEFT_ROOM_PLAYER_INDEXES:
			players_in_left_room = true
		elif not players_in_middle_room and player_index in MIDDLE_ROOM_PLAYER_INDEXES:
			players_in_middle_room = true
		elif not players_in_right_room and player_index in RIGHT_ROOM_PLAYER_INDEXES:
			players_in_right_room = true
	
	# If a player is in a room, adds all of the interactables in that room the the queue
	var new_indices : Array = []
	if players_in_left_room:
		new_indices += LEFT_ROOM_PLAYER_INDEXES
	if players_in_middle_room:
		new_indices += MIDDLE_ROOM_PLAYER_INDEXES
	if players_in_right_room:
		new_indices += RIGHT_ROOM_PLAYER_INDEXES
	
#	for i in range(players_in_left_room):
#		new_indices.append(LEFT_ROOM_PLAYER_INDEXES[i])
#	for i in range(players_in_middle_room):
#		new_indices.append(MIDDLE_ROOM_PLAYER_INDEXES[i])
#	for i in range(players_in_right_room):
#		new_indices.append(RIGHT_ROOM_PLAYER_INDEXES[i])
	
	# Randomize newly picked indices order
	new_indices.shuffle()
	
	return new_indices


func _open_doors() -> void:
	if _are_doors_open:
		return
	
	_are_doors_open = true
	
	var tween : Tween
	var door_moving_part : Spatial
	var closed_point : Spatial
	var open_point : Spatial
	
	for door in $Doors.get_children():
		var opening_duration : float = 2.0 + randf()
		
		tween = door.get_node("Tween")
		door_moving_part = door.get_node("Door")
		closed_point = door.get_node("ClosedPoint")
		open_point = door.get_node("OpenPoint")
		
		tween.interpolate_property(
			door_moving_part,
			"translation",
			closed_point.translation,
			open_point.translation,
			opening_duration, Tween.TRANS_BOUNCE,
			Tween.EASE_OUT
		)
		tween.start()
