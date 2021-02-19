extends Area

var all_players : Array
var players_in_win_area : Array


func _ready():
	all_players = get_tree().get_nodes_in_group("players")

func on_player_entered(body: Node):
	if body.is_in_group("players"):
		print_debug(body.name + " entered win area")
		players_in_win_area.append(body)
		
		if do_arrays_match(all_players, players_in_win_area):
			win()

func on_player_exited(body: Node):
	if body.is_in_group("players"):
		print_debug(body.name + " left win area")
		players_in_win_area.erase(body)

func do_arrays_match(array1 : Array, array2 : Array):
	if array1.size() != array2.size():
		return false
	
	for player in array1:
		if !array2.has(player):
			return false
	
	return true

func win():
	print_debug("move to next level")
	# TODO: maybe add timer
	# TODO: move to next level
