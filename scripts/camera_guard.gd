extends KinematicBody

var game_manager : Node

onready var top_pos : Spatial = $"../TopPos"
onready var bottom_pos : Spatial = $"../BottomPos"
onready var fov_raycasts : Array = $FOVRaycasts.get_children()
onready var fov_area : Area = $FOVArea
onready var detection_timer : Timer = $DetectionTimer
onready var movement_pause_timer : Timer = $MovementPauseTimer

var speed : float = 6
var direction : Vector3 = Vector3(0, -1, 0)

var players_nearby : Array = []
var visible_players : Array = []

signal player_busted


func _enter_tree():
	game_manager = $"/root/Main"

func _ready():
	# warning-ignore:return_value_discarded
	self.connect("player_busted", game_manager, "on_player_busted")

func _physics_process(_delta):
	if not players_nearby.empty():
		check_for_players()
	elif not detection_timer.is_stopped():
		# Otherwise detection timer will continue when no players are in the area
		detection_timer.stop()
	
	if movement_pause_timer.is_stopped():
		# warning-ignore:return_value_discarded
		move_and_slide(direction * speed)
		check_bounds()

func check_bounds():
	if translation.y < bottom_pos.translation.y:	# Reached the bottom
		direction.y = 1
		translation.y = bottom_pos.translation.y
		
		movement_pause_timer.start()
	elif translation.y > top_pos.translation.y:		# Reached the top
		direction.y = -1
		translation.y = top_pos.translation.y
		movement_pause_timer.start()

func check_for_players():
	visible_players = []
	
	for i in range(fov_raycasts.size()):
		var raycast : RayCast = fov_raycasts[i]
		if raycast.is_colliding():
			var collider : Node = raycast.get_collider()
			if collider.is_in_group("players") and not visible_players.has(collider):
				visible_players.append(collider)
	
	if not visible_players.empty() and detection_timer.is_stopped():
		detection_timer.start()
		print_debug(self.name + " detection_timer started")
	elif visible_players.empty() and not detection_timer.is_stopped():
		detection_timer.stop()
		print_debug(self.name + " detection_timer stopped")

func body_entered_area(body : Node):
	if body.is_in_group("players"):
		players_nearby.append(body)
		print_debug(body.name + " entered " + self.name + " FOV area")

func body_exited_area(body : Node):
	if body.is_in_group("players"):
		players_nearby.erase(body)
		print_debug(body.name + " exited " + self.name + " FOV area")

func game_over():
	# TODO: finish function
	
	print_debug(self.name + " triggered the game over")
	
	emit_signal("player_busted")
	
	# Disconnect signals used by FOVArea to stop warnings
	$FOVArea.disconnect("body_entered", self, "body_entered_area")
	$FOVArea.disconnect("body_exited", self, "body_exited_area")
	
	# Stop script
	set_script(null)
