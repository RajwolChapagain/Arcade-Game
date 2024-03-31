extends CharacterBody2D

var linear_velocity = 0
var direction = Vector2.RIGHT
var angular_velocity:
	get:
		return angular_velocity
	set(_value):
		angular_velocity = 0

func _process(delta):
	velocity = linear_velocity * direction
	move_and_collide(velocity * delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func on_bullet_hit():
	$HitSound.play()
