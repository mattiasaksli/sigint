extends Node

export var _level : String

var _frametimes : Array = []


func _ready() -> void:
	print("Starting " + _level + " benchmark")


func _process(delta : float) -> void:
	_frametimes.append(delta)


func _exit_tree() -> void:
	_on_save_to_file()


func _on_save_to_file() -> void:
	print("Stopping " + _level + " benchmark")
	
	var file : File = File.new()
	var status : int = file.open("user://" + _level + "_benchmark.csv", File.WRITE)
	
	if status == OK:
		file.store_csv_line(_frametimes)
	
	file.close()
	
	self.queue_free()
