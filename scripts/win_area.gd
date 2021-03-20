extends Area

var ALL_PLAYERS : Array
var PLAYERS_IN_WIN_AREA : Array


func _ready() -> void:
	ALL_PLAYERS = get_tree().get_nodes_in_group("players")

func on_player_entered(body: Node) -> void:
	print_debug(body.name + " entered win area")
	if not PLAYERS_IN_WIN_AREA.has(body):
		PLAYERS_IN_WIN_AREA.append(body)
	
	if _do_arrays_match(ALL_PLAYERS, PLAYERS_IN_WIN_AREA):
		_win()

func on_player_exited(body: Node) -> void:
	print_debug(body.name + " left win area")
	PLAYERS_IN_WIN_AREA.erase(body)

# Returns true if array2 contains the same elements as array1, assuming there are no duplicate elements.
func _do_arrays_match(array1 : Array, array2 : Array) -> bool:
	if array1.size() != array2.size():
		return false
	
	for player in array1:
		if !array2.has(player):
			return false
	
	return true

func _win() -> void:
	print_debug("move to next level")
	# TODO: add timer
	# TODO: move to next level
