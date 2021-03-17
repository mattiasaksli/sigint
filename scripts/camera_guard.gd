extends Spatial

var game_manager : Node

onready var detection_timer : Timer = $DetectionTimer
onready var movement_pause_timer : Timer = $MovementPauseTimer

export var direction : Vector3 = Vector3(0, -1, 0)
export var speed : float = 6
export var top_bound : float = 20
export var bottom_bound : float = -20

const players_nearby : Array = []
const visible_players : Array = []

const player_and_hidable_env_mask : int = 0b1010
const player_layer : int = 0b10

signal player_busted


func _enter_tree() -> void:
	game_manager = $"/root/Main"

func _ready() -> void:
	# warning-ignore:return_value_discarded
	self.connect("player_busted", game_manager, "on_player_busted")	# Send game over to game manager
	# warning-ignore:return_value_discarded
	game_manager.connect("game_over", self, "on_game_over")	# Do game over logic when the signal comes from game manager

func _physics_process(delta) -> void:
	if not players_nearby.empty():
		check_for_players()
	elif not detection_timer.is_stopped():
		# Otherwise detection timer will continue when no players are in the area
		detection_timer.stop()
	
	if movement_pause_timer.is_stopped():
		translation += direction * (speed * delta)
		check_bounds()

func check_bounds() -> void:
	if translation.y < bottom_bound:	# Reached the bottom
		direction.y = 1
		translation.y = bottom_bound
		
		movement_pause_timer.start()
	elif translation.y > top_bound:		# Reached the top
		direction.y = -1
		translation.y = top_bound
		movement_pause_timer.start()

func check_for_players() -> void:
	visible_players.clear()
	var collider : PhysicsBody
	var raycast_hit : Dictionary
	var space_state : PhysicsDirectSpaceState = get_world().direct_space_state
	
	# Raycast for all players inside FOVArea.
	for player in players_nearby:
		raycast_hit = space_state.intersect_ray(translation, player.translation, [], player_and_hidable_env_mask)
		# A hit is guaranteed, since a player has to be inside FOVArea for a raycast to occur.
		collider = raycast_hit.collider
		if collider.collision_layer == player_layer and not visible_players.has(collider):
			visible_players.append(collider)
	
#	for i in range(fov_raycasts.size()):
#		raycast = fov_raycasts[i]
#		if raycast.is_colliding():
#			collider = raycast.get_collider()
#			if not collider.is_in_group("players"):
#				continue
#			elif not visible_players.has(collider):
#				visible_players.append(collider)
	
	if not visible_players.empty() and detection_timer.is_stopped():
		detection_timer.start()
	elif visible_players.empty() and not detection_timer.is_stopped():
		detection_timer.stop()

func body_entered_area(body : Node) -> void:
	players_nearby.append(body)

func body_exited_area(body : Node) -> void:
	players_nearby.erase(body)

func trigger_game_over() -> void:
	# TODO: finish function
	
	print_debug(self.name + " triggered the game over because " + get_caught_players_string() + " got caught")
	
	emit_signal("player_busted")

func get_caught_players_string() -> String:
	if players_nearby.size() == 1:
		return players_nearby[0].name
	
	var caught_players_string : String = ""
	
	var player_name : String
	for i in range(players_nearby.size()):
		player_name = players_nearby[i].name
		# If the next index is the last one, finish the string.
		if i + 1 == players_nearby.size() - 1:
			var last_player_name : String = players_nearby[i + 1].name
			return caught_players_string + player_name + " and " + last_player_name
		else:
			caught_players_string += player_name + ", "
	return caught_players_string

func on_game_over() -> void:
	# TODO: finish function
	
	# Disconnect signals used by FOVArea to stop warnings
	$FOV/FOVArea.disconnect("body_entered", self, "body_entered_area")
	$FOV/FOVArea.disconnect("body_exited", self, "body_exited_area")
	
	# Stop script
	set_script(null)
