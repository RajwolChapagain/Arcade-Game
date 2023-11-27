extends Area2D

var linear_velocity = 0
var direction = Vector2.RIGHT
var angular_velocity:
	get:
		return angular_velocity
	set(value):
		angular_velocity = 0

func _process(delta):
	position += linear_velocity * direction * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
