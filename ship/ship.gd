extends CharacterBody2D

@export var TOP_SPEED = 1500
@export var ACCELERATION = 1000 #Per second. Multiply by delta
@export var DECELERATION = 800 #Per second. Multiply by delta
@export var ROTATION_SPEED = 270 #Degrees per second. Multiply by delta
@export var hp = 100
var current_speed = 0
var thrust_direction = transform.x

var BULLET_SCENE = preload("res://bullet/bullet.tscn")

signal bullet_fired(bullet, direction, location)

func _physics_process(delta):
	get_input(delta)
	velocity = thrust_direction * current_speed
	move_and_slide()

func _input(event):
	if event.is_action_pressed("fire"):
		bullet_fired.emit(BULLET_SCENE, transform.x, global_position)
	
func get_input(delta):
	#-----------Thrust-------------------
	if Input.is_action_pressed("thrust"):
		current_speed += ACCELERATION * delta
		thrust_direction = transform.x
	else:
		current_speed -= DECELERATION * delta
		
	current_speed = clamp(current_speed, 0, TOP_SPEED)
	
	#------------Rotation-----------------
	var rotation_direction = Input.get_axis("rotate_anticlockwise", "rotate_clockwise")
	rotation_degrees += rotation_direction * ROTATION_SPEED * delta
	
func on_hit(damage):
	hp -= damage
	
	if hp <= 0:
		die()
		
func die():
	queue_free()
