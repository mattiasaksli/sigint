extends Spatial

var _interactable_nodes : Array = []
var _next_active_node_indices_stack : Array = []
var _max_interactable_nodes : int

onready var _game_manager : Node = $"/root/Main/GameManager"


func _ready() -> void:
	# warning-ignore:return_value_discarded
	_game_manager.connect("add_player", self, "on_add_player")
	# warning-ignore:return_value_discarded
	_game_manager.connect("remove_player", self, "on_remove_player")
	
	# Initialize random seed
	randomize()
	
	# Initialize variables
	_max_interactable_nodes = $"/root/Main/Players".get_child_count()
	
	var nodes : Array = $Interactables.get_children()
	for node in nodes:
		_interactable_nodes.append(node)
	
	_next_active_node_indices_stack = _set_active_nodes_order()
	
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
	_max_interactable_nodes += 1
	_reset_progress()


func on_remove_player(_player : Node) -> void:
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
	
	var left_room_interactable_indexes : Array = [0, 3, 6]
	var middle_room_interactable_indexes : Array = [2, 5]
	var right_room_interactable_indexes : Array = [1, 4, 7]
	left_room_interactable_indexes.shuffle()
	middle_room_interactable_indexes.shuffle()
	right_room_interactable_indexes.shuffle()
	
	var rooms : Array = [left_room_interactable_indexes, right_room_interactable_indexes, middle_room_interactable_indexes]
	var new_indices : Array = []
	
	# Make sure that each player gets "their own" interactable in the room they are in
	for i in range(_max_interactable_nodes):
		var room_index = i % 3
		new_indices.append(rooms[room_index].pop_front())
	
	new_indices.shuffle()
	
	return new_indices


func _open_doors() -> void:
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
		
		# warning-ignore:return_value_discarded
		tween.interpolate_property(
			door_moving_part,
			"translation",
			closed_point.translation,
			open_point.translation,
			opening_duration, Tween.TRANS_BOUNCE,
			Tween.EASE_OUT
		)
		# warning-ignore:return_value_discarded
		tween.start()
