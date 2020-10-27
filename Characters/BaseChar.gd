extends KinematicBody2D

export (int) var weight



var velocity = Vector2(0,0)
var stick_buffer = []

const UP = Vector2(0,-1)
const GROUND_SPEED = 1200

func _physics_process(delta):
	
	
	move_and_slide(velocity, UP)





func check_on_floor():
	pass

