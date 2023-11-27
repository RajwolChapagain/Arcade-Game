extends Area2D

const SPEED = 400
var direction = Vector2.RIGHT

func _process(delta):
	position += SPEED * direction * delta
