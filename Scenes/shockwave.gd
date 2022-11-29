extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var activated := false
var counter := 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	if counter == 0:
		var j = get_overlapping_bodies()
		for i in j:
			if i.has_method("shot"):
				i.shot()
		queue_free()
	else:
		counter -= 1
#	print(get_overlapping_bodies())



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
