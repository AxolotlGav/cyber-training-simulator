extends Spatial

const POWERUP_COOLDOWN := 2.5
const EXTRA_TIME_COOLDOWN := 6.0

onready var container = $ViewportContainer
onready var viewport = $ViewportContainer/Viewport
onready var ui_timer = $Control/V/H/timer
onready var ui_power = $Control/V/H/power
onready var ui_score = $Control/V/H/score
onready var ui_timer_note = $Control/V/H2/timer_note
onready var ui_power_note = $Control/V/H2/power_note
onready var ui_score_note = $Control/V/H2/score_note

onready var sfx_enemy_die = $sfx/enemy_die
onready var sfx_extra_time = $sfx/extra_time
onready var sfx_start = $sfx/start
onready var sfx_bgm = $sfx/bgm

onready var player = $Player

var viewport_initial_size := Vector2()

var enemy = preload("res://Scenes/enemy.tscn")
var pickup = preload("res://Scenes/pickup.tscn")
var extra_time = preload("res://Scenes/pickup_extra_time.tscn")

var score := 0
var modifier := 0

var timer := 45.0

var powerup_cooldown := 0.0
var extra_time_cooldown := 0.0

func _ready():
	#warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
	viewport_initial_size = viewport.size
#	OS.window_maximized = true
	container.set_margin(MARGIN_RIGHT, get_viewport().get_size().x)
	container.set_margin(MARGIN_BOTTOM, get_viewport().get_size().y)
	
	sfx_start.play()
	
	
	randomize()
	for i in 300:
		spawn()

func _process(delta):
	timer -= delta
	powerup_cooldown -= delta
	extra_time_cooldown -= delta
	
	ui_timer.set_text(str(stepify(timer, 0.01)))
	ui_score.set_text(str(score))
	
	if player.is_airborn:
		modifier = 100
		ui_score_note.set_text("AIRBORNE BONUS x2!") #wow i noticed the typo RIGHT AFTER writing all these variables THANK GOD I CAUGHT THAT
	elif player.is_bhop:
		modifier = 50
		ui_score_note.set_text("BHOP BONUS x1.5!")
	else:
		modifier = 0
		ui_score_note.set_text(" ")
	
	if timer <= 0:
		end_game()
	
	if powerup_cooldown <= 0:
		spawn_powerup()
		powerup_cooldown = POWERUP_COOLDOWN
	
	if extra_time_cooldown <= 0:
		spawn_extra_time()
		extra_time_cooldown = EXTRA_TIME_COOLDOWN

func add_time(time):
	timer += time
	sfx_extra_time.play()

func power_ui(text, text2):
	ui_power.set_text(text)
	ui_power_note.set_text(text2)

func spawn(): #spawn an enemy
	var enemy_instance = enemy.instance()
	enemy_instance.translation = Vector3(rand_range(-105, 105), 0, rand_range(-105, 105))
	add_child(enemy_instance)

func spawn_powerup():
	var pickup_instance = pickup.instance()
	pickup_instance.translation = Vector3(rand_range(-105, 105), 0, rand_range(-105, 105))
	add_child(pickup_instance)

func spawn_extra_time():
	var pickup_instance = extra_time.instance()
	pickup_instance.translation = Vector3(rand_range(-105, 105), 0, rand_range(-105, 105))
	add_child(pickup_instance)

func oof(): #if an enemy dies, spawn another one and add to the score
	spawn()
	add_score()
	sfx_enemy_die.play()

func add_score(): #add score; if player is bhopping, add more score; if player is high up, add even more score
	score += 100 + modifier
	print(score)

func end_game():
	vars.total_score = score
	get_tree().change_scene("res://Scenes/menu.tscn")


func _root_viewport_size_changed():
	container.set_margin(MARGIN_RIGHT, get_viewport().get_size().x)
	container.set_margin(MARGIN_BOTTOM, get_viewport().get_size().y)
	pass


func _on_void_body_entered(body): #if the player has a skill issue, end the game
	if body.has_method("walk"):
		end_game()
