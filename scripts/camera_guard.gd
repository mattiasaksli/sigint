extends KinematicBody

onready var top_pos : Spatial = $"../TopPos"
onready var bottom_pos : Spatial = $"../BottomPos"

var moving_to_bottom : bool = true
var speed : float = 6
var direction : Vector3 = Vector3(0, -1, 0)

var waiting : bool = false
var pause_start_time : int = 0
var pause_duration_ms : int = 2000

var visible_players : Array
var is_game_over : bool = false
var player_detected_start_time : int = 0
var player_grace_period_ms : int = 1000

func _ready():
	pass

func _process(delta):
	if visible_players.size() != 0:
		# Player(s) visible
		if !is_waiting(player_detected_start_time, player_grace_period_ms) and !is_game_over:
			game_over()

func _physics_process(delta):
	if is_game_over:
		return
	
	if waiting:
		waiting = is_waiting(pause_start_time, pause_duration_ms)
		return
	
	move_and_slide(direction * speed)
	
	if moving_to_bottom and translation.y < bottom_pos.translation.y:
		# Reached the bottom
		moving_to_bottom = false
		direction.y = 1
		translation.y = bottom_pos.translation.y
		waiting = true
		pause_start_time = OS.get_ticks_msec()
	elif !moving_to_bottom and translation.y > top_pos.translation.y:
		# Reached the top
		moving_to_bottom = true
		direction.y = -1
		translation.y = top_pos.translation.y
		waiting = true
		pause_start_time = OS.get_ticks_msec()

func is_waiting(wait_start_time : int, wait_duration_ms : int):
	# Returns true if wait_duration_ms is not passed
	return OS.get_ticks_msec() - wait_start_time <= wait_duration_ms

func player_detected(body : Node):
	if body.is_in_group("players"):
		print_debug(body.to_string() + " detected")
		
		visible_players.append(body)
		if OS.get_ticks_msec() - player_detected_start_time > player_grace_period_ms:
			# This makes sure that player_detected_start_time does not update too frequently
			player_detected_start_time = OS.get_ticks_msec()

func player_got_away(body : Node):
	if body.is_in_group("players"):
		print_debug(body.to_string() + " got away")
		
		visible_players.erase(body)

func game_over():
	print_debug("game over")
	is_game_over = true
	# TODO: finish function
