extends Line2D

@export var max_length = 20
@export var distance_between_points = 2

func _physics_process(delta):
	if position.distance_to(points[points.size()- 1]) >= distance_between_points:
		add_point(position)
	
	if points.size() > max_length / distance_between_points:
		remove_point(0)
