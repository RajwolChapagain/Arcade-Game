extends Area2D

const SPEED = 400
var direction = Vector2.RIGHT

func _process(delta):
	position += SPEED * direction * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
