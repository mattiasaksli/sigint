extends Node

signal sync_interacted(node)

const INACTIVE_COLOR : Color = Color("#c7c7c7")
const ACTIVE_COLOR : Color = Color("#ff9500")
const COMPLETED_COLOR : Color = Color("#20ff00")

var _registered_players : Array = []

onready var active_light : MeshInstance = $ActiveLight as MeshInstance
onready var sync_puzzle_controller : Node = $"../../"
onready var _button_sprite_3d : Sprite3D = $MeshInstance/ButtonSprite3D as Sprite3D


func _ready() -> void:
	# warning-ignore:return_value_discarded
	self.connect("sync_interacted", sync_puzzle_controller, "on_interacted")


func _physics_process(_delta : float) -> void:
	if not _registered_players.empty():
		for player_string_prefix in _registered_players:
			if Input.is_action_just_pressed(player_string_prefix + "interact_A"):
				emit_signal("sync_interacted", self)


func set_active() -> void:
	(active_light.material_override as SpatialMaterial).albedo_color = ACTIVE_COLOR


func set_completed() -> void:
	(active_light.material_override as SpatialMaterial).albedo_color = COMPLETED_COLOR


func reset() -> void:
	(active_light.material_override as SpatialMaterial).albedo_color = INACTIVE_COLOR


func on_player_registered(body : Node) -> void:
	var player : String = body.name.to_lower() + "_"
	if not _registered_players.has(player):
		_registered_players.append(player)
		_button_sprite_3d.visible = true


func on_player_unregistered(body : Node) -> void:
	_registered_players.erase(body.name.to_lower() + "_")
	
	if _registered_players.size() == 0:
		_button_sprite_3d.visible = false
