extends Node2D

const RADIUS = 100

func _ready():
	var angle = 2 * PI / get_child_count()
	var distance_vector = Vector2(RADIUS, 0)
	var current_angle = 0
	
	for child in get_children():
		child.position = distance_vector.rotated(current_angle)
		current_angle += angle
