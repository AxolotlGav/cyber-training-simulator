extends Control

onready var score_label = $Label2

onready var sound_end = $end

func _ready():
	print(vars.total_score)
	score_label.set_text(" ") #completely set the label blank if the game started up
	if vars.total_score != 0:
		sound_end.play()
		score_label.set_text("Your Score: {s}".format({"s": str(vars.total_score)}))
		JavaScript.eval("postScore('Score',%s)" % vars.total_score)
	
	JavaScript.eval("initSession()")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta):
	if Input.is_action_just_pressed("jump"):
		get_tree().change_scene("res://Scenes/testing.tscn")
