extends Area

const SPEED := 23

onready var player_node = get_node("/root/main/Player/Head")

var dir :Vector3

func _ready():
	#PLAY BFG SOUND
	dir = Vector3.FORWARD.rotated(Vector3.UP, deg2rad(player_node.rotation_degrees.y))
	pass

func _physics_process(delta):
	translate(dir * SPEED * delta)


func _on_bfg_body_entered(body):
	if body.has_method("shot"):
		body.shot()
