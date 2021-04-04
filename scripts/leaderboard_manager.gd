extends Node

const FILE_NAME : String = "user://leaderboard.dat"
const PASSWD : String = "1337"

var _leaderboard_loaded_from_file : bool = false
var _leaderboard_state : Array = []  # Array of dictionaries
#[
#	{
#		"team_name" : team_name,
#		"elapsed_time" : elapsed_time,
#		"finished_time" : finished_time
#	},
#	...
#]


func save_to_file(team_name : String, elapsed_time : String, finished_time : String) -> void:
	
	print("saving team name: " + team_name + ", elapsed time: " + elapsed_time + ", finished time: " + finished_time)
	
	# Adds new entry to leaderboard
	_leaderboard_state.append(
		{
			"team_name" : team_name,
			"elapsed_time" : elapsed_time,
			"finished_time" : finished_time
		}
	)
	
	# Sorts leaderboard state by elapsed time
	_sort_leaderboard_state()
	
	# Saves leaderboard state to file
	var file : File = File.new()
	var status : int = file.open_encrypted_with_pass(FILE_NAME, File.WRITE, PASSWD)
	
	if status == OK:
		file.store_string(to_json(_leaderboard_state))
	else:
		printerr("Error when saving leaderboard data!")
	
	file.close()


func get_leaderboard_state() -> Array:
	if not _leaderboard_loaded_from_file:
		_load_from_file()
		_leaderboard_loaded_from_file = true
	
	if _leaderboard_state.size() != 0:
		_sort_leaderboard_state()
	
	return _leaderboard_state


func _load_from_file() -> void:
	var file : File = File.new() as File
	
	if file.file_exists(FILE_NAME):
		var status : int = file.open_encrypted_with_pass(FILE_NAME, File.READ, PASSWD)
		
		if status == OK:
			var loaded_state = parse_json(file.get_as_text())
			file.close()
			
			if typeof(loaded_state) == TYPE_ARRAY:
				_leaderboard_state = loaded_state
			else:
				printerr("Leaderboard data corrupted!")
		else:
			printerr("Error when loading leaderboard data!")
	else:
		printerr("No saved leaderboard data!")
	
	if file.is_open():
		file.close()


func _sort_leaderboard_state() -> void:
	_leaderboard_state.sort_custom(LeaderboardSorter, "sort_ascending")


class LeaderboardSorter:
	static func sort_ascending(a : Dictionary, b : Dictionary) -> bool:
		if a["elapsed_time"] < b["elapsed_time"]:
			return true
		return false
