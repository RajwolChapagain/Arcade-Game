extends CharacterBody2D

@export var SPEED = 3000
var direction = transform.x

func _physics_process(delta):
	move_and_collide(direction * SPEED * delta)

func set_direction(new_direction):
	direction = new_direction
