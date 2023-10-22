extends CharacterBody2D

@export var TOP_SPEED = 1500
@export var ACCELERATION = 1000 #Per second. Multiply by delta
@export var DECELERATION = 800 #Per second. Multiply by delta
@export var ROTATION_SPEED = 270 #Degrees per second. Multiply by delta
var current_speed = 0
var thrust_direction = transform.x

func _physics_process(delta):
	get_input(delta)
	velocity = thrust_direction * current_speed
	move_and_slide()

func get_input(delta):
	if Input.is_action_pressed("thrust"):
		current_speed += ACCELERATION * delta
		thrust_direction = transform.x
	else:
		current_speed -= DECELERATION * delta
		
	current_speed = clamp(current_speed, 0, TOP_SPEED)
	
	var rotation_direction = Input.get_axis("rotate_anticlockwise", "rotate_clockwise")
	rotation_degrees += rotation_direction * ROTATION_SPEED * delta
