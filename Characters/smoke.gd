extends KinematicBody2D

export (int) var weight = 1200
export (int) var fall_speed = 200
export (int) var air_speed = 200
export (int) var ground_speed = 100
export (int) var max_speed = ground_speed
export (int) var jumps = 2
export (int) var jump_speed = 2000
export (int) var short_hop_speed = 1000
export (float) var air_lerp = 0.2

onready var floor_raycasts = $FloorRaycasts
onready var sprite = $AnimatedSprite
onready var dash_timer = $DashTimer
onready var label = $Label
onready var turn_timer = $TurnTimer
onready var idle_buffer_timer = $IdleBufferTimer/
onready var short_hop_timer = $ShortHopTimer
onready var stage = get_parent()

var velocity = Vector2(0,0)
var stick_buffer = []
var x_direction = 0
var y_direction = 0
var jump_pressed = false


const UP = Vector2(0,-1)


func _physics_process(delta):
	#apply_gravity()
	get_input(delta)
	move_and_slide(velocity, UP)

func get_input(delta):
	if Input.is_action_pressed('left'):
		x_direction = -1
	if Input.is_action_pressed('right'):
		x_direction = 1
	if Input.is_action_just_pressed('jump'):
		y_direction = 1
	elif Input.is_action_pressed('crouch'):
		y_direction = -1
	else:
		y_direction = 0
	if !Input.is_action_pressed('left') and !Input.is_action_pressed("right") and !Input.is_action_just_pressed('jump'):
		x_direction = 0
	if Input.is_action_just_pressed("crouch"):
		set_fall_through_platform(false)
		
	if Input.is_action_just_released('crouch'):
		set_fall_through_platform(true)
		

func apply_gravity():
	#if !check_on_floor():
	if !is_on_floor():
		velocity.y += fall_speed

func jump(full = true):
	if full:
		velocity.y = -jump_speed
	else:
		velocity.y = -short_hop_speed

func move(direction, delta):
	velocity.x = ground_speed * direction * delta

func check_on_floor():
	
	for raycast in floor_raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false

func set_fall_through_platform(set):
	print(set)
	set_collision_mask_bit(2, set)
	for raycast in floor_raycasts.get_children():
		print(set)
		raycast.set_collision_mask_bit(2, set)

func respawn():
	self.position = stage.spawn.position

func _on_death_zone_area_entered(area):
	print('died')
	respawn()


func _on_death_zone_body_entered(body):
	print('died')
	respawn()
