extends Node

signal sync_interacted(node)

const INACTIVE_COLOR : Color = Color("#c7c7c7")
const ACTIVE_COLOR : Color = Color("#ff9500")
const COMPLETED_COLOR : Color = Color("#20ff00")

var _registered_players : Array = []
var _computer_material_path : NodePath = @"Base/PersonalComputer:material/2"
var _computer : SpatialMaterial

onready var sync_puzzle_controller : Node = $"../../"
onready var _button_sprite_3d : Sprite3D = $ButtonSprite3D as Sprite3D
onready var _light : OmniLight = $OmniLight as OmniLight


func _ready() -> void:
	self.connect("sync_interacted", sync_puzzle_controller, "on_interacted")
	
	_computer = get_node_and_resource(_computer_material_path)[1]


func _physics_process(_delta : float) -> void:
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			if Input.is_action_just_pressed(player_string_prefix + "interact_A"):
				emit_signal("sync_interacted", self)


func set_active() -> void:
	_computer.albedo_color = ACTIVE_COLOR
	_light.visible = true


func set_completed() -> void:
	_computer.albedo_color = COMPLETED_COLOR
	_light.visible = false


func reset() -> void:
	_computer.albedo_color = INACTIVE_COLOR
	_light.visible = false


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)
		_button_sprite_3d.visible = true


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")
	
	if _registered_players.size() == 0:
		_button_sprite_3d.visible = false
