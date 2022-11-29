extends KinematicBody

enum {POWER_NOTHING, POWER_BOMB, POWER_BFG, POWER_RAM, POWER_SMG}

const MAX_SPEED = 20         # 11
const MAX_RUNNING_SPEED = 13 # 20
const MAX_BHOP_SPEED = 36    # 40
const RAM_MODIFIER = 1.2
const ACCEL = 10
const DEACCEL = 15

const JUMP_HEIGHT = 15
const JUMP_BUFFER := 0.3
const BHOP_BUFFER := 0.12
const BHOP_STREAK_BREAK := 0.15
const HEIGHT_THRESHOLD := 4.3

const MEH_COOLDOWN_SECONDS = 15

const PREFAB_SHOCKWAVE = preload("res://Scenes/shockwave.tscn")
const PREFAB_BFG = preload("res://Scenes/bfg.tscn")

var camera_angle = 0
var mouse_sensitivity = 0.15 #0.2 #0.17
var velocity = Vector3()
var direction = Vector3()
var gravity = -9.8 * 3.5
var jump_buffer := 0.0
var is_bhop = false
var bhop_chain = 0.0

var is_mouse_focused : bool = true

var cooldown = 0

var hand_camera_initial_size :Vector2

var current_powerup = POWER_NOTHING
var powerup_amount := 15.0

var is_airborn := false # REGULAR JUMPING HEIGHT: 4.186274, MAX JUMPING HEIGHT: 9.14

var debug := 0.0

onready var main = get_node("/root/main")

onready var gun_animation = get_node("/root/main/ViewportContainer/Viewport/Camera/GunHand/AnimationPlayer")
onready var ray = $Head/Camera/interact
onready var ray_shoot = $Head/Camera/shoot
onready var area = $Area

onready var sound_jump = $jump
onready var sound_shoot = $shoot
onready var sound_powerup = $powerup
onready var sound_explosion = $explosion

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_mouse_focused = false
#		get_tree().quit()

	if Input.is_action_just_pressed("restart"):
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("click"):
		if is_mouse_focused:
			shoot()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			is_mouse_focused = true
	
	if Input.is_action_just_pressed("right_click"):
		if is_mouse_focused:
			match current_powerup:
				POWER_BOMB:
					bomb()
				POWER_BFG:
					bfg()
	
	process_cooldowns(delta)
	
	if is_mouse_focused:
		walk(delta)
	
	update_power_ui()
	
	debug()


func _input(event):
	# mouse movement for looking around
	# TODO: FIX MOVING LOOKING DOWNWARDS
	if event is InputEventMouseMotion and is_mouse_focused:
		$Head.rotate_y(deg2rad(event.relative.x * -mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		else:
			pass

# walking lmao
func walk(delta):
	direction = Vector3()
	
	var aim = $Head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	
	direction = direction.normalized()
	
	velocity.y += gravity * delta
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	if is_bhop:
		speed = MAX_BHOP_SPEED
	elif Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER
	
	if is_on_floor():
		bhop_chain -= delta
		if is_bhop == true:
			is_bhop = false
			bhop_chain = BHOP_STREAK_BREAK
		is_airborn = false
		
	
	if jump_buffer > 0 and is_on_floor():
		velocity.y = JUMP_HEIGHT
		if (jump_buffer > (JUMP_BUFFER - BHOP_BUFFER) and jump_buffer != JUMP_BUFFER) or bhop_chain > 0:
			is_bhop = true
			sound_jump.play()
	
	if translation.y > HEIGHT_THRESHOLD:
		is_airborn = true
	
	
	jump_buffer -= delta
	
	

func shoot():
	if ray_shoot.is_colliding():
		if ray_shoot.get_collider().has_method("shot"):
			ray_shoot.get_collider().shot()
	gun_animation.play("shoot")
	sound_shoot.play()


func powerup():
	sound_powerup.play()
	var i = (randi() % 3) + 1
	match i:
		1: #BOMB
			current_powerup = POWER_BOMB
			powerup_amount = 6
			print("lmap oil and rope")
		2: #BFG
			current_powerup = POWER_BFG
			print("i'm gonna geoff")
		3: #RAM
			current_powerup = POWER_RAM
			powerup_amount = 15.0
			print("mooooooo")
#		4: #TIME
#			get_node("/root/main").add_time(10.0)
#			print("time time")

func powerdown():
	#PLAY POWERDOWN SOUND
	current_powerup = POWER_NOTHING
	powerup_amount = 0
	print("boowomp")


func bomb():
	if ray_shoot.is_colliding():
		var shockwave_instance = PREFAB_SHOCKWAVE.instance()
		get_tree().current_scene.add_child(shockwave_instance)
		shockwave_instance.set_translation(ray_shoot.get_collision_point())
	powerup_amount -= 1
	sound_explosion.play()
	if powerup_amount <= 0:
		powerdown()

func bfg():
	var bfg_instance = PREFAB_BFG.instance()
	get_tree().current_scene.add_child(bfg_instance)
	bfg_instance.set_translation(Vector3(translation.x, 0, translation.z))
	current_powerup = POWER_NOTHING


# called every frame; it just lowers all of the cooldowns to 0
func process_cooldowns(delta):
	# decreases the cooldown; each whole number is one second.
	cooldown = max(cooldown - delta, 0)
	
	if current_powerup == POWER_RAM:
		powerup_amount -= delta
		
		if powerup_amount <= 0:
			powerdown()


func update_power_ui():
	match current_powerup:
		POWER_NOTHING:
			main.power_ui(" ", " ")
		POWER_BOMB:
			main.power_ui("BOMBS!", str(powerup_amount))
		POWER_BFG:
			main.power_ui("RELEASE THE GEOFF!", " ")
		POWER_RAM:
#			main.power_ui("RAM EVERYTHING!", "15")
			main.power_ui("RAM EVERYTHING!", str(stepify(powerup_amount, 1)))


func debug():
	pass


func _on_Area_body_entered(body):
	if body.has_method("shot") and current_powerup == POWER_RAM:
		body.shot()
