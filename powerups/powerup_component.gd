extends Area2D

@export var emitted_values = []
var linear_velocity = 0
var angular_velocity = 0

signal collected(player, emitted_values)

func _physics_process(delta):
	position += linear_velocity * delta
	rotation_degrees += angular_velocity * delta

func _on_body_entered(body):
	if body.is_in_group("ship") or body.is_in_group("bullet"):
		if body.owner_player == 1:
			collected.emit(1, emitted_values)
		else:
			collected.emit(2, emitted_values)
		queue_free()
