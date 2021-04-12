extends Spatial

signal player_crushed(players_crushed)

enum {EXTENDING, RETRACTING}

export var extend_duration : float = 0.8
export var retract_duration : float = 1.5
export var starting_delay : float = 0.0
export var before_retract_start_delay : float = 1.0
export var before_extend_start_delay : float = 0.5

var _state : int = EXTENDING
var _players_in_left_piston_area : Array = []
var _players_in_right_piston_area : Array = []

onready var _left_piston : Spatial = $Left/Piston as Spatial
onready var _right_piston : Spatial = $Right/Piston as Spatial
onready var _left_retracted_pos : Vector3 = ($Left/RetractedPosition as Spatial).translation
onready var _left_extended_pos : Vector3 = ($Left/ExtendedPosition as Spatial).translation
onready var _right_retracted_pos : Vector3 = ($Right/RetractedPosition as Spatial).translation
onready var _right_extended_pos : Vector3 = ($Right/ExtendedPosition as Spatial).translation
onready var _left_danger_area : CollisionShape = $Left/Piston/DangerArea/CollisionShape as CollisionShape
onready var _right_danger_area : CollisionShape = $Right/Piston/DangerArea/CollisionShape as CollisionShape
onready var _tween : Tween = $Tween as Tween


func _ready() -> void:
	self.connect("player_crushed", $"/root/Main/GameManager", "on_player_busted")
	
	_tween.interpolate_property(
		_left_piston,
		"translation",
		_left_retracted_pos,
		_left_extended_pos,
		extend_duration,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT,
		starting_delay
	)
	_tween.interpolate_property(
		_right_piston,
		"translation",
		_right_retracted_pos,
		_right_extended_pos,
		extend_duration,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT,
		starting_delay
	)
	_tween.start()


func on_player_entered_left_piston_area(player : KinematicBody) -> void:
	_players_in_left_piston_area.append(player)
	
	if _players_in_right_piston_area.has(player):
		_trigger_game_over()


func on_player_entered_right_piston_area(player : KinematicBody) -> void:
	_players_in_right_piston_area.append(player)
	
	if _players_in_left_piston_area.has(player):
		_trigger_game_over()


func on_player_exited_left_piston_area(player : KinematicBody) -> void:
	_players_in_left_piston_area.erase(player)


func on_player_exited_right_piston_area(player : KinematicBody) -> void:
	_players_in_right_piston_area.erase(player)


func on_tween_completed() -> void:
	if _state == EXTENDING:
		_retract_pistons()
	else:
		_extend_pistons()


func _extend_pistons() -> void:
	_state = EXTENDING
	
	_left_danger_area.disabled = false
	_right_danger_area.disabled = false
	
	_tween.stop_all()
	_tween.interpolate_property(
		_left_piston,
		"translation",
		_left_retracted_pos,
		_left_extended_pos,
		extend_duration,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT,
		before_extend_start_delay
	)
	_tween.interpolate_property(
		_right_piston,
		"translation",
		_right_retracted_pos,
		_right_extended_pos,
		extend_duration,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT,
		before_extend_start_delay
	)
	_tween.start()


func _retract_pistons() -> void:
	_state = RETRACTING
	
	_left_danger_area.disabled = true
	_right_danger_area.disabled = true
	
	_tween.stop_all()
	_tween.interpolate_property(
		_left_piston,
		"translation",
		_left_extended_pos,
		_left_retracted_pos,
		retract_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		before_retract_start_delay
	)
	_tween.interpolate_property(
		_right_piston,
		"translation",
		_right_extended_pos,
		_right_retracted_pos,
		retract_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		before_retract_start_delay
	)
	_tween.start()


func _trigger_game_over() -> void:
	var players_crushed : Array = []
	var players = $"/root/Main/Players".get_children()
	
	for player in players:
		if _players_in_left_piston_area.has(player) and _players_in_right_piston_area.has(player):
			players_crushed.append(player)
			(player as Player).on_hide_player()
	
	emit_signal("player_crushed", players_crushed)
