extends Area

onready var player_node = get_node("/root/main/Player")
onready var cube = $Cube001

var outline = preload("res://Models/outline.material")
var outline_focused = preload("res://Models/outline_focused.material")


func _ready():
	unfocused()
#	interact()


func focused():
	cube.set_surface_material(1, outline_focused)

func unfocused():
	cube.set_surface_material(1, outline)


func interact():
	print("holy POOOP luisois it works!!@1!!1!!! *(not clickbait) [GONE WRONG] {GIFT CARD GIVEAWAY}")
