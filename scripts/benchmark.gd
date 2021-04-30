extends Node

export var _level : String

var _frametimes : Array = []


func _ready() -> void:
	print("starting benchmark")

func _process(delta : float) -> void:
	_frametimes.append(delta)


func on_save_to_file() -> void:
	print("stopping benchmark")
	
	var file : File = File.new()
	var status : int = file.open("user://" + _level + "_benchmark.csv", File.WRITE)
	
	if status == OK:
		file.store_csv_line(_frametimes)
	
	file.close()
	
	self.queue_free()
