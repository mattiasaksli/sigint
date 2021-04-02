class_name TimeTracker

extends Node

var _time_in_seconds : float = 0


func _ready() -> void:
	_time_in_seconds = 0


func _process(delta : float) -> void:
	_time_in_seconds += delta


func get_elapsed_time_and_stop_tracking() -> float:
	set_process(false)
	return _time_in_seconds
