extends Spatial

const SPEED = 5
const JUMPSCARE_DISTANCE = 1.3

var player_pos : Vector3
var target : Vector3

onready var player_node = get_node("/root/main/Player")

func _ready():
	print(player_node)


func _physics_process(delta):
	player_pos = player_node.translation
	target = Vector3(player_pos.x, 0, player_pos.z)
	
	translate(translation.direction_to(target) * delta * SPEED)
	
	#print(translation.distance_to(player_node.translation) < JUMPSCARE_DISTANCE)
	
	if translation.distance_to(player_node.translation) < JUMPSCARE_DISTANCE:
		#jumpscare happens idk
		get_tree().reload_current_scene()

func meh():
	translate(target.direction_to(translation) * 50)
