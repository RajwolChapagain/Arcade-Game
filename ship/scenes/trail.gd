extends Line2D

@export var max_length = 20

func _physics_process(delta):
	if points.size() > max_length:
		remove_point(0)
