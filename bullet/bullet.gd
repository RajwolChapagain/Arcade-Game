extends CharacterBody2D

@export var SPEED = 4000
@export var DAMAGE = 10

var direction = transform.x

func _physics_process(delta):
	var collision = move_and_collide(direction * SPEED * delta)
	
	if collision != null:
		if collision.get_collider().has_method("on_hit"):
			collision.get_collider().on_hit(DAMAGE)
			queue_free()

func set_direction(new_direction):
	direction = new_direction

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
