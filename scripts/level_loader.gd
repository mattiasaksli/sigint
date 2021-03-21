class_name LevelLoader

var _thread : Thread
var _mutex : Mutex
var _semaphore : Semaphore
var _interactive_loader : ResourceInteractiveLoader = null
var _level : PackedScene = null

# Description variable is there to replace comments
func _lock(_description) -> void:
	_mutex.lock()


func _unlock(_description) -> void:
	_mutex.unlock()


func _post(_description) -> void:
	if _semaphore.post() == ERR_BUSY:
		printerr("Error lowering semaphore!")


func _wait(_description) -> void:
	if _semaphore.wait() == ERR_BUSY:
		printerr("Error waiting for semaphore!")


func queue_level(path : String) -> void:
	_lock("queue_level")
	
	if _level != null:
		# The level is already loaded
		_unlock("queue_level")
		return
	elif ResourceLoader.has_cached(path):
		# Resource loader has the level cached
		var res : PackedScene = ResourceLoader.load(path)
		_level = res
		_unlock("queue_level")
		return
	else:
		# Starts loading the level from disk
		_interactive_loader = ResourceLoader.load_interactive(path)
		_post("queue_level") # Allow thread process to continue
		_unlock("queue_level")
		return


func cancel_loading_level() -> void:
	_lock("cancel_loading_level")
	
	# Check if level is currently being loaded
	if _interactive_loader != null:
		_interactive_loader = null
		
	_unlock("cancel_loading_level")


func get_progress() -> float:
	_lock("get_progress")
	var percentage : float = -1.0
	
	# Check if level is currently being loaded
	if _interactive_loader != null:
		if _level == null:
			percentage = float(_interactive_loader.get_stage()) / float(_interactive_loader.get_stage_count())
		else:
			percentage = 1.0
		
	_unlock("get_progress")
	return percentage


#func is_ready() -> bool:
#	var status : bool
#	_lock("is_ready")
#
#	status = _level != null
#
#	_unlock("is_ready")
#	return status


func _wait_for_level() -> void:
	_unlock("wait_for_level")
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		_lock("wait_for_level")
		
		var status : int = _interactive_loader.poll()
		if status == ERR_FILE_EOF || status != OK:
			# Level has loaded
			return
		
		_unlock("wait_for_level")


func get_level(path : String) -> PackedScene:
	_lock("get_level")
	
	if _interactive_loader != null:
		if _level == null:
			# Level is currently loading, wait until it has loaded
			_wait_for_level()
			var res : PackedScene = _interactive_loader.get_resource()
			
			_unlock("return")
			return res
		else:
			# Level is loaded, returning level
			_unlock("return")
			return _level
	else:
		# Not currently loading level, loads level in a blocking manner
		_unlock("return")
		return ResourceLoader.load(path) as PackedScene


func _thread_process() -> void:
	_wait("thread_process")
	_lock("process")

	while _interactive_loader != null:
		_unlock("process_poll")
		
		var status : int = _interactive_loader.poll()
		
		_lock("process_check_if_loaded")
		if status == ERR_FILE_EOF || status != OK:
			# Level is loaded
			_level = _interactive_loader.get_resource()
			_interactive_loader = null
	
	_unlock("process")


func _thread_loop(_u) -> void:
	while true:
		_thread_process()


func start() -> void:
	_mutex = Mutex.new()
	_semaphore = Semaphore.new()
	_thread = Thread.new()
	
	if _thread.start(self, "_thread_loop", 0) == ERR_CANT_CREATE:
		printerr("Failed creating resource loader thread!")
