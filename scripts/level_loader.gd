class_name LevelLoader

var _can_thread_run : bool = true
var _path : String
var _thread : Thread
var _mutex : Mutex
var _semaphore : Semaphore
var _interactive_loader : ResourceInteractiveLoader = null   # Level is loading when _interactive_loader is not null
var _levels : Dictionary = {}

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
	_lock("queue_levels")
	
	if _levels.has(path):
		# The level is already loaded
		_unlock("queue_levels")
		return
	elif ResourceLoader.has_cached(path):
		# Resource loader has the level cached
		var packed_scene : PackedScene = ResourceLoader.load(path) as PackedScene
		_levels[path] = packed_scene
		_unlock("queue_levels")
		return
	else:
		# Starts loading the level from disk
		_interactive_loader = ResourceLoader.load_interactive(path)
		_path = path
		_post("queue_levels") # Allow thread process to continue
		_unlock("queue_levels")
		
		print("Started loading level " + path)
		
		return


func cancel_loading_level() -> void:
	_lock("cancel_loading_levels")
	
	# Check if level is currently being loaded
	if _interactive_loader != null:
		_interactive_loader = null
		
	_unlock("cancel_loading_levels")


func get_progress(path : String) -> float:
	_lock("get_progress")
	var percentage : float = -1.0
	
	# Check if level is currently being loaded
	if _interactive_loader != null:
		if not _levels.has(path):
			# Level has not been loaded
			percentage = float(_interactive_loader.get_stage()) / float(_interactive_loader.get_stage_count())
		else:
			# Level is loaded
			percentage = 1.0
		
	_unlock("get_progress")
	return percentage


func is_ready(path : String) -> bool:
	var status : bool
	_lock("is_ready")

	status = _levels.has(path)

	_unlock("is_ready")
	return status


func _wait_for_level() -> void:
	_unlock("wait_for_levels")
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		_lock("wait_for_levels")
		
		var status : int = _interactive_loader.poll()
		if status == ERR_FILE_EOF || status != OK:
			# Level has loaded
			return
		
		_unlock("wait_for_levels")


func get_level(path : String) -> PackedScene:
	_lock("get_levels")
	
	if _interactive_loader != null:
		if not _levels.has(path):
			# Level is currently loading, wait until it has loaded
			_wait_for_level()
			var packed_scene : PackedScene = _interactive_loader.get_resource() as PackedScene
			
			_unlock("return")
			return packed_scene
		else:
			# Level is loaded, returning level
			_unlock("return")
			return _levels[path]
	else:
		# Not currently loading level, loads the level normally
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
			_levels[_path] = _interactive_loader.get_resource()
			_interactive_loader = null
			_path = ""
	
	_unlock("process")


func _thread_loop(_u) -> void:
	while _can_thread_run:
		_thread_process()
	
	_thread.wait_to_finish()


func start() -> void:
	_mutex = Mutex.new()
	_semaphore = Semaphore.new()
	_thread = Thread.new()
	
	if _thread.start(self, "_thread_loop", 0) == ERR_CANT_CREATE:
		printerr("Failed creating resource loader thread!")


func stop_thread() -> void:
	_can_thread_run = false
