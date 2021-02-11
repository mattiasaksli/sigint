extends Spatial

var SPEED : float = 50
var RADIUS : float = 0.75

var direction : Vector3
var attack_damage : int

onready var ref_player1 : Spatial = $"../../Player1"
onready var ref_player2 : Spatial = $"../../Player2"
onready var ref_player3 : Spatial = $"../../Player3"

func init(dir : Vector2, dmg : int, player: Spatial):
	direction = Vector3(dir.x, dir.y, 0).normalized()
	attack_damage = dmg

func _process(delta):
	translation += direction * SPEED * delta
	
	handle_if_collided_with_player()
	handle_if_out_of_bounds()

func handle_if_collided_with_player():
	if (ref_player1.translation - translation).length_squared() < 3:
		ref_player1.take_damage(attack_damage)
		queue_free()
	if (ref_player2.translation - translation).length_squared() < 3:
		ref_player2.take_damage(attack_damage)
		queue_free()
	if (ref_player3.translation - translation).length_squared() < 3:
		ref_player3.take_damage(attack_damage)
		queue_free()

func handle_if_out_of_bounds():
	if translation.x < -50.5 or translation.y < -32.5 or translation.x > 50.5 or translation.y > 32.5:
		queue_free()
