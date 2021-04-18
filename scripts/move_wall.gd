extends Spatial

enum {MOVING_UP, MOVING_DOWN, NOT_MOVING}

export var movable_wall_node_path : NodePath
export var speed : float = 6
export var upper_bound : float = 25
export var lower_bound : float = -25
export var arrow_active_color : Color = Color("#b79141")
export var arrow_normal_color : Color = Color("#343434")

var _state : int = NOT_MOVING
var _wall_movement_direction : Vector3 = Vector3.ZERO
var _registered_players : Array
var _wall_node : Spatial
var _game_manager : Node
var _up_arrow : MeshInstance
var _down_arrow : MeshInstance

var _is_guard_investigating : bool = false

onready var _button_sprite_3d : Sprite3D = $ButtonSprite3D as Sprite3D


func _enter_tree() -> void:
	_game_manager = $"/root/Main/GameManager"


func _ready() -> void:
	_wall_node = get_node(movable_wall_node_path) as Spatial
	_up_arrow = _wall_node.get_node("UpArrow") as MeshInstance
	_down_arrow = _wall_node.get_node("DownArrow") as MeshInstance
	
	_game_manager.connect("game_over", self, "on_game_over")
	
	# TODO: change this to unspaghettify code
	# "Disable" CameraGuard2
	var guard : CameraGuard = $"../../../MiddleRoom/Guards/CameraGuard2" as CameraGuard
	(guard.get_node("FOV/ImmediateGeometry") as ImmediateGeometry).visible = false
	guard.is_movement_stopped = true


func _process(_delta : float) -> void:
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			_handle_player_input(player_string_prefix)


func _physics_process(delta : float) -> void:
	_handle_wall_movement(delta)


func _handle_player_input(prefix : String) -> void:
	# TODO: change this to unspaghettify code
	if not _is_guard_investigating and (Input.is_action_pressed(prefix + "interact_up") or Input.is_action_pressed(prefix + "interact_down")):
		_make_guard_investigate()
	
	if Input.is_action_pressed(prefix + "interact_up"):
		_wall_movement_direction.y = 1
		if _state != MOVING_UP:
			_state = MOVING_UP
			(_up_arrow.material_override as SpatialMaterial).albedo_color = arrow_active_color
			(_down_arrow.material_override as SpatialMaterial).albedo_color = arrow_normal_color
	elif Input.is_action_pressed(prefix + "interact_down"):
		_wall_movement_direction.y = -1
		if _state != MOVING_DOWN:
			_state = MOVING_DOWN
			(_up_arrow.material_override as SpatialMaterial).albedo_color = arrow_normal_color
			(_down_arrow.material_override as SpatialMaterial).albedo_color = arrow_active_color
	else:
		_wall_movement_direction.y = 0
		if _state != NOT_MOVING:
			_state = NOT_MOVING
			(_up_arrow.material_override as SpatialMaterial).albedo_color = arrow_normal_color
			(_down_arrow.material_override as SpatialMaterial).albedo_color = arrow_normal_color


func _handle_wall_movement(delta : float) -> void:
	if _wall_movement_direction.y == 0:
		return
	
	_wall_node.translation += _wall_movement_direction * (speed * delta)
	
	if _wall_movement_direction.y == 1 and _wall_node.translation.y > upper_bound:
		_wall_node.translation.y = upper_bound
	elif _wall_movement_direction.y == -1 and _wall_node.translation.y < lower_bound:
		_wall_node.translation.y = lower_bound


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)
		_button_sprite_3d.visible = true


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")
	_wall_movement_direction.y = 0
	
	if _registered_players.size() == 0:
		_button_sprite_3d.visible = false


func on_game_over() -> void:
	self.set_physics_process(false)
	self.set_process(false)
	
	$InteractionArea.disconnect("body_entered", self, "on_player_registered")
	$InteractionArea.disconnect("body_exited", self, "on_player_unregistered")
	
	# Stop script
	set_script(null)


func _make_guard_investigate() -> void:
	_is_guard_investigating = true
	var guard : CameraGuard = $"../../../MiddleRoom/Guards/CameraGuard2" as CameraGuard
	(guard.get_node("FOV/ImmediateGeometry") as ImmediateGeometry).visible = true
	guard.is_movement_stopped = false
