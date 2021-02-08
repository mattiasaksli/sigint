extends Spatial

var SPEED : float = 50
var RADIUS : float = 0.75

var direction : Vector3
var attack_damage : int

var ref_shot_by_player : Spatial

onready var ref_player1 : Spatial = $"../../Player1"
onready var ref_player2 : Spatial = $"../../Player2"
onready var ref_player3 : Spatial = $"../../Player3"

func init(dir : Vector2, dmg : int, player: Spatial):
	# Used to set the intial direction vector of the bullet from the player script
	direction = Vector3(dir.x, dir.y, 0).normalized()
	attack_damage = dmg
	ref_shot_by_player = player

func _process(delta):
	translation += direction * SPEED * delta
	
	handle_if_collided_with_player()
	handle_if_out_of_bounds()

func handle_if_collided_with_player():
	if ref_shot_by_player != ref_player1 and (ref_player1.translation - translation).length_squared() < 3:
		ref_player1.take_damage(attack_damage)
		queue_free()
	if ref_shot_by_player != ref_player2 and (ref_player2.translation - translation).length_squared() < 3:
		ref_player2.take_damage(attack_damage)
		queue_free()
	if ref_shot_by_player != ref_player3 and (ref_player3.translation - translation).length_squared() < 3:
		ref_player3.take_damage(attack_damage)
		queue_free()
	
	# TODO: add small score bonus for shooting player

func handle_if_out_of_bounds():
	if translation.x < -50.5 or translation.y < -32.5 or translation.x > 50.5 or translation.y > 32.5:
		queue_free()
