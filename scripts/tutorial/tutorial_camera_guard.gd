extends Spatial

signal tutorial_player_busted

const PLAYER_AND_HIDABLE_ENV_LAYERS : int = 0b1010
const PLAYER_LAYER : int = 0b10

export var direction : Vector3 = Vector3(0, -1, 0)
export var speed : float = 6
export var top_bound : float = 20
export var bottom_bound : float = -20
export var detection_time : float = 1
export var movement_pause_time : float = 1

export var normal_fov_color : Color = Color("#8cdec301")
export var busted_fov_color : Color = Color("#cc973500")

var _players_nearby : Array
var _visible_players : Array
var _movement_is_stopped : bool = true
var _can_change_cone_color : bool = true

onready var _detection_timer : Timer = $DetectionTimer as Timer           # The detection timer does not reset even if a player is no longer detected
onready var _movement_pause_timer : Timer = $MovementPauseTimer as Timer
onready var _immediate_geometry : ImmediateGeometry = $FOV/ImmediateGeometry as ImmediateGeometry
onready var _tutorial_script : Control = $"/root/Main/TutorialControl" as Control


func _ready() -> void:
	# Sets defaults
	_detection_timer.wait_time = detection_time
	_movement_pause_timer.wait_time = movement_pause_time
	_immediate_geometry.visible = false
	(_immediate_geometry.material_override as SpatialMaterial).albedo_color = normal_fov_color
	
	# Connects signals
	# warning-ignore:return_value_discarded
	self.connect("tutorial_player_busted", $"/root/Main/TutorialControl", "on_player_got_caught")  # Send game over to game manager
	# warning-ignore:return_value_discarded
	_tutorial_script.connect("activate_enemy", self, "_activate_tutorial_enemy")


func _process(_delta : float) -> void:
	if not _detection_timer.paused and _can_change_cone_color:
		# Interpolates the colors in reverse, to avoid extra math with _detection_timer.time_left
		(_immediate_geometry.material_override as SpatialMaterial).albedo_color = lerp(
			busted_fov_color,
			normal_fov_color,
			_detection_timer.time_left / _detection_timer.wait_time
		)


func _physics_process(delta : float) -> void:
	if not _players_nearby.empty():
		_check_for_players()
	elif not _detection_timer.paused:
		# Otherwise detection timer will continue when no players are in the area
		_stop_detecting()
	
	if not _movement_is_stopped and _movement_pause_timer.is_stopped():
		translation += direction * (speed * delta)
		
		_check_bounds()


func _check_bounds() -> void:
	if translation.y < bottom_bound:	# Reached the bottom
		direction.y = 1
		translation.y = bottom_bound
		
		_movement_pause_timer.start()
	elif translation.y > top_bound:		# Reached the top
		direction.y = -1
		translation.y = top_bound
		_movement_pause_timer.start()


func _check_for_players() -> void:
	_visible_players.clear()
	var collider : PhysicsBody
	var raycast_hit : Dictionary
	var space_state : PhysicsDirectSpaceState = get_world().direct_space_state
	var player : Spatial
	
	# Raycast for all players inside FOVArea.
	for i in range(_players_nearby.size()):
		player = _players_nearby[i]
		raycast_hit = space_state.intersect_ray(self.global_transform.origin, player.global_transform.origin, [], PLAYER_AND_HIDABLE_ENV_LAYERS)
		# A hit is guaranteed, since a player has to be inside FOVArea for a raycast to occur.
		collider = raycast_hit.collider
		if collider.collision_layer == PLAYER_LAYER and not _visible_players.has(collider):
			_visible_players.append(collider)
	
	if not _visible_players.empty() and _detection_timer.paused:
		_start_detecting()
	elif _visible_players.empty() and not _detection_timer.paused:
		_stop_detecting()


func _start_detecting() -> void:
	if _detection_timer.is_stopped():
		_detection_timer.start()
	else:
		_detection_timer.paused = false


func _stop_detecting() -> void:
	_detection_timer.paused = true


func _activate_tutorial_enemy() -> void:
	_immediate_geometry.visible = true
	_movement_is_stopped = false


func body_entered_area(body : Node) -> void:
	_players_nearby.append(body)


func body_exited_area(body : Node) -> void:
	_players_nearby.erase(body)


func trigger_game_over() -> void:
	(_immediate_geometry.material_override as SpatialMaterial).albedo_color = busted_fov_color
	
	_movement_is_stopped = true
	_can_change_cone_color = false
	
	emit_signal("tutorial_player_busted")
