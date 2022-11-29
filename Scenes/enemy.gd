extends KinematicBody

const SPEED := 6

var health := 1

onready var main_node = get_node("/root/main")

func _ready():
	pass

func _physics_process(delta):
	pass

func shot():
	health -= 1
	if health == 0:
		main_node.oof()
		queue_free()
